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
assert(config.configurationVersion == "TM01M-moose-native-five-convoys-1")
assert(config.routing.speedKph == 50, "expected 50 km/h multi-convoy test")
assert(#config.convoys == 5, "expected five configured convoys")
assert(config.zones == nil, "legacy single-convoy zones table must be removed")
assert(config.routing.msrPathlines == nil, "legacy shared route pathlines must be removed")

local ZoneMethods = {}
function ZoneMethods:GetCoordinate() return coordinate(self.name, self.x, self.y) end
function ZoneMethods:IsVec2InZone(vec2)
  local dx = vec2.x - self.x
  local dy = vec2.y - self.y
  return math.sqrt(dx * dx + dy * dy) <= self.radius
end

local zones = {}
local routeGeometry = {
  EAST_E3_BGR_KBL = { startX = 0, targetX = 1000, y = 0, reversed = true },
  EAST_E2_KBL_JBAD = { startX = 2000, targetX = 3000, y = 1000, reversed = true },
  EAST_E1_TRK_JBAD = { startX = 4000, targetX = 5000, y = 2000 },
  KUNAR_K1_JBAD_ASAD = { startX = 6000, targetX = 7000, y = 3000 },
  CAL_ASAD_BOSTIK = { startX = 8000, targetX = 10000, y = 4000 },
}

for _, convoyConfig in ipairs(config.convoys) do
  local geometry = assert(routeGeometry[convoyConfig.id])
  zones[convoyConfig.startZone] = setmetatable({
    name = convoyConfig.startZone,
    x = geometry.startX,
    y = geometry.y,
    radius = 500,
  }, { __index = ZoneMethods })
  zones[convoyConfig.targetZone] = setmetatable({
    name = convoyConfig.targetZone,
    x = geometry.targetX,
    y = geometry.y,
    radius = 500,
  }, { __index = ZoneMethods })
end

_G.ZONE = { FindByName = function(_, name) return zones[name] end }
_G.ZONE_BASE = {
  GetCoordinate = ZoneMethods.GetCoordinate,
  IsVec2InZone = ZoneMethods.IsVec2InZone,
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
        { x = geometry.targetX - 100, y = geometry.y },
        { x = geometry.startX + 100, y = geometry.y },
      }
    else
      points = {
        { x = geometry.startX + 100, y = geometry.y },
        { x = geometry.targetX - 100, y = geometry.y },
      }
    end
    pathlines[convoyConfig.msrPathlines[1]] = setmetatable({ points = points }, {
      __index = PathlineMethods,
    })
  else
    assert(convoyConfig.id == "CAL_ASAD_BOSTIK", "only California route should use two PATHLINE objects")
    pathlines[convoyConfig.msrPathlines[1]] = setmetatable({
      points = {
        { x = geometry.startX + 100, y = geometry.y },
        { x = 9000, y = geometry.y },
      },
    }, { __index = PathlineMethods })
    pathlines[convoyConfig.msrPathlines[2]] = setmetatable({
      points = {
        { x = 9000, y = geometry.y },
        { x = geometry.targetX - 100, y = geometry.y },
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
    route = nil,
    inZone = false,
  }
  function group:IsAlive() return self.alive end
  function group:CountAliveUnits() return self.alive and 6 or 0 end
  function group:GetName() return self.alias .. "#001" end
  function group:Route(route)
    self.route = route
    return true
  end
  function group:IsCompletelyInZone()
    return self.inZone
  end
  runtimeGroups[alias] = group
  return group
end

_G.GROUP = {
  FindByName = function(_, name)
    if name == config.template.groupName then return { template = true } end
    return nil
  end,
  CountAliveUnits = function() end,
  IsCompletelyInZone = function() end,
}
_G.CONTROLLABLE = { Route = function() end }

local spawners = {}
_G.SPAWN = {
  InitSetUnitAbsolutePositions = function() end,
  Spawn = function() end,
  NewWithAlias = function(_, templateName, alias)
    assert(templateName == config.template.groupName)
    assert(spawners[alias] == nil, "runtime alias must be unique: " .. tostring(alias))
    local spawner = { alias = alias }
    function spawner:InitSetUnitAbsolutePositions(positions)
      spawnPositionsByAlias[self.alias] = positions
      self.positions = positions
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
    assert(type(callback) == "function", "scheduler callback missing")
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
assert(#state.convoys == 5, "five convoy runtime states expected")
assert(schedulerCalls == 1, "exactly one MOOSE scheduler expected for all convoys")
for _, convoyState in ipairs(state.convoys) do
  assert(convoyState.routePlan ~= nil, "route plan missing for " .. convoyState.config.id)
end
assert(state.convoyById.EAST_E3_BGR_KBL.routePlan.pathlineDiagnostics[1]:find(":reversed", 1, true))
assert(state.convoyById.EAST_E2_KBL_JBAD.routePlan.pathlineDiagnostics[1]:find(":reversed", 1, true))
assert(state.convoyById.EAST_E1_TRK_JBAD.routePlan.pathlineDiagnostics[1]:find(":forward", 1, true))
assert(state.convoyById.KUNAR_K1_JBAD_ASAD.routePlan.pathlineDiagnostics[1]:find(":forward", 1, true))
assert(#state.convoyById.CAL_ASAD_BOSTIK.routePlan.pathlineDiagnostics == 2)

assert(state.spawnAllConvoys() == true, "multi-convoy spawn failed")
assert(state.spawnAllConvoys() == false, "duplicate multi-convoy spawn must be rejected")
for _, convoyState in ipairs(state.convoys) do
  local positions = spawnPositionsByAlias[convoyState.config.runtimeAlias]
  assert(type(positions) == "table" and #positions == 6,
    "six absolute spawn positions expected for " .. convoyState.config.id)
  for index, position in ipairs(positions) do
    assert(convoyState.objects.startZone:IsVec2InZone({ x = position.x, y = position.y }),
      "spawned vehicle must remain inside start zone")
    assert(position.heading == 0, "test route heading must point north")
    if index > 1 then
      assert(math.abs((positions[index - 1].x - position.x)
        - config.routing.vehicleSpacingMeters) < 0.001,
        "vehicles must be spaced individually along the route")
    end
  end
end

assert(state.startAllRoutes() == true, "multi-convoy route start failed")
assert(state.startAllRoutes() == false, "duplicate multi-convoy route start must be rejected")
for _, convoyState in ipairs(state.convoys) do
  local runtimeGroup = runtimeGroups[convoyState.config.runtimeAlias]
  assert(runtimeGroup and #runtimeGroup.route >= 2,
    "assigned route missing for " .. convoyState.config.id)
  assert(runtimeGroup.route[1].x > spawnPositionsByAlias[convoyState.config.runtimeAlias][1].x,
    "first route waypoint must be ahead of the lead vehicle")
  assert(runtimeGroup.route[#runtimeGroup.route].x
      == zones[convoyState.config.targetZone].x,
    "final route waypoint must reach target-zone road coordinate")
  for _, waypoint in ipairs(runtimeGroup.route) do
    assert(waypoint.speed == 50, "every waypoint must command 50 km/h")
    assert(waypoint.formation == "On Road", "route must use On Road formation")
  end
end

for _, runtimeGroup in pairs(runtimeGroups) do runtimeGroup.inZone = true end
assert(type(schedulerCallback) == "function")
schedulerCallback()
for _, convoyState in ipairs(state.convoys) do
  assert(convoyState.arrived == true, "arrival must be detected for " .. convoyState.config.id)
end
assert(state.allArrivedLogged == true, "aggregate all-convoys arrival must be logged")

local function countLogEvent(event)
  local count = 0
  for _, text in ipairs(logs) do
    if text:find("event=" .. event, 1, true) then count = count + 1 end
  end
  return count
end
assert(countLogEvent("convoy_route_plan_compiled") == 5)
assert(countLogEvent("convoy_spawned") == 5)
assert(countLogEvent("convoy_route_started") == 5)
assert(countLogEvent("convoy_arrived") == 5)
assert(countLogEvent("all_convoys_arrived") == 1)
assert(#messages >= 4, "expected MOOSE MESSAGE output")

local source = assert(io.open(repositoryRoot .. "/mission/tests/tm01-blue-convoy/src/tm01m.lua", "rb")):read("*a")
assert(not source:find("timer.scheduleFunction", 1, true), "native timer scheduling is forbidden")
assert(not source:find("trigger.action.outText", 1, true), "native text output is forbidden")
assert(not source:find("Group.getByName", 1, true), "native group lookup is forbidden")
assert(not source:find("ConvoyProxyController", 1, true), "old proxy controller is forbidden")
assert(not source:find("RepresentationInterestMonitor", 1, true), "old interest monitor is forbidden")
assert(not source:find("TaskGroundOnRoad", 1, true),
  "TM01M must not rebuild independent road routes to legacy anchor zones")
assert(source:find("PATHLINE:FindByName", 1, true),
  "TM01M must resolve Mission Editor MSR PATHLINE objects through MOOSE")
assert(source:find("InitSetUnitAbsolutePositions", 1, true),
  "TM01M must use MOOSE absolute per-unit spawn placement")
assert(source:find("SPAWN:NewWithAlias", 1, true),
  "TM01M must create independent MOOSE spawners from the shared template")
assert(source:find("CONTROLLABLE and CONTROLLABLE.Route", 1, true),
  "TM01M must validate the inherited CONTROLLABLE.Route implementation")
assert(not source:find('"GROUP.Route", GROUP and GROUP.Route', 1, true),
  "TM01M must not require Route to be declared directly on GROUP")

print("TM01M static PASS: five simultaneous MOOSE PATHLINE convoys at 50 km/h")
