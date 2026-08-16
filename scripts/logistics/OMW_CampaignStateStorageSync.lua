-- Operation Mountain Watch - one-way CampaignState to MOOSE STORAGE fuel sync.
--
-- CampaignState remains authoritative. This coordinator reads authoritative
-- CampaignState fuel data and delegates comparison/write verification to the
-- StorageFuelAdapter. It never mutates CampaignState and never imports DCS
-- warehouse state as strategic truth.

local CampaignStateStorageSync = {}

local Sync = {}
Sync.__index = Sync

local TAG = "[OMW][Logistics.CampaignStateStorageSync]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireInterface(object, methodName, objectName)
  if type(object) ~= "table" or type(object[methodName]) ~= "function" then
    fail(string.format("%s requires method %s", tostring(objectName), tostring(methodName)))
  end
end

local function validateResourceIds(resourceIds, nodeId)
  if type(resourceIds) ~= "table" or #resourceIds == 0 then
    fail("resourceIdsByNode requires non-empty array nodeId=" .. tostring(nodeId))
  end
  for index, resourceId in ipairs(resourceIds) do
    if type(resourceId) ~= "string" or resourceId == "" then
      fail(string.format("invalid fuel resourceId nodeId=%s index=%s", tostring(nodeId), tostring(index)))
    end
  end
end

local function buildConfiguredSnapshot(sync, nodeId)
  local resourceIds = sync.resourceIdsByNode and sync.resourceIdsByNode[nodeId]
  if resourceIds == nil then
    return sync.campaignStateStore:GetFuelSnapshot(nodeId)
  end

  validateResourceIds(resourceIds, nodeId)

  local airbaseName = sync.airbaseNameByNode and sync.airbaseNameByNode[nodeId]
  if type(airbaseName) ~= "string" or airbaseName == "" then
    fail("airbaseNameByNode requires entry nodeId=" .. tostring(nodeId))
  end

  local snapshot = {
    nodeId = nodeId,
    airbaseName = airbaseName,
    resourcesKg = {},
  }

  for _, resourceId in ipairs(resourceIds) do
    local resource = sync.campaignStateStore:GetResource(nodeId, resourceId)
    if resource.canonicalUnit ~= "kg" then
      fail(string.format(
        "configured fuel resource is not kg nodeId=%s resourceId=%s unit=%s",
        tostring(nodeId),
        tostring(resourceId),
        tostring(resource.canonicalUnit)
      ))
    end
    snapshot.resourcesKg[resourceId] = resource.quantity
  end

  return snapshot
end

function CampaignStateStorageSync.New(campaignStateStore, storageFuelAdapter, options)
  requireInterface(campaignStateStore, "GetFuelSnapshot", "campaignStateStore")
  requireInterface(campaignStateStore, "GetResource", "campaignStateStore")
  requireInterface(storageFuelAdapter, "PlanSnapshot", "storageFuelAdapter")
  requireInterface(storageFuelAdapter, "ApplySnapshot", "storageFuelAdapter")

  options = options or {}
  if type(options) ~= "table" then
    fail("options must be a table")
  end
  if options.resourceIdsByNode ~= nil and type(options.resourceIdsByNode) ~= "table" then
    fail("options.resourceIdsByNode must be a table")
  end
  if options.airbaseNameByNode ~= nil and type(options.airbaseNameByNode) ~= "table" then
    fail("options.airbaseNameByNode must be a table")
  end

  return setmetatable({
    campaignStateStore = campaignStateStore,
    storageFuelAdapter = storageFuelAdapter,
    resourceIdsByNode = options.resourceIdsByNode,
    airbaseNameByNode = options.airbaseNameByNode,
  }, Sync)
end

function Sync:PlanNode(nodeId)
  if type(nodeId) ~= "string" or nodeId == "" then
    fail("PlanNode requires nodeId")
  end
  local snapshot = buildConfiguredSnapshot(self, nodeId)
  return self.storageFuelAdapter.PlanSnapshot(snapshot)
end

function Sync:ApplyNode(nodeId)
  if type(nodeId) ~= "string" or nodeId == "" then
    fail("ApplyNode requires nodeId")
  end
  local snapshot = buildConfiguredSnapshot(self, nodeId)
  local result = self.storageFuelAdapter.ApplySnapshot(snapshot)
  if not result.verified then
    fail("STORAGE mirror verification failed nodeId=" .. tostring(nodeId))
  end
  return result
end

return CampaignStateStorageSync
