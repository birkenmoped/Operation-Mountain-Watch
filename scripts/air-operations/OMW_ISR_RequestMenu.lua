-- Operation Mountain Watch - MOOSE bridge for Phase 1 player UAV ISR requests.
--
-- Requires a preloaded OMW_ISR_RequestCoordinator instance. This bridge uses
-- public MOOSE MARKEROPS_BASE, MENU_GROUP, MENU_GROUP_COMMAND and MESSAGE APIs.
-- It deliberately has no DCS native spawn/routing API and no AIRWING dispatch.

local RequestMenu = {}
RequestMenu.__index = RequestMenu

local TAG = "[OMW][ISR.RequestMenu]"
local UAV_MARKER_TEXT = "UAV RECON"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  if env and type(env.info) == "function" then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function requireFunction(value, label)
  if type(value) ~= "function" then
    fail(label .. " must be a function")
  end
  return value
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function messageText(result)
  if result == "GROUP_ALREADY_HAS_OPEN_REQUEST" then
    return "ISR Cell: your group already has an open UAV request."
  elseif result == "NO_VALID_MARKER_IN_SUBMIT_RADIUS" then
    return "ISR Cell: no valid UAV RECON marker is within the submit radius."
  elseif result == "AMBIGUOUS_NEAREST_MARKER" then
    return "ISR Cell: nearest UAV RECON marker is ambiguous."
  elseif result == "NO_OPEN_REQUEST" then
    return "ISR Cell: your group has no open UAV request."
  elseif result == "REQUEST_NOT_CANCELLABLE" then
    return "ISR Cell: your request cannot be cancelled in its current state."
  end
  return "ISR Cell: request rejected (" .. tostring(result) .. ")."
end

local function formatStatus(request)
  if not request then
    return "ISR Cell: your group has no open UAV request."
  end
  return string.format(
    "ISR Cell: %s status=%s marker=%s",
    tostring(request.id),
    tostring(request.status),
    tostring(request.markerId)
  )
end

function RequestMenu.New(config)
  config = requireTable(config, "config")
  if type(config.coordinator) ~= "table"
      or type(config.coordinator.UpsertMarker) ~= "function"
      or type(config.coordinator.ClearMarkersAfterUnidentifiedDelete) ~= "function"
      or type(config.coordinator.SubmitNearest) ~= "function"
      or type(config.coordinator.GetOpenRequestForGroup) ~= "function"
      or type(config.coordinator.GetRequest) ~= "function"
      or type(config.coordinator.CancelOwnRequest) ~= "function" then
    fail("config.coordinator must be an ISR request coordinator")
  end
  if config.blueCoalitionNumber == nil then
    fail("config.blueCoalitionNumber is required")
  end

  local moose = config.moose or _G
  requireTable(moose.MARKEROPS_BASE, "MOOSE MARKEROPS_BASE")
  requireTable(moose.MENU_GROUP, "MOOSE MENU_GROUP")
  requireTable(moose.MENU_GROUP_COMMAND, "MOOSE MENU_GROUP_COMMAND")

  local self = setmetatable({
    coordinator = config.coordinator,
    blueCoalitionNumber = config.blueCoalitionNumber,
    now = config.now or function() return nil end,
    moose = moose,
    menusByGroupId = {},
    groupsById = {},
    sendMessage = config.sendMessage,
    onRequestQueued = config.onRequestQueued,
    onRequestCancellation = config.onRequestCancellation,
  }, RequestMenu)

  if self.sendMessage == nil then
    requireTable(moose.MESSAGE, "MOOSE MESSAGE")
    self.sendMessage = function(group, text)
      moose.MESSAGE:New(text, 15, "ISR Cell", false):ToGroup(group)
    end
  end
  requireFunction(self.sendMessage, "config.sendMessage")
  if self.onRequestQueued ~= nil then requireFunction(self.onRequestQueued, "config.onRequestQueued") end
  if self.onRequestCancellation ~= nil then
    requireFunction(self.onRequestCancellation, "config.onRequestCancellation")
  end

  -- The pinned MARKEROPS_BASE source only calls MarkChanged when the configured
  -- tag matches the *new* text. An empty tag makes every add/change observable;
  -- strict UAV RECON validation remains in the coordinator. This prevents a
  -- former UAV marker from surviving a text change to an unrelated marker.
  --
  -- Do not attach deletion handling to this untagged observer. MARKEROPS_BASE
  -- supplies no deleted marker ID, so every unrelated marker deletion would
  -- otherwise clear the valid UAV marker cache.
  self.markerOps = moose.MARKEROPS_BASE:New("", {})

  function self.markerOps:OnAfterMarkAdded(From, Event, To, Text, Keywords, Coord, MarkerID, CoalitionNumber)
    self.owner:OnMarkerChanged("ADDED", Text, Coord, MarkerID, CoalitionNumber)
  end

  function self.markerOps:OnAfterMarkChanged(From, Event, To, Text, Keywords, Coord, MarkerID, CoalitionNumber)
    self.owner:OnMarkerChanged("CHANGED", Text, Coord, MarkerID, CoalitionNumber)
  end

  self.markerDeletionOps = moose.MARKEROPS_BASE:New(UAV_MARKER_TEXT, {})

  function self.markerDeletionOps:OnAfterMarkDeleted()
    log("UAV_MARKER_DELETED cache=cleared")
    self.owner:OnMarkerDeleted()
  end

  self.markerOps.owner = self
  self.markerDeletionOps.owner = self
  return self
end

function RequestMenu:RegisterBlueClients()
  requireTable(self.moose.SET_CLIENT, "MOOSE SET_CLIENT")

  local clientSet = self.moose.SET_CLIENT:New():FilterCoalitions("blue")

  function clientSet:OnAfterAdded(From, Event, To, ObjectName, client)
    local group = client and client:GetGroup() or nil
    if group and group:GetID() then
      self.owner:RegisterGroup(group)
    end
  end

  self.clientSet = clientSet
  clientSet.owner = self
  clientSet:FilterStart()
  return clientSet
end

function RequestMenu:OnMarkerChanged(eventKind, text, coordinate, markerId, coalitionNumber)
  local accepted = text == UAV_MARKER_TEXT
    and coalitionNumber == self.blueCoalitionNumber
    and coordinate ~= nil
  log("MARKER_" .. tostring(eventKind)
    .. " id=" .. tostring(markerId)
    .. " coalition=" .. tostring(coalitionNumber)
    .. " expectedCoalition=" .. tostring(self.blueCoalitionNumber)
    .. " text=[" .. tostring(text) .. "]"
    .. " accepted=" .. tostring(accepted))
  self.coordinator:UpsertMarker({
    markerId = markerId,
    text = text,
    coordinate = coordinate,
    coalitionNumber = coalitionNumber,
  })
end

function RequestMenu:OnMarkerDeleted()
  -- Pinned MARKEROPS_BASE does not pass the deleted marker ID. Fail closed
  -- instead of allowing stale coordinate submission.
  self.coordinator:ClearMarkersAfterUnidentifiedDelete()
end

function RequestMenu:RegisterGroup(group)
  if type(group) ~= "table" or type(group.GetID) ~= "function" or type(group.GetCoordinate) ~= "function" then
    fail("group must be a MOOSE GROUP with GetID and GetCoordinate")
  end

  local groupId = group:GetID()
  if groupId == nil then
    fail("group GetID returned nil")
  end
  local key = tostring(groupId)
  if self.menusByGroupId[key] then
    return self.menusByGroupId[key]
  end

  local commandMenu = self.moose.MENU_GROUP:New(group, "Command")
  local isrMenu = self.moose.MENU_GROUP:New(group, "ISR Cell", commandMenu)
  local menus = {
    command = commandMenu,
    isr = isrMenu,
  }
  menus.submit = self.moose.MENU_GROUP_COMMAND:New(
    group,
    "Submit nearest UAV marker",
    isrMenu,
    function() self:SubmitFromGroup(group) end
  )
  menus.status = self.moose.MENU_GROUP_COMMAND:New(
    group,
    "Own request status",
    isrMenu,
    function() self:ShowStatusForGroup(group) end
  )
  menus.cancel = self.moose.MENU_GROUP_COMMAND:New(
    group,
    "Cancel own UAV request",
    isrMenu,
    function() self:CancelForGroup(group) end
  )

  self.menusByGroupId[key] = menus
  self.groupsById[key] = group
  return menus
end

function RequestMenu:NotifyGroupId(groupId, text)
  local group = self.groupsById[tostring(groupId)]
  if not group then
    return nil, "GROUP_NOT_REGISTERED"
  end
  self.sendMessage(group, text)
  return true
end

function RequestMenu:SubmitFromGroup(group)
  local groupId = group:GetID()
  local groupCoordinate = group:GetCoordinate()
  if groupCoordinate == nil or type(groupCoordinate.Get2DDistance) ~= "function" then
    fail("group coordinate with Get2DDistance is required")
  end

  local markerCount = self.coordinator:GetMarkerCount()
  log("SUBMIT_ATTEMPT groupId=" .. tostring(groupId)
    .. " validMarkerCache=" .. tostring(markerCount))
  local request, reason = self.coordinator:SubmitNearest({
    ownerGroupId = groupId,
    createdAt = self.now(),
    distanceForMarker = function(markerCoordinate)
      return groupCoordinate:Get2DDistance(markerCoordinate)
    end,
  })
  if request then
    log("SUBMIT_ACCEPTED groupId=" .. tostring(groupId)
      .. " requestId=" .. tostring(request.id)
      .. " markerId=" .. tostring(request.markerId))
    local dispatch, dispatchReason = nil, nil
    if self.onRequestQueued then
      dispatch, dispatchReason = self.onRequestQueued(request)
    end
    if dispatch then
      self.sendMessage(group, string.format(
        "ISR Cell: %s queued in MOOSE AIRWING for %s.",
        tostring(request.id), tostring(dispatch.platformId)
      ))
      return request
    end

    -- A failed AIRWING submission is not a hidden local queue. Remove the
    -- coordinator request so the player can correct or submit again.
    local cancelled = self.coordinator:CancelOwnRequest(groupId, "MOOSE_QUEUE_SUBMISSION_FAILED")
    log("MOOSE_QUEUE_SUBMISSION_FAILED requestId=" .. tostring(request.id)
      .. " reason=" .. tostring(dispatchReason))
    self.sendMessage(group, string.format(
      "ISR Cell: %s was not queued in MOOSE (%s).",
      tostring(request.id), tostring(dispatchReason)
    ))
    return nil, dispatchReason
  end

  self.sendMessage(group, messageText(reason))
  log("SUBMIT_REJECTED groupId=" .. tostring(groupId)
    .. " reason=" .. tostring(reason)
    .. " validMarkerCache=" .. tostring(self.coordinator:GetMarkerCount()))
  return nil, reason
end

function RequestMenu:ShowStatusForGroup(group)
  local request = self.coordinator:GetOpenRequestForGroup(group:GetID())
  self.sendMessage(group, formatStatus(request))
  return request
end

function RequestMenu:CancelForGroup(group)
  local existing = self.coordinator:GetOpenRequestForGroup(group:GetID())
  if not existing then
    self.sendMessage(group, messageText("NO_OPEN_REQUEST"))
    return nil, "NO_OPEN_REQUEST"
  end


  if self.onRequestCancellation then
    local outcome, reason = self.onRequestCancellation(group, existing)
    if outcome == "CANCELLED" then
      self.sendMessage(group, string.format("ISR Cell: %s cancelled before launch.", tostring(existing.id)))
      return existing, nil
    elseif outcome == "RECALL_ORDERED" then
      self.sendMessage(group, string.format("ISR Cell: %s recall ordered; returning to base.", tostring(existing.id)))
      return existing, nil
    elseif outcome == "RECALL_ALREADY_ORDERED" then
      self.sendMessage(group, string.format("ISR Cell: %s is already returning to base.", tostring(existing.id)))
      return existing, nil
    end
    self.sendMessage(group, messageText(reason or outcome))
    return nil, reason or outcome
  end

  local request, reason = self.coordinator:CancelOwnRequest(group:GetID())
  if request then
    self.sendMessage(group, string.format("ISR Cell: %s cancelled.", tostring(request.id)))
    return request
  end

  self.sendMessage(group, messageText(reason))
  return nil, reason
end

return RequestMenu
