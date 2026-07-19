local TM02W2FDirectOffroadNavigation = {}

local function directedKey(sourceSiteId, targetSiteId)
  return tostring(sourceSiteId) .. "\0" .. tostring(targetSiteId)
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

  if type(registryState) ~= "table" or registryState.configurationValid ~= true then
    addError("REGISTRY_INVALID", "TM02W1 registry unavailable or invalid")
  end
  if type(plannerState) ~= "table" or plannerState.configurationValid ~= true then
    addError("PLANNER_INVALID", "TM02W2F planner unavailable or invalid")
  end
  if type(ASTAR) ~= "table" or type(ASTAR.New) ~= "function" then
    addError("MOOSE_ASTAR_MISSING", "ASTAR.New unavailable")
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

  function state:preparePlannerTasks()
    self.safeTaskCount = 0
    for _, task in ipairs(plannerState.tasks or {}) do
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
        addError("TASK_ENDPOINT_MISSING", task.taskId)
      else
        astar:FindStartNode(startNode)
        astar:FindEndNode(endNode)
        astar:SetValidNeighbourFunction(function(firstNode, secondNode)
          local plan = self:getLegPlan(firstNode.siteId, secondNode.siteId)
          return plan ~= nil and plan.safe == true
        end)
        astar:SetCostFunction(function(firstNode, secondNode)
          local plan = self:getLegPlan(firstNode.siteId, secondNode.siteId)
          return plan and plan.safe == true and plan.lengthMeters or ASTAR.INF
        end)

        local ok, result = pcall(function() return astar:GetPath(false, false) end)
        if not ok or type(result) ~= "table" or #result < 2 then
          addError("SAFE_DIRECT_LOGICAL_PATH_MISSING", task.taskId)
        else
          local path, linkIds = {}, {}
          local complete = true
          for _, node in ipairs(result) do path[#path + 1] = node.siteId end
          for index = 1, #path - 1 do
            local plan = self:getLegPlan(path[index], path[index + 1])
            if not plan or plan.safe ~= true then
              complete = false
              addError("SAFE_DIRECT_LEG_MISSING", task.taskId .. " leg=" .. path[index] .. ">" .. path[index + 1])
              break
            end
            linkIds[#linkIds + 1] = plan.linkId
          end
          if complete then
            task.path = path
            task.linkIds = linkIds
            self.safeTaskCount = self.safeTaskCount + 1
            log("INFO", "direct_offroad_task_path_selected", {
              taskId = task.taskId,
              sourceSiteId = task.sourceSiteId,
              targetSiteId = task.targetSiteId,
              path = table.concat(path, ">"),
              legCount = #path - 1,
              physicalWaypointsPerLeg = 2,
              method = "MOOSE_ASTAR_RED_NETWORK",
            })
          end
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
