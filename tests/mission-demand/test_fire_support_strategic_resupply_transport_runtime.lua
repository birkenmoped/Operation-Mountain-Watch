local Runtime=dofile("scripts/campaign/OMW_FireSupStratResupply_ResupplyTransportRuntime.lua")
local CommanderBridge=dofile("scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua")
local StorageFactory=dofile("scripts/campaign/OMW_FireSupStratResupply_StorageTransportFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previous=OPSTRANSPORT
OPSTRANSPORT={}
function OPSTRANSPORT:New(cargo,pickup,deploy)
  local t={pickup=pickup,deploy=deploy,cancelCount=0}
  function t:AddCargoStorage(source,dest,cargoType,amount,weight) self.storage={source=source,dest=dest,cargoType=cargoType,amount=amount,weight=weight};return self end
  function t:SetRequiredCarriers(a,b) self.min=a;self.max=b;return self end
  function t:SetPriority(p,i,u) self.priority=p;self.importance=i;self.urgent=u;return self end
  function t:Cancel() self.cancelCount=self.cancelCount+1 end
  return t
end

local groundCommander={transports={}}
function groundCommander:AddOpsTransport(t) self.transports[#self.transports+1]=t return self end
local airCommander={transports={}}
function airCommander:AddOpsTransport(t) self.transports[#self.transports+1]=t return self end
local pickup,deploy,source,dest={},{},{},{}
local function descriptor(tag)
  return {pickupZone=pickup,deployZone=deploy,sourceStorage=source,destinationStorage=dest,cargoType=tag,cargoWeightKg=10}
end
local runtime=Runtime.New({
  commanderBridge=CommanderBridge,
  storageTransportFactory=StorageFactory,
  groundCommander=groundCommander,
  resolveGroundTransport=function(demand) return descriptor("GROUND") end,
  airCommander=airCommander,
  resolveAirTransport=function(demand) return descriptor("AIR") end,
})
local adapters=runtime:GetAdapters()
yes(adapters.GROUND_RESUPPLY~=nil,"ground adapter")
yes(adapters.AIR_RESUPPLY~=nil,"air adapter")
eq(runtime:GetAdapter("GROUND_RESUPPLY"),adapters.GROUND_RESUPPLY,"ground lookup")
eq(runtime:GetAdapter("AIR_RESUPPLY"),adapters.AIR_RESUPPLY,"air lookup")

local ground,groundCreated,groundReason=adapters.GROUND_RESUPPLY:Dispatch({demandId="R|G",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",resourceId="GROUND_AMMO_PACKAGE",quantity=4},{})
yes(groundCreated,"ground transport queued")
eq(groundReason,nil,"ground reason")
eq(#groundCommander.transports,1,"ground commander gets one transport")
eq(#airCommander.transports,0,"air commander untouched")
eq(groundCommander.transports[1].storage.cargoType,"GROUND","ground descriptor used")

local air,airCreated=adapters.AIR_RESUPPLY:Dispatch({demandId="R|A",siteId="FOB_JOYCE",supportType="AIR_RESUPPLY",resourceId="GROUND_SUPPLY_PACKAGE",quantity=2},{})
yes(airCreated,"air transport queued")
eq(#airCommander.transports,1,"air commander gets one transport")
eq(airCommander.transports[1].storage.cargoType,"AIR","air descriptor used")

yes(ground:Cancel(),"ground cancel forwarded")
eq(ground.runtime.cancelCount,1,"ground transport cancel once")

local onlyGround=Runtime.New({
  commanderBridge=CommanderBridge,
  storageTransportFactory=StorageFactory,
  groundCommander=groundCommander,
  resolveGroundTransport=function() return descriptor("GROUND_ONLY") end,
})
yes(onlyGround:GetAdapter("GROUND_RESUPPLY")~=nil,"ground-only adapter exists")
eq(onlyGround:GetAdapter("AIR_RESUPPLY"),nil,"air adapter optional")

local ok,err=pcall(function()
  Runtime.New({commanderBridge=CommanderBridge,storageTransportFactory=StorageFactory})
end)
no(ok,"empty transport runtime rejected")
yes(type(err)=="string" and string.find(err,"at least one physical resupply transport mode",1,true)~=nil,"empty runtime error")

OPSTRANSPORT=previous
print("PASS test_fire_support_strategic_resupply_transport_runtime")
