-- Operation Mountain Watch - Stage 1D-P Air PERSONNEL FlightPath/return acceptance.
-- Test-ID: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-1
--
-- Scope:
--   Jalalabad -> Fortress PERSONNEL meta-resource resupply using the existing
--   Jalalabad CH-47 AIRWING/SQUADRON asset, the Mission Editor PATHLINE
--   OMW_FlightPath with a 500 m right-hand directional offset, a normal
--   trigger-zone LZ at Fortress, and physical return to Jalalabad before PASS.
--
-- CampaignState remains sole strategic PERSONNEL authority. No physical
-- infantry cargo group is created and TROOPTRANSPORT is intentionally not used.

local TEST_ID = "AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local RESOURCE_ID = "GROUND_PERSONNEL"
local RESOURCE_CLASS = "GROUND_PERSONNEL"
local RESOURCE_UNIT = "count"

local AIR_ORIGIN_NODE = "GROUND_NODE_JALALABAD"
local AIR_DESTINATION_NODE = "GROUND_NODE_FORTRESS"
local AIR_LZ_ZONE_NAME = "OMW_BLUE_LZ_FORTRESS_01"
local AIR_PATHLINE_NAME = "OMW_FlightPath"
local AIR_SQUADRON_KEY = "CH47"
local AIR_SQUADRON_NAME = "SQ_US_JBAD_CH47_HEAVYLIFT"
local AIR_TEMPLATE_NAME = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
local AIR_DEMAND_ID = "RESUPPLY-ACCEPTANCE-FORTRESS-PERSONNEL-AIR-FLIGHTPATH-001"
local AIR_TRANSFER_ID = "TRANSFER-ACCEPTANCE-JALALABAD-FORTRESS-PERSONNEL-AIR-FLIGHTPATH-001"
local AIR_SHORTAGE_TX_ID = "CONSUMPTION-ACCEPTANCE-FORTRESS-PERSONNEL-AIR-FLIGHTPATH-001"
local AIR_CARRIER_ENTITY_ID = "AIR-RESUPPLY-JALALABAD-FORTRESS-PERSONNEL-CH47-FLIGHTPATH-001"
local AIR_ASSIGNEE_ID = "AI:SQUADRON:" .. AIR_SQUADRON_NAME

local AIR_INITIAL_ORIGIN = 480
local AIR_INITIAL_DESTINATION = 160
local AIR_SHORTAGE_QUANTITY = 33
local AIR_DESTINATION_AFTER_SHORTAGE = 127
local AIR_TRANSFER_QUANTITY = 33
local AIR_FINAL_ORIGIN = 447
local AIR_FINAL_DESTINATION = 160
local AIR_REORDER = 128

local AIR_PATH_OFFSET_RIGHT_M = 500
local AIR_CORRIDOR_ALTITUDE_FT_AGL = 500
local AIR_LANDING_DWELL_SEC = 30
local AIR_LANDING_ACCEPTANCE_RADIUS_M = 100
local AIR_ROUTE_INSTALL_DELAY_SEC = 5
local AIR_ROUTE_INSTALL_RETRY_SEC = 2
local AIR_ROUTE_INSTALL_MAX_ATTEMPTS = 5

local state = {
  failed = false,
  passed = false,
  registry = nil,
  store = nil,
  campaignState = nil,
  air = {
    flightOnMissionCount = 0,
    initialTakeoffCount = 0,
    landedAtCount = 0,
    missionDoneCount = 0,
    homeLandedCount = 0,
    legionReturnedCount = 0,
    deliveryCommitted = false,
    routeInstalled = false,
    pathlinePointCount = 0,
    outboundWaypointCount = 0,
    returnWaypointCount = 0,
    routeInstallAttempts = 0,
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

local function reverseCoordinates(coordinates)
  local result = {}
  for index = #coordinates, 1, -1 do
    result[#result + 1] = coordinates[index]
  end
  return result
end

local function nearestCoordinateIndex(coordinates, referenceCoordinate)
  local bestIndex = nil
  local bestDistance = nil
  for index, coordinate in ipairs(coordinates) do
    local distance = coordinate:Get2DDistance(referenceCoordinate)
    if bestDistance == nil or distance < bestDistance then
      bestIndex = index
      bestDistance = distance
    end
  end
  return bestIndex, bestDistance
end

local function directionalRightOffsetCoordinates(coordinates, offsetMeters)
  local result = {}
  if #coordinates < 2 then return result end

  for index, coordinate in ipairs(coordinates) do
    local fromCoordinate = nil
    local toCoordinate = nil
    if index < #coordinates then
      fromCoordinate = coordinate
      toCoordinate = coordinates[index + 1]
    else
      fromCoordinate = coordinates[index - 1]
      toCoordinate = coordinate
    end

    local heading = fromCoordinate:HeadingTo(toCoordinate)
    result[#result + 1] = coordinate:Translate(offsetMeters, heading - 90, false, false)
  end

  return result
end

local function buildCorridor(pathline, originCoordinate, destinationCoordinate)
  local rawCoordinates = pathline:GetCoordinates()
  state.air.pathlinePointCount = #rawCoordinates
  if #rawCoordinates < 2 then
    fail("AIR_PATHLINE_TOO_SHORT points=" .. tostring(#rawCoordinates))
    return nil, nil
  end

  local firstDistance = rawCoordinates[1]:Get2DDistance(originCoordinate)
  local lastDistance = rawCoordinates[#rawCoordinates]:Get2DDistance(originCoordinate)
  local oriented = rawCoordinates
  if lastDistance < firstDistance then
    oriented = reverseCoordinates(rawCoordinates)
  end

  local originIndex, originDistance = nearestCoordinateIndex(oriented, originCoordinate)
  local destinationIndex, destinationDistance = nearestCoordinateIndex(oriented, destinationCoordinate)
  if not originIndex or not destinationIndex then
    fail("AIR_PATHLINE_NEAREST_POINT_UNAVAILABLE")
    return nil, nil
  end
  if destinationIndex <= originIndex then
    fail("AIR_PATHLINE_DIRECTION_INVALID originIndex=" .. tostring(originIndex)
      .. " destinationIndex=" .. tostring(destinationIndex))
    return nil, nil
  end

  local centerline = {}
  for index = originIndex, destinationIndex do
    centerline[#centerline + 1] = oriented[index]
  end
  if #centerline < 2 then
    fail("AIR_PATHLINE_CORRIDOR_TOO_SHORT")
    return nil, nil
  end

  local outbound = directionalRightOffsetCoordinates(centerline, AIR_PATH_OFFSET_RIGHT_M)
  local returnCenterline = reverseCoordinates(centerline)
  local returnRoute = directionalRightOffsetCoordinates(returnCenterline, AIR_PATH_OFFSET_RIGHT_M)

  log("AIR_PATHLINE_RESOLVED name=" .. AIR_PATHLINE_NAME
    .. " points=" .. tostring(#rawCoordinates)
    .. " corridorPoints=" .. tostring(#centerline)
    .. " originDistanceM=" .. string.format("%.1f", originDistance or -1)
    .. " destinationDistanceM=" .. string.format("%.1f", destinationDistance or -1)
    .. " offsetRightM=" .. tostring(AIR_PATH_OFFSET_RIGHT_M))

  return outbound, returnRoute
end

local function createDemandAndReservation(stockRow)
  if not expectEqual(snapshot(AIR_ORIGIN_NODE).quantity, AIR_INITIAL_ORIGIN, "AIR_ORIGIN_INITIAL") then return false end
  if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_INITIAL_DESTINATION, "AIR_DESTINATION_INITIAL") then return false end

  local shortage, shortageCreated = state.store:ReserveResource({
    transactionId = AIR_SHORTAGE_TX_ID,
    reservationId = "ACCEPTANCE-SHORTAGE:" .. AIR_SHORTAGE_TX_ID,
    kind = state.campaignState.TransactionKind.CONSUMPTION,
    resourceId = RESOURCE_ID,
    quantity = AIR_SHORTAGE_QUANTITY,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = AIR_DESTINATION_NODE,
  })
  if shortageCreated ~= true then fail("AIR_SHORTAGE_TRANSACTION_NOT_CREATED"); return false end
  state.store:Consume(shortage.transactionId)
  state.store:CompleteConsumption(shortage.transactionId)

  local afterShortage = snapshot(AIR_DESTINATION_NODE)
  if not expectEqual(afterShortage.quantity, AIR_DESTINATION_AFTER_SHORTAGE, "AIR_DESTINATION_AFTER_SHORTAGE") then return false end

  local candidate = OMW_PERSONNEL_FLIGHTPATH_RESOURCE_DEMAND_POLICY.Evaluate(stockRow, afterShortage)
  if not candidate then fail("AIR_RESOURCE_DEMAND_POLICY_NO_CANDIDATE"); return false end
  if not expectEqual(candidate.level, "REORDER", "AIR_CANDIDATE_LEVEL") then return false end
  if not expectEqual(candidate.resourceClass, RESOURCE_CLASS, "AIR_CANDIDATE_RESOURCE_CLASS") then return false end
  if not expectEqual(candidate.requestedQuantity, AIR_TRANSFER_QUANTITY, "AIR_CANDIDATE_QUANTITY") then return false end
  if not expectEqual(candidate.supplyParent, AIR_ORIGIN_NODE, "AIR_CANDIDATE_SUPPLY_PARENT") then return false end
  if not expectEqual(candidate.reorder, AIR_REORDER, "AIR_CANDIDATE_REORDER") then return false end
  if not expectEqual(candidate.reorderComparison, "BELOW", "AIR_CANDIDATE_REORDER_COMPARISON") then return false end

  local demand, demandCreated = state.registry:Create({
    id = AIR_DEMAND_ID,
    missionType = OMW_PERSONNEL_FLIGHTPATH_MISSION_DEMAND.Type.RESUPPLY,
    origin = AIR_ORIGIN_NODE,
    objective = "Restore Fortress PERSONNEL to target by Jalalabad CH-47 using OMW_FlightPath",
    target = { nodeId = AIR_DESTINATION_NODE, resourceId = RESOURCE_ID },
    priority = 20,
    playerCapable = false,
    aiCapable = true,
    reservationState = "UNRESERVED",
    successCriteria = { destinationQuantity = AIR_FINAL_DESTINATION },
    failureConsequences = { resourceTransfer = "LOST_OR_CANCELLED_BY_CAMPAIGNSTATE" },
    createdReason = candidate.level,
    dedupeKey = candidate.dedupeKey,
  })
  if demandCreated ~= true then fail("AIR_MISSION_DEMAND_NOT_CREATED"); return false end

  local transfer, transferCreated = state.store:ReserveResource({
    transactionId = AIR_TRANSFER_ID,
    reservationId = "MISSION-DEMAND:" .. AIR_DEMAND_ID,
    missionDemandId = AIR_DEMAND_ID,
    carrierEntityId = AIR_CARRIER_ENTITY_ID,
    kind = state.campaignState.TransactionKind.TRANSFER,
    resourceId = RESOURCE_ID,
    quantity = AIR_TRANSFER_QUANTITY,
    canonicalUnit = RESOURCE_UNIT,
    originNodeId = AIR_ORIGIN_NODE,
    destinationNodeId = AIR_DESTINATION_NODE,
  })
  if transferCreated ~= true then fail("AIR_TRANSFER_RESERVATION_NOT_CREATED"); return false end

  state.registry:SetReservationState(AIR_DEMAND_ID, "RESERVED", {
    transactionId = AIR_TRANSFER_ID,
    originNodeId = AIR_ORIGIN_NODE,
    destinationNodeId = AIR_DESTINATION_NODE,
    resourceId = RESOURCE_ID,
    quantity = AIR_TRANSFER_QUANTITY,
    carrierEntityId = AIR_CARRIER_ENTITY_ID,
  })
  state.registry:AssignAI(AIR_DEMAND_ID, AIR_ASSIGNEE_ID)

  log("AIR_DEMAND_RESERVED demandId=" .. demand.id
    .. " origin=" .. AIR_ORIGIN_NODE .. " destination=" .. AIR_DESTINATION_NODE
    .. " resource=" .. RESOURCE_ID .. " quantity=" .. tostring(AIR_TRANSFER_QUANTITY)
    .. " reorder=" .. tostring(AIR_REORDER) .. " comparison=BELOW")
  return true
end

local function verifyFinalState()
  if state.failed or state.passed then return end
  local air = state.air

  if air.deliveryCommitted ~= true then return end
  if air.routeInstalled ~= true then return end
  if air.missionDoneCount ~= 1 then return end
  if air.homeLandedCount ~= 1 then return end
  if air.legionReturnedCount ~= 1 then return end

  if not expectEqual(air.flightOnMissionCount, 1, "AIR_FLIGHT_ON_MISSION_COUNT") then return end
  if not expectEqual(air.initialTakeoffCount, 1, "AIR_INITIAL_TAKEOFF_COUNT") then return end
  if not expectEqual(air.landedAtCount, 1, "AIR_LANDED_AT_COUNT") then return end
  if air.outboundWaypointCount < 2 then fail("AIR_OUTBOUND_WAYPOINT_COUNT_TOO_LOW"); return end
  if air.returnWaypointCount < 1 then fail("AIR_RETURN_WAYPOINT_COUNT_TOO_LOW"); return end

  if not expectEqual(snapshot(AIR_ORIGIN_NODE).quantity, AIR_FINAL_ORIGIN, "AIR_ORIGIN_FINAL") then return end
  if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_FINAL_DESTINATION, "AIR_DESTINATION_FINAL") then return end

  local followup = OMW_PERSONNEL_FLIGHTPATH_RESOURCE_DEMAND_POLICY.Evaluate(state.air.stockRow, snapshot(AIR_DESTINATION_NODE))
  if followup ~= nil then fail("AIR_FOLLOWUP_DEMAND_UNEXPECTED"); return end
  if not expectEqual(state.registry:Get(AIR_DEMAND_ID).status, OMW_PERSONNEL_FLIGHTPATH_MISSION_DEMAND.Status.SUCCESS, "AIR_DEMAND_FINAL_STATUS") then return end

  state.passed = true
  log("PASS resource=" .. RESOURCE_ID
    .. " air=JALALABAD_TO_FORTRESS"
    .. " final=" .. AIR_FINAL_ORIGIN .. "/" .. AIR_FINAL_DESTINATION
    .. " pathline=" .. AIR_PATHLINE_NAME
    .. " rightOffsetM=" .. tostring(AIR_PATH_OFFSET_RIGHT_M)
    .. " outboundWaypoints=" .. tostring(air.outboundWaypointCount)
    .. " returnWaypoints=" .. tostring(air.returnWaypointCount)
    .. " landingZone=" .. AIR_LZ_ZONE_NAME
    .. " physicalReturn=JALALABAD"
    .. " personnelFloor=80_PERCENT_STRICT_BELOW")
end

local function installMissionCorridor(flightGroup, mission)
  if state.failed or state.air.routeInstalled then return end

  state.air.routeInstallAttempts = state.air.routeInstallAttempts + 1
  local missionUid = mission:GetGroupWaypointIndex(flightGroup)
  local egressUid = mission:GetGroupEgressWaypointUID(flightGroup)
  if type(missionUid) ~= "number" or type(egressUid) ~= "number" then
    if state.air.routeInstallAttempts < AIR_ROUTE_INSTALL_MAX_ATTEMPTS then
      log("AIR_CORRIDOR_ROUTE_WAIT attempt=" .. tostring(state.air.routeInstallAttempts)
        .. " missionUid=" .. tostring(missionUid) .. " egressUid=" .. tostring(egressUid))
      SCHEDULER:New(nil, function()
        installMissionCorridor(flightGroup, mission)
      end, {}, AIR_ROUTE_INSTALL_RETRY_SEC)
      return
    end
    fail("AIR_MISSION_ROUTE_UIDS_UNAVAILABLE missionUid=" .. tostring(missionUid)
      .. " egressUid=" .. tostring(egressUid))
    return
  end

  local missionIndex = flightGroup:GetWaypointIndex(missionUid)
  if type(missionIndex) ~= "number" or missionIndex <= 1 then
    fail("AIR_MISSION_WAYPOINT_INDEX_INVALID index=" .. tostring(missionIndex))
    return
  end

  local previousUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 1)
  if type(previousUid) ~= "number" then
    fail("AIR_PREMISSION_WAYPOINT_UID_UNAVAILABLE")
    return
  end

  local outbound = state.air.outboundRoute
  local returnRoute = state.air.returnRoute
  for _, coordinate in ipairs(outbound) do
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, previousUid, AIR_CORRIDOR_ALTITUDE_FT_AGL, false)
    previousUid = waypoint.uid
    state.air.outboundWaypointCount = state.air.outboundWaypointCount + 1
  end

  local insertAfterUid = missionUid
  -- The final return-route coordinate is already the AUFTRAG egress waypoint.
  for index = 1, math.max(#returnRoute - 1, 0) do
    local coordinate = returnRoute[index]
    local updateRoute = index == (#returnRoute - 1)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, insertAfterUid, AIR_CORRIDOR_ALTITUDE_FT_AGL, updateRoute)
    insertAfterUid = waypoint.uid
    state.air.returnWaypointCount = state.air.returnWaypointCount + 1
  end

  state.air.routeInstalled = true
  log("AIR_CORRIDOR_ROUTE_INSTALLED group=" .. tostring(flightGroup:GetName())
    .. " pathline=" .. AIR_PATHLINE_NAME
    .. " offsetRightM=" .. tostring(AIR_PATH_OFFSET_RIGHT_M)
    .. " altitudeFtAGL=" .. tostring(AIR_CORRIDOR_ALTITUDE_FT_AGL)
    .. " outboundWaypoints=" .. tostring(state.air.outboundWaypointCount)
    .. " returnWaypoints=" .. tostring(state.air.returnWaypointCount))
end

local function attachAirFlightCallbacks(flightGroup)
  local air = state.air
  if flightGroup.__omwPersonnelFlightPathAcceptanceCallbacks then return end
  flightGroup.__omwPersonnelFlightPathAcceptanceCallbacks = true

  local previousTakeoff = flightGroup.OnAfterTakeoff
  flightGroup.OnAfterTakeoff = function(self, From, Event, To, ...)
    if previousTakeoff then previousTakeoff(self, From, Event, To, ...) end
    if state.failed or self ~= air.flightGroup or air.initialTakeoffCount > 0 then return end
    if air.routeInstalled ~= true then fail("AIR_TAKEOFF_BEFORE_CORRIDOR_ROUTE_INSTALLED"); return end
    air.initialTakeoffCount = air.initialTakeoffCount + 1
    local transaction = state.store:MarkInTransit(AIR_TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.IN_TRANSIT, "AIR_TRANSFER_IN_TRANSIT_STATUS") then return end
    state.registry:SetReservationState(AIR_DEMAND_ID, "IN_TRANSIT")
    state.registry:Activate(AIR_DEMAND_ID)
    if not expectEqual(snapshot(AIR_ORIGIN_NODE).quantity, AIR_FINAL_ORIGIN, "AIR_ORIGIN_IN_TRANSIT") then return end
    log("AIR_INITIAL_TAKEOFF group=" .. tostring(self:GetName())
      .. " transferStatus=IN_TRANSIT demandStatus=ACTIVE")
  end

  local previousLandedAt = flightGroup.OnAfterLandedAt
  flightGroup.OnAfterLandedAt = function(self, From, Event, To, ...)
    if previousLandedAt then previousLandedAt(self, From, Event, To, ...) end
    if state.failed or self ~= air.flightGroup or air.deliveryCommitted then return end

    air.landedAtCount = air.landedAtCount + 1
    if not expectEqual(air.landedAtCount, 1, "AIR_LANDED_AT_COUNT") then return end
    if air.initialTakeoffCount ~= 1 then fail("AIR_LANDED_AT_BEFORE_INITIAL_TAKEOFF"); return end
    if self:IsAirborne() then fail("AIR_LANDED_AT_WHILE_AIRBORNE"); return end

    local distance = self:Get2DDistance(air.targetCoordinate)
    if type(distance) ~= "number" or distance > AIR_LANDING_ACCEPTANCE_RADIUS_M then
      fail("AIR_LANDING_OUTSIDE_FORTRESS_LZ distanceM=" .. tostring(distance))
      return
    end

    local transaction = state.store:MarkDelivered(AIR_TRANSFER_ID)
    if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "AIR_TRANSFER_DELIVERY_STATUS") then return end
    state.registry:SetReservationState(AIR_DEMAND_ID, "DELIVERED")
    state.registry:Succeed(AIR_DEMAND_ID, { transactionId = AIR_TRANSFER_ID, carrierEntityId = AIR_CARRIER_ENTITY_ID })
    air.deliveryCommitted = true
    if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_FINAL_DESTINATION, "AIR_DESTINATION_DELIVERED") then return end

    log("AIR_DELIVERY_CONFIRMED group=" .. tostring(self:GetName())
      .. " lz=" .. AIR_LZ_ZONE_NAME
      .. " distanceM=" .. string.format("%.1f", distance)
      .. " airborne=false quantity=" .. tostring(AIR_TRANSFER_QUANTITY)
      .. " campaignStateStatus=DELIVERED demandStatus=SUCCESS")
  end

  local previousMissionDone = flightGroup.OnAfterMissionDone
  flightGroup.OnAfterMissionDone = function(self, From, Event, To, Mission)
    if previousMissionDone then previousMissionDone(self, From, Event, To, Mission) end
    if state.failed or Mission ~= air.mission then return end
    air.missionDoneCount = air.missionDoneCount + 1
    if not expectEqual(air.missionDoneCount, 1, "AIR_MISSION_DONE_COUNT") then return end
    if air.deliveryCommitted ~= true then fail("AIR_MISSION_DONE_BEFORE_DELIVERY"); return end
    if self:IsAirborne() ~= true then fail("AIR_MISSION_DONE_NOT_AIRBORNE_AT_CORRIDOR_EGRESS"); return end
    log("AIR_MISSION_DONE_AT_CORRIDOR_EGRESS group=" .. tostring(self:GetName())
      .. " physicalReturnPending=true")
  end

  local previousLanded = flightGroup.OnAfterLanded
  flightGroup.OnAfterLanded = function(self, From, Event, To, Airbase)
    if previousLanded then previousLanded(self, From, Event, To, Airbase) end
    if state.failed or self ~= air.flightGroup or not Airbase then return end
    if Airbase:GetName() ~= air.homeAirbase:GetName() then return end
    air.homeLandedCount = air.homeLandedCount + 1
    if not expectEqual(air.homeLandedCount, 1, "AIR_HOME_LANDED_COUNT") then return end
    if air.missionDoneCount ~= 1 then fail("AIR_HOME_LANDED_BEFORE_MISSION_DONE"); return end
    log("AIR_HOME_LANDED group=" .. tostring(self:GetName())
      .. " airbase=" .. tostring(Airbase:GetName()))
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
  requireValue(GROUP:FindByName(AIR_TEMPLATE_NAME), AIR_TEMPLATE_NAME)
  air.targetZone = requireValue(ZONE:FindByName(AIR_LZ_ZONE_NAME), AIR_LZ_ZONE_NAME)
  air.pathline = requireValue(PATHLINE:FindByName(AIR_PATHLINE_NAME), AIR_PATHLINE_NAME)
  if state.failed then return false end

  air.targetCoordinate = requireValue(air.targetZone:GetCoordinate(), AIR_LZ_ZONE_NAME .. "_COORDINATE")
  local airbaseName = requireValue(air.airwing:GetAirbaseName(), "JALALABAD_AIRBASE_NAME")
  air.homeAirbase = requireValue(AIRBASE:FindByName(airbaseName), "JALALABAD_AIRBASE")
  if state.failed then return false end

  air.outboundRoute, air.returnRoute = buildCorridor(air.pathline, air.homeAirbase:GetCoordinate(), air.targetCoordinate)
  if state.failed or not air.outboundRoute or not air.returnRoute then return false end

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
    SCHEDULER:New(nil, function()
      installMissionCorridor(FlightGroup, Mission)
    end, {}, AIR_ROUTE_INSTALL_DELAY_SEC)
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
    if air.homeLandedCount ~= 1 then fail("AIR_LEGION_RETURNED_BEFORE_HOME_LANDING"); return end
    log("AIR_LEGION_ASSET_RETURNED squadron=" .. AIR_SQUADRON_NAME
      .. " asset=" .. tostring(Asset.spawngroupname)
      .. " homeLandingConfirmed=true")
    verifyFinalState()
  end

  air.mission = AUFTRAG:NewLANDATCOORDINATE(
    air.targetCoordinate,
    nil,
    nil,
    AIR_LANDING_DWELL_SEC
  )
  air.mission:SetName("OMW_AIR_PERSONNEL_RESUPPLY_JALALABAD_TO_FORTRESS_FLIGHTPATH")
  air.mission:SetRequiredAssets(1, 1)
  air.mission:AssignSquadrons({ air.squadron })
  air.mission:SetPriority(20, true)
  -- Final egress is the last right-offset return-corridor point near Jalalabad.
  air.mission:SetMissionEgressCoord(air.returnRoute[#air.returnRoute], AIR_CORRIDOR_ALTITUDE_FT_AGL)
  air.airwing:AddMission(air.mission)

  log("AIR_MISSION_QUEUED type=LANDATCOORDINATE origin=" .. AIR_ORIGIN_NODE
    .. " destination=" .. AIR_DESTINATION_NODE
    .. " lz=" .. AIR_LZ_ZONE_NAME
    .. " pathline=" .. AIR_PATHLINE_NAME
    .. " offsetRightM=" .. tostring(AIR_PATH_OFFSET_RIGHT_M)
    .. " corridorAltitudeFtAGL=" .. tostring(AIR_CORRIDOR_ALTITUDE_FT_AGL)
    .. " squadron=" .. AIR_SQUADRON_NAME
    .. " requiredAssets=1 dwellSec=" .. tostring(AIR_LANDING_DWELL_SEC)
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
state.air.stockRow = findStockRow(initialStock, AIR_DESTINATION_NODE)
if not state.air.stockRow then fail("FORTRESS_PERSONNEL_STOCK_ROW_NOT_FOUND"); return end
if not expectEqual(state.air.stockRow.resourceClass, RESOURCE_CLASS, "AIR_STOCK_RESOURCE_CLASS") then return end
if not expectEqual(state.air.stockRow.reorderComparison, "BELOW", "AIR_STOCK_REORDER_COMPARISON") then return end

state.registry = OMW_PERSONNEL_FLIGHTPATH_MISSION_DEMAND.New()
if not createDemandAndReservation(state.air.stockRow) then return end
if not prepareAirExecution() then return end

log("PHYSICAL_EXECUTION_READY airMission=LANDATCOORDINATE airTemplate=" .. AIR_TEMPLATE_NAME
  .. " pathline=" .. AIR_PATHLINE_NAME
  .. " strategicAuthority=CAMPAIGNSTATE physicalInfantryCargo=false TROOPTRANSPORT=false")