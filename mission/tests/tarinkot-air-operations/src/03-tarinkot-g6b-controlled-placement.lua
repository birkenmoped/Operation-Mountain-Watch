-- Operation Mountain Watch - Tarinkot G6B controlled parking placement.
--
-- This stage uses only the exact MOOSE 2.9.18 SPAWN parking path:
--   SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
--
-- The builder injects exactly one family configuration per generated bundle.
-- AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER and OPSTRANSPORT objects are
-- deliberately outside this test. AI remains disabled after placement.

local TAG = "[OMW][AirOps.TKOT.G6B]"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G6B_BUILD or {}
local config = OMW_TKOT_G6B_CONFIG or {}

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

local function coordinateDistance2D(left, right)
  local leftVec = left and left:GetVec3() or nil
  local rightVec = right and right:GetVec3() or nil
  if not leftVec or not rightVec then return nil end
  local dx = (leftVec.x or 0) - (rightVec.x or 0)
  local dz = (leftVec.z or 0) - (rightVec.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function join(values)
  local labels = {}
  for _, value in ipairs(values or {}) do labels[#labels + 1] = tostring(value) end
  return #labels > 0 and table.concat(labels, ",") or "none"
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

local function terminalTypeAccepted(terminalType)
  return AIRBASE and AIRBASE._CheckTerminalType and
    AIRBASE._CheckTerminalType(terminalType, AIRBASE.TerminalType.HelicopterUsable) == true
end

local function result(status, reason, groupsSpawned, unitsFound, placementFailures)
  if state.Finalized then return end
  state.Finalized = true
  log(string.format(
    "RESULT G6B_%s_CONTROLLED_PLACEMENT status=%s reason=%s requestedGroups=%d groupsSpawned=%d expectedUnits=%d unitsFound=%d placementFailures=%d activePlayerClients=%d spawnCalls=%d visualConfirmationRequired=true",
    tostring(config.Family or "UNKNOWN"),
    tostring(status),
    tostring(reason or "none"),
    #(config.SpawnRequests or {}),
    tonumber(groupsSpawned) or 0,
    tonumber(config.ExpectedTotalUnits) or 0,
    tonumber(unitsFound) or 0,
    tonumber(placementFailures) or 0,
    activePlayerClientCount(),
    state.SpawnCalls
  ))
end

local function preflight()
  log("BEGIN Tarinkot G6B controlled placement")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder),
    tostring(build.BuilderVersion),
    tostring(build.GitCommit),
    tostring(build.GeneratedUtc)
  ))
  log(string.format(
    "CONFIG family=%s template=%s expectedType=%s expectedGroups=%d expectedUnits=%d modelRadiusM=%.3f aiEnabled=false takeoff=COLD",
    tostring(config.Family),
    tostring(config.TemplateGroup),
    tostring(config.ExpectedType),
    #(config.SpawnRequests or {}),
    tonumber(config.ExpectedTotalUnits) or -1,
    tonumber(config.ModelRadiusM) or -1
  ))
  log("MUTATION_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_LIST_MUTATION=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0 RANDOMIZATION=0")
  log("SPAWN_PATH method=SPAWN:SpawnAtParkingSpot takeoff=SPAWN.Takeoff.Cold aiOff=true")

  if not AIRBASE or not AIRBASE.TerminalType or not SPAWN or not GROUP or not UNIT then
    result("FAIL_PREFLIGHT", "MOOSE_CLASS_UNAVAILABLE", 0, 0, 0)
    return false
  end

  if not config.Family or not config.TemplateGroup or not config.ExpectedType or
      not config.ModelRadiusM or not config.SpawnRequests or not config.ExpectedTotalUnits then
    result("FAIL_PREFLIGHT", "CONFIGURATION_INCOMPLETE", 0, 0, 0)
    return false
  end

  if activePlayerClientCount() > 0 then
    result("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT", 0, 0, 0)
    return false
  end

  local template = GROUP:FindByName(config.TemplateGroup)
  if not template then
    result("FAIL_PREFLIGHT", "TEMPLATE_GROUP_NOT_FOUND", 0, 0, 0)
    return false
  end

  local airbase = AIRBASE:FindByID(EXPECTED.AirbaseID)
  if not airbase then
    result("FAIL_PREFLIGHT", "AIRBASE_ID_NOT_FOUND", 0, 0, 0)
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
    result("FAIL_PREFLIGHT", "PARKING_COUNT_MISMATCH", 0, 0, 0)
    return false
  end

  local seenTerminalIDs = {}
  local totalRequestedUnits = 0

  for requestIndex, request in ipairs(config.SpawnRequests) do
    local spots = request.Spots or {}
    local expectedUnits = tonumber(request.ExpectedUnits) or #spots
    totalRequestedUnits = totalRequestedUnits + expectedUnits

    log(string.format(
      "REQUEST index=%d alias=%s terminalIDs=%s expectedUnits=%d",
      requestIndex,
      tostring(request.Alias),
      join(spots),
      expectedUnits
    ))

    if #spots ~= expectedUnits then
      result("FAIL_PREFLIGHT", "REQUEST_SPOT_UNIT_COUNT_MISMATCH", 0, 0, 0)
      return false
    end

    for _, terminalIDValue in ipairs(spots) do
      local terminalID = tonumber(terminalIDValue)
      local spot = terminalID and state.ParkingByID[terminalID] or nil
      if not terminalID or not spot then
        result("FAIL_PREFLIGHT", "REQUESTED_TERMINAL_NOT_FOUND_" .. tostring(terminalIDValue), 0, 0, 0)
        return false
      end
      if seenTerminalIDs[terminalID] then
        result("FAIL_PREFLIGHT", "DUPLICATE_REQUESTED_TERMINAL_" .. tostring(terminalID), 0, 0, 0)
        return false
      end
      seenTerminalIDs[terminalID] = true
      if EXPECTED.ClientTerminalIDs[terminalID] then
        result("FAIL_PREFLIGHT", "CLIENT_TERMINAL_REQUESTED_" .. tostring(terminalID), 0, 0, 0)
        return false
      end
      if spot.Free ~= true or spot.TOAC == true then
        result("FAIL_PREFLIGHT", "TERMINAL_NOT_FREE_" .. tostring(terminalID), 0, 0, 0)
        return false
      end
      if not terminalTypeAccepted(spot.TerminalType) then
        result("FAIL_PREFLIGHT", "TERMINAL_TYPE_REJECTED_" .. tostring(terminalID), 0, 0, 0)
        return false
      end
      log(string.format(
        "TERMINAL_READY id=%d type=%s free=%s toac=%s coordinateX=%.3f coordinateZ=%.3f",
        terminalID,
        tostring(spot.TerminalType),
        tostring(spot.Free),
        tostring(spot.TOAC),
        tonumber(spot.Coordinate and spot.Coordinate:GetVec3().x) or -1,
        tonumber(spot.Coordinate and spot.Coordinate:GetVec3().z) or -1
      ))
    end
  end

  if totalRequestedUnits ~= tonumber(config.ExpectedTotalUnits) then
    result("FAIL_PREFLIGHT", "TOTAL_EXPECTED_UNIT_COUNT_MISMATCH", 0, 0, 0)
    return false
  end

  log("PREFLIGHT status=PASS")
  return true
end

local function spawnConfiguredRequests()
  if state.Finalized then return end

  if activePlayerClientCount() > 0 then
    result("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT_BEFORE_SPAWN", 0, 0, 0)
    return
  end

  local groupsSpawned = 0
  for requestIndex, request in ipairs(config.SpawnRequests) do
    local expectedUnits = tonumber(request.ExpectedUnits) or #(request.Spots or {})
    local spawner = SPAWN:NewWithAlias(config.TemplateGroup, request.Alias)
    if not spawner then
      result("FAIL_SPAWN", "SPAWNER_CONSTRUCTION_FAILED_" .. tostring(requestIndex), groupsSpawned, 0, 0)
      return
    end

    state.Spawners[#state.Spawners + 1] = spawner
    spawner:InitLimit(expectedUnits, 1)
    spawner:InitAIOff()

    state.SpawnCalls = state.SpawnCalls + 1
    local group = spawner:SpawnAtParkingSpot(state.Airbase, request.Spots, SPAWN.Takeoff.Cold)
    if not group then
      result("FAIL_SPAWN", "SPAWN_RETURNED_NIL_" .. tostring(requestIndex), groupsSpawned, 0, 0)
      return
    end

    groupsSpawned = groupsSpawned + 1
    state.Spawned[#state.Spawned + 1] = {
      RequestIndex = requestIndex,
      Request = request,
      Group = group
    }

    local units = safe("GET_UNITS_AFTER_SPAWN_" .. tostring(requestIndex), function()
      return group:GetUnits()
    end) or {}

    log(string.format(
      "SPAWNED request=%d alias=%s group=%s terminalIDs=%s unitsReported=%d aiEnabled=false",
      requestIndex,
      tostring(request.Alias),
      tostring(group:GetName()),
      join(request.Spots),
      #units
    ))
  end

  log("SPAWN_PHASE status=PASS groupsSpawned=" .. tostring(groupsSpawned))

  local function inspectCallback()
    local groupsFound = 0
    local unitsFound = 0
    local placementFailures = 0

    if activePlayerClientCount() > 0 then
      result("INVALID_ACTIVE_PLAYER_CLIENT", "ACTIVE_PLAYER_CLIENT_DURING_INSPECTION", #state.Spawned, 0, 0)
      return
    end

    for _, spawned in ipairs(state.Spawned) do
      local request = spawned.Request
      local group = spawned.Group
      local units = safe("GET_UNITS_INSPECTION_" .. tostring(spawned.RequestIndex), function()
        return group:GetUnits()
      end) or {}
      groupsFound = groupsFound + 1

      if #units ~= tonumber(request.ExpectedUnits) then
        placementFailures = placementFailures + 1
        log(string.format(
          "PLACEMENT_VIOLATION request=%d reason=UNIT_COUNT expected=%d actual=%d",
          spawned.RequestIndex,
          tonumber(request.ExpectedUnits) or -1,
          #units
        ))
      end

      local assigned = {}
      for _, unit in ipairs(units) do
        unitsFound = unitsFound + 1
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
          tostring(unitType) == tostring(config.ExpectedType) and
          nearestTerminalID ~= nil and nearestDistance ~= nil and
          nearestDistance <= tonumber(config.ModelRadiusM)

        if nearestTerminalID then assigned[nearestTerminalID] = true end
        if not placementAccepted then placementFailures = placementFailures + 1 end

        log(string.format(
          "UNIT_PLACEMENT request=%d group=%s unit=%s type=%s alive=%s assignedTerminalID=%s centerDistanceM=%.3f allowedDistanceM=%.3f accepted=%s",
          spawned.RequestIndex,
          tostring(group:GetName()),
          tostring(unit:GetName()),
          tostring(unitType),
          tostring(unitAlive),
          tostring(nearestTerminalID or "none"),
          tonumber(nearestDistance) or -1,
          tonumber(config.ModelRadiusM) or -1,
          tostring(placementAccepted)
        ))
      end

      for _, terminalIDValue in ipairs(request.Spots or {}) do
        local terminalID = tonumber(terminalIDValue)
        if terminalID and not assigned[terminalID] then
          placementFailures = placementFailures + 1
          log(string.format(
            "PLACEMENT_VIOLATION request=%d reason=TERMINAL_UNASSIGNED terminalID=%d",
            spawned.RequestIndex,
            terminalID
          ))
        end
      end
    end

    local status = "PASS_RUNTIME_PLACEMENT"
    local reason = "none"
    if groupsFound ~= #(config.SpawnRequests or {}) then
      status = "FAIL_PLACEMENT"
      reason = "GROUP_COUNT_MISMATCH"
    elseif unitsFound ~= tonumber(config.ExpectedTotalUnits) then
      status = "FAIL_PLACEMENT"
      reason = "UNIT_COUNT_MISMATCH"
    elseif placementFailures > 0 then
      status = "FAIL_PLACEMENT"
      reason = "PLACEMENT_VIOLATIONS"
    end

    log("VISUAL_CONFIRMATION_REQUIRED family=" .. tostring(config.Family) .. " checks=no_overlap,no_static_contact,on_prepared_surface,rotor_clearance")
    result(status, reason, groupsFound, unitsFound, placementFailures)
  end

  if SCHEDULER then
    SCHEDULER:New(nil, inspectCallback, {}, 8)
  else
    timer.scheduleFunction(function()
      inspectCallback()
      return nil
    end, nil, timer.getTime() + 8)
  end
end

local function main()
  if not preflight() then return end

  if SCHEDULER then
    SCHEDULER:New(nil, spawnConfiguredRequests, {}, 3)
  else
    timer.scheduleFunction(function()
      spawnConfiguredRequests()
      return nil
    end, nil, timer.getTime() + 3)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 8)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 8)
end
