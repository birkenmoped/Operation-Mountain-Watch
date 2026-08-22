local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local GroundCampaignStateAdapter = dofile("scripts/ground/OMW_GroundCampaignStateAdapter.lua")
local GroundAmmoRearmAdapter = dofile("scripts/ground/OMW_GroundAmmoRearmAdapter.lua")
local GroundRuntimeIntegration = dofile("scripts/ground/OMW_GroundRuntimeIntegration.lua")

local function fail(message)
  error("GROUND_RUNTIME_REARM_RESTORE_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local store = CampaignState.New({
  schemaVersion = "GROUND-RUNTIME-REARM-RESTORE-TEST-1",
  nodes = {
    {
      nodeId = "GROUND_NODE_BOSTICK",
      airbaseName = "BOSTICK",
      resources = {
        GROUND_AMMO_PACKAGE = { quantity = 3, unit = "count" },
      },
    },
  },
})

local transactionId = "GROUND-REARM-RUNTIME-RESTORE-001"
store:ReserveResource({
  transactionId = transactionId,
  reservationId = "GROUND-LOCAL-REARM:" .. transactionId,
  kind = CampaignState.TransactionKind.CONSUMPTION,
  resourceId = "GROUND_AMMO_PACKAGE",
  quantity = 1,
  canonicalUnit = "count",
  originNodeId = "GROUND_NODE_BOSTICK",
})
store:Consume(transactionId)

expectEqual(store:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 2, "PRE_RESTORE_DEBIT")
expectEqual(store:GetTransaction(transactionId).status, CampaignState.TransactionStatus.CONSUMED, "PRE_RESTORE_STATUS")

local restored = CampaignState.Restore(store:ExportSnapshot())
local stock = {
  SchemaVersion = "GROUND-RUNTIME-REARM-RESTORE-STOCK-TEST-1",
  Rows = {
    {
      nodeId = "GROUND_NODE_BOSTICK",
      resourceId = "GROUND_AMMO_PACKAGE",
      unit = "count",
      initial = 3,
    },
  },
}

local context = GroundRuntimeIntegration.Attach({
  store = restored,
  campaignState = CampaignState,
  adapterModule = GroundCampaignStateAdapter,
  ammoRearmAdapterModule = GroundAmmoRearmAdapter,
  groundInitialStock = stock,
  restored = true,
})

expectEqual(context.restored, true, "RESTORED_FLAG")
expectEqual(context.localRearmReconciliation.compensated, 1, "LOCAL_REARM_COMPENSATED")
expectEqual(context.localRearmReconciliation.completed, 0, "NO_COMPLETED_REARM")
expectEqual(restored:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 3, "RESTORE_COMPENSATED_AMMO")
expectEqual(restored:GetTransaction(transactionId).status, CampaignState.TransactionStatus.COMPENSATED, "RESTORE_TX_COMPENSATED")

local second = GroundRuntimeIntegration.Attach({
  store = restored,
  campaignState = CampaignState,
  adapterModule = GroundCampaignStateAdapter,
  ammoRearmAdapterModule = GroundAmmoRearmAdapter,
  groundInitialStock = stock,
  restored = true,
})

expectEqual(second.localRearmReconciliation.compensated, 0, "SECOND_ATTACH_NO_COMPENSATION")
expectEqual(second.localRearmReconciliation.alreadyCompensated, 1, "SECOND_ATTACH_ALREADY_COMPENSATED")
expectEqual(restored:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 3, "SECOND_ATTACH_AMMO_STABLE")

print("PASS Ground runtime integration wires exactly-once local rearm restore compensation")