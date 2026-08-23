-- Operation Mountain Watch - CampaignState adapter for the off-map E-3 AWACS pool.
--
-- This module contains no MOOSE or DCS logic. It binds the physical AWACS
-- lifecycle to CampaignState's generic resource transaction API.
-- CampaignState remains the sole strategic resource authority.

local Adapter = {}
Adapter.__index = Adapter

local TAG = "[OMW][AWACS.CampaignStateAdapter]"
local RESOURCE_ID = "AIRCRAFT_E3A_AWACS"
local LOSS_RESOURCE_ID = "AIRCRAFT_E3A_AWACS_LOST"
local UNIT = "count"
local SOURCE_NODE = "OFFMAP_AL_DHAFRA"
local TRANSACTION_PREFIX = "AWACS-E3A-COMMIT:"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function getRuntimeId(runtime)
  if type(runtime) ~= "table" then fail("runtime must be a table") end
  return requireNonEmptyString(runtime.runtimeId, "runtime.runtimeId")
end

local function validateSelection(selection)
  if type(selection) ~= "table" then fail("selection must be a table") end
  if selection.sourceDomain ~= "AL_DHAFRA" then
    fail("unsupported AWACS sourceDomain=" .. tostring(selection.sourceDomain))
  end
  return SOURCE_NODE
end

local function transactionId(runtimeId) return TRANSACTION_PREFIX .. runtimeId end
local function handoffCreditId(runtimeId) return "AWACS-E3A-HANDOFF:" .. runtimeId end
local function lossCreditId(runtimeId) return "AWACS-E3A-LOSS:" .. runtimeId end
local function restartCreditId(runtimeId) return "AWACS-E3A-RESTART:" .. runtimeId end

local function runtimeIdFromTransactionId(id)
  if type(id) ~= "string" or id:sub(1, #TRANSACTION_PREFIX) ~= TRANSACTION_PREFIX then return nil end
  local runtimeId = id:sub(#TRANSACTION_PREFIX + 1)
  return runtimeId ~= "" and runtimeId or nil
end

function Adapter.New(store, campaignStateModule)
  if type(store) ~= "table" or type(store.GetResource) ~= "function"
      or type(store.ReserveResource) ~= "function" or type(store.Consume) ~= "function"
      or type(store.GetTransaction) ~= "function" or type(store.CreditResourceOnce) ~= "function"
      or type(store.GetResourceCredit) ~= "function" or type(store.ExportSnapshot) ~= "function" then
    fail("CampaignState store with resource transaction/snapshot API is required")
  end
  if type(campaignStateModule) ~= "table" or type(campaignStateModule.TransactionKind) ~= "table"
      or type(campaignStateModule.TransactionStatus) ~= "table" then
    fail("CampaignState module with transaction enums is required")
  end
  return setmetatable({ store = store, campaignState = campaignStateModule }, Adapter)
end

function Adapter:_ValidateCommitment(selection, runtime)
  local nodeId = validateSelection(selection)
  local runtimeId = getRuntimeId(runtime)
  local transaction = self.store:GetTransaction(transactionId(runtimeId))
  if transaction.status ~= self.campaignState.TransactionStatus.CONSUMED then
    fail(string.format("E-3 lifecycle resolution requires consumed commitment runtime=%s status=%s",
      runtimeId, tostring(transaction.status)))
  end
  if transaction.originNodeId ~= nodeId or transaction.resourceId ~= RESOURCE_ID or transaction.quantity ~= 1
      or transaction.canonicalUnit ~= UNIT then
    fail("E-3 commitment mismatch runtime=" .. runtimeId)
  end
  return nodeId, runtimeId
end

function Adapter:CanMaterialize(selection)
  local nodeId = validateSelection(selection)
  local resource = self.store:GetResource(nodeId, RESOURCE_ID)
  if resource.canonicalUnit ~= UNIT then
    fail(string.format("unexpected E-3 resource unit nodeId=%s unit=%s", nodeId, tostring(resource.canonicalUnit)))
  end
  if resource.available < 1 then
    return false, string.format("E3A_STRATEGIC_UNAVAILABLE source=AL_DHAFRA available=%s", tostring(resource.available))
  end
  return true
end

function Adapter:OnMaterialized(selection, runtime)
  local nodeId = validateSelection(selection)
  local runtimeId = getRuntimeId(runtime)
  local id = transactionId(runtimeId)
  self.store:ReserveResource({
    transactionId = id,
    reservationId = id,
    missionDemandId = selection.missionDemandId,
    carrierEntityId = runtimeId,
    kind = self.campaignState.TransactionKind.CONSUMPTION,
    resourceId = RESOURCE_ID,
    quantity = 1,
    canonicalUnit = UNIT,
    originNodeId = nodeId,
  })
  self.store:Consume(id)
  local resource = self.store:GetResource(nodeId, RESOURCE_ID)
  return { runtimeId = runtimeId, nodeId = nodeId, available = resource.available, quantity = resource.quantity }
end

function Adapter:OnHandoff(selection, runtime)
  local nodeId, runtimeId = self:_ValidateCommitment(selection, runtime)
  if self.store:GetResourceCredit(lossCreditId(runtimeId)) then
    fail("E-3 handoff cannot recredit a recorded loss runtime=" .. runtimeId)
  end
  self.store:CreditResourceOnce({
    creditId = handoffCreditId(runtimeId),
    nodeId = nodeId,
    resourceId = RESOURCE_ID,
    quantity = 1,
    canonicalUnit = UNIT,
    reason = "AWACS_OFFMAP_HANDOFF",
    entityId = runtimeId,
  })
  local resource = self.store:GetResource(nodeId, RESOURCE_ID)
  return { runtimeId = runtimeId, nodeId = nodeId, available = resource.available, quantity = resource.quantity }
end

function Adapter:OnLost(selection, runtime, reason)
  local nodeId, runtimeId = self:_ValidateCommitment(selection, runtime)
  if self.store:GetResourceCredit(handoffCreditId(runtimeId)) or self.store:GetResourceCredit(restartCreditId(runtimeId)) then
    fail("E-3 loss cannot be recorded after strategic recredit runtime=" .. runtimeId)
  end
  self.store:CreditResourceOnce({
    creditId = lossCreditId(runtimeId),
    nodeId = nodeId,
    resourceId = LOSS_RESOURCE_ID,
    quantity = 1,
    canonicalUnit = UNIT,
    reason = "AWACS_AIRCRAFT_LOSS:" .. tostring(reason or "DEAD"),
    entityId = runtimeId,
  })
  local available = self.store:GetResource(nodeId, RESOURCE_ID)
  local lost = self.store:GetResource(nodeId, LOSS_RESOURCE_ID)
  return { runtimeId = runtimeId, nodeId = nodeId, available = available.available, quantity = available.quantity, lost = lost.quantity }
end

function Adapter:ReconcileRestore()
  local snapshot = self.store:ExportSnapshot()
  local reconciled, preservedLosses, alreadyResolved = 0, 0, 0
  for _, transaction in ipairs(snapshot.transactions or {}) do
    local runtimeId = runtimeIdFromTransactionId(transaction.transactionId)
    if runtimeId and transaction.resourceId == RESOURCE_ID and transaction.quantity == 1
        and transaction.canonicalUnit == UNIT and transaction.status == self.campaignState.TransactionStatus.CONSUMED then
      local handoff = self.store:GetResourceCredit(handoffCreditId(runtimeId))
      local loss = self.store:GetResourceCredit(lossCreditId(runtimeId))
      local restart = self.store:GetResourceCredit(restartCreditId(runtimeId))
      if loss then
        preservedLosses = preservedLosses + 1
      elseif handoff or restart then
        alreadyResolved = alreadyResolved + 1
      else
        if transaction.originNodeId ~= SOURCE_NODE then
          fail("AWACS restore transaction has unsupported origin node runtime=" .. runtimeId)
        end
        self.store:CreditResourceOnce({
          creditId = restartCreditId(runtimeId),
          nodeId = SOURCE_NODE,
          resourceId = RESOURCE_ID,
          quantity = 1,
          canonicalUnit = UNIT,
          reason = "AWACS_RESTART_RECONCILIATION",
          entityId = runtimeId,
        })
        reconciled = reconciled + 1
      end
    end
  end
  return { reconciled = reconciled, preservedLosses = preservedLosses, alreadyResolved = alreadyResolved }
end

function Adapter:GetPoolStatus()
  local pool = self.store:GetResource(SOURCE_NODE, RESOURCE_ID)
  local loss = self.store:GetResource(SOURCE_NODE, LOSS_RESOURCE_ID)
  pool.lost = loss.quantity
  return pool
end

function Adapter:GetConfig()
  return {
    resourceId = RESOURCE_ID,
    lossResourceId = LOSS_RESOURCE_ID,
    canonicalUnit = UNIT,
    sourceNode = SOURCE_NODE,
  }
end

return Adapter