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

local function row(reorder, critical)
  return {
    nodeId = "GROUND_NODE_HONAKER",
    resourceId = "GROUND_AMMO_PACKAGE",
    resourceClass = "GROUND_AMMO",
    unit = "count",
    target = 40,
    reorder = reorder,
    critical = critical,
    supplyParent = "GROUND_NODE_JOYCE",
  }
end

local function snapshot(available)
  return {
    nodeId = "GROUND_NODE_HONAKER",
    resourceId = "GROUND_AMMO_PACKAGE",
    canonicalUnit = "count",
    quantity = available,
    reserved = 0,
    available = available,
  }
end

local transferable = {
  GROUND_SUPPLY = true,
  GROUND_AMMO = true,
  GROUND_FUEL = true,
}

assertEqual(InitialStock.ResupplyThresholds.reorderRatio, 0.50, "approved reorder ratio")
assertEqual(InitialStock.ResupplyThresholds.criticalRatio, 0.25, "approved critical ratio")

for _, stockRow in ipairs(InitialStock.Rows) do
  if transferable[stockRow.resourceClass] then
    assertEqual(stockRow.reorder, stockRow.target * 0.50, stockRow.nodeId .. " " .. stockRow.resourceClass .. " reorder")
    assertEqual(stockRow.critical, stockRow.target * 0.25, stockRow.nodeId .. " " .. stockRow.resourceClass .. " critical")
  else
    assertEqual(stockRow.reorder, 0, stockRow.nodeId .. " " .. stockRow.resourceClass .. " no automatic reorder")
    assertEqual(stockRow.critical, 0, stockRow.nodeId .. " " .. stockRow.resourceClass .. " no automatic critical")
  end
end

assertEqual(Policy.Evaluate(row(0, 0), snapshot(0)), nil, "zero reorder disables automatic resupply")
assertEqual(Policy.Evaluate(row(20, 10), snapshot(25)), nil, "above reorder has no demand")

local reorderCandidate = Policy.Evaluate(row(20, 10), snapshot(20))
assertEqual(reorderCandidate.level, Policy.Level.REORDER, "reorder level")
assertEqual(reorderCandidate.requestedQuantity, 20, "reorder requested quantity")
assertEqual(reorderCandidate.supplyParent, "GROUND_NODE_JOYCE", "reorder supply parent")
assertEqual(reorderCandidate.dedupeKey, "RESUPPLY|GROUND_NODE_HONAKER|GROUND_AMMO_PACKAGE", "reorder dedupe key")

local criticalCandidate = Policy.Evaluate(row(20, 10), snapshot(8))
assertEqual(criticalCandidate.level, Policy.Level.CRITICAL, "critical level")
assertEqual(criticalCandidate.requestedQuantity, 32, "critical requested quantity")

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
