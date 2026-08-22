-- Operation Mountain Watch - additive Air Tasking -> existing AAR vertical DCS acceptance harness.
--
-- Test-only scope:
--   * wait for the accepted OMW.AirOps.AAR facade to be RUNNING;
--   * attach Air Tasking without recreating/replacing the AAR base;
--   * wait for the accepted four STANDARD AAR tracks to reach a stable baseline;
--   * submit one canonical-shape MissionDemand plus AAR planning fields through the Air Tasking bridge;
--   * verify translation to the accepted AAR runtime-demand contract;
--   * verify LISA reserve materialization, stable ASR/ATM/EXE correlation and natural track arrival;
--   * close the mission only after natural on-station arrival;
--   * verify external handoff, exact-once strategic recredit and terminal Air Tasking domain state.
--
-- This harness does not alter MissionDemand state, AAR routing, fuel, relief,
-- CampaignState accounting or MOOSE internals.

local TEST_ID = "AIR-TASKING-AAR-VERTICAL-3"
local TAG = "[OMW][TEST][AirTaskingAARVertical]"
local POLL_SEC = 5
local ATTACH_POLL_SEC = 1
local TIMEOUT_SEC = 4 * 60 * 60
local DEMAND_ID = "MD-000001"
local REQUEST_ID = "ASR-000001"
local MISSION_ID = "ATM-000001"

local executionSerial = 0
local startedAt = timer.getAbsTime()
local demandSubmitted = false
local observedExecuting = false
local observedOnStation = false
local endRequested = false
local baselineAlUdeidAvailable = nil
local testScheduler = nil
local attachScheduler = nil
local vertical = nil

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " RESULT FAIL reason=" .. tostring(message))
  error(TAG .. " " .. tostring(message), 2)
end

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    fail(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function assertTrue(value, label)
  if not value then fail(label) end
end

local function nextExecutionId()
  executionSerial = executionSerial + 1
  return string.format("EXE-%06d", executionSerial)
end

if not SCHEDULER then fail("MOOSE SCHEDULER is unavailable") end
if not OMW_AIR_TASKING_TEST_Bridge then fail("Air Tasking bridge module is unavailable") end
if not OMW_AIR_TASKING_TEST_Bootstrap then fail("Air Tasking bootstrap module is unavailable") end

local function standardBaselineReady()
  local counts = vertical.AAR.GetRuntimeCounts()
  if not counts or counts.supportAircraft ~= 4 then return false end

  for _, area in ipairs({ "NELSON", "PATTY", "MILHOUSE", "KRUSTY" }) do
    local station = vertical.AAR.Controller.GetStation(area)
    local runtime = station and station.activeRuntime or nil
    if not runtime or not runtime.onStationAt or runtime.egressOrdered or runtime.lossHandled then
      return false
    end
  end
  return true
end

local function submitDemand()
  local pool = vertical.AAR.StrategicAdapter:GetPoolStatus("AL_UDEID")
  baselineAlUdeidAvailable = pool.available

  -- Canonical MissionDemand contract shape from current main. This acceptance
  -- fixture is read-only input to Air Tasking; the bridge does not own or mutate
  -- the MissionDemand lifecycle.
  local canonicalDemand = {
    id = DEMAND_ID,
    missionType = "CAS_IMMEDIATE",
    origin = "AIR_TASKING_AAR_VERTICAL_ACCEPTANCE",
    objective = "Provide AAR support to a WEST receiver package",
    target = { operationsArea = "WEST" },
    priority = 100,
    playerCapable = true,
    aiCapable = true,
    reservationState = nil,
    expiresAt = nil,
    successCriteria = { aarSupport = true },
    failureConsequences = nil,
    resourceReservation = nil,
    createdReason = "AIR_TASKING_AAR_VERTICAL_ACCEPTANCE",
    dedupeKey = "AIR_TASKING_AAR_VERTICAL|WEST|FAST",
    status = "OPEN",
    assignedTo = nil,
    result = nil,
    failureReason = nil,
  }

  local record, reason = vertical.SubmitApprovedAAR({
    requestId = REQUEST_ID,
    missionId = MISSION_ID,
    requestStatus = "APPROVED",
    requestTiming = "PREPLANNED",
    requiredEffectOrTask = "AAR_SUPPORT",
    missionDemand = canonicalDemand,
    aarDemand = {
      receiverProfile = "FAST",
      operationsArea = "WEST",
      supportMode = "SUPPORT",
    },
  })

  assertTrue(record ~= nil, "SubmitApprovedAAR rejected reason=" .. tostring(reason))
  assertEqual(record.request.request_id, REQUEST_ID, "request id")
  assertEqual(record.request.mission_demand_id, DEMAND_ID, "canonical MissionDemand id")
  assertEqual(record.mission.mission_id, MISSION_ID, "mission id")
  assertEqual(record.mission.mission_area_id, "LISA", "mission area")
  assertEqual(record.runtimeDemand.missionDemandId, DEMAND_ID, "runtime MissionDemand correlation")
  assertEqual(record.runtimeDemand.receiverProfile, "FAST", "runtime receiver profile")
  assertEqual(record.runtimeDemand.operationsArea, "WEST", "runtime operations area")
  assertEqual(record.runtimeDemand.supportMode, "SUPPORT", "runtime support mode")
  assertEqual(record.runtimeDemand.priority, 100, "runtime numeric priority")
  assertEqual(record.request.status, "TASKED", "request status after submit")
  assertEqual(record.mission.status, "TASKED", "mission status after submit")

  demandSubmitted = true
  log(string.format("DEMAND_SUBMITTED demand=%s request=%s mission=%s reason=%s baselineAlUdeidAvailable=%s canonicalContract=true",
    DEMAND_ID, REQUEST_ID, MISSION_ID, tostring(reason), tostring(baselineAlUdeidAvailable)))
end

local function finalPass()
  local mission = vertical.GetMission(MISSION_ID)
  local request = vertical.GetRequest(REQUEST_ID)
  local attempts = vertical.GetExecutionAttempts(MISSION_ID)
  local snapshot = vertical.ExportSnapshot()
  local pool = vertical.AAR.StrategicAdapter:GetPoolStatus("AL_UDEID")

  assertEqual(mission.status, "COMPLETED", "terminal mission status")
  assertEqual(mission.result, "SUCCESS", "terminal mission result")
  assertEqual(request.status, "FULFILLED", "terminal request status")
  assertTrue(#attempts >= 1, "no execution attempts recorded")
  assertEqual(attempts[#attempts].status, "ENDED", "terminal execution status")
  assertEqual(attempts[#attempts].result, "HANDOFF", "terminal execution result")
  assertEqual(pool.available, baselineAlUdeidAvailable, "AL_UDEID exact-once recredit")

  for _, item in ipairs(snapshot.execution_attempts or {}) do
    if item.runtime_id ~= nil then fail("snapshot persisted runtime_id") end
  end

  log(string.format(
    "CORRELATION_PASS demand=%s request=%s mission=%s execution=%s runtimePersisted=false canonicalContract=true",
    DEMAND_ID, REQUEST_ID, MISSION_ID, tostring(attempts[#attempts].execution_attempt_id)))
  log(string.format("SETTLEMENT_PASS source=AL_UDEID available=%s", tostring(pool.available)))
  log("RESULT PASS testId=" .. TEST_ID)
  if testScheduler then testScheduler:Stop() end
end

local function pollTest()
  local elapsed = timer.getAbsTime() - startedAt
  if elapsed > TIMEOUT_SEC then fail("timeout after " .. tostring(elapsed) .. " sec") end

  if not demandSubmitted then
    if standardBaselineReady() then
      log("STANDARD_BASELINE_PASS tracks=4 aircraft=4 onStation=true")
      submitDemand()
    end
    return
  end

  local mission = vertical.GetMission(MISSION_ID)
  local request = vertical.GetRequest(REQUEST_ID)
  if not mission or not request then fail("domain record disappeared") end

  local station = vertical.AAR.Controller.GetStation("LISA", "FAST")
  local runtime = station and station.activeRuntime or nil

  if mission.status == "EXECUTING" and request.status == "EXECUTING" and not observedExecuting then
    local attempts = vertical.GetExecutionAttempts(MISSION_ID)
    assertTrue(attempts and #attempts >= 1, "EXECUTING without EXE attempt")
    assertEqual(attempts[#attempts].status, "STARTED", "execution status at materialization")
    observedExecuting = true
    log(string.format("EXECUTION_STARTED_PASS execution=%s runtime=%s area=LISA",
      tostring(attempts[#attempts].execution_attempt_id), tostring(attempts[#attempts].runtime_id)))
  end

  if runtime and runtime.onStationAt and not runtime.egressOrdered and not runtime.lossHandled and not observedOnStation then
    assertTrue(observedExecuting, "LISA reached station before execution correlation")
    observedOnStation = true
    log(string.format("NATURAL_LISA_ON_STATION_PASS runtime=%s firIngress=%s lateApproach=%s onStationAt=%s",
      tostring(runtime.runtimeId), tostring(runtime.firIngressPassed), tostring(runtime.lateApproachPassed),
      tostring(runtime.onStationAt)))
  end

  if observedOnStation and not endRequested then
    local _, reason = vertical.EndAAR(MISSION_ID, "COMPLETE")
    endRequested = true
    log("MISSION_END_REQUESTED_PASS mission=" .. MISSION_ID .. " reason=" .. tostring(reason))
    return
  end

  if endRequested and mission.status == "COMPLETED" then
    finalPass()
  end
end

local function attachWhenReady()
  local elapsed = timer.getAbsTime() - startedAt
  if elapsed > TIMEOUT_SEC then fail("timeout waiting for existing AAR base") end

  local aar = OMW and OMW.AirOps and OMW.AirOps.AAR or nil
  if not aar or aar.Status ~= "RUNNING" then return end

  vertical = OMW_AIR_TASKING_TEST_Bootstrap.Start({
    bridgeModule = OMW_AIR_TASKING_TEST_Bridge,
    aarFacade = aar,
    nextExecutionId = nextExecutionId,
    logger = function(message) env.info(message) end,
  })

  assertTrue(vertical and vertical.Status == "RUNNING", "Air Tasking facade did not attach")
  assertTrue(vertical.AAR == aar, "Air Tasking did not retain the existing AAR facade instance")
  assertEqual(vertical.Scope, "AIR_TASKING_AAR_ADDITIVE", "Air Tasking scope")
  assertEqual(vertical.AAR.Config.standardTrackCount, 4, "standardTrackCount")
  assertEqual(vertical.AAR.Config.reserveTrackCount, 2, "reserveTrackCount")
  assertEqual(vertical.AAR.Config.availabilityByArea.LISA, "RESERVE", "LISA availability")
  assertEqual(vertical.AAR.Config.sourceDomainByArea.LISA, "AL_UDEID", "LISA source")
  assertEqual(vertical.AAR.Config.firFixByArea.LISA, "DAVER", "LISA FIR fix")

  log("EXISTING_AAR_ATTACH_PASS sameFacade=true adapterRecreated=false adapterMutated=false testId=" .. TEST_ID)
  if attachScheduler then attachScheduler:Stop() end
  testScheduler = SCHEDULER:New(nil, pollTest, {}, POLL_SEC, POLL_SEC)
end

log("WAITING_FOR_EXISTING_AAR_BASE testId=" .. TEST_ID)
attachScheduler = SCHEDULER:New(nil, attachWhenReady, {}, 0, ATTACH_POLL_SEC)
