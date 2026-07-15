  function controller:start()
    local action = "Start convoy"
    if not ensureReady(action) then
      return false
    end
    if self.entity.representationState ~= REPRESENTATION_NOT_STARTED then
      return reject(action, "convoy has already been started")
    end

    local routeOk, routePlanOrError = buildGlobalRoutePlan()
    if not routeOk then
      return halt("convoy_route_plan_failed", routePlanOrError)
    end
    self.routePlan = routePlanOrError

    local survivors = copyArray(self.entity.survivingVehicleSlotsRearToFront)
    local initialLeadDistance = (#survivors - 1) * config.routing.vehicleSpacingMeters + 20
    local layout, layoutError = buildLayoutAtLeadDistance(initialLeadDistance, survivors)
    if not layout then
      return halt("convoy_initial_layout_failed", layoutError)
    end

    local spawnResult, spawnError = spawnDynamicGroup(layout.slotsFrontToRear, layout.positions)
    if not spawnResult then
      return halt("convoy_initial_spawn_failed", spawnError)
    end
    local assignmentOk, routeOrError = assignRoute(spawnResult.group, initialLeadDistance)
    if not assignmentOk then
      pcall(function()
        spawnResult.group:Destroy(false)
      end)
      return halt("convoy_initial_route_failed", routeOrError)
    end

    setRuntimeFromSpawn(spawnResult, REPRESENTATION_EXPANDED, initialLeadDistance)
    local leadItem, leadError = currentLeadItem()
    if not leadItem then
      return halt("convoy_initial_inspection_failed", leadError)
    end

    logInfo("convoy_proxy_test_started", {
      globalRoadDistanceMeters = self.routePlan.totalDistance,
      sampledPointCount = #self.routePlan.points,
      waypointCount = #routeOrError.waypoints,
      survivorCount = #survivors,
    })
    announce("TM01C started\nConvoy expanded with 6 vehicles")
    updateMarker(true)

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        schedulerTick,
        nil,
        timer.getTime() + config.transitions.pollSeconds
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      return halt(
        "convoy_scheduler_failed",
        scheduleOk and "scheduler returned nil" or scheduleResult
      )
    end
    self.schedulerId = scheduleResult
    return true
  end

  function controller:pack()
    local action = "Pack convoy"
    if not ensureReady(action) then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return reject(action, "transition is already active")
    end
    if self.entity.representationState ~= REPRESENTATION_EXPANDED then
      return reject(action, "convoy is not expanded")
    end
    if not groupIsAlive(self.runtimeGroup) then
      return halt("convoy_pack_failed", "expanded runtime group is not alive")
    end

    local liveOk, liveItemsOrError = captureLiveUnits()
    if not liveOk then
      return halt("convoy_pack_failed", liveItemsOrError)
    end
    local syncOk, leadOrError = synchronizeExpandedSurvivors(liveItemsOrError)
    if not syncOk then
      return halt("convoy_pack_failed", leadOrError)
    end
    local leadItem = leadOrError
    local vecOk, leadVecOrError = pcall(function()
      return leadItem.unit:GetVec2()
    end)
    if not vecOk then
      return halt("convoy_pack_failed", leadVecOrError)
    end
    local projection, projectionError = projectToRoute(leadVecOrError)
    if not projection then
      return halt("convoy_pack_failed", projectionError)
    end

    local routeOk, routeOrError = assignRoute(self.runtimeGroup, projection.routeDistance)
    if not routeOk then
      return halt("convoy_pack_route_failed", routeOrError)
    end

    updateEntity({ transitionState = TRANSITION_PACKING })
    for _, item in ipairs(liveItemsOrError) do
      if item.stableSlot ~= self.entity.currentLeadSlot then
        local destroyOk, destroyError = pcall(function()
          item.unit:Destroy(false)
        end)
        if not destroyOk then
          return halt("convoy_pack_failed", destroyError)
        end
      end
    end

    local countOk, countOrError = pcall(function()
      return self.runtimeGroup:CountAliveUnits()
    end)
    if not countOk or countOrError ~= 1 then
      return halt(
        "convoy_pack_failed",
        countOk and "packed runtime group does not contain exactly one unit" or countOrError
      )
    end

    local leadRuntimeMapping = {
      [leadItem.runtimeIndex] = leadItem.stableSlot,
    }
    updateEntity({
      representationState = REPRESENTATION_COLLAPSED,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_EN_ROUTE,
      routeProgressMeters = projection.routeDistance,
      runtimeIndexToStableSlot = leadRuntimeMapping,
    })
    self.lastError = nil

    logInfo("convoy_packed", {
      proxyRuntimeIndex = leadItem.runtimeIndex,
      proxyRouteOffsetMeters = projection.offsetMeters,
      storedVehicleCount = #self.entity.survivingVehicleSlotsRearToFront - 1,
      waypointCount = #routeOrError.waypoints,
    })
    announce(
      "Convoy packed"
        .. "\nProxy slot: "
        .. tostring(self.entity.currentLeadSlot)
        .. "\nStored vehicles: "
        .. tostring(#self.entity.survivingVehicleSlotsRearToFront - 1)
    )
    updateMarker(true)
    return true
  end

  function controller:unpack(automaticAtTarget)
    local action = automaticAtTarget and "Automatic target unpack" or "Unpack convoy"
    if not ensureReady(action) then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return reject(action, "transition is already active")
    end
    if self.entity.representationState ~= REPRESENTATION_COLLAPSED then
      return reject(action, "convoy is not in collapsed proxy state")
    end
    if not groupIsAlive(self.runtimeGroup) then
      return halt("convoy_unpack_failed", "proxy runtime group is not alive")
    end

    local leadItem, leadError = currentLeadItem()
    if not leadItem then
      return halt("convoy_unpack_failed", leadError)
    end
    local positionOk, proxyVec2OrError = pcall(function()
      return leadItem.unit:GetVec2()
    end)
    if not positionOk then
      return halt("convoy_unpack_failed", proxyVec2OrError)
    end

    local layout, layoutError = findUnpackLayout(
      proxyVec2OrError,
      self.entity.survivingVehicleSlotsRearToFront
    )
    if not layout then
      logError("convoy_unpack_site_unavailable", layoutError)
      announce("Unpack failed closed; proxy continues\n" .. tostring(layoutError))
      self.lastError = tostring(layoutError)
      return false
    end

    local oldRuntimeName = self.entity.runtimeGroupName
    local proxyHeading = headingAtDistance(layout.proxyProjection.routeDistance)
    local pending = {
      oldRuntimeGroupName = oldRuntimeName,
      oldRuntimeGroup = self.runtimeGroup,
      layout = layout,
      proxyVec2 = copyVec2(proxyVec2OrError),
      proxyHeading = proxyHeading,
      proxyRouteProgress = layout.proxyProjection.routeDistance,
      automaticAtTarget = automaticAtTarget == true,
      startedAt = timer.getTime(),
      attempts = 0,
    }
    self.pendingUnpack = pending
    self.arrivalRequested = automaticAtTarget == true
    updateEntity({ transitionState = TRANSITION_UNPACKING })

    local destroyOk, destroyError = pcall(function()
      self.runtimeGroup:Destroy(false)
    end)
    if not destroyOk then
      self.pendingUnpack = nil
      updateEntity({ transitionState = TRANSITION_IDLE })
      return halt("convoy_unpack_failed", destroyError)
    end
    self.runtimeGroup = nil
    self.spawner = nil

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        pollUnpackDestroy,
        nil,
        timer.getTime() + config.transitions.destroyConfirmationPollSeconds
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      local lookupOk, existsOrError = nativeGroupExists(oldRuntimeName)
      if lookupOk and existsOrError == true then
        self.runtimeGroup = pending.oldRuntimeGroup
        self.pendingUnpack = nil
        self.arrivalRequested = false
        updateEntity({ transitionState = TRANSITION_IDLE })
        return reject(action, "unpack scheduler failed; existing proxy retained")
      end
      return rollbackProxy(
        pending,
        scheduleOk and "unpack scheduler returned nil" or scheduleResult
      )
    end

    logInfo("convoy_unpack_started", {
      oldRuntimeGroupName = oldRuntimeName,
      selectedLeadOffsetMeters = layout.selectedLeadOffsetMeters,
      leadDisplacementMeters = layout.leadDisplacementMeters,
      survivorCount = #self.entity.survivingVehicleSlotsRearToFront,
      automaticAtTarget = automaticAtTarget == true,
    })
    announce("Unpack transition started")
    return true
  end

  function controller:tick()
    if self.halted then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return true
    end
    if self.entity.representationState == REPRESENTATION_NOT_STARTED
      or self.entity.representationState == REPRESENTATION_ARRIVED
      or self.entity.representationState == REPRESENTATION_DESTROYED then
      return true
    end
    if not groupIsAlive(self.runtimeGroup) then
      updateEntity({
        representationState = REPRESENTATION_DESTROYED,
        movementState = MOVEMENT_DESTROYED,
        clearFields = { "runtimeGroupName" },
      })
      logInfo("convoy_runtime_group_destroyed", {})
      announce("Convoy runtime representation destroyed")
      return false
    end

    local leadItem, leadError = currentLeadItem()
    if not leadItem then
      return halt("convoy_monitor_failed", leadError)
    end
    if updateMarker(false) == false then
      return halt("convoy_marker_failed", "marker update failed")
    end

    local targetZone, targetError = zoneByName(config.zones.target)
    if not targetZone then
      return halt("convoy_target_monitor_failed", targetError)
    end

    if self.entity.representationState == REPRESENTATION_COLLAPSED then
      local vecOk, vecOrError = pcall(function()
        return leadItem.unit:GetVec2()
      end)
      if not vecOk then
        return halt("convoy_target_monitor_failed", vecOrError)
      end
      if targetZone:IsVec2InZone(vecOrError) == true
        and config.transitions.automaticUnpackAtTarget == true then
        return self:unpack(true)
      end
      return true
    end

    local inZoneOk, completelyInsideOrError = pcall(function()
      return self.runtimeGroup:IsCompletelyInZone(targetZone) == true
    end)
    if not inZoneOk then
      return halt("convoy_target_monitor_failed", completelyInsideOrError)
    end
    if completelyInsideOrError then
      updateEntity({
        representationState = REPRESENTATION_ARRIVED,
        movementState = MOVEMENT_ARRIVED,
      })
      logInfo("convoy_route_arrived", {
        survivorCount = #self.entity.survivingVehicleSlotsRearToFront,
        arrivedExpanded = true,
      })
      announce(
        "Convoy arrived at Jalalabad"
          .. "\nReststaerke: "
          .. tostring(#self.entity.survivingVehicleSlotsRearToFront)
      )
      return false
    end
    return true
  end

  schedulerTick = function(_, scheduledTime)
    if controller.halted
      or controller.entity.representationState == REPRESENTATION_ARRIVED
      or controller.entity.representationState == REPRESENTATION_DESTROYED then
      return nil
    end
    local ok, resultOrError = pcall(function()
      return controller:tick()
    end)
    if not ok then
      halt("convoy_scheduler_tick_failed", resultOrError)
      return nil
    end
    if resultOrError == false and controller.halted then
      return nil
    end
    return scheduledTime + config.transitions.pollSeconds
  end

  function controller:showStatus()
    local liveCount = "unavailable"
    if self.runtimeGroup then
      local countOk, countOrError = pcall(function()
        return self.runtimeGroup:CountAliveUnits()
      end)
      if countOk then
        liveCount = countOrError
      end
    end

    logInfo("convoy_proxy_status", {
      halted = self.halted,
      lastError = self.lastError or "none",
      liveRuntimeUnitCount = liveCount,
      pendingUnpack = self.pendingUnpack ~= nil,
    })
    announce(
      "Entity: " .. self.entity.entityId
        .. "\nRepresentation: " .. self.entity.representationState
        .. "\nTransition: " .. self.entity.transitionState
        .. "\nMovement: " .. self.entity.movementState
        .. "\nRuntime group: " .. tostring(self.entity.runtimeGroupName or "none")
        .. "\nLive runtime units: " .. tostring(liveCount)
        .. "\nSurvivor slots rear-to-front: "
        .. joinNumbers(self.entity.survivingVehicleSlotsRearToFront)
        .. "\nLead slot: " .. tostring(self.entity.currentLeadSlot or "none")
        .. "\nError: " .. tostring(self.lastError or "none")
    )
  end

  function controller:getState()
    return campaignState:getEntitySnapshot(config.scenarioId)
  end

  return controller
end

return ConvoyProxyController
