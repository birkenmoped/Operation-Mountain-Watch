-- Operation Mountain Watch - OPSTRANSPORT helicopter corridor adapter.
--
-- MOOSE 2.9.18 applies OPSTRANSPORT transport paths to FLIGHTGROUP carriers only
-- when the deploy target is an airbase. OMW also transports to field LZ zones.
-- This adapter keeps the complete MOOSE OPSTRANSPORT loading/unloading lifecycle
-- and only inserts public FLIGHTGROUP waypoints around that lifecycle.

local Adapter = {
  Schema = "OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-1",
}

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

local function installRoute(flightGroup, coordinates, altitudeFtAgl, label, options)
  if type(coordinates) ~= "table" or #coordinates == 0 then
    return fail(options, label .. " route has no coordinates")
  end

  local afterUid = flightGroup:GetWaypointCurrentUID()
  if type(afterUid) ~= "number" then
    return fail(options, label .. " current waypoint UID unavailable")
  end

  local count = 0
  for i = 1, #coordinates do
    local waypoint = flightGroup:AddWaypoint(coordinates[i], nil, afterUid, altitudeFtAgl, false)
    if not waypoint or type(waypoint.uid) ~= "number" then
      return fail(options, string.format("%s AddWaypoint failed at index=%d", label, i))
    end
    afterUid = waypoint.uid
    count = count + 1
  end

  flightGroup:UpdateRoute()
  log(string.format("%s installed flight=%s count=%d lastUid=%d", label, flightGroup:GetName(), count, afterUid))
  return true, count
end

function Adapter.Bind(flightGroup, transport, resolvedCorridor, altitudeFtAgl, options)
  options = options or {}

  if not flightGroup or type(flightGroup.AddWaypoint) ~= "function" or type(flightGroup.UpdateRoute) ~= "function" then
    return nil, false, "FLIGHTGROUP_REQUIRED"
  end
  if not transport or type(transport.GetState) ~= "function" then
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
    outboundInstalled = false,
    returnInstalled = false,
    outboundWaypointCount = 0,
    returnWaypointCount = 0,
  }

  local oldTransport = flightGroup.OnAfterTransport
  function flightGroup:OnAfterTransport(From, Event, To)
    if oldTransport then oldTransport(self, From, Event, To) end
    if binding.outboundInstalled or self.cargoTransport ~= transport then return end

    local ok, result = installRoute(self, resolvedCorridor.outbound, altitudeFtAgl, "R500_OUTBOUND", options)
    if not ok then return end
    binding.outboundInstalled = true
    binding.outboundWaypointCount = result
    if type(options.onOutboundInstalled) == "function" then
      options.onOutboundInstalled(binding)
    end
  end

  local oldDelivered = flightGroup.OnAfterDelivered
  function flightGroup:OnAfterDelivered(From, Event, To, deliveredTransport)
    if oldDelivered then oldDelivered(self, From, Event, To, deliveredTransport) end
    if binding.returnInstalled or deliveredTransport ~= transport then return end

    local ok, result = installRoute(self, resolvedCorridor.returnRoute, altitudeFtAgl, "R500_RETURN", options)
    if not ok then return end
    binding.returnInstalled = true
    binding.returnWaypointCount = result
    if type(options.onReturnInstalled) == "function" then
      options.onReturnInstalled(binding)
    end
  end

  log(string.format("bound flight=%s transportUid=%s", flightGroup:GetName(), tostring(transport.uid)))
  return binding, true, nil
end

return Adapter
