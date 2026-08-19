-- Operation Mountain Watch - ARMY Ground Foundation Acceptance 4 harness.
-- Scope: one Fenty BRIGADE/Warehouse lifecycle return handoff after a road approach.
-- Reuses the owner-approved, version-pinned Acceptance-3 road-aligned Warehouse
-- materialization adapter. The return itself uses public ARMYGROUP:RTZ(...).

local TEST_ID = "ARMY-GROUND-ACCEPTANCE-4-1"
local TAG = "OMW_GND_A4"
local TEMPLATE_NAME = "TPL_BLUE_GND_PATROL_MATV_4"

local POST_START_DELAY_SEC = 5
local APPROACH_HOLD_SEC = 10
local RETURN_DELAY_SEC = 2
local WAREHOUSE_RETURN_DELAY_SEC = 10
local POST_RETURN_VERIFY_DELAY_SEC = WAREHOUSE_RETURN_DELAY_SEC + 5
local APPROACH_STANDOFF_M = 1500
local MIN_APPROACH_LEG_M = 500
local ROAD_SPEED_KNOTS = 27
local ROAD_SPAWN_VEHICLE_SPACING_M = 18
local ROAD_SPAWN_REAR_CLEARANCE_M = 20
local ROAD_SPAWN_HEADING_SAMPLE_M = 10
local ROAD_SPAWN_MAX_SNAP_M = 30
local ROAD_SPAWN_MIN_SEPARATION_M = 8

local sites = {
  {
    id = "FENTY",
    warehouse = "WH_BLUE_GND_FENTY",
    brigadeName = "BDE_BLUE_GND_JALALABAD_RETURN_ACCEPTANCE",
    platoonName = "PLT_BLUE_GND_JALALABAD_RETURN_MATV",
    accessZone = "ZON_BLUE_GND_FENTY_ACCESS",
    observationZone = "ZON_BLUE_GND_FENTY_PATROL_TEST_01",
  },
}

local global = {
  failed = false,
  passedSites = 0,
  armyGroupOwners = {},
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(site, reason)
  if site then
    site.failed = true
  end
  global.failed = true
  log("FAIL site=" .. tostring(site and site.id or "GLOBAL") .. " reason=" .. tostring(reason))
end

local function roundMeters(value)
  return math.floor((value or 0) + 0.5)
end

local function requireObject(site, value, label)
  if not value then
    fail(site, "MISSING_OBJECT " .. label)
    return false
  end
  return true
end

local function maybeGlobalPass()
  if global.failed then
    return
  end
  if global.passedSites == #sites then
    log("RUNTIME_PASS_VISUAL_PENDING sites=" .. tostring(#sites) .. " passed=" .. tostring(global.passedSites))
  end
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

local function headingAtDistance(routePoints, totalDistance, distance)
  local offset = math.max(1, ROAD_SPAWN_HEADING_SAMPLE_M)
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

local function buildRoadSpawnPositions(site, templateGroup)
  local startRoad = site.accessZoneObject:GetCoordinate():GetClosestPointToRoad(false)
  if not startRoad then
    return nil, nil, "ACCESS_ROAD_NOT_FOUND"
  end
  if site.accessZoneObject:IsVec2InZone(startRoad:GetVec2()) ~= true then
    return nil, nil, "ACCESS_ROAD_OUTSIDE_ZONE"
  end

  local roadPath, roadLength, gotRoadPath = startRoad:GetPathOnRoad(site.approachCoord, true, false, false, false)
  if gotRoadPath ~= true or type(roadPath) ~= "table" or #roadPath < 2 then
    return nil, nil, "ACCESS_TO_APPROACH_ROAD_PATH_UNAVAILABLE"
  end

  local routePoints = {}
  for _, coordinate in ipairs(roadPath) do
    routePoints[#routePoints + 1] = { vec2 = coordinate:GetVec2() }
  end
  local totalDistance = compileDistances(routePoints)
  if totalDistance <= 0 then
    return nil, nil, "ACCESS_TO_APPROACH_ROAD_PATH_EMPTY"
  end

  local count = templateGroup:GetInitialSize()
  if type(count) ~= "number" or count < 1 then
    return nil, nil, "TEMPLATE_UNIT_COUNT_INVALID"
  end
  local leadDistance = ROAD_SPAWN_REAR_CLEARANCE_M + (count - 1) * ROAD_SPAWN_VEHICLE_SPACING_M
  if leadDistance >= totalDistance then
    return nil, nil, "ACCESS_TO_APPROACH_ROAD_PATH_TOO_SHORT"
  end

  local positions = {}
  local maximumSnap = 0
  for index = 1, count do
    local routeDistance = leadDistance - (index - 1) * ROAD_SPAWN_VEHICLE_SPACING_M
    local rawVec2 = pointAtDistance(routePoints, totalDistance, routeDistance)
    local rawCoordinate = COORDINATE:NewFromVec2(rawVec2)
    local roadCoordinate = rawCoordinate:GetClosestPointToRoad(false)
    if not roadCoordinate then
      return nil, nil, "SPAWN_ROAD_PROJECTION_UNAVAILABLE unit=" .. tostring(index)
    end
    local snapDistance = rawCoordinate:Get2DDistance(roadCoordinate)
    maximumSnap = math.max(maximumSnap, snapDistance)
    if snapDistance > ROAD_SPAWN_MAX_SNAP_M then
      return nil, nil, "SPAWN_ROAD_SNAP_TOO_LARGE unit=" .. tostring(index) .. " distanceM=" .. tostring(roundMeters(snapDistance))
    end
    if site.accessZoneObject:IsVec2InZone(roadCoordinate:GetVec2()) ~= true then
      return nil, nil, "SPAWN_POSITION_OUTSIDE_ACCESS unit=" .. tostring(index)
    end
    positions[index] = {
      x = roadCoordinate.x,
      y = roadCoordinate.z,
      alt = roadCoordinate.y,
      heading = headingAtDistance(routePoints, totalDistance, routeDistance),
    }
    if index > 1 and distance2d(positions[index - 1], positions[index]) < ROAD_SPAWN_MIN_SEPARATION_M then
      return nil, nil, "SPAWN_VEHICLE_SEPARATION_TOO_SMALL unit=" .. tostring(index)
    end
  end

  return positions, {
    leadDistance = leadDistance,
    maximumSnap = maximumSnap,
    roadLength = roadLength or totalDistance,
  }
end

local function installRoadAlignedWarehouseSpawnAdapter(site)
  local originalSpawn = site.brigade._SpawnAssetGroundNaval
  if type(originalSpawn) ~= "function" then
    fail(site, "WAREHOUSE_PRIVATE_SPAWN_UNAVAILABLE")
    return false
  end
  if site.brigade.ValidateAndRepositionGroundUnits == true then
    fail(site, "WAREHOUSE_REPOSITIONING_CONFLICT")
    return false
  end

  site.brigade._SpawnAssetGroundNaval = function(self, alias, asset, request, spawnzone, lateactivated)
    if not asset or asset.category ~= Group.Category.GROUND then
      return originalSpawn(self, alias, asset, request, spawnzone, lateactivated)
    end
    if type(asset.template) ~= "table" or type(asset.template.units) ~= "table" then
      fail(site, "WAREHOUSE_TEMPLATE_UNAVAILABLE")
      return nil
    end
    if #asset.template.units ~= #site.roadSpawnPositions then
      fail(site, "WAREHOUSE_TEMPLATE_POSITION_COUNT_MISMATCH expected=" .. tostring(#site.roadSpawnPositions) .. " actual=" .. tostring(#asset.template.units))
      return nil
    end

    local template = self:_SpawnAssetPrepareTemplate(asset, alias)
    if not template or type(template.units) ~= "table" or #template.units ~= #site.roadSpawnPositions then
      fail(site, "WAREHOUSE_SPAWN_TEMPLATE_INVALID")
      return nil
    end

    template.route.points[1] = template.route.points[1] or {}
    for index, position in ipairs(site.roadSpawnPositions) do
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
    template.route.points[1].x = site.roadSpawnPositions[1].x
    template.route.points[1].y = site.roadSpawnPositions[1].y
    template.x = site.roadSpawnPositions[1].x
    template.y = site.roadSpawnPositions[1].y
    template.alt = site.roadSpawnPositions[1].alt
    template.lateActivation = lateactivated

    log("ROAD_ALIGNED_WAREHOUSE_SPAWN site=" .. site.id
      .. " units=" .. tostring(#site.roadSpawnPositions)
      .. " leadDistanceM=" .. tostring(roundMeters(site.roadSpawnDiagnostics.leadDistance))
      .. " maximumSnapM=" .. tostring(roundMeters(site.roadSpawnDiagnostics.maximumSnap)))
    return _DATABASE:Spawn(template)
  end
  return true
end

local function prepareSite(site, templateGroup)
  site.failed = false
  site.spawnCount = 0
  site.returnedCount = 0
  site.addAssetCount = 0
  site.returnIssued = false
  site.passed = false
  site.firstArmyGroup = nil
  site.firstArmyGroupName = nil
  site.mission1 = nil
  site.mission1Done = false

  local warehouseHost = UNIT:FindByName(site.warehouse)
  if not warehouseHost then
    warehouseHost = STATIC:FindByName(site.warehouse, false)
  end
  local accessZone = ZONE:FindByName(site.accessZone)
  local observationZone = ZONE:FindByName(site.observationZone)

  if not requireObject(site, warehouseHost, site.warehouse) then return false end
  if not requireObject(site, templateGroup, TEMPLATE_NAME) then return false end
  if not requireObject(site, accessZone, site.accessZone) then return false end
  if not requireObject(site, observationZone, site.observationZone) then return false end

  site.accessZoneObject = accessZone
  site.targetCoord = observationZone:GetCoordinate()
  local accessCoord = accessZone:GetCoordinate()
  local totalDistance = accessCoord:Get2DDistance(site.targetCoord)
  if totalDistance <= APPROACH_STANDOFF_M + MIN_APPROACH_LEG_M then
    fail(site, "APPROACH_GEOMETRY_TOO_SHORT totalDistanceM=" .. tostring(roundMeters(totalDistance)))
    return false
  end

  local approachFraction = (totalDistance - APPROACH_STANDOFF_M) / totalDistance
  local rawApproachCoord = accessCoord:GetIntermediateCoordinate(site.targetCoord, approachFraction)
  site.approachCoord = rawApproachCoord:GetClosestPointToRoad() or rawApproachCoord
  local approachLeg = accessCoord:Get2DDistance(site.approachCoord)
  if approachLeg < MIN_APPROACH_LEG_M then
    fail(site, "APPROACH_LEG_TOO_SHORT distanceM=" .. tostring(roundMeters(approachLeg)))
    return false
  end

  site.brigade = BRIGADE:New(site.warehouse, site.brigadeName)
  if not site.brigade then
    fail(site, "BRIGADE_CONSTRUCTION")
    return false
  end
  site.brigade:SetSpawnZone(accessZone, 1000)

  site.platoon = PLATOON:New(TEMPLATE_NAME, 1, site.platoonName)
  if not site.platoon then
    fail(site, "PLATOON_CONSTRUCTION")
    return false
  end
  site.platoon:AddMissionCapability(AUFTRAG.Type.ARMOREDGUARD, 100)
  site.brigade:AddPlatoon(site.platoon)

  local roadSpawnPositions, roadSpawnDiagnostics, roadSpawnError = buildRoadSpawnPositions(site, templateGroup)
  if not roadSpawnPositions then
    fail(site, roadSpawnError)
    return false
  end
  site.roadSpawnPositions = roadSpawnPositions
  site.roadSpawnDiagnostics = roadSpawnDiagnostics
  if not installRoadAlignedWarehouseSpawnAdapter(site) then
    return false
  end

  log("SITE_READY site=" .. site.id
    .. " approachLegM=" .. tostring(roundMeters(approachLeg))
    .. " roadSpawnLeadM=" .. tostring(roundMeters(roadSpawnDiagnostics.leadDistance))
    .. " roadSpawnMaxSnapM=" .. tostring(roundMeters(roadSpawnDiagnostics.maximumSnap))
    .. " returnZone=" .. site.accessZone)
  return true
end

local function verifyWarehouseReturn(site)
  if global.failed or site.failed then
    return
  end
  if site.returnedCount ~= 1 then
    fail(site, "RETURNED_COUNT expected=1 actual=" .. tostring(site.returnedCount))
    return
  end
  if site.addAssetCount ~= 1 then
    fail(site, "WAREHOUSE_ADD_ASSET_COUNT expected=1 actual=" .. tostring(site.addAssetCount))
    return
  end
  if site.spawnCount ~= 1 then
    fail(site, "SPAWN_COUNT expected=1 actual=" .. tostring(site.spawnCount))
    return
  end
  if site.firstArmyGroup:IsAlive() then
    fail(site, "PHYSICAL_GROUP_NOT_REMOVED_AFTER_WAREHOUSE_ADD name=" .. site.firstArmyGroupName)
    return
  end
  site.passed = true
  global.passedSites = global.passedSites + 1
  log("SITE_RUNTIME_PASS site=" .. site.id
    .. " spawnCount=1 returnedCount=1 warehouseAddAssetCount=1 physicalGroupRemoved=true")
  maybeGlobalPass()
end

local function issueReturn(site)
  if global.failed or site.failed or site.returnIssued then
    return
  end
  local armyGroup = site.firstArmyGroup
  if not armyGroup or not armyGroup:IsAlive() then
    fail(site, "RETURN_GROUP_NOT_ALIVE")
    return
  end
  site.returnIssued = true
  armyGroup:RTZ(site.accessZoneObject, ENUMS.Formation.Vehicle.OnRoad)
  log("RETURN_TO_HANDOFF_QUEUED site=" .. site.id
    .. " group=" .. site.firstArmyGroupName
    .. " zone=" .. site.accessZone
    .. " formation=OnRoad")
end

local function attachArmyGroupCallbacks(site, armyGroup)
  if armyGroup.__omwGroundA4Callbacks then
    return
  end
  armyGroup.__omwGroundA4Callbacks = true

  local previousOwner = global.armyGroupOwners[armyGroup:GetName()]
  if previousOwner and previousOwner ~= site.id then
    fail(site, "GROUP_CROSS_SITE_COLLISION name=" .. tostring(armyGroup:GetName()) .. " owner=" .. tostring(previousOwner))
    return
  end
  global.armyGroupOwners[armyGroup:GetName()] = site.id

  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if global.failed or site.failed then
      return
    end
    if Mission == site.mission1 then
      log("APPROACH_GUARD_EXECUTING site=" .. site.id .. " formation=OnRoad")
      site.mission1:__Cancel(APPROACH_HOLD_SEC)
    end
  end

  function armyGroup:OnAfterMissionDone(From, Event, To, Mission)
    if global.failed or site.failed or Mission ~= site.mission1 then
      return
    end
    site.mission1Done = true
    if not self:IsAlive() then
      fail(site, "GROUP_REMOVED_AFTER_MISSION1")
      return
    end
    log("MISSION1_DONE site=" .. site.id .. " physicalGroupRetained=true")
    SCHEDULER:New(nil, function() issueReturn(site) end, {}, RETURN_DELAY_SEC)
  end

  function armyGroup:OnAfterReturned(From, Event, To)
    if global.failed or site.failed then
      return
    end
    if self ~= site.firstArmyGroup or self:GetName() ~= site.firstArmyGroupName then
      fail(site, "RETURNED_DIFFERENT_GROUP name=" .. tostring(self:GetName()))
      return
    end
    site.returnedCount = site.returnedCount + 1
    if site.returnedCount ~= 1 then
      fail(site, "DUPLICATE_RETURNED count=" .. tostring(site.returnedCount))
      return
    end
    log("RETURNED_HANDOFF site=" .. site.id .. " group=" .. site.firstArmyGroupName)
    SCHEDULER:New(nil, function() verifyWarehouseReturn(site) end, {}, POST_RETURN_VERIFY_DELAY_SEC)
  end
end

local function installBrigadeCallbacks(site)
  site.brigade.OnAfterAssetSpawned = function(self, From, Event, To, Group, Asset, Request)
    if global.failed or site.failed then
      return
    end
    site.spawnCount = site.spawnCount + 1
    local groupName = Group and Group:GetName() or "UNKNOWN"
    if site.spawnCount ~= 1 then
      fail(site, "DUPLICATE_GROUP count=" .. tostring(site.spawnCount) .. " name=" .. tostring(groupName))
      return
    end
    log("GROUP_MATERIALIZED site=" .. site.id .. " name=" .. tostring(groupName))
  end

  site.brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
    if global.failed or site.failed then
      return
    end
    if not ArmyGroup then
      fail(site, "ARMYGROUP_NIL")
      return
    end
    attachArmyGroupCallbacks(site, ArmyGroup)
    if global.failed or site.failed then
      return
    end
    local groupName = ArmyGroup:GetName()
    if not site.firstArmyGroup then
      site.firstArmyGroup = ArmyGroup
      site.firstArmyGroupName = groupName
    elseif ArmyGroup ~= site.firstArmyGroup or groupName ~= site.firstArmyGroupName then
      fail(site, "DUPLICATE_GROUP missionGroup=" .. tostring(groupName) .. " expected=" .. tostring(site.firstArmyGroupName))
      return
    end
    if Mission == site.mission1 then
      log("MISSION1_ON_MISSION site=" .. site.id .. " name=" .. tostring(groupName))
    end
  end

  site.brigade.OnAfterAddAsset = function(self, From, Event, To, Group, Groups)
    if global.failed or site.failed then
      return
    end
    local groupName = Group and Group:GetName() or "UNKNOWN"
    if groupName ~= site.firstArmyGroupName then
      fail(site, "WAREHOUSE_ADD_UNEXPECTED_GROUP name=" .. tostring(groupName))
      return
    end
    site.addAssetCount = site.addAssetCount + 1
    if site.addAssetCount ~= 1 then
      fail(site, "DUPLICATE_WAREHOUSE_ADD count=" .. tostring(site.addAssetCount))
      return
    end
    log("WAREHOUSE_ADD_ASSET site=" .. site.id .. " group=" .. groupName)
  end

  site.brigade.OnAfterStart = function(self, From, Event, To)
    if global.failed or site.failed then
      return
    end
    log("BRIGADE_STARTED site=" .. site.id .. " brigade=" .. site.brigadeName)
    SCHEDULER:New(nil, function()
      if global.failed or site.failed then
        return
      end
      local availableAssets = site.platoon:CountAssets(true, AUFTRAG.Type.ARMOREDGUARD)
      if availableAssets ~= 1 then
        fail(site, "PLATOON_ASSET_COUNT expected=1 actual=" .. tostring(availableAssets))
        return
      end
      site.mission1 = AUFTRAG:NewARMOREDGUARD(site.approachCoord, ENUMS.Formation.Vehicle.OnRoad)
      site.mission1:SetName("OMW_GND_A4_" .. site.id .. "_ROAD_APPROACH")
      site.mission1:SetMissionSpeed(ROAD_SPEED_KNOTS)
      site.mission1:SetReturnToLegion(false)
      site.brigade:AddMission(site.mission1)
      log("MISSION1_QUEUED site=" .. site.id .. " formation=OnRoad speedKt=" .. tostring(ROAD_SPEED_KNOTS))
    end, {}, POST_START_DELAY_SEC)
  end
end

log("START testId=" .. TEST_ID .. " sites=" .. tostring(#sites))

local templateGroup = GROUP:FindByName(TEMPLATE_NAME)
if not templateGroup then
  fail(nil, "MISSING_OBJECT " .. TEMPLATE_NAME)
  return
end

for _, site in ipairs(sites) do
  if not prepareSite(site, templateGroup) then
    return
  end
end

for _, site in ipairs(sites) do
  installBrigadeCallbacks(site)
end

for _, site in ipairs(sites) do
  site.brigade:Start()
end
