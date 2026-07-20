local TM02W2FProgressWatchdog = {}

local function vec3(value)
  if not value then return nil end
  if type(value.GetVec3) == "function" then
    local ok, result = pcall(function() return value:GetVec3() end)
    if ok and type(result) == "table" then return result end
  end
  if type(value) == "table" and type(value.x) == "number" then
    return {
      x = value.x,
      y = value.y or 0,
      z = value.z or value.y or 0,
    }
  end
  return nil
end

local function distance2D(first, second)
  local a, b = vec3(first), vec3(second)
  if not a or not b then return math.huge end
  local dx, dz = b.x - a.x, b.z - a.z
  return math.sqrt(dx * dx + dz * dz)
end

local function coordinateFromVec3(value)
  local point = vec3(value)
  if not point then return nil end
  return COORDINATE:NewFromVec3({ x = point.x, y = point.y or 0, z = point.z })
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

function TM02W2FProgressWatchdog.install(config, executionState, navigation, transitRepresentation)
  local watchdogConfig = config.watchdog or {}
  local prefix = "[OMW][TM02W2F][WATCHDOG]"
  local state = {
    valid = true,
    errors = {},
    warnings = {},
    running = false,
    generation = 0,
    sampleCount = 0,
    stallCount = 0,
    recoveryCount = 0,
    blockedCount = 0,
    nextGlobalRecoveryAt = -math.huge,
    urbanCache = {},
  }

  local function log(level, event, fields)
    local suffix = formatFields(fields)
    env.info(prefix .. " level=" .. level .. " event=" .. event
      .. (suffix ~= "" and (" " .. suffix) or ""))
  end

  local function addError(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "watchdog_validation_error", { code = code, detail = detail })
  end

  local function addWarning(code, detail)
    state.warnings[#state.warnings + 1] = tostring(code) .. ": " .. tostring(detail)
    log("WARNING", "watchdog_warning", { code = code, detail = detail })
  end

  local requiredPositiveNumbers = {
    initialDelaySeconds = watchdogConfig.initialDelaySeconds,
    sampleIntervalSeconds = watchdogConfig.sampleIntervalSeconds,
    stallWindowSeconds = watchdogConfig.stallWindowSeconds,
    minimumProgressMeters = watchdogConfig.minimumProgressMeters,
    minimumDistanceToDestinationMeters = watchdogConfig.minimumDistanceToDestinationMeters,
    postRecoveryGraceSeconds = watchdogConfig.postRecoveryGraceSeconds,
    perTaskRecoveryCooldownSeconds = watchdogConfig.perTaskRecoveryCooldownSeconds,
    globalRecoveryIntervalSeconds = watchdogConfig.globalRecoveryIntervalSeconds,
    maxRecoveryAttemptsPerEpisode = watchdogConfig.maxRecoveryAttemptsPerEpisode,
    blockedResetProgressMeters = watchdogConfig.blockedResetProgressMeters,
    microDetourLateralMeters = watchdogConfig.microDetourLateralMeters,
    microDetourForwardMeters = watchdogConfig.microDetourForwardMeters,
    urbanScanRadiusMeters = watchdogConfig.urbanScanRadiusMeters,
    urbanSceneryThreshold = watchdogConfig.urbanSceneryThreshold,
    urbanCacheCellMeters = watchdogConfig.urbanCacheCellMeters,
    urbanCacheSeconds = watchdogConfig.urbanCacheSeconds,
    roadEscapeForwardMeters = watchdogConfig.roadEscapeForwardMeters,
    maximumRoadSnapDistanceMeters = watchdogConfig.maximumRoadSnapDistanceMeters,
  }
  for name, value in pairs(requiredPositiveNumbers) do
    if type(value) ~= "number" or value <= 0 then
      addError("CONFIG_INVALID", name .. "=" .. tostring(value))
    end
  end

  if watchdogConfig.enabled ~= true then
    addError("WATCHDOG_DISABLED", tostring(watchdogConfig.enabled))
  end
  if not config.navigation or config.navigation.automaticRecoveryEnabled ~= true then
    addError("AUTOMATIC_RECOVERY_DISABLED", "navigation.automaticRecoveryEnabled must be true")
  end
  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    addError("EXECUTION_INVALID", "execution state unavailable or invalid")
  end
  if type(navigation) ~= "table" or navigation.valid ~= true or navigation.routingReady ~= true then
    addError("NAVIGATION_INVALID", "navigation unavailable or invalid")
  end
  if type(transitRepresentation) ~= "table" or transitRepresentation.valid ~= true then
    addError("TRANSIT_REPRESENTATION_INVALID", "transit representation unavailable or invalid")
  else
    if type(transitRepresentation.convertTaskForRecovery) ~= "function" then
      addError("RECOVERY_CONVERSION_API_MISSING", "convertTaskForRecovery")
    end
    if type(transitRepresentation.reassignDirectRouteForRecovery) ~= "function" then
      addError("RECOVERY_ROUTE_API_MISSING", "reassignDirectRouteForRecovery")
    end
    if type(transitRepresentation.isTransitionActive) ~= "function" then
      addError("RECOVERY_LOCK_API_MISSING", "isTransitionActive")
    end
  end
  if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec3) ~= "function" then
    addError("COORDINATE_API_MISSING", "COORDINATE.NewFromVec3")
  end
  if type(ZONE) ~= "table" or type(ZONE.FindByName) ~= "function" then
    addError("ZONE_API_MISSING", "ZONE.FindByName")
  end

  local function taskMonitor(task)
    if type(task.w2fProgressWatchdog) ~= "table" then
      task.w2fProgressWatchdog = {
        groupName = nil,
        sampleTime = nil,
        samplePosition = nil,
        sampleDistanceToDestination = nil,
        graceUntil = 0,
        nextRecoveryAt = 0,
        attempts = 0,
        episode = 0,
        recoveryAnchor = nil,
        progressReported = false,
        blockedLogged = false,
      }
    end
    return task.w2fProgressWatchdog
  end

  local function activeGroup(task)
    if task and task.proxyGroup and task.proxyGroup:IsAlive() == true then
      return task.proxyGroup
    end
    return nil
  end

  local function destinationCoordinate(task)
    local nextSiteId = task.path and task.path[task.currentLegIndex + 1] or nil
    local zone = nextSiteId and ZONE:FindByName(nextSiteId) or nil
    if not zone then return nil, nextSiteId end
    return zone:GetCoordinate(), nextSiteId
  end

  local function resetSample(monitor, now, position, distanceToDestination)
    monitor.sampleTime = now
    monitor.samplePosition = vec3(position)
    monitor.sampleDistanceToDestination = distanceToDestination
  end

  local function surfaceIsUsable(point)
    if type(land) ~= "table" or type(land.getSurfaceType) ~= "function" then
      return true
    end
    local ok, surfaceType = pcall(function()
      return land.getSurfaceType({ x = point.x, y = point.z })
    end)
    if not ok then return true end
    local surfaceTypes = land.SurfaceType or {}
    if surfaceType == surfaceTypes.WATER or surfaceType == surfaceTypes.SHALLOW_WATER then
      return false
    end
    return true
  end

  local function sceneryCount(point, radius, stopAfter)
    if type(world) ~= "table"
      or type(world.searchObjects) ~= "function"
      or type(world.VolumeType) ~= "table"
      or world.VolumeType.SPHERE == nil
      or type(Object) ~= "table"
      or type(Object.Category) ~= "table"
      or Object.Category.SCENERY == nil then
      return nil, "SCENERY_SEARCH_UNAVAILABLE"
    end

    local count = 0
    local volume = {
      id = world.VolumeType.SPHERE,
      params = {
        point = { x = point.x, y = point.y or 0, z = point.z },
        radius = radius,
      },
    }
    local ok, searchError = pcall(function()
      world.searchObjects(Object.Category.SCENERY, volume, function(object)
        if object then count = count + 1 end
        return not stopAfter or count < stopAfter
      end)
    end)
    if not ok then return nil, tostring(searchError) end
    return count, nil
  end

  local function classifyEnvironment(position, now)
    local cellSize = watchdogConfig.urbanCacheCellMeters
    local cellX = math.floor(position.x / cellSize)
    local cellZ = math.floor(position.z / cellSize)
    local key = tostring(cellX) .. ":" .. tostring(cellZ)
    local cached = state.urbanCache[key]
    if cached and now - cached.sampledAt <= watchdogConfig.urbanCacheSeconds then
      return cached.classification, cached.sceneryCount, "CACHE"
    end

    local count, scanError = sceneryCount(
      position,
      watchdogConfig.urbanScanRadiusMeters,
      watchdogConfig.urbanSceneryThreshold
    )
    local classification = count and count >= watchdogConfig.urbanSceneryThreshold
      and "URBAN"
      or "RURAL"
    if count == nil then
      classification = "UNKNOWN"
      addWarning("URBAN_SCAN_UNAVAILABLE", scanError)
    end
    state.urbanCache[key] = {
      classification = classification,
      sceneryCount = count or -1,
      sampledAt = now,
    }
    log("INFO", "environment_classified", {
      cacheKey = key,
      classification = classification,
      sceneryCount = count or -1,
      radiusMeters = watchdogConfig.urbanScanRadiusMeters,
      source = "LIVE_SCAN",
    })
    return classification, count or -1, "LIVE_SCAN"
  end

  local function assignWaypoints(task, coordinates, formations, mode, reason)
    local group = activeGroup(task)
    if not group then return false, "GROUP_UNAVAILABLE" end
    if #coordinates ~= #formations then return false, "WAYPOINT_FORMATION_COUNT_MISMATCH" end
    if #coordinates > config.routing.maximumPhysicalWaypointsPerLeg then
      return false, "WAYPOINT_LIMIT_EXCEEDED"
    end

    local waypoints = {}
    for index, coordinate in ipairs(coordinates) do
      if not coordinate or type(coordinate.WaypointGround) ~= "function" then
        return false, "WAYPOINT_COORDINATE_INVALID_" .. tostring(index)
      end
      waypoints[index] = coordinate:WaypointGround(
        config.routing.proxyTestSpeedKph,
        formations[index]
      )
    end

    local ok, assigned = pcall(function()
      return group:Route(waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then
      return false, ok and "ROUTE_RETURNED_NIL" or tostring(assigned)
    end
    log("INFO", "watchdog_route_assigned", {
      taskId = task.taskId,
      groupName = group:GetName(),
      mode = mode,
      reason = reason,
      waypointCount = #waypoints,
      formations = table.concat(formations, ">"),
    })
    return true, nil
  end

  local function microDetour(task, attempt)
    local group = activeGroup(task)
    local destination = destinationCoordinate(task)
    if not group or not destination then return false, "ROUTE_COORDINATE_UNAVAILABLE" end
    local current = group:GetCoordinate()
    local currentPoint = vec3(current)
    local targetPoint = vec3(destination)
    if not currentPoint or not targetPoint then return false, "ROUTE_COORDINATE_UNAVAILABLE" end

    local dx, dz = targetPoint.x - currentPoint.x, targetPoint.z - currentPoint.z
    local length = math.sqrt(dx * dx + dz * dz)
    if length < 1 then return false, "DESTINATION_TOO_CLOSE" end
    local forwardX, forwardZ = dx / length, dz / length
    local lateralX, lateralZ = -forwardZ, forwardX
    local preferredSign = attempt % 2 == 0 and -1 or 1
    local candidates = {}
    local definitions = {
      { preferredSign, 1.0 },
      { -preferredSign, 1.0 },
      { preferredSign, 1.5 },
      { -preferredSign, 1.5 },
    }
    for _, definition in ipairs(definitions) do
      local sign, scale = definition[1], definition[2]
      local point = {
        x = currentPoint.x + forwardX * watchdogConfig.microDetourForwardMeters * scale
          + lateralX * watchdogConfig.microDetourLateralMeters * sign * scale,
        y = currentPoint.y or 0,
        z = currentPoint.z + forwardZ * watchdogConfig.microDetourForwardMeters * scale
          + lateralZ * watchdogConfig.microDetourLateralMeters * sign * scale,
      }
      if surfaceIsUsable(point) then
        local nearby = sceneryCount(point, 18, 4)
        candidates[#candidates + 1] = {
          point = point,
          sceneryCount = nearby or 0,
        }
      end
    end
    table.sort(candidates, function(first, second)
      return first.sceneryCount < second.sceneryCount
    end)
    local selected = candidates[1]
    if not selected then return false, "NO_USABLE_DETOUR_POINT" end
    local detour = coordinateFromVec3(selected.point)
    if not detour then return false, "DETOUR_COORDINATE_FAILED" end

    local success, failure = assignWaypoints(
      task,
      { current, detour, destination },
      {
        config.routing.offRoadFormation,
        config.routing.offRoadFormation,
        config.routing.offRoadFormation,
      },
      "RURAL_MICRO_DETOUR",
      "stalled-off-road-obstacle"
    )
    if success then
      log("INFO", "micro_detour_selected", {
        taskId = task.taskId,
        attempt = attempt,
        sceneryCountAtDetour = selected.sceneryCount,
        lateralMeters = watchdogConfig.microDetourLateralMeters,
        forwardMeters = watchdogConfig.microDetourForwardMeters,
      })
    end
    return success, failure
  end

  local function roadEscape(task)
    local group = activeGroup(task)
    local destination = destinationCoordinate(task)
    if not group or not destination then return false, "ROUTE_COORDINATE_UNAVAILABLE" end
    local current = group:GetCoordinate()
    local currentPoint = vec3(current)
    local targetPoint = vec3(destination)
    if not currentPoint or not targetPoint then return false, "ROUTE_COORDINATE_UNAVAILABLE" end
    if type(current.GetClosestPointToRoad) ~= "function" then
      return false, "ROAD_API_UNAVAILABLE"
    end

    local dx, dz = targetPoint.x - currentPoint.x, targetPoint.z - currentPoint.z
    local remaining = math.sqrt(dx * dx + dz * dz)
    if remaining < 1 then return false, "DESTINATION_TOO_CLOSE" end
    local forwardDistance = math.min(watchdogConfig.roadEscapeForwardMeters, remaining * 0.6)
    local projectedPoint = {
      x = currentPoint.x + dx / remaining * forwardDistance,
      y = currentPoint.y or 0,
      z = currentPoint.z + dz / remaining * forwardDistance,
    }
    local projected = coordinateFromVec3(projectedPoint)
    if not projected or type(projected.GetClosestPointToRoad) ~= "function" then
      return false, "ROAD_PROJECTION_UNAVAILABLE"
    end

    local entryOk, entry = pcall(function() return current:GetClosestPointToRoad() end)
    local exitOk, exit = pcall(function() return projected:GetClosestPointToRoad() end)
    if not entryOk or not exitOk or not entry or not exit then
      return false, "ROAD_POINT_UNAVAILABLE"
    end
    local entrySnap = distance2D(current, entry)
    local exitSnap = distance2D(projected, exit)
    if entrySnap > watchdogConfig.maximumRoadSnapDistanceMeters
      or exitSnap > watchdogConfig.maximumRoadSnapDistanceMeters then
      return false, "ROAD_SNAP_TOO_FAR"
    end
    if distance2D(entry, exit) < 60 then
      return false, "ROAD_ESCAPE_TOO_SHORT"
    end
    if distance2D(exit, destination) >= distance2D(current, destination) - 25 then
      return false, "ROAD_ESCAPE_NOT_FORWARD"
    end

    return assignWaypoints(
      task,
      { current, entry, exit, destination },
      {
        config.routing.offRoadFormation,
        config.routing.roadFormation,
        config.routing.roadFormation,
        config.routing.offRoadFormation,
      },
      "URBAN_ROAD_ESCAPE",
      "stalled-in-dense-scenery"
    )
  end

  local function recoveryStrategy(attempt, environment)
    if attempt == 1 then return "SAME_GROUP_DIRECT_RESET" end
    if attempt == 2 then return "REPRESENTATION_RESET" end
    if attempt == 3 then
      return environment == "URBAN" and "URBAN_ROAD_ESCAPE" or "RURAL_MICRO_DETOUR"
    end
    if attempt == 4 then return "REPRESENTATION_RESET" end
    if attempt == 5 then
      return environment == "URBAN" and "URBAN_ROAD_ESCAPE" or "RURAL_MICRO_DETOUR"
    end
    return "REPRESENTATION_RESET"
  end

  local function applyRecovery(task, monitor, now)
    if monitor.attempts >= watchdogConfig.maxRecoveryAttemptsPerEpisode then
      task.navigationState = "NAVIGATION_BLOCKED"
      if monitor.blockedLogged ~= true then
        monitor.blockedLogged = true
        state.blockedCount = state.blockedCount + 1
        log("ERROR", "navigation_blocked", {
          taskId = task.taskId,
          groupName = task.proxyGroupName or "none",
          attempts = monitor.attempts,
          episode = monitor.episode,
          automaticRecoveryStopped = true,
        })
      end
      return false
    end
    if now < state.nextGlobalRecoveryAt or now < (monitor.nextRecoveryAt or 0) then
      return false
    end
    if transitRepresentation.isTransitionActive() == true then
      return false
    end

    local group = activeGroup(task)
    if not group then return false end
    local position = vec3(group:GetCoordinate())
    if not position then return false end
    local environment, scenery = classifyEnvironment(position, now)
    local attempt = monitor.attempts + 1
    local strategy = recoveryStrategy(attempt, environment)
    local success, failure

    if strategy == "SAME_GROUP_DIRECT_RESET" then
      success, failure = transitRepresentation.reassignDirectRouteForRecovery(
        task,
        "watchdog-same-group-direct-reset"
      )
    elseif strategy == "REPRESENTATION_RESET" then
      success, failure = transitRepresentation.convertTaskForRecovery(
        task,
        "watchdog-representation-reset-attempt-" .. tostring(attempt)
      )
    elseif strategy == "URBAN_ROAD_ESCAPE" then
      success, failure = roadEscape(task)
      if success ~= true then
        strategy = "RURAL_MICRO_DETOUR_FALLBACK"
        success, failure = microDetour(task, attempt)
      end
    else
      success, failure = microDetour(task, attempt)
    end

    if failure == "TRANSITION_BUSY" then return false end

    monitor.attempts = attempt
    monitor.episode = monitor.episode + (attempt == 1 and 1 or 0)
    monitor.graceUntil = now + watchdogConfig.postRecoveryGraceSeconds
    monitor.nextRecoveryAt = now + watchdogConfig.perTaskRecoveryCooldownSeconds
    monitor.recoveryAnchor = vec3(activeGroup(task) and activeGroup(task):GetCoordinate() or position)
    monitor.progressReported = false
    monitor.blockedLogged = false
    state.nextGlobalRecoveryAt = now + watchdogConfig.globalRecoveryIntervalSeconds

    if success == true then
      state.recoveryCount = state.recoveryCount + 1
      task.navigationState = "RECOVERING_" .. strategy
      log("WARNING", "recovery_applied", {
        taskId = task.taskId,
        groupName = task.proxyGroupName or "none",
        attempt = attempt,
        episode = monitor.episode,
        strategy = strategy,
        environment = environment,
        sceneryCount = scenery,
        nextRecoveryAt = monitor.nextRecoveryAt,
      })
    else
      task.navigationState = "RECOVERY_FAILED_" .. strategy
      log("ERROR", "recovery_failed", {
        taskId = task.taskId,
        groupName = task.proxyGroupName or "none",
        attempt = attempt,
        episode = monitor.episode,
        strategy = strategy,
        environment = environment,
        reason = failure or "unknown",
      })
    end
    return success == true
  end

  local function inspectTask(task, now)
    if task.movementState ~= "EN_ROUTE" then
      task.w2fProgressWatchdog = nil
      return false
    end
    local group = activeGroup(task)
    if not group then return false end
    local currentCoordinate = group:GetCoordinate()
    local current = vec3(currentCoordinate)
    local destination = destinationCoordinate(task)
    local target = vec3(destination)
    if not current or not target then return false end
    local remainingDistance = distance2D(current, target)
    local monitor = taskMonitor(task)
    local groupName = group:GetName()

    if monitor.groupName ~= groupName then
      monitor.groupName = groupName
      monitor.graceUntil = now + watchdogConfig.postRecoveryGraceSeconds
      resetSample(monitor, now, current, remainingDistance)
      log("INFO", "watchdog_group_observed", {
        taskId = task.taskId,
        groupName = groupName,
        graceUntil = monitor.graceUntil,
      })
      return false
    end

    if task.navCombatUntil and task.navCombatUntil > now then
      task.navigationState = "COMBAT_HOLD"
      resetSample(monitor, now, current, remainingDistance)
      return false
    end
    if task.navigationState == "COMBAT_HOLD" then
      task.navigationState = "DIRECT_OFFROAD"
      monitor.graceUntil = now + watchdogConfig.postRecoveryGraceSeconds
    end

    if monitor.recoveryAnchor then
      local recoveryProgress = distance2D(monitor.recoveryAnchor, current)
      if recoveryProgress >= watchdogConfig.minimumProgressMeters
        and monitor.progressReported ~= true then
        monitor.progressReported = true
        log("INFO", "navigation_progress_resumed", {
          taskId = task.taskId,
          groupName = groupName,
          progressMeters = string.format("%.1f", recoveryProgress),
          attempts = monitor.attempts,
          episode = monitor.episode,
        })
      end
      if recoveryProgress >= watchdogConfig.blockedResetProgressMeters then
        log("INFO", "recovery_episode_cleared", {
          taskId = task.taskId,
          groupName = groupName,
          progressMeters = string.format("%.1f", recoveryProgress),
          previousAttempts = monitor.attempts,
          episode = monitor.episode,
        })
        monitor.attempts = 0
        monitor.recoveryAnchor = nil
        monitor.progressReported = false
        monitor.blockedLogged = false
        task.navigationState = "DIRECT_OFFROAD"
      end
    end

    if remainingDistance <= watchdogConfig.minimumDistanceToDestinationMeters then
      resetSample(monitor, now, current, remainingDistance)
      return false
    end
    if now < (monitor.graceUntil or 0) then
      resetSample(monitor, now, current, remainingDistance)
      return false
    end
    if not monitor.sampleTime or not monitor.samplePosition then
      resetSample(monitor, now, current, remainingDistance)
      return false
    end

    local travelled = distance2D(monitor.samplePosition, current)
    local forwardProgress = (monitor.sampleDistanceToDestination or remainingDistance) - remainingDistance
    if travelled >= watchdogConfig.minimumProgressMeters
      or forwardProgress >= watchdogConfig.minimumProgressMeters then
      resetSample(monitor, now, current, remainingDistance)
      return false
    end

    local sampleAge = now - monitor.sampleTime
    if sampleAge < watchdogConfig.stallWindowSeconds then return false end
    if task.navigationState == "NAVIGATION_BLOCKED" then return false end

    state.stallCount = state.stallCount + 1
    log("WARNING", "stall_detected", {
      taskId = task.taskId,
      groupName = groupName,
      sampleAgeSeconds = string.format("%.1f", sampleAge),
      travelledMeters = string.format("%.1f", travelled),
      forwardProgressMeters = string.format("%.1f", forwardProgress),
      remainingDistanceMeters = string.format("%.1f", remainingDistance),
      attempts = monitor.attempts,
      episode = monitor.episode,
    })
    resetSample(monitor, now, current, remainingDistance)
    return applyRecovery(task, monitor, now)
  end

  local function watchdogTick()
    if not state.running or executionState.completed == true or executionState.failed == true then
      return false
    end
    local now = timer.getTime()
    state.sampleCount = state.sampleCount + 1
    for _, task in ipairs(executionState.tasks or {}) do
      local ok, inspectionError = pcall(inspectTask, task, now)
      if not ok then
        addWarning("TASK_INSPECTION_FAILED", task.taskId .. " reason=" .. tostring(inspectionError))
      end
    end
    return true
  end

  local function start()
    if not state.valid or state.running then return false end
    state.running = true
    state.generation = state.generation + 1
    local generation = state.generation
    timer.scheduleFunction(function(_, scheduledTime)
      if not state.running or generation ~= state.generation then return nil end
      local ok, continueOrError = pcall(watchdogTick)
      if not ok then
        addWarning("WATCHDOG_TICK_FAILED", continueOrError)
      elseif continueOrError ~= true then
        state.running = false
        return nil
      end
      return timer.getTime() + watchdogConfig.sampleIntervalSeconds
    end, nil, timer.getTime() + watchdogConfig.initialDelaySeconds)
    log("INFO", "progress_watchdog_started", {
      configurationVersion = config.configurationVersion,
      sampleIntervalSeconds = watchdogConfig.sampleIntervalSeconds,
      stallWindowSeconds = watchdogConfig.stallWindowSeconds,
      minimumProgressMeters = watchdogConfig.minimumProgressMeters,
      maxRecoveryAttemptsPerEpisode = watchdogConfig.maxRecoveryAttemptsPerEpisode,
      automaticRepresentationReset = true,
      urbanRoadEscape = true,
      ruralMicroDetour = true,
      globallySerialized = true,
      timerCatchUpDisabled = true,
    })
    return true
  end

  state.tick = watchdogTick
  state.start = start
  state.stop = function()
    state.running = false
    state.generation = state.generation + 1
  end

  log(state.valid and "INFO" or "ERROR", "progress_watchdog_validation", {
    configurationVersion = config.configurationVersion,
    valid = state.valid,
    automaticRecoveryEnabled = config.navigation and config.navigation.automaticRecoveryEnabled == true,
    maximumRecoveryWaypoints = config.routing.maximumPhysicalWaypointsPerLeg,
    normalRoadUse = false,
    representationResetSpawnsBounded = true,
    errorCount = #state.errors,
    warningCount = #state.warnings,
  })
  if state.valid then start() end
  return state
end

return TM02W2FProgressWatchdog
