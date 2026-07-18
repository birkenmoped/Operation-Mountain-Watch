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

local function distance2D(first, second)
  local dx = (second.x or 0) - (first.x or 0)
  local dz = (second.z or 0) - (first.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function pairKey(firstId, secondId)
  if firstId < secondId then
    return firstId .. "\0" .. secondId
  end
  return secondId .. "\0" .. firstId
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
    if config.debug and config.debug.showMessages == true then
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
    objectiveById = {},
    commandLinks = {},
    movementLinks = {},
    markerIds = {},
    markersEnabled = config.debug and config.debug.markersEnabledOnStart == true,
    menu = nil,
    commandGraph = {
      areaCount = 0,
      linkCount = 0,
      reachableFromHqCount = 0,
      acyclic = false,
    },
    movementGraph = {
      linkCount = 0,
      componentCount = 0,
      reachableFromHqCount = 0,
      hasCycle = false,
      crossAreaLinkCount = 0,
    },
    objectiveGraph = {
      objectiveCount = 0,
      associationCount = 0,
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

  local locationDefinitionById = {}
  local objectiveDefinitionById = {}

  local function indexConfiguration()
    for _, definition in ipairs(config.locations or {}) do
      local siteId = definition.siteId
      if type(siteId) ~= "string" or siteId == "" then
        addError("LOCATION_ID_INVALID", tostring(siteId))
      elseif locationDefinitionById[siteId] then
        addError("DUPLICATE_LOCATION_DEFINITION", siteId)
      else
        locationDefinitionById[siteId] = definition
      end
    end

    for _, definition in ipairs(config.objectives or {}) do
      local objectiveId = definition.objectiveId
      if type(objectiveId) ~= "string" or objectiveId == "" then
        addError("OBJECTIVE_ID_INVALID", tostring(objectiveId))
      elseif objectiveDefinitionById[objectiveId] then
        addError("DUPLICATE_OBJECTIVE_DEFINITION", objectiveId)
      else
        objectiveDefinitionById[objectiveId] = definition
      end
    end
  end

  local function roleFromZoneName(name)
    if startsWith(name, config.prefixes.headquarters) then
      return "HEADQUARTERS"
    end
    if startsWith(name, config.prefixes.subHeadquarters) then
      return "SUB_HEADQUARTERS"
    end
    if startsWith(name, config.prefixes.site) then
      return "STATION"
    end
    if startsWith(name, config.prefixes.nodeArea) then
      return "NODE_AREA"
    end
    return nil
  end

  local function isBlueObjectiveZone(name)
    return startsWith(name, config.prefixes.blueObjective)
  end

  local function validateZoneGeometry(zone, objectId)
    if type(zone.x) ~= "number" or type(zone.y) ~= "number" then
      addError("ZONE_COORDINATE_INVALID", objectId)
      return false
    end
    if type(zone.radius) ~= "number" or zone.radius <= 0 then
      addError("ZONE_MUST_BE_CIRCULAR", objectId)
      return false
    end
    return true
  end

  local function registerRedLocation(zone, detectedRole)
    local definition = locationDefinitionById[zone.name]
    if not definition then
      addError("UNEXPECTED_RED_LOCATION_ZONE", zone.name)
      return
    end
    if not validateZoneGeometry(zone, zone.name) then
      return
    end
    if definition.role ~= detectedRole then
      addError(
        "LOCATION_ROLE_PREFIX_MISMATCH",
        zone.name .. " configured=" .. tostring(definition.role) .. " detected=" .. tostring(detectedRole)
      )
      return
    end
    if state.siteById[zone.name] then
      addError("DUPLICATE_RED_LOCATION_ZONE", zone.name)
      return
    end
    if type(definition.commandAreaId) ~= "string" or definition.commandAreaId == "" then
      addError("COMMAND_AREA_MISSING", zone.name)
      return
    end

    local active = definition.initialNodeStatus == "ACTIVE"
    local site = {
      siteId = zone.name,
      role = definition.role,
      commandAreaId = definition.commandAreaId,
      commandParentId = definition.commandParentId,
      coordinate = { x = zone.x, z = zone.y },
      radius = zone.radius,
      status = active and "OCCUPIED" or "AVAILABLE",
    }
    state.siteById[site.siteId] = site

    if active then
      state.nodeById[site.siteId] = {
        nodeId = site.siteId,
        siteId = site.siteId,
        role = site.role,
        commandAreaId = site.commandAreaId,
        status = "ACTIVE",
      }
    end
  end

  local function registerNodeArea(zone)
    if not validateZoneGeometry(zone, zone.name) then
      return
    end
    state.nodeAreas[#state.nodeAreas + 1] = {
      areaId = zone.name,
      coordinate = { x = zone.x, z = zone.y },
      radius = zone.radius,
    }
  end

  local function registerBlueObjective(zone)
    local definition = objectiveDefinitionById[zone.name]
    if not definition then
      addError("UNEXPECTED_BLUE_OBJECTIVE_ZONE", zone.name)
      return
    end
    if not validateZoneGeometry(zone, zone.name) then
      return
    end
    if state.objectiveById[zone.name] then
      addError("DUPLICATE_BLUE_OBJECTIVE_ZONE", zone.name)
      return
    end

    state.objectiveById[zone.name] = {
      objectiveId = zone.name,
      objectiveType = definition.objectiveType or "UNKNOWN",
      coordinate = { x = zone.x, z = zone.y },
      radius = zone.radius,
      associatedSiteIds = definition.associatedSiteIds or {},
    }
  end

  local function scanMissionZones()
    local zones = env.mission
      and env.mission.triggers
      and env.mission.triggers.zones
      or {}

    for _, zone in pairs(zones) do
      if type(zone) == "table" and type(zone.name) == "string" then
        local role = roleFromZoneName(zone.name)
        if role == "NODE_AREA" then
          registerNodeArea(zone)
        elseif role then
          registerRedLocation(zone, role)
        elseif isBlueObjectiveZone(zone.name) then
          registerBlueObjective(zone)
        end
      end
    end
  end

  local function validateExpectedZones()
    for siteId in pairs(locationDefinitionById) do
      if not state.siteById[siteId] then
        addError("EXPECTED_RED_LOCATION_ZONE_MISSING", siteId)
      end
    end
    for objectiveId in pairs(objectiveDefinitionById) do
      if not state.objectiveById[objectiveId] then
        addError("EXPECTED_BLUE_OBJECTIVE_ZONE_MISSING", objectiveId)
      end
    end
  end

  local function findHeadquartersId()
    local result = nil
    local count = 0
    for siteId, site in pairs(state.siteById) do
      if site.role == "HEADQUARTERS" then
        result = siteId
        count = count + 1
      end
    end
    if count ~= 1 then
      addError("HEADQUARTERS_COUNT", count)
      return nil
    end
    return result
  end

  local function buildCommandGraph(headquartersId)
    local childrenByParent = {}
    local commandAreas = {}
    local commandLinkByChild = {}

    for siteId, site in pairs(state.siteById) do
      childrenByParent[siteId] = {}
      commandAreas[site.commandAreaId] = true
    end

    for siteId, site in pairs(state.siteById) do
      local parentId = site.commandParentId
      if siteId == headquartersId then
        if parentId ~= nil then
          addError("HEADQUARTERS_HAS_COMMAND_PARENT", tostring(parentId))
        end
      else
        if type(parentId) ~= "string" or parentId == "" then
          addError("COMMAND_PARENT_MISSING", siteId)
        elseif not state.siteById[parentId] then
          addError("COMMAND_PARENT_UNKNOWN", siteId .. " parent=" .. parentId)
        elseif parentId == siteId then
          addError("COMMAND_SELF_REFERENCE", siteId)
        elseif commandLinkByChild[siteId] then
          addError("MULTIPLE_COMMAND_PARENTS", siteId)
        else
          local parent = state.siteById[parentId]
          if parent.role ~= "HEADQUARTERS" and parent.role ~= "SUB_HEADQUARTERS" then
            addError("COMMAND_PARENT_NOT_COMMAND_NODE", siteId .. " parent=" .. parentId)
          else
            local link = {
              linkId = "COMMAND_" .. parentId .. "__" .. siteId,
              superiorSiteId = parentId,
              subordinateSiteId = siteId,
            }
            state.commandLinks[#state.commandLinks + 1] = link
            commandLinkByChild[siteId] = link
            childrenByParent[parentId][#childrenByParent[parentId] + 1] = siteId
          end
        end
      end
    end

    table.sort(state.commandLinks, function(first, second)
      return first.linkId < second.linkId
    end)
    for _, children in pairs(childrenByParent) do
      table.sort(children)
    end

    local colors = {}
    local acyclic = true
    local function visit(siteId)
      if colors[siteId] == "GRAY" then
        acyclic = false
        return
      end
      if colors[siteId] == "BLACK" then
        return
      end
      colors[siteId] = "GRAY"
      for _, childId in ipairs(childrenByParent[siteId] or {}) do
        visit(childId)
      end
      colors[siteId] = "BLACK"
    end
    for _, siteId in ipairs(sortedKeys(state.siteById)) do
      if not colors[siteId] then
        visit(siteId)
      end
    end

    local reachable = 0
    if headquartersId then
      local visited = { [headquartersId] = true }
      local queue = { headquartersId }
      local cursor = 1
      while cursor <= #queue do
        local current = queue[cursor]
        cursor = cursor + 1
        reachable = reachable + 1
        for _, childId in ipairs(childrenByParent[current] or {}) do
          if not visited[childId] then
            visited[childId] = true
            queue[#queue + 1] = childId
          end
        end
      end
    end

    state.commandGraph.areaCount = #sortedKeys(commandAreas)
    state.commandGraph.linkCount = #state.commandLinks
    state.commandGraph.reachableFromHqCount = reachable
    state.commandGraph.acyclic = acyclic

    local locationCount = #sortedKeys(state.siteById)
    if config.graph.requireCommandGraphAcyclic == true and not acyclic then
      addError("COMMAND_GRAPH_CYCLE", "detected")
    end
    if config.graph.requireAllCommandLocationsReachableFromHq == true and reachable ~= locationCount then
      addError("COMMAND_GRAPH_NOT_REACHABLE", "reachable=" .. reachable .. " total=" .. locationCount)
    end
  end

  local function buildMovementGraph(headquartersId)
    local adjacency = {}
    local undirectedPairSeen = {}

    for siteId in pairs(state.siteById) do
      adjacency[siteId] = {}
    end

    for _, definition in ipairs(config.movementLinks or {}) do
      local linkId = definition.linkId
      local source = state.siteById[definition.sourceSiteId]
      local target = state.siteById[definition.targetSiteId]
      local direction = definition.direction or "BIDIRECTIONAL"

      if type(linkId) ~= "string" or linkId == "" then
        addError("MOVEMENT_LINK_ID_INVALID", tostring(linkId))
      elseif not source then
        addError("MOVEMENT_LINK_SOURCE_UNKNOWN", tostring(linkId))
      elseif not target then
        addError("MOVEMENT_LINK_TARGET_UNKNOWN", tostring(linkId))
      elseif source.siteId == target.siteId then
        addError("MOVEMENT_LINK_SELF_REFERENCE", tostring(linkId))
      else
        local key = pairKey(source.siteId, target.siteId)
        if undirectedPairSeen[key] then
          addError("DUPLICATE_MOVEMENT_LINK_PAIR", tostring(linkId))
        else
          undirectedPairSeen[key] = true
          local distanceMeters = distance2D(source.coordinate, target.coordinate)
          local speedMetersPerSecond = (config.graph.defaultWalkingSpeedKph or 5) / 3.6
          local link = {
            linkId = linkId,
            sourceSiteId = source.siteId,
            targetSiteId = target.siteId,
            direction = direction,
            distanceMeters = distanceMeters,
            expectedTravelTimeSeconds = distanceMeters / speedMetersPerSecond,
            crossesCommandArea = source.commandAreaId ~= target.commandAreaId,
          }
          state.movementLinks[#state.movementLinks + 1] = link
          adjacency[source.siteId][target.siteId] = true
          if direction == "BIDIRECTIONAL" then
            adjacency[target.siteId][source.siteId] = true
          end
          if link.crossesCommandArea then
            state.movementGraph.crossAreaLinkCount = state.movementGraph.crossAreaLinkCount + 1
          end
        end
      end
    end

    table.sort(state.movementLinks, function(first, second)
      return first.linkId < second.linkId
    end)

    local componentCount = 0
    local visited = {}
    for _, startId in ipairs(sortedKeys(adjacency)) do
      if not visited[startId] then
        componentCount = componentCount + 1
        local queue = { startId }
        visited[startId] = true
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

    local reachable = 0
    if headquartersId and adjacency[headquartersId] then
      local hqVisited = { [headquartersId] = true }
      local queue = { headquartersId }
      local cursor = 1
      while cursor <= #queue do
        local current = queue[cursor]
        cursor = cursor + 1
        reachable = reachable + 1
        for neighborId in pairs(adjacency[current] or {}) do
          if not hqVisited[neighborId] then
            hqVisited[neighborId] = true
            queue[#queue + 1] = neighborId
          end
        end
      end
    end

    local cycleVisited = {}
    local hasCycle = false
    local function visitUndirected(currentId, parentId)
      cycleVisited[currentId] = true
      for neighborId in pairs(adjacency[currentId] or {}) do
        if not cycleVisited[neighborId] then
          visitUndirected(neighborId, currentId)
        elseif neighborId ~= parentId then
          hasCycle = true
        end
      end
    end
    for _, siteId in ipairs(sortedKeys(adjacency)) do
      if not cycleVisited[siteId] then
        visitUndirected(siteId, nil)
      end
    end

    state.movementGraph.linkCount = #state.movementLinks
    state.movementGraph.componentCount = componentCount
    state.movementGraph.reachableFromHqCount = reachable
    state.movementGraph.hasCycle = hasCycle

    local locationCount = #sortedKeys(state.siteById)
    if config.graph.requireAllMovementLocationsReachableFromHq == true and reachable ~= locationCount then
      addError("MOVEMENT_GRAPH_NOT_REACHABLE", "reachable=" .. reachable .. " total=" .. locationCount)
    end
    if config.graph.requireMovementCycle == true and not hasCycle then
      addError("MOVEMENT_GRAPH_HAS_NO_CYCLE", "links=" .. #state.movementLinks)
    end
    if config.graph.requireCrossAreaMovementLink == true and state.movementGraph.crossAreaLinkCount < 1 then
      addError("MOVEMENT_GRAPH_HAS_NO_CROSS_AREA_LINK", "count=0")
    end
  end

  local function validateObjectives()
    for objectiveId, objective in pairs(state.objectiveById) do
      if #objective.associatedSiteIds < 1 then
        addError("OBJECTIVE_HAS_NO_ASSOCIATED_SITE", objectiveId)
      end
      for _, siteId in ipairs(objective.associatedSiteIds) do
        local site = state.siteById[siteId]
        if not site then
          addError("OBJECTIVE_ASSOCIATED_SITE_UNKNOWN", objectiveId .. " site=" .. siteId)
        else
          state.objectiveGraph.associationCount = state.objectiveGraph.associationCount + 1
        end
      end
    end
    state.objectiveGraph.objectiveCount = #sortedKeys(state.objectiveById)
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

  local function addMarker(markerId, text, point)
    trigger.action.markToAll(markerId, text, markerCoordinate(point), true, "")
    state.markerIds[#state.markerIds + 1] = markerId
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
      addMarker(
        nextMarkerId,
        "RED " .. site.role .. "\n" .. site.siteId
          .. "\narea=" .. site.commandAreaId
          .. "\nparent=" .. tostring(site.commandParentId or "NONE")
          .. "\nnode=" .. tostring(node and node.status or "NONE"),
        site.coordinate
      )
      nextMarkerId = nextMarkerId + 1
    end

    for _, objectiveId in ipairs(sortedKeys(state.objectiveById)) do
      local objective = state.objectiveById[objectiveId]
      addMarker(
        nextMarkerId,
        "BLUE OBJECTIVE\n" .. objective.objectiveId .. "\ntype=" .. objective.objectiveType,
        objective.coordinate
      )
      nextMarkerId = nextMarkerId + 1
    end

    for _, link in ipairs(state.movementLinks) do
      local source = state.siteById[link.sourceSiteId]
      local target = state.siteById[link.targetSiteId]
      local midpoint = {
        x = (source.coordinate.x + target.coordinate.x) / 2,
        z = (source.coordinate.z + target.coordinate.z) / 2,
      }
      addMarker(
        nextMarkerId,
        "MOVE " .. link.linkId
          .. "\n" .. link.sourceSiteId .. " <-> " .. link.targetSiteId
          .. "\ndistanceM=" .. tostring(math.floor(link.distanceMeters + 0.5))
          .. " crossArea=" .. tostring(link.crossesCommandArea),
        midpoint
      )
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
        commandAreaId = site.commandAreaId,
        commandParentId = site.commandParentId or "NONE",
        siteStatus = site.status,
        nodePresent = node ~= nil,
      })
    end

    for _, link in ipairs(state.commandLinks) do
      log("INFO", "red_command_link_registered", {
        linkId = link.linkId,
        superiorSiteId = link.superiorSiteId,
        subordinateSiteId = link.subordinateSiteId,
      })
    end

    for _, link in ipairs(state.movementLinks) do
      log("INFO", "red_movement_link_registered", {
        linkId = link.linkId,
        sourceSiteId = link.sourceSiteId,
        targetSiteId = link.targetSiteId,
        direction = link.direction,
        directDistanceMeters = math.floor(link.distanceMeters + 0.5),
        expectedTravelTimeSeconds = math.floor(link.expectedTravelTimeSeconds + 0.5),
        crossesCommandArea = link.crossesCommandArea,
      })
    end

    for _, objectiveId in ipairs(sortedKeys(state.objectiveById)) do
      local objective = state.objectiveById[objectiveId]
      log("INFO", "blue_objective_registered", {
        objectiveId = objective.objectiveId,
        objectiveType = objective.objectiveType,
        associatedSiteCount = #objective.associatedSiteIds,
      })
    end
  end

  local function countsByRole()
    local result = {
      headquarters = 0,
      subHeadquarters = 0,
      ordinarySites = 0,
    }
    for _, site in pairs(state.siteById) do
      if site.role == "HEADQUARTERS" then
        result.headquarters = result.headquarters + 1
      elseif site.role == "SUB_HEADQUARTERS" then
        result.subHeadquarters = result.subHeadquarters + 1
      else
        result.ordinarySites = result.ordinarySites + 1
      end
    end
    return result
  end

  local function showSummary()
    local text = string.format(
      "TM02W1 %s | red=%d nodes=%d cmdAreas=%d cmdLinks=%d cmdReach=%d moveLinks=%d moveReach=%d moveCycle=%s crossArea=%d objectives=%d errors=%d",
      state.configurationValid and "PASS" or "FAIL",
      #sortedKeys(state.siteById),
      #sortedKeys(state.nodeById),
      state.commandGraph.areaCount,
      state.commandGraph.linkCount,
      state.commandGraph.reachableFromHqCount,
      state.movementGraph.linkCount,
      state.movementGraph.reachableFromHqCount,
      tostring(state.movementGraph.hasCycle),
      state.movementGraph.crossAreaLinkCount,
      state.objectiveGraph.objectiveCount,
      #state.errors
    )
    announce(text)
    log("INFO", "red_network_graph_summary", {
      configurationValid = state.configurationValid,
      redLocationCount = #sortedKeys(state.siteById),
      activeNodeCount = #sortedKeys(state.nodeById),
      commandAreaCount = state.commandGraph.areaCount,
      commandLinkCount = state.commandGraph.linkCount,
      commandReachableFromHqCount = state.commandGraph.reachableFromHqCount,
      commandAcyclic = state.commandGraph.acyclic,
      movementLinkCount = state.movementGraph.linkCount,
      movementComponentCount = state.movementGraph.componentCount,
      movementReachableFromHqCount = state.movementGraph.reachableFromHqCount,
      movementHasCycle = state.movementGraph.hasCycle,
      movementCrossAreaLinkCount = state.movementGraph.crossAreaLinkCount,
      objectiveCount = state.objectiveGraph.objectiveCount,
      objectiveAssociationCount = state.objectiveGraph.associationCount,
      errorCount = #state.errors,
      warningCount = #state.warnings,
    })
  end

  local function showLocations()
    for _, siteId in ipairs(sortedKeys(state.siteById)) do
      local site = state.siteById[siteId]
      announce(
        site.siteId
          .. " | role=" .. site.role
          .. " | area=" .. site.commandAreaId
          .. " | parent=" .. tostring(site.commandParentId or "NONE")
          .. " | node=" .. tostring(state.nodeById[siteId] and "ACTIVE" or "NONE")
      )
    end
  end

  local function showCommandGraph()
    for _, link in ipairs(state.commandLinks) do
      announce(link.superiorSiteId .. " -> " .. link.subordinateSiteId)
    end
  end

  local function showMovementGraph()
    for _, link in ipairs(state.movementLinks) do
      announce(
        link.sourceSiteId .. " <-> " .. link.targetSiteId
          .. " | " .. tostring(math.floor(link.distanceMeters + 0.5)) .. " m"
          .. " | crossArea=" .. tostring(link.crossesCommandArea)
      )
    end
  end

  local function showObjectives()
    for _, objectiveId in ipairs(sortedKeys(state.objectiveById)) do
      local objective = state.objectiveById[objectiveId]
      announce(
        objective.objectiveId
          .. " | type=" .. objective.objectiveType
          .. " | associatedSites=" .. tostring(#objective.associatedSiteIds)
      )
    end
  end

  local function installMenu()
    if not config.debug or config.debug.enableF10Menu ~= true or not missionCommands then
      return
    end
    local root = missionCommands.addSubMenu("OMW Tests")
    state.menu = missionCommands.addSubMenu("TM02W1 RED Network Registry", root)
    missionCommands.addCommand("Show validation summary", state.menu, showSummary)
    missionCommands.addCommand("List RED locations", state.menu, showLocations)
    missionCommands.addCommand("List command graph", state.menu, showCommandGraph)
    missionCommands.addCommand("List movement graph", state.menu, showMovementGraph)
    missionCommands.addCommand("List BLUE objectives", state.menu, showObjectives)
    missionCommands.addCommand("Toggle markers", state.menu, function()
      state.markersEnabled = not state.markersEnabled
      drawMarkers()
      announce("TM02W1 markers: " .. tostring(state.markersEnabled))
    end)
  end

  local ok, reason = pcall(function()
    indexConfiguration()
    scanMissionZones()
    validateExpectedZones()
    local headquartersId = findHeadquartersId()
    buildCommandGraph(headquartersId)
    buildMovementGraph(headquartersId)
    validateObjectives()
  end)

  if not ok then
    addError("UNCAUGHT_VALIDATION_ERROR", reason)
  end

  state.configurationValid = #state.errors == 0
  state.failed = not state.configurationValid

  local roleCounts = countsByRole()
  logRegistry()
  log("INFO", "red_network_registry_validation", {
    buildTimestamp = build and build.buildTimestamp or "unknown",
    configurationVersion = config.configurationVersion,
    configurationValid = state.configurationValid,
    missionFileName = config.mission.fileName,
    redLocationCount = #sortedKeys(state.siteById),
    headquartersCount = roleCounts.headquarters,
    subHeadquartersCount = roleCounts.subHeadquarters,
    ordinarySiteCount = roleCounts.ordinarySites,
    activeNodeCount = #sortedKeys(state.nodeById),
    nodeAreaCount = #state.nodeAreas,
    commandAreaCount = state.commandGraph.areaCount,
    commandLinkCount = state.commandGraph.linkCount,
    commandReachableFromHqCount = state.commandGraph.reachableFromHqCount,
    commandAcyclic = state.commandGraph.acyclic,
    movementLinkCount = state.movementGraph.linkCount,
    movementComponentCount = state.movementGraph.componentCount,
    movementReachableFromHqCount = state.movementGraph.reachableFromHqCount,
    movementHasCycle = state.movementGraph.hasCycle,
    movementCrossAreaLinkCount = state.movementGraph.crossAreaLinkCount,
    objectiveCount = state.objectiveGraph.objectiveCount,
    objectiveAssociationCount = state.objectiveGraph.associationCount,
    errorCount = #state.errors,
    warningCount = #state.warnings,
  })

  installMenu()
  drawMarkers()
  showSummary()

  return state
end

return TM02W1
