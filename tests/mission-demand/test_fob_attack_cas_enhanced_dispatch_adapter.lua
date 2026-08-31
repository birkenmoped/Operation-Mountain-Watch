local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local DispatchAdapter = dofile("scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local previousAuftrag = AUFTRAG
local calls = {}
AUFTRAG = {
  NewCASENHANCED=function(self, zone, altitude, speed, rangeNm, noEngageZoneSet, targetTypes)
    calls[#calls+1]={zone=zone,altitude=altitude,speed=speed,rangeNm=rangeNm,noEngageZoneSet=noEngageZoneSet,targetTypes=targetTypes}
    return {
      GetName=function() return "TEST_CASENHANCED" end,
      Cancel=function() end,
    }
  end,
}

local registry = MissionDemand.New()
local airwing = { AddMission=function(self, mission) self.mission=mission return self end, I=function() end }
local tacticalZone = { name="HONAKER_TACTICAL" }
local demand = registry:Create({
  id="MD-CAS-ENHANCED-1", missionType=MissionDemand.Type.CAS_IMMEDIATE, origin="BLUE_GROUND_COP_HONAKER",
  objective="FOB_ATTACK_SUPPORT", target={installationId="BLUE_GROUND_COP_HONAKER"}, priority=90,
  playerCapable=true, aiCapable=true, dedupeKey="CASENHANCED|HONAKER",
})

local adapter = DispatchAdapter.New({
  missionDemand=MissionDemand,
  registry=registry,
  airwing=airwing,
  assigneeId="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
  missionMode=DispatchAdapter.MissionMode.CASENHANCED,
  casAltitudeFt=7200,
  casSpeedKts=120,
  engageDetectedRangeNm=5,
  engageDetectedTargetTypes={"Ground Units"},
  requireExecutionEvidence=true,
})

local mission, dispatched, reason = adapter:Dispatch(demand, tacticalZone)
assertTrue(dispatched, "CASENHANCED dispatch")
assertEqual(reason, nil, "CASENHANCED dispatch reason")
assertEqual(#calls, 1, "NewCASENHANCED call count")
assertEqual(calls[1].zone, tacticalZone, "CASENHANCED tactical zone")
assertEqual(calls[1].altitude, 7200, "CASENHANCED ASL altitude")
assertEqual(calls[1].speed, 120, "CASENHANCED speed")
assertEqual(calls[1].rangeNm, 5, "CASENHANCED detected range")
assertEqual(calls[1].noEngageZoneSet, nil, "CASENHANCED no-engage set")
assertEqual(calls[1].targetTypes[1], "Ground Units", "CASENHANCED target type")
assertEqual(airwing.mission, mission, "CASENHANCED added to AIRWING")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "CASENHANCED assigned status")

mission:OnAfterExecuting("STARTED","Executing","EXECUTING")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "CASENHANCED active")
local _, recorded, evidenceReason = adapter:ConfirmExecutionEvidence(demand.id,{event="SHOT",weaponType="HYDRA_70_M151"})
assertTrue(recorded, "CASENHANCED execution evidence")
assertEqual(evidenceReason,"EVIDENCE_RECORDED_PENDING_MISSION_COMPLETION","CASENHANCED evidence non-terminal")
assertEqual(registry:Get(demand.id).status,MissionDemand.Status.ACTIVE,"CASENHANCED shot remains active")
mission:OnAfterSuccess("EXECUTING","Success","SUCCESS")
assertEqual(registry:Get(demand.id).status,MissionDemand.Status.SUCCESS,"CASENHANCED success after evidence")
assertEqual(registry:Get(demand.id).result.missionMode,DispatchAdapter.MissionMode.CASENHANCED,"CASENHANCED result mode")

AUFTRAG = previousAuftrag
print("PASS test_fob_attack_cas_enhanced_dispatch_adapter")
