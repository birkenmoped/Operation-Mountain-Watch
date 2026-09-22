local Runtime=dofile("scripts/campaign/OMW_FireSupStratResupply_ArtySelectionRuntime.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local targetCoordinate={marker="TARGET"}
local selectionMission={_omwFssrArtyTarget={coordinate=targetCoordinate,shots=6,radiusM=80}}
local factory={}
function factory:Create(demand,context)
  eq(context.marker,"CTX","factory context")
  return selectionMission,true,nil
end

local legion={alias="BDE_BLUE_GND_WRIGHT"}
local asset={spawngroupname="ARTY_BLUE_WRIGHT_L118_01",isReserved=false}
local commander={can=true,recruit=true,addMissionCount=0}
function commander:CanMission(mission) eq(mission,selectionMission,"selection mission"); return self.can end
function commander:RecruitAssetsForMission(mission)
  eq(mission,selectionMission,"recruit mission")
  if not self.recruit then return false,{},{} end
  asset.isReserved=true
  return true,{asset},{[legion.alias]=legion}
end
function commander:AddMission() self.addMissionCount=self.addMissionCount+1 end

local releases=0
local function releaseAssets(assets)
  eq(#assets,1,"release cardinality")
  eq(assets[1],asset,"released asset")
  assets[1].isReserved=false
  releases=releases+1
end

local arty={assignCalls={},removeCalls={}}
function arty:AssignTargetCoord(coord,prio,radius,shots,maxengage,time,weapontype,name,unique)
  self.assignCalls[#self.assignCalls+1]={coord=coord,prio=prio,radius=radius,shots=shots,maxengage=maxengage,name=name,unique=unique}
  return name
end
function arty:RemoveTarget(name) self.removeCalls[#self.removeCalls+1]=name end

local runtime=Runtime.New({
  commander=commander,
  artyMissionFactory=factory,
  resolveFunctionalArty=function(selectedAsset,selectedLegion,demand,context,mission)
    eq(selectedAsset,asset,"selected asset")
    eq(selectedLegion,legion,"selected legion")
    eq(mission,selectionMission,"resolver mission")
    return {arty=arty,priority=7,maxEngagements=1,acceptedShots=4,acceptedRadiusM=60}
  end,
  releaseAssets=releaseAssets,
})

local demand={demandId="D|ARTY|1",supportType="ARTY",siteId="COP_HONAKER"}
local handle,created,reason=runtime:Dispatch(demand,{marker="CTX"})
yes(created,"selection dispatched")
eq(reason,nil,"selection reason")
eq(commander.addMissionCount,0,"selection-only path must not queue AUFTRAG")
eq(#arty.assignCalls,1,"functional ARTY assignment count")
eq(arty.assignCalls[1].coord,targetCoordinate,"functional target coordinate")
eq(arty.assignCalls[1].prio,7,"owner priority")
eq(arty.assignCalls[1].radius,60,"accepted radius")
eq(arty.assignCalls[1].shots,4,"accepted shots")
eq(arty.assignCalls[1].maxengage,1,"max engagements")
yes(asset.isReserved,"selected asset remains reserved while firing")
eq(releases,0,"no early release")

arty:OnAfterOpenFire(nil,nil,nil,nil,{name=runtime:GetState(demand.demandId).targetName})
yes(runtime:GetState(demand.demandId).started,"fire started")
arty:OnAfterCeaseFire(nil,nil,nil,nil,{name=runtime:GetState(demand.demandId).targetName})
yes(runtime:GetState(demand.demandId).completed,"fire completed")
no(asset.isReserved,"selection released after cease fire")
eq(releases,1,"one release after cease fire")
no(handle:Cancel("LATE"),"completed handle not cancellable")

commander.can=false
local none,noneCreated,noneReason=runtime:Dispatch({demandId="D|ARTY|2",supportType="ARTY"},{marker="CTX"})
eq(none,nil,"incapable no handle")
no(noneCreated,"incapable not dispatched")
eq(noneReason,"NO_CAPABLE_ARTY_PROVIDER","incapable reason")
commander.can=true

commander.recruit=false
local busy,busyCreated,busyReason=runtime:Dispatch({demandId="D|ARTY|3",supportType="ARTY"},{marker="CTX"})
eq(busy,nil,"unavailable no handle")
no(busyCreated,"unavailable not dispatched")
eq(busyReason,"NO_AVAILABLE_ARTY_PROVIDER","unavailable reason")
commander.recruit=true

local runtimeMissing=Runtime.New({
  commander=commander,
  artyMissionFactory=factory,
  resolveFunctionalArty=function() return nil,"SELECTED_ARTY_NOT_MATERIALIZED" end,
  releaseAssets=releaseAssets,
})
local missing,missingCreated,missingReason=runtimeMissing:Dispatch({demandId="D|ARTY|4",supportType="ARTY"},{marker="CTX"})
eq(missing,nil,"missing owner no handle")
no(missingCreated,"missing owner not dispatched")
eq(missingReason,"SELECTED_ARTY_NOT_MATERIALIZED","missing owner reason")
no(asset.isReserved,"missing owner releases selection")
eq(releases,2,"missing owner release")

local runtimeCancel=Runtime.New({
  commander=commander,
  artyMissionFactory=factory,
  resolveFunctionalArty=function() return {arty=arty} end,
  releaseAssets=releaseAssets,
})
local cancelHandle,cancelCreated=runtimeCancel:Dispatch({demandId="D|ARTY|5",supportType="ARTY"},{marker="CTX"})
yes(cancelCreated,"cancel fixture dispatched")
yes(asset.isReserved,"cancel fixture reserved")
yes(cancelHandle:Cancel("INCIDENT_CLOSED"),"queued cancel accepted")
eq(#arty.removeCalls,1,"functional target removed")
no(asset.isReserved,"queued cancel releases selection")
eq(releases,3,"queued cancel release")
no(cancelHandle:Cancel("DUP"),"cancel idempotent")

print("PASS test_fire_support_strategic_resupply_arty_selection_runtime")
