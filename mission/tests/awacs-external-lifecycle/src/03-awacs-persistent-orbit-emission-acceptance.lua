-- Operation Mountain Watch - AWACS Acceptance 3.
-- Persistent APOC racetrack with sensor/emission service toggle and no AWACS task.
--
-- Purpose:
--   * validate that 15:30 service activation does not replace/cancel the physical orbit;
--   * validate the MOOSE SwitchEmission + radar-option path in DCS;
--   * provide manual RWR evidence before/after service activation;
--   * validate that ROSIE is only flown after an explicit egress request.
--
-- This test observes the production AWACS controller from OMW_AWACS_Foundation.lua.
-- It does not implement a parallel flight controller.

local Acceptance3 = {}

local TAG = "[OMW][AWACS.Acceptance3]"
local TEST_ID = "AWACS-PERSISTENT-ORBIT-EMISSION-ACCEPTANCE-3"
local SAMPLE_INTERVAL_SEC = 30
local CONTROLLED_EGRESS_SEC = 15 * 3600 + 40 * 60
local COMPLETE_TIMEOUT_SEC = 16 * 3600 + 10 * 60

local state = {
  started = false,
  runtime = nil,
  egressRequested = false,
  activationObserved = false,
  standbyObserved = false,
  completed = false,
  lastServiceState = nil,
  lastSensorState = nil,
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function clockSec()
  return UTILS.SecondsOfToday()
end

local function requireInitialRuntime()
  if not OMW or not OMW.AirOps or not OMW.AirOps.AWACS then
    fail("OMW.AirOps.AWACS is unavailable; load OMW_AWACS_Foundation.lua first")
  end
  if type(OMW.AirOps.AWACS.GetRuntime) ~= "function" then
    fail("OMW.AirOps.AWACS.GetRuntime() is unavailable")
  end
  local runtime = OMW.AirOps.AWACS.GetRuntime()
  if not runtime then fail("AWACS runtime is unavailable") end
  return runtime
end

local function sampleRuntime(runtime)
  local fg = runtime.flightGroup
  if not fg or not fg:IsAlive() then
    log(string.format("SAMPLE runtime=%s alive=false serviceState=%s sensorState=%s handoffComplete=%s",
      tostring(runtime.runtimeId), tostring(runtime.serviceState), tostring(runtime.sensorState), tostring(runtime.handoffComplete)))
    return
  end

  local coordinate = fg:GetCoordinate()
  local altitude = fg:GetAltitude()
  local velocity = fg:GetVelocity()
  local altitudeFt = altitude and UTILS.MetersToFeet(altitude) or -1
  local velocityKt = velocity and UTILS.MpsToKnots(velocity) or -1
  local headingDeg = fg:GetHeading() or -1
  local fuelPct = fg:GetFuelMin()
  local fuelKg = fg:GetCurrentFuelKgs()
  local fuelMaxKg = fg:GetFuelMassMax()
  local position = coordinate and coordinate:GetLLDDM() or "UNKNOWN"

  log(string.format(
    "SAMPLE runtime=%s clockSec=%.1f serviceState=%s sensorState=%s missionKind=%s physicalOnTrack=%s egressOrdered=%s handoffComplete=%s altFt=%.0f speedKt=%.1f headingDeg=%.1f fuelPct=%s fuelKg=%s fuelMaxKg=%s position=%s",
    tostring(runtime.runtimeId), clockSec(), tostring(runtime.serviceState), tostring(runtime.sensorState),
    tostring(runtime.serviceMissionKind), tostring(runtime.physicalOnTrack), tostring(runtime.egressOrdered), tostring(runtime.handoffComplete),
    altitudeFt, velocityKt, headingDeg,
    fuelPct and string.format("%.4f", fuelPct) or "nil",
    fuelKg and string.format("%.1f", fuelKg) or "nil",
    fuelMaxKg and string.format("%.1f", fuelMaxKg) or "nil",
    tostring(position)
  ))
end

local function monitor()
  if state.completed then return end

  local runtime = state.runtime
  if not runtime then fail("Acceptance 3 runtime reference is unavailable") end

  local serviceState = tostring(runtime.serviceState)
  local sensorState = tostring(runtime.sensorState)
  local localSec = clockSec()

  if state.lastServiceState ~= serviceState or state.lastSensorState ~= sensorState then
    log(string.format("STATE_CHANGE runtime=%s serviceState=%s sensorState=%s missionKind=%s",
      tostring(runtime.runtimeId), serviceState, sensorState, tostring(runtime.serviceMissionKind)))
    state.lastServiceState = serviceState
    state.lastSensorState = sensorState
  end

  if serviceState == "STANDBY" and sensorState == "SILENT" then
    state.standbyObserved = true
  end

  if serviceState == "ACTIVE" and sensorState == "EMITTING" then
    if not state.activationObserved then
      state.activationObserved = true
      log(string.format("SERVICE_ACTIVATION_OBSERVED runtime=%s missionKind=%s persistentOrbit=%s",
        tostring(runtime.runtimeId), tostring(runtime.serviceMissionKind),
        tostring(runtime.serviceMissionKind == "PERSISTENT_RACETRACK")))
    end
  end

  sampleRuntime(runtime)

  if not state.egressRequested and localSec >= CONTROLLED_EGRESS_SEC then
    if not state.standbyObserved then fail("standby SILENT state was not observed before controlled egress") end
    if not state.activationObserved then fail("ACTIVE/EMITTING state was not observed before controlled egress") end
    if runtime.serviceMissionKind ~= "PERSISTENT_RACETRACK" then
      fail("persistent racetrack mission was not retained through service activation")
    end

    local accepted = OMW.AirOps.AWACS.RequestEgress("ACCEPTANCE_3_CONTROLLED_EGRESS")
    if accepted ~= true then fail("controlled egress request was rejected") end
    state.egressRequested = true
    log(string.format("CONTROLLED_EGRESS_REQUESTED runtime=%s localSec=%.1f", tostring(runtime.runtimeId), localSec))
    return
  end

  if state.egressRequested then
    if runtime.handoffComplete == true then
      state.completed = true
      log("AUTOMATED_CAPTURE_COMPLETE result=PASS_PENDING_MANUAL_RWR_AND_NO_DETOUR_REVIEW")
      return
    end

    if runtime.egressOrdered ~= true then
      fail("egress request accepted but runtime.egressOrdered is not true")
    end
  end

  if localSec >= COMPLETE_TIMEOUT_SEC then
    fail("Acceptance 3 timed out before external handoff")
  end
end

function Acceptance3.Start()
  if state.started then return Acceptance3 end
  if not SCHEDULER or not UTILS then fail("required MOOSE SCHEDULER/UTILS classes are unavailable") end

  local runtime = requireInitialRuntime()
  state.runtime = runtime
  state.started = true

  log(string.format(
    "START testId=%s runtime=%s sampleIntervalSec=%d controlledEgressLocal=15:40 manualChecks=RWR_SILENT_BEFORE_1530,RWR_EMITTER_AFTER_1530,NO_ROSIE_DETOUR_AT_1530",
    TEST_ID, tostring(runtime.runtimeId), SAMPLE_INTERVAL_SEC
  ))

  SCHEDULER:New(nil, monitor, {}, 1, SAMPLE_INTERVAL_SEC)
  return Acceptance3
end

Acceptance3.Start()

return Acceptance3
