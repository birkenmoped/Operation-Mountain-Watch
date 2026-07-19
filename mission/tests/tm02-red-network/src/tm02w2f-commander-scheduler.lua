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

local function pairKey(firstId, secondId)
  if firstId < secondId then return firstId .. "\0" .. secondId end
  return secondId .. "\0" .. firstId
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
  if type(navigation) ~= "table" or navigation.valid ~= true then
    addError("NAVIGATION_INVALID", "navigation unavailable or invalid")
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
    maximumLaunchHoldSeconds = commanderConfig.maximumLaunchHoldSeconds,
  }
  for name, value in pairs(requiredNumbers) do
    if type(value) ~= "number" or value <= 0 then addError("CONFIG_INVALID", name .. "=" .. tostring(value)) end
  end

  local function logicalPathDistance(task)
    local total = 0
    for index = 1, #(task.path or {}) - 1 do
      local plan = navigation.planByPair[pairKey(task.path[index], task.path[index + 1])]
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
      if task.movementState == "SPAWNING" or task.movementState == "EN_ROUTE" or task.movementState == "QUEUED" then
        count = count + 1
      end
    end
    return count
  end

  local function updateLaunchTracking(now)
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "EN_ROUTE" then
        task.commanderState = "EN_ROUTE"
        if not task.commanderLaunchedAt then
          task.commanderLaunchedAt = now
          task.commanderLaunchCoordinate = vec3(task.currentCoordinate)
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

  local function firstEdgeOccupants(edgeKey)
    local result = {}
    for _, task in ipairs(executionState.tasks or {}) do
      if task.currentLegIndex == 1
        and firstEdgeKey(task) == edgeKey
        and (task.movementState == "QUEUED" or task.movementState == "SPAWNING" or task.movementState == "EN_ROUTE") then
        result[#result + 1] = task
      end
    end
    return result
  end

  local function predecessorAllowsLaunch(task, now)
    local occupants = firstEdgeOccupants(firstEdgeKey(task))
    if #occupants == 0 then return true, "EDGE_EMPTY" end
    if #occupants >= commanderConfig.maxActiveTransportsPerFirstEdge then return false, "EDGE_LIMIT" end

    local predecessor = occupants[#occupants]
    local progress = distance2D(predecessor.commanderLaunchCoordinate, predecessor.currentCoordinate)
    local age = predecessor.commanderLaunchedAt and (now - predecessor.commanderLaunchedAt) or 0
    if progress >= commanderConfig.minimumPredecessorProgressMeters then
      return true, "PREDECESSOR_PROGRESS"
    end
    if age >= commanderConfig.maximumLaunchHoldSeconds then
      return true, "MAXIMUM_HOLD_EXPIRED"
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
        safeRouteDistanceMeters = string.format("%.0f", logicalPathDistance(task)),
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

  local function releaseOne(now, forceFirst)
    if not state.running then return false end
    if activeGlobalCount() >= commanderConfig.maxActiveTransportsGlobal then return false end
    if not forceFirst and now - state.lastReleaseMissionTime < commanderConfig.spawnIntervalSeconds then return false end

    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "ORDERED" then
        local allowed, reason = predecessorAllowsLaunch(task, now)
        if allowed then
          task.movementState = "QUEUED"
          task.commanderState = "LAUNCH_PENDING"
          task.commanderReleaseReason = reason
          task.commanderReleasedAt = now
          state.lastReleaseMissionTime = now
          state.releasedTaskCount = state.releasedTaskCount + 1
          log("INFO", "transport_released_to_executor", {
            taskId = task.taskId,
            cycle = task.commanderCycle,
            firstEdge = firstEdgeKey(task),
            releaseReason = reason,
            activeGlobalBeforeDispatch = activeGlobalCount(),
            orderedWaiting = countState("ORDERED"),
          })
          return true
        end
      end
    end
    return false
  end

  local function schedulerTick(_, scheduledTime)
    if not state.running or state.generation ~= state.activeGeneration
      or executionState.completed == true or executionState.failed == true then
      return nil
    end
    local now = timer.getTime()
    updateLaunchTracking(now)
    releaseOne(now, false)
    return scheduledTime + (commanderConfig.schedulerTickSeconds or 1)
  end

  local function commanderCycleTick(_, scheduledTime)
    if not state.running or state.generation ~= state.activeGeneration
      or executionState.completed == true or executionState.failed == true then
      return nil
    end
    orderCycle(timer.getTime())
    return scheduledTime + commanderConfig.planningIntervalSeconds
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
    state.activeGeneration = state.generation
    local now = timer.getTime()
    orderCycle(now)
    releaseOne(now, true)

    local started = state.nativeStartExecution()
    if started ~= true then
      state.running = false
      return false
    end

    timer.scheduleFunction(schedulerTick, nil, now + (commanderConfig.schedulerTickSeconds or 1))
    timer.scheduleFunction(commanderCycleTick, nil, now + commanderConfig.planningIntervalSeconds)
    log("INFO", "accelerated_commander_started", {
      planningIntervalSeconds = commanderConfig.planningIntervalSeconds,
      commandBudgetPerCycle = commanderConfig.commandBudgetPerCycle,
      maxActiveTransportsGlobal = commanderConfig.maxActiveTransportsGlobal,
      maxActiveTransportsPerFirstEdge = commanderConfig.maxActiveTransportsPerFirstEdge,
      spawnIntervalSeconds = commanderConfig.spawnIntervalSeconds,
      minimumPredecessorProgressMeters = commanderConfig.minimumPredecessorProgressMeters,
      maximumLaunchHoldSeconds = commanderConfig.maximumLaunchHoldSeconds,
    })
    announce("TM02W2F: beschleunigter RED-Commander gestartet")
    return true
  end

  local function showStatus()
    updateLaunchTracking(timer.getTime())
    local text = table.concat({
      "TM02W2F Commander",
      "Running: " .. tostring(state.running),
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
    errorCount = #state.errors,
  })
  return state
end

return TM02W2FCommanderScheduler
