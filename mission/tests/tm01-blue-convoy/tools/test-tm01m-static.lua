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
assert(config.zones.routeAnchors == nil, "TM01M must no longer depend on route-anchor zones")
assert(#config.routing.msrPathlines == 2, "expected two configured MSR PATHLINE objects")

local ZoneMethods = {}
function ZoneMethods:GetCoordinate() return coordinate(self.name, self.x, self.y) end
function ZoneMethods:IsVec2InZone(vec2)
  local dx = vec2.x - self.x
  local dy = vec2.y - self.y
  return math.sqrt(dx * dx + dy * dy) <= self.radius
end

local zones = {
  [config.zones.start] = setmetatable({ name = config.zones.start, x = 0, y = 0, radius = 500 },
    { __index = ZoneMethods }),
  [config.zones.target] = setmetatable({ name = config.zones.target, x = 3000, y = 0, radius = 500 },
    { __index = ZoneMethods }),
}

_G.ZONE = { FindByName = function(_, name) return zones[name] end }
_G.ZONE_BASE = {
  GetCoordinate = ZoneMethods.GetCoordinate,
  IsVec2InZone = ZoneMethods.IsVec2InZone,
}

local PathlineMethods = {}
function PathlineMethods:GetNumberOfPoints() return #self.points end
function PathlineMethods:GetPoint2DFromIndex(index) return self.points[index] end

local pathlines = {
  [config.routing.msrPathlines[1]] = setmetatable({
    name = config.routing.msrPathlines[1],
    -- Deliberately opposite to the required Bagram -> Kabul direction.
    points = {
      { x = 1500, y = 0 },
      { x = 200, y = 0 },
    },
  }, { __index = PathlineMethods }),
  [config.routing.msrPathlines[2]] = setmetatable({
    name = config.routing.msrPathlines[2],
    -- Deliberately opposite to the required Kabul -> Jalalabad direction.
    points = {
      { x = 2800, y = 0 },
      { x = 1500, y = 0 },
    },
  }, { __index = PathlineMethods }),
}

_G.PATHLINE = {
  FindByName = function(_, name) return pathlines[name] end,
  GetNumberOfPoints = PathlineMethods.GetNumberOfPoints,
  GetPoint2DFromIndex = PathlineMethods.GetPoint2DFromIndex,
}

local runtimeGroup = {
  alive = true,
  route = nil,
  IsAlive = function(self) return self.alive end,
  CountAliveUnits = function() return 6 end,
  GetName = function() return "TM01M_BLUE_CONVOY#001" end,
  Route = function(self, route)
    self.route = route
    return true
  end,
  IsCompletelyInZone = function() return false end,
}

_G.GROUP = {
  FindByName = function(_, name)
    if name == config.template.groupName then return { template = true } end
    return nil
  end,
  CountAliveUnits = function() end,
  IsCompletelyInZone = function() end,
}
_G.CONTROLLABLE = { Route = function() end }

local spawnPositions = nil
local spawner = {
  InitSetUnitAbsolutePositions = function(self, positions)
    spawnPositions = positions
    self.positions = positions
    return self
  end,
  Spawn = function() return runtimeGroup end,
}

_G.SPAWN = {
  InitSetUnitAbsolutePositions = function() end,
  Spawn = function() end,
  NewWithAlias = function() return spawner end,
}

local schedulerCalls = 0
_G.SCHEDULER = {
  New = function(_, _, callback)
    schedulerCalls = schedulerCalls + 1
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
assert(schedulerCalls == 1, "exactly one MOOSE scheduler expected")
assert(state.routePlan ~= nil, "MSR route plan must be compiled during bootstrap")
assert(state.routePlan.pathlineDiagnostics[1]:find(":reversed", 1, true),
  "first PATHLINE must be oriented from Bagram toward Kabul")
assert(state.routePlan.pathlineDiagnostics[2]:find(":reversed", 1, true),
  "second PATHLINE must be oriented from Kabul toward Jalalabad")

assert(state.spawnConvoy() == true, "spawn failed")
assert(type(spawnPositions) == "table" and #spawnPositions == 6,
  "MOOSE absolute unit layout must contain six positions")
for index, position in ipairs(spawnPositions) do
  assert(zones[config.zones.start]:IsVec2InZone({ x = position.x, y = position.y }),
    "spawned vehicle must remain inside start zone")
  assert(position.heading == 0, "test route heading must point north")
  if index > 1 then
    assert(math.abs((spawnPositions[index - 1].x - position.x)
      - config.routing.vehicleSpacingMeters) < 0.001,
      "vehicles must be spaced individually along the route")
  end
end

assert(state.startRoute() == true, "route start failed")
assert(#runtimeGroup.route >= 4, "MSR route must contain multiple constrained waypoints")
assert(runtimeGroup.route[1].x > spawnPositions[1].x,
  "first route waypoint must be ahead of the lead vehicle")
assert(runtimeGroup.route[#runtimeGroup.route].x == zones[config.zones.target].x,
  "final route waypoint must reach the target-zone road coordinate")
for _, waypoint in ipairs(runtimeGroup.route) do
  assert(waypoint.speed == config.routing.speedKph, "unexpected route speed")
  assert(waypoint.formation == config.routing.formation, "route must use On Road formation")
end
assert(#messages >= 3, "expected MOOSE MESSAGE output")

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
assert(source:find("CONTROLLABLE and CONTROLLABLE.Route", 1, true),
  "TM01M must validate the inherited CONTROLLABLE.Route implementation")
assert(not source:find('"GROUP.Route", GROUP and GROUP.Route', 1, true),
  "TM01M must not require Route to be declared directly on GROUP")

print("TM01M static PASS: MOOSE PATHLINE MSR routing and absolute per-unit road spawn")
