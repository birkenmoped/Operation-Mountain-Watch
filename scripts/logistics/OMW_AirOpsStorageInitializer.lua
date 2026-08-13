-- Operation Mountain Watch - selective CampaignState to MOOSE STORAGE item initializer.
--
-- CampaignState remains the strategic authority. This adapter performs a one-shot
-- operational initialization of directly validated DCS/MOOSE STORAGE item mirrors.
-- It deliberately skips resources without one unambiguous validated item mapping.
-- Fuel remains handled by OMW_StorageFuelAdapter / OMW_CampaignStateStorageSync.

local StorageInitializer = {}

local TAG = "[OMW][Logistics.AirOpsStorageInitializer]"

StorageInitializer.SchemaVersion = "OMW-AIROPS-STORAGE-INITIALIZER-1"

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

local function startsWith(value, prefix)
  return type(value) == "string" and string.sub(value, 1, #prefix) == prefix
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

local function buildValidatedItemMappings(resourceManifest)
  if type(resourceManifest) ~= "table" or type(resourceManifest.GetEntries) ~= "function" then
    fail("AirOps resource manifest with GetEntries() is required")
  end

  local candidates = {}
  for _, entry in ipairs(resourceManifest.GetEntries()) do
    if entry.resourceId
        and entry.storageKind == "ITEM"
        and type(entry.storageItemName) == "string"
        and entry.storageItemName ~= ""
        and startsWith(entry.mappingScope, "VALIDATED_") then
      local byItem = candidates[entry.resourceId]
      if not byItem then
        byItem = {}
        candidates[entry.resourceId] = byItem
      end
      byItem[entry.storageItemName] = true
    end
  end

  local mappings = {}
  for resourceId, byItem in pairs(candidates) do
    local itemCount = 0
    local onlyItem = nil
    for itemName in pairs(byItem) do
      itemCount = itemCount + 1
      onlyItem = itemName
    end

    if itemCount == 1 then
      mappings[resourceId] = {
        eligible = true,
        storageItemName = onlyItem,
      }
    else
      mappings[resourceId] = {
        eligible = false,
        reason = "MULTIPLE_VALIDATED_STORAGE_ITEMS",
        validatedItemCount = itemCount,
      }
    end
  end

  return mappings
end

local function buildAirbaseIndex(initialState)
  if type(initialState) ~= "table" or type(initialState.nodes) ~= "table" then
    fail("campaign context initialState.nodes is required")
  end

  local result = {}
  for _, node in ipairs(initialState.nodes) do
    if type(node.nodeId) ~= "string" or node.nodeId == "" then
      fail("initialState node requires nodeId")
    end
    if type(node.airbaseName) ~= "string" or node.airbaseName == "" then
      fail("initialState node requires airbaseName nodeId=" .. tostring(node.nodeId))
    end
    result[node.nodeId] = node.airbaseName
  end
  return result
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function readItemAmount(storage, itemName, nodeId, resourceId)
  local ok, amount = pcall(function()
    return storage:GetItemAmount(itemName)
  end)
  if not ok then
    fail(string.format(
      "STORAGE read failed nodeId=%s resourceId=%s item=%s error=%s",
      tostring(nodeId),
      tostring(resourceId),
      tostring(itemName),
      tostring(amount)
    ))
  end
  if not isFiniteNonNegativeInteger(amount) then
    fail(string.format(
      "STORAGE returned invalid item quantity nodeId=%s resourceId=%s item=%s value=%s",
      tostring(nodeId),
      tostring(resourceId),
      tostring(itemName),
      tostring(amount)
    ))
  end
  return amount
end

function StorageInitializer.BuildValidatedItemMappings(resourceManifest)
  return buildValidatedItemMappings(resourceManifest)
end

function StorageInitializer.Plan(campaignContext, resourceManifest)
  if type(campaignContext) ~= "table" then
    fail("campaignContext must be a table")
  end
  if type(campaignContext.store) ~= "table" or type(campaignContext.store.GetResource) ~= "function" then
    fail("campaignContext.store with GetResource() is required")
  end
  if type(campaignContext.metadataByNode) ~= "table" then
    fail("campaignContext.metadataByNode is required")
  end

  local airbaseByNode = buildAirbaseIndex(campaignContext.initialState)
  local mappings = buildValidatedItemMappings(resourceManifest)
  local storageCache = {}
  local plan = {
    schemaVersion = StorageInitializer.SchemaVersion,
    entries = {},
    skipped = {},
    blockerCount = 0,
    changeCount = 0,
  }

  for _, nodeId in ipairs(sortedKeys(campaignContext.metadataByNode)) do
    local airbaseName = airbaseByNode[nodeId]
    if not airbaseName then
      fail("No airbaseName for nodeId=" .. tostring(nodeId))
    end

    local metadataByResource = campaignContext.metadataByNode[nodeId]
    for _, resourceId in ipairs(sortedKeys(metadataByResource)) do
      local mapping = mappings[resourceId]
      if not mapping then
        plan.skipped[#plan.skipped + 1] = {
          nodeId = nodeId,
          resourceId = resourceId,
          reason = "NO_VALIDATED_DIRECT_ITEM_MAPPING",
        }
      elseif not mapping.eligible then
        plan.skipped[#plan.skipped + 1] = {
          nodeId = nodeId,
          resourceId = resourceId,
          reason = mapping.reason,
          validatedItemCount = mapping.validatedItemCount,
        }
      else
        local storage = storageCache[airbaseName]
        if not storage then
          storage = resolveStorage(airbaseName)
          storageCache[airbaseName] = storage
        end

        if storage:IsLimitedWeapons() ~= true then
          plan.blockerCount = plan.blockerCount + 1
          plan.skipped[#plan.skipped + 1] = {
            nodeId = nodeId,
            airbaseName = airbaseName,
            resourceId = resourceId,
            storageItemName = mapping.storageItemName,
            reason = "WAREHOUSE_WEAPONS_NOT_LIMITED",
            blocker = true,
          }
        else
          local resource = campaignContext.store:GetResource(nodeId, resourceId)
          if resource.canonicalUnit ~= "count" then
            fail(string.format(
              "direct item mapping requires count unit nodeId=%s resourceId=%s unit=%s",
              tostring(nodeId),
              tostring(resourceId),
              tostring(resource.canonicalUnit)
            ))
          end
          if not isFiniteNonNegativeInteger(resource.quantity) then
            fail(string.format(
              "CampaignState item quantity must be non-negative integer nodeId=%s resourceId=%s quantity=%s",
              tostring(nodeId),
              tostring(resourceId),
              tostring(resource.quantity)
            ))
          end

          local observed = readItemAmount(storage, mapping.storageItemName, nodeId, resourceId)
          local delta = resource.quantity - observed
          if delta ~= 0 then
            plan.changeCount = plan.changeCount + 1
          end

          plan.entries[#plan.entries + 1] = {
            nodeId = nodeId,
            airbaseName = airbaseName,
            resourceId = resourceId,
            storageItemName = mapping.storageItemName,
            desired = resource.quantity,
            observed = observed,
            delta = delta,
          }
        end
      end
    end
  end

  log(string.format(
    "PLAN entries=%d skipped=%d blockers=%d changes=%d",
    #plan.entries,
    #plan.skipped,
    plan.blockerCount,
    plan.changeCount
  ))

  return plan
end

function StorageInitializer.Apply(campaignContext, resourceManifest)
  local plan = StorageInitializer.Plan(campaignContext, resourceManifest)
  if plan.blockerCount > 0 then
    fail("STORAGE initialization blocked because one or more mapped warehouses do not use limited weapons")
  end

  local storageCache = {}
  local verified = true
  local results = {}

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
          "STORAGE write failed nodeId=%s resourceId=%s item=%s desired=%s error=%s",
          tostring(entry.nodeId),
          tostring(entry.resourceId),
          tostring(entry.storageItemName),
          tostring(entry.desired),
          tostring(result)
        ))
      end
    end

    local actual = readItemAmount(storage, entry.storageItemName, entry.nodeId, entry.resourceId)
    local entryVerified = actual == entry.desired
    if not entryVerified then
      verified = false
    end

    results[#results + 1] = {
      nodeId = entry.nodeId,
      airbaseName = entry.airbaseName,
      resourceId = entry.resourceId,
      storageItemName = entry.storageItemName,
      desired = entry.desired,
      actual = actual,
      verified = entryVerified,
    }
  end

  log(string.format(
    "APPLY entries=%d changes=%d verified=%s",
    #plan.entries,
    plan.changeCount,
    tostring(verified)
  ))

  return {
    schemaVersion = StorageInitializer.SchemaVersion,
    plan = plan,
    results = results,
    verified = verified,
  }
end

return StorageInitializer
