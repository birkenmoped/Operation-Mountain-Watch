-- Operation Mountain Watch - generic Ground meta RESUPPLY execution acceptance.
-- Test-ID: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
--
-- Acceptance-only vertical slice using GROUND_FUEL_PACKAGE as the first meta-resource fixture:
-- Honaker CampaignState shortage -> ResourceDemandPolicy -> MissionDemand
-- -> CampaignState TRANSFER Joyce -> Honaker -> MOOSE BRIGADE/PLATOON/ARMYGROUP
-- -> neutral AUFTRAG NOTHING movement -> destination-zone proof -> delivery settlement
-- -> explicit OnRoad RTZ -> Returned -> Warehouse AddAsset.
--
-- AUFTRAG NOTHING carries no strategic fuel/cargo authority. CampaignState remains authoritative.

local TEST_ID = "GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local ORIGIN_NODE = "GROUND_NODE_JOYCE"
local DESTINATION_NODE = "GROUND_NODE_HONAKER"
local RESOURCE_ID = "GROUND_FUEL_PACKAGE"
local RESOURCE_UNIT = "count"
local WAREHOUSE_NAME = "WH_BLUE_GND_JOYCE"
local ORIGIN_ACCESS_ZONE = "ZON_BLUE_GND_JOYCE_ACCESS"
local DESTINATION_ACCESS_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"
local TEMPLATE_NAME = "TPL_BLUE_CONVOY_FUEL_LIGHT_06"
local BRIGADE_NAME = "BDE_BLUE_GND_JOYCE_META_RESUPPLY_ACCEPTANCE"
local PLATOON_NAME = "PLT_BLUE_GND_JOYCE_META_RESUPPLY_ACCEPTANCE"
local DEMAND_ID = "RESUPPLY-ACCEPTANCE-HONAKER-META-FUEL-001"
local TRANSFER_ID = "TRANSFER-ACCEPTANCE-JOYCE-HONAKER-META-FUEL-001"
local SHORTAGE_TX_ID = "CONSUMPTION-ACCEPTANCE-HONAKER-META-FUEL-001"
local CARRIER_ENTITY_ID = "GROUND-RESUPPLY-JOYCE-HONAKER-META-FUEL-CONVOY-LIGHT-001"
local ASSIGNEE_ID = "AI:BRIGADE:" .. BRIGADE_NAME

local INITIAL_ORIGIN = 40
local INITIAL_DESTINATION = 36
local SHORTAGE_QUANTITY = 18
local SHORTAGE_DESTINATION = 18
local TRANSFER_QUANTITY = 18
local FINAL_ORIGIN = 22
local FINAL_DESTINATION = 36
local ROAD_SPEED_KNOTS = 27
local DESTINATION_CHECK_INTERVAL_SEC = 15
local DESTINATION_EXECUTION_GRACE_SEC = 90
local RETURN_ISSUE_DELAY_SEC = 30
local RETURN_SETTLEMENT_DELAY_SEC = 12

local state = {
  failed = false,
  passed = false,
  spawnCount = 0,
  armyOnMissionCount = 0,
  missionExecuteCount = 0,
  missionDoneCount = 0,
  returnedCount = 0,
  addAssetCount = 0,
  deliveryCommitted = false,
  returnIssued = false,
  destinationObserved = false,
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

local function findDestinationStockRow(initialStock)
  for _, row in ipairs(initialStock.Rows or {}) do
    if row.nodeId == DESTINATION_NODE and row.resourceId == RESOURCE_ID then
      return row
    end
  end
  return nil
end

local function verifyFinalState()
  if state.failed or state.passed then return end
  if not expectEqual(state.spawnCount, 1, "SPAWN_COUNT") then return end
  if not expectEqual(state.returnedCount, 1, "RETURNED_COUNT") then return end
  if not expectEqual(state.addAssetCount, 1, "WAREHOUSE_ADD_ASSET_COUNT") then return end
  if state.deliveryCommitted ~= true then fail("DELIVERY_NOT_COMMITTED"); return end
  if state.armyGroup and state.armyGroup:IsAlive() then
    fail("PHYSICAL_GROUP_NOT_REMOVED_AFTER_WAREHOUSE_ADD")
    return
  end

  local origin = snapshot(ORIGIN_NODE)
  local destination = snapshot(DESTINATION_NODE)
  if not expectEqual(origin.quantity, FINAL_ORIGIN, "ORIGIN_FINAL_QUANTITY") then return end
  if not expectEqual(destination.quantity, FINAL_DESTINATION, "DESTINATION_FINAL_QUANTITY") then return end

  local followup = OMW_GROUND_RESUPPLY_RESOURCE_DEMAND_POLICY.Evaluate(state.stockRow, destination)
  if followup ~= nil then
    fail("FOLLOWUP_DEMAND_UNEXPECTED dedupeKey=" .. tostring(followup.dedupeKey))
    return
  end

  local demand = state.registry:Get(DEMAND_ID)
  if not expectEqual(demand.status, OMW_GROUND_RESUPPLY_MISSION_DEMAND.Status.SUCCESS, "DEMAND_FINAL_STATUS") then return end
  if state.registry:GetActiveByDedupeKey(state.candidate.dedupeKey) ~= nil then
    fail("DEMAND_DEDUPE_KEY_STILL_ACTIVE")
    return
  end

  state.passed = true
  log("PASS originFinal=" .. tostring(origin.quantity)
    .. " destinationFinal=" .. tostring(destination.quantity)
    .. " transferQuantity=" .. tostring(TRANSFER_QUANTITY)
    .. " template=" .. TEMPLATE_NAME
    .. " physicalMission=NOTHING"
    .. " demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1")
end

local function issueReturn()
  if state.failed or state.returnIssued then return end
  if not state.armyGroup or not state.armyGroup:IsAlive() then
    fail("RETURN_GROUP_NOT_ALIVE")
    return
  end

  state.returnIssued = true
  state.armyGroup:RTZ(state.originZone, ENUMS.Formation.Vehicle.OnRoad)
  if not state.armyGroup:IsReturning() then
    fail("RETURN_RTZ_NOT_ACCEPTED state=" .. tostring(state.armyGroup:GetState()))
    return
  end
  log("RETURN_RTZ_ISSUED group=" .. tostring(state.armyGroup:GetName())
    .. " zone=" .. ORIGIN_ACCESS_ZONE .. " formation=OnRoad")
end

local function checkDestinationProgress()
  if state.failed or state.passed or state.deliveryCommitted then return end
  if not state.armyGroup or not state.armyGroup:IsAlive() then return end

  if state.armyGroup:IsInZone(state.destinationZone) == true then
    if state.destinationObserved ~= true then
      state.destinationObserved = true
      log("DESTINATION_ZONE_ENTERED group=" .. tostring(state.armyGroup:GetName())
        .. " graceSec=" .. tostring(DESTINATION_EXECUTION_GRACE_SEC))
      SCHEDULER:New(nil, function()
        if state.failed or state.passed or state.deliveryCommitted or state.missionExecuteCount > 0 then return end
        fail("DESTINATION_EXECUTION_TIMEOUT seconds=" .. tostring(DESTINATION_EXECUTION_GRACE_SEC)
          .. " missionExecuteCount=" .. tostring(state.missionExecuteCount)
          .. " missionDoneCount=" .. tostring(state.missionDoneCount))
      end, {}, DESTINATION_EXECUTION_GRACE_SEC)
    end
    return
  end

  SCHEDULER:New(nil, checkDestinationProgress, {}, DESTINATION_CHECK_INTERVAL_SEC)
end

local function attachArmyGroupCallbacks(armyGroup)
  if armyGroup.__omwGroundMetaResupplyNothingAcceptanceCallbacks then return end
  armyGroup.__omwGroundMetaResupplyNothingAcceptanceCallbacks = true

  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if state.failed or Mission ~= state.mission then return end
    state.missionExecuteCount = state.missionExecuteCount + 1
    if not expectEqual(state.missionExecuteCount, 1, "MISSION_EXECUTE_COUNT") then return end

    if self:IsInZone(state.destinationZone) ~= true then
      fail("MISSION_EXECUTE_OUTSIDE_DESTINATION zone=" .. DESTINATION_ACCESS_ZONE)
      return
    end

    local transaction = state.store:MarkDelivered(TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "TRANSFER_DELIVERY_STATUS") then return end

    state.registry:SetReservationState(DEMAND_ID, "DELIVERED", {
      transactionId = TRANSFER_ID,
      originNodeId = ORIGIN_NODE,
      destinationNodeId = DESTINATION_NODE,
      resourceId = RESOURCE_ID,
      quantity = TRANSFER_QUANTITY,
      carrierEntityId = CARRIER_ENTITY_ID,
    })
    state.registry:Succeed(DEMAND_ID, {
      transactionId = TRANSFER_ID,
      carrierEntityId = CARRIER_ENTITY_ID,
      destinationNodeId = DESTINATION_NODE,
    })
    state.deliveryCommitted = true

    if not expectEqual(snapshot(DESTINATION_NODE).quantity, FINAL_DESTINATION, "DESTINATION_DELIVERED_QUANTITY") then return end

    log("DELIVERY_CONFIRMED group=" .. tostring(self:GetName())
      .. " destination=" .. DESTINATION_NODE
      .. " quantity=" .. tostring(TRANSFER_QUANTITY)
      .. " physicalMission=NOTHING campaignStateStatus=DELIVERED demandStatus=SUCCESS")

    state.mission:__Cancel(1)
  end

  function armyGroup:OnAfterMissionDone(From, Event, To, Mission)
    if state.failed or Mission ~= state.mission then return end
    state.missionDoneCount = state.missionDoneCount + 1
    if not expectEqual(state.missionDoneCount, 1, "MISSION_DONE_COUNT") then return end
    if state.deliveryCommitted ~= true then fail("MISSION_DONE_BEFORE_DELIVERY_SETTLEMENT"); return end
    log("MISSION_DONE deliveryCommitted=true returnIssueDelaySec=" .. tostring(RETURN_ISSUE_DELAY_SEC))
    SCHEDULER:New(nil, issueReturn, {}, RETURN_ISSUE_DELAY_SEC)
  end

  function armyGroup:OnAfterRTZ(From, Event, To, Zone, Formation)
    if state.failed then return end
    if Zone ~= state.originZone then fail("RETURN_RTZ_UNEXPECTED_ZONE"); return end
    if Formation ~= ENUMS.Formation.Vehicle.OnRoad then fail("RETURN_RTZ_UNEXPECTED_FORMATION"); return end
    log("RETURN_RTZ_ACTIVE group=" .. tostring(self:GetName()))
  end

  function armyGroup:OnAfterReturned(From, Event, To)
    if state.failed then return end
    if self ~= state.armyGroup then fail("RETURNED_DIFFERENT_GROUP"); return end
    state.returnedCount = state.returnedCount + 1
    if not expectEqual(state.returnedCount, 1, "RETURNED_COUNT_EVENT") then return end
    log("RETURNED_HANDOFF group=" .. tostring(self:GetName()))
    SCHEDULER:New(nil, verifyFinalState, {}, RETURN_SETTLEMENT_DELAY_SEC)
  end
end

local function installBrigadeCallbacks()
  state.brigade.OnAfterAssetSpawned = function(self, From, Event, To, Group, Asset, Request)
    if state.failed then return end
    state.spawnCount = state.spawnCount + 1
    if not expectEqual(state.spawnCount, 1, "SPAWN_COUNT_EVENT") then return end

    local transaction = state.store:MarkLoading(TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.LOADING, "TRANSFER_LOADING_STATUS") then return end
    state.registry:SetReservationState(DEMAND_ID, "LOADING")
    log("GROUP_MATERIALIZED name=" .. tostring(Group and Group:GetName() or "UNKNOWN")
      .. " template=" .. TEMPLATE_NAME .. " transferStatus=LOADING")
  end

  state.brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
    if state.failed or Mission ~= state.mission then return end
    state.armyOnMissionCount = state.armyOnMissionCount + 1
    if not expectEqual(state.armyOnMissionCount, 1, "ARMY_ON_MISSION_COUNT") then return end
    if not ArmyGroup then fail("ARMYGROUP_NIL"); return end

    state.armyGroup = ArmyGroup
    attachArmyGroupCallbacks(ArmyGroup)

    local transaction = state.store:MarkInTransit(TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.IN_TRANSIT, "TRANSFER_IN_TRANSIT_STATUS") then return end
    state.registry:SetReservationState(DEMAND_ID, "IN_TRANSIT")
    state.registry:Activate(DEMAND_ID)
    if not expectEqual(snapshot(ORIGIN_NODE).quantity, FINAL_ORIGIN, "ORIGIN_IN_TRANSIT_QUANTITY") then return end

    log("ARMY_ON_MISSION group=" .. tostring(ArmyGroup:GetName())
      .. " mission=NOTHING transferStatus=IN_TRANSIT demandStatus=ACTIVE")
    SCHEDULER:New(nil, checkDestinationProgress, {}, DESTINATION_CHECK_INTERVAL_SEC)
  end

  state.brigade.OnAfterAddAsset = function(self, From, Event, To, Group, Groups)
    if state.failed then return end
    state.addAssetCount = state.addAssetCount + 1
    if not expectEqual(state.addAssetCount, 1, "WAREHOUSE_ADD_ASSET_COUNT_EVENT") then return end
    log("WAREHOUSE_ADD_ASSET group=" .. tostring(Group and Group:GetName() or "UNKNOWN"))
  end

  state.brigade.OnAfterStart = function(self, From, Event, To)
    if state.failed then return end
    log("BRIGADE_STARTED brigade=" .. BRIGADE_NAME)
    SCHEDULER:New(nil, function()
      if state.failed then return end
      local availableAssets = state.platoon:CountAssets(true, AUFTRAG.Type.NOTHING)
      if not expectEqual(availableAssets, 1, "PLATOON_ASSET_COUNT") then return end

      state.mission = AUFTRAG:NewNOTHING(state.destinationZone)
      state.mission:SetName("OMW_GROUND_META_RESUPPLY_JOYCE_TO_HONAKER")
      state.mission:SetMissionSpeed(ROAD_SPEED_KNOTS)
      state.mission:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
      state.mission:SetReturnToLegion(false)
      state.mission:SetPriority(20, true)
      state.brigade:AddMission(state.mission)
      log("MISSION_QUEUED type=NOTHING formation=OnRoad speedKt=" .. tostring(ROAD_SPEED_KNOTS)
        .. " origin=" .. ORIGIN_NODE .. " destination=" .. DESTINATION_NODE
        .. " resource=" .. RESOURCE_ID .. " template=" .. TEMPLATE_NAME)
    end, {}, 5)
  end
end

local function createDemandAndReservation()
  if not expectEqual(snapshot(ORIGIN_NODE).quantity, INITIAL_ORIGIN, "ORIGIN_INITIAL_QUANTITY") then return false end
  if not expectEqual(snapshot(DESTINATION_NODE).quantity, INITIAL_DESTINATION, "DESTINATION_INITIAL_QUANTITY") then return false end

  local shortage, created = state.store:ReserveResource({
    transactionId = SHORTAGE_TX_ID,
    reservationId = "ACCEPTANCE-SHORTAGE:" .. SHORTAGE_TX_ID,
    kind = state.campaignState.TransactionKind.CONSUMPTION,
    resourceId = RESOURCE_ID,
    quantity = SHORTAGE_QUANTITY,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = DESTINATION_NODE,
  })
  if created ~= true then fail("SHORTAGE_TRANSACTION_NOT_CREATED"); return false end
  state.store:Consume(shortage.transactionId)
  state.store:CompleteConsumption(shortage.transactionId)

  local afterShortage = snapshot(DESTINATION_NODE)
  if not expectEqual(afterShortage.quantity, SHORTAGE_DESTINATION, "DESTINATION_AFTER_SHORTAGE") then return false end

  state.candidate = OMW_GROUND_RESUPPLY_RESOURCE_DEMAND_POLICY.Evaluate(state.stockRow, afterShortage)
  if not state.candidate then fail("RESOURCE_DEMAND_POLICY_NO_CANDIDATE"); return false end
  if not expectEqual(state.candidate.level, "REORDER", "CANDIDATE_LEVEL") then return false end
  if not expectEqual(state.candidate.requestedQuantity, TRANSFER_QUANTITY, "CANDIDATE_QUANTITY") then return false end
  if not expectEqual(state.candidate.supplyParent, ORIGIN_NODE, "CANDIDATE_SUPPLY_PARENT") then return false end

  state.registry = OMW_GROUND_RESUPPLY_MISSION_DEMAND.New()
  local demand, demandCreated = state.registry:Create({
    id = DEMAND_ID,
    missionType = OMW_GROUND_RESUPPLY_MISSION_DEMAND.Type.RESUPPLY,
    origin = ORIGIN_NODE,
    objective = "Restore Honaker Ground fuel meta-resource to target stock",
    target = { nodeId = DESTINATION_NODE, resourceId = RESOURCE_ID },
    priority = 20,
    playerCapable = false,
    aiCapable = true,
    reservationState = "UNRESERVED",
    successCriteria = { destinationQuantity = FINAL_DESTINATION },
    failureConsequences = { resourceTransfer = "LOST_OR_CANCELLED_BY_CAMPAIGNSTATE" },
    createdReason = state.candidate.level,
    dedupeKey = state.candidate.dedupeKey,
  })
  if demandCreated ~= true then fail("MISSION_DEMAND_NOT_CREATED"); return false end

  local transfer, transferCreated = state.store:ReserveResource({
    transactionId = TRANSFER_ID,
    reservationId = "MISSION-DEMAND:" .. DEMAND_ID,
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
    originNodeId = ORIGIN_NODE,
    destinationNodeId = DESTINATION_NODE,
    resourceId = RESOURCE_ID,
    quantity = TRANSFER_QUANTITY,
    carrierEntityId = CARRIER_ENTITY_ID,
  })
  state.registry:AssignAI(DEMAND_ID, ASSIGNEE_ID)

  log("DEMAND_RESERVED demandId=" .. demand.id
    .. " dedupeKey=" .. state.candidate.dedupeKey
    .. " origin=" .. ORIGIN_NODE .. " destination=" .. DESTINATION_NODE
    .. " quantity=" .. tostring(TRANSFER_QUANTITY))
  return true
end

local function preparePhysicalExecution()
  state.originZone = requireValue(ZONE:FindByName(ORIGIN_ACCESS_ZONE), ORIGIN_ACCESS_ZONE)
  state.destinationZone = requireValue(ZONE:FindByName(DESTINATION_ACCESS_ZONE), DESTINATION_ACCESS_ZONE)
  requireValue(GROUP:FindByName(TEMPLATE_NAME), TEMPLATE_NAME)
  requireValue(UNIT:FindByName(WAREHOUSE_NAME) or STATIC:FindByName(WAREHOUSE_NAME, false), WAREHOUSE_NAME)
  if state.failed then return false end

  state.brigade = requireValue(BRIGADE:New(WAREHOUSE_NAME, BRIGADE_NAME), BRIGADE_NAME)
  if state.failed then return false end
  state.brigade:SetSpawnZone(state.originZone, 1000)

  state.platoon = requireValue(PLATOON:New(TEMPLATE_NAME, 1, PLATOON_NAME), PLATOON_NAME)
  if state.failed then return false end
  state.platoon:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
  state.brigade:AddPlatoon(state.platoon)

  OMW_GROUND_RESUPPLY_ROAD_SPAWN_ADAPTER.Install(state.brigade, {
    resolveRoadSpawn = function(self, asset, request)
      if not asset or asset.templatename ~= TEMPLATE_NAME then return nil end
      return {
        entityId = CARRIER_ENTITY_ID,
        accessZone = state.originZone,
        forwardCoordinate = state.destinationZone:GetCoordinate(),
      }
    end,
    log = function(message) log(message) end,
  })

  log("PHYSICAL_EXECUTION_READY warehouse=" .. WAREHOUSE_NAME
    .. " template=" .. TEMPLATE_NAME
    .. " physicalMission=NOTHING"
    .. " originZone=" .. ORIGIN_ACCESS_ZONE
    .. " destinationZone=" .. DESTINATION_ACCESS_ZONE)
  return true
end

log("START testId=" .. TEST_ID .. " origin=" .. ORIGIN_NODE
  .. " destination=" .. DESTINATION_NODE .. " resource=" .. RESOURCE_ID)

if type(USERFLAG) ~= "table" or type(USERFLAG.New) ~= "function" then
  fail("MOOSE_USERFLAG_UNAVAILABLE")
  return
end
local warehouseReady = USERFLAG:New("OMW_WAREHOUSE_READY"):Get()
local groundReady = USERFLAG:New("OMW_GROUND_READY"):Get()
if warehouseReady ~= 1 then fail("OMW_WAREHOUSE_READY expected=1 actual=" .. tostring(warehouseReady)); return end
if groundReady ~= 1 then fail("OMW_GROUND_READY expected=1 actual=" .. tostring(groundReady)); return end
if type(OMW) ~= "table" or type(OMW.Ground) ~= "table" or type(OMW.Ground.Base) ~= "table" then
  fail("OMW_GROUND_BASE_UNAVAILABLE")
  return
end

local groundContext = OMW.Ground.Base.GetContext()
if type(groundContext) ~= "table" then fail("GROUND_CONTEXT_UNAVAILABLE"); return end
state.store = requireValue(groundContext.store, "groundContext.store")
state.campaignState = requireValue(groundContext.campaignState, "groundContext.campaignState")
if state.failed then return end

state.stockRow = findDestinationStockRow(OMW.Ground.Base.GetInitialStock())
if not state.stockRow then fail("HONAKER_FUEL_STOCK_ROW_NOT_FOUND"); return end

if not createDemandAndReservation() then return end
if not preparePhysicalExecution() then return end
installBrigadeCallbacks()
state.brigade:Start()
