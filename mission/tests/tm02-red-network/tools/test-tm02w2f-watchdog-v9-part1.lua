local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local function loadPatchedWatchdog()
  local path = repositoryRoot
    .. "/mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v9.lua"
  local handle = assert(io.open(path, "rb"))
  local source = handle:read("*a")
  handle:close()
  local original = "local remaining = projection.totalMeters - projection.alongMeters"
  local replacement = "local remaining = distance2D(group:GetCoordinate(), context.target)"
  local count = 0
  source = source:gsub(original, function()
    count = count + 1
    return replacement
  end)
  assert(count == 1, "physical terminal-distance patch count mismatch: " .. tostring(count))
  local chunk, errorMessage = loadstring(source)
  assert(chunk, errorMessage)
  return chunk()
end

local now = 0
local scheduledCallback
local scheduledAt
local logLines = {}
local spawnedGroups = {}
local routeAssignments = 0
local exposureMode = "CLEAR"

_G.env = { info = function(line) logLines[#logLines + 1] = line end }
_G.timer = {
  getTime = function() return now end,
  scheduleFunction = function(callback, argument, at)
    scheduledCallback = callback
    scheduledAt = at
    return 1
  end,
}

local function newCoordinate(x, z, roadOffset)
  local item = { x = x, y = 0, z = z, roadOffset = roadOffset or 10 }
  function item:GetVec3() return { x = self.x, y = self.y, z = self.z } end
  function item:WaypointGround(speed, formation)
    return { x = self.x, y = self.z, speed = speed, formation = formation }
  end
  function item:GetClosestPointToRoad()
    return newCoordinate(self.x, self.z + self.roadOffset, self.roadOffset)
  end
  return item
end

_G.COORDINATE = {}
function COORDINATE:NewFromVec3(value)
  return newCoordinate(value.x, value.z)
end

local targetCoordinate = newCoordinate(2000, 0)
_G.ZONE = {}
function ZONE:FindByName(name)
  if name ~= "TARGET" then return nil end
  return { GetCoordinate = function() return targetCoordinate end }
end

_G.land = {
  SurfaceType = { LAND = 1, SHALLOW_WATER = 2, WATER = 3, ROAD = 4 },
  getSurfaceType = function() return 1 end,
}
_G.Object = { Category = { UNIT = 1 } }
_G.Unit = {
  Category = { AIRPLANE = 0, HELICOPTER = 1, GROUND_UNIT = 2 },
}
_G.world = {
  VolumeType = { SPHERE = 1 },
  searchObjects = function(category, volume, callback)
    if exposureMode == "PLAYER_AIR" then
      local objectGroup = { getName = function() return "PLAYER-GROUP" end }
      callback({
        getGroup = function() return objectGroup end,
        getPoint = function()
          local point = volume.params.point
          return { x = point.x + 500, y = point.y, z = point.z }
        end,
        getDesc = function() return { category = Unit.Category.AIRPLANE } end,
        getPlayerName = function() return "Static Pilot" end,
        getCoalition = function() return 2 end,
      })
    elseif exposureMode == "ENEMY_GROUND" then
      local objectGroup = { getName = function() return "ENEMY-GROUP" end }
      callback({
        getGroup = function() return objectGroup end,
        getPoint = function()
          local point = volume.params.point
          return { x = point.x + 200, y = point.y, z = point.z }
        end,
        getDesc = function() return { category = Unit.Category.GROUND_UNIT } end,
        getPlayerName = function() return nil end,
        getCoalition = function() return 2 end,
      })
    end
  end,
}

local function newGroup(name, coordinateValue, unitCount)
  local group = {
    name = name,
    coordinate = coordinateValue,
    alive = true,
    unitCount = unitCount or 1,
    destroyed = false,
    lastWaypoints = nil,
  }
  function group:IsAlive() return self.alive end
  function group:GetName() return self.name end
  function group:GetCoordinate() return self.coordinate end
  function group:GetCoalition() return 1 end
  function group:CountAliveUnits() return self.unitCount end
  function group:Destroy() self.alive = false self.destroyed = true end
  function group:Route(waypoints, delay)
    routeAssignments = routeAssignments + 1
    self.lastWaypoints = waypoints
    self.lastDelay = delay
    return self
  end
  return group
end

_G.SPAWN = {}
function SPAWN:NewWithAlias(templateName, alias)
  local spawner = {}
  function spawner:SpawnFromCoordinate(spawnCoordinate)
    local templateCount = tonumber(templateName:match("PACKET_(%d+)_")) or 1
    local count = alias:find("RED_TRANSIT_FULL", 1, true) and templateCount or 1
    local group = newGroup(alias, newCoordinate(spawnCoordinate.x, spawnCoordinate.z), count)
    spawnedGroups[#spawnedGroups + 1] = group
    return group
  end
  return spawner
end

local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local watchdogModule = loadPatchedWatchdog()
local executionState = {
  configurationValid = true,
  completed = false,
  failed = false,
  totalLosses = 0,
  tasks = {},
}
local navigation = {
  valid = true,
  routingReady = true,
  registryState = {
    siteById = {
      SOURCE = { siteId = "SOURCE", coordinate = { x = 0, y = 0, z = 0 } },
      TARGET = { siteId = "TARGET", coordinate = { x = 2000, y = 0, z = 0 } },
    },
  },
}

local function addTaskAt(id, x, z, unitCount, expanded, survivorCount, roadOffset)
  local group = newGroup(id .. "-GROUP", newCoordinate(x, z, roadOffset), unitCount)
  local task = {
    taskId = id,
    movementState = "EN_ROUTE",
    proxyGroup = group,
    proxyGroupName = group:GetName(),
    path = { "SOURCE", "TARGET" },
    currentLegIndex = 1,
    strength = survivorCount,
    survivorCount = survivorCount,
    transitExpanded = expanded == true,
    transitRepresentation = expanded and "FULL_GROUP" or "LEADER_PROXY",
  }
  executionState.tasks[#executionState.tasks + 1] = task
  return task
end

local function addTask(id, x, unitCount, expanded, survivorCount, roadOffset)
  return addTaskAt(id, x, 0, unitCount, expanded, survivorCount, roadOffset)
end

local watchdog = watchdogModule.install(config, executionState, navigation)
assert(watchdog.valid == true, table.concat(watchdog.errors or {}, "; "))
assert(watchdog.running == true, "watchdog must start after validation")
assert(type(scheduledCallback) == "function", "watchdog timer callback missing")
assert(scheduledAt == config.watchdog.initialDelaySeconds,
  "watchdog initial delay mismatch")

local function initialize(task)
  watchdog.tick()
  assert(task.w2fProgressWatchdog, "task monitor missing")
end

local function triggerConfirmedStall(task)
  local monitor = assert(task.w2fProgressWatchdog, "monitor unavailable")
  now = math.max(
    now + config.watchdog.stallWindowSeconds + 1,
    (monitor.graceUntil or 0) + config.watchdog.stallWindowSeconds + 1,
    (monitor.nextRecoveryAt or 0) + config.watchdog.stallWindowSeconds + 1,
    (monitor.waitUntil or 0) + 1
  )
  watchdog.tick()
end
