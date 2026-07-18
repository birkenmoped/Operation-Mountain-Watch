local TM02W2EProgressWatchdogV5 = {}

local function startsWith(value, prefix)
  return type(value) == "string"
    and type(prefix) == "string"
    and value:sub(1, #prefix) == prefix
end

local function pairKey(firstId, secondId)
  if firstId < secondId then
    return firstId .. "\0" .. secondId
  end
  return secondId .. "\0" .. firstId
end

local function reverseArray(values)
  local result = {}
  for index = #(values or {}), 1, -1 do
    result[#result + 1] = values[index]
  end
  return result
end

local function vec3(value)
  if not value then
    return nil
  end
  if type(value.GetVec3) == "function" then
    local ok, result = pcall(function()
      return value:GetVec3()
    end)
    if ok and type(result) == "table" then
      return result
    end
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
  local a = vec3(first)
  local b = vec3(second)
  if not a or not b then
    return math.huge
  end
  local dx = b.x - a.x
  local dz = b.z - a.z
  return math.sqrt(dx * dx + dz * dz)
end

local function interpolate(first, second, fraction)
  local a = vec3(first)
  local b = vec3(second)
  if not a or not b then
    return nil
  end
  return COORDINATE:NewFromVec3({
    x = a.x + (b.x - a.x) * fraction,
    y = a.y + (b.y - a.y) * fraction,
    z = a.z + (b.z - a.z) * fraction,
  })
end

local function safeCall(object, methodName, ...)
  if type(object) ~= "table" or type(object[methodName]) ~= "function" then
    return nil
  end
  local arguments = { ... }
  local ok, result = pcall(function()
    return object[methodName](object, unpack(arguments))
  end)
  if ok then
    return result
  end
  return nil
end

local function routeLength(coordinates)
  local total = 0
  for index = 2, #(coordinates or {}) do
    total = total + distance2D(coordinates[index - 1], coordinates[index])
  end
  return total
end

local function projectOnRoute(coordinates, position)
  local point = vec3(position)
  if not point or type(coordinates) ~= "table" or #coordinates < 2 then
    return nil
  end
  local bestDistance = math.huge
  local bestAlong = 0
  local bestCoordinate = nil
  local bestSegmentIndex = 1
  local cumulative = 0
  for index = 2, #coordinates do
    local a = vec3(coordinates[index - 1])
    local b = vec3(coordinates[index])
    if a and b then
      local dx = b.x - a.x
      local dz = b.z - a.z
      local segmentSquared = dx * dx + dz * dz
      local fraction = 0
      if segmentSquared > 0 then
        fraction = ((point.x - a.x) * dx + (point.z - a.z) * dz) / segmentSquared
        fraction = math.max(0, math.min(1, fraction))
      end
      local projected = {
        x = a.x + dx * fraction,
        y = a.y + (b.y - a.y) * fraction,
        z = a.z + dz * fraction,
      }
      local crossTrack = distance2D(point, projected)
      local segmentMeters = math.sqrt(segmentSquared)
      if crossTrack < bestDistance then
        bestDistance = crossTrack
        bestAlong = cumulative + segmentMeters * fraction
        bestCoordinate = COORDINATE:NewFromVec3(projected)
        bestSegmentIndex = index - 1
      end
      cumulative = cumulative + segmentMeters
    end
  end
  return {
    alongMeters = bestAlong,
    crossTrackMeters = bestDistance,
    coordinate = bestCoordinate,
    segmentIndex = bestSegmentIndex,
    totalMeters = cumulative,
  }
end

local function sliceRouteFromDistance(coordinates, requestedMeters)
  if type(coordinates) ~= "table" or #coordinates < 2 then
    return nil
  end
  local total = routeLength(coordinates)
  local distance = math.max(0, math.min(requestedMeters, total))
  local cumulative = 0
  for index = 2, #coordinates do
    local first = coordinates[index - 1]
    local second = coordinates[index]
    local segmentMeters = distance2D(first, second)
    if cumulative + segmentMeters >= distance then
      local fraction = segmentMeters > 0 and (distance - cumulative) / segmentMeters or 0
      local result = { interpolate(first, second, fraction) }
      for remaining = index, #coordinates do
        result[#result + 1] = coordinates[remaining]
      end
      return result, total
    end
    cumulative = cumulative + segmentMeters
  end
  return { coordinates[#coordinates - 1], coordinates[#coordinates] }, total
end

local function segmentDistanceToPoint(first, second, point)
  local a = vec3(first)
  local b = vec3(second)
  local p = vec3(point)
  if not a or not b or not p then
    return math.huge
  end
  local dx = b.x - a.x
  local dz = b.z - a.z
  local lengthSquared = dx * dx + dz * dz
  if lengthSquared <= 0 then
    return distance2D(a, p)
  end
  local fraction = ((p.x - a.x) * dx + (p.z - a.z) * dz) / lengthSquared
  fraction = math.max(0, math.min(1, fraction))
  return distance2D({ x = a.x + dx * fraction, z = a.z + dz * fraction }, p)
end

function TM02W2EProgressWatchdogV5.install(config, registryState, plannerState, navigation, executionState)
  local prefix = "[OMW][TM02W2E][NAV]"
  local watchdog = {
    valid = true,
    errors = {},
    generation = 0,
    navigation = navigation,
    execution = executionState,
  }

  local function log(level, event, fields)
    local keys = {}
    local parts = {}
    for key in pairs(fields or {}) do
      keys[#keys + 1] = key
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info(prefix .. " level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function addError(code, detail)
    watchdog.errors[#watchdog.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "progress_watchdog_error", { code = code, detail = detail })
    watchdog.valid = false
  end

  local function pointBlocked(coordinate)
    for _, exclusion in ipairs(navigation.exclusions or {}) do
      if distance2D(coordinate, exclusion.coordinate) <= exclusion.radiusMeters then
        return true, exclusion.objectiveId
      end
    end
    return false, nil
  end

  local function segmentBlocked(first, second)
    for _, exclusion in ipairs(navigation.exclusions or {}) do
      if segmentDistanceToPoint(first, second, exclusion.coordinate) <= exclusion.radiusMeters then
        return true, exclusion.objectiveId
      end
    end
    return false, nil
  end

  local function directedPlan(sourceSiteId, targetSiteId)
    local plan = navigation.planByPair[pairKey(sourceSiteId, targetSiteId)]
    if not plan or plan.safe ~= true then
      return nil
    end
    if plan.sourceSiteId == sourceSiteId and plan.targetSiteId == targetSiteId then
      return plan
    end
    return {
      safe = true,
      mode = plan.mode,
      coordinates = reverseArray(plan.coordinates),
      lengthMeters = plan.lengthMeters,
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      linkId = plan.linkId,
    }
  end

  local function nearestSiteToWaypoint(waypoint)
    if type(waypoint) ~= "table" or type(waypoint.x) ~= "number" or type(waypoint.y) ~= "number" then
      return nil
    end
    local point = { x = waypoint.x, z = waypoint.y }
    local bestSiteId = nil
    local bestDistance = math.huge
    for siteId, site in pairs(registryState.siteById or {}) do
      local candidate = distance2D(point, site.coordinate)
      if candidate < bestDistance then
        bestDistance = candidate
        bestSiteId = siteId
      end
    end
    return bestSiteId
  end

  local function assignCoordinates(group, context, reason)
    if not group or not context or type(context.coordinates) ~= "table" or #context.coordinates < 2 then
      return false
    end
    local formation = context.mode == "ROAD"
      and (config.routing.roadFormation or "On Road")
      or (config.routing.offRoadFormation or "Off Road")
    local waypoints = {}
    for _, coordinate in ipairs(context.coordinates) do
      waypoints[#waypoints + 1] = coordinate:WaypointGround(config.routing.proxyTestSpeedKph, formation)
    end
    safeCall(group, "OptionROEReturnFire")
    safeCall(group, "OptionAlarmStateAuto")
    local nativeRoute = group.__OMWTM02W2EOriginalRoute
      or group.__OMWTM02W2EV5NativeRoute
      or group.Route
    if type(nativeRoute) ~= "function" then
      return false
    end
    local ok, assigned = pcall(function()
      return nativeRoute(group, waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then
      return false
    end
    navigation.routeContextByGroupName[group:GetName()] = {
      sourceSiteId = context.sourceSiteId,
      targetSiteId = context.targetSiteId,
      mode = context.mode,
      coordinates = context.coordinates,
      lengthMeters = routeLength(context.coordinates),
      watchdogVersion = 5,
    }
    log("INFO", "progress_route_assigned", {
      groupName = group:GetName(),
      sourceSiteId = context.sourceSiteId,
      targetSiteId = context.targetSiteId,
      mode = context.mode,
      reason = reason or "normal",
      waypointCount = #waypoints,
      pathDistanceMeters = string.format("%.0f", routeLength(context.coordinates)),
    })
    return true
  end

  local function assignPlan(group, plan, reason)
    if not plan or plan.safe ~= true then
      return false
    end
    return assignCoordinates(group, {
      sourceSiteId = plan.sourceSiteId,
      targetSiteId = plan.targetSiteId,
      mode = plan.mode,
      coordinates = plan.coordinates,
    }, reason)
  end

  local function wrapGroup(group)
    if not group or group.__OMWTM02W2EV5Wrapped == true then
      return group
    end
    if type(group.Route) ~= "function" or type(group.IsCompletelyInZone) ~= "function" then
      addError("GROUP_INSTANCE_API_MISSING", group and group:GetName() or "nil")
      return group
    end
    group.__OMWTM02W2EV5Wrapped = true
    group.__OMWTM02W2EV5NativeRoute = group.__OMWTM02W2EOriginalRoute or group.Route
    group.__OMWTM02W2EV5FallbackRoute = group.Route
    group.__OMWTM02W2EV5FallbackIsCompletelyInZone = group.IsCompletelyInZone

    function group:Route(route, delay)
      local firstWaypoint = type(route) == "table" and route[1] or nil
      local lastWaypoint = type(route) == "table" and route[#route] or nil
      local sourceSiteId = nearestSiteToWaypoint(firstWaypoint)
      local targetSiteId = nearestSiteToWaypoint(lastWaypoint)
      local plan = sourceSiteId and targetSiteId and directedPlan(sourceSiteId, targetSiteId) or nil
      if plan and assignPlan(self, plan, "executor-leg-v5") then
        return self
      end
      return self.__OMWTM02W2EV5FallbackRoute(self, route, delay)
    end

    function group:IsCompletelyInZone(zone)
      local context = navigation.routeContextByGroupName[self:GetName()]
      local targetName = zone and (safeCall(zone, "GetName") or zone.ZoneName or zone.name) or nil
      if context and targetName == context.targetSiteId then
        local portal = navigation.portalsBySiteId[context.targetSiteId]
        if portal and distance2D(self:GetCoordinate(), portal)
          <= (config.navigation.portalArrivalRadiusMeters or 100) then
          return true
        end
      end
      return self.__OMWTM02W2EV5FallbackIsCompletelyInZone(self, zone)
    end
    return group
  end

  local function taskInCombat(task, now)
    if now < (task.navCombatUntil or 0) then
      return true
    end
    local group = task.proxyGroup
    if not group then
      return false
    end
    if task.navArmyGroupName ~= group:GetName() then
      local ok, armyGroup = pcall(function()
        return ARMYGROUP:New(group)
      end)
      if ok and armyGroup then
        task.navArmyGroup = armyGroup
        task.navArmyGroupName = group:GetName()
        task.navObservedHitCount = armyGroup.Nhit or 0
      end
    end
    local armyGroup = task.navArmyGroup
    if armyGroup then
      local engaging = safeCall(armyGroup, "IsEngaging") == true
      local hitCount = armyGroup.Nhit or 0
      if engaging or hitCount > (task.navObservedHitCount or 0) then
        task.navCombatUntil = now + (config.navigation.combatCooldownSeconds or 90)
      end
      task.navObservedHitCount = hitCount
    end
    return now < (task.navCombatUntil or 0)
  end

  local function currentRouteContext(task)
    local group = task.proxyGroup
    if not group then
      return nil
    end
    local context = navigation.routeContextByGroupName[group:GetName()]
    if context and type(context.coordinates) == "table" and #context.coordinates >= 2 then
      return context
    end
    local nextSiteId = task.path[task.currentLegIndex + 1]
    local plan = nextSiteId and directedPlan(task.path[task.currentLegIndex], nextSiteId) or nil
    if not plan then
      return nil
    end
    context = {
      sourceSiteId = plan.sourceSiteId,
      targetSiteId = plan.targetSiteId,
      mode = plan.mode,
      coordinates = plan.coordinates,
      lengthMeters = routeLength(plan.coordinates),
    }
    navigation.routeContextByGroupName[group:GetName()] = context
    return context
  end

  local function resetSample(task, now, position, projection)
    task.navV5MovementSample = {
      startedAt = now,
      startPosition = position,
      lastPosition = position,
      travelledMeters = 0,
      startRouteProgressMeters = projection.alongMeters,
      maxRouteProgressMeters = projection.alongMeters,
      minRouteProgressMeters = projection.alongMeters,
    }
  end

  local function recoveryAdvance(recoveryCount, totalMeters)
    local sequence = config.navigation.recoveryAdvanceSequenceMeters or { 75, 150, 300, 600, 1200 }
    local value = sequence[recoveryCount]
    if value then
      return value, false
    end
    local terminalOffset = config.navigation.terminalRecoveryDistanceFromPortalMeters or 25
    return math.max(0, totalMeters - terminalOffset), true
  end

  local function safeRecoveryCoordinate(candidate, remainingCoordinates)
    local blocked = pointBlocked(candidate)
    if blocked then
      return nil, "ROUTE_POINT_BLOCKED"
    end
    local road = safeCall(candidate, "GetClosestPointToRoad", false)
    if road and distance2D(candidate, road) <= (config.navigation.recoveryRoadSnapMeters or 180) then
      local roadBlocked = pointBlocked(road)
      local nextCoordinate = remainingCoordinates and remainingCoordinates[2] or nil
      local connectingBlocked = nextCoordinate and segmentBlocked(road, nextCoordinate) or false
      if not roadBlocked and not connectingBlocked then
        return road, "ROAD_SNAPPED"
      end
    end
    return candidate, "ROUTE_POINT"
  end

  local function relocateTask(task, now, reason, projection, context)
    if taskInCombat(task, now) then
      log("INFO", "watchdog_recovery_suppressed_combat", {
        taskId = task.taskId,
        reason = reason,
      })
      return false
    end

    task.navRecoveryCount = (task.navRecoveryCount or 0) + 1
    local recoveryCount = task.navRecoveryCount
    local advanceOrAbsolute, terminal = recoveryAdvance(recoveryCount, projection.totalMeters)
    local requestedProgress = terminal
      and advanceOrAbsolute
      or math.min(projection.totalMeters, math.max(
        projection.alongMeters,
        task.navHighestRouteProgressMeters or 0
      ) + advanceOrAbsolute)
    local remaining, totalMeters = sliceRouteFromDistance(context.coordinates, requestedProgress)
    if not remaining or #remaining < 2 then
      addError("RECOVERY_ROUTE_UNAVAILABLE", task.taskId)
      return false
    end
    local recoveryCoordinate, coordinateMode = safeRecoveryCoordinate(remaining[1], remaining)
    if not recoveryCoordinate then
      addError("RECOVERY_POINT_UNAVAILABLE", task.taskId)
      return false
    end
    remaining[1] = recoveryCoordinate

    local alias = config.proxy.runtimeAliasPrefix
      .. task.taskId:gsub("[^%w]", "_")
      .. (terminal and "_TERMINAL" or "_RECOVERY")
      .. tostring(recoveryCount)
    local replacement = SPAWN:NewWithAlias(
      config.templatesByStrength[task.strength],
      alias
    ):SpawnFromCoordinate(recoveryCoordinate)
    replacement = wrapGroup(replacement)
    if not replacement or replacement:CountAliveUnits() ~= 1 then
      addError("RECOVERY_PROXY_SPAWN_FAILED", task.taskId)
      return false
    end

    local assigned = assignCoordinates(replacement, {
      sourceSiteId = context.sourceSiteId,
      targetSiteId = context.targetSiteId,
      mode = context.mode,
      coordinates = remaining,
    }, terminal and "watchdog-terminal-relocation" or "watchdog-route-relocation")
    if not assigned then
      pcall(function() replacement:Destroy() end)
      addError("RECOVERY_ROUTE_ASSIGNMENT_FAILED", task.taskId)
      return false
    end

    local oldProxy = task.proxyGroup
    local oldName = oldProxy and oldProxy:GetName() or "none"
    task.proxyGroup = replacement
    task.proxyGroupName = replacement:GetName()
    task.navArmyGroup = nil
    task.navArmyGroupName = nil
    task.navObservedHitCount = nil
    task.navV5MovementSample = nil
    task.navV5IneffectiveWindowCount = 0
    task.navHighestRouteProgressMeters = requestedProgress
    if oldProxy then
      pcall(function() oldProxy:Destroy() end)
      navigation.routeContextByGroupName[oldName] = nil
    end

    log(terminal and "WARNING" or "INFO", terminal and "proxy_relocated_terminal_safe_path" or "proxy_relocated_along_safe_path", {
      taskId = task.taskId,
      reason = reason,
      recoveryCount = recoveryCount,
      requestedRouteProgressMeters = string.format("%.1f", requestedProgress),
      routeLengthMeters = string.format("%.1f", totalMeters),
      coordinateMode = coordinateMode,
      runtimeGroupName = replacement:GetName(),
    })
    return true
  end

  local function watchTask(task, now)
    if task.movementState ~= "EN_ROUTE" or not task.proxyGroup or task.proxyGroup:IsAlive() ~= true then
      task.navV5MovementSample = nil
      task.navV5GroupName = nil
      return
    end

    local group = wrapGroup(task.proxyGroup)
    if task.navV5GroupName ~= group:GetName() then
      task.navV5GroupName = group:GetName()
      task.navV5MovementSample = nil
    end
    local context = currentRouteContext(task)
    local position = vec3(group:GetCoordinate())
    local projection = context and projectOnRoute(context.coordinates, position) or nil
    if not context or not position or not projection then
      addError("ROUTE_PROGRESS_CONTEXT_MISSING", task.taskId)
      return
    end

    task.navHighestRouteProgressMeters = math.max(
      task.navHighestRouteProgressMeters or 0,
      projection.alongMeters
    )

    if taskInCombat(task, now) then
      resetSample(task, now, position, projection)
      return
    end

    local sample = task.navV5MovementSample
    if not sample then
      resetSample(task, now, position, projection)
      return
    end

    sample.travelledMeters = sample.travelledMeters + distance2D(sample.lastPosition, position)
    sample.lastPosition = position
    sample.maxRouteProgressMeters = math.max(sample.maxRouteProgressMeters, projection.alongMeters)
    sample.minRouteProgressMeters = math.min(sample.minRouteProgressMeters, projection.alongMeters)

    if now - sample.startedAt < (config.navigation.stuckWindowSeconds or 18) then
      return
    end

    local forwardProgress = sample.maxRouteProgressMeters - sample.startRouteProgressMeters
    local endProgress = projection.alongMeters - sample.startRouteProgressMeters
    local netMovement = distance2D(sample.startPosition, position)
    local efficiency = forwardProgress / math.max(1, sample.travelledMeters)
    local minimumTravel = config.navigation.minimumTravelMeters or 5
    local minimumProgress = config.navigation.minimumProgressMeters or 4
    local circularTravel = config.navigation.circularTravelMeters or 6
    local circularNet = config.navigation.circularNetMeters or 12
    local efficiencyFloor = config.navigation.routeEfficiencyFloor or 0.15
    local wrongWayMeters = config.navigation.wrongWayMeters or 12
    local crossTrackLimit = config.navigation.crossTrackLimitMeters or 60

    local stationary = sample.travelledMeters < minimumTravel
      and forwardProgress < minimumProgress
    local circular = sample.travelledMeters >= circularTravel
      and forwardProgress < minimumProgress
      and netMovement <= math.max(circularNet, sample.travelledMeters * 0.35)
    local wrongWay = endProgress <= -wrongWayMeters
    local offRoute = projection.crossTrackMeters >= crossTrackLimit
      and forwardProgress < minimumProgress
    local ineffective = sample.travelledMeters >= minimumTravel
      and forwardProgress < minimumProgress
      and efficiency < efficiencyFloor

    if ineffective and not circular and not wrongWay and not offRoute then
      task.navV5IneffectiveWindowCount = (task.navV5IneffectiveWindowCount or 0) + 1
    else
      task.navV5IneffectiveWindowCount = 0
    end
    local repeatedIneffective = task.navV5IneffectiveWindowCount
      >= (config.navigation.ineffectiveWindowLimit or 2)

    log("INFO", "watchdog_sample", {
      taskId = task.taskId,
      nextSiteId = task.path[task.currentLegIndex + 1],
      travelledMeters = string.format("%.1f", sample.travelledMeters),
      netMovementMeters = string.format("%.1f", netMovement),
      routeProgressMeters = string.format("%.1f", projection.alongMeters),
      forwardProgressMeters = string.format("%.1f", forwardProgress),
      endProgressMeters = string.format("%.1f", endProgress),
      crossTrackMeters = string.format("%.1f", projection.crossTrackMeters),
      routeEfficiency = string.format("%.3f", efficiency),
      stationary = stationary,
      circular = circular,
      wrongWay = wrongWay,
      offRoute = offRoute,
      ineffective = ineffective,
      ineffectiveWindowCount = task.navV5IneffectiveWindowCount or 0,
      recoveryCount = task.navRecoveryCount or 0,
    })

    local reason = nil
    if stationary then
      reason = "STATIONARY"
    elseif circular then
      reason = "CIRCULAR_MOVEMENT"
    elseif wrongWay then
      reason = "WRONG_WAY"
    elseif offRoute then
      reason = "OFF_ROUTE"
    elseif repeatedIneffective then
      reason = "NO_ROUTE_PROGRESS"
    end

    if reason then
      relocateTask(task, now, reason, projection, context)
    end

    local activeGroup = task.proxyGroup
    local activeContext = activeGroup and navigation.routeContextByGroupName[activeGroup:GetName()] or context
    local activePosition = activeGroup and vec3(activeGroup:GetCoordinate()) or position
    local activeProjection = activeContext and projectOnRoute(activeContext.coordinates, activePosition) or projection
    resetSample(task, now, activePosition, activeProjection)
  end

  function watchdog:attach()
    self.generation = self.generation + 1
    local generation = self.generation
    timer.scheduleFunction(function(_, scheduledTime)
      if generation ~= self.generation
        or executionState.completed == true
        or executionState.failed == true then
        return nil
      end
      local now = timer.getTime()
      for _, task in ipairs(executionState.tasks or {}) do
        watchTask(task, now)
      end
      return scheduledTime + (config.navigation.watchdogIntervalSeconds or 3)
    end, nil, timer.getTime() + (config.navigation.watchdogInitialDelaySeconds or 5))
    log("INFO", "watchdog_started", {
      engine = "ROUTE_PROGRESS_V5",
      intervalSeconds = config.navigation.watchdogIntervalSeconds,
      stuckWindowSeconds = config.navigation.stuckWindowSeconds,
      combatCooldownSeconds = config.navigation.combatCooldownSeconds,
      maxRecoveryAttempts = #(config.navigation.recoveryAdvanceSequenceMeters or {}),
      terminalRecoveryEnabled = true,
    })
    return true
  end

  if type(navigation) ~= "table" or navigation.valid ~= true then
    addError("NAVIGATION_INVALID", "navigation state unavailable or invalid")
  end
  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    addError("EXECUTION_INVALID", "execution state unavailable or invalid")
  end
  if type(SPAWN) ~= "table" or type(SPAWN.NewWithAlias) ~= "function" then
    addError("MOOSE_API_MISSING", "SPAWN.NewWithAlias")
  end
  if type(ARMYGROUP) ~= "table" or type(ARMYGROUP.New) ~= "function" then
    addError("MOOSE_API_MISSING", "ARMYGROUP.New")
  end

  log(watchdog.valid and "INFO" or "ERROR", "progress_watchdog_validation", {
    configurationVersion = config.configurationVersion,
    valid = watchdog.valid,
    errorCount = #watchdog.errors,
  })
  return watchdog
end

TM02W2EProgressWatchdogV5.projectOnRoute = projectOnRoute
TM02W2EProgressWatchdogV5.sliceRouteFromDistance = sliceRouteFromDistance

return TM02W2EProgressWatchdogV5
