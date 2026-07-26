local TM02W2FDirectOffroadNavigation = {}

local function directedKey(sourceSiteId, targetSiteId)
  return tostring(sourceSiteId) .. "\0" .. tostring(targetSiteId)
end

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function distance2D(first, second)
  local dx = (second.x or 0) - (first.x or 0)
  local dz = (second.z or 0) - (first.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function segmentDistanceToPoint(first, second, point)
  local dx = (second.x or 0) - (first.x or 0)
  local dz = (second.z or 0) - (first.z or 0)
  local lengthSquared = dx * dx + dz * dz
  local fraction = 0
  if lengthSquared > 0 then
    fraction = (((point.x or 0) - (first.x or 0)) * dx
      + ((point.z or 0) - (first.z or 0)) * dz) / lengthSquared
    fraction = math.max(0, math.min(1, fraction))
  end
  local projected = {
    x = (first.x or 0) + dx * fraction,
    z = (first.z or 0) + dz * fraction,
  }
  return distance2D(projected, point)
end

local function coordinateFromSite(site)
  return COORDINATE:NewFromVec3({
    x = site.coordinate.x,
    y = 0,
    z = site.coordinate.z,
  })
end

function TM02W2FDirectOffroadNavigation.install(config, registryState, plannerState)
  local state = {
    valid = true,
    routingReady = false,
    errors = {},
    warnings = {},
    registryState = registryState,
    plannerState = plannerState,
    planByDirectedPair = {},
    movementLinkByDirectedPair = {},
    safeEdgeCount = 0,
    blockedEdgeCount = 0,
    safeTaskCount = 0,
    moosePathCount = 0,
    fallbackPathCount = 0,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM02W2F][DIRECT] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function addError(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "direct_navigation_error", { code = code, detail = detail })
  end

  local function addWarning(code, detail)
    state.warnings[#state.warnings + 1] = tostring(code) .. ": " .. tostring(detail)
    log("WARNING", "direct_navigation_warning", { code = code, detail = detail })
  end

  if type(registryState) ~= "table" or registryState.configurationValid ~= true then
    addError("REGISTRY_INVALID", "TM02W1 registry unavailable or invalid")
  end
  if type(plannerState) ~= "table" or plannerState.configurationValid ~= true then
    addError("PLANNER_INVALID", "TM02W2F planner unavailable or invalid")
  end

  local requiredAstarApis = {
    "New",
    "AddNodeFromCoordinate",
    "SetStartCoordinate",
    "SetEndCoordinate",
    "SetValidNeighbourFunction",
    "SetCostFunction",
    "GetPath",
  }
  if type(ASTAR) ~= "table" then
    addError("MOOSE_ASTAR_MISSING", "ASTAR table unavailable")
  else
    for _, methodName in ipairs(requiredAstarApis) do
      if type(ASTAR[methodName]) ~= "function" then
        addError("MOOSE_ASTAR_API_MISSING", methodName)
      end
    end
  end
  if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec3) ~= "function" then
    addError("MOOSE_COORDINATE_MISSING", "COORDINATE.NewFromVec3 unavailable")
  end

  local objectiveBuffer = config.navigation.blueObjectiveBufferMeters or 250

  local function directSegmentSafe(sourceSite, targetSite)
    for objectiveId, objective in pairs(registryState.objectiveById or {}) do
      local protectedRadius = (objective.radius or 0) + objectiveBuffer
      local separation = segmentDistanceToPoint(
        sourceSite.coordinate,
        targetSite.coordinate,
        objective.coordinate
      )
      if separation < protectedRadius then
        return false, objectiveId, separation, protectedRadius
      end
    end
    return true, nil, nil, nil
  end

  local function registerDirectedPlan(link, sourceSiteId, targetSiteId)
    local sourceSite = registryState.siteById[sourceSiteId]
    local targetSite = registryState.siteById[targetSiteId]
    if not sourceSite or not targetSite then
      addError("MOVEMENT_ENDPOINT_MISSING", tostring(link.linkId))
      return
    end

    local safe, objectiveId, separation, protectedRadius = directSegmentSafe(sourceSite, targetSite)
    local key = directedKey(sourceSiteId, targetSiteId)
    state.movementLinkByDirectedPair[key] = link
    state.planByDirectedPair[key] = {
      safe = safe,
      mode = "DIRECT_OFFROAD",
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      linkId = link.linkId,
      lengthMeters = distance2D(sourceSite.coordinate, targetSite.coordinate),
      waypointCount = 2,
      blockedByObjectiveId = objectiveId,
    }

    if safe then
      state.safeEdgeCount = state.safeEdgeCount + 1
    else
      state.blockedEdgeCount = state.blockedEdgeCount + 1
    end

    log(safe and "INFO" or "WARNING", "direct_offroad_edge_compiled", {
      linkId = link.linkId,
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      safe = safe,
      mode = "DIRECT_OFFROAD",
      waypointCount = 2,
      lengthMeters = string.format("%.0f", state.planByDirectedPair[key].lengthMeters),
      blockedByObjectiveId = objectiveId or "none",
      objectiveSeparationMeters = separation and string.format("%.1f", separation) or "n/a",
      protectedRadiusMeters = protectedRadius and string.format("%.1f", protectedRadius) or "n/a",
    })
  end

  for _, link in ipairs(registryState.movementLinks or {}) do
    registerDirectedPlan(link, link.sourceSiteId, link.targetSiteId)
    if link.direction == "BIDIRECTIONAL" then
      registerDirectedPlan(link, link.targetSiteId, link.sourceSiteId)
    end
  end

  function state:getLegPlan(sourceSiteId, targetSiteId)
    return self.planByDirectedPair[directedKey(sourceSiteId, targetSiteId)]
  end

  local function customLogicalPath(sourceSiteId, targetSiteId)
    local siteIds = sortedKeys(registryState.siteById)
    local cost = { [sourceSiteId] = 0 }
    local previous = {}
    local visited = {}

    while true do
      local currentSiteId
      local currentCost = math.huge
      for _, siteId in ipairs(siteIds) do
        if not visited[siteId] and cost[siteId] and cost[siteId] < currentCost then
          currentSiteId = siteId
          currentCost = cost[siteId]
        end
      end

      if not currentSiteId then
        return nil
      end
      if currentSiteId == targetSiteId then
        break
      end

      visited[currentSiteId] = true
      for _, candidateSiteId in ipairs(siteIds) do
        if candidateSiteId ~= currentSiteId and not visited[candidateSiteId] then
          local plan = state:getLegPlan(currentSiteId, candidateSiteId)
          if plan and plan.safe == true then
            local candidateCost = currentCost + plan.lengthMeters
            if not cost[candidateSiteId] or candidateCost < cost[candidateSiteId] then
              cost[candidateSiteId] = candidateCost
              previous[candidateSiteId] = currentSiteId
            end
          end
        end
      end
    end

    local path = {}
    local currentSiteId = targetSiteId
    while currentSiteId do
      table.insert(path, 1, currentSiteId)
      currentSiteId = previous[currentSiteId]
    end
    if path[1] ~= sourceSiteId then
      return nil
    end
    return path
  end

  local function mooseLogicalPath(task)
    local astar = ASTAR:New()
    local nodesBySiteId = {}
    for siteId, site in pairs(registryState.siteById or {}) do
      local node = astar:AddNodeFromCoordinate(coordinateFromSite(site))
      node.siteId = siteId
      nodesBySiteId[siteId] = node
    end

    local startNode = nodesBySiteId[task.sourceSiteId]
    local endNode = nodesBySiteId[task.targetSiteId]
    if not startNode or not endNode then
      return nil, "TASK_ENDPOINT_MISSING"
    end

    astar:SetStartCoordinate(startNode.coordinate)
    astar:SetEndCoordinate(endNode.coordinate)
    astar:SetValidNeighbourFunction(function(firstNode, secondNode)
      local plan = state:getLegPlan(firstNode.siteId, secondNode.siteId)
      return plan ~= nil and plan.safe == true
    end)
    astar:SetCostFunction(function(firstNode, secondNode)
      return distance2D(firstNode.coordinate, secondNode.coordinate)
    end)

    local ok, result = pcall(function()
      return astar:GetPath(false, false)
    end)
    if not ok then
      return nil, "RUNTIME_ERROR:" .. tostring(result)
    end
    if type(result) ~= "table" or #result < 2 then
      return nil, "NO_PATH"
    end

    local path = {}
    for _, node in ipairs(result) do
      if type(node) ~= "table" or not node.siteId then
        return nil, "RESULT_NODE_WITHOUT_SITE_ID"
      end
      path[#path + 1] = node.siteId
    end
    if path[1] ~= task.sourceSiteId or path[#path] ~= task.targetSiteId then
      return nil, "RESULT_ENDPOINT_MISMATCH"
    end
    return path, nil
  end

  function state:preparePlannerTasks()
    self.safeTaskCount = 0
    self.moosePathCount = 0
    self.fallbackPathCount = 0

    for _, task in ipairs(plannerState.tasks or {}) do
      local path, mooseFailure = mooseLogicalPath(task)
      local method = "MOOSE_ASTAR_RED_NETWORK"

      if not path then
        addWarning("MOOSE_ASTAR_FALLBACK", task.taskId .. " reason=" .. tostring(mooseFailure))
        path = customLogicalPath(task.sourceSiteId, task.targetSiteId)
        method = "CUSTOM_GRAPH_AFTER_MOOSE_ASTAR"
      end

      if not path or #path < 2 then
        addError("SAFE_DIRECT_LOGICAL_PATH_MISSING",
          task.taskId .. " mooseReason=" .. tostring(mooseFailure))
      else
        local linkIds = {}
        local complete = true
        for index = 1, #path - 1 do
          local plan = self:getLegPlan(path[index], path[index + 1])
          if not plan or plan.safe ~= true then
            complete = false
            addError("SAFE_DIRECT_LEG_MISSING",
              task.taskId .. " leg=" .. path[index] .. ">" .. path[index + 1])
            break
          end
          linkIds[#linkIds + 1] = plan.linkId
        end

        if complete then
          task.path = path
          task.linkIds = linkIds
          task.routingMethod = method
          self.safeTaskCount = self.safeTaskCount + 1
          if method == "MOOSE_ASTAR_RED_NETWORK" then
            self.moosePathCount = self.moosePathCount + 1
          else
            self.fallbackPathCount = self.fallbackPathCount + 1
          end
          log("INFO", "direct_offroad_task_path_selected", {
            taskId = task.taskId,
            sourceSiteId = task.sourceSiteId,
            targetSiteId = task.targetSiteId,
            path = table.concat(path, ">"),
            legCount = #path - 1,
            physicalWaypointsPerLeg = 2,
            method = method,
          })
        end
      end
    end

    self.routingReady = self.valid == true
      and self.safeTaskCount == #(plannerState.tasks or {})
      and #self.errors == 0
    log(self.routingReady and "INFO" or "ERROR", "direct_offroad_navigation_validation", {
      configurationVersion = config.configurationVersion,
      valid = self.routingReady,
      safeTaskCount = self.safeTaskCount,
      expectedTaskCount = #(plannerState.tasks or {}),
      safeDirectedEdgeCount = self.safeEdgeCount,
      blockedDirectedEdgeCount = self.blockedEdgeCount,
      moosePathCount = self.moosePathCount,
      fallbackPathCount = self.fallbackPathCount,
      maximumPhysicalWaypointsPerLeg = 2,
      roadsUsed = false,
      automaticRecoveryEnabled = false,
      errorCount = #self.errors,
      warningCount = #self.warnings,
    })
    return self.routingReady
  end

  return state
end

return TM02W2FDirectOffroadNavigation
