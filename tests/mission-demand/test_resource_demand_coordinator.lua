local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local ResourceDemandPolicy = dofile("scripts/campaign/OMW_ResourceDemandPolicy.lua")
local Coordinator = dofile("scripts/campaign/OMW_ResourceDemandCoordinator.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local snapshot = {
  nodeId="GROUND_NODE_FORTRESS", resourceId="GROUND_PERSONNEL", quantity=127,
  reserved=0, available=127, canonicalUnit="count",
}
local store = { GetResource=function(_, nodeId, resourceId)
  assertEqual(nodeId, "GROUND_NODE_FORTRESS", "store node")
  assertEqual(resourceId, "GROUND_PERSONNEL", "store resource")
  return snapshot
end }
local row = {
  nodeId="GROUND_NODE_FORTRESS", resourceId="GROUND_PERSONNEL", resourceClass="GROUND_PERSONNEL",
  unit="count", target=160, reorder=128, critical=80, reorderComparison="BELOW",
  supplyParent="GROUND_NODE_JALALABAD",
}
local registry = MissionDemand.New()
local demand, created, reason, candidate = Coordinator.EvaluateAndCreate({
  policy=ResourceDemandPolicy, missionDemand=MissionDemand, registry=registry, store=store, row=row,
  demandIdFactory=function() return "RESUPPLY-FORTRESS-PERSONNEL-127" end,
})
assertTrue(created, "shortage demand created")
assertEqual(reason, nil, "create reason")
assertEqual(candidate.requestedQuantity, 33, "requested quantity")
assertEqual(demand.missionType, MissionDemand.Type.RESUPPLY, "mission type")
assertEqual(demand.origin, "GROUND_NODE_JALALABAD", "supply origin")
assertEqual(demand.target.nodeId, "GROUND_NODE_FORTRESS", "destination")
assertEqual(demand.target.requestedQuantity, 33, "demand quantity")
assertEqual(demand.dedupeKey, "RESUPPLY|GROUND_NODE_FORTRESS|GROUND_PERSONNEL", "dedupe")

local duplicate, duplicateCreated, duplicateReason = Coordinator.EvaluateAndCreate({
  policy=ResourceDemandPolicy, missionDemand=MissionDemand, registry=registry, store=store, row=row,
  demandIdFactory=function() return "RESUPPLY-FORTRESS-PERSONNEL-SECOND" end,
})
assertEqual(duplicate.id, demand.id, "duplicate returns active demand")
assertEqual(duplicateCreated, false, "duplicate not created")
assertEqual(duplicateReason, "active_duplicate", "duplicate reason")

snapshot.available=128
snapshot.quantity=128
local none, noneCreated, noneReason = Coordinator.EvaluateAndCreate({
  policy=ResourceDemandPolicy, missionDemand=MissionDemand, registry=MissionDemand.New(), store=store, row=row,
})
assertEqual(none, nil, "strict BELOW no demand at threshold")
assertEqual(noneCreated, false, "no demand created at threshold")
assertEqual(noneReason, "NO_SHORTAGE", "no-shortage reason")

print("PASS test_resource_demand_coordinator")
