local RequestMenu = dofile("scripts/air-operations/OMW_ISR_RequestMenu.lua")

env = { info = function() end }

local messages = {}
local retryCallback = nil
local scheduler = {
  Stop = function(self, scheduleId) self.stopped = scheduleId end,
}

local request = {
  id = "ISR-0042",
  status = "QUEUED",
  ownerGroupId = "77",
  markerId = "42",
  coordinate = { marker = true },
}

local coordinator = {
  UpsertMarker = function() end,
  ClearMarkersAfterUnidentifiedDelete = function() end,
  SubmitNearest = function()
    return request
  end,
  GetOpenRequestForGroup = function(_, groupId)
    return tostring(groupId) == request.ownerGroupId and request or nil
  end,
  GetRequest = function(_, requestId)
    return requestId == request.id and request or nil
  end,
  CancelOwnRequest = function(_, groupId)
    assert(tostring(groupId) == request.ownerGroupId)
    assert(request.status == "QUEUED")
    request.status = "CANCELLED"
    return request
  end,
  GetMarkerCount = function() return 1 end,
}

local moose = {
  MARKEROPS_BASE = {},
  MENU_GROUP = {},
  MENU_GROUP_COMMAND = {},
  SCHEDULER = {
    New = function(_, _, callback, arguments, start, repeatInterval)
      retryCallback = callback
      assert(arguments[1] == "ISR-0042")
      assert(start == 30)
      assert(repeatInterval == 30)
      return scheduler, "RETRY-SCHEDULE"
    end,
  },
}

local attempts = 0
local menu = RequestMenu.New({
  coordinator = coordinator,
  blueCoalitionNumber = 2,
  moose = moose,
  sendMessage = function(_, text) messages[#messages + 1] = text end,
  onRequestQueued = function(dispatchedRequest)
    assert(dispatchedRequest.id == "ISR-0042")
    attempts = attempts + 1
    if attempts == 1 then
      return nil, "NO_AVAILABLE_ISR_ASSET"
    end
    request.status = "ASSIGNED"
    return { platformId = "MQ-9" }
  end,
})

local group = {
  GetID = function() return 77 end,
  GetCoordinate = function()
    return { Get2DDistance = function() return 1000 end }
  end,
}
menu.groupsById["77"] = group

assert(menu:SubmitFromGroup(group).id == "ISR-0042")
assert(attempts == 1)
assert(menu.pendingDispatchByRequestId["ISR-0042"] ~= nil)
assert(messages[#messages]:find("waiting for a strategic MQ%-9") ~= nil)

retryCallback("ISR-0042")
assert(attempts == 2)
assert(menu.pendingDispatchByRequestId["ISR-0042"] == nil)
assert(scheduler.stopped == "RETRY-SCHEDULE")
assert(messages[#messages]:find("accepted for MQ%-9") ~= nil)

request.status = "QUEUED"
attempts = 0
scheduler.stopped = nil
assert(menu:SubmitFromGroup(group).id == "ISR-0042")
assert(menu.pendingDispatchByRequestId["ISR-0042"] ~= nil)
assert(menu:CancelForGroup(group).id == "ISR-0042")
assert(request.status == "CANCELLED")
assert(menu.pendingDispatchByRequestId["ISR-0042"] == nil)
assert(scheduler.stopped == "RETRY-SCHEDULE")

print("PASS test_isr_request_menu")
