local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_Runtime.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local sites={Sites={FOB_JOYCE={siteId="FOB_JOYCE"}}}
local profiles={Profiles={}}
local ids={Incident=function() end}
local brigades={FOB_JOYCE={alias="BDE_BLUE_GND_JOYCE"}}
local marker={}
local calls={}

local modules={}
modules.guardMaterializationAdapter={New=function() end}
modules.guardRouteAdapter={New=function() end}
modules.guardMissionFactory={New=function() end}
modules.qrfMissionFactory={New=function() end}
modules.legionBridge={New=function() end}

modules.guardRuntime={}
function modules.guardRuntime.New(spec)
  calls.guardSpec=spec
  local r={}
  function r:Prepare() calls.guardPrepared=true return self,true,nil end
  function r:Dispatch() return marker,true,nil end
  return r
end
modules.qrfRuntime={}
function modules.qrfRuntime.New(spec)
  calls.qrfSpec=spec
  local r={}
  function r:Dispatch() return marker,true,nil end
  return r
end
modules.lifecycleAdapter={}
function modules.lifecycleAdapter.New(spec) calls.lifecycleSpec=spec;return {Register=function() end,Cancel=function() end} end
modules.base={}
function modules.base.New(spec)
  calls.baseSpec=spec
  local b={}
  function b:StartSite(siteId,spec2) calls.startSite={siteId=siteId,spec=spec2};return {siteId=siteId},true,nil end
  return b
end
modules.perimeterBridge={}
function modules.perimeterBridge.New(spec) calls.perimeterBridgeSpec=spec;return {HandleThreat=function() end,HandleClear=function() end} end
modules.threatAdapter={New=function() end}
modules.perimeterRuntime={}
function modules.perimeterRuntime.New(spec)
  calls.perimeterSpec=spec
  local p={}
  function p:StartAll() calls.perimetersStarted=true;return {FOB_JOYCE=true},true,nil end
  function p:StopAll() calls.perimetersStopped=true;return self,true,nil end
  return p
end

local arty={marker="ARTY"}
local runtime=Runtime.New({
  modules=modules,
  siteRegistry=sites,
  supportProfiles=profiles,
  idContract=ids,
  brigades=brigades,
  resolveGuardPathline=function() return {} end,
  resolveGuardTemplateGroup=function() return {} end,
  resolveQrfCoordinate=function() return {} end,
  externalAdapters={ARTY=arty},
  perimeters={FOB_JOYCE={anchorCoordinate={},radiusM=1000,priority=10}},
  blueCoalition=2,
  redCoalition=1,
})

local before,beforeCreated,beforeReason=runtime:StartSite("FOB_JOYCE",{})
eq(before,nil,"start before prepare nil")
no(beforeCreated,"start before prepare false")
eq(beforeReason,"RUNTIME_NOT_PREPARED","start before prepare reason")

local _,prepared,reason=runtime:Prepare()
yes(prepared,"runtime prepared")
eq(reason,nil,"prepare reason")
yes(calls.guardPrepared,"Guard runtime prepared")
eq(calls.guardSpec.brigades,brigades,"Guard receives injected brigades")
eq(calls.qrfSpec.brigades,brigades,"QRF receives injected brigades")
eq(calls.baseSpec.adapters.GUARD,runtime:GetAdapter("GUARD"),"Base GUARD adapter")
eq(calls.baseSpec.adapters.QRF,runtime:GetAdapter("QRF"),"Base QRF adapter")
eq(calls.baseSpec.adapters.ARTY,arty,"external ARTY adapter preserved")
eq(runtime:GetBase(),calls.perimeterBridgeSpec.base,"perimeter bridge uses same Base")
eq(calls.perimeterSpec.perimeters.FOB_JOYCE.radiusM,1000,"perimeter config forwarded")
eq(calls.perimeterSpec.blueCoalition,2,"blue coalition forwarded")
eq(calls.perimeterSpec.redCoalition,1,"red coalition forwarded")

local _,preparedAgain,againReason=runtime:Prepare()
no(preparedAgain,"second prepare idempotent")
eq(againReason,"ALREADY_PREPARED","second prepare reason")

local siteState,siteStarted=runtime:StartSite("FOB_JOYCE",{priority=50})
yes(siteStarted,"site start forwarded")
eq(siteState.siteId,"FOB_JOYCE","site state")
eq(calls.startSite.spec.priority,50,"site spec forwarded")
local _,perimetersStarted=runtime:StartPerimeters();yes(perimetersStarted,"perimeters started")
yes(calls.perimetersStarted,"perimeter StartAll called")
local _,perimetersStopped=runtime:StopPerimeters();yes(perimetersStopped,"perimeters stopped")
yes(calls.perimetersStopped,"perimeter StopAll called")

local noPerimeter=Runtime.New({
  modules=modules,
  siteRegistry=sites,
  supportProfiles=profiles,
  idContract=ids,
  brigades=brigades,
  resolveGuardPathline=function() return {} end,
  resolveGuardTemplateGroup=function() return {} end,
  resolveQrfCoordinate=function() return {} end,
})
noPerimeter:Prepare()
local p,pCreated,pReason=noPerimeter:StartPerimeters()
eq(p,nil,"no perimeter runtime nil")
no(pCreated,"no perimeter false")
eq(pReason,"PERIMETERS_NOT_CONFIGURED","no perimeter explicit reason")

print("PASS test_fire_support_strategic_resupply_runtime")
