-- Operation Mountain Watch - lifecycle-safe MOOSE AUFTRAG FlightPath adapter.
--
-- Purpose:
--   * Keep native AUFTRAG ingress/egress as the mission lifecycle anchors.
--   * Make native ingress the FIRST owner-authored corridor point so aircraft enter the
--     corridor before the actual AUFTRAG objective instead of flying directly to the AO.
--   * Add the remaining outbound PATHLINE geometry as AUFTRAG-owned FLIGHTGROUP waypoints.
--   * Add the complete return PATHLINE geometry as recovery waypoints NOT owned by the
--     AUFTRAG so AUFTRAG:Cancel() cannot remove the required WEST/R500 return corridor.
--   * Re-install the outbound corridor only while the AUFTRAG is still active and only
--     if MOOSE actually rebuilds/removes the mission route.
--
-- This is intentionally a small adapter around public MOOSE route ownership. It does
-- not replace AUFTRAG, FLIGHTGROUP, EngageDetected, mission pause/resume or RTB logic.

local Adapter = {}

local TAG = "[OMW][HelicopterMissionOwnedCorridor]"
Adapter.SchemaVersion = "OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-4"

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

  -- MOOSE RouteToMission() places the native ingress before the mission waypoint.
  -- Therefore ingress must be the corridor ENTRY nearest the origin, not the final
  -- corridor point near the AO.
  local ingressCoordinate = resolved.outbound[1]

  -- The native egress remains a MOOSE mission anchor while the mission is active.
  -- The complete recovery path is separately installed as non-mission-owned waypoints,
  -- including its final Jalalabad-side corridor point. This is required because MOOSE
  -- removes missionUID waypoints when AUFTRAG:Cancel() completes the CAS mission.
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
    mode = "MOOSE_NATIVE_CORRIDOR_ENTRY_PLUS_PERSISTENT_RECOVERY_ROUTE",
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

local function allOutboundWaypointsPresent(flightGroup, binding)
  local uids = binding.outboundUids or {}
  if #uids == 0 then return false end
  for _, uid in ipairs(uids) do
    if not waypointStillPresent(flightGroup, uid) then return false end
  end
  return true
end

local function anyOutboundWaypointPresent(flightGroup, binding)
  for _, uid in ipairs(binding.outboundUids or {}) do
    if waypointStillPresent(flightGroup, uid) then return true end
  end
  return false
end

local function missionIsOver(mission)
  return type(mission.IsOver) == "function" and mission:IsOver() == true
end

local function installNow(flightGroup, binding)
  if binding.installing then return nil, false, "INSTALL_IN_PROGRESS" end
  if missionIsOver(binding.mission) then
    binding.closed = true
    return binding.lastResult, true, "MISSION_OVER_RECOVERY_ROUTE_PRESERVED"
  end
  if allOutboundWaypointsPresent(flightGroup, binding) and binding.returnInstalled then
    return binding.lastResult, true, "ALREADY_INSTALLED"
  end
  if anyOutboundWaypointPresent(flightGroup, binding) then
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

  local ingressUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 1)
  if type(ingressUid) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  binding.installing = true
  binding.outboundUids = {}
  binding.returnUids = binding.returnUids or {}
  local outboundProfiles, returnProfiles = {}, {}
  local defaultAltitudeFtAgl = binding.defaultAltitudeFtAgl

  -- resolved.outbound[1] is already represented by AUFTRAG's native ingress waypoint.
  -- Inject only points 2..N between ingress and the mission execution waypoint.
  local afterUid = ingressUid
  for index = 2, #resolved.outbound do
    local coordinate = resolved.outbound[index]
    local segmentIndex = resolved.outboundSegmentIndexes and resolved.outboundSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
    waypoint.missionUID = mission.auftragsnummer
    binding.outboundUids[#binding.outboundUids + 1] = waypoint.uid
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

  -- Install the COMPLETE return corridor once. These recovery waypoints intentionally
  -- have NO missionUID. MOOSE therefore leaves them in the FLIGHTGROUP route when the
  -- PATROLZONE AUFTRAG is cancelled after tactical completion.
  if not binding.returnInstalled then
    afterUid = missionUid
    for index = 1, #resolved.returnRoute do
      local coordinate = resolved.returnRoute[index]
      local segmentIndex = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[index] or 1
      local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
      local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
      binding.returnUids[#binding.returnUids + 1] = waypoint.uid
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
    binding.returnInstalled = true
  else
    for index, uid in ipairs(binding.returnUids) do
      local segmentIndex = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[index] or 1
      local profile = profileFor(resolved, segmentIndex, defaultAltitudeFtAgl)
      returnProfiles[#returnProfiles + 1] = {
        uid = uid,
        sourceIndex = index,
        segmentIndex = segmentIndex,
        pathlineName = pathlineFor(resolved, segmentIndex),
        altitudeFtAgl = profile.altitudeFtAgl,
        altType = "RADIO",
      }
    end
  end

  requireFunction(flightGroup, "UpdateRoute", "FLIGHTGROUP")
  flightGroup:UpdateRoute()

  binding.installing = false
  binding.installCount = (binding.installCount or 0) + 1
  binding.lastResult = {
    missionUid = missionUid,
    ingressUid = ingressUid,
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
    recoveryWaypointsMissionOwned = false,
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
    if not binding or binding.installing or binding.closed then return end
    if missionIsOver(binding.mission) then
      binding.closed = true
      return
    end
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
  requireFunction(mission, "IsOver", "AUFTRAG")
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
    outboundUids = {},
    returnUids = {},
    returnInstalled = false,
    installCount = 0,
    installing = false,
    closed = false,
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
