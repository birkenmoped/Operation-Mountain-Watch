local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local Ledger = dofile("scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local store = CampaignState.New({
  nodes = {
    {
      nodeId = "GROUND_NODE_FORTRESS",
      resources = {
        GROUND_PERSONNEL = { quantity = 160, unit = "count" },
      },
    },
  },
})

local deployment, _, created = Ledger.New({
  store=store, campaignState=CampaignState, nodeId="GROUND_NODE_FORTRESS",
  resourceId="GROUND_PERSONNEL", deploymentId="TEST-GUARD", entityId="GUARD-1", quantity=9,
})
assertTrue(created, "deployment reservation created")
local reserved = store:GetResource("GROUND_NODE_FORTRESS", "GROUND_PERSONNEL")
assertEqual(reserved.quantity, 160, "deployment does not consume strategic quantity")
assertEqual(reserved.reserved, 9, "deployment reserved")
assertEqual(reserved.available, 151, "deployment unavailable")

local settlement, changed = deployment:SettleReturned(6)
assertTrue(changed, "first settlement")
assertEqual(settlement.survivors, 6, "survivors")
assertEqual(settlement.casualties, 3, "casualties")
assertEqual(settlement.snapshot.quantity, 157, "only confirmed casualties consumed")
assertEqual(settlement.snapshot.reserved, 0, "deployment reservation released")
assertEqual(settlement.snapshot.available, 157, "survivors available after return")

local settlementAgain, changedAgain = deployment:SettleReturned(6)
assertEqual(changedAgain, false, "settlement idempotent")
assertEqual(settlementAgain.snapshot.quantity, 157, "idempotent quantity")

print("PASS test_ground_personnel_deployment_ledger")
