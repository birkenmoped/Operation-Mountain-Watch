-- Operation Mountain Watch - Shindand G6 AH-64 foundation parking observer.
--
-- Purpose: validate physical AH-64 initial placement after the production
-- foundation itself has applied the Jalalabad-style parking preflight before
-- AIRWING creation/start.
--
-- This harness does not change parking configuration. It only:
--   * verifies the already-running foundation parking contract,
--   * issues one native AIRWING/WAREHOUSE self-request for the AH-64 template,
--   * observes the spawned units and classifies their physical parking nodes.
--
-- No AIRBASE blacklist mutation, no AIRWING parking mutation, no safe-parking
-- mutation, no COMMANDER, AUFTRAG, OPSTRANSPORT, direct SPAWN, native DCS group
-- creation, CampaignState mutation or MOOSE override.

local TAG = "[OMW][AirOps.SHND.G6.AH64Parking]"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_AIRBASE_ID = 14
local EXPECTED_SQUADRON = "SQ_US_SHND_AH64D_ATTACK"
local EXPECTED_TEMPLATE = "TPL_AIR_US_SHND_AH64D_CAS_2SHIP"

local AH64_RESERVED_IDS = { 21, 3, 34, 15 }
local SHARED_FREE_IDS = { 0, 16, 24, 33, 14, 25, 42, 27, 22, 39, 38, 5, 29, 11, 26, 40, 9 }
local UH60_RESERVED_IDS = { 41, 18, 13, 20, 19 }
local CH47_RESERVED_IDS = { 30, 10, 23 }

local EXPECTED_ASSET_GROUPS = 1
local EXPECTED_UNITS = 2
local MAX_NODE_DISTANCE_M = 12
local ASSIGNMENT = "OMW_SHND_G6_AH64_FOUNDATION_PARKING_OBSERVER"
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
  if type(actual) ~= "table" then return false end
  local actualSet = {}
  for key, value in pairs(actual) do
    if type(value) == "number" then
      actualSet[tonumber(value)] = true
    elseif value == true and tonumber(key) then
      actualSet[tonumber(key)] = true
    end
  end
  local expectedSet = toSet(expected)
  for value in pairs(expectedSet) do if not actualSet[value] then return false end end
  for value in pairs(actualSet) do if not expectedSet[value] then return false end end
  return true
end

local function getAssignment(airwing, request)
  if airwing and airwing.GetAssignment then
    local ok, value = pcall(function() return airwing:GetAssignment(request) end)
    if ok and value then return tostring(value) end
  end
  if type(request) == "table" then
    return tostring(request.assignment or request.Assignment or "")
  end
  return ""
end

local function finish(spawnedGroups, spawnedUnits, terminalIDs, ah64Count, sharedCount, foreignCount)
  if completed then return end
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
      "RESULT status=PASS_FOUNDATION_PARKING assetGroups=%d units=%d terminalIDs=%s ah64ReservedUsed=%d sharedFreeUsed=%d foreignTypeReservedUsed=%d parkingMutation=false nativeWarehouseSelfRequest=true commander=false auftrag=false opstransport=false directSpawn=false mooseOverride=false campaignStateMutation=false",
      spawnedGroups,
      spawnedUnits,
      table.concat(terminalIDs, ","),
      ah64Count,
      sharedCount,
      foreignCount
    ))
  else
    log(string.format(
      "RESULT status=FAIL_FOUNDATION_PARKING violations=%d requestIssued=%s spawnedGroups=%d spawnedUnits=%d terminalIDs=%s ah64ReservedUsed=%d sharedFreeUsed=%d foreignTypeReservedUsed=%d parkingMutation=false",
      violations,
      tostring(requestIssued),
      spawnedGroups,
      spawnedUnits,
      table.concat(terminalIDs, ","),
      ah64Count,
      sharedCount,
      foreignCount
    ))
  end
end

local function inspectGroups(state, groupset)
  if not groupset or not groupset.ForEachGroup then
    fail("SELF_REQUEST_GROUPSET_INVALID")
    finish(0, 0, {}, 0, 0, 0)
    return
  end

  local ah64Reserved = toSet(AH64_RESERVED_IDS)
  local sharedFree = toSet(SHARED_FREE_IDS)
  local uh60Reserved = toSet(UH60_RESERVED_IDS)
  local ch47Reserved = toSet(CH47_RESERVED_IDS)
  local terminalSeen = {}
  local spawnedGroups = 0
  local spawnedUnits = 0
  local terminalIDs = {}
  local ah64Count = 0
  local sharedCount = 0
  local foreignCount = 0

  groupset:ForEachGroup(function(group)
    spawnedGroups = spawnedGroups + 1
    local groupName = tostring(group:GetName())
    if group:IsAlive() ~= true then fail("SPAWNED_GROUP_NOT_ALIVE group=" .. groupName) end
    if group:IsAirborne() == true then fail("SPAWNED_GROUP_AIRBORNE group=" .. groupName) end
    if group:AllOnGround() ~= true then fail("SPAWNED_GROUP_NOT_ALL_ON_GROUND group=" .. groupName) end

    local units = group:GetUnits() or {}
    log(string.format("GROUP_SPAWNED group=%s units=%d", groupName, #units))

    for _, unit in ipairs(units) do
      spawnedUnits = spawnedUnits + 1
      local unitName = tostring(unit:GetName())
      local unitType = tostring(unit:GetTypeName())
      local coordinate = unit:GetCoordinate()
      local terminalID = nil
      local distanceM = nil

      if coordinate then
        local _, resolvedTerminalID, resolvedDistanceM = coordinate:GetClosestParkingSpot(state.Airbase, nil, nil)
        terminalID = tonumber(resolvedTerminalID)
        distanceM = tonumber(resolvedDistanceM)
      end

      local category = "INVALID"
      if terminalID and ah64Reserved[terminalID] then
        category = "AH64_RESERVED"
        ah64Count = ah64Count + 1
      elseif terminalID and sharedFree[terminalID] then
        category = "SHARED_FREE"
        sharedCount = sharedCount + 1
      elseif terminalID and uh60Reserved[terminalID] then
        category = "UH60_RESERVED"
        foreignCount = foreignCount + 1
        fail(string.format("SPAWNED_UNIT_ON_UH60_RESERVED unit=%s terminalID=%d", unitName, terminalID))
      elseif terminalID and ch47Reserved[terminalID] then
        category = "CH47_RESERVED"
        foreignCount = foreignCount + 1
        fail(string.format("SPAWNED_UNIT_ON_CH47_RESERVED unit=%s terminalID=%d", unitName, terminalID))
      elseif terminalID then
        category = "UNALLOCATED"
        fail(string.format("SPAWNED_UNIT_ON_UNALLOCATED_TERMINAL unit=%s terminalID=%d", unitName, terminalID))
      else
        fail("SPAWNED_UNIT_TERMINAL_UNRESOLVED unit=" .. unitName)
      end

      if terminalID then
        terminalIDs[#terminalIDs + 1] = terminalID
        if terminalSeen[terminalID] then
          fail(string.format("DUPLICATE_TERMINAL_ASSIGNMENT terminalID=%d unit=%s", terminalID, unitName))
        end
        terminalSeen[terminalID] = true
      end

      if unitType ~= "AH-64D_BLK_II" then
        fail(string.format("SPAWNED_TYPE_MISMATCH unit=%s actual=%s", unitName, unitType))
      end
      if not distanceM or distanceM > MAX_NODE_DISTANCE_M then
        fail(string.format("SPAWNED_UNIT_NODE_DISTANCE_EXCEEDED unit=%s terminalID=%s max=%d actual=%s", unitName, tostring(terminalID), MAX_NODE_DISTANCE_M, distanceM and string.format("%.3f", distanceM) or "nil"))
      end

      log(string.format("UNIT_PARKED group=%s unit=%s type=%s terminalID=%s category=%s distanceM=%.3f", groupName, unitName, unitType, tostring(terminalID), category, tonumber(distanceM) or -1))
    end
  end)

  finish(spawnedGroups, spawnedUnits, terminalIDs, ah64Count, sharedCount, foreignCount)
end

local function run()
  local state = OMW and OMW.AirOps and OMW.AirOps.Shindand or nil
  if not state or not state.Airwing or not state.Airbase or not state.Squadrons or not state.Parking then
    error("Shindand foundation state is unavailable")
  end
  if state.Status ~= "RUNNING" then
    error("Shindand foundation is not RUNNING: " .. tostring(state.Status))
  end
  if state.Airbase:GetName() ~= EXPECTED_AIRBASE or tonumber(state.Airbase:GetID()) ~= EXPECTED_AIRBASE_ID then
    error("Shindand Heliport identity mismatch")
  end
  if state.Parking.Pattern ~= "JALALABAD" then
    error("Foundation parking pattern mismatch: " .. tostring(state.Parking.Pattern))
  end
  if state.Parking.AirbaseBlacklistAppliedBeforeAirwingCreation ~= true then
    error("Foundation did not apply AIRBASE blacklist before AIRWING creation")
  end
  if state.Parking.SafeParkingConfiguredBeforeStart ~= true then
    error("Foundation did not configure safe parking before AIRWING start")
  end
  if state.Parking.AirwingParkingRestriction ~= false then
    error("Foundation unexpectedly uses AIRWING parking restriction")
  end
  if not sameNumericSet(state.Parking.SharedFreeTerminalIDs, SHARED_FREE_IDS) then
    error("Foundation shared-free parking contract mismatch")
  end
  if not WAREHOUSE or not WAREHOUSE.Descriptor or not WAREHOUSE.Descriptor.GROUPNAME or not SCHEDULER then
    error("Required pinned MOOSE request APIs are unavailable")
  end

  local squadron = state.Squadrons.AH64D
  if not squadron or tostring(squadron.name) ~= EXPECTED_SQUADRON then
    error("Shindand AH-64 SQUADRON binding mismatch")
  end
  if tostring(squadron.templatename) ~= EXPECTED_TEMPLATE then
    error("Shindand AH-64 template binding mismatch")
  end
  if not sameNumericSet(squadron.parkingIDs, AH64_RESERVED_IDS) then
    error("AH-64 SQUADRON parking IDs no longer match owner-reserved pool")
  end

  log("FOUNDATION_CONTRACT_VERIFIED pattern=JALALABAD parkingMutation=false airbaseBlacklistPreStart=true safeParkingPreStart=true airwingParkingRestriction=false sharedFreeParkingConfigured=true")

  local airwing = state.Airwing
  local previousSelfRequest = airwing.OnAfterSelfRequest
  function airwing:OnAfterSelfRequest(From, Event, To, groupset, request)
    if previousSelfRequest then pcall(previousSelfRequest, self, From, Event, To, groupset, request) end
    local assignment = getAssignment(self, request)
    if assignment ~= ASSIGNMENT then
      log("SELF_REQUEST_IGNORED assignment=" .. tostring(assignment))
      return
    end
    log("SELF_REQUEST_FULFILLED assignment=" .. assignment)
    inspectGroups(state, groupset)
  end

  local ok, result = pcall(function()
    return airwing:AddRequest(airwing, WAREHOUSE.Descriptor.GROUPNAME, EXPECTED_TEMPLATE, EXPECTED_ASSET_GROUPS, nil, nil, 1, ASSIGNMENT)
  end)
  requestIssued = ok
  if not ok then error("WAREHOUSE self-request failed: " .. tostring(result)) end

  log(string.format("REQUEST_ISSUED template=%s assetGroups=%d expectedUnits=%d assignment=%s parkingMutation=false", EXPECTED_TEMPLATE, EXPECTED_ASSET_GROUPS, EXPECTED_UNITS, ASSIGNMENT))

  SCHEDULER:New(nil, function()
    if not completed then
      fail("SELF_REQUEST_TIMEOUT")
      finish(0, 0, {}, 0, 0, 0)
    end
  end, {}, TIMEOUT_S)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
    finish(0, 0, {}, 0, 0, 0)
  end
end, {}, START_DELAY_S)
