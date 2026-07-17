local PhysicalRelayController = {}

local MOOSE_FORMATIONS = {
  OFF_ROAD = "Off Road",
  ON_ROAD = "On Road",
}

local ROUTE_ASSIGNMENT_DELAY_SECONDS = 1
local TERMINAL_MOVEMENT_STATES = {
  ARRIVED = true,
  DESTROYED = true,
  FAILED = true,
}

local function display(value)
  if value == nil then
    return "none"
  end
  return tostring(value)
end

function PhysicalRelayController.new(options)
  local config = options.config
  local logger = options.logger
  local controller = {
    runtimeGroup = nil,
    runtimeGroupName = nil,
    spawnAttempted = false,
    routeAssignmentAttempted = false,
    arrivalEventLogged = false,
    arrivalMonitorActive = false,
    arrivalMonitorGeneration = 0,
    arrivalMonitorScheduleId = nil,
  }

  local function announce(text)
    options.announce(text)
  end

  local function commonFields()
    local movement = options.campaignState:getMovementSnapshot()
    return {
      destinationNodeId = config.transfer.destinationNodeId,
      movementId = config.movement.movementId,
      movementState = movement and movement.movementState or "NONE",
      representationState = movement and movement.representationState or "NONE",
      runtimeGroupName = controller.runtimeGroupName or "none",
      sourceNodeId = config.transfer.sourceNodeId,
    }
  end

  local function fail(reason, event)
    local reasonText = tostring(reason)
    options.campaignState:failMovement(reasonText)
    local fields = commonFields()
    fields.reason = reasonText
    fields.missionTimeSeconds = timer.getTime()
    logger:error(event or "red_relay_start_failed", fields)
    announce("RED relay failed: " .. reasonText)
  end

  local function inspectGroup(group, sourceZone, destinationZone, templateGroup)
    return pcall(function()
      local destinationZoneMembership = nil
      local sourceZoneMembership = nil
      local templateAlive = nil
      if destinationZone then
        destinationZoneMembership = group:IsCompletelyInZone(destinationZone) == true
      end
      if sourceZone then
        sourceZoneMembership = group:IsCompletelyInZone(sourceZone) == true
      end
      if templateGroup then
        templateAlive = templateGroup:IsAlive() == true
      end
      return {
        alive = group:IsAlive() == true,
        destinationZoneMembership = destinationZoneMembership,
        runtimeGroupName = group:GetName(),
        sourceZoneMembership = sourceZoneMembership,
        survivorCount = group:CountAliveUnits(),
        templateAlive = templateAlive,
      }
    end)
  end

  local function buildRoute(group)
    return pcall(function()
      local onRoadFormation = MOOSE_FORMATIONS[config.routing.formation]
      if config.routing.roadOnly ~= true or not onRoadFormation then
        error("road-only ON_ROAD routing is required")
      end
      if not group then
        error("runtime group is unavailable for route construction")
      end

      local startCoordinate = group:GetCoordinate()
      if not startCoordinate then
        error("runtime-group coordinate is unavailable")
      end

      local waypoints = {}
      local startWaypoint = startCoordinate:WaypointGround(
        config.routing.speedKph,
        MOOSE_FORMATIONS.OFF_ROAD
      )
      if type(startWaypoint) ~= "table" then
        error("runtime start waypoint construction failed")
      end
      waypoints[#waypoints + 1] = startWaypoint

      for _, zoneName in ipairs(config.zones.routeAnchors) do
        local zone = ZONE:FindByName(zoneName)
        if not zone then
          error("route zone is unavailable: " .. zoneName)
        end
        local coordinate = zone:GetCoordinate()
        if not coordinate then
          error("route-zone coordinate is unavailable: " .. zoneName)
        end
        local waypoint = coordinate:WaypointGround(
          config.routing.speedKph,
          onRoadFormation
        )
        if type(waypoint) ~= "table" then
          error("ground waypoint construction failed: " .. zoneName)
        end
        waypoints[#waypoints + 1] = waypoint
      end

      local destinationZone = ZONE:FindByName(config.zones.target)
      if not destinationZone then
        error("route zone is unavailable: " .. config.zones.target)
      end
      local destinationCoordinate = destinationZone:GetCoordinate()
      if not destinationCoordinate then
        error("route-zone coordinate is unavailable: " .. config.zones.target)
      end
      local destinationWaypoint = destinationCoordinate:WaypointGround(
        config.routing.speedKph,
        MOOSE_FORMATIONS.OFF_ROAD
      )
      if type(destinationWaypoint) ~= "table" then
        error("ground waypoint construction failed: " .. config.zones.target)
      end
      waypoints[#waypoints + 1] = destinationWaypoint

      return {
        assignmentDelaySeconds = ROUTE_ASSIGNMENT_DELAY_SECONDS,
        startWaypointIncluded = true,
        waypoints = waypoints,
      }
    end)
  end

  local function arrivalMonitorSettings()
    local settings = config.arrivalMonitoring or {}
    local initialDelaySeconds = settings.initialDelaySeconds
    local intervalSeconds = settings.intervalSeconds
    if type(initialDelaySeconds) ~= "number" or initialDelaySeconds <= 0 then
      error("arrivalMonitoring.initialDelaySeconds must be greater than zero")
    end
    if type(intervalSeconds) ~= "number" or intervalSeconds <= 0 then
      error("arrivalMonitoring.intervalSeconds must be greater than zero")
    end
    return initialDelaySeconds, intervalSeconds
  end

  local function logArrival(arrival)
    if controller.arrivalEventLogged then
      return
    end
    controller.arrivalEventLogged = true
    logger:info("red_relay_arrived", {
      destinationNodeId = arrival.destinationNodeId,
      movementId = arrival.movementId,
      missionTimeSeconds = timer.getTime(),
      runtimeGroupName = arrival.runtimeGroupName,
      survivorCount = arrival.survivorCount,
      targetZoneMembership = true,
    })
    announce(
      "RED relay arrived"
        .. "\nMovement: " .. arrival.movementId
        .. "\nSurvivors credited: " .. arrival.survivorCount
        .. "\nDestination: " .. arrival.destinationNodeId
    )
  end

  local function reconcileActiveMovement()
    local movement = options.campaignState:getMovementSnapshot()
    if not movement then
      return false, "movement is unavailable"
    end
    if TERMINAL_MOVEMENT_STATES[movement.movementState] then
      return false, movement.movementState
    end
    if movement.movementState ~= "EN_ROUTE" then
      return true, movement.movementState
    end
    if not controller.runtimeGroup then
      fail("runtime group is unavailable", "red_relay_arrival_monitor_failed")
      return false, "FAILED"
    end

    local destinationZone = ZONE:FindByName(config.zones.target)
    if not destinationZone then
      fail("destination zone is unavailable", "red_relay_arrival_monitor_failed")
      return false, "FAILED"
    end

    local inspectionOk, inspection = inspectGroup(
      controller.runtimeGroup,
      nil,
      destinationZone,
      nil
    )
    if not inspectionOk then
      fail(inspection, "red_relay_arrival_monitor_inspection_failed")
      return false, "FAILED"
    end

    local synced, syncReason = options.campaignState:syncSurvivors(
      inspection.survivorCount
    )
    if not synced then
      fail(syncReason, "red_relay_survivor_sync_failed")
      return false, "FAILED"
    end

    if inspection.survivorCount < 1 then
      local destroyed, destroyedReason = options.campaignState:markDestroyed()
      if not destroyed then
        fail(destroyedReason, "red_relay_destroyed_state_failed")
        return false, "FAILED"
      end
      return false, "DESTROYED"
    end

    if inspection.destinationZoneMembership == true then
      local completed, completionReason = options.campaignState:completeArrival()
      if not completed then
        fail(completionReason, "red_relay_arrival_completion_failed")
        return false, "FAILED"
      end
      local arrival = options.campaignState:getMovementSnapshot()
      logArrival(arrival)
      return false, "ARRIVED"
    end

    return true, "EN_ROUTE"
  end

  local function stopArrivalMonitor(reason)
    if not controller.arrivalMonitorActive then
      return
    end
    controller.arrivalMonitorActive = false
    local fields = commonFields()
    fields.missionTimeSeconds = timer.getTime()
    fields.reason = reason or "stopped"
    logger:info("red_relay_arrival_monitor_stopped", fields)
  end

  local function startArrivalMonitor()
    local settingsOk, initialDelayOrError, intervalSeconds = pcall(arrivalMonitorSettings)
    if not settingsOk then
      fail(initialDelayOrError, "red_relay_arrival_monitor_configuration_failed")
      return false
    end

    controller.arrivalMonitorGeneration = controller.arrivalMonitorGeneration + 1
    local generation = controller.arrivalMonitorGeneration
    controller.arrivalMonitorActive = true
    local firstRunAt = timer.getTime() + initialDelayOrError

    local scheduleOk, scheduleIdOrError = pcall(function()
      return timer.scheduleFunction(function(_, scheduledTime)
        if not controller.arrivalMonitorActive
          or generation ~= controller.arrivalMonitorGeneration then
          return nil
        end

        local tickOk, keepRunning, reason = pcall(reconcileActiveMovement)
        if not tickOk then
          fail(keepRunning, "red_relay_arrival_monitor_failed")
          stopArrivalMonitor("FAILED")
          return nil
        end
        if not keepRunning then
          stopArrivalMonitor(reason)
          return nil
        end
        return timer.getTime() + intervalSeconds
      end, nil, firstRunAt)
    end)

    if not scheduleOk or not scheduleIdOrError then
      controller.arrivalMonitorActive = false
      fail(
        scheduleOk and "timer.scheduleFunction returned nil" or scheduleIdOrError,
        "red_relay_arrival_monitor_start_failed"
      )
      return false
    end

    controller.arrivalMonitorScheduleId = scheduleIdOrError
    local fields = commonFields()
    fields.firstCheckDelaySeconds = initialDelayOrError
    fields.intervalSeconds = intervalSeconds
    fields.missionTimeSeconds = timer.getTime()
    logger:info("red_relay_arrival_monitor_started", fields)
    return true
  end

  function controller:startOneTransfer()
    local requestFields = commonFields()
    requestFields.bootstrapOutcome = options.getBootstrapOutcome()
    requestFields.missionTimeSeconds = timer.getTime()
    logger:info("red_relay_start_requested", requestFields)

    if options.getBootstrapOutcome() ~= "READY" then
      announce("RED relay start rejected: bootstrap is not READY")
      logger:info("red_relay_start_rejected", {
        movementId = config.movement.movementId,
        reason = "bootstrap outcome is not READY",
      })
      return
    end
    if self.spawnAttempted then
      announce("RED relay start rejected: transfer already attempted")
      logger:info("red_relay_start_rejected", {
        movementId = config.movement.movementId,
        reason = "spawn was already attempted",
      })
      return
    end

    local reserved, movementOrReason = options.campaignState:reserveTransfer()
    if not reserved then
      announce("RED relay start rejected: " .. tostring(movementOrReason))
      logger:info("red_relay_start_rejected", {
        movementId = config.movement.movementId,
        reason = movementOrReason,
      })
      return
    end

    local lookupOk, lookup = pcall(function()
      return {
        sourceZone = ZONE:FindByName(config.zones.start),
        destinationZone = ZONE:FindByName(config.zones.target),
        templateGroup = GROUP:FindByName(config.template.groupName),
      }
    end)
    if not lookupOk then
      fail(lookup, "red_relay_object_lookup_failed")
      return
    end
    if not lookup.sourceZone or not lookup.destinationZone or not lookup.templateGroup then
      fail("required template or node zone is unavailable", "red_relay_object_lookup_failed")
      return
    end

    local templateCheckOk, templateCheck = pcall(function()
      return lookup.templateGroup:IsAlive() == true
    end)
    if not templateCheckOk then
      fail(templateCheck, "red_relay_template_check_failed")
      return
    end
    if templateCheck then
      fail("Late Activation template is already active", "red_relay_template_check_failed")
      return
    end

    local spawnerOk, spawnerOrError = pcall(function()
      return SPAWN:NewWithAlias(config.template.groupName, config.template.runtimeAlias)
    end)
    if not spawnerOk or not spawnerOrError then
      fail(spawnerOk and "SPAWN construction returned nil" or spawnerOrError)
      return
    end

    self.spawnAttempted = true
    local spawnOk, groupOrError = pcall(function()
      return spawnerOrError:SpawnInZone(lookup.sourceZone, false)
    end)
    if not spawnOk or type(groupOrError) ~= "table" then
      fail(spawnOk and "SpawnInZone did not return a GROUP wrapper" or groupOrError)
      return
    end
    self.runtimeGroup = groupOrError

    local inspectionOk, inspection = inspectGroup(
      self.runtimeGroup,
      lookup.sourceZone,
      lookup.destinationZone,
      lookup.templateGroup
    )
    if not inspectionOk then
      fail(inspection, "red_relay_spawn_inspection_failed")
      return
    end

    self.runtimeGroupName = inspection.runtimeGroupName
    local physicalMarked, physicalReason = options.campaignState:markPhysical(
      self.runtimeGroupName
    )
    if not physicalMarked then
      fail(physicalReason, "red_relay_physical_registration_failed")
      return
    end

    local survivorSynced, survivorReason = options.campaignState:syncSurvivors(
      inspection.survivorCount
    )
    if not survivorSynced then
      fail(survivorReason, "red_relay_survivor_sync_failed")
      return
    end

    local failures = {}
    if not inspection.alive then
      failures[#failures + 1] = "runtime group is not alive"
    end
    if inspection.survivorCount ~= config.template.expectedFighterCount then
      failures[#failures + 1] = "runtime group does not contain exactly six fighters"
    end
    if inspection.sourceZoneMembership ~= true then
      failures[#failures + 1] = "runtime group is not completely inside the source zone"
    end
    if inspection.templateAlive == true then
      failures[#failures + 1] = "original template became active"
    end
    if type(inspection.runtimeGroupName) ~= "string"
      or inspection.runtimeGroupName == ""
      or inspection.runtimeGroupName == config.template.groupName then
      failures[#failures + 1] = "runtime group name is invalid"
    end
    if #failures > 0 then
      fail(table.concat(failures, ", "), "red_relay_spawn_validation_failed")
      return
    end

    local routeOk, routeOrError = buildRoute(self.runtimeGroup)
    if not routeOk then
      fail(routeOrError, "red_relay_route_build_failed")
      return
    end

    self.routeAssignmentAttempted = true
    local assignmentOk, assignmentResult = pcall(function()
      return self.runtimeGroup:Route(
        routeOrError.waypoints,
        routeOrError.assignmentDelaySeconds
      )
    end)
    if not assignmentOk or not assignmentResult then
      fail(
        assignmentOk and "route assignment returned nil" or assignmentResult,
        "red_relay_route_assignment_failed"
      )
      return
    end

    local routeMarked, routeReason = options.campaignState:markEnRoute()
    if not routeMarked then
      fail(routeReason, "red_relay_route_state_failed")
      return
    end

    local fields = commonFields()
    fields.missionTimeSeconds = timer.getTime()
    fields.routeAnchorCount = #config.zones.routeAnchors
    fields.routeAssignmentDelaySeconds = routeOrError.assignmentDelaySeconds
    fields.startWaypointIncluded = routeOrError.startWaypointIncluded
    fields.totalWaypointCount = #routeOrError.waypoints
    fields.speedKph = config.routing.speedKph
    logger:info("red_relay_started", fields)
    announce(
      "RED relay started"
        .. "\nMovement: " .. config.movement.movementId
        .. "\nRuntime group: " .. self.runtimeGroupName
        .. "\nFighters: " .. config.movement.fighterCount
        .. "\nDestination: " .. config.transfer.destinationNodeId
    )

    startArrivalMonitor()
  end

  function controller:showActiveMovement()
    local movement = options.campaignState:getMovementSnapshot()
    if not movement then
      logger:info("red_relay_movement_status", {
        movementId = config.movement.movementId,
        movementState = "NONE",
      })
      announce("No TM02A movement has been created")
      return
    end

    local destinationMembership = nil
    local inspectionError = nil
    local observedSurvivorCount = nil
    if self.runtimeGroup then
      local destinationZone = ZONE:FindByName(config.zones.target)
      local inspectionOk, inspection = inspectGroup(
        self.runtimeGroup,
        nil,
        destinationZone,
        nil
      )
      if inspectionOk then
        destinationMembership = inspection.destinationZoneMembership
        observedSurvivorCount = inspection.survivorCount
      else
        inspectionError = inspection
      end
    end

    local fields = commonFields()
    fields.arrivalCredited = movement.arrivalCredited
    fields.arrivalMonitorActive = self.arrivalMonitorActive
    fields.destinationZoneMembership = destinationMembership == nil
      and "unavailable" or destinationMembership
    fields.failureReason = movement.failureReason or "none"
    fields.missionTimeSeconds = timer.getTime()
    fields.observedSurvivorCount = observedSurvivorCount == nil
      and "unavailable" or observedSurvivorCount
    fields.routeAssigned = movement.routeAssigned
    fields.survivorCount = movement.survivorCount
    if inspectionError then
      fields.inspectionError = inspectionError
    end
    logger:info("red_relay_movement_status", fields)

    announce(
      "Movement: " .. movement.movementId
        .. "\nState: " .. movement.movementState
        .. "\nRepresentation: " .. movement.representationState
        .. "\nRuntime group: " .. display(movement.runtimeGroupName)
        .. "\nSurvivors: " .. movement.survivorCount
        .. "\nObserved survivors: " .. display(observedSurvivorCount)
        .. "\nInside destination: " .. display(destinationMembership)
        .. "\nArrival credited: " .. tostring(movement.arrivalCredited)
        .. "\nArrival monitor active: " .. tostring(self.arrivalMonitorActive)
    )
  end

  return controller
end

return PhysicalRelayController
