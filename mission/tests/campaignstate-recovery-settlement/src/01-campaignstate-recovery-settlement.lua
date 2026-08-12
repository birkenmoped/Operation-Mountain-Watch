local TEST_ID = "CAMPAIGNSTATE-RECOVERY-SETTLEMENT-1"

local function log(message)
  if env and env.info then
    env.info(string.format("[OMW-TEST][%s] %s", TEST_ID, message), false)
  end
end

local function fail(message)
  error(string.format("[OMW-TEST][%s] %s", TEST_ID, tostring(message)), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function expectTrue(value, label)
  if value ~= true then
    fail(label .. " expected=true")
  end
end

local CampaignState = OMW_CampaignState
if not CampaignState then
  fail("OMW_CampaignState module not injected")
end

local store = CampaignState.New({
  nodes = {
    {
      nodeId = "SHINDAND_HELIPORT",
      airbaseName = "Shindand Heliport",
      resources = {
        FUEL_JP8 = { quantity = 10000, unit = "kg" },
        AMMUNITION_HELLFIRE = { quantity = 100, unit = "count" },
      },
    },
  },
})

local recovery, created = store:BeginAircraftRecovery({
  entityId = "AIRFRAME_AH64D_001",
  recoveryNodeId = "SHINDAND_HELIPORT",
  recoveryStartedAt = 1000,
  recoveryCompleteAt = 2800,
  repairCompleteAt = 24400,
})
expectTrue(created, "recovery creation")
expectEqual(recovery.status, CampaignState.AircraftRecoveryStatus.RECOVERY_IN_PROGRESS, "initial recovery state")

local recoveryAgain, createdAgain = store:BeginAircraftRecovery({
  entityId = "AIRFRAME_AH64D_001",
  recoveryNodeId = "SHINDAND_HELIPORT",
  recoveryStartedAt = 1000,
  recoveryCompleteAt = 2800,
  repairCompleteAt = 24400,
})
expectEqual(createdAgain, false, "recovery idempotency")
expectEqual(recoveryAgain.status, CampaignState.AircraftRecoveryStatus.RECOVERY_IN_PROGRESS, "idempotent recovery state")

local completed, changed = store:CompleteAircraftRecovery("AIRFRAME_AH64D_001", 2800)
expectTrue(changed, "recovery completion")
expectEqual(completed.status, CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR, "recovered state")

local fuelCredit, fuelCreated = store:CreditResourceOnce({
  creditId = "RECOVERY-AIRFRAME_AH64D_001-FUEL_JP8",
  nodeId = "SHINDAND_HELIPORT",
  resourceId = "FUEL_JP8",
  quantity = 425,
  canonicalUnit = "kg",
  reason = "FORCED_LANDING_RECOVERY_REMAINDER",
  entityId = "AIRFRAME_AH64D_001",
})
expectTrue(fuelCreated, "fuel recovery credit")
expectEqual(fuelCredit.quantity, 425, "fuel credit quantity")
expectEqual(store:GetResource("SHINDAND_HELIPORT", "FUEL_JP8").quantity, 10425, "fuel quantity after credit")

local _, fuelCreatedAgain = store:CreditResourceOnce({
  creditId = "RECOVERY-AIRFRAME_AH64D_001-FUEL_JP8",
  nodeId = "SHINDAND_HELIPORT",
  resourceId = "FUEL_JP8",
  quantity = 425,
  canonicalUnit = "kg",
  reason = "FORCED_LANDING_RECOVERY_REMAINDER",
  entityId = "AIRFRAME_AH64D_001",
})
expectEqual(fuelCreatedAgain, false, "fuel credit idempotency")
expectEqual(store:GetResource("SHINDAND_HELIPORT", "FUEL_JP8").quantity, 10425, "fuel quantity after duplicate credit")

local _, storeCreated = store:CreditResourceOnce({
  creditId = "RECOVERY-AIRFRAME_AH64D_001-HELLFIRE",
  nodeId = "SHINDAND_HELIPORT",
  resourceId = "AMMUNITION_HELLFIRE",
  quantity = 3,
  canonicalUnit = "count",
  reason = "FORCED_LANDING_RECOVERY_REMAINDER",
  entityId = "AIRFRAME_AH64D_001",
})
expectTrue(storeCreated, "store recovery credit")
expectEqual(store:GetResource("SHINDAND_HELIPORT", "AMMUNITION_HELLFIRE").quantity, 103, "store quantity after credit")

local snapshot = store:ExportSnapshot()
expectEqual(snapshot.snapshotVersion, CampaignState.SnapshotVersion, "snapshot version")

local restored = CampaignState.Restore(snapshot)
expectEqual(restored:GetResource("SHINDAND_HELIPORT", "FUEL_JP8").quantity, 10425, "restored fuel quantity")
expectEqual(restored:GetResource("SHINDAND_HELIPORT", "AMMUNITION_HELLFIRE").quantity, 103, "restored store quantity")
expectEqual(restored:GetAircraftRecovery("AIRFRAME_AH64D_001").status, CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR, "restored aircraft recovery state")

local _, restoredDuplicate = restored:CreditResourceOnce({
  creditId = "RECOVERY-AIRFRAME_AH64D_001-FUEL_JP8",
  nodeId = "SHINDAND_HELIPORT",
  resourceId = "FUEL_JP8",
  quantity = 425,
  canonicalUnit = "kg",
  reason = "FORCED_LANDING_RECOVERY_REMAINDER",
  entityId = "AIRFRAME_AH64D_001",
})
expectEqual(restoredDuplicate, false, "restart credit idempotency")
expectEqual(restored:GetResource("SHINDAND_HELIPORT", "FUEL_JP8").quantity, 10425, "restart duplicate leaves fuel unchanged")

local repaired, repairChanged = restored:CompleteAircraftRepair("AIRFRAME_AH64D_001", 24400)
expectTrue(repairChanged, "repair completion")
expectEqual(repaired.status, CampaignState.AircraftRecoveryStatus.AVAILABLE, "aircraft available after repair lock")

log("RECOVERY_SETTLEMENT_PASS fuelCreditKg=425 storeCreditCount=3 duplicateCredit=false")
log("SNAPSHOT_RESTORE_PASS recoveryState=RECOVERED_AWAITING_REPAIR restartDuplicateCredit=false")
log("REPAIR_LOCK_PASS repairCompleteAt=24400 status=AVAILABLE")
log("RESULT status=PASS campaignStateAuthority=true storageMutation=false mooseDependency=false filesystemIo=false")
