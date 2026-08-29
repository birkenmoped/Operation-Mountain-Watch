-- Operation Mountain Watch - ARMY Ground strategic initial stock runtime data.
--
-- Pure CampaignState input data. This module has no MOOSE/DCS dependency and
-- creates no independent store. It is intended to be composed into the single
-- authoritative CampaignState initial state through the existing initializer.
--
-- Source baselines:
-- docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
-- docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md

local InitialStock = {}

InitialStock.SchemaVersion = "OMW-GROUND-INITIAL-STOCK-3"
InitialStock.Unit = "count"

InitialStock.ResourceId = {
  PERSONNEL = "GROUND_PERSONNEL",
  SUPPLY = "GROUND_SUPPLY_PACKAGE",
  AMMO = "GROUND_AMMO_PACKAGE",
  FUEL = "GROUND_FUEL_PACKAGE",
}

InitialStock.ResupplyThresholds = {
  commodityReorderRatio = 0.50,
  commodityCriticalRatio = 0.25,
  personnelReorderRatio = 0.80,
}

InitialStock.ReorderComparison = {
  AT_OR_BELOW = "AT_OR_BELOW",
  BELOW = "BELOW",
  DISABLED = "DISABLED",
}

local TRANSFERABLE_RESOURCE_CLASSES = {
  PERSONNEL = true,
  SUPPLY = true,
  AMMO = true,
  FUEL = true,
}

local COMMODITY_RESOURCE_CLASSES = {
  SUPPLY = true,
  AMMO = true,
  FUEL = true,
}

local function fail(message)
  error("[OMW][Ground.InitialStock] " .. tostring(message), 2)
end

local function legacyResourceId(nodeId, resourceClass)
  return "GROUND:" .. nodeId .. ":" .. resourceClass
end

local function resourceId(nodeId, resourceClass)
  return InitialStock.ResourceId[resourceClass] or legacyResourceId(nodeId, resourceClass)
end

local function thresholds(resourceClass, target)
  if resourceClass == "PERSONNEL" then
    return target * InitialStock.ResupplyThresholds.personnelReorderRatio,
      0,
      InitialStock.ReorderComparison.BELOW
  end

  if COMMODITY_RESOURCE_CLASSES[resourceClass] then
    return target * InitialStock.ResupplyThresholds.commodityReorderRatio,
      target * InitialStock.ResupplyThresholds.commodityCriticalRatio,
      InitialStock.ReorderComparison.AT_OR_BELOW
  end

  return 0, 0, InitialStock.ReorderComparison.DISABLED
end

local function row(nodeId, resourceClass, initial, supplyParent)
  local target = initial
  local reorder, critical, reorderComparison = thresholds(resourceClass, target)

  return {
    nodeId = nodeId,
    resourceId = resourceId(nodeId, resourceClass),
    legacyResourceId = TRANSFERABLE_RESOURCE_CLASSES[resourceClass] and legacyResourceId(nodeId, resourceClass) or nil,
    resourceClass = "GROUND_" .. resourceClass,
    unit = InitialStock.Unit,
    initial = initial,
    target = target,
    reorder = reorder,
    critical = critical,
    reorderComparison = reorderComparison,
    supplyParent = supplyParent,
    mappingStatus = "OMW_GROUND_DESIGN_STOCK",
  }
end

local function lossRow(nodeId, resourceClass, supplyParent)
  return {
    nodeId = nodeId,
    resourceId = legacyResourceId(nodeId, resourceClass .. "_LOST"),
    resourceClass = "GROUND_" .. resourceClass .. "_LOSS_AUDIT",
    unit = InitialStock.Unit,
    initial = 0,
    target = 0,
    reorder = 0,
    critical = 0,
    reorderComparison = InitialStock.ReorderComparison.DISABLED,
    supplyParent = supplyParent,
    mappingStatus = "OMW_RUNTIME_AUDIT",
  }
end

local function appendNode(rows, nodeId, personnel, vehicle, supply, ammo, fuel, supplyParent)
  rows[#rows + 1] = row(nodeId, "PERSONNEL", personnel, supplyParent)
  rows[#rows + 1] = row(nodeId, "VEHICLE", vehicle, supplyParent)
  rows[#rows + 1] = row(nodeId, "SUPPLY", supply, supplyParent)
  rows[#rows + 1] = row(nodeId, "AMMO", ammo, supplyParent)
  rows[#rows + 1] = row(nodeId, "FUEL", fuel, supplyParent)
  rows[#rows + 1] = lossRow(nodeId, "PERSONNEL", supplyParent)
  rows[#rows + 1] = lossRow(nodeId, "VEHICLE", supplyParent)
end

local function deepCopy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for key, item in pairs(value) do
    result[deepCopy(key)] = deepCopy(item)
  end
  return result
end

local function migrationMapByNode()
  local result = {}
  for _, source in ipairs(InitialStock.Rows) do
    if source.legacyResourceId then
      local byLegacy = result[source.nodeId]
      if not byLegacy then
        byLegacy = {}
        result[source.nodeId] = byLegacy
      end
      byLegacy[source.legacyResourceId] = source.resourceId
    end
  end
  return result
end

local function migratedResourceId(map, nodeId, oldResourceId)
  local byLegacy = map[nodeId]
  if not byLegacy then
    return nil
  end
  return byLegacy[oldResourceId]
end

local function rejectUnsupportedLegacyGroundCommitment(recordId, oldResourceId, newResourceId)
  if newResourceId == InitialStock.ResourceId.PERSONNEL then
    return
  end

  if type(recordId) == "string" and recordId:sub(1, 14) == "GROUND-COMMIT:" then
    fail(string.format(
      "cannot migrate unsupported legacy commodity commitment id=%s resourceId=%s targetResourceId=%s",
      recordId,
      oldResourceId,
      newResourceId
    ))
  end
end

-- Migrates supported pre-v3 Ground snapshots without mutating the caller's
-- snapshot. Legacy node-specific PERSONNEL IDs are normalized to the shared
-- transferable PERSONNEL resource. Legacy SUPPLY/AMMO/FUEL node keys continue
-- to migrate to their shared package IDs. Existing PERSONNEL commitments are
-- supported because PERSONNEL settlement predates this normalization; legacy
-- commodity commitments remain rejected because they were never part of the
-- accepted Foundation settlement contract.
function InitialStock.MigrateSnapshot(snapshot)
  if type(snapshot) ~= "table" then
    fail("snapshot must be a table")
  end

  local migrated = deepCopy(snapshot)
  local map = migrationMapByNode()

  for _, node in ipairs(migrated.nodes or {}) do
    local byLegacy = map[node.nodeId]
    if byLegacy and type(node.resources) == "table" then
      for oldResourceId, newResourceId in pairs(byLegacy) do
        local oldEntry = node.resources[oldResourceId]
        if oldEntry then
          if node.resources[newResourceId] then
            fail(string.format(
              "snapshot contains both legacy and normalized resource IDs nodeId=%s legacy=%s normalized=%s",
              tostring(node.nodeId),
              oldResourceId,
              newResourceId
            ))
          end
          node.resources[newResourceId] = oldEntry
          node.resources[oldResourceId] = nil
        end
      end
    end
  end

  for _, transaction in ipairs(migrated.transactions or {}) do
    local newResourceId = migratedResourceId(map, transaction.originNodeId, transaction.resourceId)
    if newResourceId then
      rejectUnsupportedLegacyGroundCommitment(transaction.transactionId, transaction.resourceId, newResourceId)
      transaction.resourceId = newResourceId
    end
  end

  for _, credit in ipairs(migrated.resourceCredits or {}) do
    local newResourceId = migratedResourceId(map, credit.nodeId, credit.resourceId)
    if newResourceId then
      credit.resourceId = newResourceId
    end
  end

  return migrated
end

InitialStock.Rows = {}

appendNode(InitialStock.Rows, "GROUND_NODE_JALALABAD", 480, 48, 120, 100, 120, "OFF_MAP")
appendNode(InitialStock.Rows, "GROUND_NODE_FORTRESS", 160, 18, 44, 48, 40, "GROUND_NODE_JALALABAD")
appendNode(InitialStock.Rows, "GROUND_NODE_JOYCE", 180, 20, 48, 44, 40, "GROUND_NODE_JALALABAD")
appendNode(InitialStock.Rows, "GROUND_NODE_WRIGHT", 120, 22, 36, 30, 36, "GROUND_NODE_JALALABAD")
appendNode(InitialStock.Rows, "GROUND_NODE_HONAKER", 120, 18, 40, 40, 36, "GROUND_NODE_JOYCE")
appendNode(InitialStock.Rows, "GROUND_NODE_BOSTICK", 220, 26, 56, 52, 48, "GROUND_NODE_JALALABAD")

InitialStock.MotorizedPatrol = {
  vehicleCount = 4,
  perVehicleResources = {
    VEHICLE = 1,
    PERSONNEL = 3,
  },
  totalResources = {
    VEHICLE = 4,
    PERSONNEL = 12,
  },
}

return InitialStock
