local Coordinator = dofile("scripts/campaign/OMW_ISR_RequestCoordinator.lua")
local RequestMenu = dofile("scripts/air-operations/OMW_ISR_RequestMenu.lua")

local function fail(message)
  error("UAV_ISR_REQUEST_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local function expectTrue(value, label)
  if value ~= true then
    fail(label .. " expected=true actual=" .. tostring(value))
  end
end

local function expectNil(value, label)
  if value ~= nil then
    fail(label .. " expected=nil actual=" .. tostring(value))
  end
end

local function coordinate(x, z)
  return {
    x = x,
    z = z,
    Get2DDistance = function(self, other)
      local dx, dz = self.x - other.x, self.z - other.z
      return math.sqrt(dx * dx + dz * dz)
    end,
  }
end

local function newCoordinator()
  return Coordinator.New({
    blueCoalitionNumber = 2,
    submitRadiusMeters = 5000,
    requestIdPrefix = "ISR",
  })
end

do
  local coordinator = newCoordinator()
  coordinator:UpsertMarker({
    markerId = 11,
    text = "UAV RECON",
    coordinate = coordinate(1000, 0),
    coalitionNumber = 2,
  })
  local request, reason = coordinator:SubmitNearest({
    ownerGroupId = 101,
    createdAt = 100,
    distanceForMarker = function(markerCoordinate)
      return coordinate(0, 0):Get2DDistance(markerCoordinate)
    end,
  })
  expectEqual(reason, nil, "FIRST_SUBMIT_REASON")
  expectEqual(request.id, "ISR-0001", "FIRST_REQUEST_ID")
  expectEqual(request.status, Coordinator.RequestStatus.QUEUED, "FIRST_REQUEST_STATUS")
  expectEqual(request.ownerGroupId, "101", "FIRST_REQUEST_OWNER")
  expectEqual(request.markerId, "11", "FIRST_REQUEST_MARKER")
  expectEqual(coordinator:GetOpenRequestForGroup(101).id, request.id, "OWN_STATUS")

  local second, secondReason = coordinator:SubmitNearest({
    ownerGroupId = 101,
    distanceForMarker = function() return 0 end,
  })
  expectNil(second, "SECOND_REQUEST")
  expectEqual(secondReason, "GROUP_ALREADY_HAS_OPEN_REQUEST", "SECOND_REASON")

  local other, otherReason = coordinator:SubmitNearest({
    ownerGroupId = 202,
    distanceForMarker = function(markerCoordinate)
      return coordinate(0, 0):Get2DDistance(markerCoordinate)
    end,
  })
  expectEqual(otherReason, nil, "OTHER_GROUP_REASON")
  expectEqual(other.id, "ISR-0002", "OTHER_GROUP_ID")

  local cancelled, cancelReason = coordinator:CancelOwnRequest(101)
  expectEqual(cancelReason, nil, "CANCEL_REASON")
  expectEqual(cancelled.status, Coordinator.RequestStatus.CANCELLED, "CANCEL_STATUS")
  expectNil(coordinator:GetOpenRequestForGroup(101), "STATUS_AFTER_CANCEL")
  expectEqual(coordinator:GetOpenRequestForGroup(202).id, other.id, "FOREIGN_REQUEST_UNCHANGED")
end

do
  local coordinator = newCoordinator()
  coordinator:UpsertMarker({
    markerId = 21,
    text = "UAV RECON",
    coordinate = coordinate(1000, 0),
    coalitionNumber = 1,
  })
  coordinator:UpsertMarker({
    markerId = 22,
    text = "UAV OTHER",
    coordinate = coordinate(500, 0),
    coalitionNumber = 2,
  })
  local request, reason = coordinator:SubmitNearest({
    ownerGroupId = "BLUE-1",
    distanceForMarker = function(markerCoordinate)
      return coordinate(0, 0):Get2DDistance(markerCoordinate)
    end,
  })
  expectNil(request, "INVALID_MARKERS_REQUEST")
  expectEqual(reason, "NO_VALID_MARKER_IN_SUBMIT_RADIUS", "INVALID_MARKERS_REASON")

  coordinator:UpsertMarker({
    markerId = 23,
    text = "UAV RECON",
    coordinate = coordinate(8000, 0),
    coalitionNumber = 2,
  })
  request, reason = coordinator:SubmitNearest({
    ownerGroupId = "BLUE-1",
    distanceForMarker = function(markerCoordinate)
      return coordinate(0, 0):Get2DDistance(markerCoordinate)
    end,
  })
  expectNil(request, "OUT_OF_RANGE_REQUEST")
  expectEqual(reason, "NO_VALID_MARKER_IN_SUBMIT_RADIUS", "OUT_OF_RANGE_REASON")

  coordinator:UpsertMarker({
    markerId = 23,
    text = "NOT A REQUEST",
    coordinate = coordinate(8000, 0),
    coalitionNumber = 2,
  })
  expectEqual(coordinator:GetMarkerCount(), 0, "TEXT_CHANGE_REMOVES_MARKER")
end

do
  local coordinator = newCoordinator()
  coordinator:UpsertMarker({ markerId = 31, text = "UAV RECON", coordinate = coordinate(1000, 0), coalitionNumber = 2 })
  coordinator:UpsertMarker({ markerId = 32, text = "UAV RECON", coordinate = coordinate(-1000, 0), coalitionNumber = 2 })
  local request, reason = coordinator:SubmitNearest({
    ownerGroupId = 301,
    distanceForMarker = function(markerCoordinate)
      return coordinate(0, 0):Get2DDistance(markerCoordinate)
    end,
  })
  expectNil(request, "TIE_REQUEST")
  expectEqual(reason, "AMBIGUOUS_NEAREST_MARKER", "TIE_REASON")

  coordinator:ClearMarkersAfterUnidentifiedDelete()
  expectEqual(coordinator:GetMarkerCount(), 0, "FAIL_CLOSED_DELETE_CLEAR")
end

do
  local commands, messages = {}, {}
  local fakeMoose = {
    MARKEROPS_BASE = {
      New = function()
        return {}
      end,
    },
    MENU_GROUP = {
      New = function(_, group, text, parent)
        return { group = group, text = text, parent = parent }
      end,
    },
    MENU_GROUP_COMMAND = {
      New = function(_, group, text, parent, callback)
        local command = { group = group, text = text, parent = parent, callback = callback }
        commands[text] = command
        return command
      end,
    },
  }

  local coordinator = newCoordinator()
  local runtime = RequestMenu.New({
    coordinator = coordinator,
    blueCoalitionNumber = 2,
    moose = fakeMoose,
    now = function() return 77 end,
    sendMessage = function(group, text)
      messages[#messages + 1] = { group = group, text = text }
    end,
  })
  local group = {
    GetID = function() return 401 end,
    GetCoordinate = function() return coordinate(0, 0) end,
  }

  runtime:RegisterGroup(group)
  runtime.markerOps:OnAfterMarkChanged(nil, nil, nil, "UAV RECON", nil, coordinate(1200, 0), 41, 2)
  commands["Submit nearest UAV marker"].callback()
  expectTrue(messages[#messages].text:find("ISR%-0001 queued") ~= nil, "MENU_SUBMIT_MESSAGE")
  commands["Own request status"].callback()
  expectTrue(messages[#messages].text:find("status=QUEUED") ~= nil, "MENU_STATUS_MESSAGE")
  commands["Cancel own queued request"].callback()
  expectTrue(messages[#messages].text:find("cancelled") ~= nil, "MENU_CANCEL_MESSAGE")

  runtime.markerOps:OnAfterMarkChanged(nil, nil, nil, "UAV RECON", nil, coordinate(1200, 0), 42, 2)
  runtime.markerOps:OnAfterMarkDeleted()
  commands["Submit nearest UAV marker"].callback()
  expectTrue(messages[#messages].text:find("no valid UAV RECON marker") ~= nil, "DELETE_FAIL_CLOSED_MESSAGE")
end

print("PASS UAV ISR request coordinator and MOOSE menu contract")
