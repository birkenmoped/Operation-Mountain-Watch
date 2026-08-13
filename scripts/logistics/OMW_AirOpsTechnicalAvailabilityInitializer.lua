-- Operation Mountain Watch - one-shot technical non-strategic STORAGE availability initializer.
--
-- Technical non-strategic items are operational DCS/MOOSE STORAGE requirements only.
-- They never create, consume, refund, or otherwise mutate CampaignState resources.
-- Desired quantities are supplied explicitly by the caller; this module does not invent
-- technical stock levels and does not run a scheduler or continuous overwrite loop.

local TechnicalAvailabilityInitializer = {}

local TAG = "[OMW][Logistics.AirOpsTechnicalAvailabilityInitializer]"

TechnicalAvailabilityInitializer.SchemaVersion = "OMW-AIROPS-TECHNICAL-AVAILABILITY-1"

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function isFiniteNonNegativeInteger(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
    and math.floor(value) == value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
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
  if type(storage.GetItemAmount) ~= "function"
      or type(storage.SetItem) ~= "function"
      or type(storage.IsLimitedWeapons) ~= "function" then
    fail("Resolved STORAGE wrapper lacks required item methods airbaseName=" .. tostring(airbaseName))
  end

  return storage
end

local function buildAirbaseIndex(initialState)
  if type(initialState) ~= "table" or type(initialState.nodes) ~= "table" then
    fail("campaignContext.initialState.nodes is required")
  end

  local result = {}
  for _, node in ipairs(initialState.nodes) do
    requireNonEmptyString(node.nodeId, "initialState nodeId")
    requireNonEmptyString(node.airbaseName, "initialState airbaseName")
    result[node.nodeId] = node.airbaseName
  end
  return result
end

local function buildTechnicalEntryIndex(resourceManifest)
  if type(resourceManifest) ~= "table" or type(resourceManifest.GetEntries) ~= "function" then
    fail("AirOps resource manifest with GetEntries() is required")
  end
  if type(resourceManifest.Class) ~= "table"
      or type(resourceManifest.Class.TECHNICAL_NON_STRATEGIC) ~= "string" then
    fail("AirOps resource manifest TECHNICAL_NON_STRATEGIC class is required")
  end

  local index = {}
  for _, entry in ipairs(resourceManifest.GetEntries()) do
    if entry.class == resourceManifest.Class.TECHNICAL_NON_STRATEGIC then
      if entry.resourceId ~= nil then
        fail("Technical non-strategic entry must not define resourceId key=" .. tostring(entry.key))
      end
      if entry.storageKind ~= "ITEM"
          or type(entry.storageItemName) ~= "string"
          or entry.storageItemName == "" then
        fail("Technical non-strategic entry requires direct ITEM mapping key=" .. tostring(entry.key))
      end
      if type(entry.key) ~= "string" or entry.key == "" then
        fail("Technical non-strategic manifest entry requires key")
      end
      if index[entry.key] then
        fail("Duplicate technical non-strategic manifest key=" .. tostring(entry.key))
      end
      index[entry.key] = entry
    end
  end

  return index
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function readItemAmount(storage, itemName, nodeId, key)
  local ok, amount = pcall(function()
    return storage:GetItemAmount(itemName)
  end)
  if not ok then
    fail(string.format(
      "STORAGE read failed nodeId=%s key=%s item=%s error=%s",
      tostring(nodeId),
      tostring(key),
      tostring(itemName),
      tostring(amount)
    ))
  end
  if not isFiniteNonNegativeInteger(amount) then
    fail(string.format(
      "STORAGE returned invalid item quantity nodeId=%s key=%s item=%s value=%s",
      tostring(nodeId),
      tostring(key),
      tostring(itemName),
      tostring(amount)
    ))
  end
  return amount
end

function TechnicalAvailabilityInitializer.Plan(campaignContext, resourceManifest, availabilityByNode)
  if type(campaignContext) ~= "table" then
    fail("campaignContext must be a table")
  end
  if type(availabilityByNode) ~= "table" then
    fail("availabilityByNode must be a table")
  end

  local airbaseByNode = buildAirbaseIndex(campaignContext.initialState)
  local technicalByKey = buildTechnicalEntryIndex(resourceManifest)
  local storageCache = {}
  local plan = {
    schemaVersion = TechnicalAvailabilityInitializer.SchemaVersion,
    entries = {},
    blockerCount = 0,
    changeCount = 0,
  }

  for _, nodeId in ipairs(sortedKeys(availabilityByNode)) do
    local airbaseName = airbaseByNode[nodeId]
    if not airbaseName then
      fail("No airbaseName for configured technical availability nodeId=" .. tostring(nodeId))
    end

    local desiredByKey = availabilityByNode[nodeId]
    if type(desiredByKey) ~= "table" then
      fail("technical availability node value must be table nodeId=" .. tostring(nodeId))
    end

    for _, key in ipairs(sortedKeys(desiredByKey)) do
      local desired = desiredByKey[key]
      if not isFiniteNonNegativeInteger(desired) then
        fail(string.format(
          "technical availability quantity must be non-negative integer nodeId=%s key=%s quantity=%s",
          tostring(nodeId),
          tostring(key),
          tostring(desired)
        ))
      end

      local manifestEntry = technicalByKey[key]
      if not manifestEntry then
        fail("Unknown or non-technical availability key=" .. tostring(key))
      end

      local storage = storageCache[airbaseName]
      if not storage then
        storage = resolveStorage(airbaseName)
        storageCache[airbaseName] = storage
      end

      if storage:IsLimitedWeapons() ~= true then
        plan.blockerCount = plan.blockerCount + 1
        plan.entries[#plan.entries + 1] = {
          nodeId = nodeId,
          airbaseName = airbaseName,
          key = key,
          storageItemName = manifestEntry.storageItemName,
          desired = desired,
          blocker = true,
          reason = "WAREHOUSE_WEAPONS_NOT_LIMITED",
        }
      else
        local observed = readItemAmount(storage, manifestEntry.storageItemName, nodeId, key)
        local delta = desired - observed
        if delta ~= 0 then
          plan.changeCount = plan.changeCount + 1
        end

        plan.entries[#plan.entries + 1] = {
          nodeId = nodeId,
          airbaseName = airbaseName,
          key = key,
          storageItemName = manifestEntry.storageItemName,
          desired = desired,
          observed = observed,
          delta = delta,
          mappingScope = manifestEntry.mappingScope,
        }
      end
    end
  end

  log(string.format(
    "PLAN entries=%d blockers=%d changes=%d",
    #plan.entries,
    plan.blockerCount,
    plan.changeCount
  ))

  return plan
end

function TechnicalAvailabilityInitializer.Apply(campaignContext, resourceManifest, availabilityByNode)
  local plan = TechnicalAvailabilityInitializer.Plan(campaignContext, resourceManifest, availabilityByNode)
  if plan.blockerCount > 0 then
    fail("Technical STORAGE availability initialization blocked because one or more warehouses do not use limited weapons")
  end

  local storageCache = {}
  local results = {}
  local verified = true

  for _, entry in ipairs(plan.entries) do
    local storage = storageCache[entry.airbaseName]
    if not storage then
      storage = resolveStorage(entry.airbaseName)
      storageCache[entry.airbaseName] = storage
    end

    if entry.delta ~= 0 then
      local ok, result = pcall(function()
        return storage:SetItem(entry.storageItemName, entry.desired)
      end)
      if not ok then
        fail(string.format(
          "STORAGE write failed nodeId=%s key=%s item=%s desired=%s error=%s",
          tostring(entry.nodeId),
          tostring(entry.key),
          tostring(entry.storageItemName),
          tostring(entry.desired),
          tostring(result)
        ))
      end
    end

    local actual = readItemAmount(storage, entry.storageItemName, entry.nodeId, entry.key)
    local entryVerified = actual == entry.desired
    if not entryVerified then
      verified = false
    end

    results[#results + 1] = {
      nodeId = entry.nodeId,
      airbaseName = entry.airbaseName,
      key = entry.key,
      storageItemName = entry.storageItemName,
      desired = entry.desired,
      actual = actual,
      verified = entryVerified,
      mappingScope = entry.mappingScope,
    }
  end

  log(string.format(
    "APPLY entries=%d changes=%d verified=%s",
    #plan.entries,
    plan.changeCount,
    tostring(verified)
  ))

  return {
    schemaVersion = TechnicalAvailabilityInitializer.SchemaVersion,
    plan = plan,
    results = results,
    verified = verified,
  }
end

return TechnicalAvailabilityInitializer
