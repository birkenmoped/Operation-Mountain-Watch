-- Operation Mountain Watch - OPSTRANSPORT helicopter corridor adapter.
--
-- MOOSE 2.9.18 applies OPSTRANSPORT transport paths to FLIGHTGROUP carriers only
-- when the deploy target is an airbase. OMW also transports to field LZ zones.
-- This adapter keeps the complete MOOSE OPSTRANSPORT loading/unloading lifecycle
-- and only inserts public FLIGHTGROUP waypoints around that lifecycle.
--
-- Route geometry remains owner-authored through the configured PATHLINE. Optional
-- lead-turn smoothing uses only public MOOSE COORDINATE:GetIntermediateCoordinate()
-- geometry and FLIGHTGROUP:AddWaypoint() TurningPoint waypoints. It does not add a
-- second routing lifecycle or native DCS controller logic.

local Adapter = {
  Schema = "OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2",
}

local DEFAULT_MIN_LEAD_TURN_M = 50
local DEFAULT_MAX_LEG_FRACTION = 0.25
local DEFAULT_MIN_TURN_DEG = 5

local function log(text)
  env.info("[OMW][OPSTRANSPORT-CORRIDOR] " .. tostring(text), false)
end

local function fail(options, reason)
  log("ERROR " .. tostring(reason))
  if options and type(options.onError) == "function" then
    options.onError(reason)
  end
  return false, reason
end

local function headingDeltaDeg(a, b)
  local delta = (b - a + 180) % 360 - 180
  return math.abs(delta)
end

local function smoothCoordinates(coordinates, leadTurnDistanceM, options)
  local sourceCount = #coordinates
  if sourceCount < 3 or type(leadTurnDistanceM) ~= "number" or leadTurnDistanceM <= 0 then
    return coordinates, sourceCount, sourceCount, 0
  end

  local minLeadM = options.minLeadTurnDistanceM or DEFAULT_MIN_LEAD_TURN_M
  local maxLegFraction = options.maxLeadTurnLegFraction or DEFAULT_MAX_LEG_FRACTION
  local minTurnDeg = options.minLeadTurnAngleDeg or DEFAULT_MIN_TURN_DEG
  if type(minLeadM) ~= "number" or minLeadM < 0 then return nil, sourceCount, 0, 0, "INVALID_MIN_LEAD_TURN_DISTANCE" end
  if type(maxLegFraction) ~= "number" or maxLegFraction <= 0 or maxLegFraction > 0.5 then return nil, sourceCount, 0, 0, "INVALID_MAX_LEG_FRACTION" end
  if type(minTurnDeg) ~= "number" or minTurnDeg < 0 or minTurnDeg >= 180 then return nil, sourceCount, 0, 0, "INVALID_MIN_TURN_ANGLE" end

  local result = { coordinates[1] }
  local smoothedCorners = 0

  for index = 2, sourceCount - 1 do
    local previous = coordinates[index - 1]
    local corner = coordinates[index]
    local following = coordinates[index + 1]
    local inboundDistance = previous:Get2DDistance(corner)
    local outboundDistance = corner:Get2DDistance(following)
    local inboundHeading = previous:HeadingTo(corner)
    local outboundHeading = corner:HeadingTo(following)
    local turnDeg = headingDeltaDeg(inboundHeading, outboundHeading)
    local trimM = math.min(leadTurnDistanceM, inboundDistance * maxLegFraction, outboundDistance * maxLegFraction)

    if turnDeg >= minTurnDeg and trimM >= minLeadM then
      result[#result + 1] = corner:GetIntermediateCoordinate(previous, trimM)
      result[#result + 1] = corner:GetIntermediateCoordinate(following, trimM)
      smoothedCorners = smoothedCorners + 1
    else
      result[#result + 1] = corner
    end
  end

  result[#result + 1] = coordinates[sourceCount]
  return result, sourceCount, #result, smoothedCorners
end

local function installRoute(flightGroup, coordinates, altitudeFtAgl, label, options)
  if type(coordinates) ~= "table" or #coordinates == 0 then
    return fail(options, label .. " route has no coordinates")
  end

  local speedKts = options.speedKts
  if speedKts ~= nil and (type(speedKts) ~= "number" or speedKts <= 0) then
    return fail(options, label .. " speedKts must be positive when provided")
  end

  local routeCoordinates, sourceCount, plannedCount, smoothedCorners, smoothingReason =
    smoothCoordinates(coordinates, options.leadTurnDistanceM or 0, options)
  if not routeCoordinates then
    return fail(options, label .. " smoothing failed: " .. tostring(smoothingReason))
  end

  local afterUid = flightGroup:GetWaypointCurrentUID()
  if type(afterUid) ~= "number" then
    return fail(options, label .. " current waypoint UID unavailable")
  end

  local count = 0
  for i = 1, #routeCoordinates do
    local waypoint = flightGroup:AddWaypoint(routeCoordinates[i], speedKts, afterUid, altitudeFtAgl, false)
    if not waypoint or type(waypoint.uid) ~= "number" then
      return fail(options, string.format("%s AddWaypoint failed at index=%d", label, i))
    end
    afterUid = waypoint.uid
    count = count + 1
  end

  flightGroup:UpdateRoute()
  log(string.format(
    "%s installed flight=%s sourcePoints=%d routePoints=%d smoothedCorners=%d speedKts=%s leadTurnM=%s lastUid=%d",
    label, flightGroup:GetName(), sourceCount, plannedCount, smoothedCorners,
    tostring(speedKts or "MOOSE_CRUISE"), tostring(options.leadTurnDistanceM or 0), afterUid))
  return true, {
    waypointCount = count,
    sourcePointCount = sourceCount,
    smoothedCorners = smoothedCorners,
    speedKts = speedKts,
    leadTurnDistanceM = options.leadTurnDistanceM or 0,
  }
end

function Adapter.Bind(flightGroup, transport, resolvedCorridor, altitudeFtAgl, options)
  options = options or {}

  if not flightGroup or type(flightGroup.AddWaypoint) ~= "function" or type(flightGroup.UpdateRoute) ~= "function" then
    return nil, false, "FLIGHTGROUP_REQUIRED"
  end
  if not transport or type(transport.GetState) ~= "function" or type(transport.IsCarrier) ~= "function" then
    return nil, false, "OPSTRANSPORT_REQUIRED"
  end
  if not resolvedCorridor or type(resolvedCorridor.outbound) ~= "table" or type(resolvedCorridor.returnRoute) ~= "table" then
    return nil, false, "RESOLVED_CORRIDOR_REQUIRED"
  end
  if type(altitudeFtAgl) ~= "number" then
    return nil, false, "ALTITUDE_REQUIRED"
  end

  local binding = {
    flightGroup = flightGroup,
    transport = transport,
    speedKts = options.speedKts,
    leadTurnDistanceM = options.leadTurnDistanceM or 0,
    outboundInstalled = false,
    returnInstalled = false,
    outboundWaypointCount = 0,
    outboundSourcePointCount = 0,
    outboundSmoothedCorners = 0,
    returnWaypointCount = 0,
    returnSourcePointCount = 0,
    returnSmoothedCorners = 0,
  }

  local oldTransport = flightGroup.OnAfterTransport
  function flightGroup:OnAfterTransport(From, Event, To)
    if oldTransport then oldTransport(self, From, Event, To) end
    if binding.outboundInstalled or not transport:IsCarrier(self) then return end

    local ok, result = installRoute(self, resolvedCorridor.outbound, altitudeFtAgl, "FLIGHTPATH_OUTBOUND", options)
    if not ok then return end
    binding.outboundInstalled = true
    binding.outboundWaypointCount = result.waypointCount
    binding.outboundSourcePointCount = result.sourcePointCount
    binding.outboundSmoothedCorners = result.smoothedCorners
    if type(options.onOutboundInstalled) == "function" then
      options.onOutboundInstalled(binding)
    end
  end

  local oldDelivered = flightGroup.OnAfterDelivered
  function flightGroup:OnAfterDelivered(From, Event, To, deliveredTransport)
    if oldDelivered then oldDelivered(self, From, Event, To, deliveredTransport) end
    if binding.returnInstalled or deliveredTransport ~= transport then return end

    local ok, result = installRoute(self, resolvedCorridor.returnRoute, altitudeFtAgl, "FLIGHTPATH_RETURN", options)
    if not ok then return end
    binding.returnInstalled = true
    binding.returnWaypointCount = result.waypointCount
    binding.returnSourcePointCount = result.sourcePointCount
    binding.returnSmoothedCorners = result.smoothedCorners
    if type(options.onReturnInstalled) == "function" then
      options.onReturnInstalled(binding)
    end
  end

  log(string.format("bound flight=%s transportUid=%s speedKts=%s leadTurnM=%s",
    flightGroup:GetName(), tostring(transport.uid), tostring(options.speedKts or "MOOSE_CRUISE"), tostring(options.leadTurnDistanceM or 0)))
  return binding, true, nil
end

return Adapter
