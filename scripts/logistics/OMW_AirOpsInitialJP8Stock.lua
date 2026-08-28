-- Operation Mountain Watch - approved productive AirOps JP-8 initial stock.
--
-- Owner-approved v0.3-RELEASE baseline for Issue #105. CampaignState remains the
-- sole strategic resource authority. Values are project design values in kg;
-- historical infrastructure/throughput evidence constrains sizing where noted.

local InitialJP8Stock = {}

InitialJP8Stock.SchemaVersion = "OMW-AIROPS-INITIAL-JP8-STOCK-1"
InitialJP8Stock.SourceDecision = "OMW owner decision 2026-08-16"
InitialJP8Stock.Release = "v0.3-RELEASE"
InitialJP8Stock.ResourceId = "FUEL_JP8"
InitialJP8Stock.Unit = "kg"

InitialJP8Stock.Rows = {
  {
    nodeId = "BAGRAM",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 5000000,
    target = 5000000,
    reorder = 2140000,
    critical = 750000,
    supplyParent = "OFF_MAP",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
  {
    nodeId = "KANDAHAR_MAIN",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 3500000,
    target = 3500000,
    reorder = 1500000,
    critical = 525000,
    supplyParent = "OFF_MAP",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
  {
    nodeId = "JALALABAD",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 575000,
    target = 575000,
    reorder = 320000,
    critical = 120000,
    supplyParent = "BAGRAM",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
  {
    nodeId = "KANDAHAR_HELI",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 180000,
    target = 180000,
    reorder = 90000,
    critical = 45000,
    supplyParent = "KANDAHAR_MAIN",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
  {
    nodeId = "SALERNO",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 1200000,
    target = 1200000,
    reorder = 640000,
    critical = 240000,
    supplyParent = "KANDAHAR_MAIN",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
  {
    nodeId = "TARINKOT",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 950000,
    target = 950000,
    reorder = 540000,
    critical = 202500,
    supplyParent = "KANDAHAR_MAIN",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
  {
    nodeId = "SHINDAND_HELI",
    resourceId = "FUEL_JP8",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 450000,
    target = 450000,
    reorder = 195000,
    critical = 65000,
    supplyParent = "KANDAHAR_MAIN",
    mappingStatus = "STORAGE_LIQUID_JETFUEL",
  },
}

-- Planning metadata is documentary only. Runtime CampaignState consumes Rows.
-- Daily values below are sizing assumptions except Bagram's historical reference
-- and Kandahar Heli's documented issue-capability reference.
InitialJP8Stock.Planning = {
  BAGRAM = {
    evidenceClass = "PROJECT_DESIGN_VALUE_CAPACITY_THROUGHPUT_CONSTRAINED",
    dailySizingKg = 713900,
    targetDays = 7.0,
    reorderDays = 3.0,
    criticalDays = 1.05,
    historicalCapacityUsGallons = 2200000,
    historicalThroughputUsGallonsPerDay = 235738,
  },
  KANDAHAR_MAIN = {
    evidenceClass = "PROJECT_DESIGN_VALUE_HUB_RELATION_INTERPOLATED",
    dailySizingKg = 500000,
    targetDays = 7.0,
    reorderDays = 3.0,
    criticalDays = 1.05,
  },
  JALALABAD = {
    evidenceClass = "PROJECT_DESIGN_VALUE_CAPACITY_CONSTRAINED",
    dailySizingKg = 80000,
    targetDays = 7.1875,
    reorderDays = 4.0,
    criticalDays = 1.5,
    historicalFuelPointCapacityUsGallons = 210000,
  },
  KANDAHAR_HELI = {
    evidenceClass = "PROJECT_DESIGN_VALUE_THROUGHPUT_CONSTRAINED",
    dailySizingKg = 45425,
    targetDays = 3.96,
    reorderDays = 2.0,
    criticalDays = 1.0,
    historicalIssueCapacityUsGallonsPerDayMin = 10000,
    historicalIssueCapacityUsGallonsPerDayMax = 15000,
    historicalBladderTypeUsGallons = 50000,
  },
  SALERNO = {
    evidenceClass = "PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED",
    dailySizingKg = 160000,
    targetDays = 7.5,
    reorderDays = 4.0,
    criticalDays = 1.5,
  },
  TARINKOT = {
    evidenceClass = "PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED",
    dailySizingKg = 135000,
    targetDays = 7.04,
    reorderDays = 4.0,
    criticalDays = 1.5,
  },
  SHINDAND_HELI = {
    evidenceClass = "PROJECT_DESIGN_VALUE_OPERATIONAL_INTERPOLATED",
    dailySizingKg = 65000,
    targetDays = 6.92,
    reorderDays = 3.0,
    criticalDays = 1.0,
  },
}

return InitialJP8Stock
