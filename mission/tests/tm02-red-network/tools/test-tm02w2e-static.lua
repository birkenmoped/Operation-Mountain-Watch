local repositoryRoot = arg[1] or "."

local function path(relative)
  return repositoryRoot .. "/" .. relative
end

local logLines = {}
local missionTime = 0
local scheduledFunction = nil
local scheduledTime = nil
local proxySpawnCount = 0
local physicalSpawnCount = 0

local zoneDefinitions = {
  OMW_RED_HQ_Main = { x = 0, y = 0, radius = 300 },
  OMW_RED_SITE_Central_01 = { x = -1000, y = 1000, radius = 300 },
  OMW_RED_SITE_Central_02 = { x = 1000, y = 1000, radius = 300 },
  OMW_RED_SITE_Central_03 = { x = -1000, y = 2200, radius = 300 },
  OMW_RED_SITE_Central_04 = { x = 1000, y = 2200, radius = 300 },
  OMW_RED_SUBHQ_Left = { x = -2200, y = 3300, radius = 300 },
  OMW_RED_SUBHQ_Right = { x = 2200, y = 3300, radius = 300 },
  OMW_RED_SITE_Left_01 = { x = -2900, y = 4400, radius = 300 },
  OMW_RED_SITE_Left_02 = { x = -1500, y = 4400, radius = 300 },
  OMW_RED_SITE_Right_01 = { x = 1500, y = 4400, radius = 300 },
  OMW_RED_SITE_Right_02 = { x = 2900, y = 4400, radius = 300 },
}

local function newCoordinate(zoneName)
  local definition = assert(zoneDefinitions[zoneName], "unknown coordinate zone " .. tostring(zoneName))
  local coordinate = { zoneName = zoneName }
  function coordinate:GetVec3()
    return { x = definition.x, y = 0, z = definition.y }
  end
  function coordinate:WaypointGround(speedKph, formation)
    return {
      zoneName = zoneName,
      speedKph = speedKph,
      formation = formation,
    }
  end
  return coordinate
end

local zones = {}
for name, definition in pairs(zoneDefinitions) do
  local zone = {
    name = name,
    x = definition.x,
    y = definition.y,
    radius = definition.radius,
  }
  function zone:GetVec2()
    return { x = self.x, y = self.y }
  end
  function zone:IsVec2InZone(vec2)
    local dx = vec2.x - self.x
    local dy = vec2.y - self.y
    return dx * dx + dy * dy <= self.radius * self.radius
  end
  function zone:GetCoordinate()
    return newCoordinate(self.name)
  end
  zones[name] = zone
end

local function nearestZoneName(x, y)
  local bestName = nil
  local bestDistance = math.huge
  for name, definition in pairs(zoneDefinitions) do
    local dx = x - definition.x
    local dy = y - definition.y
    local distance = dx * dx + dy * dy
    if distance < bestDistance then
      bestDistance = distance
      bestName = name
    end
  end
  return bestName
end

ZONE = {}
function ZONE:FindByName(name)
  return zones[name]
end

GROUP = {}
function GROUP:FindByName(name)
  if type(name) == "string" and name:match("^TPL_TEST_RED_PACKET_%d%d_01$") then
    return { name = name }
  end
  return nil
end

local function templateStrength(templateName)
  local value = templateName and templateName:match("TPL_TEST_RED_PACKET_(%d%d)_01")
  return value and tonumber(value) or 1
end

local function makeTemplate(templateName)
  local units = {}
  for index = 1, templateStrength(templateName) do
    units[index] = { name = templateName .. "-" .. index }
  end
  return {
    units = units,
    CategoryID = 2,
    CountryID = 80,
    CoalitionID = 1,
  }
end

local function makeGroup(alias, unitCount, zoneName)
  local group = {
    alias = alias,
    unitCount = unitCount,
    currentZoneName = zoneName,
    routeDestinationZoneName = nil,
    alive = true,
  }
  function group:GetName()
    return self.alias
  end
  function group:CountAliveUnits()
    return self.alive and self.unitCount or 0
  end
  function group:IsAlive()
    return self.alive
  end
  function group:Destroy()
    self.alive = false
  end
  function group:GetCoordinate()
    return newCoordinate(self.currentZoneName)
  end
  function group:Route(waypoints)
    local destination = waypoints and waypoints[#waypoints]
    assert(destination and destination.zoneName, "route destination missing")
    self.routeDestinationZoneName = destination.zoneName
    return true
  end
  function group:IsCompletelyInZone(zone)
    if self.routeDestinationZoneName == zone.name then
      self.currentZoneName = zone.name
      self.routeDestinationZoneName = nil
      return true
    end
    return self.currentZoneName == zone.name
  end
  return group
end

local function makeSpawner(template, alias)
  local spawner = {
    SpawnTemplate = template,
    alias = alias,
    absolutePositions = nil,
  }
  function spawner:InitCategory()
    return self
  end
  function spawner:InitCountry()
    return self
  end
  function spawner:InitCoalition()
    return self
  end
  function spawner:InitSetUnitAbsolutePositions(positions)
    self.absolutePositions = positions
    return self
  end
  function spawner:Spawn()
    local position = assert(self.absolutePositions and self.absolutePositions[1], "absolute spawn position missing")
    local zoneName = nearestZoneName(position.x, position.y)
    proxySpawnCount = proxySpawnCount + 1
    return makeGroup(self.alias, #self.SpawnTemplate.units, zoneName)
  end
  function spawner:SpawnInZone(zone)
    proxySpawnCount = proxySpawnCount + 1
    return makeGroup(self.alias, #self.SpawnTemplate.units, zone.name)
  end
  function spawner:SpawnFromCoordinate(coordinate)
    physicalSpawnCount = physicalSpawnCount + 1
    return makeGroup(self.alias, #self.SpawnTemplate.units, coordinate.zoneName)
  end
  return spawner
end

SPAWN = {}
function SPAWN:New(templateName)
  return makeSpawner(makeTemplate(templateName), templateName .. "_SOURCE")
end
function SPAWN:NewWithAlias(templateName, alias)
  return makeSpawner(makeTemplate(templateName), alias)
end
function SPAWN:NewFromTemplate(template, _, alias)
  return makeSpawner(template, alias)
end

env = {
  info = function(line)
    logLines[#logLines + 1] = line
    print(line)
  end,
}

trigger = {
  action = {
    outText = function() end,
    markToAll = function() end,
    removeMark = function() end,
  },
}

timer = {
  getTime = function()
    return missionTime
  end,
  scheduleFunction = function(callback, _, firstTime)
    scheduledFunction = callback
    scheduledTime = firstTime
    return 1
  end,
}

MENU_MISSION = {}
function MENU_MISSION:New()
  return {}
end
MENU_MISSION_COMMAND = {}
function MENU_MISSION_COMMAND:New()
  return {}
end

local config = assert(dofile(path("mission/tests/tm02-red-network/config-tm02w2e.lua")))
config.debug.showMessages = false
config.debug.enableF10Menu = false
config.debug.markersEnabledOnStart = false
config.execution.autoStart = false

local adapter = assert(dofile(path("mission/tests/tm02-red-network/src/tm02w2e-leader-proxy-adapter.lua")))
local executor = assert(dofile(path("mission/tests/tm02-red-network/src/tm02w2e.lua")))

local registry = {
  configurationValid = true,
  siteById = {},
}
for name in pairs(zoneDefinitions) do
  registry.siteById[name] = {
    siteId = name,
    coordinate = { x = zoneDefinitions[name].x, z = zoneDefinitions[name].y },
    status = "OCCUPIED",
  }
end

local inventories = {
  OMW_RED_HQ_Main = { currentPersonnel = 30, guardFloor = 12, defensiveTarget = 24, hardCapacity = 40, reservedInbound = 0, reservedOutbound = 0 },
  OMW_RED_SUBHQ_Left = { currentPersonnel = 10, guardFloor = 8, defensiveTarget = 10, hardCapacity = 18, reservedInbound = 0, reservedOutbound = 2 },
  OMW_RED_SUBHQ_Right = { currentPersonnel = 10, guardFloor = 8, defensiveTarget = 10, hardCapacity = 18, reservedInbound = 0, reservedOutbound = 2 },
  OMW_RED_SITE_Central_01 = { currentPersonnel = 10, guardFloor = 4, defensiveTarget = 8, hardCapacity = 16, reservedInbound = 0, reservedOutbound = 6 },
  OMW_RED_SITE_Central_02 = { currentPersonnel = 10, guardFloor = 4, defensiveTarget = 8, hardCapacity = 16, reservedInbound = 0, reservedOutbound = 0 },
  OMW_RED_SITE_Central_03 = { currentPersonnel = 12, guardFloor = 4, defensiveTarget = 10, hardCapacity = 16, reservedInbound = 0, reservedOutbound = 4 },
  OMW_RED_SITE_Central_04 = { currentPersonnel = 12, guardFloor = 4, defensiveTarget = 10, hardCapacity = 16, reservedInbound = 0, reservedOutbound = 2 },
  OMW_RED_SITE_Left_01 = { currentPersonnel = 2, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, reservedInbound = 6, reservedOutbound = 0 },
  OMW_RED_SITE_Left_02 = { currentPersonnel = 4, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, reservedInbound = 4, reservedOutbound = 0 },
  OMW_RED_SITE_Right_01 = { currentPersonnel = 2, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, reservedInbound = 6, reservedOutbound = 0 },
  OMW_RED_SITE_Right_02 = { currentPersonnel = 6, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, reservedInbound = 2, reservedOutbound = 2 },
}

local tasks = {
  { taskId = "W2-TASK-01", sourceSiteId = "OMW_RED_SITE_Central_01", targetSiteId = "OMW_RED_SITE_Left_01", strength = 4, path = { "OMW_RED_SITE_Central_01", "OMW_RED_SITE_Central_03", "OMW_RED_SUBHQ_Left", "OMW_RED_SITE_Left_01" }, linkIds = { "A", "B", "C" } },
  { taskId = "W2-TASK-02", sourceSiteId = "OMW_RED_SITE_Central_01", targetSiteId = "OMW_RED_SITE_Left_01", strength = 2, path = { "OMW_RED_SITE_Central_01", "OMW_RED_SITE_Central_03", "OMW_RED_SUBHQ_Left", "OMW_RED_SITE_Left_01" }, linkIds = { "A", "B", "C" } },
  { taskId = "W2-TASK-03", sourceSiteId = "OMW_RED_SUBHQ_Left", targetSiteId = "OMW_RED_SITE_Left_02", strength = 2, path = { "OMW_RED_SUBHQ_Left", "OMW_RED_SITE_Left_02" }, linkIds = { "D" } },
  { taskId = "W2-TASK-04", sourceSiteId = "OMW_RED_SITE_Right_02", targetSiteId = "OMW_RED_SITE_Left_02", strength = 2, path = { "OMW_RED_SITE_Right_02", "OMW_RED_SITE_Right_01", "OMW_RED_SITE_Left_02" }, linkIds = { "E", "F" } },
  { taskId = "W2-TASK-05", sourceSiteId = "OMW_RED_SITE_Central_03", targetSiteId = "OMW_RED_SITE_Right_01", strength = 4, path = { "OMW_RED_SITE_Central_03", "OMW_RED_SUBHQ_Right", "OMW_RED_SITE_Right_01" }, linkIds = { "G", "H" } },
  { taskId = "W2-TASK-06", sourceSiteId = "OMW_RED_SUBHQ_Right", targetSiteId = "OMW_RED_SITE_Right_01", strength = 2, path = { "OMW_RED_SUBHQ_Right", "OMW_RED_SITE_Right_01" }, linkIds = { "H" } },
  { taskId = "W2-TASK-07", sourceSiteId = "OMW_RED_SITE_Central_04", targetSiteId = "OMW_RED_SITE_Right_02", strength = 2, path = { "OMW_RED_SITE_Central_04", "OMW_RED_SUBHQ_Right", "OMW_RED_SITE_Right_02" }, linkIds = { "I", "J" } },
}

local planner = {
  configurationValid = true,
  inventoryBySiteId = inventories,
  tasks = tasks,
  unresolvedDeficit = 0,
  totalReservedInbound = 18,
  totalReservedOutbound = 18,
}

local build = {
  buildTimestamp = "STATIC-HARNESS",
  stageId = "TM02W2E",
}

assert(adapter.install(config) == true, "leader adapter must install")
local state = executor.start(config, registry, planner, build)
assert(state.configurationValid == true, table.concat(state.errors or {}, "; "))
assert(#state.tasks == 7, "expected seven execution tasks")
assert(state.totalInitialPersonnel == 108, "expected 108 logical personnel")
assert(state.startExecution() == true, "execution must start")
assert(state.activeTaskCount == 4, "expected four tasks in the initial active wave")

local iterations = 0
while scheduledFunction and iterations < 100 do
  iterations = iterations + 1
  missionTime = scheduledTime
  local nextTime = scheduledFunction(nil, scheduledTime)
  if nextTime == nil then
    scheduledFunction = nil
    scheduledTime = nil
  else
    scheduledTime = nextTime
  end
end

assert(iterations < 100, "execution monitor did not terminate")
assert(state.completed == true, table.concat(state.errors or {}, "; "))
assert(state.failed == false, "execution must not fail")
assert(state.activeTaskCount == 0, "no task may remain active")
assert(state.arrivedTaskCount == 7, "all seven tasks must arrive")
assert(state.destroyedTaskCount == 0, "no task may be destroyed")
assert(state.failedTaskCount == 0, "no task may fail")
assert(state.totalLosses == 0, "technical acceptance requires zero losses")
assert(proxySpawnCount == 7, "expected one leader proxy per task")
assert(physicalSpawnCount == 7, "expected one physical destination group per task")

local expected = {
  OMW_RED_HQ_Main = 30,
  OMW_RED_SUBHQ_Left = 8,
  OMW_RED_SUBHQ_Right = 8,
  OMW_RED_SITE_Central_01 = 4,
  OMW_RED_SITE_Central_02 = 10,
  OMW_RED_SITE_Central_03 = 8,
  OMW_RED_SITE_Central_04 = 10,
  OMW_RED_SITE_Left_01 = 8,
  OMW_RED_SITE_Left_02 = 8,
  OMW_RED_SITE_Right_01 = 8,
  OMW_RED_SITE_Right_02 = 6,
}

local total = 0
for siteId, expectedPersonnel in pairs(expected) do
  local inventory = assert(planner.inventoryBySiteId[siteId], "inventory missing for " .. siteId)
  assert(inventory.currentPersonnel == expectedPersonnel, siteId .. " final personnel mismatch")
  assert(inventory.reservedInbound == 0, siteId .. " inbound reservation remains")
  assert(inventory.reservedOutbound == 0, siteId .. " outbound reservation remains")
  total = total + inventory.currentPersonnel
end
assert(total == 108, "final personnel total must remain 108")

for _, line in ipairs(logLines) do
  assert(not line:find("%[OMW%]%[TM02W2E%] level=ERROR"), line)
end

print(string.format(
  "TM02W2E STATIC PASS tasks=%d proxies=%d physical=%d iterations=%d personnel=%d",
  #state.tasks,
  proxySpawnCount,
  physicalSpawnCount,
  iterations,
  total
))
