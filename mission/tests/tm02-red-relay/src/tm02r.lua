local TM02R = {}

local TERMINAL_PACKET_STATES = {
  ARRIVED = true,
  DESTROYED = true,
  FAILED = true,
}

local function copyTable(source)
  local result = {}
  for key, value in pairs(source or {}) do
    result[key] = type(value) == "table" and copyTable(value) or value
  end
  return result
end

local function join(values, separator)
  local parts = {}
  for index, value in ipairs(values or {}) do
    parts[index] = tostring(value)
  end
  return table.concat(parts, separator or ",")
end

local function formatFields(fields)
  local keys = {}
  local parts = {}
  for key in pairs(fields or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  for _, key in ipairs(keys) do
    local value = tostring(fields[key]):gsub("[\r\n]", " ")
    parts[#parts + 1] = tostring(key) .. "=" .. value
  end
  return table.concat(parts, " ")
end

function TM02R.start(config, build)
  local prefix = "[OMW][TM02R]"

  local function log(level, event, fields)
    local suffix = formatFields(fields)
    local line = prefix .. " level=" .. level .. " event=" .. event
    if suffix ~= "" then
      line = line .. " " .. suffix
    end
    env.info(line)
  end

  local function announce(text)
    if config.debug.showMessages == true then
      trigger.action.outText(text, 14)
    end
  end

  local state = {
    lossesApplied = false,
    replenishmentStarted = false,
    completed = false,
    failed = false,
    monitorActive = false,
    monitorGeneration = 0,
    activePacketCount = 0,
    currentDispatchDepth = 1,
    maximumDispatchDepth = 0,
    totalLosses = 0,
    initialPersonnel = 0,
    nextPacketSequence = 1,
    nodeById = {},
    packets = {},
  }

  local function fail(reason, event)
    if state.failed then
      return
    end
    state.failed = true
    state.monitorActive = false
    state.monitorGeneration = state.monitorGeneration + 1
    log("ERROR", event or "red_replenishment_failed", {
      missionTimeSeconds = timer.getTime(),
      reason = tostring(reason),
    })
    announce("TM02R failed: " .. tostring(reason))
  end

  local function buildNodeRegistry()
    local hq = {
      nodeId = config.headquarters.nodeId,
      label = "HQ",
      zoneName = config.headquarters.zoneName,
      targetStrength = nil,
      currentGarrison = config.headquarters.initialPersonnel,
      initialGarrison = config.headquarters.initialPersonnel,
      parentNodeId = nil,
      childNodeIds = {},
      depth = 0,
    }
    state.nodeById[hq.nodeId] = hq
    state.initialPersonnel = hq.currentGarrison

    for _, definition in ipairs(config.shelters) do
      if state.nodeById[definition.nodeId] then
        error("duplicate nodeId: " .. definition.nodeId)
      end
      state.nodeById[definition.nodeId] = {
        nodeId = definition.nodeId,
        label = definition.label,
        zoneName = definition.zoneName,
        targetStrength = definition.targetStrength,
        currentGarrison = definition.initialGarrison,
        initialGarrison = definition.initialGarrison,
        parentNodeId = definition.parentNodeId,
        childNodeIds = {},
        depth = nil,
      }
      state.initialPersonnel = state.initialPersonnel + definition.initialGarrison
    end

    local unresolved = #config.shelters
    local passes = 0
    while unresolved > 0 and passes <= #config.shelters do
      passes = passes + 1
      local progress = false
      for _, definition in ipairs(config.shelters) do
        local node = state.nodeById[definition.nodeId]
        if node.depth == nil then
          local parent = state.nodeById[definition.parentNodeId]
          if parent and parent.depth ~= nil then
            node.depth = parent.depth + 1
            parent.childNodeIds[#parent.childNodeIds + 1] = node.nodeId
            unresolved = unresolved - 1
            progress = true
            if node.depth > state.maximumDispatchDepth then
              state.maximumDispatchDepth = node.depth
            end
          end
        end
      end
      if not progress then
        break
      end
    end
    if unresolved > 0 then
      error("node tree contains a missing parent or cycle")
    end
  end

  local function validateConfiguration()
    local errors = {}
    if config.replenishment.originPolicy ~= "HQ_TO_FINAL" then
      errors[#errors + 1] = "TM02R first acceptance requires originPolicy=HQ_TO_FINAL"
    end
    if config.replenishment.fillOrder ~= "TOP_DOWN" then
      errors[#errors + 1] = "TM02R requires fillOrder=TOP_DOWN"
    end
    if config.replenishment.maxActivePackets ~= 2 then
      errors[#errors + 1] = "TM02R requires exactly two active packet slots"
    end
    if #config.shelters ~= 6 then
      errors[#errors + 1] = "TM02R requires exactly six shelters"
    end
    if state.initialPersonnel ~= 100 then
      errors[#errors + 1] = "TM02R initial personnel must equal 100"
    end

    for strength = 1, 10 do
      local templateName = config.templatesByStrength[strength]
      if type(templateName) ~= "string" or templateName == "" then
        errors[#errors + 1] = "missing template name for strength " .. strength
      end
    end

    local totalSimulatedLosses = 0
    local previousDepth = 0
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      if definition.targetStrength ~= 10 then
        errors[#errors + 1] = definition.nodeId .. " targetStrength must equal 10"
      end
      if definition.initialGarrison ~= definition.targetStrength then
        errors[#errors + 1] = definition.nodeId .. " must start at target strength"
      end
      if node.depth < previousDepth then
        errors[#errors + 1] = "shelters must be configured in top-down order"
      end
      previousDepth = node.depth
      local loss = config.simulatedLosses[definition.nodeId]
      if type(loss) ~= "number" or loss % 1 ~= 0 or loss < 0 or loss > definition.initialGarrison then
        errors[#errors + 1] = definition.nodeId .. " simulated loss must be an integer from 0 to 10"
      else
        totalSimulatedLosses = totalSimulatedLosses + loss
      end
    end
    if totalSimulatedLosses < 1 then
      errors[#errors + 1] = "simulated loss profile must contain at least one loss"
    end
    if totalSimulatedLosses > config.headquarters.initialPersonnel then
      errors[#errors + 1] = "HQ stock cannot replace the configured loss profile"
    end
    return #errors == 0, errors, totalSimulatedLosses
  end

  local function validateMissionObjects()
    local missing = {}
    for strength = 1, 10 do
      local templateName = config.templatesByStrength[strength]
      if type(templateName) == "string" and not GROUP:FindByName(templateName) then
        missing[#missing + 1] = templateName
      end
    end
    for _, node in pairs(state.nodeById) do
      if not ZONE:FindByName(node.zoneName) then
        missing[#missing + 1] = node.zoneName
      end
    end
    return #missing == 0, missing
  end

  local inventoryOrder = {
    config.headquarters.nodeId,
    "RED_SHELTER_A",
    "RED_SHELTER_B",
    "RED_SHELTER_AA",
    "RED_SHELTER_AB",
    "RED_SHELTER_BA",
    "RED_SHELTER_BB",
  }

  local function countInboundForNode(nodeId)
    local inbound = 0
    for _, packet in ipairs(state.packets) do
      if packet.finalDestinationNodeId == nodeId
        and (packet.state == "QUEUED" or packet.state == "SPAWNING" or packet.state == "MOVING") then
        inbound = inbound + packet.survivorCount
      end
    end
    return inbound
  end

  local function inventorySnapshot()
    local hq = state.nodeById[config.headquarters.nodeId]
    local shelterPersonnel = 0
    local inTransitPersonnel = 0
    local queuedPacketCount = 0
    local arrivedPacketCount = 0
    local destroyedPacketCount = 0
    local failedPacketCount = 0
    local totalDeficit = 0

    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      shelterPersonnel = shelterPersonnel + node.currentGarrison
      totalDeficit = totalDeficit + math.max(0, node.targetStrength - node.currentGarrison)
    end
    for _, packet in ipairs(state.packets) do
      if packet.state == "QUEUED" then
        queuedPacketCount = queuedPacketCount + 1
      elseif packet.state == "SPAWNING" or packet.state == "MOVING" then
        inTransitPersonnel = inTransitPersonnel + packet.survivorCount
      elseif packet.state == "ARRIVED" then
        arrivedPacketCount = arrivedPacketCount + 1
      elseif packet.state == "DESTROYED" then
        destroyedPacketCount = destroyedPacketCount + 1
      elseif packet.state == "FAILED" then
        failedPacketCount = failedPacketCount + 1
      end
    end

    local accountedPersonnel = hq.currentGarrison + shelterPersonnel + inTransitPersonnel + state.totalLosses
    local allSheltersAtTarget = totalDeficit == 0
    return {
      hqPersonnel = hq.currentGarrison,
      shelterPersonnel = shelterPersonnel,
      inTransitPersonnel = inTransitPersonnel,
      totalLosses = state.totalLosses,
      totalDeficit = totalDeficit,
      accountedPersonnel = accountedPersonnel,
      initialPersonnel = state.initialPersonnel,
      accountingValid = accountedPersonnel == state.initialPersonnel,
      queuedPacketCount = queuedPacketCount,
      activePacketCount = state.activePacketCount,
      arrivedPacketCount = arrivedPacketCount,
      destroyedPacketCount = destroyedPacketCount,
      failedPacketCount = failedPacketCount,
      allSheltersAtTarget = allSheltersAtTarget,
      currentDispatchDepth = state.currentDispatchDepth,
      networkComplete = state.completed,
      lossesApplied = state.lossesApplied,
      replenishmentStarted = state.replenishmentStarted,
    }
  end

  local function logInventory(reason)
    for _, nodeId in ipairs(inventoryOrder) do
      local node = state.nodeById[nodeId]
      local inbound = node.targetStrength and countInboundForNode(nodeId) or 0
      log("INFO", "red_node_inventory", {
        nodeId = node.nodeId,
        label = node.label,
        currentGarrison = node.currentGarrison,
        targetStrength = node.targetStrength or "POOL",
        deficit = node.targetStrength and math.max(0, node.targetStrength - node.currentGarrison) or 0,
        inboundPersonnel = inbound,
        atTargetStrength = node.targetStrength == nil or node.currentGarrison == node.targetStrength,
        depth = node.depth,
      })
    end
    local snapshot = inventorySnapshot()
    snapshot.reason = reason or "manual"
    log("INFO", "red_replenishment_inventory", snapshot)
    return snapshot
  end

  local function showInventory()
    local snapshot = logInventory("manual")
    local lines = { "RED REPLENISHMENT INVENTORY" }
    for _, nodeId in ipairs(inventoryOrder) do
      local node = state.nodeById[nodeId]
      if node.targetStrength then
        lines[#lines + 1] = node.label .. ": " .. node.currentGarrison .. " / " .. node.targetStrength
          .. " (inbound " .. countInboundForNode(nodeId) .. ")"
      else
        lines[#lines + 1] = node.label .. ": " .. node.currentGarrison
      end
    end
    lines[#lines + 1] = "Dispatch level: " .. snapshot.currentDispatchDepth
    lines[#lines + 1] = "In transit: " .. snapshot.inTransitPersonnel
    lines[#lines + 1] = "Recorded losses: " .. snapshot.totalLosses
    lines[#lines + 1] = "Remaining deficit: " .. snapshot.totalDeficit
    lines[#lines + 1] = "Accounted: " .. snapshot.accountedPersonnel .. " / " .. snapshot.initialPersonnel
    lines[#lines + 1] = "Accounting valid: " .. tostring(snapshot.accountingValid)
    lines[#lines + 1] = "All shelters at target: " .. tostring(snapshot.allSheltersAtTarget)
    announce(table.concat(lines, "\n"))
  end

  local function showPackets()
    local lines = { "TM02R REPLENISHMENT PACKETS" }
    if #state.packets == 0 then
      lines[#lines + 1] = "none"
    end
    for _, packet in ipairs(state.packets) do
      lines[#lines + 1] = packet.packetId
        .. " | " .. packet.state
        .. " | " .. packet.survivorCount .. "/" .. packet.strength
        .. " | depth " .. packet.targetDepth
        .. " | " .. join(packet.routeNodeIds, ">")
      log("INFO", "red_replenishment_packet_status", {
        packetId = packet.packetId,
        packetState = packet.state,
        strength = packet.strength,
        survivorCount = packet.survivorCount,
        targetDepth = packet.targetDepth,
        finalDestinationNodeId = packet.finalDestinationNodeId,
        routeNodeIds = join(packet.routeNodeIds, ">"),
        runtimeGroupName = packet.runtimeGroupName or "none",
      })
    end
    announce(table.concat(lines, "\n"))
  end

  local function buildRouteToNode(nodeId)
    local reversed = {}
    local current = state.nodeById[nodeId]
    while current do
      reversed[#reversed + 1] = current.nodeId
      if current.parentNodeId == nil then
        break
      end
      current = state.nodeById[current.parentNodeId]
    end
    if reversed[#reversed] ~= config.headquarters.nodeId then
      error("node is not connected to HQ: " .. nodeId)
    end
    local route = {}
    for index = #reversed, 1, -1 do
      route[#route + 1] = reversed[index]
    end
    return route
  end

  local function nextPacketId()
    local sequence = state.nextPacketSequence
    state.nextPacketSequence = sequence + 1
    return string.format("TEST.TM02.REPL.PACKET.%03d", sequence), string.format("%03d", sequence)
  end

  local function queuePacket(finalNode, strength)
    if strength < 1 or strength > 10 then
      error("replacement strength outside 1..10 for " .. finalNode.nodeId)
    end
    local packetId, suffix = nextPacketId()
    local packet = {
      packetId = packetId,
      runtimeAliasSuffix = suffix,
      routeNodeIds = buildRouteToNode(finalNode.nodeId),
      finalDestinationNodeId = finalNode.nodeId,
      targetDepth = finalNode.depth,
      state = "QUEUED",
      strength = strength,
      survivorCount = strength,
      runtimeGroup = nil,
      runtimeGroupName = nil,
    }
    state.packets[#state.packets + 1] = packet
    log("INFO", "red_replenishment_packet_queued", {
      packetId = packet.packetId,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      targetDepth = packet.targetDepth,
      strength = packet.strength,
      templateName = config.templatesByStrength[packet.strength],
      routeNodeIds = join(packet.routeNodeIds, ">"),
    })
    return packet
  end

  local function ensureDeficitPacketsForCurrentDepth()
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      if node.depth == state.currentDispatchDepth then
        local inbound = countInboundForNode(node.nodeId)
        local deficit = node.targetStrength - node.currentGarrison - inbound
        if deficit > 0 then
          queuePacket(node, deficit)
        end
      end
    end
  end

  local function buildPhysicalRoute(packet)
    if not packet.runtimeGroup then
      error("runtime group unavailable for " .. packet.packetId)
    end
    local startCoordinate = packet.runtimeGroup:GetCoordinate()
    if not startCoordinate then
      error("runtime coordinate unavailable for " .. packet.packetId)
    end
    local waypoints = {
      startCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
    }
    for index = 2, #packet.routeNodeIds do
      local node = state.nodeById[packet.routeNodeIds[index]]
      local zone = ZONE:FindByName(node.zoneName)
      if not zone then
        error("route zone unavailable: " .. node.zoneName)
      end
      local coordinate = zone:GetCoordinate()
      if not coordinate then
        error("route coordinate unavailable: " .. node.zoneName)
      end
      waypoints[#waypoints + 1] = coordinate:WaypointGround(config.routing.speedKph, config.routing.formation)
    end
    return waypoints
  end

  local function dispatchPacket(packet)
    local hq = state.nodeById[config.headquarters.nodeId]
    if hq.currentGarrison < packet.strength then
      error("HQ lacks personnel for " .. packet.packetId)
    end
    local sourceZone = ZONE:FindByName(config.headquarters.zoneName)
    if not sourceZone then
      error("HQ source zone unavailable")
    end

    hq.currentGarrison = hq.currentGarrison - packet.strength
    packet.state = "SPAWNING"
    local templateName = config.templatesByStrength[packet.strength]
    local alias = config.runtimeAliasPrefix .. packet.runtimeAliasSuffix
    local group = SPAWN:NewWithAlias(templateName, alias):SpawnInZone(sourceZone, false)
    if not group then
      error("spawn returned nil for " .. packet.packetId)
    end
    packet.runtimeGroup = group
    packet.runtimeGroupName = group:GetName()
    packet.survivorCount = group:CountAliveUnits()
    if packet.survivorCount ~= packet.strength then
      error(packet.packetId .. " spawned with " .. packet.survivorCount .. " instead of " .. packet.strength)
    end

    local waypoints = buildPhysicalRoute(packet)
    local assigned = group:Route(waypoints, config.routing.assignmentDelaySeconds)
    if not assigned then
      error("route assignment returned nil for " .. packet.packetId)
    end
    packet.state = "MOVING"
    state.activePacketCount = state.activePacketCount + 1
    log("INFO", "red_replenishment_packet_dispatched", {
      packetId = packet.packetId,
      strength = packet.strength,
      survivorCount = packet.survivorCount,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      targetDepth = packet.targetDepth,
      routeNodeIds = join(packet.routeNodeIds, ">"),
      runtimeGroupName = packet.runtimeGroupName,
      waypointCount = #waypoints,
      hqPersonnel = hq.currentGarrison,
      activePacketCount = state.activePacketCount,
    })
  end

  local function dispatchAvailablePackets()
    while not state.failed and state.activePacketCount < config.replenishment.maxActivePackets do
      local queued = nil
      for _, packet in ipairs(state.packets) do
        if packet.state == "QUEUED" and packet.targetDepth == state.currentDispatchDepth then
          queued = packet
          break
        end
      end
      if not queued then
        return
      end
      local ok, dispatchError = pcall(dispatchPacket, queued)
      if not ok then
        queued.state = "FAILED"
        fail(dispatchError, "red_replenishment_packet_dispatch_failed")
        return
      end
    end
  end

  local function finalizePacket(packet)
    local destinationNode = state.nodeById[packet.finalDestinationNodeId]
    if destinationNode.currentGarrison + packet.survivorCount > destinationNode.targetStrength then
      error("arrival would overfill " .. destinationNode.nodeId)
    end
    destinationNode.currentGarrison = destinationNode.currentGarrison + packet.survivorCount
    packet.state = "ARRIVED"
    state.activePacketCount = state.activePacketCount - 1
    log("INFO", "red_replenishment_packet_arrived", {
      packetId = packet.packetId,
      strength = packet.strength,
      survivorCount = packet.survivorCount,
      destinationNodeId = destinationNode.nodeId,
      destinationGarrison = destinationNode.currentGarrison,
      targetStrength = destinationNode.targetStrength,
      targetDepth = packet.targetDepth,
      activePacketCount = state.activePacketCount,
    })
  end

  local function reconcilePacket(packet)
    if packet.state ~= "MOVING" then
      return
    end
    if not packet.runtimeGroup then
      error("active packet lacks runtime group: " .. packet.packetId)
    end
    local observedSurvivors = packet.runtimeGroup:CountAliveUnits()
    if observedSurvivors > packet.survivorCount then
      error("survivor count increased for " .. packet.packetId)
    end
    if observedSurvivors < packet.survivorCount then
      local losses = packet.survivorCount - observedSurvivors
      packet.survivorCount = observedSurvivors
      state.totalLosses = state.totalLosses + losses
      log("INFO", "red_replenishment_transit_losses_recorded", {
        packetId = packet.packetId,
        losses = losses,
        survivorCount = packet.survivorCount,
        totalLosses = state.totalLosses,
      })
    end
    if packet.survivorCount < 1 then
      packet.state = "DESTROYED"
      state.activePacketCount = state.activePacketCount - 1
      log("INFO", "red_replenishment_packet_destroyed", {
        packetId = packet.packetId,
        finalDestinationNodeId = packet.finalDestinationNodeId,
        activePacketCount = state.activePacketCount,
      })
      return
    end

    local destinationNode = state.nodeById[packet.finalDestinationNodeId]
    local destinationZone = ZONE:FindByName(destinationNode.zoneName)
    if packet.runtimeGroup:IsCompletelyInZone(destinationZone) == true then
      finalizePacket(packet)
    end
  end

  local function depthAtTarget(depth)
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      if node.depth == depth and node.currentGarrison ~= node.targetStrength then
        return false
      end
    end
    return true
  end

  local function depthHasPendingPackets(depth)
    for _, packet in ipairs(state.packets) do
      if packet.targetDepth == depth
        and (packet.state == "QUEUED" or packet.state == "SPAWNING" or packet.state == "MOVING") then
        return true
      end
    end
    return false
  end

  local function advanceDispatchDepthIfReady()
    while state.currentDispatchDepth < state.maximumDispatchDepth
      and depthAtTarget(state.currentDispatchDepth)
      and not depthHasPendingPackets(state.currentDispatchDepth) do
      local previousDepth = state.currentDispatchDepth
      state.currentDispatchDepth = state.currentDispatchDepth + 1
      log("INFO", "red_replenishment_level_advanced", {
        previousDepth = previousDepth,
        currentDispatchDepth = state.currentDispatchDepth,
      })
      ensureDeficitPacketsForCurrentDepth()
    end
  end

  local function monitorTick()
    for _, packet in ipairs(state.packets) do
      if packet.state == "MOVING" then
        reconcilePacket(packet)
      end
    end

    ensureDeficitPacketsForCurrentDepth()
    advanceDispatchDepthIfReady()
    dispatchAvailablePackets()

    local snapshot = inventorySnapshot()
    if snapshot.accountingValid ~= true then
      fail("personnel accounting mismatch", "red_replenishment_accounting_failed")
      return false
    end

    if snapshot.allSheltersAtTarget
      and snapshot.activePacketCount == 0
      and snapshot.queuedPacketCount == 0 then
      state.completed = true
      state.monitorActive = false
      snapshot.networkComplete = true
      log("INFO", "red_replenishment_completed", snapshot)
      announce(
        "TM02R complete"
          .. "\nAll shelters: 10 / 10"
          .. "\nHQ remaining: " .. snapshot.hqPersonnel
          .. "\nRecorded losses: " .. snapshot.totalLosses
          .. "\nAccounting valid: " .. tostring(snapshot.accountingValid)
      )
      return false
    end
    return true
  end

  local function startMonitor()
    state.monitorGeneration = state.monitorGeneration + 1
    local generation = state.monitorGeneration
    state.monitorActive = true
    log("INFO", "red_replenishment_monitor_started", {
      initialDelaySeconds = config.replenishment.monitorInitialDelaySeconds,
      intervalSeconds = config.replenishment.monitorIntervalSeconds,
    })
    timer.scheduleFunction(function(_, scheduledTime)
      if not state.monitorActive or generation ~= state.monitorGeneration then
        return nil
      end
      local ok, continueOrError = pcall(monitorTick)
      if not ok then
        fail(continueOrError, "red_replenishment_monitor_failed")
        return nil
      end
      if continueOrError ~= true then
        return nil
      end
      return scheduledTime + config.replenishment.monitorIntervalSeconds
    end, nil, timer.getTime() + config.replenishment.monitorInitialDelaySeconds)
  end

  local function applySimulatedLosses()
    if state.lossesApplied then
      announce("TM02R loss profile rejected: losses already applied")
      log("INFO", "red_loss_profile_rejected", { reason = "already applied" })
      return
    end
    if state.replenishmentStarted then
      announce("TM02R loss profile rejected: replenishment already started")
      log("INFO", "red_loss_profile_rejected", { reason = "replenishment already started" })
      return
    end

    local profileLosses = 0
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      local losses = config.simulatedLosses[node.nodeId] or 0
      if losses > node.currentGarrison then
        fail("loss profile exceeds garrison at " .. node.nodeId, "red_loss_profile_failed")
        return
      end
      node.currentGarrison = node.currentGarrison - losses
      state.totalLosses = state.totalLosses + losses
      profileLosses = profileLosses + losses
      log("INFO", "red_shelter_losses_applied", {
        nodeId = node.nodeId,
        label = node.label,
        losses = losses,
        currentGarrison = node.currentGarrison,
        targetStrength = node.targetStrength,
        deficit = node.targetStrength - node.currentGarrison,
        depth = node.depth,
      })
    end
    state.lossesApplied = true
    state.currentDispatchDepth = 1
    log("INFO", "red_loss_profile_applied", {
      profileLosses = profileLosses,
      totalLosses = state.totalLosses,
      originPolicy = config.replenishment.originPolicy,
      fillOrder = config.replenishment.fillOrder,
    })
    showInventory()
  end

  local function startReplenishment()
    if state.replenishmentStarted then
      announce("TM02R start rejected: replenishment already started")
      log("INFO", "red_replenishment_start_rejected", { reason = "already started" })
      return
    end
    if not state.lossesApplied then
      announce("TM02R start rejected: apply simulated losses first")
      log("INFO", "red_replenishment_start_rejected", { reason = "losses not applied" })
      return
    end
    if state.failed then
      announce("TM02R start rejected: bootstrap failed")
      return
    end

    state.replenishmentStarted = true
    state.currentDispatchDepth = 1
    log("INFO", "red_replenishment_start_requested", {
      initialPersonnel = state.initialPersonnel,
      hqPersonnel = state.nodeById[config.headquarters.nodeId].currentGarrison,
      totalLosses = state.totalLosses,
      originPolicy = config.replenishment.originPolicy,
      fillOrder = config.replenishment.fillOrder,
      maxActivePackets = config.replenishment.maxActivePackets,
    })
    ensureDeficitPacketsForCurrentDepth()
    dispatchAvailablePackets()
    if not state.failed then
      startMonitor()
      showInventory()
    end
  end

  local function validateAndReport()
    local configValid, configErrors, profileLosses = validateConfiguration()
    local objectsValid, missingObjects = validateMissionObjects()
    log("INFO", "red_replenishment_validation", {
      configurationValid = configValid,
      missionObjectsValid = objectsValid,
      configurationErrors = #configErrors == 0 and "none" or join(configErrors, " | "),
      missingObjects = #missingObjects == 0 and "none" or join(missingObjects, ","),
      checkedNodeCount = 1 + #config.shelters,
      checkedTemplateCount = 10,
      profileLosses = profileLosses or "invalid",
      originPolicy = config.replenishment.originPolicy,
      fillOrder = config.replenishment.fillOrder,
    })
    announce(
      "TM02R validation"
        .. "\nConfiguration: " .. tostring(configValid)
        .. "\nMission objects: " .. tostring(objectsValid)
        .. "\nTemplates: strengths 1..10"
        .. "\nLoss profile: " .. tostring(profileLosses or "invalid")
        .. "\nMissing: " .. (#missingObjects == 0 and "none" or join(missingObjects, ", "))
    )
    return configValid and objectsValid
  end

  local registryOk, registryError = pcall(buildNodeRegistry)
  if not registryOk then
    fail(registryError, "red_replenishment_registry_failed")
    return state
  end

  local ready = validateAndReport()
  if not ready then
    fail("configuration or Mission Editor validation failed", "red_replenishment_bootstrap_failed")
    return state
  end

  if config.debug.enableF10Menu == true then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM02R Loss Replenishment", root)
    MENU_MISSION_COMMAND:New("Validate network", menu, validateAndReport)
    MENU_MISSION_COMMAND:New("Apply simulated losses", menu, applySimulatedLosses)
    MENU_MISSION_COMMAND:New("Start automatic replenishment", menu, startReplenishment)
    MENU_MISSION_COMMAND:New("Show all node stocks", menu, showInventory)
    MENU_MISSION_COMMAND:New("Show replenishment packets", menu, showPackets)
  end

  log("INFO", "startup", {
    buildTimestamp = build and build.buildTimestamp or "source",
    configurationVersion = config.configurationVersion,
    networkId = config.networkId,
    initialPersonnel = state.initialPersonnel,
    hqPersonnel = config.headquarters.initialPersonnel,
    shelterPersonnel = state.initialPersonnel - config.headquarters.initialPersonnel,
    nodeCount = 1 + #config.shelters,
    templateStrengthRange = "1-10",
    originPolicy = config.replenishment.originPolicy,
    fillOrder = config.replenishment.fillOrder,
  })
  announce("TM02R READY: apply losses, then start top-down replenishment")

  state.applySimulatedLosses = applySimulatedLosses
  state.startReplenishment = startReplenishment
  state.showInventory = showInventory
  state.showPackets = showPackets
  state.validateAndReport = validateAndReport
  state.inventorySnapshot = inventorySnapshot
  state.monitorTick = monitorTick
  return state
end

return TM02R
