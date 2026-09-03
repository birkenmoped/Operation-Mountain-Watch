-- Operation Mountain Watch - one-shot MOOSE AUFTRAG route/task-chain adapter.
--
-- Purpose:
--   * Keep native AUFTRAG ingress/egress and the AUFTRAG mission waypoint/task.
--   * Use the native ingress as the first owner-authored corridor point.
--   * Insert the remaining outbound PATHLINE coordinates once before the mission waypoint.
--   * Insert the complete return PATHLINE coordinates once after the mission waypoint.
--   * Keep recovery waypoints outside mission ownership so AUFTRAG completion/cancel does
--     not remove the WEST/R500 return chain.
--   * Perform no persistent OnAfterUpdateRoute interception or route re-installation.
--
-- This remains a small adapter around public MOOSE AUFTRAG/FLIGHTGROUP route APIs.

local Adapter = {}

local TAG = "[OMW][HelicopterMissionOwnedCorridor]"
Adapter.SchemaVersion = "OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-5"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function profileFor(resolved, segmentIndex, fallbackAltitudeFtAgl)
  local profile = resolved.segmentProfiles and resolved.segmentProfiles[segmentIndex] or nil
  return {
    altitudeFtAgl = profile and profile.altitudeFtAgl or fallbackAltitudeFtAgl,
    formation = profile and profile.formation or nil,
  }
end

local function pathlineFor(resolved, segmentIndex)
  return resolved.pathlineNames and resolved.pathlineNames[segmentIndex] or resolved.pathlineName
end

local function aslFeetForAgl(coordinate, altitudeFtAgl)
  requireTable(coordinate, "coordinate")
  requireFunction(coordinate, "GetLandHeight", "COORDINATE")
  if type(UTILS) ~= "table" or type(UTILS.MetersToFeet) ~= "function" then
    fail("MOOSE UTILS.MetersToFeet() is required")
  end
  return UTILS.MetersToFeet(coordinate:GetLandHeight()) + altitudeFtAgl
end

function Adapter.ConfigureMission(mission, resolved, spec)
  requireTable(mission, "mission")
  requireTable(resolved, "resolved")
  spec = spec or {}
  requireFunction(mission, "SetMissionIngressCoord", "AUFTRAG")
  requireFunction(mission, "SetMissionEgressCoord", "AUFTRAG")

  if type(resolved.outbound) ~= "table" or #resolved.outbound < 2 then
    fail("resolved.outbound requires at least two coordinates")
  end
  if type(resolved.returnRoute) ~= "table" or #resolved.returnRoute < 2 then
    fail("resolved.returnRoute requires at least two coordinates")
  end

  local ingressCoordinate = resolved.outbound[1]
  local egressCoordinate = resolved.returnRoute[#resolved.returnRoute]
  local ingressSegment = resolved.outboundSegmentIndexes and resolved.outboundSegmentIndexes[1] or 1
  local egressSegment = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[#resolved.returnRoute] or 1
  local ingressProfile = profileFor(resolved, ingressSegment, spec.defaultAltitudeFtAgl or 500)
  local egressProfile = profileFor(resolved, egressSegment, spec.defaultAltitudeFtAgl or 500)
  local ingressAltitudeFtAsl = spec.ingressAltitudeFtAsl or aslFeetForAgl(ingressCoordinate, ingressProfile.altitudeFtAgl)
  local egressAltitudeFtAsl = spec.egressAltitudeFtAsl or aslFeetForAgl(egressCoordinate, egressProfile.altitudeFtAgl)

  mission:SetMissionIngressCoord(ingressCoordinate, ingressAltitudeFtAsl, spec.speedKts)
  mission:SetMissionEgressCoord(egressCoordinate, egressAltitudeFtAsl, spec.speedKts)

  return {
    mode = "MOOSE_ONE_SHOT_ROUTE_TASK_CHAIN",
    ingressCoordinate = ingressCoordinate,
    egressCoordinate = egressCoordinate,
    ingressAltitudeFtAsl = ingressAltitudeFtAsl,
    egressAltitudeFtAsl = egressAltitudeFtAsl,
    ingressPathlineName = pathlineFor(resolved, ingressSegment),
    egressPathlineName = pathlineFor(resolved, egressSegment),
    offsetMode = resolved.offsetMode,
    segmentOffsets = resolved.segmentOffsets,
  }
end

local function installOnce(flightGroup, binding)
  if binding.installed then return binding.lastResult, true, "ALREADY_INSTALLED" end
  if binding.installing then return nil, false, "INSTALL_IN_PROGRESS" end

  local mission = binding.mission
  local resolved = binding.resolved
  local missionUid = mission:GetGroupWaypointIndex(flightGroup)
  local egressUid = mission:GetGroupEgressWaypointUID(flightGroup)
  if type(missionUid) ~= "number" or type(egressUid) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  local missionIndex = flightGroup:GetWaypointIndex(missionUid)
  local egressIndex = flightGroup:GetWaypointIndex(egressUid)
  if type(missionIndex) ~= "number" or missionIndex <= 1 or type(egressIndex) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  local ingressUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 1)
  if type(ingressUid) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  binding.installing = true
  local outboundProfiles, returnProfiles = {}, {}
  local outboundUids, returnUids = {}, {}
  local defaultAltitudeFtAgl = binding.defaultAltitudeFtAgl

  local afterUid = ingressUid
  for index = 2, #resolved.outbound do
    local coordinate = resolved.outbound[index]
    local segmentIndex = resolved.outboundSegmentIndexes and resolved.outboundSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
    waypoint.missionUID = mission.auftragsnummer
    outboundUids[#outboundUids + 1] = waypoint.uid
    outboundProfiles[#outboundProfiles + 1] = {
      uid = waypoint.uid,
      sourceIndex = index,
      segmentIndex = segmentIndex,
      pathlineName = pathlineFor(resolved, segmentIndex),
      altitudeFtAgl = profile.altitudeFtAgl,
      altType = "RADIO",
    }
    afterUid = waypoint.uid
  end

  afterUid = missionUid
  for index = 1, #resolved.returnRoute do
    local coordinate = resolved.returnRoute[index]
    local segmentIndex = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
    returnUids[#returnUids + 1] = waypoint.uid
    returnProfiles[#returnProfiles + 1] = {
      uid = waypoint.uid,
      sourceIndex = index,
      segmentIndex = segmentIndex,
      pathlineName = pathlineFor(resolved, segmentIndex),
      altitudeFtAgl = profile.altitudeFtAgl,
      altType = "RADIO",
    }
    afterUid = waypoint.uid
  end

  flightGroup:UpdateRoute()

  binding.installing = false
  binding.installed = true
  binding.outboundUids = outboundUids
  binding.returnUids = returnUids
  binding.lastResult = {
    mode = "MOOSE_ONE_SHOT_ROUTE_TASK_CHAIN",
    missionUid = missionUid,
    ingressUid = ingressUid,
    egressUid = egressUid,
    outboundWaypointCount = #outboundProfiles,
    returnWaypointCount = #returnProfiles,
    waypointProfiles = {
      outbound = outboundProfiles,
      returnRoute = returnProfiles,
    },
    pathlineNames = resolved.pathlineNames,
    segmentOffsets = resolved.segmentOffsets,
    offsetMode = resolved.offsetMode,
    recoveryWaypointsMissionOwned = false,
    persistentUpdateRouteHook = false,
  }

  if type(binding.onInstalled) == "function" then binding.onInstalled(binding.lastResult) end
  return binding.lastResult, true, nil
end

local function stopRetry(binding)
  if binding.retryScheduler and type(binding.retryScheduler.Stop) == "function" then
    binding.retryScheduler:Stop()
  end
  binding.retryScheduler = nil
end

local function scheduleBoundedRetry(flightGroup, binding)
  if binding.retryScheduler or binding.installed then return end
  binding.retryScheduler = SCHEDULER:New(nil, function()
    if binding.installed then stopRetry(binding); return end
    binding.attempts = binding.attempts + 1
    local result, ok, reason = installOnce(flightGroup, binding)
    if ok then stopRetry(binding); return result end
    if reason == "MISSION_ROUTE_UIDS_NOT_READY" and binding.attempts < binding.maxAttempts then return end
    stopRetry(binding)
    binding.lastReason = reason
    if type(binding.onFailed) == "function" then binding.onFailed(reason) end
  end, {}, 1, 1)
end

function Adapter.Bind(flightGroup, mission, resolved, spec)
  requireTable(flightGroup, "flightGroup")
  requireTable(mission, "mission")
  requireTable(resolved, "resolved")
  spec = spec or {}
  requireFunction(mission, "GetGroupWaypointIndex", "AUFTRAG")
  requireFunction(mission, "GetGroupEgressWaypointUID", "AUFTRAG")
  requireFunction(flightGroup, "GetWaypointIndex", "FLIGHTGROUP")
  requireFunction(flightGroup, "GetWaypointUIDFromIndex", "FLIGHTGROUP")
  requireFunction(flightGroup, "AddWaypoint", "FLIGHTGROUP")
  requireFunction(flightGroup, "UpdateRoute", "FLIGHTGROUP")

  local binding = {
    mission = mission,
    resolved = resolved,
    defaultAltitudeFtAgl = spec.defaultAltitudeFtAgl or 500,
    onInstalled = spec.onInstalled,
    onFailed = spec.onFailed,
    attempts = 1,
    maxAttempts = spec.maxAttempts or 8,
    installed = false,
    installing = false,
    retryScheduler = nil,
    lastResult = nil,
    lastReason = nil,
  }
  flightGroup.__omwMissionOwnedCorridorBinding = binding

  local result, ok, reason = installOnce(flightGroup, binding)
  if ok then return result, true, nil end
  if reason == "MISSION_ROUTE_UIDS_NOT_READY" then
    scheduleBoundedRetry(flightGroup, binding)
    return nil, false, reason
  end
  binding.lastReason = reason
  if type(binding.onFailed) == "function" then binding.onFailed(reason) end
  return nil, false, reason
end

return Adapter
