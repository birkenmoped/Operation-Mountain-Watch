-- Operation Mountain Watch - ARMY Ground strategic initial stock runtime data.
--
-- Pure CampaignState input data. This module has no MOOSE/DCS dependency and
-- creates no independent store. It is intended to be composed into the single
-- authoritative CampaignState initial state through the existing initializer.
--
-- Source baseline:
-- docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md

local InitialStock = {}

InitialStock.SchemaVersion = "OMW-GROUND-INITIAL-STOCK-1"
InitialStock.Unit = "count"

local function row(nodeId, resourceClass, initial, supplyParent)
  return {
    nodeId = nodeId,
    resourceId = "GROUND:" .. nodeId .. ":" .. resourceClass,
    resourceClass = "GROUND_" .. resourceClass,
    unit = InitialStock.Unit,
    initial = initial,
    target = initial,
    reorder = 0,
    critical = 0,
    supplyParent = supplyParent,
    mappingStatus = "OMW_GROUND_DESIGN_STOCK",
  }
end

local function lossRow(nodeId, resourceClass, supplyParent)
  return {
    nodeId = nodeId,
    resourceId = "GROUND:" .. nodeId .. ":" .. resourceClass .. "_LOST",
    resourceClass = "GROUND_" .. resourceClass .. "_LOSS_AUDIT",
    unit = InitialStock.Unit,
    initial = 0,
    target = 0,
    reorder = 0,
    critical = 0,
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

InitialStock.Rows = {}

appendNode(InitialStock.Rows, "GROUND_NODE_JALALABAD", 480, 48, 120, 100, 120, "OFF_MAP")
appendNode(InitialStock.Rows, "GROUND_NODE_JOYCE", 180, 20, 48, 44, 40, "GROUND_NODE_JALALABAD")
appendNode(InitialStock.Rows, "GROUND_NODE_WRIGHT", 120, 22, 36, 30, 36, "GROUND_NODE_JALALABAD")
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
