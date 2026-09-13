local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua")
local Sites = dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local LegionBridge = dofile("scripts/campaign/OMW_FireSupStratResupply_LegionBridge.lua")
local QrfFactory = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
local previousZone=ZONE
local previousZoneRadius=ZONE_RADIUS
local previousUtils=UTILS
local previousGroup=Group
local previousWarehouse=WAREHOUSE
local previousOmw=OMW

local groundAttackCalls=0
AUFTRAG={}
function AUFTRAG:NewGROUNDATTACK()
  groundAttackCalls=groundAttackCalls+1
  error("GROUNDATTACK substitution is forbidden")
end
function AUFTRAG:NewONGUARD(coordinate)
  local mission={coordinate=coordinate,cancelCount=0}
  function mission:SetTeleport(v) self.teleport=v return self end
  function mission:SetReturnToLegion(v) self.returnToLegion=v return self end
  function mission:SetRequiredAssets(a,b) self.requiredMin=a;self.requiredMax=b;return self end
  function mission:SetRequiredAttribute(v) self.requiredAttributes=v;return self end
  function mission:SetRequiredProperty(v) self.requiredProperties=v;return self end
  function mission:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function mission:SetEngageDetected(range,targetTypes,zone) self.engageRange=range;self.targetTypes=targetTypes;self.engageZone=zone;return self end
  function mission:Cancel() self.cancelCount=self.cancelCount+1 end
  return mission
end

Group={Category={GROUND=2}}
WAREHOUSE={Attribute={GROUND_INFANTRY="Ground Infantry"}}
UTILS={}
function UTILS.NMToMeters(value) return value*1852 end

local accessZones={}
ZONE={}
function ZONE:FindByName(name) return accessZones[name] end
ZONE_RADIUS={}
function ZONE_RADIUS:New(name,vec2,radius) return {name=name,vec2=vec2,radius=radius} end

local roadInstalls={}
local RoadSpawnAdapter={}
function RoadSpawnAdapter.Install(brigade,spec)
  roadInstalls[brigade.alias]=spec
  return true
end
OMW={FireSupStratResupply={Modules={roadSpawnAdapter=RoadSpawnAdapter}}}

local brigades={}
for siteId,site in pairs(Sites.Sites) do
  local accessCoordinate={marker="ACCESS_COORDINATE|"..siteId}
  function accessCoordinate:GetClosestPointToRoad() return self end
  local zone={name=site.accessZoneName}
  function zone:GetName() return self.name end
  function zone:GetCoordinate() return accessCoordinate end
  accessZones[site.accessZoneName]=zone

  local brigadeCoordinate={marker="BRIGADE_COORDINATE|"..siteId}
  function brigadeCoordinate:GetVec2() return {x=10,y=20} end
  local brigade={alias="BDE_TEST_"..siteId,missions={}}
  function brigade:SetSpawnZone(z,maxDist) self.spawnZone=z;self.spawnMaxDist=maxDist;return self end
  function brigade:GetCoordinate() return brigadeCoordinate end
  function brigade:AddMission(m) self.missions[#self.missions+1]=m return self end
  brigades[siteId]=brigade
end

local resolved={}
local roadResolved={}
local roadForward={}
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
  resolveRoadSpawnForwardCoordinate=function(siteId,site,accessZone,physicalTargetCoordinate,brigade)
    local coordinate={marker="VALIDATED_ROAD_FORWARD|"..siteId}
    roadResolved[siteId]={site=site,accessZone=accessZone,target=physicalTargetCoordinate,brigade=brigade,coordinate=coordinate}
    roadForward[siteId]=coordinate
    return coordinate
  end,
})

for siteId,site in pairs(Sites.Sites) do
  eq(brigades[siteId].spawnZone,accessZones[site.accessZoneName],siteId.." ACCESS home/spawn zone")
  eq(brigades[siteId].spawnMaxDist,1000,siteId.." spawn max distance")
  yes(roadInstalls[brigades[siteId].alias]~=nil,siteId.." road adapter installed")
  eq(runtime.engageZones[siteId].radius,5*1852,siteId.." accepted five NM QRF tactical radius")
end

local demand={demandId="INC|FOB_JOYCE|QRF",siteId="FOB_JOYCE",supportType="QRF",priority=12}
local context={marker="INCIDENT"}
local handle,created,reason=runtime:Dispatch(demand,context)
yes(created,"Joyce QRF dispatched")
eq(reason,nil,"Joyce QRF reason")
eq(#brigades.FOB_JOYCE.missions,1,"Joyce local brigade receives mission")
eq(handle.mission.coordinate,targetCoordinate,"ONGUARD starts at physical threat coordinate")
eq(handle.mission.engageRange,5,"accepted Honaker engage range")
eq(handle.mission.targetTypes[1],"Ground Units","accepted target class")
eq(handle.mission.engageZone,runtime.engageZones.FOB_JOYCE,"site tactical zone forwarded")
eq(handle.mission.teleport,false,"QRF teleport disabled")
eq(handle.mission.returnToLegion,true,"accepted MOOSE return lifecycle enabled")
eq(handle.mission.requiredMin,1,"QRF default one asset")
eq(handle.mission.requiredAttributes,requiredAttributes,"QRF required attributes forwarded")
eq(handle.mission.requiredProperties,requiredProperties,"QRF required properties forwarded")
eq(resolved[1].legion,brigades.FOB_JOYCE,"target resolver sees local brigade")
eq(runtime.targetCoordinates.FOB_JOYCE,targetCoordinate,"physical target coordinate retained for materialization correlation")
eq(groundAttackCalls,0,"GROUNDATTACK never used")

-- The injected road resolver is intentionally invoked only when MOOSE materializes
-- a mobile Ground asset. Exercise the installed adapter resolver directly here.
local roadSpec=roadInstalls[brigades.FOB_JOYCE.alias].resolveRoadSpawn(nil,{
  category=Group.Category.GROUND,speedmax=10,attribute="Ground APC"
})
yes(roadSpec~=nil,"mobile QRF road spec")
eq(roadResolved.FOB_JOYCE.target,targetCoordinate,"physical target supplied to validated road resolver")
eq(roadResolved.FOB_JOYCE.accessZone,accessZones[Sites.Sites.FOB_JOYCE.accessZoneName],"ACCESS supplied to validated road resolver")
eq(roadResolved.FOB_JOYCE.brigade,brigades.FOB_JOYCE,"brigade supplied to validated road resolver")
eq(roadSpec.forwardCoordinate,roadForward.FOB_JOYCE,"validated forward coordinate used unchanged")
eq(roadSpec.accessZone,accessZones[Sites.Sites.FOB_JOYCE.accessZoneName],"road spec keeps ACCESS zone")

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

local ok,err=pcall(function()
  Runtime.New({
    siteRegistry=Sites,brigades=brigades,qrfMissionFactory=QrfFactory,legionBridge=LegionBridge,
    resolveCoordinate=function() return target end,
  })
end)
no(ok,"runtime rejects missing validated road resolver")
yes(type(err)=="string" and err:find("resolveRoadSpawnForwardCoordinate",1,true)~=nil,"missing road resolver error")

AUFTRAG=previousAuftrag
ZONE=previousZone
ZONE_RADIUS=previousZoneRadius
UTILS=previousUtils
Group=previousGroup
WAREHOUSE=previousWarehouse
OMW=previousOmw
print("PASS test_fire_support_strategic_resupply_qrf_runtime")