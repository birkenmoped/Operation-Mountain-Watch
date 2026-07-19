local TM02W2FRouteReassignmentWatchdog = {}

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

local function interpolate(first, second, fraction)
  local a, b = vec3(first), vec3(second)
  if not a or not b then return nil end
  return COORDINATE:NewFromVec3({
    x = a.x + (b.x - a.x) * fraction,
    y = a.y + (b.y - a.y) * fraction,
    z = a.z + (b.z - a.z) * fraction,
  })
end

local function projectOnRoute(coordinates, position)
  local point = vec3(position)
  if not point or type(coordinates) ~= "table" or #coordinates < 2 then return nil end
  local bestDistance, bestAlong, cumulative = math.huge, 0, 0
  for index = 2, #coordinates do
    local a, b = vec3(coordinates[index - 1]), vec3(coordinates[index])
    if a and b then
      local dx, dz = b.x - a.x, b.z - a.z
      local squared = dx * dx + dz * dz
      local fraction = 0
      if squared > 0 then
        fraction = ((point.x - a.x) * dx + (point.z - a.z) * dz) / squared
        fraction = math.max(0, math.min(1, fraction))
      end
      local projected = { x = a.x + dx * fraction, y = a.y, z = a.z + dz * fraction }
      local crossTrack = distance2D(point, projected)
      local segmentMeters = math.sqrt(squared)
      if crossTrack < bestDistance then
        bestDistance = crossTrack
        bestAlong = cumulative + segmentMeters * fraction
      end
      cumulative = cumulative + segmentMeters
    end
  end
  return { alongMeters = bestAlong, crossTrackMeters = bestDistance, totalMeters = cumulative }
end

local function sliceRoute(coordinates, requestedMeters, currentCoordinate)
  if type(coordinates) ~= "table" or #coordinates < 2 then return nil end
  local result = { currentCoordinate }
  local cumulative = 0
  for index = 2, #coordinates do
    local first, second = coordinates[index - 1], coordinates[index]
    local segmentMeters = distance2D(first, second)
    if cumulative + segmentMeters >= requestedMeters then
      local fraction = segmentMeters > 0 and (requestedMeters - cumulative) / segmentMeters or 0
      result[#result + 1] = interpolate(first, second, fraction)
      for remaining = index, #coordinates do result[#result + 1] = coordinates[remaining] end
      return result
    end
    cumulative = cumulative + segmentMeters
  end
  result[#result + 1] = coordinates[#coordinates]
  return result
end

local function safeCall(object, methodName, ...)
  if type(object) ~= "table" or type(object[methodName]) ~= "function" then return nil end
  local arguments = { ... }
  local ok, result = pcall(function() return object[methodName](object, unpack(arguments)) end)
  if ok then return result end
  return nil
end

function TM02W2FRouteReassignmentWatchdog.install(config, executionState, navigation)
  local watchdogConfig = config.routeReassignmentWatchdog or {}
  local state = {
    valid = true,
    errors = {},
    generation = 0,
    lastGlobalRecoveryMissionTime = -math.huge,
    recoveryOperationCount = 0,
    replacementSpawnCount = 0,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM02W2F][WATCHDOG] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function addError(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "route_reassignment_watchdog_error", { code = code, detail = detail })
  end

  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    addError("EXECUTION_INVALID", "execution state unavailable or invalid")
  end
  if type(navigation) ~= "table" or navigation.valid ~= true then
    addError("NAVIGATION_INVALID", "navigation unavailable or invalid")
  end

  local requiredNumbers = {
    initialDelaySeconds = watchdogConfig.initialDelaySeconds,
    intervalSeconds = watchdogConfig.intervalSeconds,
    sampleWindowSeconds = watchdogConfig.sampleWindowSeconds,
    minimumTravelMeters = watchdogConfig.minimumTravelMeters,
    minimumProgressMeters = watchdogConfig.minimumProgressMeters,
    maximumRouteReassignmentsPerTask = watchdogConfig.maximumRouteReassignmentsPerTask,
    perTaskRecoveryCooldownSeconds = watchdogConfig.perTaskRecoveryCooldownSeconds,
    globalRecoveryIntervalSeconds = watchdogConfig.globalRecoveryIntervalSeconds,
    blockedResetProgressMeters = watchdogConfig.blockedResetProgressMeters,
  }
  for name, value in pairs(requiredNumbers) do
    if type(value) ~= "number" or value <= 0 then addError("CONFIG_INVALID", name .. "=" .. tostring(value)) end
  end

  local function taskInCombat(task, now)
    if now < (task.navCombatUntil or 0) then return true end
    local group = task.proxyGroup
    if not group then return false end
    if task.navArmyGroupName ~= group:GetName() then
      local ok, armyGroup = pcall(function() return ARMYGROUP:New(group) end)
      if ok and armyGroup then
        task.navArmyGroup = armyGroup
        task.navArmyGroupName = group:GetName()
        task.navObservedHitCount = armyGroup.Nhit or 0
      end
    end
    if task.navArmyGroup then
      local engaging = safeCall(task.navArmyGroup, "IsEngaging") == true
      local hitCount = task.navArmyGroup.Nhit or 0
      if engaging or hitCount > (task.navObservedHitCount or 0) then
        task.navCombatUntil = now + (config.navigation.combatCooldownSeconds or 90)
      end
      task.navObservedHitCount = hitCount
    end
    return now < (task.navCombatUntil or 0)
  end

  local function routeContext(task)
    local group = task.proxyGroup
    if not group then return nil end
    return navigation.routeContextByGroupName[group:GetName()]
  end

  local function resetSample(task, now, position, projection)
    task.w2fWatchdogSample = {
      startedAt = now,
      startPosition = position,
      lastPosition = position,
      travelledMeters = 0,
      startRouteProgressMeters = projection.alongMeters,
      maxRouteProgressMeters = projection.alongMeters,
    }
  end

  local function reassignRemainingRoute(task, now, reason, context, projection)
    if taskInCombat(task, now) then
      log("INFO", "route_reassignment_suppressed_combat", { taskId = task.taskId, reason = reason })
      return false
    end
    if now - state.lastGlobalRecoveryMissionTime < watchdogConfig.globalRecoveryIntervalSeconds then
      return false
    end
    if now - (task.w2fLastRecoveryMissionTime or -math.huge) < watchdogConfig.perTaskRecoveryCooldownSeconds then
      return false
    end
    if (task.w2fRouteReassignmentCount or 0) >= watchdogConfig.maximumRouteReassignmentsPerTask then
      if task.navigationState ~= "NAVIGATION_BLOCKED" then
        task.navigationState = "NAVIGATION_BLOCKED"
        task.navigationBlockReason = reason
        task.navigationBlockedAt = now
        log("WARNING", "navigation_blocked", {
          taskId = task.taskId,
          reason = reason,
          routeReassignmentCount = task.w2fRouteReassignmentCount or 0,
          movementState = task.movementState,
          accountingPreserved = true,
        })
      end
      return false
    end

    local group = task.proxyGroup
    local currentCoordinate = group and group:GetCoordinate() or nil
    local remaining = currentCoordinate and sliceRoute(context.coordinates, projection.alongMeters, currentCoordinate) or nil
    if not remaining or #remaining < 2 then
      log("ERROR", "route_reassignment_failed", { taskId = task.taskId, reason = "REMAINING_ROUTE_UNAVAILABLE" })
      return false
    end

    local formation = context.mode == "ROAD"
      and (config.routing.roadFormation or "On Road")
      or (config.routing.offRoadFormation or "Off Road")
    local waypoints = {}
    for _, coordinate in ipairs(remaining) do
      waypoints[#waypoints + 1] = coordinate:WaypointGround(config.routing.proxyTestSpeedKph, formation)
    end

    local nativeRoute = group.__OMWTM02W2EOriginalRoute or group.Route
    local ok, assigned = pcall(function()
      return nativeRoute(group, waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then
      log("ERROR", "route_reassignment_failed", {
        taskId = task.taskId,
        reason = reason,
        detail = ok and "route returned nil" or tostring(assigned),
      })
      return false
    end

    navigation.routeContextByGroupName[group:GetName()] = {
      sourceSiteId = context.sourceSiteId,
      targetSiteId = context.targetSiteId,
      mode = context.mode,
      coordinates = remaining,
      lengthMeters = math.max(0, projection.totalMeters - projection.alongMeters),
      watchdogVersion = "W2F_REASSIGN_ONLY_1",
    }
    task.w2fRouteReassignmentCount = (task.w2fRouteReassignmentCount or 0) + 1
    task.w2fLastRecoveryMissionTime = now
    task.navigationState = "ROUTE_REASSIGNED"
    state.lastGlobalRecoveryMissionTime = now
    state.recoveryOperationCount = state.recoveryOperationCount + 1
    log("INFO", "same_group_route_reassigned", {
      taskId = task.taskId,
      reason = reason,
      groupName = group:GetName(),
      routeReassignmentCount = task.w2fRouteReassignmentCount,
      waypointCount = #waypoints,
      remainingDistanceMeters = string.format("%.1f", math.max(0, projection.totalMeters - projection.alongMeters)),
      replacementSpawnCount = state.replacementSpawnCount,
    })
    return true
  end

  local function watchTask(task, now)
    if task.movementState ~= "EN_ROUTE" or not task.proxyGroup or task.proxyGroup:IsAlive() ~= true then
      task.w2fWatchdogSample = nil
      return
    end
    local context = routeContext(task)
    local position = vec3(task.proxyGroup:GetCoordinate())
    local projection = context and projectOnRoute(context.coordinates, position) or nil
    if not context or not position or not projection then return end

    if task.navigationState == "NAVIGATION_BLOCKED" then
      local blockedProgress = task.w2fBlockedProgressMeters or projection.alongMeters
      task.w2fBlockedProgressMeters = blockedProgress
      if projection.alongMeters - blockedProgress >= watchdogConfig.blockedResetProgressMeters then
        task.navigationState = "NORMAL"
        task.navigationBlockReason = nil
        task.w2fRouteReassignmentCount = 0
        task.w2fBlockedProgressMeters = nil
        log("INFO", "navigation_block_cleared", {
          taskId = task.taskId,
          progressMeters = string.format("%.1f", projection.alongMeters - blockedProgress),
        })
      end
    end

    if taskInCombat(task, now) then
      resetSample(task, now, position, projection)
      return
    end

    local sample = task.w2fWatchdogSample
    if not sample then
      resetSample(task, now, position, projection)
      return
    end
    sample.travelledMeters = sample.travelledMeters + distance2D(sample.lastPosition, position)
    sample.lastPosition = position
    sample.maxRouteProgressMeters = math.max(sample.maxRouteProgressMeters, projection.alongMeters)
    if now - sample.startedAt < watchdogConfig.sampleWindowSeconds then return end

    local forwardProgress = sample.maxRouteProgressMeters - sample.startRouteProgressMeters
    local netMovement = distance2D(sample.startPosition, position)
    local stationary = sample.travelledMeters < watchdogConfig.minimumTravelMeters
      and forwardProgress < watchdogConfig.minimumProgressMeters
    local circular = sample.travelledMeters >= watchdogConfig.minimumTravelMeters
      and forwardProgress < watchdogConfig.minimumProgressMeters
      and netMovement <= math.max(12, sample.travelledMeters * 0.35)
    local offRoute = projection.crossTrackMeters >= (watchdogConfig.crossTrackLimitMeters or 60)
      and forwardProgress < watchdogConfig.minimumProgressMeters

    log("INFO", "watchdog_sample", {
      taskId = task.taskId,
      travelledMeters = string.format("%.1f", sample.travelledMeters),
      netMovementMeters = string.format("%.1f", netMovement),
      forwardProgressMeters = string.format("%.1f", forwardProgress),
      crossTrackMeters = string.format("%.1f", projection.crossTrackMeters),
      stationary = stationary,
      circular = circular,
      offRoute = offRoute,
      routeReassignmentCount = task.w2fRouteReassignmentCount or 0,
      navigationState = task.navigationState or "NORMAL",
    })

    local reason = stationary and "STATIONARY"
      or (circular and "CIRCULAR_MOVEMENT")
      or (offRoute and "OFF_ROUTE")
      or nil
    if reason and task.navigationState ~= "NAVIGATION_BLOCKED" then
      reassignRemainingRoute(task, now, reason, context, projection)
    elseif forwardProgress >= watchdogConfig.blockedResetProgressMeters then
      task.w2fRouteReassignmentCount = 0
      task.navigationState = "NORMAL"
    end

    local activeContext = routeContext(task) or context
    local activeProjection = projectOnRoute(activeContext.coordinates, task.proxyGroup:GetCoordinate()) or projection
    resetSample(task, now, vec3(task.proxyGroup:GetCoordinate()), activeProjection)
  end

  function state:attach()
    self.generation = self.generation + 1
    local generation = self.generation
    timer.scheduleFunction(function(_, scheduledTime)
      if generation ~= self.generation or executionState.completed == true or executionState.failed == true then
        return nil
      end
      local now = timer.getTime()
      for _, task in ipairs(executionState.tasks or {}) do watchTask(task, now) end
      return scheduledTime + watchdogConfig.intervalSeconds
    end, nil, timer.getTime() + watchdogConfig.initialDelaySeconds)
    log("INFO", "route_reassignment_watchdog_started", {
      engine = "SAME_GROUP_REASSIGN_ONLY_1",
      intervalSeconds = watchdogConfig.intervalSeconds,
      sampleWindowSeconds = watchdogConfig.sampleWindowSeconds,
      maximumRouteReassignmentsPerTask = watchdogConfig.maximumRouteReassignmentsPerTask,
      globalRecoveryIntervalSeconds = watchdogConfig.globalRecoveryIntervalSeconds,
      replacementSpawnsAllowed = false,
    })
    return true
  end

  log(state.valid and "INFO" or "ERROR", "route_reassignment_watchdog_validation", {
    configurationVersion = config.configurationVersion,
    valid = state.valid,
    errorCount = #state.errors,
    replacementSpawnsAllowed = false,
  })
  return state
end

return TM02W2FRouteReassignmentWatchdog
