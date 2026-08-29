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

local pathline = { coordinates={coord(0,0), coord(0,1000), coord(0,2000), coord(0,3000)} }
function pathline:GetCoordinates() return self.coordinates end

local resolved = Corridor.Resolve({
  pathline=pathline,
  originCoordinate=coord(0,100),
  destinationCoordinate=coord(0,2900),
})
assertEqual(resolved.pathlineName, "OMW_FlightPath", "pathline name")
assertEqual(resolved.corridorPointCount, 4, "corridor point count")
assertEqual(resolved.offsetRightM, 500, "right offset")
assertEqual(math.floor(resolved.outbound[1].x+0.5), 500, "outbound right-hand x offset")
assertEqual(math.floor(resolved.returnRoute[1].x+0.5), -500, "reverse route right-hand x offset")

local mission = {}
function mission:GetGroupWaypointIndex() return 20 end
function mission:GetGroupEgressWaypointUID() return 30 end
local flight = { added={} }
function flight:GetWaypointIndex(uid) assertEqual(uid,20,"mission uid"); return 3 end
function flight:GetWaypointUIDFromIndex(index) assertEqual(index,2,"previous waypoint index"); return 10 end
function flight:AddWaypoint(coordinate, _, insertAfterUid, altitude, updateRoute)
  local uid=100+#self.added+1
  self.added[#self.added+1]={coord=coordinate, after=insertAfterUid, altitude=altitude, update=updateRoute, uid=uid}
  return { uid=uid }
end

local installed, ok, reason = Corridor.Install(flight, mission, resolved, 500)
assertTrue(ok, "corridor installed")
assertEqual(reason, nil, "install reason")
assertEqual(installed.outboundWaypointCount, 4, "outbound count")
assertEqual(installed.returnWaypointCount, 3, "return count")
assertEqual(#flight.added, 7, "total added waypoints")
assertEqual(flight.added[1].after, 10, "outbound starts after pre-mission waypoint")
assertEqual(flight.added[5].after, 20, "return starts after mission waypoint")
assertEqual(flight.added[7].update, true, "last inserted return waypoint updates route")

local waitingMission = {}
function waitingMission:GetGroupWaypointIndex() return nil end
function waitingMission:GetGroupEgressWaypointUID() return nil end
local noInstall, noOk, noReason = Corridor.Install(flight, waitingMission, resolved, 500)
assertEqual(noInstall, nil, "not-ready no install")
assertEqual(noOk, false, "not-ready false")
assertEqual(noReason, "MISSION_ROUTE_UIDS_NOT_READY", "not-ready reason")

print("PASS test_helicopter_flightpath_corridor")
