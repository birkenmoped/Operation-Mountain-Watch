-- Operation Mountain Watch - strategic off-map air-support pool stock.
--
-- These rows are CampaignState-only strategic resources. OFFMAP_MANAS,
-- OFFMAP_AL_UDEID and OFFMAP_AL_DHAFRA are logical nodes, not DCS airbases,
-- MOOSE WAREHOUSE objects or AIRWINGs. CampaignState remains the sole
-- strategic authority.
--
-- The E-3 quantity is an OMW design stock for the physical lifecycle
-- (one active aircraft plus one possible relief), not a historical claim about
-- the number of 964th EAACS aircraft deployed at Al Dhafra.

local StrategicStock = {}

-- Keep the accepted AAR schema marker for existing production validators.
-- ExtendedSchemaVersion records the additive AWACS resource extension.
StrategicStock.SchemaVersion = "OMW-AAR-STRATEGIC-STOCK-2"
StrategicStock.ExtendedSchemaVersion = "OMW-OFFMAP-AIR-SUPPORT-STOCK-3"
StrategicStock.ResourceId = "AIRCRAFT_KC135"
StrategicStock.LossResourceId = "AIRCRAFT_KC135_LOST"
StrategicStock.AwacsResourceId = "AIRCRAFT_E3A_AWACS"
StrategicStock.AwacsLossResourceId = "AIRCRAFT_E3A_AWACS_LOST"
StrategicStock.Unit = "count"

StrategicStock.Rows = {
  {
    nodeId = "OFFMAP_MANAS",
    resourceId = StrategicStock.ResourceId,
    resourceClass = "AIRCRAFT_POOL_STRATEGIC",
    unit = StrategicStock.Unit,
    initial = 16,
    target = 16,
    reorder = 0,
    critical = 0,
    supplyParent = "OFF_MAP",
    mappingStatus = "OMW_DESIGN_STOCK",
  },
  {
    nodeId = "OFFMAP_MANAS",
    resourceId = StrategicStock.LossResourceId,
    resourceClass = "AIRCRAFT_LOSS_AUDIT",
    unit = StrategicStock.Unit,
    initial = 0,
    target = 0,
    reorder = 0,
    critical = 0,
    supplyParent = "OFF_MAP",
    mappingStatus = "OMW_RUNTIME_AUDIT",
  },
  {
    nodeId = "OFFMAP_AL_UDEID",
    resourceId = StrategicStock.ResourceId,
    resourceClass = "AIRCRAFT_POOL_STRATEGIC",
    unit = StrategicStock.Unit,
    initial = 40,
    target = 40,
    reorder = 0,
    critical = 0,
    supplyParent = "OFF_MAP",
    mappingStatus = "OMW_DESIGN_STOCK",
  },
  {
    nodeId = "OFFMAP_AL_UDEID",
    resourceId = StrategicStock.LossResourceId,
    resourceClass = "AIRCRAFT_LOSS_AUDIT",
    unit = StrategicStock.Unit,
    initial = 0,
    target = 0,
    reorder = 0,
    critical = 0,
    supplyParent = "OFF_MAP",
    mappingStatus = "OMW_RUNTIME_AUDIT",
  },
  {
    nodeId = "OFFMAP_AL_DHAFRA",
    resourceId = StrategicStock.AwacsResourceId,
    resourceClass = "AIRCRAFT_POOL_STRATEGIC",
    unit = StrategicStock.Unit,
    initial = 2,
    target = 2,
    reorder = 0,
    critical = 0,
    supplyParent = "OFF_MAP",
    mappingStatus = "OMW_DESIGN_STOCK_NOT_HISTORICAL_ORBAT",
  },
  {
    nodeId = "OFFMAP_AL_DHAFRA",
    resourceId = StrategicStock.AwacsLossResourceId,
    resourceClass = "AIRCRAFT_LOSS_AUDIT",
    unit = StrategicStock.Unit,
    initial = 0,
    target = 0,
    reorder = 0,
    critical = 0,
    supplyParent = "OFF_MAP",
    mappingStatus = "OMW_RUNTIME_AUDIT",
  },
}

return StrategicStock
