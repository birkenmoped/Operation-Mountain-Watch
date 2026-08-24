-- Operation Mountain Watch - E-3A speed/altitude fuel performance matrix.
--
-- Test fixture only. Spawns 15 E-3A aircraft from the existing late-activated
-- OMW_C2_E3A_WIZARD template. Every profile flies a 20 NM stabilization leg
-- followed by a 200 NM measurement leg. Geometry, routing and telemetry are
-- generated entirely in Lua; no ME markers, zones or per-profile triggers are required.

local Acceptance5 = {}

local TAG = "[OMW][AWACS.Acceptance5]"
local TEMPLATE = "OMW_C2_E3A_WIZARD"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local BASE_LAT = 30.10
local BASE_LON = 61.85
local ROUTE_HEADING_DEG = 90
local LANE_SPACING_NM = 12
local STABILIZATION_NM = 20
local MEASUREMENT_NM = 200
local STATE_INTERVAL_SEC = 10
local TELEMETRY_INTERVAL_SEC = 30
local START_GATE_NM = 1.5
local END_GATE_NM = 2.0

local ALTITUDES_FT = { 25000, 32000, 35000 }
local TARGET_IAS_KT = { 230, 250, 270, 290, 310 }

local state = {
  flights = {},
  scheduler = nil,
  startedAt = nil,
  completed = 0,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function fmt(value, pattern)
  if type(value) ~= "number" then return "NA" end
  return string.format(pattern, value)
end

local function requireMoose()
  if not SPAWN or not FLIGHTGROUP or not COORDINATE or not SCHEDULER or not UTILS then
    fail("required MOOSE classes are unavailable")
  end
  if type(UTILS.IasToTas) ~= "function" or type(UTILS.NMToMeters) ~= "function" then
    fail("required MOOSE speed/distance utilities are unavailable")
  end
end

local function cloneAtAltitude(coord, altitudeFt)
  local result = COORDINATE:NewFromVec3(coord:GetVec3())
  result:SetAltitude(UTILS.FeetToMeters(altitudeFt), true)
  return result
end

local function profileName(altitudeFt, iasKt)
  return string.format("OMW_TEST_E3_FL%d_IAS%d", math.floor(altitudeFt / 100), iasKt)
end

local function getUnit(runtime)
  if not runtime.group or not runtime.group:IsAlive() then return nil end
  return runtime.group:GetUnit(1)
end

local function getTelemetry(runtime)
  local unit = getUnit(runtime)
  local fg = runtime.flightGroup
  if not unit or not unit:IsAlive() or not fg or not fg:IsAlive() then return nil end

  local iasMps = unit:GetAirspeedIndicated()
  local tasMps = unit:GetAirspeedTrue()
  return {
    altitudeFt = fg:GetAltitude(),
    iasKt = type(iasMps) == "number" and UTILS.MpsToKnots(iasMps) or nil,
    tasKt = type(tasMps) == "number" and UTILS.MpsToKnots(tasMps) or nil,
    fuelPct = fg:GetFuelMin(),
    coordinate = fg:GetCoordinate(),
  }
end

local function addMeasurementSample(runtime, telemetry)
  runtime.sampleCount = runtime.sampleCount + 1
  runtime.sumIAS = runtime.sumIAS + (telemetry.iasKt or 0)
  runtime.sumTAS = runtime.sumTAS + (telemetry.tasKt or 0)
  runtime.sumAltitude = runtime.sumAltitude + (telemetry.altitudeFt or 0)
  if type(telemetry.iasKt) == "number" then
    local errorKt = math.abs(telemetry.iasKt - runtime.targetIASKt)
    runtime.maxIASErrorKt = math.max(runtime.maxIASErrorKt, errorKt)
    if errorKt <= 5 then runtime.samplesWithin5Kt = runtime.samplesWithin5Kt + 1 end
    if errorKt > 15 then runtime.samplesOver15Kt = runtime.samplesOver15Kt + 1 end
  end
end

local function classify(runtime)
  if runtime.sampleCount == 0 then return "NO_DATA" end
  local within5 = runtime.samplesWithin5Kt / runtime.sampleCount
  local over15 = runtime.samplesOver15Kt / runtime.sampleCount
  if within5 >= 0.90 then return "STABLE" end
  if over15 >= 0.20 then return "UNSUSTAINABLE" end
  return "MARGINAL"
end

local function beginMeasurement(runtime, telemetry, now)
  runtime.phase = "MEASURING"
  runtime.measurementStartAt = now
  runtime.measurementStartFuelPct = telemetry.fuelPct
  runtime.lastTelemetryAt = -math.huge
  log(string.format(
    "MEASUREMENT_START testId=%s targetAltFt=%d targetIASKt=%d actualAltFt=%s actualIASKt=%s actualTASKt=%s fuelPct=%s",
    runtime.testId, runtime.altitudeFt, runtime.targetIASKt,
    fmt(telemetry.altitudeFt, "%.0f"), fmt(telemetry.iasKt, "%.1f"), fmt(telemetry.tasKt, "%.1f"),
    fmt(telemetry.fuelPct, "%.3f")
  ))
end

local function finishMeasurement(runtime, telemetry, now)
  runtime.phase = "COMPLETE"
  runtime.measurementEndAt = now
  runtime.measurementEndFuelPct = telemetry.fuelPct
  state.completed = state.completed + 1

  local elapsedSec = now - runtime.measurementStartAt
  local fuelBurnPct = nil
  if type(runtime.measurementStartFuelPct) == "number" and type(runtime.measurementEndFuelPct) == "number" then
    fuelBurnPct = runtime.measurementStartFuelPct - runtime.measurementEndFuelPct
  end
  local avgIAS = runtime.sampleCount > 0 and runtime.sumIAS / runtime.sampleCount or nil
  local avgTAS = runtime.sampleCount > 0 and runtime.sumTAS / runtime.sampleCount or nil
  local avgAlt = runtime.sampleCount > 0 and runtime.sumAltitude / runtime.sampleCount or nil
  local fuelPer100Nm = type(fuelBurnPct) == "number" and fuelBurnPct / 2 or nil
  local fuelPerHour = type(fuelBurnPct) == "number" and elapsedSec > 0 and fuelBurnPct * 3600 / elapsedSec or nil

  log(string.format(
    "SUMMARY testId=%s classification=%s targetAltFt=%d targetIASKt=%d elapsedSec=%.1f samples=%d avgAltFt=%s avgIASKt=%s avgTASKt=%s maxIASErrorKt=%s fuelStartPct=%s fuelEndPct=%s fuelBurnPct=%s fuelBurnPctPer100Nm=%s fuelBurnPctPerHour=%s completed=%d/15",
    runtime.testId, classify(runtime), runtime.altitudeFt, runtime.targetIASKt, elapsedSec, runtime.sampleCount,
    fmt(avgAlt, "%.0f"), fmt(avgIAS, "%.1f"), fmt(avgTAS, "%.1f"), fmt(runtime.maxIASErrorKt, "%.1f"),
    fmt(runtime.measurementStartFuelPct, "%.3f"), fmt(runtime.measurementEndFuelPct, "%.3f"),
    fmt(fuelBurnPct, "%.3f"), fmt(fuelPer100Nm, "%.3f"), fmt(fuelPerHour, "%.3f"), state.completed
  ))

  if state.completed == 15 then
    log("ALL_COMPLETE profiles=15 stabilizationNm=20 measurementNm=200")
  end
end

local function updateRuntime(runtime, now)
  if runtime.phase == "COMPLETE" or runtime.phase == "FAILED" then return end

  local telemetry = getTelemetry(runtime)
  if not telemetry or not telemetry.coordinate then
    runtime.phase = "FAILED"
    log(string.format("FAILED testId=%s reason=AIRCRAFT_NOT_ALIVE_OR_TELEMETRY_UNAVAILABLE", runtime.testId))
    return
  end

  local distanceToMeasureStartNm = telemetry.coordinate:Get2DDistance(runtime.measurementStart) / 1852
  local distanceToMeasureEndNm = telemetry.coordinate:Get2DDistance(runtime.measurementEnd) / 1852

  if runtime.phase == "STABILIZING" and distanceToMeasureStartNm <= START_GATE_NM then
    beginMeasurement(runtime, telemetry, now)
  end

  if runtime.phase == "MEASURING" then
    if now - runtime.lastTelemetryAt >= TELEMETRY_INTERVAL_SEC then
      runtime.lastTelemetryAt = now
      addMeasurementSample(runtime, telemetry)
      log(string.format(
        "TELEMETRY testId=%s elapsedSec=%.1f targetAltFt=%d targetIASKt=%d actualAltFt=%s actualIASKt=%s actualTASKt=%s fuelPct=%s distanceToEndNm=%.1f",
        runtime.testId, now - runtime.measurementStartAt, runtime.altitudeFt, runtime.targetIASKt,
        fmt(telemetry.altitudeFt, "%.0f"), fmt(telemetry.iasKt, "%.1f"), fmt(telemetry.tasKt, "%.1f"),
        fmt(telemetry.fuelPct, "%.3f"), distanceToMeasureEndNm
      ))
    end

    if distanceToMeasureEndNm <= END_GATE_NM then
      finishMeasurement(runtime, telemetry, now)
    end
  end
end

local function monitor()
  local now = timer.getTime()
  for _, runtime in ipairs(state.flights) do
    updateRuntime(runtime, now)
  end
end

local function spawnProfile(altitudeFt, targetIASKt, laneIndex)
  local testId = profileName(altitudeFt, targetIASKt)
  local lateralNm = (laneIndex - 3) * LANE_SPACING_NM
  local lateralHeading = lateralNm >= 0 and 0 or 180
  local lateralDistance = UTILS.NMToMeters(math.abs(lateralNm))

  local base = COORDINATE:NewFromLLDD(BASE_LAT, BASE_LON)
  local laneStart = lateralDistance > 0 and base:Translate(lateralDistance, lateralHeading) or base
  laneStart = cloneAtAltitude(laneStart, altitudeFt)
  local measurementStart = cloneAtAltitude(laneStart:Translate(UTILS.NMToMeters(STABILIZATION_NM), ROUTE_HEADING_DEG), altitudeFt)
  local measurementEnd = cloneAtAltitude(measurementStart:Translate(UTILS.NMToMeters(MEASUREMENT_NM), ROUTE_HEADING_DEG), altitudeFt)

  -- FLIGHTGROUP:AddWaypoint ultimately passes DCS a route speed. Convert the requested
  -- indicated airspeed to the MOOSE TAS approximation at the test altitude first.
  local routeSpeedKt = UTILS.IasToTas(targetIASKt, UTILS.FeetToMeters(altitudeFt))

  local spawner = SPAWN:NewWithAlias(TEMPLATE, testId)
  spawner:InitHeading(ROUTE_HEADING_DEG)
  spawner:InitSpeedKnots(routeSpeedKt)
  local group = spawner:SpawnFromCoordinate(laneStart)
  if not group then fail("spawn failed testId=" .. testId) end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then fail("FLIGHTGROUP creation failed testId=" .. testId) end

  flightGroup:AddWaypoint(measurementStart, routeSpeedKt, nil, altitudeFt, false)
  flightGroup:AddWaypoint(measurementEnd, routeSpeedKt, nil, altitudeFt, true)

  local runtime = {
    testId = testId,
    altitudeFt = altitudeFt,
    targetIASKt = targetIASKt,
    routeSpeedKt = routeSpeedKt,
    group = group,
    flightGroup = flightGroup,
    measurementStart = measurementStart,
    measurementEnd = measurementEnd,
    phase = "STABILIZING",
    measurementStartAt = nil,
    measurementEndAt = nil,
    measurementStartFuelPct = nil,
    measurementEndFuelPct = nil,
    lastTelemetryAt = -math.huge,
    sampleCount = 0,
    sumIAS = 0,
    sumTAS = 0,
    sumAltitude = 0,
    maxIASErrorKt = 0,
    samplesWithin5Kt = 0,
    samplesOver15Kt = 0,
  }
  table.insert(state.flights, runtime)

  log(string.format(
    "SPAWNED testId=%s targetAltFt=%d targetIASKt=%d routeSpeedKt=%.1f stabilizationNm=%d measurementNm=%d",
    testId, altitudeFt, targetIASKt, routeSpeedKt, STABILIZATION_NM, MEASUREMENT_NM
  ))
end

function Acceptance5.Start()
  requireMoose()
  if state.scheduler then return Acceptance5 end
  if not GROUP:FindByName(TEMPLATE) then fail("template unavailable: " .. TEMPLATE) end

  state.startedAt = timer.getTime()
  for _, altitudeFt in ipairs(ALTITUDES_FT) do
    for laneIndex, targetIASKt in ipairs(TARGET_IAS_KT) do
      spawnProfile(altitudeFt, targetIASKt, laneIndex)
    end
  end

  state.scheduler = SCHEDULER:New(nil, monitor, {}, 1, STATE_INTERVAL_SEC)
  log(string.format(
    "STARTED profiles=15 template=%s baseLat=%.4f baseLon=%.4f headingDeg=%d laneSpacingNm=%d stabilizationNm=%d measurementNm=%d stateIntervalSec=%d telemetryIntervalSec=%d mooseCommit=%s mooseSha256=%s",
    TEMPLATE, BASE_LAT, BASE_LON, ROUTE_HEADING_DEG, LANE_SPACING_NM, STABILIZATION_NM, MEASUREMENT_NM,
    STATE_INTERVAL_SEC, TELEMETRY_INTERVAL_SEC, MOOSE_COMMIT, MOOSE_SHA256
  ))
  return Acceptance5
end

function Acceptance5.GetState()
  return state
end

Acceptance5.Start()
return Acceptance5
