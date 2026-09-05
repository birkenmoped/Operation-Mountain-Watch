-- Operation Mountain Watch - Stage 3 Air-AMMO CARGOTRANSPORT acceptance.
-- Test-ID: AIR-AMMO-CARGOTRANSPORT-ACCEPTANCE-1
--
-- Scope:
--   Isolated MOOSE-first validation of one strategic Ground-AMMO RESUPPLY
--   manifest represented by one physical slingload static cargo item.
--   CampaignState remains sole strategic quantity/ownership authority.
--
-- This acceptance intentionally does NOT prove the final Honaker attack ->
-- Wright fire-support -> rearm -> shortage chain. It validates only the new
-- Jalalabad -> Wright physical Air-AMMO transport/settlement contract first.

local TEST_ID = "AIR-AMMO-CARGOTRANSPORT-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local RESOURCE_ID = "GROUND_AMMO_PACKAGE"
local RESOURCE_CLASS = "GROUND_AMMO"
local RESOURCE_UNIT = "count"

local ORIGIN_NODE = "GROUND_NODE_JALALABAD"
local DESTINATION_NODE = "GROUND_NODE_WRIGHT"
local PICKUP_ZONE_NAME = "OMW_LOG_NODE_JALALABAD"
local DROP_ZONE_NAME = "OMW_BLUE_LZ_WRIGHT_01"
local AIR_SQUADRON_KEY = "CH47"
local AIR_SQUADRON_NAME = "SQ_US_JBAD_CH47_HEAVYLIFT"
local AIR_TEMPLATE_NAME = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"

local DEMAND_ID = "RESUPPLY-ACCEPTANCE-WRIGHT-AMMO-AIR-CARGOTRANSPORT-001"
local TRANSFER_ID = "TRANSFER-ACCEPTANCE-JALALABAD-WRIGHT-AMMO-AIR-CARGOTRANSPORT-001"
local SHORTAGE_TX_ID = "CONSUMPTION-ACCEPTANCE-WRIGHT-AMMO-AIR-CARGOTRANSPORT-001"
local CARGO_ID = "CARGO-ACCEPTANCE-JALALABAD-WRIGHT-AMMO-AIR-CARGOTRANSPORT-001"
local CARRIER_ENTITY_ID = "AIR-RESUPPLY-JALALABAD-WRIGHT-AMMO-CH47-CARGOTRANSPORT-001"
local ASSIGNEE_ID = "AI:SQUADRON:" .. AIR_SQUADRON_NAME

local INITIAL_ORIGIN = 100
local INITIAL_DESTINATION = 30
local SHORTAGE_QUANTITY = 15
local DESTINATION_AFTER_SHORTAGE = 15
local TRANSFER_QUANTITY = 15
local FINAL_ORIGIN = 85
local FINAL_DESTINATION = 30
local REORDER = 15
local CRITICAL = 7.5

-- Acceptance-only physical parameter. This is NOT a conversion from kg to
-- GROUND_AMMO_PACKAGE and is not a normative logistics mass decision.
local PHYSICAL_CARGO_TYPE = "ammo_cargo"
local PHYSICAL_CARGO_CATEGORY = "Cargos"
local PHYSICAL_CARGO_MASS_KG = 1000
local CARGO_REPOSITION_RADIUS_M = 120
local TRANSIT_CHECK_INTERVAL_SEC = 5

local state = {
  failed = false,
  passed = false,
  registry = nil,
  store = nil,
  campaignState = nil,
  missionDemand = nil,
  resourceDemandPolicy = nil,
  pickupZone = nil,
  dropZone = nil,
  cargo = nil,
  airwing = nil,
  squadron = nil,
  mission = nil,
  flightGroup = nil,
  asset = nil,
  loadingConfirmed = false,
  inTransitCommitted = false,
  deliveryCommitted = false,
  missionSuccessCount = 0,
  homeLandedCount = 0,
  legionReturnedCount = 0,
  transitScheduler = nil,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(reason)
  if state.failed or state.passed then return end
  state.failed = true
  log("FAIL reason=" .. tostring(reason))
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
    return false
  end
  return true
end

local function requireValue(value, label)
  if value == nil then
    fail("MISSING_REQUIRED value=" .. tostring(label))
    return nil
  end
  return value
end

local function snapshot(nodeId)
  return state.store:GetResource(nodeId, RESOURCE_ID)
end

local function isDemandTerminal(demand)
  if not demand then return true end
  return state.missionDemand.IsTerminalStatus(demand.status)
end

local function stopTransitScheduler()
  if state.transitScheduler and type(state.transitScheduler.Stop) == "function" then
    state.transitScheduler:Stop()
  end
  state.transitScheduler = nil
end

local function verifyFinalState()
  if state.failed or state.passed then return end
  if state.deliveryCommitted ~= true then return end
  if state.missionSuccessCount ~= 1 then return end
  if state.homeLandedCount ~= 1 then return end
  if state.legionReturnedCount ~= 1 then return end

  if not expectEqual(snapshot(ORIGIN_NODE).quantity, FINAL_ORIGIN, "ORIGIN_FINAL") then return end
  if not expectEqual(snapshot(DESTINATION_NODE).quantity, FINAL_DESTINATION, "DESTINATION_FINAL") then return end

  local transaction = state.store:GetTransaction(TRANSFER_ID)
  if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "TRANSFER_FINAL_STATUS") then return end
  if not expectEqual(transaction.cargoId, CARGO_ID, "TRANSFER_CARGO_ID") then return end

  local demand = state.registry:Get(DEMAND_ID)
  if not expectEqual(demand.status, state.missionDemand.Status.SUCCESS, "DEMAND_FINAL_STATUS") then return end

  local followup = state.resourceDemandPolicy.Evaluate({
    nodeId = DESTINATION_NODE,
    resourceId = RESOURCE_ID,
    resourceClass = RESOURCE_CLASS,
    unit = RESOURCE_UNIT,
    target = INITIAL_DESTINATION,
    reorder = REORDER,
    critical = CRITICAL,
    reorderComparison = state.resourceDemandPolicy.ReorderComparison.AT_OR_BELOW,
    supplyParent = ORIGIN_NODE,
  }, snapshot(DESTINATION_NODE))
  if followup ~= nil then fail("FOLLOWUP_DEMAND_UNEXPECTED"); return end

  state.passed = true
  log("PASS resource=" .. RESOURCE_ID
    .. " route=JALALABAD_TO_WRIGHT"
    .. " mission=AUFTRAG_CARGOTRANSPORT"
    .. " manifestQuantity=" .. tostring(TRANSFER_QUANTITY)
    .. " physicalCargoCount=1"
    .. " physicalCargoMassKg=" .. tostring(PHYSICAL_CARGO_MASS_KG)
    .. " strategicKgConversion=false"
    .. " final=" .. tostring(FINAL_ORIGIN) .. "/" .. tostring(FINAL_DESTINATION)
    .. " homeReturn=JALALABAD")
end

local function settleFailure(reason)
  if state.failed or state.passed then return end
  stopTransitScheduler()

  local transaction = state.store:GetTransaction(TRANSFER_ID)
  if transaction.status == state.campaignState.TransactionStatus.RESERVED
      or transaction.status == state.campaignState.TransactionStatus.LOADING then
    state.store:Cancel(TRANSFER_ID)
  elseif transaction.status == state.campaignState.TransactionStatus.IN_TRANSIT then
    state.store:MarkLost(TRANSFER_ID)
  end

  local demand = state.registry:Get(DEMAND_ID)
  if demand and not isDemandTerminal(demand) then
    state.registry:Fail(DEMAND_ID, reason)
  end
  fail(reason)
end

local function commitInTransitIfPhysicalDepartureObserved()
  if state.failed or state.deliveryCommitted or state.inTransitCommitted then return end
  if state.loadingConfirmed ~= true then return end
  if not state.cargo or state.cargo:IsAlive() ~= true then
    settleFailure("PHYSICAL_CARGO_LOST_BEFORE_TRANSIT")
    return
  end

  -- The exact physical manifest static begins inside OMW_LOG_NODE_JALALABAD.
  -- Debit occurs only after that same static has physically left the pickup zone.
  if state.cargo:IsInZone(state.pickupZone) then return end

  local transaction = state.store:MarkInTransit(TRANSFER_ID)
  if not expectEqual(transaction.status, state.campaignState.TransactionStatus.IN_TRANSIT, "TRANSFER_IN_TRANSIT_STATUS") then return end
  state.registry:SetReservationState(DEMAND_ID, "IN_TRANSIT")

  local demand = state.registry:Get(DEMAND_ID)
  if demand.status == state.missionDemand.Status.AI_ASSIGNED then
    state.registry:Activate(DEMAND_ID)
  end

  state.inTransitCommitted = true
  if not expectEqual(snapshot(ORIGIN_NODE).quantity, FINAL_ORIGIN, "ORIGIN_AFTER_TRANSIT") then return end
  log("AIR_AMMO_IN_TRANSIT cargoId=" .. CARGO_ID
    .. " transferId=" .. TRANSFER_ID
    .. " originQuantity=" .. tostring(FINAL_ORIGIN))
end

local function attachFlightCallbacks(flightGroup)
  if flightGroup.__omwAirAmmoCargoTransportAcceptance1Callbacks then return end
  flightGroup.__omwAirAmmoCargoTransportAcceptance1Callbacks = true

  local previousLanded = flightGroup.OnAfterLanded
  flightGroup.OnAfterLanded = function(self, From, Event, To, Airbase)
    if previousLanded then previousLanded(self, From, Event, To, Airbase) end
    if state.failed or self ~= state.flightGroup or not Airbase then return end
    local homeName = state.airwing:GetAirbaseName()
    if Airbase:GetName() ~= homeName then return end
    state.homeLandedCount = state.homeLandedCount + 1
    if not expectEqual(state.homeLandedCount, 1, "HOME_LANDED_COUNT") then return end
    if state.deliveryCommitted ~= true then fail("HOME_LANDED_BEFORE_DELIVERY"); return end
    log("AIR_AMMO_HOME_LANDED group=" .. tostring(self:GetName())
      .. " airbase=" .. tostring(Airbase:GetName()))
  end
end

local function createDemandAndTransfer()
  state.campaignState = OMW_AIR_AMMO_CAMPAIGN_STATE
  state.missionDemand = OMW_AIR_AMMO_MISSION_DEMAND
  state.resourceDemandPolicy = OMW_AIR_AMMO_RESOURCE_DEMAND_POLICY

  state.store = state.campaignState.New({
    nodes = {
      {
        nodeId = ORIGIN_NODE,
        airbaseName = "Jalalabad",
        resources = { [RESOURCE_ID] = { quantity = INITIAL_ORIGIN, unit = RESOURCE_UNIT } },
      },
      {
        nodeId = DESTINATION_NODE,
        airbaseName = "FOB Wright",
        resources = { [RESOURCE_ID] = { quantity = INITIAL_DESTINATION, unit = RESOURCE_UNIT } },
      },
    },
  })
  state.registry = state.missionDemand.New()

  local shortage, shortageCreated = state.store:ReserveResource({
    transactionId = SHORTAGE_TX_ID,
    reservationId = "ACCEPTANCE-SHORTAGE:" .. SHORTAGE_TX_ID,
    kind = state.campaignState.TransactionKind.CONSUMPTION,
    resourceId = RESOURCE_ID,
    quantity = SHORTAGE_QUANTITY,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = DESTINATION_NODE,
  })
  if shortageCreated ~= true then fail("SHORTAGE_TRANSACTION_NOT_CREATED"); return false end
  state.store:Consume(shortage.transactionId)
  state.store:CompleteConsumption(shortage.transactionId)
  if not expectEqual(snapshot(DESTINATION_NODE).quantity, DESTINATION_AFTER_SHORTAGE, "DESTINATION_AFTER_SHORTAGE") then return false end

  local row = {
    nodeId = DESTINATION_NODE,
    resourceId = RESOURCE_ID,
    resourceClass = RESOURCE_CLASS,
    unit = RESOURCE_UNIT,
    target = INITIAL_DESTINATION,
    reorder = REORDER,
    critical = CRITICAL,
    reorderComparison = state.resourceDemandPolicy.ReorderComparison.AT_OR_BELOW,
    supplyParent = ORIGIN_NODE,
  }
  local candidate = state.resourceDemandPolicy.Evaluate(row, snapshot(DESTINATION_NODE))
  if not candidate then fail("RESOURCE_DEMAND_POLICY_NO_CANDIDATE"); return false end
  if not expectEqual(candidate.level, state.resourceDemandPolicy.Level.REORDER, "CANDIDATE_LEVEL") then return false end
  if not expectEqual(candidate.requestedQuantity, TRANSFER_QUANTITY, "CANDIDATE_QUANTITY") then return false end
  if not expectEqual(candidate.supplyParent, ORIGIN_NODE, "CANDIDATE_SUPPLY_PARENT") then return false end

  local demand, demandCreated = state.registry:Create({
    id = DEMAND_ID,
    missionType = state.missionDemand.Type.RESUPPLY,
    origin = ORIGIN_NODE,
    objective = "Restore Wright Ground AMMO by Jalalabad CH-47 slingload manifest",
    target = { nodeId = DESTINATION_NODE, resourceId = RESOURCE_ID },
    priority = 20,
    playerCapable = false,
    aiCapable = true,
    reservationState = "UNRESERVED",
    successCriteria = { destinationQuantity = FINAL_DESTINATION },
    failureConsequences = { resourceTransfer = "LOST_OR_CANCELLED_BY_CAMPAIGNSTATE" },
    createdReason = candidate.level,
    dedupeKey = candidate.dedupeKey,
  })
  if demandCreated ~= true then fail("MISSION_DEMAND_NOT_CREATED"); return false end

  local transfer, transferCreated = state.store:ReserveResource({
    transactionId = TRANSFER_ID,
    reservationId = "MISSION-DEMAND:" .. DEMAND_ID,
    cargoId = CARGO_ID,
    missionDemandId = DEMAND_ID,
    carrierEntityId = CARRIER_ENTITY_ID,
    kind = state.campaignState.TransactionKind.TRANSFER,
    resourceId = RESOURCE_ID,
    quantity = TRANSFER_QUANTITY,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = ORIGIN_NODE,
    destinationNodeId = DESTINATION_NODE,
  })
  if transferCreated ~= true then fail("TRANSFER_RESERVATION_NOT_CREATED"); return false end

  state.registry:SetReservationState(DEMAND_ID, "RESERVED", {
    transactionId = TRANSFER_ID,
    cargoId = CARGO_ID,
    originNodeId = ORIGIN_NODE,
    destinationNodeId = DESTINATION_NODE,
    resourceId = RESOURCE_ID,
    quantity = TRANSFER_QUANTITY,
    carrierEntityId = CARRIER_ENTITY_ID,
  })
  state.registry:AssignAI(DEMAND_ID, ASSIGNEE_ID)

  log("AIR_AMMO_DEMAND_RESERVED demandId=" .. demand.id
    .. " transferId=" .. transfer.transactionId
    .. " cargoId=" .. CARGO_ID
    .. " quantity=" .. tostring(TRANSFER_QUANTITY))
  return true
end

local function preparePhysicalExecution()
  if type(OMW) ~= "table" or type(OMW.AirOps) ~= "table"
      or type(OMW.AirOps.Jalalabad) ~= "table"
      or OMW.AirOps.Jalalabad.Status ~= "RUNNING" then
    fail("JALALABAD_AIRWING_NOT_RUNNING")
    return false
  end

  state.airwing = requireValue(OMW.AirOps.Jalalabad.Airwing, "JALALABAD_AIRWING")
  state.squadron = requireValue(OMW.AirOps.Jalalabad.Squadrons and OMW.AirOps.Jalalabad.Squadrons[AIR_SQUADRON_KEY], AIR_SQUADRON_NAME)
  requireValue(GROUP:FindByName(AIR_TEMPLATE_NAME), AIR_TEMPLATE_NAME)
  state.pickupZone = requireValue(ZONE:FindByName(PICKUP_ZONE_NAME), PICKUP_ZONE_NAME)
  state.dropZone = requireValue(ZONE:FindByName(DROP_ZONE_NAME), DROP_ZONE_NAME)
  if state.failed then return false end
  if not state.dropZone.ZoneID then fail("DROP_ZONE_REQUIRES_ME_ZONE_ID"); return false end

  local spawner = SPAWNSTATIC:NewFromType(PHYSICAL_CARGO_TYPE, PHYSICAL_CARGO_CATEGORY, country.id.USA)
    :InitCargo(true)
    :InitCargoMass(PHYSICAL_CARGO_MASS_KG)
    :InitCoordinate(state.pickupZone:GetCoordinate())
    :InitValidateAndRepositionStatic(true, CARGO_REPOSITION_RADIUS_M)

  state.cargo = requireValue(spawner:Spawn(0, CARGO_ID), CARGO_ID)
  if state.failed then return false end
  if state.cargo:IsAlive() ~= true then fail("PHYSICAL_CARGO_NOT_ALIVE_AFTER_SPAWN"); return false end
  if not state.cargo:IsInZone(state.pickupZone) then fail("PHYSICAL_CARGO_NOT_IN_PICKUP_ZONE"); return false end

  local previousFlightOnMission = state.airwing.OnAfterFlightOnMission
  state.airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if state.failed or Mission ~= state.mission then return end
    if state.flightGroup then fail("MULTIPLE_FLIGHTS_ASSIGNED"); return end

    state.flightGroup = requireValue(FlightGroup, "AIR_FLIGHTGROUP")
    if state.failed then return end
    state.asset = Mission:GetAssetByName(FlightGroup:GetName())
    if not state.asset then fail("AIR_MISSION_ASSET_NOT_FOUND"); return end
    attachFlightCallbacks(FlightGroup)

    local transaction = state.store:MarkLoading(TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.LOADING, "TRANSFER_LOADING_STATUS") then return end
    state.registry:SetReservationState(DEMAND_ID, "LOADING")
    state.loadingConfirmed = true

    state.transitScheduler = SCHEDULER:New(nil, function()
      commitInTransitIfPhysicalDepartureObserved()
    end, {}, TRANSIT_CHECK_INTERVAL_SEC, TRANSIT_CHECK_INTERVAL_SEC)

    log("AIR_AMMO_FLIGHT_ON_MISSION group=" .. tostring(FlightGroup:GetName())
      .. " squadron=" .. AIR_SQUADRON_NAME
      .. " transferStatus=LOADING")
  end

  local previousAssetReturned = state.airwing.OnAfterLegionAssetReturned
  state.airwing.OnAfterLegionAssetReturned = function(self, From, Event, To, Cohort, Asset)
    if previousAssetReturned then previousAssetReturned(self, From, Event, To, Cohort, Asset) end
    if state.failed or not state.asset or Asset ~= state.asset then return end
    if Cohort ~= state.squadron then fail("RETURNED_UNEXPECTED_SQUADRON"); return end
    state.legionReturnedCount = state.legionReturnedCount + 1
    if not expectEqual(state.legionReturnedCount, 1, "LEGION_RETURNED_COUNT") then return end
    if state.homeLandedCount ~= 1 then fail("LEGION_RETURNED_BEFORE_HOME_LANDING"); return end
    log("AIR_AMMO_LEGION_ASSET_RETURNED squadron=" .. AIR_SQUADRON_NAME
      .. " asset=" .. tostring(Asset.spawngroupname)
      .. " homeLandingConfirmed=true")
    verifyFinalState()
  end

  state.mission = requireValue(AUFTRAG:NewCARGOTRANSPORT(state.cargo, state.dropZone), "CARGOTRANSPORT_AUFTRAG")
  if state.failed then return false end
  state.mission:SetName("OMW_AIR_AMMO_RESUPPLY_JALALABAD_TO_WRIGHT_CARGOTRANSPORT")
  state.mission:SetRequiredAssets(1, 1)
  state.mission:AssignSquadrons({ state.squadron })
  state.mission:SetPriority(20, true)

  local previousSuccess = state.mission.OnAfterSuccess
  state.mission.OnAfterSuccess = function(self, From, Event, To)
    if previousSuccess then previousSuccess(self, From, Event, To) end
    if state.failed or self ~= state.mission then return end
    state.missionSuccessCount = state.missionSuccessCount + 1
    if not expectEqual(state.missionSuccessCount, 1, "MISSION_SUCCESS_COUNT") then return end
    if state.deliveryCommitted then fail("DUPLICATE_DELIVERY_CALLBACK"); return end
    if not state.cargo or state.cargo:IsAlive() ~= true then settleFailure("CARGO_NOT_ALIVE_AT_SUCCESS"); return end
    if not state.cargo:IsInZone(state.dropZone) then settleFailure("CARGO_NOT_IN_WRIGHT_DROP_ZONE_AT_SUCCESS"); return end
    if state.inTransitCommitted ~= true then settleFailure("MISSION_SUCCESS_BEFORE_IN_TRANSIT_COMMIT"); return end

    stopTransitScheduler()
    local transaction = state.store:MarkDelivered(TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "TRANSFER_DELIVERED_STATUS") then return end
    state.registry:SetReservationState(DEMAND_ID, "DELIVERED")
    state.registry:Succeed(DEMAND_ID, {
      transactionId = TRANSFER_ID,
      cargoId = CARGO_ID,
      carrierEntityId = CARRIER_ENTITY_ID,
      physicalMission = "AUFTRAG:CARGOTRANSPORT",
    })
    state.deliveryCommitted = true
    if not expectEqual(snapshot(DESTINATION_NODE).quantity, FINAL_DESTINATION, "DESTINATION_AFTER_DELIVERY") then return end

    log("AIR_AMMO_DELIVERY_CONFIRMED cargoId=" .. CARGO_ID
      .. " zone=" .. DROP_ZONE_NAME
      .. " quantity=" .. tostring(TRANSFER_QUANTITY)
      .. " physicalCargoCount=1"
      .. " campaignStateStatus=DELIVERED demandStatus=SUCCESS")
    verifyFinalState()
  end

  local previousFailed = state.mission.OnAfterFailed
  state.mission.OnAfterFailed = function(self, From, Event, To)
    if previousFailed then previousFailed(self, From, Event, To) end
    if state.failed or state.deliveryCommitted then return end
    settleFailure("MOOSE_CARGOTRANSPORT_FAILED")
  end

  state.airwing:AddMission(state.mission)
  log("AIR_AMMO_MISSION_QUEUED mission=AUFTRAG:CARGOTRANSPORT"
    .. " cargoId=" .. CARGO_ID
    .. " pickup=" .. PICKUP_ZONE_NAME
    .. " drop=" .. DROP_ZONE_NAME
    .. " dropZoneId=" .. tostring(state.dropZone.ZoneID)
    .. " physicalCargoMassKg=" .. tostring(PHYSICAL_CARGO_MASS_KG)
    .. " strategicKgConversion=false")
  return true
end

local function start()
  log("START scope=isolated_air_ammo_contract"
    .. " strategicAuthority=CampaignState"
    .. " physicalExecutor=MOOSE_CARGOTRANSPORT"
    .. " manifestQuantity=" .. tostring(TRANSFER_QUANTITY)
    .. " physicalCargoCount=1")

  if not createDemandAndTransfer() then return end
  preparePhysicalExecution()
end

SCHEDULER:New(nil, start, {}, 10)
