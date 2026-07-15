  local activationConfig = config.transitions or {}
  local routeActivationInitialDelaySeconds = activationConfig.routeActivationInitialDelaySeconds or 1
  local routeActivationPollSeconds = activationConfig.routeActivationPollSeconds or 1
  local routeActivationReissueSeconds = activationConfig.routeActivationReissueSeconds or 5
  local routeActivationTimeoutSeconds = activationConfig.routeActivationTimeoutSeconds or 30
  local routeActivationMovementThresholdMeters = activationConfig.routeActivationMovementThresholdMeters or 2

  local positiveActivationSettings = {
    { routeActivationInitialDelaySeconds, "routeActivationInitialDelaySeconds" },
    { routeActivationPollSeconds, "routeActivationPollSeconds" },
    { routeActivationReissueSeconds, "routeActivationReissueSeconds" },
    { routeActivationTimeoutSeconds, "routeActivationTimeoutSeconds" },
    { routeActivationMovementThresholdMeters, "routeActivationMovementThresholdMeters" },
  }
  for _, setting in ipairs(positiveActivationSettings) do
    if type(setting[1]) ~= "number" or setting[1] <= 0 then
      error(setting[2] .. " must be a positive number")
    end
  end

  controller.pendingRouteActivation = nil

  local function safeGroupName(group)
    local ok, nameOrError = pcall(function()
      return group and group:GetName()
    end)
    if not ok then
      return nil, nameOrError
    end
    if type(nameOrError) ~= "string" or nameOrError == "" then
      return nil, "runtime group name is unavailable"
    end
    return nameOrError, nil
  end

  local function firstRuntimeUnit(group)
    local units = group:GetUnits()
    if type(units) ~= "table" then
      return nil, "runtime units are unavailable"
    end
    local firstUnit = nil
    local firstIndex = nil
    for _, unit in pairs(units) do
      if unit and unit:IsAlive() == true then
        local runtimeIndex = parseRuntimeIndex(unit:GetName())
        if runtimeIndex and (not firstIndex or runtimeIndex < firstIndex) then
          firstUnit = unit
          firstIndex = runtimeIndex
        elseif not firstUnit then
          firstUnit = unit
        end
      end
    end
    if not firstUnit then
      return nil, "runtime group has no live unit"
    end
    return firstUnit, nil
  end

  local function serviceDamageRestore(active, now)
    if active.damageVerified then
      return true
    end

    if active.damageApplyAttempts == 0 then
      return applyStoredDamage(active)
    end

    if now - (active.damageAppliedAt or 0) < damageRestoreRetrySeconds then
      return true
    end

    local verified, verificationError = verifyStoredDamage(active)
    if verified then
      active.damageVerified = true
      return true
    end

    if active.damageApplyAttempts >= damageRestoreMaxAttempts then
      return false, verificationError
    end

    local applied, applyError = applyStoredDamage(active)
    if not applied then
      return false, applyError
    end
    active.lastDamageVerificationError = tostring(verificationError)
    return true
  end

  local originalAssignRoute = assignRoute
  assignRoute = function(group, fromDistance)
    local runtimeName, runtimeNameError = safeGroupName(group)
    if not runtimeName then
      return false, runtimeNameError
    end

    local isExistingRuntime = controller.runtimeGroup == group
      and controller.entity.runtimeGroupName == runtimeName
    if isExistingRuntime then
      return originalAssignRoute(group, fromDistance)
    end

    if controller.pendingRouteActivation then
      return false, "another spawned-group route activation is already pending"
    end

    local routeOk, routeOrError = buildRemainingRoute(fromDistance)
    if not routeOk then
      return false, routeOrError
    end

    local leadUnit, leadError = firstRuntimeUnit(group)
    if not leadUnit then
      return false, leadError
    end
    local baselineOk, baselineVecOrError = pcall(function()
      return leadUnit:GetVec2()
    end)
    if not baselineOk or type(baselineVecOrError) ~= "table" then
      return false,
        baselineOk and "runtime lead position is unavailable" or baselineVecOrError
    end
    local baselineProjection, projectionError = projectToRoute(baselineVecOrError)
    if not baselineProjection then
      return false, projectionError
    end

    local active = {
      group = group,
      runtimeName = runtimeName,
      route = routeOrError,
      fromDistance = fromDistance,
      baselineVec2 = copyVec2(baselineVecOrError),
      baselineRouteDistance = baselineProjection.routeDistance,
      startedAt = timer.getTime(),
      routeAssignmentAttempts = 0,
      nextRouteAssignmentAt = timer.getTime() + routeActivationInitialDelaySeconds,
      damageApplyAttempts = 0,
      damageAppliedAt = nil,
      damageVerified = false,
      lastDamageVerificationError = nil,
      movementRequired = not (controller.pendingUnpack
        and controller.pendingUnpack.automaticAtTarget == true),
      context = controller.entity.representationState == REPRESENTATION_NOT_STARTED
        and "INITIAL_SPAWN"
        or "SPAWNED_REPRESENTATION",
    }
    controller.pendingRouteActivation = active

    local function failActivation(eventName, reason)
      controller.pendingRouteActivation = nil
      halt(eventName, reason)
      return nil
    end

    local function pollRouteActivation(_, scheduledTime)
      if controller.pendingRouteActivation ~= active then
        return nil
      end
      if controller.halted then
        controller.pendingRouteActivation = nil
        return nil
      end
      if not groupIsAlive(active.group) then
        return failActivation(
          "convoy_route_activation_failed",
          "spawned runtime group is no longer alive"
        )
      end

      local now = timer.getTime()
      local damageOk, damageError = serviceDamageRestore(active, now)
      if not damageOk then
        return failActivation("convoy_damage_restore_failed", damageError)
      end

      if active.routeAssignmentAttempts == 0 or now >= active.nextRouteAssignmentAt then
        local assignmentOk, assignmentResult = pcall(function()
          return active.group:Route(active.route.waypoints, 0)
        end)
        if not assignmentOk or not assignmentResult then
          return failActivation(
            "convoy_route_activation_failed",
            assignmentOk and "route assignment returned nil" or assignmentResult
          )
        end
        active.routeAssignmentAttempts = active.routeAssignmentAttempts + 1
        active.nextRouteAssignmentAt = now + routeActivationReissueSeconds
        logInfo("convoy_route_activation_task_issued", {
          context = active.context,
          routeAssignmentAttempts = active.routeAssignmentAttempts,
          waypointCount = #active.route.waypoints,
          movementRequired = active.movementRequired,
        })
      end

      local currentLead, currentLeadError = firstRuntimeUnit(active.group)
      if not currentLead then
        return failActivation("convoy_route_activation_failed", currentLeadError)
      end
      local vecOk, vecOrError = pcall(function()
        return currentLead:GetVec2()
      end)
      if not vecOk or type(vecOrError) ~= "table" then
        return failActivation(
          "convoy_route_activation_failed",
          vecOk and "runtime lead position is unavailable" or vecOrError
        )
      end
      local projection, currentProjectionError = projectToRoute(vecOrError)
      if not projection then
        return failActivation("convoy_route_activation_failed", currentProjectionError)
      end

      local forwardMeters = projection.routeDistance - active.baselineRouteDistance
      local displacementMeters = distance2d(active.baselineVec2, vecOrError)
      local movementConfirmed = not active.movementRequired
        or (forwardMeters >= routeActivationMovementThresholdMeters
          and displacementMeters >= routeActivationMovementThresholdMeters)
      if active.routeAssignmentAttempts > 0
        and active.damageVerified
        and movementConfirmed then
        controller.pendingRouteActivation = nil
        updateEntity({
          transitionState = TRANSITION_IDLE,
          movementState = MOVEMENT_EN_ROUTE,
          routeProgressMeters = projection.routeDistance,
        })
        logInfo("convoy_route_activation_confirmed", {
          context = active.context,
          routeAssignmentAttempts = active.routeAssignmentAttempts,
          forwardMeters = forwardMeters,
          displacementMeters = displacementMeters,
          waypointCount = #active.route.waypoints,
          movementRequired = active.movementRequired,
        })
        announce("Convoy route active and movement confirmed")
        return nil
      end

      if now - active.startedAt >= routeActivationTimeoutSeconds then
        local reason = "spawned convoy did not begin forward movement"
          .. "; attempts=" .. tostring(active.routeAssignmentAttempts)
          .. "; forwardMeters=" .. tostring(forwardMeters)
          .. "; displacementMeters=" .. tostring(displacementMeters)
        if active.lastDamageVerificationError then
          reason = reason
            .. "; lastDamageVerification="
            .. active.lastDamageVerificationError
        end
        return failActivation("convoy_route_activation_timeout", reason)
      end

      return scheduledTime + routeActivationPollSeconds
    end

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        pollRouteActivation,
        nil,
        timer.getTime() + routeActivationInitialDelaySeconds
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      controller.pendingRouteActivation = nil
      return false,
        scheduleOk and "route activation scheduler returned nil" or scheduleResult
    end

    routeOrError.activationPending = true
    return true, routeOrError
  end

  local originalSetRuntimeFromSpawn = setRuntimeFromSpawn
  setRuntimeFromSpawn = function(spawnResult, representation, routeProgress)
    originalSetRuntimeFromSpawn(spawnResult, representation, routeProgress)
    local active = controller.pendingRouteActivation
    if active and active.runtimeName == spawnResult.runtimeName then
      active.context = representation == REPRESENTATION_COLLAPSED
        and "ROLLBACK_PROXY"
        or (spawnResult.generation == 1 and "INITIAL_SPAWN" or "UNPACK_SPAWN")
      updateEntity({
        transitionState = "ACTIVATING_ROUTE",
        movementState = "ACTIVATING_ROUTE",
      })
    end
  end
