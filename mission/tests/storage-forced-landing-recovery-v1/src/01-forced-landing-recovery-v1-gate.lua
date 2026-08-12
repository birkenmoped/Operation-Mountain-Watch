-- Operation Mountain Watch - forced landing/recovery V1 runtime acceptance gate.
--
-- Manual DCS action: occupy CLIENT_US_SHND_AH64D_01, depart Shindand Heliport,
-- land off-field within 5 km of the heliport, then shut down an engine.
-- The harness is observation-only and performs no CampaignState/STORAGE or
-- physical DCS mutation.

local TAG = "[OMW][FORCED-LANDING-RECOVERY-V1-GATE]"
local CLIENT_GROUP_NAME = "CLIENT_US_SHND_AH64D_01"
local TRACK_INTERVAL_SECONDS = 2
local TRACK_TIMEOUT_SECONDS = 120
local RESULT_TIMEOUT_SECONDS = 900

local policy = OMWForcedLandingRecoveryPolicy
local observerModule = OMWForcedLandingObserver

if type(policy) ~= "table" then
  error(TAG .. " missing OMWForcedLandingRecoveryPolicy")
end
if type(observerModule) ~= "table" then
  error(TAG .. " missing OMWForcedLandingObserver")
end

local observer = observerModule.New(policy, {
  recoveryNodes = {
    {
      nodeId = "SHINDAND_HELIPORT",
      airbaseName = "Shindand Heliport",
      recoveryCapable = true,
    },
  },
})

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s %s expected=%s actual=%s", TAG, label, tostring(expected), tostring(actual)))
  end
end

local function runPolicyChecks()
  assertEqual(
    policy.ClassifyLanding({
      plannedLanding = true,
      expectedReturn = false,
      unexpectedLandingEvidence = false,
      recoveryCapable = true,
      distanceToRecoveryMeters = 1000,
    }),
    policy.Classification.NORMAL_PLANNED_LANDING,
    "planned landing exclusion"
  )
  env.info(TAG .. " PLANNED_EXCLUSION_PASS")

  assertEqual(
    policy.ClassifyLanding({
      plannedLanding = false,
      expectedReturn = false,
      unexpectedLandingEvidence = true,
      recoveryCapable = true,
      distanceToRecoveryMeters = 6000,
    }),
    policy.Classification.OFF_FIELD_UNRECOVERABLE,
    "outside recovery envelope"
  )
  env.info(TAG .. " UNRECOVERABLE_POLICY_PASS")

  local started = policy.BeginRecovery(1000)
  assertEqual(started.state, policy.RecoveryState.RECOVERY_IN_PROGRESS, "recovery start state")
  assertEqual(started.recoveryCompletesAt, 2800, "recovery completion time")
  assertEqual(started.resourceCreditAllowed, false, "credit before recovery")

  local recovered = policy.CompleteRecovery(started, 2800)
  assertEqual(recovered.state, policy.RecoveryState.RECOVERED_AWAITING_REPAIR, "recovered state")
  assertEqual(recovered.repairCompletesAt, 24400, "repair completion time")
  assertEqual(recovered.resourceCreditAllowed, true, "credit after recovery")
  assertEqual(recovered.aircraftAvailable, false, "aircraft lock after recovery")

  local available = policy.CompleteRepair(recovered, 24400)
  assertEqual(available.state, policy.RecoveryState.AVAILABLE, "available state")
  assertEqual(available.aircraftAvailable, true, "aircraft availability after repair")
  env.info(TAG .. " POLICY_TIMING_PASS recoverySeconds=1800 repairLockSeconds=21600")
end

runPolicyChecks()

env.info(string.format(
  "%s WAITING_FOR_CLIENT group=%s action=takeoff_then_offfield_land_within_5km_then_engine_shutdown",
  TAG,
  CLIENT_GROUP_NAME
))

local trackingStartedAt = timer.getTime()
local tracked = false
local resultStartedAt = nil

local trackScheduler
trackScheduler = SCHEDULER:New(nil, function()
  if tracked then
    if trackScheduler then
      trackScheduler:Stop()
    end
    return
  end

  local group = GROUP:FindByName(CLIENT_GROUP_NAME)
  if group and group:IsAlive() then
    observer:TrackClientGroup(group, { acceptanceCase = "SHINDAND_RECOVERABLE_CLIENT_FORCED_LANDING" })
    tracked = true
    resultStartedAt = timer.getTime()
    env.info(TAG .. " CLIENT_TRACKED group=" .. CLIENT_GROUP_NAME)
    if trackScheduler then
      trackScheduler:Stop()
    end
    return
  end

  if timer.getTime() - trackingStartedAt >= TRACK_TIMEOUT_SECONDS then
    env.error(TAG .. " RESULT status=FAIL reason=CLIENT_NOT_ACTIVE")
    if trackScheduler then
      trackScheduler:Stop()
    end
  end
end, {}, 0, TRACK_INTERVAL_SECONDS)

local resultScheduler
resultScheduler = SCHEDULER:New(nil, function()
  if not tracked then
    return
  end

  local observations = observer:GetObservations()
  if #observations > 0 then
    local observation = observations[#observations]
    local pass = observation.classification == policy.Classification.RECOVERABLE_FORCED_LANDING
      and observation.trackingMode == "CLIENT_GROUP"
      and observation.plannedLanding == false
      and observation.expectedReturn == false
      and observation.recoveryCapable == true
      and type(observation.distanceToRecoveryMeters) == "number"
      and observation.distanceToRecoveryMeters <= policy.RECOVERY_RADIUS_METERS

    if pass then
      env.info(string.format(
        "%s RECOVERABLE_RUNTIME_PASS group=%s place=%s distanceM=%.3f lowFuel=%s",
        TAG,
        tostring(observation.groupName),
        tostring(observation.placeName),
        observation.distanceToRecoveryMeters,
        tostring(observation.lowFuelSignal)
      ))
      env.info(TAG .. " RESULT status=PASS campaignStateMutation=false storageMutation=false physicalMutation=false csar=false")
    else
      env.error(string.format(
        "%s RESULT status=FAIL reason=CLASSIFICATION classification=%s mode=%s planned=%s expectedReturn=%s recoveryCapable=%s distanceM=%s",
        TAG,
        tostring(observation.classification),
        tostring(observation.trackingMode),
        tostring(observation.plannedLanding),
        tostring(observation.expectedReturn),
        tostring(observation.recoveryCapable),
        tostring(observation.distanceToRecoveryMeters)
      ))
    end

    observer:Stop()
    if resultScheduler then
      resultScheduler:Stop()
    end
    return
  end

  if resultStartedAt and timer.getTime() - resultStartedAt >= RESULT_TIMEOUT_SECONDS then
    env.error(TAG .. " RESULT status=FAIL reason=NO_CLASSIFICATION_WITHIN_TIMEOUT")
    observer:Stop()
    if resultScheduler then
      resultScheduler:Stop()
    end
  end
end, {}, 1, TRACK_INTERVAL_SECONDS)
