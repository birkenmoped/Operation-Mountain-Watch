local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua")
local Sites = dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local LegionBridge = dofile("scripts/campaign/OMW_FireSupStratResupply_LegionBridge.lua")
local QrfFactory = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
AUFTRAG={}
function AUFTRAG:NewONGUARD(coordinate)
  local mission={coordinate=coordinate,cancelCount=0}
  function mission:SetTeleport(v) self.teleport=v return self end
  function mission:SetRequiredAssets(a,b) self.requiredMin=a;self.requiredMax=b;return self end
  function mission:SetRequiredAttribute(v) self.requiredAttributes=v;return self end
  function mission:SetRequiredProperty(v) self.requiredProperties=v;return self end
  function mission:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function mission:Cancel() self.cancelCount=self.cancelCount+1 end
  return mission
end

local brigades={}
for siteId in pairs(Sites.Sites) do
  local brigade={alias="BDE_TEST_"..siteId,missions={}}
  function brigade:AddMission(m) self.missions[#self.missions+1]=m return self end
  brigades[siteId]=brigade
end

local resolved={}
local requiredAttributes={"Ground_APC"}
local requiredProperties={"APC"}
local runtime=Runtime.New({
  siteRegistry=Sites,
  brigades=brigades,
  qrfMissionFactory=QrfFactory,
  legionBridge=LegionBridge,
  requiredAttributes=requiredAttributes,
  requiredProperties=requiredProperties,
  resolveCoordinate=function(demand,context,legion)
    resolved[#resolved+1]={demand=demand,context=context,legion=legion}
    if demand.siteId=="FOB_BOSTICK" then return nil,"QRF_RESPONSE_ANCHOR_NOT_CONFIGURED" end
    return {siteId=demand.siteId,marker="QRF_RESPONSE"}
  end,
})

local demand={demandId="INC|FOB_JOYCE|QRF",siteId="FOB_JOYCE",supportType="QRF",priority=12}
local context={marker="INCIDENT"}
local handle,created,reason=runtime:Dispatch(demand,context)
yes(created,"Joyce QRF dispatched")
eq(reason,nil,"Joyce QRF reason")
eq(#brigades.FOB_JOYCE.missions,1,"Joyce local brigade receives mission")
eq(handle.mission.coordinate.siteId,"FOB_JOYCE","response coordinate site")
eq(handle.mission.teleport,false,"QRF teleport disabled")
eq(handle.mission.requiredMin,1,"QRF default one asset")
eq(handle.mission.requiredAttributes,requiredAttributes,"QRF required attributes forwarded")
eq(handle.mission.requiredProperties,requiredProperties,"QRF required properties forwarded")
eq(resolved[1].legion,brigades.FOB_JOYCE,"coordinate resolver sees local brigade")
for siteId,brigade in pairs(brigades) do if siteId~="FOB_JOYCE" then eq(#brigade.missions,0,siteId.." untouched") end end

local unavailable,unavailableCreated,unavailableReason=runtime:Dispatch({demandId="INC|FOB_BOSTICK|QRF",siteId="FOB_BOSTICK",supportType="QRF"},{})
eq(unavailable,nil,"Bostick without response anchor no mission")
no(unavailableCreated,"Bostick not dispatched")
eq(unavailableReason,"QRF_RESPONSE_ANCHOR_NOT_CONFIGURED","Bostick reason")
eq(#brigades.FOB_BOSTICK.missions,0,"Bostick brigade receives no guessed mission")

local missing,missingCreated,missingReason=runtime:Dispatch({demandId="INC|UNKNOWN|QRF",siteId="UNKNOWN",supportType="QRF"},{})
eq(missing,nil,"unknown site no mission")
no(missingCreated,"unknown site not dispatched")
eq(missingReason,"SITE_NOT_FOUND","unknown site reason")

AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_qrf_runtime")
