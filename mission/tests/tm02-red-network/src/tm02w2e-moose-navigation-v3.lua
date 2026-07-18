local TM02W2EMooseNavigationV3 = {}
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

local function coordinateFromVec3(value)
  local point = vec3(value)
  if not point then
    return nil
  end
  return COORDINATE:NewFromVec3(point)
end

local function distance2D(first, second)
  local firstPoint = vec3(first)
  local secondPoint = vec3(second)
  if not firstPoint or not secondPoint then
    return math.huge
  end
  local dx = secondPoint.x - firstPoint.x
  local dz = secondPoint.z - firstPoint.z
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

local function interpolate(first, second, fraction)
  local firstPoint = vec3(first)
  local secondPoint = vec3(second)
  if not firstPoint or not secondPoint then
    return nil
  end
  return COORDINATE:NewFromVec3({
    x = firstPoint.x + (secondPoint.x - firstPoint.x) * fraction,
    y = firstPoint.y + (secondPoint.y - firstPoint.y) * fraction,
    z = firstPoint.z + (secondPoint.z - firstPoint.z) * fraction,
  })
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
  local t = ((p.x - a.x) * dx + (p.z - a.z) * dz) / lengthSquared
  t = math.max(0, math.min(1, t))
  local closest = {
    x = a.x + dx * t,
    z = a.z + dz * t,
  }
  return distance2D(closest, p)
end

function TM02W2EMooseNavigationV3.install(config, registryState, plannerState)
  local prefix = "[OMW][TM02W2E][NAV]"
  local navigation = {
    valid = false,
    errors = {},
    warnings = {},
    portalsBySiteId = {},
    exclusions = {},
    movementLinkByPair = {},
    planByPair = {},
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
    log("ERROR", "navigation_error", { code = code, detail = detail })
  end

  local function addWarning(code, detail)
    navigation.warnings[#navigation.warnings + 1] = tostring(code) .. ": " .. tostring(detail)
    log("WARNING", "navigation_warning", { code = code, detail = detail })
  end

  local function pointBlocked(coordinate)
    for _, exclusion in ipairs(navigation.exclusions) do
      if distance2D(coordinate, exclusion.coordinate) <= exclusion.radiusMeters then
        return true, exclusion.objectiveId
      end
    end
    return false, nil
  end

  local function segmentBlocked(first, second)
    for _, exclusion in ipairs(navigation.exclusions) do
      if segmentDistanceToPoint(first, second, exclusion.coordinate) <= exclusion.radiusMeters then
        return true, exclusion.objectiveId
      end
    end
    return false, nil
  end

  local function pathBlocked(coordinates)
    for index, coordinate in ipairs(coordinates or {}) do
      local blocked, objectiveId = pointBlocked(coordinate)
      if blocked then
        return true, objectiveId
      end
      if index > 1 then
        blocked, objectiveId = segmentBlocked(coordinates[index - 1], coordinate)
        if blocked then
          return true, objectiveId
        end
      end
    end
    return false, nil
  end

  local function validateDirectApis()
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
      { "SPAWN.NewWithAlias", SPAWN and SPAWN.NewWithAlias },
    }
    for _, definition in ipairs(required) do
      if type(definition[2]) ~= "function" then
        addError("MOOSE_API_MISSING", definition[1])
      end
    end
  end

  local function registerExclusions()
    local bufferMeters = config.navigation.blueObjectiveBufferMeters or 250
    for objectiveId, objective in pairs(registryState.objectiveById or {}) do
      navigation.exclusions[#navigation.exclusions + 1] = {
        objectiveId = objectiveId,
        coordinate = objective.coordinate,
        radiusMeters = (objective.radius or 0) + bufferMeters,
      }
    end
  end

  local function registerPortals()
    for siteId in pairs(registryState.siteById or {}) do
      local zone = ZONE:FindByName(siteId)
      local center = zone and zone:GetCoordinate() or nil
      local portal = center and safeCall(center, "GetClosestPointToRoad", false) or nil
      if not portal then
        addError("ROAD_PORTAL_MISSING", siteId)
      else
        local snapDistanceMeters = distance2D(center, portal)
        local blocked, objectiveId = pointBlocked(portal)
        if blocked then
          addError("ROAD_PORTAL_IN_BLUE_EXCLUSION", siteId .. " objective=" .. tostring(objectiveId))
        else
          navigation.portalsBySiteId[siteId] = portal
          if snapDistanceMeters > (config.navigation.maximumRoadSnapMeters or 1500) then
            addWarning(
              "ROAD_PORTAL_DISTANT",
              siteId .. " distance=" .. string.format("%.0f", snapDistanceMeters)
            )
          end
          log("INFO", "road_portal_registered", {
            siteId = siteId,
            snapDistanceMeters = string.format("%.0f", snapDistanceMeters),
            distant = snapDistanceMeters > (config.navigation.maximumRoadSnapMeters or 1500),
          })
        end
      end
    end
  end

  local function getRoadCandidate(fromCoordinate, toCoordinate)
    local ok, coordinates, lengthMeters, validPath = pcall(function()
      return fromCoordinate:GetPathOnRoad(toCoordinate, true, false, false, false)
    end)
    if not ok then
      return nil, nil, "GET_PATH_ERROR:" .. tostring(coordinates)
    end
    if validPath ~= true or type(coordinates) ~= "table" or #coordinates < 2 then
      return nil, nil, "NO_VALID_ROAD_PATH"
    end
    local blocked, objectiveId = pathBlocked(coordinates)
    if blocked then
      return nil, nil, "BLUE_EXCLUSION:" .. tostring(objectiveId)
    end
    local directMeters = distance2D(fromCoordinate, toCoordinate)
    local factor = directMeters > 0 and lengthMeters / directMeters or math.huge
    if lengthMeters > (config.navigation.maximumRoadPathMeters or 25000) then
      return nil, nil, "ROAD_PATH_TOO_LONG:" .. string.format("%.0f", lengthMeters)
    end
    if factor > (config.navigation.maximumRoadDetourFactor or 8) then
      return nil, nil, "ROAD_DETOUR_FACTOR:" .. string.format("%.2f", factor)
    end
    return coordinates, lengthMeters, nil
  end

  local function addAvoidanceCandidates(astar, nodes, exclusion)
    local clearance = config.navigation.exclusionClearanceMeters or 150
    local radius = exclusion.radiusMeters + clearance
    for index = 0, 7 do
      local angle = index * math.pi / 4
      local center = vec3(exclusion.coordinate)
      local coordinate = COORDINATE:NewFromVec3({
        x = center.x + math.cos(angle) * radius,
        y = center.y,
        z = center.z + math.sin(angle) * radius,
      })
      local blocked = pointBlocked(coordinate)
      if not blocked then
        local node = astar:AddNodeFromCoordinate(coordinate)
        node.coordinate = coordinate
        nodes[#nodes + 1] = node
      end
    end
  end

  local function getOffRoadCandidate(fromCoordinate, toCoordinate)
    local astar = ASTAR:New()
    local nodes = {}
    local startNode = astar:AddNodeFromCoordinate(fromCoordinate)
    startNode.coordinate = fromCoordinate
    nodes[#nodes + 1] = startNode
    local endNode = astar:AddNodeFromCoordinate(toCoordinate)
    endNode.coordinate = toCoordinate
    nodes[#nodes + 1] = endNode

    for _, exclusion in ipairs(navigation.exclusions) do
      addAvoidanceCandidates(astar, nodes, exclusion)
    end

    astar:FindStartNode(startNode)
    astar:FindEndNode(endNode)
    astar:SetValidNeighbourFunction(function(firstNode, secondNode)
      return segmentBlocked(firstNode.coordinate, secondNode.coordinate) ~= true
    end)
    astar:SetCostFunction(function(firstNode, secondNode)
      return distance2D(firstNode.coordinate, secondNode.coordinate)
    end)

    local result = astar:GetPath(false, false)
    if type(result) ~= "table" or #result < 2 then
      return nil, nil, "NO_SAFE_OFFROAD_PATH"
    end
    local coordinates = {}
    local lengthMeters = 0
    for index, node in ipairs(result) do
      coordinates[#coordinates + 1] = node.coordinate
      if index > 1 then
        lengthMeters = lengthMeters + distance2D(result[index - 1].coordinate, node.coordinate)
      end
    end
    return coordinates, lengthMeters, nil
  end

  local function buildHybridPlan(fromCoordinate, toCoordinate)
    local roadCoordinates, roadLength, roadReason = getRoadCandidate(fromCoordinate, toCoordinate)
    if roadCoordinates then
      return {
        safe = true,
        mode = "ROAD",
        coordinates = roadCoordinates,
        lengthMeters = roadLength,
        roadRejectionReason = "none",
      }
    end

    local offRoadCoordinates, offRoadLength, offRoadReason = getOffRoadCandidate(fromCoordinate, toCoordinate)
    if offRoadCoordinates then
      return {
        safe = true,
        mode = "OFFROAD_FALLBACK",
        coordinates = offRoadCoordinates,
        lengthMeters = offRoadLength,
        roadRejectionReason = roadReason,
      }
    end

    return {
      safe = false,
      mode = "UNAVAILABLE",
      coordinates = nil,
      lengthMeters = nil,
      roadRejectionReason = roadReason,
      rejectionReason = offRoadReason,
    }
  end

  local function compileMovementEdges()
    for _, link in ipairs(registryState.movementLinks or {}) do
      local sourcePortal = navigation.portalsBySiteId[link.sourceSiteId]
      local targetPortal = navigation.portalsBySiteId[link.targetSiteId]
      local plan = nil
      if sourcePortal and targetPortal then
        plan = buildHybridPlan(sourcePortal, targetPortal)
      else
        plan = {
          safe = false,
          mode = "UNAVAILABLE",
          rejectionReason = "ENDPOINT_MISSING",
        }
      end
      plan.sourceSiteId = link.sourceSiteId
      plan.targetSiteId = link.targetSiteId
      plan.linkId = link.linkId
      navigation.movementLinkByPair[pairKey(link.sourceSiteId, link.targetSiteId)] = link
      navigation.planByPair[pairKey(link.sourceSiteId, link.targetSiteId)] = plan
      log(plan.safe and "INFO" or "ERROR", "movement_edge_compiled", {
        linkId = link.linkId,
        sourceSiteId = link.sourceSiteId,
        targetSiteId = link.targetSiteId,
        safe = plan.safe,
        mode = plan.mode,
        pathDistanceMeters = plan.lengthMeters and string.format("%.0f", plan.lengthMeters) or "none",
        pointCount = plan.coordinates and #plan.coordinates or 0,
        roadRejectionReason = plan.roadRejectionReason or "none",
        rejectionReason = plan.rejectionReason or "none",
      })
      if plan.safe ~= true then
        addError("MOVEMENT_EDGE_UNUSABLE", link.linkId .. " reason=" .. tostring(plan.rejectionReason))
      end
    end
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
      roadRejectionReason = plan.roadRejectionReason,
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      linkId = plan.linkId,
    }
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
      local plan = context.planByPair[pairKey(firstNode.siteId, secondNode.siteId)]
      return plan ~= nil and plan.safe == true
    end, navigation)
    astar:SetCostFunction(function(firstNode, secondNode, context)
      local plan = context.planByPair[pairKey(firstNode.siteId, secondNode.siteId)]
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

  local function sampleCoordinates(coordinates, spacingMeters)
    if type(coordinates) ~= "table" or #coordinates < 2 then
      return nil
    end
    local result = { coordinates[1] }
    for segmentIndex = 2, #coordinates do
      local first = coordinates[segmentIndex - 1]
      local second = coordinates[segmentIndex]
      local segmentMeters = distance2D(first, second)
      local steps = math.max(1, math.ceil(segmentMeters / spacingMeters))
      for step = 1, steps do
        local coordinate = interpolate(first, second, step / steps)
        result[#result + 1] = coordinate
      end
    end
    return result
  end

  local function assignPlan(group, plan, reason)
    if not plan or plan.safe ~= true then
      return false
    end
    local spacingMeters = plan.mode == "ROAD"
      and (config.navigation.routeWaypointSpacingMeters or 100)
      or (config.navigation.offRoadWaypointSpacingMeters or 150)
    local sampled = sampleCoordinates(plan.coordinates, spacingMeters)
    if not sampled or #sampled < 2 then
      return false
    end
    local formation = plan.mode == "ROAD"
      and (config.routing.roadFormation or "On Road")
      or (config.routing.offRoadFormation or "Off Road")
    local waypoints = {}
    for _, coordinate in ipairs(sampled) do
      waypoints[#waypoints + 1] = coordinate:WaypointGround(
        config.routing.proxyTestSpeedKph,
        formation
      )
    end
    safeCall(group, "OptionROEReturnFire")
    safeCall(group, "OptionAlarmStateAuto")
    local originalRoute = group.__OMWTM02W2EOriginalRoute or group.Route
    if type(originalRoute) ~= "function" then
      return false
    end
    local ok, assigned = pcall(function()
      return originalRoute(group, waypoints, config.routing.assignmentDelaySeconds)
    end)
    if not ok or not assigned then
      return false
    end
    navigation.routeContextByGroupName[group:GetName()] = {
      sourceSiteId = plan.sourceSiteId,
      targetSiteId = plan.targetSiteId,
      mode = plan.mode,
      coordinates = sampled,
      lengthMeters = plan.lengthMeters,
    }
    log("INFO", "hybrid_route_assigned", {
      groupName = group:GetName(),
      sourceSiteId = plan.sourceSiteId,
      targetSiteId = plan.targetSiteId,
      mode = plan.mode,
      reason = reason or "normal",
      waypointCount = #waypoints,
      pathDistanceMeters = plan.lengthMeters and string.format("%.0f", plan.lengthMeters) or "unknown",
    })
    return true
  end

  local function wrapProxyGroup(group)
    if not group or group.__OMWTM02W2EV3Wrapped == true then
      return group
    end
    local originalRoute = group.Route
    local originalIsCompletelyInZone = group.IsCompletelyInZone
    if type(originalRoute) ~= "function" or type(originalIsCompletelyInZone) ~= "function" then
      addError("GROUP_INSTANCE_API_MISSING", group:GetName())
      return group
    end
    group.__OMWTM02W2EV3Wrapped = true
    group.__OMWTM02W2EOriginalRoute = originalRoute
    group.__OMWTM02W2EOriginalIsCompletelyInZone = originalIsCompletelyInZone

    function group:Route(route, delay)
      local firstWaypoint = type(route) == "table" and route[1] or nil
      local lastWaypoint = type(route) == "table" and route[#route] or nil
      local sourceSiteId = nearestSiteToWaypoint(firstWaypoint)
      local targetSiteId = nearestSiteToWaypoint(lastWaypoint)
      local plan = sourceSiteId and targetSiteId and directedPlan(sourceSiteId, targetSiteId) or nil
      if plan and assignPlan(self, plan, "executor-leg") then
        return self
      end
      return self.__OMWTM02W2EOriginalRoute(self, route, delay)
    end

    function group:IsCompletelyInZone(zone)
      local context = navigation.routeContextByGroupName[self:GetName()]
      if context and zoneName(zone) == context.targetSiteId then
        local portal = navigation.portalsBySiteId[context.targetSiteId]
        if portal
          and distance2D(self:GetCoordinate(), portal)
            <= (config.navigation.portalArrivalRadiusMeters or 100) then
          return true
        end
      end
      return self.__OMWTM02W2EOriginalIsCompletelyInZone(self, zone)
    end
    return group
  end

  local function patchProxySpawner()
    if SPAWN.__OMWTM02W2EV3Installed == true then
      return
    end
    SPAWN.__OMWTM02W2EV3Installed = true
    local originalNewWithAlias = SPAWN.NewWithAlias
    SPAWN.NewWithAlias = function(spawnClass, templateName, alias)
      local spawner = originalNewWithAlias(spawnClass, templateName, alias)
      if startsWith(alias, config.proxy.runtimeAliasPrefix) then
        function spawner:SpawnInZone(zone, randomize)
          if randomize ~= false then
            error("TM02W2E portal spawn requires randomize=false")
          end
          local active = TM02W2EMooseNavigationV3.__active
          local portal = active and active.portalsBySiteId[zoneName(zone)] or nil
          if not portal then
            error("TM02W2E portal unavailable for " .. tostring(zoneName(zone)))
          end
          return wrapProxyGroup(self:SpawnFromCoordinate(portal))
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

  local function resetSample(task, now, position, goalDistance)
    task.navMovementSample = {
      startedAt = now,
      startPosition = position,
      lastPosition = position,
      travelledMeters = 0,
      startGoalDistanceMeters = goalDistance,
    }
  end

  local function pointAhead(coordinates, requestedMeters)
    local travelled = 0
    for index = 2, #(coordinates or {}) do
      local first = coordinates[index - 1]
      local second = coordinates[index]
      local segmentMeters = distance2D(first, second)
      if travelled + segmentMeters >= requestedMeters then
        return interpolate(first, second, (requestedMeters - travelled) / segmentMeters)
      end
      travelled = travelled + segmentMeters
    end
    return nil
  end

  local function stopForNavigationFailure(task, reason)
    local execution = navigation.executionState
    if not execution or execution.failed then
      return
    end
    execution.failed = true
    execution.completed = false
    execution.monitorActive = false
    execution.monitorGeneration = (execution.monitorGeneration or 0) + 1
    execution.errors[#execution.errors + 1] = "NAVIGATION_BLOCKED: " .. task.taskId .. ": " .. tostring(reason)
    if task.movementState == "EN_ROUTE" then
      task.movementState = "FAILED"
      task.representationState = "NONE"
      execution.failedTaskCount = (execution.failedTaskCount or 0) + 1
      execution.activeTaskCount = math.max(0, (execution.activeTaskCount or 0) - 1)
    end
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
      stopForNavigationFailure(task, "maximum recovery attempts exceeded")
      return
    end

    local nextSiteId = task.path[task.currentLegIndex + 1]
    local targetPortal = navigation.portalsBySiteId[nextSiteId]
    local dynamicPlan = buildHybridPlan(task.proxyGroup:GetCoordinate(), targetPortal)
    dynamicPlan.sourceSiteId = task.path[task.currentLegIndex]
    dynamicPlan.targetSiteId = nextSiteId

    if recoveryCount == 1 then
      if not assignPlan(task.proxyGroup, dynamicPlan, "watchdog-reroute") then
        stopForNavigationFailure(task, "hybrid reroute failed")
      end
      return
    end

    local advanceMeters = math.min(
      (config.navigation.recoveryAdvanceMeters or 20) * (recoveryCount - 1),
      config.navigation.maximumRecoveryAdvanceMeters or 80
    )
    local coordinate = dynamicPlan.safe and pointAhead(dynamicPlan.coordinates, advanceMeters) or nil
    if not coordinate then
      stopForNavigationFailure(task, "safe recovery point unavailable")
      return
    end
    local blocked, objectiveId = pointBlocked(coordinate)
    if blocked then
      stopForNavigationFailure(task, "recovery point blocked by " .. tostring(objectiveId))
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
    replacement = wrapProxyGroup(replacement)
    if not replacement or replacement:CountAliveUnits() ~= 1 then
      stopForNavigationFailure(task, "proxy replacement failed")
      return
    end

    local oldProxy = task.proxyGroup
    task.proxyGroup = replacement
    task.proxyGroupName = replacement:GetName()
    task.navArmyGroup = nil
    task.navArmyGroupName = nil
    task.navObservedHitCount = nil
    pcall(function() oldProxy:Destroy() end)

    local replacementPlan = buildHybridPlan(replacement:GetCoordinate(), targetPortal)
    replacementPlan.sourceSiteId = task.path[task.currentLegIndex]
    replacementPlan.targetSiteId = nextSiteId
    if not assignPlan(replacement, replacementPlan, "watchdog-relocation") then
      stopForNavigationFailure(task, "replacement route failed")
      return
    end
    log("WARNING", "proxy_relocated_on_safe_path", {
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
      resetSample(task, now, position, goalDistance)
      return
    end
    local sample = task.navMovementSample
    if not sample then
      resetSample(task, now, position, goalDistance)
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
    local currentPosition = task.proxyGroup and vec3(task.proxyGroup:GetCoordinate()) or position
    resetSample(task, now, currentPosition, distance2D(currentPosition, goal))
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

  validateDirectApis()
  registerExclusions()
  registerPortals()
  compileMovementEdges()
  TM02W2EMooseNavigationV3.__active = navigation
  if #navigation.errors == 0 then
    patchProxySpawner()
  end
  navigation.valid = #navigation.errors == 0
  local portalCount = 0
  local roadEdgeCount = 0
  local offRoadEdgeCount = 0
  for _ in pairs(navigation.portalsBySiteId) do portalCount = portalCount + 1 end
  for _, plan in pairs(navigation.planByPair) do
    if plan.mode == "ROAD" then roadEdgeCount = roadEdgeCount + 1 end
    if plan.mode == "OFFROAD_FALLBACK" then offRoadEdgeCount = offRoadEdgeCount + 1 end
  end
  log("INFO", "navigation_validation", {
    configurationVersion = config.configurationVersion,
    valid = navigation.valid,
    errorCount = #navigation.errors,
    warningCount = #navigation.warnings,
    portalCount = portalCount,
    exclusionCount = #navigation.exclusions,
    movementEdgeCount = #(registryState.movementLinks or {}),
    roadEdgeCount = roadEdgeCount,
    offRoadFallbackEdgeCount = offRoadEdgeCount,
  })
  return navigation
end

return TM02W2EMooseNavigationV3
