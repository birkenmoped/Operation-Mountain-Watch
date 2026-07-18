local TM02W2EMooseNavigation = {}
local unpackValues = unpack or table.unpack

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
  first = vec3(first)
  second = vec3(second)
  if not first or not second then
    return math.huge
  end
  local dx = second.x - first.x
  local dz = second.z - first.z
  return math.sqrt(dx * dx + dz * dz)
end

local function zoneName(zone)
  if not zone then
    return nil
  end
  if type(zone.GetName) == "function" then
    local ok, result = pcall(function()
      return zone:GetName()
    end)
    if ok then
      return result
    end
  end
  return zone.ZoneName or zone.name
end

local function safeCall(object, methodName, ...)
  if type(object) ~= "table" or type(object[methodName]) ~= "function" then
    return nil
  end
  local arguments = { ... }
  local ok, result = pcall(function()
    return object[methodName](object, unpackValues(arguments))
  end)
  if ok then
    return result
  end
  return nil
end

local function interpolateCoordinate(first, second, fraction)
  local firstVec = vec3(first)
  local secondVec = vec3(second)
  if not firstVec or not secondVec then
    return nil
  end
  return COORDINATE:NewFromVec3({
    x = firstVec.x + (secondVec.x - firstVec.x) * fraction,
    y = firstVec.y + (secondVec.y - firstVec.y) * fraction,
    z = firstVec.z + (secondVec.z - firstVec.z) * fraction,
  })
end

function TM02W2EMooseNavigation.install(config, registryState, plannerState)
  local prefix = "[OMW][TM02W2E][NAV]"
  local navigation = {
    valid = false,
    errors = {},
    warnings = {},
    portalsBySiteId = {},
    exclusionZones = {},
    movementLinkByPair = {},
    roadPlanByPair = {},
    routeContextByGroupName = {},
    executionState = nil,
    watchdogGeneration = 0,
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
    navigation.errors[#navigation.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "navigation_error", {
      code = code,
      detail = detail,
    })
  end

  local function addWarning(code, detail)
    navigation.warnings[#navigation.warnings + 1] = tostring(code) .. ": " .. tostring(detail)
    log("WARNING", "navigation_warning", {
      code = code,
      detail = detail,
    })
  end

  local function coordinateBlocked(coordinate)
    local point = vec3(coordinate)
    if not point then
      return true, "NO_COORDINATE"
    end
    for _, exclusion in ipairs(navigation.exclusionZones) do
      if distance2D(point, exclusion.coordinate) <= exclusion.radiusMeters then
        return true, exclusion.objectiveId
      end
    end
    return false, nil
  end

  local function getRoadPath(fromCoordinate, toCoordinate)
    if not fromCoordinate or not toCoordinate then
      return nil, nil, "ENDPOINT_MISSING"
    end
    local ok, path, lengthMeters, validPath = pcall(function()
      return fromCoordinate:GetPathOnRoad(
        toCoordinate,
        true,
        false,
        false,
        false
      )
    end)
    if not ok then
      return nil, nil, "GET_PATH_ERROR:" .. tostring(path)
    end
    if validPath ~= true or type(path) ~= "table" or #path < 2 then
      return nil, nil, "NO_VALID_ROAD_PATH"
    end
    for _, coordinate in ipairs(path) do
      local blocked, objectiveId = coordinateBlocked(coordinate)
      if blocked then
        return nil, nil, "BLUE_EXCLUSION:" .. tostring(objectiveId)
      end
    end
    return path, lengthMeters, nil
  end

  local function validateRequiredMooseApis()
    local required = {
      { "COORDINATE.NewFromVec3", COORDINATE and COORDINATE.NewFromVec3 },
      { "COORDINATE.GetClosestPointToRoad", COORDINATE and COORDINATE.GetClosestPointToRoad },
      { "COORDINATE.GetPathOnRoad", COORDINATE and COORDINATE.GetPathOnRoad },
      { "COORDINATE.WaypointGround", COORDINATE and COORDINATE.WaypointGround },
      { "ASTAR.New", ASTAR and ASTAR.New },
      { "ASTAR.AddNodeFromCoordinate", ASTAR and ASTAR.AddNodeFromCoordinate },
      { "ASTAR.FindStartNode", ASTAR and ASTAR.FindStartNode },
      { "ASTAR.FindEndNode", ASTAR and ASTAR.FindEndNode },
      { "ASTAR.SetValidNeighbourFunction", ASTAR and ASTAR.SetValidNeighbourFunction },
      { "ASTAR.SetCostFunction", ASTAR and ASTAR.SetCostFunction },
      { "ASTAR.GetPath", ASTAR and ASTAR.GetPath },
      { "ARMYGROUP.New", ARMYGROUP and ARMYGROUP.New },
      { "ARMYGROUP.IsEngaging", ARMYGROUP and ARMYGROUP.IsEngaging },
      { "GROUP.Route", GROUP and GROUP.Route },
      { "GROUP.RouteGroundOnRoad", GROUP and GROUP.RouteGroundOnRoad },
      { "GROUP.IsCompletelyInZone", GROUP and GROUP.IsCompletelyInZone },
      { "SPAWN.NewWithAlias", SPAWN and SPAWN.NewWithAlias },
      { "SPAWN.SpawnFromCoordinate", SPAWN and SPAWN.SpawnFromCoordinate },
    }
    for _, definition in ipairs(required) do
      if type(definition[2]) ~= "function" then
        addError("MOOSE_API_MISSING", definition[1])
      end
    end
  end

  local function registerPortalsAndExclusions()
    local bufferMeters = config.navigation.blueObjectiveBufferMeters or 250
    for objectiveId, objective in pairs(registryState.objectiveById or {}) do
      navigation.exclusionZones[#navigation.exclusionZones + 1] = {
        objectiveId = objectiveId,
        coordinate = objective.coordinate,
        radiusMeters = (objective.radius or 0) + bufferMeters,
      }
    end

    for siteId in pairs(registryState.siteById or {}) do
      local zone = ZONE:FindByName(siteId)
      local center = zone and zone:GetCoordinate() or nil
      local portal = center and safeCall(center, "GetClosestPointToRoad", false) or nil
      if not portal then
        addError("ROAD_PORTAL_MISSING", siteId)
      else
        local snapDistanceMeters = distance2D(center, portal)
        local blocked, objectiveId = coordinateBlocked(portal)
        if snapDistanceMeters > (config.navigation.maximumRoadSnapMeters or 1500) then
          addError("ROAD_PORTAL_TOO_FAR", siteId .. " distance=" .. tostring(snapDistanceMeters))
        elseif blocked then
          addError("ROAD_PORTAL_IN_BLUE_EXCLUSION", siteId .. " objective=" .. tostring(objectiveId))
        else
          navigation.portalsBySiteId[siteId] = portal
          log("INFO", "road_portal_registered", {
            siteId = siteId,
            snapDistanceMeters = string.format("%.0f", snapDistanceMeters),
          })
        end
      end
    end
  end

  local function compileMovementEdges()
    for _, link in ipairs(registryState.movementLinks or {}) do
      local key = pairKey(link.sourceSiteId, link.targetSiteId)
      local path, lengthMeters, reason = getRoadPath(
        navigation.portalsBySiteId[link.sourceSiteId],
        navigation.portalsBySiteId[link.targetSiteId]
      )
      navigation.movementLinkByPair[key] = link
      navigation.roadPlanByPair[key] = {
        sourceSiteId = link.sourceSiteId,
        targetSiteId = link.targetSiteId,
        coordinates = path,
        lengthMeters = lengthMeters,
        safe = reason == nil,
        rejectionReason = reason,
      }
      log(reason and "WARNING" or "INFO", "road_edge_compiled", {
        linkId = link.linkId,
        sourceSiteId = link.sourceSiteId,
        targetSiteId = link.targetSiteId,
        safe = reason == nil,
        rejectionReason = reason or "none",
        roadDistanceMeters = lengthMeters and string.format("%.0f", lengthMeters) or "none",
        roadPointCount = path and #path or 0,
      })
    end
  end

  local function roadPlanForDirection(sourceSiteId, targetSiteId)
    local plan = navigation.roadPlanByPair[pairKey(sourceSiteId, targetSiteId)]
    if not plan or plan.safe ~= true then
      return nil
    end
    if plan.sourceSiteId == sourceSiteId and plan.targetSiteId == targetSiteId then
      return plan.coordinates
    end
    return reverseArray(plan.coordinates)
  end

  local function safeLogicalPath(sourceSiteId, targetSiteId)
    local astar = ASTAR:New()
    local nodesBySiteId = {}
    for siteId, portal in pairs(navigation.portalsBySiteId) do
      local node = astar:AddNodeFromCoordinate(portal)
      node.siteId = siteId
      nodesBySiteId[siteId] = node
    end
    if not nodesBySiteId[sourceSiteId] or not nodesBySiteId[targetSiteId] then
      return nil
    end
    astar:FindStartNode(nodesBySiteId[sourceSiteId])
    astar:FindEndNode(nodesBySiteId[targetSiteId])
    astar:SetValidNeighbourFunction(function(firstNode, secondNode, context)
      local plan = context.roadPlanByPair[pairKey(firstNode.siteId, secondNode.siteId)]
      return plan ~= nil and plan.safe == true
    end, navigation)
    astar:SetCostFunction(function(firstNode, secondNode, context)
      local plan = context.roadPlanByPair[pairKey(firstNode.siteId, secondNode.siteId)]
      return plan and plan.lengthMeters or ASTAR.INF
    end, navigation)
    local result = astar:GetPath(false, false)
    if type(result) ~= "table" or #result < 2 then
      return nil
    end
    local path = {}
    for _, node in ipairs(result) do
      path[#path + 1] = node.siteId
    end
    return path
  end

  function navigation:preparePlannerTasks()
    for _, task in ipairs(plannerState.tasks or {}) do
      local path = safeLogicalPath(task.sourceSiteId, task.targetSiteId)
      if not path then
        addError("SAFE_LOGICAL_PATH_MISSING", task.taskId)
      else
        local linkIds = {}
        local complete = true
        for index = 1, #path - 1 do
          local link = self.movementLinkByPair[pairKey(path[index], path[index + 1])]
          if not link then
            addError("SAFE_LOGICAL_LINK_MISSING", task.taskId)
            complete = false
            break
          end
          linkIds[#linkIds + 1] = link.linkId
        end
        if complete then
          task.path = path
          task.linkIds = linkIds
          log("INFO", "safe_task_path_selected", {
            taskId = task.taskId,
            sourceSiteId = task.sourceSiteId,
            targetSiteId = task.targetSiteId,
            path = table.concat(path, ">"),
          })
        end
      end
    end
    self.valid = #self.errors == 0
    return self.valid
  end

  local function nearestSiteToWaypoint(waypoint)
    if type(waypoint) ~= "table"
      or type(waypoint.x) ~= "number"
      or type(waypoint.y) ~= "number" then
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

  local function sampleRoadCoordinates(coordinates, spacingMeters)
    if type(coordinates) ~= "table" or #coordinates < 2 then
      return nil
    end
    local result = { coordinates[1] }
    local distanceSinceLast = 0
    local previous = coordinates[1]
    for index = 2, #coordinates do
      local current = coordinates[index]
      distanceSinceLast = distanceSinceLast + distance2D(previous, current)
      if distanceSinceLast >= spacingMeters or index == #coordinates then
        result[#result + 1] = current
        distanceSinceLast = 0
      end
      previous = current
    end
    if result[#result] ~= coordinates[#coordinates] then
      result[#result + 1] = coordinates[#coordinates]
    end
    return result
  end

  local function assignExplicitRoadRoute(group, sourceSiteId, targetSiteId, reason, dynamicStart)
    local coordinates = nil
    local lengthMeters = nil
    if dynamicStart then
      local path, pathLength, pathError = getRoadPath(group:GetCoordinate(), navigation.portalsBySiteId[targetSiteId])
      if not path then
        log("ERROR", "dynamic_road_route_failed", {
          groupName = group:GetName(),
          targetSiteId = targetSiteId,
          reason = pathError,
        })
        return false
      end
      coordinates = path
      lengthMeters = pathLength
    else
      coordinates = roadPlanForDirection(sourceSiteId, targetSiteId)
      local stored = navigation.roadPlanByPair[pairKey(sourceSiteId, targetSiteId)]
      lengthMeters = stored and stored.lengthMeters or nil
    end
    if not coordinates then
      return false
    end

    local sampled = sampleRoadCoordinates(
      coordinates,
      config.navigation.routeWaypointSpacingMeters or 250
    )
    if not sampled or #sampled < 2 then
      return false
    end
    local waypoints = {}
    for _, coordinate in ipairs(sampled) do
      waypoints[#waypoints + 1] = coordinate:WaypointGround(
        config.routing.proxyTestSpeedKph,
        config.routing.roadFormation or "On Road"
      )
    end

    safeCall(group, "OptionROEReturnFire")
    safeCall(group, "OptionAlarmStateAuto")
    group.__OMWTM02W2EAssigningRoadRoute = true
    local ok, assigned = pcall(function()
      return GROUP.__OMWTM02W2EOriginalRoute(group, waypoints, config.routing.assignmentDelaySeconds)
    end)
    group.__OMWTM02W2EAssigningRoadRoute = nil
    if not ok or not assigned then
      return false
    end

    navigation.routeContextByGroupName[group:GetName()] = {
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      roadCoordinates = sampled,
      roadLengthMeters = lengthMeters,
    }
    log("INFO", "explicit_road_route_assigned", {
      groupName = group:GetName(),
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      reason = reason or "normal",
      waypointCount = #waypoints,
      roadDistanceMeters = lengthMeters and string.format("%.0f", lengthMeters) or "unknown",
    })
    return true
  end

  local function patchMooseRoutingAndSpawning()
    if GROUP.__OMWTM02W2ERoadNavigationInstalled == true then
      return
    end
    GROUP.__OMWTM02W2ERoadNavigationInstalled = true
    GROUP.__OMWTM02W2EOriginalRoute = GROUP.Route
    GROUP.__OMWTM02W2EOriginalIsCompletelyInZone = GROUP.IsCompletelyInZone

    function GROUP:Route(route, delay)
      local active = TM02W2EMooseNavigation.__active
      local groupName = self:GetName()
      if active
        and startsWith(groupName, config.proxy.runtimeAliasPrefix)
        and self.__OMWTM02W2EAssigningRoadRoute ~= true then
        local firstWaypoint = type(route) == "table" and route[1] or nil
        local lastWaypoint = type(route) == "table" and route[#route] or nil
        local sourceSiteId = nearestSiteToWaypoint(firstWaypoint)
        local targetSiteId = nearestSiteToWaypoint(lastWaypoint)
        if sourceSiteId and targetSiteId
          and assignExplicitRoadRoute(self, sourceSiteId, targetSiteId, "executor-leg", false) then
          return self
        end
      end
      return GROUP.__OMWTM02W2EOriginalRoute(self, route, delay)
    end

    function GROUP:IsCompletelyInZone(zone)
      local active = TM02W2EMooseNavigation.__active
      local groupName = self:GetName()
      local context = active
        and startsWith(groupName, config.proxy.runtimeAliasPrefix)
        and active.routeContextByGroupName[groupName]
        or nil
      if context and zoneName(zone) == context.targetSiteId then
        local portal = active.portalsBySiteId[context.targetSiteId]
        if portal
          and distance2D(self:GetCoordinate(), portal)
            <= (config.navigation.portalArrivalRadiusMeters or 100) then
          return true
        end
      end
      return GROUP.__OMWTM02W2EOriginalIsCompletelyInZone(self, zone)
    end

    local originalNewWithAlias = SPAWN.NewWithAlias
    SPAWN.NewWithAlias = function(spawnClass, templateName, alias)
      local spawner = originalNewWithAlias(spawnClass, templateName, alias)
      if startsWith(alias, config.proxy.runtimeAliasPrefix) then
        function spawner:SpawnInZone(zone, randomize)
          if randomize ~= false then
            error("TM02W2E road portal spawn requires randomize=false")
          end
          local active = TM02W2EMooseNavigation.__active
          local portal = active and active.portalsBySiteId[zoneName(zone)] or nil
          if not portal then
            error("TM02W2E road portal is unavailable for " .. tostring(zoneName(zone)))
          end
          return self:SpawnFromCoordinate(portal)
        end
      end
      return spawner
    end
  end

  local function taskInCombat(task, now)
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

  local function resetMovementSample(task, now, position, goalDistance)
    task.navMovementSample = {
      startedAt = now,
      startPosition = position,
      lastPosition = position,
      travelledMeters = 0,
      startGoalDistanceMeters = goalDistance,
    }
  end

  local function coordinateAheadOnRoad(currentCoordinate, targetCoordinate, requestedMeters)
    local path, _, errorReason = getRoadPath(currentCoordinate, targetCoordinate)
    if not path then
      return nil, errorReason
    end
    local travelled = 0
    local previous = path[1]
    for index = 2, #path do
      local current = path[index]
      local segment = distance2D(previous, current)
      if travelled + segment >= requestedMeters then
        local fraction = segment > 0 and (requestedMeters - travelled) / segment or 0
        local coordinate = interpolateCoordinate(previous, current, fraction)
        if coordinate then
          local blocked, objectiveId = coordinateBlocked(coordinate)
          if not blocked then
            return coordinate, nil
          end
          return nil, "BLUE_EXCLUSION:" .. tostring(objectiveId)
        end
      end
      travelled = travelled + segment
      previous = current
    end
    return nil, "ROAD_PATH_TOO_SHORT"
  end

  local function stopExecutionForNavigationFailure(task, reason)
    local execution = navigation.executionState
    execution.failed = true
    execution.completed = false
    execution.monitorActive = false
    execution.monitorGeneration = (execution.monitorGeneration or 0) + 1
    execution.errors[#execution.errors + 1] = "NAVIGATION_BLOCKED: " .. task.taskId .. ": " .. tostring(reason)
    log("ERROR", "navigation_blocked", {
      taskId = task.taskId,
      reason = reason,
      recoveryCount = task.navRecoveryCount or 0,
    })
  end

  local function recoverTask(task, now, reason)
    if taskInCombat(task, now) then
      log("INFO", "watchdog_recovery_suppressed_combat", {
        taskId = task.taskId,
        reason = reason,
      })
      return
    end

    task.navRecoveryCount = (task.navRecoveryCount or 0) + 1
    local recoveryCount = task.navRecoveryCount
    if recoveryCount > (config.navigation.maxRecoveryAttempts or 4) then
      stopExecutionForNavigationFailure(task, "maximum recovery attempts exceeded")
      return
    end

    local nextSiteId = task.path[task.currentLegIndex + 1]
    if recoveryCount == 1 then
      if not assignExplicitRoadRoute(
        task.proxyGroup,
        task.path[task.currentLegIndex],
        nextSiteId,
        "watchdog-reroute",
        true
      ) then
        stopExecutionForNavigationFailure(task, "road reroute failed")
      end
      return
    end

    local advanceMeters = math.min(
      (config.navigation.recoveryAdvanceMeters or 20) * (recoveryCount - 1),
      config.navigation.maximumRecoveryAdvanceMeters or 80
    )
    local coordinate, coordinateError = coordinateAheadOnRoad(
      task.proxyGroup:GetCoordinate(),
      navigation.portalsBySiteId[nextSiteId],
      advanceMeters
    )
    if not coordinate then
      stopExecutionForNavigationFailure(task, coordinateError)
      return
    end

    local alias = config.proxy.runtimeAliasPrefix
      .. task.taskId:gsub("[^%w]", "_")
      .. "_RECOVERY"
      .. tostring(recoveryCount)
    local replacement = SPAWN:NewWithAlias(
      config.templatesByStrength[task.strength],
      alias
    ):SpawnFromCoordinate(coordinate)
    if not replacement or replacement:CountAliveUnits() ~= 1 then
      stopExecutionForNavigationFailure(task, "proxy replacement failed")
      return
    end

    local oldProxy = task.proxyGroup
    task.proxyGroup = replacement
    task.proxyGroupName = replacement:GetName()
    task.navArmyGroup = nil
    task.navArmyGroupName = nil
    task.navObservedHitCount = nil
    pcall(function()
      oldProxy:Destroy()
    end)

    if not assignExplicitRoadRoute(
      replacement,
      task.path[task.currentLegIndex],
      nextSiteId,
      "watchdog-relocation",
      true
    ) then
      stopExecutionForNavigationFailure(task, "replacement route failed")
      return
    end

    log("WARNING", "proxy_relocated_on_road", {
      taskId = task.taskId,
      reason = reason,
      recoveryCount = recoveryCount,
      advanceMeters = advanceMeters,
      runtimeGroupName = replacement:GetName(),
    })
  end

  local function watchTask(task, now)
    if task.movementState ~= "EN_ROUTE"
      or not task.proxyGroup
      or task.proxyGroup:IsAlive() ~= true then
      task.navMovementSample = nil
      return
    end

    local position = vec3(task.proxyGroup:GetCoordinate())
    local nextSiteId = task.path[task.currentLegIndex + 1]
    local goal = navigation.portalsBySiteId[nextSiteId]
    if not position or not goal then
      return
    end
    local goalDistance = distance2D(position, goal)

    if taskInCombat(task, now) then
      resetMovementSample(task, now, position, goalDistance)
      return
    end

    local sample = task.navMovementSample
    if not sample then
      resetMovementSample(task, now, position, goalDistance)
      return
    end

    sample.travelledMeters = sample.travelledMeters + distance2D(sample.lastPosition, position)
    sample.lastPosition = position
    if now - sample.startedAt < (config.navigation.stuckWindowSeconds or 30) then
      return
    end

    local progressMeters = sample.startGoalDistanceMeters - goalDistance
    local netMovementMeters = distance2D(sample.startPosition, position)
    local stationary = sample.travelledMeters < (config.navigation.minimumTravelMeters or 8)
      and progressMeters < (config.navigation.minimumProgressMeters or 5)
    local circular = sample.travelledMeters >= (config.navigation.circularTravelMeters or 25)
      and netMovementMeters < (config.navigation.circularNetMeters or 8)
      and progressMeters < (config.navigation.minimumProgressMeters or 5)

    log("INFO", "watchdog_sample", {
      taskId = task.taskId,
      nextSiteId = nextSiteId,
      travelledMeters = string.format("%.1f", sample.travelledMeters),
      netMovementMeters = string.format("%.1f", netMovementMeters),
      progressMeters = string.format("%.1f", progressMeters),
      stationary = stationary,
      circular = circular,
      recoveryCount = task.navRecoveryCount or 0,
    })

    if stationary or circular then
      recoverTask(task, now, circular and "CIRCULAR_MOVEMENT" or "STATIONARY")
    end

    position = task.proxyGroup and vec3(task.proxyGroup:GetCoordinate()) or position
    resetMovementSample(task, now, position, distance2D(position, goal))
  end

  function navigation:attach(executionState)
    self.executionState = executionState
    self.watchdogGeneration = self.watchdogGeneration + 1
    local generation = self.watchdogGeneration
    timer.scheduleFunction(function(_, scheduledTime)
      if generation ~= self.watchdogGeneration
        or executionState.completed == true
        or executionState.failed == true then
        return nil
      end
      local now = timer.getTime()
      for _, task in ipairs(executionState.tasks or {}) do
        watchTask(task, now)
      end
      return scheduledTime + (config.navigation.watchdogIntervalSeconds or 5)
    end, nil, timer.getTime() + (config.navigation.watchdogInitialDelaySeconds or 5))

    log("INFO", "watchdog_started", {
      intervalSeconds = config.navigation.watchdogIntervalSeconds,
      stuckWindowSeconds = config.navigation.stuckWindowSeconds,
      combatCooldownSeconds = config.navigation.combatCooldownSeconds,
      maxRecoveryAttempts = config.navigation.maxRecoveryAttempts,
    })
  end

  validateRequiredMooseApis()
  registerPortalsAndExclusions()
  compileMovementEdges()
  TM02W2EMooseNavigation.__active = navigation
  if #navigation.errors == 0 then
    patchMooseRoutingAndSpawning()
  end
  navigation.valid = #navigation.errors == 0
  local portalCount = 0
  for _ in pairs(navigation.portalsBySiteId) do
    portalCount = portalCount + 1
  end
  log("INFO", "navigation_validation", {
    configurationVersion = config.configurationVersion,
    valid = navigation.valid,
    errorCount = #navigation.errors,
    warningCount = #navigation.warnings,
    portalCount = portalCount,
    exclusionCount = #navigation.exclusionZones,
    movementEdgeCount = #(registryState.movementLinks or {}),
  })
  return navigation
end

return TM02W2EMooseNavigation
