local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

_G.env = {
  info = function() end,
  error = function() end,
}

local messages = {}
_G.MESSAGE = {
  New = function(_, text)
    messages[#messages + 1] = text
    return { ToAll = function() return true end }
  end,
}

local zones = {}
local function coordinate(name, x, z)
  return {
    x = x or 0,
    z = z or 0,
    WaypointGround = function(_, speed, formation)
      return { name = name, speed = speed, formation = formation }
    end,
  }
end

local config = loadLua("mission/tests/tm01-blue-convoy/config-tm01m.lua")
for index, name in ipairs(config.zones.routeAnchors) do
  zones[name] = { GetCoordinate = function() return coordinate(name, index * 1000, index * 1000) end }
end
zones[config.zones.start] = { GetCoordinate = function() return coordinate(config.zones.start, 100, 200) end }
zones[config.zones.target] = { GetCoordinate = function() return coordinate(config.zones.target, 9000, 9000) end }

_G.ZONE = { FindByName = function(_, name) return zones[name] end }
_G.ZONE_BASE = { GetCoordinate = function() end }

local runtimeGroup = {
  alive = true,
  route = nil,
  currentCoordinate = coordinate("runtime", 100, 200),
  IsAlive = function(self) return self.alive end,
  CountAliveUnits = function() return 6 end,
  GetName = function() return "TM01M_BLUE_CONVOY#001" end,
  GetCoordinate = function(self) return self.currentCoordinate end,
  TaskGroundOnRoad = function(_, toCoordinate, speed, formation, _, fromCoordinate)
    return {
      fromCoordinate:WaypointGround(speed, formation),
      toCoordinate:WaypointGround(speed, "On Road"),
    }
  end,
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
_G.CONTROLLABLE = {
  Route = function() end,
  TaskGroundOnRoad = function() end,
}

local spawnCoordinate = nil
_G.SPAWN = {
  SpawnFromCoordinate = function() end,
  NewWithAlias = function()
    return {
      SpawnFromCoordinate = function(_, value)
        spawnCoordinate = value
        runtimeGroup.currentCoordinate = value
        return runtimeGroup
      end,
    }
  end,
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
assert(state.spawnConvoy() == true, "spawn failed")
assert(spawnCoordinate == zones[config.zones.start]:GetCoordinate() or spawnCoordinate.x == 100,
  "convoy must spawn from configured start zone coordinate")
assert(state.startRoute() == true, "route start failed")
assert(#runtimeGroup.route == 9, "expected current point plus seven anchors plus target")
assert(runtimeGroup.route[1].speed == 30, "unexpected route speed")
assert(runtimeGroup.route[1].formation == "Off Road", "initial road ingress must use off-road formation")
assert(runtimeGroup.route[2].formation == "On Road", "road segment must use MOOSE on-road waypoint")
assert(#messages >= 3, "expected MOOSE MESSAGE output")

local source = assert(io.open(repositoryRoot .. "/mission/tests/tm01-blue-convoy/src/tm01m.lua", "rb")):read("*a")
assert(not source:find("timer.scheduleFunction", 1, true), "native timer scheduling is forbidden")
assert(not source:find("trigger.action.outText", 1, true), "native text output is forbidden")
assert(not source:find("Group.getByName", 1, true), "native group lookup is forbidden")
assert(not source:find("ConvoyProxyController", 1, true), "old proxy controller is forbidden")
assert(not source:find("RepresentationInterestMonitor", 1, true), "old interest monitor is forbidden")
assert(source:find("SpawnFromCoordinate(objects.startZone:GetCoordinate())", 1, true),
  "TM01M must spawn at the configured start zone")
assert(source:find("TaskGroundOnRoad", 1, true),
  "TM01M must use MOOSE road path generation")
assert(source:find("CONTROLLABLE and CONTROLLABLE.Route", 1, true),
  "TM01M must validate the inherited CONTROLLABLE.Route implementation")
assert(not source:find('"GROUP.Route", GROUP and GROUP.Route', 1, true),
  "TM01M must not require Route to be declared directly on GROUP")

print("TM01M static PASS: zoned SPAWN and MOOSE road-routing baseline")
