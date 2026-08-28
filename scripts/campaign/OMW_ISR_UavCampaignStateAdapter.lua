-- Operation Mountain Watch - CampaignState adapter for player ISR UAV settlement.
--
-- MOOSE AIRWING owns physical admission, queueing and turnaround. CampaignState
-- mirrors a confirmed physical start and a confirmed physical recovery using
-- idempotent transaction/credit IDs. It does not maintain a second queue.

local Adapter = {}
Adapter.__index = Adapter

local TAG = "[OMW][ISR.UavCampaignStateAdapter]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires a non-empty string")
  end
  return value
end

function Adapter.New(config)
  if type(config) ~= "table" or type(config.campaignState) ~= "table" then
    fail("config.campaignState is required")
  end
  if type(config.campaignState.ReserveResource) ~= "function"
      or type(config.campaignState.Cancel) ~= "function"
      or type(config.campaignState.Consume) ~= "function"
      or type(config.campaignState.CreditResourceOnce) ~= "function" then
    fail("campaignState lacks reservation/recovery operations")
  end
  return setmetatable({
    campaignState = config.campaignState,
    nodeId = requireString(config.nodeId, "config.nodeId"),
    reservationsByRequestId = {},
  }, Adapter)
end

function Adapter:Reserve(requestId, profile)
  requestId = requireString(requestId, "requestId")
  if type(profile) ~= "table" then
    fail("profile is required")
  end
  if self.reservationsByRequestId[requestId] then
    return self.reservationsByRequestId[requestId]
  end

  local transactionId = "ISR-UAV-RESERVE:" .. requestId
  local ok, transaction, reason = pcall(self.campaignState.ReserveResource, self.campaignState, {
    transactionId = transactionId,
    reservationId = transactionId,
    cargoId = transactionId,
    missionDemandId = requestId,
    carrierEntityId = "ISR_CELL",
    kind = "CONSUMPTION",
    resourceId = requireString(profile.resourceId, "profile.resourceId"),
    quantity = 1,
    canonicalUnit = "count",
    originNodeId = self.nodeId,
  })
  if not ok then
    if tostring(transaction):find("insufficient available resource", 1, true) then
      return nil, "CAMPAIGNSTATE_MOOSE_DIVERGENCE_RESOURCE_UNAVAILABLE"
    end
    return nil, "CAMPAIGNSTATE_RESERVATION_FAILED"
  end
  if not transaction then
    return nil, reason or "CAMPAIGNSTATE_RESERVATION_FAILED"
  end

  local reservation = {
    requestId = requestId,
    transactionId = transactionId,
    resourceId = profile.resourceId,
    platformId = profile.platformId,
    consumed = false,
    recovered = false,
  }
  self.reservationsByRequestId[requestId] = reservation
  return reservation
end

function Adapter:ConsumeAtPhysicalStart(requestId)
  local reservation = self.reservationsByRequestId[requireString(requestId, "requestId")]
  if not reservation then
    return nil, "NO_RESERVATION"
  end
  if reservation.consumed then
    return reservation
  end
  local ok, transaction, reason = pcall(self.campaignState.Consume,
    self.campaignState, reservation.transactionId)
  if not ok then
    return nil, "CAMPAIGNSTATE_CONSUME_FAILED:" .. tostring(transaction)
  end
  if not transaction then
    return nil, reason or "CAMPAIGNSTATE_CONSUME_FAILED"
  end
  reservation.consumed = true
  return reservation
end

function Adapter:BeginPhysicalStart(requestId, profile)
  local reservation, reason = self:Reserve(requestId, profile)
  if not reservation then
    return nil, reason
  end
  local consumed, consumeReason = self:ConsumeAtPhysicalStart(requestId)
  if consumed then
    return consumed
  end

  -- A failed consume must not leave a ghost reservation. The physical mission
  -- caller will recall via MOOSE and report the reconciliation failure.
  if not reservation.consumed then
    pcall(self.campaignState.Cancel, self.campaignState, reservation.transactionId)
    self.reservationsByRequestId[requestId] = nil
  end
  return nil, consumeReason
end

function Adapter:RecoverAfterPhysicalRecovery(requestId)
  local reservation = self.reservationsByRequestId[requireString(requestId, "requestId")]
  if not reservation then
    return nil, "NO_RESERVATION"
  end
  if not reservation.consumed then
    return nil, "PHYSICAL_START_NOT_RECORDED"
  end
  if reservation.recovered then
    return reservation
  end

  local credit, reason = self.campaignState:CreditResourceOnce({
    creditId = "ISR-UAV-RECOVERY:" .. reservation.requestId,
    nodeId = self.nodeId,
    resourceId = reservation.resourceId,
    quantity = 1,
    canonicalUnit = "count",
    reason = "PHYSICAL_UAV_RECOVERY",
    entityId = "ISR_CELL",
  })
  if not credit then
    return nil, reason
  end
  reservation.recovered = true
  return reservation
end

function Adapter:CancelBeforePhysicalStart(requestId)
  local reservation = self.reservationsByRequestId[requireString(requestId, "requestId")]
  if not reservation then
    -- A queued MOOSE mission has no CampaignState reservation by design.
    return { requestId = requestId, cancellationRequired = false }
  end
  if reservation.consumed then
    return nil, "PHYSICAL_START_ALREADY_RECORDED"
  end
  local transaction, reason = self.campaignState:Cancel(reservation.transactionId)
  if not transaction then
    return nil, reason
  end
  self.reservationsByRequestId[requestId] = nil
  return transaction
end

return Adapter
