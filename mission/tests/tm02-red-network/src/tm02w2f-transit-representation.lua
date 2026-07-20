local TM02W2FTransitRepresentation = {}

function TM02W2FTransitRepresentation.install(config, executionState, navigation)
  local state = {
    valid = true,
    errors = {},
    menu = nil,
    transitionActive = false,
    transitionGeneration = 0,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM02W2F][TRANSIT] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function announce(text)
    if config.debug and config.debug.showMessages == true then
      trigger.action.outText(text, 16)
    end
  end

  local generation = 0
  local function nextAlias(task, prefixValue)
    generation = generation + 1
    return prefixValue .. task.taskId:gsub("[^%w]", "_") .. "_M" .. string.format("%04d", generation)
  end

  local function currentDestination(task)
    local nextSiteId = task.path and task.path[task.currentLegIndex + 1] or nil
    local zone = nextSiteId and ZONE:FindByName(nextSiteId) or nil
    return nextSiteId, zone
  end

  local function assignDirectRoute(group, task, reason)
    local nextSiteId, destinationZone = currentDestination(task)
    if not nextSiteId or not destinationZone then return false, "DESTINATION_UNAVAILABLE" end

    local sourceSiteId = task.path[task.currentLegIndex]
    local plan = navigation:getLegPlan(sourceSiteId, nextSiteId)
    if not plan or plan.safe ~= true or plan.mode ~= "DIRECT_OFFROAD" then
      return false, "DIRECT_LEG_NOT_VALIDATED"
    end

    local startCoordinate = group:GetCoordinate()
    local targetCoordinate = destinationZone:GetCoordinate()
    if not startCoordinate or not targetCoordinate then return false, "ROUTE_COORDINATE_UNAVAILABLE" end

    local waypoints = {
      startCoordinate:WaypointGround(config.routing.proxyTestSpeedKph, config.routing.offRoadFormation),
      targetCoordinate:WaypointGround(config.routing.proxyTestSpeedKph, config.routing.offRoadFormation),
    }
    local ok, assigned = pcall(function()
      return group:Route(waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then
      return false, ok and "ROUTE_RETURNED_NIL" or tostring(assigned)
    end

    log("INFO", "transit_direct_route_assigned", {
      taskId = task.taskId,
      groupName = group:GetName(),
      reason = reason,
      sourceSiteId = sourceSiteId,
      destinationSiteId = nextSiteId,
      waypointCount = #waypoints,
      formation = config.routing.offRoadFormation,
      roadsUsed = false,
    })
    return true, nil
  end

  local function resetSamples(task)
    task.navArmyGroup = nil
    task.navArmyGroupName = nil
    task.navObservedHitCount = nil
    task.navV5MovementSample = nil
    task.navV5GroupName = nil
    task.navV5IneffectiveWindowCount = 0
    task.navHighestRouteProgressMeters = 0
    task.w2fWatchdogSample = nil
  end

  local function convertTask(task, unpack, reason)
    if task.movementState ~= "EN_ROUTE" or not task.proxyGroup or task.proxyGroup:IsAlive() ~= true then
      return false, "TASK_NOT_TRAVELLING"
    end

    local oldGroup = task.proxyGroup
    local coordinate = oldGroup:GetCoordinate()
    if not coordinate then return false, "CURRENT_COORDINATE_UNAVAILABLE" end

    local templateName = config.templatesByStrength[task.survivorCount]
    local alias = unpack
      and nextAlias(task, config.physical.transitRuntimeAliasPrefix)
      or nextAlias(task, config.proxy.runtimeAliasPrefix)
    local replacement = SPAWN:NewWithAlias(templateName, alias):SpawnFromCoordinate(coordinate)
    local expectedCount = unpack and task.survivorCount or config.proxy.expectedUnitCount
    if not replacement or replacement:CountAliveUnits() ~= expectedCount then
      if replacement then pcall(function() replacement:Destroy() end) end
      return false, "SPAWN_COUNT_MISMATCH"
    end

    local conversionReason = reason or (unpack and "manual-unpack-all" or "manual-pack-all")
    local routeOk, routeError = assignDirectRoute(replacement, task, conversionReason)
    if routeOk ~= true then
      pcall(function() replacement:Destroy() end)
      return false, routeError
    end

    local oldName = oldGroup:GetName()
    task.proxyGroup = replacement
    task.proxyGroupName = replacement:GetName()
    task.representationState = "LEADER_PROXY"
    task.transitExpanded = unpack == true
    task.transitRepresentation = unpack and "FULL_GROUP" or "LEADER_PROXY"
    task.currentCoordinate = coordinate:GetVec3()
    resetSamples(task)
    pcall(function() oldGroup:Destroy() end)

    log("INFO", unpack and "travelling_proxy_unpacked" or "travelling_group_packed", {
      taskId = task.taskId,
      strength = task.survivorCount,
      oldGroupName = oldName,
      newGroupName = replacement:GetName(),
      waypointCount = 2,
      physicalMode = "DIRECT_OFFROAD",
      roadsUsed = false,
      conversionReason = conversionReason,
    })
    return true, nil
  end

  local function convertTaskForRecovery(task, reason)
    if state.transitionActive then
      return false, "TRANSITION_BUSY"
    end
    state.transitionActive = true
    state.transitionGeneration = state.transitionGeneration + 1
    local unpack = task.transitExpanded ~= true
    local ok, success, failureReason = pcall(
      convertTask,
      task,
      unpack,
      reason or "watchdog-representation-reset"
    )
    state.transitionActive = false
    if not ok or success ~= true then
      local detail = ok and tostring(failureReason) or tostring(success)
      log("ERROR", "watchdog_representation_reset_failed", {
        taskId = task.taskId,
        reason = detail,
      })
      return false, detail
    end
    log("INFO", "watchdog_representation_reset_completed", {
      taskId = task.taskId,
      representation = task.transitRepresentation,
      groupName = task.proxyGroupName or "none",
    })
    return true, nil
  end

  local function reassignDirectRouteForRecovery(task, reason)
    if task.movementState ~= "EN_ROUTE" or not task.proxyGroup or task.proxyGroup:IsAlive() ~= true then
      return false, "TASK_NOT_TRAVELLING"
    end
    return assignDirectRoute(task.proxyGroup, task, reason or "watchdog-direct-reset")
  end

  local function collectCandidates(unpack)
    local result = {}
    for _, task in ipairs(executionState.tasks or {}) do
      local candidate = task.movementState == "EN_ROUTE"
        and task.proxyGroup ~= nil
        and ((unpack and task.transitExpanded ~= true)
          or (not unpack and task.transitExpanded == true))
      if candidate then result[#result + 1] = task end
    end
    return result
  end

  local function beginSerializedConversion(unpack)
    if state.transitionActive then
      announce("TM02W2F: eine Pack-/Entpackoperation laeuft bereits")
      return false
    end

    local candidates = collectCandidates(unpack)
    if #candidates == 0 then
      announce(unpack and "Keine gepackten Reise-Proxies vorhanden" or "Keine entpackten Reisegruppen vorhanden")
      return true
    end

    state.transitionActive = true
    state.transitionGeneration = state.transitionGeneration + 1
    local transitionGeneration = state.transitionGeneration
    local index, converted, skipped, errors = 1, 0, 0, 0
    local operation = unpack and "UNPACK" or "PACK"
    log("INFO", "serialized_transit_conversion_started", {
      operation = operation,
      candidateCount = #candidates,
      intervalSeconds = config.transitRepresentation.transitionIntervalSeconds,
      physicalMode = "DIRECT_OFFROAD",
    })
    announce((unpack and "Reise-Proxies werden entpackt: " or "Reisegruppen werden gepackt: ") .. #candidates)

    timer.scheduleFunction(function(_, scheduledTime)
      if transitionGeneration ~= state.transitionGeneration then return nil end
      local task = candidates[index]
      if not task then
        state.transitionActive = false
        log(errors == 0 and "INFO" or "WARNING", "serialized_transit_conversion_completed", {
          operation = operation,
          candidateCount = #candidates,
          convertedCount = converted,
          skippedCount = skipped,
          errorCount = errors,
        })
        announce((unpack and "Reise-Proxies entpackt: " or "Reisegruppen gepackt: ")
          .. converted .. " / " .. #candidates .. "; uebersprungen: " .. skipped .. "; Fehler: " .. errors)
        return nil
      end

      local stillEligible = task.movementState == "EN_ROUTE"
        and task.proxyGroup ~= nil
        and ((unpack and task.transitExpanded ~= true)
          or (not unpack and task.transitExpanded == true))
      if not stillEligible then
        skipped = skipped + 1
      else
        local ok, success, reason = pcall(
          convertTask,
          task,
          unpack,
          unpack and "manual-unpack-all" or "manual-pack-all"
        )
        if ok and success == true then
          converted = converted + 1
        else
          errors = errors + 1
          log("ERROR", "transit_conversion_failed", {
            taskId = task.taskId,
            operation = operation,
            reason = ok and tostring(reason) or tostring(success),
          })
        end
      end
      index = index + 1
      return timer.getTime() + config.transitRepresentation.transitionIntervalSeconds
    end, nil, timer.getTime() + 0.1)
    return true
  end

  local function showStatus()
    local travelling, packed, unpacked = 0, 0, 0
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "EN_ROUTE" then
        travelling = travelling + 1
        if task.transitExpanded == true then unpacked = unpacked + 1 else packed = packed + 1 end
      end
    end
    log("INFO", "transit_representation_status", {
      travellingCount = travelling,
      packedProxyCount = packed,
      unpackedFullGroupCount = unpacked,
      transitionActive = state.transitionActive,
      physicalMode = "DIRECT_OFFROAD",
    })
    announce("TM02W2F Reise-Darstellung\nReisend: " .. travelling
      .. "\nGepackte Proxies: " .. packed
      .. "\nEntpackte Gruppen: " .. unpacked
      .. "\nUmstellung aktiv: " .. tostring(state.transitionActive))
  end

  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    state.valid = false
    state.errors[#state.errors + 1] = "EXECUTION_INVALID"
  end
  if type(navigation) ~= "table" or navigation.valid ~= true or navigation.routingReady ~= true then
    state.valid = false
    state.errors[#state.errors + 1] = "NAVIGATION_INVALID"
  end

  if state.valid and config.transitRepresentation.enableF10Menu == true then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New(config.transitRepresentation.menuTitle, root)
    MENU_MISSION_COMMAND:New(config.transitRepresentation.startCommand, menu, executionState.startExecution)
    MENU_MISSION_COMMAND:New(config.transitRepresentation.unpackCommand, menu, function() return beginSerializedConversion(true) end)
    MENU_MISSION_COMMAND:New(config.transitRepresentation.packCommand, menu, function() return beginSerializedConversion(false) end)
    MENU_MISSION_COMMAND:New(config.transitRepresentation.statusCommand, menu, showStatus)
    if type(executionState.showCommanderStatus) == "function" then
      MENU_MISSION_COMMAND:New(config.transitRepresentation.commanderStatusCommand, menu, executionState.showCommanderStatus)
    end
    MENU_MISSION_COMMAND:New(config.transitRepresentation.listCommand, menu, executionState.showTasks)
    MENU_MISSION_COMMAND:New(config.transitRepresentation.markerCommand, menu, executionState.toggleMarkers)
    state.menu = { root = root, menu = menu }
  end

  state.unpackAllTravelling = function() return beginSerializedConversion(true) end
  state.packAllTravelling = function() return beginSerializedConversion(false) end
  state.convertTaskForRecovery = convertTaskForRecovery
  state.reassignDirectRouteForRecovery = reassignDirectRouteForRecovery
  state.isTransitionActive = function() return state.transitionActive end
  state.showStatus = showStatus
  log(state.valid and "INFO" or "ERROR", "transit_representation_validation", {
    configurationVersion = config.configurationVersion,
    valid = state.valid,
    menuInstalled = state.menu ~= nil,
    transitionIntervalSeconds = config.transitRepresentation.transitionIntervalSeconds,
    physicalMode = config.routing.physicalMode,
    maximumAssignedWaypoints = 2,
    roadsUsedForNormalMovement = false,
    automaticRecoveryInterface = true,
    errorCount = #state.errors,
  })
  return state
end

return TM02W2FTransitRepresentation
