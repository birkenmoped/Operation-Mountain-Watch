local CampaignState=dofile("scripts/campaign/OMW_CampaignState.lua")
local Settlement=dofile("scripts/campaign/OMW_FireSupStratResupply_TransportSettlement.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local function newStore()
  return CampaignState.New({nodes={
    {nodeId="GROUND_NODE_JALALABAD",resources={GROUND_AMMO_PACKAGE={quantity=20,unit="count"}}},
    {nodeId="GROUND_NODE_JOYCE",resources={GROUND_AMMO_PACKAGE={quantity=2,unit="count"}}},
  }})
end
local function transport(total)
  local t={storage={cargoAmount=total,cargoDelivered=0,cargoLost=0}}
  function t:GetCargoStorages() return {self.storage} end
  return t
end
local function demand(id,quantity)
  return {demandId=id,siteId="FOB_JOYCE",supportType="GROUND_RESUPPLY",resourceId="GROUND_AMMO_PACKAGE",quantity=quantity,tacticalContext={supplyParentNodeId="GROUND_NODE_JALALABAD",campaignNodeId="GROUND_NODE_JOYCE"}}
end
local function descriptor()
  local d={}
  function d.installInTransitObserver(t,callback) t.confirmInTransit=callback end
  return d
end

-- Full delivery: reserve -> loading -> explicit physical in-transit -> delivered.
local store=newStore()
local terminals={}
local settlement=Settlement.New({campaignState=CampaignState,store=store,onTerminal=function(d,outcome,transaction) terminals[#terminals+1]={d=d,outcome=outcome,transaction=transaction} end})
local t=transport(5)
local d=demand("R|DELIVERED",5)
local binding,attached,reason=settlement:Attach(t,d,{},descriptor())
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
local lostBinding=lostSettlement:Attach(lostT,demand("R|LOST",4),{},descriptor())
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
local cancelBinding=cancelSettlement:Attach(cancelT,demand("R|CANCEL",3),{},descriptor())
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
local partialBinding=partialSettlement:Attach(partialT,demand("R|PARTIAL",5),{},descriptor())
partialT:OnAfterExecuting("Queued","Executing","Executing")
partialT.confirmInTransit("DEPARTED")
partialT.storage.cargoDelivered=2;partialT.storage.cargoLost=3
partialT:OnAfterDelivered("Executing","Delivered","Delivered")
eq(partialCount,1,"partial outcome surfaced")
eq(partialStore:GetTransaction(partialBinding.transactionId).status,CampaignState.TransactionStatus.IN_TRANSIT,"partial outcome remains unresolved")

-- A settlement binding is rejected without caller-provided physical in-transit evidence.
local noObserverStore=newStore()
local noObserverSettlement=Settlement.New({campaignState=CampaignState,store=noObserverStore})
local noBinding,noAttach,noReason=noObserverSettlement:Attach(transport(2),demand("R|NOOBS",2),{}, {})
eq(noBinding,nil,"no observer no binding")
no(noAttach,"no observer attach false")
eq(noReason,"IN_TRANSIT_OBSERVER_REQUIRED","no observer explicit reason")
eq(noObserverStore:GetResource("GROUND_NODE_JALALABAD","GROUND_AMMO_PACKAGE").reserved,0,"no reservation before observer contract")

print("PASS test_fire_support_strategic_resupply_transport_settlement")
