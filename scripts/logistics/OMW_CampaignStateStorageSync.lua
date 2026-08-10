-- Operation Mountain Watch - one-way CampaignState to MOOSE STORAGE fuel sync.
--
-- CampaignState remains authoritative. This coordinator reads an authoritative
-- fuel snapshot and delegates comparison/write verification to StorageFuelAdapter.
-- It never mutates CampaignState and never imports DCS warehouse state as truth.

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

function CampaignStateStorageSync.New(campaignStateStore, storageFuelAdapter)
  requireInterface(campaignStateStore, "GetFuelSnapshot", "campaignStateStore")
  requireInterface(storageFuelAdapter, "PlanSnapshot", "storageFuelAdapter")
  requireInterface(storageFuelAdapter, "ApplySnapshot", "storageFuelAdapter")

  return setmetatable({
    campaignStateStore = campaignStateStore,
    storageFuelAdapter = storageFuelAdapter,
  }, Sync)
end

function Sync:PlanNode(nodeId)
  if type(nodeId) ~= "string" or nodeId == "" then
    fail("PlanNode requires nodeId")
  end
  local snapshot = self.campaignStateStore:GetFuelSnapshot(nodeId)
  return self.storageFuelAdapter.PlanSnapshot(snapshot)
end

function Sync:ApplyNode(nodeId)
  if type(nodeId) ~= "string" or nodeId == "" then
    fail("ApplyNode requires nodeId")
  end
  local snapshot = self.campaignStateStore:GetFuelSnapshot(nodeId)
  local result = self.storageFuelAdapter.ApplySnapshot(snapshot)
  if not result.verified then
    fail("STORAGE mirror verification failed nodeId=" .. tostring(nodeId))
  end
  return result
end

return CampaignStateStorageSync
