-- Operation Mountain Watch - final Warehouse/resource acceptance gate.
--
-- This gate does not repeat aircraft materialization, rearm/refuel, return,
-- physical loss or the already accepted forced-landing flight. It combines the
-- accepted observation semantics with the final CampaignState settlement and
-- read-only STORAGE reconciliation boundary.

local TEST_ID = "WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE-1"
local TAG = "[OMW-TEST][" .. TEST_ID .. "]"
local START_DELAY_SECONDS = 10
local FUEL_TOLERANCE_KG = 0.5

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function expect(condition, message)
  if not condition then
    fail(message)
  end
end

local function findComparison(comparison, resourceId)
  for _, entry in ipairs(comparison.entries or {}) do
    if entry.resourceId == resourceId then
      return entry
    end
  end
  return nil
end

local function run()
  log("START inheritedPhysicalEvidence=true storageMutation=false filesystemIo=false")

  local manifest = OMWAirOpsResourceManifest
  local CampaignState = OMWCampaignState
  local policy = OMWForcedLandingRecoveryPolicy
  local storageObserver = OMWStorageResourceObserver.New(manifest)
  local coordinator = OMWRecoverySettlementCoordinator.New(policy)

  local observed = storageObserver:ReadNode("SHINDAND_HELIPORT", "Shindand Heliport")
  local jp8 = observed.resources[manifest.ResourceId.JP8]
  local avgas = observed.resources[manifest.ResourceId.AVGAS]
  expect(jp8 ~= nil and avgas ~= nil, "Shindand complete fuel observations missing")

  local store = CampaignState.New({
    schemaVersion = TEST_ID,
    nodes = {
      {
        nodeId = "SHINDAND_HELIPORT",
        airbaseName = "Shindand Heliport",
        resources = {
          [manifest.ResourceId.JP8] = { quantity = jp8.quantity, unit = jp8.canonicalUnit },
          [manifest.ResourceId.AVGAS] = { quantity = avgas.quantity, unit = avgas.canonicalUnit },
        },
      },
    },
  })

  local tolerances = {
    [manifest.Unit.KG] = FUEL_TOLERANCE_KG,
  }

  local baseline = storageObserver:CompareNode(store, "SHINDAND_HELIPORT", "Shindand Heliport", tolerances)
  expect(baseline.driftCount == 0 and baseline.matchCount == 2, "baseline CampaignState/STORAGE comparison failed")
  log(string.format("BASELINE_PASS jp8Kg=%.3f avgasKg=%.3f", jp8.quantity, avgas.quantity))

  -- Replay only the already accepted classification result. This is not a new
  -- claim about a physical landing or a new distance measurement.
  local acceptedObservation = {
    classification = policy.Classification.RECOVERABLE_FORCED_LANDING,
    recoveryCapable = true,
    nearestRecoveryNodeId = "SHINDAND_HELIPORT",
    distanceToRecoveryMeters = 4782.4415407502,
  }

  local recovery, recoveryCreated = coordinator:Begin(store, acceptedObservation, {
    entityId = "ACCEPTED-AH64D-RECOVERY-001",
    startedAt = 1000,
  })
  expect(recoveryCreated == true, "recovery was not created")
  expect(recovery.status == CampaignState.AircraftRecoveryStatus.RECOVERY_IN_PROGRESS, "unexpected initial recovery state")
  expect(recovery.recoveryCompleteAt == 2800, "unexpected recovery completion time")
  expect(recovery.repairCompleteAt == 24400, "unexpected repair completion time")
  log("RECOVERY_BEGIN_PASS recoveryCompleteAt=2800 repairCompleteAt=24400")

  -- 425 kg is a deterministic integration fixture quantity, not a claim about
  -- the fuel remaining in the previously accepted physical DCS landing.
  local settlement = coordinator:CompleteRecovery(store, "ACCEPTED-AH64D-RECOVERY-001", 2800, {
    {
      creditId = "ACCEPTED-AH64D-RECOVERY-001-FUEL_JP8",
      resourceId = manifest.ResourceId.JP8,
      quantity = 425,
      canonicalUnit = manifest.Unit.KG,
    },
  })
  expect(settlement.recovery.status == CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR, "recovery settlement state mismatch")
  expect(settlement.creditsCreated == 1, "expected exactly one strategic recovery credit")
  expect(math.abs(store:GetResource("SHINDAND_HELIPORT", manifest.ResourceId.JP8).quantity - (jp8.quantity + 425)) <= FUEL_TOLERANCE_KG, "strategic recovery credit mismatch")
  log("SETTLEMENT_PASS resourceId=FUEL_JP8 creditKg=425 creditsCreated=1")

  local drift = storageObserver:CompareNode(store, "SHINDAND_HELIPORT", "Shindand Heliport", tolerances)
  local jp8Drift = findComparison(drift, manifest.ResourceId.JP8)
  expect(jp8Drift ~= nil and jp8Drift.status == OMWStorageResourceObserver.Status.DRIFT, "recognized settlement drift not detected")
  expect(math.abs(jp8Drift.delta + 425) <= FUEL_TOLERANCE_KG, "recognized settlement drift magnitude mismatch")
  log(string.format("RECONCILIATION_SIGNAL_PASS resourceId=FUEL_JP8 delta=%.3f reverseOverwrite=false", jp8Drift.delta))

  local snapshot = store:ExportSnapshot()
  local restored = CampaignState.Restore(snapshot)
  expect(restored:GetAircraftRecovery("ACCEPTED-AH64D-RECOVERY-001").status == CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR, "restored recovery state mismatch")

  local duplicate = coordinator:CompleteRecovery(restored, "ACCEPTED-AH64D-RECOVERY-001", 2800, {
    {
      creditId = "ACCEPTED-AH64D-RECOVERY-001-FUEL_JP8",
      resourceId = manifest.ResourceId.JP8,
      quantity = 425,
      canonicalUnit = manifest.Unit.KG,
    },
  })
  expect(duplicate.recoveryChanged == false, "duplicate recovery changed state")
  expect(duplicate.creditsCreated == 0, "restart duplicate created resource credit")
  expect(math.abs(restored:GetResource("SHINDAND_HELIPORT", manifest.ResourceId.JP8).quantity - (jp8.quantity + 425)) <= FUEL_TOLERANCE_KG, "restart duplicate changed strategic quantity")
  log("RESTART_RECONCILIATION_PASS duplicateCredit=false recoveryChanged=false")

  local repaired, repairChanged = coordinator:CompleteRepair(restored, "ACCEPTED-AH64D-RECOVERY-001", 24400)
  expect(repairChanged == true, "repair state did not change")
  expect(repaired.status == CampaignState.AircraftRecoveryStatus.AVAILABLE, "aircraft did not become AVAILABLE")
  log("REPAIR_LOCK_PASS repairSeconds=21600 status=AVAILABLE")

  log("RESULT status=PASS campaignStateAuthority=true storageReadOnly=true reverseOverwrite=false restartIdempotent=true filesystemPersistence=false inheritedForcedLandingEvidence=true")
end

SCHEDULER:New(nil, run, {}, START_DELAY_SECONDS)
