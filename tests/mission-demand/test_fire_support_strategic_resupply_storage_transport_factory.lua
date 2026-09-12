local Factory = dofile("scripts/campaign/OMW_FireSupStratResupply_StorageTransportFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previous=OPSTRANSPORT
local created={}
OPSTRANSPORT={}
function OPSTRANSPORT:New(cargo,pickup,deploy)
  local t={cargo=cargo,pickup=pickup,deploy=deploy,cancelCount=0}
  function t:AddCargoStorage(source,destination,cargoType,amount,weight)
    self.storage={source=source,destination=destination,cargoType=cargoType,amount=amount,weight=weight};return self
  end
  function t:SetRequiredCarriers(minimum,maximum) self.carriersMin=minimum;self.carriersMax=maximum;return self end
  function t:SetPriority(priority,importance,urgent) self.priority=priority;self.importance=importance;self.urgent=urgent;return self end
  function t:Cancel() self.cancelCount=self.cancelCount+1 end
  created[#created+1]=t
  return t
end

local pickup,deploy,source,destination={},{},{},{}
local descriptor={pickupZone=pickup,deployZone=deploy,sourceStorage=source,destinationStorage=destination,cargoType="AMMO",cargoAmount=7,cargoWeightKg=25,requiredCarriersMin=1,requiredCarriersMax=2}
local factory=Factory.New({resolveTransport=function(demand,context)
  eq(context.marker,"PHYSICAL","resolver context")
  return descriptor
end})
local demand={demandId="R|JOYCE|AMMO|1",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",resourceId="GROUND_AMMO_PACKAGE",quantity=7,priority=18}
local transport,made,reason,returnedDescriptor=factory:Create(demand,{marker="PHYSICAL"})
yes(made,"storage transport created")
eq(reason,nil,"create reason")
eq(returnedDescriptor,descriptor,"descriptor returned")
eq(transport.cargo,nil,"storage transport first cargo nil")
eq(transport.pickup,pickup,"pickup zone")
eq(transport.deploy,deploy,"deploy zone")
eq(transport.storage.source,source,"source storage")
eq(transport.storage.destination,destination,"destination storage")
eq(transport.storage.cargoType,"AMMO","cargo type")
eq(transport.storage.amount,7,"cargo amount")
eq(transport.storage.weight,25,"cargo weight")
eq(transport.carriersMin,1,"carrier min")
eq(transport.carriersMax,2,"carrier max")
eq(transport.priority,18,"priority")
eq(transport.importance,nil,"importance remains nil")
eq(transport.urgent,false,"transport not urgent by factory")

local airFactory=Factory.New({resolveTransport=function() return {pickupZone=pickup,deployZone=deploy,sourceStorage=source,destinationStorage=destination,cargoType="FUEL"} end})
local air,airMade=airFactory:Create({demandId="R|JOYCE|FUEL|1",siteId="FOB_JOYCE",supportType="AIR_RESUPPLY",resourceId="GROUND_FUEL_PACKAGE",quantity=3},{})
yes(airMade,"air storage transport uses same MOOSE factory")
eq(air.storage.amount,3,"demand quantity default")
eq(air.carriersMin,1,"default one carrier")
eq(air.carriersMax,1,"default max one carrier")

local unavailableFactory=Factory.New({resolveTransport=function() return nil,"PHYSICAL_STORAGE_MAPPING_UNAVAILABLE" end})
local none,noneMade,noneReason=unavailableFactory:Create({demandId="R|NONE",siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",resourceId="GROUND_SUPPLY_PACKAGE",quantity=2},{})
eq(none,nil,"missing descriptor no transport")
no(noneMade,"missing descriptor not created")
eq(noneReason,"PHYSICAL_STORAGE_MAPPING_UNAVAILABLE","missing descriptor reason")
eq(#created,2,"missing descriptor never invokes MOOSE")

local mismatchFactory=Factory.New({resolveTransport=function() return {pickupZone=pickup,deployZone=deploy,sourceStorage=source,destinationStorage=destination,cargoType="AMMO",cargoAmount=6} end})
local ok,err=pcall(function() mismatchFactory:Create(demand,{}) end)
no(ok,"quantity mismatch rejected")
yes(type(err)=="string" and string.find(err,"cargoAmount must equal demand.quantity",1,true)~=nil,"quantity mismatch error")

OPSTRANSPORT=previous
print("PASS test_fire_support_strategic_resupply_storage_transport_factory")
