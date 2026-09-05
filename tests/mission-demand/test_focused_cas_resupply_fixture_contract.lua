local function assertContains(source, marker, label)
  if not string.find(source, marker, 1, true) then
    error(label .. " missing marker: " .. marker)
  end
end

local function assertNotContains(source, marker, label)
  if string.find(source, marker, 1, true) then
    error(label .. " contains forbidden marker: " .. marker)
  end
end

local fixturePath = "mission/tests/stage3-cas-resupply-focused/src/01-stage3-cas-resupply-focused-acceptance.lua"
local fixtureHandle = assert(io.open(fixturePath, "rb"))
local source = fixtureHandle:read("*a")
fixtureHandle:close()

local handoffPath = "scripts/air-operations/OMW_SlingloadCorridorHandoff.lua"
local handoffHandle = assert(io.open(handoffPath, "rb"))
local handoffSource = handoffHandle:read("*a")
handoffHandle:close()

-- Rejected 2026-09-05 fixture used one global state.failed and a false numeric
-- cargo-ID gate. Either regression can suppress otherwise valid MOOSE execution.
assertContains(source, "casFailed=false", "independent CAS state")
assertContains(source, "cargoFailed=false", "independent RESUPPLY state")
assertContains(source, "local function casFail", "CAS failure function")
assertContains(source, "local function cargoFail", "RESUPPLY failure function")
assertNotContains(source, "state.failed", "cross-subsystem failure gate")
assertNotContains(source, "cargo numeric ID unavailable", "rejected numeric cargo-ID gate")
assertNotContains(source, "type(state.cargo:GetID())~=\"number\"", "numeric cargo-ID requirement")

-- Preserve the DCS-proven MOOSE engagement configuration while NewCAS owns the CAS
-- task and OMW owns the explicit route geometry. The successful CAS path is frozen for
-- the slingload lifecycle diagnostic run.
assertContains(source, "SetMissionIngressCoord", "explicit CAS ingress")
assertContains(source, "SetMissionEgressCoord", "explicit CAS egress")
assertContains(source, "SetMissionWaypointRandomization(0)", "CAS waypoint randomization")
assertContains(source, "SetEngageDetected", "MOOSE CAS EngageDetected")
assertContains(source, "SetROE(ENUMS.ROE.OpenFire)", "MOOSE CAS ROE")
assertContains(source, "SetROT(ENUMS.ROT.PassiveDefense)", "MOOSE CAS ROT")

-- Lifecycle diagnostics must remain observation-only. They are intended to identify
-- which MOOSE transition changes the paused CARGOTRANSPORT mission to OVER; they must
-- never become a new runtime prerequisite or completion gate.
assertContains(handoffSource, "OMW-SLINGLOAD-CORRIDOR-HANDOFF-5", "diagnostic handoff schema")
assertContains(handoffSource, "LIFECYCLE label=", "lifecycle snapshot logging")
assertContains(handoffSource, "BEFORE_PauseMission", "pre-pause snapshot")
assertContains(handoffSource, "EVENT_OnAfterPauseMission", "pause callback snapshot")
assertContains(handoffSource, "EVENT_OnAfterTaskDone", "task-done callback snapshot")
assertContains(handoffSource, "EVENT_OnAfterMissionDone", "mission-done callback snapshot")
assertContains(handoffSource, "POST_PAUSE_T+", "post-pause timeline snapshots")
assertContains(handoffSource, "DELIVERY_MONITOR_MISSION_IS_OVER", "mission-over observation")
assertContains(handoffSource, "Diagnostic-only inspection", "internal-field diagnostic boundary")
assertNotContains(handoffSource, "if missionState", "mission-state diagnostic gate")
assertNotContains(handoffSource, "if groupStatus", "group-status diagnostic gate")

print("PASS test_focused_cas_resupply_fixture_contract")
