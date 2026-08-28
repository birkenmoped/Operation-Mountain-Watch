local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local Adapter = dofile("scripts/campaign/OMW_ISR_UavCampaignStateAdapter.lua")

local state = CampaignState.New({
  nodes = {{
    nodeId = "KANDAHAR_MAIN",
    airbaseName = "Kandahar",
    resources = { AIRCRAFT_MQ9 = { quantity = 2, unit = "count" } },
  }},
})
local adapter = Adapter.New({ campaignState = state, nodeId = "KANDAHAR_MAIN" })
local profile = { resourceId = "AIRCRAFT_MQ9", platformId = "MQ-9" }

assert(adapter:CancelBeforePhysicalStart("ISR-0001").cancellationRequired == false,
  "MOOSE-queued request has no CampaignState reservation")
local reservation = assert(adapter:BeginPhysicalStart("ISR-0001", profile))
assert(reservation.transactionId == "ISR-UAV-RESERVE:ISR-0001")
assert(reservation.consumed == true)
assert(state:GetResource("KANDAHAR_MAIN", "AIRCRAFT_MQ9").quantity == 1)
assert(adapter:RecoverAfterPhysicalRecovery("ISR-0001"))
assert(state:GetResource("KANDAHAR_MAIN", "AIRCRAFT_MQ9").quantity == 2)
assert(adapter:RecoverAfterPhysicalRecovery("ISR-0001"))
assert(state:GetResource("KANDAHAR_MAIN", "AIRCRAFT_MQ9").quantity == 2)
print("PASS test_isr_uav_campaign_state_adapter")
