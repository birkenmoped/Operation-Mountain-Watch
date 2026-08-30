local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Policy = dofile("scripts/campaign/OMW_FobAttackFireSupportDemandPolicy.lua")
local Adapter = dofile("scripts/ground/OMW_FobAttackFunctionalArtyDispatchAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local registry = MissionDemand.New()
local demand = Policy.CreateDemand(MissionDemand, registry, {
  incidentId = "INC-HONAKER-1",
  installationId = "BLUE_GROUND_COP_HONAKER",
  priority = 90,
}, {
  targetKind = "DETECTED_RED_GROUND_GROUP",
  targetName = "RED-1",
  position = { x = 1, z = 2 },
})

local targetGroup = { IsAlive=function() return true end }
local arty = {
  AssignAttackGroup = function(self, group, priority, radiusM, shells, maxEngagements)
    assertEqual(group, targetGroup, "target group")
    assertEqual(priority, 10, "priority")
    assertEqual(radiusM, 50, "radius")
    assertEqual(shells, 4, "shells")
    assertEqual(maxEngagements, 1, "max engagements")
    return "RED-1"
  end,
  I = function() end,
}

local started, completed = 0, 0
local adapter = Adapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  arty = arty,
  assigneeId = "ARTY:WRIGHT:L118",
  shells = 4,
  radiusM = 50,
  onFireStarted = function() started = started + 1 end,
  onFireComplete = function() completed = completed + 1 end,
})

local targetName, dispatched, reason = adapter:Dispatch(demand, targetGroup)
assertTrue(dispatched, "dispatched")
assertEqual(reason, nil, "reason")
assertEqual(targetName, "RED-1", "target name")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "assigned")

arty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name="RED-1" })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "active")
assertEqual(started, 1, "started callbacks")

arty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name="RED-1" })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "success")
assertEqual(registry:Get(demand.id).result.executor, "ARTY:WRIGHT:L118", "executor")
assertEqual(completed, 1, "completed callbacks")

local duplicateTarget, duplicateDispatched, duplicateReason = adapter:Dispatch(registry:Get(demand.id), targetGroup)
assertEqual(duplicateTarget, "RED-1", "duplicate target")
assertEqual(duplicateDispatched, false, "duplicate dispatch")
assertEqual(duplicateReason, "ALREADY_DISPATCHED", "duplicate reason")

print("PASS test_fob_attack_functional_arty")
