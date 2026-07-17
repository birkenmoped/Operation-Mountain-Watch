local TM02V = {}

local TERMINAL_PACKET_STATES = {
  ARRIVED = true,
  DESTROYED = true,
  FAILED = true,
}

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

local function distance2D(first, second)
  if not first or not second then
    return nil
  end
  local dx = (second.x or 0) - (first.x or 0)
  local dz = (second.z or 0) - (first.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

function TM02V.start(config, build)
  local prefix = "[OMW][TM02V]"

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
    started = false,
    completed = false,
    failed = false,
    blocked = false,
    monitorActive = false,
    monitorGeneration = 0,
    markersEnabled = config.debug.markersEnabledOnStart == true,
    activePacketCount = 0,
    currentDispatchDepth = 1,
    maximumDispatchDepth = 0,
    totalLosses = config.recordedLosses or 0,
    initialPersonnel = 0,
    nextPacketSequence = 1,
    nodeById = {},
    packets = {},
    packetById = {},
    launchSlotInUse = {},
    menu = nil,
  }

  local installPacketMenu
  local dispatchAvailablePackets
  local evaluateCompletion

  local function fail(reason, event, packet)
    if state.failed then
      return
    end
    state.failed = true
    state.completed = false
    state.monitorActive = false
    state.monitorGeneration = state.monitorGeneration + 1
    if packet and not TERMINAL_PACKET_STATES[packet.movementState] then
      packet.movementState = "FAILED"
    end
    log("ERROR", event or "red_proxy_movement_failed", {
      missionTimeSeconds = timer.getTime(),
      reason = tostring(reason),
      packetId = packet and packet.packetId or "none",
      representationState = packet and packet.representationState or "none",
    })
    announce("TM02V failed: " .. tostring(reason))
  end

  local function safeDestroy(group)
    if group then
      pcall(function()
        group:Destroy()
      end)
    end
  end

  local function buildNodeRegistry()
    local hq = {
      nodeId = config.headquarters.nodeId,
      label = "HQ",
      parentNodeId = nil,
      childNodeIds = {},
      zoneName = config.headquarters.zoneName,
      targetStrength = nil,
      currentGarrison = config.headquarters.initialPersonnel,
      initialGarrison = config.headquarters.initialPersonnel,
      depth = 0,
    }
    state.nodeById[hq.nodeId] = hq
    state.initialPersonnel = hq.currentGarrison + state.totalLosses

    for _, definition in ipairs(config.shelters or {}) do
      if state.nodeById[definition.nodeId] then
        error("duplicate nodeId: " .. tostring(definition.nodeId))
      end
      state.nodeById[definition.nodeId] = {
        nodeId = definition.nodeId,
        label = definition.label,
        parentNodeId = definition.parentNodeId,
        childNodeIds = {},
        zoneName = definition.zoneName,
        targetStrength = definition.targetStrength,
        currentGarrison = definition.initialGarrison,
        initialGarrison = definition.initialGarrison,
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

  local function totalInitialDeficit()
    local total = 0
    for _, definition in ipairs(config.shelters or {}) do
      local node = state.nodeById[definition.nodeId]
      total = total + math.max(0, node.targetStrength - node.currentGarrison)
    end
    return total
  end

  local function validateConfiguration()
    local errors = {}
    if state.initialPersonnel ~= 100 then
      errors[#errors + 1] = "TM02V authoritative initial personnel must equal 100"
    end
    if #config.shelters ~= 6 then
      errors[#errors + 1] = "TM02V requires the six-shelter TM02 tree"
    end
    if config.movement.originPolicy ~= "HQ_TO_FINAL" then
      errors[#errors + 1] = "TM02V requires originPolicy=HQ_TO_FINAL"
    end
    if config.movement.fillOrder ~= "TOP_DOWN" then
      errors[#errors + 1] = "TM02V requires fillOrder=TOP_DOWN"
    end
    if type(config.movement.packetMaxStrength) ~= "number"
      or config.movement.packetMaxStrength % 1 ~= 0
      or config.movement.packetMaxStrength < 1
      or config.movement.packetMaxStrength > 10 then
      errors[#errors + 1] = "packetMaxStrength must be an integer from 1 to 10"
    end
    if type(config.movement.maxActivePackets) ~= "number"
      or config.movement.maxActivePackets % 1 ~= 0
      or config.movement.maxActivePackets < 1 then
      errors[#errors + 1] = "maxActivePackets must be a positive integer"
    end
    if type(config.proxy.launchSlots) ~= "table"
      or #config.proxy.launchSlots < config.movement.maxActivePackets then
      errors[#errors + 1] = "launchSlots must cover every active packet slot"
    end

    local launchOffsets = {}
    for index, offset in ipairs(config.proxy.launchSlots or {}) do
      if type(offset) ~= "table"
        or type(offset.x) ~= "number"
        or type(offset.y) ~= "number" then
        errors[#errors + 1] = "launch slot " .. tostring(index) .. " requires numeric x/y offsets"
      else
        local key = tostring(offset.x) .. ":" .. tostring(offset.y)
        if launchOffsets[key] then
          errors[#errors + 1] = "duplicate launch slot offset " .. key
        end
        launchOffsets[key] = true
      end
    end

    for strength = 1, 10 do
      if type(config.templatesByStrength[strength]) ~= "string"
        or config.templatesByStrength[strength] == "" then
        errors[#errors + 1] = "missing group template for strength " .. tostring(strength)
      end
    end

    for _, definition in ipairs(config.shelters or {}) do
      local node = state.nodeById[definition.nodeId]
      if type(node.targetStrength) ~= "number"
        or node.targetStrength % 1 ~= 0
        or node.targetStrength < 1 then
        errors[#errors + 1] = node.nodeId .. " targetStrength must be a positive integer"
      end
      if type(node.currentGarrison) ~= "number"
        or node.currentGarrison % 1 ~= 0
        or node.currentGarrison < 0
        or node.currentGarrison > node.targetStrength then
        errors[#errors + 1] = node.nodeId .. " initialGarrison must be between 0 and targetStrength"
      end
    end

    local hq = state.nodeById[config.headquarters.nodeId]
    if totalInitialDeficit() > hq.currentGarrison then
      errors[#errors + 1] = "HQ stock is insufficient to fill all configured shelter deficits"
    end
    return #errors == 0, errors
  end

  local function validateMissionObjects()
    local missing = {}
    for strength = 1, 10 do
      local templateName = config.templatesByStrength[strength]
      if not GROUP:FindByName(templateName) then
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
      error("node is not connected to HQ: " .. tostring(nodeId))
    end
    local route = {}
    for index = #reversed, 1, -1 do
      route[#route + 1] = reversed[index]
    end
    return route
  end

  local function packetPersonnelInTransit(packet)
    if packet.movementState == "SPAWNING" or packet.movementState == "EN_ROUTE" then
      return packet.survivorCount
    end
    return 0
  end

  local function inboundForNode(nodeId)
    local total = 0
    for _, packet in ipairs(state.packets) do
      if packet.finalDestinationNodeId == nodeId
        and (packet.movementState == "SPAWNING" or packet.movementState == "EN_ROUTE") then
        total = total + packet.survivorCount
      end
    end
    return total
  end

  local function inventorySnapshot()
    local hq = state.nodeById[config.headquarters.nodeId]
    local shelterPersonnel = 0
    local totalDeficit = 0
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      shelterPersonnel = shelterPersonnel + node.currentGarrison
      totalDeficit = totalDeficit + math.max(0, node.targetStrength - node.currentGarrison)
    end

    local inTransitPersonnel = 0
    local arrivedPacketCount = 0
    local destroyedPacketCount = 0
    local failedPacketCount = 0
    for _, packet in ipairs(state.packets) do
      inTransitPersonnel = inTransitPersonnel + packetPersonnelInTransit(packet)
      if packet.movementState == "ARRIVED" then
        arrivedPacketCount = arrivedPacketCount + 1
      elseif packet.movementState == "DESTROYED" then
        destroyedPacketCount = destroyedPacketCount + 1
      elseif packet.movementState == "FAILED" then
        failedPacketCount = failedPacketCount + 1
      end
    end

    local accountedPersonnel = hq.currentGarrison + shelterPersonnel + inTransitPersonnel + state.totalLosses
    return {
      hqPersonnel = hq.currentGarrison,
      shelterPersonnel = shelterPersonnel,
      inTransitPersonnel = inTransitPersonnel,
      totalLosses = state.totalLosses,
      totalDeficit = totalDeficit,
      accountedPersonnel = accountedPersonnel,
      initialPersonnel = state.initialPersonnel,
      accountingValid = accountedPersonnel == state.initialPersonnel,
      activePacketCount = state.activePacketCount,
      generatedPacketCount = #state.packets,
      arrivedPacketCount = arrivedPacketCount,
      destroyedPacketCount = destroyedPacketCount,
      failedPacketCount = failedPacketCount,
      allSheltersAtTarget = totalDeficit == 0,
      currentDispatchDepth = state.currentDispatchDepth,
      maximumDispatchDepth = state.maximumDispatchDepth,
      networkComplete = state.completed,
      blocked = state.blocked,
    }
  end

  local function activeGroup(packet)
    if packet.representationState == "LEADER_PROXY" then
      return packet.proxyGroup
    end
    if packet.representationState == "PHYSICAL"
      or packet.representationState == "PHYSICAL_GARRISON" then
      return packet.physicalGroup
    end
    return nil
  end

  local function updateCurrentCoordinate(packet)
    local group = activeGroup(packet)
    if not group then
      return nil
    end
    local coordinate = group:GetCoordinate()
    if not coordinate then
      return nil
    end
    packet.currentCoordinate = coordinate:GetVec3()
    packet.lastUpdateMissionTime = timer.getTime()
    return coordinate
  end

  local function removeMarker(packet)
    if trigger.action.removeMark then
      trigger.action.removeMark(packet.markerId)
    end
  end

  local function markerText(packet)
    local currentNodeId = packet.routeNodeIds[packet.currentLegIndex]
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = nextNodeId and state.nodeById[nextNodeId] or nil
    local nextCoordinate = nextNode and ZONE:FindByName(nextNode.zoneName):GetCoordinate():GetVec3() or nil
    local remaining = distance2D(packet.currentCoordinate, nextCoordinate)
    return table.concat({
      "TM02V " .. packet.packetId,
      packet.representationState .. " / " .. packet.movementState,
      "Strength: " .. packet.survivorCount .. " / " .. packet.strength,
      "Target: " .. packet.finalDestinationNodeId,
      "Leg: " .. tostring(currentNodeId) .. " -> " .. tostring(nextNodeId or packet.finalDestinationNodeId),
      "Next node distance: " .. (remaining and string.format("%.0f m", remaining) or "n/a"),
    }, "\n")
  end

  local function updateMarker(packet)
    if state.markersEnabled ~= true or not packet.currentCoordinate then
      return
    end
    removeMarker(packet)
    trigger.action.markToAll(packet.markerId, markerText(packet), packet.currentCoordinate, true)
  end

  local function updateAllMarkers()
    for _, packet in ipairs(state.packets) do
      updateCurrentCoordinate(packet)
      updateMarker(packet)
    end
  end

  local function logPacketStatus(packet, reason)
    local currentNodeId = packet.routeNodeIds[packet.currentLegIndex]
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    log("INFO", "red_proxy_packet_status", {
      reason = reason or "manual",
      packetId = packet.packetId,
      movementState = packet.movementState,
      representationState = packet.representationState,
      strength = packet.strength,
      survivorCount = packet.survivorCount,
      targetDepth = packet.targetDepth,
      launchSlotIndex = packet.launchSlotIndex or "none",
      currentLegIndex = packet.currentLegIndex,
      currentNodeId = currentNodeId,
      nextNodeId = nextNodeId or "none",
      finalDestinationNodeId = packet.finalDestinationNodeId,
      proxyGroupName = packet.proxyGroupName or "none",
      physicalGroupName = packet.physicalGroupName or "none",
      coordinateX = packet.currentCoordinate and packet.currentCoordinate.x or "none",
      coordinateY = packet.currentCoordinate and packet.currentCoordinate.y or "none",
      coordinateZ = packet.currentCoordinate and packet.currentCoordinate.z or "none",
      arrivalCredited = packet.arrivalCredited,
    })
  end

  local function showPacketStatus(packetId)
    local packet = state.packetById[packetId]
    if not packet then
      announce("TM02V packet not found: " .. tostring(packetId))
      return false
    end
    updateCurrentCoordinate(packet)
    updateMarker(packet)
    logPacketStatus(packet, "manual")
    announce(table.concat({
      packet.packetId,
      "Movement: " .. packet.movementState,
      "Representation: " .. packet.representationState,
      "Strength: " .. packet.survivorCount .. " / " .. packet.strength,
      "Target: " .. packet.finalDestinationNodeId,
      "Leg: " .. packet.currentLegIndex .. " / " .. (#packet.routeNodeIds - 1),
      "Route: " .. join(packet.routeNodeIds, " > "),
      "Proxy: " .. tostring(packet.proxyGroupName or "none"),
      "Physical: " .. tostring(packet.physicalGroupName or "none"),
    }, "\n"))
    return true
  end

  local function showAllStatus()
    updateAllMarkers()
    local snapshot = inventorySnapshot()
    local lines = { "TM02V DYNAMIC PROXY FILL" }
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      lines[#lines + 1] = node.label .. ": " .. node.currentGarrison .. " / " .. node.targetStrength
        .. " (inbound " .. inboundForNode(node.nodeId) .. ")"
    end
    lines[#lines + 1] = "Generated packets: " .. snapshot.generatedPacketCount
    lines[#lines + 1] = "Active packets: " .. snapshot.activePacketCount
    lines[#lines + 1] = "Dispatch depth: " .. snapshot.currentDispatchDepth
    lines[#lines + 1] = "HQ: " .. snapshot.hqPersonnel
    lines[#lines + 1] = "Shelters: " .. snapshot.shelterPersonnel
    lines[#lines + 1] = "In transit: " .. snapshot.inTransitPersonnel
    lines[#lines + 1] = "Losses: " .. snapshot.totalLosses
    lines[#lines + 1] = "Deficit: " .. snapshot.totalDeficit
    lines[#lines + 1] = "Accounted: " .. snapshot.accountedPersonnel .. " / " .. snapshot.initialPersonnel
    lines[#lines + 1] = "Accounting valid: " .. tostring(snapshot.accountingValid)
    lines[#lines + 1] = "All shelters full: " .. tostring(snapshot.allSheltersAtTarget)
    announce(table.concat(lines, "\n"))
    log("INFO", "red_proxy_network_status", snapshot)
    for _, packet in ipairs(state.packets) do
      logPacketStatus(packet, "all-status")
    end
    return snapshot
  end

  local function buildLegWaypoints(packet, group)
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = state.nodeById[nextNodeId]
    if not nextNode then
      error("next route node unavailable for " .. packet.packetId)
    end
    local destinationZone = ZONE:FindByName(nextNode.zoneName)
    if not destinationZone then
      error("destination zone unavailable: " .. nextNode.zoneName)
    end
    local startCoordinate = group:GetCoordinate()
    local destinationCoordinate = destinationZone:GetCoordinate()
    if not startCoordinate or not destinationCoordinate then
      error("route coordinates unavailable for " .. packet.packetId)
    end
    return {
      startCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
      destinationCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
    }, nextNode
  end

  local function assignCurrentLeg(packet, group, representationState)
    local waypoints, nextNode = buildLegWaypoints(packet, group)
    local assigned = group:Route(waypoints, config.routing.assignmentDelaySeconds)
    if not assigned then
      error("route assignment returned nil for " .. packet.packetId)
    end
    log("INFO", "red_proxy_leg_started", {
      packetId = packet.packetId,
      representationState = representationState,
      currentLegIndex = packet.currentLegIndex,
      sourceNodeId = packet.routeNodeIds[packet.currentLegIndex],
      destinationNodeId = nextNode.nodeId,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      survivorCount = packet.survivorCount,
      runtimeGroupName = group:GetName(),
      waypointCount = #waypoints,
    })
  end

  local function nextAlias(packet, prefixValue, includeLaunchSlot)
    packet.runtimeGeneration = packet.runtimeGeneration + 1
    local alias = prefixValue .. packet.runtimeAliasSuffix
    if includeLaunchSlot then
      alias = alias .. "_SLOT" .. tostring(packet.launchSlotIndex)
    end
    return alias .. "_G" .. string.format("%03d", packet.runtimeGeneration)
  end

  local function spawnProxyAtCoordinate(packet, coordinate, continueMovement)
    local templateName = config.templatesByStrength[packet.survivorCount]
    if not templateName then
      error("no proxy source template for survivor count " .. tostring(packet.survivorCount))
    end
    local alias = nextAlias(packet, config.proxy.runtimeAliasPrefix, false)
    local group = SPAWN:NewWithAlias(templateName, alias):SpawnFromCoordinate(coordinate)
    if not group then
      error("proxy spawn returned nil for " .. packet.packetId)
    end
    local count = group:CountAliveUnits()
    if count ~= config.proxy.expectedUnitCount then
      safeDestroy(group)
      error("proxy spawned with " .. tostring(count) .. " instead of 1 for " .. packet.packetId)
    end
    if continueMovement then
      local routeOk, routeError = pcall(assignCurrentLeg, packet, group, "LEADER_PROXY")
      if not routeOk then
        safeDestroy(group)
        error(routeError)
      end
    end
    return group
  end

  local function spawnPhysicalAtCoordinate(packet, coordinate, continueMovement)
    local templateName = config.templatesByStrength[packet.survivorCount]
    if not templateName then
      error("no physical template for survivor count " .. tostring(packet.survivorCount))
    end
    local alias = nextAlias(packet, config.physical.runtimeAliasPrefix, false)
    local group = SPAWN:NewWithAlias(templateName, alias):SpawnFromCoordinate(coordinate)
    if not group then
      error("physical spawn returned nil for " .. packet.packetId)
    end
    local count = group:CountAliveUnits()
    if count ~= packet.survivorCount then
      safeDestroy(group)
      error("physical group spawned with " .. tostring(count) .. " instead of " .. tostring(packet.survivorCount))
    end
    if continueMovement then
      local routeOk, routeError = pcall(assignCurrentLeg, packet, group, "PHYSICAL")
      if not routeOk then
        safeDestroy(group)
        error(routeError)
      end
    end
    return group
  end

  local function synchronizePhysicalSurvivors(packet)
    if not packet.physicalGroup then
      return
    end
    local observed = packet.physicalGroup:CountAliveUnits()
    if observed > packet.survivorCount then
      error("physical survivor count increased for " .. packet.packetId)
    end
    if observed < packet.survivorCount then
      local losses = packet.survivorCount - observed
      packet.survivorCount = observed
      state.totalLosses = state.totalLosses + losses
      log("INFO", "red_proxy_physical_losses_recorded", {
        packetId = packet.packetId,
        losses = losses,
        survivorCount = packet.survivorCount,
        totalLosses = state.totalLosses,
      })
    end
  end

  local function forceUnpackInternal(packet, reason, continueMovement)
    if packet.representationState ~= "LEADER_PROXY" or not packet.proxyGroup then
      return false, "packet is not represented by its leader proxy"
    end
    local coordinate = packet.proxyGroup:GetCoordinate()
    if not coordinate then
      return false, "proxy coordinate unavailable"
    end
    packet.representationState = "UNPACKING"
    local ok, groupOrError = pcall(spawnPhysicalAtCoordinate, packet, coordinate, continueMovement)
    if not ok then
      packet.representationState = "LEADER_PROXY"
      return false, groupOrError
    end
    local oldProxy = packet.proxyGroup
    packet.physicalGroup = groupOrError
    packet.physicalGroupName = groupOrError:GetName()
    packet.proxyGroup = nil
    packet.proxyGroupName = nil
    safeDestroy(oldProxy)
    packet.representationState = continueMovement and "PHYSICAL" or "PHYSICAL_GARRISON"
    updateCurrentCoordinate(packet)
    updateMarker(packet)
    log("INFO", "red_proxy_unpacked", {
      packetId = packet.packetId,
      reason = reason,
      survivorCount = packet.survivorCount,
      physicalGroupName = packet.physicalGroupName,
      movementState = packet.movementState,
      representationState = packet.representationState,
    })
    return true
  end

  local function forceUnpack(packetId)
    local packet = state.packetById[packetId]
    if not packet or packet.movementState ~= "EN_ROUTE" then
      announce("TM02V unpack rejected for " .. tostring(packetId) .. ": movement is not en route")
      return false
    end
    local ok, reason = forceUnpackInternal(packet, "manual", true)
    if not ok then
      announce("TM02V unpack rejected for " .. packet.runtimeAliasSuffix .. ": " .. tostring(reason))
      log("INFO", "red_proxy_unpack_rejected", { packetId = packet.packetId, reason = tostring(reason) })
      return false
    end
    announce("TM02V " .. packet.runtimeAliasSuffix .. " unpacked")
    return true
  end

  local function forcePackInternal(packet, reason)
    if packet.representationState ~= "PHYSICAL" or not packet.physicalGroup then
      return false, "packet is not an en-route physical group"
    end
    synchronizePhysicalSurvivors(packet)
    if packet.survivorCount < 1 then
      packet.movementState = "DESTROYED"
      packet.representationState = "NONE"
      safeDestroy(packet.physicalGroup)
      packet.physicalGroup = nil
      packet.physicalGroupName = nil
      state.activePacketCount = math.max(0, state.activePacketCount - 1)
      state.launchSlotInUse[packet.launchSlotIndex] = nil
      return false, "physical group has no survivors"
    end
    local coordinate = packet.physicalGroup:GetCoordinate()
    if not coordinate then
      return false, "physical group coordinate unavailable"
    end
    packet.representationState = "PACKING"
    local ok, groupOrError = pcall(spawnProxyAtCoordinate, packet, coordinate, true)
    if not ok then
      packet.representationState = "PHYSICAL"
      return false, groupOrError
    end
    local oldPhysical = packet.physicalGroup
    packet.proxyGroup = groupOrError
    packet.proxyGroupName = groupOrError:GetName()
    packet.physicalGroup = nil
    packet.physicalGroupName = nil
    safeDestroy(oldPhysical)
    packet.representationState = "LEADER_PROXY"
    updateCurrentCoordinate(packet)
    updateMarker(packet)
    log("INFO", "red_proxy_packed", {
      packetId = packet.packetId,
      reason = reason,
      survivorCount = packet.survivorCount,
      proxyGroupName = packet.proxyGroupName,
    })
    return true
  end

  local function forcePack(packetId)
    local packet = state.packetById[packetId]
    if not packet or packet.movementState ~= "EN_ROUTE" then
      announce("TM02V pack rejected for " .. tostring(packetId) .. ": movement is not en route")
      return false
    end
    local ok, reason = forcePackInternal(packet, "manual")
    if not ok then
      announce("TM02V pack rejected for " .. packet.runtimeAliasSuffix .. ": " .. tostring(reason))
      log("INFO", "red_proxy_pack_rejected", { packetId = packet.packetId, reason = tostring(reason) })
      return false
    end
    announce("TM02V " .. packet.runtimeAliasSuffix .. " packed")
    return true
  end

  local function releaseLaunchSlot(packet)
    if packet.launchSlotIndex then
      state.launchSlotInUse[packet.launchSlotIndex] = nil
    end
  end

  local function creditArrival(packet)
    if packet.arrivalCredited then
      error("duplicate arrival credit for " .. packet.packetId)
    end
    local destination = state.nodeById[packet.finalDestinationNodeId]
    if not destination then
      error("arrival destination unavailable for " .. packet.packetId)
    end
    if destination.currentGarrison + packet.survivorCount > destination.targetStrength then
      error("arrival would overfill " .. destination.nodeId)
    end
    destination.currentGarrison = destination.currentGarrison + packet.survivorCount
    packet.arrivalCredited = true
    packet.movementState = "ARRIVED"
    packet.representationState = "PHYSICAL_GARRISON"
    state.activePacketCount = math.max(0, state.activePacketCount - 1)
    releaseLaunchSlot(packet)
    updateCurrentCoordinate(packet)
    updateMarker(packet)
    log("INFO", "red_proxy_arrived", {
      packetId = packet.packetId,
      destinationNodeId = destination.nodeId,
      destinationGarrison = destination.currentGarrison,
      targetStrength = destination.targetStrength,
      survivorCount = packet.survivorCount,
      physicalGroupName = packet.physicalGroupName,
      representationState = packet.representationState,
      activePacketCount = state.activePacketCount,
    })
  end

  local function arriveAtCurrentLegDestination(packet)
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    log("INFO", "red_proxy_leg_arrived", {
      packetId = packet.packetId,
      currentLegIndex = packet.currentLegIndex,
      nodeId = nextNodeId,
      finalDestinationNodeId = packet.finalDestinationNodeId,
      representationState = packet.representationState,
      survivorCount = packet.survivorCount,
    })

    if nextNodeId == packet.finalDestinationNodeId then
      if packet.representationState == "LEADER_PROXY" then
        local ok, reason = forceUnpackInternal(packet, "destination", false)
        if not ok then
          error(reason)
        end
      elseif packet.representationState == "PHYSICAL" then
        synchronizePhysicalSurvivors(packet)
        if packet.survivorCount < 1 then
          error("physical group reached destination without survivors")
        end
        packet.representationState = "PHYSICAL_GARRISON"
      else
        error("unsupported destination representation state " .. tostring(packet.representationState))
      end
      creditArrival(packet)
      return
    end

    packet.currentLegIndex = packet.currentLegIndex + 1
    local group = activeGroup(packet)
    if not group then
      error("packet has no active representation after intermediate arrival")
    end
    assignCurrentLeg(packet, group, packet.representationState)
  end

  local function reconcilePacket(packet)
    if packet.movementState ~= "EN_ROUTE" then
      return
    end
    local group = activeGroup(packet)
    if not group then
      error("active packet lacks physical representation: " .. packet.packetId)
    end
    if group:IsAlive() ~= true then
      if packet.representationState == "LEADER_PROXY" then
        state.totalLosses = state.totalLosses + packet.survivorCount
        packet.survivorCount = 0
      else
        synchronizePhysicalSurvivors(packet)
      end
      packet.movementState = "DESTROYED"
      packet.representationState = "NONE"
      state.activePacketCount = math.max(0, state.activePacketCount - 1)
      releaseLaunchSlot(packet)
      removeMarker(packet)
      log("INFO", "red_proxy_packet_destroyed", {
        packetId = packet.packetId,
        activePacketCount = state.activePacketCount,
        totalLosses = state.totalLosses,
      })
      return
    end
    if packet.representationState == "PHYSICAL" then
      synchronizePhysicalSurvivors(packet)
      if packet.survivorCount < 1 then
        packet.movementState = "DESTROYED"
        packet.representationState = "NONE"
        state.activePacketCount = math.max(0, state.activePacketCount - 1)
        releaseLaunchSlot(packet)
        removeMarker(packet)
        return
      end
    end

    updateCurrentCoordinate(packet)
    updateMarker(packet)
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = state.nodeById[nextNodeId]
    local destinationZone = nextNode and ZONE:FindByName(nextNode.zoneName) or nil
    if not destinationZone then
      error("next destination zone unavailable for " .. packet.packetId)
    end
    if group:IsCompletelyInZone(destinationZone) == true then
      arriveAtCurrentLegDestination(packet)
    end
  end

  local function activeAtDepth(depth)
    for _, packet in ipairs(state.packets) do
      if packet.targetDepth == depth
        and (packet.movementState == "SPAWNING" or packet.movementState == "EN_ROUTE") then
        return true
      end
    end
    return false
  end

  local function depthAtTarget(depth)
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      if node.depth == depth then
        if node.currentGarrison ~= node.targetStrength or inboundForNode(node.nodeId) > 0 then
          return false
        end
      end
    end
    return true
  end

  local function advanceDispatchDepth()
    while state.currentDispatchDepth <= state.maximumDispatchDepth
      and depthAtTarget(state.currentDispatchDepth)
      and not activeAtDepth(state.currentDispatchDepth) do
      local previous = state.currentDispatchDepth
      state.currentDispatchDepth = state.currentDispatchDepth + 1
      log("INFO", "red_proxy_fill_level_advanced", {
        previousDepth = previous,
        currentDispatchDepth = state.currentDispatchDepth,
      })
    end
  end

  local function nextDeficitNode()
    for _, definition in ipairs(config.shelters) do
      local node = state.nodeById[definition.nodeId]
      if node.depth == state.currentDispatchDepth then
        local deficit = node.targetStrength - node.currentGarrison - inboundForNode(node.nodeId)
        if deficit > 0 then
          return node, deficit
        end
      end
    end
    return nil, 0
  end

  local function acquireLaunchSlot()
    for index = 1, config.movement.maxActivePackets do
      if not state.launchSlotInUse[index] then
        state.launchSlotInUse[index] = true
        return index
      end
    end
    return nil
  end

  local function createPacket(destination, strength, launchSlotIndex)
    local sequence = state.nextPacketSequence
    state.nextPacketSequence = sequence + 1
    local suffix = string.format("%03d", sequence)
    local packet = {
      packetId = "TEST.TM02.VIRTUAL.PACKET." .. suffix,
      runtimeAliasSuffix = suffix,
      strength = strength,
      survivorCount = strength,
      routeNodeIds = buildRouteToNode(destination.nodeId),
      currentLegIndex = 1,
      finalDestinationNodeId = destination.nodeId,
      targetDepth = destination.depth,
      markerId = config.debug.markerIdBase + sequence,
      launchSlotIndex = launchSlotIndex,
      movementState = "IDLE",
      representationState = "NONE",
      proxyGroup = nil,
      proxyGroupName = nil,
      physicalGroup = nil,
      physicalGroupName = nil,
      arrivalCredited = false,
      currentCoordinate = nil,
      lastUpdateMissionTime = nil,
      runtimeGeneration = 0,
    }
    state.packets[#state.packets + 1] = packet
    state.packetById[packet.packetId] = packet
    log("INFO", "red_proxy_packet_generated", {
      packetId = packet.packetId,
      strength = packet.strength,
      destinationNodeId = packet.finalDestinationNodeId,
      targetDepth = packet.targetDepth,
      routeNodeIds = join(packet.routeNodeIds, ">"),
      launchSlotIndex = packet.launchSlotIndex,
    })
    if installPacketMenu then
      installPacketMenu(packet)
    end
    return packet
  end

  local function dispatchPacket(packet)
    local hq = state.nodeById[config.headquarters.nodeId]
    local sourceZone = ZONE:FindByName(config.headquarters.zoneName)
    if not sourceZone then
      error("HQ source zone unavailable")
    end
    if hq.currentGarrison < packet.strength then
      error("HQ lacks personnel for " .. packet.packetId)
    end

    hq.currentGarrison = hq.currentGarrison - packet.strength
    packet.movementState = "SPAWNING"
    packet.representationState = "SPAWNING_PROXY"
    local templateName = config.templatesByStrength[packet.strength]
    local alias = nextAlias(packet, config.proxy.runtimeAliasPrefix, true)
    local spawnOk, proxyOrError = pcall(function()
      local group = SPAWN:NewWithAlias(templateName, alias):SpawnInZone(sourceZone, false)
      if not group then
        error("initial proxy spawn returned nil")
      end
      if group:CountAliveUnits() ~= config.proxy.expectedUnitCount then
        safeDestroy(group)
        error("initial proxy did not contain exactly one unit")
      end
      assignCurrentLeg(packet, group, "LEADER_PROXY")
      return group
    end)
    if not spawnOk then
      hq.currentGarrison = hq.currentGarrison + packet.strength
      packet.movementState = "FAILED"
      packet.representationState = "NONE"
      releaseLaunchSlot(packet)
      error(proxyOrError)
    end

    packet.proxyGroup = proxyOrError
    packet.proxyGroupName = proxyOrError:GetName()
    packet.movementState = "EN_ROUTE"
    packet.representationState = "LEADER_PROXY"
    state.activePacketCount = state.activePacketCount + 1
    updateCurrentCoordinate(packet)
    updateMarker(packet)
    log("INFO", "red_proxy_packet_started", {
      packetId = packet.packetId,
      strength = packet.strength,
      routeNodeIds = join(packet.routeNodeIds, ">"),
      finalDestinationNodeId = packet.finalDestinationNodeId,
      proxyGroupName = packet.proxyGroupName,
      launchSlotIndex = packet.launchSlotIndex,
      hqPersonnel = hq.currentGarrison,
      representationState = packet.representationState,
      movementState = packet.movementState,
      activePacketCount = state.activePacketCount,
    })
  end

  dispatchAvailablePackets = function()
    if state.failed or not state.started then
      return
    end
    advanceDispatchDepth()
    while state.activePacketCount < config.movement.maxActivePackets
      and state.currentDispatchDepth <= state.maximumDispatchDepth do
      local destination, deficit = nextDeficitNode()
      if not destination then
        break
      end
      local hq = state.nodeById[config.headquarters.nodeId]
      local strength = math.min(config.movement.packetMaxStrength, deficit, hq.currentGarrison)
      if strength < 1 then
        if not state.blocked then
          state.blocked = true
          log("INFO", "red_proxy_fill_blocked", {
            reason = "insufficient HQ stock",
            hqPersonnel = hq.currentGarrison,
            remainingDeficit = inventorySnapshot().totalDeficit,
          })
          announce("TM02V fill blocked: insufficient HQ personnel")
        end
        break
      end
      local slot = acquireLaunchSlot()
      if not slot then
        break
      end
      local packet = createPacket(destination, strength, slot)
      local ok, dispatchError = pcall(dispatchPacket, packet)
      if not ok then
        fail(dispatchError, "red_proxy_dispatch_failed", packet)
        return
      end
      state.blocked = false
      advanceDispatchDepth()
    end
  end

  evaluateCompletion = function()
    if state.failed then
      return false
    end
    local snapshot = inventorySnapshot()
    if snapshot.allSheltersAtTarget
      and snapshot.activePacketCount == 0
      and snapshot.accountingValid then
      state.completed = true
      state.monitorActive = false
      state.monitorGeneration = state.monitorGeneration + 1
      snapshot.networkComplete = true
      log("INFO", "red_proxy_network_completed", {
        generatedPacketCount = snapshot.generatedPacketCount,
        arrivedPacketCount = snapshot.arrivedPacketCount,
        destroyedPacketCount = snapshot.destroyedPacketCount,
        hqPersonnel = snapshot.hqPersonnel,
        shelterPersonnel = snapshot.shelterPersonnel,
        inTransitPersonnel = snapshot.inTransitPersonnel,
        totalLosses = snapshot.totalLosses,
        totalDeficit = snapshot.totalDeficit,
        accountedPersonnel = snapshot.accountedPersonnel,
        accountingValid = snapshot.accountingValid,
        allSheltersAtTarget = snapshot.allSheltersAtTarget,
        networkComplete = true,
      })
      announce("TM02V complete: all six shelters are physically occupied at target strength")
      return true
    end
    return false
  end

  local function monitorTick()
    if state.monitorActive ~= true or state.failed then
      return false
    end
    for _, packet in ipairs(state.packets) do
      local ok, packetError = pcall(reconcilePacket, packet)
      if not ok then
        fail(packetError, "red_proxy_monitor_failed", packet)
        return false
      end
    end
    dispatchAvailablePackets()
    evaluateCompletion()
    return state.monitorActive == true
  end

  local function startMonitor()
    state.monitorGeneration = state.monitorGeneration + 1
    local generation = state.monitorGeneration
    state.monitorActive = true
    log("INFO", "red_proxy_monitor_started", {
      maxActivePackets = config.movement.maxActivePackets,
      initialDelaySeconds = config.movement.monitorInitialDelaySeconds,
      intervalSeconds = config.movement.monitorIntervalSeconds,
    })
    timer.scheduleFunction(function(_, scheduledTime)
      if state.monitorActive ~= true or state.monitorGeneration ~= generation then
        return nil
      end
      local ok, continueOrError = pcall(monitorTick)
      if not ok then
        fail(continueOrError, "red_proxy_monitor_failed")
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
      announce("TM02V start rejected: already started")
      return false
    end
    if state.failed then
      announce("TM02V start rejected: bootstrap failed")
      return false
    end
    state.started = true
    startMonitor()
    dispatchAvailablePackets()
    local snapshot = inventorySnapshot()
    log("INFO", "red_proxy_automatic_fill_started", {
      generatedPacketCount = snapshot.generatedPacketCount,
      activePacketCount = snapshot.activePacketCount,
      currentDispatchDepth = snapshot.currentDispatchDepth,
      hqPersonnel = snapshot.hqPersonnel,
      shelterPersonnel = snapshot.shelterPersonnel,
      inTransitPersonnel = snapshot.inTransitPersonnel,
      totalDeficit = snapshot.totalDeficit,
      accountedPersonnel = snapshot.accountedPersonnel,
      accountingValid = snapshot.accountingValid,
    })
    announce("TM02V automatic fill started: dynamic packets will continue until all six shelters are full")
    return not state.failed
  end

  local function toggleMarkers()
    state.markersEnabled = not state.markersEnabled
    if state.markersEnabled then
      updateAllMarkers()
    else
      for _, packet in ipairs(state.packets) do
        removeMarker(packet)
      end
    end
    log("INFO", "red_proxy_markers_toggled", { enabled = state.markersEnabled })
    announce("TM02V packet markers enabled: " .. tostring(state.markersEnabled))
    return state.markersEnabled
  end

  local function validateAndReport()
    local configValid, configErrors = validateConfiguration()
    local objectsValid, missingObjects = validateMissionObjects()
    log("INFO", "red_proxy_validation", {
      configurationValid = configValid,
      missionObjectsValid = objectsValid,
      configurationErrors = #configErrors == 0 and "none" or join(configErrors, " | "),
      missingObjects = #missingObjects == 0 and "none" or join(missingObjects, ","),
      checkedStrengthTemplateCount = 10,
      checkedNodeCount = 1 + #config.shelters,
      dynamicPacketGeneration = true,
      maxActivePackets = config.movement.maxActivePackets,
      launchSlotCount = #config.proxy.launchSlots,
      initialDeficit = totalInitialDeficit(),
    })
    announce(table.concat({
      "TM02V validation",
      "Configuration: " .. tostring(configValid),
      "Mission objects: " .. tostring(objectsValid),
      "Dynamic packet generation: true",
      "Initial shelter deficit: " .. tostring(totalInitialDeficit()),
      "Missing: " .. (#missingObjects == 0 and "none" or join(missingObjects, ", ")),
    }, "\n"))
    return configValid and objectsValid
  end

  local registryOk, registryError = pcall(buildNodeRegistry)
  if not registryOk then
    fail(registryError, "red_proxy_registry_failed")
    return state
  end

  local ready = validateAndReport()
  if not ready then
    fail("configuration or Mission Editor validation failed", "red_proxy_bootstrap_failed")
    return state
  end

  if config.debug.enableF10Menu == true then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM02V Dynamic Proxy Fill", root)
    state.menu = { root = root, menu = menu, packetMenus = {} }
    MENU_MISSION_COMMAND:New("Validate test", menu, validateAndReport)
    MENU_MISSION_COMMAND:New("Start automatic proxy fill", menu, startAutomaticFill)
    MENU_MISSION_COMMAND:New("Show network and packet status", menu, showAllStatus)
    MENU_MISSION_COMMAND:New("Toggle packet markers", menu, toggleMarkers)

    installPacketMenu = function(packet)
      if state.menu.packetMenus[packet.packetId] then
        return
      end
      local packetId = packet.packetId
      local packetMenu = MENU_MISSION:New(
        "Packet " .. packet.runtimeAliasSuffix .. " -> " .. packet.finalDestinationNodeId,
        menu
      )
      state.menu.packetMenus[packet.packetId] = packetMenu
      MENU_MISSION_COMMAND:New("Show status", packetMenu, function()
        return showPacketStatus(packetId)
      end)
      MENU_MISSION_COMMAND:New("Force unpack", packetMenu, function()
        return forceUnpack(packetId)
      end)
      MENU_MISSION_COMMAND:New("Force pack", packetMenu, function()
        return forcePack(packetId)
      end)
    end
  end

  log("INFO", "startup", {
    buildTimestamp = build and build.buildTimestamp or "source",
    configurationVersion = config.configurationVersion,
    dynamicPacketGeneration = true,
    configuredMovementCount = 0,
    initialPersonnel = state.initialPersonnel,
    initialHqPersonnel = state.nodeById[config.headquarters.nodeId].currentGarrison,
    initialShelterDeficit = totalInitialDeficit(),
    maximumDispatchDepth = state.maximumDispatchDepth,
    maxActivePackets = config.movement.maxActivePackets,
    launchSlotCount = #config.proxy.launchSlots,
  })
  announce("TM02V READY: dynamic top-down proxy fill for all six shelters")

  state.startAutomaticFill = startAutomaticFill
  state.forceUnpack = forceUnpack
  state.forcePack = forcePack
  state.showPacketStatus = showPacketStatus
  state.showAllStatus = showAllStatus
  state.toggleMarkers = toggleMarkers
  state.validateAndReport = validateAndReport
  state.inventorySnapshot = inventorySnapshot
  state.monitorTick = monitorTick
  state.dispatchAvailablePackets = dispatchAvailablePackets
  return state
end

return TM02V
