-- Operation Mountain Watch - Kandahar full-inventory physical parking saturation test.
--
-- Load order:
--   1. Moose.lua
--   2. OMW_AirOps_Kandahar.lua
--   3. this test bundle
--
-- Scope: request every registered Kandahar Main and Kandahar Heliport AI asset
-- through the native MOOSE WAREHOUSE self-request path, keep the spawned groups
-- physically present, and verify every unit against its owner-defined parking pool.
-- No COMMANDER, OPSTRANSPORT, tactical AUFTRAG dispatch, F10 controls,
-- CampaignState mutation, recovery, persistence, or MOOSE source override.

local TAG = "[OMW][AirOps.KAF.Parking.FullInventory]"
local START_DELAY_S = 20
local MONITOR_INTERVAL_S = 5
local MONITOR_LIMIT_S = 420
local EXPECTED_GROUPS = 76
local EXPECTED_AIRFRAMES = 112
local EXPECTED_REQUESTS = 9

local EXPECTED = {
  A10C = {
    wing = "Main",
    name = "SQ_US_KAF_A10C_74_EFS",
    template = "TPL_AIR_US_KAF_A10C_CAS_2SHIP",
    groups = 8,
    grouping = 2,
    airframes = 16,
    parkingIDs = { 247, 177, 8, 11, 141, 59, 109, 88, 237, 266, 49, 268, 270, 179, 20, 69, 91, 43, 287, 282, 278, 63, 313, 51 },
  },
  HH60G = {
    wing = "Main",
    name = "SQ_US_KAF_HH60G_26_ERQS",
    template = "TPL_AIR_US_KAF_HH60G_CSAR_1SHIP",
    groups = 6,
    grouping = 1,
    airframes = 6,
    parkingIDs = { 66, 190, 111, 158, 73, 14, 60, 274, 145, 191, 168, 125 },
  },
  C130 = {
    wing = "Main",
    name = "SQ_US_KAF_C130_772_EAS",
    template = "TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP",
    groups = 12,
    grouping = 1,
    airframes = 12,
    parkingIDs = { 309, 232, 107, 260, 299, 194, 294, 92, 201, 174, 156, 124, 238, 280, 28, 16, 40, 136, 281, 314, 25, 229 },
  },
  MQ1 = {
    wing = "Main",
    name = "SQ_US_KAF_MQ1_361_ERS",
    template = "TPL_AIR_US_KAF_MQ1A_RECON_1SHIP",
    groups = 4,
    grouping = 1,
    airframes = 4,
    parkingIDs = { 189, 303, 202, 224, 46, 291, 129, 143, 27, 54, 263 },
  },
  MQ9 = {
    wing = "Main",
    name = "SQ_US_KAF_MQ9_361_ERS",
    template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
    groups = 2,
    grouping = 1,
    airframes = 2,
    parkingIDs = { 189, 303, 202, 224, 46, 291, 129, 143, 27, 54, 263 },
  },
  AH64D = {
    wing = "Heliport",
    name = "SQ_US_KAF_AH64_4_227_AVN",
    template = "TPL_AIR_US_KAF_AH64D_CAS_2SHIP",
    groups = 4,
    grouping = 2,
    airframes = 8,
    parkingIDs = { 13, 12, 75, 54, 76, 69, 29, 43, 7, 53, 19, 86, 83, 87, 20, 55, 49, 74, 30, 64, 71, 67, 59, 11, 50, 36 },
  },
  OH58D = {
    wing = "Heliport",
    name = "SQ_US_KAF_OH58D_7_17_CAV",
    template = "TPL_AIR_US_KAF_OH58D_RECON_2SHIP",
    groups = 8,
    grouping = 2,
    airframes = 16,
    parkingIDs = { 80, 79, 73, 39, 3, 24, 28, 34, 62, 57, 23, 85, 78, 51, 33, 35, 10, 63, 0 },
  },
  CH47 = {
    wing = "Heliport",
    name = "SQ_US_KAF_CH47_7_101_GSAB",
    template = "TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP",
    groups = 16,
    grouping = 1,
    airframes = 16,
    parkingIDs = { 4, 25, 18, 81, 58, 38, 45, 47, 2, 70, 5, 48 },
  },
  UH60 = {
    wing = "Heliport",
    name = "SQ_US_KAF_UH60_7_101_GSAB",
    template = "TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP",
    groups = 16,
    grouping = 2,
    airframes = 32,
    parkingIDs = { 60, 52, 9, 22, 31, 21, 61, 42, 72, 41, 84, 8, 32, 15, 46, 56, 27, 66, 82, 17, 1, 6, 37, 68, 40, 16, 14, 26, 65 },
  },
}

local ORDER = { "A10C", "HH60G", "C130", "MQ1", "MQ9", "AH64D", "OH58D", "CH47", "UH60" }

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
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

local function containsParkingID(parkingIDs, terminalID)
  for _, parkingID in ipairs(parkingIDs) do
    if parkingID == terminalID then
      return true
    end
  end
  return false
end

local function sameParkingPool(actual, expected)
  if type(actual) ~= "table" or #actual ~= #expected then
    return false
  end
  local lookup = {}
  for _, value in ipairs(actual) do
    lookup[value] = (lookup[value] or 0) + 1
  end
  for _, value in ipairs(expected) do
    if not lookup[value] or lookup[value] == 0 then
      return false
    end
    lookup[value] = lookup[value] - 1
  end
  return true
end

local function validateFoundation(state)
  if state.Status ~= "RUNNING" then
    error("Kandahar foundation is not RUNNING: " .. tostring(state.Status))
  end
  if state.RegisteredGroups ~= EXPECTED_GROUPS then
    error("Unexpected registered group total: " .. tostring(state.RegisteredGroups))
  end
  if state.RegisteredAirframes ~= EXPECTED_AIRFRAMES then
    error("Unexpected registered airframe total: " .. tostring(state.RegisteredAirframes))
  end

  for _, key in ipairs(ORDER) do
    local expected = EXPECTED[key]
    local squadron = state.Squadrons and state.Squadrons[key] or nil
    local config = state.Config and state.Config.squadrons and state.Config.squadrons[key] or nil
    if not squadron or not config then
      error("Missing squadron/config for " .. key)
    end
    if squadron.name ~= expected.name then
      error("Unexpected squadron name for " .. key .. ": " .. tostring(squadron.name))
    end
    if config.template ~= expected.template
      or config.assetGroups ~= expected.groups
      or config.grouping ~= expected.grouping
      or config.logicalAircraft ~= expected.airframes
      or not sameParkingPool(config.parkingIDs, expected.parkingIDs) then
      error("Foundation contract mismatch for " .. key)
    end
  end
end

local function newResults()
  return {
    completedRequests = 0,
    groups = 0,
    airframes = 0,
    parkingViolations = 0,
    duplicateOccupancy = 0,
    completed = {},
    parkingOccupancy = { Main = {}, Heliport = {} },
  }
end

local function inspectRequest(state, results, key, groupset)
  local expected = EXPECTED[key]
  local airbase = state.Airbases[expected.wing]
  local groups = groupset and groupset:GetSetObjects() or {}
  local groupCount = 0
  local airframeCount = 0
  local requestViolations = 0
  local requestDuplicates = 0

  for _, group in pairs(groups) do
    groupCount = groupCount + 1
    local units = group and group:GetUnits() or {}
    airframeCount = airframeCount + #units

    for unitIndex, unit in ipairs(units) do
      local coordinate = unit and unit:GetCoordinate() or nil
      if not coordinate then
        requestViolations = requestViolations + 1
        fail(string.format("SPAWN_PARKING key=%s group=%s unitIndex=%d coordinate=UNAVAILABLE", key, tostring(group and group:GetName()), unitIndex))
      else
        local _, terminalID, distanceM = coordinate:GetClosestParkingSpot(airbase, nil, nil)
        local allowed = containsParkingID(expected.parkingIDs, terminalID)
        local occupancyKey = tostring(terminalID)
        local previous = results.parkingOccupancy[expected.wing][occupancyKey]
        local duplicate = previous ~= nil

        if not allowed then
          requestViolations = requestViolations + 1
        end
        if duplicate then
          requestDuplicates = requestDuplicates + 1
        else
          results.parkingOccupancy[expected.wing][occupancyKey] = tostring(unit:GetName())
        end

        log(string.format(
          "SPAWN_PARKING key=%s wing=%s squadron=%s group=%s unitIndex=%d unitName=%s unitType=%s terminalID=%s parkingAllowed=%s duplicateOccupancy=%s previousUnit=%s distanceM=%.3f",
          key,
          expected.wing,
          expected.name,
          tostring(group:GetName()),
          unitIndex,
          tostring(unit:GetName()),
          tostring(unit:GetTypeName()),
          tostring(terminalID),
          tostring(allowed),
          tostring(duplicate),
          tostring(previous),
          tonumber(distanceM) or -1
        ))
      end
    end
  end

  if groupCount ~= expected.groups then
    requestViolations = requestViolations + 1
    fail(string.format("GROUP_COUNT key=%s expected=%d actual=%d", key, expected.groups, groupCount))
  end
  if airframeCount ~= expected.airframes then
    requestViolations = requestViolations + 1
    fail(string.format("AIRFRAME_COUNT key=%s expected=%d actual=%d", key, expected.airframes, airframeCount))
  end

  results.completedRequests = results.completedRequests + 1
  results.groups = results.groups + groupCount
  results.airframes = results.airframes + airframeCount
  results.parkingViolations = results.parkingViolations + requestViolations
  results.duplicateOccupancy = results.duplicateOccupancy + requestDuplicates
  results.completed[key] = true

  log(string.format(
    "REQUEST_RESULT key=%s wing=%s squadron=%s expectedGroups=%d actualGroups=%d expectedAirframes=%d actualAirframes=%d parkingViolations=%d duplicateOccupancy=%d",
    key,
    expected.wing,
    expected.name,
    expected.groups,
    groupCount,
    expected.airframes,
    airframeCount,
    requestViolations,
    requestDuplicates
  ))
end

local function finalStatus(results)
  local complete = results.completedRequests == EXPECTED_REQUESTS
    and results.groups == EXPECTED_GROUPS
    and results.airframes == EXPECTED_AIRFRAMES
  local clean = results.parkingViolations == 0 and results.duplicateOccupancy == 0
  return complete and clean and "PASS_FULL_INVENTORY_PHYSICAL_PARKING" or "FAIL_FULL_INVENTORY_PHYSICAL_PARKING"
end

local function run()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Kandahar then
    error("Kandahar foundation state not loaded")
  end
  if not WAREHOUSE or not SCHEDULER then
    error("Required pinned MOOSE WAREHOUSE/SCHEDULER classes are unavailable")
  end

  local state = OMW.AirOps.Kandahar
  validateFoundation(state)

  local results = newResults()
  local assignments = {}

  for _, key in ipairs(ORDER) do
    assignments["KAF_FULL_PARKING_" .. key] = key
  end

  local function installObserver(wingKey)
    local airwing = state.Airwings[wingKey]
    airwing.OnAfterSelfRequest = function(self, From, Event, To, GroupSet, Request)
      local key = Request and assignments[Request.assignment] or nil
      if not key then
        fail("Unexpected self-request callback assignment=" .. tostring(Request and Request.assignment))
        return
      end
      if results.completed[key] then
        fail("Duplicate self-request callback for " .. key)
        return
      end
      inspectRequest(state, results, key, GroupSet)
    end
  end

  installObserver("Main")
  installObserver("Heliport")

  for requestIndex, key in ipairs(ORDER) do
    local expected = EXPECTED[key]
    local airwing = state.Airwings[expected.wing]
    local assignment = "KAF_FULL_PARKING_" .. key
    log(string.format(
      "SELF_REQUEST key=%s requestIndex=%d wing=%s squadron=%s template=%s groups=%d grouping=%d airframes=%d parkingPool=%d",
      key,
      requestIndex,
      expected.wing,
      expected.name,
      expected.template,
      expected.groups,
      expected.grouping,
      expected.airframes,
      #expected.parkingIDs
    ))
    airwing:AddRequest(
      airwing,
      WAREHOUSE.Descriptor.GROUPNAME,
      expected.template,
      expected.groups,
      WAREHOUSE.TransportType.SELFPROPELLED,
      0,
      50,
      assignment
    )
  end

  local elapsed = 0
  SCHEDULER:New(nil, function()
    elapsed = elapsed + MONITOR_INTERVAL_S

    if results.completedRequests == EXPECTED_REQUESTS then
      local status = finalStatus(results)
      log(string.format(
        "RESULT status=%s requests=%d/%d groups=%d/%d airframes=%d/%d parkingViolations=%d duplicateOccupancy=%d mainUniqueTerminalIDs=%d heliportUniqueTerminalIDs=%d elapsedS=%d",
        status,
        results.completedRequests,
        EXPECTED_REQUESTS,
        results.groups,
        EXPECTED_GROUPS,
        results.airframes,
        EXPECTED_AIRFRAMES,
        results.parkingViolations,
        results.duplicateOccupancy,
        countTable(results.parkingOccupancy.Main),
        countTable(results.parkingOccupancy.Heliport),
        elapsed
      ))
      return false
    end

    if elapsed >= MONITOR_LIMIT_S then
      fail(string.format(
        "RESULT status=FAIL_TIMEOUT requests=%d/%d groups=%d/%d airframes=%d/%d parkingViolations=%d duplicateOccupancy=%d mainUniqueTerminalIDs=%d heliportUniqueTerminalIDs=%d elapsedS=%d",
        results.completedRequests,
        EXPECTED_REQUESTS,
        results.groups,
        EXPECTED_GROUPS,
        results.airframes,
        EXPECTED_AIRFRAMES,
        results.parkingViolations,
        results.duplicateOccupancy,
        countTable(results.parkingOccupancy.Main),
        countTable(results.parkingOccupancy.Heliport),
        elapsed
      ))
      return false
    end

    return true
  end, {}, MONITOR_INTERVAL_S, MONITOR_INTERVAL_S)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
  end
end, {}, START_DELAY_S)
