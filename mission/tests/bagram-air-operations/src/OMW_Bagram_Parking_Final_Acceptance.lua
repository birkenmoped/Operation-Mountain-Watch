-- Operation Mountain Watch - Bagram final parking acceptance harness.
-- Test-only. Requires OMW_AirOps_Bagram_Bootstrap.lua to have initialized
-- OMW.AirOps.Bagram before this source is appended to the same generated bundle.
--
-- Scope: one controlled MOOSE ALERT5 materialization per Bagram SQUADRON,
-- runtime parking-set correlation, foundation/post-start parking propagation,
-- and physical unit-to-TerminalID verification.
--
-- No native DCS spawn path, no SPAWN class, no COMMANDER, no OPSTRANSPORT.

local TEST_ID = "BAGRAM-PARKING-FINAL-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local EXPECTED_RUNTIME_PARKING = 187
local EXPECTED_FOUNDATION_ASSETS = 69
local EXPECTED_TEST_GROUPS = 7
local EXPECTED_TEST_UNITS = 9
local MAX_NEAREST_PARKING_DISTANCE_M = 50

local candidates = __BAGRAM_PARKING_CANDIDATES__

local dispatchDefinitions = {
  F15E = { missionType = AUFTRAG.Type.CAS, expectedUnits = 2 },
  F16C = { missionType = AUFTRAG.Type.CAS, expectedUnits = 2 },
  MQ1A = { missionType = AUFTRAG.Type.RECON, expectedUnits = 1 },
  C130 = { missionType = AUFTRAG.Type.TROOPTRANSPORT, expectedUnits = 1 },
  HH60G = { missionType = AUFTRAG.Type.RESCUEHELO, expectedUnits = 1 },
  UH60 = { missionType = AUFTRAG.Type.TROOPTRANSPORT, expectedUnits = 1 },
  CH47 = { missionType = AUFTRAG.Type.TROOPTRANSPORT, expectedUnits = 1 },
}

local result = {
  finalized = false,
  objectContract = false,
  foundationAssets = 0,
  foundationParkingChecked = 0,
  foundationParkingFailed = 0,
  dispatchRequested = 0,
  groupsMaterialized = 0,
  unitsMaterialized = 0,
  unitsParkingChecked = 0,
  unitsInOwnPool = 0,
  crossPoolViolations = 0,
  blacklistViolations = 0,
  unknownParking = 0,
  unexpectedMissions = 0,
  groupFailures = 0,
  seenMissions = {},
  missionToKey = {},
  parkingSpots = {},
  parkingByID = {},
  blacklisted = {},
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " " .. tostring(message), false)
end

local function countTable(value)
  local count = 0
  if type(value) == "table" then
    for _ in pairs(value) do
      count = count + 1
    end
  end
  return count
end

local function sameNumberSet(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" or #actual ~= #expected then
    return false
  end
  local seen = {}
  for _, id in ipairs(actual) do
    seen[id] = (seen[id] or 0) + 1
  end
  for _, id in ipairs(expected) do
    if not seen[id] then
      return false
    end
    seen[id] = seen[id] - 1
    if seen[id] == 0 then
      seen[id] = nil
    end
  end
  return next(seen) == nil
end

local function containsNumber(list, value)
  if type(list) ~= "table" then
    return false
  end
  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end
  return false
end

local function emitFinal(status, reason)
  if result.finalized then
    return
  end
  result.finalized = true
  log(string.format(
    "BAGRAM_PARKING_FINAL_RESULT status=%s reason=%s foundationAssets=%d foundationParkingChecked=%d foundationParkingFailed=%d dispatchRequested=%d groupsMaterialized=%d unitsMaterialized=%d unitsParkingChecked=%d unitsInOwnPool=%d crossPoolViolations=%d blacklistViolations=%d unknownParking=%d unexpectedMissions=%d groupFailures=%d",
    status,
    tostring(reason or "NONE"),
    result.foundationAssets,
    result.foundationParkingChecked,
    result.foundationParkingFailed,
    result.dispatchRequested,
    result.groupsMaterialized,
    result.unitsMaterialized,
    result.unitsParkingChecked,
    result.unitsInOwnPool,
    result.crossPoolViolations,
    result.blacklistViolations,
    result.unknownParking,
    result.unexpectedMissions,
    result.groupFailures
  ))
end

local function nearestParkingSpot(coordinate)
  local nearest = nil
  local nearestDistance = nil
  for _, spot in pairs(result.parkingSpots) do
    if spot.Coordinate then
      local distance = coordinate:Get2DDistance(spot.Coordinate)
      if nearestDistance == nil or distance < nearestDistance then
        nearest = spot
        nearestDistance = distance
      end
    end
  end
  return nearest, nearestDistance
end

local function inspectPhysicalParking(key, opsGroup)
  if result.finalized then
    return
  end

  local state = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  local definition = state and state.Config and state.Config.squadrons[key] or nil
  local expected = dispatchDefinitions[key]
  local groupName = opsGroup and opsGroup.GetName and opsGroup:GetName() or nil
  local group = groupName and GROUP:FindByName(groupName) or nil

  if not definition or not expected or not group then
    result.groupFailures = result.groupFailures + 1
    fail(string.format("MATERIALIZATION status=FAIL squadronKey=%s group=%s reason=GROUP_OR_DEFINITION_UNAVAILABLE", tostring(key), tostring(groupName)))
    if result.groupsMaterialized + result.groupFailures >= EXPECTED_TEST_GROUPS then
      emitFinal("FAIL", "MATERIALIZATION_FAILURE")
    end
    return
  end

  local units = group:GetUnits() or {}
  if #units ~= expected.expectedUnits then
    result.groupFailures = result.groupFailures + 1
    fail(string.format("MATERIALIZATION status=FAIL squadron=%s group=%s expectedUnits=%d actualUnits=%d", definition.name, tostring(groupName), expected.expectedUnits, #units))
  else
    result.groupsMaterialized = result.groupsMaterialized + 1
  end

  for _, unit in ipairs(units) do
    result.unitsMaterialized = result.unitsMaterialized + 1
    local coordinate = unit:GetCoordinate()
    local spot = nil
    local distance = nil
    if coordinate then
      spot, distance = nearestParkingSpot(coordinate)
    end

    if not spot or distance == nil or distance > MAX_NEAREST_PARKING_DISTANCE_M then
      result.unknownParking = result.unknownParking + 1
      fail(string.format(
        "PHYSICAL_PARKING status=FAIL squadron=%s group=%s unit=%s reason=NO_NEAR_PARKING distance=%s",
        definition.name,
        tostring(groupName),
        tostring(unit:GetName()),
        tostring(distance)
      ))
    else
      result.unitsParkingChecked = result.unitsParkingChecked + 1
      local terminalID = spot.TerminalID
      local ownPool = containsNumber(definition.parkingIDs, terminalID)
      local blacklisted = result.blacklisted[terminalID] == true

      if blacklisted then
        result.blacklistViolations = result.blacklistViolations + 1
      end
      if ownPool then
        result.unitsInOwnPool = result.unitsInOwnPool + 1
      else
        result.crossPoolViolations = result.crossPoolViolations + 1
      end

      log(string.format(
        "PHYSICAL_PARKING status=%s squadron=%s group=%s unit=%s terminalID=%s parkingPool=%s distanceM=%.2f blacklisted=%s ownPool=%s",
        ownPool and not blacklisted and "PASS" or "FAIL",
        definition.name,
        tostring(groupName),
        tostring(unit:GetName()),
        tostring(terminalID),
        tostring(definition.parkingLabels),
        distance,
        tostring(blacklisted),
        tostring(ownPool)
      ))
    end
  end

  if result.groupsMaterialized + result.groupFailures >= EXPECTED_TEST_GROUPS then
    local pass = result.objectContract
      and result.foundationAssets == EXPECTED_FOUNDATION_ASSETS
      and result.foundationParkingChecked == EXPECTED_FOUNDATION_ASSETS
      and result.foundationParkingFailed == 0
      and result.dispatchRequested == EXPECTED_TEST_GROUPS
      and result.groupsMaterialized == EXPECTED_TEST_GROUPS
      and result.unitsMaterialized == EXPECTED_TEST_UNITS
      and result.unitsParkingChecked == EXPECTED_TEST_UNITS
      and result.unitsInOwnPool == EXPECTED_TEST_UNITS
      and result.crossPoolViolations == 0
      and result.blacklistViolations == 0
      and result.unknownParking == 0
      and result.unexpectedMissions == 0
      and result.groupFailures == 0

    emitFinal(pass and "PASS" or "FAIL", pass and "ALL_GATES_PASS" or "AGGREGATE_GATE_FAILURE")
  end
end

local function handleOpsOnMission(opsGroup, mission)
  local key = result.missionToKey[mission]
  if not key then
    result.unexpectedMissions = result.unexpectedMissions + 1
    local missionId = mission and (mission.name or mission.auftragsnummer or mission.type) or "nil"
    fail(string.format("DISPATCH_EVENT status=FAIL reason=UNEXPECTED_MISSION group=%s mission=%s", tostring(opsGroup and opsGroup.GetName and opsGroup:GetName()), tostring(missionId)))
    return
  end
  if result.seenMissions[mission] then
    return
  end
  result.seenMissions[mission] = true
  log(string.format("DISPATCH_EVENT status=OBSERVED squadronKey=%s group=%s missionType=%s", key, tostring(opsGroup:GetName()), tostring(mission:GetType())))
  SCHEDULER:New(nil, inspectPhysicalParking, { key, opsGroup }, 2)
end

local function verifyObjectContractAndFoundation()
  local state = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  if not state or state.Status ~= "RUNNING" then
    fail("OBJECT_CONTRACT status=FAIL reason=FOUNDATION_NOT_RUNNING")
    emitFinal("FAIL", "FOUNDATION_NOT_RUNNING")
    return false
  end

  local airbase = state.Airbases and state.Airbases.USAF or nil
  if not airbase then
    fail("OBJECT_CONTRACT status=FAIL reason=BAGRAM_AIRBASE_MISSING")
    emitFinal("FAIL", "BAGRAM_AIRBASE_MISSING")
    return false
  end

  local parkingSpots = airbase:GetParkingSpotsTable() or {}
  result.parkingSpots = parkingSpots
  local duplicateIDs = 0
  local uniqueIDs = 0
  for _, spot in pairs(parkingSpots) do
    local id = spot.TerminalID
    if result.parkingByID[id] then
      duplicateIDs = duplicateIDs + 1
    else
      result.parkingByID[id] = spot
      uniqueIDs = uniqueIDs + 1
    end
  end

  local missingCandidates = 0
  for _, candidate in ipairs(candidates) do
    if not result.parkingByID[candidate.terminalID] then
      missingCandidates = missingCandidates + 1
    end
  end

  local unexpectedRuntimeIDs = 0
  local candidateIDs = {}
  for _, candidate in ipairs(candidates) do
    candidateIDs[candidate.terminalID] = true
  end
  for runtimeID in pairs(result.parkingByID) do
    if not candidateIDs[runtimeID] then
      unexpectedRuntimeIDs = unexpectedRuntimeIDs + 1
    end
  end

  log(string.format(
    "PARKING_RUNTIME_BASELINE status=%s candidates=%d runtimeParkingSpots=%d runtimeUniqueTerminalIDs=%d runtimeDuplicateIDs=%d missingCandidates=%d unexpectedRuntimeIDs=%d",
    (#candidates == EXPECTED_RUNTIME_PARKING and #parkingSpots == EXPECTED_RUNTIME_PARKING and uniqueIDs == EXPECTED_RUNTIME_PARKING and duplicateIDs == 0 and missingCandidates == 0 and unexpectedRuntimeIDs == 0) and "PASS" or "FAIL",
    #candidates,
    #parkingSpots,
    uniqueIDs,
    duplicateIDs,
    missingCandidates,
    unexpectedRuntimeIDs
  ))

  if #candidates ~= EXPECTED_RUNTIME_PARKING or #parkingSpots ~= EXPECTED_RUNTIME_PARKING or uniqueIDs ~= EXPECTED_RUNTIME_PARKING or duplicateIDs ~= 0 or missingCandidates ~= 0 or unexpectedRuntimeIDs ~= 0 then
    emitFinal("FAIL", "PARKING_RUNTIME_BASELINE_FAILURE")
    return false
  end

  for _, terminalID in ipairs(state.Config.parkingBlacklist or {}) do
    result.blacklisted[terminalID] = true
    if not result.parkingByID[terminalID] then
      fail("OBJECT_CONTRACT status=FAIL reason=BLACKLIST_TERMINAL_MISSING terminalID=" .. tostring(terminalID))
      emitFinal("FAIL", "BLACKLIST_TERMINAL_MISSING")
      return false
    end
  end

  local foundationAssets = 0
  local foundationParkingChecked = 0
  local foundationParkingFailed = 0
  local templateFailures = 0
  local policyIDs = {}

  for key, definition in pairs(state.Config.squadrons) do
    local squadron = state.Squadrons[key]
    local template = GROUP:FindByName(definition.template)
    local templateUnits = template and template:GetUnits() or {}
    local templateTypes = {}
    for _, unit in ipairs(templateUnits) do
      templateTypes[#templateTypes + 1] = tostring(unit:GetTypeName())
    end

    if not squadron or not template or #templateUnits ~= definition.grouping then
      templateFailures = templateFailures + 1
    end

    log(string.format(
      "OBJECT_TEMPLATE squadron=%s template=%s expectedUnits=%d actualUnits=%d dcsTypes=%s",
      definition.name,
      definition.template,
      definition.grouping,
      #templateUnits,
      table.concat(templateTypes, ",")
    ))

    local assets = squadron and squadron.assets or {}
    foundationAssets = foundationAssets + countTable(assets)
    for _, asset in pairs(assets) do
      foundationParkingChecked = foundationParkingChecked + 1
      if not sameNumberSet(asset.parkingIDs, definition.parkingIDs) then
        foundationParkingFailed = foundationParkingFailed + 1
      end
    end

    for _, terminalID in ipairs(definition.parkingIDs or {}) do
      if result.blacklisted[terminalID] or policyIDs[terminalID] or not result.parkingByID[terminalID] then
        fail(string.format("OBJECT_CONTRACT status=FAIL reason=INVALID_POLICY_TERMINAL squadron=%s terminalID=%s", definition.name, tostring(terminalID)))
        emitFinal("FAIL", "INVALID_POLICY_TERMINAL")
        return false
      end
      policyIDs[terminalID] = key
    end
  end

  result.foundationAssets = foundationAssets
  result.foundationParkingChecked = foundationParkingChecked
  result.foundationParkingFailed = foundationParkingFailed

  local warehouseUSAF = (STATIC and STATIC:FindByName(state.Config.usaf.warehouseName, false)) or (UNIT and UNIT:FindByName(state.Config.usaf.warehouseName))
  local warehouseArmy = (STATIC and STATIC:FindByName(state.Config.army.warehouseName, false)) or (UNIT and UNIT:FindByName(state.Config.army.warehouseName))
  local airwingsRunning = state.Airwings.USAF:IsRunning() and state.Airwings.Army:IsRunning()
  local objectPass = warehouseUSAF ~= nil
    and warehouseArmy ~= nil
    and templateFailures == 0
    and countTable(policyIDs) == 44
    and foundationAssets == EXPECTED_FOUNDATION_ASSETS
    and foundationParkingChecked == EXPECTED_FOUNDATION_ASSETS
    and foundationParkingFailed == 0
    and airwingsRunning

  log(string.format(
    "OBJECT_CONTRACT status=%s warehouseUSAF=%s warehouseArmy=%s squadrons=%d policyIDs=%d foundationAssets=%d foundationParkingChecked=%d foundationParkingFailed=%d airwingsRunning=%s templateFailures=%d",
    objectPass and "PASS" or "FAIL",
    tostring(warehouseUSAF ~= nil),
    tostring(warehouseArmy ~= nil),
    countTable(state.Squadrons),
    countTable(policyIDs),
    foundationAssets,
    foundationParkingChecked,
    foundationParkingFailed,
    tostring(airwingsRunning),
    templateFailures
  ))

  if not objectPass then
    emitFinal("FAIL", "OBJECT_CONTRACT_FAILURE")
    return false
  end

  result.objectContract = true
  return true
end

local function startDispatch()
  if result.finalized or not verifyObjectContractAndFoundation() then
    return
  end

  local state = OMW.AirOps.Bagram

  function state.Airwings.USAF:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
    handleOpsOnMission(OpsGroup, Mission)
  end

  function state.Airwings.Army:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
    handleOpsOnMission(OpsGroup, Mission)
  end

  for _, key in ipairs({ "F15E", "F16C", "MQ1A", "C130", "HH60G", "UH60", "CH47" }) do
    local definition = state.Config.squadrons[key]
    local dispatch = dispatchDefinitions[key]
    local squadron = state.Squadrons[key]
    local airwing = definition.wing == "usaf" and state.Airwings.USAF or state.Airwings.Army
    local mission = AUFTRAG:NewALERT5(dispatch.missionType)
    mission:SetRequiredAssets(1, 1)
    mission:AssignSquadrons({ squadron })
    result.missionToKey[mission] = key
    airwing:AddMission(mission)
    result.dispatchRequested = result.dispatchRequested + 1
    log(string.format("DISPATCH_REQUEST status=QUEUED squadron=%s key=%s alert5MissionType=%s requiredAssets=1", definition.name, key, tostring(dispatch.missionType)))
  end

  log(string.format("DISPATCH_BATCH status=QUEUED requested=%d expected=%d", result.dispatchRequested, EXPECTED_TEST_GROUPS))
end

SCHEDULER:New(nil, startDispatch, {}, 2)
SCHEDULER:New(nil, function()
  if not result.finalized then
    emitFinal("FAIL", "TIMEOUT_120S")
  end
end, {}, 120)
