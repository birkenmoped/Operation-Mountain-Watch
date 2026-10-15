local Base = dofile("scripts/campaign/OMW_FireSupStratResupply_Base.lua")

local function eq(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", message, tostring(expected), tostring(actual)), 2)
  end
end

local dispatchCount = 0
local lifecycle = {}
function lifecycle:Register() end
function lifecycle:Cancel() return nil,false,"CANCEL_NOT_APPLICABLE" end

local idContract = {}
function idContract.Incident(siteId,key) return siteId .. ":" .. key end
function idContract.Demand(incidentId,supportType,key)
  return incidentId .. ":" .. supportType .. ":" .. tostring(key)
end
function idContract.SiteDemand(siteId,supportType,key)
  return siteId .. ":" .. supportType .. ":" .. key
end

local base = Base.New({
  siteRegistry = {
    Sites = {FOB_WRIGHT={
      siteId="FOB_WRIGHT",
      supportProfileId="GROUND_INSTALLATION_STANDARD",
      campaignNodeId="GROUND_NODE_WRIGHT",
    }},
  },
  supportProfiles = {
    Profiles = {GROUND_INSTALLATION_STANDARD={
      support={
        artillery={enabled=true},
        cas={enabled=true},
      },
    }},
  },
  idContract = idContract,
  lifecycleAdapter = lifecycle,
  adapters = {
    ARTY = {
      Dispatch = function(_, demand, context)
        dispatchCount = dispatchCount + 1
        eq(context.incident.closed, true, "incident is closed")
        eq(context.requestContext.sourceTargetGroup ~= nil, true, "C2 source present")
        return {Cancel=function() return false end},true,nil
      end,
    },
  },
})

local incident,created = base:OpenIncident({
  siteId="FOB_WRIGHT", incidentKey="INCIDENT-1",
  context={sourceIncidentCoordinator={}},
})
eq(created,true,"incident created")
local closed,changed = base:CloseIncident(incident.incidentId,"PERIMETER_CLEAR")
eq(changed,true,"perimeter close")
eq(closed.closed,true,"incident marked closed")

local _,allowed1,reason1=base:RequestIncidentSupport(
  incident.incidentId,"ARTY",{requestKey="INITIAL",cancelWhenIncidentClosed=false}
)
eq(allowed1,false,"initial new demand blocked")
eq(reason1,"INCIDENT_CLOSED","initial closed reason")

local _,allowed2,reason2=base:RequestIncidentSupport(
  incident.incidentId,"CAS",{
    requestKey="UNAUTHORIZED_CAS",
    continuationAfterIncidentClose=true,
    cancelWhenIncidentClosed=false,
    context={sourceTargetGroup={}},
  }
)
eq(allowed2,false,"CAS new demand not enabled by ARTY exception")
eq(reason2,"INCIDENT_CLOSED","CAS closed reason")

local _,allowed3,reason3=base:RequestIncidentSupport(
  incident.incidentId,"ARTY",{
    requestKey="MISSING_C2",
    continuationAfterIncidentClose=true,
    cancelWhenIncidentClosed=false,
  }
)
eq(allowed3,false,"C2 target required for closed ARTY")
eq(reason3,"INCIDENT_CLOSED","C2 target absence reason")

local target={name="AUTHORIZED_RED"}
local fireDemand,allowed4=base:RequestIncidentSupport(
  incident.incidentId,"ARTY",{
    requestKey="C2_CYCLE_1",
    continuationAfterIncidentClose=true,
    cancelWhenIncidentClosed=false,
    context={sourceTargetGroup=target},
  }
)
eq(allowed4,true,"continuation allowed after incident close")
eq(fireDemand.status,"DISPATCHED","continuation dispatched by normal adapter")
eq(dispatchCount,1,"no extra dispatch")
local same,deduped,dedupeReason=base:RequestIncidentSupport(
  incident.incidentId,"ARTY",{
    requestKey="C2_CYCLE_1",
    continuationAfterIncidentClose=true,
    cancelWhenIncidentClosed=false,
    context={sourceTargetGroup=target},
  }
)
eq(same,fireDemand,"same demand on repeated request")
eq(deduped,false,"demand deduped")
eq(dedupeReason,"ALREADY_REQUESTED","dedupe reason")
eq(dispatchCount,1,"MOOSE owner still only one dispatch")

print("PASS test_fire_support_strategic_resupply_closed_arty_continuation")
