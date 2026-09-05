-- Operation Mountain Watch - PATROLZONE CAS completion adapter.
--
-- AUFTRAG:PATROLZONE is a readiness/loiter mission and is not expected to end merely
-- because the current attack incident has no living participants. OMW therefore closes
-- the MOOSE mission explicitly when tactical completion is authoritative. For FOB/COP
-- attack support, tacticalComplete means that the supported element has released its
-- current CAS requirement after its own local tactical assessment. It is not an
-- omniscient C2 decision and it is not inferred by the CAS flight merely because the
-- flight currently sees no target. Weapon-use evidence remains mandatory only for
-- adapters configured to require it.

local Closure = {}

local TAG = "[OMW][FobAttackCasPatrolClosure]"
Closure.SchemaVersion = "OMW-FOB-ATTACK-CAS-PATROL-CLOSURE-2"
Closure.ReleaseAuthority = "SUPPORTED_ELEMENT"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

function Closure.Complete(spec)
  requireTable(spec, "spec")
  local adapter = requireTable(spec.adapter, "spec.adapter")
  local registry = requireTable(spec.registry, "spec.registry")
  local missionDemand = requireTable(spec.missionDemand, "spec.missionDemand")
  if type(spec.demandId) ~= "string" or spec.demandId == "" then fail("spec.demandId is required") end
  if spec.tacticalComplete ~= true then return nil, false, "TACTICAL_COMPLETION_REQUIRED" end
  if adapter.requireExecutionEvidence == true and spec.executionEvidenceConfirmed ~= true then
    return nil, false, "EXECUTION_EVIDENCE_REQUIRED"
  end
  if type(adapter.RequestMissionClosure) ~= "function" then fail("adapter.RequestMissionClosure() is required") end
  if type(registry.Get) ~= "function" or type(registry.Activate) ~= "function" or type(registry.Succeed) ~= "function" then
    fail("MissionDemand registry Get/Activate/Succeed are required")
  end

  local mission, requested, reason = adapter:RequestMissionClosure(spec.demandId, spec.reason or "TACTICAL_COMPLETION_CONFIRMED")
  if requested ~= true then return mission, false, reason end

  local demand = registry:Get(spec.demandId)
  if demand and demand.status == missionDemand.Status.AI_ASSIGNED then
    registry:Activate(spec.demandId)
    demand = registry:Get(spec.demandId)
  end
  if not demand or demand.status ~= missionDemand.Status.ACTIVE then
    return mission, false, "DEMAND_NOT_ACTIVE_AFTER_MISSION_CLOSURE"
  end

  registry:Succeed(spec.demandId, {
    executor = spec.executor,
    missionMode = "PATROLZONE_ENGAGE",
    closureReason = spec.reason or "TACTICAL_COMPLETION_CONFIRMED",
    tacticalComplete = true,
    releaseAuthority = Closure.ReleaseAuthority,
    releaseSource = spec.releaseSource or "REQUESTING_INSTALLATION",
    executionEvidenceConfirmed = spec.executionEvidenceConfirmed == true,
  })
  return mission, true, "CLOSED"
end

return Closure
