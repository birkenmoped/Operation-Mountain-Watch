-- Operation Mountain Watch - forced landing and recovery policy foundation.
--
-- Pure Campaign-domain policy. No MOOSE/DCS dependency and no physical mutation.
-- Runtime adapters must provide observed context and remain responsible for
-- correlating MOOSE lifecycle signals with CampaignState.

local ForcedLandingRecoveryPolicy = {}

ForcedLandingRecoveryPolicy.Classification = {
  NORMAL_PLANNED_LANDING = "NORMAL_PLANNED_LANDING",
  NORMAL_EXPECTED_RETURN = "NORMAL_EXPECTED_RETURN",
  INDETERMINATE = "INDETERMINATE",
  RECOVERABLE_FORCED_LANDING = "RECOVERABLE_FORCED_LANDING",
  OFF_FIELD_UNRECOVERABLE = "OFF_FIELD_UNRECOVERABLE",
}

ForcedLandingRecoveryPolicy.RecoveryState = {
  RECOVERY_IN_PROGRESS = "RECOVERY_IN_PROGRESS",
  RECOVERED_AWAITING_REPAIR = "RECOVERED_AWAITING_REPAIR",
  AVAILABLE = "AVAILABLE",
}

ForcedLandingRecoveryPolicy.RECOVERY_RADIUS_METERS = 5000
ForcedLandingRecoveryPolicy.RECOVERY_DURATION_SECONDS = 30 * 60
ForcedLandingRecoveryPolicy.REPAIR_LOCK_SECONDS = 6 * 60 * 60
ForcedLandingRecoveryPolicy.LOW_FUEL_SIGNAL_FRACTION = 0.05

local function fail(message)
  error("[OMW][ForcedLandingRecoveryPolicy] " .. tostring(message), 2)
end

local function finiteNonNegative(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

local function requireBooleanOrNil(value, label)
  if value ~= nil and type(value) ~= "boolean" then
    fail(label .. " must be boolean or nil")
  end
end

function ForcedLandingRecoveryPolicy.ClassifyLanding(context)
  if type(context) ~= "table" then
    fail("context must be a table")
  end

  requireBooleanOrNil(context.plannedLanding, "plannedLanding")
  requireBooleanOrNil(context.expectedReturn, "expectedReturn")
  requireBooleanOrNil(context.unexpectedLandingEvidence, "unexpectedLandingEvidence")
  requireBooleanOrNil(context.recoveryCapable, "recoveryCapable")

  if context.plannedLanding == true then
    return ForcedLandingRecoveryPolicy.Classification.NORMAL_PLANNED_LANDING
  end

  if context.expectedReturn == true then
    return ForcedLandingRecoveryPolicy.Classification.NORMAL_EXPECTED_RETURN
  end

  -- Low fuel is deliberately not used as a sole trigger. The owner decision
  -- defines <=5 percent as supporting evidence only.
  if context.unexpectedLandingEvidence ~= true then
    return ForcedLandingRecoveryPolicy.Classification.INDETERMINATE
  end

  if not finiteNonNegative(context.distanceToRecoveryMeters) then
    fail("distanceToRecoveryMeters must be non-negative finite for unexpected landing")
  end

  if context.recoveryCapable == true
      and context.distanceToRecoveryMeters <= ForcedLandingRecoveryPolicy.RECOVERY_RADIUS_METERS then
    return ForcedLandingRecoveryPolicy.Classification.RECOVERABLE_FORCED_LANDING
  end

  return ForcedLandingRecoveryPolicy.Classification.OFF_FIELD_UNRECOVERABLE
end

function ForcedLandingRecoveryPolicy.IsLowFuelSignal(fuelFraction)
  if not finiteNonNegative(fuelFraction) then
    return false
  end
  return fuelFraction <= ForcedLandingRecoveryPolicy.LOW_FUEL_SIGNAL_FRACTION
end

function ForcedLandingRecoveryPolicy.BeginRecovery(startTimeSeconds)
  if not finiteNonNegative(startTimeSeconds) then
    fail("startTimeSeconds must be non-negative finite")
  end

  return {
    state = ForcedLandingRecoveryPolicy.RecoveryState.RECOVERY_IN_PROGRESS,
    recoveryStartedAt = startTimeSeconds,
    recoveryCompletesAt = startTimeSeconds + ForcedLandingRecoveryPolicy.RECOVERY_DURATION_SECONDS,
    resourceCreditAllowed = false,
    aircraftAvailable = false,
  }
end

function ForcedLandingRecoveryPolicy.CompleteRecovery(recovery, nowSeconds)
  if type(recovery) ~= "table" or recovery.state ~= ForcedLandingRecoveryPolicy.RecoveryState.RECOVERY_IN_PROGRESS then
    fail("recovery must be RECOVERY_IN_PROGRESS")
  end
  if not finiteNonNegative(nowSeconds) then
    fail("nowSeconds must be non-negative finite")
  end
  if nowSeconds < recovery.recoveryCompletesAt then
    fail("recovery duration has not elapsed")
  end

  return {
    state = ForcedLandingRecoveryPolicy.RecoveryState.RECOVERED_AWAITING_REPAIR,
    recoveredAt = nowSeconds,
    repairCompletesAt = nowSeconds + ForcedLandingRecoveryPolicy.REPAIR_LOCK_SECONDS,
    resourceCreditAllowed = true,
    aircraftAvailable = false,
  }
end

function ForcedLandingRecoveryPolicy.CompleteRepair(recovery, nowSeconds)
  if type(recovery) ~= "table" or recovery.state ~= ForcedLandingRecoveryPolicy.RecoveryState.RECOVERED_AWAITING_REPAIR then
    fail("recovery must be RECOVERED_AWAITING_REPAIR")
  end
  if not finiteNonNegative(nowSeconds) then
    fail("nowSeconds must be non-negative finite")
  end
  if nowSeconds < recovery.repairCompletesAt then
    fail("repair lock has not elapsed")
  end

  return {
    state = ForcedLandingRecoveryPolicy.RecoveryState.AVAILABLE,
    availableAt = nowSeconds,
    resourceCreditAllowed = true,
    aircraftAvailable = true,
  }
end

return ForcedLandingRecoveryPolicy
