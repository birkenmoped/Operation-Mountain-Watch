local TEST_ID = "AAR-FUEL-TELEMETRY-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local POLL_SEC = 1
local TIMEOUT_SEC = 4 * 60 * 60

local AREAS = {
  { area = "NELSON", profile = "FAST", source = "MANAS", firFix = "EGPAN", reserve = false },
  { area = "PATTY", profile = "SLOW", source = "MANAS", firFix = "EGPAN", reserve = false },
  { area = "LISA", profile = "FAST", source = "MANAS", firFix = "PINAX", reserve = true },
  { area = "MOE", profile = "FAST", source = "MANAS", firFix = "PINAX", reserve = true },
  { area = "MILHOUSE", profile = "SLOW", source = "AL_UDEID", firFix = "DAVER", reserve = false },
  { area = "KRUSTY", profile = "SLOW", source = "AL_UDEID", firFix = "DAVER", reserve = false },
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message))
  error(TAG .. " " .. tostring(message), 2)
end

local function assertTrue(condition, message)
  if not condition then fail(message) end
end

local function buildStore()
  local created = OMW_AAR_TEST_Initializer.CreateStore(
    OMW_AAR_TEST_CampaignState,
    OMW_AAR_TEST_StrategicStock
  )
  return created.store
end

local function makeReserveDemand(area)
  if area == "LISA" then
    return {
      missionDemandId = "AAR-FUEL-TELEMETRY-LISA",
      receiverProfile = "FAST",
      operationsArea = "WEST",
      supportMode = "SUPPORT",
      priority = "FUEL_TELEMETRY",
    }
  end
  if area == "MOE" then
    return {
      missionDemandId = "AAR-FUEL-TELEMETRY-MOE",
      receiverProfile = "FAST",
      operationsArea = "CENTRAL",
      supportMode = "SUPPORT",
      priority = "FUEL_TELEMETRY",
    }
  end
  return nil
end

local function snapshot(runtime, pointName, referenceCoord)
  local unit = runtime.group and runtime.group:GetUnit(1) or nil
  assertTrue(unit ~= nil, runtime.runtimeId .. " unit unavailable at " .. pointName)

  local fuelRel = unit:GetFuel()
  assertTrue(type(fuelRel) == "number", runtime.runtimeId .. " fuel unavailable at " .. pointName)

  local fuelKg = nil
  if type(unit.GetCurrentFuelKgs) == "function" then
    fuelKg = unit:GetCurrentFuelKgs()
  end

  local maxFuelKg = nil
  if type(unit.GetFuelMassMax) == "function" then
    local _, maximum = unit:GetFuelMassMax()
    maxFuelKg = maximum
  end

  local coordinate = runtime.flightGroup:GetCoordinate()
  assertTrue(coordinate ~= nil, runtime.runtimeId .. " coordinate unavailable at " .. pointName)

  local distanceToReferenceNm = nil
  if referenceCoord then
    distanceToReferenceNm = coordinate:Get2DDistance(referenceCoord) / 1852
  end

  return {
    point = pointName,
    time = timer.getAbsTime(),
    fuelRel = fuelRel,
    fuelPct = fuelRel * 100,
    fuelKg = fuelKg,
    maxFuelKg = maxFuelKg,
    coordinate = coordinate,
    distanceToReferenceNm = distanceToReferenceNm,
  }
end

local function valueOrNA(value, format)
  if type(value) ~= "number" then return "NA" end
  return string.format(format, value)
end

local function logSnapshot(spec, runtime, sample, extra)
  log(string.format(
    "SAMPLE area=%s profile=%s source=%s runtime=%s point=%s fuelRel=%.8f fuelPct=%.4f fuelKg=%s maxFuelKg=%s time=%.3f distanceToReferenceNm=%s%s",
    spec.area,
    spec.profile,
    spec.source,
    runtime.runtimeId,
    sample.point,
    sample.fuelRel,
    sample.fuelPct,
    valueOrNA(sample.fuelKg, "%.1f"),
    valueOrNA(sample.maxFuelKg, "%.1f"),
    sample.time,
    valueOrNA(sample.distanceToReferenceNm, "%.3f"),
    extra and (" " .. extra) or ""
  ))
end

assertTrue(OMW_AAR_TEST_CampaignState ~= nil, "CampaignState test module unavailable")
assertTrue(OMW_AAR_TEST_StrategicStock ~= nil, "AAR strategic stock test module unavailable")
assertTrue(OMW_AAR_TEST_Initializer ~= nil, "CampaignState initializer test module unavailable")
assertTrue(OMW_AAR_TEST_Adapter ~= nil, "AAR CampaignState adapter test module unavailable")
assertTrue(OMW_AAR_TEST_RuntimeIntegration ~= nil, "AAR RuntimeIntegration test module unavailable")
assertTrue(OMW and OMW.AAR, "production AAR controller unavailable")
assertTrue(type(OMW.AAR.TestForceEgress) == "function", "branch-local TestForceEgress hook unavailable")

local config = OMW.AAR.GetConfig()
assertTrue(config.standardTrackCount == 4, "expected four STANDARD tracks")
assertTrue(config.reserveTrackCount == 2, "expected two RESERVE tracks")
assertTrue(config.firFixRadiusNm == 5, "unexpected FIR fix radius")
assertTrue(config.trackEntryRadiusNm == 5, "unexpected track-entry radius")
assertTrue(config.handoffRadiusNm == 10, "unexpected external handoff radius")

local startedAt = timer.getAbsTime()
local records = {}
local complete = false

for _, spec in ipairs(AREAS) do
  records[spec.area] = {
    spec = spec,
    runtimeId = nil,
    spawn = nil,
    ingress = nil,
    track = nil,
    departure = nil,
    egress = nil,
    handoff = nil,
    lastCoordinate = nil,
    pathSpawnToIngressNm = 0,
    pathIngressToTrackNm = 0,
    pathDepartureToEgressNm = 0,
    pathEgressToHandoffNm = 0,
  }
end

local function updatePath(record, coordinate)
  if record.lastCoordinate then
    local deltaNm = record.lastCoordinate:Get2DDistance(coordinate) / 1852
    if deltaNm >= 0 then
      if not record.ingress then
        record.pathSpawnToIngressNm = record.pathSpawnToIngressNm + deltaNm
      elseif not record.track then
        record.pathIngressToTrackNm = record.pathIngressToTrackNm + deltaNm
      elseif record.departure and not record.egress then
        record.pathDepartureToEgressNm = record.pathDepartureToEgressNm + deltaNm
      elseif record.egress and not record.handoff then
        record.pathEgressToHandoffNm = record.pathEgressToHandoffNm + deltaNm
      end
    end
  end
  record.lastCoordinate = coordinate
end

local function recordSpawn(record, runtime)
  local sample = snapshot(runtime, "SPAWN", runtime.spawnCoord)
  record.spawn = sample
  record.lastCoordinate = sample.coordinate
  local sampleDelaySec = sample.time - runtime.materializedAt
  logSnapshot(record.spec, runtime, sample, string.format(
    "materializedAt=%.3f sampleDelaySec=%.3f configuredInitialFuelPct=%.1f plannedSpawnToFirNm=%.3f plannedFirToTrackNm=%.3f",
    runtime.materializedAt,
    sampleDelaySec,
    runtime.initialFuelPct or -1,
    runtime.spawnToFirNm or -1,
    runtime.firToTrackNm or -1
  ))
end

local function recordIngress(record, runtime, currentCoordinate)
  local sample = snapshot(runtime, "INGRESS", runtime.firIngressCoord)
  record.ingress = sample
  record.lastCoordinate = currentCoordinate or sample.coordinate
  logSnapshot(record.spec, runtime, sample, string.format(
    "pathSpawnToIngressNm=%.3f elapsedSpawnToIngressSec=%.3f burnSpawnToIngressPct=%.4f",
    record.pathSpawnToIngressNm,
    sample.time - record.spawn.time,
    record.spawn.fuelPct - sample.fuelPct
  ))
end

local function recordTrack(record, runtime, currentCoordinate)
  local sample = snapshot(runtime, "TRACK", runtime.trackCoord)
  record.track = sample
  record.lastCoordinate = currentCoordinate or sample.coordinate
  logSnapshot(record.spec, runtime, sample, string.format(
    "pathIngressToTrackNm=%.3f elapsedIngressToTrackSec=%.3f burnIngressToTrackPct=%.4f pathSpawnToTrackNm=%.3f elapsedSpawnToTrackSec=%.3f burnSpawnToTrackPct=%.4f",
    record.pathIngressToTrackNm,
    sample.time - record.ingress.time,
    record.ingress.fuelPct - sample.fuelPct,
    record.pathSpawnToIngressNm + record.pathIngressToTrackNm,
    sample.time - record.spawn.time,
    record.spawn.fuelPct - sample.fuelPct
  ))
end

local function recordDeparture(record, runtime)
  local ordered, reason = OMW.AAR.TestForceEgress(record.spec.area, record.spec.profile, "FUEL_TELEMETRY_OUTBOUND")
  assertTrue(ordered == true, string.format("failed to order telemetry egress area=%s reason=%s",
    record.spec.area, tostring(reason)))
  local sample = snapshot(runtime, "TRACK_DEPARTURE", runtime.trackCoord)
  record.departure = sample
  record.lastCoordinate = sample.coordinate
  logSnapshot(record.spec, runtime, sample, string.format(
    "egressReason=%s elapsedTrackToDepartureSec=%.3f burnTrackToDeparturePct=%.4f",
    tostring(runtime.egressReason),
    sample.time - record.track.time,
    record.track.fuelPct - sample.fuelPct
  ))
end

local function recordEgress(record, runtime, currentCoordinate)
  local sample = snapshot(runtime, "FIR_EGRESS", runtime.firEgressCoord)
  record.egress = sample
  record.lastCoordinate = currentCoordinate or sample.coordinate
  logSnapshot(record.spec, runtime, sample, string.format(
    "fix=%s pathDepartureToEgressNm=%.3f elapsedDepartureToEgressSec=%.3f burnDepartureToEgressPct=%.4f",
    record.spec.firFix,
    record.pathDepartureToEgressNm,
    sample.time - record.departure.time,
    record.departure.fuelPct - sample.fuelPct
  ))
end

local function recordHandoff(record, runtime)
  local sample = snapshot(runtime, "EXTERNAL_HANDOFF", runtime.externalHandoffCoord)
  updatePath(record, sample.coordinate)
  record.handoff = sample
  logSnapshot(record.spec, runtime, sample, string.format(
    "pathEgressToHandoffNm=%.3f elapsedEgressToHandoffSec=%.3f burnEgressToHandoffPct=%.4f pathDepartureToHandoffNm=%.3f elapsedDepartureToHandoffSec=%.3f burnDepartureToHandoffPct=%.4f",
    record.pathEgressToHandoffNm,
    sample.time - record.egress.time,
    record.egress.fuelPct - sample.fuelPct,
    record.pathDepartureToEgressNm + record.pathEgressToHandoffNm,
    sample.time - record.departure.time,
    record.departure.fuelPct - sample.fuelPct
  ))
end

local liveStore = buildStore()
local integration = OMW_AAR_TEST_RuntimeIntegration.Attach({
  store = liveStore,
  campaignState = OMW_AAR_TEST_CampaignState,
  adapterModule = OMW_AAR_TEST_Adapter,
  controller = OMW.AAR,
  restored = false,
})

assertTrue(integration and integration.adapter, "runtime integration adapter unavailable")
local originalOnHandoff = integration.adapter.OnHandoff
assertTrue(type(originalOnHandoff) == "function", "adapter OnHandoff unavailable")
integration.adapter.OnHandoff = function(adapter, selection, runtime)
  local area = runtime and runtime.selection and runtime.selection.area or nil
  local record = area and records[area] or nil
  if record and runtime.runtimeId == record.runtimeId and record.departure and record.egress and not record.handoff then
    recordHandoff(record, runtime)
  end
  return originalOnHandoff(adapter, selection, runtime)
end

for _, spec in ipairs(AREAS) do
  if spec.reserve then
    local demand = makeReserveDemand(spec.area)
    local _, status = OMW.AAR.SubmitDemand(demand)
    assertTrue(status == "RESERVE_TRACK_QUEUED" or status == "ACTIVE_REUSED" or status == "RELIEF_INBOUND",
      spec.area .. " reserve demand failed status=" .. tostring(status))
    log(string.format("RESERVE_REQUEST area=%s status=%s", spec.area, tostring(status)))
  end
end

local function allComplete()
  for _, spec in ipairs(AREAS) do
    local record = records[spec.area]
    if not record.spawn or not record.ingress or not record.track or not record.departure or not record.egress or not record.handoff then
      return false
    end
  end
  return true
end

local function logFinalSummary()
  log("SUMMARY_BEGIN")
  for _, spec in ipairs(AREAS) do
    local record = records[spec.area]
    log(string.format(
      "SUMMARY area=%s profile=%s source=%s runtime=%s spawnFuelPct=%.4f ingressFuelPct=%.4f trackFuelPct=%.4f departureFuelPct=%.4f egressFuelPct=%.4f handoffFuelPct=%.4f burnIngressTrackPct=%.4f burnDepartureEgressPct=%.4f burnDepartureHandoffPct=%.4f pathDepartureEgressNm=%.3f pathEgressHandoffNm=%.3f pathDepartureHandoffNm=%.3f timeDepartureEgressSec=%.3f timeEgressHandoffSec=%.3f timeDepartureHandoffSec=%.3f",
      spec.area,
      spec.profile,
      spec.source,
      tostring(record.runtimeId),
      record.spawn.fuelPct,
      record.ingress.fuelPct,
      record.track.fuelPct,
      record.departure.fuelPct,
      record.egress.fuelPct,
      record.handoff.fuelPct,
      record.ingress.fuelPct - record.track.fuelPct,
      record.departure.fuelPct - record.egress.fuelPct,
      record.departure.fuelPct - record.handoff.fuelPct,
      record.pathDepartureToEgressNm,
      record.pathEgressToHandoffNm,
      record.pathDepartureToEgressNm + record.pathEgressToHandoffNm,
      record.egress.time - record.departure.time,
      record.handoff.time - record.egress.time,
      record.handoff.time - record.departure.time
    ))
  end
  log("SUMMARY_END")
  log("RESULT PASS allTracks=6 samplesPerTrack=6 points=SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF fuelLowExcluded=true")
end

SCHEDULER:New(nil, function()
  if complete then return end
  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    fail("TIMEOUT waiting for six inbound/outbound tanker telemetry records")
  end

  for _, spec in ipairs(AREAS) do
    local record = records[spec.area]
    local runtime = OMW.AAR.GetActive(spec.area, spec.profile)

    if runtime and not runtime.lossHandled then
      if not record.runtimeId then
        record.runtimeId = runtime.runtimeId
      elseif record.runtimeId ~= runtime.runtimeId then
        fail(string.format("runtime changed before telemetry completed area=%s old=%s new=%s",
          spec.area, tostring(record.runtimeId), tostring(runtime.runtimeId)))
      end

      if not record.spawn then
        recordSpawn(record, runtime)
      else
        local currentCoordinate = runtime.flightGroup:GetCoordinate()
        assertTrue(currentCoordinate ~= nil, runtime.runtimeId .. " live coordinate unavailable")
        updatePath(record, currentCoordinate)

        if not record.ingress then
          local ingressDistanceNm = currentCoordinate:Get2DDistance(runtime.firIngressCoord) / 1852
          if ingressDistanceNm <= config.firFixRadiusNm then
            recordIngress(record, runtime, currentCoordinate)
          end
        elseif not record.track then
          local trackDistanceNm = currentCoordinate:Get2DDistance(runtime.trackCoord) / 1852
          if trackDistanceNm <= config.trackEntryRadiusNm then
            recordTrack(record, runtime, currentCoordinate)
            recordDeparture(record, runtime)
          end
        elseif record.departure and not record.egress and runtime.egressOrdered then
          local egressDistanceNm = currentCoordinate:Get2DDistance(runtime.firEgressCoord) / 1852
          if runtime.firEgressPassed or egressDistanceNm <= config.firFixRadiusNm then
            recordEgress(record, runtime, currentCoordinate)
          end
        end
      end
    end
  end

  if allComplete() then
    complete = true
    logFinalSummary()
  end
end, {}, 0, POLL_SEC)

log(string.format(
  "START pollSec=%d timeoutSec=%d tracks=6 standard=4 reserve=2 fuelPoints=SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF fuelLowExcluded=true outboundForcedViaControllerHook=true mooseCommit=%s mooseSha256=%s",
  POLL_SEC,
  TIMEOUT_SEC,
  tostring(config.mooseCommit),
  tostring(config.mooseSha256)
))
