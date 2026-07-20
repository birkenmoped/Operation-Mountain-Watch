local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local now = 0
local scheduledCallback
local scheduledAt
local logLines = {}
local directResetCount = 0
local representationResetCount = 0
local routeAssignmentCount = 0

_G.env = {
  info = function(line)
    logLines[#logLines + 1] = line
  end,
}

_G.timer = {
  getTime = function() return now end,
  scheduleFunction = function(callback, argument, at)
    scheduledCallback = callback
    scheduledAt = at
    return 1
  end,
}

local function newCoordinate(x, z)
  local coordinate = {
    x = x,
    y = 0,
    z = z,
  }
  function coordinate:GetVec3()
    return { x = self.x, y = self.y, z = self.z }
  end
  function coordinate:WaypointGround(speed, formation)
    return {
      x = self.x,
      y = self.z,
      speed = speed,
      formation = formation,
    }
  end
  function coordinate:GetClosestPointToRoad()
    return newCoordinate(self.x, self.z)
  end
  return coordinate
end

_G.COORDINATE = {}
function COORDINATE:NewFromVec3(value)
  return newCoordinate(value.x, value.z)
end

local destination = newCoordinate(1000, 0)
_G.ZONE = {}
function ZONE:FindByName(name)
  if name ~= "TARGET" then return nil end
  return {
    GetCoordinate = function() return destination end,
  }
end

_G.land = {
  SurfaceType = {
    LAND = 1,
    SHALLOW_WATER = 2,
    WATER = 3,
    ROAD = 4,
  },
  getSurfaceType = function() return 1 end,
}

_G.Object = {
  Category = {
    SCENERY = 5,
  },
}

_G.world = {
  VolumeType = {
    SPHERE = 1,
  },
  searchObjects = function(category, volume, callback)
    for index = 1, 8 do
      if callback({ index = index }) == false then break end
    end
  end,
}

local group = {
  name = "STATIC-GROUP-1",
  coordinate = newCoordinate(0, 0),
}
function group:IsAlive() return true end
function group:GetName() return self.name end
function group:GetCoordinate() return self.coordinate end
function group:Route(waypoints, delay)
  routeAssignmentCount = routeAssignmentCount + 1
  self.lastWaypoints = waypoints
  self.lastDelay = delay
  return self
end

local task = {
  taskId = "STATIC-WATCHDOG",
  movementState = "EN_ROUTE",
  proxyGroup = group,
  proxyGroupName = group.name,
  path = { "SOURCE", "TARGET" },
  currentLegIndex = 1,
  survivorCount = 4,
  transitExpanded = false,
}

local executionState = {
  configurationValid = true,
  completed = false,
  failed = false,
  tasks = { task },
}

local navigation = {
  valid = true,
  routingReady = true,
}

local transitionActive = false
local transitRepresentation = {
  valid = true,
  isTransitionActive = function() return transitionActive end,
  reassignDirectRouteForRecovery = function(recoveryTask, reason)
    directResetCount = directResetCount + 1
    return true
  end,
  convertTaskForRecovery = function(recoveryTask, reason)
    representationResetCount = representationResetCount + 1
    recoveryTask.transitExpanded = not recoveryTask.transitExpanded
    group.name = "STATIC-GROUP-" .. tostring(representationResetCount + 1)
    recoveryTask.proxyGroupName = group.name
    return true
  end,
}

local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local watchdogModule = loadLua("mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog.lua")
local watchdog = watchdogModule.install(config, executionState, navigation, transitRepresentation)

assert(watchdog.valid == true, table.concat(watchdog.errors or {}, "; "))
assert(watchdog.running == true, "watchdog must start after successful validation")
assert(type(scheduledCallback) == "function", "watchdog timer callback was not scheduled")
assert(scheduledAt == config.watchdog.initialDelaySeconds,
  "watchdog initial delay does not match configuration")

watchdog.tick()
assert(directResetCount == 0, "first observation must not recover immediately")

now = config.watchdog.postRecoveryGraceSeconds + 1
watchdog.tick()
assert(directResetCount == 0, "grace expiry must only establish a movement sample")

now = now + config.watchdog.stallWindowSeconds + 1
watchdog.tick()
assert(directResetCount == 1, "first stall must reassign the route to the same group")
assert(representationResetCount == 0, "first stall must not replace the representation")
assert(task.navigationState == "RECOVERING_SAME_GROUP_DIRECT_RESET",
  "first recovery state was not recorded")

now = now + config.watchdog.postRecoveryGraceSeconds + config.watchdog.stallWindowSeconds + 1
watchdog.tick()
assert(representationResetCount == 1,
  "second stall must perform one serialized representation reset")
assert(task.navigationState == "RECOVERING_REPRESENTATION_RESET",
  "representation recovery state was not recorded")

now = now + 1
watchdog.tick()
now = now + config.watchdog.postRecoveryGraceSeconds + config.watchdog.stallWindowSeconds + 1
watchdog.tick()
assert(routeAssignmentCount == 1,
  "third urban stall must assign one bounded road-escape route")
assert(#group.lastWaypoints == 4, "urban road escape must use exactly four waypoints")
assert(group.lastWaypoints[1].formation == config.routing.offRoadFormation,
  "road escape must begin off road")
assert(group.lastWaypoints[2].formation == config.routing.roadFormation,
  "road escape entry must use on-road formation")
assert(group.lastWaypoints[3].formation == config.routing.roadFormation,
  "road escape exit must use on-road formation")
assert(group.lastWaypoints[4].formation == config.routing.offRoadFormation,
  "road escape must return to off-road movement")
assert(task.navigationState == "RECOVERING_URBAN_ROAD_ESCAPE",
  "urban road escape state was not recorded")

now = 500
local nextAt = scheduledCallback(nil, 0)
assert(nextAt == now + config.watchdog.sampleIntervalSeconds,
  "watchdog timer must schedule from current mission time and must not catch up")

local source = assert(io.open(
  repositoryRoot .. "/mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog.lua",
  "rb"
)):read("*a")
assert(not source:find("scheduledTime%s*%+", 1),
  "watchdog must not schedule from stale scheduledTime")
assert(source:find("maxRecoveryAttemptsPerEpisode", 1, true),
  "bounded recovery attempts are missing")
assert(source:find("NAVIGATION_BLOCKED", 1, true),
  "terminal navigation block state is missing")

print("TM02W2F watchdog contract PASS: direct-reset=1 representation-reset=1 urban-road-escape=4wp")
