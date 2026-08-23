-- Operation Mountain Watch - AWACS full fuel-driven lifecycle acceptance.
--
-- Observer-only acceptance for the production AWACS foundation. It does not spawn,
-- route, refuel or destroy aircraft. All physical actions must originate from the
-- production AWACS/AAR runtime so the observed behavior is representative.

local Acceptance4 = {}

local TAG = "[OMW][AWACS.Acceptance4]"
local SAMPLE_INTERVAL_SEC = 30
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local state = {
  scheduler = nil,
  samples = 0,
  lastServiceState = nil,
  lastAarPhase = nil,
  lisaObserved = false,
  fuelLowObserved = false,
  refuelObserved = false,
  egressObserved = false,
  handoffObserved = false,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function getFacade()
  if not OMW or not OMW.AirOps or not OMW.AirOps.AWACS then return nil end
  local facade = OMW.AirOps.AWACS
  if facade.Status ~= "RUNNING" or type(facade.GetRuntime) ~= "function" then return nil end
  return facade
end

local function fmt(value, pattern)
  if type(value) ~= "number" then return "NA" end
  return string.format(pattern, value)
end

local function sample()
  local facade = getFacade()
  if not facade then
    log("WAITING reason=AWACS_FACADE_NOT_RUNNING")
    return
  end

  local runtime = facade.GetRuntime()
  if not runtime or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then
    log("WAITING reason=AWACS_RUNTIME_NOT_ALIVE")
    return
  end

  state.samples = state.samples + 1
  local fg = runtime.flightGroup
  local coord = fg:GetCoordinate()
  local lat, lon = nil, nil
  if coord then lat, lon = coord:GetLLDDM() end

  local fuelPct = fg:GetFuelMin()
  local altitudeFt = fg:GetAltitude()
  local velocityMps = fg:GetVelocity()
  local speedKt = velocityMps and UTILS.MpsToKnots(velocityMps) or nil
  local headingDeg = fg:GetHeading()

  if runtime.serviceState ~= state.lastServiceState then
    log(string.format("SERVICE_STATE runtime=%s from=%s to=%s fuelPct=%s",
      tostring(runtime.runtimeId), tostring(state.lastServiceState), tostring(runtime.serviceState), fmt(fuelPct, "%.2f")))
    state.lastServiceState = runtime.serviceState
  end

  if runtime.aarPhase ~= state.lastAarPhase then
    log(string.format("AAR_PHASE runtime=%s from=%s to=%s tanker=%s fuelPct=%s",
      tostring(runtime.runtimeId), tostring(state.lastAarPhase), tostring(runtime.aarPhase),
      tostring(runtime.designatedTankerGroupName or "NONE"), fmt(fuelPct, "%.2f")))
    state.lastAarPhase = runtime.aarPhase
  end

  if type(fuelPct) == "number" and fuelPct <= 40 then state.fuelLowObserved = true end
  if runtime.aarCompletedAt then state.refuelObserved = true end
  if runtime.egressOrdered then state.egressObserved = true end
  if runtime.handoffComplete then state.handoffObserved = true end
  if OMW and OMW.AirOps and OMW.AirOps.AAR then
    local counts = type(OMW.AirOps.AAR.GetRuntimeCounts) == "function" and OMW.AirOps.AAR.GetRuntimeCounts() or nil
    if counts and counts.supportAircraft and counts.supportAircraft > 4 then state.lisaObserved = true end
  end

  log(string.format(
    "TELEMETRY seq=%d runtime=%s localSec=%.1f serviceState=%s sensorState=%s aarPhase=%s tanker=%s altFt=%s speedKt=%s headingDeg=%s fuelPct=%s lat=%s lon=%s egress=%s",
    state.samples,
    tostring(runtime.runtimeId),
    UTILS.SecondsOfToday(),
    tostring(runtime.serviceState),
    tostring(runtime.sensorState),
    tostring(runtime.aarPhase or "NONE"),
    tostring(runtime.designatedTankerGroupName or "NONE"),
    fmt(altitudeFt, "%.0f"),
    fmt(speedKt, "%.1f"),
    fmt(headingDeg, "%.1f"),
    fmt(fuelPct, "%.2f"),
    fmt(lat, "%.6f"),
    fmt(lon, "%.6f"),
    tostring(runtime.egressOrdered == true)
  ))
end

function Acceptance4.Start()
  if not SCHEDULER or not UTILS then fail("required MOOSE scheduler/utilities unavailable") end
  if state.scheduler then return Acceptance4 end
  state.scheduler = SCHEDULER:New(nil, sample, {}, 1, SAMPLE_INTERVAL_SEC)
  log(string.format("STARTED sampleIntervalSec=%d mooseCommit=%s mooseSha256=%s observerOnly=true",
    SAMPLE_INTERVAL_SEC, MOOSE_COMMIT, MOOSE_SHA256))
  return Acceptance4
end

function Acceptance4.GetState()
  return state
end

Acceptance4.Start()
return Acceptance4
