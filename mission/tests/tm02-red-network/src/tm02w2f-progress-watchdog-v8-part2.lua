    monitor.maxAlong = projection.alongMeters
  end

  local function assignRoute(group, task, coordinates, formations, mode, reason)
    if #coordinates ~= #formations
      or #coordinates > config.routing.maximumPhysicalWaypointsPerLeg then
      return false, "WAYPOINT_LIMIT"
    end
    local waypoints = {}
    for index, item in ipairs(coordinates) do
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
    })
    return true
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
    local current = math.max(projection.alongMeters, monitor.highestAlong or 0)
    local requested = terminal
      and math.max(current, projection.totalMeters - cfg.terminalRecoveryOffsetMeters)
      or math.min(projection.totalMeters - cfg.terminalRecoveryOffsetMeters,
        current + cfg.relocationAdvanceMeters)
    if requested <= current + 0.5 then return false, "NO_FORWARD_RECOVERY_POINT" end
    local recovery = coordinateAtDistance(context.source, context.target, requested)
    if not recovery then return false, "RECOVERY_POINT_MISSING" end

    local alias = replacementAlias(task, terminal)
    local template = config.templatesByStrength[task.survivorCount or task.strength]
    local ok, replacement = pcall(function()
      return SPAWN:NewWithAlias(template, alias):SpawnFromCoordinate(recovery)
    end)
    if not ok or not replacement then return false, tostring(replacement) end
    local expected = task.transitExpanded == true
      and (task.survivorCount or task.strength) or config.proxy.expectedUnitCount
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
    monitor.recoveryAnchorDistance = distance2D(recovery, context.target)
    monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
    monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    resetSample(monitor, now, recovery, { alongMeters = requested }, monitor.recoveryAnchorDistance)
    if terminal then
      monitor.terminalRecoveryUsed = true
      state.terminalRecoveryCount = state.terminalRecoveryCount + 1
      task.navigationState = "RECOVERING_TERMINAL_DIRECT_OFFROAD"
    else
      monitor.offroadRelocations = monitor.offroadRelocations + 1
      state.relocationCount = state.relocationCount + 1
      task.navigationState = "RECOVERING_DIRECT_OFFROAD_RELOCATION"
    end
    log(terminal and "WARNING" or "INFO",
      terminal and "proxy_relocated_terminal_safe_path" or "proxy_relocated_along_safe_path", {
        taskId = task.taskId,
        reason = reason,
        oldGroupName = oldName,
        runtimeGroupName = replacement:GetName(),
        requestedRouteProgressMeters = string.format("%.1f", requested),
        remainingDistanceMeters = string.format("%.1f", projection.totalMeters - requested),
        offroadRelocations = monitor.offroadRelocations,
        representationPreserved = true,
      })
    return true
  end

  local function roadRecovery(task, monitor, context, now, reason)
    local group = activeGroup(task)
    local current = group and group:GetCoordinate() or nil
    if not current or type(current.GetClosestPointToRoad) ~= "function"
      or type(context.target.GetClosestPointToRoad) ~= "function" then
      return false, "ROAD_API_UNAVAILABLE"
    end
    local entryOk, entry = pcall(function() return current:GetClosestPointToRoad() end)
    local exitOk, exit = pcall(function() return context.target:GetClosestPointToRoad() end)
    if not entryOk or not exitOk or not entry or not exit then
      return false, "ROAD_POINT_UNAVAILABLE"
    end
    if distance2D(current, entry) > cfg.maximumRoadSnapDistanceMeters
      or distance2D(context.target, exit) > cfg.maximumRoadSnapDistanceMeters then
      return false, "ROAD_SNAP_TOO_FAR"
    end
    if distance2D(entry, exit) < cfg.minimumRoadSegmentMeters then
      return false, "ROAD_SEGMENT_TOO_SHORT"
    end
    local routed, routeError = assignRoute(group, task,
      { current, entry, exit, context.target },
      { config.routing.offRoadFormation, config.routing.roadFormation,
        config.routing.roadFormation, config.routing.offRoadFormation },
      "ROAD_RECOVERY_TO_LEG_TARGET", reason)
    if not routed then return false, routeError end
    monitor.roadRecoveryUsed = true
    monitor.recoveryAnchorDistance = distance2D(current, context.target)
    monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
    monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    task.navigationState = "RECOVERING_ROAD_TO_LEG_TARGET"
    state.roadRecoveryCount = state.roadRecoveryCount + 1
    log("WARNING", "road_recovery_applied", {
      taskId = task.taskId,
      reason = reason,
      waypointCount = 4,
      groupName = group:GetName(),
      representationPreserved = true,
    })
    return true
  end

  local function blocked(task, monitor, context, reason, failure)
    task.navigationState = "NAVIGATION_BLOCKED"
    if monitor.blockedLogged then return end
    monitor.blockedLogged = true
    state.blockedCount = state.blockedCount + 1
    log("ERROR", "navigation_blocked", {
      taskId = task.taskId,
      leg = context.key,
      reason = reason,
      failure = failure,
      offroadRelocations = monitor.offroadRelocations,
      roadRecoveryUsed = monitor.roadRecoveryUsed,
      accountingPreserved = true,
    })
  end

  local function recover(task, monitor, context, projection, now, reason)
    if now < state.nextGlobalRecoveryAt or now < monitor.nextRecoveryAt then return false end
    if task.navCombatUntil and task.navCombatUntil > now then return false end
    local remaining = projection.totalMeters - projection.alongMeters
    local success, failure, strategy
    if remaining <= cfg.terminalRecoveryThresholdMeters
      and remaining > cfg.terminalRecoveryOffsetMeters
      and not monitor.terminalRecoveryUsed then
      strategy = "TERMINAL_DIRECT_OFFROAD"
      success, failure = relocate(task, monitor, context, projection, now, true, reason)
    elseif monitor.offroadRelocations < cfg.maxOffroadRelocationsPerEpisode then
      strategy = "DIRECT_OFFROAD_RELOCATION_75M"
      local before = monitor.offroadRelocations
      success, failure = relocate(task, monitor, context, projection, now, false, reason)
      if not success then monitor.offroadRelocations = before + 1 end
    elseif not monitor.roadRecoveryUsed then
      strategy = "ROAD_RECOVERY_TO_LEG_TARGET"
      success, failure = roadRecovery(task, monitor, context, now, reason)
    else
      blocked(task, monitor, context, reason, "RECOVERY_EXHAUSTED")
      return false
    end
    state.nextGlobalRecoveryAt = now + cfg.globalRecoveryIntervalSeconds
    if success then
      log("WARNING", "recovery_applied", {
