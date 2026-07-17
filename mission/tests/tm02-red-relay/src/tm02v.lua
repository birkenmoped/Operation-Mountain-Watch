local TM02V = {}

local TERMINAL_MOVEMENT_STATES = {
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
    markerEnabled = config.debug.markerEnabledOnStart == true,
    totalLosses = config.recordedLosses,
    initialPersonnel = 0,
    nodeById = {},
    packet = {
      packetId = config.movementId,
      strength = config.movement.strength,
      survivorCount = config.movement.strength,
      routeNodeIds = config.movement.routeNodeIds,
      currentLegIndex = 1,
      finalDestinationNodeId = config.movement.finalDestinationNodeId,
      movementState = "IDLE",
      representationState = "NONE",
      proxyGroup = nil,
      proxyGroupName = nil,
      physicalGroup = nil,
      physicalGroupName = nil,
      arrivalCredited = false,
      currentCoordinate = nil,
      lastUpdateMissionTime = nil,
    },
  }

  local function fail(reason, event)
    if state.failed then
      return
    end
    state.failed = true
    state.completed = false
    state.monitorActive = false
    state.monitorGeneration = state.monitorGeneration + 1
    state.packet.movementState = "FAILED"
    log("ERROR", event or "red_proxy_movement_failed", {
      missionTimeSeconds = timer.getTime(),
      reason = tostring(reason),
      packetId = state.packet.packetId,
      representationState = state.packet.representationState,
    })
    announce("TM02V failed: " .. tostring(reason))
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

  local function validateConfiguration()
    local errors = {}
    local packet = state.packet
    if state.initialPersonnel ~= 100 then
      errors[#errors + 1] = "TM02V authoritative initial personnel must equal 100"
    end
    if type(packet.strength) ~= "number" or packet.strength % 1 ~= 0 or packet.strength < 1 or packet.strength > 10 then
      errors[#errors + 1] = "movement strength must be an integer from 1 to 10"
    end
    if config.proxy.expectedUnitCount ~= 1 then
      errors[#errors + 1] = "proxy expected unit count must equal 1"
    end
    if #config.shelters ~= 6 then
      errors[#errors + 1] = "TM02V requires the six-shelter TM02 tree"
    end
    if #packet.routeNodeIds < 2 then
      errors[#errors + 1] = "movement route requires at least two nodes"
    elseif packet.routeNodeIds[1] ~= config.headquarters.nodeId then
      errors[#errors + 1] = "movement route must originate at HQ"
    elseif packet.routeNodeIds[#packet.routeNodeIds] ~= packet.finalDestinationNodeId then
      errors[#errors + 1] = "final destination must equal the final route node"
    end

    for index = 2, #packet.routeNodeIds do
      local child = state.nodeById[packet.routeNodeIds[index]]
      if not child then
        errors[#errors + 1] = "route references missing node " .. tostring(packet.routeNodeIds[index])
      elseif child.parentNodeId ~= packet.routeNodeIds[index - 1] then
        errors[#errors + 1] = "route skips parent-child edge at " .. child.nodeId
      end
    end

    local destination = state.nodeById[packet.finalDestinationNodeId]
    if not destination or not destination.targetStrength then
      errors[#errors + 1] = "final destination must be a shelter"
    elseif destination.targetStrength - destination.currentGarrison ~= packet.strength then
      errors[#errors + 1] = "final destination deficit must exactly equal movement strength"
    end
    if state.nodeById[config.headquarters.nodeId].currentGarrison < packet.strength then
      errors[#errors + 1] = "HQ lacks movement personnel"
    end
    for strength = 1, 10 do
      if type(config.templatesByStrength[strength]) ~= "string" or config.templatesByStrength[strength] == "" then
        errors[#errors + 1] = "missing physical template for strength " .. strength
      end
    end
    if type(config.proxy.templateGroupName) ~= "string" or config.proxy.templateGroupName == "" then
      errors[#errors + 1] = "missing proxy template"
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
    if not GROUP:FindByName(config.proxy.templateGroupName) then
      missing[#missing + 1] = config.proxy.templateGroupName
    end
    for _, node in pairs(state.nodeById) do
      if not ZONE:FindByName(node.zoneName) then
        missing[#missing + 1] = node.zoneName
      end
    end
    return #missing == 0, missing
  end

  local function packetPersonnelInTransit()
    local packet = state.packet
    if packet.movementState == "EN_ROUTE" then
      return packet.survivorCount
    end
    return 0
  end

  local function inventorySnapshot()
    local hq = state.nodeById[config.headquarters.nodeId]
    local shelterPersonnel = 0
    for _, definition in ipairs(config.shelters) do
      shelterPersonnel = shelterPersonnel + state.nodeById[definition.nodeId].currentGarrison
    end
    local inTransitPersonnel = packetPersonnelInTransit()
    local accountedPersonnel = hq.currentGarrison + shelterPersonnel + inTransitPersonnel + state.totalLosses
    local destination = state.nodeById[state.packet.finalDestinationNodeId]
    return {
      hqPersonnel = hq.currentGarrison,
      shelterPersonnel = shelterPersonnel,
      inTransitPersonnel = inTransitPersonnel,
      totalLosses = state.totalLosses,
      accountedPersonnel = accountedPersonnel,
      initialPersonnel = state.initialPersonnel,
      accountingValid = accountedPersonnel == state.initialPersonnel,
      destinationGarrison = destination.currentGarrison,
      destinationTargetStrength = destination.targetStrength,
      destinationAtTarget = destination.currentGarrison == destination.targetStrength,
      movementState = state.packet.movementState,
      representationState = state.packet.representationState,
      survivorCount = state.packet.survivorCount,
      arrivalCredited = state.packet.arrivalCredited,
      networkComplete = state.completed,
    }
  end

  local function activeGroup()
    local packet = state.packet
    if packet.representationState == "PROXY" then
      return packet.proxyGroup
    end
    if packet.representationState == "PHYSICAL" or packet.representationState == "PHYSICAL_GARRISON" then
      return packet.physicalGroup
    end
    return nil
  end

  local function updateCurrentCoordinate()
    local group = activeGroup()
    if not group then
      return nil
    end
    local coordinate = group:GetCoordinate()
    if not coordinate then
      return nil
    end
    local vec3 = coordinate:GetVec3()
    state.packet.currentCoordinate = vec3
    state.packet.lastUpdateMissionTime = timer.getTime()
    return coordinate, vec3
  end

  local function markerText()
    local packet = state.packet
    local currentNodeId = packet.routeNodeIds[packet.currentLegIndex]
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = nextNodeId and state.nodeById[nextNodeId] or nil
    local nextCoordinate = nextNode and ZONE:FindByName(nextNode.zoneName):GetCoordinate():GetVec3() or nil
    local remaining = distance2D(packet.currentCoordinate, nextCoordinate)
    return table.concat({
      "TM02V " .. packet.packetId,
      packet.representationState .. " / " .. packet.movementState,
      "Strength: " .. packet.survivorCount,
      "Leg: " .. tostring(currentNodeId) .. " -> " .. tostring(nextNodeId or packet.finalDestinationNodeId),
      "Next node distance: " .. (remaining and string.format("%.0f m", remaining) or "n/a"),
    }, "\n")
  end

  local function removeMarker()
    if trigger.action.removeMark then
      trigger.action.removeMark(config.debug.markerId)
    end
  end

  local function updateMarker()
    if state.markerEnabled ~= true then
      return
    end
    if not state.packet.currentCoordinate then
      return
    end
    removeMarker()
    trigger.action.markToAll(
      config.debug.markerId,
      markerText(),
      state.packet.currentCoordinate,
      true
    )
  end

  local function logStatus(reason)
    local packet = state.packet
    local snapshot = inventorySnapshot()
    local currentNodeId = packet.routeNodeIds[packet.currentLegIndex]
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    log("INFO", "red_proxy_movement_status", {
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
      hqPersonnel = snapshot.hqPersonnel,
      destinationGarrison = snapshot.destinationGarrison,
      inTransitPersonnel = snapshot.inTransitPersonnel,
      totalLosses = snapshot.totalLosses,
      accountedPersonnel = snapshot.accountedPersonnel,
      accountingValid = snapshot.accountingValid,
      arrivalCredited = packet.arrivalCredited,
    })
    return snapshot
  end

  local function showStatus()
    updateCurrentCoordinate()
    updateMarker()
    local snapshot = logStatus("manual")
    local packet = state.packet
    announce(table.concat({
      "TM02V PROXY MOVEMENT",
      "Movement: " .. packet.movementState,
      "Representation: " .. packet.representationState,
      "Strength: " .. packet.survivorCount .. " / " .. packet.strength,
      "Leg: " .. packet.currentLegIndex .. " / " .. (#packet.routeNodeIds - 1),
      "HQ: " .. snapshot.hqPersonnel,
      "Destination: " .. snapshot.destinationGarrison .. " / " .. snapshot.destinationTargetStrength,
      "In transit: " .. snapshot.inTransitPersonnel,
      "Accounted: " .. snapshot.accountedPersonnel .. " / " .. snapshot.initialPersonnel,
      "Accounting valid: " .. tostring(snapshot.accountingValid),
      "Marker enabled: " .. tostring(state.markerEnabled),
    }, "\n"))
  end

  local function buildLegWaypoints(group)
    local packet = state.packet
    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = state.nodeById[nextNodeId]
    if not nextNode then
      error("next route node unavailable")
    end
    local destinationZone = ZONE:FindByName(nextNode.zoneName)
    if not destinationZone then
      error("destination zone unavailable: " .. nextNode.zoneName)
    end
    local startCoordinate = group:GetCoordinate()
    local destinationCoordinate = destinationZone:GetCoordinate()
    if not startCoordinate or not destinationCoordinate then
      error("route coordinates unavailable")
    end
    return {
      startCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
      destinationCoordinate:WaypointGround(config.routing.speedKph, config.routing.formation),
    }, nextNode
  end

  local function assignCurrentLeg(group, representationState)
    local waypoints, nextNode = buildLegWaypoints(group)
    local assigned = group:Route(waypoints, config.routing.assignmentDelaySeconds)
    if not assigned then
      error("route assignment returned nil")
    end
    log("INFO", "red_proxy_leg_started", {
      packetId = state.packet.packetId,
      representationState = representationState,
      currentLegIndex = state.packet.currentLegIndex,
      sourceNodeId = state.packet.routeNodeIds[state.packet.currentLegIndex],
      destinationNodeId = nextNode.nodeId,
      finalDestinationNodeId = state.packet.finalDestinationNodeId,
      survivorCount = state.packet.survivorCount,
      runtimeGroupName = group:GetName(),
      waypointCount = #waypoints,
    })
  end

  local function safeDestroy(group)
    if group then
      pcall(function() group:Destroy() end)
    end
  end

  local function spawnProxyAtCoordinate(coordinate, continueMovement)
    local alias = config.proxy.runtimeAliasPrefix .. "001"
    local spawner = SPAWN:NewWithAlias(config.proxy.templateGroupName, alias)
    local group = spawner:SpawnFromCoordinate(coordinate)
    if not group then
      error("proxy spawn returned nil")
    end
    local count = group:CountAliveUnits()
    if count ~= config.proxy.expectedUnitCount then
      safeDestroy(group)
      error("proxy spawned with " .. tostring(count) .. " instead of 1")
    end
    if continueMovement then
      local routeOk, routeError = pcall(assignCurrentLeg, group, "PROXY")
      if not routeOk then
        safeDestroy(group)
        error(routeError)
      end
    end
    return group
  end

  local function spawnPhysicalAtCoordinate(coordinate, continueMovement)
    local strength = state.packet.survivorCount
    local templateName = config.templatesByStrength[strength]
    if not templateName then
      error("no physical template for survivor count " .. tostring(strength))
    end
    local alias = config.physical.runtimeAliasPrefix .. string.format("%02d_001", strength)
    local spawner = SPAWN:NewWithAlias(templateName, alias)
    local group = spawner:SpawnFromCoordinate(coordinate)
    if not group then
      error("physical spawn returned nil")
    end
    local count = group:CountAliveUnits()
    if count ~= strength then
      safeDestroy(group)
      error("physical group spawned with " .. tostring(count) .. " instead of " .. tostring(strength))
    end
    if continueMovement then
      local routeOk, routeError = pcall(assignCurrentLeg, group, "PHYSICAL")
      if not routeOk then
        safeDestroy(group)
        error(routeError)
      end
    end
    return group
  end

  local function forceUnpackInternal(reason, continueMovement)
    local packet = state.packet
    if packet.representationState ~= "PROXY" or not packet.proxyGroup then
      return false, "packet is not represented by a proxy"
    end
    local coordinate = packet.proxyGroup:GetCoordinate()
    if not coordinate then
      return false, "proxy coordinate unavailable"
    end
    packet.representationState = "UNPACKING"
    local ok, groupOrError = pcall(spawnPhysicalAtCoordinate, coordinate, continueMovement)
    if not ok then
      packet.representationState = "PROXY"
      return false, groupOrError
    end
    local physicalGroup = groupOrError
    local oldProxy = packet.proxyGroup
    packet.physicalGroup = physicalGroup
    packet.physicalGroupName = physicalGroup:GetName()
    packet.proxyGroup = nil
    packet.proxyGroupName = nil
    safeDestroy(oldProxy)
    packet.representationState = continueMovement and "PHYSICAL" or "PHYSICAL_GARRISON"
    updateCurrentCoordinate()
    updateMarker()
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

  local function forceUnpack()
    local packet = state.packet
    if packet.movementState ~= "EN_ROUTE" then
      announce("TM02V unpack rejected: movement is not en route")
      return false
    end
    local ok, reason = forceUnpackInternal("manual", true)
    if not ok then
      announce("TM02V unpack rejected: " .. tostring(reason))
      log("INFO", "red_proxy_unpack_rejected", { reason = tostring(reason) })
      return false
    end
    announce("TM02V unpacked: full group now physical")
    return true
  end

  local function synchronizePhysicalSurvivors()
    local packet = state.packet
    if not packet.physicalGroup then
      return
    end
    local observed = packet.physicalGroup:CountAliveUnits()
    if observed > packet.survivorCount then
      error("physical survivor count increased")
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

  local function forcePackInternal(reason)
    local packet = state.packet
    if packet.representationState ~= "PHYSICAL" or not packet.physicalGroup then
      return false, "packet is not an en-route physical group"
    end
    synchronizePhysicalSurvivors()
    if packet.survivorCount < 1 then
      packet.movementState = "DESTROYED"
      packet.representationState = "NONE"
      safeDestroy(packet.physicalGroup)
      packet.physicalGroup = nil
      packet.physicalGroupName = nil
      return false, "physical group has no survivors"
    end
    local coordinate = packet.physicalGroup:GetCoordinate()
    if not coordinate then
      return false, "physical group coordinate unavailable"
    end
    packet.representationState = "PACKING"
    local ok, groupOrError = pcall(spawnProxyAtCoordinate, coordinate, true)
    if not ok then
      packet.representationState = "PHYSICAL"
      return false, groupOrError
    end
    local proxyGroup = groupOrError
    local oldPhysical = packet.physicalGroup
    packet.proxyGroup = proxyGroup
    packet.proxyGroupName = proxyGroup:GetName()
    packet.physicalGroup = nil
    packet.physicalGroupName = nil
    safeDestroy(oldPhysical)
    packet.representationState = "PROXY"
    updateCurrentCoordinate()
    updateMarker()
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

  local function forcePack()
    if state.packet.movementState ~= "EN_ROUTE" then
      announce("TM02V pack rejected: movement is not en route")
      return false
    end
    local ok, reason = forcePackInternal("manual")
    if not ok then
      announce("TM02V pack rejected: " .. tostring(reason))
      log("INFO", "red_proxy_pack_rejected", { reason = tostring(reason) })
      return false
    end
    announce("TM02V packed: one proxy now carries the position")
    return true
  end

  local function creditArrival()
    local packet = state.packet
    if packet.arrivalCredited then
      error("duplicate arrival credit")
    end
    local destination = state.nodeById[packet.finalDestinationNodeId]
    if destination.currentGarrison + packet.survivorCount > destination.targetStrength then
      error("arrival would overfill destination")
    end
    destination.currentGarrison = destination.currentGarrison + packet.survivorCount
    packet.arrivalCredited = true
    packet.movementState = "ARRIVED"
    packet.representationState = "PHYSICAL_GARRISON"
    state.monitorActive = false
    state.monitorGeneration = state.monitorGeneration + 1
    local snapshot = inventorySnapshot()
    state.completed = snapshot.accountingValid and snapshot.destinationAtTarget
    updateCurrentCoordinate()
    updateMarker()
    log("INFO", "red_proxy_arrived", {
      packetId = packet.packetId,
      destinationNodeId = destination.nodeId,
      destinationGarrison = destination.currentGarrison,
      targetStrength = destination.targetStrength,
      survivorCount = packet.survivorCount,
      physicalGroupName = packet.physicalGroupName,
      representationState = packet.representationState,
      accountedPersonnel = snapshot.accountedPersonnel,
      accountingValid = snapshot.accountingValid,
      networkComplete = state.completed,
    })
    announce(
      state.completed
        and "TM02V complete: packet materialized visibly at AA"
        or "TM02V arrived with losses; destination remains below target"
    )
  end

  local function arriveAtCurrentLegDestination()
    local packet = state.packet
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
      if packet.representationState == "PROXY" then
        local ok, reason = forceUnpackInternal("destination", false)
        if not ok then
          error(reason)
        end
      elseif packet.representationState == "PHYSICAL" then
        synchronizePhysicalSurvivors()
        if packet.survivorCount < 1 then
          error("physical group reached destination without survivors")
        end
      else
        error("unsupported representation at destination: " .. packet.representationState)
      end
      creditArrival()
      return
    end

    packet.currentLegIndex = packet.currentLegIndex + 1
    local group = activeGroup()
    if not group then
      error("no active representation for next leg")
    end
    assignCurrentLeg(group, packet.representationState)
  end

  local function reconcileMovement()
    local packet = state.packet
    if packet.movementState ~= "EN_ROUTE" then
      return
    end

    local group = activeGroup()
    if not group then
      error("en-route packet has no active representation")
    end

    if packet.representationState == "PROXY" then
      if group:CountAliveUnits() ~= 1 then
        error("proxy representation is unavailable or destroyed")
      end
    elseif packet.representationState == "PHYSICAL" then
      synchronizePhysicalSurvivors()
      if packet.survivorCount < 1 then
        packet.movementState = "DESTROYED"
        packet.representationState = "NONE"
        safeDestroy(packet.physicalGroup)
        packet.physicalGroup = nil
        packet.physicalGroupName = nil
        state.monitorActive = false
        log("INFO", "red_proxy_packet_destroyed", {
          packetId = packet.packetId,
          totalLosses = state.totalLosses,
        })
        return
      end
    else
      error("invalid en-route representation: " .. tostring(packet.representationState))
    end

    updateCurrentCoordinate()
    updateMarker()

    local nextNodeId = packet.routeNodeIds[packet.currentLegIndex + 1]
    local nextNode = state.nodeById[nextNodeId]
    local zone = ZONE:FindByName(nextNode.zoneName)
    if group:IsCompletelyInZone(zone) == true then
      arriveAtCurrentLegDestination()
    end
  end

  local function monitorTick()
    reconcileMovement()
    local snapshot = inventorySnapshot()
    if snapshot.accountingValid ~= true then
      fail("personnel accounting mismatch", "red_proxy_accounting_failed")
      return false
    end
    if TERMINAL_MOVEMENT_STATES[state.packet.movementState] then
      state.monitorActive = false
      return false
    end
    return true
  end

  local function startMonitor()
    state.monitorGeneration = state.monitorGeneration + 1
    local generation = state.monitorGeneration
    state.monitorActive = true
    log("INFO", "red_proxy_monitor_started", {
      initialDelaySeconds = config.movement.monitorInitialDelaySeconds,
      intervalSeconds = config.movement.monitorIntervalSeconds,
    })
    timer.scheduleFunction(function(_, scheduledTime)
      if not state.monitorActive or generation ~= state.monitorGeneration then
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

  local function startProxyMovement()
    if state.started then
      announce("TM02V start rejected: already started")
      log("INFO", "red_proxy_start_rejected", { reason = "already started" })
      return false
    end
    if state.failed then
      announce("TM02V start rejected: bootstrap failed")
      return false
    end

    local packet = state.packet
    local hq = state.nodeById[config.headquarters.nodeId]
    if hq.currentGarrison < packet.strength then
      fail("HQ lacks movement personnel", "red_proxy_start_failed")
      return false
    end
    local sourceZone = ZONE:FindByName(config.headquarters.zoneName)
    if not sourceZone then
      fail("HQ source zone unavailable", "red_proxy_start_failed")
      return false
    end

    hq.currentGarrison = hq.currentGarrison - packet.strength
    packet.movementState = "SPAWNING"
    packet.representationState = "SPAWNING_PROXY"

    local alias = config.proxy.runtimeAliasPrefix .. "001"
    local spawner = SPAWN:NewWithAlias(config.proxy.templateGroupName, alias)
    local proxyGroup = spawner:SpawnInZone(sourceZone, false)
    if not proxyGroup then
      hq.currentGarrison = hq.currentGarrison + packet.strength
      fail("initial proxy spawn returned nil", "red_proxy_start_failed")
      return false
    end
    if proxyGroup:CountAliveUnits() ~= 1 then
      safeDestroy(proxyGroup)
      hq.currentGarrison = hq.currentGarrison + packet.strength
      fail("initial proxy did not contain exactly one unit", "red_proxy_start_failed")
      return false
    end

    packet.proxyGroup = proxyGroup
    packet.proxyGroupName = proxyGroup:GetName()
    packet.movementState = "EN_ROUTE"
    packet.representationState = "PROXY"
    local routeOk, routeError = pcall(assignCurrentLeg, proxyGroup, "PROXY")
    if not routeOk then
      safeDestroy(proxyGroup)
      packet.proxyGroup = nil
      packet.proxyGroupName = nil
      packet.movementState = "FAILED"
      packet.representationState = "NONE"
      hq.currentGarrison = hq.currentGarrison + packet.strength
      fail(routeError, "red_proxy_start_failed")
      return false
    end

    state.started = true
    updateCurrentCoordinate()
    updateMarker()
    log("INFO", "red_proxy_movement_started", {
      packetId = packet.packetId,
      strength = packet.strength,
      routeNodeIds = join(packet.routeNodeIds, ">"),
      proxyGroupName = packet.proxyGroupName,
      hqPersonnel = hq.currentGarrison,
      representationState = packet.representationState,
      movementState = packet.movementState,
    })
    startMonitor()
    logStatus("start")
    announce("TM02V started: six-person packet represented by one moving proxy")
    return true
  end

  local function toggleMarker()
    state.markerEnabled = not state.markerEnabled
    if state.markerEnabled then
      updateCurrentCoordinate()
      updateMarker()
    else
      removeMarker()
    end
    log("INFO", "red_proxy_marker_toggled", { enabled = state.markerEnabled })
    announce("TM02V proxy marker enabled: " .. tostring(state.markerEnabled))
    return state.markerEnabled
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
      checkedProxyTemplateCount = 1,
      checkedNodeCount = 1 + #config.shelters,
    })
    announce(table.concat({
      "TM02V validation",
      "Configuration: " .. tostring(configValid),
      "Mission objects: " .. tostring(objectsValid),
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
    local menu = MENU_MISSION:New("TM02V Proxy Movement", root)
    MENU_MISSION_COMMAND:New("Validate test", menu, validateAndReport)
    MENU_MISSION_COMMAND:New("Start proxy movement", menu, startProxyMovement)
    MENU_MISSION_COMMAND:New("Show movement status", menu, showStatus)
    MENU_MISSION_COMMAND:New("Force unpack", menu, forceUnpack)
    MENU_MISSION_COMMAND:New("Force pack", menu, forcePack)
    MENU_MISSION_COMMAND:New("Toggle proxy marker", menu, toggleMarker)
  end

  log("INFO", "startup", {
    buildTimestamp = build and build.buildTimestamp or "source",
    configurationVersion = config.configurationVersion,
    movementId = config.movementId,
    routeNodeIds = join(config.movement.routeNodeIds, ">"),
    strength = config.movement.strength,
    initialPersonnel = state.initialPersonnel,
    initialRecordedLosses = state.totalLosses,
  })
  announce("TM02V READY: proxy movement HQ -> A -> AA")

  state.startProxyMovement = startProxyMovement
  state.forceUnpack = forceUnpack
  state.forcePack = forcePack
  state.showStatus = showStatus
  state.toggleMarker = toggleMarker
  state.validateAndReport = validateAndReport
  state.inventorySnapshot = inventorySnapshot
  state.monitorTick = monitorTick
  return state
end

return TM02V
