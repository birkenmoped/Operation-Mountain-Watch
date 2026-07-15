  local function captureLiveUnits()
    return pcall(function()
      if not controller.runtimeGroup then
        error("runtime group wrapper is unavailable")
      end
      local units = controller.runtimeGroup:GetUnits()
      if type(units) ~= "table" then
        error("runtime units are unavailable")
      end
      local result = {}
      local seenStableSlots = {}
      for _, unit in pairs(units) do
        if unit and unit:IsAlive() == true then
          local runtimeIndex = parseRuntimeIndex(unit:GetName())
          if not runtimeIndex then
            error("cannot parse runtime unit index from " .. tostring(unit:GetName()))
          end
          local stableSlot = controller.entity.runtimeIndexToStableSlot[runtimeIndex]
          if not stableSlot then
            error("runtime index has no stable-slot mapping: " .. tostring(runtimeIndex))
          end
          if seenStableSlots[stableSlot] then
            error("duplicate stable slot in runtime group: " .. tostring(stableSlot))
          end
          seenStableSlots[stableSlot] = true
          result[#result + 1] = {
            unit = unit,
            runtimeIndex = runtimeIndex,
            stableSlot = stableSlot,
          }
        end
      end
      return result
    end)
  end

  local function liveItemByStableSlot(liveItems, stableSlot)
    for _, item in ipairs(liveItems or {}) do
      if item.stableSlot == stableSlot then
        return item
      end
    end
    return nil
  end

  local function synchronizeExpandedSurvivors(liveItems)
    local liveSet = {}
    for _, item in ipairs(liveItems) do
      liveSet[item.stableSlot] = true
    end

    local survivors = {}
    for _, stableSlot in ipairs(controller.entity.survivingVehicleSlotsRearToFront) do
      if liveSet[stableSlot] then
        survivors[#survivors + 1] = stableSlot
      end
    end
    if #survivors == 0 then
      updateEntity({
        representationState = REPRESENTATION_DESTROYED,
        movementState = MOVEMENT_DESTROYED,
        clearFields = { "runtimeGroupName", "currentLeadSlot", "currentLeadUnitType" },
      })
      controller.runtimeGroup = nil
      return false, "no surviving convoy vehicles remain"
    end

    local survivorsChanged = not arraysEqual(
      survivors,
      controller.entity.survivingVehicleSlotsRearToFront
    )
    local leadSlot = survivors[#survivors]
    local leadItem = liveItemByStableSlot(liveItems, leadSlot)
    if not leadItem then
      return false, "current lead slot is not represented by a live unit"
    end
    local typeOk, typeOrError = pcall(function()
      return leadItem.unit:GetTypeName()
    end)
    local leadType = typeOk and typeOrError or "unknown"

    local leadChanged = controller.entity.currentLeadSlot ~= leadSlot
      or controller.entity.currentLeadUnitType ~= leadType
    if survivorsChanged or leadChanged then
      updateEntity({
        survivingVehicleSlotsRearToFront = survivors,
        currentLeadSlot = leadSlot,
        currentLeadUnitType = leadType,
      })
    end

    if survivorsChanged then
      logInfo("convoy_losses_observed", {
        survivorCount = #survivors,
        currentLeadSlot = leadSlot,
      })
    end
    return true, leadItem
  end

  local function currentLeadItem()
    local liveOk, liveItemsOrError = captureLiveUnits()
    if not liveOk then
      return nil, liveItemsOrError
    end
    if controller.entity.representationState == REPRESENTATION_EXPANDED then
      local syncOk, leadOrError = synchronizeExpandedSurvivors(liveItemsOrError)
      if not syncOk then
        return nil, leadOrError
      end
      return leadOrError, nil
    end
    local lead = liveItemByStableSlot(liveItemsOrError, controller.entity.currentLeadSlot)
    if not lead then
      return nil, "collapsed proxy lead unit is unavailable"
    end
    if #liveItemsOrError ~= 1 then
      return nil, "collapsed proxy representation contains more than one live unit"
    end
    return lead, nil
  end

  local function updateMarker(force)
    local now = timer.getTime()
    if not force
      and controller.markerLastUpdate
      and now - controller.markerLastUpdate < config.transitions.markerUpdateSeconds then
      return true
    end

    local leadItem, leadError = currentLeadItem()
    if not leadItem then
      return false, leadError
    end
    local vecOk, vecOrError = pcall(function()
      return leadItem.unit:GetVec2()
    end)
    if not vecOk then
      return false, vecOrError
    end

    local text = "TM01C - Konvoi " .. controller.entity.representationState
      .. "\nReststaerke: "
      .. tostring(#controller.entity.survivingVehicleSlotsRearToFront)
      .. "\nFuehrungsslot: "
      .. tostring(controller.entity.currentLeadSlot)

    local markerOk, markerOrError = pcall(function()
      local coordinate = coordinateFromVec2(vecOrError)
      if not controller.marker then
        controller.marker = MARKER:New(coordinate, text):ReadOnly():ToBlue()
      else
        controller.marker:UpdateCoordinate(coordinate)
        controller.marker:UpdateText(text)
      end
      return controller.marker
    end)
    if not markerOk or not markerOrError then
      return false, markerOrError
    end
    controller.markerLastUpdate = now
    return true
  end

  local function setRuntimeFromSpawn(spawnResult, representation, routeProgress)
    controller.spawner = spawnResult.spawner
    controller.runtimeGroup = spawnResult.group
    updateEntity({
      representationState = representation,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_EN_ROUTE,
      runtimeGeneration = spawnResult.generation,
      runtimeGroupName = spawnResult.runtimeName,
      runtimeIndexToStableSlot = spawnResult.runtimeIndexToStableSlot,
      routeProgressMeters = routeProgress,
    })
  end

  local function rollbackProxy(pending, reason)
    local leadSlot = controller.entity.currentLeadSlot
    local rollbackPositions = {
      {
        x = pending.proxyVec2.x,
        y = pending.proxyVec2.y,
        heading = pending.proxyHeading,
      },
    }
    local rollback, rollbackError = spawnDynamicGroup({ leadSlot }, rollbackPositions)
    if not rollback then
      return halt(
        "convoy_unpack_rollback_failed",
        tostring(reason) .. "; rollback=" .. tostring(rollbackError)
      )
    end
    local routeOk, routeError = assignRoute(rollback.group, pending.proxyRouteProgress)
    if not routeOk then
      pcall(function()
        rollback.group:Destroy(false)
      end)
      return halt(
        "convoy_unpack_rollback_failed",
        tostring(reason) .. "; rollback route=" .. tostring(routeError)
      )
    end
    setRuntimeFromSpawn(rollback, REPRESENTATION_COLLAPSED, pending.proxyRouteProgress)
    controller.pendingUnpack = nil
    controller.arrivalRequested = false
    controller.lastError = tostring(reason)
    logError("convoy_unpack_failed_proxy_restored", reason)
    announce("Unpack failed; proxy restored: " .. tostring(reason))
    updateMarker(true)
    return false
  end

  local function completeUnpack(pending)
    local spawnResult, spawnError = spawnDynamicGroup(
      pending.layout.slotsFrontToRear,
      pending.layout.positions
    )
    if not spawnResult then
      return rollbackProxy(pending, spawnError)
    end

    local routeOk, routeOrError = assignRoute(spawnResult.group, pending.layout.leadDistance)
    if not routeOk then
      pcall(function()
        spawnResult.group:Destroy(false)
      end)
      return rollbackProxy(pending, routeOrError)
    end

    setRuntimeFromSpawn(spawnResult, REPRESENTATION_EXPANDED, pending.layout.leadDistance)
    controller.pendingUnpack = nil
    controller.lastError = nil

    logInfo("convoy_unpacked", {
      survivorCount = #controller.entity.survivingVehicleSlotsRearToFront,
      selectedLeadOffsetMeters = pending.layout.selectedLeadOffsetMeters,
      leadDisplacementMeters = pending.layout.leadDisplacementMeters,
      waypointCount = #routeOrError.waypoints,
      automaticAtTarget = pending.automaticAtTarget == true,
    })
    announce(
      "Convoy unpacked"
        .. "\nVehicles: "
        .. tostring(#controller.entity.survivingVehicleSlotsRearToFront)
        .. "\nLead offset: "
        .. tostring(pending.layout.selectedLeadOffsetMeters)
        .. " m"
    )
    updateMarker(true)
    return true
  end

  pollUnpackDestroy = function(_, scheduledTime)
    local pending = controller.pendingUnpack
    if not pending then
      return nil
    end
    pending.attempts = pending.attempts + 1
    local lookupOk, existsOrError = nativeGroupExists(pending.oldRuntimeGroupName)
    if lookupOk and existsOrError == false then
      completeUnpack(pending)
      return nil
    end

    local elapsed = timer.getTime() - pending.startedAt
    if elapsed >= config.transitions.destroyConfirmationTimeoutSeconds then
      if lookupOk and existsOrError == true then
        controller.runtimeGroup = pending.oldRuntimeGroup
        controller.pendingUnpack = nil
        controller.arrivalRequested = false
        controller.lastError = "proxy group still exists after destruction timeout"
        updateEntity({ transitionState = TRANSITION_IDLE })
        logError("convoy_unpack_destroy_timeout_proxy_retained", controller.lastError)
        announce("Unpack cancelled; existing proxy retained")
        return nil
      end
      return halt(
        "convoy_unpack_destroy_confirmation_failed",
        "proxy destruction lookup failed: " .. tostring(existsOrError)
      ) and nil or nil
    end
    return scheduledTime + config.transitions.destroyConfirmationPollSeconds
  end

