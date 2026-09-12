local Base=dofile("scripts/campaign/OMW_FireSupStratResupply_Base.lua")
local Lifecycle=dofile("scripts/campaign/OMW_FireSupStratResupply_LifecycleAdapter.lua")
local Bridge=dofile("scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua")
local Sites=dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local Profiles=dofile("scripts/campaign/OMW_FireSupStratResupply_SupportProfiles.lua")
local Ids=dofile("scripts/campaign/OMW_FireSupStratResupply_IdContract.lua")

local commander={missions={},transports={}}
function commander:AddMission(v) table.insert(self.missions,v) end
function commander:AddOpsTransport(v) table.insert(self.transports,v) end
local function runtime() local r={n=0}; function r:Cancel() self.n=self.n+1 end; return r end
local adapters={}
for _,t in ipairs({"GUARD","QRF","ARTY","CAS"}) do adapters[t]=Bridge.New({commander=commander,kind=Bridge.Kind.MISSION,factory=function() return runtime() end}) end
for _,t in ipairs({"GROUND_RESUPPLY","AIR_RESUPPLY"}) do adapters[t]=Bridge.New({commander=commander,kind=Bridge.Kind.TRANSPORT,factory=function() return runtime() end}) end
local base=Base.New({siteRegistry=Sites,supportProfiles=Profiles,idContract=Ids,lifecycleAdapter=Lifecycle.New(),adapters=adapters})
local incident,created=base:OpenIncident({siteId="FOB_JOYCE",incidentKey="000001"})
assert(created==true)
assert(#incident.demandIds==6)
assert(#commander.missions==4)
assert(#commander.transports==2)
local casId=Ids.Demand(incident.incidentId,"CAS")
local _,expired=base:ExpireDemand(casId,"TEST")
assert(expired==true)
local _,closed=base:CloseIncident(incident.incidentId,"TEST")
assert(closed==true)
print("PASS test_fire_support_strategic_resupply_gate3")
