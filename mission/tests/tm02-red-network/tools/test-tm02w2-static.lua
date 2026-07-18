local repositoryRoot = arg[1] or "."

local function path(relative)
  return repositoryRoot .. "/" .. relative
end

local logLines = {}

env = {
  mission = {
    triggers = {
      zones = {
        { name = "OMW_RED_HQ_Main", x = 0, y = 0, radius = 100 },
        { name = "OMW_RED_SITE_Central_01", x = -1000, y = 1000, radius = 100 },
        { name = "OMW_RED_SITE_Central_02", x = 1000, y = 1000, radius = 100 },
        { name = "OMW_RED_SITE_Central_03", x = -1000, y = 2200, radius = 100 },
        { name = "OMW_RED_SITE_Central_04", x = 1000, y = 2200, radius = 100 },
        { name = "OMW_RED_SUBHQ_Left", x = -2200, y = 3300, radius = 100 },
        { name = "OMW_RED_SUBHQ_Right", x = 2200, y = 3300, radius = 100 },
        { name = "OMW_RED_SITE_Left_01", x = -2900, y = 4400, radius = 100 },
        { name = "OMW_RED_SITE_Left_02", x = -1500, y = 4400, radius = 100 },
        { name = "OMW_RED_SITE_Right_01", x = 1500, y = 4400, radius = 100 },
        { name = "OMW_RED_SITE_Right_02", x = 2900, y = 4400, radius = 100 },
        { name = "OMW_BLUE_OBJECTIVE_FOB", x = -2200, y = 5400, radius = 500 },
        { name = "OMW_BLUE_OBJECTIVE_Airport", x = 2200, y = 5400, radius = 800 },
      },
    },
  },
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

missionCommands = nil

local config = assert(dofile(path("mission/tests/tm02-red-network/config-tm02w2.lua")))
local TM02W1 = assert(dofile(path("mission/tests/tm02-red-network/src/tm02w1.lua")))
local TM02W2 = assert(dofile(path("mission/tests/tm02-red-network/src/tm02w2.lua")))

local build = {
  buildTimestamp = "STATIC-HARNESS",
  stageId = "TM02W2",
}

local registry = TM02W1.start(config.network, build)
assert(registry.configurationValid == true, "W1 registry must be valid")
assert(#registry.movementLinks == 17, "expected 17 movement links")
assert(#(function()
  local keys = {}
  for key in pairs(registry.nodeById) do keys[#keys + 1] = key end
  return keys
end)() == 11, "expected 11 active W2 nodes")

local planner = TM02W2.start(config, registry, build)
assert(planner.configurationValid == true, table.concat(planner.errors or {}, "; "))
assert(planner.initialDeficit == 18, "expected initial deficit 18")
assert(planner.totalReservedInbound == 18, "expected inbound reservations 18")
assert(planner.totalReservedOutbound == 18, "expected outbound reservations 18")
assert(planner.unresolvedDeficit == 0, "expected no unresolved deficit")
assert(#planner.tasks >= 4, "expected at least four tasks")
assert(planner.candidateEvaluationCount > #planner.tasks, "expected multiple candidate evaluations")
assert(planner.multiHopTaskCount >= 1, "expected a multi-hop task")
assert(planner.nonNearestSelectionCount >= 1, "expected a non-nearest source selection")
assert(planner.reservationInfluenceCount >= 1, "expected reservation influence")

print(string.format(
  "TM02W2 STATIC PASS tasks=%d candidates=%d multiHop=%d nonNearest=%d reservationInfluence=%d",
  #planner.tasks,
  planner.candidateEvaluationCount,
  planner.multiHopTaskCount,
  planner.nonNearestSelectionCount,
  planner.reservationInfluenceCount
))
