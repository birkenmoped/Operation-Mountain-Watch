local TM02N = {}

local TERMINAL_PACKET_STATES = {
  ARRIVED = true,
  DESTROYED = true,
  FAILED = true,
}

local function copyTable(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "table" then
      result[key] = copyTable(value)
    else
      result[key] = value
    end
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

function TM02N.start(config, build)
  local prefix = "[OMW][TM02N]"

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
      trigger.action.outText(text, 12)
    end
  end

  local state = {
    started = false,
    completed = false,
    failed = false,
    monitorActive = false,
    monitorGeneration = 0,
    activePacketCount = 0,
    nextQueueIndex = 1,
    totalLosses = 0,
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
    log("ERROR", event or "network_failed", {
      reason = tostring(reason),
      missionTimeSeconds = timer.getTime(),
    })
    announce("TM02N failed: " .. tostring(reason))
  end

  local function buildNodeRegistry()
    local hq = {
      nodeId = config.headquarters.nodeId,
      label = "HQ",
      zoneName = config.headquarters.zoneName,
      targetStrength = nil,
      currentGarrison = config.headquarters.initialPersonnel,
      parentNodeId = nil,
      childNodeIds = {},
    }
    state.nodeById[hq.nodeId] = hq

    for _, definition in ipairs(config.shelters) do
      if state.nodeById[definition.nodeId] then
        error("duplicate nodeId: " .. definition.nodeId)
      end
      state.nodeById[definition.nodeId] = {
        nodeId = definition.nodeId,
        label = definition.label,
        zoneName = definition.zoneName,
        targetStrength = definition.targetStrength,
        currentGarrison = 0,
        parentNodeId = definition.parentNodeId,
        childNodeIds = {},
      }
    end

    for _, definition in ipairs(config.shelters) do
      local parent = state.nodeById[definition.parentNodeId]
      if not parent then
        error("missing parent node: " .. tostring(definition.parentNodeId))
      end
      parent.childNodeIds[#parent.childNodeIds + 1] = definition.nodeId
    end
  end

  local function validateConfiguration()
    local errors = {}
    if type(config.headquarters.initialPersonnel) ~= "number"
      or config.headquarters.initialPersonnel < 0 then
      errors[#errors + 1] = "headquarters.initialPersonnel must be non-negative"
    end
    if config.movement.packetStrength ~= config.template.expectedFighterCount then
      errors[#errors + 1] = "packet strength and template fighter count differ"
    end
    if config.movement.packetStrength ~= 10 then
      errors[#errors + 1] = "TM02N requires packet strength 10"
    end
    if config.movement.maxActivePackets ~= 2 then
      errors[#errors + 1] = "TM02N requires exactly two active packet slots"
    end
    if #config.shelters ~= 6 then
      errors[#errors + 1] = "TM02N requires exactly six shelters"
    end
    if #config.packets ~= 6 then
      errors[#errors + 1] = "TM02N requires exactly six packets"
    end

    local finalTargets = {}
    local plannedPersonnel = 0
    for _, shelter in ipairs(config.shelters) do
      if shelter.targetStrength ~= 10 then
        errors[#errors + 1] = shelter.nodeId .. " targetStrength must equal 10"
      end
    end

    for _, packetDefinition in ipairs(config.packets) do
      local route = packetDefinition.routeNodeIds or {}
      if #route < 2 then
        errors[#errors + 1] = packetDefinition.packetId .. " route must contain at least two nodes"
      elseif route[1] ~= config.headquarters.nodeId then
        errors[#errors + 1] = packetDefinition.packetId .. " must originate at HQ"
      else
        for index = 2, #route do
          local child = state.nodeById[route[index]]
          if not child then
            errors[#errors + 1] = packetDefinition.packetId .. " references missing node " .. tostring(route[index])
          elseif child.parentNodeId ~= route[index - 1] then
            errors[#errors + 1] = packetDefinition.packetId .. " skips parent-child edge at " .. route[index]
          end
        end
        local finalTarget = route[#route]
        if finalTargets[finalTarget] then
          errors[#errors + 1] = "duplicate final destination: " .. finalTarget
        end
        finalTargets[finalTarget] = true
      end
      plannedPersonnel = plannedPersonnel + config.movement.packetStrength
    end

    for _, shelter in ipairs(config.shelters) do
      if not finalTargets[shelter.nodeId] then
        errors[#errors + 1] = "shelter has no final packet: " .. shelter.nodeId
      end
    end
    if plannedPersonnel > config.headquarters.initialPersonnel then
      errors[#errors + 1] = "planned packet personnel exceeds HQ stock"
    end

    return #errors == 0, errors
  end

  local function validateMissionObjects()
    local missing = {}
    local templateGroup = GROUP:FindByName(config.template.groupName)
    if not templateGroup then
      missing[#missing + 1] = config.template.groupName
    end
    for _, node in pairs(state.nodeById) do
      if not ZONE:FindByName(node.zoneName) then
        missing[#missing + 1] = node.zoneName
      end
    end
    return #missing == 0, missing
  end

  local function initialisePackets()
    for index, definition in ipairs(config.packets) do
      state.packets[index] = {
        packetId = definition.packetId,
        runtimeAliasSuffix = definition.runtimeAliasSuffix,
        routeNodeIds = copyTable(definition.routeNodeIds),
        finalDestinationNodeId = definition.routeNodeIds[#definition.routeNodeIds],
        currentLegIndex = 1,
        state = "QUEUED",
        strength = config.movement.packetStrength,
        survivorCount = config.movement.packetStrength,
        runtimeGroup = nil,
        runtimeGroupName = nil,
      }
    end
  end

  local function inventorySnapshot()
    local hq = state.nodeById[config.headquarters.nodeId]
    local shelterPersonnel = 0
    local inTransitPersonnel = 0
    local queuedPacketCount = 0
    local arrivedPacketCount = 0
    local destroyedPacketCount = 0

    for _, shelter in ipairs(config.shelters) do
      shelterPersonnel = shelterPersonnel + state.nodeById[shelter.nodeId].currentGarrison
    end
    for _, packet in ipairs(state.packets) do
      if packet.state == "QUEUED" then
        queuedPacketCount = queuedPacketCount + 1
      elseif packet.state == "MOVING" or packet.state == "SPAWNING" then
        inTransitPersonnel = inTransitPersonnel + packet.survivorCount
      elseif packet.state == "ARRIVED" then
        arrivedPacketCount = arrivedPacketCount + 1
      elseif packet.state == "DESTROYED" then
        destroyedPacketCount = destroyedPacketCount + 1
      end
    end

    local accountedPersonnel = hq.currentGarrison
      + shelterPersonnel
      + inTransitPersonnel
      + state.totalLosses

    local allSheltersAtTarget = true
    for _, shelter in ipairs(config.shelters) do
      local node = state.nodeById[shelter.nodeId]
      if node.currentGarrison ~= node.targetStrength then
        allSheltersAtTarget = false
        break
      end
    end

    return {
      hqPersonnel = hq.currentGarrison,
      shelterPersonnel = shelterPersonnel,
      inTransitPersonnel = inTransitPersonnel,
      totalLosses = state.totalLosses,
      accountedPersonnel = accountedPersonnel,
      initialPersonnel = config.headquarters.initialPersonnel,
      accountingValid = accountedPersonnel == config.headquarters.initialPersonnel,
      queuedPacketCount = queuedPacketCount,
      activePacketCount = state.activePacketCount,
      arrivedPacketCount = arrivedPacketCount,
      destroyedPacketCount = destroyedPacketCount,
      allSheltersAtTarget = allSheltersAtTarget,
      networkComplete = state.completed,
    }
  end

  local function logInventory(event)
    for _, nodeId in ipairs({
      config.headquarters.nodeId,
      "RED_SHELTER_A",
      "RED_SHELTER_B",
      "RED_SHELTER_AA",
      "RED_SHELTER_AB",
      "RED_SHELTER_BA",
      "RED_SHELTER_BB",
    }) do
      local node = state.nodeById[nodeId]
      log("INFO", "red_node_inventory", {
        nodeId = node.nodeId,
        label = node.label,
        currentGarrison = node.currentGarrison,
        targetStrength = node.targetStrength or "POOL",
        atTargetStrength = node.targetStrength == nil or node.currentGarrison == node.targetStrength,
      })
    end
    local snapshot = inventorySnapshot()
    snapshot.reason = event or "manual"
    log("INFO", "red_network_inventory", snapshot)
    return snapshot
  end

  local function showInventory()
    local snapshot = logInventory("manual")
    local lines = { "RED NETWORK INVENTORY" }
    local order = {
      config.headquarters.nodeId,
      "RED_SHELTER_A",
      "RED_SHELTER_B",
      "RED_SHELTER_AA",
      "RED_SHELTER_AB",
      "RED_SHELTER_BA",
      "RED_SHELTER_BB",
    }
    for _, nodeId in ipairs(order) do
      local node = state.nodeById[nodeId]
      if node.targetStrength then
        lines[#lines + 1] = node.label .. ": " .. node.currentGarrison .. " / " .. node.targetStrength
      else
        lines[#lines + 1] = node.label .. ": " .. node.currentGarrison
      end
    end
    lines[#lines + 1] = "In transit: " .. snapshot.inTransitPersonnel
    lines[#lines + 1] = "Losses: " .. snapshot.totalLosses
    lines[#lines + 1] = "Accounted: " .. snapshot.accountedPersonnel .. " / " .. snapshot.initialPersonnel
    lines[#lines + 1] = "Accounting valid: " .. tostring(snapshot.accountingValid)
    lines[#lines + 1] = "All shelters at target: " .. tostring(snapshot.allSheltersAtTarget)
    announce(table.concat(lines, "\n"))
  end

  local function showPackets()
    local lines = { "TM02N PACKETS" }
    for _, packet in ipairs(state.packets) do
      local currentNodeId = packet.routeNodeIds[packet.currentLegIndex]
      local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
      lines[#lines + 1] = packet.packetId
        .. " | " .. packet.state
        .. " | " .. packet.survivorCount
        .. " | " .. tostring(currentNodeId)
        .. " -> " .. tostring(nextNodeId or packet.finalDestinationNodeId)
      log("INFO", "red_packet_status", {
        packetId = packet.packetId,
        packetState = packet.state,
        survivorCount = packet.survivorCount,
        currentLegIndex = packet.currentLegIndex,
        currentNodeId = currentNodeId,
        nextNodeId = nextNodeId or "none",
        finalDestinationNodeId = packet.finalDestinationNodeId,
        runtimeGroupName = packet.runtimeGroupName or "none",
      })
    end
    announce(table.concat(lines, "\n"))
  end

  local function buildLegRoute(packet)
    local group = packet.runtimeGroup
    if not group then
      error("runtime group unavailable for " .. packet.packetId)
    end
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = state.nodeById[nextNodeId]
    if not nextNode then
      error("next node unavailable for " .. packet.packetId)
    end
    local destinationZone = ZONE:FindByName(nextNode.zoneName)
    if not destinationZone then
      error("destination zone unavailable: " .. nextNode.zoneName)
    end
    local startCoordinate = group:GetCoordinate()
    local destinationCoordinate = destinationZone:GetCoordinate()
    if not startCoordinate or not destinationCoordinate then
      error("route coordinate unavailable for " .. packet.packetId)
    end
    return {
      startCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
      destinationCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
    }, nextNode
  end

  local function assignCurrentLeg(packet)
    local waypoints, nextNode = buildLegRoute(packet)
    local assigned = packet.runtimeGroup:Route(
      waypoints,
      config.routing.assignmentDelaySeconds
    )
    if not assigned then
      error("route assignment returned nil for " .. packet.packetId)
    end
    packet.state = "MOVING"
    log("INFO", "red_packet_leg_started", {
      packetId = packet.packetId,
      currentLegIndex = packet.currentLegIndex,
      sourceNodeId = packet.routeNodeIds[packet.currentLegIndex],
      destinationNodeId = nextNode.nodeId,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      runtimeGroupName = packet.runtimeGroupName,
      survivorCount = packet.survivorCount,
      waypointCount = #waypoints,
    })
  end

  local function dispatchPacket(packet)
    local hq = state.nodeById[config.headquarters.nodeId]
    if hq.currentGarrison < packet.strength then
      error("HQ lacks personnel for " .. packet.packetId)
    end
    hq.currentGarrison = hq.currentGarrison - packet.strength
    packet.state = "SPAWNING"

    local sourceZone = ZONE:FindByName(config.headquarters.zoneName)
    if not sourceZone then
      error("HQ source zone unavailable")
    end
    local alias = config.template.runtimeAliasPrefix .. packet.runtimeAliasSuffix
    local spawner = SPAWN:NewWithAlias(config.template.groupName, alias)
    local group = spawner:SpawnInZone(sourceZone, false)
    if not group then
      error("spawn returned nil for " .. packet.packetId)
    end
    packet.runtimeGroup = group
    packet.runtimeGroupName = group:GetName()
    packet.survivorCount = group:CountAliveUnits()
    if packet.survivorCount ~= packet.strength then
      error(packet.packetId .. " spawned with " .. packet.survivorCount .. " instead of " .. packet.strength)
    end

    state.activePacketCount = state.activePacketCount + 1
    log("INFO", "red_packet_dispatched", {
      packetId = packet.packetId,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      hqPersonnel = hq.currentGarrison,
      routeNodeIds = join(packet.routeNodeIds, ">"),
      runtimeGroupName = packet.runtimeGroupName,
      strength = packet.strength,
      activePacketCount = state.activePacketCount,
    })
    assignCurrentLeg(packet)
  end

  local function dispatchAvailablePackets()
    while not state.failed
      and state.activePacketCount < config.movement.maxActivePackets
      and state.nextQueueIndex <= #state.packets do
      local packet = state.packets[state.nextQueueIndex]
      state.nextQueueIndex = state.nextQueueIndex + 1
      local ok, dispatchError = pcall(dispatchPacket, packet)
      if not ok then
        packet.state = "FAILED"
        fail(dispatchError, "red_packet_dispatch_failed")
        return
      end
    end
  end

  local function finalizePacket(packet)
    local destinationNode = state.nodeById[packet.finalDestinationNodeId]
    if not destinationNode or not destinationNode.targetStrength then
      error("final destination is not a shelter for " .. packet.packetId)
    end
    if destinationNode.currentGarrison + packet.survivorCount > destinationNode.targetStrength then
      error("arrival would overfill " .. destinationNode.nodeId)
    end
    destinationNode.currentGarrison = destinationNode.currentGarrison + packet.survivorCount
    packet.state = "ARRIVED"
    state.activePacketCount = state.activePacketCount - 1
    log("INFO", "red_packet_arrived", {
      packetId = packet.packetId,
      destinationNodeId = destinationNode.nodeId,
      destinationGarrison = destinationNode.currentGarrison,
      targetStrength = destinationNode.targetStrength,
      survivorCount = packet.survivorCount,
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
      log("INFO", "red_packet_losses_recorded", {
        packetId = packet.packetId,
        losses = losses,
        survivorCount = packet.survivorCount,
        totalLosses = state.totalLosses,
      })
    end
    if packet.survivorCount < 1 then
      packet.state = "DESTROYED"
      state.activePacketCount = state.activePacketCount - 1
      log("INFO", "red_packet_destroyed", {
        packetId = packet.packetId,
        activePacketCount = state.activePacketCount,
      })
      return
    end

    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = state.nodeById[nextNodeId]
    local destinationZone = ZONE:FindByName(nextNode.zoneName)
    if packet.runtimeGroup:IsCompletelyInZone(destinationZone) ~= true then
      return
    end

    log("INFO", "red_packet_leg_arrived", {
      packetId = packet.packetId,
      currentLegIndex = packet.currentLegIndex,
      nodeId = nextNode.nodeId,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      survivorCount = packet.survivorCount,
    })

    if packet.currentLegIndex + 1 == #packet.routeNodeIds then
      finalizePacket(packet)
      return
    end

    packet.currentLegIndex = packet.currentLegIndex + 1
    assignCurrentLeg(packet)
  end

  local function allPacketsTerminal()
    for _, packet in ipairs(state.packets) do
      if not TERMINAL_PACKET_STATES[packet.state] then
        return false
      end
    end
    return true
  end

  local function monitorTick()
    for _, packet in ipairs(state.packets) do
      if packet.state == "MOVING" then
        reconcilePacket(packet)
      end
    end
    dispatchAvailablePackets()

    local snapshot = inventorySnapshot()
    if snapshot.accountingValid ~= true then
      fail("personnel accounting mismatch", "red_network_accounting_failed")
      return false
    end

    if allPacketsTerminal() then
      state.completed = snapshot.allSheltersAtTarget
        and snapshot.destroyedPacketCount == 0
        and snapshot.accountingValid
      state.monitorActive = false
      log("INFO", "red_network_completed", snapshot)
      announce(
        state.completed
          and "TM02N complete: all shelters at 10, HQ at 40"
          or "TM02N stopped without full network completion"
      )
      return false
    end
    return true
  end

  local function startMonitor()
    state.monitorGeneration = state.monitorGeneration + 1
    local generation = state.monitorGeneration
    state.monitorActive = true
    log("INFO", "red_network_monitor_started", {
      initialDelaySeconds = config.movement.monitorInitialDelaySeconds,
      intervalSeconds = config.movement.monitorIntervalSeconds,
    })
    timer.scheduleFunction(function(_, scheduledTime)
      if not state.monitorActive or generation ~= state.monitorGeneration then
        return nil
      end
      local ok, continueOrError = pcall(monitorTick)
      if not ok then
        fail(continueOrError, "red_network_monitor_failed")
        return nil
      end
      if continueOrError ~= true then
        return nil
      end
      return scheduledTime + config.movement.monitorIntervalSeconds
    end, nil, timer.getTime() + config.movement.monitorInitialDelaySeconds)
  end

  local function startAutomaticFill()
    if state.started then
      announce("TM02N start rejected: network fill already started")
      log("INFO", "red_network_start_rejected", { reason = "already started" })
      return
    end
    if state.failed then
      announce("TM02N start rejected: bootstrap failed")
      return
    end
    state.started = true
    log("INFO", "red_network_start_requested", {
      packetCount = #state.packets,
      packetStrength = config.movement.packetStrength,
      maxActivePackets = config.movement.maxActivePackets,
      initialPersonnel = config.headquarters.initialPersonnel,
    })
    dispatchAvailablePackets()
    if not state.failed then
      startMonitor()
      showInventory()
    end
  end

  local function validateAndReport()
    local configValid, configErrors = validateConfiguration()
    local objectsValid, missingObjects = validateMissionObjects()
    log("INFO", "red_network_validation", {
      configurationValid = configValid,
      missionObjectsValid = objectsValid,
      configurationErrors = #configErrors == 0 and "none" or join(configErrors, " | "),
      missingObjects = #missingObjects == 0 and "none" or join(missingObjects, ","),
      checkedNodeCount = 1 + #config.shelters,
      checkedPacketCount = #config.packets,
    })
    announce(
      "TM02N validation"
        .. "\nConfiguration: " .. tostring(configValid)
        .. "\nMission objects: " .. tostring(objectsValid)
        .. "\nMissing: " .. (#missingObjects == 0 and "none" or join(missingObjects, ", "))
    )
    return configValid and objectsValid
  end

  local registryOk, registryError = pcall(buildNodeRegistry)
  if not registryOk then
    fail(registryError, "red_network_registry_failed")
    return state
  end
  initialisePackets()

  local ready = validateAndReport()
  if not ready then
    fail("configuration or Mission Editor validation failed", "red_network_bootstrap_failed")
    return state
  end

  if config.debug.enableF10Menu == true then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM02N RED Tree Fill", root)
    MENU_MISSION_COMMAND:New("Validate network", menu, validateAndReport)
    MENU_MISSION_COMMAND:New("Start automatic fill", menu, startAutomaticFill)
    MENU_MISSION_COMMAND:New("Show all node stocks", menu, showInventory)
    MENU_MISSION_COMMAND:New("Show active packets", menu, showPackets)
  end

  log("INFO", "startup", {
    buildTimestamp = build and build.buildTimestamp or "source",
    configurationVersion = config.configurationVersion,
    networkId = config.networkId,
    nodeCount = 1 + #config.shelters,
    packetCount = #config.packets,
    initialPersonnel = config.headquarters.initialPersonnel,
  })
  announce("TM02N READY: HQ 100, six shelters target strength 10")

  state.showInventory = showInventory
  state.showPackets = showPackets
  state.startAutomaticFill = startAutomaticFill
  state.validateAndReport = validateAndReport
  state.inventorySnapshot = inventorySnapshot
  return state
end

return TM02N
