local ConvoyCacheController = {}

local REPRESENTATION_VIRTUAL = "VIRTUAL"
local REPRESENTATION_PHYSICAL = "PHYSICAL"

local TRANSITION_IDLE = "IDLE"
local TRANSITION_MATERIALIZING = "MATERIALIZING"
local TRANSITION_DEMATERIALIZING = "DEMATERIALIZING"

local MOVEMENT_NOT_STARTED = "NOT_STARTED"
local MOVEMENT_VIRTUAL_MOVING = "VIRTUAL_MOVING"
local MOVEMENT_PHYSICAL_MOVING = "PHYSICAL_MOVING"
local MOVEMENT_ARRIVED = "ARRIVED"
local MOVEMENT_DESTROYED = "DESTROYED"
local MOVEMENT_AUTOMATION_FAILED = "AUTOMATION_FAILED"

local MOOSE_FORMATIONS = {
  ON_ROAD = "On Road",
}

local function copyArray(values)
  local copy = {}
  for index, value in ipairs(values or {}) do
    copy[index] = value
  end
  return copy
end

local function copyVec2(vec2)
  return { x = vec2.x, y = vec2.y }
end

local function joinNumbers(values)
  local text = {}
  for index, value in ipairs(values or {}) do
    text[index] = tostring(value)
  end
  return table.concat(text, ",")
end

local function makeSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[value] = true
  end
  return result
end

local function arraysEqual(left, right)
  if #(left or {}) ~= #(right or {}) then
    return false
  end
  for index, value in ipairs(left or {}) do
    if right[index] ~= value then
      return false
    end
  end
  return true
end

local function clamp(value, minimum, maximum)
  if value < minimum then
    return minimum
  end
  if value > maximum then
    return maximum
  end
  return value
end

local function distance2d(left, right)
  local dx = right.x - left.x
  local dy = right.y - left.y
  return math.sqrt(dx * dx + dy * dy)
end

local function interpolateVec2(left, right, fraction)
  return {
    x = left.x + (right.x - left.x) * fraction,
    y = left.y + (right.y - left.y) * fraction,
  }
end

local function atan2(y, x)
  if type(math.atan2) == "function" then
    return math.atan2(y, x)
  end
  if x > 0 then
    return math.atan(y / x)
  end
  if x < 0 and y >= 0 then
    return math.atan(y / x) + math.pi
  end
  if x < 0 and y < 0 then
    return math.atan(y / x) - math.pi
  end
  if x == 0 and y > 0 then
    return math.pi / 2
  end
  if x == 0 and y < 0 then
    return -math.pi / 2
  end
  return 0
end

local function headingDegrees(fromVec2, toVec2)
  local dx = toVec2.x - fromVec2.x
  local dy = toVec2.y - fromVec2.y
  local degrees = math.deg(atan2(dx, dy))
  while degrees < 0 do
    degrees = degrees + 360
  end
  while degrees >= 360 do
    degrees = degrees - 360
  end
  return degrees
end

local function formatDuration(seconds)
  local rounded = math.max(0, math.floor(seconds + 0.5))
  local hours = math.floor(rounded / 3600)
  local minutes = math.floor((rounded % 3600) / 60)
  local remainingSeconds = rounded % 60
  if hours > 0 then
    return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
  end
  return string.format("%02d:%02d", minutes, remainingSeconds)
end

local function parseSpawnSlot(unitName)
  if type(unitName) ~= "string" then
    return nil
  end
  local suffix = string.match(unitName, "%-(%d+)$")
  return suffix and tonumber(suffix) or nil
end

function ConvoyCacheController.new(options)
  local config = options.config
  local logger = options.logger
  local campaignState = options.campaignState

  if type(campaignState) ~= "table"
    or type(campaignState.getEntity) ~= "function"
    or type(campaignState.updateEntity) ~= "function"
    or type(campaignState.getEntitySnapshot) ~= "function" then
    error("a valid InMemoryCampaignState is required")
  end

  local entity = campaignState:getEntity(config.scenarioId)
  if type(entity) ~= "table" then
    error("CampaignState entity is unavailable: " .. tostring(config.scenarioId))
  end

  local controller = {
    campaignState = campaignState,
    entity = entity,
    spawner = nil,
    runtimeGroup = nil,
    routeAssignedGeneration = nil,
    retiredRuntimeGroupNames = {},
    pendingDematerialization = nil,
    routePlan = nil,
    virtualLeg = nil,
    schedulerId = nil,
    halted = false,
    arrivalLogged = false,
    lastError = nil,
    completedWindows = {},
    activeWindowIndex = nil,
    activeWindowWasOccupied = false,
    virtualMarker = nil,
    virtualMarkerLastUpdate = nil,
    windowMarkers = {},
  }

  local automationTick
  local pollPendingDematerialization
  local beginVirtualLeg
  local materializeWindow
  local beginDematerialization
  local finalizeDematerialization

  local function updateEntity(changes)
    controller.entity = controller.campaignState:updateEntity(config.scenarioId, changes)
    return controller.entity
  end

  local function currentWindow()
    local index = controller.activeWindowIndex or controller.entity.currentSectionIndex
    return controller.routePlan and controller.routePlan.windows[index] or nil
  end

  local function announce(text)
    options.announce(text)
  end

  local function commonFields()
    local window = currentWindow()
    local leg = controller.virtualLeg
    return {
      entityId = controller.entity.entityId,
      routeId = controller.entity.routeId,
      automationStarted = controller.entity.automationStarted == true,
      automationHalted = controller.halted,
      representationState = controller.entity.representationState,
      transitionState = controller.entity.transitionState,
      movementState = controller.entity.movementState,
      currentWindowIndex = controller.entity.currentSectionIndex,
      currentWindowId = window and window.id or "none",
      routeDistanceMeters = controller.entity.routeDistanceMeters,
      routeProgress = controller.routePlan and controller.entity.routeDistanceMeters / controller.routePlan.totalDistance or 0,
      physicalGeneration = controller.entity.physicalGeneration,
      runtimeGroupName = controller.entity.runtimeGroupName or "none",
      survivingVehicleSlots = joinNumbers(controller.entity.survivingVehicleSlots),
      pendingDematerialization = controller.pendingDematerialization ~= nil,
      virtualLegTargetKind = leg and leg.targetKind or "none",
      virtualLegWindowIndex = leg and leg.windowIndex or "none",
      revision = controller.entity.revision,
    }
  end

  local function logInfo(event, extra)
    local fields = commonFields()
    for key, value in pairs(extra or {}) do
      fields[key] = value
    end
    fields.missionTimeSeconds = timer.getTime()
    logger:info(event, fields)
  end

  local function removeVirtualMarker()
    if controller.virtualMarker then
      pcall(function()
        controller.virtualMarker:Remove()
      end)
      controller.virtualMarker = nil
      controller.virtualMarkerLastUpdate = nil
    end
  end

  local function haltAutomation(event, reason, movementState)
    controller.halted = true
    controller.lastError = tostring(reason)
    removeVirtualMarker()
    updateEntity({
      movementState = movementState or MOVEMENT_AUTOMATION_FAILED,
      transitionState = TRANSITION_IDLE,
    })
    local fields = commonFields()
    fields.reason = controller.lastError
    fields.missionTimeSeconds = timer.getTime()
    logger:error(event, fields)
    announce("Convoy automation halted: " .. controller.lastError)
    return false
  end

  local function reject(action, reason)
    logInfo("convoy_automation_command_rejected", {
      action = action,
      reason = reason,
    })
    announce(action .. " rejected: " .. reason)
    return false
  end

  local function ensureBootstrapReady(action)
    if options.getBootstrapOutcome() ~= "READY" then
      return reject(action, "bootstrap outcome is not READY")
    end
    return true
  end

  local function groupIsAlive(group)
    local ok, alive = pcall(function()
      return group and group:IsAlive() == true
    end)
    return ok and alive == true
  end

  local function nativeGroupExists(runtimeName)
    return pcall(function()
      local nativeGroup = Group.getByName(runtimeName)
      if not nativeGroup then
        return false
      end
      return nativeGroup:isExist() == true
    end)
  end

  local function ensureRetiredGroupsAreAbsent()
    for _, runtimeName in ipairs(controller.retiredRuntimeGroupNames) do
      local lookupOk, existsOrError = nativeGroupExists(runtimeName)
      if not lookupOk then
        return false, existsOrError
      end
      if existsOrError then
        return false, "retired runtime group still exists: " .. runtimeName
      end
    end
    return true
  end

  local function validateRepresentationInvariant()
    if controller.entity.representationState == REPRESENTATION_VIRTUAL then
      if controller.entity.runtimeGroupName ~= nil then
        return false, "virtual entity still has an authoritative runtime group name"
      end
      if controller.runtimeGroup and groupIsAlive(controller.runtimeGroup) then
        return false, "virtual entity still has a live physical group"
      end
      return true
    end

    if controller.entity.representationState == REPRESENTATION_PHYSICAL then
      if controller.entity.transitionState == TRANSITION_DEMATERIALIZING then
        if not controller.pendingDematerialization then
          return false, "dematerializing entity has no pending transition record"
        end
        return true
      end
      if not controller.runtimeGroup then
        return false, "physical entity has no runtime group wrapper"
      end
      if not groupIsAlive(controller.runtimeGroup) then
        return false, "physical entity runtime group is not alive"
      end
      return true
    end

    return false, "unknown representation state"
  end

  local function zoneByName(zoneName)
    local ok, zoneOrError = pcall(function()
      return ZONE:FindByName(zoneName)
    end)
    if not ok then
      return nil, zoneOrError
    end
    if not zoneOrError then
      return nil, "zone is unavailable: " .. tostring(zoneName)
    end
    return zoneOrError, nil
  end

  local function coordinateFromVec2(vec2)
    return COORDINATE:NewFromVec2(copyVec2(vec2))
  end

  local function pointAtDistance(routePlan, requestedDistance)
    local distance = clamp(requestedDistance, 0, routePlan.totalDistance)
    local points = routePlan.points
    if distance <= 0 then
      return copyVec2(points[1].vec2), 1
    end
    if distance >= routePlan.totalDistance then
      return copyVec2(points[#points].vec2), #points - 1
    end

    local low = 1
    local high = #points
    while low + 1 < high do
      local middle = math.floor((low + high) / 2)
      if points[middle].distance <= distance then
        low = middle
      else
        high = middle
      end
    end

    local left = points[low]
    local right = points[high]
    local span = right.distance - left.distance
    local fraction = span > 0 and (distance - left.distance) / span or 0
    return interpolateVec2(left.vec2, right.vec2, fraction), low
  end

  local function headingAtDistance(routePlan, distance)
    local offset = math.max(5, config.routing.routeSampleMeters / 2)
    local fromDistance = clamp(distance - offset, 0, routePlan.totalDistance)
    local toDistance = clamp(distance + offset, 0, routePlan.totalDistance)
    if toDistance <= fromDistance then
      return 0
    end
    local fromVec2 = pointAtDistance(routePlan, fromDistance)
    local toVec2 = pointAtDistance(routePlan, toDistance)
    return headingDegrees(fromVec2, toVec2)
  end

  local function appendUniqueVec2(values, vec2)
    local last = values[#values]
    if not last or distance2d(last, vec2) > 0.25 then
      values[#values + 1] = copyVec2(vec2)
    end
  end

  local function snapZoneToRoad(zoneName)
    local zone, zoneError = zoneByName(zoneName)
    if not zone then
      return nil, zoneError
    end
    local center = zone:GetCoordinate()
    local road = center:GetClosestPointToRoad(false)
    if not road then
      return nil, "no road point found near zone: " .. zoneName
    end
    local snapDistance = center:Get2DDistance(road)
    if snapDistance > config.routing.maximumRoadSnapMeters then
      return nil, "nearest road exceeds maximum snap distance for " .. zoneName
    end
    return road, snapDistance
  end

  local function buildGlobalRoutePlan()
    return pcall(function()
      local routeZoneNames = { config.zones.start }
      for _, zoneName in ipairs(config.zones.routeAnchors) do
        routeZoneNames[#routeZoneNames + 1] = zoneName
      end
      routeZoneNames[#routeZoneNames + 1] = config.zones.target

      local snappedCoordinates = {}
      local snapDistances = {}
      for index, zoneName in ipairs(routeZoneNames) do
        local coordinate, snapDistanceOrError = snapZoneToRoad(zoneName)
        if not coordinate then
          error(snapDistanceOrError)
        end
        snappedCoordinates[index] = coordinate
        snapDistances[index] = snapDistanceOrError
      end

      local rawVec2 = {}
      for index = 1, #snappedCoordinates - 1 do
        local fromCoordinate = snappedCoordinates[index]
        local toCoordinate = snappedCoordinates[index + 1]
        local path, _, gotPath = fromCoordinate:GetPathOnRoad(
          toCoordinate,
          true,
          false,
          false,
          false
        )
        if gotPath ~= true or type(path) ~= "table" or #path < 2 then
          error(
            "no valid road path between "
              .. routeZoneNames[index]
              .. " and "
              .. routeZoneNames[index + 1]
          )
        end
        for _, coordinate in ipairs(path) do
          local vec2 = coordinate:GetVec2()
          if type(vec2) ~= "table" then
            error("road path coordinate is unavailable")
          end
          appendUniqueVec2(rawVec2, vec2)
        end
      end

      if #rawVec2 < 2 then
        error("compiled road path has fewer than two points")
      end

      local points = {
        { vec2 = copyVec2(rawVec2[1]), distance = 0 },
      }
      local totalDistance = 0
      for index = 1, #rawVec2 - 1 do
        local left = rawVec2[index]
        local right = rawVec2[index + 1]
        local segmentLength = distance2d(left, right)
        if segmentLength > 0.1 then
          local steps = math.max(1, math.ceil(segmentLength / config.routing.routeSampleMeters))
          local previous = points[#points].vec2
          for step = 1, steps do
            local vec2 = interpolateVec2(left, right, step / steps)
            totalDistance = totalDistance + distance2d(previous, vec2)
            points[#points + 1] = {
              vec2 = vec2,
              distance = totalDistance,
            }
            previous = vec2
          end
        end
      end

      return {
        routeZoneNames = routeZoneNames,
        snapDistances = snapDistances,
        points = points,
        totalDistance = totalDistance,
        windows = {},
      }
    end)
  end

  local function boundaryDistance(zone, leftPoint, rightPoint, entering)
    local low = 0
    local high = 1
    for _ = 1, 18 do
      local middle = (low + high) / 2
      local vec2 = interpolateVec2(leftPoint.vec2, rightPoint.vec2, middle)
      local inside = zone:IsVec2InZone(vec2) == true
      if entering then
        if inside then
          high = middle
        else
          low = middle
        end
      else
        if inside then
          low = middle
        else
          high = middle
        end
      end
    end
    local fraction = entering and high or low
    return leftPoint.distance + (rightPoint.distance - leftPoint.distance) * fraction
  end

  local function findWindowInterval(routePlan, windowConfig, windowIndex)
    local zone, zoneError = zoneByName(windowConfig.zone)
    if not zone then
      return nil, zoneError
    end

    local radius = zone:GetRadius()
    if type(radius) ~= "number" or radius <= 0 then
      return nil, "reveal window is not a valid circular zone: " .. windowConfig.zone
    end

    local intervals = {}
    local points = routePlan.points
    local previousInside = zone:IsVec2InZone(points[1].vec2) == true
    local currentStart = previousInside and 0 or nil

    for index = 2, #points do
      local inside = zone:IsVec2InZone(points[index].vec2) == true
      if not previousInside and inside then
        currentStart = boundaryDistance(zone, points[index - 1], points[index], true)
      elseif previousInside and not inside then
        local currentEnd = boundaryDistance(zone, points[index - 1], points[index], false)
        intervals[#intervals + 1] = {
          entryDistance = currentStart,
          exitDistance = currentEnd,
        }
        currentStart = nil
      end
      previousInside = inside
    end

    if previousInside then
      intervals[#intervals + 1] = {
        entryDistance = currentStart,
        exitDistance = routePlan.totalDistance,
      }
    end

    if #intervals ~= 1 then
      return nil,
        "road path must cross reveal window exactly once: "
          .. windowConfig.zone
          .. " intervals="
          .. tostring(#intervals)
    end

    local interval = intervals[1]
    local formationLength = (config.template.expectedVehicleCount - 1)
      * config.routing.vehicleSpacingMeters
    local spawnLeadDistance = interval.entryDistance
      + config.routing.spawnInteriorMarginMeters
      + formationLength
    local virtualResumeDistance = interval.exitDistance
      + formationLength
      + config.routing.spawnInteriorMarginMeters
    local physicalRouteEndDistance = virtualResumeDistance
      + config.routing.physicalClearanceMeters

    if spawnLeadDistance >= interval.exitDistance - config.routing.spawnInteriorMarginMeters then
      return nil,
        "reveal window is too short for the complete road-aligned convoy: "
          .. windowConfig.zone
    end
    if physicalRouteEndDistance > routePlan.totalDistance then
      return nil, "reveal window exit is too close to route target: " .. windowConfig.zone
    end

    for slot = 1, config.template.expectedVehicleCount do
      local positionDistance = spawnLeadDistance
        - (slot - 1) * config.routing.vehicleSpacingMeters
      local vec2 = pointAtDistance(routePlan, positionDistance)
      if zone:IsVec2InZone(vec2) ~= true then
        return nil,
          "not all template vehicle positions fit inside reveal window: "
            .. windowConfig.zone
      end
      local coordinate = coordinateFromVec2(vec2)
      local nearestRoad = coordinate:GetClosestPointToRoad(false)
      if not nearestRoad then
        return nil, "road validation failed inside reveal window: " .. windowConfig.zone
      end
      if coordinate:Get2DDistance(nearestRoad) > config.routing.roadPositionToleranceMeters then
        return nil, "planned vehicle position is not on road: " .. windowConfig.zone
      end
    end

    return {
      id = windowConfig.id,
      zoneName = windowConfig.zone,
      zone = zone,
      radiusMeters = radius,
      diameterMeters = radius * 2,
      index = windowIndex,
      entryDistance = interval.entryDistance,
      exitDistance = interval.exitDistance,
      spawnLeadDistance = spawnLeadDistance,
      virtualResumeDistance = virtualResumeDistance,
      physicalRouteEndDistance = physicalRouteEndDistance,
      formationLengthMeters = formationLength,
    }, nil
  end

  local function compileRouteAndWindows()
    local routeOk, routePlanOrError = buildGlobalRoutePlan()
    if not routeOk then
      return false, routePlanOrError
    end
    local routePlan = routePlanOrError

    for index, windowConfig in ipairs(config.zones.revealWindows) do
      local window, windowError = findWindowInterval(routePlan, windowConfig, index)
      if not window then
        return false, windowError
      end
      routePlan.windows[index] = window
    end

    for index, window in ipairs(routePlan.windows) do
      if index > 1 then
        local previous = routePlan.windows[index - 1]
        if window.entryDistance <= previous.exitDistance then
          return false, "reveal windows overlap or are out of route order"
        end
        if window.spawnLeadDistance <= previous.virtualResumeDistance then
          return false, "insufficient virtual road distance between reveal windows"
        end
      end
    end

    controller.routePlan = routePlan
    logInfo("convoy_road_route_compiled", {
      totalDistanceMeters = routePlan.totalDistance,
      sampledPointCount = #routePlan.points,
      revealWindowCount = #routePlan.windows,
    })
    return true, routePlan
  end

  local function markerTextForVirtualLeg(leg, distance, remainingSeconds)
    local progress = 0
    if leg.endDistance > leg.startDistance then
      progress = (distance - leg.startDistance) / (leg.endDistance - leg.startDistance)
    end
    local destination
    if leg.targetKind == "WINDOW" then
      destination = controller.routePlan.windows[leg.windowIndex].id
    else
      destination = "JALALABAD"
    end
    return "TM01B - virtueller Konvoi"
      .. "\nNaechstes Ziel: " .. destination
      .. "\nETA: " .. formatDuration(remainingSeconds)
      .. "\nEtappe: " .. tostring(math.floor(clamp(progress, 0, 1) * 100 + 0.5)) .. "%"
  end

  local function updateVirtualMarker(distance, remainingSeconds, force)
    if config.virtualization.showVirtualMarker ~= true then
      return true
    end
    local now = timer.getTime()
    if not force
      and controller.virtualMarkerLastUpdate
      and now - controller.virtualMarkerLastUpdate < config.virtualization.virtualMarkerUpdateSeconds then
      return true
    end

    local vec2 = pointAtDistance(controller.routePlan, distance)
    local coordinate = coordinateFromVec2(vec2)
    local text = markerTextForVirtualLeg(controller.virtualLeg, distance, remainingSeconds)
    local ok, markerOrError = pcall(function()
      if not controller.virtualMarker then
        controller.virtualMarker = MARKER:New(coordinate, text):ReadOnly():ToBlue()
      else
        controller.virtualMarker:UpdateCoordinate(coordinate)
        controller.virtualMarker:UpdateText(text)
      end
      return controller.virtualMarker
    end)
    if not ok or not markerOrError then
      return haltAutomation("convoy_virtual_marker_failed", markerOrError)
    end
    controller.virtualMarkerLastUpdate = now
    return true
  end

  local function createWindowMarkers()
    if config.virtualization.showRevealWindowMarkers ~= true then
      return true
    end
    for index, window in ipairs(controller.routePlan.windows) do
      local ok, markerOrError = pcall(function()
        local text = window.id
          .. " - Sichtfenster"
          .. "\nDurchmesser: " .. tostring(math.floor(window.diameterMeters + 0.5)) .. " m"
          .. "\nInnen physisch / aussen virtuell"
        return MARKER:New(window.zone:GetCoordinate(), text):ReadOnly():ToBlue()
      end)
      if not ok or not markerOrError then
        return haltAutomation("convoy_window_marker_failed", markerOrError)
      end
      controller.windowMarkers[index] = markerOrError
    end
    return true
  end

  local function captureLiveUnits(group)
    return pcall(function()
      local units = group:GetUnits()
      if type(units) ~= "table" then
        error("runtime group units are unavailable")
      end

      local result = {}
      local seen = {}
      for _, unit in pairs(units) do
        if unit and unit:IsAlive() == true then
          local unitName = unit:GetName()
          local slot = parseSpawnSlot(unitName)
          if not slot then
            error("cannot parse vehicle slot from unit name: " .. tostring(unitName))
          end
          if slot < 1 or slot > config.template.expectedVehicleCount then
            error("parsed vehicle slot is outside configured range: " .. tostring(slot))
          end
          if seen[slot] then
            error("duplicate vehicle slot detected: " .. tostring(slot))
          end
          seen[slot] = true
          result[#result + 1] = {
            slot = slot,
            unit = unit,
          }
        end
      end

      table.sort(result, function(left, right)
        return left.slot < right.slot
      end)
      return result
    end)
  end

  local function slotsFromLiveUnits(liveUnits)
    local slots = {}
    for _, item in ipairs(liveUnits or {}) do
      slots[#slots + 1] = item.slot
    end
    return slots
  end

  local function captureSurvivingSlots(group)
    local ok, liveUnitsOrError = captureLiveUnits(group)
    if not ok then
      return false, liveUnitsOrError
    end
    local slots = slotsFromLiveUnits(liveUnitsOrError)
    if #slots < 1 then
      return false, "no surviving vehicle slots remain"
    end
    return true, slots
  end

  local function pruneSpawnedGroupToSlots(group, survivingSlots)
    return pcall(function()
      local allowed = makeSet(survivingSlots)
      local observed = {}
      local units = group:GetUnits()
      if type(units) ~= "table" then
        error("spawned group units are unavailable")
      end

      for _, unit in pairs(units) do
        if unit and unit:IsAlive() == true then
          local slot = parseSpawnSlot(unit:GetName())
          if not slot then
            error("cannot parse spawned vehicle slot")
          end
          if allowed[slot] then
            observed[slot] = true
          else
            unit:Destroy(false)
          end
        end
      end

      for _, slot in ipairs(survivingSlots) do
        if not observed[slot] then
          error("required surviving slot was not spawned: " .. tostring(slot))
        end
      end
      return #survivingSlots
    end)
  end

  local function buildAbsoluteVehiclePositions(window)
    local positions = {}
    for slot = 1, config.template.expectedVehicleCount do
      local distance = window.spawnLeadDistance
        - (slot - 1) * config.routing.vehicleSpacingMeters
      local vec2 = pointAtDistance(controller.routePlan, distance)
      if window.zone:IsVec2InZone(vec2) ~= true then
        return nil, "vehicle position falls outside reveal window"
      end
      local coordinate = coordinateFromVec2(vec2)
      local nearestRoad = coordinate:GetClosestPointToRoad(false)
      if not nearestRoad
        or coordinate:Get2DDistance(nearestRoad) > config.routing.roadPositionToleranceMeters then
        return nil, "vehicle position is not on the road centerline"
      end
      positions[slot] = {
        x = vec2.x,
        y = vec2.y,
        heading = headingAtDistance(controller.routePlan, distance),
      }
    end
    return positions, nil
  end

  local function buildPhysicalRoute(window)
    return pcall(function()
      local formation = MOOSE_FORMATIONS[config.routing.formation]
      if config.routing.roadOnly ~= true or not formation then
        error("road-only ON_ROAD routing configuration is required")
      end

      local waypoints = {}
      local waypointDistances = {}
      local startDistance = window.spawnLeadDistance
      local endDistance = window.physicalRouteEndDistance
      local distance = startDistance + config.routing.physicalWaypointSpacingMeters

      while distance < endDistance do
        local coordinate = coordinateFromVec2(pointAtDistance(controller.routePlan, distance))
        waypoints[#waypoints + 1] = coordinate:WaypointGround(config.routing.speedKph, formation)
        waypointDistances[#waypointDistances + 1] = distance
        distance = distance + config.routing.physicalWaypointSpacingMeters
      end

      local endCoordinate = coordinateFromVec2(pointAtDistance(controller.routePlan, endDistance))
      waypoints[#waypoints + 1] = endCoordinate:WaypointGround(config.routing.speedKph, formation)
      waypointDistances[#waypointDistances + 1] = endDistance

      if #waypoints < 1 then
        error("physical reveal-window route contains no waypoints")
      end

      return {
        waypoints = waypoints,
        waypointDistances = waypointDistances,
      }
    end)
  end

  local function destroyGroupSilently(group)
    return pcall(function()
      group:Destroy(false)
    end)
  end

  beginVirtualLeg = function(startDistance, endDistance, targetKind, windowIndex)
    if endDistance <= startDistance then
      return haltAutomation("convoy_virtual_leg_failed", "virtual leg has no positive road distance")
    end
    local speedMetersPerSecond = config.virtualization.effectiveSpeedKph / 3.6
    local durationSeconds = math.max(
      config.virtualization.minimumVirtualLegSeconds,
      (endDistance - startDistance) / speedMetersPerSecond
    )
    local now = timer.getTime()

    controller.virtualLeg = {
      startDistance = startDistance,
      endDistance = endDistance,
      targetKind = targetKind,
      windowIndex = windowIndex,
      durationSeconds = durationSeconds,
      startedAt = now,
    }

    updateEntity({
      clearFields = { "runtimeGroupName" },
      representationState = REPRESENTATION_VIRTUAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_VIRTUAL_MOVING,
      routeDistanceMeters = startDistance,
      segmentProgress = 0,
      lastMovementUpdateCampaignTime = now,
    })

    local markerOk = updateVirtualMarker(startDistance, durationSeconds, true)
    if markerOk == false then
      return false
    end

    logInfo("convoy_virtual_leg_started", {
      startDistanceMeters = startDistance,
      endDistanceMeters = endDistance,
      roadDistanceMeters = endDistance - startDistance,
      durationSeconds = durationSeconds,
      effectiveSpeedKph = config.virtualization.effectiveSpeedKph,
      targetKind = targetKind,
      targetWindowIndex = windowIndex or "none",
    })
    return true
  end

  local function tickVirtual()
    local leg = controller.virtualLeg
    if not leg then
      return haltAutomation("convoy_virtual_tick_failed", "virtual entity has no active virtual leg")
    end

    local now = timer.getTime()
    local progress = clamp((now - leg.startedAt) / leg.durationSeconds, 0, 1)
    local distance = leg.startDistance + (leg.endDistance - leg.startDistance) * progress
    local remainingSeconds = math.max(0, leg.durationSeconds - (now - leg.startedAt))

    updateEntity({
      routeDistanceMeters = distance,
      segmentProgress = progress,
      lastMovementUpdateCampaignTime = now,
    })

    if updateVirtualMarker(distance, remainingSeconds, false) == false then
      return false
    end

    if progress < 1 then
      return true
    end

    controller.virtualLeg = nil
    updateEntity({
      routeDistanceMeters = leg.endDistance,
      segmentProgress = 1,
      lastMovementUpdateCampaignTime = now,
    })

    if leg.targetKind == "WINDOW" then
      local window = controller.routePlan.windows[leg.windowIndex]
      if not window then
        return haltAutomation("convoy_virtual_arrival_failed", "reveal window is unavailable")
      end
      updateEntity({
        currentSectionIndex = leg.windowIndex,
        segmentProgress = 0,
      })
      logInfo("convoy_reveal_window_reached", {
        revealWindowId = window.id,
        revealZoneName = window.zoneName,
        triggerDistanceMeters = window.spawnLeadDistance,
      })
      return materializeWindow(window)
    end

    if leg.targetKind == "TARGET" then
      removeVirtualMarker()
      updateEntity({
        routeDistanceMeters = controller.routePlan.totalDistance,
        segmentProgress = 1,
        movementState = MOVEMENT_ARRIVED,
      })
      if not controller.arrivalLogged then
        controller.arrivalLogged = true
        logInfo("convoy_route_arrived", {
          targetZoneName = config.zones.target,
        })
      end
      announce("Convoy arrived virtually at " .. config.zones.target)
      return true
    end

    return haltAutomation("convoy_virtual_arrival_failed", "unknown virtual target kind")
  end

  materializeWindow = function(window)
    local retiredOk, retiredError = ensureRetiredGroupsAreAbsent()
    if not retiredOk then
      return haltAutomation("convoy_materialization_failed", retiredError)
    end
    if controller.completedWindows[window.index] then
      return haltAutomation("convoy_materialization_failed", "reveal window has already completed")
    end

    local positions, positionsError = buildAbsoluteVehiclePositions(window)
    if not positions then
      return haltAutomation("convoy_spawn_site_unavailable", positionsError)
    end
    local routeOk, routeOrError = buildPhysicalRoute(window)
    if not routeOk then
      return haltAutomation("convoy_physical_route_failed", routeOrError)
    end

    removeVirtualMarker()
    updateEntity({ transitionState = TRANSITION_MATERIALIZING })

    local nextGeneration = controller.entity.physicalGeneration + 1
    local alias = config.template.runtimeAliasPrefix
      .. "_G" .. string.format("%02d", nextGeneration)

    local constructionOk, spawnerOrError = pcall(function()
      return SPAWN:NewWithAlias(config.template.groupName, alias)
        :InitSetUnitAbsolutePositions(positions)
    end)
    if not constructionOk or type(spawnerOrError) ~= "table" then
      return haltAutomation(
        "convoy_materialization_failed",
        constructionOk and "SPAWN absolute-position initialization returned no spawner" or spawnerOrError
      )
    end

    local spawnOk, groupOrError = pcall(function()
      return spawnerOrError:Spawn()
    end)
    if not spawnOk or type(groupOrError) ~= "table" then
      return haltAutomation(
        "convoy_materialization_failed",
        spawnOk and "SPAWN:Spawn did not return a GROUP wrapper" or groupOrError
      )
    end

    local runtimeGroup = groupOrError
    local pruneOk, livingCountOrError = pruneSpawnedGroupToSlots(
      runtimeGroup,
      controller.entity.survivingVehicleSlots
    )
    if not pruneOk then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation("convoy_materialization_failed", livingCountOrError)
    end

    local assignmentOk, assignmentResult = pcall(function()
      return runtimeGroup:Route(routeOrError.waypoints, 0)
    end)
    if not assignmentOk or not assignmentResult then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation(
        "convoy_physical_route_failed",
        assignmentOk and "route assignment returned nil" or assignmentResult
      )
    end

    local inspectionOk, runtimeNameOrError = pcall(function()
      return runtimeGroup:GetName()
    end)
    if not inspectionOk or type(runtimeNameOrError) ~= "string" then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation("convoy_materialization_failed", runtimeNameOrError)
    end

    controller.spawner = spawnerOrError
    controller.runtimeGroup = runtimeGroup
    controller.routeAssignedGeneration = nextGeneration
    controller.activeWindowIndex = window.index
    controller.activeWindowWasOccupied = true
    controller.lastError = nil

    updateEntity({
      physicalGeneration = nextGeneration,
      runtimeGroupName = runtimeNameOrError,
      representationState = REPRESENTATION_PHYSICAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_PHYSICAL_MOVING,
      routeDistanceMeters = window.spawnLeadDistance,
      segmentProgress = 0,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })

    local invariantOk, invariantError = validateRepresentationInvariant()
    if not invariantOk then
      destroyGroupSilently(runtimeGroup)
      controller.runtimeGroup = nil
      controller.spawner = nil
      return haltAutomation("convoy_materialization_failed", invariantError)
    end

    logInfo("convoy_automatically_materialized", {
      revealWindowId = window.id,
      revealZoneName = window.zoneName,
      revealWindowDiameterMeters = window.diameterMeters,
      runtimeGroupName = runtimeNameOrError,
      livingUnitCount = livingCountOrError,
      vehicleSpacingMeters = config.routing.vehicleSpacingMeters,
      allTemplateSlotsPlacedOnRoad = true,
      allTemplateSlotsInsideWindow = true,
      physicalWaypointCount = #routeOrError.waypoints,
    })
    announce(
      "Convoy visible in " .. window.id
        .. "\nZone: " .. window.zoneName
        .. "\nAll vehicles spawned on road"
    )
    return true
  end

  local function tickPhysical()
    if not controller.runtimeGroup or not groupIsAlive(controller.runtimeGroup) then
      updateEntity({ movementState = MOVEMENT_DESTROYED })
      controller.halted = true
      logInfo("convoy_destroyed", {})
      announce("Convoy destroyed; automation stopped")
      return false
    end

    local window = currentWindow()
    if not window then
      return haltAutomation("convoy_window_monitor_failed", "active reveal window is unavailable")
    end

    local liveOk, liveUnitsOrError = captureLiveUnits(controller.runtimeGroup)
    if not liveOk then
      return haltAutomation("convoy_window_monitor_failed", liveUnitsOrError)
    end
    local liveSlots = slotsFromLiveUnits(liveUnitsOrError)
    if #liveSlots < 1 then
      updateEntity({ movementState = MOVEMENT_DESTROYED })
      controller.halted = true
      logInfo("convoy_destroyed", {})
      announce("Convoy destroyed; automation stopped")
      return false
    end

    if not arraysEqual(liveSlots, controller.entity.survivingVehicleSlots) then
      updateEntity({ survivingVehicleSlots = copyArray(liveSlots) })
      logInfo("convoy_losses_observed", {
        survivingVehicleSlots = joinNumbers(liveSlots),
      })
    end

    local insideCount = 0
    for _, item in ipairs(liveUnitsOrError) do
      local vec2Ok, vec2OrError = pcall(function()
        return item.unit:GetVec2()
      end)
      if not vec2Ok then
        return haltAutomation("convoy_window_monitor_failed", vec2OrError)
      end
      if window.zone:IsVec2InZone(vec2OrError) == true then
        insideCount = insideCount + 1
      end
    end

    if insideCount > 0 then
      controller.activeWindowWasOccupied = true
      return true
    end

    if controller.activeWindowWasOccupied then
      logInfo("convoy_reveal_window_cleared", {
        revealWindowId = window.id,
        revealZoneName = window.zoneName,
        survivingVehicleCount = #liveSlots,
      })
      return beginDematerialization(window)
    end

    return true
  end

  beginDematerialization = function(window)
    if controller.pendingDematerialization then
      return true
    end

    local slotsOk, survivingSlotsOrError = captureSurvivingSlots(controller.runtimeGroup)
    if not slotsOk then
      return haltAutomation("convoy_dematerialization_failed", survivingSlotsOrError)
    end

    local pending = {
      runtimeGroupName = controller.entity.runtimeGroupName,
      windowId = window.id,
      windowIndex = window.index,
      zoneName = window.zoneName,
      resumeDistance = window.virtualResumeDistance,
      startedAt = timer.getTime(),
      attempts = 0,
    }
    controller.pendingDematerialization = pending

    updateEntity({
      transitionState = TRANSITION_DEMATERIALIZING,
      survivingVehicleSlots = copyArray(survivingSlotsOrError),
      routeDistanceMeters = window.virtualResumeDistance,
      segmentProgress = 1,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        pollPendingDematerialization,
        nil,
        timer.getTime() + config.virtualization.destroyConfirmationPollSeconds
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      return haltAutomation(
        "convoy_dematerialization_failed",
        scheduleOk and "destruction confirmation scheduler returned nil" or scheduleResult
      )
    end

    local destructionOk, destructionError = destroyGroupSilently(controller.runtimeGroup)
    if not destructionOk then
      return haltAutomation("convoy_dematerialization_failed", destructionError)
    end

    logInfo("convoy_automatic_dematerialization_started", {
      revealWindowId = window.id,
      revealZoneName = window.zoneName,
      survivingVehicleSlots = joinNumbers(survivingSlotsOrError),
    })
    return true
  end

  finalizeDematerialization = function(pending)
    if controller.pendingDematerialization ~= pending then
      return false
    end

    controller.retiredRuntimeGroupNames[#controller.retiredRuntimeGroupNames + 1] = pending.runtimeGroupName
    controller.completedWindows[pending.windowIndex] = true
    controller.pendingDematerialization = nil
    controller.runtimeGroup = nil
    controller.spawner = nil
    controller.routeAssignedGeneration = nil
    controller.activeWindowIndex = nil
    controller.activeWindowWasOccupied = false

    updateEntity({
      clearFields = { "runtimeGroupName" },
      representationState = REPRESENTATION_VIRTUAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_VIRTUAL_MOVING,
      routeDistanceMeters = pending.resumeDistance,
      segmentProgress = 0,
    })

    logInfo("convoy_automatically_dematerialized", {
      revealWindowId = pending.windowId,
      revealZoneName = pending.zoneName,
      retiredRuntimeGroupName = pending.runtimeGroupName,
      destroyConfirmationAttempts = pending.attempts,
      virtualResumeDistanceMeters = pending.resumeDistance,
    })
    announce("Convoy virtual after " .. pending.windowId)

    local nextWindowIndex = pending.windowIndex + 1
    local nextWindow = controller.routePlan.windows[nextWindowIndex]
    if nextWindow then
      return beginVirtualLeg(
        pending.resumeDistance,
        nextWindow.spawnLeadDistance,
        "WINDOW",
        nextWindowIndex
      )
    end

    return beginVirtualLeg(
      pending.resumeDistance,
      controller.routePlan.totalDistance,
      "TARGET",
      nil
    )
  end

  pollPendingDematerialization = function(_, scheduledTime)
    local pending = controller.pendingDematerialization
    if not pending then
      return nil
    end

    pending.attempts = pending.attempts + 1
    local lookupOk, existsOrError = nativeGroupExists(pending.runtimeGroupName)
    if lookupOk and existsOrError == false then
      finalizeDematerialization(pending)
      return nil
    end

    local elapsed = timer.getTime() - pending.startedAt
    if elapsed >= config.virtualization.destroyConfirmationTimeoutSeconds then
      local reason = lookupOk
        and "native runtime group still exists after destruction timeout"
        or "native destruction confirmation failed: " .. tostring(existsOrError)
      haltAutomation("convoy_dematerialization_failed", reason)
      return nil
    end

    return scheduledTime + config.virtualization.destroyConfirmationPollSeconds
  end

  function controller:tick()
    if self.halted then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return true
    end
    if self.entity.representationState == REPRESENTATION_VIRTUAL
      and self.entity.movementState == MOVEMENT_VIRTUAL_MOVING then
      return tickVirtual()
    end
    if self.entity.representationState == REPRESENTATION_PHYSICAL
      and self.entity.movementState == MOVEMENT_PHYSICAL_MOVING then
      return tickPhysical()
    end
    return true
  end

  automationTick = function(_, scheduledTime)
    if controller.halted
      or controller.entity.movementState == MOVEMENT_ARRIVED
      or controller.entity.movementState == MOVEMENT_DESTROYED then
      return nil
    end

    local ok, resultOrError = pcall(function()
      return controller:tick()
    end)
    if not ok then
      haltAutomation("convoy_automation_tick_failed", resultOrError)
      return nil
    end
    if resultOrError == false or controller.halted then
      return nil
    end

    return scheduledTime + config.virtualization.automationPollSeconds
  end

  function controller:start()
    local action = "Start convoy"
    if not ensureBootstrapReady(action) then
      return false
    end
    if self.entity.automationStarted == true then
      return reject(action, "automation has already been started")
    end
    if self.entity.movementState ~= MOVEMENT_NOT_STARTED then
      return reject(action, "convoy is not in NOT_STARTED state")
    end

    local compileOk, compileResultOrError = compileRouteAndWindows()
    if not compileOk then
      return haltAutomation("convoy_route_plan_failed", compileResultOrError)
    end
    if createWindowMarkers() == false then
      return false
    end

    local firstWindow = controller.routePlan.windows[config.virtualization.initialSectionIndex]
    if not firstWindow then
      return haltAutomation("convoy_automation_start_failed", "initial reveal window is unavailable")
    end

    updateEntity({ automationStarted = true })
    local legOk = beginVirtualLeg(
      0,
      firstWindow.spawnLeadDistance,
      "WINDOW",
      config.virtualization.initialSectionIndex
    )
    if not legOk then
      return false
    end

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        automationTick,
        nil,
        timer.getTime() + 0.1
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      return haltAutomation(
        "convoy_automation_start_failed",
        scheduleOk and "automation scheduler returned nil" or scheduleResult
      )
    end

    self.schedulerId = scheduleResult
    logInfo("convoy_automation_started", {
      schedulerId = scheduleResult,
      startZoneName = config.zones.start,
      firstRevealWindowId = firstWindow.id,
      firstRevealZoneName = firstWindow.zoneName,
      globalRoadDistanceMeters = controller.routePlan.totalDistance,
    })
    announce(
      "Convoy automation started"
        .. "\nVirtual marker active"
        .. "\nFirst reveal: " .. firstWindow.id
    )
    return true
  end

  function controller:showStatus()
    local invariantOk, invariantError = validateRepresentationInvariant()
    local fields = commonFields()
    fields.invariantOk = invariantOk
    fields.lastError = controller.lastError or "none"
    fields.missionTimeSeconds = timer.getTime()
    if not invariantOk then
      fields.invariantError = invariantError
    end
    logger:info("convoy_cache_status", fields)

    local leg = controller.virtualLeg
    local eta = "none"
    if leg then
      eta = formatDuration(math.max(0, leg.durationSeconds - (timer.getTime() - leg.startedAt)))
    end
    announce(
      "Entity: " .. controller.entity.entityId
        .. "\nStarted: " .. tostring(controller.entity.automationStarted == true)
        .. "\nRepresentation: " .. controller.entity.representationState
        .. "\nMovement: " .. controller.entity.movementState
        .. "\nTransition: " .. controller.entity.transitionState
        .. "\nWindow: " .. tostring(currentWindow() and currentWindow().id or "none")
        .. "\nRuntime group: " .. tostring(controller.entity.runtimeGroupName or "none")
        .. "\nVehicle slots: " .. joinNumbers(controller.entity.survivingVehicleSlots)
        .. "\nRoute distance: " .. tostring(math.floor(controller.entity.routeDistanceMeters + 0.5)) .. " m"
        .. "\nVirtual ETA: " .. eta
        .. "\nInvariant: " .. tostring(invariantOk)
        .. "\nError: " .. tostring(controller.lastError or "none")
    )
  end

  function controller:getState()
    return self.campaignState:getEntitySnapshot(config.scenarioId)
  end

  return controller
end

return ConvoyCacheController
