local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local function loadWatchdog()
  local paths = {
    "mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v8-part1.lua",
    "mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v8-part2.lua",
    "mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v8-part3.lua",
  }
  local parts = {}
  for _, path in ipairs(paths) do
    local handle = assert(io.open(repositoryRoot .. "/" .. path, "rb"))
    parts[#parts + 1] = handle:read("*a")
    handle:close()
  end
  local chunk, errorMessage = loadstring(table.concat(parts, "\n"))
  assert(chunk, errorMessage)
  return chunk()
end

local now = 0
local scheduledCallback
local scheduledAt
local logLines = {}
local spawnedGroups = {}
local roadRouteAssignments = 0

_G.env = {
  info = function(line) logLines[#logLines + 1] = line end,
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
  local coordinate = { x = x, y = 0, z = z }
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
    return newCoordinate(self.x, self.z + 10)
  end
  return coordinate
end

_G.COORDINATE = {}
function COORDINATE:NewFromVec3(value)
  return newCoordinate(value.x, value.z)
end

local targetCoordinate = newCoordinate(1000, 0)
_G.ZONE = {}
function ZONE:FindByName(name)
  if name ~= "TARGET" then return nil end
  return {
    GetCoordinate = function() return targetCoordinate end,
  }
end

local function newGroup(name, coordinate, unitCount)
  local group = {
    name = name,
    coordinate = coordinate,
    alive = true,
    unitCount = unitCount or 1,
    destroyed = false,
    lastWaypoints = nil,
  }
  function group:IsAlive() return self.alive end
  function group:GetName() return self.name end
  function group:GetCoordinate() return self.coordinate end
  function group:CountAliveUnits() return self.unitCount end
  function group:Destroy()
    self.alive = false
    self.destroyed = true
  end
  function group:Route(waypoints, delay)
    self.lastWaypoints = waypoints
    self.lastDelay = delay
    if #waypoints == 4
      and waypoints[2].formation == "On Road"
      and waypoints[3].formation == "On Road" then
      roadRouteAssignments = roadRouteAssignments + 1
    end
    return self
  end
  return group
end

_G.SPAWN = {}
function SPAWN:NewWithAlias(templateName, alias)
  local spawner = {}
  function spawner:SpawnFromCoordinate(coordinate)
    local group = newGroup(alias, newCoordinate(coordinate.x, coordinate.z), 1)
    spawnedGroups[#spawnedGroups + 1] = group
    return group
  end
  return spawner
end

local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local watchdogModule = loadWatchdog()

local firstGroup = newGroup("STATIC-GROUP-INITIAL", newCoordinate(0, 0), 1)
local task = {
  taskId = "STATIC-WATCHDOG",
  movementState = "EN_ROUTE",
  proxyGroup = firstGroup,
  proxyGroupName = firstGroup:GetName(),
  path = { "SOURCE", "TARGET" },
  currentLegIndex = 1,
  strength = 4,
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
  registryState = {
    siteById = {
      SOURCE = { siteId = "SOURCE", coordinate = { x = 0, y = 0, z = 0 } },
      TARGET = { siteId = "TARGET", coordinate = { x = 1000, y = 0, z = 0 } },
    },
  },
}

local watchdog = watchdogModule.install(config, executionState, navigation)
assert(watchdog.valid == true, table.concat(watchdog.errors or {}, "; "))
assert(watchdog.running == true, "watchdog must start after validation")
assert(type(scheduledCallback) == "function", "watchdog timer callback missing")
assert(scheduledAt == config.watchdog.initialDelaySeconds,
  "watchdog initial delay mismatch")

watchdog.tick()
assert(task.w2fProgressWatchdog ~= nil, "first observation did not create monitor")

local function triggerConfirmedStall(stalledTask)
  local monitor = assert(stalledTask.w2fProgressWatchdog, "monitor unavailable")
  now = math.max(now + 1, monitor.graceUntil - 1)
  watchdog.tick()
  now = now + config.watchdog.stallWindowSeconds + 1
  watchdog.tick()
end

for expectedAttempt = 1, 4 do
  local oldGroup = task.proxyGroup
  triggerConfirmedStall(task)
  assert(task.proxyGroup ~= oldGroup,
    "off-road recovery " .. expectedAttempt .. " must replace the representation")
  assert(oldGroup.destroyed == true,
    "old representation was not removed after recovery " .. expectedAttempt)
  assert(task.proxyGroup:CountAliveUnits() == 1,
    "packed recovery must remain a one-man proxy")
  assert(task.transitExpanded == false,
    "watchdog must not unpack a travelling proxy")
  assert(task.w2fProgressWatchdog.offroadRelocations == expectedAttempt,
    "off-road relocation count mismatch")
  local expectedX = expectedAttempt * config.watchdog.relocationAdvanceMeters
  assert(math.abs(task.proxyGroup:GetCoordinate().x - expectedX) < 0.01,
    "recovery did not advance exactly 75 m along the safe leg")
end

local groupBeforeRoadRecovery = task.proxyGroup
local spawnCountBeforeRoadRecovery = #spawnedGroups
triggerConfirmedStall(task)
assert(task.proxyGroup == groupBeforeRoadRecovery,
  "road recovery must keep the same physical representation")
assert(#spawnedGroups == spawnCountBeforeRoadRecovery,
  "road recovery must not spawn a replacement")
assert(roadRouteAssignments == 1,
  "fifth confirmed stall must assign one road route")
assert(task.proxyGroup.lastWaypoints and #task.proxyGroup.lastWaypoints == 4,
  "road recovery must use four bounded waypoints")
assert(task.proxyGroup.lastWaypoints[1].formation == config.routing.offRoadFormation,
  "road recovery must start off road")
assert(task.proxyGroup.lastWaypoints[2].formation == config.routing.roadFormation,
  "road entry must use on-road formation")
assert(task.proxyGroup.lastWaypoints[3].formation == config.routing.roadFormation,
  "road exit must use on-road formation")
assert(task.proxyGroup.lastWaypoints[4].formation == config.routing.offRoadFormation,
  "road recovery must return to off-road formation at the target")
assert(task.navigationState == "RECOVERING_ROAD_TO_LEG_TARGET",
  "road recovery state missing")

triggerConfirmedStall(task)
assert(task.navigationState == "NAVIGATION_BLOCKED",
  "a stalled road recovery must terminate as NAVIGATION_BLOCKED")
assert(task.w2fProgressWatchdog.offroadRelocations == 4,
  "blocked task must not receive a fifth 75 m relocation")

local terminalGroup = newGroup("STATIC-TERMINAL-INITIAL", newCoordinate(930, 0), 1)
local terminalTask = {
  taskId = "STATIC-TERMINAL",
  movementState = "EN_ROUTE",
  proxyGroup = terminalGroup,
  proxyGroupName = terminalGroup:GetName(),
  path = { "SOURCE", "TARGET" },
  currentLegIndex = 1,
  strength = 2,
  survivorCount = 2,
  transitExpanded = false,
}
executionState.tasks[#executionState.tasks + 1] = terminalTask
watchdog.tick()
triggerConfirmedStall(terminalTask)
assert(terminalTask.proxyGroup ~= terminalGroup,
  "terminal recovery must replace the stalled proxy")
assert(math.abs(terminalTask.proxyGroup:GetCoordinate().x - 975) < 0.01,
  "terminal recovery must place the proxy 25 m before the target")
assert(terminalTask.w2fProgressWatchdog.terminalRecoveryUsed == true,
  "terminal recovery flag missing")
assert(terminalTask.w2fProgressWatchdog.offroadRelocations == 0,
  "terminal recovery inside 100 m must not consume a normal 75 m attempt")
assert(terminalTask.navigationState == "RECOVERING_TERMINAL_DIRECT_OFFROAD",
  "terminal recovery state missing")

now = 1000
local nextAt = scheduledCallback(nil, 0)
assert(nextAt == now + config.watchdog.sampleIntervalSeconds,
  "watchdog timer must schedule from current mission time")

local source = {}
for _, path in ipairs({
  "mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v8-part1.lua",
  "mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v8-part2.lua",
  "mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v8-part3.lua",
}) do
  local handle = assert(io.open(repositoryRoot .. "/" .. path, "rb"))
  source[#source + 1] = handle:read("*a")
  handle:close()
end
source = table.concat(source, "\n")
assert(not source:find("scheduledTime%s*%+", 1),
  "stale scheduledTime catch-up scheduling is forbidden")
assert(not source:find("convertTaskForRecovery", 1, true),
  "watchdog must never call pack/unpack conversion APIs")
assert(not source:find("transitRepresentation", 1, true),
  "watchdog must be independent of transit representation")
assert(not source:find("REPRESENTATION_RESET", 1, true),
  "representation reset must not be a recovery strategy")
assert(source:find("maxOffroadRelocationsPerEpisode", 1, true),
  "four-attempt off-road recovery limit missing")
assert(source:find("ROAD_RECOVERY_TO_LEG_TARGET", 1, true),
  "road fallback after four relocations missing")
assert(source:find("terminalRecoveryThresholdMeters", 1, true),
  "100 m terminal gate missing")

print("TM02W2F watchdog PASS: 4x75m, then road, terminal-only-under-100m, no-pack-unpack")
