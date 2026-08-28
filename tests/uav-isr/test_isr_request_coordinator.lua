local Coordinator = dofile("scripts/campaign/OMW_ISR_RequestCoordinator.lua")
local coordinator = Coordinator.New({
  blueCoalitionNumber = 2, submitRadiusMeters = 50000, requestIdPrefix = "ISR",
})
coordinator:UpsertMarker({
  markerId = 10, text = "UAV RECON", coalitionNumber = 2,
  coordinate = { sentinel = true },
})
local request = assert(coordinator:SubmitNearest({
  ownerGroupId = 77,
  distanceForMarker = function() return 0 end,
}))
assert(request.status == Coordinator.RequestStatus.QUEUED)
local assigned = assert(coordinator:MarkAssigned(request.id, "ISR " .. request.id))
assert(assigned.status == Coordinator.RequestStatus.ASSIGNED)
local launching = assert(coordinator:MarkLaunching(request.id, "TX-ISR-0001"))
assert(launching.status == Coordinator.RequestStatus.LAUNCHING)
assert(launching.transactionId == "TX-ISR-0001")
local recon = assert(coordinator:MarkReconciliationRequired(request.id, "CAMPAIGNSTATE_MOOSE_DIVERGENCE"))
assert(recon.status == Coordinator.RequestStatus.RECONCILIATION_REQUIRED)
assert(coordinator:GetOpenRequestForGroup(77) == nil)
print("PASS test_isr_request_coordinator")
