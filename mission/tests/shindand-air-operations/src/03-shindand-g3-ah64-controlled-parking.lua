-- Operation Mountain Watch - Shindand G3 isolated AH-64 controlled parking test.
--
-- Reuses the established OMW Kandahar controlled-parking pattern before any
-- Shindand-specific workaround is considered:
--   * keep the existing AIRWING/WAREHOUSE lifecycle;
--   * constrain the AIRWING parking IDs through the public MOOSE API;
--   * issue one exact-template WAREHOUSE self-request;
--   * observe physical placement without AUFTRAG or COMMANDER tasking.
--
-- Load order:
--   1. Moose.lua
--   2. OMW_AirOps_Shindand.lua
--   3. this test bundle
--
-- No COMMANDER, AUFTRAG, OPSTRANSPORT, direct SPAWN, native DCS group creation,
-- F10 controls, CampaignState mutation, recovery or persistence.

local TAG = "[OMW][AirOps.SHND.G3.AH64Parking]"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_AIRBASE_ID = 14
local EXPECTED_SQUADRON = "SQ_US_SHND_AH64D_ATTACK"
local EXPECTED_TEMPLATE = "TPL_AIR_US_SHND_AH64D_CAS_2SHIP"
local EXPECTED_PARKING_IDS = { 21, 3, 34, 15 }
local EXPECTED_ASSET_GROUPS = 1
local EXPECTED_UNITS = 2
local MAX_NODE_DISTANCE_M = 12
local ASSIGNMENT = "OMW_SHND_G3_AH64_CONTROLLED_PARKING"
local START_DELAY_S = 20
local TIMEOUT_S = 90

local completed = false
local requestIssued = false
local violations = 0

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(reason)
  violations = violations + 1
  env.error(TAG .. " VIOLATION reason=" .. tostring(reason), false)
end

local function toSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[tonumber(value)] = true
  end
  return result
end

local function sameNumericSet(actual, expected)
  if type(actual) ~= "table" then
    return false
  end
  local actualSet = {}
  for key, value in pairs(actual) do
    if type(value) == "number" then
      actualSet[tonumber(value)] = true
    elseif value == true and tonumber(key) then
      actualSet[tonumber(key)] = true
    end
  end
  local expectedSet = toSet(expected)
  for value in pairs(expectedSet) do
    if not actualSet[value] then
      return false
    end
  end
  for value in pairs(actualSet) do
    if not expectedSet[value] then
      return false
    end
  end
  return true
end

local function getAssignment(airwing, request)
  if airwing and airwing.GetAssignment then
    local ok, value = pcall(function()
      return airwing:GetAssignment(request)
    end)
    if ok and value then
      return tostring(value)
    end
  end
  if type(request) == "table" then
    return tostring(request.assignment or request.Assignment or "")
  end
  return ""
end

local function finish(spawnedGroups, spawnedUnits, terminalIDs)
  if completed then
    return
  end
  completed = true

  if spawnedGroups ~= EXPECTED_ASSET_GROUPS then
    fail(string.format("SPAWNED_GROUP_COUNT_MISMATCH expected=%d actual=%d", EXPECTED_ASSET_GROUPS, spawnedGroups))
  end
  if spawnedUnits ~= EXPECTED_UNITS then
    fail(string.format("SPAWNED_UNIT_COUNT_MISMATCH expected=%d actual=%d", EXPECTED_UNITS, spawnedUnits))
  end

  table.sort(terminalIDs)
  if violations == 0 then
    log(string.format(
      "RESULT status=PASS_CONTROLLED_PARKING airbase=%s airbaseID=%d squadron=%s template=%s assetGroups=%d units=%d terminalIDs=%s airwingParkingRestricted=true nativeWarehouseSelfRequest=true commander=false auftrag=false opstransport=false directSpawn=false campaignStateMutation=false",
      EXPECTED_AIRBASE,
      EXPECTED_AIRBASE_ID,
      EXPECTED_SQUADRON,
      EXPECTED_TEMPLATE,
      spawnedGroups,
      spawnedUnits,
      table.concat(terminalIDs, ",")
    ))
  else
    log(string.format(
      "RESULT status=FAIL_CONTROLLED_PARKING violations=%d requestIssued=%s spawnedGroups=%d spawnedUnits=%d terminalIDs=%s",
      violations,
      tostring(requestIssued),
      spawnedGroups,
      spawnedUnits,
      table.concat(terminalIDs, ",")
    ))
  end
end

local function inspectGroups(state, groupset)
  if not groupset or not groupset.ForEachGroup then
    fail("SELF_REQUEST_GROUPSET_INVALID")
    finish(0, 0, {})
    return
  end

  local allowed = toSet(EXPECTED_PARKING_IDS)
  local terminalSeen = {}
  local spawnedGroups = 0
  local spawnedUnits = 0
  local terminalIDs = {}

  groupset:ForEachGroup(function(group)
    spawnedGroups = spawnedGroups + 1
    local groupName = tostring(group:GetName())
    local alive = group:IsAlive() == true
    local airborne = group:IsAirborne() == true
    local onGround = group:AllOnGround() == true

    if not alive then
      fail("SPAWNED_GROUP_NOT_ALIVE group=" .. groupName)
    end
    if airborne then
      fail("SPAWNED_GROUP_AIRBORNE group=" .. groupName)
    end
    if not onGround then
      fail("SPAWNED_GROUP_NOT_ALL_ON_GROUND group=" .. groupName)
    end

    local units = group:GetUnits() or {}
    log(string.format(
      "GROUP_SPAWNED group=%s units=%d alive=%s airborne=%s allOnGround=%s",
      groupName,
      #units,
      tostring(alive),
      tostring(airborne),
      tostring(onGround)
    ))

    for _, unit in ipairs(units) do
      spawnedUnits = spawnedUnits + 1
      local unitName = tostring(unit:GetName())
      local unitType = tostring(unit:GetTypeName())
      local coordinate = unit:GetCoordinate()
      local _, terminalID, distanceM = coordinate and coordinate:GetClosestParkingSpot(state.Airbase, nil, nil) or nil, nil, nil

      -- Lua multiple-return values cannot be preserved by the conditional above.
      if coordinate then
        local _, resolvedTerminalID, resolvedDistanceM = coordinate:GetClosestParkingSpot(state.Airbase, nil, nil)
        terminalID = tonumber(resolvedTerminalID)
        distanceM = tonumber(resolvedDistanceM)
      end

      local parkingAllowed = terminalID and allowed[terminalID] == true or false
      if not terminalID then
        fail("SPAWNED_UNIT_TERMINAL_UNRESOLVED unit=" .. unitName)
      else
        terminalIDs[#terminalIDs + 1] = terminalID
        if not parkingAllowed then
          fail(string.format("SPAWNED_UNIT_NOT_ON_AH64_POOL unit=%s terminalID=%d", unitName, terminalID))
        end
        if terminalSeen[terminalID] then
          fail(string.format("DUPLICATE_TERMINAL_ASSIGNMENT terminalID=%d unit=%s", terminalID, unitName))
        end
        terminalSeen[terminalID] = true
      end

      if not distanceM or distanceM > MAX_NODE_DISTANCE_M then
        fail(string.format(
          "SPAWNED_UNIT_NODE_DISTANCE_EXCEEDED unit=%s terminalID=%s max=%d actual=%s",
          unitName,
          tostring(terminalID),
          MAX_NODE_DISTANCE_M,
          distanceM and string.format("%.3f", distanceM) or "nil"
        ))
      end

      log(string.format(
        "UNIT_PARKED group=%s unit=%s type=%s terminalID=%s parkingAllowed=%s distanceM=%.3f",
        groupName,
        unitName,
        unitType,
        tostring(terminalID),
        tostring(parkingAllowed),
        tonumber(distanceM) or -1
      ))
    end
  end)

  finish(spawnedGroups, spawnedUnits, terminalIDs)
end

local function run()
  local state = OMW and OMW.AirOps and OMW.AirOps.Shindand or nil
  if not state or not state.Airwing or not state.Airbase or not state.Squadrons then
    error("Shindand foundation state is unavailable")
  end
  if state.Status ~= "RUNNING" then
    error("Shindand foundation is not RUNNING: " .. tostring(state.Status))
  end
  if not WAREHOUSE or not WAREHOUSE.Descriptor or not WAREHOUSE.Descriptor.GROUPNAME then
    error("Pinned MOOSE WAREHOUSE group descriptor is unavailable")
  end
  if not SCHEDULER then
    error("Pinned MOOSE SCHEDULER is unavailable")
  end
  if state.Airbase:GetName() ~= EXPECTED_AIRBASE or tonumber(state.Airbase:GetID()) ~= EXPECTED_AIRBASE_ID then
    error("Shindand Heliport identity mismatch")
  end

  local squadron = state.Squadrons.AH64D
  if not squadron or tostring(squadron.name) ~= EXPECTED_SQUADRON then
    error("Shindand AH-64 SQUADRON binding mismatch")
  end
  if tostring(squadron.templatename) ~= EXPECTED_TEMPLATE then
    error("Shindand AH-64 template binding mismatch: " .. tostring(squadron.templatename))
  end

  local airwing = state.Airwing
  if not airwing.SetParkingIDs then
    error("Pinned MOOSE AIRWING:SetParkingIDs is unavailable")
  end

  airwing:SetParkingIDs(EXPECTED_PARKING_IDS)
  if not sameNumericSet(airwing.parkingIDs, EXPECTED_PARKING_IDS) then
    error("AIRWING parking-ID restriction did not persist")
  end

  log("AIRWING_PARKING_IDS_UPDATED terminalIDs=" .. table.concat(EXPECTED_PARKING_IDS, ","))

  local previousSelfRequest = airwing.OnAfterSelfRequest
  function airwing:OnAfterSelfRequest(From, Event, To, groupset, request)
    if previousSelfRequest then
      pcall(previousSelfRequest, self, From, Event, To, groupset, request)
    end

    local assignment = getAssignment(self, request)
    if assignment ~= ASSIGNMENT then
      log("SELF_REQUEST_IGNORED assignment=" .. tostring(assignment))
      return
    end

    log("SELF_REQUEST_FULFILLED assignment=" .. assignment)
    inspectGroups(state, groupset)
  end

  local ok, result = pcall(function()
    return airwing:AddRequest(
      airwing,
      WAREHOUSE.Descriptor.GROUPNAME,
      EXPECTED_TEMPLATE,
      EXPECTED_ASSET_GROUPS,
      nil,
      nil,
      1,
      ASSIGNMENT
    )
  end)
  requestIssued = ok
  if not ok then
    error("WAREHOUSE self-request failed: " .. tostring(result))
  end

  log(string.format(
    "REQUEST_ISSUED template=%s assetGroups=%d expectedUnits=%d assignment=%s commander=false auftrag=false opstransport=false directSpawn=false campaignStateMutation=false",
    EXPECTED_TEMPLATE,
    EXPECTED_ASSET_GROUPS,
    EXPECTED_UNITS,
    ASSIGNMENT
  ))

  SCHEDULER:New(nil, function()
    if not completed then
      fail("SELF_REQUEST_TIMEOUT")
      finish(0, 0, {})
    end
  end, {}, TIMEOUT_S)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
    finish(0, 0, {})
  end
end, {}, START_DELAY_S)
