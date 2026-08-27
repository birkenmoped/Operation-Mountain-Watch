local function repoPath(relative)
  return relative
end

local CampaignState = dofile(repoPath("scripts/campaign/OMW_CampaignState.lua"))
local Adapter = dofile(repoPath("scripts/campaign/OMW_ISR_UavCampaignStateAdapter.lua"))

local state = CampaignState.New({
  nodes = {
    {
      nodeId = "KANDAHAR_MAIN",
      airbaseName = "Kandahar",
      resources = { AIRCRAFT_MQ9 = { quantity = 2, unit = "count" } },
    },
  },
})
local adapter = Adapter.New({ campaignState = state, nodeId = "KANDAHAR_MAIN" })
local profile = { resourceId = "AIRCRAFT_MQ9", platformId = "MQ-9" }

local reservation = assert(adapter:Reserve("ISR-0001", profile))
assert(reservation.transactionId == "ISR-UAV-RESERVE:ISR-0001")
assert(adapter:CancelBeforePhysicalStart("ISR-0001"))

local second = assert(adapter:Reserve("ISR-0002", profile))
assert(adapter:ConsumeAtPhysicalStart("ISR-0002"))
local resource = assert(state:GetResource("KANDAHAR_MAIN", "AIRCRAFT_MQ9"))
assert(resource.quantity == 1, "physical start must consume one MQ-9")
assert(second.platformId == "MQ-9")
assert(adapter:RecoverAfterPhysicalRecovery("ISR-0002"))
local recoveredResource = assert(state:GetResource("KANDAHAR_MAIN", "AIRCRAFT_MQ9"))
assert(recoveredResource.quantity == 2, "physical recovery must restore one MQ-9")
assert(adapter:RecoverAfterPhysicalRecovery("ISR-0002"))
local idempotentResource = assert(state:GetResource("KANDAHAR_MAIN", "AIRCRAFT_MQ9"))
assert(idempotentResource.quantity == 2, "recovery credit must be idempotent")
assert(adapter:Reserve("ISR-0003", profile))

print("PASS test_isr_uav_campaign_state_adapter")

