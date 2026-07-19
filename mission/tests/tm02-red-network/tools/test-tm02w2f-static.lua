local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

_G.env = {
  info = function() end,
}

local baseConfig = loadLua("mission/tests/tm02-red-network/config-tm02w2.lua")
local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local plannerModule = loadLua("mission/tests/tm02-red-network/src/tm02w2f-initial-fill-planner.lua")

local registry = {
  configurationValid = true,
  siteById = {},
}
for siteId in pairs(config.initialFill.targetPersonnelBySiteId) do
  registry.siteById[siteId] = {
    siteId = siteId,
    coordinate = { x = 0, y = 0, z = 0 },
  }
end

local planner = plannerModule.start(config, baseConfig, registry, {
  buildTimestamp = "STATIC",
})

assert(planner.configurationValid == true, table.concat(planner.errors or {}, "; "))
assert(#planner.tasks == 20, "expected 20 tasks, got " .. tostring(#planner.tasks))
assert(planner.totalReservedInbound == 88, "expected 88 inbound reservations")
assert(planner.totalReservedOutbound == 88, "expected 88 outbound reservations")
assert(planner.unresolvedDeficit == 0, "initial fill must not leave an unresolved deficit")

local taskStrength = 0
local inboundByTarget = {}
for _, task in ipairs(planner.tasks) do
  assert(task.sourceSiteId == config.initialFill.supplySiteId, "unexpected source")
  assert(task.strength >= 1 and task.strength <= 6, "packet strength outside 1..6")
  taskStrength = taskStrength + task.strength
  inboundByTarget[task.targetSiteId] = (inboundByTarget[task.targetSiteId] or 0) + task.strength
end
assert(taskStrength == 88, "task personnel total mismatch")

local targetTotal = 0
for siteId, target in pairs(config.initialFill.targetPersonnelBySiteId) do
  targetTotal = targetTotal + target
  if siteId ~= config.initialFill.supplySiteId then
    assert(inboundByTarget[siteId] == target,
      siteId .. " expected inbound " .. target .. ", got " .. tostring(inboundByTarget[siteId]))
  end
end
assert(targetTotal == 112, "target total must be 112")

local supply = planner.inventoryBySiteId[config.initialFill.supplySiteId]
assert(supply.currentPersonnel == 112, "supply must begin with 112 personnel")
assert(supply.currentPersonnel - supply.reservedOutbound == 24,
  "supply must retain 24 personnel")

assert(config.configurationVersion == "TM02W2F-red-direct-offroad-canary-5",
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

print("TM02W2F static contract PASS: tasks=20 direct-offroad=2wp canary=75m spawn=10s active=4")
