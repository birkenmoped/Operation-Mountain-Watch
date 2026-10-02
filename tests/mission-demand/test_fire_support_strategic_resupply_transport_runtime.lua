local Runtime=dofile("scripts/campaign/OMW_FireSupStratResupply_ResupplyTransportRuntime.lua")
local StorageFactory=dofile("scripts/campaign/OMW_FireSupStratResupply_StorageTransportFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousTransport=OPSTRANSPORT
local previousLegion=LEGION
OPSTRANSPORT={}
function OPSTRANSPORT:New(cargo,pickup,deploy)
  local t={pickup=pickup,deploy=deploy,cancelCount=0,assets={}}
  function t:AddCargoStorage(source,dest,cargoType,amount,weight)
    self.storage={source=source,dest=dest,cargoType=cargoType,amount=amount,weight=weight};return self
  end
  function t:SetRequiredCarriers(a,b) self.min=a;self.max=b;return self end
  function t:SetPriority(p,i,u) self.priority=p;self.importance=i;self.urgent=u;return self end
  function t:AddAsset(asset) self.assets[#self.assets+1]=asset;return self end
  function t:Cancel() self.cancelCount=self.cancelCount+1 end
  return t
end

LEGION={unrecruited={}}
function LEGION.UnRecruitAssets(assets)
  LEGION.unrecruited[#LEGION.unrecruited+1]=assets
end

local function commander(tag)
  local c={tag=tag,recruitCalls={},assignCalls={},nextAsset=1,available=true}
  function c:RecruitAssetsForTransport(transport,cargoWeight,totalWeight)
    self.recruitCalls[#self.recruitCalls+1]={transport=transport,cargoWeight=cargoWeight,totalWeight=totalWeight}
    if not self.available then return false,{},{} end
    local asset={name=self.tag.."-ASSET-"..tostring(self.nextAsset)}
    self.nextAsset=self.nextAsset+1
    return true,{asset},{[self.tag]=self}
  end
  function c:TransportAssign(transport,legions)
    self.assignCalls[#self.assignCalls+1]={transport=transport,legions=legions}
  end
  return c
end

local groundCommander=commander("GROUND")
local airCommander=commander("AIR")
local pickup,deploy,source,dest={},{},{},{}
local function descriptor(tag,amount,itemWeight)
  return {
    pickupZone=pickup,deployZone=deploy,sourceStorage=source,destinationStorage=dest,
    cargoType=tag,cargoAmount=amount,cargoWeightKg=itemWeight,
    installInTransitObserver=function() end,
  }
end

local attached={}
local settlement={}
function settlement:Attach(transport,demand,context,resolved)
  attached[#attached+1]={transport=transport,demand=demand,context=context,descriptor=resolved}
  if demand.requestKey=="SETTLEMENT_REFUSE" then return nil,false,"STRATEGIC_TRANSFER_UNAVAILABLE" end
  return {transactionId="TX|"..demand.demandId},true,nil
end

local runtime=Runtime.New({
  storageTransportFactory=StorageFactory,
  settlement=settlement,
  groundCommander=groundCommander,
  resolveGroundTransport=function(demand) return descriptor("GROUND",demand.quantity*2,25) end,
  airCommander=airCommander,
  resolveAirTransport=function(demand) return descriptor("AIR",demand.quantity*10,nil) end,
})
local adapters=runtime:GetAdapters()
yes(adapters.GROUND_RESUPPLY~=nil,"ground adapter")
yes(adapters.AIR_RESUPPLY~=nil,"air adapter")
eq(runtime:GetAdapter("GROUND_RESUPPLY"),adapters.GROUND_RESUPPLY,"ground lookup")
eq(runtime:GetAdapter("AIR_RESUPPLY"),adapters.AIR_RESUPPLY,"air lookup")

local groundContext={marker="GROUND_CTX"}
local ground,groundCreated,groundReason=adapters.GROUND_RESUPPLY:Dispatch({
  demandId="R|G",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",
  resourceId="GROUND_AMMO_PACKAGE",quantity=4,requestKey="G",
},groundContext)
yes(groundCreated,"ground transport assigned")
eq(groundReason,nil,"ground reason")
eq(#groundCommander.recruitCalls,1,"ground MOOSE recruitment called once")
eq(groundCommander.recruitCalls[1].cargoWeight,200,"ground conservative manifest recruitment weight")
eq(groundCommander.recruitCalls[1].totalWeight,200,"ground total recruitment weight")
eq(#groundCommander.assignCalls,1,"ground TransportAssign once")
eq(#ground.runtime.assets,1,"MOOSE-selected asset added to transport")
eq(ground.runtime.assets[1].name,"GROUND-ASSET-1","ground selected asset preserved")
eq(#airCommander.recruitCalls,0,"air commander untouched")
eq(#attached,1,"settlement attached before recruitment")
eq(attached[1].transport,ground.runtime,"settlement transport")
eq(attached[1].context,groundContext,"settlement context")
eq(attached[1].descriptor.cargoType,"GROUND","settlement descriptor")

local air,airCreated=adapters.AIR_RESUPPLY:Dispatch({
  demandId="R|A",siteId="FOB_JOYCE",supportType="AIR_RESUPPLY",
  resourceId="GROUND_SUPPLY_PACKAGE",quantity=2,requestKey="A",
},{})
yes(airCreated,"air transport assigned")
eq(#airCommander.recruitCalls,1,"air MOOSE recruitment called once")
eq(airCommander.recruitCalls[1].cargoWeight,20,"omitted storage item weight follows pinned MOOSE 1kg default")
eq(airCommander.recruitCalls[1].totalWeight,20,"air total weight")
eq(#airCommander.assignCalls,1,"air TransportAssign once")
eq(#attached,2,"air settlement attached")

local duplicate,duplicateCreated,duplicateReason=adapters.GROUND_RESUPPLY:Dispatch({
  demandId="R|G",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",
  resourceId="GROUND_AMMO_PACKAGE",quantity=4,requestKey="G",
},{})
eq(duplicate,ground,"duplicate returns same handle")
no(duplicateCreated,"duplicate not redispatched")
eq(duplicateReason,"ALREADY_DISPATCHED","duplicate reason")
eq(#groundCommander.recruitCalls,1,"duplicate never re-recruits")

yes(ground:Cancel(),"ground cancel forwarded")
eq(ground.runtime.cancelCount,1,"ground transport cancel once")
no(ground:Cancel(),"ground cancel idempotent")
eq(ground.runtime.cancelCount,1,"ground transport remains one cancel")

local refused,refusedCreated,refusedReason=adapters.GROUND_RESUPPLY:Dispatch({
  demandId="R|REFUSE",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",
  resourceId="GROUND_AMMO_PACKAGE",quantity=1,requestKey="SETTLEMENT_REFUSE",
},{})
eq(refused,nil,"settlement refusal no handle")
no(refusedCreated,"settlement refusal not assigned")
eq(refusedReason,"STRATEGIC_TRANSFER_UNAVAILABLE","settlement refusal reason")
eq(#groundCommander.recruitCalls,1,"settlement refusal occurs before MOOSE recruitment")
eq(attached[3].transport.cancelCount,1,"unsettled transport cancelled")

groundCommander.available=false
local unavailable,unavailableCreated,unavailableReason=adapters.GROUND_RESUPPLY:Dispatch({
  demandId="R|BUSY",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",
  resourceId="GROUND_AMMO_PACKAGE",quantity=1,requestKey="BUSY",
},{})
eq(unavailable,nil,"no carrier no handle")
no(unavailableCreated,"no carrier not assigned")
eq(unavailableReason,"MOOSE_TRANSPORT_CARRIER_UNAVAILABLE","no carrier reason")
eq(#groundCommander.assignCalls,1,"unavailable transport never assigned")
eq(attached[4].transport.cancelCount,1,"unavailable transport cancelled after strategic reservation")
groundCommander.available=true

local concurrent1=adapters.GROUND_RESUPPLY:Dispatch({
  demandId="R|C1",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",
  resourceId="GROUND_AMMO_PACKAGE",quantity=1,requestKey="C1",
},{})
local concurrent2=adapters.GROUND_RESUPPLY:Dispatch({
  demandId="R|C2",siteId="FOB_WRIGHT",supportType="GROUND_RESUPPLY",
  resourceId="GROUND_AMMO_PACKAGE",quantity=1,requestKey="C2",
},{})
yes(concurrent1~=nil and concurrent2~=nil,"independent concurrent handles")
no(concurrent1==concurrent2,"concurrent handles isolated")
eq(concurrent1.assets[1].name,"GROUND-ASSET-2","first concurrent MOOSE asset")
eq(concurrent2.assets[1].name,"GROUND-ASSET-3","second concurrent MOOSE asset")
eq(#groundCommander.assignCalls,3,"three successful ground assignments total")

local onlyGround=Runtime.New({
  storageTransportFactory=StorageFactory,
  groundCommander=groundCommander,
  resolveGroundTransport=function(demand) return descriptor("GROUND_ONLY",demand.quantity,1) end,
})
yes(onlyGround:GetAdapter("GROUND_RESUPPLY")~=nil,"ground-only adapter exists")
eq(onlyGround:GetAdapter("AIR_RESUPPLY"),nil,"air adapter optional")

local ok,err=pcall(function()
  Runtime.New({storageTransportFactory=StorageFactory})
end)
no(ok,"empty transport runtime rejected")
yes(type(err)=="string" and string.find(err,"at least one physical resupply transport mode",1,true)~=nil,"empty runtime error")

OPSTRANSPORT=previousTransport
LEGION=previousLegion
print("PASS test_fire_support_strategic_resupply_transport_runtime")
