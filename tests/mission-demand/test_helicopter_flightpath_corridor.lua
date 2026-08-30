local Corridor = dofile("scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local function coord(x, y)
  local c = { x=x, y=y }
  function c:Get2DDistance(other)
    local dx, dy = self.x-other.x, self.y-other.y
    return math.sqrt(dx*dx+dy*dy)
  end
  function c:HeadingTo(other)
    local angle = math.deg(math.atan(other.x-self.x, other.y-self.y))
    if angle < 0 then angle=angle+360 end
    return angle
  end
  function c:Translate(distance, heading)
    local r=math.rad(heading)
    return coord(self.x + distance*math.sin(r), self.y + distance*math.cos(r))
  end
  return c
end

local function makeFlight()
  local flight = { added={}, formations={} }
  function flight:GetWaypointIndex(uid) assertEqual(uid,20,"mission uid"); return 3 end
  function flight:GetWaypointUIDFromIndex(index) assertEqual(index,2,"previous waypoint index"); return 10 end
  function flight:AddWaypoint(coordinate, _, insertAfterUid, altitude, updateRoute)
    local uid=100+#self.added+1
    self.added[#self.added+1]={coord=coordinate, after=insertAfterUid, altitude=altitude, update=updateRoute, uid=uid}
    return { uid=uid }
  end
  function flight:GetGroup()
    return { SetFormation=function(_, formation) self.formations[#self.formations+1]=formation end }
  end
  return flight
end

local pathline = { coordinates={coord(0,0), coord(0,1000), coord(0,2000), coord(0,3000)} }
function pathline:GetCoordinates() return self.coordinates end

local resolved = Corridor.Resolve({ pathline=pathline, originCoordinate=coord(0,100), destinationCoordinate=coord(0,2900) })
assertEqual(resolved.pathlineName, "OMW_FlightPath", "pathline name")
assertEqual(resolved.corridorPointCount, 4, "corridor point count")
assertEqual(resolved.offsetRightM, 500, "right offset")
assertEqual(math.floor(resolved.outbound[1].x+0.5), 500, "outbound right-hand x offset")
assertEqual(math.floor(resolved.returnRoute[1].x+0.5), -500, "reverse route right-hand x offset")

local west = { coordinates={coord(100,3000), coord(100,4000), coord(100,5000)} }
function west:GetCoordinates() return self.coordinates end
local chained = Corridor.ResolveSequence({
  pathlineNames={"OMW_FlightPath","OMW_FlightPath_WEST"}, pathlines={pathline,west},
  originCoordinate=coord(0,100), destinationCoordinate=coord(100,4900), maxJunctionDistanceM=250,
  segmentProfiles={{altitudeFtAgl=500},{altitudeFtAgl=2500,formation=720896}},
})
assertEqual(chained.pathlineName, "OMW_FlightPath -> OMW_FlightPath_WEST", "chained pathline name")
assertEqual(#chained.pathlineNames, 2, "chained pathline count")
assertEqual(#chained.junctions, 1, "chained junction count")
assertEqual(math.floor(chained.junctions[1].distanceM+0.5), 100, "chained junction gap")
assertEqual(chained.corridorPointCount, 7, "chained centerline point count")
assertEqual(#chained.outbound, 7, "chained outbound count")
assertEqual(#chained.returnRoute, 7, "chained return count")
assertEqual(chained.segmentProfiles[1].altitudeFtAgl, 500, "primary altitude profile")
assertEqual(chained.segmentProfiles[2].altitudeFtAgl, 2500, "west altitude profile")
assertEqual(chained.segmentProfiles[2].formation, 720896, "west column formation profile")
assertEqual(chained.outboundSegmentIndexes[1], 1, "outbound starts primary")
assertEqual(chained.outboundSegmentIndexes[#chained.outboundSegmentIndexes], 2, "outbound ends west")
assertEqual(chained.returnSegmentIndexes[1], 2, "return starts west")
assertEqual(math.floor(chained.outbound[1].x+0.5), 500, "chained outbound starts right of first path")
assertEqual(math.floor(chained.returnRoute[1].x+0.5), -400, "chained return starts right of reversed west path")

local gapOk, gapError = pcall(function()
  local far = { coordinates={coord(2000,3000),coord(2000,4000)} }
  function far:GetCoordinates() return self.coordinates end
  Corridor.ResolveSequence({ pathlineNames={"A","B"}, pathlines={pathline,far}, originCoordinate=coord(0,0), destinationCoordinate=coord(2000,4000), maxJunctionDistanceM=500 })
end)
assertEqual(gapOk, false, "oversize junction rejected")
assertTrue(string.find(gapError, "gap", 1, true) ~= nil, "oversize junction error explains gap")

local mission = {}
function mission:GetGroupWaypointIndex() return 20 end
function mission:GetGroupEgressWaypointUID() return 30 end
local flight = makeFlight()
local installed, ok, reason = Corridor.Install(flight, mission, resolved, 500)
assertTrue(ok, "corridor installed")
assertEqual(reason, nil, "install reason")
assertEqual(installed.egressUid, 30, "optional egress uid captured")
assertEqual(installed.outboundWaypointCount, 4, "outbound count")
assertEqual(installed.returnWaypointCount, 3, "return count")
assertEqual(#flight.added, 7, "total added waypoints")
assertEqual(flight.added[1].after, 10, "outbound starts after pre-mission waypoint")
assertEqual(flight.added[5].after, 20, "return starts after mission waypoint")
assertEqual(flight.added[7].update, true, "last inserted return waypoint updates route")

local chainedFlight = makeFlight()
local chainedInstalled, chainedOk, chainedReason = Corridor.Install(chainedFlight, mission, chained, 500)
assertTrue(chainedOk, "chained corridor installed")
assertEqual(chainedReason, nil, "chained install reason")
assertEqual(chainedInstalled.outboundWaypointCount, 7, "chained installed outbound")
assertEqual(chainedInstalled.returnWaypointCount, 6, "chained installed return")
assertEqual(#chainedFlight.added, 13, "chained total added waypoints")
assertEqual(chainedInstalled.pathlineNames[2], "OMW_FlightPath_WEST", "chained install retains sequence")
assertEqual(math.floor(chainedInstalled.junctions[1].distanceM+0.5), 100, "chained install retains junction evidence")
assertEqual(chainedFlight.added[1].altitude, 500, "primary outbound is 500 ft AGL")
assertEqual(chainedFlight.added[5].altitude, 2500, "west outbound is 2500 ft AGL")
assertEqual(chainedFlight.added[8].altitude, 2500, "west return is 2500 ft AGL")
assertTrue(type(chainedFlight.OnAfterPassingWaypoint)=="function", "formation transition callback installed")
local westTransitionUid
for uid, formation in pairs(chainedInstalled.formationTransitions) do
  if formation == 720896 then westTransitionUid=uid break end
end
assertTrue(type(westTransitionUid)=="number", "west formation transition recorded")
chainedFlight:OnAfterPassingWaypoint("Cruising","PassingWaypoint","Cruising",{uid=westTransitionUid})
assertEqual(chainedFlight.formations[1],720896,"west segment switches to RotaryWing Column D70")

-- AUFTRAG:NewCAS() may have no egress coordinate. Corridor insertion must still work.
local casMission = {}
function casMission:GetGroupWaypointIndex() return 20 end
function casMission:GetGroupEgressWaypointUID() return nil end
local casFlight = makeFlight()
local casInstalled, casOk, casReason = Corridor.Install(casFlight, casMission, resolved, 500)
assertTrue(casOk, "CAS corridor installs without egress uid")
assertEqual(casReason, nil, "CAS no-egress reason")
assertEqual(casInstalled.egressUid, nil, "CAS egress uid remains optional")
assertEqual(#casFlight.added, 7, "CAS no-egress waypoint count")

local waitingMission = {}
function waitingMission:GetGroupWaypointIndex() return nil end
function waitingMission:GetGroupEgressWaypointUID() return nil end
local waitingFlight = makeFlight()
local noInstall, noOk, noReason = Corridor.Install(waitingFlight, waitingMission, resolved, 500)
assertEqual(noInstall, nil, "not-ready no install")
assertEqual(noOk, false, "not-ready false")
assertEqual(noReason, "MISSION_ROUTE_UIDS_NOT_READY", "not-ready reason")
assertTrue(type(waitingFlight.OnAfterUpdateRoute)=="function", "not-ready arms MOOSE route callback")

local deferredMission = { missionUid=nil }
function deferredMission:GetGroupWaypointIndex() return self.missionUid end
function deferredMission:GetGroupEgressWaypointUID() return nil end
local deferredFlight = makeFlight()
deferredFlight.previousUpdateRouteCalls=0
function deferredFlight:OnAfterUpdateRoute() self.previousUpdateRouteCalls=self.previousUpdateRouteCalls+1 end
local deferredInstall, deferredOk, deferredReason = Corridor.Install(deferredFlight, deferredMission, resolved, 500)
assertEqual(deferredInstall, nil, "deferred initial install")
assertEqual(deferredOk, false, "deferred initial ok")
assertEqual(deferredReason, "MISSION_ROUTE_UIDS_NOT_READY", "deferred initial reason")
assertTrue(type(deferredFlight.OnAfterUpdateRoute)=="function", "deferred route callback installed")
deferredMission.missionUid=20
deferredFlight:OnAfterUpdateRoute("Cruising", "UpdateRoute", "Cruising", nil, nil)
assertEqual(deferredFlight.previousUpdateRouteCalls, 1, "previous route callback preserved")
assertEqual(#deferredFlight.added, 7, "deferred total added waypoints")
assertEqual(deferredFlight.added[1].after, 10, "deferred outbound starts after pre-mission waypoint")
assertEqual(deferredFlight.added[5].after, 20, "deferred return starts after mission waypoint")
assertEqual(deferredFlight.added[7].update, true, "deferred last return waypoint updates route")
local cached, cachedOk, cachedReason = Corridor.Install(deferredFlight, deferredMission, resolved, 500)
assertTrue(cachedOk, "deferred cached install")
assertEqual(cachedReason, nil, "deferred cached reason")
assertEqual(cached.outboundWaypointCount, 4, "deferred cached outbound count")
assertEqual(cached.returnWaypointCount, 3, "deferred cached return count")
assertEqual(#deferredFlight.added, 7, "cached install does not duplicate waypoints")

print("PASS test_helicopter_flightpath_corridor")
