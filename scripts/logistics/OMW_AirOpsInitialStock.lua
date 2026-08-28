-- Operation Mountain Watch - AirOps strategic initial stock runtime data.
--
-- This module is pure project data. It has no MOOSE/DCS dependency and performs
-- no CampaignState or STORAGE mutation. CampaignState remains the strategic
-- authority once the approved start state is instantiated by a separate adapter.
--
-- Source baseline:
-- data/logistics/air-operations-initial-store-stock-v20.csv

local InitialStock = {}

InitialStock.SchemaVersion = "OMW-AIROPS-INITIAL-STOCK-1"
InitialStock.SourceBaseline = "air-operations-initial-store-stock-v20.csv"

InitialStock.Rows = {
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_AIM120", resourceClass = "DEPLOYMENT_FINITE_STOCK", initial = 52, target = 52, reorder = 0, critical = 0, supplyParent = "OFF_MAP", mappingStatus = "VALIDATED_OR_EXPLICITLY_UNRESOLVED_BY_VARIANT" },
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_AIM9", resourceClass = "DEPLOYMENT_FINITE_STOCK", initial = 26, target = 26, reorder = 0, critical = 0, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_VALIDATED" },
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_GBU12", resourceClass = "CONSUMABLE_STRATEGIC", initial = 102, target = 102, reorder = 84, critical = 36, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_GBU31_V1", resourceClass = "CONSUMABLE_STRATEGIC", initial = 43, target = 43, reorder = 36, critical = 16, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_VALIDATED" },
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_GBU31_V3", resourceClass = "CONSUMABLE_STRATEGIC", initial = 43, target = 43, reorder = 36, critical = 16, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_VALIDATED" },
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_GBU38", resourceClass = "CONSUMABLE_STRATEGIC", initial = 216, target = 216, reorder = 180, critical = 84, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "BAGRAM", resourceId = "AMMUNITION_GBU54", resourceClass = "CONSUMABLE_STRATEGIC", initial = 120, target = 120, reorder = 96, critical = 48, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "BAGRAM", resourceId = "EQUIPMENT_AAQ13", resourceClass = "RETURNABLE_STRATEGIC_EQUIPMENT", initial = 16, target = 16, reorder = 13, critical = 10, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "BAGRAM", resourceId = "EQUIPMENT_AAQ14", resourceClass = "RETURNABLE_STRATEGIC_EQUIPMENT", initial = 16, target = 16, reorder = 13, critical = 10, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "BAGRAM", resourceId = "EQUIPMENT_AAQ33", resourceClass = "RETURNABLE_STRATEGIC_EQUIPMENT", initial = 16, target = 16, reorder = 13, critical = 10, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "JALALABAD", resourceId = "AMMUNITION_30MM_M230", resourceClass = "CONSUMABLE_STRATEGIC", initial = 7920, target = 7920, reorder = 6480, critical = 2880, supplyParent = "BAGRAM", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "JALALABAD", resourceId = "AMMUNITION_50CAL_M3P", resourceClass = "CONSUMABLE_STRATEGIC", initial = 44640, target = 44640, reorder = 36000, critical = 14400, supplyParent = "BAGRAM", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "JALALABAD", resourceId = "AMMUNITION_HELLFIRE", resourceClass = "CONSUMABLE_STRATEGIC", initial = 54, target = 54, reorder = 44, critical = 20, supplyParent = "BAGRAM", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "JALALABAD", resourceId = "AMMUNITION_ROCKETS_70MM", resourceClass = "CONSUMABLE_STRATEGIC", initial = 1575, target = 1575, reorder = 1287, critical = 567, supplyParent = "BAGRAM", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "KANDAHAR_HELI", resourceId = "AMMUNITION_30MM_M230", resourceClass = "CONSUMABLE_STRATEGIC", initial = 12960, target = 12960, reorder = 10080, critical = 3600, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_HELI", resourceId = "AMMUNITION_50CAL_M3P", resourceClass = "CONSUMABLE_STRATEGIC", initial = 49920, target = 49920, reorder = 38400, critical = 14400, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_HELI", resourceId = "AMMUNITION_HELLFIRE", resourceClass = "CONSUMABLE_STRATEGIC", initial = 88, target = 88, reorder = 68, critical = 24, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_HELI", resourceId = "AMMUNITION_ROCKETS_70MM", resourceClass = "CONSUMABLE_STRATEGIC", initial = 2113, target = 2113, reorder = 1652, critical = 653, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_30MM_GAU8", resourceClass = "CONSUMABLE_STRATEGIC", initial = 37375, target = 37375, reorder = 33350, critical = 22425, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_AGM65D", resourceClass = "CONSUMABLE_STRATEGIC", initial = 26, target = 26, reorder = 24, critical = 20, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_GBU12", resourceClass = "CONSUMABLE_STRATEGIC", initial = 12, target = 12, reorder = 12, critical = 6, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_GBU38", resourceClass = "CONSUMABLE_STRATEGIC", initial = 156, target = 156, reorder = 132, critical = 78, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_HELLFIRE", resourceClass = "CONSUMABLE_STRATEGIC", initial = 56, target = 56, reorder = 46, critical = 20, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_LUU2B", resourceClass = "CONSUMABLE_STRATEGIC", initial = 232, target = 232, reorder = 208, critical = 156, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "AMMUNITION_ROCKETS_70MM", resourceClass = "CONSUMABLE_STRATEGIC", initial = 212, target = 212, reorder = 192, critical = 136, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "EQUIPMENT_AAQ28", resourceClass = "RETURNABLE_STRATEGIC_EQUIPMENT", initial = 20, target = 20, reorder = 16, critical = 12, supplyParent = "OFF_MAP", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "SALERNO", resourceId = "AMMUNITION_30MM_M230", resourceClass = "CONSUMABLE_STRATEGIC", initial = 6480, target = 6480, reorder = 5040, critical = 2880, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "SALERNO", resourceId = "AMMUNITION_50CAL_M3P", resourceClass = "CONSUMABLE_STRATEGIC", initial = 12000, target = 12000, reorder = 9120, critical = 4800, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "SALERNO", resourceId = "AMMUNITION_HELLFIRE", resourceClass = "CONSUMABLE_STRATEGIC", initial = 44, target = 44, reorder = 34, critical = 20, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "SALERNO", resourceId = "AMMUNITION_ROCKETS_70MM", resourceClass = "CONSUMABLE_STRATEGIC", initial = 865, target = 865, reorder = 692, critical = 433, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "SHINDAND_HELI", resourceId = "AMMUNITION_30MM_M230", resourceClass = "CONSUMABLE_STRATEGIC", initial = 6480, target = 6480, reorder = 5040, critical = 2880, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "SHINDAND_HELI", resourceId = "AMMUNITION_HELLFIRE", resourceClass = "CONSUMABLE_STRATEGIC", initial = 44, target = 44, reorder = 34, critical = 20, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "SHINDAND_HELI", resourceId = "AMMUNITION_ROCKETS_70MM", resourceClass = "CONSUMABLE_STRATEGIC", initial = 653, target = 653, reorder = 538, critical = 365, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "TARINKOT", resourceId = "AMMUNITION_30MM_M230", resourceClass = "CONSUMABLE_STRATEGIC", initial = 11340, target = 11340, reorder = 8820, critical = 5040, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "TARINKOT", resourceId = "AMMUNITION_HELLFIRE", resourceClass = "CONSUMABLE_STRATEGIC", initial = 76, target = 76, reorder = 60, critical = 34, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },
  { nodeId = "TARINKOT", resourceId = "AMMUNITION_ROCKETS_70MM", resourceClass = "CONSUMABLE_STRATEGIC", initial = 1143, target = 1143, reorder = 941, critical = 639, supplyParent = "KANDAHAR_MAIN", mappingStatus = "RUNTIME_MAPPING_MIXED_SEE_WEAPON_STOCK" },

  { nodeId = "BAGRAM", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 16369, target = 16369, reorder = 14427, critical = 9576, supplyParent = "OFF_MAP", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
  { nodeId = "JALALABAD", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 6173, target = 6173, reorder = 5724, critical = 4608, supplyParent = "BAGRAM", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
  { nodeId = "KANDAHAR_HELI", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 13597, target = 13597, reorder = 12096, critical = 8352, supplyParent = "KANDAHAR_MAIN", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
  { nodeId = "KANDAHAR_MAIN", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 17134, target = 17134, reorder = 14994, critical = 9648, supplyParent = "OFF_MAP", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
  { nodeId = "SALERNO", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 4428, target = 4428, reorder = 4100, critical = 3600, supplyParent = "KANDAHAR_MAIN", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
  { nodeId = "SHINDAND_HELI", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 3168, target = 3168, reorder = 2941, critical = 2592, supplyParent = "KANDAHAR_MAIN", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
  { nodeId = "TARINKOT", resourceId = "FLARES_CHAFF", resourceClass = "CONSUMABLE_STRATEGIC", initial = 3114, target = 3114, reorder = 2880, critical = 2520, supplyParent = "KANDAHAR_MAIN", mappingStatus = "PLANNING_MAPPING_SEPARATE_COUNTERMEASURES" },
}

return InitialStock
