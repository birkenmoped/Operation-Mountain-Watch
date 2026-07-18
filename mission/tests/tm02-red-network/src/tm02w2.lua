local TM02W2 = {}

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function formatFields(fields)
  local keys = sortedKeys(fields)
  local parts = {}
  for _, key in ipairs(keys) do
    local value = tostring(fields[key]):gsub("[\r\n]", " ")
    parts[#parts + 1] = tostring(key) .. "=" .. value
  end
  return table.concat(parts, " ")
end

local function shallowCopy(values)
  local result = {}
  for key, value in pairs(values or {}) do
    result[key] = value
  end
  return result
end

local function joinPath(path)
  return table.concat(path or {}, ">")
end

function TM02W2.start(config, registryState, build)
  local prefix = "[OMW][TM02W2]"

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
    errors = {},
    warnings = {},
    inventoryBySiteId = {},
    tasks = {},
    candidateEvaluationCount = 0,
    multiCandidateDecisionCount = 0,
    multiHopTaskCount = 0,
    crossAreaTaskCount = 0,
    nonNearestSelectionCount = 0,
    reservationInfluenceCount = 0,
    totalReservedOutbound = 0,
    totalReservedInbound = 0,
    unresolvedDeficit = 0,
    initialDeficit = 0,
    planGeneration = 0,
    menu = nil,
  }

  local function addError(code, detail)
    local message = tostring(code) .. ": " .. tostring(detail)
    state.errors[#state.errors + 1] = message
    log("ERROR", "red_planner_error", { code = code, detail = detail })
  end

  local function addWarning(code, detail)
    local message = tostring(code) .. ": " .. tostring(detail)
    state.warnings[#state.warnings + 1] = message
    log("WARNING", "red_planner_warning", { code = code, detail = detail })
  end

  if type(registryState) ~= "table" or registryState.configurationValid ~= true then
    addError("REGISTRY_INVALID", "TM02W1 registry state is missing or invalid")
  end

  local adjacency = {}

  local function buildAdjacency()
    for siteId in pairs(registryState.siteById or {}) do
      adjacency[siteId] = {}
    end

    for _, link in ipairs(registryState.movementLinks or {}) do
      if not adjacency[link.sourceSiteId] or not adjacency[link.targetSiteId] then
        addError("MOVEMENT_LINK_ENDPOINT_MISSING", tostring(link.linkId))
      else
        local function addEdge(sourceId, targetId)
          adjacency[sourceId][#adjacency[sourceId] + 1] = {
            targetSiteId = targetId,
            linkId = link.linkId,
            distanceMeters = link.distanceMeters,
            crossesCommandArea = link.crossesCommandArea == true,
          }
        end

        addEdge(link.sourceSiteId, link.targetSiteId)
        if link.direction == nil or link.direction == "BIDIRECTIONAL" then
          addEdge(link.targetSiteId, link.sourceSiteId)
        end
      end
    end

    for _, edges in pairs(adjacency) do
      table.sort(edges, function(first, second)
        if first.targetSiteId ~= second.targetSiteId then
          return first.targetSiteId < second.targetSiteId
        end
        return first.linkId < second.linkId
      end)
    end
  end

  local function edgeWeightedCost(edge)
    local planning = config.planning or {}
    local cost = (edge.distanceMeters or 0) * (planning.distanceWeight or 1)
    if edge.crossesCommandArea then
      cost = cost + (planning.crossAreaPenalty or 0)
    end
    return cost
  end

  local function shortestPath(sourceId, targetId)
    if sourceId == targetId then
      return {
        path = { sourceId },
        linkIds = {},
        distanceMeters = 0,
        weightedPathCost = 0,
        crossAreaEdges = 0,
      }
    end
    if not adjacency[sourceId] or not adjacency[targetId] then
      return nil
    end

    local distances = {}
    local physicalDistances = {}
    local crossAreaCounts = {}
    local previous = {}
    local previousLink = {}
    local open = {}

    for siteId in pairs(adjacency) do
      distances[siteId] = math.huge
      physicalDistances[siteId] = math.huge
      crossAreaCounts[siteId] = math.huge
      open[siteId] = true
    end
    distances[sourceId] = 0
    physicalDistances[sourceId] = 0
    crossAreaCounts[sourceId] = 0

    while true do
      local currentId = nil
      local currentCost = math.huge
      for siteId in pairs(open) do
        local candidateCost = distances[siteId]
        if candidateCost < currentCost or (candidateCost == currentCost and currentId and siteId < currentId) then
          currentId = siteId
          currentCost = candidateCost
        end
      end

      if not currentId or currentCost == math.huge then
        break
      end
      open[currentId] = nil
      if currentId == targetId then
        break
      end

      for _, edge in ipairs(adjacency[currentId] or {}) do
        if open[edge.targetSiteId] then
          local newCost = currentCost + edgeWeightedCost(edge)
          local newPhysical = physicalDistances[currentId] + (edge.distanceMeters or 0)
          local newCross = crossAreaCounts[currentId] + (edge.crossesCommandArea and 1 or 0)
          local oldCost = distances[edge.targetSiteId]
          local oldPhysical = physicalDistances[edge.targetSiteId]
          local better = newCost < oldCost
            or (newCost == oldCost and newPhysical < oldPhysical)
            or (newCost == oldCost and newPhysical == oldPhysical and newCross < crossAreaCounts[edge.targetSiteId])
          if better then
            distances[edge.targetSiteId] = newCost
            physicalDistances[edge.targetSiteId] = newPhysical
            crossAreaCounts[edge.targetSiteId] = newCross
            previous[edge.targetSiteId] = currentId
            previousLink[edge.targetSiteId] = edge.linkId
          end
        end
      end
    end

    if distances[targetId] == math.huge then
      return nil
    end

    local reversePath = { targetId }
    local reverseLinks = {}
    local cursor = targetId
    while cursor ~= sourceId do
      reverseLinks[#reverseLinks + 1] = previousLink[cursor]
      cursor = previous[cursor]
      if not cursor then
        return nil
      end
      reversePath[#reversePath + 1] = cursor
    end

    local path = {}
    for index = #reversePath, 1, -1 do
      path[#path + 1] = reversePath[index]
    end
    local linkIds = {}
    for index = #reverseLinks, 1, -1 do
      linkIds[#linkIds + 1] = reverseLinks[index]
    end

    return {
      path = path,
      linkIds = linkIds,
      distanceMeters = physicalDistances[targetId],
      weightedPathCost = distances[targetId],
      crossAreaEdges = crossAreaCounts[targetId],
    }
  end

  local function registerInventories()
    local seen = {}
    for _, definition in ipairs(config.personnel or {}) do
      local siteId = definition.siteId
      local node = registryState.nodeById and registryState.nodeById[siteId]
      if type(siteId) ~= "string" or siteId == "" then
        addError("PERSONNEL_SITE_ID_INVALID", tostring(siteId))
      elseif seen[siteId] then
        addError("PERSONNEL_SITE_DUPLICATE", siteId)
      elseif not node then
        addError("PERSONNEL_NODE_NOT_ACTIVE", siteId)
      else
        seen[siteId] = true
        local current = tonumber(definition.currentPersonnel)
        local guard = tonumber(definition.guardFloor)
        local target = tonumber(definition.defensiveTarget)
        local capacity = tonumber(definition.hardCapacity)
        if not current or not guard or not target or not capacity then
          addError("PERSONNEL_VALUE_INVALID", siteId)
        elseif guard < 0 or current < 0 or target < guard or capacity < target or current > capacity then
          addError(
            "PERSONNEL_BANDS_INVALID",
            siteId .. " current=" .. tostring(current)
              .. " guard=" .. tostring(guard)
              .. " target=" .. tostring(target)
              .. " capacity=" .. tostring(capacity)
          )
        else
          local inventory = {
            siteId = siteId,
            currentPersonnel = current,
            guardFloor = guard,
            defensiveTarget = target,
            hardCapacity = capacity,
            planningPriority = tonumber(definition.planningPriority) or 0,
            reservedInbound = 0,
            reservedOutbound = 0,
            initialAvailable = math.max(0, current - guard),
          }
          state.inventoryBySiteId[siteId] = inventory
          state.initialDeficit = state.initialDeficit + math.max(0, target - current)
        end
      end
    end

    for siteId in pairs(registryState.nodeById or {}) do
      if not state.inventoryBySiteId[siteId] then
        addError("PERSONNEL_NODE_MISSING", siteId)
      end
    end
  end

  local function availablePersonnel(inventory)
    return math.max(0, inventory.currentPersonnel - inventory.guardFloor - inventory.reservedOutbound)
  end

  local function remainingDeficit(inventory)
    local targetDeficit = inventory.defensiveTarget - inventory.currentPersonnel - inventory.reservedInbound
    local capacityDeficit = inventory.hardCapacity - inventory.currentPersonnel - inventory.reservedInbound
    return math.max(0, math.min(targetDeficit, capacityDeficit))
  end

  local function orderedTargets()
    local targets = {}
    for _, inventory in pairs(state.inventoryBySiteId) do
      if remainingDeficit(inventory) > 0 then
        targets[#targets + 1] = inventory
      end
    end
    table.sort(targets, function(first, second)
      if first.planningPriority ~= second.planningPriority then
        return first.planningPriority > second.planningPriority
      end
      local firstDeficit = remainingDeficit(first)
      local secondDeficit = remainingDeficit(second)
      if firstDeficit ~= secondDeficit then
        return firstDeficit > secondDeficit
      end
      return first.siteId < second.siteId
    end)
    return targets
  end

  local function evaluateCandidates(targetInventory)
    local planning = config.planning or {}
    local need = remainingDeficit(targetInventory)
    local desiredPacket = math.min(planning.maxPacketStrength or 6, need)
    local candidates = {}

    for _, sourceId in ipairs(sortedKeys(state.inventoryBySiteId)) do
      if sourceId ~= targetInventory.siteId then
        local source = state.inventoryBySiteId[sourceId]
        local available = availablePersonnel(source)
        if source.reservedOutbound > 0 then
          state.reservationInfluenceCount = state.reservationInfluenceCount + 1
        end
        if available > 0 then
          local route = shortestPath(sourceId, targetInventory.siteId)
          if route then
            local packetStrength = math.min(desiredPacket, available)
            local postDispatch = source.currentPersonnel - source.reservedOutbound - packetStrength
            local belowTarget = math.max(0, source.defensiveTarget - postDispatch)
            local depletionPenalty = belowTarget * (planning.depletionPenaltyPerPersonBelowTarget or 0)
            local fragmentationPenalty = math.max(0, desiredPacket - packetStrength)
              * (planning.fragmentationPenaltyPerMissingPerson or 0)
            local totalCost = route.weightedPathCost + depletionPenalty + fragmentationPenalty
            local candidate = {
              sourceSiteId = sourceId,
              targetSiteId = targetInventory.siteId,
              packetStrength = packetStrength,
              availableBeforeReservation = available,
              route = route,
              depletionPenalty = depletionPenalty,
              fragmentationPenalty = fragmentationPenalty,
              totalCost = totalCost,
            }
            candidates[#candidates + 1] = candidate
            state.candidateEvaluationCount = state.candidateEvaluationCount + 1
            log("INFO", "red_source_candidate_evaluated", {
              sourceSiteId = sourceId,
              targetSiteId = targetInventory.siteId,
              packetStrength = packetStrength,
              availablePersonnel = available,
              path = joinPath(route.path),
              hopCount = #route.path - 1,
              distanceMeters = math.floor(route.distanceMeters + 0.5),
              weightedPathCost = math.floor(route.weightedPathCost + 0.5),
              depletionPenalty = math.floor(depletionPenalty + 0.5),
              fragmentationPenalty = math.floor(fragmentationPenalty + 0.5),
              totalCost = math.floor(totalCost + 0.5),
              reservationAffected = source.reservedOutbound > 0,
            })
          end
        end
      end
    end

    table.sort(candidates, function(first, second)
      if first.totalCost ~= second.totalCost then
        return first.totalCost < second.totalCost
      end
      if first.packetStrength ~= second.packetStrength then
        return first.packetStrength > second.packetStrength
      end
      if first.route.distanceMeters ~= second.route.distanceMeters then
        return first.route.distanceMeters < second.route.distanceMeters
      end
      return first.sourceSiteId < second.sourceSiteId
    end)

    if #candidates > 1 then
      state.multiCandidateDecisionCount = state.multiCandidateDecisionCount + 1
    end

    return candidates
  end

  local function reserveTask(candidate)
    local source = state.inventoryBySiteId[candidate.sourceSiteId]
    local target = state.inventoryBySiteId[candidate.targetSiteId]
    source.reservedOutbound = source.reservedOutbound + candidate.packetStrength
    target.reservedInbound = target.reservedInbound + candidate.packetStrength

    local task = {
      taskId = string.format("W2-TASK-%02d", #state.tasks + 1),
      sourceSiteId = candidate.sourceSiteId,
      targetSiteId = candidate.targetSiteId,
      strength = candidate.packetStrength,
      path = shallowCopy(candidate.route.path),
      linkIds = shallowCopy(candidate.route.linkIds),
      hopCount = #candidate.route.path - 1,
      distanceMeters = candidate.route.distanceMeters,
      weightedPathCost = candidate.route.weightedPathCost,
      crossAreaEdges = candidate.route.crossAreaEdges,
      depletionPenalty = candidate.depletionPenalty,
      fragmentationPenalty = candidate.fragmentationPenalty,
      totalCost = candidate.totalCost,
      status = "RESERVED",
    }
    state.tasks[#state.tasks + 1] = task
    state.totalReservedOutbound = state.totalReservedOutbound + task.strength
    state.totalReservedInbound = state.totalReservedInbound + task.strength
    if task.hopCount > 1 then
      state.multiHopTaskCount = state.multiHopTaskCount + 1
    end
    if task.crossAreaEdges > 0 then
      state.crossAreaTaskCount = state.crossAreaTaskCount + 1
    end

    log("INFO", "red_reinforcement_task_reserved", {
      taskId = task.taskId,
      sourceSiteId = task.sourceSiteId,
      targetSiteId = task.targetSiteId,
      strength = task.strength,
      path = joinPath(task.path),
      hopCount = task.hopCount,
      crossAreaEdges = task.crossAreaEdges,
      distanceMeters = math.floor(task.distanceMeters + 0.5),
      totalCost = math.floor(task.totalCost + 0.5),
      sourceReservedOutbound = source.reservedOutbound,
      targetReservedInbound = target.reservedInbound,
    })
  end

  local function clearPlan()
    state.tasks = {}
    state.candidateEvaluationCount = 0
    state.multiCandidateDecisionCount = 0
    state.multiHopTaskCount = 0
    state.crossAreaTaskCount = 0
    state.nonNearestSelectionCount = 0
    state.reservationInfluenceCount = 0
    state.totalReservedOutbound = 0
    state.totalReservedInbound = 0
    state.unresolvedDeficit = 0
    for _, inventory in pairs(state.inventoryBySiteId) do
      inventory.reservedInbound = 0
      inventory.reservedOutbound = 0
    end
  end

  local function buildPlan()
    clearPlan()
    state.planGeneration = state.planGeneration + 1
    local planning = config.planning or {}

    for _, target in ipairs(orderedTargets()) do
      while remainingDeficit(target) > 0 do
        if #state.tasks >= (planning.maxTasks or 12) then
          addError("MAX_TASKS_EXCEEDED", tostring(planning.maxTasks))
          break
        end

        local candidates = evaluateCandidates(target)
        if #candidates == 0 then
          addError("NO_SOURCE_FOR_DEFICIT", target.siteId .. " remaining=" .. remainingDeficit(target))
          break
        end

        local nearest = candidates[1]
        for _, candidate in ipairs(candidates) do
          if candidate.route.distanceMeters < nearest.route.distanceMeters
            or (candidate.route.distanceMeters == nearest.route.distanceMeters and candidate.sourceSiteId < nearest.sourceSiteId) then
            nearest = candidate
          end
        end

        local selected = candidates[1]
        if selected.sourceSiteId ~= nearest.sourceSiteId then
          state.nonNearestSelectionCount = state.nonNearestSelectionCount + 1
          log("INFO", "red_non_nearest_source_selected", {
            targetSiteId = target.siteId,
            selectedSourceSiteId = selected.sourceSiteId,
            selectedDistanceMeters = math.floor(selected.route.distanceMeters + 0.5),
            selectedTotalCost = math.floor(selected.totalCost + 0.5),
            nearestSourceSiteId = nearest.sourceSiteId,
            nearestDistanceMeters = math.floor(nearest.route.distanceMeters + 0.5),
            nearestTotalCost = math.floor(nearest.totalCost + 0.5),
          })
        end

        reserveTask(selected)
      end
    end

    state.unresolvedDeficit = 0
    for _, inventory in pairs(state.inventoryBySiteId) do
      state.unresolvedDeficit = state.unresolvedDeficit + remainingDeficit(inventory)
    end
  end

  local function validatePlan()
    local planning = config.planning or {}

    for siteId, inventory in pairs(state.inventoryBySiteId) do
      local projected = inventory.currentPersonnel + inventory.reservedInbound - inventory.reservedOutbound
      if inventory.currentPersonnel - inventory.reservedOutbound < inventory.guardFloor then
        addError("SOURCE_BELOW_GUARD_FLOOR", siteId)
      end
      if inventory.currentPersonnel + inventory.reservedInbound > inventory.hardCapacity then
        addError("TARGET_ABOVE_HARD_CAPACITY", siteId)
      end
      if projected < 0 then
        addError("PROJECTED_PERSONNEL_NEGATIVE", siteId)
      end
    end

    for _, task in ipairs(state.tasks) do
      if task.strength < 1 or task.strength > (planning.maxPacketStrength or 6) then
        addError("TASK_STRENGTH_INVALID", task.taskId .. " strength=" .. tostring(task.strength))
      end
      if task.hopCount < 1 then
        addError("TASK_PATH_INVALID", task.taskId)
      end
    end

    if state.totalReservedInbound ~= state.totalReservedOutbound then
      addError(
        "RESERVATION_ACCOUNTING_MISMATCH",
        "inbound=" .. state.totalReservedInbound .. " outbound=" .. state.totalReservedOutbound
      )
    end
    if planning.requireAllDeficitsReserved == true and state.unresolvedDeficit ~= 0 then
      addError("UNRESOLVED_DEFICIT", tostring(state.unresolvedDeficit))
    end
    if planning.requireMultipleCandidateEvaluations == true
      and state.candidateEvaluationCount <= #state.tasks then
      addError(
        "MULTIPLE_CANDIDATES_NOT_PROVEN",
        "evaluations=" .. state.candidateEvaluationCount .. " tasks=" .. #state.tasks
      )
    end
    if planning.requireMultiHopTask == true and state.multiHopTaskCount < 1 then
      addError("MULTI_HOP_TASK_NOT_PROVEN", "count=0")
    end
    if planning.requireReservationInfluence == true and state.reservationInfluenceCount < 1 then
      addError("RESERVATION_INFLUENCE_NOT_PROVEN", "count=0")
    end
    if planning.requireNonNearestSelection == true and state.nonNearestSelectionCount < 1 then
      addError("NON_NEAREST_SELECTION_NOT_PROVEN", "count=0")
    end
  end

  local function logInventories()
    for _, siteId in ipairs(sortedKeys(state.inventoryBySiteId)) do
      local inventory = state.inventoryBySiteId[siteId]
      log("INFO", "red_personnel_inventory", {
        siteId = siteId,
        currentPersonnel = inventory.currentPersonnel,
        guardFloor = inventory.guardFloor,
        defensiveTarget = inventory.defensiveTarget,
        hardCapacity = inventory.hardCapacity,
        reservedInbound = inventory.reservedInbound,
        reservedOutbound = inventory.reservedOutbound,
        projectedPersonnel = inventory.currentPersonnel + inventory.reservedInbound - inventory.reservedOutbound,
      })
    end
  end

  local function showSummary()
    local text = string.format(
      "TM02W2 %s | tasks=%d reserved=%d initialDeficit=%d unresolved=%d candidates=%d multiHop=%d nonNearest=%d errors=%d",
      state.configurationValid and "PASS" or "FAIL",
      #state.tasks,
      state.totalReservedInbound,
      state.initialDeficit,
      state.unresolvedDeficit,
      state.candidateEvaluationCount,
      state.multiHopTaskCount,
      state.nonNearestSelectionCount,
      #state.errors
    )
    announce(text)
    log("INFO", "red_source_cost_plan_summary", {
      buildTimestamp = build and build.buildTimestamp or "unknown",
      configurationVersion = config.configurationVersion,
      configurationValid = state.configurationValid,
      missionFileName = config.mission.fileName,
      planGeneration = state.planGeneration,
      inventoryCount = #sortedKeys(state.inventoryBySiteId),
      initialDeficit = state.initialDeficit,
      plannedTaskCount = #state.tasks,
      candidateEvaluationCount = state.candidateEvaluationCount,
      multiCandidateDecisionCount = state.multiCandidateDecisionCount,
      multiHopTaskCount = state.multiHopTaskCount,
      crossAreaTaskCount = state.crossAreaTaskCount,
      nonNearestSelectionCount = state.nonNearestSelectionCount,
      reservationInfluenceCount = state.reservationInfluenceCount,
      totalReservedOutbound = state.totalReservedOutbound,
      totalReservedInbound = state.totalReservedInbound,
      unresolvedDeficit = state.unresolvedDeficit,
      errorCount = #state.errors,
      warningCount = #state.warnings,
      movementExecuted = false,
    })
  end

  local function showInventories()
    for _, siteId in ipairs(sortedKeys(state.inventoryBySiteId)) do
      local inventory = state.inventoryBySiteId[siteId]
      announce(
        siteId
          .. " | current=" .. inventory.currentPersonnel
          .. " guard=" .. inventory.guardFloor
          .. " target=" .. inventory.defensiveTarget
          .. " in=" .. inventory.reservedInbound
          .. " out=" .. inventory.reservedOutbound
          .. " projected=" .. (inventory.currentPersonnel + inventory.reservedInbound - inventory.reservedOutbound)
      )
    end
  end

  local function showTasks()
    for _, task in ipairs(state.tasks) do
      announce(
        task.taskId
          .. " | " .. task.sourceSiteId .. " -> " .. task.targetSiteId
          .. " | strength=" .. task.strength
          .. " | hops=" .. task.hopCount
          .. " | path=" .. joinPath(task.path)
          .. " | cost=" .. math.floor(task.totalCost + 0.5)
      )
    end
  end

  local function installMenu()
    if not config.debug or config.debug.enableF10Menu ~= true or not missionCommands then
      return
    end
    local root = missionCommands.addSubMenu("OMW Tests")
    state.menu = missionCommands.addSubMenu("TM02W2 RED Source Cost", root)
    missionCommands.addCommand("Show plan summary", state.menu, showSummary)
    missionCommands.addCommand("List inventories", state.menu, showInventories)
    missionCommands.addCommand("List reserved tasks", state.menu, showTasks)
    missionCommands.addCommand("Reset and replan", state.menu, function()
      local previousErrorCount = #state.errors
      state.errors = {}
      buildPlan()
      validatePlan()
      state.configurationValid = #state.errors == 0
      logInventories()
      showSummary()
      log("INFO", "red_source_cost_replan", {
        previousErrorCount = previousErrorCount,
        newErrorCount = #state.errors,
        planGeneration = state.planGeneration,
      })
    end)
  end

  local ok, reason = pcall(function()
    buildAdjacency()
    registerInventories()
    buildPlan()
    validatePlan()
  end)

  if not ok then
    addError("UNCAUGHT_PLANNER_ERROR", reason)
  end

  state.configurationValid = #state.errors == 0
  logInventories()
  installMenu()
  showSummary()

  return state
end

return TM02W2
