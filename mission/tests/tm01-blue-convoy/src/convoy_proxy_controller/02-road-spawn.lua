  local function coordinateFromVec2(vec2)
    return COORDINATE:NewFromVec2(copyVec2(vec2))
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

  local function appendRoutePoint(points, vec2, currentDistance)
    local last = points[#points]
    if not last then
      points[1] = { vec2 = copyVec2(vec2), distance = currentDistance }
      return currentDistance
    end
    local segment = distance2d(last.vec2, vec2)
    if segment <= 0.1 then
      return currentDistance
    end
    local steps = math.max(1, math.ceil(segment / config.routing.routeSampleMeters))
    local previous = last.vec2
    for step = 1, steps do
      local sample = interpolateVec2(last.vec2, vec2, step / steps)
      currentDistance = currentDistance + distance2d(previous, sample)
      points[#points + 1] = {
        vec2 = sample,
        distance = currentDistance,
      }
      previous = sample
    end
    return currentDistance
  end

  local function snapZoneToRoad(zoneName)
    local zone, zoneError = zoneByName(zoneName)
    if not zone then
      return nil, zoneError
    end
    local center = zone:GetCoordinate()
    local road = center:GetClosestPointToRoad(false)
    if not road then
      return nil, "no road found near zone: " .. zoneName
    end
    local snapDistance = center:Get2DDistance(road)
    if snapDistance > config.routing.maximumRoadSnapMeters then
      return nil, "road snap distance exceeds limit for " .. zoneName
    end
    return road, nil
  end

  local function buildGlobalRoutePlan()
    return pcall(function()
      local names = { config.zones.start }
      for _, name in ipairs(config.zones.routeAnchors) do
        names[#names + 1] = name
      end
      names[#names + 1] = config.zones.target

      local snapped = {}
      for index, name in ipairs(names) do
        local coordinate, roadError = snapZoneToRoad(name)
        if not coordinate then
          error(roadError)
        end
        snapped[index] = coordinate
      end

      local points = {}
      local anchorEntries = {
        {
          zoneName = names[1],
          distance = 0,
          vec2 = copyVec2(snapped[1]:GetVec2()),
        },
      }
      local totalDistance = 0
      appendRoutePoint(points, snapped[1]:GetVec2(), totalDistance)

      for segmentIndex = 1, #snapped - 1 do
        local path, _, gotPath = snapped[segmentIndex]:GetPathOnRoad(
          snapped[segmentIndex + 1],
          true,
          false,
          false,
          false
        )
        if gotPath ~= true or type(path) ~= "table" or #path < 2 then
          error(
            "no road path between "
              .. names[segmentIndex]
              .. " and "
              .. names[segmentIndex + 1]
          )
        end
        for _, coordinate in ipairs(path) do
          local vec2 = coordinate:GetVec2()
          if type(vec2) ~= "table" then
            error("road path coordinate is unavailable")
          end
          totalDistance = appendRoutePoint(points, vec2, totalDistance)
        end
        anchorEntries[#anchorEntries + 1] = {
          zoneName = names[segmentIndex + 1],
          distance = totalDistance,
          vec2 = copyVec2(points[#points].vec2),
        }
      end

      if #points < 2 or totalDistance <= 0 then
        error("compiled road route is empty")
      end

      return {
        points = points,
        totalDistance = totalDistance,
        anchorEntries = anchorEntries,
      }
    end)
  end

  local function pointAtDistance(requestedDistance)
    local routePlan = controller.routePlan
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

  local function headingAtDistance(distance)
    local offset = math.max(5, config.routing.routeSampleMeters)
    local fromDistance = clamp(distance - offset, 0, controller.routePlan.totalDistance)
    local toDistance = clamp(distance + offset, 0, controller.routePlan.totalDistance)
    if toDistance <= fromDistance then
      return 0
    end
    return headingDegrees(pointAtDistance(fromDistance), pointAtDistance(toDistance))
  end

  local function projectToRoute(vec2)
    local bestDistanceSquared = nil
    local bestRouteDistance = nil
    local bestVec2 = nil
    local points = controller.routePlan.points

    for index = 1, #points - 1 do
      local left = points[index]
      local right = points[index + 1]
      local segmentX = right.vec2.x - left.vec2.x
      local segmentY = right.vec2.y - left.vec2.y
      local lengthSquared = segmentX * segmentX + segmentY * segmentY
      local fraction = 0
      if lengthSquared > 0 then
        fraction = (
          (vec2.x - left.vec2.x) * segmentX
            + (vec2.y - left.vec2.y) * segmentY
        ) / lengthSquared
        fraction = clamp(fraction, 0, 1)
      end
      local projected = {
        x = left.vec2.x + segmentX * fraction,
        y = left.vec2.y + segmentY * fraction,
      }
      local candidateDistanceSquared = distanceSquared(vec2, projected)
      if not bestDistanceSquared or candidateDistanceSquared < bestDistanceSquared then
        bestDistanceSquared = candidateDistanceSquared
        bestRouteDistance = left.distance + (right.distance - left.distance) * fraction
        bestVec2 = projected
      end
    end

    if not bestRouteDistance then
      return nil, "route projection failed"
    end
    return {
      routeDistance = bestRouteDistance,
      projectedVec2 = bestVec2,
      offsetMeters = math.sqrt(bestDistanceSquared),
    }, nil
  end

  local function surfaceTypeAt(vec2)
    local ok, value = pcall(function()
      return land.getSurfaceType({ x = vec2.x, y = vec2.y })
    end)
    if not ok then
      return nil, value
    end
    return value, nil
  end

  local function surfaceIsRejected(surfaceType)
    local types = land and land.SurfaceType or {}
    return (types.WATER ~= nil and surfaceType == types.WATER)
      or (types.SHALLOW_WATER ~= nil and surfaceType == types.SHALLOW_WATER)
  end

  local function buildLayoutAtLeadDistance(leadDistance, survivorsRearToFront)
    local slotsFrontToRear = reverseArray(survivorsRearToFront)
    local positions = {}
    local details = {}

    for index, stableSlot in ipairs(slotsFrontToRear) do
      local slotDistance = leadDistance - (index - 1) * config.routing.vehicleSpacingMeters
      if slotDistance < 0 or slotDistance > controller.routePlan.totalDistance then
        return nil, "formation exceeds compiled route bounds"
      end

      local rawVec2 = pointAtDistance(slotDistance)
      local rawCoordinate = coordinateFromVec2(rawVec2)
      local nearestRoad = rawCoordinate:GetClosestPointToRoad(false)
      if not nearestRoad then
        return nil, "no road projection for stable slot " .. tostring(stableSlot)
      end
      local snapDistance = rawCoordinate:Get2DDistance(nearestRoad)
      if snapDistance > config.routing.roadPositionToleranceMeters then
        return nil,
          "road projection exceeds tolerance for stable slot "
            .. tostring(stableSlot)
            .. ": "
            .. tostring(snapDistance)
      end

      local finalVec2 = nearestRoad:GetVec2()
      local surfaceType, surfaceError = surfaceTypeAt(finalVec2)
      if surfaceType == nil then
        return nil, "surface lookup failed: " .. tostring(surfaceError)
      end
      if surfaceIsRejected(surfaceType) then
        return nil, "water surface rejected for stable slot " .. tostring(stableSlot)
      end

      positions[index] = {
        x = finalVec2.x,
        y = finalVec2.y,
        heading = headingAtDistance(slotDistance),
      }
      details[index] = {
        stableSlot = stableSlot,
        routeDistance = slotDistance,
        snapDistance = snapDistance,
        surfaceType = surfaceType,
      }

      if index > 1 then
        local separation = distance2d(positions[index - 1], positions[index])
        if separation < config.routing.minimumVehicleSeparationMeters then
          return nil,
            "projected vehicle separation is too small: " .. tostring(separation)
        end
      end
    end

    return {
      slotsFrontToRear = slotsFrontToRear,
      positions = positions,
      details = details,
      leadDistance = leadDistance,
    }, nil
  end

  local function findUnpackLayout(proxyVec2, survivorsRearToFront)
    local projection, projectionError = projectToRoute(proxyVec2)
    if not projection then
      return nil, projectionError
    end

    local failures = {}
    for _, offset in ipairs(config.routing.unpackLeadOffsetCandidatesMeters) do
      local candidateDistance = projection.routeDistance + offset
      local layout, layoutError = buildLayoutAtLeadDistance(
        candidateDistance,
        survivorsRearToFront
      )
      if layout then
        layout.proxyProjection = projection
        layout.selectedLeadOffsetMeters = offset
        layout.leadDisplacementMeters = distance2d(proxyVec2, layout.positions[1])
        return layout, nil
      end
      failures[#failures + 1] = tostring(offset) .. "m=" .. tostring(layoutError)
    end

    return nil, table.concat(failures, "; ")
  end

  local function buildRemainingRoute(fromDistance)
    return pcall(function()
      local formation = MOOSE_FORMATIONS[config.routing.formation]
      if config.routing.roadOnly ~= true or not formation then
        error("road-only ON_ROAD routing is required")
      end

      local waypointEntries = {}
      local shortLeadDistance = math.min(
        controller.routePlan.totalDistance,
        fromDistance + 100
      )
      if shortLeadDistance > fromDistance + 20 then
        waypointEntries[#waypointEntries + 1] = {
          distance = shortLeadDistance,
          vec2 = pointAtDistance(shortLeadDistance),
          label = "local-road-lead",
        }
      end

      for index = 2, #controller.routePlan.anchorEntries do
        local entry = controller.routePlan.anchorEntries[index]
        if entry.distance > fromDistance + 100 then
          waypointEntries[#waypointEntries + 1] = {
            distance = entry.distance,
            vec2 = copyVec2(entry.vec2),
            label = entry.zoneName,
          }
        end
      end

      if #waypointEntries == 0 then
        local target = controller.routePlan.anchorEntries[#controller.routePlan.anchorEntries]
        waypointEntries[1] = {
          distance = target.distance,
          vec2 = copyVec2(target.vec2),
          label = target.zoneName,
        }
      end

      local waypoints = {}
      for _, entry in ipairs(waypointEntries) do
        waypoints[#waypoints + 1] = coordinateFromVec2(entry.vec2):WaypointGround(
          config.routing.speedKph,
          formation
        )
      end
      return {
        waypoints = waypoints,
        entries = waypointEntries,
      }
    end)
  end

  local function spawnDynamicGroup(stableSlotsFrontToRear, positions)
    local generation = controller.entity.runtimeGeneration + 1
    local alias = config.template.runtimeAliasPrefix
      .. "_G"
      .. string.format("%03d", generation)

    local constructionOk, resultOrError = pcall(function()
      local spawner = SPAWN:NewWithAlias(config.template.groupName, alias)
      if type(spawner) ~= "table"
        or type(spawner.SpawnTemplate) ~= "table"
        or type(spawner.SpawnTemplate.units) ~= "table" then
        error("SPAWN template data is unavailable")
      end

      local filteredUnits = {}
      for index, stableSlot in ipairs(stableSlotsFrontToRear) do
        local sourceUnit = spawner.SpawnTemplate.units[stableSlot]
        if type(sourceUnit) ~= "table" then
          error("template unit is unavailable for stable slot " .. tostring(stableSlot))
        end
        filteredUnits[index] = deepCopy(sourceUnit)
      end
      spawner.SpawnTemplate.units = filteredUnits
      spawner:InitSetUnitAbsolutePositions(positions)
      local group = spawner:Spawn()
      if type(group) ~= "table" then
        error("SPAWN:Spawn returned no GROUP wrapper")
      end
      return {
        spawner = spawner,
        group = group,
        alias = alias,
        generation = generation,
      }
    end)

    if not constructionOk then
      return nil, resultOrError
    end

    local result = resultOrError
    local inspectionOk, runtimeNameOrError = pcall(function()
      if result.group:IsAlive() ~= true then
        error("spawned runtime group is not alive")
      end
      if result.group:CountAliveUnits() ~= #stableSlotsFrontToRear then
        error("spawned runtime unit count does not match survivor count")
      end
      return result.group:GetName()
    end)
    if not inspectionOk then
      pcall(function()
        result.group:Destroy(false)
      end)
      return nil, runtimeNameOrError
    end

    result.runtimeName = runtimeNameOrError
    result.runtimeIndexToStableSlot = {}
    for index, stableSlot in ipairs(stableSlotsFrontToRear) do
      result.runtimeIndexToStableSlot[index] = stableSlot
    end
    return result, nil
  end

  local function assignRoute(group, fromDistance)
    local routeOk, routeOrError = buildRemainingRoute(fromDistance)
    if not routeOk then
      return false, routeOrError
    end
    local assignmentOk, assignmentResult = pcall(function()
      return group:Route(routeOrError.waypoints, 0)
    end)
    if not assignmentOk or not assignmentResult then
      return false, assignmentOk and "route assignment returned nil" or assignmentResult
    end
    return true, routeOrError
  end

