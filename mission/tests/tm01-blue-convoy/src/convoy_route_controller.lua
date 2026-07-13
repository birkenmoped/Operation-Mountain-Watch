local ConvoyRouteController = {}

local STATE_NOT_READY = "NOT_READY"
local STATE_READY = "READY"
local STATE_STARTING = "STARTING"
local STATE_EN_ROUTE = "EN_ROUTE"
local STATE_ARRIVED = "ARRIVED"
local STATE_ROUTE_FAILED = "ROUTE_FAILED"
local STATE_DESTROYED = "DESTROYED"

local MOOSE_FORMATIONS = {
  ON_ROAD = "On Road",
}

local function displayValue(value)
  if value == nil then
    return "none"
  end
  return tostring(value)
end

function ConvoyRouteController.new(options)
  local config = options.config
  local logger = options.logger
  local route = {
    state = STATE_NOT_READY,
    routeAssignmentAttempted = false,
    routeAssigned = false,
    runtimeGroupName = nil,
    currentUnitCount = nil,
    targetZoneMembership = nil,
    waypointCount = 0,
    arrivalLogged = false,
  }

  local function commonFields()
    return {
      entityId = config.scenarioId,
      routeId = config.routeId,
      routeState = route.state,
      runtimeGroupName = route.runtimeGroupName or "none",
      configuredSpeedKph = config.routing.speedKph,
      formation = config.routing.formation,
      roadOnly = config.routing.roadOnly,
      routeAssigned = route.routeAssigned,
    }
  end

  local function announce(text)
    options.announce(text)
  end

  local function logRejected(reason)
    local fields = commonFields()
    fields.reason = reason
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_route_rejected", fields)
    announce(
      "Convoy route rejected: " .. reason
        .. "\nRoute state: " .. route.state
        .. "\nRuntime group: " .. displayValue(route.runtimeGroupName)
    )
  end

  local function logFailed(reason)
    local reasonText = tostring(reason)
    route.state = STATE_ROUTE_FAILED
    local fields = commonFields()
    fields.reason = reasonText
    fields.missionTimeSeconds = timer.getTime()
    logger:error("convoy_route_failed", fields)
    announce("Convoy route failed: " .. reasonText)
  end

  local function getPhysicalSnapshot()
    local ok, snapshot = pcall(function()
      return options.physicalConvoyController:getRouteHandoff()
    end)
    if not ok then
      return false, snapshot
    end
    if type(snapshot) ~= "table" then
      return false, "physical convoy handoff is unavailable"
    end
    if not snapshot.inspectionOk then
      return false, snapshot.inspectionError or "physical convoy inspection failed"
    end
    return true, snapshot
  end

  local function inspectRuntimeGroup(snapshot, targetZone)
    return pcall(function()
      local group = snapshot.runtimeGroup
      if type(group) ~= "table" then
        error("runtime group wrapper is unavailable")
      end
      local targetZoneMembership = nil
      if targetZone then
        targetZoneMembership = group:IsCompletelyInZone(targetZone) == true
      end
      return {
        actualRuntimeGroupName = group:GetName(),
        alive = group:IsAlive() == true,
        livingUnitCount = group:CountAliveUnits(),
        targetZoneMembership = targetZoneMembership,
      }
    end)
  end

  local function evaluateReadiness()
    local snapshotOk, snapshot = getPhysicalSnapshot()
    if not snapshotOk then
      return false, snapshot
    end

    route.runtimeGroupName = snapshot.runtimeGroupName
    route.currentUnitCount = snapshot.currentUnitCount

    if snapshot.state == "DESTROYED" then
      route.state = STATE_DESTROYED
      return false, "physical convoy is destroyed"
    end
    if snapshot.state == "NOT_SPAWNED" then
      route.state = STATE_NOT_READY
      return false, "physical convoy has not been spawned"
    end
    if snapshot.state == "SPAWNING" then
      route.state = STATE_NOT_READY
      return false, "physical convoy is still spawning"
    end
    if snapshot.state == "SPAWN_FAILED" then
      route.state = STATE_NOT_READY
      return false, "physical convoy spawn failed"
    end
    if snapshot.state ~= "SPAWNED" then
      route.state = STATE_NOT_READY
      return false, "physical convoy is not ready"
    end
    if options.getBootstrapOutcome() ~= "READY" then
      route.state = STATE_NOT_READY
      return false, "bootstrap outcome is not READY"
    end
    if type(snapshot.runtimeGroup) ~= "table" then
      route.state = STATE_NOT_READY
      return false, "runtime group wrapper is unavailable"
    end

    local inspectionOk, inspection = inspectRuntimeGroup(snapshot, nil)
    if not inspectionOk then
      return false, inspection
    end
    route.runtimeGroupName = inspection.actualRuntimeGroupName or route.runtimeGroupName
    route.currentUnitCount = inspection.livingUnitCount

    if inspection.livingUnitCount < 1 then
      route.state = STATE_DESTROYED
      options.physicalConvoyController:markDestroyed()
      return false, "runtime group has no living units"
    end
    if not inspection.alive and not route.routeAssigned then
      route.state = STATE_NOT_READY
      return false, "runtime group is not alive"
    end
    if type(snapshot.runtimeGroupName) ~= "string"
      or inspection.actualRuntimeGroupName ~= snapshot.runtimeGroupName then
      route.state = STATE_NOT_READY
      return false, "actual runtime group name does not match tracked group"
    end
    if inspection.actualRuntimeGroupName == config.template.groupName then
      route.state = STATE_NOT_READY
      return false, "refusing to route the original template"
    end

    if route.state == STATE_NOT_READY or route.state == STATE_READY then
      route.state = STATE_READY
    end
    return true, {
      snapshot = snapshot,
      inspection = inspection,
    }
  end

  local function buildDeterministicRoute()
    return pcall(function()
      local routeZoneNames = {}
      for index, zoneName in ipairs(config.zones.routeAnchors) do
        routeZoneNames[index] = zoneName
      end
      routeZoneNames[#routeZoneNames + 1] = config.zones.target

      local formation = MOOSE_FORMATIONS[config.routing.formation]
      if config.routing.roadOnly ~= true or not formation then
        error("road-only ON_ROAD routing configuration is required")
      end

      local waypoints = {}
      local zones = {}
      for index, zoneName in ipairs(routeZoneNames) do
        local zone = ZONE:FindByName(zoneName)
        if not zone then
          error("route zone is unavailable: " .. zoneName)
        end
        local coordinate = zone:GetCoordinate()
        if not coordinate then
          error("route-zone coordinate is unavailable: " .. zoneName)
        end
        local waypoint = coordinate:WaypointGround(config.routing.speedKph, formation)
        if type(waypoint) ~= "table" then
          error("ground waypoint construction failed: " .. zoneName)
        end
        zones[index] = zone
        waypoints[index] = waypoint
      end

      if #waypoints ~= #config.zones.routeAnchors + 1 then
        error("route waypoint count is incomplete")
      end

      return {
        waypoints = waypoints,
        targetZone = zones[#zones],
        firstRouteZoneName = routeZoneNames[1],
        finalTargetZoneName = routeZoneNames[#routeZoneNames],
      }
    end)
  end

  function route:start()
    local requestedFields = commonFields()
    requestedFields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_route_requested", requestedFields)

    if self.state == STATE_STARTING or self.state == STATE_EN_ROUTE then
      logRejected("route has already started")
      return
    end
    if self.state == STATE_ARRIVED then
      logRejected("route has already arrived")
      return
    end
    if self.state == STATE_ROUTE_FAILED then
      logRejected("route assignment previously failed")
      return
    end
    if self.state == STATE_DESTROYED then
      logRejected("physical convoy is destroyed")
      return
    end
    if self.routeAssignmentAttempted or self.routeAssigned then
      logRejected("route assignment has already been attempted")
      return
    end

    local readinessOk, readiness = evaluateReadiness()
    if not readinessOk then
      logRejected(readiness)
      return
    end

    self.state = STATE_STARTING
    local constructionOk, routeDefinition = buildDeterministicRoute()
    if not constructionOk then
      logFailed(routeDefinition)
      return
    end

    local runtimeGroup = readiness.snapshot.runtimeGroup
    self.routeAssignmentAttempted = true
    local assignmentOk, assignmentResult = pcall(function()
      return runtimeGroup:Route(routeDefinition.waypoints, 0)
    end)
    if not assignmentOk or not assignmentResult then
      logFailed(assignmentOk and "route assignment returned nil" or assignmentResult)
      return
    end

    self.routeAssigned = true
    self.waypointCount = #routeDefinition.waypoints
    self.state = STATE_EN_ROUTE

    local fields = commonFields()
    fields.anchorCount = #config.zones.routeAnchors
    fields.totalWaypointCount = self.waypointCount
    fields.firstRouteZoneName = routeDefinition.firstRouteZoneName
    fields.finalTargetZoneName = routeDefinition.finalTargetZoneName
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_route_started", fields)
    announce(
      "Convoy route started"
        .. "\nRuntime group: " .. self.runtimeGroupName
        .. "\nWaypoints: " .. self.waypointCount
        .. "\nSpeed: " .. config.routing.speedKph .. " km/h"
    )
  end

  function route:showStatus()
    local readinessOk, readiness = evaluateReadiness()
    local targetZone = nil

    local targetLookupOk, targetOrError = pcall(function()
      return ZONE:FindByName(config.zones.target)
    end)
    if targetLookupOk then
      targetZone = targetOrError
    end

    if readinessOk and targetZone then
      local inspectionOk, inspection = inspectRuntimeGroup(readiness.snapshot, targetZone)
      if inspectionOk then
        self.runtimeGroupName = inspection.actualRuntimeGroupName or self.runtimeGroupName
        self.currentUnitCount = inspection.livingUnitCount
        self.targetZoneMembership = inspection.targetZoneMembership

        if inspection.livingUnitCount < 1 then
          self.state = STATE_DESTROYED
          options.physicalConvoyController:markDestroyed()
        elseif self.routeAssigned and inspection.targetZoneMembership then
          self.state = STATE_ARRIVED
          if not self.arrivalLogged then
            self.arrivalLogged = true
            local arrivalFields = commonFields()
            arrivalFields.livingUnitCount = inspection.livingUnitCount
            arrivalFields.missionTimeSeconds = timer.getTime()
            arrivalFields.targetZoneName = config.zones.target
            arrivalFields.targetZoneMembership = true
            logger:info("convoy_route_arrived", arrivalFields)
          end
        end
      else
        readinessOk = false
        readiness = inspection
      end
    elseif not targetLookupOk then
      readinessOk = false
      readiness = targetOrError
    elseif not targetZone then
      readinessOk = false
      readiness = "target zone is unavailable"
    end

    local fields = commonFields()
    fields.currentLivingUnitCount = self.currentUnitCount or "unavailable"
    fields.missionTimeSeconds = timer.getTime()
    fields.targetZoneMembership = self.targetZoneMembership == nil
      and "unavailable" or self.targetZoneMembership
    fields.totalWaypointCount = self.waypointCount
    if not readinessOk then
      fields.inspectionError = readiness
    end
    logger:info("convoy_route_status", fields)

    announce(
      "Entity: " .. config.scenarioId
        .. "\nRoute: " .. config.routeId
        .. "\nRoute state: " .. self.state
        .. "\nRuntime group: " .. displayValue(self.runtimeGroupName)
        .. "\nSpeed: " .. config.routing.speedKph .. " km/h"
        .. "\nLiving units: " .. displayValue(self.currentUnitCount)
        .. "\nInside target: " .. displayValue(self.targetZoneMembership)
        .. "\nRoute assigned: " .. tostring(self.routeAssigned)
    )
  end

  return route
end

return ConvoyRouteController
