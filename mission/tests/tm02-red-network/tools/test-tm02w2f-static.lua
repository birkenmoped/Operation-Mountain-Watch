local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local logLines = {}
_G.env = {
  info = function(line)
    logLines[#logLines + 1] = line
  end,
}

_G.COORDINATE = {}
function COORDINATE:NewFromVec3(vec3)
  local coordinate = {
    x = vec3.x,
    y = vec3.y or 0,
    z = vec3.z,
  }
  function coordinate:Get2DDistance(other)
    local target = other.coordinate or other
    local dx = target.x - self.x
    local dz = target.z - self.z
    return math.sqrt(dx * dx + dz * dz)
  end
  return coordinate
end

_G.ASTAR = {
  INF = math.huge,
  forceNoPath = false,
}

function ASTAR:New()
  local instance = {
    nodes = {},
    counter = 1,
  }
  return setmetatable(instance, { __index = ASTAR })
end

function ASTAR:AddNodeFromCoordinate(coordinate)
  local node = {
    id = self.counter,
    coordinate = coordinate,
  }
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
  assert(self.startCoordinate, "SetStartCoordinate must be called before GetPath")
  assert(self.endCoordinate, "SetEndCoordinate must be called before GetPath")
  assert(type(self.validNeighbourFunction) == "function", "valid-neighbour function missing")
  assert(type(self.costFunction) == "function", "cost function missing")

  if ASTAR.forceNoPath then
    return nil
  end

  local startNode
  local endNode
  for _, node in ipairs(self.nodes) do
    if sameCoordinate(node.coordinate, self.startCoordinate) then
      startNode = node
    end
    if sameCoordinate(node.coordinate, self.endCoordinate) then
      endNode = node
    end
  end
  assert(startNode, "start coordinate was not mapped to a node")
  assert(endNode, "end coordinate was not mapped to a node")

  local heuristic = self.costFunction(startNode, endNode)
  assert(type(heuristic) == "number" and heuristic < math.huge,
    "ASTAR heuristic must remain finite even when start and goal are not direct neighbours")

  local queue = { startNode }
  local queueIndex = 1
  local visited = { [startNode] = true }
  local previous = {}

  while queueIndex <= #queue do
    local current = queue[queueIndex]
    queueIndex = queueIndex + 1
    if current == endNode then
      break
    end
    for _, candidate in ipairs(self.nodes) do
      if not visited[candidate]
        and candidate ~= current
        and self.validNeighbourFunction(current, candidate) == true then
        visited[candidate] = true
        previous[candidate] = current
        queue[#queue + 1] = candidate
      end
    end
  end

  if not visited[endNode] then
    return nil
  end

  local path = {}
  local current = endNode
  while current do
    table.insert(path, 1, current)
    current = previous[current]
  end
  return path
end

local baseConfig = loadLua("mission/tests/tm02-red-network/config-tm02w2.lua")
local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local plannerModule = loadLua("mission/tests/tm02-red-network/src/tm02w2f-initial-fill-planner.lua")
local navigationModule = loadLua("mission/tests/tm02-red-network/src/tm02w2f-direct-offroad-navigation.lua")

local supplySiteId = config.initialFill.supplySiteId
local targetSiteIds = {}
for siteId in pairs(config.initialFill.targetPersonnelBySiteId) do
  if siteId ~= supplySiteId then
    targetSiteIds[#targetSiteIds + 1] = siteId
  end
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
assert(#planner.tasks == 20, "expected 20 tasks, got " .. tostring(#planner.tasks))
assert(planner.totalReservedInbound == 88, "expected 88 inbound reservations")
assert(planner.totalReservedOutbound == 88, "expected 88 outbound reservations")
assert(planner.unresolvedDeficit == 0, "initial fill must not leave an unresolved deficit")

local navigation = navigationModule.install(config, registry, planner)
assert(navigation:preparePlannerTasks() == true,
  table.concat(navigation.errors or {}, "; "))
assert(navigation.safeTaskCount == 20, "all 20 tasks must receive a safe logical path")
assert(navigation.moosePathCount == 20, "normal static run must use MOOSE ASTAR for all tasks")
assert(navigation.fallbackPathCount == 0, "fallback must remain unused while MOOSE succeeds")
assert(#navigation.errors == 0, "navigation must not produce errors")

for _, task in ipairs(planner.tasks) do
  assert(task.path[1] == task.sourceSiteId, "logical path source mismatch")
  assert(task.path[#task.path] == task.targetSiteId, "logical path target mismatch")
  assert(task.routingMethod == "MOOSE_ASTAR_RED_NETWORK", "unexpected normal routing method")
  assert(#task.linkIds == #task.path - 1, "logical path/link count mismatch")
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
assert(fallbackNavigation.safeTaskCount == 1, "fallback task must receive a path")
assert(fallbackNavigation.moosePathCount == 0, "forced MOOSE failure must not count as MOOSE path")
assert(fallbackNavigation.fallbackPathCount == 1, "deterministic graph fallback was not used")
assert(fallbackPlanner.tasks[1].routingMethod == "CUSTOM_GRAPH_AFTER_MOOSE_ASTAR",
  "fallback routing method not recorded")
assert(#fallbackNavigation.errors == 0, "successful fallback must not become an error")
assert(#fallbackNavigation.warnings == 1, "MOOSE fallback must be visible as one warning")
ASTAR.forceNoPath = false

local taskStrength = 0
local inboundByTarget = {}
for _, task in ipairs(planner.tasks) do
  assert(task.sourceSiteId == supplySiteId, "unexpected source")
  assert(task.strength >= 1 and task.strength <= 6, "packet strength outside 1..6")
  taskStrength = taskStrength + task.strength
  inboundByTarget[task.targetSiteId] = (inboundByTarget[task.targetSiteId] or 0) + task.strength
end
assert(taskStrength == 88, "task personnel total mismatch")

local targetTotal = 0
for siteId, target in pairs(config.initialFill.targetPersonnelBySiteId) do
  targetTotal = targetTotal + target
  if siteId ~= supplySiteId then
    assert(inboundByTarget[siteId] == target,
      siteId .. " expected inbound " .. target .. ", got " .. tostring(inboundByTarget[siteId]))
  end
end
assert(targetTotal == 112, "target total must be 112")

local supply = planner.inventoryBySiteId[supplySiteId]
assert(supply.currentPersonnel == 112, "supply must begin with 112 personnel")
assert(supply.currentPersonnel - supply.reservedOutbound == 24,
  "supply must retain 24 personnel")

assert(config.configurationVersion == "TM02W2F-red-direct-offroad-canary-6",
  "unexpected configuration version")
assert(config.commanderTest.planningIntervalSeconds == 30,
  "commander planning interval must be 30 seconds")
assert(config.commanderTest.commandBudgetPerCycle == 4,
  "commander command budget must be four")
assert(config.commanderTest.maxActiveTransportsGlobal == 4,
  "global active transport limit must be four")
assert(config.commanderTest.maxActiveTransportsPerFirstEdge == 2,
  "first-edge transport limit must be two")
assert(config.commanderTest.spawnIntervalSeconds == 10,
  "spawn interval must be ten seconds")
assert(config.commanderTest.minimumPredecessorProgressMeters == 150,
  "predecessor progress threshold must be 150 metres")
assert(config.commanderTest.canaryProgressMeters == 75,
  "canary must prove 75 metres of movement")
assert(config.commanderTest.canaryTimeoutSeconds == 120,
  "canary timeout must be 120 seconds")
assert(config.execution.maxActiveTasks == config.commanderTest.maxActiveTransportsGlobal,
  "executor and commander global limits must match")

assert(config.routing.physicalMode == "DIRECT_OFFROAD",
  "physical movement must be direct off-road")
assert(config.routing.maximumPhysicalWaypointsPerLeg == 2,
  "physical route must contain only start and destination")
assert(config.routing.formation == "Off Road",
  "executor formation must be Off Road")
assert(config.navigation.roadsUsedForNormalMovement == false,
  "normal movement must not use roads")
assert(config.navigation.automaticRecoveryEnabled == false,
  "automatic recovery must be disabled for the canary run")
assert(config.routeReassignmentWatchdog == nil,
  "legacy route-reassignment watchdog must not be configured")

assert(#config.proxy.launchSlots == config.execution.maxActiveTasks,
  "launch slot count must match executor capacity")
for _, slot in ipairs(config.proxy.launchSlots) do
  assert(slot.x == 0 and slot.y == 0,
    "free Cartesian launch spreading is forbidden")
end
assert(config.transitRepresentation.transitionIntervalSeconds >= 0.5,
  "manual group conversion must be serialized")

print("TM02W2F static contract PASS: tasks=20 astar=20 fallback=1 direct-offroad=2wp canary=75m")
