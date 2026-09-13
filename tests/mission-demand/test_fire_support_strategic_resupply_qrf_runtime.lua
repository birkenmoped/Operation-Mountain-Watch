local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua")
local Sites = dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local LegionBridge = dofile("scripts/campaign/OMW_FireSupStratResupply_LegionBridge.lua")
local QrfFactory = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
local previousZone=ZONE
local previousGroup=Group
local previousWarehouse=WAREHOUSE
local previousOmw=OMW

AUFTRAG={}
function AUFTRAG:NewGROUNDATTACK(target)
  local mission={target=target,cancelCount=0}
  function mission:SetTeleport(v) self.teleport=v return self end
  function mission:SetReturnToLegion(v) self.returnToLegion=v return self end
  function mission:SetRequiredAssets(a,b) self.requiredMin=a;self.requiredMax=b;return self end
  function mission:SetRequiredAttribute(v) self.requiredAttributes=v;return self end
  function mission:SetRequiredProperty(v) self.requiredProperties=v;return self end
  function mission:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function mission:Cancel() self.cancelCount=self.cancelCount+1 end
  return mission
end

Group={Category={GROUND=2}}
WAREHOUSE={Attribute={GROUND_INFANTRY="Ground Infantry"}}

local accessZones={}
ZONE={}
function ZONE:FindByName(name) return accessZones[name] end

local roadInstalls={}
local RoadSpawnAdapter={}
function RoadSpawnAdapter.Install(brigade,spec)
  roadInstalls[brigade.alias]=spec
  return true
end
OMW={FireSupStratResupply={Modules={roadSpawnAdapter=RoadSpawnAdapter}}}

local brigades={}
for siteId,site in pairs(Sites.Sites) do
  local zone={name=site.accessZoneName}
  function zone:GetName() return self.name end
  function zone:GetCoordinate() return {marker="ACCESS_COORDINATE|"..siteId} end
  accessZones[site.accessZoneName]=zone

  local brigade={alias="BDE_TEST_"..siteId,missions={}}
  function brigade:SetSpawnZone(z,maxDist) self.spawnZone=z;self.spawnMaxDist=maxDist;return self end
  function brigade:AddMission(m) self.missions[#self.missions+1]=m return self end
  brigades[siteId]=brigade
end

local resolved={}
local requiredAttributes={"Ground_APC"}
local requiredProperties={"APC"}
local targetCoordinate={marker="QRF_TARGET_COORDINATE"}
local target={name="BadGuys_A3_JOYCE"}
function target:IsInstanceOf(className) return className=="GROUP" end
function target:IsAlive() return true end
function target:GetName() return self.name end
function target:GetCoordinate() return targetCoordinate end

local runtime=Runtime.New({
  siteRegistry=Sites,
  brigades=brigades,
  qrfMissionFactory=QrfFactory,
  legionBridge=LegionBridge,
  requiredAttributes=requiredAttributes,
  requiredProperties=requiredProperties,
  resolveCoordinate=function(demand,context,legion)
    resolved[#resolved+1]={demand=demand,context=context,legion=legion}
    if demand.siteId=="FOB_BOSTICK" then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
    return target
  end,
})

for siteId,site in pairs(Sites.Sites) do
  eq(brigades[siteId].spawnZone,accessZones[site.accessZoneName],siteId.." ACCESS home/spawn zone")
  eq(brigades[siteId].spawnMaxDist,1000,siteId.." spawn max distance")
  yes(roadInstalls[brigades[siteId].alias]~=nil,siteId.." road adapter installed")
end

local demand={demandId="INC|FOB_JOYCE|QRF",siteId="FOB_JOYCE",supportType="QRF",priority=12}
local context={marker="INCIDENT"}
local handle,created,reason=runtime:Dispatch(demand,context)
yes(created,"Joyce QRF dispatched")
eq(reason,nil,"Joyce QRF reason")
eq(#brigades.FOB_JOYCE.missions,1,"Joyce local brigade receives mission")
eq(handle.mission.target,target,"GROUNDATTACK physical target")
eq(handle.mission.teleport,false,"QRF teleport disabled")
eq(handle.mission.returnToLegion,true,"accepted MOOSE return lifecycle enabled")
eq(handle.mission.requiredMin,1,"QRF default one asset")
eq(handle.mission.requiredAttributes,requiredAttributes,"QRF required attributes forwarded")
eq(handle.mission.requiredProperties,requiredProperties,"QRF required properties forwarded")
eq(resolved[1].legion,brigades.FOB_JOYCE,"target resolver sees local brigade")
eq(runtime.targetCoordinates.FOB_JOYCE,targetCoordinate,"physical target coordinate retained only for road materialization")
for siteId,brigade in pairs(brigades) do if siteId~="FOB_JOYCE" then eq(#brigade.missions,0,siteId.." untouched") end end

local unavailable,unavailableCreated,unavailableReason=runtime:Dispatch({demandId="INC|FOB_BOSTICK|QRF",siteId="FOB_BOSTICK",supportType="QRF"},{})
eq(unavailable,nil,"Bostick without physical target no mission")
no(unavailableCreated,"Bostick not dispatched")
eq(unavailableReason,"QRF_PHYSICAL_TARGET_UNAVAILABLE","Bostick reason")
eq(#brigades.FOB_BOSTICK.missions,0,"Bostick brigade receives no guessed mission")

local missing,missingCreated,missingReason=runtime:Dispatch({demandId="INC|UNKNOWN|QRF",siteId="UNKNOWN",supportType="QRF"},{})
eq(missing,nil,"unknown site no mission")
no(missingCreated,"unknown site not dispatched")
eq(missingReason,"SITE_NOT_FOUND","unknown site reason")

AUFTRAG=previousAuftrag
ZONE=previousZone
Group=previousGroup
WAREHOUSE=previousWarehouse
OMW=previousOmw
print("PASS test_fire_support_strategic_resupply_qrf_runtime")