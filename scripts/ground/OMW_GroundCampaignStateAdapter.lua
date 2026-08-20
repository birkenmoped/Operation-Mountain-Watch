-- Operation Mountain Watch - strategic settlement adapter for ground mission commitments.
--
-- This module intentionally contains no MOOSE or DCS calls. MOOSE owns the
-- operational lifecycle; CampaignState remains the only strategic authority.
-- A vehicle group is correlated through an explicit per-vehicle resource map,
-- never inferred from its DCS group name.
--
-- Current owner-approved motorized-patrol correlation:
--   1 physical vehicle = 1 VEHICLE + 3 PERSONNEL

local Adapter = {}
Adapter.__index = Adapter

local TAG = "[OMW][Ground.CampaignStateAdapter]"
local UNIT = "count"
local TRANSACTION_PREFIX = "GROUND-COMMIT:"
local RETURN_PREFIX = "GROUND-RETURN:"
local LOSS_PREFIX = "GROUND-LOSS:"
local RESTART_PREFIX = "GROUND-RESTART:"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requirePositiveInteger(value, label)
  if type(value) ~= "number" or value < 1 or value % 1 ~= 0 then
    fail(label .. " requires positive integer")
  end
  return value
end

local function copyMap(map)
  local result = {}
  for key, value in pairs(map) do
    result[key] = value
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

local function commitmentId(runtimeId, resourceId)
  return TRANSACTION_PREFIX .. runtimeId .. "|" .. resourceId
end

local function creditId(prefix, runtimeId, resourceId)
  return prefix .. runtimeId .. ":" .. resourceId
end

local function parseCommitmentId(transactionId)
  if type(transactionId) ~= "string" or transactionId:sub(1, #TRANSACTION_PREFIX) ~= TRANSACTION_PREFIX then
    return nil
  end
  local payload = transactionId:sub(#TRANSACTION_PREFIX + 1)
  local runtimeId, resourceId = payload:match("^([^|]+)|(.+)$")
  if not runtimeId or not resourceId or runtimeId == "" or resourceId == "" then
    return nil
  end
  return runtimeId, resourceId
end

local function normalizePerVehicleResources(value)
  if type(value) ~= "table" or next(value) == nil then
    fail("perVehicleResources requires non-empty table")
  end
  local result = {}
  for resourceId, quantity in pairs(value) do
    requireNonEmptyString(resourceId, "perVehicleResources resourceId")
    result[resourceId] = requirePositiveInteger(quantity, "perVehicleResources quantity")
  end
  return result
end

local function normalizeSpec(spec)
  if type(spec) ~= "table" then
    fail("commitment spec must be table")
  end
  local runtimeId = requireNonEmptyString(spec.runtimeId, "spec.runtimeId")
  local nodeId = requireNonEmptyString(spec.nodeId, "spec.nodeId")
  local vehicleCount = requirePositiveInteger(spec.vehicleCount, "spec.vehicleCount")
  local perVehicleResources = normalizePerVehicleResources(spec.perVehicleResources)
  local resourceQuantities = {}
  for resourceId, perVehicle in pairs(perVehicleResources) do
    resourceQuantities[resourceId] = vehicleCount * perVehicle
  end
  return {
    runtimeId = runtimeId,
    nodeId = nodeId,
    vehicleCount = vehicleCount,
    perVehicleResources = perVehicleResources,
    resourceQuantities = resourceQuantities,
    missionDemandId = spec.missionDemandId,
  }
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
  return setmetatable({ store = store, campaignState = campaignStateModule, commitments = {} }, Adapter)
end

function Adapter:_GetCommitment(runtimeId)
  local commitment = self.commitments[runtimeId]
  if not commitment then
    fail("unknown ground runtimeId=" .. tostring(runtimeId))
  end
  return commitment
end

function Adapter:_ValidateConsumed(commitment, resourceId)
  local transaction = self.store:GetTransaction(commitmentId(commitment.runtimeId, resourceId))
  if transaction.status ~= self.campaignState.TransactionStatus.CONSUMED then
    fail("ground commitment is not consumed runtime=" .. commitment.runtimeId .. " resource=" .. resourceId)
  end
  if transaction.originNodeId ~= commitment.nodeId
      or transaction.resourceId ~= resourceId
      or transaction.quantity ~= commitment.resourceQuantities[resourceId]
      or transaction.canonicalUnit ~= UNIT then
    fail("ground commitment mismatch runtime=" .. commitment.runtimeId .. " resource=" .. resourceId)
  end
  return transaction
end

function Adapter:CanMaterialize(spec)
  local commitment = normalizeSpec(spec)
  for resourceId, quantity in pairs(commitment.resourceQuantities) do
    local resource = self.store:GetResource(commitment.nodeId, resourceId)
    if resource.canonicalUnit ~= UNIT then
      fail("ground resource requires count unit node=" .. commitment.nodeId .. " resource=" .. resourceId)
    end
    if resource.available < quantity then
      return false, string.format(
        "GROUND_STRATEGIC_UNAVAILABLE node=%s resource=%s available=%s requested=%s",
        commitment.nodeId, resourceId, tostring(resource.available), tostring(quantity)
      )
    end
  end
  return true
end

function Adapter:OnMaterialized(spec)
  local commitment = normalizeSpec(spec)
  local existing = self.commitments[commitment.runtimeId]
  if existing then
    if existing.nodeId == commitment.nodeId
        and existing.vehicleCount == commitment.vehicleCount
        and existing.missionDemandId == commitment.missionDemandId then
      return existing, false
    end
    fail("runtimeId already registered with different ground commitment=" .. commitment.runtimeId)
  end

  local allowed, reason = self:CanMaterialize(commitment)
  if not allowed then
    return nil, false, reason
  end

  for _, resourceId in ipairs(sortedKeys(commitment.resourceQuantities)) do
    local quantity = commitment.resourceQuantities[resourceId]
    local id = commitmentId(commitment.runtimeId, resourceId)
    self.store:ReserveResource({
      transactionId = id,
      reservationId = id,
      missionDemandId = commitment.missionDemandId,
      carrierEntityId = commitment.runtimeId,
      kind = self.campaignState.TransactionKind.CONSUMPTION,
      resourceId = resourceId,
      quantity = quantity,
      canonicalUnit = UNIT,
      originNodeId = commitment.nodeId,
    })
    self.store:Consume(id)
  end

  self.commitments[commitment.runtimeId] = commitment
  return commitment, true
end

function Adapter:_Credit(prefix, commitment, vehicleCount, reason)
  vehicleCount = requirePositiveInteger(vehicleCount, "vehicleCount")
  if vehicleCount > commitment.vehicleCount then
    fail("vehicleCount exceeds commitment runtime=" .. commitment.runtimeId)
  end

  local result = {}
  for _, resourceId in ipairs(sortedKeys(commitment.perVehicleResources)) do
    self:_ValidateConsumed(commitment, resourceId)
    local quantity = vehicleCount * commitment.perVehicleResources[resourceId]
    local credit, inserted = self.store:CreditResourceOnce({
      creditId = creditId(prefix, commitment.runtimeId, resourceId),
      nodeId = commitment.nodeId,
      resourceId = resourceId,
      quantity = quantity,
      canonicalUnit = UNIT,
      reason = reason,
      entityId = commitment.runtimeId,
    })
    result[resourceId] = { quantity = quantity, inserted = inserted, creditId = credit.creditId }
  end
  return result
end

function Adapter:OnReturned(runtimeId, returnedVehicleCount)
  local commitment = self:_GetCommitment(requireNonEmptyString(runtimeId, "runtimeId"))
  return self:_Credit(RETURN_PREFIX, commitment, returnedVehicleCount, "GROUND_CONFIRMED_RETURN")
end

function Adapter:OnLost(runtimeId, lostVehicleCount, lossResourceIds)
  local commitment = self:_GetCommitment(requireNonEmptyString(runtimeId, "runtimeId"))
  if type(lossResourceIds) ~= "table" then
    fail("lossResourceIds must be a table")
  end
  lostVehicleCount = requirePositiveInteger(lostVehicleCount, "lostVehicleCount")
  if lostVehicleCount > commitment.vehicleCount then
    fail("lostVehicleCount exceeds commitment runtime=" .. commitment.runtimeId)
  end

  local result = {}
  for _, resourceId in ipairs(sortedKeys(commitment.perVehicleResources)) do
    self:_ValidateConsumed(commitment, resourceId)
    local lossResourceId = requireNonEmptyString(lossResourceIds[resourceId], "loss resourceId")
    local quantity = lostVehicleCount * commitment.perVehicleResources[resourceId]
    local credit, inserted = self.store:CreditResourceOnce({
      creditId = creditId(LOSS_PREFIX, commitment.runtimeId, resourceId),
      nodeId = commitment.nodeId,
      resourceId = lossResourceId,
      quantity = quantity,
      canonicalUnit = UNIT,
      reason = "GROUND_CONFIRMED_LOSS",
      entityId = commitment.runtimeId,
    })
    result[resourceId] = { quantity = quantity, inserted = inserted, creditId = credit.creditId }
  end
  return result
end

function Adapter:ReconcileRestore()
  local snapshot = self.store:ExportSnapshot()
  local reconciled, preservedLosses, alreadyResolved = 0, 0, 0

  for _, transaction in ipairs(snapshot.transactions or {}) do
    local runtimeId, resourceId = parseCommitmentId(transaction.transactionId)
    if runtimeId and transaction.status == self.campaignState.TransactionStatus.CONSUMED
        and transaction.canonicalUnit == UNIT then
      local returnCredit = self.store:GetResourceCredit(creditId(RETURN_PREFIX, runtimeId, resourceId))
      local lossCredit = self.store:GetResourceCredit(creditId(LOSS_PREFIX, runtimeId, resourceId))
      local restartCredit = self.store:GetResourceCredit(creditId(RESTART_PREFIX, runtimeId, resourceId))
      local settled = (returnCredit and returnCredit.quantity or 0) + (lossCredit and lossCredit.quantity or 0)
      local remaining = transaction.quantity - settled

      if remaining < 0 then
        fail("ground settlement exceeds consumed quantity runtime=" .. runtimeId .. " resource=" .. resourceId)
      elseif remaining == 0 then
        if lossCredit then preservedLosses = preservedLosses + 1 else alreadyResolved = alreadyResolved + 1 end
      elseif restartCredit then
        alreadyResolved = alreadyResolved + 1
      else
        self.store:CreditResourceOnce({
          creditId = creditId(RESTART_PREFIX, runtimeId, resourceId),
          nodeId = transaction.originNodeId,
          resourceId = resourceId,
          quantity = remaining,
          canonicalUnit = UNIT,
          reason = "GROUND_RESTART_RECONCILIATION",
          entityId = runtimeId,
        })
        reconciled = reconciled + 1
      end
    end
  end

  return {
    reconciled = reconciled,
    preservedLosses = preservedLosses,
    alreadyResolved = alreadyResolved,
  }
end

function Adapter:GetConfig()
  return {
    canonicalUnit = UNIT,
    transactionPrefix = TRANSACTION_PREFIX,
    returnPrefix = RETURN_PREFIX,
    lossPrefix = LOSS_PREFIX,
    restartPrefix = RESTART_PREFIX,
  }
end

return Adapter
