-- Operation Mountain Watch - minimal CampaignState fuel store foundation.
--
-- This module is the strategic owner of the fuel snapshot it contains. It has no
-- MOOSE or DCS dependency, no persistence, no scheduler, and no transport logic.

local CampaignState = {}

local Store = {}
Store.__index = Store

local TAG = "[OMW][CampaignState]"

CampaignState.ResourceId = {
  JP8 = "FUEL_JP8",
  AVGAS = "FUEL_AVGAS",
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function isFiniteNonNegative(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

local function copyResources(resourcesKg)
  return {
    [CampaignState.ResourceId.JP8] = resourcesKg[CampaignState.ResourceId.JP8],
    [CampaignState.ResourceId.AVGAS] = resourcesKg[CampaignState.ResourceId.AVGAS],
  }
end

local function validateNode(node)
  if type(node) ~= "table" then
    fail("node must be a table")
  end
  if type(node.nodeId) ~= "string" or node.nodeId == "" then
    fail("node requires nodeId")
  end
  if type(node.airbaseName) ~= "string" or node.airbaseName == "" then
    fail("node requires airbaseName")
  end
  if type(node.resourcesKg) ~= "table" then
    fail("node requires resourcesKg")
  end

  for _, resourceId in ipairs({ CampaignState.ResourceId.JP8, CampaignState.ResourceId.AVGAS }) do
    local quantityKg = node.resourcesKg[resourceId]
    if not isFiniteNonNegative(quantityKg) then
      fail(string.format(
        "nodeId=%s requires non-negative finite kg quantity for resourceId=%s",
        tostring(node.nodeId),
        tostring(resourceId)
      ))
    end
  end
end

function CampaignState.New(initialState)
  if type(initialState) ~= "table" then
    fail("initialState must be a table")
  end
  if type(initialState.nodes) ~= "table" then
    fail("initialState requires nodes")
  end

  local nodesById = {}
  for _, node in ipairs(initialState.nodes) do
    validateNode(node)
    if nodesById[node.nodeId] ~= nil then
      fail("duplicate nodeId=" .. tostring(node.nodeId))
    end
    nodesById[node.nodeId] = {
      nodeId = node.nodeId,
      airbaseName = node.airbaseName,
      resourcesKg = copyResources(node.resourcesKg),
    }
  end

  if next(nodesById) == nil then
    fail("initialState contains no nodes")
  end

  return setmetatable({
    schemaVersion = initialState.schemaVersion or "CAMPAIGNSTATE-FUEL-FOUNDATION-1",
    nodesById = nodesById,
  }, Store)
end

function Store:GetResourceKg(nodeId, resourceId)
  local node = self.nodesById[nodeId]
  if not node then
    fail("unknown nodeId=" .. tostring(nodeId))
  end
  local quantityKg = node.resourcesKg[resourceId]
  if quantityKg == nil then
    fail(string.format("unknown resourceId=%s for nodeId=%s", tostring(resourceId), tostring(nodeId)))
  end
  return quantityKg
end

function Store:GetFuelSnapshot(nodeId)
  local node = self.nodesById[nodeId]
  if not node then
    fail("unknown nodeId=" .. tostring(nodeId))
  end

  return {
    nodeId = node.nodeId,
    airbaseName = node.airbaseName,
    resourcesKg = copyResources(node.resourcesKg),
  }
end

return CampaignState
