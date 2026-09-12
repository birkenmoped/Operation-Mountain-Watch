local Base=dofile("scripts/campaign/OMW_FireSupStratResupply_Base.lua")
local Lifecycle=dofile("scripts/campaign/OMW_FireSupStratResupply_LifecycleAdapter.lua")
local Bridge=dofile("scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua")
local Sites=dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local Profiles=dofile("scripts/campaign/OMW_FireSupStratResupply_SupportProfiles.lua")
local Ids=dofile("scripts/campaign/OMW_FireSupStratResupply_IdContract.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end

local commander={missions={},transports={}}
function commander:AddMission(v) table.insert(self.missions,v) end
function commander:AddOpsTransport(v) table.insert(self.transports,v) end
local function runtime() local r={cancelCount=0}; function r:Cancel() self.cancelCount=self.cancelCount+1 end; return r end
local adapters={}
for _,t in ipairs({"GUARD","QRF","ARTY","CAS"}) do adapters[t]=Bridge.New({commander=commander,kind=Bridge.Kind.MISSION,factory=function() return runtime() end}) end
for _,t in ipairs({"GROUND_RESUPPLY","AIR_RESUPPLY"}) do adapters[t]=Bridge.New({commander=commander,kind=Bridge.Kind.TRANSPORT,factory=function() return runtime() end}) end

local base=Base.New({siteRegistry=Sites,supportProfiles=Profiles,idContract=Ids,lifecycleAdapter=Lifecycle.New(),adapters=adapters})
local incident,created=base:OpenIncident({siteId="FOB_JOYCE",incidentKey="000001"})
yes(created,"incident created")
eq(#incident.demandIds,0,"OpenIncident does not auto-dispatch support")
eq(#commander.missions,0,"no mission before explicit demand")
eq(#commander.transports,0,"no transport before explicit demand")

for _,supportType in ipairs({"GUARD","QRF","ARTY","CAS"}) do
  local demand,requested=base:RequestSupport(incident.incidentId,supportType,{})
  yes(requested,supportType.." requested")
  eq(demand.supportType,supportType,supportType.." type")
end

local groundDemand,groundRequested=base:RequestSupport(incident.incidentId,"GROUND_RESUPPLY",{resourceId=Profiles.ResourceId.PERSONNEL,quantity=12})
yes(groundRequested,"ground resupply requested")
eq(groundDemand.resourceId,Profiles.ResourceId.PERSONNEL,"ground resource")
local airDemand,airRequested=base:RequestSupport(incident.incidentId,"AIR_RESUPPLY",{resourceId=Profiles.ResourceId.AMMO,quantity=15})
yes(airRequested,"air resupply requested")
eq(airDemand.resourceId,Profiles.ResourceId.AMMO,"air resource")

eq(#incident.demandIds,6,"six explicit support demands")
eq(#commander.missions,4,"four MOOSE missions")
eq(#commander.transports,2,"two MOOSE transports")

local duplicate,duplicateCreated,duplicateReason=base:RequestSupport(incident.incidentId,"CAS",{})
eq(duplicateCreated,false,"duplicate CAS not recreated")
eq(duplicateReason,"ALREADY_REQUESTED","duplicate CAS reason")
local followOn,followOnCreated=base:RequestSupport(incident.incidentId,"ARTY",{requestKey="FOLLOWON-1"})
yes(followOnCreated,"follow-on ARTY requested")
eq(followOn.demandId,Ids.Demand(incident.incidentId,"ARTY","FOLLOWON-1"),"follow-on stable ID")
eq(#commander.missions,5,"follow-on mission submitted")

local _,badResource,badReason=base:RequestSupport(incident.incidentId,"AIR_RESUPPLY",{requestKey="BAD",resourceId="UNREGISTERED"})
eq(badResource,false,"unknown resource rejected")
eq(badReason,"RESOURCE_NOT_ALLOWED","unknown resource reason")

local casId=Ids.Demand(incident.incidentId,"CAS")
local _,expired=base:ExpireDemand(casId,"TEST")
yes(expired,"CAS expiry forwarded")
local _,closed=base:CloseIncident(incident.incidentId,"TEST")
yes(closed,"incident closed")
local _,afterClose,afterCloseReason=base:RequestSupport(incident.incidentId,"QRF",{requestKey="LATE"})
eq(afterClose,false,"support after close rejected")
eq(afterCloseReason,"INCIDENT_CLOSED","closed incident reason")

print("PASS test_fire_support_strategic_resupply_gate3")
