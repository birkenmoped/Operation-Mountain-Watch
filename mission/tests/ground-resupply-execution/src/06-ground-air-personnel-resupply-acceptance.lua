-- Operation Mountain Watch - Stage 1D-P combined PERSONNEL RESUPPLY acceptance.
-- Test-ID: GROUND-AIR-PERSONNEL-RESUPPLY-ACCEPTANCE-1
--
-- Acceptance-only vertical slice with one shared strategic resource:
--   A) Joyce -> Honaker: CampaignState PERSONNEL shortage -> MissionDemand
--      -> CampaignState TRANSFER -> MOOSE BRIGADE/PLATOON/ARMYGROUP
--      -> AUFTRAG NOTHING -> exact-once delivery -> explicit OnRoad RTZ.
--   B) Jalalabad -> Fortress: CampaignState PERSONNEL shortage -> MissionDemand
--      -> CampaignState TRANSFER -> existing Jalalabad AIRWING CH-47 squadron
--      -> AUFTRAG LANDATCOORDINATE at the existing Fortress invisible FARP
--      -> grounded/position proof -> exact-once delivery -> normal MOOSE air return.
--
-- PERSONNEL remains CampaignState headcount. No physical infantry cargo group is
-- created and TROOPTRANSPORT is intentionally not used. CampaignState is the
-- sole strategic PERSONNEL authority.

local TEST_ID = "GROUND-AIR-PERSONNEL-RESUPPLY-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local RESOURCE_ID = "GROUND_PERSONNEL"
local RESOURCE_CLASS = "GROUND_PERSONNEL"
local RESOURCE_UNIT = "count"

local GROUND_ORIGIN_NODE = "GROUND_NODE_JOYCE"
local GROUND_DESTINATION_NODE = "GROUND_NODE_HONAKER"
local GROUND_WAREHOUSE_NAME = "WH_BLUE_GND_JOYCE"
local GROUND_ORIGIN_ACCESS_ZONE = "ZON_BLUE_GND_JOYCE_ACCESS"
local GROUND_DESTINATION_ACCESS_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"
local GROUND_TEMPLATE_NAME = "TPL_BLUE_CONVOY_LIGHT_06"
local GROUND_BRIGADE_NAME = "BDE_BLUE_GND_JOYCE_PERSONNEL_RESUPPLY_ACCEPTANCE"
local GROUND_PLATOON_NAME = "PLT_BLUE_GND_JOYCE_PERSONNEL_RESUPPLY_ACCEPTANCE"
local GROUND_DEMAND_ID = "RESUPPLY-ACCEPTANCE-HONAKER-PERSONNEL-001"
local GROUND_TRANSFER_ID = "TRANSFER-ACCEPTANCE-JOYCE-HONAKER-PERSONNEL-001"
local GROUND_SHORTAGE_TX_ID = "CONSUMPTION-ACCEPTANCE-HONAKER-PERSONNEL-001"
local GROUND_CARRIER_ENTITY_ID = "GROUND-RESUPPLY-JOYCE-HONAKER-PERSONNEL-CONVOY-LIGHT-001"
local GROUND_ASSIGNEE_ID = "AI:BRIGADE:" .. GROUND_BRIGADE_NAME

local AIR_ORIGIN_NODE = "GROUND_NODE_JALALABAD"
local AIR_DESTINATION_NODE = "GROUND_NODE_FORTRESS"
local AIR_FARP_NAME = "OMW_BLUE_LZ_FORTRESS_01"
local AIR_SQUADRON_KEY = "CH47"
local AIR_SQUADRON_NAME = "SQ_US_JBAD_CH47_HEAVYLIFT"
local AIR_TEMPLATE_NAME = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
local AIR_DEMAND_ID = "RESUPPLY-ACCEPTANCE-FORTRESS-PERSONNEL-AIR-001"
local AIR_TRANSFER_ID = "TRANSFER-ACCEPTANCE-JALALABAD-FORTRESS-PERSONNEL-AIR-001"
local AIR_SHORTAGE_TX_ID = "CONSUMPTION-ACCEPTANCE-FORTRESS-PERSONNEL-001"
local AIR_CARRIER_ENTITY_ID = "AIR-RESUPPLY-JALALABAD-FORTRESS-PERSONNEL-CH47-001"
local AIR_ASSIGNEE_ID = "AI:SQUADRON:" .. AIR_SQUADRON_NAME

local GROUND_INITIAL_ORIGIN = 180
local GROUND_INITIAL_DESTINATION = 120
local GROUND_SHORTAGE_QUANTITY = 25
local GROUND_DESTINATION_AFTER_SHORTAGE = 95
local GROUND_TRANSFER_QUANTITY = 25
local GROUND_FINAL_ORIGIN = 155
local GROUND_FINAL_DESTINATION = 120
local GROUND_REORDER = 96

local AIR_INITIAL_ORIGIN = 480
local AIR_INITIAL_DESTINATION = 160
local AIR_SHORTAGE_QUANTITY = 33
local AIR_DESTINATION_AFTER_SHORTAGE = 127
local AIR_TRANSFER_QUANTITY = 33
local AIR_FINAL_ORIGIN = 447
local AIR_FINAL_DESTINATION = 160
local AIR_REORDER = 128

local ROAD_SPEED_KNOTS = 27
local DESTINATION_CHECK_INTERVAL_SEC = 15
local DESTINATION_EXECUTION_GRACE_SEC = 90
local RETURN_ISSUE_DELAY_SEC = 30
local GROUND_RETURN_SETTLEMENT_DELAY_SEC = 12

local AIR_LANDING_DWELL_SEC = 30
local AIR_LANDING_ACCEPTANCE_RADIUS_M = 100

local state = {
  failed = false,
  passed = false,
  registry = nil,
  store = nil,
  campaignState = nil,
  ground = {
    spawnCount = 0,
    armyOnMissionCount = 0,
    missionExecuteCount = 0,
    missionDoneCount = 0,
    returnedCount = 0,
    addAssetCount = 0,
    destinationObserved = false,
    deliveryCommitted = false,
    returnIssued = false,
  },
  air = {
    flightOnMissionCount = 0,
    takeoffCount = 0,
    missionDoneCount = 0,
    legionReturnedCount = 0,
    deliveryCommitted = false,
  },
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

local function findStockRow(initialStock, nodeId)
  for _, row in ipairs(initialStock.Rows or {}) do
    if row.nodeId == nodeId and row.resourceId == RESOURCE_ID then
      return row
    end
  end
  return nil
end

local function createDemandAndReservation(spec)
  if not expectEqual(snapshot(spec.originNode).quantity, spec.initialOrigin, spec.label .. "_ORIGIN_INITIAL") then return false end
  if not expectEqual(snapshot(spec.destinationNode).quantity, spec.initialDestination, spec.label .. "_DESTINATION_INITIAL") then return false end

  local shortage, shortageCreated = state.store:ReserveResource({
    transactionId = spec.shortageId,
    reservationId = "ACCEPTANCE-SHORTAGE:" .. spec.shortageId,
    kind = state.campaignState.TransactionKind.CONSUMPTION,
    resourceId = RESOURCE_ID,
    quantity = spec.shortageQuantity,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = spec.destinationNode,
  })
  if shortageCreated ~= true then fail(spec.label .. "_SHORTAGE_TRANSACTION_NOT_CREATED"); return false end
  state.store:Consume(shortage.transactionId)
  state.store:CompleteConsumption(shortage.transactionId)

  local afterShortage = snapshot(spec.destinationNode)
  if not expectEqual(afterShortage.quantity, spec.destinationAfterShortage, spec.label .. "_DESTINATION_AFTER_SHORTAGE") then return false end

  local candidate = OMW_PERSONNEL_RESUPPLY_RESOURCE_DEMAND_POLICY.Evaluate(spec.stockRow, afterShortage)
  if not candidate then fail(spec.label .. "_RESOURCE_DEMAND_POLICY_NO_CANDIDATE"); return false end
  if not expectEqual(candidate.level, "REORDER", spec.label .. "_CANDIDATE_LEVEL") then return false end
  if not expectEqual(candidate.resourceClass, RESOURCE_CLASS, spec.label .. "_CANDIDATE_RESOURCE_CLASS") then return false end
  if not expectEqual(candidate.requestedQuantity, spec.transferQuantity, spec.label .. "_CANDIDATE_QUANTITY") then return false end
  if not expectEqual(candidate.supplyParent, spec.originNode, spec.label .. "_CANDIDATE_SUPPLY_PARENT") then return false end
  if not expectEqual(candidate.reorder, spec.reorder, spec.label .. "_CANDIDATE_REORDER") then return false end
  if not expectEqual(candidate.reorderComparison, "BELOW", spec.label .. "_CANDIDATE_REORDER_COMPARISON") then return false end

  local demand, demandCreated = state.registry:Create({
    id = spec.demandId,
    missionType = OMW_PERSONNEL_RESUPPLY_MISSION_DEMAND.Type.RESUPPLY,
    origin = spec.originNode,
    objective = spec.objective,
    target = { nodeId = spec.destinationNode, resourceId = RESOURCE_ID },
    priority = 20,
    playerCapable = false,
    aiCapable = true,
    reservationState = "UNRESERVED",
    successCriteria = { destinationQuantity = spec.finalDestination },
    failureConsequences = { resourceTransfer = "LOST_OR_CANCELLED_BY_CAMPAIGNSTATE" },
    createdReason = candidate.level,
    dedupeKey = candidate.dedupeKey,
  })
  if demandCreated ~= true then fail(spec.label .. "_MISSION_DEMAND_NOT_CREATED"); return false end

  local transfer, transferCreated = state.store:ReserveResource({
    transactionId = spec.transferId,
    reservationId = "MISSION-DEMAND:" .. spec.demandId,
    missionDemandId = spec.demandId,
    carrierEntityId = spec.carrierEntityId,
    kind = state.campaignState.TransactionKind.TRANSFER,
    resourceId = RESOURCE_ID,
    quantity = spec.transferQuantity,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = spec.originNode,
    destinationNodeId = spec.destinationNode,
  })
  if transferCreated ~= true then fail(spec.label .. "_TRANSFER_RESERVATION_NOT_CREATED"); return false end

  state.registry:SetReservationState(spec.demandId, "RESERVED", {
    transactionId = spec.transferId,
    originNodeId = spec.originNode,
    destinationNodeId = spec.destinationNode,
    resourceId = RESOURCE_ID,
    quantity = spec.transferQuantity,
    carrierEntityId = spec.carrierEntityId,
  })
  state.registry:AssignAI(spec.demandId, spec.assigneeId)

  spec.candidate = candidate
  log(spec.label .. "_DEMAND_RESERVED demandId=" .. demand.id
    .. " origin=" .. spec.originNode .. " destination=" .. spec.destinationNode
    .. " resource=" .. RESOURCE_ID .. " quantity=" .. tostring(spec.transferQuantity)
    .. " reorder=" .. tostring(spec.reorder) .. " comparison=BELOW")
  return true
end

local function verifyFinalState()
  if state.failed or state.passed then return end
  local ground = state.ground
  local air = state.air

  if ground.deliveryCommitted ~= true or ground.returnedCount ~= 1 or ground.addAssetCount ~= 1 then return end
  if air.deliveryCommitted ~= true or air.legionReturnedCount ~= 1 then return end

  if not expectEqual(ground.spawnCount, 1, "GROUND_SPAWN_COUNT") then return end
  if not expectEqual(ground.armyOnMissionCount, 1, "GROUND_ARMY_ON_MISSION_COUNT") then return end
  if not expectEqual(ground.missionExecuteCount, 1, "GROUND_MISSION_EXECUTE_COUNT") then return end
  if not expectEqual(ground.missionDoneCount, 1, "GROUND_MISSION_DONE_COUNT") then return end
  if ground.destinationObserved ~= true then fail("GROUND_DESTINATION_NOT_OBSERVED"); return end
  if ground.returnIssued ~= true then fail("GROUND_RETURN_NOT_ISSUED"); return end
  if ground.armyGroup and ground.armyGroup:IsAlive() then fail("GROUND_PHYSICAL_GROUP_NOT_REMOVED_AFTER_WAREHOUSE_ADD"); return end

  if not expectEqual(air.flightOnMissionCount, 1, "AIR_FLIGHT_ON_MISSION_COUNT") then return end
  if not expectEqual(air.takeoffCount, 1, "AIR_TAKEOFF_COUNT") then return end
  if not expectEqual(air.missionDoneCount, 1, "AIR_MISSION_DONE_COUNT") then return end
  if not air.flightGroup then fail("AIR_FLIGHTGROUP_MISSING"); return end

  if not expectEqual(snapshot(GROUND_ORIGIN_NODE).quantity, GROUND_FINAL_ORIGIN, "GROUND_ORIGIN_FINAL") then return end
  if not expectEqual(snapshot(GROUND_DESTINATION_NODE).quantity, GROUND_FINAL_DESTINATION, "GROUND_DESTINATION_FINAL") then return end
  if not expectEqual(snapshot(AIR_ORIGIN_NODE).quantity, AIR_FINAL_ORIGIN, "AIR_ORIGIN_FINAL") then return end
  if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_FINAL_DESTINATION, "AIR_DESTINATION_FINAL") then return end

  local groundFollowup = OMW_PERSONNEL_RESUPPLY_RESOURCE_DEMAND_POLICY.Evaluate(state.ground.stockRow, snapshot(GROUND_DESTINATION_NODE))
  local airFollowup = OMW_PERSONNEL_RESUPPLY_RESOURCE_DEMAND_POLICY.Evaluate(state.air.stockRow, snapshot(AIR_DESTINATION_NODE))
  if groundFollowup ~= nil then fail("GROUND_FOLLOWUP_DEMAND_UNEXPECTED"); return end
  if airFollowup ~= nil then fail("AIR_FOLLOWUP_DEMAND_UNEXPECTED"); return end

  if not expectEqual(state.registry:Get(GROUND_DEMAND_ID).status, OMW_PERSONNEL_RESUPPLY_MISSION_DEMAND.Status.SUCCESS, "GROUND_DEMAND_FINAL_STATUS") then return end
  if not expectEqual(state.registry:Get(AIR_DEMAND_ID).status, OMW_PERSONNEL_RESUPPLY_MISSION_DEMAND.Status.SUCCESS, "AIR_DEMAND_FINAL_STATUS") then return end

  state.passed = true
  log("PASS resource=" .. RESOURCE_ID
    .. " ground=JOYCE_TO_HONAKER groundFinal=" .. GROUND_FINAL_ORIGIN .. "/" .. GROUND_FINAL_DESTINATION
    .. " groundTemplate=" .. GROUND_TEMPLATE_NAME
    .. " air=JALALABAD_TO_FORTRESS airFinal=" .. AIR_FINAL_ORIGIN .. "/" .. AIR_FINAL_DESTINATION
    .. " airSquadron=" .. AIR_SQUADRON_NAME .. " airTemplate=" .. AIR_TEMPLATE_NAME
    .. " airMission=LANDATCOORDINATE airReturned=true personnelFloor=80_PERCENT_STRICT_BELOW")
end

local function issueGroundReturn()
  local ground = state.ground
  if state.failed or ground.returnIssued then return end
  if not ground.armyGroup or not ground.armyGroup:IsAlive() then fail("GROUND_RETURN_GROUP_NOT_ALIVE"); return end

  ground.returnIssued = true
  ground.armyGroup:RTZ(ground.originZone, ENUMS.Formation.Vehicle.OnRoad)
  if not ground.armyGroup:IsReturning() then
    fail("GROUND_RETURN_RTZ_NOT_ACCEPTED state=" .. tostring(ground.armyGroup:GetState()))
    return
  end
  log("GROUND_RETURN_RTZ_ISSUED group=" .. tostring(ground.armyGroup:GetName())
    .. " zone=" .. GROUND_ORIGIN_ACCESS_ZONE .. " formation=OnRoad")
end

local function checkGroundDestinationProgress()
  local ground = state.ground
  if state.failed or state.passed or ground.deliveryCommitted then return end
  if not ground.armyGroup or not ground.armyGroup:IsAlive() then return end

  if ground.armyGroup:IsInZone(ground.destinationZone) == true then
    if ground.destinationObserved ~= true then
      ground.destinationObserved = true
      log("GROUND_DESTINATION_ZONE_ENTERED group=" .. tostring(ground.armyGroup:GetName())
        .. " graceSec=" .. tostring(DESTINATION_EXECUTION_GRACE_SEC))
      SCHEDULER:New(nil, function()
        if state.failed or state.passed or ground.deliveryCommitted or ground.missionExecuteCount > 0 then return end
        fail("GROUND_DESTINATION_EXECUTION_TIMEOUT seconds=" .. tostring(DESTINATION_EXECUTION_GRACE_SEC))
      end, {}, DESTINATION_EXECUTION_GRACE_SEC)
    end
    return
  end
  SCHEDULER:New(nil, checkGroundDestinationProgress, {}, DESTINATION_CHECK_INTERVAL_SEC)
end

local function attachGroundCallbacks(armyGroup)
  local ground = state.ground
  if armyGroup.__omwPersonnelResupplyAcceptanceCallbacks then return end
  armyGroup.__omwPersonnelResupplyAcceptanceCallbacks = true

  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if state.failed or Mission ~= ground.mission then return end
    ground.missionExecuteCount = ground.missionExecuteCount + 1
    if not expectEqual(ground.missionExecuteCount, 1, "GROUND_MISSION_EXECUTE_COUNT") then return end
    if self:IsInZone(ground.destinationZone) ~= true then fail("GROUND_MISSION_EXECUTE_OUTSIDE_DESTINATION"); return end

    local transaction = state.store:MarkDelivered(GROUND_TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "GROUND_TRANSFER_DELIVERY_STATUS") then return end
    state.registry:SetReservationState(GROUND_DEMAND_ID, "DELIVERED")
    state.registry:Succeed(GROUND_DEMAND_ID, { transactionId = GROUND_TRANSFER_ID, carrierEntityId = GROUND_CARRIER_ENTITY_ID })
    ground.deliveryCommitted = true
    if not expectEqual(snapshot(GROUND_DESTINATION_NODE).quantity, GROUND_FINAL_DESTINATION, "GROUND_DESTINATION_DELIVERED") then return end

    log("GROUND_DELIVERY_CONFIRMED group=" .. tostring(self:GetName())
      .. " destination=" .. GROUND_DESTINATION_NODE .. " quantity=" .. tostring(GROUND_TRANSFER_QUANTITY))
    ground.mission:__Cancel(1)
  end

  function armyGroup:OnAfterMissionDone(From, Event, To, Mission)
    if state.failed or Mission ~= ground.mission then return end
    ground.missionDoneCount = ground.missionDoneCount + 1
    if not expectEqual(ground.missionDoneCount, 1, "GROUND_MISSION_DONE_COUNT") then return end
    if ground.deliveryCommitted ~= true then fail("GROUND_MISSION_DONE_BEFORE_DELIVERY"); return end
    log("GROUND_MISSION_DONE returnIssueDelaySec=" .. tostring(RETURN_ISSUE_DELAY_SEC))
    SCHEDULER:New(nil, issueGroundReturn, {}, RETURN_ISSUE_DELAY_SEC)
  end

  function armyGroup:OnAfterRTZ(From, Event, To, Zone, Formation)
    if state.failed then return end
    if Zone ~= ground.originZone then fail("GROUND_RETURN_RTZ_UNEXPECTED_ZONE"); return end
    if Formation ~= ENUMS.Formation.Vehicle.OnRoad then fail("GROUND_RETURN_RTZ_UNEXPECTED_FORMATION"); return end
    log("GROUND_RETURN_RTZ_ACTIVE group=" .. tostring(self:GetName()))
  end

  function armyGroup:OnAfterReturned(From, Event, To)
    if state.failed or self ~= ground.armyGroup then return end
    ground.returnedCount = ground.returnedCount + 1
    if not expectEqual(ground.returnedCount, 1, "GROUND_RETURNED_COUNT") then return end
    log("GROUND_RETURNED_HANDOFF group=" .. tostring(self:GetName()))
    SCHEDULER:New(nil, verifyFinalState, {}, GROUND_RETURN_SETTLEMENT_DELAY_SEC)
  end
end

local function prepareGroundExecution()
  local ground = state.ground
  ground.originZone = requireValue(ZONE:FindByName(GROUND_ORIGIN_ACCESS_ZONE), GROUND_ORIGIN_ACCESS_ZONE)
  ground.destinationZone = requireValue(ZONE:FindByName(GROUND_DESTINATION_ACCESS_ZONE), GROUND_DESTINATION_ACCESS_ZONE)
  requireValue(GROUP:FindByName(GROUND_TEMPLATE_NAME), GROUND_TEMPLATE_NAME)
  requireValue(UNIT:FindByName(GROUND_WAREHOUSE_NAME) or STATIC:FindByName(GROUND_WAREHOUSE_NAME, false), GROUND_WAREHOUSE_NAME)
  if state.failed then return false end

  ground.brigade = requireValue(BRIGADE:New(GROUND_WAREHOUSE_NAME, GROUND_BRIGADE_NAME), GROUND_BRIGADE_NAME)
  ground.brigade:SetSpawnZone(ground.originZone, 1000)
  ground.platoon = requireValue(PLATOON:New(GROUND_TEMPLATE_NAME, 1, GROUND_PLATOON_NAME), GROUND_PLATOON_NAME)
  ground.platoon:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
  ground.brigade:AddPlatoon(ground.platoon)

  OMW_PERSONNEL_RESUPPLY_ROAD_SPAWN_ADAPTER.Install(ground.brigade, {
    resolveRoadSpawn = function(self, asset, request)
      if not asset or asset.templatename ~= GROUND_TEMPLATE_NAME then return nil end
      return {
        entityId = GROUND_CARRIER_ENTITY_ID,
        accessZone = ground.originZone,
        forwardCoordinate = ground.destinationZone:GetCoordinate(),
      }
    end,
    log = function(message) log("GROUND_" .. message) end,
  })

  ground.brigade.OnAfterAssetSpawned = function(self, From, Event, To, Group, Asset, Request)
    if state.failed then return end
    ground.spawnCount = ground.spawnCount + 1
    if not expectEqual(ground.spawnCount, 1, "GROUND_SPAWN_COUNT") then return end
    state.store:MarkLoading(GROUND_TRANSFER_ID)
    state.registry:SetReservationState(GROUND_DEMAND_ID, "LOADING")
    log("GROUND_GROUP_MATERIALIZED name=" .. tostring(Group and Group:GetName() or "UNKNOWN"))
  end

  ground.brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
    if state.failed or Mission ~= ground.mission then return end
    ground.armyOnMissionCount = ground.armyOnMissionCount + 1
    if not expectEqual(ground.armyOnMissionCount, 1, "GROUND_ARMY_ON_MISSION_COUNT") then return end
    ground.armyGroup = requireValue(ArmyGroup, "GROUND_ARMYGROUP")
    if state.failed then return end
    attachGroundCallbacks(ArmyGroup)
    state.store:MarkInTransit(GROUND_TRANSFER_ID)
    state.registry:SetReservationState(GROUND_DEMAND_ID, "IN_TRANSIT")
    state.registry:Activate(GROUND_DEMAND_ID)
    if not expectEqual(snapshot(GROUND_ORIGIN_NODE).quantity, GROUND_FINAL_ORIGIN, "GROUND_ORIGIN_IN_TRANSIT") then return end
    log("GROUND_ARMY_ON_MISSION group=" .. tostring(ArmyGroup:GetName()) .. " transferStatus=IN_TRANSIT")
    SCHEDULER:New(nil, checkGroundDestinationProgress, {}, DESTINATION_CHECK_INTERVAL_SEC)
  end

  ground.brigade.OnAfterAddAsset = function(self, From, Event, To, Group, Groups)
    if state.failed then return end
    ground.addAssetCount = ground.addAssetCount + 1
    if not expectEqual(ground.addAssetCount, 1, "GROUND_WAREHOUSE_ADD_ASSET_COUNT") then return end
    log("GROUND_WAREHOUSE_ADD_ASSET group=" .. tostring(Group and Group:GetName() or "UNKNOWN"))
  end

  ground.brigade.OnAfterStart = function(self, From, Event, To)
    if state.failed then return end
    SCHEDULER:New(nil, function()
      if state.failed then return end
      if not expectEqual(ground.platoon:CountAssets(true, AUFTRAG.Type.NOTHING), 1, "GROUND_PLATOON_ASSET_COUNT") then return end
      ground.mission = AUFTRAG:NewNOTHING(ground.destinationZone)
      ground.mission:SetName("OMW_GROUND_PERSONNEL_RESUPPLY_JOYCE_TO_HONAKER")
      ground.mission:SetMissionSpeed(ROAD_SPEED_KNOTS)
      ground.mission:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
      ground.mission:SetReturnToLegion(false)
      ground.mission:SetPriority(20, true)
      ground.brigade:AddMission(ground.mission)
      log("GROUND_MISSION_QUEUED type=NOTHING origin=" .. GROUND_ORIGIN_NODE
        .. " destination=" .. GROUND_DESTINATION_NODE .. " resource=" .. RESOURCE_ID)
    end, {}, 5)
  end

  return true
end

local function attachAirFlightCallbacks(flightGroup)
  local air = state.air
  if flightGroup.__omwPersonnelResupplyAcceptanceCallbacks then return end
  flightGroup.__omwPersonnelResupplyAcceptanceCallbacks = true

  local previousTakeoff = flightGroup.OnAfterTakeoff
  flightGroup.OnAfterTakeoff = function(self, From, Event, To, ...)
    if previousTakeoff then previousTakeoff(self, From, Event, To, ...) end
    if state.failed or self ~= air.flightGroup or air.takeoffCount > 0 then return end
    air.takeoffCount = air.takeoffCount + 1
    local transaction = state.store:MarkInTransit(AIR_TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.IN_TRANSIT, "AIR_TRANSFER_IN_TRANSIT_STATUS") then return end
    state.registry:SetReservationState(AIR_DEMAND_ID, "IN_TRANSIT")
    state.registry:Activate(AIR_DEMAND_ID)
    if not expectEqual(snapshot(AIR_ORIGIN_NODE).quantity, AIR_FINAL_ORIGIN, "AIR_ORIGIN_IN_TRANSIT") then return end
    log("AIR_TAKEOFF group=" .. tostring(self:GetName()) .. " transferStatus=IN_TRANSIT demandStatus=ACTIVE")
  end

  local previousMissionDone = flightGroup.OnAfterMissionDone
  flightGroup.OnAfterMissionDone = function(self, From, Event, To, Mission)
    if previousMissionDone then previousMissionDone(self, From, Event, To, Mission) end
    if state.failed or Mission ~= air.mission then return end
    air.missionDoneCount = air.missionDoneCount + 1
    if not expectEqual(air.missionDoneCount, 1, "AIR_MISSION_DONE_COUNT") then return end
    if air.takeoffCount ~= 1 then fail("AIR_MISSION_DONE_BEFORE_TAKEOFF"); return end
    if self:IsAirborne() then fail("AIR_MISSION_DONE_WHILE_AIRBORNE"); return end

    local distance = self:Get2DDistance(air.targetCoordinate)
    if type(distance) ~= "number" or distance > AIR_LANDING_ACCEPTANCE_RADIUS_M then
      fail("AIR_LANDING_OUTSIDE_FORTRESS_FARP distanceM=" .. tostring(distance))
      return
    end

    local transaction = state.store:MarkDelivered(AIR_TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "AIR_TRANSFER_DELIVERY_STATUS") then return end
    state.registry:SetReservationState(AIR_DEMAND_ID, "DELIVERED")
    state.registry:Succeed(AIR_DEMAND_ID, { transactionId = AIR_TRANSFER_ID, carrierEntityId = AIR_CARRIER_ENTITY_ID })
    air.deliveryCommitted = true
    if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_FINAL_DESTINATION, "AIR_DESTINATION_DELIVERED") then return end

    log("AIR_DELIVERY_CONFIRMED group=" .. tostring(self:GetName())
      .. " farp=" .. AIR_FARP_NAME .. " distanceM=" .. string.format("%.1f", distance)
      .. " airborne=false quantity=" .. tostring(AIR_TRANSFER_QUANTITY)
      .. " campaignStateStatus=DELIVERED demandStatus=SUCCESS")
    verifyFinalState()
  end
end

local function prepareAirExecution()
  local air = state.air
  if type(OMW) ~= "table" or type(OMW.AirOps) ~= "table"
      or type(OMW.AirOps.Jalalabad) ~= "table"
      or OMW.AirOps.Jalalabad.Status ~= "RUNNING" then
    fail("JALALABAD_AIRWING_NOT_RUNNING")
    return false
  end

  air.airwing = requireValue(OMW.AirOps.Jalalabad.Airwing, "JALALABAD_AIRWING")
  air.squadron = requireValue(OMW.AirOps.Jalalabad.Squadrons and OMW.AirOps.Jalalabad.Squadrons[AIR_SQUADRON_KEY], AIR_SQUADRON_NAME)
  local farp = requireValue(STATIC:FindByName(AIR_FARP_NAME, false), AIR_FARP_NAME)
  requireValue(GROUP:FindByName(AIR_TEMPLATE_NAME), AIR_TEMPLATE_NAME)
  if state.failed then return false end
  air.targetCoordinate = requireValue(farp:GetCoordinate(), AIR_FARP_NAME .. "_COORDINATE")
  if state.failed then return false end

  local previousFlightOnMission = air.airwing.OnAfterFlightOnMission
  air.airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if state.failed or Mission ~= air.mission then return end
    air.flightOnMissionCount = air.flightOnMissionCount + 1
    if not expectEqual(air.flightOnMissionCount, 1, "AIR_FLIGHT_ON_MISSION_COUNT") then return end
    air.flightGroup = requireValue(FlightGroup, "AIR_FLIGHTGROUP")
    if state.failed then return end
    air.asset = Mission:GetAssetByName(FlightGroup:GetName())
    if not air.asset then fail("AIR_MISSION_ASSET_NOT_FOUND"); return end
    attachAirFlightCallbacks(FlightGroup)
    local transaction = state.store:MarkLoading(AIR_TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.LOADING, "AIR_TRANSFER_LOADING_STATUS") then return end
    state.registry:SetReservationState(AIR_DEMAND_ID, "LOADING")
    log("AIR_FLIGHT_ON_MISSION group=" .. tostring(FlightGroup:GetName())
      .. " squadron=" .. AIR_SQUADRON_NAME .. " transferStatus=LOADING")
  end

  local previousAssetReturned = air.airwing.OnAfterLegionAssetReturned
  air.airwing.OnAfterLegionAssetReturned = function(self, From, Event, To, Cohort, Asset)
    if previousAssetReturned then previousAssetReturned(self, From, Event, To, Cohort, Asset) end
    if state.failed or not air.asset or Asset ~= air.asset then return end
    if Cohort ~= air.squadron then fail("AIR_RETURNED_UNEXPECTED_SQUADRON"); return end
    air.legionReturnedCount = air.legionReturnedCount + 1
    if not expectEqual(air.legionReturnedCount, 1, "AIR_LEGION_RETURNED_COUNT") then return end
    if air.deliveryCommitted ~= true then fail("AIR_RETURNED_BEFORE_DELIVERY"); return end
    log("AIR_LEGION_ASSET_RETURNED squadron=" .. AIR_SQUADRON_NAME
      .. " asset=" .. tostring(Asset.spawngroupname))
    verifyFinalState()
  end

  air.mission = AUFTRAG:NewLANDATCOORDINATE(
    air.targetCoordinate,
    nil,
    nil,
    AIR_LANDING_DWELL_SEC
  )
  air.mission:SetName("OMW_AIR_PERSONNEL_RESUPPLY_JALALABAD_TO_FORTRESS")
  air.mission:SetRequiredAssets(1, 1)
  air.mission:AssignSquadrons({ air.squadron })
  air.mission:SetPriority(20, true)
  air.airwing:AddMission(air.mission)

  log("AIR_MISSION_QUEUED type=LANDATCOORDINATE origin=" .. AIR_ORIGIN_NODE
    .. " destination=" .. AIR_DESTINATION_NODE .. " farp=" .. AIR_FARP_NAME
    .. " squadron=" .. AIR_SQUADRON_NAME .. " requiredAssets=1"
    .. " dwellSec=" .. tostring(AIR_LANDING_DWELL_SEC)
    .. " landingAcceptanceRadiusM=" .. tostring(AIR_LANDING_ACCEPTANCE_RADIUS_M)
    .. " travelTimeout=none")
  return true
end

log("START testId=" .. TEST_ID .. " resource=" .. RESOURCE_ID
  .. " personnelFloor=80_PERCENT_STRICT_BELOW")

if type(USERFLAG) ~= "table" or type(USERFLAG.New) ~= "function" then fail("MOOSE_USERFLAG_UNAVAILABLE"); return end
if USERFLAG:New("OMW_WAREHOUSE_READY"):Get() ~= 1 then fail("OMW_WAREHOUSE_READY_NOT_1"); return end
if USERFLAG:New("OMW_GROUND_READY"):Get() ~= 1 then fail("OMW_GROUND_READY_NOT_1"); return end
if type(OMW) ~= "table" or type(OMW.Ground) ~= "table" or type(OMW.Ground.Base) ~= "table" then fail("OMW_GROUND_BASE_UNAVAILABLE"); return end

local groundContext = OMW.Ground.Base.GetContext()
if type(groundContext) ~= "table" then fail("GROUND_CONTEXT_UNAVAILABLE"); return end
state.store = requireValue(groundContext.store, "groundContext.store")
state.campaignState = requireValue(groundContext.campaignState, "groundContext.campaignState")
if state.failed then return end

local initialStock = OMW.Ground.Base.GetInitialStock()
state.ground.stockRow = findStockRow(initialStock, GROUND_DESTINATION_NODE)
state.air.stockRow = findStockRow(initialStock, AIR_DESTINATION_NODE)
if not state.ground.stockRow then fail("HONAKER_PERSONNEL_STOCK_ROW_NOT_FOUND"); return end
if not state.air.stockRow then fail("FORTRESS_PERSONNEL_STOCK_ROW_NOT_FOUND"); return end
if not expectEqual(state.ground.stockRow.resourceClass, RESOURCE_CLASS, "GROUND_STOCK_RESOURCE_CLASS") then return end
if not expectEqual(state.air.stockRow.resourceClass, RESOURCE_CLASS, "AIR_STOCK_RESOURCE_CLASS") then return end
if not expectEqual(state.ground.stockRow.reorderComparison, "BELOW", "GROUND_STOCK_REORDER_COMPARISON") then return end
if not expectEqual(state.air.stockRow.reorderComparison, "BELOW", "AIR_STOCK_REORDER_COMPARISON") then return end

state.registry = OMW_PERSONNEL_RESUPPLY_MISSION_DEMAND.New()

local groundSpec = {
  label = "GROUND",
  originNode = GROUND_ORIGIN_NODE,
  destinationNode = GROUND_DESTINATION_NODE,
  stockRow = state.ground.stockRow,
  initialOrigin = GROUND_INITIAL_ORIGIN,
  initialDestination = GROUND_INITIAL_DESTINATION,
  shortageQuantity = GROUND_SHORTAGE_QUANTITY,
  destinationAfterShortage = GROUND_DESTINATION_AFTER_SHORTAGE,
  transferQuantity = GROUND_TRANSFER_QUANTITY,
  finalDestination = GROUND_FINAL_DESTINATION,
  reorder = GROUND_REORDER,
  shortageId = GROUND_SHORTAGE_TX_ID,
  demandId = GROUND_DEMAND_ID,
  transferId = GROUND_TRANSFER_ID,
  carrierEntityId = GROUND_CARRIER_ENTITY_ID,
  assigneeId = GROUND_ASSIGNEE_ID,
  objective = "Restore Honaker PERSONNEL to target by Ground convoy",
}
local airSpec = {
  label = "AIR",
  originNode = AIR_ORIGIN_NODE,
  destinationNode = AIR_DESTINATION_NODE,
  stockRow = state.air.stockRow,
  initialOrigin = AIR_INITIAL_ORIGIN,
  initialDestination = AIR_INITIAL_DESTINATION,
  shortageQuantity = AIR_SHORTAGE_QUANTITY,
  destinationAfterShortage = AIR_DESTINATION_AFTER_SHORTAGE,
  transferQuantity = AIR_TRANSFER_QUANTITY,
  finalDestination = AIR_FINAL_DESTINATION,
  reorder = AIR_REORDER,
  shortageId = AIR_SHORTAGE_TX_ID,
  demandId = AIR_DEMAND_ID,
  transferId = AIR_TRANSFER_ID,
  carrierEntityId = AIR_CARRIER_ENTITY_ID,
  assigneeId = AIR_ASSIGNEE_ID,
  objective = "Restore Fortress PERSONNEL to target by externally tasked Jalalabad helicopter",
}

if not createDemandAndReservation(groundSpec) then return end
if not createDemandAndReservation(airSpec) then return end
if not prepareGroundExecution() then return end
if not prepareAirExecution() then return end

log("PHYSICAL_EXECUTION_READY groundMission=NOTHING groundTemplate=" .. GROUND_TEMPLATE_NAME
  .. " airMission=LANDATCOORDINATE airTemplate=" .. AIR_TEMPLATE_NAME
  .. " strategicAuthority=CAMPAIGNSTATE physicalInfantryCargo=false TROOPTRANSPORT=false")
state.ground.brigade:Start()