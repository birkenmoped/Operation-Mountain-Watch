local repositoryRoot = arg[1] or "."

local Coordinate = {}
Coordinate.__index = Coordinate
function Coordinate:new(x, z)
  return setmetatable({ x = x, y = 0, z = z }, self)
end
function Coordinate:GetVec3()
  return { x = self.x, y = self.y, z = self.z }
end

COORDINATE = {
  NewFromVec3 = function(_, value)
    return Coordinate:new(value.x, value.z)
  end,
}

local watchdog = assert(dofile(
  repositoryRoot .. "/mission/tests/tm02-red-network/src/tm02w2e-progress-watchdog-v5.lua"
))

local route = {
  Coordinate:new(0, 0),
  Coordinate:new(100, 0),
  Coordinate:new(200, 0),
}

local projection = watchdog.projectOnRoute(route, Coordinate:new(80, 10))
assert(projection ~= nil, "projection missing")
assert(math.abs(projection.alongMeters - 80) < 0.01,
  "projection must measure along-route progress")
assert(math.abs(projection.crossTrackMeters - 10) < 0.01,
  "projection must measure cross-track distance")
assert(math.abs(projection.totalMeters - 200) < 0.01,
  "route total must be preserved")

local remaining, total = watchdog.sliceRouteFromDistance(route, 75)
assert(remaining ~= nil and #remaining == 3, "route slice missing")
assert(math.abs(remaining[1]:GetVec3().x - 75) < 0.01,
  "route slice must start at requested progress")
assert(math.abs(total - 200) < 0.01, "route slice total mismatch")

local terminal, terminalTotal = watchdog.sliceRouteFromDistance(route, 175)
assert(terminal ~= nil and #terminal == 2, "terminal route slice missing")
assert(math.abs(terminal[1]:GetVec3().x - 175) < 0.01,
  "terminal slice must preserve remaining route")
assert(math.abs(terminalTotal - 200) < 0.01, "terminal route total mismatch")

print(string.format(
  "TM02W2E WATCHDOG STATIC PASS along=%.1f cross=%.1f total=%.1f",
  projection.alongMeters,
  projection.crossTrackMeters,
  projection.totalMeters
))
