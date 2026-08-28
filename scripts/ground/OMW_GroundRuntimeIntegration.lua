-- Operation Mountain Watch - production ARMY Ground CampaignState composition boundary.
--
-- The caller owns creation or restoration of the single authoritative
-- CampaignState store. This module validates the approved ground stock contract,
-- binds that store to the validated GroundCampaignStateAdapter and performs the
-- restart reconciliation only for restored state. It contains no MOOSE/DCS calls.

local Integration = {}

local TAG = "[OMW][Ground.RuntimeIntegration]"

Integration.SchemaVersion = "OMW-GROUND-RUNTIME-INTEGRATION-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(container, name, label)
  if type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
end

local function validateStockModule(stock)
  requireTable(stock, "groundInitialStock")
  requireTable(stock.Rows, "groundInitialStock.Rows")
  if type(stock.SchemaVersion) ~= "string" or stock.SchemaVersion == "" then
    fail("groundInitialStock.SchemaVersion is required")
  end
end

local function validateStoreApi(store)
  requireTable(store, "store")
  requireFunction(store, "GetResource", "store")
  requireFunction(store, "ReserveResource", "store")
  requireFunction(store, "Consume", "store")
  requireFunction(store, "CompleteConsumption", "store")
  requireFunction(store, "MarkConsumptionCompensated", "store")
  requireFunction(store, "CreditResourceOnce", "store")
  requireFunction(store, "GetResourceCredit", "store")
  requireFunction(store, "ExportSnapshot", "store")
end

local function validateGroundResources(store, stock, requireInitialQuantities)
  local checked = 0
  for _, row in ipairs(stock.Rows) do
    local resource = store:GetResource(row.nodeId, row.resourceId)
    if resource.canonicalUnit ~= (row.unit or "count") then
      fail(string.format(
        "ground resource unit mismatch nodeId=%s resourceId=%s expected=%s actual=%s",
        row.nodeId, row.resourceId, tostring(row.unit or "count"), tostring(resource.canonicalUnit)
      ))
    end
    if requireInitialQuantities then
      if resource.quantity ~= row.initial or resource.reserved ~= 0 or resource.available ~= row.initial then
        fail(string.format(
          "ground initial quantity mismatch nodeId=%s resourceId=%s quantity=%s reserved=%s available=%s expected=%s",
          row.nodeId,
          row.resourceId,
          tostring(resource.quantity),
          tostring(resource.reserved),
          tostring(resource.available),
          tostring(row.initial)
        ))
      end
    end
    checked = checked + 1
  end
  return checked
end

function Integration.Attach(spec)
  requireTable(spec, "spec")

  local store = spec.store
  validateStoreApi(store)
  local campaignState = requireTable(spec.campaignState, "campaignState")
  local adapterModule = requireTable(spec.adapterModule, "adapterModule")
  local ammoRearmAdapterModule = requireTable(spec.ammoRearmAdapterModule, "ammoRearmAdapterModule")
  local groundInitialStock = requireTable(spec.groundInitialStock, "groundInitialStock")

  validateStockModule(groundInitialStock)
  requireFunction(adapterModule, "New", "adapterModule")
  requireFunction(ammoRearmAdapterModule, "ReconcileRestore", "ammoRearmAdapterModule")

  local restored = spec.restored == true
  local checkedResources = validateGroundResources(store, groundInitialStock, not restored)
  local adapter = adapterModule.New(store, campaignState)
  local reconciliation = nil
  local localRearmReconciliation = nil

  if restored then
    requireFunction(adapter, "ReconcileRestore", "adapter")
    reconciliation = adapter:ReconcileRestore()
    localRearmReconciliation = ammoRearmAdapterModule.ReconcileRestore(store, campaignState)
  end

  return {
    store = store,
    campaignState = campaignState,
    adapter = adapter,
    restored = restored,
    reconciliation = reconciliation,
    localRearmReconciliation = localRearmReconciliation,
    checkedResources = checkedResources,
    groundInitialStockSchemaVersion = groundInitialStock.SchemaVersion,
    schemaVersion = Integration.SchemaVersion,
  }
end

return Integration