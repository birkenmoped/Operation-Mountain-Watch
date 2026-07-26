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
    scheduler = nil,
    convoys = {},
    convoyById = {},
    allArrivedLogged = false,
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

  local function validateConfig()
    local errors = {}
    if type(config.convoys) ~= "table" or #config.convoys < 1 then
      errors[#errors + 1] = "convoys"
      return false, errors
    end
    if type(config.template) ~= "table"
      or type(config.template.groupName) ~= "string"
      or type(config.template.expectedVehicleCount) ~= "number" then
      errors[#errors + 1] = "template"
    end
    if type(config.routing) ~= "table"
      or type(config.routing.speedKph) ~= "number"
      or config.routing.speedKph <= 0 then
      errors[#errors + 1] = "routing.speedKph"
    end

    local ids, aliases = {}, {}
    for index, convoyConfig in ipairs(config.convoys) do
      local prefix = "convoys[" .. tostring(index) .. "]"
      if type(convoyConfig.id) ~= "string" or convoyConfig.id == "" then
        errors[#errors + 1] = prefix .. ".id"
      elseif ids[convoyConfig.id] then
        errors[#errors + 1] = prefix .. ".id_duplicate"
      else
        ids[convoyConfig.id] = true
      end
      if type(convoyConfig.runtimeAlias) ~= "string" or convoyConfig.runtimeAlias == "" then
        errors[#errors + 1] = prefix .. ".runtimeAlias"
      elseif aliases[convoyConfig.runtimeAlias] then
        errors[#errors + 1] = prefix .. ".runtimeAlias_duplicate"
      else
        aliases[convoyConfig.runtimeAlias] = true
      end
      if type(convoyConfig.startZone) ~= "string" or convoyConfig.startZone == "" then
        errors[#errors + 1] = prefix .. ".startZone"
      end
      if type(convoyConfig.targetZone) ~= "string" or convoyConfig.targetZone == "" then
        errors[#errors + 1] = prefix .. ".targetZone"
      end
      if type(convoyConfig.msrPathlines) ~= "table" or #convoyConfig.msrPathlines < 1 then
        errors[#errors + 1] = prefix .. ".msrPathlines"
      end
    end
    return #errors == 0, errors
  end

  local function resolveZone(name, missing, errors, convoyId)
    local zoneOk, zone = pcall(function() return ZONE:FindByName(name) end)
    if not zoneOk then
      errors[#errors + 1] = tostring(convoyId) .. ":" .. tostring(name) .. ":" .. tostring(zone)
      return nil
    end
    if not zone then missing[#missing + 1] = tostring(convoyId) .. ":" .. tostring(name) end
    return zone
  end

  local function resolvePathline(name, missing, errors, convoyId)
    local pathOk, pathline = pcall(function() return PATHLINE:FindByName(name) end)
    if not pathOk then
      errors[#errors + 1] = tostring(convoyId) .. ":" .. tostring(name) .. ":" .. tostring(pathline)
      return nil
    end
    if not pathline then missing[#missing + 1] = tostring(convoyId) .. ":" .. tostring(name) end
    return pathline
  end

  local function resolveMissionObjects()
    local missing, errors = {}, {}
    local ok, template = pcall(function() return GROUP:FindByName(config.template.groupName) end)
    if not ok then
      errors[#errors + 1] = tostring(template)
    elseif not template then
      missing[#missing + 1] = config.template.groupName
    end

    for _, convoyConfig in ipairs(config.convoys) do
      local convoyState = {
        config = convoyConfig,
        objects = { pathlines = {} },
        runtimeGroup = nil,
        spawner = nil,
        routeStarted = false,
        arrived = false,
        destroyed = false,
        route = nil,
        routeEntries = nil,
        routePlan = nil,
        spawnPositions = nil,
        spawnLeadDistance = nil,
      }
      convoyState.objects.startZone = resolveZone(
        convoyConfig.startZone,
        missing,
        errors,
        convoyConfig.id
      )
      convoyState.objects.targetZone = resolveZone(
        convoyConfig.targetZone,
        missing,
        errors,
        convoyConfig.id
      )
      for _, name in ipairs(convoyConfig.msrPathlines or {}) do
        convoyState.objects.pathlines[#convoyState.objects.pathlines + 1] = {
          name = name,
          object = resolvePathline(name, missing, errors, convoyConfig.id),
        }
      end
      state.convoys[#state.convoys + 1] = convoyState
      state.convoyById[convoyConfig.id] = convoyState
    end

    return #missing == 0 and #errors == 0, template, missing, errors
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

  local function buildRoutePlan(convoyState)
    return pcall(function()
      local convoyConfig = convoyState.config
      local objects = convoyState.objects
      local startRoad, startRoadSnap = roadCoordinateForZone(objects.startZone, convoyConfig.startZone)
      local targetRoad, targetRoadSnap = roadCoordinateForZone(objects.targetZone, convoyConfig.targetZone)

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
        convoyConfig.id .. ":start-to-msr"
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
        convoyConfig.id .. ":msr-to-target"
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

  local function buildSpawnPositions(convoyState)
    local routePlan = convoyState.routePlan
    local count = config.template.expectedVehicleCount
    local leadDistance = config.routing.spawnRearClearanceMeters
      + (count - 1) * config.routing.vehicleSpacingMeters
    if leadDistance >= routePlan.totalDistance then
      return nil, nil, nil, "route is too short for the configured convoy layout"
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
      if convoyState.objects.startZone:IsVec2InZone(vec2) ~= true then
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

  local function buildRouteWaypoints(convoyState, fromDistance)
    return pcall(function()
      local routePlan = convoyState.routePlan
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

  local configOk, configErrors = validateConfig()
  if not configOk then
    setOutcome(OUTCOME_FAIL_CONFIGURATION, "TM01M multi-convoy configuration is invalid")
    log("ERROR", "configuration_validation_failed", { errors = join(configErrors) })
    return state
  end

  local objectsOk, template, missingObjects, objectErrors = resolveMissionObjects()
  state.template = template
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

  local totalSourcePointCount = 0
  local totalCompiledPointCount = 0
  local totalRouteLengthMeters = 0
  local totalPathlineCount = 0
  for _, convoyState in ipairs(state.convoys) do
    local planOk, routePlanOrError = buildRoutePlan(convoyState)
    if not planOk then
      setOutcome(OUTCOME_FAIL_CONFIGURATION, "MSR route plan could not be compiled")
      log("ERROR", "convoy_route_plan_failed", {
        convoyId = convoyState.config.id,
        detail = tostring(routePlanOrError),
      })
      return state
    end
    convoyState.routePlan = routePlanOrError
    totalSourcePointCount = totalSourcePointCount + convoyState.routePlan.sourcePointCount
    totalCompiledPointCount = totalCompiledPointCount + #convoyState.routePlan.points
    totalRouteLengthMeters = totalRouteLengthMeters + convoyState.routePlan.totalDistance
    totalPathlineCount = totalPathlineCount + #convoyState.objects.pathlines
    log("INFO", "convoy_route_plan_compiled", {
      convoyId = convoyState.config.id,
      runtimeAlias = convoyState.config.runtimeAlias,
      routeMode = "MOOSE_PATHLINE_MSR",
      startZoneName = convoyState.config.startZone,
      targetZoneName = convoyState.config.targetZone,
      msrPathlines = join(convoyState.config.msrPathlines),
      pathlineDirections = join(convoyState.routePlan.pathlineDiagnostics),
      msrPathlineCount = #convoyState.objects.pathlines,
      sourcePointCount = convoyState.routePlan.sourcePointCount,
      compiledPointCount = #convoyState.routePlan.points,
      routeLengthMeters = rounded(convoyState.routePlan.totalDistance),
      startRoadSnapMeters = rounded(convoyState.routePlan.startRoadSnapMeters),
      targetRoadSnapMeters = rounded(convoyState.routePlan.targetRoadSnapMeters),
      startConnectorMeters = rounded(convoyState.routePlan.startConnectorMeters),
      targetConnectorMeters = rounded(convoyState.routePlan.targetConnectorMeters),
    })
  end
  log("INFO", "multi_convoy_route_plans_compiled", {
    convoyCount = #state.convoys,
    msrPathlineCount = totalPathlineCount,
    sourcePointCount = totalSourcePointCount,
    compiledPointCount = totalCompiledPointCount,
    totalRouteLengthMeters = rounded(totalRouteLengthMeters),
  })

  local function spawnConvoy(convoyState, silent)
    if convoyState.runtimeGroup and convoyState.runtimeGroup:IsAlive() == true then
      if not silent then message("Spawn rejected: " .. convoyState.config.id .. " already exists") end
      return false
    end

    local positions, leadDistance, maximumSpawnRoadSnap, layoutError = buildSpawnPositions(convoyState)
    if not positions then
      state.outcome = OUTCOME_FAIL_CONFIGURATION
      state.detail = "MSR spawn layout could not be compiled for " .. convoyState.config.id
      log("ERROR", "convoy_spawn_layout_failed", {
        convoyId = convoyState.config.id,
        detail = tostring(layoutError),
      })
      if not silent then message("MOOSE MSR spawn layout failed: " .. convoyState.config.id) end
      return false
    end

    convoyState.spawner = SPAWN:NewWithAlias(
      config.template.groupName,
      convoyState.config.runtimeAlias
    )
    convoyState.spawner:InitSetUnitAbsolutePositions(positions)
    convoyState.runtimeGroup = convoyState.spawner:Spawn()
    if not convoyState.runtimeGroup or convoyState.runtimeGroup:IsAlive() ~= true then
      state.outcome = OUTCOME_FAIL_SCRIPT
      state.detail = "SPAWN did not create a living convoy for " .. convoyState.config.id
      log("ERROR", "convoy_spawn_failed", { convoyId = convoyState.config.id })
      if not silent then message("Convoy spawn failed: " .. convoyState.config.id) end
      return false
    end

    local alive = convoyState.runtimeGroup:CountAliveUnits()
    if alive ~= config.template.expectedVehicleCount then
      state.outcome = OUTCOME_FAIL_SCRIPT
      state.detail = "spawned convoy vehicle count mismatch for " .. convoyState.config.id
      log("ERROR", "spawn_count_mismatch", {
        convoyId = convoyState.config.id,
        expected = config.template.expectedVehicleCount,
        observed = alive,
      })
      if not silent then message("Convoy spawn count mismatch: " .. convoyState.config.id) end
      return false
    end

    convoyState.spawnPositions = positions
    convoyState.spawnLeadDistance = leadDistance
    convoyState.route = nil
    convoyState.routeEntries = nil
    convoyState.routeStarted = false
    convoyState.arrived = false
    convoyState.destroyed = false
    state.allArrivedLogged = false
    log("INFO", "convoy_spawned", {
      convoyId = convoyState.config.id,
      runtimeAlias = convoyState.config.runtimeAlias,
      runtimeGroupName = convoyState.runtimeGroup:GetName(),
      aliveUnits = alive,
      spawnZoneName = convoyState.config.startZone,
      spawnX = rounded(positions[1].x),
      spawnY = rounded(positions[1].y),
      spawnHeadingDeg = rounded(positions[1].heading),
      spawnLeadRouteDistanceMeters = rounded(leadDistance),
      spawnRearRouteDistanceMeters = rounded(config.routing.spawnRearClearanceMeters),
      spawnPositionMode = "MOOSE_InitSetUnitAbsolutePositions",
      maximumSpawnRoadSnapMeters = rounded(maximumSpawnRoadSnap),
      msrFirstPathline = convoyState.config.msrPathlines[1],
    })
    if not silent then
      message("Spawned " .. convoyState.config.displayName .. ": "
        .. convoyState.runtimeGroup:GetName())
    end
    return true
  end

  local function startRoute(convoyState, silent)
    if not convoyState.runtimeGroup or convoyState.runtimeGroup:IsAlive() ~= true then
      if not silent then message("Route rejected: no living convoy " .. convoyState.config.id) end
      return false
    end
    if convoyState.routeStarted then
      if not silent then message("Route rejected: already started " .. convoyState.config.id) end
      return false
    end

    local routeOk, routeOrError = buildRouteWaypoints(
      convoyState,
      assert(convoyState.spawnLeadDistance, "spawn lead distance is unavailable")
    )
    if not routeOk then
      state.outcome = OUTCOME_FAIL_SCRIPT
      state.detail = "MOOSE MSR waypoint generation failed for " .. convoyState.config.id
      log("ERROR", "convoy_route_generation_failed", {
        convoyId = convoyState.config.id,
        detail = tostring(routeOrError),
      })
      if not silent then message("MOOSE MSR route generation failed: " .. convoyState.config.id) end
      return false
    end

    convoyState.route = routeOrError.waypoints
    convoyState.routeEntries = routeOrError.entries
    local assigned = convoyState.runtimeGroup:Route(
      convoyState.route,
      config.routing.routeDelaySeconds
    )
    if not assigned then
      log("ERROR", "convoy_route_assignment_failed", { convoyId = convoyState.config.id })
      if not silent then message("MOOSE route assignment failed: " .. convoyState.config.id) end
      return false
    end
    convoyState.routeStarted = true
    log("INFO", "convoy_route_started", {
      convoyId = convoyState.config.id,
      runtimeAlias = convoyState.config.runtimeAlias,
      waypointCount = #convoyState.route,
      msrPathlineCount = #convoyState.objects.pathlines,
      msrPathlines = join(convoyState.config.msrPathlines),
      speedKph = config.routing.speedKph,
      formation = config.routing.formation,
      routeMode = "MOOSE_PATHLINE_MSR",
      routeLengthMeters = rounded(convoyState.routePlan.totalDistance - convoyState.spawnLeadDistance),
      maximumWaypointRoadSnapMeters = rounded(routeOrError.maximumObservedSnap),
    })
    if not silent then message("Route started: " .. convoyState.config.displayName) end
    return true
  end

  local function spawnAllConvoys(silent)
    local spawned = 0
    for _, convoyState in ipairs(state.convoys) do
      if spawnConvoy(convoyState, true) then spawned = spawned + 1 end
    end
    log("INFO", "multi_convoy_spawn_completed", {
      requestedConvoys = #state.convoys,
      spawnedConvoys = spawned,
      totalExpectedVehicles = #state.convoys * config.template.expectedVehicleCount,
    })
    if not silent then
      message("TM01M spawned " .. tostring(spawned) .. "/" .. tostring(#state.convoys)
        .. " convoys")
    end
    return spawned == #state.convoys
  end

  local function startAllRoutes(silent)
    local started = 0
    for _, convoyState in ipairs(state.convoys) do
      if startRoute(convoyState, true) then started = started + 1 end
    end
    log("INFO", "multi_convoy_routes_started", {
      requestedConvoys = #state.convoys,
      startedConvoys = started,
      speedKph = config.routing.speedKph,
      formation = config.routing.formation,
    })
    if not silent then
      message("TM01M started " .. tostring(started) .. "/" .. tostring(#state.convoys)
        .. " MSR routes at " .. tostring(config.routing.speedKph) .. " km/h")
    end
    return started == #state.convoys
  end

  local function launchAllConvoys()
    local spawned = spawnAllConvoys(true)
    local started = false
    if spawned then started = startAllRoutes(true) end
    log("INFO", "multi_convoy_launch_completed", {
      convoyCount = #state.convoys,
      spawnedAll = spawned,
      startedAll = started,
      speedKph = config.routing.speedKph,
    })
    message("TM01M launch: spawn=" .. tostring(spawned)
      .. " routes=" .. tostring(started)
      .. " speed=" .. tostring(config.routing.speedKph) .. " km/h")
    return spawned and started
  end

  local function convoyStatusLine(convoyState)
    local alive = convoyState.runtimeGroup and convoyState.runtimeGroup:CountAliveUnits() or 0
    return convoyState.config.id
      .. " alive=" .. tostring(alive)
      .. " route=" .. tostring(convoyState.routeStarted)
      .. " arrived=" .. tostring(convoyState.arrived)
      .. " destroyed=" .. tostring(convoyState.destroyed)
  end

  local function showConvoyStatus(convoyState)
    message(table.concat({
      convoyState.config.displayName,
      "ID: " .. convoyState.config.id,
      "Vehicles alive: " .. tostring(
        convoyState.runtimeGroup and convoyState.runtimeGroup:CountAliveUnits() or 0
      ),
      "MSR pathlines: " .. join(convoyState.config.msrPathlines),
      "Route started: " .. tostring(convoyState.routeStarted),
      "Route waypoints: " .. tostring(convoyState.route and #convoyState.route or 0),
      "Arrived: " .. tostring(convoyState.arrived),
      "Destroyed: " .. tostring(convoyState.destroyed),
    }, "\n"))
  end

  local function showFleetStatus()
    local lines = {
      "Outcome: " .. tostring(state.outcome),
      "Convoys: " .. tostring(#state.convoys),
      "Commanded speed: " .. tostring(config.routing.speedKph) .. " km/h",
    }
    for _, convoyState in ipairs(state.convoys) do
      lines[#lines + 1] = convoyStatusLine(convoyState)
    end
    message(table.concat(lines, "\n"), math.max(config.messages.durationSeconds, 25))
  end

  local function supervise()
    local arrivedCount = 0
    local survivingVehicles = 0
    for _, convoyState in ipairs(state.convoys) do
      if convoyState.runtimeGroup then
        if convoyState.runtimeGroup:IsAlive() ~= true
          or convoyState.runtimeGroup:CountAliveUnits() < 1 then
          if not convoyState.destroyed then
            convoyState.destroyed = true
            log("INFO", "convoy_destroyed", { convoyId = convoyState.config.id })
            message("Convoy destroyed: " .. convoyState.config.displayName)
          end
        else
          survivingVehicles = survivingVehicles + convoyState.runtimeGroup:CountAliveUnits()
          if convoyState.routeStarted and not convoyState.arrived
            and convoyState.runtimeGroup:IsCompletelyInZone(convoyState.objects.targetZone) == true then
            convoyState.arrived = true
            log("INFO", "convoy_arrived", {
              convoyId = convoyState.config.id,
              runtimeAlias = convoyState.config.runtimeAlias,
              runtimeGroupName = convoyState.runtimeGroup:GetName(),
              survivingVehicles = convoyState.runtimeGroup:CountAliveUnits(),
              targetZoneName = convoyState.config.targetZone,
              routeMode = "MOOSE_PATHLINE_MSR",
            })
            message("Convoy arrived: " .. convoyState.config.displayName)
          end
        end
      end
      if convoyState.arrived then arrivedCount = arrivedCount + 1 end
    end

    if arrivedCount == #state.convoys and not state.allArrivedLogged then
      state.allArrivedLogged = true
      log("INFO", "all_convoys_arrived", {
        convoyCount = #state.convoys,
        survivingVehicles = survivingVehicles,
        speedKph = config.routing.speedKph,
      })
      message("TM01M PASS: all " .. tostring(#state.convoys)
        .. " convoys arrived with " .. tostring(survivingVehicles) .. " vehicles")
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
    local menu = MENU_MISSION:New("TM01M Five MSR Convoys", root)
    MENU_MISSION_COMMAND:New("Launch all five convoys", menu, launchAllConvoys)
    MENU_MISSION_COMMAND:New("Spawn all convoys", menu, spawnAllConvoys)
    MENU_MISSION_COMMAND:New("Start all MSR routes", menu, startAllRoutes)
    MENU_MISSION_COMMAND:New("Show fleet status", menu, showFleetStatus)

    if config.debug.enableIndividualMenus == true then
      for _, convoyState in ipairs(state.convoys) do
        local convoyMenu = MENU_MISSION:New(convoyState.config.id, menu)
        MENU_MISSION_COMMAND:New("Spawn convoy", convoyMenu, spawnConvoy, convoyState)
        MENU_MISSION_COMMAND:New("Start route", convoyMenu, startRoute, convoyState)
        MENU_MISSION_COMMAND:New("Show status", convoyMenu, showConvoyStatus, convoyState)
      end
    end
  end

  state.spawnConvoy = function(convoyId)
    local convoyState = state.convoyById[convoyId]
    return convoyState and spawnConvoy(convoyState, false) or false
  end
  state.startRoute = function(convoyId)
    local convoyState = state.convoyById[convoyId]
    return convoyState and startRoute(convoyState, false) or false
  end
  state.spawnAllConvoys = spawnAllConvoys
  state.startAllRoutes = startAllRoutes
  state.launchAllConvoys = launchAllConvoys
  state.showFleetStatus = showFleetStatus
  state.supervise = supervise

  setOutcome(OUTCOME_READY, "TM01M five-convoy MOOSE-native MSR test is ready")
  log("INFO", "startup", {
    testId = build.testId,
    stageId = build.stageId,
    configurationVersion = config.configurationVersion,
    routeMode = "MOOSE_PATHLINE_MSR",
    convoyCount = #state.convoys,
    msrPathlineCount = totalPathlineCount,
    speedKph = config.routing.speedKph,
    formation = config.routing.formation,
    customCampaignStateLoaded = false,
    customProxyControllerLoaded = false,
    customInterestMonitorLoaded = false,
    customWatchdogLoaded = false,
  })
  message("TM01M READY: five MOOSE-native MSR convoys at "
    .. tostring(config.routing.speedKph) .. " km/h")
  return state
end

return TM01M
