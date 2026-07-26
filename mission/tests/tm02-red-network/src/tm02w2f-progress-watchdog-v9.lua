local TM02W2FProgressWatchdog = {}

local function vec3(value)
  if not value then return nil end
  if type(value.GetVec3) == "function" then
    local ok, result = pcall(function() return value:GetVec3() end)
    if ok and type(result) == "table" then return result end
  end
  if type(value) == "table" and type(value.x) == "number" then
    return { x = value.x, y = value.y or 0, z = value.z or value.y or 0 }
  end
  return nil
end

local function distance2D(first, second)
  local a, b = vec3(first), vec3(second)
  if not a or not b then return math.huge end
  local dx, dz = b.x - a.x, b.z - a.z
  return math.sqrt(dx * dx + dz * dz)
end

local function coordinate(value)
  local point = vec3(value)
  if not point then return nil end
  return COORDINATE:NewFromVec3({ x = point.x, y = point.y or 0, z = point.z })
end

local function projectOnSegment(first, second, position)
  local a, b, p = vec3(first), vec3(second), vec3(position)
  if not a or not b or not p then return nil end
  local dx, dz = b.x - a.x, b.z - a.z
  local squared = dx * dx + dz * dz
  local total = math.sqrt(squared)
  if total <= 0 then return nil end
  local fraction = ((p.x - a.x) * dx + (p.z - a.z) * dz) / squared
  fraction = math.max(0, math.min(1, fraction))
  local projected = { x = a.x + dx * fraction, y = 0, z = a.z + dz * fraction }
  return {
    alongMeters = total * fraction,
    crossTrackMeters = distance2D(projected, p),
    totalMeters = total,
  }
end

local function coordinateAtDistance(first, second, requestedMeters)
  local a, b = vec3(first), vec3(second)
  if not a or not b then return nil end
  local total = distance2D(a, b)
  if total == math.huge or total <= 0 then return nil end
  local fraction = math.max(0, math.min(1, requestedMeters / total))
  return coordinate({
    x = a.x + (b.x - a.x) * fraction,
    y = 0,
    z = a.z + (b.z - a.z) * fraction,
  })
end

local function safeCall(object, methodName, ...)
  if not object then return nil end
  local arguments = { ... }
  local ok, result = pcall(function()
    local method = object[methodName]
    if type(method) ~= "function" then return nil end
    return method(object, unpack(arguments))
  end)
  if ok then return result end
  return nil
end

local function formatFields(fields)
  local keys, parts = {}, {}
  for key in pairs(fields or {}) do keys[#keys + 1] = key end
  table.sort(keys)
  for _, key in ipairs(keys) do
    parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
  end
  return table.concat(parts, " ")
end

function TM02W2FProgressWatchdog.install(config, executionState, navigation)
  local cfg = config.watchdog or {}
  local state = {
    valid = true,
    errors = {},
    warnings = {},
    running = false,
    generation = 0,
    nextGlobalRecoveryAt = -math.huge,
    replacementGeneration = 0,
    stallCount = 0,
    routeRefreshCount = 0,
    localDetourCount = 0,
    relocationCount = 0,
    roadRecoveryCount = 0,
    terminalRecoveryCount = 0,
    deferredExposureCount = 0,
    exhaustedWaitCount = 0,
  }

  local function log(level, event, fields)
    local suffix = formatFields(fields)
    env.info("[OMW][TM02W2F][WATCHDOG] level=" .. level .. " event=" .. event
      .. (suffix ~= "" and (" " .. suffix) or ""))
  end

  local function invalid(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = code .. ": " .. tostring(detail)
    log("ERROR", "watchdog_validation_error", { code = code, detail = detail })
  end

  local required = {
    "initialDelaySeconds", "sampleIntervalSeconds", "stallWindowSeconds",
    "minimumTravelMeters", "minimumProgressMeters", "circularTravelMeters",
    "circularNetMeters", "routeEfficiencyFloor", "ineffectiveWindowLimit",
    "wrongWayMeters", "crossTrackLimitMeters", "minimumDistanceToDestinationMeters",
    "postRecoveryGraceSeconds", "perTaskRecoveryCooldownSeconds",
    "globalRecoveryIntervalSeconds", "routeRefreshAttempts",
    "routeRefreshCooldownSeconds", "localDetourAttempts",
    "localDetourNearLateralMeters", "localDetourFarLateralMeters",
    "localDetourForwardMeters", "proxyMaxRelocationsPerEpisode",
    "proxyRelocationAdvanceMeters", "proxyMaxRelocationsPerLeg",
    "fullGroupMaxRelocationsPerEpisode", "fullGroupRelocationAdvanceMeters",
    "fullGroupMaxRelocationsPerLeg", "recoveryCreditProgressMeters",
    "roadRecoveryResetProgressMeters", "recoveryExhaustedRetrySeconds",
    "exposureScanIntervalSeconds", "exposureClearSeconds",
    "playerAircraftSafetyRadiusMeters", "playerGroundSafetyRadiusMeters",
    "enemyGroundSafetyRadiusMeters", "enemyAirSafetyRadiusMeters",
    "terminalRecoveryThresholdMeters", "terminalRecoveryOffsetMeters",
    "maximumRoadSnapDistanceMeters", "minimumRoadSegmentMeters",
  }
  for _, name in ipairs(required) do
    if type(cfg[name]) ~= "number" or cfg[name] <= 0 then
      invalid("CONFIG_INVALID", name .. "=" .. tostring(cfg[name]))
    end
  end
  if cfg.enabled ~= true then invalid("WATCHDOG_DISABLED", cfg.enabled) end
  if not config.navigation or config.navigation.automaticRecoveryEnabled ~= true then
    invalid("AUTOMATIC_RECOVERY_DISABLED", "navigation.automaticRecoveryEnabled")
  end
  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    invalid("EXECUTION_INVALID", "execution state")
  end
  if type(navigation) ~= "table" or navigation.valid ~= true
    or navigation.routingReady ~= true or type(navigation.registryState) ~= "table" then
    invalid("NAVIGATION_INVALID", "navigation registry context")
  end
  if type(SPAWN) ~= "table" or type(SPAWN.NewWithAlias) ~= "function" then
    invalid("SPAWN_API_MISSING", "SPAWN.NewWithAlias")
  end
  if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec3) ~= "function" then
    invalid("COORDINATE_API_MISSING", "COORDINATE.NewFromVec3")
  end
  if type(ZONE) ~= "table" or type(ZONE.FindByName) ~= "function" then
    invalid("ZONE_API_MISSING", "ZONE.FindByName")
  end
  if type(world) ~= "table" or type(world.searchObjects) ~= "function"
    or type(world.VolumeType) ~= "table" or world.VolumeType.SPHERE == nil
    or type(Object) ~= "table" or type(Object.Category) ~= "table"
    or Object.Category.UNIT == nil then
    invalid("EXPOSURE_API_MISSING", "world.searchObjects Object.Category.UNIT")
  end

  local function activeGroup(task)
    return task and task.proxyGroup and task.proxyGroup:IsAlive() == true
      and task.proxyGroup or nil
  end

  local function representation(task)
    return task.transitExpanded == true and "FULL_GROUP" or "LEADER_PROXY"
  end

  local function recoveryLimits(task)
    if task.transitExpanded == true then
      return cfg.fullGroupMaxRelocationsPerEpisode,
        cfg.fullGroupRelocationAdvanceMeters,
        cfg.fullGroupMaxRelocationsPerLeg
    end
    return cfg.proxyMaxRelocationsPerEpisode,
      cfg.proxyRelocationAdvanceMeters,
      cfg.proxyMaxRelocationsPerLeg
  end

  local function legContext(task)
    local sourceId = task.path and task.path[task.currentLegIndex] or nil
    local targetId = task.path and task.path[task.currentLegIndex + 1] or nil
    local sourceSite = sourceId and navigation.registryState.siteById[sourceId] or nil
    local zone = targetId and ZONE:FindByName(targetId) or nil
    local target = zone and zone:GetCoordinate() or nil
    local source = sourceSite and coordinate(sourceSite.coordinate) or nil
    if not source or not target then return nil end
    return {
      key = tostring(sourceId) .. ">" .. tostring(targetId),
      source = source,
      target = target,
      sourceId = sourceId,
      targetId = targetId,
    }
  end

  local function monitorFor(task)
    task.w2fProgressWatchdog = task.w2fProgressWatchdog or {
      legKey = nil,
      groupName = nil,
      sampleTime = nil,
      sampleStart = nil,
      sampleLast = nil,
      sampleDistance = nil,
      sampleAlong = nil,
      travelled = 0,
      maxAlong = 0,
      highestAlong = 0,
      ineffectiveWindows = 0,
      graceUntil = 0,
      nextRecoveryAt = 0,
      waitUntil = 0,
      episode = 1,
      routeRefreshes = 0,
      localDetours = 0,
      episodeRelocations = 0,
      legRelocations = 0,
      roadRecoveryUsed = false,
      terminalRecoveryUsed = false,
      creditHighWaterAlong = 0,
      uncreditedRealProgress = 0,
      roadResetHighWaterAlong = nil,
      exposureLastScan = -math.huge,
      exposureClearSince = nil,
      exposed = true,
      exposureReason = "NOT_SCANNED",
      exposureDistanceMeters = -1,
    }
    return task.w2fProgressWatchdog
  end

  local function resetSample(monitor, now, position, projection, remaining)
    local point = vec3(position)
    monitor.sampleTime = now
    monitor.sampleStart = point
    monitor.sampleLast = point
    monitor.sampleDistance = remaining
    monitor.sampleAlong = projection.alongMeters
    monitor.travelled = 0
    monitor.maxAlong = projection.alongMeters
  end

  local function syncExpandedSurvivors(task, group)
    if task.transitExpanded ~= true then return true end
    local alive = group:CountAliveUnits()
    if type(alive) ~= "number" then return true end
    local previous = task.survivorCount or task.strength or alive
    if alive < previous then
      local losses = previous - alive
      task.survivorCount = alive
      executionState.totalLosses = (executionState.totalLosses or 0) + losses
      log("WARNING", "expanded_group_losses_recorded", {
        taskId = task.taskId,
        previousSurvivors = previous,
        currentSurvivors = alive,
        newLosses = losses,
        totalLosses = executionState.totalLosses,
      })
    end
    return alive > 0
  end

  local function assignRoute(group, task, coordinates, formations, mode, reason)
    if #coordinates ~= #formations
      or #coordinates > config.routing.maximumPhysicalWaypointsPerLeg then
      return false, "WAYPOINT_LIMIT"
    end
    local waypoints = {}
    for index, item in ipairs(coordinates) do
      if not item or type(item.WaypointGround) ~= "function" then
        return false, "WAYPOINT_COORDINATE_INVALID_" .. tostring(index)
      end
      waypoints[index] = item:WaypointGround(
        config.routing.proxyTestSpeedKph,
        formations[index]
      )
    end
    local ok, assigned = pcall(function()
      return group:Route(waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then return false, ok and "ROUTE_NIL" or tostring(assigned) end
    log("INFO", "watchdog_route_assigned", {
      taskId = task.taskId,
      mode = mode,
      reason = reason,
      waypointCount = #waypoints,
      groupName = group:GetName(),
      representation = representation(task),
    })
    return true
  end

  local function directRouteRefresh(task, context, reason)
    local group = activeGroup(task)
    local current = group and group:GetCoordinate() or nil
    if not current then return false, "GROUP_COORDINATE_UNAVAILABLE" end
    return assignRoute(group, task,
      { current, context.target },
      { config.routing.offRoadFormation, config.routing.offRoadFormation },
      "DIRECT_OFFROAD_ROUTE_REFRESH", reason)
  end

  local function surfaceUsable(point)
    if type(land) ~= "table" or type(land.getSurfaceType) ~= "function" then return true end
    local ok, surfaceType = pcall(function()
      return land.getSurfaceType({ x = point.x, y = point.z })
    end)
    if not ok then return true end
    local surfaceTypes = land.SurfaceType or {}
    return surfaceType ~= surfaceTypes.WATER and surfaceType ~= surfaceTypes.SHALLOW_WATER
  end

  local function localDetour(task, context, attempt, reason)
    local group = activeGroup(task)
    local current = group and group:GetCoordinate() or nil
    local currentPoint, targetPoint = vec3(current), vec3(context.target)
    if not currentPoint or not targetPoint then return false, "ROUTE_COORDINATE_UNAVAILABLE" end
    local dx, dz = targetPoint.x - currentPoint.x, targetPoint.z - currentPoint.z
    local length = math.sqrt(dx * dx + dz * dz)
    if length < 1 then return false, "DESTINATION_TOO_CLOSE" end
    local forwardX, forwardZ = dx / length, dz / length
    local lateralX, lateralZ = -forwardZ, forwardX
    local lateral = attempt <= 2 and cfg.localDetourNearLateralMeters
      or cfg.localDetourFarLateralMeters
    local sign = attempt % 2 == 1 and 1 or -1
    local detourPoint = {
      x = currentPoint.x + forwardX * cfg.localDetourForwardMeters + lateralX * lateral * sign,
      y = currentPoint.y or 0,
      z = currentPoint.z + forwardZ * cfg.localDetourForwardMeters + lateralZ * lateral * sign,
    }
    if not surfaceUsable(detourPoint) then return false, "DETOUR_SURFACE_UNUSABLE" end
    local detour = coordinate(detourPoint)
    if not detour then return false, "DETOUR_COORDINATE_UNAVAILABLE" end
    local success, failure = assignRoute(group, task,
      { current, detour, context.target },
      { config.routing.offRoadFormation, config.routing.offRoadFormation,
        config.routing.offRoadFormation },
      "LOCAL_OFFROAD_DETOUR", reason)
    if success then
      log("INFO", "local_detour_applied", {
        taskId = task.taskId,
        attempt = attempt,
        lateralMeters = lateral * sign,
        forwardMeters = cfg.localDetourForwardMeters,
      })
    end
    return success, failure
  end

  local function ownCoalition(group)
    local coalitionId = safeCall(group, "GetCoalition")
    if coalitionId ~= nil then return coalitionId end
    local dcsObject = safeCall(group, "GetDCSObject")
    return safeCall(dcsObject, "getCoalition")
  end

  local function unitIsAir(object)
    local desc = safeCall(object, "getDesc")
    local category = desc and desc.category or nil
    local categories = Unit and Unit.Category or {}
    local airplane = categories.AIRPLANE or 0
    local helicopter = categories.HELICOPTER or 1
    return category == airplane or category == helicopter
  end

  local function scanExposure(task, monitor, group, position, now)
    if now - (monitor.exposureLastScan or -math.huge) < cfg.exposureScanIntervalSeconds then
      return monitor.exposed, monitor.exposureReason, monitor.exposureDistanceMeters
    end
    monitor.exposureLastScan = now
    local groupCoalition = ownCoalition(group)
    if groupCoalition == nil then
      monitor.exposed = true
      monitor.exposureReason = "OWN_COALITION_UNKNOWN"
      monitor.exposureDistanceMeters = -1
      monitor.exposureClearSince = nil
      return true, monitor.exposureReason, -1
    end

    local center = vec3(position)
    local maximumRadius = math.max(
      cfg.playerAircraftSafetyRadiusMeters,
      cfg.playerGroundSafetyRadiusMeters,
      cfg.enemyGroundSafetyRadiusMeters,
      cfg.enemyAirSafetyRadiusMeters
    )
    local foundReason, foundDistance = nil, math.huge
    local taskGroupName = group:GetName()
    local volume = {
      id = world.VolumeType.SPHERE,
      params = {
        point = { x = center.x, y = center.y or 0, z = center.z },
        radius = maximumRadius,
      },
    }
    local ok, searchError = pcall(function()
      world.searchObjects(Object.Category.UNIT, volume, function(object)
        local objectGroup = safeCall(object, "getGroup")
        local objectGroupName = safeCall(objectGroup, "getName")
        if objectGroupName == taskGroupName then return true end
        local point = safeCall(object, "getPoint")
        if not point then return true end
        local separation = distance2D(center, point)
        local air = unitIsAir(object)
        local playerName = safeCall(object, "getPlayerName")
        if type(playerName) == "string" and playerName ~= "" then
          local limit = air and cfg.playerAircraftSafetyRadiusMeters
            or cfg.playerGroundSafetyRadiusMeters
          if separation <= limit then
            foundReason = air and "PLAYER_AIRCRAFT_NEARBY" or "PLAYER_GROUND_NEARBY"
            foundDistance = separation
            return false
          end
        end
        local objectCoalition = safeCall(object, "getCoalition")
        if objectCoalition ~= nil and objectCoalition ~= groupCoalition and objectCoalition ~= 0 then
          local limit = air and cfg.enemyAirSafetyRadiusMeters
            or cfg.enemyGroundSafetyRadiusMeters
          if separation <= limit then
            foundReason = air and "ENEMY_AIR_NEARBY" or "ENEMY_GROUND_NEARBY"
            foundDistance = separation
            return false
          end
        end
        return true
      end)
    end)
    if not ok then
      foundReason = "EXPOSURE_SCAN_ERROR:" .. tostring(searchError)
      foundDistance = -1
    end

    local wasExposed = monitor.exposed
    monitor.exposed = foundReason ~= nil
    monitor.exposureReason = foundReason or "CLEAR"
    monitor.exposureDistanceMeters = foundDistance == math.huge and -1 or foundDistance
    if monitor.exposed then
      monitor.exposureClearSince = nil
      if wasExposed ~= true then
        log("WARNING", "recovery_exposure_detected", {
          taskId = task.taskId,
          reason = monitor.exposureReason,
          distanceMeters = string.format("%.1f", monitor.exposureDistanceMeters),
        })
      end
    else
      if not monitor.exposureClearSince then
        monitor.exposureClearSince = now
        log("INFO", "recovery_exposure_clear_started", {
          taskId = task.taskId,
          requiredClearSeconds = cfg.exposureClearSeconds,
        })
      end
    end
    return monitor.exposed, monitor.exposureReason, monitor.exposureDistanceMeters
  end

  local function teleportAllowed(task, monitor, now)
    if task.navCombatUntil and task.navCombatUntil > now then
      return false, "COMBAT_COOLDOWN", task.navCombatUntil - now
    end
    if monitor.exposed == true then
      return false, monitor.exposureReason or "EXPOSED", monitor.exposureDistanceMeters or -1
    end
    local clearSince = monitor.exposureClearSince
    local clearSeconds = clearSince and (now - clearSince) or 0
    if clearSeconds < cfg.exposureClearSeconds then
      return false, "EXPOSURE_CLEARANCE_PENDING", cfg.exposureClearSeconds - clearSeconds
    end
    return true, "CLEAR", clearSeconds
  end

  local function replacementAlias(task, terminal)
    state.replacementGeneration = state.replacementGeneration + 1
    local prefix = task.transitExpanded == true
      and config.physical.transitRuntimeAliasPrefix or config.proxy.runtimeAliasPrefix
    return prefix .. task.taskId:gsub("[^%w]", "_")
      .. (terminal and "_TERMINAL_" or "_RECOVERY_")
      .. string.format("%04d", state.replacementGeneration)
  end

  local function relocate(task, monitor, context, projection, now, terminal, reason)
    local group = activeGroup(task)
    if not group or not syncExpandedSurvivors(task, group) then
      return false, "NO_SURVIVORS"
    end
    local episodeLimit, advanceMeters, legLimit = recoveryLimits(task)
    if not terminal and (monitor.episodeRelocations >= episodeLimit
      or monitor.legRelocations >= legLimit) then
      return false, "RELOCATION_LIMIT_REACHED"
    end
    local current = math.max(projection.alongMeters, monitor.highestAlong or 0)
    local requested = terminal
      and math.max(current, projection.totalMeters - cfg.terminalRecoveryOffsetMeters)
      or math.min(projection.totalMeters - cfg.terminalRecoveryOffsetMeters,
        current + advanceMeters)
    if requested <= current + 0.5 then return false, "NO_FORWARD_RECOVERY_POINT" end
    local recovery = coordinateAtDistance(context.source, context.target, requested)
    if not recovery then return false, "RECOVERY_POINT_MISSING" end

    local alias = replacementAlias(task, terminal)
    local survivorCount = task.survivorCount or task.strength
    local template = config.templatesByStrength[survivorCount]
    local ok, replacement = pcall(function()
      return SPAWN:NewWithAlias(template, alias):SpawnFromCoordinate(recovery)
    end)
    if not ok or not replacement then return false, tostring(replacement) end
    local expected = task.transitExpanded == true and survivorCount
      or config.proxy.expectedUnitCount
    if replacement:CountAliveUnits() ~= expected then
      pcall(function() replacement:Destroy() end)
      return false, "RECOVERY_COUNT_MISMATCH"
    end
    local routed, routeError = assignRoute(replacement, task,
      { recovery, context.target },
      { config.routing.offRoadFormation, config.routing.offRoadFormation },
      terminal and "TERMINAL_DIRECT_OFFROAD" or "DIRECT_OFFROAD_RELOCATION",
      reason)
    if not routed then
      pcall(function() replacement:Destroy() end)
      return false, routeError
    end

    local old = task.proxyGroup
    local oldName = old and old:GetName() or "none"
    task.proxyGroup = replacement
    task.proxyGroupName = replacement:GetName()
    task.currentCoordinate = recovery:GetVec3()
    task.navArmyGroup = nil
    task.navArmyGroupName = nil
    if old then pcall(function() old:Destroy() end) end

    monitor.groupName = replacement:GetName()
    monitor.highestAlong = requested
    monitor.creditHighWaterAlong = requested
    monitor.uncreditedRealProgress = 0
    if monitor.roadRecoveryUsed then monitor.roadResetHighWaterAlong = requested end
    monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
    monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    resetSample(monitor, now, recovery, { alongMeters = requested },
      distance2D(recovery, context.target))
    if terminal then
      monitor.terminalRecoveryUsed = true
      state.terminalRecoveryCount = state.terminalRecoveryCount + 1
      task.navigationState = "RECOVERING_TERMINAL_DIRECT_OFFROAD"
    else
      monitor.episodeRelocations = monitor.episodeRelocations + 1
      monitor.legRelocations = monitor.legRelocations + 1
      state.relocationCount = state.relocationCount + 1
      task.navigationState = "RECOVERING_DIRECT_OFFROAD_RELOCATION"
    end
    log(terminal and "WARNING" or "INFO",
      terminal and "representation_relocated_terminal_safe_path"
        or "representation_relocated_along_safe_path", {
        taskId = task.taskId,
        reason = reason,
        oldGroupName = oldName,
        runtimeGroupName = replacement:GetName(),
        representation = representation(task),
        requestedRouteProgressMeters = string.format("%.1f", requested),
        relocationAdvanceMeters = terminal and (requested - current) or advanceMeters,
        remainingDistanceMeters = string.format("%.1f", projection.totalMeters - requested),
        episodeRelocations = monitor.episodeRelocations,
        legRelocations = monitor.legRelocations,
        survivorCount = survivorCount,
      })
    return true
  end

  local function roadRecovery(task, monitor, context, now, reason)
    local group = activeGroup(task)
    local current = group and group:GetCoordinate() or nil
    if not current or type(current.GetClosestPointToRoad) ~= "function"
      or type(context.target.GetClosestPointToRoad) ~= "function" then
      return false, "ROAD_API_UNAVAILABLE", -1, -1
    end
    local entryOk, entry = pcall(function() return current:GetClosestPointToRoad() end)
    local exitOk, exit = pcall(function() return context.target:GetClosestPointToRoad() end)
    if not entryOk or not exitOk or not entry or not exit then
      return false, "ROAD_POINT_UNAVAILABLE", -1, -1
    end
    local entryDistance = distance2D(current, entry)
    local exitDistance = distance2D(context.target, exit)
    if entryDistance > cfg.maximumRoadSnapDistanceMeters
      or exitDistance > cfg.maximumRoadSnapDistanceMeters then
      return false, "ROAD_SNAP_TOO_FAR", entryDistance, exitDistance
    end
    if distance2D(entry, exit) < cfg.minimumRoadSegmentMeters then
      return false, "ROAD_SEGMENT_TOO_SHORT", entryDistance, exitDistance
    end
    local routed, routeError = assignRoute(group, task,
      { current, entry, exit, context.target },
      { config.routing.offRoadFormation, config.routing.roadFormation,
        config.routing.roadFormation, config.routing.offRoadFormation },
      "ROAD_RECOVERY_TO_LEG_TARGET", reason)
    if not routed then return false, routeError, entryDistance, exitDistance end
    monitor.roadRecoveryUsed = true
    monitor.roadResetHighWaterAlong = monitor.highestAlong or 0
    monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
    monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    task.navigationState = "RECOVERING_ROAD_TO_LEG_TARGET"
    state.roadRecoveryCount = state.roadRecoveryCount + 1
    log("WARNING", "road_recovery_applied", {
      taskId = task.taskId,
      reason = reason,
      waypointCount = 4,
      groupName = group:GetName(),
      representation = representation(task),
      entrySnapMeters = string.format("%.1f", entryDistance),
      exitSnapMeters = string.format("%.1f", exitDistance),
    })
    return true, nil, entryDistance, exitDistance
  end

  local function enterWait(task, monitor, now, reason, failure)
    monitor.waitUntil = now + cfg.recoveryExhaustedRetrySeconds
    monitor.nextRecoveryAt = monitor.waitUntil
    task.navigationState = "RECOVERY_EXHAUSTED_WAIT"
    state.exhaustedWaitCount = state.exhaustedWaitCount + 1
    log("WARNING", "recovery_exhausted_wait", {
      taskId = task.taskId,
      reason = reason,
      failure = failure or "RECOVERY_SEQUENCE_EXHAUSTED",
      retryAt = monitor.waitUntil,
      episode = monitor.episode,
      episodeRelocations = monitor.episodeRelocations,
      legRelocations = monitor.legRelocations,
      roadRecoveryUsed = monitor.roadRecoveryUsed,
      representation = representation(task),
    })
  end

  local function reopenEpisode(task, monitor, now)
    monitor.waitUntil = 0
    monitor.episode = monitor.episode + 1
    monitor.routeRefreshes = 0
    monitor.localDetours = 0
    monitor.episodeRelocations = 0
    monitor.nextRecoveryAt = now
    monitor.ineffectiveWindows = 0
    task.navigationState = "DIRECT_OFFROAD"
    log("INFO", "recovery_episode_reopened", {
      taskId = task.taskId,
      episode = monitor.episode,
      legRelocations = monitor.legRelocations,
      roadRecoveryUsed = monitor.roadRecoveryUsed,
    })
  end

  local function applyProgressCredits(task, monitor, projection)
    local along = projection.alongMeters
    if along <= (monitor.creditHighWaterAlong or 0) then return end
    local delta = along - monitor.creditHighWaterAlong
    monitor.creditHighWaterAlong = along
    monitor.uncreditedRealProgress = (monitor.uncreditedRealProgress or 0) + delta
    while monitor.uncreditedRealProgress >= cfg.recoveryCreditProgressMeters
      and monitor.episodeRelocations > 0 do
      monitor.uncreditedRealProgress = monitor.uncreditedRealProgress
        - cfg.recoveryCreditProgressMeters
      monitor.episodeRelocations = monitor.episodeRelocations - 1
      log("INFO", "recovery_credit_granted", {
        taskId = task.taskId,
        creditMeters = cfg.recoveryCreditProgressMeters,
        remainingEpisodeRelocations = monitor.episodeRelocations,
        legRelocations = monitor.legRelocations,
      })
    end
    if monitor.roadRecoveryUsed and monitor.roadResetHighWaterAlong
      and along - monitor.roadResetHighWaterAlong >= cfg.roadRecoveryResetProgressMeters then
      monitor.roadRecoveryUsed = false
      monitor.roadResetHighWaterAlong = nil
      log("INFO", "road_recovery_credit_granted", {
        taskId = task.taskId,
        progressMeters = cfg.roadRecoveryResetProgressMeters,
      })
    end
  end

  local function recover(task, monitor, context, projection, now, reason)
    if now < state.nextGlobalRecoveryAt or now < (monitor.nextRecoveryAt or 0) then
      return false
    end
    local group = activeGroup(task)
    if not group then return false end
    local remaining = projection.totalMeters - projection.alongMeters
    local success, failure, strategy

    if monitor.routeRefreshes < cfg.routeRefreshAttempts then
      monitor.routeRefreshes = monitor.routeRefreshes + 1
      strategy = "SAME_GROUP_ROUTE_REFRESH"
      success, failure = directRouteRefresh(task, context, reason)
      monitor.nextRecoveryAt = now + cfg.routeRefreshCooldownSeconds
    elseif monitor.localDetours < cfg.localDetourAttempts then
      monitor.localDetours = monitor.localDetours + 1
      strategy = "SAME_GROUP_LOCAL_DETOUR"
      success, failure = localDetour(task, context, monitor.localDetours, reason)
      monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    else
      local canTeleport, exposureReason, exposureValue = teleportAllowed(task, monitor, now)
      if remaining <= cfg.terminalRecoveryThresholdMeters
        and remaining > cfg.terminalRecoveryOffsetMeters
        and not monitor.terminalRecoveryUsed then
        strategy = "TERMINAL_RELOCATION"
        if not canTeleport then
          task.navigationState = "RECOVERY_DEFERRED_EXPOSED"
          monitor.nextRecoveryAt = now + cfg.exposureScanIntervalSeconds
          state.deferredExposureCount = state.deferredExposureCount + 1
          log("INFO", "recovery_deferred_exposed", {
            taskId = task.taskId,
            strategy = strategy,
            reason = exposureReason,
            value = exposureValue,
            representation = representation(task),
          })
          return false
        end
        success, failure = relocate(task, monitor, context, projection, now, true, reason)
      else
        local episodeLimit, advanceMeters, legLimit = recoveryLimits(task)
        if monitor.episodeRelocations < episodeLimit
          and monitor.legRelocations < legLimit then
          strategy = representation(task) == "FULL_GROUP"
            and "FULL_GROUP_RELOCATION_" .. tostring(advanceMeters) .. "M"
            or "PROXY_RELOCATION_" .. tostring(advanceMeters) .. "M"
          if not canTeleport then
            task.navigationState = "RECOVERY_DEFERRED_EXPOSED"
            monitor.nextRecoveryAt = now + cfg.exposureScanIntervalSeconds
            state.deferredExposureCount = state.deferredExposureCount + 1
            log("INFO", "recovery_deferred_exposed", {
              taskId = task.taskId,
              strategy = strategy,
              reason = exposureReason,
              value = exposureValue,
              representation = representation(task),
              episodeRelocations = monitor.episodeRelocations,
              legRelocations = monitor.legRelocations,
            })
            return false
          end
          success, failure = relocate(task, monitor, context, projection, now, false, reason)
        elseif not monitor.roadRecoveryUsed then
          strategy = "ROAD_RECOVERY_TO_LEG_TARGET"
          local entryDistance, exitDistance
          success, failure, entryDistance, exitDistance = roadRecovery(
            task, monitor, context, now, reason)
          if not success then
            log("WARNING", "road_recovery_unavailable", {
              taskId = task.taskId,
              failure = failure,
              entrySnapMeters = entryDistance and string.format("%.1f", entryDistance) or "n/a",
              exitSnapMeters = exitDistance and string.format("%.1f", exitDistance) or "n/a",
              maximumRoadSnapDistanceMeters = cfg.maximumRoadSnapDistanceMeters,
              retryable = true,
            })
            enterWait(task, monitor, now, reason, failure)
            return false
          end
        else
          enterWait(task, monitor, now, reason, "EPISODE_AND_ROAD_RECOVERY_EXHAUSTED")
          return false
        end
      end
    end

    if success then
      state.nextGlobalRecoveryAt = now + cfg.globalRecoveryIntervalSeconds
      if strategy == "SAME_GROUP_ROUTE_REFRESH" then
        state.routeRefreshCount = state.routeRefreshCount + 1
        task.navigationState = "RECOVERING_ROUTE_REFRESH"
      elseif strategy == "SAME_GROUP_LOCAL_DETOUR" then
        state.localDetourCount = state.localDetourCount + 1
        task.navigationState = "RECOVERING_LOCAL_DETOUR"
      end
      log("WARNING", "recovery_applied", {
        taskId = task.taskId,
        strategy = strategy,
        reason = reason,
        representation = representation(task),
        routeRefreshes = monitor.routeRefreshes,
        localDetours = monitor.localDetours,
        episodeRelocations = monitor.episodeRelocations,
        legRelocations = monitor.legRelocations,
      })
      return true
    end

    log("ERROR", "recovery_failed", {
      taskId = task.taskId,
      strategy = strategy,
      reason = reason,
      failure = failure,
      representation = representation(task),
    })
    monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    return false
  end

  local function inspect(task, now)
    if task.movementState ~= "EN_ROUTE" then
      task.w2fProgressWatchdog = nil
      return
    end
    local group = activeGroup(task)
    local context = group and legContext(task) or nil
    if not group or not context then return end
    if not syncExpandedSurvivors(task, group) then return end
    local current = group:GetCoordinate()
    local projection = projectOnSegment(context.source, context.target, current)
    if not projection then return end
    local remaining = distance2D(current, context.target)
    local monitor = monitorFor(task)

    if monitor.legKey ~= context.key then
      monitor.legKey = context.key
      monitor.groupName = group:GetName()
      monitor.routeRefreshes = 0
      monitor.localDetours = 0
      monitor.episodeRelocations = 0
      monitor.legRelocations = 0
      monitor.roadRecoveryUsed = false
      monitor.terminalRecoveryUsed = false
      monitor.waitUntil = 0
      monitor.highestAlong = projection.alongMeters
      monitor.creditHighWaterAlong = projection.alongMeters
      monitor.uncreditedRealProgress = 0
      monitor.roadResetHighWaterAlong = nil
      monitor.exposureLastScan = -math.huge
      monitor.exposureClearSince = nil
      monitor.exposed = true
      monitor.exposureReason = "NOT_SCANNED"
      monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
      task.navigationState = "DIRECT_OFFROAD"
      scanExposure(task, monitor, group, current, now)
      resetSample(monitor, now, current, projection, remaining)
      return
    end

    if monitor.groupName ~= group:GetName() then
      monitor.groupName = group:GetName()
      monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
      monitor.exposureLastScan = -math.huge
      monitor.exposureClearSince = nil
      monitor.exposed = true
      monitor.exposureReason = "REPRESENTATION_CHANGED"
      scanExposure(task, monitor, group, current, now)
      resetSample(monitor, now, current, projection, remaining)
      return
    end

    scanExposure(task, monitor, group, current, now)
    monitor.highestAlong = math.max(monitor.highestAlong or 0, projection.alongMeters)
    applyProgressCredits(task, monitor, projection)

    if monitor.waitUntil and monitor.waitUntil > 0 then
      if now < monitor.waitUntil then
        task.navigationState = "RECOVERY_EXHAUSTED_WAIT"
        resetSample(monitor, now, current, projection, remaining)
        return
      end
      reopenEpisode(task, monitor, now)
      monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
      resetSample(monitor, now, current, projection, remaining)
      return
    end

    if remaining <= cfg.minimumDistanceToDestinationMeters or now < monitor.graceUntil then
      resetSample(monitor, now, current, projection, remaining)
      return
    end

    monitor.travelled = monitor.travelled + distance2D(monitor.sampleLast, current)
    monitor.sampleLast = vec3(current)
    monitor.maxAlong = math.max(monitor.maxAlong, projection.alongMeters)
    if now - monitor.sampleTime < cfg.stallWindowSeconds then return end

    local forward = monitor.maxAlong - monitor.sampleAlong
    local targetProgress = monitor.sampleDistance - remaining
    local net = distance2D(monitor.sampleStart, current)
    local efficiency = forward / math.max(1, monitor.travelled)
    local stationary = monitor.travelled < cfg.minimumTravelMeters
      and forward < cfg.minimumProgressMeters
      and targetProgress < cfg.minimumProgressMeters
    local circular = monitor.travelled >= cfg.circularTravelMeters
      and net <= math.max(cfg.circularNetMeters, monitor.travelled * 0.35)
      and forward < cfg.minimumProgressMeters
      and targetProgress < cfg.minimumProgressMeters
    local wrongWay = targetProgress <= -cfg.wrongWayMeters
    local offRoute = projection.crossTrackMeters >= cfg.crossTrackLimitMeters
      and forward < cfg.minimumProgressMeters
    local ineffective = monitor.travelled >= cfg.minimumTravelMeters
      and forward < cfg.minimumProgressMeters
      and targetProgress < cfg.minimumProgressMeters
      and efficiency < cfg.routeEfficiencyFloor
    if ineffective and not circular and not wrongWay and not offRoute then
      monitor.ineffectiveWindows = monitor.ineffectiveWindows + 1
    else
      monitor.ineffectiveWindows = 0
    end
    local repeatedIneffective = monitor.ineffectiveWindows >= cfg.ineffectiveWindowLimit
    local reason = stationary and "STATIONARY"
      or (circular and "CIRCULAR_MOVEMENT")
      or (wrongWay and "WRONG_WAY")
      or (offRoute and "OFF_ROUTE")
      or (repeatedIneffective and "NO_ROUTE_PROGRESS")
      or nil

    resetSample(monitor, now, current, projection, remaining)
    if not reason then return end
    state.stallCount = state.stallCount + 1
    log("WARNING", "stall_detected", {
      taskId = task.taskId,
      reason = reason,
      representation = representation(task),
      remainingDistanceMeters = string.format("%.1f", remaining),
      routeRefreshes = monitor.routeRefreshes,
      localDetours = monitor.localDetours,
      episodeRelocations = monitor.episodeRelocations,
      legRelocations = monitor.legRelocations,
      roadRecoveryUsed = monitor.roadRecoveryUsed,
      exposed = monitor.exposed,
      exposureReason = monitor.exposureReason,
    })
    recover(task, monitor, context, projection, now, reason)
  end

  local function tick()
    if not state.running or executionState.completed or executionState.failed then return false end
    local now = timer.getTime()
    for _, task in ipairs(executionState.tasks or {}) do
      local ok, errorMessage = pcall(inspect, task, now)
      if not ok then
        state.warnings[#state.warnings + 1] = task.taskId .. ": " .. tostring(errorMessage)
        log("WARNING", "task_inspection_failed", { taskId = task.taskId, reason = errorMessage })
      end
    end
    return true
  end

  local function start()
    if not state.valid or state.running then return false end
    state.running = true
    state.generation = state.generation + 1
    local generation = state.generation
    timer.scheduleFunction(function()
      if not state.running or generation ~= state.generation then return nil end
      if not tick() then state.running = false return nil end
      return timer.getTime() + cfg.sampleIntervalSeconds
    end, nil, timer.getTime() + cfg.initialDelaySeconds)
    log("INFO", "progress_watchdog_started", {
      configurationVersion = config.configurationVersion,
      routeRefreshAttempts = cfg.routeRefreshAttempts,
      localDetourAttempts = cfg.localDetourAttempts,
      proxyRelocationsPerEpisode = cfg.proxyMaxRelocationsPerEpisode,
      proxyRelocationsPerLeg = cfg.proxyMaxRelocationsPerLeg,
      fullGroupRelocationsPerEpisode = cfg.fullGroupMaxRelocationsPerEpisode,
      fullGroupRelocationsPerLeg = cfg.fullGroupMaxRelocationsPerLeg,
      exposureClearSeconds = cfg.exposureClearSeconds,
      permanentNavigationBlocked = false,
      packUnpackRecoveryAllowed = false,
      timerCatchUpDisabled = true,
    })
    return true
  end

  state.tick = tick
  state.start = start
  state.stop = function()
    state.running = false
    state.generation = state.generation + 1
  end
  log(state.valid and "INFO" or "ERROR", "progress_watchdog_validation", {
    configurationVersion = config.configurationVersion,
    valid = state.valid,
    proxyRecovery = true,
    fullGroupRecovery = true,
    exposureGuard = true,
    permanentNavigationBlocked = false,
    packUnpackRecoveryAllowed = false,
    errorCount = #state.errors,
  })
  if state.valid then start() end
  return state
end

TM02W2FProgressWatchdog.projectOnSegment = projectOnSegment
TM02W2FProgressWatchdog.coordinateAtDistance = coordinateAtDistance

return TM02W2FProgressWatchdog
