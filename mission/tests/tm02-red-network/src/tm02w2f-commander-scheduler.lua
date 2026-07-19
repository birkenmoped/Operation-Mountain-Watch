local TM02W2FCommanderScheduler = {}

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
  if not a or not b then return 0 end
  local dx, dz = b.x - a.x, b.z - a.z
  return math.sqrt(dx * dx + dz * dz)
end

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
    generation = 0,
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
      trigger.action.outText(text, 16)
    end
  end

  local function addError(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "commander_scheduler_error", { code = code, detail = detail })
  end

  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    addError("EXECUTION_INVALID", "execution state unavailable or invalid")
  end
  if type(navigation) ~= "table" or navigation.valid ~= true or navigation.routingReady ~= true then
    addError("NAVIGATION_INVALID", "direct off-road navigation unavailable or invalid")
  end
  if type(state.nativeStartExecution) ~= "function" then
    addError("EXECUTION_START_MISSING", type(state.nativeStartExecution))
  end

  local requiredNumbers = {
    planningIntervalSeconds = commanderConfig.planningIntervalSeconds,
    commandBudgetPerCycle = commanderConfig.commandBudgetPerCycle,
    maxActiveTransportsGlobal = commanderConfig.maxActiveTransportsGlobal,
    maxActiveTransportsPerFirstEdge = commanderConfig.maxActiveTransportsPerFirstEdge,
    spawnIntervalSeconds = commanderConfig.spawnIntervalSeconds,
    minimumPredecessorProgressMeters = commanderConfig.minimumPredecessorProgressMeters,
    schedulerTickSeconds = commanderConfig.schedulerTickSeconds,
    canaryProgressMeters = commanderConfig.canaryProgressMeters,
    canaryTimeoutSeconds = commanderConfig.canaryTimeoutSeconds,
  }
  for name, value in pairs(requiredNumbers) do
    if type(value) ~= "number" or value <= 0 then
      addError("CONFIG_INVALID", name .. "=" .. tostring(value))
    end
  end

  local function countState(name)
    local count = 0
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == name then count = count + 1 end
    end
    return count
  end

  local function activeGlobalCount()
    local count = 0
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "QUEUED"
        or task.movementState == "SPAWNING"
        or task.movementState == "EN_ROUTE" then
        count = count + 1
      end
    end
    return count
  end

  local function logicalPathDistance(task)
    local total = 0
    for index = 1, #(task.path or {}) - 1 do
      local plan = navigation:getLegPlan(task.path[index], task.path[index + 1])
      total = total + (plan and plan.lengthMeters or 100000000)
    end
    return total
  end

  local function targetPriority(task)
    if tostring(task.targetSiteId):find("SUBHQ", 1, true) then return 0 end
    local inventory = plannerState.inventoryBySiteId[task.targetSiteId]
    local target = inventory and inventory.defensiveTarget or task.strength
    return 100 - target
  end

  local function plannedTasks()
    local result = {}
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "PLANNED" then result[#result + 1] = task end
    end
    table.sort(result, function(first, second)
      local firstPriority, secondPriority = targetPriority(first), targetPriority(second)
      if firstPriority ~= secondPriority then return firstPriority < secondPriority end
      local firstDistance, secondDistance = logicalPathDistance(first), logicalPathDistance(second)
      if firstDistance ~= secondDistance then return firstDistance < secondDistance end
      return first.taskId < second.taskId
    end)
    return result
  end

  local function taskCoordinate(task)
    if task.proxyGroup and task.proxyGroup:IsAlive() == true then
      return vec3(task.proxyGroup:GetCoordinate())
    end
    return vec3(task.currentCoordinate)
  end

  local function updateLaunchTracking(now)
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "EN_ROUTE" then
        task.commanderState = "EN_ROUTE"
        if not task.commanderLaunchedAt then
          task.commanderLaunchedAt = now
          task.commanderLaunchCoordinate = taskCoordinate(task)
          task.commanderFirstEdgeKey = firstEdgeKey(task)
          log("INFO", "transport_launch_observed", {
            taskId = task.taskId,
            firstEdge = task.commanderFirstEdgeKey,
            activeGlobal = activeGlobalCount(),
          })
        end
      elseif task.movementState == "ARRIVED" then
        task.commanderState = "ARRIVED"
      elseif task.movementState == "DESTROYED" or task.movementState == "FAILED" then
        task.commanderState = task.movementState
      end
    end
  end

  local function taskProgressFromLaunch(task)
    if not task or not task.commanderLaunchCoordinate then return 0 end
    return distance2D(task.commanderLaunchCoordinate, taskCoordinate(task))
  end

  local function updateCanary(now)
    if state.canaryPassed or state.canaryFailed or not state.canaryTaskId then return end
    local task = executionState.taskById and executionState.taskById[state.canaryTaskId] or nil
    if not task then
      state.canaryFailed = true
      state.running = false
      log("ERROR", "canary_failed", { reason = "TASK_MISSING", taskId = state.canaryTaskId })
      return
    end

    if task.movementState == "EN_ROUTE" and task.commanderLaunchCoordinate then
      state.canaryProgressMeters = taskProgressFromLaunch(task)
      if state.canaryProgressMeters >= commanderConfig.canaryProgressMeters then
        state.canaryPassed = true
        log("INFO", "canary_passed", {
          taskId = task.taskId,
          progressMeters = string.format("%.1f", state.canaryProgressMeters),
          requiredProgressMeters = commanderConfig.canaryProgressMeters,
          groupName = task.proxyGroupName or "none",
        })
        announce("TM02W2F Canary PASS: weitere Transporte werden freigegeben")
        return
      end
    end

    if state.canaryReleasedAt and now - state.canaryReleasedAt >= commanderConfig.canaryTimeoutSeconds then
      state.canaryFailed = true
      state.running = false
      log("ERROR", "canary_failed", {
        taskId = task.taskId,
        movementState = task.movementState,
        progressMeters = string.format("%.1f", state.canaryProgressMeters),
        timeoutSeconds = commanderConfig.canaryTimeoutSeconds,
        additionalSpawnsPrevented = true,
      })
      announce("TM02W2F Canary FAIL: keine weiteren Transporte werden erzeugt")
    end
  end

  local function firstEdgeOccupants(edgeKey)
    local result = {}
    for _, task in ipairs(executionState.tasks or {}) do
      if task.currentLegIndex == 1
        and firstEdgeKey(task) == edgeKey
        and (task.movementState == "QUEUED"
          or task.movementState == "SPAWNING"
          or task.movementState == "EN_ROUTE") then
        result[#result + 1] = task
      end
    end
    table.sort(result, function(first, second)
      return (first.commanderReleasedAt or 0) < (second.commanderReleasedAt or 0)
    end)
    return result
  end

  local function predecessorAllowsLaunch(task, now)
    local occupants = firstEdgeOccupants(firstEdgeKey(task))
    if #occupants == 0 then return true, "EDGE_EMPTY" end
    if #occupants >= commanderConfig.maxActiveTransportsPerFirstEdge then
      return false, "EDGE_LIMIT"
    end
    local predecessor = occupants[#occupants]
    if predecessor.movementState ~= "EN_ROUTE" or not predecessor.commanderLaunchCoordinate then
      return false, "PREDECESSOR_NOT_MOVING"
    end
    local progress = taskProgressFromLaunch(predecessor)
    if progress >= commanderConfig.minimumPredecessorProgressMeters then
      return true, "PREDECESSOR_PROGRESS"
    end
    local age = predecessor.commanderLaunchedAt and (now - predecessor.commanderLaunchedAt) or 0
    if age >= (commanderConfig.launchHoldWarningSeconds or 60)
      and predecessor.commanderHoldWarningLogged ~= true then
      predecessor.commanderHoldWarningLogged = true
      log("WARNING", "transport_launch_held_for_spacing", {
        taskId = task.taskId,
        predecessorTaskId = predecessor.taskId,
        firstEdge = firstEdgeKey(task),
        predecessorProgressMeters = string.format("%.1f", progress),
        requiredProgressMeters = commanderConfig.minimumPredecessorProgressMeters,
        holdSeconds = string.format("%.1f", age),
      })
    end
    return false, "PREDECESSOR_TOO_CLOSE"
  end

  local function orderCycle(now)
    if not state.running then return 0 end
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
      log("INFO", "transport_order_issued", {
        taskId = task.taskId,
        cycle = state.cycleCount,
        targetSiteId = task.targetSiteId,
        strength = task.strength,
        firstEdge = firstEdgeKey(task),
        safeNetworkDistanceMeters = string.format("%.0f", logicalPathDistance(task)),
        physicalMode = "DIRECT_OFFROAD",
      })
    end
    log("INFO", "commander_cycle_completed", {
      cycle = state.cycleCount,
      budget = commanderConfig.commandBudgetPerCycle,
      ordersIssued = ordered,
      plannedRemaining = countState("PLANNED"),
      orderedWaiting = countState("ORDERED"),
      activeGlobal = activeGlobalCount(),
    })
    return ordered
  end

  local function releaseOne(now, forceCanary)
    if not state.running then return false end
    if not forceCanary and not state.canaryPassed then return false end
    if activeGlobalCount() >= commanderConfig.maxActiveTransportsGlobal then return false end
    if not forceCanary and now - state.lastReleaseMissionTime < commanderConfig.spawnIntervalSeconds then
      return false
    end

    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "ORDERED" then
        local allowed, reason = forceCanary and true or predecessorAllowsLaunch(task, now)
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
          log("INFO", "transport_released_to_executor", {
            taskId = task.taskId,
            cycle = task.commanderCycle,
            firstEdge = firstEdgeKey(task),
            releaseReason = task.commanderReleaseReason,
            activeGlobalBeforeDispatch = activeGlobalCount(),
            orderedWaiting = countState("ORDERED"),
            canary = forceCanary,
          })
          return true
        end
      end
    end
    return false
  end

  local function schedulerTick(_, scheduledTime)
    if not state.running or executionState.completed == true or executionState.failed == true then
      return nil
    end
    local now = timer.getTime()
    updateLaunchTracking(now)
    updateCanary(now)
    if not state.running then return nil end
    releaseOne(now, false)
    return timer.getTime() + commanderConfig.schedulerTickSeconds
  end

  local function commanderCycleTick(_, scheduledTime)
    if not state.running or executionState.completed == true or executionState.failed == true then
      return nil
    end
    if countState("PLANNED") == 0 then
      log("INFO", "commander_planning_complete", {
        cycle = state.cycleCount,
        orderedTaskCount = state.orderedTaskCount,
      })
      return nil
    end
    orderCycle(timer.getTime())
    return timer.getTime() + commanderConfig.planningIntervalSeconds
  end

  local function startCommander()
    if state.running or executionState.started then
      announce("TM02W2F Commander start rejected: already running")
      return false
    end
    if not state.valid then
      announce("TM02W2F Commander start rejected: validation failed")
      return false
    end

    state.running = true
    state.generation = state.generation + 1
    local now = timer.getTime()
    orderCycle(now)
    if releaseOne(now, true) ~= true then
      state.running = false
      announce("TM02W2F Commander start rejected: Canary konnte nicht freigegeben werden")
      return false
    end

    local started = state.nativeStartExecution()
    if started ~= true then
      state.running = false
      return false
    end

    timer.scheduleFunction(schedulerTick, nil, timer.getTime() + commanderConfig.schedulerTickSeconds)
    timer.scheduleFunction(commanderCycleTick, nil, timer.getTime() + commanderConfig.planningIntervalSeconds)
    log("INFO", "direct_offroad_commander_started", {
      planningIntervalSeconds = commanderConfig.planningIntervalSeconds,
      commandBudgetPerCycle = commanderConfig.commandBudgetPerCycle,
      maxActiveTransportsGlobal = commanderConfig.maxActiveTransportsGlobal,
      maxActiveTransportsPerFirstEdge = commanderConfig.maxActiveTransportsPerFirstEdge,
      spawnIntervalSeconds = commanderConfig.spawnIntervalSeconds,
      canaryTaskId = state.canaryTaskId,
      canaryProgressMeters = commanderConfig.canaryProgressMeters,
      canaryTimeoutSeconds = commanderConfig.canaryTimeoutSeconds,
      physicalMode = "DIRECT_OFFROAD",
      roadsUsed = false,
      automaticRecoveryEnabled = false,
    })
    announce("TM02W2F: direkter Off-Road-Canary gestartet")
    return true
  end

  local function showStatus()
    updateLaunchTracking(timer.getTime())
    updateCanary(timer.getTime())
    local text = table.concat({
      "TM02W2F Direct Commander",
      "Running: " .. tostring(state.running),
      "Canary: " .. tostring(state.canaryTaskId or "none"),
      "Canary passed: " .. tostring(state.canaryPassed),
      "Canary failed: " .. tostring(state.canaryFailed),
      "Canary progress: " .. string.format("%.1f", state.canaryProgressMeters) .. " m",
      "Cycles: " .. tostring(state.cycleCount),
      "Planned: " .. tostring(countState("PLANNED")),
      "Ordered: " .. tostring(countState("ORDERED")),
      "Launch pending: " .. tostring(countState("QUEUED")),
      "Active: " .. tostring(activeGlobalCount()),
      "Arrived: " .. tostring(countState("ARRIVED")),
    }, "\n")
    announce(text)
    log("INFO", "commander_status", {
      running = state.running,
      canaryTaskId = state.canaryTaskId or "none",
      canaryPassed = state.canaryPassed,
      canaryFailed = state.canaryFailed,
      canaryProgressMeters = string.format("%.1f", state.canaryProgressMeters),
      cycleCount = state.cycleCount,
      plannedCount = countState("PLANNED"),
      orderedCount = countState("ORDERED"),
      queuedCount = countState("QUEUED"),
      activeGlobal = activeGlobalCount(),
      arrivedCount = countState("ARRIVED"),
    })
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
  log(state.valid and "INFO" or "ERROR", "commander_scheduler_validation", {
    configurationVersion = config.configurationVersion,
    valid = state.valid,
    taskCount = #(executionState.tasks or {}),
    canaryGateEnabled = true,
    timerCatchUpDisabled = true,
    physicalMode = "DIRECT_OFFROAD",
    errorCount = #state.errors,
  })
  return state
end

return TM02W2FCommanderScheduler
