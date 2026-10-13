local CampaignState=dofile("scripts/campaign/OMW_CampaignState.lua")
local Settlement=dofile("scripts/campaign/OMW_FireSupStratResupply_TransportSettlement.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local function newStore()
  return CampaignState.New({nodes={
    {nodeId="GROUND_NODE_JALALABAD",airbaseName="Jalalabad",resources={GROUND_AMMO_PACKAGE={quantity=20,unit="count"}}},
    {nodeId="GROUND_NODE_JOYCE",airbaseName="FOB Joyce",resources={GROUND_AMMO_PACKAGE={quantity=2,unit="count"}}},
  }})
end
local pickupZone={name="PICKUP"}
local function newCarrier(inPickup)
  local carrier={inPickup=inPickup}
  function carrier:IsInZone(zone)
    eq(zone,pickupZone,"pickup zone identity")
    return self.inPickup
  end
  return carrier
end
local function transport(total)
  local t={storage={cargoAmount=total,cargoDelivered=0,cargoLost=0,cargoLoaded=0},carriers={newCarrier(true)}}
  function t:GetCargoStorages() return {self.storage} end
  function t:GetCarriers() return self.carriers end
  return t
end
local function demand(id,quantity)
  return {demandId=id,siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",resourceId="GROUND_AMMO_PACKAGE",quantity=quantity,tacticalContext={supplyParentNodeId="GROUND_NODE_JALALABAD",campaignNodeId="GROUND_NODE_JOYCE"}}
end
local function descriptor(physicalAmount)
  local d={pickupZone=pickupZone,cargoAmount=physicalAmount}
  function d.installInTransitObserver(t,callback) t.confirmInTransit=callback end
  return d
end

-- Full delivery: reserve -> loading -> explicit physical in-transit -> delivered.
local store=newStore()
local terminals={}
local settlement=Settlement.New({campaignState=CampaignState,store=store,onTerminal=function(d,outcome,transaction) terminals[#terminals+1]={d=d,outcome=outcome,transaction=transaction} end})
local t=transport(5)
local d=demand("R|DELIVERED",5)
local binding,attached,reason=settlement:Attach(t,d,{},descriptor(5))
yes(attached,"delivery binding attached")
eq(reason,nil,"attach reason")
eq(store:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,5,"strategic source reserved")
eq(store:GetTransaction(binding.transactionId).status,CampaignState.TransactionStatus.RESERVED,"reserved status")
t:OnAfterExecuting("Queued","Executing","Executing")
eq(store:GetTransaction(binding.transactionId).status,CampaignState.TransactionStatus.LOADING,"executing maps to loading")
t.confirmInTransit("CARRIER_LEFT_PICKUP")
eq(store:GetTransaction(binding.transactionId).status,CampaignState.TransactionStatus.IN_TRANSIT,"physical evidence maps in transit")
eq(store:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").quantity,15,"origin debited in transit")
t.storage.cargoDelivered=5
t:OnAfterDelivered("Executing","Delivered","Delivered")
eq(store:GetTransaction(binding.transactionId).status,CampaignState.TransactionStatus.DELIVERED,"delivered status")
eq(store:GetResource("GROUND_NODE_JOYCE","GROUND_AMMO_PACKAGE").quantity,7,"destination credited")
eq(terminals[1].outcome,"DELIVERED","terminal callback delivered")

-- Full physical loss after confirmed in-transit.
local lostStore=newStore()
local lostSettlement=Settlement.New({campaignState=CampaignState,store=lostStore})
local lostT=transport(4)
local lostBinding=lostSettlement:Attach(lostT,demand("R|LOST",4),{},descriptor(4))
lostT:OnAfterExecuting("Queued","Executing","Executing")
lostT.confirmInTransit("CARRIER_DEPARTED")
lostT.storage.cargoLost=4
lostT:OnAfterDelivered("Executing","Delivered","Delivered")
eq(lostStore:GetTransaction(lostBinding.transactionId).status,CampaignState.TransactionStatus.LOST,"all-lost physical outcome")
eq(lostStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").quantity,16,"lost cargo remains debited")
eq(lostStore:GetResource("GROUND_NODE_JOYCE","GROUND_AMMO_PACKAGE").quantity,2,"lost cargo not credited")

-- Cancel before in-transit releases reservation.
local cancelStore=newStore()
local cancelSettlement=Settlement.New({campaignState=CampaignState,store=cancelStore})
local cancelT=transport(3)
local cancelBinding=cancelSettlement:Attach(cancelT,demand("R|CANCEL",3),{},descriptor(3))
cancelT:OnAfterExecuting("Queued","Executing","Executing")
cancelT:OnAfterCancel("Executing","Cancel","Cancelled")
eq(cancelStore:GetTransaction(cancelBinding.transactionId).status,CampaignState.TransactionStatus.CANCELLED,"pre-transit cancel")
eq(cancelStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,0,"cancel releases reservation")
eq(cancelStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").quantity,20,"cancel does not debit source")

-- MOOSE Delivered can represent mixed delivered/lost completion; never settle that silently.
local partialStore=newStore()
local partialCount=0
local partialSettlement=Settlement.New({campaignState=CampaignState,store=partialStore,onPartial=function(d,detail,binding) partialCount=partialCount+1;eq(detail.delivered,2,"partial delivered");eq(detail.lost,3,"partial lost") end})
local partialT=transport(5)
local partialBinding=partialSettlement:Attach(partialT,demand("R|PARTIAL",5),{},descriptor(5))
partialT:OnAfterExecuting("Queued","Executing","Executing")
partialT.confirmInTransit("DEPARTED")
partialT.storage.cargoDelivered=2;partialT.storage.cargoLost=3
partialT:OnAfterDelivered("Executing","Delivered","Delivered")
eq(partialCount,1,"partial outcome surfaced")
eq(partialStore:GetTransaction(partialBinding.transactionId).status,CampaignState.TransactionStatus.IN_TRANSIT,"partial outcome remains unresolved")

-- Default MOOSE-first observer: strategic package count and physical STORAGE amount are
-- independent. In-transit is confirmed only after cargo is physically loaded and every
-- assigned MOOSE carrier has left the pickup zone.
local defaultStore=newStore()
local defaultSettlement=Settlement.New({campaignState=CampaignState,store=defaultStore})
local defaultT=transport(20)
local defaultDemand=demand("R|DEFAULT_OBSERVER",2)
local defaultBinding,defaultAttached,defaultReason=defaultSettlement:Attach(
  defaultT,defaultDemand,{}, {pickupZone=pickupZone,cargoAmount=20})
yes(defaultAttached,"default observer binding attached")
eq(defaultReason,nil,"default observer attach reason")
eq(defaultStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,2,"strategic package count reserved")
defaultT:OnAfterExecuting("Queued","Executing","Executing")
defaultT.storage.cargoLoaded=20
defaultT:OnAfterStatusUpdate("*","StatusUpdate","*")
eq(defaultStore:GetTransaction(defaultBinding.transactionId).status,CampaignState.TransactionStatus.LOADING,"loaded carrier inside pickup remains loading")
defaultT.carriers[1].inPickup=false
defaultT:OnAfterStatusUpdate("*","StatusUpdate","*")
eq(defaultStore:GetTransaction(defaultBinding.transactionId).status,CampaignState.TransactionStatus.IN_TRANSIT,"loaded carrier outside pickup confirms in transit")
eq(defaultStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").quantity,18,"strategic quantity debited by package count, not physical amount")
defaultT.storage.cargoLoaded=0
defaultT.storage.cargoDelivered=20
defaultT:OnAfterDelivered("Executing","Delivered","Delivered")
eq(defaultStore:GetTransaction(defaultBinding.transactionId).status,CampaignState.TransactionStatus.DELIVERED,"physical amount delivered settles strategic transfer")
eq(defaultStore:GetResource("GROUND_NODE_JOYCE","GROUND_AMMO_PACKAGE").quantity,4,"destination credited by strategic package count")

local missingPhysicalStore=newStore()
local missingPhysicalSettlement=Settlement.New({campaignState=CampaignState,store=missingPhysicalStore})
local noBinding,noAttach,noReason=missingPhysicalSettlement:Attach(
  transport(2),demand("R|NO_PHYSICAL_AMOUNT",2),{}, {pickupZone=pickupZone})
eq(noBinding,nil,"missing physical amount no binding")
no(noAttach,"missing physical amount attach false")
eq(noReason,"PHYSICAL_CARGO_AMOUNT_REQUIRED","missing physical amount explicit reason")
eq(missingPhysicalStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,0,"missing physical amount reserves nothing")

-- Strategic transfer resolution can explicitly decouple a physical/off-map provider label
-- from the CampaignState source node. The adapter must not infer that mapping itself.
local resolvedStore=newStore()
local resolverCalls=0
local resolvedSettlement=Settlement.New({
  campaignState=CampaignState,
  store=resolvedStore,
  resolveTransfer=function(resolvedDemand,context,resolvedDescriptor)
    resolverCalls=resolverCalls+1
    eq(context.source,"OFF_MAP_PROVIDER","resolver context")
    yes(type(resolvedDescriptor.installInTransitObserver)=="function","resolver descriptor")
    return {originNodeId="GROUND_NODE_JALALABAD",destinationNodeId="GROUND_NODE_JOYCE",canonicalUnit="count"}
  end,
})
local resolvedDemand=demand("R|RESOLVED",2)
resolvedDemand.tacticalContext.supplyParentNodeId="OFF_MAP"
local resolvedBinding,resolvedAttached,resolvedReason=resolvedSettlement:Attach(transport(2),resolvedDemand,{source="OFF_MAP_PROVIDER"},descriptor(2))
yes(resolvedAttached,"resolved transfer attached")
eq(resolvedReason,nil,"resolved transfer reason")
eq(resolverCalls,1,"transfer resolver called once")
eq(resolvedStore:GetTransaction(resolvedBinding.transactionId).originNodeId,"GROUND_NODE_JALALABAD","explicit strategic source used")
eq(resolvedStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,2,"resolved source reserved")

local refusedStore=newStore()
local refusedSettlement=Settlement.New({campaignState=CampaignState,store=refusedStore,resolveTransfer=function() return nil,"STRATEGIC_SOURCE_NOT_CONFIGURED" end})
local refusedBinding,refusedAttached,refusedReason=refusedSettlement:Attach(transport(2),demand("R|REFUSED",2),{},descriptor(2))
eq(refusedBinding,nil,"resolver refusal no binding")
no(refusedAttached,"resolver refusal not attached")
eq(refusedReason,"STRATEGIC_SOURCE_NOT_CONFIGURED","resolver refusal propagated")
eq(refusedStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,0,"resolver refusal reserves nothing")

print("PASS test_fire_support_strategic_resupply_transport_settlement")
