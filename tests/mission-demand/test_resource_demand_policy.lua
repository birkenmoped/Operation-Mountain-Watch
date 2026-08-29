local Policy = dofile("scripts/campaign/OMW_ResourceDemandPolicy.lua")
local InitialStock = dofile("scripts/logistics/OMW_GroundInitialStock.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function assertTrue(value, label)
  if value ~= true then
    error(label .. " expected=true actual=" .. tostring(value))
  end
end

local function assertError(fn, label)
  local ok = pcall(fn)
  if ok then
    error(label .. " expected error")
  end
end

local function row(reorder, critical, reorderComparison)
  return {
    nodeId = "GROUND_NODE_HONAKER",
    resourceId = "GROUND_AMMO_PACKAGE",
    resourceClass = "GROUND_AMMO",
    unit = "count",
    target = 40,
    reorder = reorder,
    critical = critical,
    reorderComparison = reorderComparison,
    supplyParent = "GROUND_NODE_JOYCE",
  }
end

local function snapshot(available, resourceId)
  return {
    nodeId = "GROUND_NODE_HONAKER",
    resourceId = resourceId or "GROUND_AMMO_PACKAGE",
    canonicalUnit = "count",
    quantity = available,
    reserved = 0,
    available = available,
  }
end

local transferable = {
  GROUND_PERSONNEL = true,
  GROUND_SUPPLY = true,
  GROUND_AMMO = true,
  GROUND_FUEL = true,
}

assertEqual(InitialStock.ResupplyThresholds.commodityReorderRatio, 0.50, "approved commodity reorder ratio")
assertEqual(InitialStock.ResupplyThresholds.commodityCriticalRatio, 0.25, "approved commodity critical ratio")
assertEqual(InitialStock.ResupplyThresholds.personnelReorderRatio, 0.80, "approved personnel reorder ratio")

for _, stockRow in ipairs(InitialStock.Rows) do
  if stockRow.resourceClass == "GROUND_PERSONNEL" then
    assertEqual(stockRow.resourceId, InitialStock.ResourceId.PERSONNEL, stockRow.nodeId .. " PERSONNEL shared resource")
    assertEqual(stockRow.reorder, stockRow.target * 0.80, stockRow.nodeId .. " PERSONNEL reorder")
    assertEqual(stockRow.critical, 0, stockRow.nodeId .. " PERSONNEL critical disabled")
    assertEqual(stockRow.reorderComparison, Policy.ReorderComparison.BELOW, stockRow.nodeId .. " PERSONNEL strict floor")
  elseif transferable[stockRow.resourceClass] then
    assertEqual(stockRow.reorder, stockRow.target * 0.50, stockRow.nodeId .. " " .. stockRow.resourceClass .. " reorder")
    assertEqual(stockRow.critical, stockRow.target * 0.25, stockRow.nodeId .. " " .. stockRow.resourceClass .. " critical")
    assertEqual(stockRow.reorderComparison, Policy.ReorderComparison.AT_OR_BELOW, stockRow.nodeId .. " " .. stockRow.resourceClass .. " comparison")
  else
    assertEqual(stockRow.reorder, 0, stockRow.nodeId .. " " .. stockRow.resourceClass .. " no automatic reorder")
    assertEqual(stockRow.critical, 0, stockRow.nodeId .. " " .. stockRow.resourceClass .. " no automatic critical")
    assertEqual(stockRow.reorderComparison, Policy.ReorderComparison.DISABLED, stockRow.nodeId .. " " .. stockRow.resourceClass .. " disabled")
  end
end

assertEqual(Policy.Evaluate(row(0, 0, Policy.ReorderComparison.DISABLED), snapshot(0)), nil, "disabled reorder has no demand")
assertEqual(Policy.Evaluate(row(20, 10), snapshot(25)), nil, "above reorder has no demand")

local reorderCandidate = Policy.Evaluate(row(20, 10), snapshot(20))
assertEqual(reorderCandidate.level, Policy.Level.REORDER, "reorder level")
assertEqual(reorderCandidate.requestedQuantity, 20, "reorder requested quantity")
assertEqual(reorderCandidate.supplyParent, "GROUND_NODE_JOYCE", "reorder supply parent")
assertEqual(reorderCandidate.dedupeKey, "RESUPPLY|GROUND_NODE_HONAKER|GROUND_AMMO_PACKAGE", "reorder dedupe key")

local criticalCandidate = Policy.Evaluate(row(20, 10), snapshot(8))
assertEqual(criticalCandidate.level, Policy.Level.CRITICAL, "critical level")
assertEqual(criticalCandidate.requestedQuantity, 32, "critical requested quantity")

local personnelRow = {
  nodeId = "GROUND_NODE_HONAKER",
  resourceId = InitialStock.ResourceId.PERSONNEL,
  resourceClass = "GROUND_PERSONNEL",
  unit = "count",
  target = 120,
  reorder = 96,
  critical = 0,
  reorderComparison = Policy.ReorderComparison.BELOW,
  supplyParent = "GROUND_NODE_JOYCE",
}

assertEqual(Policy.Evaluate(personnelRow, snapshot(97, InitialStock.ResourceId.PERSONNEL)), nil, "PERSONNEL above 80 percent has no demand")
assertEqual(Policy.Evaluate(personnelRow, snapshot(96, InitialStock.ResourceId.PERSONNEL)), nil, "PERSONNEL exactly 80 percent has no demand")
local personnelCandidate = Policy.Evaluate(personnelRow, snapshot(95, InitialStock.ResourceId.PERSONNEL))
assertEqual(personnelCandidate.level, Policy.Level.REORDER, "PERSONNEL below 80 percent demand level")
assertEqual(personnelCandidate.requestedQuantity, 25, "PERSONNEL fills to target")
assertEqual(personnelCandidate.supplyParent, "GROUND_NODE_JOYCE", "PERSONNEL supply parent")
assertEqual(personnelCandidate.reorderComparison, Policy.ReorderComparison.BELOW, "PERSONNEL strict comparison preserved")

assertError(function()
  Policy.Evaluate(row(20, 10), {
    nodeId = "GROUND_NODE_HONAKER",
    resourceId = "GROUND_AMMO_PACKAGE",
    canonicalUnit = "kg",
    available = 8,
  })
end, "unit mismatch")

assertError(function()
  Policy.BuildIndex({ row(20, 10), row(20, 10) })
end, "duplicate policy row")

assertError(function()
  Policy.Evaluate(row(10, 20), snapshot(8))
end, "critical above reorder")

assertError(function()
  Policy.Evaluate(row(20, 10, "INVALID"), snapshot(8))
end, "invalid reorder comparison")

local fakeStore = {
  GetResource = function(_, nodeId, resourceId)
    assertEqual(nodeId, "GROUND_NODE_HONAKER", "EvaluateAll nodeId")
    assertEqual(resourceId, "GROUND_AMMO_PACKAGE", "EvaluateAll resourceId")
    return snapshot(8)
  end,
}

local candidates = Policy.EvaluateAll(fakeStore, { row(20, 10) })
assertEqual(#candidates, 1, "EvaluateAll candidate count")
assertTrue(candidates[1].requestedQuantity == 32, "EvaluateAll requested quantity")

print("PASS test_resource_demand_policy")
