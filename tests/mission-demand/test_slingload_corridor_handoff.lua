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
local pauseMissionCalls = 0
local activeTask = { id=91, description="MOOSE CARGOTRANSPORT mission task" }
local mission = nil
local flight = {
  GetWaypointCurrentUID=function() return 10 end,
  GetTaskCurrent=function() return activeTask end,
  GetMissionCurrent=function() return mission end,
  PauseMission=function()
    pauseMissionCalls=pauseMissionCalls+1
    -- Deliberately leave activeTask set. Real MOOSE PauseMission() cancels the
    -- waypoint task through TaskCancel; the task becomes non-current only after
    -- TaskDone. The handoff must therefore wait and must not call UpdateRoute yet.
  end,
  AddWaypoint=function(self, coordinate, speed, afterUid, altitude, updateRoute)
    assertEqual(updateRoute, false, "waypoint deferred route update")
    nextUid=nextUid+1
    return { uid=nextUid, coordinate=coordinate, afterUid=afterUid, altitude=altitude }
  end,
  AddTaskWaypoint=function(self, task, waypoint, description, prio)
    capturedCargoTask=task
    return { task=task, waypoint=waypoint, description=description, prio=prio }
  end,
  UpdateRoute=function()
    if activeTask then error("regression: MOOSE would deny UpdateRoute while taskcurrent > 0") end
    updateRouteCalls=updateRouteCalls+1
  end,
  I=function() end,
  E=function() end,
}

local cargo = {
  IsAlive=function() return true end,
  IsInZone=function() return false end,
  GetID=function() return 7001 end,
}
local dropZone = { ZoneID=8002 }
mission = {
  type=AUFTRAG.Type.CARGOTRANSPORT,
  -- Deliberately remove the constructor-time MOOSE task references. Build 1-16
  -- proved they are not a safe post-pickup dependency.
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
local explicitReferences = {
  cargo=cargo,
  dropZone=dropZone,
}

-- Build 1-17 regression gap: the old test allowed UpdateRoute unconditionally.
-- Pinned MOOSE FLIGHTGROUP:onbeforeUpdateRoute rejects ordinary route updates while
-- a non-allowlisted task is current. CARGOTRANSPORT is such a task. Test the detailed
-- handoff API directly so the shared Corridor.Install retry translation cannot hide it.
local installed, ok, reason = Handoff.Install(flight, mission, resolved, 500, explicitReferences)
assertEqual(installed, nil, "pause-request install result")
assertEqual(ok, false, "pause-request install status")
assertEqual(reason, "CARGOTRANSPORT_PAUSE_REQUESTED", "pause-request reason")
assertEqual(pauseMissionCalls, 1, "pause requested exactly once")
assertEqual(updateRouteCalls, 0, "no route update while cargo task current")

-- A retry before MOOSE TaskDone must continue waiting and must not request another pause.
installed, ok, reason = Handoff.Install(flight, mission, resolved, 500, explicitReferences)
assertEqual(installed, nil, "task-still-active install result")
assertEqual(ok, false, "task-still-active install status")
assertEqual(reason, "CARGOTRANSPORT_TASK_STILL_EXECUTING", "task-still-active reason")
assertEqual(pauseMissionCalls, 1, "pause not repeated")
assertEqual(updateRouteCalls, 0, "still no route update while task current")

-- The shared corridor wrapper must map the temporary MOOSE task-release state onto the
-- existing bounded MISSION_ROUTE_UIDS_NOT_READY retry contract used by Stage 3 callers.
local wrapperResult, wrapperOk, wrapperReason = Corridor.Install(flight, mission, resolved, 500, explicitReferences)
assertEqual(wrapperResult, nil, "wrapper waiting result")
assertEqual(wrapperOk, false, "wrapper waiting status")
assertEqual(wrapperReason, "MISSION_ROUTE_UIDS_NOT_READY", "wrapper retry reason")
assertEqual(pauseMissionCalls, 1, "wrapper does not repeat pause")
assertEqual(updateRouteCalls, 0, "wrapper does not update active task route")

-- Simulate the public MOOSE PauseMission -> TaskCancel -> TaskDone lifecycle reaching
-- the state that FLIGHTGROUP:onbeforeUpdateRoute requires: no current task.
activeTask = nil
installed, ok, reason = Handoff.Install(flight, mission, resolved, 500, explicitReferences)

assertTrue(ok, "explicit-reference handoff after MOOSE task release")
assertEqual(reason, nil, "explicit-reference handoff reason")
assertEqual(installed.mode, "APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF", "handoff mode")
assertEqual(installed.pauseMode, "MOOSE_OPSGROUP_PAUSE_MISSION", "pause mode")
assertTrue(installed.activeTaskClearedBeforeRoute, "active task cleared before route")
assertEqual(installed.referenceSource, "EXPLICIT_ACCEPTANCE_CONTEXT", "reference source")
assertEqual(installed.outboundWaypointCount, 2, "outbound waypoint count")
assertEqual(installed.returnWaypointCount, 2, "return waypoint count")
assertEqual(updateRouteCalls, 1, "single route update after task release")
assertEqual(originalInstallCalls, 0, "cargo path bypasses original install")
assertTrue(capturedCargoTask ~= nil, "cargo task captured")
assertEqual(capturedCargoTask.id, "CargoTransportation", "cargo task id")
assertEqual(capturedCargoTask.params.groupId, 7001, "cargo task group id from explicit cargo")
assertEqual(capturedCargoTask.params.zoneId, 8002, "cargo task zone id from explicit drop zone")

-- A repeated install returns the cached result and must not alter route/task state.
local cached, cachedOk, cachedReason = Handoff.Install(flight, mission, resolved, 500, explicitReferences)
assertTrue(cachedOk, "cached handoff")
assertEqual(cachedReason, "ALREADY_INSTALLED", "cached handoff reason")
assertEqual(cached, installed, "cached result identity")
assertEqual(updateRouteCalls, 1, "cached handoff does not update route again")

-- Non-cargo missions must still delegate to the original corridor implementation.
local delegated, delegatedOk = Corridor.Install(flight, {type="PATROLZONE"}, resolved, 500)
assertTrue(delegatedOk, "non-cargo delegation")
assertEqual(delegated.mode, "ORIGINAL", "non-cargo delegated mode")
assertEqual(originalInstallCalls, 1, "original install call count")

OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR = oldCorridor
AUFTRAG = oldAuftrag
SCHEDULER = oldScheduler

print("PASS test_slingload_corridor_handoff")
