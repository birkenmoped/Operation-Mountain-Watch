local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
end

local logLines = {}
_G.env = { info = function(line) logLines[#logLines + 1] = line end }

local missionTime = 0
_G.timer = { getTime = function() return missionTime end }

local scheduled = {}
_G.SCHEDULER = {}
function _G.SCHEDULER:New(_, fn, args, startDelay, interval)
  local item = {
    fn = fn,
    args = args or {},
    startDelay = startDelay,
    interval = interval,
    stopped = false,
  }
  function item:Stop() self.stopped = true end
  scheduled[#scheduled + 1] = item
  return item
end

local movementInstances = {}
_G.MOVEMENT = {}
function _G.MOVEMENT:New(prefixes, maximum)
  local item = { prefixes = prefixes, maximum = maximum, started = false, stopped = false }
  function item:ScheduleStart() self.started = true end
  function item:ScheduleStop() self.stopped = true end
  movementInstances[#movementInstances + 1] = item
  return item
end

_G.MESSAGE = {}
function _G.MESSAGE:New(text, duration, category)
  return { ToAll = function() return true end }
end

local config = loadLua("mission/tests/tm02-red-network/config-tm02w2f.lua")
local schedulerModule = loadLua("mission/tests/tm02-red-network/src/tm02w2f-commander-scheduler.lua")

local tasks = {}
local taskById = {}
local planner = { inventoryBySiteId = {} }
local navigation = { valid = true, routingReady = true, plans = {} }
function navigation:getLegPlan(sourceSiteId, targetSiteId)
  return self.plans[sourceSiteId .. ">" .. targetSiteId]
end

for index = 1, 8 do
  local firstEdgeTarget = index % 2 == 1 and "EDGE_A" or "EDGE_B"
  local targetSiteId = string.format("TARGET_%02d", index)
  local task = {
    taskId = string.format("STATIC-%02d", index),
    sourceSiteId = "HQ",
    targetSiteId = targetSiteId,
    strength = 4,
    path = { "HQ", firstEdgeTarget, targetSiteId },
    currentLegIndex = 1,
    movementState = "QUEUED",
    currentCoordinate = { x = 0, y = 0, z = 0 },
  }
  tasks[index] = task
  taskById[task.taskId] = task
  planner.inventoryBySiteId[targetSiteId] = { defensiveTarget = 8 }
  navigation.plans["HQ>" .. firstEdgeTarget] = { safe = true, mode = "DIRECT_OFFROAD", lengthMeters = 1000 }
  navigation.plans[firstEdgeTarget .. ">" .. targetSiteId] = { safe = true, mode = "DIRECT_OFFROAD", lengthMeters = 2000 + index }
end

local execution = {
  configurationValid = true,
  started = false,
  completed = false,
  failed = false,
  tasks = tasks,
  taskById = taskById,
}
execution.startExecution = function()
  assert(execution.started == false, "native execution started twice")
  execution.started = true
  local dispatched = 0
  for _, task in ipairs(execution.tasks) do
    if task.movementState == "QUEUED" then
      task.movementState = "EN_ROUTE"
      local coordinate = task.currentCoordinate
      task.proxyGroup = {
        IsAlive = function() return true end,
        GetCoordinate = function()
          return { GetVec3 = function() return coordinate end }
        end,
      }
      task.setCoordinate = function(value)
        coordinate = value
        task.currentCoordinate = value
      end
      dispatched = dispatched + 1
    end
  end
  assert(dispatched == 1, "scheduler must release exactly one canary before native start")
  return true
end

local commander = schedulerModule.install(config, execution, navigation, planner)
assert(commander.valid == true, table.concat(commander.errors or {}, "; "))
for _, task in ipairs(tasks) do assert(task.movementState == "PLANNED", "task not initialized as PLANNED") end

assert(commander.start() == true, "commander failed to start")
assert(commander.cycleCount == 1, "first commander cycle missing")
assert(commander.orderedTaskCount == 4, "first cycle must issue four orders")
assert(commander.releasedTaskCount == 1, "start must release only the canary")
assert(#scheduled == 2, "two MOOSE schedulers must be installed")
assert(#movementInstances == 1 and movementInstances[1].started == true, "MOVEMENT limiter must start")
assert(movementInstances[1].maximum == config.commanderTest.maxActiveTransportsGlobal,
  "MOVEMENT maximum must use configured global movement limit")

local canary = execution.taskById[commander.canaryTaskId]
assert(canary and canary.movementState == "EN_ROUTE", "canary must be active")

missionTime = 1
scheduled[1].fn()
assert(commander.releasedTaskCount == 1, "no task may release before canary progress")

missionTime = 20
canary.setCoordinate({ x = 80, y = 0, z = 0 })
scheduled[1].fn()
assert(commander.canaryPassed == true, "canary must pass after 75 metres")
assert(commander.releasedTaskCount == 1, "same-edge successor must remain held below spacing threshold")

missionTime = 30
canary.setCoordinate({ x = 160, y = 0, z = 0 })
scheduled[1].fn()
assert(commander.releasedTaskCount == 2, "one successor must release after spacing threshold")

scheduled[2].fn()
assert(commander.cycleCount == 2, "second commander cycle missing")
assert(commander.orderedTaskCount == 8, "two cycles must issue eight orders")

local source = io.open(repositoryRoot .. "/mission/tests/tm02-red-network/src/tm02w2f-commander-scheduler.lua", "rb"):read("*a")
assert(not source:find("timer.scheduleFunction", 1, true), "native timer scheduling is forbidden")
assert(source:find("MOVEMENT:New", 1, true), "MOOSE MOVEMENT integration missing")
assert(source:find("SCHEDULER:New", 1, true), "MOOSE SCHEDULER integration missing")
assert(source:find("MESSAGE:New", 1, true), "MOOSE MESSAGE integration missing")

print("TM02W2F scheduler PASS: MOOSE SCHEDULER+MOVEMENT+MESSAGE canary=75m spacing=150m")
