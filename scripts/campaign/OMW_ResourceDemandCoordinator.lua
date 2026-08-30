-- Operation Mountain Watch - CampaignState shortage candidate -> MissionDemand adapter.
--
-- ResourceDemandPolicy owns threshold evaluation. MissionDemand owns demand lifecycle.
-- This coordinator only bridges the two domain contracts and owns no resources or
-- physical MOOSE execution.

local Coordinator = {}
local TAG = "[OMW][ResourceDemandCoordinator]"
Coordinator.SchemaVersion = "OMW-RESOURCE-DEMAND-COORDINATOR-1"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function requireTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function requireNonEmptyString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end

function Coordinator.EvaluateAndCreate(spec)
  requireTable(spec, "spec")
  local policy = requireTable(spec.policy, "spec.policy")
  local missionDemand = requireTable(spec.missionDemand, "spec.missionDemand")
  local registry = requireTable(spec.registry, "spec.registry")
  local store = requireTable(spec.store, "spec.store")
  local row = requireTable(spec.row, "spec.row")
  if type(policy.Evaluate) ~= "function" then fail("policy.Evaluate() is required") end
  if type(store.GetResource) ~= "function" then fail("store.GetResource() is required") end
  if type(registry.Create) ~= "function" then fail("registry.Create() is required") end
  if type(missionDemand.Type) ~= "table" or missionDemand.Type.RESUPPLY == nil then fail("MissionDemand.Type.RESUPPLY is required") end

  local snapshot = store:GetResource(row.nodeId, row.resourceId)
  local candidate = policy.Evaluate(row, snapshot)
  if not candidate then return nil, false, "NO_SHORTAGE", nil end

  local demandId
  if spec.demandIdFactory then
    if type(spec.demandIdFactory) ~= "function" then fail("demandIdFactory must be a function") end
    demandId = spec.demandIdFactory(candidate, snapshot)
  else
    demandId = table.concat({ "RESUPPLY", candidate.destinationNodeId, candidate.destinationResourceId, tostring(snapshot.version or snapshot.quantity or snapshot.available) }, "|")
  end
  requireNonEmptyString(demandId, "demandId")

  local demand, created, reason = registry:Create({
    id = demandId,
    missionType = missionDemand.Type.RESUPPLY,
    origin = candidate.supplyParent,
    objective = "Restore " .. candidate.destinationResourceId .. " at " .. candidate.destinationNodeId .. " to target",
    target = {
      nodeId = candidate.destinationNodeId,
      resourceId = candidate.destinationResourceId,
      resourceClass = candidate.resourceClass,
      requestedQuantity = candidate.requestedQuantity,
      targetQuantity = candidate.target,
    },
    priority = spec.priority or (candidate.level == "CRITICAL" and 10 or 20),
    playerCapable = spec.playerCapable == true,
    aiCapable = spec.aiCapable ~= false,
    reservationState = "UNRESERVED",
    successCriteria = { destinationQuantity = candidate.target },
    failureConsequences = { resourceTransfer = "NOT_RESERVED_OR_FAILED_BY_EXECUTOR" },
    createdReason = candidate.level,
    dedupeKey = candidate.dedupeKey,
  })
  return demand, created, reason, candidate
end

return Coordinator
