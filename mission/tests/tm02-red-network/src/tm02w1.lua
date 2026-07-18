local TM02W1 = {}

local function startsWith(value, prefix)
  return type(value) == "string"
    and type(prefix) == "string"
    and value:sub(1, #prefix) == prefix
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

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function listToSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[value] = true
  end
  return result
end

local function distance2D(first, second)
  local dx = (second.x or 0) - (first.x or 0)
  local dz = (second.z or 0) - (first.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function pointFromMission(value)
  return {
    x = value and value.x or 0,
    z = value and value.y or 0,
  }
end

function TM02W1.start(config, build)
  local prefix = "[OMW][TM02W1]"

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
    configurationValid = false,
    failed = false,
    errors = {},
    warnings = {},
    siteById = {},
    nodeById = {},
    nodeAreas = {},
    routeById = {},
    routes = {},
    headquartersIds = {},
    subHeadquartersIds = {},
    ordinarySiteIds = {},
    markersEnabled = config.debug.markersEnabledOnStart == true,
    markerIds = {},
    menu = nil,
    graph = {
      connectedLocationCount = 0,
      locationCount = 0,
      edgeCount = 0,
      componentCount = 0,
      hasAlternativeConnection = false,
    },
  }

  local function addError(code, detail)
    local value = tostring(code) .. ": " .. tostring(detail)
    state.errors[#state.errors + 1] = value
    log("ERROR", "red_network_registry_error", {
      code = code,
      detail = detail,
    })
  end

  local function addWarning(code, detail)
    local value = tostring(code) .. ": " .. tostring(detail)
    state.warnings[#state.warnings + 1] = value
    log("WARNING", "red_network_registry_warning", {
      code = code,
      detail = detail,
    })
  end

  local function zoneRole(name)
    if startsWith(name, config.prefixes.headquarters) then
      return "HEADQUARTERS"
    end
    if startsWith(name, config.prefixes.subHeadquarters) then
      return "SUB_HEADQUARTERS"
    end
    if startsWith(name, config.prefixes.site) then
      return "SITE"
    end
    if startsWith(name, config.prefixes.nodeArea) then
      return "NODE_AREA"
    end
    return nil
  end

  local function registerZone(zone)
    local role = zoneRole(zone.name)
    if not role then
      return
    end

    if type(zone.x) ~= "number" or type(zone.y) ~= "number" then
      addError("ZONE_COORDINATE_INVALID", zone.name)
      return
    end

    if role == "NODE_AREA" then
      state.nodeAreas[#state.nodeAreas + 1] = {
        areaId = zone.name,
        coordinate = { x = zone.x, z = zone.y },
        radius = zone.radius,
        zoneType = zone.type,
      }
      return
    end

    if state.siteById[zone.name] then
      addError("DUPLICATE_SITE_ID", zone.name)
      return
    end

    if type(zone.radius) ~= "number" or zone.radius <= 0 then
      addError("SITE_ZONE_MUST_BE_CIRCULAR", zone.name)
      return
    end

    local site = {
      siteId = zone.name,
      role = role,
      coordinate = { x = zone.x, z = zone.y },
      radius = zone.radius,
      zoneType = zone.type,
      status = "AVAILABLE",
    }
    state.siteById[site.siteId] = site

    if role == "HEADQUARTERS" or role == "SUB_HEADQUARTERS" then
      local node = {
        nodeId = zone.name,
        siteId = zone.name,
        role = role,
        status = "ACTIVE",
      }
      state.nodeById[node.nodeId] = node
      site.status = "OCCUPIED"
    end

    if role == "HEADQUARTERS" then
      state.headquartersIds[#state.headquartersIds + 1] = site.siteId
    elseif role == "SUB_HEADQUARTERS" then
      state.subHeadquartersIds[#state.subHeadquartersIds + 1] = site.siteId
    else
      state.ordinarySiteIds[#state.ordinarySiteIds + 1] = site.siteId
    end
  end

  local function scanZones()
    local zones = env.mission
      and env.mission.triggers
      and env.mission.triggers.zones
      or {}

    for _, zone in pairs(zones) do
      if type(zone) == "table" and type(zone.name) == "string" then
        registerZone(zone)
      end
    end

    table.sort(state.headquartersIds)
    table.sort(state.subHeadquartersIds)
    table.sort(state.ordinarySiteIds)
    table.sort(state.nodeAreas, function(first, second)
      return first.areaId < second.areaId
    end)
  end

  local function locationMatches(point)
    local matches = {}
    local tolerance = config.graph.endpointToleranceMeters or 0
    for siteId, site in pairs(state.siteById) do
      local distance = distance2D(point, site.coordinate)
      if distance <= site.radius + tolerance then
        matches[#matches + 1] = siteId
      end
    end
    table.sort(matches)
    return matches
  end

  local function routeDistance(points)
    local total = 0
    for index = 2, #points do
      total = total + distance2D(
        pointFromMission(points[index - 1]),
        pointFromMission(points[index])
      )
    end
    return total
  end

  local function registerRouteGroup(group, countryName)
    if not startsWith(group.name, config.prefixes.route) then
      return
    end

    if state.routeById[group.name] then
      addError("DUPLICATE_ROUTE_ID", group.name)
      return
    end

    local points = group.route and group.route.points or {}
    local unitCount = #(group.units or {})

    if config.graph.requireLateActivationRoutes == true and group.lateActivation ~= true then
      addError("ROUTE_NOT_LATE_ACTIVATED", group.name)
    end

    if config.graph.requireSingleUnitRouteGroups == true and unitCount ~= 1 then
      addError("ROUTE_GROUP_UNIT_COUNT", group.name .. " count=" .. tostring(unitCount))
    end

    if #points < (config.graph.minimumRouteWaypointCount or 2) then
      addError("ROUTE_WAYPOINT_COUNT", group.name .. " count=" .. tostring(#points))
      return
    end

    local firstPoint = pointFromMission(points[1])
    local lastPoint = pointFromMission(points[#points])
    local sourceMatches = locationMatches(firstPoint)
    local targetMatches = locationMatches(lastPoint)

    if #sourceMatches ~= 1 then
      addError(
        "ROUTE_SOURCE_AMBIGUOUS",
        group.name .. " matches=" .. tostring(#sourceMatches)
      )
      return
    end

    if #targetMatches ~= 1 then
      addError(
        "ROUTE_TARGET_AMBIGUOUS",
        group.name .. " matches=" .. tostring(#targetMatches)
      )
      return
    end

    local sourceSiteId = sourceMatches[1]
    local targetSiteId = targetMatches[1]
    if sourceSiteId == targetSiteId then
      addError("ROUTE_SELF_REFERENCE", group.name .. " site=" .. sourceSiteId)
      return
    end

    local distanceMeters = routeDistance(points)
    local speedMetersPerSecond = (config.graph.defaultWalkingSpeedKph or 5) / 3.6
    local route = {
      routeId = group.name,
      sourceSiteId = sourceSiteId,
      targetSiteId = targetSiteId,
      direction = config.graph.direction,
      distanceMeters = distanceMeters,
      expectedTravelTimeSeconds = distanceMeters / speedMetersPerSecond,
      waypointCount = #points,
      countryName = countryName or "unknown",
      lateActivation = group.lateActivation == true,
      unitCount = unitCount,
      points = points,
    }

    state.routeById[route.routeId] = route
    state.routes[#state.routes + 1] = route
  end

  local function scanRouteGroups()
    local coalitionName = config.mission.routeCoalition or "red"
    local coalitionData = env.mission
      and env.mission.coalition
      and env.mission.coalition[coalitionName]

    if not coalitionData then
      addError("ROUTE_COALITION_MISSING", coalitionName)
      return
    end

    for _, country in pairs(coalitionData.country or {}) do
      local vehicleGroups = country.vehicle and country.vehicle.group or {}
      for _, group in pairs(vehicleGroups) do
        if type(group) == "table" and type(group.name) == "string" then
          registerRouteGroup(group, country.name)
        end
      end
    end

    table.sort(state.routes, function(first, second)
      return first.routeId < second.routeId
    end)
  end

  local function validateExactNames(label, actualValues, expectedValues)
    local actualSet = listToSet(actualValues)
    local expectedSet = listToSet(expectedValues)

    for _, expected in ipairs(expectedValues or {}) do
      if not actualSet[expected] then
        addError("EXPECTED_" .. label .. "_MISSING", expected)
      end
    end

    for _, actual in ipairs(actualValues or {}) do
      if not expectedSet[actual] then
        addError("UNEXPECTED_" .. label, actual)
      end
    end
  end

  local function validateExpectedObjects()
    validateExactNames("HEADQUARTERS", state.headquartersIds, config.expected.headquarters)
    validateExactNames("SUB_HEADQUARTERS", state.subHeadquartersIds, config.expected.subHeadquarters)
    validateExactNames("SITE", state.ordinarySiteIds, config.expected.sites)

    local nodeAreaIds = {}
    for _, area in ipairs(state.nodeAreas) do
      nodeAreaIds[#nodeAreaIds + 1] = area.areaId
    end
    validateExactNames("NODE_AREA", nodeAreaIds, config.expected.nodeAreas)

    local routeIds = {}
    for _, route in ipairs(state.routes) do
      routeIds[#routeIds + 1] = route.routeId
    end
    validateExactNames("ROUTE", routeIds, config.expected.routes)

    if #state.headquartersIds ~= 1 then
      addError("HEADQUARTERS_COUNT", #state.headquartersIds)
    end
  end

  local function buildAndValidateGraph()
    local adjacency = {}
    local locationCount = 0
    for siteId in pairs(state.siteById) do
      adjacency[siteId] = {}
      locationCount = locationCount + 1
    end

    for _, route in ipairs(state.routes) do
      if adjacency[route.sourceSiteId] and adjacency[route.targetSiteId] then
        adjacency[route.sourceSiteId][route.targetSiteId] = true
        if config.graph.direction == "BIDIRECTIONAL" then
          adjacency[route.targetSiteId][route.sourceSiteId] = true
        end
      end
    end

    local componentCount = 0
    local visited = {}
    for _, siteId in ipairs(sortedKeys(adjacency)) do
      if not visited[siteId] then
        componentCount = componentCount + 1
        local queue = { siteId }
        visited[siteId] = true
        local cursor = 1
        while cursor <= #queue do
          local current = queue[cursor]
          cursor = cursor + 1
          for neighborId in pairs(adjacency[current] or {}) do
            if not visited[neighborId] then
              visited[neighborId] = true
              queue[#queue + 1] = neighborId
            end
          end
        end
      end
    end

    local connectedFromHq = 0
    local hqId = state.headquartersIds[1]
    if hqId and adjacency[hqId] then
      local hqVisited = { [hqId] = true }
      local queue = { hqId }
      local cursor = 1
      while cursor <= #queue do
        local current = queue[cursor]
        cursor = cursor + 1
        connectedFromHq = connectedFromHq + 1
        for neighborId in pairs(adjacency[current] or {}) do
          if not hqVisited[neighborId] then
            hqVisited[neighborId] = true
            queue[#queue + 1] = neighborId
          end
        end
      end
    end

    state.graph.locationCount = locationCount
    state.graph.edgeCount = #state.routes
    state.graph.componentCount = componentCount
    state.graph.connectedLocationCount = connectedFromHq
    state.graph.hasAlternativeConnection = componentCount == 1
      and #state.routes >= locationCount

    if config.graph.requireAllLocationsConnectedToHq == true
      and connectedFromHq ~= locationCount then
      addError(
        "GRAPH_NOT_CONNECTED_TO_HQ",
        "connected=" .. tostring(connectedFromHq) .. " total=" .. tostring(locationCount)
      )
    end

    if config.graph.requireAlternativeConnection == true
      and state.graph.hasAlternativeConnection ~= true then
      addError(
        "GRAPH_HAS_NO_ALTERNATIVE_CONNECTION",
        "locations=" .. tostring(locationCount) .. " routes=" .. tostring(#state.routes)
      )
    end
  end

  local function markerCoordinate(point)
    local altitude = 0
    if land and land.getHeight then
      local ok, result = pcall(function()
        return land.getHeight({ x = point.x, y = point.z })
      end)
      if ok and type(result) == "number" then
        altitude = result
      end
    end
    return { x = point.x, y = altitude + 2, z = point.z }
  end

  local function clearMarkers()
    for _, markerId in ipairs(state.markerIds) do
      pcall(function()
        trigger.action.removeMark(markerId)
      end)
    end
    state.markerIds = {}
  end

  local function drawMarkers()
    clearMarkers()
    if state.markersEnabled ~= true then
      return
    end

    local nextMarkerId = config.debug.markerIdBase
    for _, siteId in ipairs(sortedKeys(state.siteById)) do
      local site = state.siteById[siteId]
      local node = state.nodeById[siteId]
      local text = site.role .. "\n" .. site.siteId
        .. "\nsiteStatus=" .. site.status
        .. "\nnode=" .. tostring(node and node.status or "NONE")
      trigger.action.markToAll(
        nextMarkerId,
        text,
        markerCoordinate(site.coordinate),
        true,
        ""
      )
      state.markerIds[#state.markerIds + 1] = nextMarkerId
      nextMarkerId = nextMarkerId + 1
    end

    for _, route in ipairs(state.routes) do
      local source = state.siteById[route.sourceSiteId]
      local target = state.siteById[route.targetSiteId]
      local midpoint = {
        x = (source.coordinate.x + target.coordinate.x) / 2,
        z = (source.coordinate.z + target.coordinate.z) / 2,
      }
      local text = route.routeId
        .. "\n" .. route.sourceSiteId .. " <-> " .. route.targetSiteId
        .. "\ndistanceM=" .. tostring(math.floor(route.distanceMeters + 0.5))
        .. " travelS=" .. tostring(math.floor(route.expectedTravelTimeSeconds + 0.5))
      trigger.action.markToAll(
        nextMarkerId,
        text,
        markerCoordinate(midpoint),
        true,
        ""
      )
      state.markerIds[#state.markerIds + 1] = nextMarkerId
      nextMarkerId = nextMarkerId + 1
    end
  end

  local function logRegistry()
    for _, siteId in ipairs(sortedKeys(state.siteById)) do
      local site = state.siteById[siteId]
      local node = state.nodeById[siteId]
      log("INFO", "red_network_location_registered", {
        siteId = site.siteId,
        role = site.role,
        radiusMeters = site.radius,
        siteStatus = site.status,
        nodePresent = node ~= nil,
        nodeStatus = node and node.status or "NONE",
      })
    end

    for _, route in ipairs(state.routes) do
      log("INFO", "red_network_route_registered", {
        routeId = route.routeId,
        sourceSiteId = route.sourceSiteId,
        targetSiteId = route.targetSiteId,
        direction = route.direction,
        waypointCount = route.waypointCount,
        distanceMeters = math.floor(route.distanceMeters + 0.5),
        expectedTravelTimeSeconds = math.floor(route.expectedTravelTimeSeconds + 0.5),
      })
    end
  end

  local function showSummary()
    local text = string.format(
      "TM02W1 %s | locations=%d nodes=%d routes=%d components=%d connectedFromHQ=%d alternative=%s errors=%d warnings=%d",
      state.configurationValid and "PASS" or "FAIL",
      state.graph.locationCount,
      #sortedKeys(state.nodeById),
      state.graph.edgeCount,
      state.graph.componentCount,
      state.graph.connectedLocationCount,
      tostring(state.graph.hasAlternativeConnection),
      #state.errors,
      #state.warnings
    )
    announce(text)
    log("INFO", "red_network_graph_summary", {
      configurationValid = state.configurationValid,
      locationCount = state.graph.locationCount,
      nodeCount = #sortedKeys(state.nodeById),
      routeCount = state.graph.edgeCount,
      componentCount = state.graph.componentCount,
      connectedLocationCount = state.graph.connectedLocationCount,
      hasAlternativeConnection = state.graph.hasAlternativeConnection,
      errorCount = #state.errors,
      warningCount = #state.warnings,
    })
  end

  local function showLocations()
    for _, siteId in ipairs(sortedKeys(state.siteById)) do
      local site = state.siteById[siteId]
      local node = state.nodeById[siteId]
      announce(
        site.siteId
          .. " | role=" .. site.role
          .. " | site=" .. site.status
          .. " | node=" .. tostring(node and node.status or "NONE")
      )
    end
  end

  local function showRoutes()
    for _, route in ipairs(state.routes) do
      announce(
        route.routeId
          .. " | " .. route.sourceSiteId
          .. " <-> " .. route.targetSiteId
          .. " | " .. tostring(math.floor(route.distanceMeters + 0.5)) .. " m"
      )
    end
  end

  local function installMenu()
    if config.debug.enableF10Menu ~= true or not missionCommands then
      return
    end
    local root = missionCommands.addSubMenu("OMW Tests")
    state.menu = missionCommands.addSubMenu("TM02W1 RED Network Registry", root)
    missionCommands.addCommand("Show validation summary", state.menu, showSummary)
    missionCommands.addCommand("List locations", state.menu, showLocations)
    missionCommands.addCommand("List routes", state.menu, showRoutes)
    missionCommands.addCommand("Toggle markers", state.menu, function()
      state.markersEnabled = not state.markersEnabled
      drawMarkers()
      announce("TM02W1 markers: " .. tostring(state.markersEnabled))
    end)
  end

  local ok, reason = pcall(function()
    scanZones()
    scanRouteGroups()
    validateExpectedObjects()
    buildAndValidateGraph()
  end)

  if not ok then
    addError("UNCAUGHT_VALIDATION_ERROR", reason)
  end

  state.configurationValid = #state.errors == 0
  state.failed = not state.configurationValid

  logRegistry()
  log("INFO", "red_network_registry_validation", {
    buildTimestamp = build and build.buildTimestamp or "unknown",
    configurationVersion = config.configurationVersion,
    configurationValid = state.configurationValid,
    missionFileName = config.mission.fileName,
    headquartersCount = #state.headquartersIds,
    subHeadquartersCount = #state.subHeadquartersIds,
    ordinarySiteCount = #state.ordinarySiteIds,
    nodeAreaCount = #state.nodeAreas,
    activeNodeCount = #sortedKeys(state.nodeById),
    routeCount = #state.routes,
    locationCount = state.graph.locationCount,
    componentCount = state.graph.componentCount,
    connectedLocationCount = state.graph.connectedLocationCount,
    hasAlternativeConnection = state.graph.hasAlternativeConnection,
    errorCount = #state.errors,
    warningCount = #state.warnings,
  })

  installMenu()
  drawMarkers()
  showSummary()

  return state
end

return TM02W1
