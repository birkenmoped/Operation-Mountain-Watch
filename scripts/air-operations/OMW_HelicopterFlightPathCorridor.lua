-- Operation Mountain Watch - shared MOOSE helicopter FlightPath corridor adapter.
--
-- Extracted from the DCS-accepted Stage 1D-P PERSONNEL air-resupply corridor.
-- Geometry remains owner-authored through PATHLINE; this adapter only orients,
-- offsets, and inserts MOOSE FLIGHTGROUP waypoints around an AUFTRAG mission.

local Corridor = {}

local TAG = "[OMW][HelicopterFlightPathCorridor]"
Corridor.SchemaVersion = "OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-3"
Corridor.DefaultPathlineName = "OMW_FlightPath"
Corridor.DefaultOffsetRightM = 500
Corridor.DefaultRightHeadingDeltaDeg = 90
Corridor.DefaultAltitudeFtAgl = 500

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function reverseCoordinates(coordinates)
  local result = {}
  for index = #coordinates, 1, -1 do
    result[#result + 1] = coordinates[index]
  end
  return result
end

local function nearestCoordinateIndex(coordinates, referenceCoordinate)
  local bestIndex, bestDistance = nil, nil
  for index, coordinate in ipairs(coordinates) do
    local distance = coordinate:Get2DDistance(referenceCoordinate)
    if bestDistance == nil or distance < bestDistance then
      bestIndex = index
      bestDistance = distance
    end
  end
  return bestIndex, bestDistance
end

local function directionalRightOffsetCoordinates(coordinates, offsetMeters, headingDeltaDeg)
  local result = {}
  if #coordinates < 2 then return result end

  for index, coordinate in ipairs(coordinates) do
    local fromCoordinate, toCoordinate
    if index < #coordinates then
      fromCoordinate = coordinate
      toCoordinate = coordinates[index + 1]
    else
      fromCoordinate = coordinates[index - 1]
      toCoordinate = coordinate
    end
    local heading = fromCoordinate:HeadingTo(toCoordinate)
    result[#result + 1] = coordinate:Translate(offsetMeters, heading + headingDeltaDeg, false, false)
  end
  return result
end

function Corridor.Resolve(spec)
  requireTable(spec, "spec")
  local originCoordinate = requireTable(spec.originCoordinate, "spec.originCoordinate")
  local destinationCoordinate = requireTable(spec.destinationCoordinate, "spec.destinationCoordinate")
  local pathlineName = spec.pathlineName or Corridor.DefaultPathlineName
  local offsetRightM = spec.offsetRightM or Corridor.DefaultOffsetRightM
  local headingDeltaDeg = spec.rightHeadingDeltaDeg or Corridor.DefaultRightHeadingDeltaDeg

  local pathline = spec.pathline
  if not pathline then
    if type(PATHLINE) ~= "table" or type(PATHLINE.FindByName) ~= "function" then
      fail("MOOSE PATHLINE:FindByName() is required")
    end
    pathline = PATHLINE:FindByName(pathlineName)
  end
  requireTable(pathline, "PATHLINE")
  if type(pathline.GetCoordinates) ~= "function" then fail("PATHLINE:GetCoordinates() is required") end

  local rawCoordinates = pathline:GetCoordinates()
  if type(rawCoordinates) ~= "table" or #rawCoordinates < 2 then
    fail("FlightPath requires at least two coordinates")
  end

  local firstDistance = rawCoordinates[1]:Get2DDistance(originCoordinate)
  local lastDistance = rawCoordinates[#rawCoordinates]:Get2DDistance(originCoordinate)
  local oriented = rawCoordinates
  if lastDistance < firstDistance then oriented = reverseCoordinates(rawCoordinates) end

  local originIndex, originDistance = nearestCoordinateIndex(oriented, originCoordinate)
  local destinationIndex, destinationDistance = nearestCoordinateIndex(oriented, destinationCoordinate)
  if not originIndex or not destinationIndex or destinationIndex <= originIndex then
    fail("FlightPath cannot resolve an origin-to-destination corridor")
  end

  local centerline = {}
  for index = originIndex, destinationIndex do centerline[#centerline + 1] = oriented[index] end
  if #centerline < 2 then fail("resolved FlightPath corridor is too short") end

  return {
    pathlineName = pathlineName,
    offsetRightM = offsetRightM,
    rightHeadingDeltaDeg = headingDeltaDeg,
    pathlinePointCount = #rawCoordinates,
    corridorPointCount = #centerline,
    originWaypointIndex = originIndex,
    destinationWaypointIndex = destinationIndex,
    originDistanceM = originDistance,
    destinationDistanceM = destinationDistance,
    outbound = directionalRightOffsetCoordinates(centerline, offsetRightM, headingDeltaDeg),
    returnRoute = directionalRightOffsetCoordinates(reverseCoordinates(centerline), offsetRightM, headingDeltaDeg),
  }
end

local function armRouteReadyInstall(flightGroup, mission, resolved, altitudeFtAgl)
  flightGroup.__omwFlightPathCorridorPending = {
    mission = mission,
    resolved = resolved,
    altitudeFtAgl = altitudeFtAgl,
  }

  if flightGroup.__omwFlightPathCorridorRouteHook then return end
  flightGroup.__omwFlightPathCorridorRouteHook = true

  local previousUpdateRoute = flightGroup.OnAfterUpdateRoute
  function flightGroup:OnAfterUpdateRoute(From, Event, To, n, N)
    if previousUpdateRoute then previousUpdateRoute(self, From, Event, To, n, N) end

    local pending = self.__omwFlightPathCorridorPending
    if not pending or self.__omwFlightPathCorridorInstalling then return end

    self.__omwFlightPathCorridorInstalling = true
    local installed, ok, reason = Corridor.Install(self, pending.mission, pending.resolved, pending.altitudeFtAgl)
    self.__omwFlightPathCorridorInstalling = nil

    if ok then
      self.__omwFlightPathCorridorInstalled = {
        mission = pending.mission,
        result = installed,
      }
      self.__omwFlightPathCorridorPending = nil
      self.__omwFlightPathCorridorLastReason = nil
    elseif reason ~= "MISSION_ROUTE_UID_NOT_READY" then
      self.__omwFlightPathCorridorLastReason = reason
    end
  end
end

function Corridor.Install(flightGroup, mission, resolved, altitudeFtAgl)
  requireTable(flightGroup, "flightGroup")
  requireTable(mission, "mission")
  requireTable(resolved, "resolved")

  if type(mission.GetGroupWaypointIndex) ~= "function" then fail("AUFTRAG:GetGroupWaypointIndex() is required") end
  if type(flightGroup.GetWaypointIndex) ~= "function"
      or type(flightGroup.GetWaypointUIDFromIndex) ~= "function"
      or type(flightGroup.AddWaypoint) ~= "function" then
    fail("FLIGHTGROUP waypoint APIs are required")
  end

  local cached = flightGroup.__omwFlightPathCorridorInstalled
  if cached and cached.mission == mission and cached.result then
    return cached.result, true, nil
  end
  if flightGroup.__omwFlightPathCorridorLastReason then
    return nil, false, flightGroup.__omwFlightPathCorridorLastReason
  end

  local missionUid = mission:GetGroupWaypointIndex(flightGroup)
  if type(missionUid) ~= "number" then
    -- MOOSE sets the mission waypoint UID in OPSGROUP:RouteToMission().
    -- FlightOnMission can fire before that route build has completed, so defer
    -- to the FLIGHTGROUP UpdateRoute lifecycle instead of guessing readiness.
    armRouteReadyInstall(flightGroup, mission, resolved, altitudeFtAgl)
    return nil, false, "MISSION_ROUTE_UID_NOT_READY"
  end

  -- An egress UID is optional. OPSGROUP:RouteToMission() only creates and stores
  -- one when AUFTRAG:GetMissionEgressCoord() returns a coordinate. NewCAS() is
  -- derived from NewORBIT() and does not inherently define an egress coordinate.
  -- The corridor insertion contract only needs the mission waypoint UID.
  local egressUid = nil
  if type(mission.GetGroupEgressWaypointUID) == "function" then
    egressUid = mission:GetGroupEgressWaypointUID(flightGroup)
  end

  local missionIndex = flightGroup:GetWaypointIndex(missionUid)
  if type(missionIndex) ~= "number" or missionIndex <= 1 then
    fail("mission waypoint index is invalid")
  end
  local previousUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 1)
  if type(previousUid) ~= "number" then fail("pre-mission waypoint UID is unavailable") end

  local altitude = altitudeFtAgl or Corridor.DefaultAltitudeFtAgl
  local outboundCount, returnCount = 0, 0

  -- Preserve the exact waypoint insertion contract that was DCS-accepted by the
  -- Stage 1D-P OMW_FlightPath test.
  for _, coordinate in ipairs(resolved.outbound) do
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, previousUid, altitude, false)
    previousUid = waypoint.uid
    outboundCount = outboundCount + 1
  end

  local insertAfterUid = missionUid
  for index = 1, math.max(#resolved.returnRoute - 1, 0) do
    local coordinate = resolved.returnRoute[index]
    local updateRoute = index == (#resolved.returnRoute - 1)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, insertAfterUid, altitude, updateRoute)
    insertAfterUid = waypoint.uid
    returnCount = returnCount + 1
  end

  local result = {
    missionUid = missionUid,
    egressUid = egressUid,
    outboundWaypointCount = outboundCount,
    returnWaypointCount = returnCount,
    altitudeFtAgl = altitude,
  }

  flightGroup.__omwFlightPathCorridorInstalled = {
    mission = mission,
    result = result,
  }
  flightGroup.__omwFlightPathCorridorPending = nil
  flightGroup.__omwFlightPathCorridorLastReason = nil

  return result, true, nil
end

return Corridor
