-- Operation Mountain Watch - Shindand G5 AH-64 Jalalabad-style parking acceptance test.
--
-- Owner parking rule under test:
--   * AH-64 reserved pool is exclusive to AH-64.
--   * UH-60 and CH-47 reserved pools are forbidden to AH-64.
--   * shared free pool ME 11-19 and 20-27 may be used by any AI helicopter type.
--   * all other confirmed Shindand Heliport terminals remain unavailable for this gate.
--
-- Jalalabad pattern retained:
--   * SQUADRON parking IDs remain the type-specific preferred/reserved pool.
--   * AIRBASE blacklist constrains globally forbidden parking for this isolated test.
--   * AIRWING:SetSafeParkingOn() is configured.
--   * no AIRWING:SetParkingIDs() type restriction is used.
--
-- Public MOOSE path only. No COMMANDER, AUFTRAG, OPSTRANSPORT, direct SPAWN,
-- native DCS group creation, CampaignState mutation or MOOSE override.

local TAG = "[OMW][AirOps.SHND.G5.AH64Parking]"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_AIRBASE_ID = 14
local EXPECTED_SQUADRON = "SQ_US_SHND_AH64D_ATTACK"
local EXPECTED_TEMPLATE = "TPL_AIR_US_SHND_AH64D_CAS_2SHIP"

local AH64_RESERVED_IDS = { 21, 3, 34, 15 }
local SHARED_FREE_IDS = { 0, 16, 24, 33, 14, 25, 42, 27, 22, 39, 38, 5, 29, 11, 26, 40, 9 }
local FORBIDDEN_OTHER_TYPE_IDS = { 41, 18, 13, 20, 19, 30, 10, 23 }
local ALLOWED_IDS = { 21, 3, 34, 15, 0, 16, 24, 33, 14, 25, 42, 27, 22, 39, 38, 5, 29, 11, 26, 40, 9 }

local EXPECTED_ASSET_GROUPS = 1
local EXPECTED_UNITS = 2
local MAX_NODE_DISTANCE_M = 12
local ASSIGNMENT = "OMW_SHND_G5_AH64_JALALABAD_STYLE_PARKING"
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

local function buildBlacklist(airbase)
  local allowedSet = toSet(ALLOWED_IDS)
  local forbiddenSet = toSet(FORBIDDEN_OTHER_TYPE_IDS)
  local spots = airbase:GetParkingSpotsTable() or {}
  local seen = {}
  local allIDs = {}
  local blockedIDs = {}

  for _, spot in ipairs(spots) do
    local terminalID = tonumber(spot.TerminalID)
    if terminalID and not seen[terminalID] then
      seen[terminalID] = true
      allIDs[#allIDs + 1] = terminalID
      if not allowedSet[terminalID] then
        blockedIDs[#blockedIDs + 1] = terminalID
      end
    end
  end

  for _, terminalID in ipairs(ALLOWED_IDS) do
    if not seen[terminalID] then
      error("Allowed TerminalID missing from Shindand Heliport parking table: " .. tostring(terminalID))
    end
  end
  for terminalID in pairs(forbiddenSet) do
    if allowedSet[terminalID] then
      error("Parking contract overlap with other-type reserved TerminalID: " .. tostring(terminalID))
    end
  end

  table.sort(allIDs)
  table.sort(blockedIDs)
  return allIDs, blockedIDs
end

local function finish(spawnedGroups, spawnedUnits, terminalIDs, reservedCount, sharedCount)
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
      "RESULT status=PASS_JALALABAD_STYLE_PARKING assetGroups=%d units=%d terminalIDs=%s ah64ReservedUsed=%d sharedFreeUsed=%d otherTypeReservedUsed=0 squadronParkingPreserved=true airwingParkingRestriction=false safeParkingConfigured=true nativeWarehouseSelfRequest=true commander=false auftrag=false opstransport=false directSpawn=false mooseOverride=false campaignStateMutation=false",
      spawnedGroups,
      spawnedUnits,
      table.concat(terminalIDs, ","),
      reservedCount,
      sharedCount
    ))
  else
    log(string.format(
      "RESULT status=FAIL_JALALABAD_STYLE_PARKING violations=%d requestIssued=%s spawnedGroups=%d spawnedUnits=%d terminalIDs=%s ah64ReservedUsed=%d sharedFreeUsed=%d",
      violations,
      tostring(requestIssued),
      spawnedGroups,
      spawnedUnits,
      table.concat(terminalIDs, ","),
      reservedCount,
      sharedCount
    ))
  end
end

local function inspectGroups(state, groupset)
  if not groupset or not groupset.ForEachGroup then
    fail("SELF_REQUEST_GROUPSET_INVALID")
    finish(0, 0, {}, 0, 0)
    return
  end

  local ah64Reserved = toSet(AH64_RESERVED_IDS)
  local sharedFree = toSet(SHARED_FREE_IDS)
  local forbiddenOtherType = toSet(FORBIDDEN_OTHER_TYPE_IDS)
  local terminalSeen = {}
  local spawnedGroups = 0
  local spawnedUnits = 0
  local terminalIDs = {}
  local reservedCount = 0
  local sharedCount = 0

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
        reservedCount = reservedCount + 1
      elseif terminalID and sharedFree[terminalID] then
        category = "SHARED_FREE"
        sharedCount = sharedCount + 1
      elseif terminalID and forbiddenOtherType[terminalID] then
        category = "OTHER_TYPE_RESERVED"
        fail(string.format("SPAWNED_UNIT_ON_OTHER_TYPE_RESERVED unit=%s terminalID=%d", unitName, terminalID))
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

  finish(spawnedGroups, spawnedUnits, terminalIDs, reservedCount, sharedCount)
end

local function run()
  local state = OMW and OMW.AirOps and OMW.AirOps.Shindand or nil
  if not state or not state.Airwing or not state.Airbase or not state.Squadrons then
    error("Shindand foundation state is unavailable")
  end
  if state.Status ~= "RUNNING" then
    error("Shindand foundation is not RUNNING: " .. tostring(state.Status))
  end
  if state.Airbase:GetName() ~= EXPECTED_AIRBASE or tonumber(state.Airbase:GetID()) ~= EXPECTED_AIRBASE_ID then
    error("Shindand Heliport identity mismatch")
  end
  if not WAREHOUSE or not WAREHOUSE.Descriptor or not WAREHOUSE.Descriptor.GROUPNAME or not SCHEDULER then
    error("Required pinned MOOSE parking/request APIs are unavailable")
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

  local airwing = state.Airwing
  if not state.Airbase.SetParkingSpotBlacklist or not airwing.SetSafeParkingOn then
    error("Required public MOOSE Jalalabad-style parking methods are unavailable")
  end

  local allIDs, blockedIDs = buildBlacklist(state.Airbase)
  state.Airbase:SetParkingSpotBlacklist(blockedIDs)
  airwing:SetSafeParkingOn()

  if airwing.safeparking ~= true then
    error("AIRWING safe-parking configuration did not persist")
  end

  log(string.format(
    "PARKING_RULE_APPLIED totalNodes=%d allowed=%d blocked=%d ah64Reserved=%d sharedFree=%d forbiddenOtherType=%d squadronParkingPreserved=true airwingParkingRestriction=false safeParkingConfigured=true",
    #allIDs,
    #ALLOWED_IDS,
    #blockedIDs,
    #AH64_RESERVED_IDS,
    #SHARED_FREE_IDS,
    #FORBIDDEN_OTHER_TYPE_IDS
  ))

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

  log(string.format("REQUEST_ISSUED template=%s assetGroups=%d expectedUnits=%d assignment=%s", EXPECTED_TEMPLATE, EXPECTED_ASSET_GROUPS, EXPECTED_UNITS, ASSIGNMENT))

  SCHEDULER:New(nil, function()
    if not completed then
      fail("SELF_REQUEST_TIMEOUT")
      finish(0, 0, {}, 0, 0)
    end
  end, {}, TIMEOUT_S)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
    finish(0, 0, {}, 0, 0)
  end
end, {}, START_DELAY_S)
