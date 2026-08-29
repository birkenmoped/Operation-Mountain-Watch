local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local Initializer = dofile("scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua")
local GroundInitialStock = dofile("scripts/logistics/OMW_GroundInitialStock.lua")

local function fail(message)
  error("GROUND_RESOURCE_NORMALIZATION_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local BaseStock = {
  SchemaVersion = "TEST-BASE-STOCK-1",
  Rows = {
    {
      nodeId = "BAGRAM",
      resourceId = "TEST_RESOURCE",
      resourceClass = "TEST_RESOURCE",
      unit = "count",
      initial = 1,
      target = 1,
      reorder = 0,
      critical = 0,
      supplyParent = "OFF_MAP",
      mappingStatus = "TEST_ONLY",
    },
  },
}

local created = Initializer.CreateStore(CampaignState, BaseStock, GroundInitialStock)
expectEqual(created.initializerSchemaVersion, "OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-5", "INITIALIZER_SCHEMA")
expectEqual(GroundInitialStock.SchemaVersion, "OMW-GROUND-INITIAL-STOCK-3", "GROUND_SCHEMA")
expectEqual(created.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.AMMO).available, 44, "JOYCE_AMMO_INITIAL")
expectEqual(created.store:GetResource("GROUND_NODE_HONAKER", GroundInitialStock.ResourceId.AMMO).available, 40, "HONAKER_AMMO_INITIAL")
expectEqual(created.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.PERSONNEL).available, 180, "JOYCE_PERSONNEL_INITIAL")
expectEqual(created.store:GetResource("GROUND_NODE_HONAKER", GroundInitialStock.ResourceId.PERSONNEL).available, 120, "HONAKER_PERSONNEL_INITIAL")

local ammoTransactionId = "TEST-GROUND-AMMO-JOYCE-HONAKER"
created.store:ReserveResource({
  transactionId = ammoTransactionId,
  reservationId = ammoTransactionId,
  kind = CampaignState.TransactionKind.TRANSFER,
  resourceId = GroundInitialStock.ResourceId.AMMO,
  quantity = 4,
  canonicalUnit = "count",
  originNodeId = "GROUND_NODE_JOYCE",
  destinationNodeId = "GROUND_NODE_HONAKER",
})
created.store:MarkLoading(ammoTransactionId)
created.store:MarkInTransit(ammoTransactionId)
created.store:MarkDelivered(ammoTransactionId)
expectEqual(created.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.AMMO).available, 40, "JOYCE_AMMO_AFTER_TRANSFER")
expectEqual(created.store:GetResource("GROUND_NODE_HONAKER", GroundInitialStock.ResourceId.AMMO).available, 44, "HONAKER_AMMO_AFTER_TRANSFER")

local personnelTransactionId = "TEST-GROUND-PERSONNEL-JOYCE-HONAKER"
created.store:ReserveResource({
  transactionId = personnelTransactionId,
  reservationId = personnelTransactionId,
  kind = CampaignState.TransactionKind.TRANSFER,
  resourceId = GroundInitialStock.ResourceId.PERSONNEL,
  quantity = 25,
  canonicalUnit = "count",
  originNodeId = "GROUND_NODE_JOYCE",
  destinationNodeId = "GROUND_NODE_HONAKER",
})
created.store:MarkLoading(personnelTransactionId)
created.store:MarkInTransit(personnelTransactionId)
created.store:MarkDelivered(personnelTransactionId)
expectEqual(created.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.PERSONNEL).available, 155, "JOYCE_PERSONNEL_AFTER_TRANSFER")
expectEqual(created.store:GetResource("GROUND_NODE_HONAKER", GroundInitialStock.ResourceId.PERSONNEL).available, 145, "HONAKER_PERSONNEL_AFTER_TRANSFER")

local fresh = Initializer.CreateStore(CampaignState, BaseStock, GroundInitialStock)
local legacySnapshot = fresh.store:ExportSnapshot()
for _, node in ipairs(legacySnapshot.nodes) do
  if node.nodeId == "GROUND_NODE_JOYCE" then
    node.resources["GROUND:GROUND_NODE_JOYCE:PERSONNEL"] = node.resources[GroundInitialStock.ResourceId.PERSONNEL]
    node.resources[GroundInitialStock.ResourceId.PERSONNEL] = nil
    node.resources["GROUND:GROUND_NODE_JOYCE:AMMO"] = node.resources[GroundInitialStock.ResourceId.AMMO]
    node.resources[GroundInitialStock.ResourceId.AMMO] = nil
    node.resources["GROUND:GROUND_NODE_JOYCE:SUPPLY"] = node.resources[GroundInitialStock.ResourceId.SUPPLY]
    node.resources[GroundInitialStock.ResourceId.SUPPLY] = nil
    node.resources["GROUND:GROUND_NODE_JOYCE:FUEL"] = node.resources[GroundInitialStock.ResourceId.FUEL]
    node.resources[GroundInitialStock.ResourceId.FUEL] = nil
  end
end

local restored = Initializer.RestoreStore(CampaignState, legacySnapshot, BaseStock, GroundInitialStock)
expectEqual(restored.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.PERSONNEL).available, 180, "JOYCE_PERSONNEL_MIGRATED")
expectEqual(restored.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.AMMO).available, 44, "JOYCE_AMMO_MIGRATED")
expectEqual(restored.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.SUPPLY).available, 48, "JOYCE_SUPPLY_MIGRATED")
expectEqual(restored.store:GetResource("GROUND_NODE_JOYCE", GroundInitialStock.ResourceId.FUEL).available, 40, "JOYCE_FUEL_MIGRATED")
expectEqual(restored.store:GetResource("GROUND_NODE_JOYCE", "GROUND:GROUND_NODE_JOYCE:VEHICLE").available, 20, "JOYCE_VEHICLE_ID_UNCHANGED")

print("PASS Ground transferable resource normalization and legacy snapshot migration")
