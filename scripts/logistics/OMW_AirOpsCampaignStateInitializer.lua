-- Operation Mountain Watch - AirOps initial stock to CampaignState initializer.
--
-- This module is project-domain glue only. It does not access MOOSE or DCS and
-- does not mutate STORAGE. The caller injects the CampaignState module and the
-- approved OMW initial-stock data modules.

local Initializer = {}

local TAG = "[OMW][Logistics.AirOpsCampaignStateInitializer]"

Initializer.SchemaVersion = "OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-5"

Initializer.NodeAirbaseName = {
  BAGRAM = "Bagram",
  JALALABAD = "Jalalabad",
  KANDAHAR_MAIN = "Kandahar",
  KANDAHAR_HELI = "Kandahar Heliport",
  SALERNO = "FOB Salerno",
  SHINDAND_HELI = "Shindand Heliport",
  TARINKOT = "Tarinkot",
  OFFMAP_MANAS = "OFF-MAP LOGICAL NODE - MANAS",
  OFFMAP_AL_UDEID = "OFF-MAP LOGICAL NODE - AL UDEID",
  GROUND_NODE_JALALABAD = "GROUND NODE - Jalalabad / FOB Fenty",
  GROUND_NODE_FORTRESS = "GROUND NODE - COP Fortress",
  GROUND_NODE_JOYCE = "GROUND NODE - FOB Joyce",
  GROUND_NODE_WRIGHT = "GROUND NODE - FOB Wright",
  GROUND_NODE_HONAKER = "GROUND NODE - COP Honaker-Miracle",
  GROUND_NODE_BOSTICK = "GROUND NODE - FOB Bostick",
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

local function normalizeUnit(row)
  local unit = row.unit or "count"
  if unit ~= "count" and unit ~= "kg" then
    fail(string.format("unsupported resource unit nodeId=%s resourceId=%s unit=%s", tostring(row.nodeId), tostring(row.resourceId), tostring(unit)))
  end
  return unit
end

local function copyThresholds(row)
  return { target = row.target, reorder = row.reorder, critical = row.critical }
end

local function validateRow(row, index, sourceLabel)
  if type(row) ~= "table" then
    fail(string.format("row must be a table source=%s index=%s", tostring(sourceLabel), tostring(index)))
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
  normalizeUnit(row)
  if not Initializer.NodeAirbaseName[row.nodeId] then fail("unknown CampaignState nodeId=" .. tostring(row.nodeId)) end
  if row.supplyParent ~= "OFF_MAP" and not Initializer.NodeAirbaseName[row.supplyParent] then
    fail(string.format("unknown supplyParent=%s resourceId=%s", tostring(row.supplyParent), tostring(row.resourceId)))
  end
  if row.critical > row.reorder or row.reorder > row.target then
    fail(string.format("invalid thresholds nodeId=%s resourceId=%s critical=%s reorder=%s target=%s", tostring(row.nodeId), tostring(row.resourceId), tostring(row.critical), tostring(row.reorder), tostring(row.target)))
  end
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map) do keys[#keys + 1] = key end
  table.sort(keys)
  return keys
end

local function appendRows(rows, sourceLabel, nodesById, metadataByNode, seen)
  for index, row in ipairs(rows) do
    validateRow(row, index, sourceLabel)
    local uniqueKey = row.nodeId .. "\0" .. row.resourceId
    if seen[uniqueKey] then fail(string.format("duplicate Node + Resource ID nodeId=%s resourceId=%s source=%s", tostring(row.nodeId), tostring(row.resourceId), tostring(sourceLabel))) end
    seen[uniqueKey] = true
    local node = nodesById[row.nodeId]
    if not node then
      node = { nodeId = row.nodeId, airbaseName = Initializer.NodeAirbaseName[row.nodeId], resources = {} }
      nodesById[row.nodeId] = node
      metadataByNode[row.nodeId] = {}
    end
    node.resources[row.resourceId] = { quantity = row.initial, unit = normalizeUnit(row) }
    metadataByNode[row.nodeId][row.resourceId] = {
      resourceClass = row.resourceClass,
      unit = normalizeUnit(row),
      thresholds = copyThresholds(row),
      supplyParent = row.supplyParent,
      mappingStatus = row.mappingStatus,
    }
  end
end

local function validateStockModule(stockModule, label)
  if type(stockModule) ~= "table" then fail(label .. " module must be a table") end
  if type(stockModule.Rows) ~= "table" then fail(label .. ".Rows must be a table") end
end

local function appendAdditionalStocks(additionalStock, nodesById, metadataByNode, seen)
  if additionalStock == nil then return end
  if type(additionalStock) == "table" and type(additionalStock.Rows) == "table" then
    validateStockModule(additionalStock, "additionalStock")
    appendRows(additionalStock.Rows, "additionalStock", nodesById, metadataByNode, seen)
    return
  end
  if type(additionalStock) ~= "table" then fail("additionalStock must be a stock module or an array of stock modules") end
  for index, stockModule in ipairs(additionalStock) do
    local label = string.format("additionalStock[%d]", index)
    validateStockModule(stockModule, label)
    appendRows(stockModule.Rows, label, nodesById, metadataByNode, seen)
  end
end

local function stockModules(initialStock, additionalStock)
  local modules = { initialStock }
  if additionalStock == nil then return modules end
  if type(additionalStock) == "table" and type(additionalStock.Rows) == "table" then
    modules[#modules + 1] = additionalStock
    return modules
  end
  if type(additionalStock) ~= "table" then fail("additionalStock must be a stock module or an array of stock modules") end
  for _, stockModule in ipairs(additionalStock) do modules[#modules + 1] = stockModule end
  return modules
end

local function collectAdditionalSchemaVersions(additionalStock)
  if additionalStock == nil then return {} end
  if type(additionalStock) == "table" and type(additionalStock.Rows) == "table" then return { additionalStock.SchemaVersion } end
  local versions = {}
  for _, stockModule in ipairs(additionalStock) do versions[#versions + 1] = stockModule.SchemaVersion end
  return versions
end

function Initializer.BuildInitialState(initialStock, additionalStock)
  validateStockModule(initialStock, "initialStock")
  local nodesById, metadataByNode, seen = {}, {}, {}
  appendRows(initialStock.Rows, "initialStock", nodesById, metadataByNode, seen)
  appendAdditionalStocks(additionalStock, nodesById, metadataByNode, seen)
  if next(nodesById) == nil then fail("initial-stock data contains no resources") end
  local nodes = {}
  for _, nodeId in ipairs(sortedKeys(nodesById)) do nodes[#nodes + 1] = nodesById[nodeId] end
  return { schemaVersion = Initializer.SchemaVersion, nodes = nodes }, metadataByNode
end

function Initializer.MigrateSnapshot(snapshot, initialStock, additionalStock)
  if type(snapshot) ~= "table" then fail("snapshot must be a table") end
  validateStockModule(initialStock, "initialStock")
  local migrated = snapshot
  for index, stockModule in ipairs(stockModules(initialStock, additionalStock)) do
    validateStockModule(stockModule, "stockModules[" .. tostring(index) .. "]")
    if stockModule.MigrateSnapshot ~= nil then
      if type(stockModule.MigrateSnapshot) ~= "function" then fail("stock module MigrateSnapshot must be a function index=" .. tostring(index)) end
      migrated = stockModule.MigrateSnapshot(migrated)
      if type(migrated) ~= "table" then fail("stock module MigrateSnapshot must return a snapshot table index=" .. tostring(index)) end
    end
  end
  return migrated
end

function Initializer.CreateStore(campaignStateModule, initialStock, additionalStock)
  if type(campaignStateModule) ~= "table" or type(campaignStateModule.New) ~= "function" then fail("CampaignState module with New() is required") end
  local initialState, metadataByNode = Initializer.BuildInitialState(initialStock, additionalStock)
  local store = campaignStateModule.New(initialState)
  local additionalSchemaVersions = collectAdditionalSchemaVersions(additionalStock)
  return {
    store = store,
    initialState = initialState,
    metadataByNode = metadataByNode,
    initialStockSchemaVersion = initialStock.SchemaVersion,
    additionalStockSchemaVersion = #additionalSchemaVersions == 1 and additionalSchemaVersions[1] or nil,
    additionalStockSchemaVersions = additionalSchemaVersions,
    initializerSchemaVersion = Initializer.SchemaVersion,
  }
end

function Initializer.RestoreStore(campaignStateModule, snapshot, initialStock, additionalStock)
  if type(campaignStateModule) ~= "table" or type(campaignStateModule.Restore) ~= "function" then fail("CampaignState module with Restore() is required") end
  local migratedSnapshot = Initializer.MigrateSnapshot(snapshot, initialStock, additionalStock)
  local store = campaignStateModule.Restore(migratedSnapshot)
  local additionalSchemaVersions = collectAdditionalSchemaVersions(additionalStock)
  return {
    store = store,
    migratedSnapshot = migratedSnapshot,
    initialStockSchemaVersion = initialStock.SchemaVersion,
    additionalStockSchemaVersion = #additionalSchemaVersions == 1 and additionalSchemaVersions[1] or nil,
    additionalStockSchemaVersions = additionalSchemaVersions,
    initializerSchemaVersion = Initializer.SchemaVersion,
  }
end

return Initializer
