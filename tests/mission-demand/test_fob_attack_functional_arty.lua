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

local coord1 = { id="COORD-1" }
local coord2 = { id="COORD-2" }
local targetGroup1 = { IsAlive=function() return true end, GetCoordinate=function() return coord1 end, GetName=function() return "RED-1" end }
local targetGroup2 = { IsAlive=function() return true end, GetCoordinate=function() return coord2 end, GetName=function() return "RED-2" end }

local function newArty()
  local calls = {}
  local arty = {
    AssignTargetCoord = function(self, coordinate, priority, radiusM, shells, maxEngagements, time, weaponType, name, unique)
      calls[#calls+1] = { coordinate=coordinate, priority=priority, radiusM=radiusM, shells=shells, maxEngagements=maxEngagements, name=name, unique=unique }
      return name
    end,
    I = function() end,
  }
  return arty, calls
end

local registry = MissionDemand.New()
local demand = newDemand(registry, "1")
local arty, calls = newArty()
local started, targetCompleted, completed, verified = 0, 0, 0, 0
local adapter = Adapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  arty = arty,
  assigneeId = "ARTY:WRIGHT:L118",
  shells = 4,
  radiusM = 50,
  onFireStarted = function() started = started + 1 end,
  verifyFireComplete = function() verified = verified + 1; return true end,
  onTargetComplete = function() targetCompleted = targetCompleted + 1 end,
  onFireComplete = function() completed = completed + 1 end,
})

local targetNames, dispatched, reason = adapter:DispatchTargets(demand, {targetGroup1, targetGroup2})
assertTrue(dispatched, "multi-target dispatch")
assertEqual(reason, nil, "dispatch reason")
assertEqual(#targetNames, 2, "target count")
assertEqual(targetNames[1], "RED-1", "first target name")
assertEqual(targetNames[2], "RED-2", "second target name")
assertEqual(#calls, 2, "AssignTargetCoord calls")
assertEqual(calls[1].coordinate, coord1, "first coordinate")
assertEqual(calls[2].coordinate, coord2, "second coordinate")
assertEqual(calls[1].priority, 10, "priority")
assertEqual(calls[1].radiusM, 50, "radius")
assertEqual(calls[1].shells, 4, "shells")
assertEqual(calls[1].maxEngagements, 1, "max engagements")
assertEqual(calls[1].unique, true, "unique target")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "assigned")
assertEqual(adapter:GetTargetName(demand.id), "RED-1", "first target correlation")
assertEqual(#adapter:GetTargetNames(demand.id), 2, "target correlation count")

arty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name="RED-1" })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "active")
assertEqual(started, 1, "first started callback")
arty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name="RED-1" })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "first target does not close demand")
assertEqual(targetCompleted, 1, "first target complete callback")
assertEqual(completed, 0, "mission not complete after first target")

arty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name="RED-2" })
arty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name="RED-2" })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "success")
assertEqual(registry:Get(demand.id).result.executor, "ARTY:WRIGHT:L118", "executor")
assertEqual(registry:Get(demand.id).result.physicalFireConfirmed, true, "physical verification result")
assertEqual(#registry:Get(demand.id).result.functionalArtyTargets, 2, "result target count")
assertEqual(started, 2, "started callbacks")
assertEqual(verified, 2, "verification callbacks")
assertEqual(targetCompleted, 2, "target complete callbacks")
assertEqual(completed, 1, "mission complete callback")

local duplicateTargets, duplicateDispatched, duplicateReason = adapter:DispatchTargets(registry:Get(demand.id), {targetGroup1})
assertEqual(duplicateTargets, adapter:GetTargetNames(demand.id), "duplicate targets")
assertEqual(duplicateDispatched, false, "duplicate dispatch")
assertEqual(duplicateReason, "ALREADY_DISPATCHED", "duplicate reason")

local singleRegistry = MissionDemand.New()
local singleDemand = newDemand(singleRegistry, "SINGLE")
local singleArty = newArty()
local singleAdapter = Adapter.New({ missionDemand=MissionDemand, registry=singleRegistry, arty=singleArty, assigneeId="ARTY:WRIGHT:L118" })
local singleName, singleDispatched = singleAdapter:Dispatch(singleDemand, targetGroup1)
assertTrue(singleDispatched, "single dispatch")
assertEqual(singleName, "RED-1", "single dispatch target")

local failedRegistry = MissionDemand.New()
local failedDemand = newDemand(failedRegistry, "FAILED")
local failedArty = newArty()
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
failedAdapter:Dispatch(failedDemand, targetGroup1)
failedArty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name="RED-1" })
failedArty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name="RED-1" })
assertEqual(failedRegistry:Get(failedDemand.id).status, MissionDemand.Status.FAILED, "unverified fire fails demand")
assertEqual(failedRegistry:Get(failedDemand.id).failureReason, "PHYSICAL_AMMO_UNCHANGED", "unverified failure reason")
assertEqual(rejected, 1, "rejected callbacks")
assertEqual(failedComplete, 0, "completion callback not called when unverified")

print("PASS test_fob_attack_functional_arty")
