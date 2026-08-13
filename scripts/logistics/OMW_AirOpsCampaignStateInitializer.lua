-- Operation Mountain Watch - AirOps initial stock to CampaignState initializer.
--
-- This module is project-domain glue only. It does not access MOOSE or DCS and
-- does not mutate STORAGE. The caller injects the CampaignState module and the
-- approved OMW_AirOpsInitialStock data module.

local Initializer = {}

local TAG = "[OMW][Logistics.AirOpsCampaignStateInitializer]"

Initializer.SchemaVersion = "OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-1"

Initializer.NodeAirbaseName = {
  BAGRAM = "Bagram",
  JALALABAD = "Jalalabad",
  KANDAHAR_MAIN = "Kandahar",
  KANDAHAR_HELI = "Kandahar Heliport",
  SALERNO = "FOB Salerno",
  SHINDAND_HELI = "Shindand Heliport",
  TARINKOT = "Tarinkot",
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requireNonNegativeNumber(value, label)
  if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
    fail(label .. " requires non-negative finite number")
  end
  return value
end

local function copyThresholds(row)
  return {
    target = row.target,
    reorder = row.reorder,
    critical = row.critical,
  }
end

local function validateRow(row, index)
  if type(row) ~= "table" then
    fail("row must be a table index=" .. tostring(index))
  end

  requireNonEmptyString(row.nodeId, "row.nodeId")
  requireNonEmptyString(row.resourceId, "row.resourceId")
  requireNonEmptyString(row.resourceClass, "row.resourceClass")
  requireNonEmptyString(row.supplyParent, "row.supplyParent")
  requireNonEmptyString(row.mappingStatus, "row.mappingStatus")
  requireNonNegativeNumber(row.initial, "row.initial")
  requireNonNegativeNumber(row.target, "row.target")
  requireNonNegativeNumber(row.reorder, "row.reorder")
  requireNonNegativeNumber(row.critical, "row.critical")

  if not Initializer.NodeAirbaseName[row.nodeId] then
    fail("unknown AirOps nodeId=" .. tostring(row.nodeId))
  end

  if row.supplyParent ~= "OFF_MAP" and not Initializer.NodeAirbaseName[row.supplyParent] then
    fail(string.format(
      "unknown supplyParent=%s resourceId=%s",
      tostring(row.supplyParent),
      tostring(row.resourceId)
    ))
  end

  if row.critical > row.reorder or row.reorder > row.target then
    fail(string.format(
      "invalid thresholds nodeId=%s resourceId=%s critical=%s reorder=%s target=%s",
      tostring(row.nodeId),
      tostring(row.resourceId),
      tostring(row.critical),
      tostring(row.reorder),
      tostring(row.target)
    ))
  end
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

function Initializer.BuildInitialState(initialStock)
  if type(initialStock) ~= "table" then
    fail("initialStock module must be a table")
  end
  if type(initialStock.Rows) ~= "table" then
    fail("initialStock.Rows must be a table")
  end

  local nodesById = {}
  local metadataByNode = {}
  local seen = {}

  for index, row in ipairs(initialStock.Rows) do
    validateRow(row, index)

    local uniqueKey = row.nodeId .. "\0" .. row.resourceId
    if seen[uniqueKey] then
      fail(string.format(
        "duplicate Node + Resource ID nodeId=%s resourceId=%s",
        tostring(row.nodeId),
        tostring(row.resourceId)
      ))
    end
    seen[uniqueKey] = true

    local node = nodesById[row.nodeId]
    if not node then
      node = {
        nodeId = row.nodeId,
        airbaseName = Initializer.NodeAirbaseName[row.nodeId],
        resources = {},
      }
      nodesById[row.nodeId] = node
      metadataByNode[row.nodeId] = {}
    end

    node.resources[row.resourceId] = {
      quantity = row.initial,
      unit = "count",
    }

    metadataByNode[row.nodeId][row.resourceId] = {
      resourceClass = row.resourceClass,
      thresholds = copyThresholds(row),
      supplyParent = row.supplyParent,
      mappingStatus = row.mappingStatus,
    }
  end

  if next(nodesById) == nil then
    fail("initialStock.Rows contains no resources")
  end

  local nodes = {}
  for _, nodeId in ipairs(sortedKeys(nodesById)) do
    nodes[#nodes + 1] = nodesById[nodeId]
  end

  return {
    schemaVersion = Initializer.SchemaVersion,
    nodes = nodes,
  }, metadataByNode
end

function Initializer.CreateStore(campaignStateModule, initialStock)
  if type(campaignStateModule) ~= "table" or type(campaignStateModule.New) ~= "function" then
    fail("CampaignState module with New() is required")
  end

  local initialState, metadataByNode = Initializer.BuildInitialState(initialStock)
  local store = campaignStateModule.New(initialState)

  return {
    store = store,
    initialState = initialState,
    metadataByNode = metadataByNode,
    initialStockSchemaVersion = initialStock.SchemaVersion,
    initializerSchemaVersion = Initializer.SchemaVersion,
  }
end

return Initializer
