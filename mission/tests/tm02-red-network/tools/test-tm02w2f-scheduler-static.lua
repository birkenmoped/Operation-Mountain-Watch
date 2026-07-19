local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local function readFile(path)
  local handle = assert(io.open(repositoryRoot .. "/" .. path, "rb"))
  local content = handle:read("*a")
  handle:close()
  return content
end

local logLines = {}
_G.env = { info = function(line) logLines[#logLines + 1] = line end }
_G.trigger = { action = { outText = function() end } }

local missionTime = 0
local scheduled = {}
_G.timer = {
  getTime = function() return missionTime end,
  scheduleFunction = function(fn, argument, time)
    scheduled[#scheduled + 1] = { fn = fn, argument = argument, time = time }
    return #scheduled
  end,
}

local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local schedulerModule = loadLua("mission/tests/tm02-red-network/src/tm02w2f-commander-scheduler.lua")

local function pairKey(firstId, secondId)
  if firstId < secondId then return firstId .. "\0" .. secondId end
  return secondId .. "\0" .. firstId
end

local tasks = {}
local planner = { inventoryBySiteId = {} }
local navigation = { valid = true, planByPair = {} }
for index = 1, 8 do
  local firstEdgeTarget = index % 2 == 1 and "EDGE_A" or "EDGE_B"
  local targetSiteId = string.format("TARGET_%02d", index)
  tasks[index] = {
    taskId = string.format("STATIC-%02d", index),
    sourceSiteId = "HQ",
    targetSiteId = targetSiteId,
    strength = 4,
    path = { "HQ", firstEdgeTarget, targetSiteId },
    currentLegIndex = 1,
    movementState = "QUEUED",
    currentCoordinate = { x = 0, y = 0, z = 0 },
  }
  planner.inventoryBySiteId[targetSiteId] = { defensiveTarget = 8 }
  navigation.planByPair[pairKey("HQ", firstEdgeTarget)] = {
    sourceSiteId = "HQ",
    targetSiteId = firstEdgeTarget,
    lengthMeters = firstEdgeTarget == "EDGE_A" and 1000 or 1200,
  }
  navigation.planByPair[pairKey(firstEdgeTarget, targetSiteId)] = {
    sourceSiteId = firstEdgeTarget,
    targetSiteId = targetSiteId,
    lengthMeters = 2000 + index,
  }
end

local execution = {
  configurationValid = true,
  started = false,
  completed = false,
  failed = false,
  tasks = tasks,
}
execution.startExecution = function()
  assert(execution.started == false, "native execution started twice")
  execution.started = true
  local dispatched = 0
  for _, task in ipairs(execution.tasks) do
    if task.movementState == "QUEUED" then
      task.movementState = "EN_ROUTE"
      dispatched = dispatched + 1
    end
  end
  assert(dispatched == 1, "scheduler must release exactly one task before native start")
  return true
end

local commander = schedulerModule.install(config, execution, navigation, planner)
assert(commander.valid == true, table.concat(commander.errors or {}, "; "))
for _, task in ipairs(tasks) do assert(task.movementState == "PLANNED", "task not initialized as PLANNED") end

assert(commander.start() == true, "commander failed to start")
assert(commander.cycleCount == 1, "first commander cycle missing")
assert(commander.orderedTaskCount == 4, "first cycle must issue four orders")
assert(commander.releasedTaskCount == 1, "first cycle must release one physical spawn")

local enRoute, ordered = 0, 0
for _, task in ipairs(tasks) do
  if task.movementState == "EN_ROUTE" then enRoute = enRoute + 1 end
  if task.movementState == "ORDERED" then ordered = ordered + 1 end
end
assert(enRoute == 1 and ordered == 3, "unexpected first-cycle state distribution")
assert(#scheduled == 2, "scheduler and commander-cycle timers must be installed")

missionTime = 8
scheduled[1].fn(scheduled[1].argument, missionTime)
local queued = 0
for _, task in ipairs(tasks) do if task.movementState == "QUEUED" then queued = queued + 1 end end
assert(queued == 1, "different first-edge transport should be released after eight seconds")
for _, task in ipairs(tasks) do
  if task.movementState == "QUEUED" then task.movementState = "EN_ROUTE" end
end

missionTime = 16
tasks[1].currentCoordinate = { x = 300, y = 0, z = 0 }
scheduled[1].fn(scheduled[1].argument, missionTime)
queued = 0
for _, task in ipairs(tasks) do if task.movementState == "QUEUED" then queued = queued + 1 end end
assert(queued == 1, "same-edge successor should release after 250 metres predecessor progress")

missionTime = 30
scheduled[2].fn(scheduled[2].argument, missionTime)
assert(commander.cycleCount == 2, "second commander cycle missing")
assert(commander.orderedTaskCount == 8, "two cycles must issue exactly eight orders")

local watchdogSource = readFile("mission/tests/tm02-red-network/src/tm02w2f-route-reassignment-watchdog.lua")
assert(not watchdogSource:find("SPAWN:", 1, true), "automatic TM02W2F watchdog must not spawn replacement groups")
assert(not watchdogSource:find(":Destroy", 1, true), "automatic TM02W2F watchdog must not destroy groups")

print("TM02W2F scheduler PASS: cycles=2 orders=8 serializedReleases=3 noRecoverySpawns=true")
