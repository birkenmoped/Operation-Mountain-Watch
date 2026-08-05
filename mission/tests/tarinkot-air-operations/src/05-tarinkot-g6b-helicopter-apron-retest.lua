-- Operation Mountain Watch - Tarinkot G6B helicopter-apron combined retest.
--
-- One DCS run validates AH-64, UH-60 and CH-47 placement together.
-- Only AIRBASE.TerminalType.HelicopterOnly is accepted. OpenBig/general-apron
-- parking is rejected even though MOOSE classifies it as helicopter-usable.
--
-- Exact MOOSE 2.9.18 path:
--   SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
--
-- AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER and OPSTRANSPORT remain
-- outside this gate. No productive parking list or MIZ state is modified.

local TAG = "[OMW][AirOps.TKOT.G6B.HELOAPRON]"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G6B_HELOAPRON_BUILD or {}
local config = OMW_TKOT_G6B_HELOAPRON_CONFIG or {}

local EXPECTED = {
  AirbaseID = 9,
  ParkingCount = 33,
  TerminalTypeName = "HelicopterOnly",
  ClientTerminalIDs = {
    [3] = "CLIENT_US_TKOT_CH47F_01",
    [8] = "CLIENT_US_TKOT_AH64D_02",
    [20] = "CLIENT_US_TKOT_AH64D_01"
  },
  ClientUnits = {
    "CLIENT_US_TKOT_AH64D_01_UNIT_01",
    "CLIENT_US_TKOT_AH64D_02_UNIT_01",
    "CLIENT_US_TKOT_CH47F_01_UNIT_01"
  }
}

local state = {
  Airbase = nil,
  ParkingByID = {},
  Spawned = {},
  Spawners = {},
  SpawnCalls = 0,
  Finalized = false
}

local function safe(label, callback)
  local ok, a, b, c = pcall(callback)
  if not ok then
    log("ERROR label=" .. tostring(label) .. " exception=" .. tostring(a))
    return nil, nil, nil, false
  end
  return a, b, c, true
end

local function join(values)
  local labels = {}
  for _, value in ipairs(values or {}) do
    labels[#labels + 1] = tostring(value)
  end
  return #labels > 0 and table.concat(labels, ",") or "none"
end

local function distance2D(left, right)
  local a = left and left:GetVec3() or nil
  local b = right and right:GetVec3() or nil
  if not a or not b then return nil end
  local dx = (a.x or 0) - (b.x or 0)
  local dz = (a.z or 0) - (b.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function activePlayerClientCount()
  local count = 0
  for _, unitName in ipairs(EXPECTED.ClientUnits) do
    local unit = UNIT and UNIT:FindByName(unitName) or nil
    if unit then
      local playerName = safe("GET_PLAYER_NAME_" .. unitName, function()
        return unit:GetPlayerName()
      end)
      if playerName and tostring(playerName) ~= "" then
        count = count + 1
        log("ACTIVE_PLAYER_CLIENT unit=" .. unitName .. " player=" .. tostring(playerName))
      end
    end
  end
  log("ACTIVE_PLAYER_CLIENT_COUNT=" .. tostring(count))
  return count
end

local function configuredCounts()
  local families, groups, units = 0, 0, 0
  for _, family in ipairs(config.Families or {}) do
    families = families + 1
    groups = groups + #(family.SpawnRequests or {})
    units = units + (tonumber(family.ExpectedTotalUnits) or 0)
  end
  return families, groups, units
end

local function finish(status, reason, groupsFound, unitsFound, placementFailures, familyFailures)
  if state.Finalized then return end
  state.Finalized = true
  local expectedFamilies, expectedGroups, expectedUnits = configuredCounts()
  log(string.format(
    "RESULT G6B_HELICOPTER_APRON_COMBINED status=%s reason=%s expectedFamilies=%d expectedGroups=%d groupsFound=%d expectedUnits=%d unitsFound=%d placementFailures=%d familyFailures=%d activePlayerClients=%d spawnCalls=%d expectedTerminalType=%s visualConfirmationRequired=true",
    tostring(status), tostring(reason or "none"), expectedFamilies, expectedGroups,
    tonumber(groupsFound) or 0, expectedUnits, tonumber(unitsFound) or 0,
    tonumber(placementFailures) or 0, tonumber(familyFailures) or 0,
    activePlayerClientCount(), state.SpawnCalls, EXPECTED.TerminalTypeName
  ))
end

local function preflight()
  log("BEGIN Tarinkot G6B helicopter-apron combined retest")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder), tostring(build.BuilderVersion),
    tostring(build.GitCommit), tostring(build.GeneratedUtc)
  ))
  log("MUTATION_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_LIST_MUTATION=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0 RANDOMIZATION=0")
  log("SPAWN_PATH method=SPAWN:SpawnAtParkingSpot takeoff=SPAWN.Takeoff.Cold aiOff=true")

  if not AIRBASE or not AIRBASE.TerminalType or not SPAWN or not GROUP or not UNIT then
    finish("FAIL_PREFLIGHT", "MOOSE_CLASS_UNAVAILABLE", 0, 0, 0, 0)
    return false
  end

  local helicopterOnly = tonumber(AIRBASE.TerminalType.HelicopterOnly)
  log("APRON_CONTRACT expectedTerminalTypeName=HelicopterOnly expectedTerminalTypeValue=" .. tostring(helicopterOnly) .. " openBigRejected=true")
  if helicopterOnly ~= 40 then
    finish("FAIL_PREFLIGHT", "UNEXPECTED_HELICOPTER_ONLY_CONSTANT", 0, 0, 0, 0)
    return false
  end

  local expectedFamilies, expectedGroups, expectedUnits = configuredCounts()
  if expectedFamilies ~= 3 or expectedGroups ~= 4 or expectedUnits ~= 5 then
    finish("FAIL_PREFLIGHT", "CONFIGURATION_COUNT_MISMATCH", 0, 0, 0, 0)
    return false
  end

  if activePlayerClientCount() > 0 then
    finish("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT", 0, 0, 0, 0)
    return false
  end

  local airbase = AIRBASE:FindByID(EXPECTED.AirbaseID)
  if not airbase then
    finish("FAIL_PREFLIGHT", "AIRBASE_ID_NOT_FOUND", 0, 0, 0, 0)
    return false
  end
  state.Airbase = airbase

  local parking = airbase:GetParkingSpotsTable() or {}
  for _, spot in ipairs(parking) do
    state.ParkingByID[tonumber(spot.TerminalID)] = spot
  end
  log(string.format("AIRBASE name=%s id=%s parkingCount=%d expectedParkingCount=%d",
    tostring(airbase:GetName()), tostring(airbase:GetID()), #parking, EXPECTED.ParkingCount))

  if #parking ~= EXPECTED.ParkingCount then
    finish("FAIL_PREFLIGHT", "PARKING_COUNT_MISMATCH", 0, 0, 0, 0)
    return false
  end

  local seenFamilies = {}
  local seenTerminals = {}

  for _, family in ipairs(config.Families or {}) do
    if not family.Key or seenFamilies[family.Key] then
      finish("FAIL_PREFLIGHT", "DUPLICATE_OR_MISSING_FAMILY_KEY", 0, 0, 0, 0)
      return false
    end
    seenFamilies[family.Key] = true

    if not family.TemplateGroup or not family.ExpectedType or not family.ModelRadiusM or
       not family.ExpectedTotalUnits or not family.SpawnRequests then
      finish("FAIL_PREFLIGHT", "FAMILY_CONFIGURATION_INCOMPLETE_" .. tostring(family.Key), 0, 0, 0, 0)
      return false
    end

    if not GROUP:FindByName(family.TemplateGroup) then
      finish("FAIL_PREFLIGHT", "TEMPLATE_GROUP_NOT_FOUND_" .. tostring(family.Key), 0, 0, 0, 0)
      return false
    end

    local familyUnits = 0
    log(string.format("FAMILY_CONFIG family=%s template=%s expectedType=%s expectedGroups=%d expectedUnits=%d modelRadiusM=%.3f",
      tostring(family.Key), tostring(family.TemplateGroup), tostring(family.ExpectedType),
      #(family.SpawnRequests or {}), tonumber(family.ExpectedTotalUnits), tonumber(family.ModelRadiusM)))

    for requestIndex, request in ipairs(family.SpawnRequests or {}) do
      local spots = request.Spots or {}
      local requestUnits = tonumber(request.ExpectedUnits) or #spots
      familyUnits = familyUnits + requestUnits
      log(string.format("REQUEST family=%s index=%d alias=%s terminalIDs=%s expectedUnits=%d",
        tostring(family.Key), requestIndex, tostring(request.Alias), join(spots), requestUnits))

      if #spots ~= requestUnits then
        finish("FAIL_PREFLIGHT", "REQUEST_SPOT_UNIT_COUNT_MISMATCH_" .. tostring(family.Key), 0, 0, 0, 0)
        return false
      end

      for _, terminalValue in ipairs(spots) do
        local terminalID = tonumber(terminalValue)
        local spot = terminalID and state.ParkingByID[terminalID] or nil
        if not terminalID or not spot then
          finish("FAIL_PREFLIGHT", "REQUESTED_TERMINAL_NOT_FOUND_" .. tostring(terminalValue), 0, 0, 0, 0)
          return false
        end
        if seenTerminals[terminalID] then
          finish("FAIL_PREFLIGHT", "DUPLICATE_REQUESTED_TERMINAL_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        seenTerminals[terminalID] = family.Key
        if EXPECTED.ClientTerminalIDs[terminalID] then
          finish("FAIL_PREFLIGHT", "CLIENT_TERMINAL_REQUESTED_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        if spot.Free ~= true or spot.TOAC == true then
          finish("FAIL_PREFLIGHT", "TERMINAL_NOT_FREE_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        if tonumber(spot.TerminalType) ~= helicopterOnly then
          finish("FAIL_PREFLIGHT", "TERMINAL_NOT_HELICOPTER_ONLY_" .. tostring(terminalID) .. "_TYPE_" .. tostring(spot.TerminalType), 0, 0, 0, 0)
          return false
        end
        local vec = spot.Coordinate and spot.Coordinate:GetVec3() or nil
        log(string.format("TERMINAL_READY family=%s id=%d type=%s typeName=HelicopterOnly free=%s toac=%s coordinateX=%.3f coordinateZ=%.3f",
          tostring(family.Key), terminalID, tostring(spot.TerminalType), tostring(spot.Free),
          tostring(spot.TOAC), tonumber(vec and vec.x) or -1, tonumber(vec and vec.z) or -1))
      end
    end

    if familyUnits ~= tonumber(family.ExpectedTotalUnits) then
      finish("FAIL_PREFLIGHT", "FAMILY_EXPECTED_UNIT_COUNT_MISMATCH_" .. tostring(family.Key), 0, 0, 0, 0)
      return false
    end
  end

  log("PREFLIGHT status=PASS families=3 groups=4 units=5 terminals=5 terminalType=40")
  return true
end

local function inspect()
  if state.Finalized then return end
  if activePlayerClientCount() > 0 then
    finish("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT_DURING_INSPECTION", #state.Spawned, 0, 0, 0)
    return
  end

  local expectedFamilies, expectedGroups, expectedUnits = configuredCounts()
  local groupsFound, unitsFound, placementFailures, familyFailures = 0, 0, 0, 0
  local stats = {}
  for _, family in ipairs(config.Families or {}) do
    stats[family.Key] = {
      ExpectedGroups = #(family.SpawnRequests or {}), ExpectedUnits = tonumber(family.ExpectedTotalUnits),
      GroupsFound = 0, UnitsFound = 0, PlacementFailures = 0
    }
  end

  for _, item in ipairs(state.Spawned) do
    local family, request, group = item.Family, item.Request, item.Group
    local familyStats = stats[family.Key]
    local units = safe("GET_UNITS_" .. family.Key .. "_" .. item.RequestIndex, function()
      return group:GetUnits()
    end) or {}
    groupsFound = groupsFound + 1
    familyStats.GroupsFound = familyStats.GroupsFound + 1

    if #units ~= tonumber(request.ExpectedUnits) then
      placementFailures = placementFailures + 1
      familyStats.PlacementFailures = familyStats.PlacementFailures + 1
      log(string.format("PLACEMENT_VIOLATION family=%s request=%d reason=UNIT_COUNT expected=%d actual=%d",
        family.Key, item.RequestIndex, tonumber(request.ExpectedUnits), #units))
    end

    local assigned = {}
    for _, unit in ipairs(units) do
      unitsFound = unitsFound + 1
      familyStats.UnitsFound = familyStats.UnitsFound + 1
      local coord = safe("GET_COORDINATE_" .. unit:GetName(), function() return unit:GetCoordinate() end)
      local alive = safe("GET_ALIVE_" .. unit:GetName(), function() return unit:IsAlive() end)
      local typeName = safe("GET_TYPE_" .. unit:GetName(), function() return unit:GetTypeName() end)
      local nearestID, nearestDistance = nil, nil

      for _, terminalValue in ipairs(request.Spots or {}) do
        local terminalID = tonumber(terminalValue)
        if terminalID and not assigned[terminalID] then
          local spot = state.ParkingByID[terminalID]
          local distance = spot and distance2D(coord, spot.Coordinate) or nil
          if distance and (not nearestDistance or distance < nearestDistance) then
            nearestID, nearestDistance = terminalID, distance
          end
        end
      end

      local accepted = alive == true and tostring(typeName) == tostring(family.ExpectedType) and
        nearestID ~= nil and nearestDistance ~= nil and nearestDistance <= tonumber(family.ModelRadiusM)
      if nearestID then assigned[nearestID] = true end
      if not accepted then
        placementFailures = placementFailures + 1
        familyStats.PlacementFailures = familyStats.PlacementFailures + 1
      end

      log(string.format("UNIT_PLACEMENT family=%s request=%d group=%s unit=%s type=%s alive=%s assignedTerminalID=%s terminalType=40 centerDistanceM=%.3f allowedDistanceM=%.3f accepted=%s",
        family.Key, item.RequestIndex, tostring(group:GetName()), tostring(unit:GetName()), tostring(typeName),
        tostring(alive), tostring(nearestID or "none"), tonumber(nearestDistance) or -1,
        tonumber(family.ModelRadiusM), tostring(accepted)))
    end

    for _, terminalValue in ipairs(request.Spots or {}) do
      local terminalID = tonumber(terminalValue)
      if terminalID and not assigned[terminalID] then
        placementFailures = placementFailures + 1
        familyStats.PlacementFailures = familyStats.PlacementFailures + 1
        log(string.format("PLACEMENT_VIOLATION family=%s request=%d reason=TERMINAL_UNASSIGNED terminalID=%d",
          family.Key, item.RequestIndex, terminalID))
      end
    end
  end

  for _, family in ipairs(config.Families or {}) do
    local familyStats = stats[family.Key]
    local familyPass = familyStats.GroupsFound == familyStats.ExpectedGroups and
      familyStats.UnitsFound == familyStats.ExpectedUnits and familyStats.PlacementFailures == 0
    if not familyPass then familyFailures = familyFailures + 1 end
    log(string.format("FAMILY_RESULT family=%s status=%s expectedGroups=%d groupsFound=%d expectedUnits=%d unitsFound=%d placementFailures=%d visualConfirmationRequired=true",
      family.Key, familyPass and "PASS_RUNTIME_PLACEMENT" or "FAIL_RUNTIME_PLACEMENT",
      familyStats.ExpectedGroups, familyStats.GroupsFound, familyStats.ExpectedUnits,
      familyStats.UnitsFound, familyStats.PlacementFailures))
  end

  local status, reason = "PASS_RUNTIME_PLACEMENT", "none"
  if groupsFound ~= expectedGroups then status, reason = "FAIL_PLACEMENT", "GROUP_COUNT_MISMATCH"
  elseif unitsFound ~= expectedUnits then status, reason = "FAIL_PLACEMENT", "UNIT_COUNT_MISMATCH"
  elseif placementFailures > 0 or familyFailures > 0 then status, reason = "FAIL_PLACEMENT", "PLACEMENT_VIOLATIONS" end

  log("VISUAL_CONFIRMATION_REQUIRED combined=true checks=all_five_on_designated_helicopter_apron,no_overlap,no_static_contact,no_revetment_contact,on_prepared_surface,rotor_clearance")
  finish(status, reason, groupsFound, unitsFound, placementFailures, familyFailures)
end

local function spawnAll()
  if state.Finalized then return end
  if activePlayerClientCount() > 0 then
    finish("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT_BEFORE_SPAWN", 0, 0, 0, 0)
    return
  end

  local groupsSpawned = 0
  for _, family in ipairs(config.Families or {}) do
    for requestIndex, request in ipairs(family.SpawnRequests or {}) do
      local expectedUnits = tonumber(request.ExpectedUnits) or #(request.Spots or {})
      local spawner = SPAWN:NewWithAlias(family.TemplateGroup, request.Alias)
      if not spawner then
        finish("FAIL_SPAWN", "SPAWNER_CONSTRUCTION_FAILED_" .. family.Key .. "_" .. requestIndex, groupsSpawned, 0, 0, 0)
        return
      end
      state.Spawners[#state.Spawners + 1] = spawner
      spawner:InitLimit(expectedUnits, 1)
      spawner:InitAIOff()
      state.SpawnCalls = state.SpawnCalls + 1
      local group = spawner:SpawnAtParkingSpot(state.Airbase, request.Spots, SPAWN.Takeoff.Cold)
      if not group then
        finish("FAIL_SPAWN", "SPAWN_RETURNED_NIL_" .. family.Key .. "_" .. requestIndex, groupsSpawned, 0, 0, 0)
        return
      end
      groupsSpawned = groupsSpawned + 1
      state.Spawned[#state.Spawned + 1] = {
        Family = family, Request = request, RequestIndex = requestIndex, Group = group
      }
      local units = safe("GET_UNITS_AFTER_SPAWN_" .. family.Key .. "_" .. requestIndex, function()
        return group:GetUnits()
      end) or {}
      log(string.format("SPAWNED family=%s request=%d alias=%s group=%s terminalIDs=%s terminalType=40 unitsReported=%d aiEnabled=false",
        family.Key, requestIndex, tostring(request.Alias), tostring(group:GetName()), join(request.Spots), #units))
    end
  end

  log("SPAWN_PHASE status=PASS groupsSpawned=" .. tostring(groupsSpawned) .. " spawnCalls=" .. tostring(state.SpawnCalls))
  if SCHEDULER then SCHEDULER:New(nil, inspect, {}, 8)
  else timer.scheduleFunction(function() inspect() return nil end, nil, timer.getTime() + 8) end
end

local function main()
  if not preflight() then return end
  if SCHEDULER then SCHEDULER:New(nil, spawnAll, {}, 2)
  else timer.scheduleFunction(function() spawnAll() return nil end, nil, timer.getTime() + 2) end
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 12)
else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 12) end
