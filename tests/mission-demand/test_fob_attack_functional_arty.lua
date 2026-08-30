local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Policy = dofile("scripts/campaign/OMW_FobAttackFireSupportDemandPolicy.lua")
local Adapter = dofile("scripts/ground/OMW_FobAttackFunctionalArtyDispatchAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local function newDemand(registry, suffix)
  return Policy.CreateDemand(MissionDemand, registry, {
    incidentId = "INC-HONAKER-" .. suffix,
    installationId = "BLUE_GROUND_COP_HONAKER",
    priority = 90,
  }, {
    targetKind = "DETECTED_RED_GROUND_GROUP",
    targetName = "RED-" .. suffix,
    position = { x = 1, z = 2 },
  })
end

local targetGroup = { IsAlive=function() return true end }
local function newArty(targetName)
  return {
    AssignAttackGroup = function(self, group, priority, radiusM, shells, maxEngagements)
      assertEqual(group, targetGroup, "target group")
      assertEqual(priority, 10, "priority")
      assertEqual(radiusM, 50, "radius")
      assertEqual(shells, 4, "shells")
      assertEqual(maxEngagements, 1, "max engagements")
      return targetName
    end,
    I = function() end,
  }
end

local registry = MissionDemand.New()
local demand = newDemand(registry, "1")
local arty = newArty("RED-1")
local started, completed, verified = 0, 0, 0
local adapter = Adapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  arty = arty,
  assigneeId = "ARTY:WRIGHT:L118",
  shells = 4,
  radiusM = 50,
  onFireStarted = function() started = started + 1 end,
  verifyFireComplete = function() verified = verified + 1; return true end,
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
assertEqual(registry:Get(demand.id).result.physicalFireConfirmed, true, "physical verification result")
assertEqual(verified, 1, "verification callbacks")
assertEqual(completed, 1, "completed callbacks")

local duplicateTarget, duplicateDispatched, duplicateReason = adapter:Dispatch(registry:Get(demand.id), targetGroup)
assertEqual(duplicateTarget, "RED-1", "duplicate target")
assertEqual(duplicateDispatched, false, "duplicate dispatch")
assertEqual(duplicateReason, "ALREADY_DISPATCHED", "duplicate reason")

local failedRegistry = MissionDemand.New()
local failedDemand = newDemand(failedRegistry, "2")
local failedArty = newArty("RED-2")
local rejected, failedComplete = 0, 0
local failedAdapter = Adapter.New({
  missionDemand = MissionDemand,
  registry = failedRegistry,
  arty = failedArty,
  assigneeId = "ARTY:WRIGHT:L118",
  verifyFireComplete = function() return false, "PHYSICAL_AMMO_UNCHANGED" end,
  onFireRejected = function(_, _, _, reason)
    rejected = rejected + 1
    assertEqual(reason, "PHYSICAL_AMMO_UNCHANGED", "rejection reason")
  end,
  onFireComplete = function() failedComplete = failedComplete + 1 end,
})
failedAdapter:Dispatch(failedDemand, targetGroup)
failedArty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name="RED-2" })
failedArty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name="RED-2" })
assertEqual(failedRegistry:Get(failedDemand.id).status, MissionDemand.Status.FAILED, "unverified fire fails demand")
assertEqual(failedRegistry:Get(failedDemand.id).failureReason, "PHYSICAL_AMMO_UNCHANGED", "unverified failure reason")
assertEqual(rejected, 1, "rejected callbacks")
assertEqual(failedComplete, 0, "completion callback not called when unverified")

print("PASS test_fob_attack_functional_arty")