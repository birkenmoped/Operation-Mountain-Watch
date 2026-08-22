-- Operation Mountain Watch - road-aligned Ground WAREHOUSE materialization adapter.
--
-- Owner-approved production exception, 2026-08-21:
-- whenever a Ground asset is intentionally materialized on a road, its units
-- must be placed on the road axis and aligned with the intended outbound
-- direction. The adapter changes only the prepared WAREHOUSE spawn geometry;
-- BRIGADE/WAREHOUSE request, asset, callback, PLATOON, ARMYGROUP and AUFTRAG
-- lifecycles remain MOOSE-owned.
--
-- This module is pinned to the reviewed MOOSE WAREHOUSE private spawn contract
-- used by commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54.

local Adapter = {}

local TAG = "[OMW][Ground.RoadSpawnAdapter]"
local DEFAULT_REAR_CLEARANCE_M = 20
local DEFAULT_HEADING_SAMPLE_M = 10
local DEFAULT_MAX_SNAP_M = 30
local DEFAULT_MIN_TEMPLATE_SPACING_M = 0.5

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function isFinitePositive(value)
  return type(value) == "number"
    and value == value
    and value > 0
    and value < math.huge
end

local function requireFinitePositive(value, label)
  if not isFinitePositive(value) then
    fail(label .. " requires positive finite number")
  end
  return value
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
  if heading < 0 then
    heading = heading + 360
  end
  return heading
end

local function compileDistances(routePoints)
  local totalDistance = 0
  routePoints[1].distance = 0
  for index = 2, #routePoints do
    totalDistance = totalDistance + distance2d(routePoints[index - 1].vec2, routePoints[index].vec2)
    routePoints[index].distance = totalDistance
  end
  return totalDistance
end

local function pointAtDistance(routePoints, totalDistance, requestedDistance)
  local distance = math.max(0, math.min(requestedDistance, totalDistance))
  if distance == 0 then
    return copyVec2(routePoints[1].vec2)
  end
  if distance == totalDistance then
    return copyVec2(routePoints[#routePoints].vec2)
  end

  for index = 2, #routePoints do
    local right = routePoints[index]
    if distance <= right.distance then
      local left = routePoints[index - 1]
      local span = right.distance - left.distance
      local fraction = span > 0 and (distance - left.distance) / span or 0
      return interpolateVec2(left.vec2, right.vec2, fraction)
    end
  end

  return copyVec2(routePoints[#routePoints].vec2)
end

local function headingAtDistance(routePoints, totalDistance, distance, sampleM)
  local offset = math.max(1, sampleM)
  local fromDistance = math.max(0, distance - offset)
  local toDistance = math.min(totalDistance, distance + offset)
  if toDistance <= fromDistance then
    return 0
  end
  return headingDegrees(
    pointAtDistance(routePoints, totalDistance, fromDistance),
    pointAtDistance(routePoints, totalDistance, toDistance)
  )
end

local function templateOffsets(units, minimumSpacingM)
  if type(units) ~= "table" or #units < 1 then
    fail("asset template requires at least one unit")
  end

  local offsets = { 0 }
  local cumulative = 0
  for index = 2, #units do
    local previous = units[index - 1]
    local current = units[index]
    if type(previous.x) ~= "number" or type(previous.y) ~= "number"
        or type(current.x) ~= "number" or type(current.y) ~= "number" then
      fail("asset template unit coordinates are unavailable index=" .. tostring(index))
    end
    local spacing = distance2d(
      { x = previous.x, y = previous.y },
      { x = current.x, y = current.y }
    )
    if spacing < minimumSpacingM then
      fail("asset template unit spacing too small index=" .. tostring(index)
        .. " spacingM=" .. tostring(spacing))
    end
    cumulative = cumulative + spacing
    offsets[index] = cumulative
  end
  return offsets, cumulative
end

local function buildPositions(asset, roadSpec, config)
  local accessZone = roadSpec.accessZone
  local forwardCoordinate = roadSpec.forwardCoordinate
  if type(accessZone) ~= "table" or type(accessZone.GetCoordinate) ~= "function"
      or type(accessZone.IsVec2InZone) ~= "function" then
    fail("road spawn requires MOOSE accessZone")
  end
  if type(forwardCoordinate) ~= "table" then
    fail("road spawn requires MOOSE forwardCoordinate")
  end
  if type(asset) ~= "table" or type(asset.template) ~= "table"
      or type(asset.template.units) ~= "table" then
    fail("WAREHOUSE asset template unavailable")
  end

  local startRoad = accessZone:GetCoordinate():GetClosestPointToRoad(false)
  if not startRoad then
    fail("access road not found entityId=" .. tostring(roadSpec.entityId))
  end
  if accessZone:IsVec2InZone(startRoad:GetVec2()) ~= true then
    fail("access road outside zone entityId=" .. tostring(roadSpec.entityId))
  end

  local roadPath, roadLength, gotRoadPath = startRoad:GetPathOnRoad(
    forwardCoordinate,
    true,
    false,
    false,
    false
  )
  if gotRoadPath ~= true or type(roadPath) ~= "table" or #roadPath < 2 then
    fail("outbound road path unavailable entityId=" .. tostring(roadSpec.entityId))
  end

  local routePoints = {}
  for _, coordinate in ipairs(roadPath) do
    routePoints[#routePoints + 1] = { vec2 = coordinate:GetVec2() }
  end
  local totalDistance = compileDistances(routePoints)
  if totalDistance <= 0 then
    fail("outbound road path empty entityId=" .. tostring(roadSpec.entityId))
  end

  local offsets, formationLength = templateOffsets(
    asset.template.units,
    config.minimumTemplateSpacingM
  )
  local leadDistance = config.rearClearanceM + formationLength
  if leadDistance >= totalDistance then
    fail("outbound road path too short entityId=" .. tostring(roadSpec.entityId)
      .. " requiredM=" .. tostring(leadDistance)
      .. " availableM=" .. tostring(totalDistance))
  end

  local positions = {}
  local maximumSnap = 0
  for index = 1, #asset.template.units do
    local routeDistance = leadDistance - offsets[index]
    local rawVec2 = pointAtDistance(routePoints, totalDistance, routeDistance)
    local rawCoordinate = COORDINATE:NewFromVec2(rawVec2)
    local roadCoordinate = rawCoordinate:GetClosestPointToRoad(false)
    if not roadCoordinate then
      fail("road projection unavailable entityId=" .. tostring(roadSpec.entityId)
        .. " unit=" .. tostring(index))
    end

    local snapDistance = rawCoordinate:Get2DDistance(roadCoordinate)
    maximumSnap = math.max(maximumSnap, snapDistance)
    if snapDistance > config.maxSnapM then
      fail("road snap exceeds limit entityId=" .. tostring(roadSpec.entityId)
        .. " unit=" .. tostring(index)
        .. " distanceM=" .. tostring(snapDistance))
    end
    if accessZone:IsVec2InZone(roadCoordinate:GetVec2()) ~= true then
      fail("road spawn position outside access zone entityId=" .. tostring(roadSpec.entityId)
        .. " unit=" .. tostring(index))
    end

    positions[index] = {
      x = roadCoordinate.x,
      y = roadCoordinate.z,
      alt = roadCoordinate.y,
      heading = headingAtDistance(
        routePoints,
        totalDistance,
        routeDistance,
        config.headingSampleM
      ),
    }
  end

  return positions, {
    leadDistanceM = leadDistance,
    formationLengthM = formationLength,
    maximumSnapM = maximumSnap,
    roadLengthM = roadLength or totalDistance,
  }
end

local function normalizeConfig(config)
  if type(config) ~= "table" then
    fail("config must be table")
  end
  if type(config.resolveRoadSpawn) ~= "function" then
    fail("config.resolveRoadSpawn function is required")
  end

  return {
    resolveRoadSpawn = config.resolveRoadSpawn,
    log = type(config.log) == "function" and config.log or function() end,
    rearClearanceM = requireFinitePositive(
      config.rearClearanceM or DEFAULT_REAR_CLEARANCE_M,
      "rearClearanceM"
    ),
    headingSampleM = requireFinitePositive(
      config.headingSampleM or DEFAULT_HEADING_SAMPLE_M,
      "headingSampleM"
    ),
    maxSnapM = requireFinitePositive(
      config.maxSnapM or DEFAULT_MAX_SNAP_M,
      "maxSnapM"
    ),
    minimumTemplateSpacingM = requireFinitePositive(
      config.minimumTemplateSpacingM or DEFAULT_MIN_TEMPLATE_SPACING_M,
      "minimumTemplateSpacingM"
    ),
  }
end

function Adapter.Install(brigade, config)
  if type(brigade) ~= "table" then
    fail("brigade table is required")
  end
  local originalSpawn = brigade._SpawnAssetGroundNaval
  if type(originalSpawn) ~= "function" then
    fail("pinned WAREHOUSE _SpawnAssetGroundNaval is unavailable")
  end
  if brigade.ValidateAndRepositionGroundUnits == true then
    fail("WAREHOUSE ValidateAndRepositionGroundUnits conflicts with road alignment adapter")
  end
  if brigade._omwRoadSpawnAdapterInstalled == true then
    return brigade, false
  end

  local normalized = normalizeConfig(config)
  brigade._omwRoadSpawnAdapterInstalled = true
  brigade._omwRoadSpawnOriginal = originalSpawn

  brigade._SpawnAssetGroundNaval = function(self, alias, asset, request, spawnzone, lateactivated)
    if not asset or asset.category ~= Group.Category.GROUND then
      return originalSpawn(self, alias, asset, request, spawnzone, lateactivated)
    end

    local roadSpec = normalized.resolveRoadSpawn(self, asset, request, spawnzone, lateactivated)
    if roadSpec == nil then
      return originalSpawn(self, alias, asset, request, spawnzone, lateactivated)
    end
    if type(roadSpec) ~= "table" then
      fail("resolveRoadSpawn must return nil or table")
    end

    local positions, diagnostics = buildPositions(asset, roadSpec, normalized)
    local template = self:_SpawnAssetPrepareTemplate(asset, alias)
    if type(template) ~= "table" or type(template.units) ~= "table"
        or #template.units ~= #positions then
      fail("prepared WAREHOUSE template does not match road positions entityId="
        .. tostring(roadSpec.entityId))
    end

    template.route = template.route or { points = {} }
    template.route.points = template.route.points or {}
    template.route.points[1] = template.route.points[1] or {}

    for index, position in ipairs(positions) do
      local unit = template.units[index]
      unit.x = position.x
      unit.y = position.y
      unit.alt = position.alt
      unit.heading = math.rad(position.heading)
      if asset.livery then
        unit.livery_id = asset.livery
      end
      if asset.skill then
        unit.skill = asset.skill
      end
    end

    template.route.points[1].x = positions[1].x
    template.route.points[1].y = positions[1].y
    template.x = positions[1].x
    template.y = positions[1].y
    template.alt = positions[1].alt
    template.lateActivation = lateactivated

    normalized.log(string.format(
      "%s ROAD_ALIGNED_WAREHOUSE_SPAWN entityId=%s units=%d formationLengthM=%.1f maxSnapM=%.1f",
      TAG,
      tostring(roadSpec.entityId or "UNKNOWN"),
      #positions,
      diagnostics.formationLengthM,
      diagnostics.maximumSnapM
    ))

    return _DATABASE:Spawn(template)
  end

  return brigade, true
end

function Adapter.GetDefaults()
  return {
    rearClearanceM = DEFAULT_REAR_CLEARANCE_M,
    headingSampleM = DEFAULT_HEADING_SAMPLE_M,
    maxSnapM = DEFAULT_MAX_SNAP_M,
    minimumTemplateSpacingM = DEFAULT_MIN_TEMPLATE_SPACING_M,
  }
end

return Adapter
