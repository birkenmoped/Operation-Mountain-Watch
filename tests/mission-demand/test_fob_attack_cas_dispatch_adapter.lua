local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local DispatchAdapter = dofile("scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local function makeDemand(registry, id, missionType, aiCapable)
  return registry:Create({
    id=id, missionType=missionType, origin="BLUE_GROUND_COP_FORTRESS", objective="FOB_ATTACK_SUPPORT",
    target={installationId="BLUE_GROUND_COP_FORTRESS"}, priority=90, playerCapable=true,
    aiCapable=aiCapable, dedupeKey=missionType .. "|" .. id,
  })
end

local registry = MissionDemand.New()
local targetZone = { name="SECURITY" }
local added = {}
local airwing = {
  AddMission=function(self, mission) added[#added+1]=mission return self end,
  I=function() end,
}

local factoryCalls, cancelCalls, engageCalls = 0, 0, 0
local adapter = DispatchAdapter.New({
  missionDemand=MissionDemand, registry=registry, airwing=airwing,
  assigneeId="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV", casAltitudeFt=10000, casSpeedKts=120,
  engageDetectedRangeNm=5, engageDetectedTargetTypes={"Ground Units"}, requireExecutionEvidence=true,
  auftragFactory=function(zone, altitude, speed)
    factoryCalls=factoryCalls+1
    assertEqual(zone, targetZone, "factory target zone")
    assertEqual(altitude, 10000, "factory altitude")
    assertEqual(speed, 120, "factory speed")
    return {
      GetName=function() return "TEST_CAS" end,
      Cancel=function() cancelCalls=cancelCalls+1 end,
      SetEngageDetected=function(self, rangeNm, targetTypes, engageZone, noEngageZone)
        engageCalls=engageCalls+1
        assertEqual(rangeNm, 5, "engage range")
        assertEqual(targetTypes[1], "Ground Units", "engage target type")
        assertEqual(engageZone, targetZone, "engage zone")
        assertEqual(noEngageZone, nil, "no engage zone")
        return self
      end,
    }
  end,
})

local demand = makeDemand(registry, "MD-CAS-1", MissionDemand.Type.CAS_IMMEDIATE, true)
local mission, dispatched, reason = adapter:Dispatch(demand, targetZone)
assertTrue(dispatched, "first dispatch")
assertEqual(reason, nil, "first dispatch reason")
assertEqual(factoryCalls, 1, "factory calls")
assertEqual(engageCalls, 1, "SetEngageDetected calls")
assertEqual(#added, 1, "airwing missions")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "assigned status")
assertEqual(adapter:GetMission(demand.id), mission, "mission correlation")

local duplicateMission, duplicateDispatched, duplicateReason = adapter:Dispatch(registry:Get(demand.id), targetZone)
assertEqual(duplicateMission, mission, "duplicate mission")
assertEqual(duplicateDispatched, false, "duplicate dispatched")
assertEqual(duplicateReason, "ALREADY_DISPATCHED", "duplicate reason")

mission:OnAfterExecuting("STARTED", "Executing", "EXECUTING")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "active status")

mission:OnAfterSuccess("EXECUTING", "Success", "SUCCESS")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "AUFTRAG success alone is not execution evidence")

local evidence = { event="SHOT", weaponType="M230" }
local evidenceMission, evidenceConfirmed, evidenceReason = adapter:ConfirmExecutionEvidence(demand.id, evidence)
assertEqual(evidenceMission, mission, "evidence mission")
assertTrue(evidenceConfirmed, "execution evidence confirmed")
assertEqual(evidenceReason, nil, "execution evidence reason")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "shot evidence closes demand")
assertEqual(registry:Get(demand.id).result.executor, "AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV", "success executor")
assertEqual(registry:Get(demand.id).result.executionEvidence.event, "SHOT", "success records execution event")
assertEqual(registry:Get(demand.id).result.executionEvidence.weaponType, "M230", "success records weapon type")

local _, evidenceAgain, evidenceAgainReason = adapter:ConfirmExecutionEvidence(demand.id, {event="SHOT"})
assertEqual(evidenceAgain, false, "duplicate evidence not accepted")
assertEqual(evidenceAgainReason, "EVIDENCE_ALREADY_CONFIRMED", "duplicate evidence reason")

local registryClosure = MissionDemand.New()
local closureDemand = makeDemand(registryClosure, "MD-CAS-CLOSURE", MissionDemand.Type.CAS_IMMEDIATE, true)
local closureAdapter = DispatchAdapter.New({
  missionDemand=MissionDemand, registry=registryClosure, airwing=airwing, assigneeId="AIRWING:TEST",
  auftragFactory=function() return { GetName=function() return "TEST_CLOSURE" end, Cancel=function() cancelCalls=cancelCalls+1 end } end,
})
local closureMission = closureAdapter:Dispatch(closureDemand, targetZone)
closureMission:OnAfterExecuting("STARTED", "Executing", "EXECUTING")
local _, closureRequested, closureReason = closureAdapter:RequestMissionClosure(closureDemand.id, "OPSZONE_DEFEATED_RED")
assertTrue(closureRequested, "closure requested")
assertEqual(closureReason, nil, "closure reason")
assertEqual(registryClosure:Get(closureDemand.id).status, MissionDemand.Status.ACTIVE, "closure request does not prematurely succeed demand")
closureMission:OnAfterSuccess("CANCELLED", "Success", "SUCCESS")
assertEqual(registryClosure:Get(closureDemand.id).status, MissionDemand.Status.SUCCESS, "legacy success path remains supported")
assertEqual(registryClosure:Get(closureDemand.id).result.closureRequested, true, "success records threat-clear closure")

local unsupported = makeDemand(registry, "MD-RESUPPLY-1", MissionDemand.Type.RESUPPLY, true)
local _, unsupportedDispatched, unsupportedReason = adapter:Dispatch(unsupported, targetZone)
assertEqual(unsupportedDispatched, false, "unsupported dispatched")
assertEqual(unsupportedReason, "UNSUPPORTED_MISSION_TYPE", "unsupported reason")

local noAi = makeDemand(registry, "MD-CAS-NO-AI", MissionDemand.Type.CAS_IMMEDIATE, false)
local _, noAiDispatched, noAiReason = adapter:Dispatch(noAi, targetZone)
assertEqual(noAiDispatched, false, "no-ai dispatched")
assertEqual(noAiReason, "DEMAND_NOT_AI_CAPABLE", "no-ai reason")

local registryFailed = MissionDemand.New()
local failedDemand = makeDemand(registryFailed, "MD-CAS-FAILED", MissionDemand.Type.CAS_IMMEDIATE, true)
local failedAdapter = DispatchAdapter.New({
  missionDemand=MissionDemand, registry=registryFailed, airwing=airwing, assigneeId="AIRWING:TEST",
  auftragFactory=function() return { GetName=function() return "TEST_FAILED" end, Cancel=function() end } end,
})
local failedMission = failedAdapter:Dispatch(failedDemand, targetZone)
failedMission:OnAfterFailed("STARTED", "Failed", "FAILED")
assertEqual(registryFailed:Get(failedDemand.id).status, MissionDemand.Status.FAILED, "failed status")
assertEqual(registryFailed:Get(failedDemand.id).failureReason, "MOOSE_AUFTRAG_FAILED", "failed reason")

print("PASS test_fob_attack_cas_dispatch_adapter")
