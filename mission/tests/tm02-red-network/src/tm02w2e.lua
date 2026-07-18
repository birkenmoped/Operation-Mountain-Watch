local TM02W2E = {}

local TERMINAL_STATES = {
  ARRIVED = true,
  DESTROYED = true,
  FAILED = true,
}

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function formatFields(fields)
  local parts = {}
  for _, key in ipairs(sortedKeys(fields)) do
    local value = tostring(fields[key]):gsub("[\r\n]", " ")
    parts[#parts + 1] = tostring(key) .. "=" .. value
  end
  return table.concat(parts, " ")
end

local function copyArray(values)
  local result = {}
  for index, value in ipairs(values or {}) do
    result[index] = value
  end
  return result
end

local function join(values, separator)
  local result = {}
  for index, value in ipairs(values or {}) do
    result[index] = tostring(value)
  end
  return table.concat(result, separator or ",")
end

function TM02W2E.start(config, registryState, plannerState, build)
  local prefix = "[OMW][TM02W2E]"

  local function log(level, event, fields)
    local suffix = formatFields(fields)
    local line = prefix .. " level=" .. level .. " event=" .. event
    if suffix ~= "" then
      line = line .. " " .. suffix
    end
    env.info(line)
  end

  local function announce(text)
    if config.debug and config.debug.showMessages == true then
      trigger.action.outText(text, 16)
    end
  end

  local state = {
    configurationValid = false,
    started = false,
    completed = false,
    failed = false,
    monitorActive = false,
    monitorGeneration = 0,
    errors = {},
    warnings = {},
    tasks = {},
    taskById = {},
    activeTaskCount = 0,
    arrivedTaskCount = 0,
    destroyedTaskCount = 0,
    failedTaskCount = 0,
    totalLosses = 0,
    totalInitialPersonnel = 0,
    expectedPersonnelBySiteId = {},
    launchSlotInUse = {},
    activeOutboundBySource = {},
    markersEnabled = config.debug and config.debug.markersEnabledOnStart == true,
    menu = nil,
  }

  local dispatchAvailableTasks
  local evaluateCompletion

  local function addError(code, detail)
    local message = tostring(code) .. ": " .. tostring(detail)
    state.errors[#state.errors + 1] = message
    log("ERROR", "red_task_execution_error", {
      code = code,
      detail = detail,
    })
  end

  local function addWarning(code, detail)
    local message = tostring(code) .. ": " .. tostring(detail)
    state.warnings[#state.warnings + 1] = message
    log("WARNING", "red_task_execution_warning", {
      code = code,
      detail = detail,
    })
  end

  local function safeDestroy(group)
    if group then
      pcall(function()
        group:Destroy()
      end)
    end
  end

  local function activeGroup(task)
    if task.representationState == "LEADER_PROXY" then
      return task.proxyGroup
    end
    if task.representationState == "PHYSICAL_GARRISON" then
      return task.physicalGroup
    end
    return nil
  end

  local function releaseLaunchSlot(task)
    if task.launchSlotIndex then
      state.launchSlotInUse[task.launchSlotIndex] = nil
    end
  end

  local function releaseSourceLaunch(task)
    if task.sourceLaunchReleased then
      return
    end
    local count = state.activeOutboundBySource[task.sourceSiteId] or 0
    state.activeOutboundBySource[task.sourceSiteId] = math.max(0, count - 1)
    task.sourceLaunchReleased = true
    log("INFO", "red_task_source_launch_released", {
      taskId = task.taskId,
      sourceSiteId = task.sourceSiteId,
      activeOutboundFromSource = state.activeOutboundBySource[task.sourceSiteId],
    })
  end

  local function fail(reason, event, task)
    if state.failed then
      return
    end
    state.failed = true
    state.completed = false
    state.monitorActive = false
    state.monitorGeneration = state.monitorGeneration + 1
    if task and not TERMINAL_STATES[task.movementState] then
      task.movementState = "FAILED"
      task.representationState = "NONE"
      state.failedTaskCount = state.failedTaskCount + 1
      state.activeTaskCount = math.max(0, state.activeTaskCount - 1)
      releaseSourceLaunch(task)
      releaseLaunchSlot(task)
    end
    addError(event or "EXECUTION_FAILED", reason)
    announce("TM02W2E failed: " .. tostring(reason))
  end

  local function updateCurrentCoordinate(task)
    local group = activeGroup(task)
    if not group then
      return nil
    end
    local coordinate = group:GetCoordinate()
    if not coordinate then
      return nil
    end
    task.currentCoordinate = coordinate:GetVec3()
    task.lastUpdateMissionTime = timer.getTime()
    return coordinate
  end

  local function removeMarker(task)
    if trigger.action.removeMark then
      trigger.action.removeMark(task.markerId)
    end
  end

  local function markerText(task)
    local currentNodeId = task.path[task.currentLegIndex]
    local nextNodeId = task.path[task.currentLegIndex + 1]
    return table.concat({
      "TM02W2E " .. task.taskId,
      task.representationState .. " / " .. task.movementState,
      "Strength: " .. task.survivorCount .. " / " .. task.strength,
      "Source: " .. task.sourceSiteId,
      "Target: " .. task.targetSiteId,
      "Leg: " .. tostring(currentNodeId) .. " -> " .. tostring(nextNodeId or task.targetSiteId),
    }, "\n")
  end

  local function updateMarker(task)
    if state.markersEnabled ~= true or not task.currentCoordinate then
      return
    end
    removeMarker(task)
    trigger.action.markToAll(task.markerId, markerText(task), task.currentCoordinate, true)
  end

  local function inventorySnapshot()
    local currentPersonnel = 0
    local reservedInbound = 0
    local reservedOutbound = 0
    local expectedInventoryMatch = true
    local expectedMismatchCount = 0

    for siteId, inventory in pairs(plannerState.inventoryBySiteId or {}) do
      currentPersonnel = currentPersonnel + inventory.currentPersonnel
      reservedInbound = reservedInbound + inventory.reservedInbound
      reservedOutbound = reservedOutbound + inventory.reservedOutbound
      if state.completed or (state.started and state.activeTaskCount == 0) then
        local expected = state.expectedPersonnelBySiteId[siteId]
        if expected ~= nil and inventory.currentPersonnel ~= expected then
          expectedInventoryMatch = false
          expectedMismatchCount = expectedMismatchCount + 1
        end
      end
    end

    local inTransitPersonnel = 0
    local queuedTaskCount = 0
    for _, task in ipairs(state.tasks) do
      if task.movementState == "QUEUED" then
        queuedTaskCount = queuedTaskCount + 1
      elseif task.movementState == "SPAWNING" or task.movementState == "EN_ROUTE" then
        inTransitPersonnel = inTransitPersonnel + task.survivorCount
      end
    end

    local accountedPersonnel = currentPersonnel + inTransitPersonnel + state.totalLosses
    return {
      taskCount = #state.tasks,
      queuedTaskCount = queuedTaskCount,
      activeTaskCount = state.activeTaskCount,
      arrivedTaskCount = state.arrivedTaskCount,
      destroyedTaskCount = state.destroyedTaskCount,
      failedTaskCount = state.failedTaskCount,
      currentPersonnel = currentPersonnel,
      inTransitPersonnel = inTransitPersonnel,
      totalLosses = state.totalLosses,
      accountedPersonnel = accountedPersonnel,
      totalInitialPersonnel = state.totalInitialPersonnel,
      accountingValid = accountedPersonnel == state.totalInitialPersonnel,
      remainingReservedInbound = reservedInbound,
      remainingReservedOutbound = reservedOutbound,
      expectedInventoryMatch = expectedInventoryMatch,
      expectedMismatchCount = expectedMismatchCount,
      movementExecuted = state.started,
      executionComplete = state.completed,
    }
  end

  local function logStatus(reason)
    local snapshot = inventorySnapshot()
    snapshot.reason = reason or "manual"
    snapshot.configurationVersion = config.configurationVersion
    snapshot.buildTimestamp = build and build.buildTimestamp or "unknown"
    snapshot.missionFileName = config.mission.fileName
    snapshot.configurationValid = state.configurationValid
    snapshot.errorCount = #state.errors
    snapshot.warningCount = #state.warnings
    log("INFO", "red_task_execution_status", snapshot)
    return snapshot
  end

  local function showStatus()
    local snapshot = logStatus("manual")
    announce(table.concat({
      "TM02W2E " .. (state.completed and "PASS" or (state.failed and "FAIL" or "RUNNING")),
      "Tasks: " .. snapshot.taskCount,
      "Queued: " .. snapshot.queuedTaskCount,
      "Active: " .. snapshot.activeTaskCount,
      "Arrived: " .. snapshot.arrivedTaskCount,
      "Destroyed: " .. snapshot.destroyedTaskCount,
      "Current personnel: " .. snapshot.currentPersonnel,
      "In transit: " .. snapshot.inTransitPersonnel,
      "Losses: " .. snapshot.totalLosses,
      "Accounted: " .. snapshot.accountedPersonnel .. " / " .. snapshot.totalInitialPersonnel,
      "Reservations in/out: " .. snapshot.remainingReservedInbound .. " / " .. snapshot.remainingReservedOutbound,
    }, "\n"))
    return snapshot
  end

  local function showTasks()
    for _, task in ipairs(state.tasks) do
      log("INFO", "red_task_execution_task_status", {
        taskId = task.taskId,
        sourceSiteId = task.sourceSiteId,
        targetSiteId = task.targetSiteId,
        strength = task.strength,
        survivorCount = task.survivorCount,
        path = join(task.path, ">"),
        currentLegIndex = task.currentLegIndex,
        movementState = task.movementState,
        representationState = task.representationState,
        proxyGroupName = task.proxyGroupName or "none",
        physicalGroupName = task.physicalGroupName or "none",
      })
    end
    announce("TM02W2E task states written to dcs.log")
  end

  local function buildRuntimeTasks()
    for index, planned in ipairs(plannerState.tasks or {}) do
      local task = {
        taskId = planned.taskId,
        sourceSiteId = planned.sourceSiteId,
        targetSiteId = planned.targetSiteId,
        strength = planned.strength,
        survivorCount = planned.strength,
        path = copyArray(planned.path),
        linkIds = copyArray(planned.linkIds),
        currentLegIndex = 1,
        movementState = "QUEUED",
        representationState = "NONE",
        launchSlotIndex = nil,
        sourceLaunchReleased = false,
        outboundCommitted = false,
        inboundReleased = false,
        arrivalCredited = false,
        runtimeGeneration = 0,
        proxyGroup = nil,
        proxyGroupName = nil,
        physicalGroup = nil,
        physicalGroupName = nil,
        currentCoordinate = nil,
        markerId = (config.debug.markerIdBase or 220600) + index,
      }
      state.tasks[#state.tasks + 1] = task
      state.taskById[task.taskId] = task
    end
  end

  local function validateConfigurationAndObjects()
    if type(registryState) ~= "table" or registryState.configurationValid ~= true then
      addError("REGISTRY_INVALID", "TM02W1 registry is missing or invalid")
    end
    if type(plannerState) ~= "table" or plannerState.configurationValid ~= true then
      addError("PLANNER_INVALID", "TM02W2 planner is missing or invalid")
    end
    if plannerState and plannerState.unresolvedDeficit ~= 0 then
      addError("PLANNER_DEFICIT_UNRESOLVED", tostring(plannerState.unresolvedDeficit))
    end
    if type(config.execution.maxActiveTasks) ~= "number"
      or config.execution.maxActiveTasks % 1 ~= 0
      or config.execution.maxActiveTasks < 1 then
      addError("MAX_ACTIVE_TASKS_INVALID", tostring(config.execution.maxActiveTasks))
    end
    if type(config.execution.maxActiveOutboundPerSource) ~= "number"
      or config.execution.maxActiveOutboundPerSource % 1 ~= 0
      or config.execution.maxActiveOutboundPerSource < 1 then
      addError("MAX_ACTIVE_OUTBOUND_INVALID", tostring(config.execution.maxActiveOutboundPerSource))
    end
    if type(config.proxy.launchSlots) ~= "table"
      or #config.proxy.launchSlots < config.execution.maxActiveTasks then
      addError("LAUNCH_SLOTS_INSUFFICIENT", tostring(#(config.proxy.launchSlots or {})))
    end
    if type(config.routing.proxyTestSpeedKph) ~= "number"
      or config.routing.proxyTestSpeedKph <= 0 then
      addError("PROXY_TEST_SPEED_INVALID", tostring(config.routing.proxyTestSpeedKph))
    end

    for strength = 1, 10 do
      local templateName = config.templatesByStrength[strength]
      if type(templateName) ~= "string" or templateName == "" then
        addError("TEMPLATE_NAME_MISSING", tostring(strength))
      elseif not GROUP:FindByName(templateName) then
        addError("TEMPLATE_GROUP_MISSING", templateName)
      end
    end

    local plannedOutboundBySite = {}
    local plannedInboundBySite = {}
    for _, task in ipairs(state.tasks) do
      if type(task.taskId) ~= "string" or task.taskId == "" then
        addError("TASK_ID_INVALID", tostring(task.taskId))
      elseif state.taskById[task.taskId] ~= task then
        addError("TASK_ID_DUPLICATE", tostring(task.taskId))
      end
      if type(task.strength) ~= "number"
        or task.strength % 1 ~= 0
        or task.strength < 1
        or task.strength > 6 then
        addError("TASK_STRENGTH_INVALID", task.taskId .. " strength=" .. tostring(task.strength))
      end
      if #task.path < 2
        or task.path[1] ~= task.sourceSiteId
        or task.path[#task.path] ~= task.targetSiteId then
        addError("TASK_PATH_INVALID", task.taskId .. " path=" .. join(task.path, ">"))
      end
      if not registryState.siteById[task.sourceSiteId]
        or not registryState.siteById[task.targetSiteId] then
        addError("TASK_SITE_MISSING", task.taskId)
      end
      if not plannerState.inventoryBySiteId[task.sourceSiteId]
        or not plannerState.inventoryBySiteId[task.targetSiteId] then
        addError("TASK_INVENTORY_MISSING", task.taskId)
      end
      for _, siteId in ipairs(task.path) do
        if not registryState.siteById[siteId] then
          addError("TASK_PATH_SITE_MISSING", task.taskId .. " site=" .. tostring(siteId))
        elseif not ZONE:FindByName(siteId) then
          addError("TASK_PATH_ZONE_MISSING", task.taskId .. " zone=" .. tostring(siteId))
        end
      end
      plannedOutboundBySite[task.sourceSiteId] = (plannedOutboundBySite[task.sourceSiteId] or 0) + task.strength
      plannedInboundBySite[task.targetSiteId] = (plannedInboundBySite[task.targetSiteId] or 0) + task.strength
    end

    for siteId, inventory in pairs(plannerState.inventoryBySiteId or {}) do
      state.totalInitialPersonnel = state.totalInitialPersonnel + inventory.currentPersonnel
      state.expectedPersonnelBySiteId[siteId] = inventory.currentPersonnel
        + inventory.reservedInbound
        - inventory.reservedOutbound
      if inventory.reservedOutbound ~= (plannedOutboundBySite[siteId] or 0) then
        addError(
          "OUTBOUND_RESERVATION_MISMATCH",
          siteId .. " reserved=" .. inventory.reservedOutbound
            .. " tasks=" .. tostring(plannedOutboundBySite[siteId] or 0)
        )
      end
      if inventory.reservedInbound ~= (plannedInboundBySite[siteId] or 0) then
        addError(
          "INBOUND_RESERVATION_MISMATCH",
          siteId .. " reserved=" .. inventory.reservedInbound
            .. " tasks=" .. tostring(plannedInboundBySite[siteId] or 0)
        )
      end
    end

    local snapshot = inventorySnapshot()
    if snapshot.remainingReservedInbound ~= plannerState.totalReservedInbound
      or snapshot.remainingReservedOutbound ~= plannerState.totalReservedOutbound then
      addError("PLANNER_RESERVATION_TOTAL_MISMATCH", "planner and inventory totals differ")
    end
    if snapshot.totalInitialPersonnel ~= 108 then
      addWarning("FIXTURE_PERSONNEL_CHANGED", "expected 108, observed " .. snapshot.totalInitialPersonnel)
    end

    log("INFO", "red_task_execution_validation", {
      configurationVersion = config.configurationVersion,
      configurationValid = #state.errors == 0,
      missionFileName = config.mission.fileName,
      taskCount = #state.tasks,
      totalInitialPersonnel = state.totalInitialPersonnel,
      reservedInbound = snapshot.remainingReservedInbound,
      reservedOutbound = snapshot.remainingReservedOutbound,
      maxActiveTasks = config.execution.maxActiveTasks,
      maxActiveOutboundPerSource = config.execution.maxActiveOutboundPerSource,
      launchSlotCount = #config.proxy.launchSlots,
      proxyTestSpeedKph = config.routing.proxyTestSpeedKph,
      errorCount = #state.errors,
      warningCount = #state.warnings,
    })
  end

  local function acquireLaunchSlot()
    for index = 1, config.execution.maxActiveTasks do
      if not state.launchSlotInUse[index] then
        state.launchSlotInUse[index] = true
        return index
      end
    end
    return nil
  end

  local function nextAlias(task, prefixValue, includeLaunchSlot)
    task.runtimeGeneration = task.runtimeGeneration + 1
    local alias = prefixValue .. task.taskId:gsub("[^%w]", "_")
    if includeLaunchSlot then
      alias = alias .. "_SLOT" .. tostring(task.launchSlotIndex)
    end
    return alias .. "_G" .. string.format("%03d", task.runtimeGeneration)
  end

  local function assignCurrentLeg(task, group)
    local nextSiteId = task.path[task.currentLegIndex + 1]
    if not nextSiteId then
      error("next path site is unavailable for " .. task.taskId)
    end
    local destinationZone = ZONE:FindByName(nextSiteId)
    if not destinationZone then
      error("destination zone is unavailable: " .. tostring(nextSiteId))
    end
    local startCoordinate = group:GetCoordinate()
    local destinationCoordinate = destinationZone:GetCoordinate()
    if not startCoordinate or not destinationCoordinate then
      error("route coordinates are unavailable for " .. task.taskId)
    end
    local waypoints = {
      startCoordinate:WaypointGround(config.routing.proxyTestSpeedKph, config.routing.formation),
      destinationCoordinate:WaypointGround(config.routing.proxyTestSpeedKph, config.routing.formation),
    }
    local assigned = group:Route(waypoints, config.routing.assignmentDelaySeconds)
    if not assigned then
      error("route assignment returned nil for " .. task.taskId)
    end
    log("INFO", "red_task_leg_started", {
      taskId = task.taskId,
      currentLegIndex = task.currentLegIndex,
      sourceSiteId = task.path[task.currentLegIndex],
      destinationSiteId = nextSiteId,
      finalTargetSiteId = task.targetSiteId,
      strength = task.strength,
      runtimeGroupName = group:GetName(),
      proxyTestSpeedKph = config.routing.proxyTestSpeedKph,
    })
  end

  local function spawnPhysicalAtDestination(task, coordinate)
    local templateName = config.templatesByStrength[task.survivorCount]
    local alias = nextAlias(task, config.physical.runtimeAliasPrefix, false)
    local group = SPAWN:NewWithAlias(templateName, alias):SpawnFromCoordinate(coordinate)
    if not group then
      error("physical spawn returned nil for " .. task.taskId)
    end
    local count = group:CountAliveUnits()
    if count ~= task.survivorCount then
      safeDestroy(group)
      error(
        "physical group spawned with " .. tostring(count)
          .. " instead of " .. tostring(task.survivorCount)
          .. " for " .. task.taskId
      )
    end
    return group
  end

  local function releaseTargetReservation(task)
    if task.inboundReleased then
      return
    end
    local target = plannerState.inventoryBySiteId[task.targetSiteId]
    if not target or target.reservedInbound < task.strength then
      error("target inbound reservation is unavailable for " .. task.taskId)
    end
    target.reservedInbound = target.reservedInbound - task.strength
    task.inboundReleased = true
  end

  local function creditArrival(task)
    if task.arrivalCredited then
      error("duplicate arrival credit for " .. task.taskId)
    end
    local target = plannerState.inventoryBySiteId[task.targetSiteId]
    if not target then
      error("target inventory is unavailable for " .. task.taskId)
    end
    if target.currentPersonnel + task.survivorCount > target.hardCapacity then
      error("arrival would exceed hard capacity at " .. task.targetSiteId)
    end
    releaseTargetReservation(task)
    target.currentPersonnel = target.currentPersonnel + task.survivorCount
    task.arrivalCredited = true
    task.movementState = "ARRIVED"
    task.representationState = "PHYSICAL_GARRISON"
    state.arrivedTaskCount = state.arrivedTaskCount + 1
    state.activeTaskCount = math.max(0, state.activeTaskCount - 1)
    releaseSourceLaunch(task)
    releaseLaunchSlot(task)
    updateCurrentCoordinate(task)
    updateMarker(task)
    log("INFO", "red_task_arrived", {
      taskId = task.taskId,
      sourceSiteId = task.sourceSiteId,
      targetSiteId = task.targetSiteId,
      strength = task.strength,
      targetPersonnel = target.currentPersonnel,
      targetReservedInbound = target.reservedInbound,
      physicalGroupName = task.physicalGroupName,
      activeTaskCount = state.activeTaskCount,
    })
  end

  local function arriveAtCurrentLegDestination(task)
    local nextSiteId = task.path[task.currentLegIndex + 1]
    log("INFO", "red_task_leg_arrived", {
      taskId = task.taskId,
      currentLegIndex = task.currentLegIndex,
      siteId = nextSiteId,
      finalTargetSiteId = task.targetSiteId,
      strength = task.strength,
    })

    if task.currentLegIndex == 1 then
      releaseSourceLaunch(task)
    end

    if nextSiteId == task.targetSiteId then
      local coordinate = task.proxyGroup and task.proxyGroup:GetCoordinate() or nil
      if not coordinate then
        error("proxy coordinate unavailable at final destination for " .. task.taskId)
      end
      task.representationState = "MATERIALIZING"
      local physical = spawnPhysicalAtDestination(task, coordinate)
      local oldProxy = task.proxyGroup
      task.physicalGroup = physical
      task.physicalGroupName = physical:GetName()
      task.proxyGroup = nil
      task.proxyGroupName = nil
      safeDestroy(oldProxy)
      log("INFO", "red_task_physical_materialized", {
        taskId = task.taskId,
        strength = task.strength,
        targetSiteId = task.targetSiteId,
        physicalGroupName = task.physicalGroupName,
      })
      creditArrival(task)
      return
    end

    task.currentLegIndex = task.currentLegIndex + 1
    assignCurrentLeg(task, task.proxyGroup)
  end

  local function destroyTask(task, reason)
    if TERMINAL_STATES[task.movementState] then
      return
    end
    state.totalLosses = state.totalLosses + task.survivorCount
    task.survivorCount = 0
    task.movementState = "DESTROYED"
    task.representationState = "NONE"
    state.destroyedTaskCount = state.destroyedTaskCount + 1
    state.activeTaskCount = math.max(0, state.activeTaskCount - 1)
    releaseSourceLaunch(task)
    releaseLaunchSlot(task)
    releaseTargetReservation(task)
    removeMarker(task)
    log("INFO", "red_task_proxy_destroyed", {
      taskId = task.taskId,
      reason = reason,
      totalLosses = state.totalLosses,
      activeTaskCount = state.activeTaskCount,
    })
  end

  local function reconcileTask(task)
    if task.movementState ~= "EN_ROUTE" then
      return
    end
    local group = task.proxyGroup
    if not group then
      error("active task lacks proxy group: " .. task.taskId)
    end
    if group:IsAlive() ~= true then
      destroyTask(task, "proxy group is no longer alive")
      return
    end
    updateCurrentCoordinate(task)
    updateMarker(task)
    local nextSiteId = task.path[task.currentLegIndex + 1]
    local destinationZone = nextSiteId and ZONE:FindByName(nextSiteId) or nil
    if not destinationZone then
      error("next destination zone unavailable for " .. task.taskId)
    end
    if group:IsCompletelyInZone(destinationZone) == true then
      arriveAtCurrentLegDestination(task)
    end
  end

  local function dispatchTask(task, launchSlotIndex)
    local source = plannerState.inventoryBySiteId[task.sourceSiteId]
    local sourceZone = ZONE:FindByName(task.sourceSiteId)
    if not source or not sourceZone then
      error("source inventory or zone unavailable for " .. task.taskId)
    end
    if source.reservedOutbound < task.strength then
      error("source outbound reservation unavailable for " .. task.taskId)
    end
    if source.currentPersonnel - task.strength < source.guardFloor then
      error("dispatch would cross guard floor for " .. task.taskId)
    end

    task.launchSlotIndex = launchSlotIndex
    source.currentPersonnel = source.currentPersonnel - task.strength
    source.reservedOutbound = source.reservedOutbound - task.strength
    task.outboundCommitted = true
    task.movementState = "SPAWNING"
    task.representationState = "SPAWNING_PROXY"
    state.activeOutboundBySource[task.sourceSiteId] = (state.activeOutboundBySource[task.sourceSiteId] or 0) + 1

    local templateName = config.templatesByStrength[task.strength]
    local alias = nextAlias(task, config.proxy.runtimeAliasPrefix, true)
    local spawnOk, proxyOrError = pcall(function()
      local group = SPAWN:NewWithAlias(templateName, alias):SpawnInZone(sourceZone, false)
      if not group then
        error("initial proxy spawn returned nil")
      end
      if group:CountAliveUnits() ~= config.proxy.expectedUnitCount then
        safeDestroy(group)
        error("initial proxy did not contain exactly one unit")
      end
      assignCurrentLeg(task, group)
      return group
    end)

    if not spawnOk then
      source.currentPersonnel = source.currentPersonnel + task.strength
      source.reservedOutbound = source.reservedOutbound + task.strength
      task.outboundCommitted = false
      task.movementState = "QUEUED"
      task.representationState = "NONE"
      releaseSourceLaunch(task)
      releaseLaunchSlot(task)
      error(proxyOrError)
    end

    task.proxyGroup = proxyOrError
    task.proxyGroupName = proxyOrError:GetName()
    task.movementState = "EN_ROUTE"
    task.representationState = "LEADER_PROXY"
    state.activeTaskCount = state.activeTaskCount + 1
    updateCurrentCoordinate(task)
    updateMarker(task)
    log("INFO", "red_task_proxy_started", {
      taskId = task.taskId,
      sourceSiteId = task.sourceSiteId,
      targetSiteId = task.targetSiteId,
      strength = task.strength,
      path = join(task.path, ">"),
      proxyGroupName = task.proxyGroupName,
      launchSlotIndex = task.launchSlotIndex,
      sourcePersonnel = source.currentPersonnel,
      sourceReservedOutbound = source.reservedOutbound,
      activeTaskCount = state.activeTaskCount,
    })
  end

  dispatchAvailableTasks = function()
    if state.failed or not state.started then
      return
    end
    while state.activeTaskCount < config.execution.maxActiveTasks do
      local selected = nil
      for _, task in ipairs(state.tasks) do
        if task.movementState == "QUEUED"
          and (state.activeOutboundBySource[task.sourceSiteId] or 0)
            < config.execution.maxActiveOutboundPerSource then
          selected = task
          break
        end
      end
      if not selected then
        break
      end
      local slot = acquireLaunchSlot()
      if not slot then
        break
      end
      local ok, dispatchError = pcall(dispatchTask, selected, slot)
      if not ok then
        fail(dispatchError, "TASK_DISPATCH_FAILED", selected)
        return
      end
    end
  end

  evaluateCompletion = function()
    if state.failed then
      return false
    end
    local snapshot = inventorySnapshot()
    if snapshot.queuedTaskCount == 0 and snapshot.activeTaskCount == 0 then
      if snapshot.arrivedTaskCount ~= snapshot.taskCount then
        fail(
          "not every reserved task arrived; arrived=" .. snapshot.arrivedTaskCount
            .. " taskCount=" .. snapshot.taskCount,
          "TASK_EXECUTION_INCOMPLETE"
        )
        return false
      end
      if snapshot.totalLosses ~= 0 then
        fail("technical acceptance requires zero losses", "TASK_EXECUTION_LOSSES")
        return false
      end
      if snapshot.remainingReservedInbound ~= 0 or snapshot.remainingReservedOutbound ~= 0 then
        fail("reservations remain after terminal execution", "TASK_RESERVATIONS_REMAIN")
        return false
      end
      if snapshot.accountingValid ~= true then
        fail("personnel accounting is invalid", "TASK_ACCOUNTING_INVALID")
        return false
      end
      if snapshot.expectedInventoryMatch ~= true then
        fail(
          "final inventories differ from the accepted plan at "
            .. snapshot.expectedMismatchCount .. " site(s)",
          "TASK_FINAL_INVENTORY_MISMATCH"
        )
        return false
      end

      state.completed = true
      state.monitorActive = false
      state.monitorGeneration = state.monitorGeneration + 1
      snapshot.executionComplete = true
      log("INFO", "red_task_execution_completed", {
        configurationVersion = config.configurationVersion,
        buildTimestamp = build and build.buildTimestamp or "unknown",
        missionFileName = config.mission.fileName,
        taskCount = snapshot.taskCount,
        arrivedTaskCount = snapshot.arrivedTaskCount,
        destroyedTaskCount = snapshot.destroyedTaskCount,
        failedTaskCount = snapshot.failedTaskCount,
        currentPersonnel = snapshot.currentPersonnel,
        inTransitPersonnel = snapshot.inTransitPersonnel,
        totalLosses = snapshot.totalLosses,
        accountedPersonnel = snapshot.accountedPersonnel,
        totalInitialPersonnel = snapshot.totalInitialPersonnel,
        accountingValid = snapshot.accountingValid,
        remainingReservedInbound = snapshot.remainingReservedInbound,
        remainingReservedOutbound = snapshot.remainingReservedOutbound,
        expectedInventoryMatch = snapshot.expectedInventoryMatch,
        executionComplete = true,
      })
      announce("TM02W2E PASS: all seven reserved tasks physically arrived and accounting is exact")
      return true
    end
    return false
  end

  local function monitorTick()
    if state.monitorActive ~= true or state.failed then
      return false
    end
    for _, task in ipairs(state.tasks) do
      local ok, taskError = pcall(reconcileTask, task)
      if not ok then
        fail(taskError, "TASK_MONITOR_FAILED", task)
        return false
      end
    end
    dispatchAvailableTasks()
    evaluateCompletion()
    return state.monitorActive == true
  end

  local function startMonitor()
    state.monitorGeneration = state.monitorGeneration + 1
    local generation = state.monitorGeneration
    state.monitorActive = true
    log("INFO", "red_task_monitor_started", {
      maxActiveTasks = config.execution.maxActiveTasks,
      maxActiveOutboundPerSource = config.execution.maxActiveOutboundPerSource,
      initialDelaySeconds = config.execution.monitorInitialDelaySeconds,
      intervalSeconds = config.execution.monitorIntervalSeconds,
    })
    timer.scheduleFunction(function(_, scheduledTime)
      if state.monitorActive ~= true or state.monitorGeneration ~= generation then
        return nil
      end
      local ok, continueOrError = pcall(monitorTick)
      if not ok then
        fail(continueOrError, "TASK_MONITOR_UNCAUGHT_ERROR")
        return nil
      end
      if continueOrError ~= true then
        return nil
      end
      return scheduledTime + config.execution.monitorIntervalSeconds
    end, nil, timer.getTime() + config.execution.monitorInitialDelaySeconds)
  end

  local function startExecution()
    if state.started then
      announce("TM02W2E start rejected: execution already started")
      return false
    end
    if state.configurationValid ~= true or state.failed then
      announce("TM02W2E start rejected: validation failed")
      return false
    end
    state.started = true
    startMonitor()
    dispatchAvailableTasks()
    local snapshot = logStatus("execution-started")
    log("INFO", "red_task_execution_started", {
      taskCount = snapshot.taskCount,
      queuedTaskCount = snapshot.queuedTaskCount,
      activeTaskCount = snapshot.activeTaskCount,
      totalInitialPersonnel = snapshot.totalInitialPersonnel,
      currentPersonnel = snapshot.currentPersonnel,
      inTransitPersonnel = snapshot.inTransitPersonnel,
      accountedPersonnel = snapshot.accountedPersonnel,
      accountingValid = snapshot.accountingValid,
    })
    announce("TM02W2E started: executing seven accepted reservation tasks")
    return not state.failed
  end

  local function toggleMarkers()
    state.markersEnabled = not state.markersEnabled
    if state.markersEnabled then
      for _, task in ipairs(state.tasks) do
        updateCurrentCoordinate(task)
        updateMarker(task)
      end
    else
      for _, task in ipairs(state.tasks) do
        removeMarker(task)
      end
    end
    log("INFO", "red_task_markers_toggled", { enabled = state.markersEnabled })
    announce("TM02W2E task markers enabled: " .. tostring(state.markersEnabled))
    return state.markersEnabled
  end

  local function installMenu()
    if not config.debug or config.debug.enableF10Menu ~= true then
      return
    end
    if type(MENU_MISSION) ~= "table" or type(MENU_MISSION_COMMAND) ~= "table" then
      addError("F10_MENU_API_MISSING", "MOOSE menu APIs unavailable")
      return
    end
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM02W2E RED Task Execution", root)
    state.menu = { root = root, menu = menu }
    MENU_MISSION_COMMAND:New("Start reserved task execution", menu, startExecution)
    MENU_MISSION_COMMAND:New("Show execution status", menu, showStatus)
    MENU_MISSION_COMMAND:New("List task states in log", menu, showTasks)
    MENU_MISSION_COMMAND:New("Toggle task markers", menu, toggleMarkers)
  end

  buildRuntimeTasks()
  local validationOk, validationError = pcall(validateConfigurationAndObjects)
  if not validationOk then
    addError("VALIDATION_UNCAUGHT_ERROR", validationError)
  end
  state.configurationValid = #state.errors == 0
  installMenu()

  state.startExecution = startExecution
  state.showStatus = showStatus
  state.showTasks = showTasks
  state.toggleMarkers = toggleMarkers
  state.monitorTick = monitorTick

  logStatus("bootstrap")
  announce(table.concat({
    "TM02W2E validation",
    "Configuration: " .. tostring(state.configurationValid),
    "Reserved tasks: " .. tostring(#state.tasks),
    "Initial personnel: " .. tostring(state.totalInitialPersonnel),
    "Maximum active tasks: " .. tostring(config.execution.maxActiveTasks),
    "Proxy test speed: " .. tostring(config.routing.proxyTestSpeedKph) .. " km/h",
  }, "\n"))

  if state.configurationValid and config.execution.autoStart == true then
    startExecution()
  end

  return state
end

return TM02W2E
