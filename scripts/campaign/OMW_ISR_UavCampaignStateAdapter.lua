-- Operation Mountain Watch - CampaignState adapter for player ISR UAV reservations.
--
-- CampaignState remains the only strategic source of availability. This adapter
-- never creates an aircraft and never contains a second stock ledger.

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
      or type(config.campaignState.Consume) ~= "function" then
    fail("campaignState lacks reservation operations")
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
    return nil, "REQUEST_ALREADY_RESERVED"
  end

  local transactionId = "ISR-UAV-RESERVE:" .. requestId
  local transaction, reason = self.campaignState:ReserveResource({
    transactionId = transactionId,
    reservationId = transactionId,
    cargoId = transactionId,
    missionDemandId = requestId,
    carrierEntityId = "ISR_CELL",
    resourceId = requireString(profile.resourceId, "profile.resourceId"),
    quantity = 1,
    canonicalUnit = "count",
    originNodeId = self.nodeId,
    destinationNodeId = self.nodeId,
  })
  if not transaction then
    return nil, reason
  end

  local reservation = {
    requestId = requestId,
    transactionId = transactionId,
    resourceId = profile.resourceId,
    platformId = profile.platformId,
    consumed = false,
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
  local transaction, reason = self.campaignState:Consume(reservation.transactionId)
  if not transaction then
    return nil, reason
  end
  reservation.consumed = true
  return reservation
end

function Adapter:CancelBeforePhysicalStart(requestId)
  local reservation = self.reservationsByRequestId[requireString(requestId, "requestId")]
  if not reservation then
    return nil, "NO_RESERVATION"
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
