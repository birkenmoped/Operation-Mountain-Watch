local TM01M = {}

local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"

local function join(values)
  return #(values or {}) > 0 and table.concat(values, ",") or "none"
end

local function rounded(value)
  if value == nil then return nil end
  return math.floor(value + 0.5)
end

local function copyVec2(vec2)
  return { x = vec2.x, y = vec2.y }
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

local function headingDegrees(fromVec2, toVec2)
  local north = toVec2.x - fromVec2.x
  local east = toVec2.y - fromVec2.y
  local heading = math.deg(math.atan2(east, north))
  if heading < 0 then heading = heading + 360 end
  return heading
end

local function reverseArray(values)
  local reversed = {}
  for index = #values, 1, -1 do
    reversed[#reversed + 1] = values[index]
  end
  return reversed
end

function TM01M.start(dependencies)
  local config = assert(dependencies.config, "config is required")
  local build = assert(dependencies.build, "build metadata is required")

  local state = {
    outcome = OUTCOME_FAIL_SCRIPT,
    detail = "bootstrap not completed",
    runtimeGroup = nil,
    spawner = nil,
    routeStarted = false,
    arrived = false,
    destroyed = false,
    scheduler = nil,
    route = nil,
    routeEntries = nil,
    routePlan = nil,
    spawnPositions = nil,
    spawnLeadDistance = nil,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM01M] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function message(text, duration)
    MESSAGE:New(
      text,
      duration or config.messages.durationSeconds,
      config.messages.category
    ):ToAll()
  end

  local function setOutcome(outcome, detail)
    state.outcome = outcome
    state.detail = detail
    log("INFO", "bootstrap_outcome", { outcome = outcome, detail = detail })
  end

  local function requiredMooseApis()
    local required = {
      { "SPAWN.NewWithAlias", SPAWN and SPAWN.NewWithAlias },
      { "SPAWN.InitSetUnitAbsolutePositions", SPAWN and SPAWN.InitSetUnitAbsolutePositions },
      { "SPAWN.Spawn", SPAWN and SPAWN.Spawn },
      { "GROUP.FindByName", GROUP and GROUP.FindByName },
      { "CONTROLLABLE.Route", CONTROLLABLE and CONTROLLABLE.Route },
      { "GROUP.CountAliveUnits", GROUP and GROUP.CountAliveUnits },
      { "GROUP.IsCompletelyInZone", GROUP and GROUP.IsCompletelyInZone },
      { "ZONE.FindByName", ZONE and ZONE.FindByName },
      { "ZONE_BASE.GetCoordinate", ZONE_BASE and ZONE_BASE.GetCoordinate },
      { "ZONE_BASE.IsVec2InZone", ZONE_BASE and ZONE_BASE.IsVec2InZone },
      { "PATHLINE.FindByName", PATHLINE and PATHLINE.FindByName },
      { "PATHLINE.GetNumberOfPoints", PATHLINE and PATHLINE.GetNumberOfPoints },
      { "PATHLINE.GetPoint2DFromIndex", PATHLINE and PATHLINE.GetPoint2DFromIndex },
      { "COORDINATE.NewFromVec2", COORDINATE and COORDINATE.NewFromVec2 },
      { "COORDINATE.GetVec2", COORDINATE and COORDINATE.GetVec2 },
      { "COORDINATE.Get2DDistance", COORDINATE and COORDINATE.Get2DDistance },
      { "COORDINATE.GetClosestPointToRoad", COORDINATE and COORDINATE.GetClosestPointToRoad },
      { "COORDINATE.GetPathOnRoad", COORDINATE and COORDINATE.GetPathOnRoad },
      { "COORDINATE.WaypointGround", COORDINATE and COORDINATE.WaypointGround },
      { "SCHEDULER.New", SCHEDULER and SCHEDULER.New },
      { "MESSAGE.New", MESSAGE and MESSAGE.New },
      { "MENU_MISSION.New", MENU_MISSION and MENU_MISSION.New },
      { "MENU_MISSION_COMMAND.New", MENU_MISSION_COMMAND and MENU_MISSION_COMMAND.New },
    }
    local missing = {}
    for _, item in ipairs(required) do
      if type(item[2]) ~= "function" then missing[#missing + 1] = item[1] end
    end
    return #missing == 0, missing
  end

  local function resolveMissionObjects()
    local missing, errors = {}, {}
    local objects = { pathlines = {} }

    local ok, template = pcall(function() return GROUP:FindByName(config.template.groupName) end)
    if not ok then errors[#errors + 1] = tostring(template)
    elseif not template then missing[#missing + 1] = config.template.groupName
    else objects.template = template end

    local function resolveZone(name)
      local zoneOk, zone = pcall(function() return ZONE:FindByName(name) end)
      if not zoneOk then
        errors[#errors + 1] = tostring(name) .. ":" .. tostring(zone)
        return nil
      end
      if not zone then missing[#missing + 1] = name end
      return zone
    end

    local function resolvePathline(name)
      local pathOk, pathline = pcall(function() return PATHLINE:FindByName(name) end)
      if not pathOk then
        errors[#errors + 1] = tostring(name) .. ":" .. tostring(pathline)
        return nil
      end
      if not pathline then missing[#missing + 1] = name end
      return pathline
    end

    objects.startZone = resolveZone(config.zones.start)
    objects.targetZone = resolveZone(config.zones.target)
    for _, name in ipairs(config.routing.msrPathlines or {}) do
      objects.pathlines[#objects.pathlines + 1] = {
        name = name,
        object = resolvePathline(name),
      }
    end

    if #objects.pathlines < 1 then
      missing[#missing + 1] = "routing.msrPathlines"
    end

    return #missing == 0 and #errors == 0, objects, missing, errors
  end

  local function pathlinePoints(pathline)
    local points = {}
    local count = pathline:GetNumberOfPoints()
    for index = 1, count do
      local vec2 = pathline:GetPoint2DFromIndex(index)
      if type(vec2) ~= "table" or type(vec2.x) ~= "number" or type(vec2.y) ~= "number" then
        error("PATHLINE point is unavailable at index " .. tostring(index))
      end
      points[#points + 1] = copyVec2(vec2)
    end
    if #points < 2 then error("PATHLINE contains fewer than two points") end
    return points
  end

  local function coordinateFromVec2(vec2)
    return COORDINATE:NewFromVec2(copyVec2(vec2))
  end

  local function appendRoutePoint(points, vec2, source)
    local last = points[#points]
    if last and distance2d(last.vec2, vec2) < config.routing.minimumRoutePointSeparationMeters then
      return false
    end
    points[#points + 1] = {
      vec2 = copyVec2(vec2),
      source = source,
    }
    return true
  end

  local function appendCoordinatePath(points, coordinates, source)
    for _, coordinate in ipairs(coordinates or {}) do
      local vec2 = coordinate:GetVec2()
      if type(vec2) ~= "table" then error("road path coordinate is unavailable") end
      appendRoutePoint(points, vec2, source)
    end
  end

  local function roadCoordinateForZone(zone, zoneName)
    local center = zone:GetCoordinate()
    local road = center:GetClosestPointToRoad(false)
    if not road then error("no road found near zone " .. tostring(zoneName)) end
    local snapDistance = center:Get2DDistance(road)
    if snapDistance > config.routing.maximumZoneRoadSnapMeters then
      error("road snap distance exceeds limit for zone " .. tostring(zoneName)
        .. ": " .. tostring(snapDistance))
    end
    if zone:IsVec2InZone(road:GetVec2()) ~= true then
      error("nearest road is outside zone " .. tostring(zoneName))
    end
    return road, snapDistance
  end

  local function appendRoadConnector(points, fromCoordinate, toCoordinate, source)
    local directDistance = fromCoordinate:Get2DDistance(toCoordinate)
    if directDistance < config.routing.minimumRoutePointSeparationMeters then
      appendRoutePoint(points, toCoordinate:GetVec2(), source)
      return 0
    end

    local path, pathLength, gotPath = fromCoordinate:GetPathOnRoad(
      toCoordinate,
      true,
      false,
      false,
      false
    )
    if gotPath ~= true or type(path) ~= "table" or #path < 2 then
      error("no MOOSE road connector found for " .. tostring(source))
    end
    appendCoordinatePath(points, path, source)
    return pathLength or directDistance
  end

  local function orientPathline(points, referenceVec2)
    local firstDistance = distance2d(referenceVec2, points[1])
    local lastDistance = distance2d(referenceVec2, points[#points])
    if lastDistance < firstDistance then
      return reverseArray(points), true, lastDistance
    end
    return points, false, firstDistance
  end

  local function compileDistances(points)
    local totalDistance = 0
    points[1].distance = 0
    for index = 2, #points do
      totalDistance = totalDistance + distance2d(points[index - 1].vec2, points[index].vec2)
      points[index].distance = totalDistance
    end
    return totalDistance
  end

  local function buildRoutePlan(objects)
    return pcall(function()
      local startRoad, startRoadSnap = roadCoordinateForZone(objects.startZone, config.zones.start)
      local targetRoad, targetRoadSnap = roadCoordinateForZone(objects.targetZone, config.zones.target)

      local routePoints = {}
      local boundaries = {}
      local pathlineDiagnostics = {}
      local referenceVec2 = startRoad:GetVec2()
      local orientedPathlines = {}
      local sourcePointCount = 0

      for index, entry in ipairs(objects.pathlines) do
        local points = pathlinePoints(entry.object)
        sourcePointCount = sourcePointCount + #points
        local oriented, reversed, endpointDistance = orientPathline(points, referenceVec2)
        if index > 1 and endpointDistance > config.routing.maximumPathlineJoinMeters then
          error("MSR PATHLINE join exceeds limit between "
            .. objects.pathlines[index - 1].name .. " and " .. entry.name
            .. ": " .. tostring(endpointDistance))
        end
        orientedPathlines[#orientedPathlines + 1] = {
          name = entry.name,
          points = oriented,
          reversed = reversed,
          endpointDistance = endpointDistance,
        }
        pathlineDiagnostics[#pathlineDiagnostics + 1] = entry.name
          .. (reversed and ":reversed" or ":forward")
        referenceVec2 = oriented[#oriented]
      end

      local firstPathlineCoordinate = coordinateFromVec2(orientedPathlines[1].points[1])
      local startConnectorMeters = appendRoadConnector(
        routePoints,
        startRoad,
        firstPathlineCoordinate,
        "start-to-msr"
      )

      for _, entry in ipairs(orientedPathlines) do
        for _, vec2 in ipairs(entry.points) do
          appendRoutePoint(routePoints, vec2, "pathline:" .. entry.name)
        end
        boundaries[#boundaries + 1] = {
          name = entry.name,
          pointIndex = #routePoints,
        }
      end

      local lastPathline = orientedPathlines[#orientedPathlines]
      local lastPathlineCoordinate = coordinateFromVec2(lastPathline.points[#lastPathline.points])
      local targetConnectorMeters = appendRoadConnector(
        routePoints,
        lastPathlineCoordinate,
        targetRoad,
        "msr-to-target"
      )

      if #routePoints < 2 then error("compiled MSR route contains fewer than two points") end
      local totalDistance = compileDistances(routePoints)
      if totalDistance <= 0 then error("compiled MSR route has no length") end
      for _, boundary in ipairs(boundaries) do
        boundary.distance = routePoints[boundary.pointIndex].distance
      end

      return {
        points = routePoints,
        totalDistance = totalDistance,
        boundaries = boundaries,
        pathlineDiagnostics = pathlineDiagnostics,
        sourcePointCount = sourcePointCount,
        startRoad = startRoad,
        targetRoad = targetRoad,
        startRoadSnapMeters = startRoadSnap,
        targetRoadSnapMeters = targetRoadSnap,
        startConnectorMeters = startConnectorMeters,
        targetConnectorMeters = targetConnectorMeters,
      }
    end)
  end

  local function pointAtDistance(routePlan, requestedDistance)
    local distance = math.max(0, math.min(requestedDistance, routePlan.totalDistance))
    local points = routePlan.points
    if distance <= 0 then return copyVec2(points[1].vec2), 1 end
    if distance >= routePlan.totalDistance then
      return copyVec2(points[#points].vec2), math.max(1, #points - 1)
    end

    local low = 1
    local high = #points
    while low + 1 < high do
      local middle = math.floor((low + high) / 2)
      if points[middle].distance <= distance then low = middle else high = middle end
    end
    local left = points[low]
    local right = points[high]
    local span = right.distance - left.distance
    local fraction = span > 0 and (distance - left.distance) / span or 0
    return interpolateVec2(left.vec2, right.vec2, fraction), low
  end

  local function headingAtDistance(routePlan, distance)
    local offset = math.max(1, config.routing.headingSampleMeters)
    local fromDistance = math.max(0, distance - offset)
    local toDistance = math.min(routePlan.totalDistance, distance + offset)
    if toDistance <= fromDistance then return 0 end
    local fromVec2 = pointAtDistance(routePlan, fromDistance)
    local toVec2 = pointAtDistance(routePlan, toDistance)
    return headingDegrees(fromVec2, toVec2)
  end

  local function buildSpawnPositions(routePlan)
    local count = config.template.expectedVehicleCount
    local leadDistance = config.routing.spawnRearClearanceMeters
      + (count - 1) * config.routing.vehicleSpacingMeters
    if leadDistance >= routePlan.totalDistance then
      return nil, nil, "route is too short for the configured convoy layout"
    end

    local positions = {}
    local maximumObservedSnap = 0
    for index = 1, count do
      local routeDistance = leadDistance - (index - 1) * config.routing.vehicleSpacingMeters
      local rawVec2 = pointAtDistance(routePlan, routeDistance)
      local rawCoordinate = coordinateFromVec2(rawVec2)
      local roadCoordinate = rawCoordinate:GetClosestPointToRoad(false)
      if not roadCoordinate then
        return nil, nil, nil, "no road projection for spawn vehicle " .. tostring(index)
      end
      local snapDistance = rawCoordinate:Get2DDistance(roadCoordinate)
      maximumObservedSnap = math.max(maximumObservedSnap, snapDistance)
      if snapDistance > config.routing.maximumSpawnRoadSnapMeters then
        return nil, nil, nil, "spawn road snap exceeds limit at vehicle "
          .. tostring(index) .. ": " .. tostring(snapDistance)
      end
      local vec2 = roadCoordinate:GetVec2()
      if state.objects.startZone:IsVec2InZone(vec2) ~= true then
        return nil, nil, nil, "spawn layout leaves start zone at vehicle " .. tostring(index)
      end
      positions[index] = {
        x = vec2.x,
        y = vec2.y,
        heading = headingAtDistance(routePlan, routeDistance),
      }
      if index > 1 then
        local separation = distance2d(positions[index - 1], positions[index])
        if separation < config.routing.minimumVehicleSeparationMeters then
          return nil, nil, nil, "spawn vehicle separation is too small at vehicle "
            .. tostring(index) .. ": " .. tostring(separation)
        end
      end
    end
    return positions, leadDistance, maximumObservedSnap, nil
  end

  local function uniqueSortedDistances(values)
    table.sort(values)
    local result = {}
    for _, value in ipairs(values) do
      local last = result[#result]
      if not last or math.abs(value - last) >= config.routing.minimumWaypointSeparationMeters then
        result[#result + 1] = value
      end
    end
    return result
  end

  local function buildRouteWaypoints(routePlan, fromDistance)
    return pcall(function()
      local requestedDistances = {}
      local firstDistance = math.min(
        routePlan.totalDistance,
        fromDistance + config.routing.routeStartLeadMeters
      )
      requestedDistances[#requestedDistances + 1] = firstDistance

      local distance = firstDistance + config.routing.waypointSpacingMeters
      while distance < routePlan.totalDistance do
        requestedDistances[#requestedDistances + 1] = distance
        distance = distance + config.routing.waypointSpacingMeters
      end
      for _, boundary in ipairs(routePlan.boundaries) do
        if boundary.distance > firstDistance
          and boundary.distance < routePlan.totalDistance then
          requestedDistances[#requestedDistances + 1] = boundary.distance
        end
      end
      requestedDistances[#requestedDistances + 1] = routePlan.totalDistance
      requestedDistances = uniqueSortedDistances(requestedDistances)

      local waypoints = {}
      local entries = {}
      local previousRoadVec2 = nil
      local maximumObservedSnap = 0
      for _, routeDistance in ipairs(requestedDistances) do
        local rawVec2 = pointAtDistance(routePlan, routeDistance)
        local rawCoordinate = coordinateFromVec2(rawVec2)
        local roadCoordinate = rawCoordinate:GetClosestPointToRoad(false)
        if not roadCoordinate then
          error("no road projection for route distance " .. tostring(routeDistance))
        end
        local snapDistance = rawCoordinate:Get2DDistance(roadCoordinate)
        maximumObservedSnap = math.max(maximumObservedSnap, snapDistance)
        if snapDistance > config.routing.maximumWaypointRoadSnapMeters then
          error("MSR waypoint road snap exceeds limit at route distance "
            .. tostring(routeDistance) .. ": " .. tostring(snapDistance))
        end
        local roadVec2 = roadCoordinate:GetVec2()
        if not previousRoadVec2
          or distance2d(previousRoadVec2, roadVec2) >= config.routing.minimumWaypointSeparationMeters then
          waypoints[#waypoints + 1] = roadCoordinate:WaypointGround(
            config.routing.speedKph,
            config.routing.formation
          )
          entries[#entries + 1] = {
            routeDistance = routeDistance,
            rawVec2 = rawVec2,
            roadVec2 = copyVec2(roadVec2),
            snapDistance = snapDistance,
          }
          previousRoadVec2 = roadVec2
        end
      end

      if #waypoints < 2 then error("compiled MSR route contains fewer than two waypoints") end
      return {
        waypoints = waypoints,
        entries = entries,
        maximumObservedSnap = maximumObservedSnap,
      }
    end)
  end

  local apiOk, missingApis = requiredMooseApis()
  if not apiOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required MOOSE APIs are unavailable")
    log("ERROR", "moose_api_validation_failed", { missing = join(missingApis) })
    return state
  end

  local objectsOk, objects, missingObjects, objectErrors = resolveMissionObjects()
  state.objects = objects
  if #objectErrors > 0 then
    setOutcome(OUTCOME_FAIL_SCRIPT, "Mission Editor object lookup failed")
    log("ERROR", "mission_object_lookup_failed", { errors = join(objectErrors) })
    return state
  end
  if not objectsOk then
    setOutcome(OUTCOME_FAIL_CONFIGURATION, "required Mission Editor objects are missing")
    log("ERROR", "mission_configuration_missing", { missing = join(missingObjects) })
    return state
  end

  local planOk, routePlanOrError = buildRoutePlan(objects)
  if not planOk then
    setOutcome(OUTCOME_FAIL_CONFIGURATION, "MSR route plan could not be compiled")
    log("ERROR", "msr_route_plan_failed", { detail = tostring(routePlanOrError) })
    return state
  end
  state.routePlan = routePlanOrError
  log("INFO", "msr_route_plan_compiled", {
    routeMode = "MOOSE_PATHLINE_MSR",
    msrPathlines = join(config.routing.msrPathlines),
    pathlineDirections = join(state.routePlan.pathlineDiagnostics),
    msrPathlineCount = #objects.pathlines,
    sourcePointCount = state.routePlan.sourcePointCount,
    compiledPointCount = #state.routePlan.points,
    routeLengthMeters = rounded(state.routePlan.totalDistance),
    startRoadSnapMeters = rounded(state.routePlan.startRoadSnapMeters),
    targetRoadSnapMeters = rounded(state.routePlan.targetRoadSnapMeters),
    startConnectorMeters = rounded(state.routePlan.startConnectorMeters),
    targetConnectorMeters = rounded(state.routePlan.targetConnectorMeters),
  })

  local function spawnConvoy()
    if state.runtimeGroup and state.runtimeGroup:IsAlive() == true then
      message("Spawn rejected: convoy already exists")
      return false
    end

    local positions, leadDistance, maximumSpawnRoadSnap, layoutError = buildSpawnPositions(state.routePlan)
    if not positions then
      setOutcome(OUTCOME_FAIL_CONFIGURATION, "MSR spawn layout could not be compiled")
      log("ERROR", "convoy_spawn_layout_failed", { detail = tostring(layoutError) })
      message("MOOSE MSR spawn layout failed")
      return false
    end

    state.spawner = SPAWN:NewWithAlias(config.template.groupName, config.template.runtimeAlias)
    state.spawner:InitSetUnitAbsolutePositions(positions)
    state.runtimeGroup = state.spawner:Spawn()
    if not state.runtimeGroup or state.runtimeGroup:IsAlive() ~= true then
      setOutcome(OUTCOME_FAIL_SCRIPT, "SPAWN did not create a living convoy")
      message("Convoy spawn failed")
      return false
    end

    local alive = state.runtimeGroup:CountAliveUnits()
    if alive ~= config.template.expectedVehicleCount then
      setOutcome(OUTCOME_FAIL_SCRIPT, "spawned convoy vehicle count mismatch")
      log("ERROR", "spawn_count_mismatch", {
        expected = config.template.expectedVehicleCount,
        observed = alive,
      })
      message("Convoy spawn failed: vehicle count mismatch")
      return false
    end

    state.spawnPositions = positions
    state.spawnLeadDistance = leadDistance
    state.route = nil
    state.routeEntries = nil
    state.routeStarted = false
    state.arrived = false
    state.destroyed = false
    log("INFO", "convoy_spawned", {
      runtimeGroupName = state.runtimeGroup:GetName(),
      aliveUnits = alive,
      spawnZoneName = config.zones.start,
      spawnX = rounded(positions[1].x),
      spawnY = rounded(positions[1].y),
      spawnHeadingDeg = rounded(positions[1].heading),
      spawnLeadRouteDistanceMeters = rounded(leadDistance),
      spawnRearRouteDistanceMeters = rounded(config.routing.spawnRearClearanceMeters),
      spawnPositionMode = "MOOSE_InitSetUnitAbsolutePositions",
      maximumSpawnRoadSnapMeters = rounded(maximumSpawnRoadSnap),
      msrFirstPathline = config.routing.msrPathlines[1],
    })
    message("MOOSE convoy spawned on " .. config.routing.msrPathlines[1]
      .. " from " .. config.zones.start .. ": " .. state.runtimeGroup:GetName())
    return true
  end

  local function startRoute()
    if not state.runtimeGroup or state.runtimeGroup:IsAlive() ~= true then
      message("Route rejected: no living convoy")
      return false
    end
    if state.routeStarted then
      message("Route rejected: already started")
      return false
    end

    local routeOk, routeOrError = buildRouteWaypoints(
      state.routePlan,
      assert(state.spawnLeadDistance, "spawn lead distance is unavailable")
    )
    if not routeOk then
      setOutcome(OUTCOME_FAIL_SCRIPT, "MOOSE MSR waypoint generation failed")
      log("ERROR", "convoy_route_generation_failed", { detail = tostring(routeOrError) })
      message("MOOSE MSR route generation failed")
      return false
    end

    state.route = routeOrError.waypoints
    state.routeEntries = routeOrError.entries
    local assigned = state.runtimeGroup:Route(state.route, config.routing.routeDelaySeconds)
    if not assigned then
      message("MOOSE route assignment failed")
      return false
    end
    state.routeStarted = true
    log("INFO", "convoy_route_started", {
      waypointCount = #state.route,
      msrPathlineCount = #state.objects.pathlines,
      msrPathlines = join(config.routing.msrPathlines),
      speedKph = config.routing.speedKph,
      formation = config.routing.formation,
      routeMode = "MOOSE_PATHLINE_MSR",
      routeLengthMeters = rounded(state.routePlan.totalDistance - state.spawnLeadDistance),
      maximumWaypointRoadSnapMeters = rounded(routeOrError.maximumObservedSnap),
    })
    message("MOOSE MSR route started")
    return true
  end

  local function showStatus()
    local alive = state.runtimeGroup and state.runtimeGroup:CountAliveUnits() or 0
    message(table.concat({
      "Outcome: " .. tostring(state.outcome),
      "Convoy alive: " .. tostring(state.runtimeGroup and state.runtimeGroup:IsAlive() == true),
      "Vehicles alive: " .. tostring(alive),
      "MSR pathlines: " .. join(config.routing.msrPathlines),
      "Route started: " .. tostring(state.routeStarted),
      "Route waypoints: " .. tostring(state.route and #state.route or 0),
      "Arrived: " .. tostring(state.arrived),
      "Destroyed: " .. tostring(state.destroyed),
    }, "\n"))
  end

  local function supervise()
    if not state.runtimeGroup then return end
    if state.runtimeGroup:IsAlive() ~= true or state.runtimeGroup:CountAliveUnits() < 1 then
      if not state.destroyed then
        state.destroyed = true
        log("INFO", "convoy_destroyed", {})
        message("MOOSE convoy destroyed")
      end
      return
    end
    if state.routeStarted and not state.arrived
      and state.runtimeGroup:IsCompletelyInZone(objects.targetZone) == true then
      state.arrived = true
      log("INFO", "convoy_arrived", {
        runtimeGroupName = state.runtimeGroup:GetName(),
        survivingVehicles = state.runtimeGroup:CountAliveUnits(),
        targetZoneName = config.zones.target,
        routeMode = "MOOSE_PATHLINE_MSR",
      })
      message("MOOSE convoy arrived at " .. config.zones.target)
    end
  end

  state.scheduler = SCHEDULER:New(
    nil,
    supervise,
    {},
    config.supervision.initialDelaySeconds,
    config.supervision.intervalSeconds
  )

  if config.debug.enableF10Menu == true then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM01M MOOSE Native MSR Convoy", root)
    MENU_MISSION_COMMAND:New("Spawn convoy", menu, spawnConvoy)
    MENU_MISSION_COMMAND:New("Start MSR route", menu, startRoute)
    MENU_MISSION_COMMAND:New("Show status", menu, showStatus)
  end

  state.spawnConvoy = spawnConvoy
  state.startRoute = startRoute
  state.showStatus = showStatus

  setOutcome(OUTCOME_READY, "TM01M MOOSE-native MSR convoy baseline is ready")
  log("INFO", "startup", {
    testId = build.testId,
    stageId = build.stageId,
    configurationVersion = config.configurationVersion,
    routeMode = "MOOSE_PATHLINE_MSR",
    msrPathlineCount = #objects.pathlines,
    msrPathlines = join(config.routing.msrPathlines),
    customCampaignStateLoaded = false,
    customProxyControllerLoaded = false,
    customInterestMonitorLoaded = false,
    customWatchdogLoaded = false,
  })
  message("TM01M READY: MOOSE-native MSR convoy baseline")
  return state
end

return TM01M
