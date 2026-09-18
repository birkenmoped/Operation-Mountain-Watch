local function markAirAmmoInTransit()
  if state.inTransit or not state.loading then return state.inTransit end
  context().store:MarkInTransit(TRANSFER_ID)
  registry:SetReservationState(RESUPPLY_DEMAND_ID,"IN_TRANSIT")
  local d=registry:Get(RESUPPLY_DEMAND_ID)
  if d and d.status==MissionDemand.Status.AI_ASSIGNED then registry:Activate(RESUPPLY_DEMAND_ID) end
  state.inTransit=true; msg("LOGISTICS","MOOSE OPSTRANSPORT loading complete; Jalalabad -> Wright IN TRANSIT",10)
  return true
end
local function installAirObserver()
  if not state.airwing or state.airwing.__omwStage3A2Observer then return end
  state.airwing.__omwStage3A2Observer=true
  local previousFlight=state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(From,Event,To,FlightGroup,Mission)
    if previousFlight then previousFlight(self,From,Event,To,FlightGroup,Mission) end
    if Mission~=state.casMission then return end
    state.casFlight=FlightGroup
    if type(FlightGroup.SetDefaultSpeed)=="function" then FlightGroup:SetDefaultSpeed(CAS_SPEED_KTS) end
    installCasShotObserver()
    local oldEngage=FlightGroup.OnAfterEngageTarget
    function FlightGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
      if oldEngage then oldEngage(self,F,E,T,Target,Speed,Formation) end
      state.casEngaged=true; state.casNoContactReported=false; state.casNoContactSince=nil
      log("CAS_ENGAGE_EVENT target="..tostring(Target and Target.GetName and Target:GetName() or "unknown"))
    end
    local oldLanded=FlightGroup.OnAfterLanded
    function FlightGroup:OnAfterLanded(F,E,T,Airbase)
      if oldLanded then oldLanded(self,F,E,T,Airbase) end
      if state.casRecoveryRequested and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then state.casHomeLanded=true end
    end
    bindCasFlightPathCorridor(FlightGroup,Mission)
  end
  local previousSpawned=state.airwing.OnAfterAssetSpawned
  function state.airwing:OnAfterAssetSpawned(From,Event,To,Group,Asset,Request)
    if previousSpawned then previousSpawned(self,From,Event,To,Group,Asset,Request) end
    if not state.cargoAsset or Asset~=state.cargoAsset then return end
    local flight=Asset.flightgroup
    if not flight then fail("CH-47 OPSTRANSPORT FLIGHTGROUP unavailable after AIRWING spawn"); return end
    state.cargoFlight=flight
    local binding,ok,reason=TransportCorridor.Bind(flight,state.cargoTransport,state.cargoResolved,PRIMARY_ALTITUDE_FT_AGL,{
      speedKts=CH47_TRANSIT_SPEED_KTS,leadTurnDistanceM=CH47_LEAD_TURN_DISTANCE_M,
      onOutboundInstalled=function() state.airCorridor=true; markAirAmmoInTransit() end,
      onReturnInstalled=function() state.cargoReturnInstalled=true end,
      onError=function(why) fail("CH-47 OPSTRANSPORT corridor failed: "..tostring(why)) end,
    })
    if not ok then fail("CH-47 corridor bind failed: "..tostring(reason)); return end
    state.cargoBinding=binding
    local oldLanded=flight.OnAfterLanded
    function flight:OnAfterLanded(F,E,T,Airbase)
      if oldLanded then oldLanded(self,F,E,T,Airbase) end
      if state.delivered and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then state.homeLanded=true end
    end
  end
  local oldReturn=state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(From,Event,To,Cohort,Asset)
    if oldReturn then oldReturn(self,From,Event,To,Cohort,Asset) end
    if state.casRecoveryRequested and Asset and Asset.flightgroup==state.casFlight then state.casAssetReturned=true end
    if state.cargoAsset and Asset==state.cargoAsset then
      if not state.homeLanded then fail("CH47 returned before home landing"); return end
      state.assetReturned=true
    end
  end
end

local function preconditionWright()
  local ctx=context(); if not ctx then return false end
  local before=ctx.store:GetResource(WRIGHT_NODE,AMMO_RESOURCE)
  if not before or before.quantity~=30 then fail("Wright initial AMMO expected 30"); return false end
  local tx,created=ctx.store:ReserveResource({transactionId=PRECONDITION_TX,reservationId="ACCEPTANCE:"..PRECONDITION_TX,
    kind=ctx.campaignState.TransactionKind.CONSUMPTION,resourceId=AMMO_RESOURCE,quantity=14,canonicalUnit="count",originNodeId=WRIGHT_NODE})
  if created~=true then fail("Wright precondition transaction failed"); return false end
  ctx.store:Consume(tx.transactionId); ctx.store:CompleteConsumption(tx.transactionId)
  if ctx.store:GetResource(WRIGHT_NODE,AMMO_RESOURCE).quantity~=16 then fail("Wright precondition did not reach 16"); return false end
  msg("CAMPAIGN","Acceptance precondition Wright strategic AMMO 30 -> 16",12); return true
end
local function createAirAmmoStorageFixtures()
  state.sourceStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :AddCargoResource(STORAGE.Type.WEAPONS,PHYSICAL_CARGO_TYPE,PHYSICAL_CARGO_AMOUNT,PHYSICAL_CARGO_TOTAL_WEIGHT_KG)
    :InitCoordinate(state.pickup:GetCoordinate()):InitValidateAndRepositionStatic(false):Spawn(0,SOURCE_STORAGE_NAME)
  state.destStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :ResetCargoResources():InitCoordinate(state.drop:GetCoordinate()):InitValidateAndRepositionStatic(false):Spawn(0,DEST_STORAGE_NAME)
  if not state.sourceStatic or not state.destStatic then return false,"storage static spawn failed" end
  state.sourceStorage=state.sourceStatic:GetStaticStorage(); state.destStorage=state.destStatic:GetStaticStorage()
  if not state.sourceStorage or not state.destStorage then return false,"MOOSE STORAGE wrapper unavailable" end
  if state.sourceStorage:GetAmount(PHYSICAL_CARGO_TYPE)~=PHYSICAL_CARGO_AMOUNT or state.destStorage:GetAmount(PHYSICAL_CARGO_TYPE)~=0 then
    return false,"storage fixture amount mismatch"
  end
  return true,nil
end
local function carrierRecruitSnapshot()
  return {cohortState=state.ch47:GetState(),onDuty=state.ch47:IsOnDuty(),capability=state.ch47:GetMissionCapability(AUFTRAG.Type.OPSTRANSPORT)~=nil,
    stock=state.ch47:CountAssets(true,{AUFTRAG.Type.OPSTRANSPORT}),payloads=state.airwing:CountPayloadsInStock({AUFTRAG.Type.OPSTRANSPORT},state.carrierUnitType)}
end
local armCargoCarrier
local function scheduleCargoRecruitment()
  if state.failed or state.cargoAsset or state.cargoRecruitPending then return end
  state.cargoRecruitPending=true
  SCHEDULER:New(nil,function() state.cargoRecruitPending=false; armCargoCarrier() end,{},CARRIER_RECRUIT_RETRY_SEC)
end
armCargoCarrier=function()
  if state.failed or state.cargoAsset then return end
  state.cargoRecruitAttempts=state.cargoRecruitAttempts+1
  local s=carrierRecruitSnapshot()
  if not s.onDuty or not s.capability or s.stock<1 or s.payloads<1 then
    if state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS then scheduleCargoRecruitment(); return end
    fail("CH-47 recruitment readiness timeout"); return
  end
  local recruited,assets,legions=LEGION.RecruitCohortAssets({state.ch47},AUFTRAG.Type.OPSTRANSPORT,nil,1,1,state.drop:GetVec2(),
    nil,nil,nil,PHYSICAL_CARGO_TOTAL_WEIGHT_KG,PHYSICAL_CARGO_TOTAL_WEIGHT_KG,nil,nil,nil,nil,nil,nil)
  local assetCount=type(assets)=="table" and #assets or -1
  local legionCount,recruitedLegion=0,nil
  if type(legions)=="table" then for _,legion in pairs(legions) do legionCount=legionCount+1; recruitedLegion=legion end end
  if recruited and assetCount==1 and legionCount==1 and recruitedLegion==state.airwing then
    state.cargoAsset=assets[1]; state.cargoTransport:AddAsset(state.cargoAsset); state.airwing:TransportAssign(state.cargoTransport,legions); return
  end
  if recruited and type(assets)=="table" and assetCount>0 then LEGION.UnRecruitAssets(assets) end
  if state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS then scheduleCargoRecruitment() else fail("unable to recruit exactly one Jalalabad CH-47") end
end
local function startAirResupply()
  if state.resupply then return end
  if not state.airwing or not state.ch47 then fail("Jalalabad AIRWING/CH47 unavailable for strategic resupply"); return end
  local ctx=context(); local row=stockRow(WRIGHT_NODE,AMMO_RESOURCE); local w=ctx.store:GetResource(WRIGHT_NODE,AMMO_RESOURCE)
  if not row or not w or w.quantity~=15 then fail("Wright must be at 15 AMMO after local rearm"); return end
  local demand,created,reason=ResourceDemandCoordinator.EvaluateAndCreate({policy=ResourceDemandPolicy,missionDemand=MissionDemand,registry=registry,store=ctx.store,row=row,demandIdFactory=function() return RESUPPLY_DEMAND_ID end})
  if not demand or created~=true then fail("Wright RESUPPLY demand failed: "..tostring(reason)); return end
  state.resupply=demand
  local duplicate,duplicateCreated,duplicateReason=ResourceDemandCoordinator.EvaluateAndCreate({policy=ResourceDemandPolicy,missionDemand=MissionDemand,registry=registry,store=ctx.store,row=row,demandIdFactory=function() return "DUPLICATE" end})
  if type(duplicate)~="table" or duplicate.id~=demand.id or duplicateCreated~=false or duplicateReason~="active_duplicate" then fail("RESUPPLY semantic dedupe failed"); return end
  local _,transferCreated=ctx.store:ReserveResource({transactionId=TRANSFER_ID,reservationId="MISSION-DEMAND:"..RESUPPLY_DEMAND_ID,cargoId=CARGO_ID,
    missionDemandId=RESUPPLY_DEMAND_ID,carrierEntityId=CARRIER_ID,kind=ctx.campaignState.TransactionKind.TRANSFER,resourceId=AMMO_RESOURCE,quantity=15,
    canonicalUnit="count",originNodeId=JALALABAD_NODE,destinationNodeId=WRIGHT_NODE})
  if transferCreated~=true then fail("Air-AMMO transfer reservation failed"); return end
  registry:SetReservationState(RESUPPLY_DEMAND_ID,"RESERVED",{transactionId=TRANSFER_ID,cargoId=CARGO_ID,originNodeId=JALALABAD_NODE,destinationNodeId=WRIGHT_NODE,resourceId=AMMO_RESOURCE,quantity=15,carrierEntityId=CARRIER_ID})
  state.pickup=need(ZONE:FindByName(PICKUP_ZONE),PICKUP_ZONE); state.drop=need(ZONE:FindByName(DROP_ZONE),DROP_ZONE); if state.failed then return end
  local ok,why=createAirAmmoStorageFixtures(); if not ok then fail(why); return end
  state.cargoResolved=HelicopterCorridor.Resolve({pathlineName=state.flightPathName,pathline=state.flightPath,originCoordinate=state.pickup:GetCoordinate(),destinationCoordinate=state.drop:GetCoordinate(),offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX})
  if not state.cargoResolved or not state.cargoResolved.outbound or #state.cargoResolved.outbound<2 or not state.cargoResolved.returnRoute or #state.cargoResolved.returnRoute<2 then fail("Air-AMMO corridor resolution failed"); return end
  state.cargoTransport=OPSTRANSPORT:New(nil,state.pickup,state.drop); state.cargoTransport:SetRequiredCarriers(1,1); state.cargoTransport:SetPriority(20)
  state.cargoTransport:AddCargoStorage(state.sourceStorage,state.destStorage,PHYSICAL_CARGO_TYPE,PHYSICAL_CARGO_AMOUNT,PHYSICAL_CARGO_ITEM_WEIGHT_KG)
  local oldExecuting=state.cargoTransport.OnAfterExecuting
  function state.cargoTransport:OnAfterExecuting(F,E,T)
    if oldExecuting then oldExecuting(self,F,E,T) end
    local tx=ctx.store:MarkLoading(TRANSFER_ID); registry:SetReservationState(RESUPPLY_DEMAND_ID,"LOADING"); state.loading=tx and tx.status==ctx.campaignState.TransactionStatus.LOADING
  end
  local oldDelivered=state.cargoTransport.OnAfterDelivered
  function state.cargoTransport:OnAfterDelivered(F,E,T)
    if oldDelivered then oldDelivered(self,F,E,T) end
    if state.sourceStorage:GetAmount(PHYSICAL_CARGO_TYPE)~=0 or state.destStorage:GetAmount(PHYSICAL_CARGO_TYPE)~=PHYSICAL_CARGO_AMOUNT then fail("OPSTRANSPORT Delivered without expected STORAGE transfer"); return end
    if not state.inTransit then markAirAmmoInTransit() end
    ctx.store:MarkDelivered(TRANSFER_ID); registry:SetReservationState(RESUPPLY_DEMAND_ID,"DELIVERED")
    registry:Succeed(RESUPPLY_DEMAND_ID,{transactionId=TRANSFER_ID,cargoId=CARGO_ID,carrierEntityId=CARRIER_ID,physicalMission="OPSTRANSPORT:STORAGE",corridor=primaryPathlineName()})
    state.delivered=true
  end
  registry:AssignAI(RESUPPLY_DEMAND_ID,"AI:SQUADRON:SQ_US_JBAD_CH47_HEAVYLIFT"); armCargoCarrier()
end
