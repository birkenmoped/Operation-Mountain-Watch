local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_GuardRuntime.lua")
local Sites = dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local LegionBridge = dofile("scripts/campaign/OMW_FireSupStratResupply_LegionBridge.lua")
local GuardFactory = dofile("scripts/campaign/OMW_FireSupStratResupply_GuardMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
AUFTRAG={}
function AUFTRAG:NewONGUARD(coordinate)
  local mission={coordinate=coordinate,cancelCount=0}
  function mission:SetTeleport(v) self.teleport=v return self end
  function mission:SetRequiredAssets(a,b) self.requiredMin=a;self.requiredMax=b;return self end
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

local prepared,installedMaterializer,installedRouter={},{},{}
local Materializer={}
function Materializer.New(spec)
  local m={spec=spec,lead={siteId=spec.siteId}}
  function m:Prepare() prepared[self.spec.siteId]=(prepared[self.spec.siteId] or 0)+1;return self end
  function m:Install(brigade) installedMaterializer[self.spec.siteId]=brigade;return self,true end
  function m:GetLeadCoordinate() return self.lead end
  return m
end
local Router={}
function Router.New(spec)
  local r={spec=spec,tracked=nil}
  function r:Install(brigade) installedRouter[self.spec.siteId]=brigade;return self,true end
  function r:TrackMission(mission) self.tracked=mission return self end
  return r
end

local resolvedPathlines,resolvedTemplates={},{}
local runtime=Runtime.New({
  siteRegistry=Sites,
  brigades=brigades,
  materializationAdapter=Materializer,
  routeAdapter=Router,
  guardMissionFactory=GuardFactory,
  legionBridge=LegionBridge,
  resolvePathline=function(name,siteId)
    resolvedPathlines[siteId]=name
    return {name=name}
  end,
  resolveTemplateGroup=function(name,siteId)
    resolvedTemplates[siteId]=name
    return {name=name}
  end,
})

local notReady,notReadyCreated,notReadyReason=runtime:Dispatch({demandId="early",siteId="FOB_JOYCE",supportType="GUARD"},{})
eq(notReady,nil,"dispatch before prepare has no handle")
no(notReadyCreated,"dispatch before prepare false")
eq(notReadyReason,"GUARD_RUNTIME_NOT_PREPARED","dispatch before prepare reason")

local _,didPrepare,prepareReason=runtime:Prepare()
yes(didPrepare,"first prepare")
eq(prepareReason,nil,"prepare reason")
local _,didPrepareAgain,prepareAgainReason=runtime:Prepare()
no(didPrepareAgain,"second prepare idempotent")
eq(prepareAgainReason,"ALREADY_PREPARED","second prepare reason")

local count=0
for siteId,site in pairs(Sites.Sites) do
  count=count+1
  eq(prepared[siteId],1,siteId.." materializer prepared once")
  eq(installedMaterializer[siteId],brigades[siteId],siteId.." materializer installed on local brigade")
  eq(installedRouter[siteId],brigades[siteId],siteId.." router installed on local brigade")
  eq(resolvedPathlines[siteId],site.guardRoute.pathlineName,siteId.." owner PATHLINE resolved")
  eq(resolvedTemplates[siteId],site.guardTemplateName,siteId.." Guard template resolved")
  yes(runtime:GetMaterializer(siteId)~=nil,siteId.." materializer exposed")
  yes(runtime:GetRouteAdapter(siteId)~=nil,siteId.." router exposed")
end
eq(count,6,"six sites assembled")

local demand={demandId="SITE|FOB_JOYCE|GUARD|PERSISTENT",siteId="FOB_JOYCE",supportType="GUARD",priority=40}
local handle,dispatched,reason=runtime:Dispatch(demand,{})
yes(dispatched,"Guard demand dispatched")
eq(reason,nil,"Guard dispatch reason")
eq(#brigades.FOB_JOYCE.missions,1,"Guard queued only at Joyce brigade")
eq(handle.mission.teleport,false,"Guard teleport disabled")
eq(handle.mission.requiredMin,1,"one Guard asset requested")
eq(runtime:GetRouteAdapter("FOB_JOYCE").tracked,handle.mission,"Guard route tracks MOOSE-selected mission")
for siteId,brigade in pairs(brigades) do if siteId~="FOB_JOYCE" then eq(#brigade.missions,0,siteId.." not selected for Joyce Guard") end end

-- The SiteRegistry may contain accessZoneName for convoy/resupply, but GuardRuntime
-- never reads or forwards it. Its inputs are Guard template/PATHLINE plus local BRIGADE.
AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_guard_runtime")
