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

  local function routeLength(coordinates)
    local total = 0
    for index = 2, #(coordinates or {}) do
      total = total + distance2D(coordinates[index - 1], coordinates[index])
    end
    return total
  end

  local function projectAlong(coordinates, position)
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
    return bestAlong, bestDistance
  end

  local function sliceRoute(coordinates, requestedMeters, currentCoordinate)
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

  local function remainingContext(task)
    local group = task.proxyGroup
    local context = group and navigation.routeContextByGroupName[group:GetName()] or nil
    if not context or type(context.coordinates) ~= "table" or #context.coordinates < 2 then
      return nil, "ROUTE_CONTEXT_UNAVAILABLE"
    end
    local currentCoordinate = group:GetCoordinate()
    local along, crossTrack = projectAlong(context.coordinates, currentCoordinate)
    if not along then return nil, "ROUTE_PROJECTION_UNAVAILABLE" end
    local coordinates = sliceRoute(context.coordinates, along, currentCoordinate)
    return {
      sourceSiteId = context.sourceSiteId,
      targetSiteId = context.targetSiteId,
      mode = context.mode,
      coordinates = coordinates,
      lengthMeters = routeLength(coordinates),
      crossTrackMeters = crossTrack,
    }
  end

  local function assignRoute(group, context, reason)
    local formation = context.mode == "ROAD"
      and (config.routing.roadFormation or "On Road")
      or (config.routing.offRoadFormation or "Off Road")
    local waypoints = {}
    for _, coordinate in ipairs(context.coordinates) do
      waypoints[#waypoints + 1] = coordinate:WaypointGround(config.routing.proxyTestSpeedKph, formation)
    end
    local nativeRoute = group.__OMWTM02W2EOriginalRoute or group.Route
    local ok, assigned = pcall(function()
      return nativeRoute(group, waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then return false end
    navigation.routeContextByGroupName[group:GetName()] = context
    log("INFO", "transit_route_reassigned", {
      groupName = group:GetName(),
      reason = reason,
      waypointCount = #waypoints,
      remainingDistanceMeters = string.format("%.1f", context.lengthMeters),
    })
    return true
  end

  local generation = 0
  local function nextAlias(task, prefixValue)
    generation = generation + 1
    return prefixValue .. task.taskId:gsub("[^%w]", "_") .. "_M" .. string.format("%04d", generation)
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

  local function convertTask(task, unpack)
    if task.movementState ~= "EN_ROUTE" or not task.proxyGroup or task.proxyGroup:IsAlive() ~= true then
      return false, "TASK_NOT_TRAVELLING"
    end
    local context, reason = remainingContext(task)
    if not context then return false, reason end
    local oldGroup = task.proxyGroup
    local coordinate = oldGroup:GetCoordinate()
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
    if not assignRoute(replacement, context, unpack and "manual-unpack-all" or "manual-pack-all") then
      pcall(function() replacement:Destroy() end)
      return false, "ROUTE_ASSIGNMENT_FAILED"
    end

    local oldName = oldGroup:GetName()
    task.proxyGroup = replacement
    task.proxyGroupName = replacement:GetName()
    task.transitExpanded = unpack == true
    task.transitRepresentation = unpack and "FULL_GROUP" or "LEADER_PROXY"
    task.currentCoordinate = coordinate:GetVec3()
    resetSamples(task)
    pcall(function() oldGroup:Destroy() end)
    navigation.routeContextByGroupName[oldName] = nil
    log("INFO", unpack and "travelling_proxy_unpacked" or "travelling_group_packed", {
      taskId = task.taskId,
      strength = task.survivorCount,
      oldGroupName = oldName,
      newGroupName = replacement:GetName(),
      remainingDistanceMeters = string.format("%.1f", context.lengthMeters),
      crossTrackMeters = string.format("%.1f", context.crossTrackMeters),
    })
    return true
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
        local ok, success, reason = pcall(convertTask, task, unpack)
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
      return scheduledTime + config.transitRepresentation.transitionIntervalSeconds
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
  if type(navigation) ~= "table" or navigation.valid ~= true then
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
  state.showStatus = showStatus
  log(state.valid and "INFO" or "ERROR", "transit_representation_validation", {
    configurationVersion = config.configurationVersion,
    valid = state.valid,
    menuInstalled = state.menu ~= nil,
    transitionIntervalSeconds = config.transitRepresentation.transitionIntervalSeconds,
    errorCount = #state.errors,
  })
  return state
end

return TM02W2FTransitRepresentation
