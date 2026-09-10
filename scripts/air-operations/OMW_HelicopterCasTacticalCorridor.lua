-- Operation Mountain Watch - dynamic tactical CAS corridor adapter.
--
-- OMW owns the per-allocation tactical geometry:
--   WEST -> CAS_INGRESS -> tactical ingress -> CAS_MISSION_POINT/BP
--   -> tactical egress -> CAS_EGRESS -> WEST reverse.
--
-- MOOSE owns AUFTRAG, PATROLZONE, engagement, mission FSM and recovery.
-- This module only uses public MOOSE AUFTRAG and FLIGHTGROUP APIs. It does not
-- create a Native-DCS controller task, scheduler, target policy or CAS lifecycle.

local Adapter = {
  Schema = "OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1",
}

local TAG = "[OMW][CAS-TACTICAL-CORRIDOR]"

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(value, name, label)
  if type(value) ~= "table" or type(value[name]) ~= "function" then
    fail((label or "value") .. ":" .. tostring(name) .. "() is required")
  end
end

local function requirePositiveNumber(value, label)
  if type(value) ~= "number" or value <= 0 then fail(label .. " must be a positive number") end
  return value
end

local function requireCoordinate(node, label)
  requireTable(node, label)
  if not node.coordinate then fail(label .. ".coordinate is required") end
  requireFunction(node.coordinate, "GetLandHeight", label .. ".coordinate")
  requirePositiveNumber(node.altitudeFtAgl, label .. ".altitudeFtAgl")
  requirePositiveNumber(node.speedKts, label .. ".speedKts")
  requirePositiveNumber(node.axisDeg, label .. ".axisDeg")
  return node
end

local function requireSegment(segment, label)
  if segment == nil then return {} end
  requireTable(segment, label)
  for index, node in ipairs(segment) do
    requireCoordinate(node, label .. "[" .. tostring(index) .. "]")
  end
  return segment
end

local function asAslFeet(node)
  if type(UTILS) ~= "table" or type(UTILS.MetersToFeet) ~= "function" then
    fail("MOOSE UTILS.MetersToFeet() is required")
  end
  return UTILS.MetersToFeet(node.coordinate:GetLandHeight()) + node.altitudeFtAgl
end

local function sameCoordinate(left, right, toleranceM)
  if left == right then return true end
  if not left or not right then return false end
  if type(left.Get2DDistance) ~= "function" then return false end
  return left:Get2DDistance(right) <= toleranceM
end

local function ensureSegmentExcludes(segment, forbiddenCoordinates, label, toleranceM)
  for index, node in ipairs(segment) do
    for _, forbidden in ipairs(forbiddenCoordinates) do
      if sameCoordinate(node.coordinate, forbidden, toleranceM) then
        fail(label .. "[" .. tostring(index) .. "] duplicates a mission node")
      end
    end
  end
end

local function validateGeometry(geometry)
  requireTable(geometry, "geometry")
  if type(geometry.allocationId) ~= "string" or geometry.allocationId == "" then
    fail("geometry.allocationId is required")
  end
  if type(geometry.westExitDistanceNm) ~= "number" or geometry.westExitDistanceNm < 3 or geometry.westExitDistanceNm > 4 then
    fail("geometry.westExitDistanceNm must be within the approved 3-4 NM band")
  end

  local ingress = requireCoordinate(geometry.ingress, "geometry.ingress")
  local missionPoint = requireCoordinate(geometry.missionPoint, "geometry.missionPoint")
  local egress = requireCoordinate(geometry.egress, "geometry.egress")
  local outboundTransit = requireSegment(geometry.outboundTransit, "geometry.outboundTransit")
  local tacticalIngress = requireSegment(geometry.tacticalIngress, "geometry.tacticalIngress")
  local tacticalEgress = requireSegment(geometry.tacticalEgress, "geometry.tacticalEgress")
  local returnTransit = requireSegment(geometry.returnTransit, "geometry.returnTransit")
  local toleranceM = geometry.nodeToleranceM or 1

  ensureSegmentExcludes(outboundTransit, { ingress.coordinate, missionPoint.coordinate, egress.coordinate }, "geometry.outboundTransit", toleranceM)
  ensureSegmentExcludes(tacticalIngress, { ingress.coordinate, missionPoint.coordinate, egress.coordinate }, "geometry.tacticalIngress", toleranceM)
  ensureSegmentExcludes(tacticalEgress, { ingress.coordinate, missionPoint.coordinate, egress.coordinate }, "geometry.tacticalEgress", toleranceM)
  ensureSegmentExcludes(returnTransit, { ingress.coordinate, missionPoint.coordinate, egress.coordinate }, "geometry.returnTransit", toleranceM)

  if sameCoordinate(ingress.coordinate, missionPoint.coordinate, toleranceM)
      or sameCoordinate(missionPoint.coordinate, egress.coordinate, toleranceM)
      or sameCoordinate(ingress.coordinate, egress.coordinate, toleranceM) then
    fail("CAS ingress, mission point and egress must be spatially distinct")
  end

  if type(geometry.evidence) ~= "table"
      or type(geometry.evidence.honakerReference) ~= "string"
      or type(geometry.evidence.westReference) ~= "string" then
    fail("geometry.evidence requires honakerReference and westReference")
  end

  return {
    allocationId = geometry.allocationId,
    westExitDistanceNm = geometry.westExitDistanceNm,
    ingress = ingress,
    missionPoint = missionPoint,
    egress = egress,
    outboundTransit = outboundTransit,
    tacticalIngress = tacticalIngress,
    tacticalEgress = tacticalEgress,
    returnTransit = returnTransit,
    evidence = geometry.evidence,
  }
end

local function addNodes(flightGroup, nodes, afterUid, phase, profiles)
  for index, node in ipairs(nodes) do
    local waypoint = flightGroup:AddWaypoint(node.coordinate, node.speedKts, afterUid, node.altitudeFtAgl, false)
    if not waypoint or type(waypoint.uid) ~= "number" then
      fail(phase .. " AddWaypoint failed at index=" .. tostring(index))
    end
    profiles[#profiles + 1] = {
      uid = waypoint.uid,
      phase = phase,
      sourceIndex = index,
      altitudeFtAgl = node.altitudeFtAgl,
      speedKts = node.speedKts,
      axisDeg = node.axisDeg,
    }
    afterUid = waypoint.uid
  end
  return afterUid
end

function Adapter.ConfigureMission(mission, geometry)
  requireTable(mission, "mission")
  requireFunction(mission, "SetMissionIngressCoord", "AUFTRAG")
  requireFunction(mission, "SetMissionWaypointCoord", "AUFTRAG")
  requireFunction(mission, "SetMissionEgressCoord", "AUFTRAG")

  local planned = validateGeometry(geometry)
  mission:SetMissionIngressCoord(planned.ingress.coordinate, asAslFeet(planned.ingress), planned.ingress.speedKts)
  mission:SetMissionWaypointCoord(planned.missionPoint.coordinate)
  mission:SetMissionEgressCoord(planned.egress.coordinate, asAslFeet(planned.egress), planned.egress.speedKts)

  log(string.format(
    "CAS_GEOMETRY_CONFIGURED allocationId=%s westExitDistanceNm=%.2f ingressAxisDeg=%.1f missionAxisDeg=%.1f egressAxisDeg=%.1f honaker=%s west=%s",
    planned.allocationId, planned.westExitDistanceNm, planned.ingress.axisDeg,
    planned.missionPoint.axisDeg, planned.egress.axisDeg,
    planned.evidence.honakerReference, planned.evidence.westReference))

  return planned
end


-- Derive the MOOSE single-node hooks from the selected owner route on every
-- allocation. No mission-editor marker, resolver endpoint, or random point is used.
-- The PATROLZONE remains the working area; missionPoint is its dynamic AO anchor,
-- not a separately invented battle position.
function Adapter.PlanRouteGated(spec)
  requireTable(spec, "spec")
  local outbound = requireTable(spec.outboundRoute, "spec.outboundRoute")
  local returnRoute = requireTable(spec.returnRoute, "spec.returnRoute")
  local destination = requireCoordinate(spec.destinationCoordinate, "spec.destinationCoordinate")
  local distanceNm = spec.routeGateDistanceNm
  if type(distanceNm) ~= "number" or distanceNm < 3 or distanceNm > 4 then
    fail("spec.routeGateDistanceNm must be within the approved 3-4 NM range")
  end
  local distanceM = distanceNm * 1852

  local function gate(route, phase)
    if #route < 2 then fail(phase .. " route requires at least two coordinates") end
    local best, bestDelta
    for index, coordinate in ipairs(route) do
      requireCoordinate(coordinate, phase .. " route coordinate")
      local delta = math.abs(coordinate:Get2DDistance(destination) - distanceM)
      if not bestDelta or delta < bestDelta then best, bestDelta = index, delta end
    end
    if not best or bestDelta > 1852 then
      fail(phase .. " route has no owner-authored coordinate within 1 NM of the requested 3-4 NM AO gate")
    end
    return best
  end

  local ingressIndex = gate(outbound, "INGRESS")
  local egressIndex = gate(returnRoute, "EGRESS")
  local function copyRange(route, first, last)
    local result = {}
    for index=first,last do result[#result+1] = { coordinate=route[index], altitudeFtAgl=spec.transitAltitudeFtAgl, speedKts=spec.speedKts, axisDeg=route[index]:HeadingTo(route[math.min(index+1,#route)]) } end
    return result
  end
  local function node(coordinate, nextCoordinate)
    return { coordinate=coordinate, altitudeFtAgl=spec.transitAltitudeFtAgl, speedKts=spec.speedKts, axisDeg=coordinate:HeadingTo(nextCoordinate or destination) }
  end
  local ingress = node(outbound[ingressIndex], outbound[math.min(ingressIndex+1,#outbound)])
  local egress = node(returnRoute[egressIndex], returnRoute[math.min(egressIndex+1,#returnRoute)])
  local geometry = {
    allocationId = spec.allocationId,
    westExitDistanceNm = distanceNm,
    ingress = ingress,
    missionPoint = { coordinate=destination, altitudeFtAgl=spec.missionAltitudeFtAgl, speedKts=spec.speedKts, axisDeg=ingress.axisDeg },
    egress = egress,
    outboundTransit = copyRange(outbound, 1, math.max(1, ingressIndex-1)),
    tacticalIngress = {},
    tacticalEgress = {},
    returnTransit = copyRange(returnRoute, math.min(#returnRoute, egressIndex+1), #returnRoute),
    evidence = {
      honakerReference = spec.honakerReference,
      westReference = spec.westReference,
      ingressRouteIndex = ingressIndex,
      egressRouteIndex = egressIndex,
      missionPointRole = "PATROLZONE_DYNAMIC_AO_ANCHOR_NOT_BP",
    },
  }
  validateGeometry(geometry)
  log(string.format("CAS_ROUTE_GATES_DERIVED allocationId=%s distanceNm=%.2f ingressRouteIndex=%d egressRouteIndex=%d", geometry.allocationId, distanceNm, ingressIndex, egressIndex))
  return geometry
end

local function install(flightGroup, binding)
  if binding.installed then return binding.result, true, "ALREADY_INSTALLED" end
  if binding.installing then return nil, false, "INSTALL_IN_PROGRESS" end

  local missionUid = binding.mission:GetGroupWaypointIndex(flightGroup)
  local egressUid = binding.mission:GetGroupEgressWaypointUID(flightGroup)
  if type(missionUid) ~= "number" or type(egressUid) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  local missionIndex = flightGroup:GetWaypointIndex(missionUid)
  local egressIndex = flightGroup:GetWaypointIndex(egressUid)
  if type(missionIndex) ~= "number" or missionIndex <= 2 or type(egressIndex) ~= "number" or egressIndex <= missionIndex then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  local ingressUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 1)
  local preIngressUid = flightGroup:GetWaypointUIDFromIndex(missionIndex - 2)
  if type(ingressUid) ~= "number" or type(preIngressUid) ~= "number" then
    return nil, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end

  binding.installing = true
  local profiles = {}

  addNodes(flightGroup, binding.geometry.outboundTransit, preIngressUid, "OUTBOUND_TRANSIT", profiles)
  addNodes(flightGroup, binding.geometry.tacticalIngress, ingressUid, "TACTICAL_INGRESS", profiles)
  addNodes(flightGroup, binding.geometry.tacticalEgress, missionUid, "TACTICAL_EGRESS", profiles)
  addNodes(flightGroup, binding.geometry.returnTransit, egressUid, "RETURN_TRANSIT", profiles)

  flightGroup:UpdateRoute()
  binding.installing = false
  binding.installed = true
  binding.result = {
    mode = "MOOSE_DYNAMIC_CAS_TACTICAL_CORRIDOR",
    allocationId = binding.geometry.allocationId,
    missionUid = missionUid,
    ingressUid = ingressUid,
    egressUid = egressUid,
    waypointProfiles = profiles,
    evidence = binding.geometry.evidence,
  }

  log(string.format(
    "CAS_CORRIDOR_INSTALLED allocationId=%s missionUid=%d ingressUid=%d egressUid=%d added=%d",
    binding.geometry.allocationId, missionUid, ingressUid, egressUid, #profiles))
  if type(binding.onInstalled) == "function" then binding.onInstalled(binding.result) end
  return binding.result, true, nil
end

function Adapter.Bind(flightGroup, mission, geometry, options)
  requireTable(flightGroup, "flightGroup")
  requireTable(mission, "mission")
  requireFunction(mission, "GetGroupWaypointIndex", "AUFTRAG")
  requireFunction(mission, "GetGroupEgressWaypointUID", "AUFTRAG")
  requireFunction(flightGroup, "GetWaypointIndex", "FLIGHTGROUP")
  requireFunction(flightGroup, "GetWaypointUIDFromIndex", "FLIGHTGROUP")
  requireFunction(flightGroup, "AddWaypoint", "FLIGHTGROUP")
  requireFunction(flightGroup, "UpdateRoute", "FLIGHTGROUP")
  options = options or {}

  local binding = {
    mission = mission,
    geometry = validateGeometry(geometry),
    onInstalled = options.onInstalled,
    onFailed = options.onFailed,
    installed = false,
    installing = false,
    result = nil,
  }

  local result, ok, reason = install(flightGroup, binding)
  if ok then return binding, result, true, nil end
  if reason ~= "MISSION_ROUTE_UIDS_NOT_READY" then
    if type(binding.onFailed) == "function" then binding.onFailed(reason) end
    return binding, nil, false, reason
  end

  local previousUpdateRoute = flightGroup.OnAfterUpdateRoute
  function flightGroup:OnAfterUpdateRoute(From, Event, To, n, N)
    if previousUpdateRoute then previousUpdateRoute(self, From, Event, To, n, N) end
    if binding.installed or binding.installing then return end
    local installed, installedOk, installedReason = install(self, binding)
    if installedOk then return installed end
    if installedReason ~= "MISSION_ROUTE_UIDS_NOT_READY" and type(binding.onFailed) == "function" then
      binding.onFailed(installedReason)
    end
  end

  log("CAS_CORRIDOR_PENDING_MOOSE_ROUTE_CALLBACK allocationId=" .. binding.geometry.allocationId)
  return binding, nil, false, reason
end

return Adapter
