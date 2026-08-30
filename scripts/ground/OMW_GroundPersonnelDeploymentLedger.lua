-- Operation Mountain Watch - strategic PERSONNEL deployment reservation/settlement helper.
--
-- CampaignState remains the sole strategic resource authority. Deployment reserves
-- personnel so they are unavailable while physically deployed, but does not consume
-- them. On physical MOOSE return the reservation is released and only confirmed
-- casualties are consumed exactly once.

local Ledger = {}
local Deployment = {}
Deployment.__index = Deployment

local TAG = "[OMW][Ground.PersonnelDeploymentLedger]"
Ledger.SchemaVersion = "OMW-GROUND-PERSONNEL-DEPLOYMENT-LEDGER-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function requirePositiveInteger(value, label)
  if type(value) ~= "number" or value < 1 or value % 1 ~= 0 then
    fail(label .. " requires positive integer")
  end
  return value
end

function Ledger.New(spec)
  requireTable(spec, "spec")
  local store = requireTable(spec.store, "spec.store")
  local campaignState = requireTable(spec.campaignState, "spec.campaignState")
  if type(store.GetResource) ~= "function"
      or type(store.ReserveResource) ~= "function"
      or type(store.Cancel) ~= "function"
      or type(store.Consume) ~= "function"
      or type(store.CompleteConsumption) ~= "function" then
    fail("CampaignState store requires GetResource(), ReserveResource(), Cancel(), Consume(), and CompleteConsumption()")
  end
  if type(campaignState.TransactionKind) ~= "table"
      or campaignState.TransactionKind.CONSUMPTION == nil then
    fail("campaignState.TransactionKind.CONSUMPTION is required")
  end

  local nodeId = requireNonEmptyString(spec.nodeId, "spec.nodeId")
  local resourceId = requireNonEmptyString(spec.resourceId, "spec.resourceId")
  local deploymentId = requireNonEmptyString(spec.deploymentId, "spec.deploymentId")
  local entityId = requireNonEmptyString(spec.entityId, "spec.entityId")
  local quantity = requirePositiveInteger(spec.quantity, "spec.quantity")
  local canonicalUnit = spec.canonicalUnit or "count"

  local before = store:GetResource(nodeId, resourceId)
  if before.canonicalUnit ~= canonicalUnit then
    fail("resource canonical unit mismatch")
  end
  if before.available < quantity then
    fail(string.format("insufficient personnel nodeId=%s available=%s requested=%s", nodeId, tostring(before.available), tostring(quantity)))
  end

  local transaction, created = store:ReserveResource({
    transactionId = deploymentId,
    reservationId = deploymentId,
    missionDemandId = spec.missionDemandId,
    carrierEntityId = entityId,
    kind = campaignState.TransactionKind.CONSUMPTION,
    resourceId = resourceId,
    quantity = quantity,
    canonicalUnit = canonicalUnit,
    originNodeId = nodeId,
  })

  return setmetatable({
    store = store,
    campaignState = campaignState,
    nodeId = nodeId,
    resourceId = resourceId,
    deploymentId = deploymentId,
    entityId = entityId,
    quantity = quantity,
    canonicalUnit = canonicalUnit,
    reservationCreated = created == true,
    settled = false,
    survivors = nil,
    casualties = nil,
    lossTransactionId = deploymentId .. "|LOSS",
  }, Deployment), transaction, created
end

function Deployment:GetSnapshot()
  return self.store:GetResource(self.nodeId, self.resourceId)
end

function Deployment:SettleReturned(survivors)
  if self.settled then
    return {
      survivors = self.survivors,
      casualties = self.casualties,
      snapshot = self:GetSnapshot(),
    }, false
  end
  if type(survivors) ~= "number" or survivors < 0 or survivors % 1 ~= 0 or survivors > self.quantity then
    fail("survivors must be integer in deployment range")
  end

  local casualties = self.quantity - survivors

  -- Release the temporary deployment reservation first. The full deployment was
  -- never consumed, so returning personnel require no compensating credit.
  self.store:Cancel(self.deploymentId)

  if casualties > 0 then
    local loss, created = self.store:ReserveResource({
      transactionId = self.lossTransactionId,
      reservationId = self.lossTransactionId,
      carrierEntityId = self.entityId,
      kind = self.campaignState.TransactionKind.CONSUMPTION,
      resourceId = self.resourceId,
      quantity = casualties,
      canonicalUnit = self.canonicalUnit,
      originNodeId = self.nodeId,
    })
    if created == true then
      self.store:Consume(loss.transactionId)
      self.store:CompleteConsumption(loss.transactionId)
    end
  end

  self.settled = true
  self.survivors = survivors
  self.casualties = casualties

  return {
    survivors = survivors,
    casualties = casualties,
    snapshot = self:GetSnapshot(),
    lossTransactionId = casualties > 0 and self.lossTransactionId or nil,
  }, true
end

return Ledger
