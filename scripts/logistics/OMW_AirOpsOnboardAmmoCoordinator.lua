-- Operation Mountain Watch - onboard ammunition expenditure coordinator.
--
-- This module uses the public MOOSE OPSGROUP/FLIGHTGROUP GetAmmoTot() path only
-- to capture shell-count telemetry in DCS World. CampaignState remains the
-- strategic authority. No STORAGE shell key is inferred or written, and no
-- scheduler is created here.
--
-- Current source-reviewed scope:
--   AMMUNITION_30MM_M230
--   AMMUNITION_30MM_GAU8
--
-- OH-58 M3P and FLARES_CHAFF remain unsupported until separate runtime telemetry
-- contracts are validated for those resources.

local OnboardAmmoCoordinator = {}

local TAG = "[OMW][Logistics.AirOpsOnboardAmmoCoordinator]"

OnboardAmmoCoordinator.SchemaVersion = "OMW-AIROPS-ONBOARD-AMMO-1"

OnboardAmmoCoordinator.ResourceId = {
  M230 = "AMMUNITION_30MM_M230",
  GAU8 = "AMMUNITION_30MM_GAU8",
}

local supportedResources = {
  [OnboardAmmoCoordinator.ResourceId.M230] = true,
  [OnboardAmmoCoordinator.ResourceId.GAU8] = true,
}

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function isFiniteNonNegativeInteger(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
    and math.floor(value) == value
end

local function requireSupportedResource(resourceId)
  requireNonEmptyString(resourceId, "resourceId")
  if not supportedResources[resourceId] then
    fail("unsupported onboard-ammo telemetry resourceId=" .. tostring(resourceId))
  end
  return resourceId
end

local function requireFlightGroup(flightGroup)
  if type(flightGroup) ~= "table" or type(flightGroup.GetAmmoTot) ~= "function" then
    fail("flightGroup with GetAmmoTot() is required")
  end
  return flightGroup
end

local function readShells(flightGroup)
  local ok, ammo = pcall(function()
    return flightGroup:GetAmmoTot()
  end)
  if not ok then
    fail("FLIGHTGROUP:GetAmmoTot() failed error=" .. tostring(ammo))
  end
  if type(ammo) ~= "table" or not isFiniteNonNegativeInteger(ammo.Shells) then
    fail("FLIGHTGROUP:GetAmmoTot() returned invalid Shells value")
  end
  return ammo.Shells
end

function OnboardAmmoCoordinator.Capture(flightGroup, spec)
  requireFlightGroup(flightGroup)
  if type(spec) ~= "table" then
    fail("capture spec must be a table")
  end

  local snapshot = {
    schemaVersion = OnboardAmmoCoordinator.SchemaVersion,
    nodeId = requireNonEmptyString(spec.nodeId, "nodeId"),
    entityId = requireNonEmptyString(spec.entityId, "entityId"),
    sortieId = requireNonEmptyString(spec.sortieId, "sortieId"),
    resourceId = requireSupportedResource(spec.resourceId),
    shells = readShells(flightGroup),
  }

  log(string.format(
    "CAPTURE nodeId=%s entityId=%s sortieId=%s resourceId=%s shells=%d",
    snapshot.nodeId,
    snapshot.entityId,
    snapshot.sortieId,
    snapshot.resourceId,
    snapshot.shells
  ))

  return snapshot
end

local function validateSnapshot(snapshot, label)
  if type(snapshot) ~= "table" then
    fail(label .. " snapshot must be a table")
  end
  if snapshot.schemaVersion ~= OnboardAmmoCoordinator.SchemaVersion then
    fail(label .. " snapshot schema mismatch")
  end
  requireNonEmptyString(snapshot.nodeId, label .. ".nodeId")
  requireNonEmptyString(snapshot.entityId, label .. ".entityId")
  requireNonEmptyString(snapshot.sortieId, label .. ".sortieId")
  requireSupportedResource(snapshot.resourceId)
  if not isFiniteNonNegativeInteger(snapshot.shells) then
    fail(label .. ".shells must be a non-negative integer")
  end
end

local function requireSameIdentity(beforeSnapshot, afterSnapshot)
  for _, field in ipairs({ "nodeId", "entityId", "sortieId", "resourceId" }) do
    if beforeSnapshot[field] ~= afterSnapshot[field] then
      fail("snapshot identity mismatch field=" .. field)
    end
  end
end

function OnboardAmmoCoordinator.Measure(beforeSnapshot, afterSnapshot)
  validateSnapshot(beforeSnapshot, "before")
  validateSnapshot(afterSnapshot, "after")
  requireSameIdentity(beforeSnapshot, afterSnapshot)

  if afterSnapshot.shells > beforeSnapshot.shells then
    fail(string.format(
      "shell count increased during measured sortie sortieId=%s before=%d after=%d",
      beforeSnapshot.sortieId,
      beforeSnapshot.shells,
      afterSnapshot.shells
    ))
  end

  return {
    schemaVersion = OnboardAmmoCoordinator.SchemaVersion,
    nodeId = beforeSnapshot.nodeId,
    entityId = beforeSnapshot.entityId,
    sortieId = beforeSnapshot.sortieId,
    resourceId = beforeSnapshot.resourceId,
    before = beforeSnapshot.shells,
    after = afterSnapshot.shells,
    consumed = beforeSnapshot.shells - afterSnapshot.shells,
  }
end

function OnboardAmmoCoordinator.Settle(campaignStateStore, campaignStateModule, beforeSnapshot, afterSnapshot)
  if type(campaignStateStore) ~= "table"
      or type(campaignStateStore.GetResource) ~= "function"
      or type(campaignStateStore.ReserveResource) ~= "function"
      or type(campaignStateStore.Consume) ~= "function" then
    fail("campaignStateStore requires GetResource(), ReserveResource() and Consume()")
  end
  if type(campaignStateModule) ~= "table"
      or type(campaignStateModule.TransactionKind) ~= "table"
      or type(campaignStateModule.TransactionKind.CONSUMPTION) ~= "string" then
    fail("CampaignState module with TransactionKind.CONSUMPTION is required")
  end

  local measurement = OnboardAmmoCoordinator.Measure(beforeSnapshot, afterSnapshot)
  local resource = campaignStateStore:GetResource(measurement.nodeId, measurement.resourceId)
  if resource.canonicalUnit ~= "count" then
    fail("onboard-ammo resource canonical unit must be count resourceId=" .. measurement.resourceId)
  end

  if measurement.consumed == 0 then
    log(string.format(
      "SETTLE_NOOP nodeId=%s entityId=%s sortieId=%s resourceId=%s",
      measurement.nodeId,
      measurement.entityId,
      measurement.sortieId,
      measurement.resourceId
    ))
    return {
      measurement = measurement,
      transaction = nil,
      created = false,
      consumed = false,
    }
  end

  local transactionId = table.concat({
    "ONBOARD_AMMO",
    measurement.sortieId,
    measurement.entityId,
    measurement.resourceId,
  }, ":")

  local transaction, created = campaignStateStore:ReserveResource({
    transactionId = transactionId,
    reservationId = transactionId,
    missionDemandId = measurement.sortieId,
    carrierEntityId = measurement.entityId,
    kind = campaignStateModule.TransactionKind.CONSUMPTION,
    resourceId = measurement.resourceId,
    quantity = measurement.consumed,
    canonicalUnit = "count",
    originNodeId = measurement.nodeId,
  })

  local consumedTransaction, consumed = campaignStateStore:Consume(transactionId)

  log(string.format(
    "SETTLE nodeId=%s entityId=%s sortieId=%s resourceId=%s rounds=%d created=%s consumed=%s",
    measurement.nodeId,
    measurement.entityId,
    measurement.sortieId,
    measurement.resourceId,
    measurement.consumed,
    tostring(created),
    tostring(consumed)
  ))

  return {
    measurement = measurement,
    transaction = consumedTransaction or transaction,
    created = created,
    consumed = consumed,
  }
end

return OnboardAmmoCoordinator
