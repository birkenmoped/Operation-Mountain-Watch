-- Operation Mountain Watch - strategic off-map KC-135 pool stock.
--
-- These rows are CampaignState-only strategic resources. OFFMAP_MANAS and
-- OFFMAP_AL_UDEID are logical nodes, not DCS airbases, MOOSE WAREHOUSE objects
-- or AIRWINGs. CampaignState remains the sole strategic authority.
-- AIRCRAFT_KC135_LOST is a cumulative audit counter only; it is never an
-- availability source and never participates in materialization.

local StrategicStock = {}

StrategicStock.SchemaVersion = "OMW-AAR-STRATEGIC-STOCK-2"
StrategicStock.ResourceId = "AIRCRAFT_KC135"
StrategicStock.LossResourceId = "AIRCRAFT_KC135_LOST"
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
}

return StrategicStock
