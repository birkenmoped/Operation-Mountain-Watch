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
local lifecycle=Lifecycle.New()
local base=Base.New({siteRegistry=Sites,supportProfiles=Profiles,idContract=Ids,lifecycleAdapter=lifecycle,adapters=adapters})

local siteState,siteStarted=base:StartSite("FOB_JOYCE",{})
yes(siteStarted,"site security started")
eq(siteState.guardDemandId,Ids.SiteDemand("FOB_JOYCE","GUARD","PERSISTENT"),"persistent Guard demand ID")
eq(#commander.missions,1,"one persistent Guard mission")
local _,siteAgain,siteAgainReason=base:StartSite("FOB_JOYCE",{})
eq(siteAgain,false,"site security idempotent")
eq(siteAgainReason,"ALREADY_STARTED","site already-started reason")

local incident,created=base:OpenIncident({siteId="FOB_JOYCE",incidentKey="000001"})
yes(created,"incident created")
eq(#incident.demandIds,0,"OpenIncident does not auto-dispatch support")
eq(#commander.missions,1,"only persistent Guard before incident demand")
eq(#commander.transports,0,"no transport before threshold demand")

for _,supportType in ipairs({"QRF","ARTY","CAS"}) do
  local demand,requested=base:RequestIncidentSupport(incident.incidentId,supportType,{})
  yes(requested,supportType.." requested")
  eq(demand.supportType,supportType,supportType.." type")
  eq(demand.scope,"INCIDENT_RESPONSE",supportType.." scope")
end
local _,guardIncident,guardIncidentReason=base:RequestIncidentSupport(incident.incidentId,"GUARD",{})
eq(guardIncident,false,"Guard rejected as incident support")
eq(guardIncidentReason,"SUPPORT_NOT_INCIDENT_SCOPED","Guard incident rejection reason")
local _,resupplyIncident,resupplyIncidentReason=base:RequestIncidentSupport(incident.incidentId,"AIR_RESUPPLY",{})
eq(resupplyIncident,false,"Resupply rejected as incident support")
eq(resupplyIncidentReason,"SUPPORT_NOT_INCIDENT_SCOPED","Resupply incident rejection reason")

local groundDemand,groundRequested=base:RequestResupply("FOB_JOYCE","GROUND_RESUPPLY",{requestKey="PERSONNEL-REORDER-0001",resourceId=Profiles.ResourceId.PERSONNEL,quantity=12})
yes(groundRequested,"ground resupply requested")
eq(groundDemand.resourceId,Profiles.ResourceId.PERSONNEL,"ground resource")
eq(groundDemand.scope,"RESOURCE_RESUPPLY","ground resupply scope")
local airDemand,airRequested=base:RequestResupply("FOB_JOYCE","AIR_RESUPPLY",{requestKey="AMMO-REORDER-0001",resourceId=Profiles.ResourceId.AMMO,quantity=15})
yes(airRequested,"air resupply requested")
eq(airDemand.resourceId,Profiles.ResourceId.AMMO,"air resource")
eq(airDemand.incidentId,nil,"resupply independent of incident")
eq(#incident.demandIds,3,"only incident response demands attached to incident")
eq(#commander.missions,4,"Guard plus three incident MOOSE missions")
eq(#commander.transports,2,"two threshold-driven MOOSE transports")

local duplicate,duplicateCreated,duplicateReason=base:RequestIncidentSupport(incident.incidentId,"CAS",{})
eq(duplicateCreated,false,"duplicate CAS not recreated")
eq(duplicateReason,"ALREADY_REQUESTED","duplicate CAS reason")
local followOn,followOnCreated=base:RequestIncidentSupport(incident.incidentId,"ARTY",{requestKey="FOLLOWON-1"})
yes(followOnCreated,"follow-on ARTY requested")
eq(followOn.demandId,Ids.Demand(incident.incidentId,"ARTY","FOLLOWON-1"),"follow-on stable ID")
eq(#commander.missions,5,"follow-on mission submitted")

local _,badResource,badReason=base:RequestResupply("FOB_JOYCE","AIR_RESUPPLY",{requestKey="BAD",resourceId="UNREGISTERED",quantity=1})
eq(badResource,false,"unknown resource rejected")
eq(badReason,"RESOURCE_NOT_ALLOWED","unknown resource reason")

local guardEntry=lifecycle:Get(siteState.guardDemandId)
local resupplyEntry=lifecycle:Get(airDemand.demandId)
local _,closed=base:CloseIncident(incident.incidentId,"TEST")
yes(closed,"incident closed")
eq(guardEntry.cancelRequested,false,"incident close does not cancel persistent Guard")
eq(resupplyEntry.cancelRequested,false,"incident close does not cancel independent resupply")
local qrfId=Ids.Demand(incident.incidentId,"QRF")
yes(lifecycle:Get(qrfId).cancelRequested,"incident QRF cancellation forwarded")
local _,afterClose,afterCloseReason=base:RequestIncidentSupport(incident.incidentId,"QRF",{requestKey="LATE"})
eq(afterClose,false,"support after close rejected")
eq(afterCloseReason,"INCIDENT_CLOSED","closed incident reason")

print("PASS test_fire_support_strategic_resupply_gate3")
