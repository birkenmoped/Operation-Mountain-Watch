-- Operation Mountain Watch - Phase 1 player UAV ISR request coordinator.
--
-- This module deliberately contains no MOOSE or DCS API call. It is the narrow
-- OMW policy layer approved for marker-to-group ownership and request state.
-- It does not reserve aircraft, spawn units, route aircraft, emit contacts, or
-- manage strategic resources. CampaignState integration starts in a later phase.

local Coordinator = {}
Coordinator.__index = Coordinator

Coordinator.RequestStatus = {
  QUEUED = "QUEUED",
  RESERVED = "RESERVED",
  ASSIGNED = "ASSIGNED",
  LAUNCHING = "LAUNCHING",
  ON_STATION = "ON_STATION",
  RETURNING = "RETURNING",
  COMPLETED = "COMPLETED",
  CANCELLED = "CANCELLED",
}

Coordinator.MarkerText = "UAV RECON"

local TAG = "[OMW][ISR.RequestCoordinator]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requireFiniteNonNegative(value, label)
  if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
    fail(label .. " requires a finite non-negative number")
  end
  return value
end

local function ownerKey(ownerGroupId)
  if ownerGroupId == nil or ownerGroupId == "" then
    fail("ownerGroupId is required")
  end
  return tostring(ownerGroupId)
end

local function markerKey(markerId)
  if markerId == nil or markerId == "" then
    fail("markerId is required")
  end
  return tostring(markerId)
end

local function copyRequest(request)
  if request == nil then
    return nil
  end
  return {
    id = request.id,
    status = request.status,
    ownerGroupId = request.ownerGroupId,
    markerId = request.markerId,
    coordinate = request.coordinate,
    createdAt = request.createdAt,
    cancellationReason = request.cancellationReason,
    platformId = request.platformId,
    transactionId = request.transactionId,
    missionName = request.missionName,
  }
end

local function markerIsValid(self, marker)
  return marker ~= nil
    and marker.coalitionNumber == self.blueCoalitionNumber
    and marker.text == Coordinator.MarkerText
    and marker.coordinate ~= nil
end

local function requestId(self)
  self.nextRequestNumber = self.nextRequestNumber + 1
  return string.format("%s-%04d", self.requestIdPrefix, self.nextRequestNumber)
end

function Coordinator.New(config)
  if type(config) ~= "table" then
    fail("config is required")
  end
  if config.blueCoalitionNumber == nil then
    fail("config.blueCoalitionNumber is required")
  end

  return setmetatable({
    blueCoalitionNumber = config.blueCoalitionNumber,
    submitRadiusMeters = requireFiniteNonNegative(config.submitRadiusMeters or 0, "config.submitRadiusMeters"),
    requestIdPrefix = requireNonEmptyString(config.requestIdPrefix or "ISR", "config.requestIdPrefix"),
    markersById = {},
    requestsById = {},
    openRequestIdByOwner = {},
    nextRequestNumber = 0,
  }, Coordinator)
end

function Coordinator:UpsertMarker(spec)
  if type(spec) ~= "table" then
    fail("marker spec must be a table")
  end

  local id = markerKey(spec.markerId)
  if type(spec.text) ~= "string" then
    fail("marker text must be a string")
  end

  if spec.text ~= Coordinator.MarkerText
      or spec.coalitionNumber ~= self.blueCoalitionNumber
      or spec.coordinate == nil then
    self.markersById[id] = nil
    return
  end

  self.markersById[id] = {
    markerId = id,
    text = spec.text,
    coordinate = spec.coordinate,
    coalitionNumber = spec.coalitionNumber,
  }
end

function Coordinator:ClearMarkersAfterUnidentifiedDelete()
  -- MARKEROPS_BASE passes no marker ID to MarkDeleted in the pinned source.
  -- Clearing the cache is intentionally fail-closed: a player must update a
  -- marker before it can be submitted again, rather than submitting a stale one.
  self.markersById = {}
end

function Coordinator:GetOpenRequestForGroup(ownerGroupId)
  local key = ownerKey(ownerGroupId)
  return copyRequest(self.requestsById[self.openRequestIdByOwner[key]])
end

function Coordinator:SubmitNearest(spec)
  if type(spec) ~= "table" then
    fail("submit spec must be a table")
  end

  local key = ownerKey(spec.ownerGroupId)
  if self.openRequestIdByOwner[key] then
    return nil, "GROUP_ALREADY_HAS_OPEN_REQUEST"
  end
  if type(spec.distanceForMarker) ~= "function" then
    fail("distanceForMarker must be a function")
  end

  local nearest, nearestDistance, tied = nil, nil, false
  for _, marker in pairs(self.markersById) do
    if markerIsValid(self, marker) then
      local distance = spec.distanceForMarker(marker.coordinate, marker.markerId)
      requireFiniteNonNegative(distance, "distanceForMarker result")
      if distance <= self.submitRadiusMeters then
        if nearestDistance == nil or distance < nearestDistance then
          nearest = marker
          nearestDistance = distance
          tied = false
        elseif distance == nearestDistance then
          tied = true
        end
      end
    end
  end

  if nearest == nil then
    return nil, "NO_VALID_MARKER_IN_SUBMIT_RADIUS"
  end
  if tied then
    return nil, "AMBIGUOUS_NEAREST_MARKER"
  end

  local id = requestId(self)
  local request = {
    id = id,
    status = Coordinator.RequestStatus.QUEUED,
    ownerGroupId = key,
    markerId = nearest.markerId,
    coordinate = nearest.coordinate,
    createdAt = spec.createdAt,
    cancellationReason = nil,
    platformId = nil,
    transactionId = nil,
    missionName = nil,
  }
  self.requestsById[id] = request
  self.openRequestIdByOwner[key] = id
  return copyRequest(request), nil
end

function Coordinator:MarkReserved(requestIdValue, platformId, transactionId)
  local request = self.requestsById[requireNonEmptyString(requestIdValue, "requestId")]
  if not request then return nil, "UNKNOWN_REQUEST" end
  if request.status ~= Coordinator.RequestStatus.QUEUED then return nil, "REQUEST_NOT_QUEUED" end
  request.status = Coordinator.RequestStatus.RESERVED
  request.platformId = requireNonEmptyString(platformId, "platformId")
  request.transactionId = requireNonEmptyString(transactionId, "transactionId")
  return copyRequest(request)
end

function Coordinator:MarkAssigned(requestIdValue, missionName)
  local request = self.requestsById[requireNonEmptyString(requestIdValue, "requestId")]
  if not request then return nil, "UNKNOWN_REQUEST" end
  if request.status ~= Coordinator.RequestStatus.RESERVED then return nil, "REQUEST_NOT_RESERVED" end
  request.status = Coordinator.RequestStatus.ASSIGNED
  request.missionName = requireNonEmptyString(missionName, "missionName")
  return copyRequest(request)
end

function Coordinator:MarkLaunching(requestIdValue)
  local request = self.requestsById[requireNonEmptyString(requestIdValue, "requestId")]
  if not request then return nil, "UNKNOWN_REQUEST" end
  if request.status ~= Coordinator.RequestStatus.ASSIGNED then return nil, "REQUEST_NOT_ASSIGNED" end
  request.status = Coordinator.RequestStatus.LAUNCHING
  return copyRequest(request)
end

function Coordinator:MarkOnStation(requestIdValue)
  local request = self.requestsById[requireNonEmptyString(requestIdValue, "requestId")]
  if not request then return nil, "UNKNOWN_REQUEST" end
  if request.status ~= Coordinator.RequestStatus.LAUNCHING then return nil, "REQUEST_NOT_LAUNCHING" end
  request.status = Coordinator.RequestStatus.ON_STATION
  return copyRequest(request)
end

function Coordinator:MarkReturning(requestIdValue)
  local request = self.requestsById[requireNonEmptyString(requestIdValue, "requestId")]
  if not request then return nil, "UNKNOWN_REQUEST" end
  if request.status ~= Coordinator.RequestStatus.LAUNCHING
      and request.status ~= Coordinator.RequestStatus.ON_STATION then
    return nil, "REQUEST_NOT_ACTIVE"
  end
  request.status = Coordinator.RequestStatus.RETURNING
  return copyRequest(request)
end

function Coordinator:MarkCompleted(requestIdValue)
  local request = self.requestsById[requireNonEmptyString(requestIdValue, "requestId")]
  if not request then return nil, "UNKNOWN_REQUEST" end
  if request.status ~= Coordinator.RequestStatus.RETURNING then return nil, "REQUEST_NOT_RETURNING" end
  request.status = Coordinator.RequestStatus.COMPLETED
  self.openRequestIdByOwner[request.ownerGroupId] = nil
  return copyRequest(request)
end

function Coordinator:CancelOwnRequest(ownerGroupId, reason)
  local key = ownerKey(ownerGroupId)
  local id = self.openRequestIdByOwner[key]
  if not id then
    return nil, "NO_OPEN_REQUEST"
  end

  local request = self.requestsById[id]
  if request.ownerGroupId ~= key then
    fail("owner index mismatch requestId=" .. tostring(id))
  end
  if request.status ~= Coordinator.RequestStatus.QUEUED and request.status ~= Coordinator.RequestStatus.RESERVED then
    return nil, "REQUEST_NOT_CANCELLABLE"
  end

  request.status = Coordinator.RequestStatus.CANCELLED
  request.cancellationReason = reason or "OWNER_CANCELLED"
  self.openRequestIdByOwner[key] = nil
  return copyRequest(request), nil
end

function Coordinator:GetRequest(requestIdValue)
  return copyRequest(self.requestsById[requireNonEmptyString(requestIdValue, "requestId")])
end

function Coordinator:GetMarkerCount()
  local count = 0
  for _ in pairs(self.markersById) do
    count = count + 1
  end
  return count
end

return Coordinator
