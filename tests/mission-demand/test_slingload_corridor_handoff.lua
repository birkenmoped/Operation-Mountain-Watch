local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label)
  if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end
end

local oldCorridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local oldAuftrag = AUFTRAG
local oldScheduler = SCHEDULER

local originalInstallCalls = 0
OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR = {
  Install=function()
    originalInstallCalls=originalInstallCalls+1
    return { mode="ORIGINAL" }, true, nil
  end,
}
AUFTRAG = { Type={ CARGOTRANSPORT="CARGOTRANSPORT" } }
SCHEDULER = {
  New=function()
    return { Stop=function() end }
  end,
}

local Handoff = dofile("scripts/air-operations/OMW_SlingloadCorridorHandoff.lua")
local Corridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR

local nextUid = 20
local capturedCargoTask = nil
local updateRouteCalls = 0
local flight = {
  GetWaypointCurrentUID=function() return 10 end,
  AddWaypoint=function(self, coordinate, speed, afterUid, altitude, updateRoute)
    assertEqual(updateRoute, false, "waypoint deferred route update")
    nextUid=nextUid+1
    return { uid=nextUid, coordinate=coordinate, afterUid=afterUid, altitude=altitude }
  end,
  AddTaskWaypoint=function(self, task, waypoint, description, prio)
    capturedCargoTask=task
    return { task=task, waypoint=waypoint, description=description, prio=prio }
  end,
  UpdateRoute=function() updateRouteCalls=updateRouteCalls+1 end,
  I=function() end,
  E=function() end,
}

local cargo = {
  IsAlive=function() return true end,
  IsInZone=function() return false end,
  GetID=function() return 7001 end,
}
local dropZone = { ZoneID=8002 }
local mission = {
  type=AUFTRAG.Type.CARGOTRANSPORT,
  -- Deliberately remove the constructor-time MOOSE task references. The runtime failure
  -- from Build 1-16 proved they are not a safe post-pickup dependency.
  DCStask={ params={} },
  IsOver=function() return false end,
  Success=function() end,
}
local resolved = {
  outbound={ {name="OUT1"}, {name="OUT2"} },
  returnRoute={ {name="RET1"}, {name="RET2"} },
  outboundSegmentIndexes={1,1},
  returnSegmentIndexes={1,1},
  pathlineNames={"OMW_FlightPath_R500"},
  segmentOffsets={},
  offsetMode="PATHLINE_SUFFIX",
}

local installed, ok, reason = Corridor.Install(flight, mission, resolved, 500, {
  cargo=cargo,
  dropZone=dropZone,
})

assertTrue(ok, "explicit-reference handoff")
assertEqual(reason, nil, "explicit-reference handoff reason")
assertEqual(installed.mode, "APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF", "handoff mode")
assertEqual(installed.referenceSource, "EXPLICIT_ACCEPTANCE_CONTEXT", "reference source")
assertEqual(installed.outboundWaypointCount, 2, "outbound waypoint count")
assertEqual(installed.returnWaypointCount, 2, "return waypoint count")
assertEqual(updateRouteCalls, 1, "single route update")
assertEqual(originalInstallCalls, 0, "cargo path bypasses original install")
assertTrue(capturedCargoTask ~= nil, "cargo task captured")
assertEqual(capturedCargoTask.id, "CargoTransportation", "cargo task id")
assertEqual(capturedCargoTask.params.groupId, 7001, "cargo task group id from explicit cargo")
assertEqual(capturedCargoTask.params.zoneId, 8002, "cargo task zone id from explicit drop zone")

-- Non-cargo missions must still delegate to the original corridor implementation.
local delegated, delegatedOk = Corridor.Install(flight, {type="PATROLZONE"}, resolved, 500)
assertTrue(delegatedOk, "non-cargo delegation")
assertEqual(delegated.mode, "ORIGINAL", "non-cargo delegated mode")
assertEqual(originalInstallCalls, 1, "original install call count")

OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR = oldCorridor
AUFTRAG = oldAuftrag
SCHEDULER = oldScheduler

print("PASS test_slingload_corridor_handoff")
