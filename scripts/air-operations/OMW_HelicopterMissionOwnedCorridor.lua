-- Operation Mountain Watch - lifecycle-safe MOOSE AUFTRAG FlightPath adapter.
--
-- Purpose:
--   * Keep native AUFTRAG ingress/egress as the mission lifecycle anchors.
--   * Add owner-authored PATHLINE geometry as AUFTRAG-owned FLIGHTGROUP waypoints.
--   * Mark every injected waypoint with missionUID so MOOSE removes it on PauseMission.
--   * Re-install the corridor after MOOSE rebuilds the mission route on Unpause/MissionStart.
--
-- This is intentionally a small adapter around MOOSE route ownership. It does not
-- replace AUFTRAG, FLIGHTGROUP, EngageDetected, mission pause/resume or RTB logic.

local Adapter = {}

local TAG = "[OMW][HelicopterMissionOwnedCorridor]"
Adapter.SchemaVersion = "OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-1"

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

  if type(resolved.outbound) ~= "table" or #resolved.outbound < 1 then
    fail("resolved.outbound requires at least one coordinate")
  end
  if type(resolved.returnRoute) ~= "table" or #resolved.returnRoute < 1 then
    fail("resolved.returnRoute requires at least one coordinate")
  end

  local defaultAltitudeFtAgl = spec.defaultAltitudeFtAgl or 500
  local ingressCoordinate = resolved.outbound[#resolved.outbound]
  local egressCoordinate = resolved.returnRoute[#resolved.returnRoute]
  local ingressSegment = resolved.outboundSegmentIndexes and resolved.outboundSegmentIndexes[#resolved.outbound] or 1
  local egressSegment = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[#resolved.returnRoute] or 1
  local ingressProfile = profileFor(resolved, ingressSegment, defaultAltitudeFtAgl)
  local egressProfile = profileFor(resolved, egressSegment, defaultAltitudeFtAgl)
  local ingressAltitudeFtAsl = spec.ingressAltitudeFtAsl or aslFeetForAgl(ingressCoordinate, ingressProfile.altitudeFtAgl)
  local egressAltitudeFtAsl = spec.egressAltitudeFtAsl or aslFeetForAgl(egressCoordinate, egressProfile.altitudeFtAgl)

  mission:SetMissionIngressCoord(ingressCoordinate, ingressAltitudeFtAsl, spec.speedKts)
  mission:SetMissionEgressCoord(egressCoordinate, egressAltitudeFtAsl, spec.speedKts)

  return {
    mode = "MOOSE_NATIVE_INGRESS_EGRESS_PLUS_MISSION_OWNED_PATHLINE",
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

local function waypointStillPresent(flightGroup, uid)
  if type(uid) ~= "number" then return false end
  return flightGroup:GetWaypointIndex(uid) ~= nil
end

local function allInstalledWaypointsPresent(flightGroup, binding)
  local uids = binding.installedUids or {}
  if #uids == 0 then return false end
  for _, uid in ipairs(uids) do
    if not waypointStillPresent(flightGroup, uid) then return false end
  end
  return true
end

local function anyInstalledWaypointPresent(flightGroup, binding)
  for _, uid in ipairs(binding.installedUids or {}) do
    if waypointStillPresent(flightGroup, uid) then return true end
  end
  return false
end

local function installNow(flightGroup, binding)
  if binding.installing then return nil, false, "INSTALL_IN_PROGRESS" end
  if allInstalledWaypointsPresent(flightGroup, binding) then
    return binding.lastResult, true, "ALREADY_INSTALLED"
  end
  if anyInstalledWaypointPresent(flightGroup, binding) then
    return nil, false, "PARTIAL_MISSION_OWNED_ROUTE_PRESENT"
  end

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

  local preMissionUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 1)
  if type(preMissionUid) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  binding.installing = true
  binding.installedUids = {}
  local outboundProfiles, returnProfiles = {}, {}
  local defaultAltitudeFtAgl = binding.defaultAltitudeFtAgl

  local afterUid = preMissionUid
  for index, coordinate in ipairs(resolved.outbound) do
    local segmentIndex = resolved.outboundSegmentIndexes and resolved.outboundSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
    waypoint.missionUID = mission.auftragsnummer
    binding.installedUids[#binding.installedUids + 1] = waypoint.uid
    outboundProfiles[#outboundProfiles + 1] = {
      uid = waypoint.uid,
      segmentIndex = segmentIndex,
      pathlineName = pathlineFor(resolved, segmentIndex),
      altitudeFtAgl = profile.altitudeFtAgl,
      altType = "RADIO",
    }
    afterUid = waypoint.uid
  end

  afterUid = missionUid
  local returnCount = math.max(#resolved.returnRoute - 1, 0)
  for index = 1, returnCount do
    local coordinate = resolved.returnRoute[index]
    local segmentIndex = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
    local updateRoute = index == returnCount
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, updateRoute)
    waypoint.missionUID = mission.auftragsnummer
    binding.installedUids[#binding.installedUids + 1] = waypoint.uid
    returnProfiles[#returnProfiles + 1] = {
      uid = waypoint.uid,
      segmentIndex = segmentIndex,
      pathlineName = pathlineFor(resolved, segmentIndex),
      altitudeFtAgl = profile.altitudeFtAgl,
      altType = "RADIO",
    }
    afterUid = waypoint.uid
  end

  if returnCount == 0 and #outboundProfiles > 0 then
    requireFunction(flightGroup, "UpdateRoute", "FLIGHTGROUP")
    flightGroup:UpdateRoute()
  end

  binding.installing = false
  binding.installCount = (binding.installCount or 0) + 1
  binding.lastResult = {
    missionUid = missionUid,
    egressUid = egressUid,
    installCount = binding.installCount,
    outboundWaypointCount = #outboundProfiles,
    returnWaypointCount = #returnProfiles,
    waypointProfiles = {
      outbound = outboundProfiles,
      returnRoute = returnProfiles,
    },
    pathlineNames = resolved.pathlineNames,
    segmentOffsets = resolved.segmentOffsets,
    offsetMode = resolved.offsetMode,
  }

  if type(binding.onInstalled) == "function" then
    binding.onInstalled(binding.lastResult)
  end

  return binding.lastResult, true, nil
end

local function installUpdateRouteHook(flightGroup)
  if flightGroup.__omwMissionOwnedCorridorHook then return end
  flightGroup.__omwMissionOwnedCorridorHook = true
  local previous = flightGroup.OnAfterUpdateRoute
  function flightGroup:OnAfterUpdateRoute(From, Event, To, n, N)
    if previous then previous(self, From, Event, To, n, N) end
    local binding = self.__omwMissionOwnedCorridorBinding
    if not binding or binding.installing then return end
    local _, ok, reason = installNow(self, binding)
    if not ok and reason ~= "MISSION_ROUTE_UIDS_NOT_READY" and reason ~= "INSTALL_IN_PROGRESS" then
      binding.lastReason = reason
      if type(binding.onFailed) == "function" then binding.onFailed(reason) end
    end
  end
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

  local binding = {
    mission = mission,
    resolved = resolved,
    defaultAltitudeFtAgl = spec.defaultAltitudeFtAgl or 500,
    onInstalled = spec.onInstalled,
    onFailed = spec.onFailed,
    installedUids = {},
    installCount = 0,
    installing = false,
    lastResult = nil,
    lastReason = nil,
  }
  flightGroup.__omwMissionOwnedCorridorBinding = binding
  installUpdateRouteHook(flightGroup)

  local result, ok, reason = installNow(flightGroup, binding)
  if not ok and reason ~= "MISSION_ROUTE_UIDS_NOT_READY" then
    binding.lastReason = reason
    if type(binding.onFailed) == "function" then binding.onFailed(reason) end
  end
  return result, ok, reason
end

return Adapter
