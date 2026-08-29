-- Operation Mountain Watch - Stage 2 Acceptance 1 authoritative Ground context bootstrap.
--
-- This is acceptance-only composition. It creates exactly one fresh CampaignState
-- store from the current GroundInitialStock contract and attaches the production
-- GroundBase facade to that store. It does not create any DCS/MOOSE physical
-- asset by itself and does not replace CampaignState resource authority.

local TAG = "[OMW][FOB-ATTACK-HIT-ACCEPTANCE-1][BOOTSTRAP]"

local CampaignState = OMW_STAGE2_CAMPAIGN_STATE
local GroundInitialStock = OMW_STAGE2_GROUND_INITIAL_STOCK
local GroundCampaignStateAdapter = OMW_STAGE2_GROUND_CAMPAIGN_STATE_ADAPTER
local GroundAmmoRearmAdapter = OMW_STAGE2_GROUND_AMMO_REARM_ADAPTER
local GroundRuntimeIntegration = OMW_STAGE2_GROUND_RUNTIME_INTEGRATION
local GroundBase = OMW_STAGE2_GROUND_BASE

local AIRBASE_NAME_BY_NODE = {
  GROUND_NODE_JALALABAD = "JALALABAD",
  GROUND_NODE_FORTRESS = "FORTRESS",
  GROUND_NODE_JOYCE = "JOYCE",
  GROUND_NODE_WRIGHT = "WRIGHT",
  GROUND_NODE_HONAKER = "HONAKER",
  GROUND_NODE_BOSTICK = "BOSTICK",
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function buildInitialNodes()
  local byNode = {}
  local nodeIds = {}

  for _, row in ipairs(GroundInitialStock.Rows or {}) do
    if type(row.nodeId) ~= "string" or row.nodeId == "" then
      fail("GroundInitialStock row has invalid nodeId")
    end
    if type(row.resourceId) ~= "string" or row.resourceId == "" then
      fail("GroundInitialStock row has invalid resourceId nodeId=" .. tostring(row.nodeId))
    end
    if type(row.initial) ~= "number" or row.initial < 0 then
      fail("GroundInitialStock row has invalid initial quantity nodeId=" .. tostring(row.nodeId)
        .. " resourceId=" .. tostring(row.resourceId))
    end

    local node = byNode[row.nodeId]
    if not node then
      node = {
        nodeId = row.nodeId,
        airbaseName = AIRBASE_NAME_BY_NODE[row.nodeId] or row.nodeId,
        resources = {},
      }
      byNode[row.nodeId] = node
      nodeIds[#nodeIds + 1] = row.nodeId
    end

    if node.resources[row.resourceId] ~= nil then
      fail("duplicate GroundInitialStock resource nodeId=" .. tostring(row.nodeId)
        .. " resourceId=" .. tostring(row.resourceId))
    end

    node.resources[row.resourceId] = {
      quantity = row.initial,
      unit = row.unit or "count",
    }
  end

  table.sort(nodeIds)
  local nodes = {}
  for _, nodeId in ipairs(nodeIds) do
    nodes[#nodes + 1] = byNode[nodeId]
  end
  return nodes
end

if type(CampaignState) ~= "table" or type(CampaignState.New) ~= "function" then
  fail("CampaignState.New() unavailable")
end
if type(GroundInitialStock) ~= "table" or type(GroundInitialStock.Rows) ~= "table" then
  fail("GroundInitialStock.Rows unavailable")
end
if type(GroundBase) ~= "table" or type(GroundBase.Configure) ~= "function" or type(GroundBase.Attach) ~= "function" then
  fail("GroundBase Configure/Attach unavailable")
end

GroundBase.Configure({
  groundInitialStock = GroundInitialStock,
  groundCampaignStateAdapter = GroundCampaignStateAdapter,
  groundAmmoRearmAdapter = GroundAmmoRearmAdapter,
  groundRuntimeIntegration = GroundRuntimeIntegration,
})

local store = CampaignState.New({
  schemaVersion = "OMW-STAGE2-A1-CAMPAIGNSTATE-1",
  nodes = buildInitialNodes(),
})

OMW = OMW or {}
OMW.Ground = OMW.Ground or {}
if OMW.Ground.Base ~= nil then
  fail("OMW.Ground.Base already exists; do not load another Ground Base before this standalone acceptance bundle")
end
OMW.Ground.Base = GroundBase

local context = GroundBase.Attach({
  store = store,
  campaignState = CampaignState,
  restored = false,
})

if GroundBase.GetContext() ~= context then
  fail("GroundBase context readback mismatch")
end

local fortressPersonnel = store:GetResource("GROUND_NODE_FORTRESS", "GROUND_PERSONNEL")
if fortressPersonnel.canonicalUnit ~= "count" or fortressPersonnel.available ~= 160 then
  fail("unexpected fresh Fortress GROUND_PERSONNEL available=" .. tostring(fortressPersonnel.available)
    .. " unit=" .. tostring(fortressPersonnel.canonicalUnit))
end

env.info(TAG .. " READY authority=single_acceptance_campaignstate fortressPersonnel="
  .. tostring(fortressPersonnel.available), false)
