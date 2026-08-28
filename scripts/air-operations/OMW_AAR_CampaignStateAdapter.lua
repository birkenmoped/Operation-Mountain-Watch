-- Operation Mountain Watch - CampaignState adapter for strategic KC-135 pools.
--
-- This module contains no MOOSE or DCS logic. It binds the physical AAR
-- controller lifecycle to CampaignState's generic resource transaction API.
-- CampaignState remains the sole strategic resource authority.

local Adapter = {}
Adapter.__index = Adapter

local TAG = "[OMW][AAR.CampaignStateAdapter]"
local RESOURCE_ID = "AIRCRAFT_KC135"
local LOSS_RESOURCE_ID = "AIRCRAFT_KC135_LOST"
local UNIT = "count"
local TRANSACTION_PREFIX = "AAR-KC135-COMMIT:"

local SOURCE_NODE = {
  MANAS = "OFFMAP_MANAS",
  AL_UDEID = "OFFMAP_AL_UDEID",
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function getSourceNode(selection)
  if type(selection) ~= "table" then fail("selection must be a table") end
  local sourceDomain = requireNonEmptyString(selection.sourceDomain, "selection.sourceDomain")
  local nodeId = SOURCE_NODE[sourceDomain]
  if not nodeId then fail("unsupported AAR sourceDomain=" .. tostring(sourceDomain)) end
  return nodeId
end

local function getRuntimeId(runtime)
  if type(runtime) ~= "table" then fail("runtime must be a table") end
  return requireNonEmptyString(runtime.runtimeId, "runtime.runtimeId")
end

local function transactionId(runtimeId) return TRANSACTION_PREFIX .. runtimeId end
local function handoffCreditId(runtimeId) return "AAR-KC135-HANDOFF:" .. runtimeId end
local function lossCreditId(runtimeId) return "AAR-KC135-LOSS:" .. runtimeId end
local function restartCreditId(runtimeId) return "AAR-KC135-RESTART:" .. runtimeId end

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
  local nodeId = getSourceNode(selection)
  local runtimeId = getRuntimeId(runtime)
  local transaction = self.store:GetTransaction(transactionId(runtimeId))
  if transaction.status ~= self.campaignState.TransactionStatus.CONSUMED then
    fail(string.format("KC-135 lifecycle resolution requires consumed commitment runtime=%s status=%s",
      runtimeId, tostring(transaction.status)))
  end
  if transaction.originNodeId ~= nodeId or transaction.resourceId ~= RESOURCE_ID or transaction.quantity ~= 1
      or transaction.canonicalUnit ~= UNIT then
    fail("KC-135 commitment mismatch runtime=" .. runtimeId)
  end
  return nodeId, runtimeId, transaction
end

function Adapter:CanMaterialize(selection)
  local nodeId = getSourceNode(selection)
  local resource = self.store:GetResource(nodeId, RESOURCE_ID)
  if resource.canonicalUnit ~= UNIT then
    fail(string.format("unexpected KC-135 resource unit nodeId=%s unit=%s", nodeId, tostring(resource.canonicalUnit)))
  end
  if resource.available < 1 then
    return false, string.format("KC135_STRATEGIC_UNAVAILABLE source=%s node=%s available=%s",
      tostring(selection.sourceDomain), nodeId, tostring(resource.available))
  end
  return true
end

function Adapter:OnMaterialized(selection, runtime)
  local nodeId = getSourceNode(selection)
  local runtimeId = getRuntimeId(runtime)
  local id = transactionId(runtimeId)
  self.store:ReserveResource({
    transactionId = id, reservationId = id, missionDemandId = selection.missionDemandId,
    carrierEntityId = runtimeId, kind = self.campaignState.TransactionKind.CONSUMPTION,
    resourceId = RESOURCE_ID, quantity = 1, canonicalUnit = UNIT, originNodeId = nodeId,
  })
  self.store:Consume(id)
  local resource = self.store:GetResource(nodeId, RESOURCE_ID)
  return { runtimeId = runtimeId, nodeId = nodeId, resourceId = RESOURCE_ID,
    available = resource.available, quantity = resource.quantity }
end

function Adapter:OnHandoff(selection, runtime)
  local nodeId, runtimeId = self:_ValidateCommitment(selection, runtime)
  if self.store:GetResourceCredit(lossCreditId(runtimeId)) then
    fail("KC-135 handoff cannot recredit a recorded loss runtime=" .. runtimeId)
  end
  self.store:CreditResourceOnce({
    creditId = handoffCreditId(runtimeId), nodeId = nodeId, resourceId = RESOURCE_ID,
    quantity = 1, canonicalUnit = UNIT, reason = "AAR_OFFMAP_HANDOFF", entityId = runtimeId,
  })
  local resource = self.store:GetResource(nodeId, RESOURCE_ID)
  return { runtimeId = runtimeId, nodeId = nodeId, resourceId = RESOURCE_ID,
    available = resource.available, quantity = resource.quantity }
end

function Adapter:OnLost(selection, runtime, reason)
  local nodeId, runtimeId = self:_ValidateCommitment(selection, runtime)
  if self.store:GetResourceCredit(handoffCreditId(runtimeId)) or self.store:GetResourceCredit(restartCreditId(runtimeId)) then
    fail("KC-135 loss cannot be recorded after strategic recredit runtime=" .. runtimeId)
  end
  self.store:CreditResourceOnce({
    creditId = lossCreditId(runtimeId), nodeId = nodeId, resourceId = LOSS_RESOURCE_ID,
    quantity = 1, canonicalUnit = UNIT, reason = "AAR_AIRCRAFT_LOSS:" .. tostring(reason or "DEAD"),
    entityId = runtimeId,
  })
  local available = self.store:GetResource(nodeId, RESOURCE_ID)
  local lost = self.store:GetResource(nodeId, LOSS_RESOURCE_ID)
  return { runtimeId = runtimeId, nodeId = nodeId, resourceId = RESOURCE_ID,
    available = available.available, quantity = available.quantity, lost = lost.quantity }
end

function Adapter:ReconcileRestore()
  local snapshot = self.store:ExportSnapshot()
  local reconciled, preservedLosses, alreadyResolved = 0, 0, 0
  for _, transaction in ipairs(snapshot.transactions or {}) do
    local runtimeId = runtimeIdFromTransactionId(transaction.transactionId)
    if runtimeId and transaction.resourceId == RESOURCE_ID and transaction.quantity == 1
        and transaction.canonicalUnit == UNIT and transaction.status == self.campaignState.TransactionStatus.CONSUMED then
      local nodeId = transaction.originNodeId
      local handoff = self.store:GetResourceCredit(handoffCreditId(runtimeId))
      local loss = self.store:GetResourceCredit(lossCreditId(runtimeId))
      local restart = self.store:GetResourceCredit(restartCreditId(runtimeId))
      if loss then
        preservedLosses = preservedLosses + 1
      elseif handoff or restart then
        alreadyResolved = alreadyResolved + 1
      else
        if nodeId ~= SOURCE_NODE.MANAS and nodeId ~= SOURCE_NODE.AL_UDEID then
          fail("AAR restore transaction has unsupported origin node runtime=" .. runtimeId)
        end
        self.store:CreditResourceOnce({
          creditId = restartCreditId(runtimeId), nodeId = nodeId, resourceId = RESOURCE_ID,
          quantity = 1, canonicalUnit = UNIT, reason = "AAR_RESTART_RECONCILIATION", entityId = runtimeId,
        })
        reconciled = reconciled + 1
      end
    end
  end
  return { reconciled = reconciled, preservedLosses = preservedLosses, alreadyResolved = alreadyResolved }
end

function Adapter:GetPoolStatus(sourceDomain)
  local nodeId = SOURCE_NODE[requireNonEmptyString(sourceDomain, "sourceDomain")]
  if not nodeId then fail("unsupported AAR sourceDomain=" .. tostring(sourceDomain)) end
  local pool = self.store:GetResource(nodeId, RESOURCE_ID)
  local loss = self.store:GetResource(nodeId, LOSS_RESOURCE_ID)
  pool.lost = loss.quantity
  return pool
end

function Adapter:GetConfig()
  return {
    resourceId = RESOURCE_ID, lossResourceId = LOSS_RESOURCE_ID, canonicalUnit = UNIT,
    sourceNode = { MANAS = SOURCE_NODE.MANAS, AL_UDEID = SOURCE_NODE.AL_UDEID },
  }
end

return Adapter
