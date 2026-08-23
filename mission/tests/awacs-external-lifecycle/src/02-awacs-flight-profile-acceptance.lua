-- Operation Mountain Watch - AWACS Acceptance 2 telemetry harness.
--
-- Test-only MOOSE-first observer for the already running AWACS foundation.
-- It does not alter the production routing model except for one controlled
-- RequestEgress() after 30 minutes of observed APOC station time.
--
-- MOOSE public methods used for telemetry:
--   SCHEDULER:New
--   FLIGHTGROUP:IsAlive / GetAltitude / GetVelocity / GetHeading / GetFuelMin
--   OPSGROUP:GetGroup / GetCoordinate
--   GROUP:GetUnit
--   UNIT:GetCurrentFuelKgs / GetFuelMassMax
--   COORDINATE:GetLat / GetLon
--   UTILS.MpsToKnots / SecondsOfToday

local Acceptance2 = {}

local TAG = "[OMW][AWACS.Acceptance2]"
local SAMPLE_INTERVAL_SEC = 15
local STATION_DWELL_SEC = 30 * 60
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local state = {
  scheduler = nil,
  sequence = 0,
  stationObservedAt = nil,
  stationFuelKgStart = nil,
  stationFuelPctStart = nil,
  stationMidLogged = false,
  egressRequested = false,
  completed = false,
  lastPhase = nil,
  samples = 0,
  stationSamples = 0,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireMoose()
  if not SCHEDULER or not UTILS or not COORDINATE then
    fail("required MOOSE telemetry classes/utilities are unavailable")
  end
end

local function getFacade()
  if not OMW or not OMW.AirOps or not OMW.AirOps.AWACS then return nil end
  local facade = OMW.AirOps.AWACS
  if facade.Status ~= "RUNNING" or type(facade.GetRuntime) ~= "function"
      or type(facade.RequestEgress) ~= "function" then
    return nil
  end
  return facade
end

local function classifyPhase(runtime)
  if runtime.egressOrdered then return "EGRESS" end
  if runtime.onStationAt then return "ON_STATION" end
  if runtime.lateApproachPassed then return "AWACS_APPROACH" end
  if runtime.firIngressPassed then return "INBOUND_AFG" end
  return "INBOUND_EXTERNAL"
end

local function readTelemetry(runtime)
  local flightGroup = runtime and runtime.flightGroup or nil
  if not flightGroup or not flightGroup:IsAlive() then
    return nil, "FLIGHTGROUP_NOT_ALIVE"
  end

  local coordinate = flightGroup:GetCoordinate()
  local velocityMps = flightGroup:GetVelocity()
  local altitudeFt = flightGroup:GetAltitude()
  local headingDeg = flightGroup:GetHeading()
  local fuelPct = flightGroup:GetFuelMin()

  local group = flightGroup:GetGroup()
  local unit = group and group:GetUnit(1) or nil
  local fuelKg = nil
  local fuelMaxKg = nil
  if unit and unit:IsAlive() then
    fuelKg = unit:GetCurrentFuelKgs()
    local _, maxFuel = unit:GetFuelMassMax()
    fuelMaxKg = maxFuel
  end

  return {
    altitudeFt = altitudeFt,
    speedKt = velocityMps and UTILS.MpsToKnots(velocityMps) or nil,
    headingDeg = headingDeg,
    fuelPct = fuelPct,
    fuelKg = fuelKg,
    fuelMaxKg = fuelMaxKg,
    lat = coordinate and coordinate:GetLat() or nil,
    lon = coordinate and coordinate:GetLon() or nil,
  }
end

local function fmt(value, format, fallback)
  if type(value) ~= "number" then return fallback or "NA" end
  return string.format(format, value)
end

local function logTelemetry(runtime, phase, telemetry, simTime)
  state.sequence = state.sequence + 1
  state.samples = state.samples + 1
  if phase == "ON_STATION" then state.stationSamples = state.stationSamples + 1 end

  log(string.format(
    "TELEMETRY seq=%d runtime=%s phase=%s simSec=%.1f altFt=%s speedKt=%s headingDeg=%s fuelPct=%s fuelKg=%s fuelMaxKg=%s lat=%s lon=%s",
    state.sequence,
    tostring(runtime.runtimeId),
    phase,
    simTime,
    fmt(telemetry.altitudeFt, "%.0f"),
    fmt(telemetry.speedKt, "%.1f"),
    fmt(telemetry.headingDeg, "%.1f"),
    fmt(telemetry.fuelPct, "%.3f"),
    fmt(telemetry.fuelKg, "%.1f"),
    fmt(telemetry.fuelMaxKg, "%.1f"),
    fmt(telemetry.lat, "%.6f"),
    fmt(telemetry.lon, "%.6f")
  ))
end

local function finishIfComplete(facade, simTime)
  if not state.egressRequested or state.completed then return false end
  local runtime = facade:GetRuntime()
  if runtime ~= nil then return false end

  state.completed = true
  log(string.format(
    "AUTOMATED_CAPTURE_COMPLETE simSec=%.1f samples=%d stationSamples=%d manualRadioCheckRequired=true callsign=WIZARD frequencyMHz=357.300",
    simTime, state.samples, state.stationSamples
  ))

  if state.scheduler and type(state.scheduler.Clear) == "function" then
    state.scheduler:Clear()
  end
  return true
end

local function sample()
  if state.completed then return end

  local facade = getFacade()
  if not facade then
    log("WAITING reason=AWACS_FACADE_NOT_RUNNING")
    return
  end

  local simTime = UTILS.SecondsOfToday()
  if finishIfComplete(facade, simTime) then return end

  local runtime = facade:GetRuntime()
  if not runtime then
    log("WAITING reason=NO_ACTIVE_RUNTIME")
    return
  end

  local phase = classifyPhase(runtime)
  local telemetry, reason = readTelemetry(runtime)
  if not telemetry then
    log("SAMPLE_SKIPPED runtime=" .. tostring(runtime.runtimeId) .. " reason=" .. tostring(reason))
    return
  end

  logTelemetry(runtime, phase, telemetry, simTime)

  if phase ~= state.lastPhase then
    log(string.format("PHASE_CHANGE runtime=%s from=%s to=%s simSec=%.1f",
      tostring(runtime.runtimeId), tostring(state.lastPhase or "NONE"), phase, simTime))
    state.lastPhase = phase
  end

  if phase == "ON_STATION" then
    if not state.stationObservedAt then
      state.stationObservedAt = simTime
      state.stationFuelKgStart = telemetry.fuelKg
      state.stationFuelPctStart = telemetry.fuelPct
      log(string.format(
        "STATION_BASELINE runtime=%s simSec=%.1f fuelPct=%s fuelKg=%s manualRadioCheckRequired=true callsign=WIZARD frequencyMHz=357.300",
        tostring(runtime.runtimeId), simTime,
        fmt(telemetry.fuelPct, "%.3f"), fmt(telemetry.fuelKg, "%.1f")
      ))
    end

    local stationElapsed = simTime - state.stationObservedAt
    if stationElapsed < 0 then stationElapsed = stationElapsed + 24 * 60 * 60 end

    if not state.stationMidLogged and stationElapsed >= STATION_DWELL_SEC / 2 then
      state.stationMidLogged = true
      log(string.format(
        "STATION_MIDPOINT runtime=%s elapsedSec=%.1f fuelPct=%s fuelKg=%s altFt=%s speedKt=%s headingDeg=%s",
        tostring(runtime.runtimeId), stationElapsed,
        fmt(telemetry.fuelPct, "%.3f"), fmt(telemetry.fuelKg, "%.1f"),
        fmt(telemetry.altitudeFt, "%.0f"), fmt(telemetry.speedKt, "%.1f"), fmt(telemetry.headingDeg, "%.1f")
      ))
    end

    if not state.egressRequested and stationElapsed >= STATION_DWELL_SEC then
      local burnKg = nil
      local burnPct = nil
      if type(state.stationFuelKgStart) == "number" and type(telemetry.fuelKg) == "number" then
        burnKg = state.stationFuelKgStart - telemetry.fuelKg
      end
      if type(state.stationFuelPctStart) == "number" and type(telemetry.fuelPct) == "number" then
        burnPct = state.stationFuelPctStart - telemetry.fuelPct
      end

      log(string.format(
        "STATION_30MIN_COMPLETE runtime=%s elapsedSec=%.1f fuelBurnKg=%s fuelBurnPct=%s projectedHourlyBurnKg=%s",
        tostring(runtime.runtimeId), stationElapsed,
        fmt(burnKg, "%.1f"), fmt(burnPct, "%.3f"),
        fmt(burnKg and burnKg * 2 or nil, "%.1f")
      ))

      local ok = facade.RequestEgress("ACCEPTANCE_2_PROFILE_FUEL_EGRESS")
      if ok then
        state.egressRequested = true
        log("EGRESS_REQUESTED reason=ACCEPTANCE_2_PROFILE_FUEL_EGRESS")
      else
        fail("RequestEgress returned false after 30-minute station sample")
      end
    end
  end
end

function Acceptance2.Start()
  requireMoose()
  if state.scheduler then return Acceptance2 end

  log(string.format(
    "START test=AWACS_ACCEPTANCE_2 sampleIntervalSec=%d stationDwellSec=%d mooseCommit=%s mooseSha256=%s",
    SAMPLE_INTERVAL_SEC, STATION_DWELL_SEC, MOOSE_COMMIT, MOOSE_SHA256
  ))

  state.scheduler = SCHEDULER:New(nil, sample, {}, 1, SAMPLE_INTERVAL_SEC)
  return Acceptance2
end

Acceptance2.Start()

return Acceptance2
