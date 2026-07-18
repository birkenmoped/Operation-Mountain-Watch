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
    linkById = {},
    links = {},
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

  local function validateExpectedZones()
    validateExactNames("HEADQUARTERS", state.headquartersIds, config.expected.headquarters)
    validateExactNames("SUB_HEADQUARTERS", state.subHeadquartersIds, config.expected.subHeadquarters)
    validateExactNames("SITE", state.ordinarySiteIds, config.expected.sites)

    local nodeAreaIds = {}
    for _, area in ipairs(state.nodeAreas) do
      nodeAreaIds[#nodeAreaIds + 1] = area.areaId
    end
    validateExactNames("NODE_AREA", nodeAreaIds, config.expected.nodeAreas)

    if #state.headquartersIds ~= 1 then
      addError("HEADQUARTERS_COUNT", #state.headquartersIds)
    end
  end

  local function registerConfiguredLinks()
    local speedMetersPerSecond = (config.graph.defaultWalkingSpeedKph or 5) / 3.6

    for _, definition in ipairs(config.links or {}) do
      local linkId = definition.linkId
      local source = state.siteById[definition.sourceSiteId]
      local target = state.siteById[definition.targetSiteId]

      if type(linkId) ~= "string" or linkId == "" then
        addError("LINK_ID_INVALID", tostring(linkId))
      elseif state.linkById[linkId] then
        addError("DUPLICATE_LINK_ID", linkId)
      elseif not source then
        addError("LINK_SOURCE_MISSING", linkId .. " source=" .. tostring(definition.sourceSiteId))
      elseif not target then
        addError("LINK_TARGET_MISSING", linkId .. " target=" .. tostring(definition.targetSiteId))
      elseif source.siteId == target.siteId then
        addError("LINK_SELF_REFERENCE", linkId .. " site=" .. source.siteId)
      else
        local distanceMeters = distance2D(source.coordinate, target.coordinate)
        local link = {
          linkId = linkId,
          sourceSiteId = source.siteId,
          targetSiteId = target.siteId,
          direction = definition.direction or "BIDIRECTIONAL",
          distanceMeters = distanceMeters,
          expectedTravelTimeSeconds = distanceMeters / speedMetersPerSecond,
        }
        state.linkById[link.linkId] = link
        state.links[#state.links + 1] = link
      end
    end

    table.sort(state.links, function(first, second)
      return first.linkId < second.linkId
    end)
  end

  local function addAdjacency(adjacency, sourceId, targetId)
    if adjacency[sourceId] and adjacency[targetId] then
      adjacency[sourceId][targetId] = true
    end
  end

  local function buildAndValidateGraph()
    local adjacency = {}
    local locationCount = 0
    for siteId in pairs(state.siteById) do
      adjacency[siteId] = {}
      locationCount = locationCount + 1
    end

    for _, link in ipairs(state.links) do
      addAdjacency(adjacency, link.sourceSiteId, link.targetSiteId)
      if link.direction == "BIDIRECTIONAL" then
        addAdjacency(adjacency, link.targetSiteId, link.sourceSiteId)
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
    state.graph.edgeCount = #state.links
    state.graph.componentCount = componentCount
    state.graph.connectedLocationCount = connectedFromHq
    state.graph.hasAlternativeConnection = componentCount == 1
      and #state.links >= locationCount

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
        "locations=" .. tostring(locationCount) .. " links=" .. tostring(#state.links)
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

    for _, link in ipairs(state.links) do
      local source = state.siteById[link.sourceSiteId]
      local target = state.siteById[link.targetSiteId]
      local midpoint = {
        x = (source.coordinate.x + target.coordinate.x) / 2,
        z = (source.coordinate.z + target.coordinate.z) / 2,
      }
      local text = link.linkId
        .. "\n" .. link.sourceSiteId .. " <-> " .. link.targetSiteId
        .. "\ndirectDistanceM=" .. tostring(math.floor(link.distanceMeters + 0.5))
        .. " travelS=" .. tostring(math.floor(link.expectedTravelTimeSeconds + 0.5))
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

    for _, link in ipairs(state.links) do
      log("INFO", "red_network_link_registered", {
        linkId = link.linkId,
        sourceSiteId = link.sourceSiteId,
        targetSiteId = link.targetSiteId,
        direction = link.direction,
        directDistanceMeters = math.floor(link.distanceMeters + 0.5),
        expectedTravelTimeSeconds = math.floor(link.expectedTravelTimeSeconds + 0.5),
      })
    end
  end

  local function showSummary()
    local text = string.format(
      "TM02W1 %s | locations=%d nodes=%d links=%d components=%d connectedFromHQ=%d alternative=%s errors=%d warnings=%d",
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
      linkCount = state.graph.edgeCount,
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

  local function showLinks()
    for _, link in ipairs(state.links) do
      announce(
        link.linkId
          .. " | " .. link.sourceSiteId
          .. " <-> " .. link.targetSiteId
          .. " | " .. tostring(math.floor(link.distanceMeters + 0.5)) .. " m direct"
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
    missionCommands.addCommand("List links", state.menu, showLinks)
    missionCommands.addCommand("Toggle markers", state.menu, function()
      state.markersEnabled = not state.markersEnabled
      drawMarkers()
      announce("TM02W1 markers: " .. tostring(state.markersEnabled))
    end)
  end

  local ok, reason = pcall(function()
    scanZones()
    validateExpectedZones()
    registerConfiguredLinks()
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
    linkCount = #state.links,
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
