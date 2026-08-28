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
  configLogged = false,
  lastServiceState = nil,
  lastSensorState = nil,
  lastAarPhase = nil,
  lisaObserved = false,
  lisaReadyObserved = false,
  fallbackThresholdObserved = false,
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
  if facade.Status ~= "RUNNING" or type(facade.GetRuntime) ~= "function"
      or type(facade.GetLisaRuntime) ~= "function" then return nil end
  return facade
end

local function fmt(value, pattern)
  if type(value) ~= "number" then return "NA" end
  return string.format(pattern, value)
end

local function getIASKt(group)
  if not group or not group:IsAlive() then return nil end
  local unit = group:GetUnit(1)
  if not unit or not unit:IsAlive() then return nil end
  local iasMps = unit:GetAirspeedIndicated()
  return type(iasMps) == "number" and UTILS.MpsToKnots(iasMps) or nil
end

local function logConfig(facade)
  if state.configLogged then return end
  local config = facade.Config
  if type(config) ~= "table" and facade.Controller and type(facade.Controller.GetConfig) == "function" then
    config = facade.Controller.GetConfig()
  end
  if type(config) ~= "table" then return end

  state.configLogged = true
  log(string.format(
    "CONFIG transitAltFt=%s transitTargetKIAS=%s trackAltFt=%s trackTargetKIAS=%s lisaAltFt=%s lisaTargetKIAS=%s wizardAarRvAltFt=%s wizardAarRvTargetKIAS=%s lisaPredispatchPct=%s fallbackPct=%s criticalPct=%s finalContactSpeedDcsControlled=%s",
    tostring(config.inboundCruiseAltitudeFt), tostring(config.transitTargetIASKt),
    tostring(config.trackAltitudeFt), tostring(config.trackSpeedKIAS),
    tostring(config.lisaRendezvousAltitudeFt), tostring(config.lisaRendezvousSpeedKIAS),
    tostring(config.aarRendezvousAltitudeFt), tostring(config.aarRendezvousTargetIASKt),
    tostring(config.lisaPredispatchFuelPct), tostring(config.aarTriggerFuelPct),
    tostring(config.aarCriticalFuelPct), tostring(config.finalContactSpeedDcsControlled == true)))
end

local function sample()
  local facade = getFacade()
  if not facade then
    log("WAITING reason=AWACS_FACADE_NOT_RUNNING")
    return
  end

  logConfig(facade)

  local runtime = facade.GetRuntime()
  if not runtime or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then
    log("WAITING reason=AWACS_RUNTIME_NOT_ALIVE")
    return
  end

  state.samples = state.samples + 1
  local fg = runtime.flightGroup
  local coord = fg:GetCoordinate()
  local position = coord and coord:GetLLDDM() or "UNKNOWN"

  local fuelPct = fg:GetFuelMin()
  local altitudeFt = fg:GetAltitude()
  local tasKt = runtime.group and runtime.group:IsAlive() and runtime.group:GetVelocityKNOTS() or nil
  local iasKt = getIASKt(runtime.group)
  local headingDeg = fg:GetHeading()
  local localSec = UTILS.SecondsOfToday()

  if runtime.serviceState ~= state.lastServiceState or runtime.sensorState ~= state.lastSensorState then
    log(string.format("SERVICE_STATE runtime=%s from=%s to=%s sensorFrom=%s sensorTo=%s localSec=%.1f fuelPct=%s",
      tostring(runtime.runtimeId), tostring(state.lastServiceState), tostring(runtime.serviceState),
      tostring(state.lastSensorState), tostring(runtime.sensorState), localSec, fmt(fuelPct, "%.2f")))
    state.lastServiceState = runtime.serviceState
    state.lastSensorState = runtime.sensorState
  end

  if runtime.aarPhase ~= state.lastAarPhase then
    local lisa = facade.GetLisaRuntime()
    local lisaAltitudeFt = lisa and lisa.flightGroup and lisa.flightGroup:IsAlive() and lisa.flightGroup:GetAltitude() or nil
    local lisaIASKt = lisa and getIASKt(lisa.group) or nil
    log(string.format(
      "AAR_PHASE runtime=%s from=%s to=%s tanker=%s selectionReason=%s dedicatedLisa=%s localSec=%.1f fuelPct=%s wizardAltFt=%s wizardIASKt=%s lisaAltFt=%s lisaIASKt=%s",
      tostring(runtime.runtimeId), tostring(state.lastAarPhase), tostring(runtime.aarPhase),
      tostring(runtime.designatedTankerGroupName or "NONE"), tostring(runtime.aarSelectionReason or "NONE"),
      tostring(runtime.aarDedicatedLisa == true), localSec, fmt(fuelPct, "%.2f"),
      fmt(altitudeFt, "%.0f"), fmt(iasKt, "%.1f"), fmt(lisaAltitudeFt, "%.0f"), fmt(lisaIASKt, "%.1f")))
    state.lastAarPhase = runtime.aarPhase
  end

  local lisa = facade.GetLisaRuntime()
  if lisa and not state.lisaObserved then
    state.lisaObserved = true
    log(string.format("LISA_OBSERVED runtime=%s onStation=%s egress=%s loss=%s",
      tostring(lisa.runtimeId), tostring(lisa.onStation == true), tostring(lisa.egressOrdered == true),
      tostring(lisa.lossHandled == true)))
  end

  if lisa and lisa.onStation and not state.lisaReadyObserved then
    state.lisaReadyObserved = true
    local lisaAltitudeFt = lisa.flightGroup and lisa.flightGroup:IsAlive() and lisa.flightGroup:GetAltitude() or nil
    local lisaTASKt = lisa.group and lisa.group:IsAlive() and lisa.group:GetVelocityKNOTS() or nil
    local lisaIASKt = getIASKt(lisa.group)
    log(string.format(
      "LISA_READY_OBSERVED runtime=%s localSec=%.1f altitudeFt=%s iasKt=%s tasKt=%s egressPending=%s",
      tostring(lisa.runtimeId), localSec, fmt(lisaAltitudeFt, "%.0f"), fmt(lisaIASKt, "%.1f"),
      fmt(lisaTASKt, "%.1f"), tostring(lisa.egressPending == true)))
  end

  if type(fuelPct) == "number" and fuelPct <= 40 then state.fallbackThresholdObserved = true end
  if runtime.aarCompletedAt then state.refuelObserved = true end
  if runtime.egressOrdered then state.egressObserved = true end
  if runtime.handoffComplete then state.handoffObserved = true end

  log(string.format(
    "TELEMETRY seq=%d runtime=%s localSec=%.1f serviceState=%s sensorState=%s aarPhase=%s tanker=%s altFt=%s iasKt=%s tasKt=%s headingDeg=%s fuelPct=%s position=%s egress=%s",
    state.samples,
    tostring(runtime.runtimeId),
    localSec,
    tostring(runtime.serviceState),
    tostring(runtime.sensorState),
    tostring(runtime.aarPhase or "NONE"),
    tostring(runtime.designatedTankerGroupName or "NONE"),
    fmt(altitudeFt, "%.0f"),
    fmt(iasKt, "%.1f"),
    fmt(tasKt, "%.1f"),
    fmt(headingDeg, "%.1f"),
    fmt(fuelPct, "%.2f"),
    tostring(position),
    tostring(runtime.egressOrdered == true)
  ))
end

function Acceptance4.Start()
  if not SCHEDULER or not UTILS then fail("required MOOSE scheduler/utilities unavailable") end
  if type(UTILS.MpsToKnots) ~= "function" then fail("UTILS.MpsToKnots unavailable") end
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
