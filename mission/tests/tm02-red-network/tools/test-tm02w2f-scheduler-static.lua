local repositoryRoot = assert(arg[1], "repository root argument is required")

local function loadLua(path)
  local chunk, errorMessage = loadfile(repositoryRoot .. "/" .. path)
  assert(chunk, errorMessage)
  return chunk()
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

local tasks = {}
local taskById = {}
local planner = { inventoryBySiteId = {} }
local navigation = {
  valid = true,
  routingReady = true,
  plans = {},
}
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
  navigation.plans["HQ>" .. firstEdgeTarget] = {
    safe = true,
    mode = "DIRECT_OFFROAD",
    lengthMeters = firstEdgeTarget == "EDGE_A" and 1000 or 1200,
  }
  navigation.plans[firstEdgeTarget .. ">" .. targetSiteId] = {
    safe = true,
    mode = "DIRECT_OFFROAD",
    lengthMeters = 2000 + index,
  }
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
      task.proxyGroupName = task.taskId .. "_GROUP"
      local coordinate = task.currentCoordinate
      task.proxyGroup = {
        IsAlive = function() return true end,
        GetCoordinate = function()
          return {
            GetVec3 = function() return coordinate end,
          }
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
for _, task in ipairs(tasks) do
  assert(task.movementState == "PLANNED", "task not initialized as PLANNED")
end

assert(commander.start() == true, "commander failed to start")
assert(commander.cycleCount == 1, "first commander cycle missing")
assert(commander.orderedTaskCount == 4, "first cycle must issue four orders")
assert(commander.releasedTaskCount == 1, "start must release only the canary")
assert(commander.canaryPassed == false, "canary must not pass before movement")
assert(#scheduled == 2, "scheduler and commander-cycle timers must be installed")

local canary = execution.taskById[commander.canaryTaskId]
assert(canary and canary.movementState == "EN_ROUTE", "canary must be the only active task")

missionTime = 1
local nextSchedulerTime = scheduled[1].fn(scheduled[1].argument, scheduled[1].time)
assert(nextSchedulerTime == 2, "scheduler must reschedule from current mission time")
assert(commander.releasedTaskCount == 1, "no task may release before canary progress")

missionTime = 20
canary.setCoordinate({ x = 80, y = 0, z = 0 })
nextSchedulerTime = scheduled[1].fn(scheduled[1].argument, 2)
assert(nextSchedulerTime == 21, "scheduler catch-up must be disabled")
assert(commander.canaryPassed == true, "canary must pass after 75 metres")
assert(commander.releasedTaskCount == 1,
  "same-edge successor must remain held below 150 metres predecessor progress")

missionTime = 30
canary.setCoordinate({ x = 160, y = 0, z = 0 })
nextSchedulerTime = scheduled[1].fn(scheduled[1].argument, 21)
assert(nextSchedulerTime == 31, "scheduler must continue from current mission time")
assert(commander.releasedTaskCount == 2,
  "one successor must release after canary and spacing thresholds pass")

local nextCycleTime = scheduled[2].fn(scheduled[2].argument, scheduled[2].time)
assert(nextCycleTime == 60, "commander cycle must reschedule from current mission time")
assert(commander.cycleCount == 2, "second commander cycle missing")
assert(commander.orderedTaskCount == 8, "two cycles must issue exactly eight orders")

local forbiddenSource = table.concat({
  io.open(repositoryRoot .. "/mission/tests/tm02-red-network/src/tm02w2f-commander-scheduler.lua", "rb"):read("*a"),
}, "")
assert(not forbiddenSource:find("scheduledTime +", 1, true),
  "timer catch-up scheduling is forbidden")

print("TM02W2F scheduler PASS: canary=75m spacing=150m releases=2 timerCatchUp=false")
