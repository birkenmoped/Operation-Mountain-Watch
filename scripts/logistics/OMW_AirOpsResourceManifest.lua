-- Operation Mountain Watch - AirOps strategic resource and STORAGE mapping manifest.
--
-- This module contains only mappings and classification metadata established by
-- existing OMW decisions and runtime evidence. It does not read or mutate DCS,
-- MOOSE STORAGE, or CampaignState.

local AirOpsResourceManifest = {}

AirOpsResourceManifest.Class = {
  CONSUMABLE_STRATEGIC = "CONSUMABLE_STRATEGIC",
  RETURNABLE_STRATEGIC = "RETURNABLE_STRATEGIC",
  TECHNICAL_NON_STRATEGIC = "TECHNICAL_NON_STRATEGIC",
  TELEMETRY_ONLY = "TELEMETRY_ONLY",
  STORE_WITHOUT_ROUND_CONVERSION = "STORE_WITHOUT_ROUND_CONVERSION",
  MAPPING_OBSERVED_NO_STRATEGIC_ID = "MAPPING_OBSERVED_NO_STRATEGIC_ID",
}

AirOpsResourceManifest.Unit = {
  KG = "kg",
  COUNT = "count",
}

AirOpsResourceManifest.ResourceId = {
  JP8 = "FUEL_JP8",
  AVGAS = "FUEL_AVGAS",
  HELLFIRE = "AMMUNITION_HELLFIRE",
  ROCKETS_70MM = "AMMUNITION_ROCKETS_70MM",
  M230 = "AMMUNITION_30MM_M230",
  GAU8 = "AMMUNITION_30MM_GAU8",
  M3P = "AMMUNITION_50CAL_M3P",
}

local entries = {
  {
    key = "FUEL_JP8",
    resourceId = AirOpsResourceManifest.ResourceId.JP8,
    class = AirOpsResourceManifest.Class.CONSUMABLE_STRATEGIC,
    canonicalUnit = AirOpsResourceManifest.Unit.KG,
    storageKind = "LIQUID",
    storageLiquidName = "JETFUEL",
    reconciliationEligible = true,
    mappingScope = "COMPLETE_RESOURCE",
    returnSemantics = "NATIVE_DCS_STORAGE_DEBIT_AND_RETURN",
  },
  {
    key = "FUEL_AVGAS",
    resourceId = AirOpsResourceManifest.ResourceId.AVGAS,
    class = AirOpsResourceManifest.Class.CONSUMABLE_STRATEGIC,
    canonicalUnit = AirOpsResourceManifest.Unit.KG,
    storageKind = "LIQUID",
    storageLiquidName = "GASOLINE",
    reconciliationEligible = true,
    mappingScope = "COMPLETE_RESOURCE",
    returnSemantics = "NATIVE_DCS_STORAGE_DEBIT_AND_RETURN",
  },
  {
    key = "AH64_AGM_114K",
    resourceId = AirOpsResourceManifest.ResourceId.HELLFIRE,
    class = AirOpsResourceManifest.Class.RETURNABLE_STRATEGIC,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = "ITEM",
    storageItemName = "weapons.missiles.AGM_114K",
    reconciliationEligible = false,
    mappingScope = "VALIDATED_PAYLOAD_VARIANT_ONLY",
    returnSemantics = "UNUSED_STORE_NATIVE_RECREDIT_VALIDATED",
  },
  {
    key = "AH64_HYDRA_70_M151",
    resourceId = AirOpsResourceManifest.ResourceId.ROCKETS_70MM,
    class = AirOpsResourceManifest.Class.RETURNABLE_STRATEGIC,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = "ITEM",
    storageItemName = "weapons.nurs.HYDRA_70_M151",
    reconciliationEligible = false,
    mappingScope = "VALIDATED_PAYLOAD_VARIANT_ONLY",
    returnSemantics = "UNUSED_STORE_NATIVE_RECREDIT_VALIDATED",
  },
  {
    key = "AH64_M230",
    resourceId = AirOpsResourceManifest.ResourceId.M230,
    class = AirOpsResourceManifest.Class.TELEMETRY_ONLY,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "NO_DIRECT_STORAGE_MIRROR",
    returnSemantics = "ONBOARD_AMMO_TELEMETRY_ONLY",
  },
  {
    key = "A10_GAU8",
    resourceId = AirOpsResourceManifest.ResourceId.GAU8,
    class = AirOpsResourceManifest.Class.TELEMETRY_ONLY,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "NO_DIRECT_STORAGE_MIRROR",
    returnSemantics = "ONBOARD_AMMO_TELEMETRY_ONLY",
  },
  {
    key = "OH58_M3P",
    resourceId = AirOpsResourceManifest.ResourceId.M3P,
    class = AirOpsResourceManifest.Class.STORE_WITHOUT_ROUND_CONVERSION,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "CONTAINER_PATH_VISIBLE_NO_ROUND_CONVERSION",
    returnSemantics = "NO_DIRECT_ROUND_STORAGE_RECONCILIATION",
  },
  {
    key = "AH64_IAFS_COMBOPAK_100",
    resourceId = nil,
    class = AirOpsResourceManifest.Class.TECHNICAL_NON_STRATEGIC,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = "ITEM",
    storageItemName = "weapons.droptanks.{IAFS_ComboPak_100}",
    reconciliationEligible = false,
    mappingScope = "OBSERVED_TECHNICAL_ITEM",
    returnSemantics = "NO_NATIVE_RECREDIT_OBSERVED_NON_STRATEGIC",
  },
  {
    key = "F16_370GAL_TANK",
    resourceId = nil,
    class = AirOpsResourceManifest.Class.MAPPING_OBSERVED_NO_STRATEGIC_ID,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = "ITEM",
    storageItemName = "weapons.droptanks.fuel_tank_370gal",
    reconciliationEligible = false,
    mappingScope = "OBSERVED_RETURNABLE_ITEM_NO_OWNER_APPROVED_RESOURCE_ID",
    returnSemantics = "NATIVE_RECREDIT_VALIDATED",
  },
  {
    key = "F16_M61",
    resourceId = nil,
    class = AirOpsResourceManifest.Class.TELEMETRY_ONLY,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "REAL_EXPENDITURE_OBSERVED_NO_STRATEGIC_RESOURCE_MAPPING",
    returnSemantics = "ONBOARD_AMMO_TELEMETRY_ONLY",
  },
  {
    key = "F15E_M61",
    resourceId = nil,
    class = AirOpsResourceManifest.Class.TELEMETRY_ONLY,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "REAL_EXPENDITURE_OBSERVED_NO_STRATEGIC_RESOURCE_MAPPING",
    returnSemantics = "ONBOARD_AMMO_TELEMETRY_ONLY",
  },
  {
    key = "CH47_M60D",
    resourceId = nil,
    class = AirOpsResourceManifest.Class.STORE_WITHOUT_ROUND_CONVERSION,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "PORT_STBD_CONTAINER_DEBIT_RECREDIT_NO_ROUND_CONVERSION",
    returnSemantics = "CONTAINER_RETURN_OBSERVED_ROUND_CONSUMPTION_UNRESOLVED",
  },
  {
    key = "UH60_DOOR_GUNS",
    resourceId = nil,
    class = AirOpsResourceManifest.Class.TELEMETRY_ONLY,
    canonicalUnit = AirOpsResourceManifest.Unit.COUNT,
    storageKind = nil,
    reconciliationEligible = false,
    mappingScope = "GETAMMOTOT_ZERO_IN_DOCUMENTED_TEST_SCOPE",
    returnSemantics = "NO_STORAGE_ROUND_MAPPING_ESTABLISHED",
  },
}

local function copyEntry(entry)
  local result = {}
  for key, value in pairs(entry) do
    result[key] = value
  end
  return result
end

function AirOpsResourceManifest.GetEntries()
  local result = {}
  for index, entry in ipairs(entries) do
    result[index] = copyEntry(entry)
  end
  return result
end

function AirOpsResourceManifest.GetEntry(key)
  for _, entry in ipairs(entries) do
    if entry.key == key then
      return copyEntry(entry)
    end
  end
  return nil
end

function AirOpsResourceManifest.GetReconciliationEntries()
  local result = {}
  for _, entry in ipairs(entries) do
    if entry.reconciliationEligible then
      result[#result + 1] = copyEntry(entry)
    end
  end
  return result
end

function AirOpsResourceManifest.GetObservedStorageEntries()
  local result = {}
  for _, entry in ipairs(entries) do
    if entry.storageKind ~= nil then
      result[#result + 1] = copyEntry(entry)
    end
  end
  return result
end

return AirOpsResourceManifest
