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

print("TM02W2F static planner PASS: tasks=20 reserved=88 total=112")
