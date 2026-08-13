-- Operation Mountain Watch - forced-landing recovery settlement coordinator.
--
-- This is the narrow CampaignState boundary between an already classified
-- forced-landing observation and strategic recovery settlement. It has no
-- MOOSE, DCS, STORAGE, scheduler or filesystem dependency.

local RecoverySettlementCoordinator = {}
RecoverySettlementCoordinator.__index = RecoverySettlementCoordinator

local TAG = "[OMW][RecoverySettlementCoordinator]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function finiteNonNegative(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

function RecoverySettlementCoordinator.New(policy)
  requireTable(policy, "policy")
  if type(policy.BeginRecovery) ~= "function"
      or type(policy.CompleteRecovery) ~= "function"
      or type(policy.CompleteRepair) ~= "function"
      or type(policy.Classification) ~= "table" then
    fail("policy lacks required recovery API")
  end

  return setmetatable({
    policy = policy,
  }, RecoverySettlementCoordinator)
end

function RecoverySettlementCoordinator:Begin(store, observation, spec)
  requireTable(store, "store")
  requireTable(observation, "observation")
  requireTable(spec, "spec")

  if type(store.BeginAircraftRecovery) ~= "function" then
    fail("store lacks BeginAircraftRecovery()")
  end
  if observation.classification ~= self.policy.Classification.RECOVERABLE_FORCED_LANDING then
    fail("observation is not RECOVERABLE_FORCED_LANDING")
  end
  if observation.recoveryCapable ~= true then
    fail("observation recovery node is not recovery-capable")
  end

  local entityId = requireNonEmptyString(spec.entityId, "entityId")
  local recoveryNodeId = requireNonEmptyString(
    spec.recoveryNodeId or observation.nearestRecoveryNodeId,
    "recoveryNodeId"
  )
  if observation.nearestRecoveryNodeId ~= nil
      and recoveryNodeId ~= observation.nearestRecoveryNodeId then
    fail("recoveryNodeId does not match observation")
  end
  if not finiteNonNegative(spec.startedAt) then
    fail("startedAt must be non-negative finite")
  end

  local policyState = self.policy.BeginRecovery(spec.startedAt)
  local recoveredState = self.policy.CompleteRecovery(policyState, policyState.recoveryCompletesAt)

  return store:BeginAircraftRecovery({
    entityId = entityId,
    recoveryNodeId = recoveryNodeId,
    recoveryStartedAt = policyState.recoveryStartedAt,
    recoveryCompleteAt = policyState.recoveryCompletesAt,
    repairCompleteAt = recoveredState.repairCompletesAt,
  })
end

function RecoverySettlementCoordinator:CompleteRecovery(store, entityId, now, credits)
  requireTable(store, "store")
  entityId = requireNonEmptyString(entityId, "entityId")
  if type(store.CompleteAircraftRecovery) ~= "function"
      or type(store.CreditResourceOnce) ~= "function" then
    fail("store lacks recovery settlement API")
  end
  if not finiteNonNegative(now) then
    fail("now must be non-negative finite")
  end
  requireTable(credits, "credits")

  local recovery, recoveryChanged = store:CompleteAircraftRecovery(entityId, now)
  local credited = {}
  local createdCount = 0

  for index, credit in ipairs(credits) do
    requireTable(credit, "credits[" .. tostring(index) .. "]")
    local result, created = store:CreditResourceOnce({
      creditId = requireNonEmptyString(credit.creditId, "creditId"),
      nodeId = recovery.recoveryNodeId,
      resourceId = requireNonEmptyString(credit.resourceId, "resourceId"),
      quantity = credit.quantity,
      canonicalUnit = credit.canonicalUnit,
      reason = "FORCED_LANDING_RECOVERY_REMAINDER",
      entityId = entityId,
    })
    credited[#credited + 1] = result
    if created then
      createdCount = createdCount + 1
    end
  end

  return {
    recovery = recovery,
    recoveryChanged = recoveryChanged,
    credits = credited,
    creditsCreated = createdCount,
  }
end

function RecoverySettlementCoordinator:CompleteRepair(store, entityId, now)
  requireTable(store, "store")
  entityId = requireNonEmptyString(entityId, "entityId")
  if type(store.CompleteAircraftRepair) ~= "function" then
    fail("store lacks CompleteAircraftRepair()")
  end
  if not finiteNonNegative(now) then
    fail("now must be non-negative finite")
  end
  return store:CompleteAircraftRepair(entityId, now)
end

return RecoverySettlementCoordinator
