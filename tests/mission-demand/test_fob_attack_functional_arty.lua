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

-- Dynamic sequential extension: after the first physically verified fire mission,
-- the caller can reacquire the MOOSE OPSZONE picture and append one fresh target.
local registry = MissionDemand.New()
local demand = newDemand(registry, "1")
local arty, calls = newArty()
local started, targetCompleted, completed, verified = 0, 0, 0, 0
local adapter
adapter = Adapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  arty = arty,
  assigneeId = "ARTY:WRIGHT:L118",
  shells = 4,
  radiusM = 50,
  onFireStarted = function() started = started + 1 end,
  verifyFireComplete = function() verified = verified + 1; return true end,
  onTargetComplete = function(demandId)
    targetCompleted = targetCompleted + 1
    if targetCompleted == 1 then
      local targetName, queued, reason = adapter:QueueTarget(demandId, targetGroup2)
      assertTrue(queued, "dynamic target queued")
      assertEqual(reason, nil, "dynamic target queue reason")
      assertEqual(targetName, "RED-2|FS|002", "dynamic target alias")
    end
  end,
  onFireComplete = function() completed = completed + 1 end,
})

local firstName, dispatched, reason = adapter:Dispatch(demand, targetGroup1)
assertTrue(dispatched, "first coordinate dispatch")
assertEqual(reason, nil, "dispatch reason")
assertEqual(firstName, "RED-1|FS|001", "first target alias")
assertEqual(#calls, 1, "first AssignTargetCoord call")
assertEqual(calls[1].coordinate, coord1, "first coordinate")
assertEqual(calls[1].priority, 10, "priority")
assertEqual(calls[1].radiusM, 50, "radius")
assertEqual(calls[1].shells, 4, "shells")
assertEqual(calls[1].maxEngagements, 1, "max engagements")
assertEqual(calls[1].unique, true, "unique target")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "assigned")
assertEqual(adapter:GetTargetName(demand.id), "RED-1|FS|001", "first target correlation")
assertEqual(adapter:GetTargetMetadata(firstName).sourceGroupName, "RED-1", "first source group metadata")

arty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name=firstName })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "active")
assertEqual(started, 1, "first started callback")
arty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name=firstName })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "fresh target appended before completion gate")
assertEqual(targetCompleted, 1, "first target complete callback")
assertEqual(completed, 0, "mission remains active after dynamic extension")
assertEqual(#calls, 2, "second AssignTargetCoord appended")
assertEqual(calls[2].coordinate, coord2, "second coordinate is freshly read from new target")
assertEqual(#adapter:GetTargetNames(demand.id), 2, "dynamic target correlation count")

local secondName = adapter:GetTargetNames(demand.id)[2]
arty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name=secondName })
arty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name=secondName })
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "success after no further target extension")
assertEqual(registry:Get(demand.id).result.executor, "ARTY:WRIGHT:L118", "executor")
assertEqual(registry:Get(demand.id).result.physicalFireConfirmed, true, "physical verification result")
assertEqual(#registry:Get(demand.id).result.functionalArtyTargets, 2, "result target count")
assertEqual(started, 2, "started callbacks")
assertEqual(verified, 2, "verification callbacks")
assertEqual(targetCompleted, 2, "target complete callbacks")
assertEqual(completed, 1, "mission complete callback")

local _, queueAfterSuccess, queueAfterSuccessReason = adapter:QueueTarget(demand.id, targetGroup1)
assertEqual(queueAfterSuccess, false, "cannot extend completed demand")
assertEqual(queueAfterSuccessReason, "DEMAND_NOT_ACTIVE", "completed demand extension reason")

-- Initial multi-target dispatch remains supported for callers that intentionally
-- want a fixed list, but each MOOSE target receives a unique fire-mission alias.
local multiRegistry = MissionDemand.New()
local multiDemand = newDemand(multiRegistry, "MULTI")
local multiArty, multiCalls = newArty()
local multiAdapter = Adapter.New({ missionDemand=MissionDemand, registry=multiRegistry, arty=multiArty, assigneeId="ARTY:WRIGHT:L118" })
local names, multiDispatched = multiAdapter:DispatchTargets(multiDemand, {targetGroup1,targetGroup2})
assertTrue(multiDispatched, "multi dispatch")
assertEqual(names[1], "RED-1|FS|001", "multi first alias")
assertEqual(names[2], "RED-2|FS|002", "multi second alias")
assertEqual(#multiCalls, 2, "multi AssignTargetCoord calls")

local duplicateTargets, duplicateDispatched, duplicateReason = multiAdapter:DispatchTargets(multiRegistry:Get(multiDemand.id), {targetGroup1})
assertEqual(duplicateTargets, multiAdapter:GetTargetNames(multiDemand.id), "duplicate targets")
assertEqual(duplicateDispatched, false, "duplicate dispatch")
assertEqual(duplicateReason, "ALREADY_DISPATCHED", "duplicate reason")

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
local failedName = failedAdapter:Dispatch(failedDemand, targetGroup1)
failedArty:OnAfterOpenFire(nil, "READY", "OpenFire", "FIRING", { name=failedName })
failedArty:OnAfterCeaseFire(nil, "FIRING", "CeaseFire", "READY", { name=failedName })
assertEqual(failedRegistry:Get(failedDemand.id).status, MissionDemand.Status.FAILED, "unverified fire fails demand")
assertEqual(failedRegistry:Get(failedDemand.id).failureReason, "PHYSICAL_AMMO_UNCHANGED", "unverified failure reason")
assertEqual(rejected, 1, "rejected callbacks")
assertEqual(failedComplete, 0, "completion callback not called when unverified")

print("PASS test_fob_attack_functional_arty")
