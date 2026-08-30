-- Operation Mountain Watch - shared MOOSE helicopter FlightPath corridor adapter.
--
-- Extracted from the DCS-accepted Stage 1D-P PERSONNEL air-resupply corridor.
-- Geometry remains owner-authored through PATHLINE; this adapter only orients,
-- composes, offsets, and inserts MOOSE FLIGHTGROUP waypoints around an AUFTRAG mission.

local Corridor = {}

local TAG = "[OMW][HelicopterFlightPathCorridor]"
Corridor.SchemaVersion = "OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-4"
Corridor.DefaultPathlineName = "OMW_FlightPath"
Corridor.DefaultOffsetRightM = 500
Corridor.DefaultRightHeadingDeltaDeg = 90
Corridor.DefaultAltitudeFtAgl = 500
Corridor.DefaultJunctionMaxDistanceM = 1000

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

local function nearestCoordinatePair(leftCoordinates, rightCoordinates)
  local bestLeft, bestRight, bestDistance = nil, nil, nil
  for leftIndex, leftCoordinate in ipairs(leftCoordinates) do
    for rightIndex, rightCoordinate in ipairs(rightCoordinates) do
      local distance = leftCoordinate:Get2DDistance(rightCoordinate)
      if bestDistance == nil or distance < bestDistance then
        bestLeft = leftIndex
        bestRight = rightIndex
        bestDistance = distance
      end
    end
  end
  return bestLeft, bestRight, bestDistance
end

local function appendSegment(result, coordinates, fromIndex, toIndex, skipFirst)
  local step = toIndex >= fromIndex and 1 or -1
  local index = fromIndex
  local first = true
  while true do
    if not (skipFirst and first) then result[#result + 1] = coordinates[index] end
    if index == toIndex then break end
    index = index + step
    first = false
  end
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

local function resolvePathline(pathlineName, suppliedPathline)
  local pathline = suppliedPathline
  if not pathline then
    if type(PATHLINE) ~= "table" or type(PATHLINE.FindByName) ~= "function" then
      fail("MOOSE PATHLINE:FindByName() is required")
    end
    pathline = PATHLINE:FindByName(pathlineName)
  end
  requireTable(pathline, "PATHLINE " .. tostring(pathlineName))
  if type(pathline.GetCoordinates) ~= "function" then fail("PATHLINE:GetCoordinates() is required") end
  local coordinates = pathline:GetCoordinates()
  if type(coordinates) ~= "table" or #coordinates < 2 then
    fail("FlightPath requires at least two coordinates: " .. tostring(pathlineName))
  end
  return pathline, coordinates
end

function Corridor.Resolve(spec)
  requireTable(spec, "spec")
  local originCoordinate = requireTable(spec.originCoordinate, "spec.originCoordinate")
  local destinationCoordinate = requireTable(spec.destinationCoordinate, "spec.destinationCoordinate")
  local pathlineName = spec.pathlineName or Corridor.DefaultPathlineName
  local offsetRightM = spec.offsetRightM or Corridor.DefaultOffsetRightM
  local headingDeltaDeg = spec.rightHeadingDeltaDeg or Corridor.DefaultRightHeadingDeltaDeg

  local _, rawCoordinates = resolvePathline(pathlineName, spec.pathline)
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
    pathlineNames = { pathlineName },
    offsetRightM = offsetRightM,
    rightHeadingDeltaDeg = headingDeltaDeg,
    pathlinePointCount = #rawCoordinates,
    corridorPointCount = #centerline,
    originWaypointIndex = originIndex,
    destinationWaypointIndex = destinationIndex,
    originDistanceM = originDistance,
    destinationDistanceM = destinationDistance,
    junctions = {},
    outbound = directionalRightOffsetCoordinates(centerline, offsetRightM, headingDeltaDeg),
    returnRoute = directionalRightOffsetCoordinates(reverseCoordinates(centerline), offsetRightM, headingDeltaDeg),
  }
end

function Corridor.ResolveSequence(spec)
  requireTable(spec, "spec")
  local originCoordinate = requireTable(spec.originCoordinate, "spec.originCoordinate")
  local destinationCoordinate = requireTable(spec.destinationCoordinate, "spec.destinationCoordinate")
  local pathlineNames = requireTable(spec.pathlineNames, "spec.pathlineNames")
  if #pathlineNames < 1 then fail("spec.pathlineNames requires at least one PATHLINE name") end
  if #pathlineNames == 1 then
    return Corridor.Resolve({
      pathlineName = pathlineNames[1],
      pathline = spec.pathlines and spec.pathlines[1] or nil,
      originCoordinate = originCoordinate,
      destinationCoordinate = destinationCoordinate,
      offsetRightM = spec.offsetRightM,
      rightHeadingDeltaDeg = spec.rightHeadingDeltaDeg,
    })
  end

  local offsetRightM = spec.offsetRightM or Corridor.DefaultOffsetRightM
  local headingDeltaDeg = spec.rightHeadingDeltaDeg or Corridor.DefaultRightHeadingDeltaDeg
  local maxJunctionDistanceM = spec.maxJunctionDistanceM or Corridor.DefaultJunctionMaxDistanceM
  if type(maxJunctionDistanceM) ~= "number" or maxJunctionDistanceM <= 0 then
    fail("spec.maxJunctionDistanceM must be a positive number")
  end

  local allCoordinates = {}
  local totalPointCount = 0
  for index, pathlineName in ipairs(pathlineNames) do
    if type(pathlineName) ~= "string" or pathlineName == "" then fail("pathlineNames entries must be non-empty strings") end
    local supplied = spec.pathlines and spec.pathlines[index] or nil
    local _, coordinates = resolvePathline(pathlineName, supplied)
    allCoordinates[index] = coordinates
    totalPointCount = totalPointCount + #coordinates
  end

  local junctions = {}
  for index = 1, #allCoordinates - 1 do
    local leftIndex, rightIndex, distance = nearestCoordinatePair(allCoordinates[index], allCoordinates[index + 1])
    if not leftIndex or not rightIndex or distance > maxJunctionDistanceM then
      fail(string.format(
        "FlightPath junction %s -> %s gap %.1f m exceeds %.1f m",
        tostring(pathlineNames[index]), tostring(pathlineNames[index + 1]), tonumber(distance) or -1, maxJunctionDistanceM))
    end
    junctions[index] = {
      fromPathlineName = pathlineNames[index],
      toPathlineName = pathlineNames[index + 1],
      fromIndex = leftIndex,
      toIndex = rightIndex,
      distanceM = distance,
    }
  end

  local originIndex, originDistance = nearestCoordinateIndex(allCoordinates[1], originCoordinate)
  local destinationIndex, destinationDistance = nearestCoordinateIndex(allCoordinates[#allCoordinates], destinationCoordinate)
  if not originIndex or not destinationIndex then fail("FlightPath sequence cannot resolve origin/destination") end

  local centerline = {}
  for index = 1, #allCoordinates do
    local fromIndex
    local toIndex
    if index == 1 then
      fromIndex = originIndex
      toIndex = junctions[1].fromIndex
    elseif index == #allCoordinates then
      fromIndex = junctions[index - 1].toIndex
      toIndex = destinationIndex
    else
      fromIndex = junctions[index - 1].toIndex
      toIndex = junctions[index].fromIndex
    end
    appendSegment(centerline, allCoordinates[index], fromIndex, toIndex, false)
  end
  if #centerline < 2 then fail("resolved FlightPath sequence corridor is too short") end

  return {
    pathlineName = table.concat(pathlineNames, " -> "),
    pathlineNames = pathlineNames,
    offsetRightM = offsetRightM,
    rightHeadingDeltaDeg = headingDeltaDeg,
    pathlinePointCount = totalPointCount,
    corridorPointCount = #centerline,
    originWaypointIndex = originIndex,
    destinationWaypointIndex = destinationIndex,
    originDistanceM = originDistance,
    destinationDistanceM = destinationDistance,
    junctions = junctions,
    maxJunctionDistanceM = maxJunctionDistanceM,
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
    elseif reason ~= "MISSION_ROUTE_UIDS_NOT_READY" then
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
    armRouteReadyInstall(flightGroup, mission, resolved, altitudeFtAgl)
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

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
    pathlineNames = resolved.pathlineNames,
    junctions = resolved.junctions,
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