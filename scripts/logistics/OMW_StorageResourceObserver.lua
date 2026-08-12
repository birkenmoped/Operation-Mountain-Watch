-- Operation Mountain Watch - read-only MOOSE STORAGE resource observer.
--
-- The observer reads only public MOOSE STORAGE APIs and compares complete,
-- reconciliation-eligible mappings with CampaignState. It never writes STORAGE,
-- never mutates CampaignState, and does not schedule or own lifecycle events.

local StorageResourceObserver = {}

local Observer = {}
Observer.__index = Observer

local TAG = "[OMW][Logistics.StorageResourceObserver]"

StorageResourceObserver.Status = {
  MATCH = "MATCH",
  DRIFT = "DRIFT",
  UNAVAILABLE = "UNAVAILABLE",
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

local function isFiniteNonNegative(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

local function isFiniteNonNegativeTolerance(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

local function requireMooseStorageApi()
  if type(STORAGE) ~= "table" then
    fail("MOOSE STORAGE class is unavailable")
  end
  if type(STORAGE.FindByName) ~= "function" then
    fail("STORAGE:FindByName() is unavailable")
  end
end

local function resolveStorage(airbaseName)
  requireMooseStorageApi()

  local storage = STORAGE:FindByName(airbaseName)
  if not storage and AIRBASE and AIRBASE.FindByName then
    local airbase = AIRBASE:FindByName(airbaseName)
    if airbase and airbase.GetStorage then
      storage = airbase:GetStorage()
    end
  end

  if not storage then
    fail("No MOOSE STORAGE wrapper found for airbaseName=" .. tostring(airbaseName))
  end

  return storage
end

local function resolveLiquidType(entry)
  if type(STORAGE.Liquid) ~= "table" then
    fail("MOOSE STORAGE liquid enumerators are unavailable")
  end
  local liquidType = STORAGE.Liquid[entry.storageLiquidName]
  if liquidType == nil then
    fail("Unknown STORAGE liquid name=" .. tostring(entry.storageLiquidName))
  end
  return liquidType
end

local function readEntry(storage, entry, nodeId)
  local methodName
  local argument

  if entry.storageKind == "LIQUID" then
    methodName = "GetLiquidAmount"
    argument = resolveLiquidType(entry)
  elseif entry.storageKind == "ITEM" then
    methodName = "GetItemAmount"
    argument = entry.storageItemName
  else
    fail("Unsupported storageKind=" .. tostring(entry.storageKind))
  end

  if type(storage[methodName]) ~= "function" then
    fail("Resolved STORAGE wrapper lacks method=" .. tostring(methodName))
  end

  local ok, amount = pcall(function()
    return storage[methodName](storage, argument)
  end)
  if not ok then
    fail(string.format(
      "STORAGE read failed nodeId=%s key=%s error=%s",
      tostring(nodeId),
      tostring(entry.key),
      tostring(amount)
    ))
  end
  if not isFiniteNonNegative(amount) then
    fail(string.format(
      "STORAGE returned invalid quantity nodeId=%s key=%s value=%s",
      tostring(nodeId),
      tostring(entry.key),
      tostring(amount)
    ))
  end

  return amount
end

local function toleranceFor(entry, tolerances)
  if tolerances == nil then
    return 0
  end
  if type(tolerances) ~= "table" then
    fail("tolerances must be a table when provided")
  end

  local value = tolerances[entry.resourceId]
  if value == nil then
    value = tolerances[entry.canonicalUnit]
  end
  if value == nil then
    return 0
  end
  if not isFiniteNonNegativeTolerance(value) then
    fail("invalid tolerance resourceId=" .. tostring(entry.resourceId))
  end
  return value
end

function StorageResourceObserver.New(manifest)
  if type(manifest) ~= "table" or type(manifest.GetObservedStorageEntries) ~= "function"
      or type(manifest.GetReconciliationEntries) ~= "function" then
    fail("manifest requires GetObservedStorageEntries() and GetReconciliationEntries()")
  end

  return setmetatable({
    manifest = manifest,
  }, Observer)
end

function Observer:ReadNode(nodeId, airbaseName)
  requireNonEmptyString(nodeId, "nodeId")
  requireNonEmptyString(airbaseName, "airbaseName")

  local storage = resolveStorage(airbaseName)
  local result = {
    nodeId = nodeId,
    airbaseName = airbaseName,
    resources = {},
    variants = {},
  }

  for _, entry in ipairs(self.manifest.GetObservedStorageEntries()) do
    local observation = {
      key = entry.key,
      resourceId = entry.resourceId,
      canonicalUnit = entry.canonicalUnit,
      class = entry.class,
      mappingScope = entry.mappingScope,
      quantity = readEntry(storage, entry, nodeId),
      reconciliationEligible = entry.reconciliationEligible == true,
    }

    if observation.reconciliationEligible and observation.resourceId ~= nil then
      result.resources[observation.resourceId] = observation
    else
      result.variants[observation.key] = observation
    end
  end

  return result
end

function Observer:CompareNode(campaignStateStore, nodeId, airbaseName, tolerances)
  if type(campaignStateStore) ~= "table" or type(campaignStateStore.GetResource) ~= "function" then
    fail("campaignStateStore requires GetResource()")
  end

  local observed = self:ReadNode(nodeId, airbaseName)
  local comparison = {
    nodeId = nodeId,
    airbaseName = airbaseName,
    entries = {},
    matchCount = 0,
    driftCount = 0,
  }

  for _, manifestEntry in ipairs(self.manifest.GetReconciliationEntries()) do
    local observation = observed.resources[manifestEntry.resourceId]
    if observation then
      local ok, strategic = pcall(function()
        return campaignStateStore:GetResource(nodeId, manifestEntry.resourceId)
      end)

      local resultEntry = {
        resourceId = manifestEntry.resourceId,
        canonicalUnit = manifestEntry.canonicalUnit,
        observedQuantity = observation.quantity,
        strategicQuantity = nil,
        delta = nil,
        tolerance = toleranceFor(manifestEntry, tolerances),
        status = StorageResourceObserver.Status.UNAVAILABLE,
      }

      if ok and type(strategic) == "table" and isFiniteNonNegative(strategic.quantity) then
        if strategic.canonicalUnit ~= manifestEntry.canonicalUnit then
          fail("CampaignState unit mismatch resourceId=" .. tostring(manifestEntry.resourceId))
        end

        resultEntry.strategicQuantity = strategic.quantity
        resultEntry.delta = observation.quantity - strategic.quantity
        if math.abs(resultEntry.delta) <= resultEntry.tolerance then
          resultEntry.status = StorageResourceObserver.Status.MATCH
          comparison.matchCount = comparison.matchCount + 1
        else
          resultEntry.status = StorageResourceObserver.Status.DRIFT
          comparison.driftCount = comparison.driftCount + 1
        end
      end

      comparison.entries[#comparison.entries + 1] = resultEntry
    end
  end

  return comparison
end

function Observer:MeasureDelta(beforeSnapshot, afterSnapshot)
  if type(beforeSnapshot) ~= "table" or type(afterSnapshot) ~= "table" then
    fail("MeasureDelta requires before and after snapshots")
  end
  if beforeSnapshot.nodeId ~= afterSnapshot.nodeId or beforeSnapshot.airbaseName ~= afterSnapshot.airbaseName then
    fail("MeasureDelta snapshot identity mismatch")
  end

  local result = {
    nodeId = beforeSnapshot.nodeId,
    airbaseName = beforeSnapshot.airbaseName,
    resources = {},
    variants = {},
  }

  for resourceId, before in pairs(beforeSnapshot.resources or {}) do
    local after = (afterSnapshot.resources or {})[resourceId]
    if after then
      result.resources[resourceId] = {
        resourceId = resourceId,
        canonicalUnit = before.canonicalUnit,
        before = before.quantity,
        after = after.quantity,
        delta = after.quantity - before.quantity,
      }
    end
  end

  for key, before in pairs(beforeSnapshot.variants or {}) do
    local after = (afterSnapshot.variants or {})[key]
    if after then
      result.variants[key] = {
        key = key,
        resourceId = before.resourceId,
        canonicalUnit = before.canonicalUnit,
        mappingScope = before.mappingScope,
        before = before.quantity,
        after = after.quantity,
        delta = after.quantity - before.quantity,
      }
    end
  end

  return result
end

return StorageResourceObserver
