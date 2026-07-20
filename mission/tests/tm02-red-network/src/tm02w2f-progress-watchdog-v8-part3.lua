        taskId = task.taskId,
        strategy = strategy,
        reason = reason,
        offroadRelocations = monitor.offroadRelocations,
      })
      return true
    end
    log("ERROR", "recovery_failed", {
      taskId = task.taskId,
      strategy = strategy,
      reason = reason,
      failure = failure,
    })
    monitor.nextRecoveryAt = now + cfg.perTaskRecoveryCooldownSeconds
    if strategy == "TERMINAL_DIRECT_OFFROAD" then
      monitor.terminalRecoveryUsed = true
    end
    if strategy == "ROAD_RECOVERY_TO_LEG_TARGET" then
      monitor.roadRecoveryUsed = true
      blocked(task, monitor, context, reason, failure)
    end
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
    local current = group:GetCoordinate()
    local projection = projectOnSegment(context.source, context.target, current)
    if not projection then return end
    local remaining = distance2D(current, context.target)
    local monitor = monitorFor(task)

    if monitor.legKey ~= context.key then
      monitor.legKey = context.key
      monitor.groupName = group:GetName()
      monitor.offroadRelocations = 0
      monitor.roadRecoveryUsed = false
      monitor.terminalRecoveryUsed = false
      monitor.recoveryAnchorDistance = nil
      monitor.highestAlong = projection.alongMeters
      monitor.blockedLogged = false
      monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
      task.navigationState = "DIRECT_OFFROAD"
      resetSample(monitor, now, current, projection, remaining)
      return
    end

    if monitor.groupName ~= group:GetName() then
      monitor.groupName = group:GetName()
      monitor.graceUntil = now + cfg.postRecoveryGraceSeconds
      resetSample(monitor, now, current, projection, remaining)
      return
    end

    monitor.highestAlong = math.max(monitor.highestAlong or 0, projection.alongMeters)
    if monitor.recoveryAnchorDistance
      and monitor.recoveryAnchorDistance - remaining >= cfg.episodeResetProgressMeters then
      monitor.offroadRelocations = 0
      monitor.roadRecoveryUsed = false
      monitor.terminalRecoveryUsed = false
      monitor.recoveryAnchorDistance = nil
      monitor.blockedLogged = false
      monitor.episode = monitor.episode + 1
      task.navigationState = "DIRECT_OFFROAD"
      log("INFO", "recovery_episode_cleared", { taskId = task.taskId, episode = monitor.episode })
    end

    if task.navCombatUntil and task.navCombatUntil > now then
      task.navigationState = "COMBAT_HOLD"
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
    local reason = stationary and "STATIONARY"
      or (circular and "CIRCULAR_MOVEMENT")
      or (wrongWay and "WRONG_WAY")
      or (offRoute and "OFF_ROUTE")
      or nil

    resetSample(monitor, now, current, projection, remaining)
    if not reason then return end
    state.stallCount = state.stallCount + 1
    log("WARNING", "stall_detected", {
      taskId = task.taskId,
      reason = reason,
      remainingDistanceMeters = string.format("%.1f", remaining),
      offroadRelocations = monitor.offroadRelocations,
      roadRecoveryUsed = monitor.roadRecoveryUsed,
    })
    if task.navigationState ~= "NAVIGATION_BLOCKED" then
      recover(task, monitor, context, projection, now, reason)
    end
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
      maxOffroadRelocationsPerEpisode = cfg.maxOffroadRelocationsPerEpisode,
      relocationAdvanceMeters = cfg.relocationAdvanceMeters,
      terminalRecoveryThresholdMeters = cfg.terminalRecoveryThresholdMeters,
      roadRecoveryAfterRelocations = true,
      representationSwitchingAllowed = false,
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
    packUnpackRecoveryAllowed = false,
    errorCount = #state.errors,
  })
  if state.valid then start() end
  return state
end

TM02W2FProgressWatchdog.projectOnSegment = projectOnSegment
TM02W2FProgressWatchdog.coordinateAtDistance = coordinateAtDistance

return TM02W2FProgressWatchdog
