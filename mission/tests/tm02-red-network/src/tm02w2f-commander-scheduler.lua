local TM02W2FCommanderScheduler = {}

local function firstEdgeKey(task)
  if type(task.path) ~= "table" or #task.path < 2 then return "INVALID" end
  return tostring(task.path[1]) .. ">" .. tostring(task.path[2])
end

function TM02W2FCommanderScheduler.install(config, executionState, navigation, plannerState)
  local commanderConfig = config.commanderTest or {}
  local state = {
    valid = true,
    errors = {},
    running = false,
    cycleCount = 0,
    orderedTaskCount = 0,
    releasedTaskCount = 0,
    lastReleaseMissionTime = -math.huge,
    nativeStartExecution = executionState and executionState.startExecution or nil,
    canaryTaskId = nil,
    canaryReleasedAt = nil,
    canaryPassed = false,
    canaryFailed = false,
    canaryProgressMeters = 0,
    scheduler = nil,
    planningScheduler = nil,
    movementLimiter = nil,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM02W2F][COMMANDER] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function announce(text)
    if config.debug and config.debug.showMessages == true then
      MESSAGE:New(tostring(text), 16, "OMW TEST"):ToAll()
    end
  end

  local function addError(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "commander_scheduler_error", { code = code, detail = detail })
  end

  if type(SCHEDULER) ~= "table" or type(SCHEDULER.New) ~= "function" then
    addError("MOOSE_SCHEDULER_MISSING", "SCHEDULER:New unavailable")
  end
  if type(MOVEMENT) ~= "table" or type(MOVEMENT.New) ~= "function" then
    addError("MOOSE_MOVEMENT_MISSING", "MOVEMENT:New unavailable")
  end
  if type(MESSAGE) ~= "table" or type(MESSAGE.New) ~= "function" then
    addError("MOOSE_MESSAGE_MISSING", "MESSAGE:New unavailable")
  end
  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    addError("EXECUTION_INVALID", "execution state unavailable or invalid")
  end
  if type(navigation) ~= "table" or navigation.valid ~= true or navigation.routingReady ~= true then
    addError("NAVIGATION_INVALID", "navigation unavailable or invalid")
  end
  if type(state.nativeStartExecution) ~= "function" then
    addError("EXECUTION_START_MISSING", type(state.nativeStartExecution))
  end

  local function countState(name)
    local count = 0
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == name then count = count + 1 end
    end
    return count
  end

  local function taskCoordinate(task)
    if task.proxyGroup and task.proxyGroup:IsAlive() == true then
      return task.proxyGroup:GetCoordinate()
    end
    return task.currentCoordinate
  end

  local function distance2D(first, second)
    if not first or not second then return 0 end
    local a = type(first.GetVec3) == "function" and first:GetVec3() or first
    local b = type(second.GetVec3) == "function" and second:GetVec3() or second
    if not a or not b then return 0 end
    local ax, az = a.x, a.z or a.y
    local bx, bz = b.x, b.z or b.y
    if not ax or not az or not bx or not bz then return 0 end
    local dx, dz = bx - ax, bz - az
    return math.sqrt(dx * dx + dz * dz)
  end

  local function updateLaunchTracking(now)
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "EN_ROUTE" and not task.commanderLaunchedAt then
        task.commanderLaunchedAt = now
        task.commanderLaunchCoordinate = taskCoordinate(task)
        task.commanderFirstEdgeKey = firstEdgeKey(task)
        log("INFO", "transport_launch_observed", { taskId = task.taskId, firstEdge = task.commanderFirstEdgeKey })
      end
    end
  end

  local function taskProgressFromLaunch(task)
    return distance2D(task.commanderLaunchCoordinate, taskCoordinate(task))
  end

  local function updateCanary(now)
    if state.canaryPassed or state.canaryFailed or not state.canaryTaskId then return end
    local task = executionState.taskById and executionState.taskById[state.canaryTaskId] or nil
    if not task then
      state.canaryFailed = true
      state.running = false
      return
    end
    if task.movementState == "EN_ROUTE" and task.commanderLaunchCoordinate then
      state.canaryProgressMeters = taskProgressFromLaunch(task)
      if state.canaryProgressMeters >= commanderConfig.canaryProgressMeters then
        state.canaryPassed = true
        announce("TM02W2F Canary PASS: weitere Transporte werden freigegeben")
        log("INFO", "canary_passed", { taskId = task.taskId, progressMeters = state.canaryProgressMeters })
        return
      end
    end
    if state.canaryReleasedAt and now - state.canaryReleasedAt >= commanderConfig.canaryTimeoutSeconds then
      state.canaryFailed = true
      state.running = false
      announce("TM02W2F Canary FAIL: keine weiteren Transporte werden erzeugt")
      log("ERROR", "canary_failed", { taskId = task.taskId, progressMeters = state.canaryProgressMeters })
    end
  end

  local function firstEdgeOccupants(edgeKey)
    local result = {}
    for _, task in ipairs(executionState.tasks or {}) do
      if task.currentLegIndex == 1 and firstEdgeKey(task) == edgeKey
        and (task.movementState == "QUEUED" or task.movementState == "SPAWNING" or task.movementState == "EN_ROUTE") then
        result[#result + 1] = task
      end
    end
    return result
  end

  local function predecessorAllowsLaunch(task)
    local occupants = firstEdgeOccupants(firstEdgeKey(task))
    if #occupants == 0 then return true, "EDGE_EMPTY" end
    if #occupants >= commanderConfig.maxActiveTransportsPerFirstEdge then return false, "EDGE_LIMIT" end
    local predecessor = occupants[#occupants]
    if predecessor.movementState ~= "EN_ROUTE" or not predecessor.commanderLaunchCoordinate then
      return false, "PREDECESSOR_NOT_MOVING"
    end
    if taskProgressFromLaunch(predecessor) >= commanderConfig.minimumPredecessorProgressMeters then
      return true, "PREDECESSOR_PROGRESS"
    end
    return false, "PREDECESSOR_TOO_CLOSE"
  end

  local function plannedTasks()
    local result = {}
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "PLANNED" then result[#result + 1] = task end
    end
    table.sort(result, function(a, b) return tostring(a.taskId) < tostring(b.taskId) end)
    return result
  end

  local function orderCycle(now)
    if not state.running then return end
    state.cycleCount = state.cycleCount + 1
    local ordered = 0
    for _, task in ipairs(plannedTasks()) do
      if ordered >= commanderConfig.commandBudgetPerCycle then break end
      task.movementState = "ORDERED"
      task.commanderState = "ORDERED"
      task.commanderOrderedAt = now
      task.commanderCycle = state.cycleCount
      ordered = ordered + 1
      state.orderedTaskCount = state.orderedTaskCount + 1
    end
    log("INFO", "commander_cycle_completed", { cycle = state.cycleCount, ordersIssued = ordered, plannedRemaining = countState("PLANNED") })
  end

  local function releaseOne(now, forceCanary)
    if not state.running then return false end
    if not forceCanary and not state.canaryPassed then return false end
    if not forceCanary and now - state.lastReleaseMissionTime < commanderConfig.spawnIntervalSeconds then return false end
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "ORDERED" then
        local allowed, reason = forceCanary and true or predecessorAllowsLaunch(task)
        if allowed then
          task.movementState = "QUEUED"
          task.commanderState = "LAUNCH_PENDING"
          task.commanderReleaseReason = forceCanary and "CANARY" or reason
          task.commanderReleasedAt = now
          state.lastReleaseMissionTime = now
          state.releasedTaskCount = state.releasedTaskCount + 1
          if forceCanary then
            state.canaryTaskId = task.taskId
            state.canaryReleasedAt = now
          end
          log("INFO", "transport_released_to_executor", { taskId = task.taskId, releaseReason = task.commanderReleaseReason })
          return true
        end
      end
    end
    return false
  end

  local function stopSchedulers()
    if state.scheduler then state.scheduler:Stop() end
    if state.planningScheduler then state.planningScheduler:Stop() end
    if state.movementLimiter then state.movementLimiter:ScheduleStop() end
  end

  local function serviceTick()
    if not state.running or executionState.completed == true or executionState.failed == true then
      state.running = false
      stopSchedulers()
      return
    end
    local now = timer.getTime()
    updateLaunchTracking(now)
    updateCanary(now)
    releaseOne(now, false)
  end

  local function startCommander()
    if state.running or executionState.started then return false end
    if not state.valid then return false end
    state.running = true
    orderCycle(timer.getTime())
    if releaseOne(timer.getTime(), true) ~= true then state.running = false return false end
    if state.nativeStartExecution() ~= true then state.running = false return false end

    state.movementLimiter = MOVEMENT:New({
      config.proxy.runtimeAliasPrefix,
      config.physical.transitRuntimeAliasPrefix,
    }, commanderConfig.maxActiveTransportsGlobal)
    state.movementLimiter:ScheduleStart()

    state.scheduler = SCHEDULER:New(nil, serviceTick, {}, commanderConfig.schedulerTickSeconds, commanderConfig.schedulerTickSeconds)
    state.planningScheduler = SCHEDULER:New(nil, function()
      if state.running and countState("PLANNED") > 0 then orderCycle(timer.getTime()) end
    end, {}, commanderConfig.planningIntervalSeconds, commanderConfig.planningIntervalSeconds)

    log("INFO", "moose_commander_started", {
      scheduler = "SCHEDULER",
      movementLimiter = "MOVEMENT",
      maxMovingGround = commanderConfig.maxActiveTransportsGlobal,
      perFirstEdgeLimit = commanderConfig.maxActiveTransportsPerFirstEdge,
    })
    announce("TM02W2F MOOSE Commander gestartet")
    return true
  end

  local function showStatus()
    announce(table.concat({
      "TM02W2F MOOSE Commander",
      "Running: " .. tostring(state.running),
      "Canary passed: " .. tostring(state.canaryPassed),
      "Planned: " .. tostring(countState("PLANNED")),
      "Ordered: " .. tostring(countState("ORDERED")),
      "Queued: " .. tostring(countState("QUEUED")),
      "En route: " .. tostring(countState("EN_ROUTE")),
      "Arrived: " .. tostring(countState("ARRIVED")),
    }, "\n"))
  end

  if state.valid then
    for _, task in ipairs(executionState.tasks or {}) do
      task.movementState = "PLANNED"
      task.commanderState = "PLANNED"
      task.commanderFirstEdgeKey = firstEdgeKey(task)
    end
    executionState.startExecution = startCommander
    executionState.showCommanderStatus = showStatus
  end

  state.start = startCommander
  state.showStatus = showStatus
  state.stop = stopSchedulers
  log(state.valid and "INFO" or "ERROR", "commander_scheduler_validation", {
    valid = state.valid,
    scheduler = "MOOSE_SCHEDULER",
    movementLimiter = "MOOSE_MOVEMENT",
    errorCount = #state.errors,
  })
  return state
end

return TM02W2FCommanderScheduler
