local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local logs = {}
_G.env = {
  info = function(text) logs[#logs + 1] = text end,
  error = function(text) logs[#logs + 1] = text end,
}

local messages = {}
_G.MESSAGE = {
  New = function(_, text)
    messages[#messages + 1] = text
    return { ToAll = function() return true end }
  end,
}

local CoordinateMethods = {}
local function coordinate(name, x, y)
  return setmetatable({ name = name, x = x, z = y }, { __index = CoordinateMethods })
end

function CoordinateMethods:GetVec2()
  return { x = self.x, y = self.z }
end

function CoordinateMethods:Get2DDistance(other)
  local dx = other.x - self.x
  local dy = other.z - self.z
  return math.sqrt(dx * dx + dy * dy)
end

function CoordinateMethods:GetClosestPointToRoad()
  return coordinate(self.name .. ":road", self.x, self.z)
end

function CoordinateMethods:GetPathOnRoad(toCoordinate)
  return {
    coordinate(self.name .. ":path-start", self.x, self.z),
    coordinate(toCoordinate.name .. ":path-end", toCoordinate.x, toCoordinate.z),
  }, self:Get2DDistance(toCoordinate), true
end

function CoordinateMethods:WaypointGround(speed, formation)
  return {
    name = self.name,
    x = self.x,
    y = self.z,
    speed = speed,
    formation = formation,
  }
end

_G.COORDINATE = {
  NewFromVec2 = function(_, vec2) return coordinate("vec2", vec2.x, vec2.y) end,
  GetVec2 = CoordinateMethods.GetVec2,
  Get2DDistance = CoordinateMethods.Get2DDistance,
  GetClosestPointToRoad = CoordinateMethods.GetClosestPointToRoad,
  GetPathOnRoad = CoordinateMethods.GetPathOnRoad,
  WaypointGround = CoordinateMethods.WaypointGround,
}

local config = loadLua("mission/tests/tm01-blue-convoy/config-tm01m.lua")
assert(config.configurationVersion == "TM01M-moose-native-five-convoys-5")
assert(config.template.groupName == "TPL_BLUE_CONVOY_STANDARD_07")
assert(config.template.expectedVehicleCount == 7)
assert(config.templateLibrary.activeSelectionMode == "FIXED_STANDARD_07")
assert(config.templateLibrary.plannedSelectionMode == "MOOSE_InitRandomizeTemplate")
assert(config.templateLibrary.availableGroups[1].groupName == "TPL_BLUE_CONVOY_LIGHT_06")
assert(config.templateLibrary.availableGroups[1].expectedVehicleCount == 6)
assert(config.templateLibrary.availableGroups[2].groupName == "TPL_BLUE_CONVOY_STANDARD_07")
assert(config.templateLibrary.availableGroups[2].expectedVehicleCount == 7)
assert(config.templateLibrary.legacyGroupNames[1] == "TPL_TEST_BLUE_CONVOY_STANDARD_01")
assert(config.routing.speedKph == 50)
assert(config.arrival.despawnDelaySeconds == 60)
assert(config.arrival.generateDestroyEvents == false)
assert(#config.convoys == 5)

local expectedEndpoints = {
  EAST_E3_BGR_KBL = {
    startZone = "OMW_LOG_NODE_BAGRAM",
    targetZone = "OMW_LOG_NODE_KABUL",
    pathlines = { "MSR_EAST_E03" },
  },
  EAST_E2_KBL_JBAD = {
    startZone = "OMW_LOG_NODE_KABUL",
    targetZone = "OMW_LOG_NODE_JALALABAD",
    pathlines = { "MSR_EAST_E02" },
  },
  EAST_E1_TRK_JBAD = {
    startZone = "OMW_LOG_NODE_TORKHAM",
    targetZone = "OMW_LOG_NODE_JALALABAD",
    pathlines = { "MSR_EAST_E01" },
  },
  KUNAR_K1_JBAD_ASAD = {
    startZone = "OMW_LOG_NODE_JALALABAD",
    targetZone = "OMW_LOG_NODE_ASADABAD",
    pathlines = { "MSR_KUNAR_K01" },
  },
  CAL_ASAD_BOSTIK = {
    startZone = "OMW_LOG_NODE_ASADABAD",
    targetZone = "OMW_LOG_NODE_BOSTICK",
    pathlines = { "MSR_CAL_C01", "MSR_CAL_C02" },
  },
}

local configuredNodes = {}
for _, convoyConfig in ipairs(config.convoys) do
  local expected = assert(expectedEndpoints[convoyConfig.id])
  assert(convoyConfig.startZone == expected.startZone)
  assert(convoyConfig.targetZone == expected.targetZone)
  assert(#convoyConfig.msrPathlines == #expected.pathlines)
  for index, pathlineName in ipairs(expected.pathlines) do
    assert(convoyConfig.msrPathlines[index] == pathlineName)
  end
  configuredNodes[convoyConfig.startZone] = true
  configuredNodes[convoyConfig.targetZone] = true
end

local expectedNodes = {
  OMW_LOG_NODE_BAGRAM = true,
  OMW_LOG_NODE_KABUL = true,
  OMW_LOG_NODE_TORKHAM = true,
  OMW_LOG_NODE_JALALABAD = true,
  OMW_LOG_NODE_ASADABAD = true,
  OMW_LOG_NODE_BOSTICK = true,
}
local nodeCount = 0
for nodeName in pairs(configuredNodes) do
  assert(expectedNodes[nodeName], "unexpected node " .. tostring(nodeName))
  nodeCount = nodeCount + 1
end
assert(nodeCount == 6)

local ZoneMethods = {}
function ZoneMethods:GetCoordinate()
  return coordinate(self.name, self.x, self.y)
end
function ZoneMethods:IsVec2InZone(vec2)
  local dx = vec2.x - self.x
  local dy = vec2.y - self.y
  return math.sqrt(dx * dx + dy * dy) <= self.radius
end

local nodeGeometry = {
  OMW_LOG_NODE_BAGRAM = { x = 0, y = 0 },
  OMW_LOG_NODE_KABUL = { x = 1000, y = 0 },
  OMW_LOG_NODE_TORKHAM = { x = 2000, y = 0 },
  OMW_LOG_NODE_JALALABAD = { x = 3000, y = 0 },
  OMW_LOG_NODE_ASADABAD = { x = 4000, y = 0 },
  OMW_LOG_NODE_BOSTICK = { x = 6000, y = 0 },
}

local zones = {}
for nodeName, geometry in pairs(nodeGeometry) do
  zones[nodeName] = setmetatable({
    name = nodeName,
    x = geometry.x,
    y = geometry.y,
    radius = 500,
  }, { __index = ZoneMethods })
end

_G.ZONE = { FindByName = function(_, name) return zones[name] end }
_G.ZONE_BASE = {
  GetCoordinate = ZoneMethods.GetCoordinate,
  IsVec2InZone = ZoneMethods.IsVec2InZone,
}

local routeGeometry = {
  EAST_E3_BGR_KBL = { startX = 0, targetX = 1000, reversed = true },
  EAST_E2_KBL_JBAD = { startX = 1000, targetX = 3000, reversed = true },
  EAST_E1_TRK_JBAD = { startX = 2000, targetX = 3000 },
  KUNAR_K1_JBAD_ASAD = { startX = 3000, targetX = 4000 },
  CAL_ASAD_BOSTIK = { startX = 4000, targetX = 6000 },
}

local PathlineMethods = {}
function PathlineMethods:GetNumberOfPoints() return #self.points end
function PathlineMethods:GetPoint2DFromIndex(index) return self.points[index] end

local pathlines = {}
for _, convoyConfig in ipairs(config.convoys) do
  local geometry = assert(routeGeometry[convoyConfig.id])
  if #convoyConfig.msrPathlines == 1 then
    local points
    if geometry.reversed then
      points = {
        { x = geometry.targetX - 100, y = 0 },
        { x = geometry.startX + 100, y = 0 },
      }
    else
      points = {
        { x = geometry.startX + 100, y = 0 },
        { x = geometry.targetX - 100, y = 0 },
      }
    end
    pathlines[convoyConfig.msrPathlines[1]] = setmetatable({ points = points }, {
      __index = PathlineMethods,
    })
  else
    pathlines[convoyConfig.msrPathlines[1]] = setmetatable({
      points = {
        { x = geometry.startX + 100, y = 0 },
        { x = 5000, y = 0 },
      },
    }, { __index = PathlineMethods })
    pathlines[convoyConfig.msrPathlines[2]] = setmetatable({
      points = {
        { x = 5000, y = 0 },
        { x = geometry.targetX - 100, y = 0 },
      },
    }, { __index = PathlineMethods })
  end
end

_G.PATHLINE = {
  FindByName = function(_, name) return pathlines[name] end,
  GetNumberOfPoints = PathlineMethods.GetNumberOfPoints,
  GetPoint2DFromIndex = PathlineMethods.GetPoint2DFromIndex,
}

local runtimeGroups = {}
local spawnPositionsByAlias = {}
local function newRuntimeGroup(alias)
  local group = {
    alias = alias,
    alive = true,
    inZone = false,
    route = nil,
    destroyScheduled = false,
    destroyGenerateEvent = nil,
    destroyDelay = nil,
  }
  function group:IsAlive() return self.alive end
  function group:CountAliveUnits() return self.alive and 7 or 0 end
  function group:GetName() return self.alias .. "#001" end
  function group:Route(route)
    self.route = route
    return true
  end
  function group:IsCompletelyInZone() return self.inZone end
  function group:Destroy(generateEvent, delay)
    self.destroyScheduled = true
    self.destroyGenerateEvent = generateEvent
    self.destroyDelay = delay
  end
  runtimeGroups[alias] = group
  return group
end

_G.GROUP = {
  FindByName = function(_, name)
    if name == "TPL_BLUE_CONVOY_STANDARD_07" then return { template = true } end
    return nil
  end,
  Destroy = function() end,
  CountAliveUnits = function() end,
  IsCompletelyInZone = function() end,
}
_G.CONTROLLABLE = { Route = function() end }

local spawners = {}
_G.SPAWN = {
  InitSetUnitAbsolutePositions = function() end,
  Spawn = function() end,
  NewWithAlias = function(_, templateName, alias)
    assert(templateName == "TPL_BLUE_CONVOY_STANDARD_07")
    assert(spawners[alias] == nil, "runtime alias must be unique")
    local spawner = { alias = alias }
    function spawner:InitSetUnitAbsolutePositions(positions)
      self.positions = positions
      spawnPositionsByAlias[self.alias] = positions
      return self
    end
    function spawner:Spawn()
      return newRuntimeGroup(self.alias)
    end
    spawners[alias] = spawner
    return spawner
  end,
}

local schedulerCalls = 0
local schedulerCallback = nil
_G.SCHEDULER = {
  New = function(_, _, callback)
    schedulerCalls = schedulerCalls + 1
    schedulerCallback = callback
    return { callback = callback }
  end,
}

_G.MENU_MISSION = { New = function() return {} end }
_G.MENU_MISSION_COMMAND = { New = function() return {} end }

local module = loadLua("mission/tests/tm01-blue-convoy/src/tm01m.lua")
local state = module.start({
  config = config,
  build = { testId = "TM01", stageId = "TM01M" },
})

assert(state.outcome == "READY", state.detail)
assert(#state.convoys == 5)
assert(schedulerCalls == 1)
assert(state.convoyById.EAST_E3_BGR_KBL.routePlan.pathlineDiagnostics[1]:find(":reversed", 1, true))
assert(state.convoyById.EAST_E2_KBL_JBAD.routePlan.pathlineDiagnostics[1]:find(":reversed", 1, true))
assert(state.convoyById.EAST_E1_TRK_JBAD.routePlan.pathlineDiagnostics[1]:find(":forward", 1, true))
assert(state.convoyById.KUNAR_K1_JBAD_ASAD.routePlan.pathlineDiagnostics[1]:find(":forward", 1, true))
assert(#state.convoyById.CAL_ASAD_BOSTIK.routePlan.pathlineDiagnostics == 2)

assert(state.spawnAllConvoys() == true)
assert(state.spawnAllConvoys() == false)
for _, convoyState in ipairs(state.convoys) do
  local positions = spawnPositionsByAlias[convoyState.config.runtimeAlias]
  assert(type(positions) == "table" and #positions == 7,
    "seven absolute spawn positions expected")
  for index, position in ipairs(positions) do
    assert(convoyState.objects.startZone:IsVec2InZone({ x = position.x, y = position.y }))
    assert(position.heading == 0)
    if index > 1 then
      assert(math.abs((positions[index - 1].x - position.x)
        - config.routing.vehicleSpacingMeters) < 0.001)
    end
  end
end

assert(state.startAllRoutes() == true)
assert(state.startAllRoutes() == false)
for _, convoyState in ipairs(state.convoys) do
  local runtimeGroup = runtimeGroups[convoyState.config.runtimeAlias]
  assert(runtimeGroup and #runtimeGroup.route >= 2)
  assert(runtimeGroup.route[1].x > spawnPositionsByAlias[convoyState.config.runtimeAlias][1].x)
  assert(runtimeGroup.route[#runtimeGroup.route].x == zones[convoyState.config.targetZone].x)
  for _, waypoint in ipairs(runtimeGroup.route) do
    assert(waypoint.speed == 50)
    assert(waypoint.formation == "On Road")
  end
end

for _, runtimeGroup in pairs(runtimeGroups) do runtimeGroup.inZone = true end
assert(type(schedulerCallback) == "function")
schedulerCallback()
for _, convoyState in ipairs(state.convoys) do
  local runtimeGroup = runtimeGroups[convoyState.config.runtimeAlias]
  assert(convoyState.arrived == true)
  assert(convoyState.arrivalVehicleCount == 7)
  assert(convoyState.despawnScheduled == true)
  assert(runtimeGroup.destroyScheduled == true)
  assert(runtimeGroup.destroyGenerateEvent == false)
  assert(runtimeGroup.destroyDelay == 60)
end
assert(state.allArrivedLogged == true)

for _, runtimeGroup in pairs(runtimeGroups) do runtimeGroup.alive = false end
schedulerCallback()
for _, convoyState in ipairs(state.convoys) do
  assert(convoyState.despawned == true)
  assert(convoyState.destroyed == false)
end
assert(state.allDespawnedLogged == true)

local function countLogEvent(event)
  local count = 0
  for _, text in ipairs(logs) do
    if text:find("event=" .. event, 1, true) then count = count + 1 end
  end
  return count
end

local function findLogEvent(event)
  for _, text in ipairs(logs) do
    if text:find("event=" .. event, 1, true) then return text end
  end
  return nil
end

assert(countLogEvent("convoy_route_plan_compiled") == 5)
assert(countLogEvent("convoy_spawned") == 5)
assert(countLogEvent("convoy_route_started") == 5)
assert(countLogEvent("convoy_arrived") == 5)
assert(countLogEvent("convoy_despawn_scheduled") == 5)
assert(countLogEvent("convoy_despawned") == 5)
assert(countLogEvent("convoy_destroyed") == 0)
assert(countLogEvent("all_convoys_arrived") == 1)
assert(countLogEvent("all_convoys_despawned") == 1)
assert(findLogEvent("all_convoys_arrived"):find("survivingVehicles=35", 1, true))
assert(#messages >= 5)

local source = assert(io.open(
  repositoryRoot .. "/mission/tests/tm01-blue-convoy/src/tm01m.lua",
  "rb"
)):read("*a")
assert(not source:find("timer.scheduleFunction", 1, true))
assert(not source:find("trigger.action.outText", 1, true))
assert(not source:find("Group.getByName", 1, true))
assert(source:find("PATHLINE:FindByName", 1, true))
assert(source:find("InitSetUnitAbsolutePositions", 1, true))
assert(source:find("SPAWN:NewWithAlias", 1, true))
assert(source:find("runtimeGroup:Destroy", 1, true))

print("TM01M static PASS: seven-vehicle standard template, six shared nodes, five PATHLINE convoys and cleanup")
