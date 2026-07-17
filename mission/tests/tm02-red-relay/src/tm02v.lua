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
    monitorActive = false,
    monitorGeneration = 0,
    markersEnabled = config.debug.markersEnabledOnStart == true,
    activePacketCount = 0,
    totalLosses = config.recordedLosses,
    initialPersonnel = 0,
    nodeById = {},
    packets = {},
    packetById = {},
  }

  local function fail(reason, event, packet)
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
      zoneName = config.headquarters.zoneName,
      targetStrength = nil,
      currentGarrison = config.headquarters.initialPersonnel,
      depth = 0,
    }
    state.nodeById[hq.nodeId] = hq
    state.initialPersonnel = hq.currentGarrison + state.totalLosses

    for _, definition in ipairs(config.shelters) do
      if state.nodeById[definition.nodeId] then
        error("duplicate nodeId: " .. definition.nodeId)
      end
      state.nodeById[definition.nodeId] = {
        nodeId = definition.nodeId,
        label = definition.label,
        parentNodeId = definition.parentNodeId,
        zoneName = definition.zoneName,
        targetStrength = definition.targetStrength,
        currentGarrison = definition.initialGarrison,
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
            unresolved = unresolved - 1
            progress = true
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

  local function buildPacketRegistry()
    for index, definition in ipairs(config.movements or {}) do
      if state.packetById[definition.packetId] then
        error("duplicate packetId: " .. tostring(definition.packetId))
      end
      local packet = {
        packetId = definition.packetId,
        runtimeAliasSuffix = definition.runtimeAliasSuffix or string.format("%03d", index),
        strength = definition.strength,
        survivorCount = definition.strength,
        routeNodeIds = definition.routeNodeIds,
        currentLegIndex = 1,
        finalDestinationNodeId = definition.finalDestinationNodeId,
        markerId = definition.markerId,
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
    end
  end

  local function validateConfiguration()
    local errors = {}
    if state.initialPersonnel ~= 100 then
      errors[#errors + 1] = "TM02V authoritative initial personnel must equal 100"
    end
    if #config.shelters ~= 6 then
      errors[#errors + 1] = "TM02V requires the six-shelter TM02 tree"
    end
    if #state.packets < 2 then
      errors[#errors + 1] = "TM02V multi-proxy acceptance requires at least two packets"
    end
    if config.movement.maxActivePackets < #state.packets then
      errors[#errors + 1] = "maxActivePackets must permit all configured packets"
    end

    for strength = 1, 10 do
      if type(config.templatesByStrength[strength]) ~= "string"
        or config.templatesByStrength[strength] == "" then
        errors[#errors + 1] = "missing physical template for strength " .. strength
      end
    end

    local totalMovementPersonnel = 0
    local inboundByDestination = {}
    local markerIds = {}
    local suffixes = {}
    for _, packet in ipairs(state.packets) do
      if type(packet.strength) ~= "number"
        or packet.strength % 1 ~= 0
        or packet.strength < 1
        or packet.strength > 10 then
        errors[#errors + 1] = packet.packetId .. " strength must be an integer from 1 to 10"
      else
        totalMovementPersonnel = totalMovementPersonnel + packet.strength
      end
      if type(packet.routeNodeIds) ~= "table" or #packet.routeNodeIds < 2 then
        errors[#errors + 1] = packet.packetId .. " route requires at least two nodes"
      elseif packet.routeNodeIds[1] ~= config.headquarters.nodeId then
        errors[#errors + 1] = packet.packetId .. " route must originate at HQ"
      elseif packet.routeNodeIds[#packet.routeNodeIds] ~= packet.finalDestinationNodeId then
        errors[#errors + 1] = packet.packetId .. " final destination must equal final route node"
      end
      for routeIndex = 2, #(packet.routeNodeIds or {}) do
        local child = state.nodeById[packet.routeNodeIds[routeIndex]]
        if not child then
          errors[#errors + 1] = packet.packetId .. " route references missing node " .. tostring(packet.routeNodeIds[routeIndex])
        elseif child.parentNodeId ~= packet.routeNodeIds[routeIndex - 1] then
          errors[#errors + 1] = packet.packetId .. " route skips parent-child edge at " .. child.nodeId
        end
      end
      local destination = state.nodeById[packet.finalDestinationNodeId]
      if not destination or not destination.targetStrength then
        errors[#errors + 1] = packet.packetId .. " final destination must be a shelter"
      else
        inboundByDestination[destination.nodeId] = (inboundByDestination[destination.nodeId] or 0) + packet.strength
      end
      if type(packet.markerId) ~= "number" or markerIds[packet.markerId] then
        errors[#errors + 1] = packet.packetId .. " markerId must be unique"
      else
        markerIds[packet.markerId] = true
      end
      if type(packet.runtimeAliasSuffix) ~= "string" or suffixes[packet.runtimeAliasSuffix] then
        errors[#errors + 1] = packet.packetId .. " runtimeAliasSuffix must be unique"
      else
        suffixes[packet.runtimeAliasSuffix] = true
      end
    end

    for nodeId, inbound in pairs(inboundByDestination) do
      local node = state.nodeById[nodeId]
      local deficit = node.targetStrength - node.currentGarrison
      if inbound ~= deficit then
        errors[#errors + 1] = nodeId .. " configured inbound " .. inbound .. " must equal deficit " .. deficit
      end
    end
    if state.nodeById[config.headquarters.nodeId].currentGarrison < totalMovementPersonnel then
      errors[#errors + 1] = "HQ lacks configured movement personnel"
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

  local function packetPersonnelInTransit(packet)
    if packet.movementState == "SPAWNING" or packet.movementState == "EN_ROUTE" then
      return packet.survivorCount
    end
    return 0
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
      arrivedPacketCount = arrivedPacketCount,
      destroyedPacketCount = destroyedPacketCount,
      failedPacketCount = failedPacketCount,
      allSheltersAtTarget = totalDeficit == 0,
      networkComplete = state.completed,
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
      return
    end
    updateCurrentCoordinate(packet)
    updateMarker(packet)
    logPacketStatus(packet, "manual")
    announce(table.concat({
      packet.packetId,
      "Movement: " .. packet.movementState,
      "Representation: " .. packet.representationState,
      "Strength: " .. packet.survivorCount .. " / " .. packet.strength,
      "Leg: " .. packet.currentLegIndex .. " / " .. (#packet.routeNodeIds - 1),
      "Route: " .. join(packet.routeNodeIds, " > "),
      "Proxy: " .. tostring(packet.proxyGroupName or "none"),
      "Physical: " .. tostring(packet.physicalGroupName or "none"),
    }, "\n"))
  end

  local function showAllStatus()
    updateAllMarkers()
    local snapshot = inventorySnapshot()
    local lines = { "TM02V MULTI-PROXY STATUS" }
    for _, packet in ipairs(state.packets) do
      lines[#lines + 1] = packet.runtimeAliasSuffix
        .. " | " .. packet.movementState
        .. " | " .. packet.representationState
        .. " | " .. packet.survivorCount .. "/" .. packet.strength
        .. " | " .. join(packet.routeNodeIds, ">")
      logPacketStatus(packet, "all-status")
    end
    lines[#lines + 1] = "Active packets: " .. snapshot.activePacketCount
    lines[#lines + 1] = "HQ: " .. snapshot.hqPersonnel
    lines[#lines + 1] = "Shelters: " .. snapshot.shelterPersonnel
    lines[#lines + 1] = "In transit: " .. snapshot.inTransitPersonnel
    lines[#lines + 1] = "Losses: " .. snapshot.totalLosses
    lines[#lines + 1] = "Accounted: " .. snapshot.accountedPersonnel .. " / " .. snapshot.initialPersonnel
    lines[#lines + 1] = "Accounting valid: " .. tostring(snapshot.accountingValid)
    announce(table.concat(lines, "\n"))
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

  local function nextAlias(packet, prefixValue)
    packet.runtimeGeneration = packet.runtimeGeneration + 1
    return prefixValue
      .. packet.runtimeAliasSuffix
      .. "_G"
      .. string.format("%03d", packet.runtimeGeneration)
  end

  local function spawnProxyAtCoordinate(packet, coordinate, continueMovement)
    local templateName = config.templatesByStrength[packet.survivorCount]
    if not templateName then
      error("no proxy source template for survivor count " .. tostring(packet.survivorCount))
    end
    local alias = nextAlias(packet, config.proxy.runtimeAliasPrefix)
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
    local alias = nextAlias(packet, config.physical.runtimeAliasPrefix)
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
      movementState = packet.movementState,
      representationState = packet.representationState,
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

  local function creditArrival(packet)
    if packet.arrivalCredited then
      error("duplicate arrival credit for " .. packet.packetId)
    end
    local destination = state.nodeById[packet.finalDestinationNodeId]
    if destination.currentGarrison + packet.survivorCount > destination.targetStrength then
      error("arrival would overfill destination for " .. packet.packetId)
    end
    destination.currentGarrison = destination.currentGarrison + packet.survivorCount
    packet.arrivalCredited = true
    packet.movementState = "ARRIVED"
    packet.representationState = "PHYSICAL_GARRISON"
    state.activePacketCount = math.max(0, state.activePacketCount - 1)
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

  local function evaluateCompletion()
    if state.failed then
      return false
    end
    for _, packet in ipairs(state.packets) do
      if packet.movementState ~= "ARRIVED" then
        return false
      end
    end
    local snapshot = inventorySnapshot()
    state.completed = snapshot.accountingValid and snapshot.allSheltersAtTarget
    if state.completed then
      state.monitorActive = false
      state.monitorGeneration = state.monitorGeneration + 1
      log("INFO", "red_proxy_network_completed", {
        packetCount = #state.packets,
        arrivedPacketCount = snapshot.arrivedPacketCount,
        hqPersonnel = snapshot.hqPersonnel,
        shelterPersonnel = snapshot.shelterPersonnel,
        inTransitPersonnel = snapshot.inTransitPersonnel,
        totalLosses = snapshot.totalLosses,
        accountedPersonnel = snapshot.accountedPersonnel,
        accountingValid = snapshot.accountingValid,
        allSheltersAtTarget = snapshot.allSheltersAtTarget,
        networkComplete = true,
      })
      announce("TM02V complete: all three packets materialized at their own destinations")
    end
    return state.completed
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
    evaluateCompletion()
    return state.monitorActive == true
  end

  local function startMonitor()
    state.monitorGeneration = state.monitorGeneration + 1
    local generation = state.monitorGeneration
    state.monitorActive = true
    log("INFO", "red_proxy_monitor_started", {
      packetCount = #state.packets,
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

  local function rollbackStart(reservedPackets)
    local hq = state.nodeById[config.headquarters.nodeId]
    for _, packet in ipairs(reservedPackets) do
      safeDestroy(packet.proxyGroup)
      packet.proxyGroup = nil
      packet.proxyGroupName = nil
      packet.movementState = "IDLE"
      packet.representationState = "NONE"
      packet.currentCoordinate = nil
      hq.currentGarrison = hq.currentGarrison + packet.strength
    end
    state.activePacketCount = 0
  end

  local function startAllMovements()
    if state.started then
      announce("TM02V start rejected: already started")
      return false
    end
    if state.failed then
      announce("TM02V start rejected: bootstrap failed")
      return false
    end

    local hq = state.nodeById[config.headquarters.nodeId]
    local sourceZone = ZONE:FindByName(config.headquarters.zoneName)
    if not sourceZone then
      fail("HQ source zone unavailable", "red_proxy_start_failed")
      return false
    end

    local totalRequired = 0
    for _, packet in ipairs(state.packets) do
      totalRequired = totalRequired + packet.strength
    end
    if hq.currentGarrison < totalRequired then
      fail("HQ lacks movement personnel", "red_proxy_start_failed")
      return false
    end

    local reservedPackets = {}
    for _, packet in ipairs(state.packets) do
      hq.currentGarrison = hq.currentGarrison - packet.strength
      reservedPackets[#reservedPackets + 1] = packet
      packet.movementState = "SPAWNING"
      packet.representationState = "SPAWNING_PROXY"

      local templateName = config.templatesByStrength[packet.strength]
      local alias = nextAlias(packet, config.proxy.runtimeAliasPrefix)
      local spawnOk, proxyOrError = pcall(function()
        local group = SPAWN:NewWithAlias(templateName, alias):SpawnInZone(sourceZone, false)
        if not group then
          error("initial proxy spawn returned nil")
        end
        if group:CountAliveUnits() ~= 1 then
          safeDestroy(group)
          error("initial proxy did not contain exactly one unit")
        end
        assignCurrentLeg(packet, group, "LEADER_PROXY")
        return group
      end)
      if not spawnOk then
        rollbackStart(reservedPackets)
        fail(proxyOrError, "red_proxy_start_failed", packet)
        return false
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
        proxyGroupName = packet.proxyGroupName,
        hqPersonnel = hq.currentGarrison,
        representationState = packet.representationState,
        movementState = packet.movementState,
        activePacketCount = state.activePacketCount,
      })
    end

    state.started = true
    startMonitor()
    local snapshot = inventorySnapshot()
    log("INFO", "red_proxy_movements_started", {
      packetCount = #state.packets,
      activePacketCount = state.activePacketCount,
      hqPersonnel = snapshot.hqPersonnel,
      inTransitPersonnel = snapshot.inTransitPersonnel,
      accountedPersonnel = snapshot.accountedPersonnel,
      accountingValid = snapshot.accountingValid,
    })
    announce("TM02V started: three independent packets, three independent leader proxies")
    return true
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
      checkedPacketCount = #state.packets,
      checkedNodeCount = 1 + #config.shelters,
    })
    announce(table.concat({
      "TM02V validation",
      "Configuration: " .. tostring(configValid),
      "Mission objects: " .. tostring(objectsValid),
      "Packets: " .. tostring(#state.packets),
      "Missing: " .. (#missingObjects == 0 and "none" or join(missingObjects, ", ")),
    }, "\n"))
    return configValid and objectsValid
  end

  local registryOk, registryError = pcall(function()
    buildNodeRegistry()
    buildPacketRegistry()
  end)
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
    local menu = MENU_MISSION:New("TM02V Multi-Proxy Movement", root)
    MENU_MISSION_COMMAND:New("Validate test", menu, validateAndReport)
    MENU_MISSION_COMMAND:New("Start all proxy movements", menu, startAllMovements)
    MENU_MISSION_COMMAND:New("Show all packet status", menu, showAllStatus)
    MENU_MISSION_COMMAND:New("Toggle packet markers", menu, toggleMarkers)
    for _, packet in ipairs(state.packets) do
      local packetId = packet.packetId
      local packetMenu = MENU_MISSION:New(
        "Packet " .. packet.runtimeAliasSuffix .. " -> " .. packet.finalDestinationNodeId,
        menu
      )
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

  local packetIds = {}
  for _, packet in ipairs(state.packets) do
    packetIds[#packetIds + 1] = packet.packetId
  end
  log("INFO", "startup", {
    buildTimestamp = build and build.buildTimestamp or "source",
    configurationVersion = config.configurationVersion,
    packetCount = #state.packets,
    packetIds = join(packetIds, ","),
    initialPersonnel = state.initialPersonnel,
    initialRecordedLosses = state.totalLosses,
  })
  announce("TM02V READY: three independent packet proxies")

  state.startAllMovements = startAllMovements
  state.forceUnpack = forceUnpack
  state.forcePack = forcePack
  state.showPacketStatus = showPacketStatus
  state.showAllStatus = showAllStatus
  state.toggleMarkers = toggleMarkers
  state.validateAndReport = validateAndReport
  state.inventorySnapshot = inventorySnapshot
  state.monitorTick = monitorTick
  return state
end

return TM02V
