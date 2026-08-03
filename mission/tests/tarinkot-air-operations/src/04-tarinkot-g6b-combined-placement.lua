-- Operation Mountain Watch - Tarinkot G6B combined controlled parking placement.
--
-- One DCS run validates all three Tarinkot helicopter families together:
--   AH-64: one two-ship group
--   UH-60: two independent one-ship groups
--   CH-47: one one-ship group
--
-- Exact MOOSE 2.9.18 path:
--   SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
--
-- AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER and OPSTRANSPORT objects are
-- deliberately outside this gate. AI remains disabled after placement.

local TAG = "[OMW][AirOps.TKOT.G6B.COMBINED]"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G6B_COMBINED_BUILD or {}
local config = OMW_TKOT_G6B_COMBINED_CONFIG or {}

local EXPECTED = {
  AirbaseID = 9,
  ParkingCount = 33,
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
  Spawners = {},
  Spawned = {},
  SpawnCalls = 0,
  Finalized = false
}

local function safe(label, callback)
  local ok, resultA, resultB, resultC = pcall(callback)
  if not ok then
    log("ERROR label=" .. tostring(label) .. " exception=" .. tostring(resultA))
    return nil, nil, nil, false
  end
  return resultA, resultB, resultC, true
end

local function join(values)
  local labels = {}
  for _, value in ipairs(values or {}) do labels[#labels + 1] = tostring(value) end
  return #labels > 0 and table.concat(labels, ",") or "none"
end

local function coordinateDistance2D(left, right)
  local leftVec = left and left:GetVec3() or nil
  local rightVec = right and right:GetVec3() or nil
  if not leftVec or not rightVec then return nil end
  local dx = (leftVec.x or 0) - (rightVec.x or 0)
  local dz = (leftVec.z or 0) - (rightVec.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function terminalTypeAccepted(terminalType)
  return AIRBASE and AIRBASE._CheckTerminalType and
    AIRBASE._CheckTerminalType(terminalType, AIRBASE.TerminalType.HelicopterUsable) == true
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

local function countConfigured()
  local families = 0
  local groups = 0
  local units = 0
  for _, family in ipairs(config.Families or {}) do
    families = families + 1
    units = units + (tonumber(family.ExpectedTotalUnits) or 0)
    groups = groups + #(family.SpawnRequests or {})
  end
  return families, groups, units
end

local function result(status, reason, groupsFound, unitsFound, placementFailures, familyFailures)
  if state.Finalized then return end
  state.Finalized = true
  local expectedFamilies, expectedGroups, expectedUnits = countConfigured()
  log(string.format(
    "RESULT G6B_COMBINED_CONTROLLED_PLACEMENT status=%s reason=%s expectedFamilies=%d expectedGroups=%d groupsFound=%d expectedUnits=%d unitsFound=%d placementFailures=%d familyFailures=%d activePlayerClients=%d spawnCalls=%d visualConfirmationRequired=true",
    tostring(status),
    tostring(reason or "none"),
    expectedFamilies,
    expectedGroups,
    tonumber(groupsFound) or 0,
    expectedUnits,
    tonumber(unitsFound) or 0,
    tonumber(placementFailures) or 0,
    tonumber(familyFailures) or 0,
    activePlayerClientCount(),
    state.SpawnCalls
  ))
end

local function preflight()
  log("BEGIN Tarinkot G6B combined controlled placement")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder),
    tostring(build.BuilderVersion),
    tostring(build.GitCommit),
    tostring(build.GeneratedUtc)
  ))
  log("MUTATION_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_LIST_MUTATION=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0 RANDOMIZATION=0")
  log("SPAWN_PATH method=SPAWN:SpawnAtParkingSpot takeoff=SPAWN.Takeoff.Cold aiOff=true")

  if not AIRBASE or not AIRBASE.TerminalType or not SPAWN or not GROUP or not UNIT then
    result("FAIL_PREFLIGHT", "MOOSE_CLASS_UNAVAILABLE", 0, 0, 0, 0)
    return false
  end

  local expectedFamilies, expectedGroups, expectedUnits = countConfigured()
  if expectedFamilies ~= 3 or expectedGroups ~= 4 or expectedUnits ~= 5 then
    result("FAIL_PREFLIGHT", "CONFIGURATION_COUNT_MISMATCH", 0, 0, 0, 0)
    return false
  end

  if activePlayerClientCount() > 0 then
    result("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT", 0, 0, 0, 0)
    return false
  end

  local airbase = AIRBASE:FindByID(EXPECTED.AirbaseID)
  if not airbase then
    result("FAIL_PREFLIGHT", "AIRBASE_ID_NOT_FOUND", 0, 0, 0, 0)
    return false
  end
  state.Airbase = airbase

  local parking = airbase:GetParkingSpotsTable() or {}
  for _, spot in ipairs(parking) do
    state.ParkingByID[tonumber(spot.TerminalID)] = spot
  end

  log(string.format(
    "AIRBASE name=%s id=%s parkingCount=%d expectedParkingCount=%d",
    tostring(airbase:GetName()),
    tostring(airbase:GetID()),
    #parking,
    EXPECTED.ParkingCount
  ))

  if #parking ~= EXPECTED.ParkingCount then
    result("FAIL_PREFLIGHT", "PARKING_COUNT_MISMATCH", 0, 0, 0, 0)
    return false
  end

  local seenFamilyKeys = {}
  local seenTerminalIDs = {}

  for _, family in ipairs(config.Families or {}) do
    if not family.Key or seenFamilyKeys[family.Key] then
      result("FAIL_PREFLIGHT", "DUPLICATE_OR_MISSING_FAMILY_KEY", 0, 0, 0, 0)
      return false
    end
    seenFamilyKeys[family.Key] = true

    if not family.TemplateGroup or not family.ExpectedType or not family.ModelRadiusM or
        not family.ExpectedTotalUnits or not family.SpawnRequests then
      result("FAIL_PREFLIGHT", "FAMILY_CONFIGURATION_INCOMPLETE_" .. tostring(family.Key), 0, 0, 0, 0)
      return false
    end

    if not GROUP:FindByName(family.TemplateGroup) then
      result("FAIL_PREFLIGHT", "TEMPLATE_GROUP_NOT_FOUND_" .. tostring(family.Key), 0, 0, 0, 0)
      return false
    end

    local familyUnits = 0
    log(string.format(
      "FAMILY_CONFIG family=%s template=%s expectedType=%s expectedGroups=%d expectedUnits=%d modelRadiusM=%.3f",
      tostring(family.Key),
      tostring(family.TemplateGroup),
      #(family.SpawnRequests or {}),
      tonumber(family.ExpectedTotalUnits) or -1,
      tonumber(family.ModelRadiusM) or -1
    ))

    for requestIndex, request in ipairs(family.SpawnRequests or {}) do
      local spots = request.Spots or {}
      local requestUnits = tonumber(request.ExpectedUnits) or #spots
      familyUnits = familyUnits + requestUnits

      log(string.format(
        "REQUEST family=%s index=%d alias=%s terminalIDs=%s expectedUnits=%d",
        tostring(family.Key),
        requestIndex,
        tostring(request.Alias),
        join(spots),
        requestUnits
      ))

      if #spots ~= requestUnits then
        result("FAIL_PREFLIGHT", "REQUEST_SPOT_UNIT_COUNT_MISMATCH_" .. tostring(family.Key), 0, 0, 0, 0)
        return false
      end

      for _, terminalIDValue in ipairs(spots) do
        local terminalID = tonumber(terminalIDValue)
        local spot = terminalID and state.ParkingByID[terminalID] or nil
        if not terminalID or not spot then
          result("FAIL_PREFLIGHT", "REQUESTED_TERMINAL_NOT_FOUND_" .. tostring(terminalIDValue), 0, 0, 0, 0)
          return false
        end
        if seenTerminalIDs[terminalID] then
          result("FAIL_PREFLIGHT", "DUPLICATE_REQUESTED_TERMINAL_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        seenTerminalIDs[terminalID] = family.Key
        if EXPECTED.ClientTerminalIDs[terminalID] then
          result("FAIL_PREFLIGHT", "CLIENT_TERMINAL_REQUESTED_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        if spot.Free ~= true or spot.TOAC == true then
          result("FAIL_PREFLIGHT", "TERMINAL_NOT_FREE_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        if not terminalTypeAccepted(spot.TerminalType) then
          result("FAIL_PREFLIGHT", "TERMINAL_TYPE_REJECTED_" .. tostring(terminalID), 0, 0, 0, 0)
          return false
        end
        local vec = spot.Coordinate and spot.Coordinate:GetVec3() or nil
        log(string.format(
          "TERMINAL_READY family=%s id=%d type=%s free=%s toac=%s coordinateX=%.3f coordinateZ=%.3f",
          tostring(family.Key),
          terminalID,
          tostring(spot.TerminalType),
          tostring(spot.Free),
          tostring(spot.TOAC),
          tonumber(vec and vec.x) or -1,
          tonumber(vec and vec.z) or -1
        ))
      end
    end

    if familyUnits ~= tonumber(family.ExpectedTotalUnits) then
      result("FAIL_PREFLIGHT", "FAMILY_EXPECTED_UNIT_COUNT_MISMATCH_" .. tostring(family.Key), 0, 0, 0, 0)
      return false
    end
  end

  log("PREFLIGHT status=PASS families=3 groups=4 units=5 terminals=5")
  return true
end

local function inspectCombined()
  if state.Finalized then return end

  if activePlayerClientCount() > 0 then
    result("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT_DURING_INSPECTION", #state.Spawned, 0, 0, 0)
    return
  end

  local expectedFamilies, expectedGroups, expectedUnits = countConfigured()
  local groupsFound = 0
  local unitsFound = 0
  local placementFailures = 0
  local familyFailures = 0
  local familyStats = {}

  for _, family in ipairs(config.Families or {}) do
    familyStats[family.Key] = {
      ExpectedGroups = #(family.SpawnRequests or {}),
      ExpectedUnits = tonumber(family.ExpectedTotalUnits) or 0,
      GroupsFound = 0,
      UnitsFound = 0,
      PlacementFailures = 0
    }
  end

  for _, spawned in ipairs(state.Spawned) do
    local family = spawned.Family
    local request = spawned.Request
    local group = spawned.Group
    local stats = familyStats[family.Key]
    local units = safe("GET_UNITS_INSPECTION_" .. tostring(family.Key) .. "_" .. tostring(spawned.RequestIndex), function()
      return group:GetUnits()
    end) or {}

    groupsFound = groupsFound + 1
    stats.GroupsFound = stats.GroupsFound + 1

    if #units ~= tonumber(request.ExpectedUnits) then
      placementFailures = placementFailures + 1
      stats.PlacementFailures = stats.PlacementFailures + 1
      log(string.format(
        "PLACEMENT_VIOLATION family=%s request=%d reason=UNIT_COUNT expected=%d actual=%d",
        tostring(family.Key),
        spawned.RequestIndex,
        tonumber(request.ExpectedUnits) or -1,
        #units
      ))
    end

    local assigned = {}
    for _, unit in ipairs(units) do
      unitsFound = unitsFound + 1
      stats.UnitsFound = stats.UnitsFound + 1

      local unitCoordinate = safe("GET_UNIT_COORDINATE_" .. tostring(unit:GetName()), function()
        return unit:GetCoordinate()
      end)
      local unitAlive = safe("GET_UNIT_ALIVE_" .. tostring(unit:GetName()), function()
        return unit:IsAlive()
      end)
      local unitType = safe("GET_UNIT_TYPE_" .. tostring(unit:GetName()), function()
        return unit:GetTypeName()
      end)

      local nearestTerminalID = nil
      local nearestDistance = nil
      for _, terminalIDValue in ipairs(request.Spots or {}) do
        local terminalID = tonumber(terminalIDValue)
        if terminalID and not assigned[terminalID] then
          local spot = state.ParkingByID[terminalID]
          local distance = spot and coordinateDistance2D(unitCoordinate, spot.Coordinate) or nil
          if distance and (not nearestDistance or distance < nearestDistance) then
            nearestTerminalID = terminalID
            nearestDistance = distance
          end
        end
      end

      local placementAccepted = unitAlive == true and
        tostring(unitType) == tostring(family.ExpectedType) and
        nearestTerminalID ~= nil and nearestDistance ~= nil and
        nearestDistance <= tonumber(family.ModelRadiusM)

      if nearestTerminalID then assigned[nearestTerminalID] = true end
      if not placementAccepted then
        placementFailures = placementFailures + 1
        stats.PlacementFailures = stats.PlacementFailures + 1
      end

      log(string.format(
        "UNIT_PLACEMENT family=%s request=%d group=%s unit=%s type=%s alive=%s assignedTerminalID=%s centerDistanceM=%.3f allowedDistanceM=%.3f accepted=%s",
        tostring(family.Key),
        spawned.RequestIndex,
        tostring(group:GetName()),
        tostring(unit:GetName()),
        tostring(unitType),
        tostring(unitAlive),
        tostring(nearestTerminalID or "none"),
        tonumber(nearestDistance) or -1,
        tonumber(family.ModelRadiusM) or -1,
        tostring(placementAccepted)
      ))
    end

    for _, terminalIDValue in ipairs(request.Spots or {}) do
      local terminalID = tonumber(terminalIDValue)
      if terminalID and not assigned[terminalID] then
        placementFailures = placementFailures + 1
        stats.PlacementFailures = stats.PlacementFailures + 1
        log(string.format(
          "PLACEMENT_VIOLATION family=%s request=%d reason=TERMINAL_UNASSIGNED terminalID=%d",
          tostring(family.Key),
          spawned.RequestIndex,
          terminalID
        ))
      end
    end
  end

  for _, family in ipairs(config.Families or {}) do
    local stats = familyStats[family.Key]
    local familyPass = stats.GroupsFound == stats.ExpectedGroups and
      stats.UnitsFound == stats.ExpectedUnits and
      stats.PlacementFailures == 0
    if not familyPass then familyFailures = familyFailures + 1 end
    log(string.format(
      "FAMILY_RESULT family=%s status=%s expectedGroups=%d groupsFound=%d expectedUnits=%d unitsFound=%d placementFailures=%d visualConfirmationRequired=true",
      tostring(family.Key),
      familyPass and "PASS_RUNTIME_PLACEMENT" or "FAIL_PLACEMENT",
      stats.ExpectedGroups,
      stats.GroupsFound,
      stats.ExpectedUnits,
      stats.UnitsFound,
      stats.PlacementFailures
    ))
  end

  local status = "PASS_RUNTIME_PLACEMENT"
  local reason = "none"
  if groupsFound ~= expectedGroups then
    status = "FAIL_PLACEMENT"
    reason = "GROUP_COUNT_MISMATCH"
  elseif unitsFound ~= expectedUnits then
    status = "FAIL_PLACEMENT"
    reason = "UNIT_COUNT_MISMATCH"
  elseif placementFailures > 0 or familyFailures > 0 then
    status = "FAIL_PLACEMENT"
    reason = "PLACEMENT_VIOLATIONS"
  end

  log("VISUAL_CONFIRMATION_REQUIRED combined=true checks=all_five_aircraft_present,no_overlap,no_static_contact,on_prepared_surface,rotor_clearance")
  result(status, reason, groupsFound, unitsFound, placementFailures, familyFailures)
end

local function spawnCombined()
  if state.Finalized then return end

  if activePlayerClientCount() > 0 then
    result("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT_BEFORE_SPAWN", 0, 0, 0, 0)
    return
  end

  for _, family in ipairs(config.Families or {}) do
    for requestIndex, request in ipairs(family.SpawnRequests or {}) do
      local expectedUnits = tonumber(request.ExpectedUnits) or #(request.Spots or {})
      local spawner = SPAWN:NewWithAlias(family.TemplateGroup, request.Alias)
      if not spawner then
        result("FAIL_SPAWN", "SPAWNER_CONSTRUCTION_FAILED_" .. tostring(family.Key) .. "_" .. tostring(requestIndex), #state.Spawned, 0, 0, 1)
        return
      end

      state.Spawners[#state.Spawners + 1] = spawner
      spawner:InitLimit(expectedUnits, 1)
      spawner:InitAIOff()

      state.SpawnCalls = state.SpawnCalls + 1
      local group = spawner:SpawnAtParkingSpot(state.Airbase, request.Spots, SPAWN.Takeoff.Cold)
      if not group then
        result("FAIL_SPAWN", "SPAWN_RETURNED_NIL_" .. tostring(family.Key) .. "_" .. tostring(requestIndex), #state.Spawned, 0, 0, 1)
        return
      end

      state.Spawned[#state.Spawned + 1] = {
        Family = family,
        RequestIndex = requestIndex,
        Request = request,
        Group = group
      }

      local units = safe("GET_UNITS_AFTER_SPAWN_" .. tostring(family.Key) .. "_" .. tostring(requestIndex), function()
        return group:GetUnits()
      end) or {}

      log(string.format(
        "SPAWNED family=%s request=%d alias=%s group=%s terminalIDs=%s unitsReported=%d aiEnabled=false",
        tostring(family.Key),
        requestIndex,
        tostring(request.Alias),
        tostring(group:GetName()),
        join(request.Spots),
        #units
      ))
    end
  end

  log("SPAWN_PHASE status=PASS groupsSpawned=" .. tostring(#state.Spawned) .. " spawnCalls=" .. tostring(state.SpawnCalls))

  if SCHEDULER then
    SCHEDULER:New(nil, inspectCombined, {}, 8)
  else
    timer.scheduleFunction(function()
      inspectCombined()
      return nil
    end, nil, timer.getTime() + 8)
  end
end

local function main()
  if not preflight() then return end
  if SCHEDULER then
    SCHEDULER:New(nil, spawnCombined, {}, 2)
  else
    timer.scheduleFunction(function()
      spawnCombined()
      return nil
    end, nil, timer.getTime() + 2)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 12)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 12)
end
