local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

_G.env = { info = function() end }

_G.COORDINATE = {}
function COORDINATE:NewFromVec3(vec3)
  local coordinate = { x = vec3.x, y = vec3.y or 0, z = vec3.z }
  function coordinate:Get2DDistance(other)
    local target = other.coordinate or other
    local dx, dz = target.x - self.x, target.z - self.z
    return math.sqrt(dx * dx + dz * dz)
  end
  return coordinate
end

_G.ASTAR = { INF = math.huge, forceNoPath = false }
function ASTAR:New()
  return setmetatable({ nodes = {}, counter = 1 }, { __index = ASTAR })
end
function ASTAR:AddNodeFromCoordinate(coordinate)
  local node = { id = self.counter, coordinate = coordinate }
  self.counter = self.counter + 1
  self.nodes[#self.nodes + 1] = node
  return node
end
function ASTAR:SetStartCoordinate(coordinate)
  self.startCoordinate = coordinate
  return self
end
function ASTAR:SetEndCoordinate(coordinate)
  self.endCoordinate = coordinate
  return self
end
function ASTAR:SetValidNeighbourFunction(fn)
  self.validNeighbourFunction = fn
  return self
end
function ASTAR:SetCostFunction(fn)
  self.costFunction = fn
  return self
end
local function sameCoordinate(first, second)
  return first and second and first.x == second.x and first.z == second.z
end
function ASTAR:GetPath()
  assert(self.startCoordinate, "start coordinate missing")
  assert(self.endCoordinate, "end coordinate missing")
  if ASTAR.forceNoPath then return nil end
  local startNode, endNode
  for _, node in ipairs(self.nodes) do
    if sameCoordinate(node.coordinate, self.startCoordinate) then startNode = node end
    if sameCoordinate(node.coordinate, self.endCoordinate) then endNode = node end
  end
  assert(startNode and endNode, "ASTAR endpoints were not mapped")
  local heuristic = self.costFunction(startNode, endNode)
  assert(type(heuristic) == "number" and heuristic < math.huge,
    "ASTAR heuristic must be finite")

  local queue, queueIndex = { startNode }, 1
  local visited, previous = { [startNode] = true }, {}
  while queueIndex <= #queue do
    local current = queue[queueIndex]
    queueIndex = queueIndex + 1
    if current == endNode then break end
    for _, candidate in ipairs(self.nodes) do
      if candidate ~= current
        and not visited[candidate]
        and self.validNeighbourFunction(current, candidate) == true then
        visited[candidate] = true
        previous[candidate] = current
        queue[#queue + 1] = candidate
      end
    end
  end
  if not visited[endNode] then return nil end
  local path, current = {}, endNode
  while current do
    table.insert(path, 1, current)
    current = previous[current]
  end
  return path
end

local baseConfig = loadLua("mission/tests/tm02-red-network/config-tm02w2.lua")
local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local plannerModule = loadLua(
  "mission/tests/tm02-red-network/src/tm02w2f-initial-fill-planner.lua"
)
local navigationModule = loadLua(
  "mission/tests/tm02-red-network/src/tm02w2f-direct-offroad-navigation.lua"
)

local supplySiteId = config.initialFill.supplySiteId
local targetSiteIds = {}
for siteId in pairs(config.initialFill.targetPersonnelBySiteId) do
  if siteId ~= supplySiteId then targetSiteIds[#targetSiteIds + 1] = siteId end
end
table.sort(targetSiteIds)

local registry = {
  configurationValid = true,
  siteById = {},
  objectiveById = {},
  movementLinks = {},
}
registry.siteById[supplySiteId] = {
  siteId = supplySiteId,
  coordinate = { x = 0, y = 0, z = 0 },
}
local previousSiteId = supplySiteId
for index, siteId in ipairs(targetSiteIds) do
  registry.siteById[siteId] = {
    siteId = siteId,
    coordinate = { x = index * 1000, y = 0, z = (index % 2) * 250 },
  }
  registry.movementLinks[#registry.movementLinks + 1] = {
    linkId = string.format("STATIC-LINK-%02d", index),
    sourceSiteId = previousSiteId,
    targetSiteId = siteId,
    direction = "BIDIRECTIONAL",
  }
  previousSiteId = siteId
end

local planner = plannerModule.start(config, baseConfig, registry, {
  buildTimestamp = "STATIC",
})
assert(planner.configurationValid == true, table.concat(planner.errors or {}, "; "))
assert(#planner.tasks == 20, "expected 20 initial-fill tasks")
assert(planner.totalReservedInbound == 88, "expected 88 inbound personnel")
assert(planner.totalReservedOutbound == 88, "expected 88 outbound personnel")
assert(planner.inventoryBySiteId[supplySiteId].currentPersonnel
    - planner.inventoryBySiteId[supplySiteId].reservedOutbound == 24,
  "HQ must retain 24 personnel")

local navigation = navigationModule.install(config, registry, planner)
assert(navigation:preparePlannerTasks() == true,
  table.concat(navigation.errors or {}, "; "))
assert(navigation.safeTaskCount == 20, "all tasks need safe logical paths")
assert(navigation.moosePathCount == 20, "normal run must use MOOSE ASTAR")
assert(navigation.fallbackPathCount == 0, "fallback should remain unused")
assert(navigation.registryState == registry,
  "watchdog requires registry context through navigation")
for _, task in ipairs(planner.tasks) do
  assert(task.path[1] == task.sourceSiteId, "path source mismatch")
  assert(task.path[#task.path] == task.targetSiteId, "path target mismatch")
  assert(#task.linkIds == #task.path - 1, "path/link count mismatch")
end

ASTAR.forceNoPath = true
local fallbackPlanner = {
  configurationValid = true,
  tasks = {
    {
      taskId = "STATIC-FALLBACK",
      sourceSiteId = supplySiteId,
      targetSiteId = targetSiteIds[#targetSiteIds],
      strength = 1,
    },
  },
}
local fallbackNavigation = navigationModule.install(config, registry, fallbackPlanner)
assert(fallbackNavigation:preparePlannerTasks() == true,
  table.concat(fallbackNavigation.errors or {}, "; "))
assert(fallbackNavigation.fallbackPathCount == 1,
  "deterministic graph fallback missing")
assert(fallbackPlanner.tasks[1].routingMethod == "CUSTOM_GRAPH_AFTER_MOOSE_ASTAR",
  "fallback routing method missing")
ASTAR.forceNoPath = false

assert(config.configurationVersion
    == "TM02W2F-red-direct-offroad-progress-watchdog-8",
  "unexpected configuration version")
assert(config.execution.maxActiveTasks == 4, "expected four active transports")
assert(config.commanderTest.maxActiveTransportsGlobal == 4,
  "commander/executor active limits differ")
assert(config.commanderTest.canaryProgressMeters == 75,
  "canary threshold must remain 75 m")
assert(config.routing.physicalMode
    == "DIRECT_OFFROAD_WITH_PROGRESS_RELOCATION_RECOVERY",
  "unexpected physical mode")
assert(config.routing.maximumPhysicalWaypointsPerLeg == 4,
  "road fallback requires at most four waypoints")
assert(config.navigation.roadsUsedForNormalMovement == false,
  "normal movement must remain direct off road")
assert(config.navigation.automaticRecoveryEnabled == true,
  "progress recovery must be enabled")
assert(config.watchdog.enabled == true, "watchdog must be enabled")
assert(config.watchdog.maxOffroadRelocationsPerEpisode == 4,
  "exactly four off-road relocations are required")
assert(config.watchdog.relocationAdvanceMeters == 75,
  "each relocation must advance exactly 75 m")
assert(config.watchdog.terminalRecoveryThresholdMeters == 100,
  "terminal recovery gate must be 100 m")
assert(config.watchdog.terminalRecoveryOffsetMeters == 25,
  "terminal recovery offset must be 25 m")
assert(config.watchdog.episodeResetProgressMeters >= 150,
  "recovery episode must require substantial real progress before reset")
assert(config.routeReassignmentWatchdog == nil,
  "legacy route-reassignment watchdog must remain disabled")
for _, slot in ipairs(config.proxy.launchSlots) do
  assert(slot.x == 0 and slot.y == 0,
    "unsafe Cartesian launch spreading is forbidden")
end

print("TM02W2F static PASS: tasks=20 astar=20 fallback=1 watchdog=4x75m+road terminal<=100m")
