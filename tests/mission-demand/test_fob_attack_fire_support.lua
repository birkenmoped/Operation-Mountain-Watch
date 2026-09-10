local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Policy = dofile("scripts/campaign/OMW_FobAttackFireSupportDemandPolicy.lua")
local DispatchAdapter = dofile("scripts/ground/OMW_FobAttackFireSupportDispatchAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

assertEqual(MissionDemand.Type.FIRE_SUPPORT_IMMEDIATE, "FIRE_SUPPORT_IMMEDIATE", "fire support type")

local registry = MissionDemand.New()
local incident = {
  incidentId = "FOB-THREAT|BLUE_GROUND_COP_HONAKER|1",
  installationId = "BLUE_GROUND_COP_HONAKER",
  priority = 90,
}
local target = {
  targetKind = "DETECTED_RED_GROUND_GROUP",
  targetName = "RED_ATTACKER_1",
  position = { x = 135000, y = 1200, z = 439000 },
}

local demand, created, reason = Policy.CreateDemand(MissionDemand, registry, incident, target)
assertTrue(created, "fire-support demand created")
assertEqual(reason, nil, "fire-support create reason")
assertEqual(demand.missionType, MissionDemand.Type.FIRE_SUPPORT_IMMEDIATE, "fire-support mission type")
assertEqual(demand.origin, "BLUE_GROUND_COP_HONAKER", "fire-support requester")
assertEqual(demand.target.fireSupportTarget.targetName, "RED_ATTACKER_1", "fire-support target")
assertEqual(demand.dedupeKey, "FIRE_SUPPORT_IMMEDIATE|FOB_ATTACK|BLUE_GROUND_COP_HONAKER", "fire-support dedupe")

local duplicate, duplicateCreated, duplicateReason = Policy.CreateDemand(MissionDemand, registry, {
  incidentId = "FOB-THREAT|BLUE_GROUND_COP_HONAKER|2",
  installationId = "BLUE_GROUND_COP_HONAKER",
  priority = 90,
}, target)
assertEqual(duplicate.id, demand.id, "active duplicate demand")
assertEqual(duplicateCreated, false, "active duplicate not created")
assertEqual(duplicateReason, "active_duplicate", "active duplicate reason")

local added, factoryCalls = {}, 0
local armyGroup = {
  AddMission = function(self, mission) added[#added + 1] = mission return self end,
  I = function() end,
}
local targetCoordinate = { name = "TARGET_COORD" }
local adapter = DispatchAdapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  armyGroup = armyGroup,
  assigneeId = "ARMYGROUP:TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",
  shots = 4,
  radiusM = 50,
  isTargetInRange = function(group, coordinate)
    assertEqual(group, armyGroup, "range army group")
    assertEqual(coordinate, targetCoordinate, "range target coordinate")
    return true
  end,
  auftragFactory = function(coordinate, shots, radiusM)
    factoryCalls = factoryCalls + 1
    assertEqual(coordinate, targetCoordinate, "factory target coordinate")
    assertEqual(shots, 4, "factory shots")
    assertEqual(radiusM, 50, "factory radius")
    return { GetName = function() return "TEST_ARTY" end }
  end,
})

local mission, dispatched, dispatchReason = adapter:Dispatch(demand, targetCoordinate)
assertTrue(dispatched, "fire-support dispatched")
assertEqual(dispatchReason, nil, "fire-support dispatch reason")
assertEqual(factoryCalls, 1, "ARTY factory calls")
assertEqual(#added, 1, "ARMYGROUP missions")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "fire-support assigned")
assertEqual(adapter:GetMission(demand.id), mission, "fire-support mission correlation")

local duplicateMission, duplicateDispatched, duplicateDispatchReason = adapter:Dispatch(registry:Get(demand.id), targetCoordinate)
assertEqual(duplicateMission, mission, "duplicate fire-support mission")
assertEqual(duplicateDispatched, false, "duplicate fire-support dispatch")
assertEqual(duplicateDispatchReason, "ALREADY_DISPATCHED", "duplicate fire-support reason")

mission:OnAfterExecuting("STARTED", "Executing", "EXECUTING")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "fire-support active")
mission:OnAfterSuccess("EXECUTING", "Success", "SUCCESS")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "fire-support success")
assertEqual(registry:Get(demand.id).result.executor, "ARMYGROUP:TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2", "fire-support executor")
assertEqual(registry:Get(demand.id).result.fireMissionExecuted, true, "fire-support executed result")

local registryOutOfRange = MissionDemand.New()
local outDemand = Policy.CreateDemand(MissionDemand, registryOutOfRange, {
  incidentId = "FOB-THREAT|BLUE_GROUND_COP_HONAKER|3",
  installationId = "BLUE_GROUND_COP_HONAKER",
  priority = 90,
}, target)
local outAdapter = DispatchAdapter.New({
  missionDemand = MissionDemand,
  registry = registryOutOfRange,
  armyGroup = armyGroup,
  assigneeId = "ARMYGROUP:WRIGHT",
  isTargetInRange = function() return false end,
  auftragFactory = function() error("out-of-range mission must not be created") end,
})
local _, outDispatched, outReason = outAdapter:Dispatch(outDemand, targetCoordinate)
assertEqual(outDispatched, false, "out-of-range dispatch")
assertEqual(outReason, "TARGET_OUT_OF_RANGE", "out-of-range reason")
assertEqual(registryOutOfRange:Get(outDemand.id).status, MissionDemand.Status.OPEN, "out-of-range demand remains open")

local registryFailed = MissionDemand.New()
local failedDemand = Policy.CreateDemand(MissionDemand, registryFailed, {
  incidentId = "FOB-THREAT|BLUE_GROUND_COP_HONAKER|4",
  installationId = "BLUE_GROUND_COP_HONAKER",
  priority = 90,
}, target)
local failedAdapter = DispatchAdapter.New({
  missionDemand = MissionDemand,
  registry = registryFailed,
  armyGroup = armyGroup,
  assigneeId = "ARMYGROUP:WRIGHT",
  auftragFactory = function() return { GetName = function() return "TEST_ARTY_FAILED" end } end,
})
local failedMission = failedAdapter:Dispatch(failedDemand, targetCoordinate)
failedMission:OnAfterFailed("STARTED", "Failed", "FAILED")
assertEqual(registryFailed:Get(failedDemand.id).status, MissionDemand.Status.FAILED, "fire-support failed")
assertEqual(registryFailed:Get(failedDemand.id).failureReason, "MOOSE_AUFTRAG_FAILED", "fire-support failure reason")

print("PASS test_fob_attack_fire_support")
