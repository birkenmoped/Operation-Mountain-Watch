local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local DispatchAdapter = dofile("scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua")
local Closure = dofile("scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label)
  if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end
end

local function makeDemand(registry, id)
  return registry:Create({
    id=id,
    missionType=MissionDemand.Type.CAS_IMMEDIATE,
    origin="BLUE_GROUND_COP_HONAKER",
    objective="FOB_ATTACK_SUPPORT",
    target={installationId="BLUE_GROUND_COP_HONAKER"},
    priority=90,
    playerCapable=true,
    aiCapable=true,
    dedupeKey="CAS|" .. id,
  })
end

local function makeAdapter(registry, requireEvidence, cancelCounter)
  local airwing = { AddMission=function(self) return self end, I=function() end }
  return DispatchAdapter.New({
    missionDemand=MissionDemand,
    registry=registry,
    airwing=airwing,
    assigneeId="AIRWING:TEST",
    requireExecutionEvidence=requireEvidence,
    auftragFactory=function()
      return {
        GetName=function() return "TEST_PATROLZONE" end,
        Cancel=function() cancelCounter.count=cancelCounter.count+1 end,
      }
    end,
  })
end

-- Stage-3 contract: tactical completion is a release by the supported element after its
-- own local tactical assessment. It must release the PATROLZONE mission even when
-- EVENTS.Shot evidence was not observed. Shot evidence remains an acceptance result gate,
-- not an operational RTB gate and not a source of C2 omniscience.
do
  local registry = MissionDemand.New()
  local counter = { count=0 }
  local adapter = makeAdapter(registry, false, counter)
  local demand = makeDemand(registry, "MD-CAS-TACTICAL-CLOSE")
  local mission, dispatched = adapter:Dispatch(demand, { name="TACTICAL_ZONE" })
  assertTrue(dispatched, "dispatch")
  mission:OnAfterExecuting("STARTED", "Executing", "EXECUTING")

  local closedMission, closed, reason = Closure.Complete({
    adapter=adapter,
    registry=registry,
    missionDemand=MissionDemand,
    demandId=demand.id,
    tacticalComplete=true,
    executionEvidenceConfirmed=false,
    reason="KNOWN_ATTACKERS_NEUTRALIZED",
    executor="AIRWING:TEST",
  })

  assertEqual(closedMission, mission, "closed mission")
  assertTrue(closed, "closure without shot evidence")
  assertEqual(reason, "CLOSED", "closure reason")
  assertEqual(counter.count, 1, "mission cancel count")
  assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "demand status")
  assertEqual(registry:Get(demand.id).result.releaseAuthority, "SUPPORTED_ELEMENT", "release authority")
  assertEqual(registry:Get(demand.id).result.releaseSource, "BLUE_GROUND_COP_HONAKER", "release source from demand origin")
  assertEqual(registry:Get(demand.id).result.executionEvidenceConfirmed, false, "recorded evidence state")
end

-- Evidence-gated adapters still retain the stricter behavior when explicitly configured.
do
  local registry = MissionDemand.New()
  local counter = { count=0 }
  local adapter = makeAdapter(registry, true, counter)
  local demand = makeDemand(registry, "MD-CAS-EVIDENCE-GATED")
  local mission, dispatched = adapter:Dispatch(demand, { name="TACTICAL_ZONE" })
  assertTrue(dispatched, "gated dispatch")
  mission:OnAfterExecuting("STARTED", "Executing", "EXECUTING")

  local _, closed, reason = Closure.Complete({
    adapter=adapter,
    registry=registry,
    missionDemand=MissionDemand,
    demandId=demand.id,
    tacticalComplete=true,
    executionEvidenceConfirmed=false,
  })

  assertEqual(closed, false, "gated closure")
  assertEqual(reason, "EXECUTION_EVIDENCE_REQUIRED", "gated reason")
  assertEqual(counter.count, 0, "gated cancel count")
  assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "gated demand remains active")
end

print("PASS test_fob_attack_cas_patrol_closure")


-- Shared production path: generic closure request can reuse the same supported-element
-- contract without depending on the legacy MissionDemand registry adapter.
do
  local called = { count=0, reason=nil }
  local mission = { name="GENERIC_CAS" }
  local returned, requested, reason = Closure.Request({
    demandId="MD-CAS-GENERIC-REQUEST",
    tacticalComplete=true,
    executionEvidenceConfirmed=true,
    reason="SUPPORTED_ELEMENT_RELEASE_NO_CONTACT",
    requestClosure=function(demandId, closeReason)
      assertEqual(demandId, "MD-CAS-GENERIC-REQUEST", "generic demandId")
      called.count=called.count+1
      called.reason=closeReason
      return mission, true, nil
    end,
  })
  assertEqual(returned, mission, "generic closure mission")
  assertTrue(requested, "generic closure requested")
  assertEqual(reason, nil, "generic closure reason")
  assertEqual(called.count, 1, "generic closure callback count")
  assertEqual(called.reason, "SUPPORTED_ELEMENT_RELEASE_NO_CONTACT", "generic closure callback reason")
end
