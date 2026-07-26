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
local function coordinate(name)
  return {
    WaypointGround = function(_, speed, formation)
      return { name = name, speed = speed, formation = formation }
    end,
  }
end

local config = loadLua("mission/tests/tm01-blue-convoy/config-tm01m.lua")
for _, name in ipairs(config.zones.routeAnchors) do
  zones[name] = { GetCoordinate = function() return coordinate(name) end }
end
zones[config.zones.start] = { GetCoordinate = function() return coordinate(config.zones.start) end }
zones[config.zones.target] = { GetCoordinate = function() return coordinate(config.zones.target) end }

_G.ZONE = { FindByName = function(_, name) return zones[name] end }
_G.ZONE_BASE = { GetCoordinate = function() end }
_G.COORDINATE = { WaypointGround = function() end }

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
  Route = function() end,
  CountAliveUnits = function() end,
  IsCompletelyInZone = function() end,
}
_G.SPAWN = {
  NewWithAlias = function()
    return { Spawn = function() return runtimeGroup end }
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
assert(state.startRoute() == true, "route start failed")
assert(#runtimeGroup.route == 8, "expected seven anchors plus target")
assert(runtimeGroup.route[1].speed == 30, "unexpected route speed")
assert(runtimeGroup.route[1].formation == "On Road", "unexpected formation")
assert(#messages >= 3, "expected MOOSE MESSAGE output")

local source = assert(io.open(repositoryRoot .. "/mission/tests/tm01-blue-convoy/src/tm01m.lua", "rb")):read("*a")
assert(not source:find("timer.scheduleFunction", 1, true), "native timer scheduling is forbidden")
assert(not source:find("trigger.action.outText", 1, true), "native text output is forbidden")
assert(not source:find("Group.getByName", 1, true), "native group lookup is forbidden")
assert(not source:find("ConvoyProxyController", 1, true), "old proxy controller is forbidden")
assert(not source:find("RepresentationInterestMonitor", 1, true), "old interest monitor is forbidden")

print("TM01M static PASS: MOOSE SPAWN/GROUP/SCHEDULER/MESSAGE route baseline")
