-- Operation Mountain Watch - CampaignState resource and transaction foundation.
--
-- CampaignState is the strategic authority for the resources stored here.
-- This module deliberately has no MOOSE or DCS dependency, no filesystem I/O,
-- no scheduler, and no physical transport implementation. MOOSE remains the
-- operational framework for transport and STORAGE representation.

local CampaignState = {}

local Store = {}
Store.__index = Store

local TAG = "[OMW][CampaignState]"

CampaignState.ResourceId = {
  JP8 = "FUEL_JP8",
  AVGAS = "FUEL_AVGAS",
}

CampaignState.Unit = {
  KG = "kg",
  COUNT = "count",
}

CampaignState.TransactionKind = {
  TRANSFER = "TRANSFER",
  CONSUMPTION = "CONSUMPTION",
}

CampaignState.TransactionStatus = {
  RESERVED = "RESERVED",
  LOADING = "LOADING",
  IN_TRANSIT = "IN_TRANSIT",
  DELIVERED = "DELIVERED",
  CONSUMED = "CONSUMED",
  LOST = "LOST",
  CANCELLED = "CANCELLED",
}

CampaignState.AircraftRecoveryStatus = {
  RECOVERY_IN_PROGRESS = "RECOVERY_IN_PROGRESS",
  RECOVERED_AWAITING_REPAIR = "RECOVERED_AWAITING_REPAIR",
  AVAILABLE = "AVAILABLE",
}

CampaignState.SnapshotVersion = "CAMPAIGNSTATE-SNAPSHOT-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function isFiniteNonNegative(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

local function isFinitePositive(value)
  return isFiniteNonNegative(value) and value > 0
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function copyResourceEntry(entry)
  return {
    quantity = entry.quantity,
    unit = entry.unit,
  }
end

local function copyResources(resources)
  local result = {}
  for resourceId, entry in pairs(resources) do
    result[resourceId] = copyResourceEntry(entry)
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

local function normalizeNodeResources(node)
  local resources = {}

  if node.resources ~= nil then
    if type(node.resources) ~= "table" then
      fail("node resources must be a table")
    end

    for resourceId, entry in pairs(node.resources) do
      requireNonEmptyString(resourceId, "resourceId")
      if type(entry) ~= "table" then
        fail("resource entry must be a table resourceId=" .. tostring(resourceId))
      end
      if not isFiniteNonNegative(entry.quantity) then
        fail("resource quantity must be non-negative finite resourceId=" .. tostring(resourceId))
      end
      requireNonEmptyString(entry.unit, "resource unit")
      resources[resourceId] = {
        quantity = entry.quantity,
        unit = entry.unit,
      }
    end
  end

  if node.resourcesKg ~= nil then
    if type(node.resourcesKg) ~= "table" then
      fail("node resourcesKg must be a table")
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

      local existing = resources[resourceId]
      if existing and (existing.unit ~= CampaignState.Unit.KG or existing.quantity ~= quantityKg) then
        fail("resources/resourcesKg mismatch resourceId=" .. tostring(resourceId))
      end

      resources[resourceId] = {
        quantity = quantityKg,
        unit = CampaignState.Unit.KG,
      }
    end
  end

  if next(resources) == nil then
    fail("node requires resources or resourcesKg")
  end

  return resources
end

local function validateNode(node)
  if type(node) ~= "table" then
    fail("node must be a table")
  end
  requireNonEmptyString(node.nodeId, "nodeId")
  requireNonEmptyString(node.airbaseName, "airbaseName")
  return normalizeNodeResources(node)
end

local function copyTransaction(transaction)
  if not transaction then
    return nil
  end

  return {
    transactionId = transaction.transactionId,
    reservationId = transaction.reservationId,
    cargoId = transaction.cargoId,
    missionDemandId = transaction.missionDemandId,
    carrierEntityId = transaction.carrierEntityId,
    kind = transaction.kind,
    resourceId = transaction.resourceId,
    quantity = transaction.quantity,
    canonicalUnit = transaction.canonicalUnit,
    originNodeId = transaction.originNodeId,
    destinationNodeId = transaction.destinationNodeId,
    status = transaction.status,
    originDebited = transaction.originDebited,
    destinationCredited = transaction.destinationCredited,
  }
end

local function copyCredit(credit)
  if not credit then
    return nil
  end
  return {
    creditId = credit.creditId,
    nodeId = credit.nodeId,
    resourceId = credit.resourceId,
    quantity = credit.quantity,
    canonicalUnit = credit.canonicalUnit,
    reason = credit.reason,
    entityId = credit.entityId,
  }
end

local function copyAircraftRecovery(recovery)
  if not recovery then
    return nil
  end
  return {
    entityId = recovery.entityId,
    recoveryNodeId = recovery.recoveryNodeId,
    status = recovery.status,
    recoveryStartedAt = recovery.recoveryStartedAt,
    recoveryCompleteAt = recovery.recoveryCompleteAt,
    repairCompleteAt = recovery.repairCompleteAt,
  }
end

local function specsEqual(a, b)
  return a.transactionId == b.transactionId
    and a.reservationId == b.reservationId
    and a.cargoId == b.cargoId
    and a.missionDemandId == b.missionDemandId
    and a.carrierEntityId == b.carrierEntityId
    and a.kind == b.kind
    and a.resourceId == b.resourceId
    and a.quantity == b.quantity
    and a.canonicalUnit == b.canonicalUnit
    and a.originNodeId == b.originNodeId
    and a.destinationNodeId == b.destinationNodeId
end

local function creditsEqual(a, b)
  return a.creditId == b.creditId
    and a.nodeId == b.nodeId
    and a.resourceId == b.resourceId
    and a.quantity == b.quantity
    and a.canonicalUnit == b.canonicalUnit
    and a.reason == b.reason
    and a.entityId == b.entityId
end

local function getNode(store, nodeId)
  local node = store.nodesById[nodeId]
  if not node then
    fail("unknown nodeId=" .. tostring(nodeId))
  end
  return node
end

local function getResource(store, nodeId, resourceId)
  local node = getNode(store, nodeId)
  local resource = node.resources[resourceId]
  if not resource then
    fail(string.format("unknown resourceId=%s for nodeId=%s", tostring(resourceId), tostring(nodeId)))
  end
  return resource
end

local function getReserved(store, nodeId, resourceId)
  local byResource = store.reservedByNode[nodeId]
  if not byResource then
    return 0
  end
  return byResource[resourceId] or 0
end

local function adjustReserved(store, nodeId, resourceId, delta)
  local byResource = store.reservedByNode[nodeId]
  if not byResource then
    byResource = {}
    store.reservedByNode[nodeId] = byResource
  end

  local nextValue = (byResource[resourceId] or 0) + delta
  if nextValue < 0 then
    fail(string.format("reserved quantity underflow nodeId=%s resourceId=%s", nodeId, resourceId))
  end
  byResource[resourceId] = nextValue
end

local function debitOrigin(store, transaction)
  if transaction.originDebited then
    return false
  end

  local resource = getResource(store, transaction.originNodeId, transaction.resourceId)
  if resource.quantity < transaction.quantity then
    fail(string.format(
      "insufficient stock during debit transactionId=%s available=%s requested=%s",
      transaction.transactionId,
      tostring(resource.quantity),
      tostring(transaction.quantity)
    ))
  end

  resource.quantity = resource.quantity - transaction.quantity
  adjustReserved(store, transaction.originNodeId, transaction.resourceId, -transaction.quantity)
  transaction.originDebited = true
  return true
end

local function creditDestination(store, transaction)
  if transaction.destinationCredited then
    return false
  end

  local resource = getResource(store, transaction.destinationNodeId, transaction.resourceId)
  if resource.unit ~= transaction.canonicalUnit then
    fail("destination canonical unit mismatch transactionId=" .. tostring(transaction.transactionId))
  end

  resource.quantity = resource.quantity + transaction.quantity
  transaction.destinationCredited = true
  return true
end

local function getTransaction(store, transactionId)
  local transaction = store.transactionsById[transactionId]
  if not transaction then
    fail("unknown transactionId=" .. tostring(transactionId))
  end
  return transaction
end

local function ensureStatus(transaction, expected)
  if transaction.status ~= expected then
    fail(string.format(
      "invalid transaction transition transactionId=%s status=%s expected=%s",
      transaction.transactionId,
      tostring(transaction.status),
      tostring(expected)
    ))
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
    local resources = validateNode(node)
    if nodesById[node.nodeId] ~= nil then
      fail("duplicate nodeId=" .. tostring(node.nodeId))
    end
    nodesById[node.nodeId] = {
      nodeId = node.nodeId,
      airbaseName = node.airbaseName,
      resources = resources,
    }
  end

  if next(nodesById) == nil then
    fail("initialState contains no nodes")
  end

  return setmetatable({
    schemaVersion = initialState.schemaVersion or "CAMPAIGNSTATE-RESOURCE-TRANSACTION-1",
    nodesById = nodesById,
    reservedByNode = {},
    transactionsById = {},
    creditsById = {},
    aircraftRecoveryById = {},
  }, Store)
end

function CampaignState.Restore(snapshot)
  if type(snapshot) ~= "table" then
    fail("snapshot must be a table")
  end
  if snapshot.snapshotVersion ~= CampaignState.SnapshotVersion then
    fail("unsupported snapshotVersion=" .. tostring(snapshot.snapshotVersion))
  end

  local store = CampaignState.New({
    schemaVersion = snapshot.stateSchemaVersion,
    nodes = snapshot.nodes,
  })

  for _, transaction in ipairs(snapshot.transactions or {}) do
    local transactionId = requireNonEmptyString(transaction.transactionId, "transactionId")
    if store.transactionsById[transactionId] then
      fail("duplicate snapshot transactionId=" .. tostring(transactionId))
    end
    store.transactionsById[transactionId] = copyTransaction(transaction)
    if transaction.originDebited ~= true
        and (transaction.status == CampaignState.TransactionStatus.RESERVED
          or transaction.status == CampaignState.TransactionStatus.LOADING) then
      adjustReserved(store, transaction.originNodeId, transaction.resourceId, transaction.quantity)
    end
  end

  for _, credit in ipairs(snapshot.resourceCredits or {}) do
    local creditId = requireNonEmptyString(credit.creditId, "creditId")
    if store.creditsById[creditId] then
      fail("duplicate snapshot creditId=" .. tostring(creditId))
    end
    store.creditsById[creditId] = copyCredit(credit)
  end

  for _, recovery in ipairs(snapshot.aircraftRecovery or {}) do
    local entityId = requireNonEmptyString(recovery.entityId, "entityId")
    if store.aircraftRecoveryById[entityId] then
      fail("duplicate snapshot aircraft entityId=" .. tostring(entityId))
    end
    store.aircraftRecoveryById[entityId] = copyAircraftRecovery(recovery)
  end

  return store
end

function Store:GetResource(nodeId, resourceId)
  local resource = getResource(self, nodeId, resourceId)
  local reserved = getReserved(self, nodeId, resourceId)
  return {
    nodeId = nodeId,
    resourceId = resourceId,
    quantity = resource.quantity,
    canonicalUnit = resource.unit,
    reserved = reserved,
    available = resource.quantity - reserved,
  }
end

function Store:GetResourceKg(nodeId, resourceId)
  local resource = getResource(self, nodeId, resourceId)
  if resource.unit ~= CampaignState.Unit.KG then
    fail(string.format("resourceId=%s for nodeId=%s is not kg", tostring(resourceId), tostring(nodeId)))
  end
  return resource.quantity
end

function Store:GetFuelSnapshot(nodeId)
  local node = getNode(self, nodeId)
  local resourcesKg = {}

  for _, resourceId in ipairs({ CampaignState.ResourceId.JP8, CampaignState.ResourceId.AVGAS }) do
    local resource = node.resources[resourceId]
    if not resource or resource.unit ~= CampaignState.Unit.KG then
      fail(string.format("fuel resource unavailable nodeId=%s resourceId=%s", nodeId, resourceId))
    end
    resourcesKg[resourceId] = resource.quantity
  end

  return {
    nodeId = node.nodeId,
    airbaseName = node.airbaseName,
    resourcesKg = resourcesKg,
  }
end

function Store:ReserveResource(spec)
  if type(spec) ~= "table" then
    fail("transaction spec must be a table")
  end

  local transactionId = requireNonEmptyString(spec.transactionId, "transactionId")
  local reservationId = requireNonEmptyString(spec.reservationId or transactionId, "reservationId")
  local originNodeId = requireNonEmptyString(spec.originNodeId, "originNodeId")
  local resourceId = requireNonEmptyString(spec.resourceId, "resourceId")
  local kind = requireNonEmptyString(spec.kind, "kind")

  if kind ~= CampaignState.TransactionKind.TRANSFER and kind ~= CampaignState.TransactionKind.CONSUMPTION then
    fail("unsupported transaction kind=" .. tostring(kind))
  end
  if not isFinitePositive(spec.quantity) then
    fail("transaction quantity must be positive finite")
  end

  local origin = getResource(self, originNodeId, resourceId)
  local canonicalUnit = spec.canonicalUnit or origin.unit
  if canonicalUnit ~= origin.unit then
    fail("origin canonical unit mismatch transactionId=" .. tostring(transactionId))
  end

  local destinationNodeId = spec.destinationNodeId
  if kind == CampaignState.TransactionKind.TRANSFER then
    destinationNodeId = requireNonEmptyString(destinationNodeId, "destinationNodeId")
    local destination = getResource(self, destinationNodeId, resourceId)
    if destination.unit ~= canonicalUnit then
      fail("destination canonical unit mismatch transactionId=" .. tostring(transactionId))
    end
  elseif destinationNodeId ~= nil then
    fail("consumption transaction must not define destinationNodeId")
  end

  local candidate = {
    transactionId = transactionId,
    reservationId = reservationId,
    cargoId = spec.cargoId,
    missionDemandId = spec.missionDemandId,
    carrierEntityId = spec.carrierEntityId,
    kind = kind,
    resourceId = resourceId,
    quantity = spec.quantity,
    canonicalUnit = canonicalUnit,
    originNodeId = originNodeId,
    destinationNodeId = destinationNodeId,
    status = CampaignState.TransactionStatus.RESERVED,
    originDebited = false,
    destinationCredited = false,
  }

  local existing = self.transactionsById[transactionId]
  if existing then
    if specsEqual(existing, candidate) then
      return copyTransaction(existing), false
    end
    fail("transactionId already exists with different specification=" .. tostring(transactionId))
  end

  local available = origin.quantity - getReserved(self, originNodeId, resourceId)
  if available < spec.quantity then
    fail(string.format(
      "insufficient available resource transactionId=%s available=%s requested=%s",
      transactionId,
      tostring(available),
      tostring(spec.quantity)
    ))
  end

  adjustReserved(self, originNodeId, resourceId, spec.quantity)
  self.transactionsById[transactionId] = candidate
  return copyTransaction(candidate), true
end

function Store:MarkLoading(transactionId)
  local transaction = getTransaction(self, transactionId)
  if transaction.status == CampaignState.TransactionStatus.LOADING then
    return copyTransaction(transaction), false
  end
  ensureStatus(transaction, CampaignState.TransactionStatus.RESERVED)
  transaction.status = CampaignState.TransactionStatus.LOADING
  return copyTransaction(transaction), true
end

function Store:MarkInTransit(transactionId)
  local transaction = getTransaction(self, transactionId)
  if transaction.status == CampaignState.TransactionStatus.IN_TRANSIT then
    return copyTransaction(transaction), false
  end
  if transaction.kind ~= CampaignState.TransactionKind.TRANSFER then
    fail("only transfer transaction can enter IN_TRANSIT transactionId=" .. tostring(transactionId))
  end
  ensureStatus(transaction, CampaignState.TransactionStatus.LOADING)
  debitOrigin(self, transaction)
  transaction.status = CampaignState.TransactionStatus.IN_TRANSIT
  return copyTransaction(transaction), true
end

function Store:MarkDelivered(transactionId)
  local transaction = getTransaction(self, transactionId)
  if transaction.status == CampaignState.TransactionStatus.DELIVERED then
    return copyTransaction(transaction), false
  end
  if transaction.kind ~= CampaignState.TransactionKind.TRANSFER then
    fail("only transfer transaction can be DELIVERED transactionId=" .. tostring(transactionId))
  end
  ensureStatus(transaction, CampaignState.TransactionStatus.IN_TRANSIT)
  creditDestination(self, transaction)
  transaction.status = CampaignState.TransactionStatus.DELIVERED
  return copyTransaction(transaction), true
end

function Store:MarkLost(transactionId)
  local transaction = getTransaction(self, transactionId)
  if transaction.status == CampaignState.TransactionStatus.LOST then
    return copyTransaction(transaction), false
  end
  if transaction.kind ~= CampaignState.TransactionKind.TRANSFER then
    fail("only transfer transaction can be LOST transactionId=" .. tostring(transactionId))
  end
  ensureStatus(transaction, CampaignState.TransactionStatus.IN_TRANSIT)
  transaction.status = CampaignState.TransactionStatus.LOST
  return copyTransaction(transaction), true
end

function Store:Consume(transactionId)
  local transaction = getTransaction(self, transactionId)
  if transaction.status == CampaignState.TransactionStatus.CONSUMED then
    return copyTransaction(transaction), false
  end
  if transaction.kind ~= CampaignState.TransactionKind.CONSUMPTION then
    fail("only consumption transaction can be CONSUMED transactionId=" .. tostring(transactionId))
  end
  if transaction.status ~= CampaignState.TransactionStatus.RESERVED
      and transaction.status ~= CampaignState.TransactionStatus.LOADING then
    fail("invalid consumption transition transactionId=" .. tostring(transactionId) .. " status=" .. tostring(transaction.status))
  end
  debitOrigin(self, transaction)
  transaction.status = CampaignState.TransactionStatus.CONSUMED
  return copyTransaction(transaction), true
end

function Store:Cancel(transactionId)
  local transaction = getTransaction(self, transactionId)
  if transaction.status == CampaignState.TransactionStatus.CANCELLED then
    return copyTransaction(transaction), false
  end
  if transaction.status ~= CampaignState.TransactionStatus.RESERVED
      and transaction.status ~= CampaignState.TransactionStatus.LOADING then
    fail("only RESERVED/LOADING transaction can be cancelled transactionId=" .. tostring(transactionId))
  end

  adjustReserved(self, transaction.originNodeId, transaction.resourceId, -transaction.quantity)
  transaction.status = CampaignState.TransactionStatus.CANCELLED
  return copyTransaction(transaction), true
end

function Store:GetTransaction(transactionId)
  return copyTransaction(getTransaction(self, transactionId))
end

function Store:CreditResourceOnce(spec)
  if type(spec) ~= "table" then
    fail("resource credit spec must be a table")
  end

  local creditId = requireNonEmptyString(spec.creditId, "creditId")
  local nodeId = requireNonEmptyString(spec.nodeId, "nodeId")
  local resourceId = requireNonEmptyString(spec.resourceId, "resourceId")
  local resource = getResource(self, nodeId, resourceId)
  local canonicalUnit = spec.canonicalUnit or resource.unit

  if canonicalUnit ~= resource.unit then
    fail("resource credit canonical unit mismatch creditId=" .. tostring(creditId))
  end
  if not isFinitePositive(spec.quantity) then
    fail("resource credit quantity must be positive finite")
  end

  local candidate = {
    creditId = creditId,
    nodeId = nodeId,
    resourceId = resourceId,
    quantity = spec.quantity,
    canonicalUnit = canonicalUnit,
    reason = spec.reason,
    entityId = spec.entityId,
  }

  local existing = self.creditsById[creditId]
  if existing then
    if creditsEqual(existing, candidate) then
      return copyCredit(existing), false
    end
    fail("creditId already exists with different specification=" .. tostring(creditId))
  end

  resource.quantity = resource.quantity + spec.quantity
  self.creditsById[creditId] = candidate
  return copyCredit(candidate), true
end

function Store:GetResourceCredit(creditId)
  return copyCredit(self.creditsById[creditId])
end

function Store:BeginAircraftRecovery(spec)
  if type(spec) ~= "table" then
    fail("aircraft recovery spec must be a table")
  end

  local entityId = requireNonEmptyString(spec.entityId, "entityId")
  local recoveryNodeId = requireNonEmptyString(spec.recoveryNodeId, "recoveryNodeId")
  getNode(self, recoveryNodeId)

  if not isFiniteNonNegative(spec.recoveryStartedAt)
      or not isFiniteNonNegative(spec.recoveryCompleteAt)
      or not isFiniteNonNegative(spec.repairCompleteAt) then
    fail("aircraft recovery times must be non-negative finite")
  end
  if spec.recoveryCompleteAt < spec.recoveryStartedAt then
    fail("recoveryCompleteAt precedes recoveryStartedAt entityId=" .. tostring(entityId))
  end
  if spec.repairCompleteAt < spec.recoveryCompleteAt then
    fail("repairCompleteAt precedes recoveryCompleteAt entityId=" .. tostring(entityId))
  end

  local candidate = {
    entityId = entityId,
    recoveryNodeId = recoveryNodeId,
    status = CampaignState.AircraftRecoveryStatus.RECOVERY_IN_PROGRESS,
    recoveryStartedAt = spec.recoveryStartedAt,
    recoveryCompleteAt = spec.recoveryCompleteAt,
    repairCompleteAt = spec.repairCompleteAt,
  }

  local existing = self.aircraftRecoveryById[entityId]
  if existing then
    if existing.recoveryNodeId == candidate.recoveryNodeId
        and existing.recoveryStartedAt == candidate.recoveryStartedAt
        and existing.recoveryCompleteAt == candidate.recoveryCompleteAt
        and existing.repairCompleteAt == candidate.repairCompleteAt then
      return copyAircraftRecovery(existing), false
    end
    fail("aircraft recovery already exists with different specification entityId=" .. tostring(entityId))
  end

  self.aircraftRecoveryById[entityId] = candidate
  return copyAircraftRecovery(candidate), true
end

function Store:CompleteAircraftRecovery(entityId, now)
  entityId = requireNonEmptyString(entityId, "entityId")
  if not isFiniteNonNegative(now) then
    fail("now must be non-negative finite")
  end

  local recovery = self.aircraftRecoveryById[entityId]
  if not recovery then
    fail("unknown aircraft recovery entityId=" .. tostring(entityId))
  end
  if recovery.status == CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR
      or recovery.status == CampaignState.AircraftRecoveryStatus.AVAILABLE then
    return copyAircraftRecovery(recovery), false
  end
  if now < recovery.recoveryCompleteAt then
    fail("aircraft recovery not yet complete entityId=" .. tostring(entityId))
  end

  recovery.status = CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR
  return copyAircraftRecovery(recovery), true
end

function Store:CompleteAircraftRepair(entityId, now)
  entityId = requireNonEmptyString(entityId, "entityId")
  if not isFiniteNonNegative(now) then
    fail("now must be non-negative finite")
  end

  local recovery = self.aircraftRecoveryById[entityId]
  if not recovery then
    fail("unknown aircraft recovery entityId=" .. tostring(entityId))
  end
  if recovery.status == CampaignState.AircraftRecoveryStatus.AVAILABLE then
    return copyAircraftRecovery(recovery), false
  end
  if recovery.status ~= CampaignState.AircraftRecoveryStatus.RECOVERED_AWAITING_REPAIR then
    fail("aircraft repair requires recovered state entityId=" .. tostring(entityId))
  end
  if now < recovery.repairCompleteAt then
    fail("aircraft repair lock not yet complete entityId=" .. tostring(entityId))
  end

  recovery.status = CampaignState.AircraftRecoveryStatus.AVAILABLE
  return copyAircraftRecovery(recovery), true
end

function Store:GetAircraftRecovery(entityId)
  return copyAircraftRecovery(self.aircraftRecoveryById[entityId])
end

function Store:ExportSnapshot()
  local nodes = {}
  for _, nodeId in ipairs(sortedKeys(self.nodesById)) do
    local node = self.nodesById[nodeId]
    nodes[#nodes + 1] = {
      nodeId = node.nodeId,
      airbaseName = node.airbaseName,
      resources = copyResources(node.resources),
    }
  end

  local transactions = {}
  for _, transactionId in ipairs(sortedKeys(self.transactionsById)) do
    transactions[#transactions + 1] = copyTransaction(self.transactionsById[transactionId])
  end

  local resourceCredits = {}
  for _, creditId in ipairs(sortedKeys(self.creditsById)) do
    resourceCredits[#resourceCredits + 1] = copyCredit(self.creditsById[creditId])
  end

  local aircraftRecovery = {}
  for _, entityId in ipairs(sortedKeys(self.aircraftRecoveryById)) do
    aircraftRecovery[#aircraftRecovery + 1] = copyAircraftRecovery(self.aircraftRecoveryById[entityId])
  end

  return {
    snapshotVersion = CampaignState.SnapshotVersion,
    stateSchemaVersion = self.schemaVersion,
    nodes = nodes,
    transactions = transactions,
    resourceCredits = resourceCredits,
    aircraftRecovery = aircraftRecovery,
  }
end

return CampaignState
