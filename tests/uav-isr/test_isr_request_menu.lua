local RequestMenu = dofile("scripts/air-operations/OMW_ISR_RequestMenu.lua")
env = { info = function() end }

local messages = {}
local request = {
  id = "ISR-0042", status = "QUEUED", ownerGroupId = "77",
  markerId = "42", coordinate = { marker = true },
}
local coordinator = {
  UpsertMarker = function() end,
  ClearMarkersAfterUnidentifiedDelete = function() end,
  SubmitNearest = function() return request end,
  GetOpenRequestForGroup = function(_, groupId)
    return tostring(groupId) == "77" and request or nil
  end,
  GetRequest = function(_, requestId) return requestId == request.id and request or nil end,
  CancelOwnRequest = function(_, groupId)
    assert(tostring(groupId) == "77")
    request.status = "CANCELLED"
    return request
  end,
  GetMarkerCount = function() return 1 end,
}
local moose = { MARKEROPS_BASE = {}, MENU_GROUP = {}, MENU_GROUP_COMMAND = {} }
local calls = 0
local menu = RequestMenu.New({
  coordinator = coordinator, blueCoalitionNumber = 2, moose = moose,
  sendMessage = function(_, text) messages[#messages + 1] = text end,
  onRequestQueued = function(dispatched)
    calls = calls + 1
    assert(dispatched.id == "ISR-0042")
    request.status = "ASSIGNED"
    return { platformId = "MQ-9", mission = { name = "ISR ISR-0042 MQ-9" } }
  end,
  onRequestCancellation = function(_, dispatched)
    assert(dispatched.id == "ISR-0042")
    request.status = "CANCELLED"
    return "CANCELLED"
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
assert(calls == 1, "menu must submit once to MOOSE, never own a retry queue")
assert(menu.pendingDispatchByRequestId == nil)
assert(menu:CancelForGroup(group).id == "ISR-0042")
assert(request.status == "CANCELLED")
print("PASS test_isr_request_menu")
