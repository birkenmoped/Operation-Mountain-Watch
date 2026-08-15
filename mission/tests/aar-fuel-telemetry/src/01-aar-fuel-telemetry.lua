local TEST_ID = "AAR-FUEL-TELEMETRY-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local POLL_SEC = 1
local TIMEOUT_SEC = 2 * 60 * 60

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

local config = OMW.AAR.GetConfig()
assertTrue(config.standardTrackCount == 4, "expected four STANDARD tracks")
assertTrue(config.reserveTrackCount == 2, "expected two RESERVE tracks")
assertTrue(config.firFixRadiusNm == 5, "unexpected FIR fix radius")
assertTrue(config.trackEntryRadiusNm == 5, "unexpected track-entry radius")

local liveStore = buildStore()
OMW_AAR_TEST_RuntimeIntegration.Attach({
  store = liveStore,
  campaignState = OMW_AAR_TEST_CampaignState,
  adapterModule = OMW_AAR_TEST_Adapter,
  controller = OMW.AAR,
  restored = false,
})

for _, spec in ipairs(AREAS) do
  if spec.reserve then
    local demand = makeReserveDemand(spec.area)
    local _, status = OMW.AAR.SubmitDemand(demand)
    assertTrue(status == "RESERVE_TRACK_QUEUED" or status == "ACTIVE_REUSED" or status == "RELIEF_INBOUND",
      spec.area .. " reserve demand failed status=" .. tostring(status))
    log(string.format("RESERVE_REQUEST area=%s status=%s", spec.area, tostring(status)))
  end
end

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
    lastCoordinate = nil,
    pathSpawnToIngressNm = 0,
    pathIngressToTrackNm = 0,
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

local function allComplete()
  for _, spec in ipairs(AREAS) do
    local record = records[spec.area]
    if not record.spawn or not record.ingress or not record.track then return false end
  end
  return true
end

local function logFinalSummary()
  log("SUMMARY_BEGIN")
  for _, spec in ipairs(AREAS) do
    local record = records[spec.area]
    local runtime = OMW.AAR.GetActive(spec.area, spec.profile)
    local plannedFirToTrackNm = runtime and runtime.firToTrackNm or -1
    log(string.format(
      "SUMMARY area=%s profile=%s source=%s runtime=%s spawnFuelPct=%.4f ingressFuelPct=%.4f trackFuelPct=%.4f burnSpawnIngressPct=%.4f burnIngressTrackPct=%.4f burnSpawnTrackPct=%.4f pathSpawnIngressNm=%.3f pathIngressTrackNm=%.3f plannedFirTrackNm=%.3f timeSpawnIngressSec=%.3f timeIngressTrackSec=%.3f",
      spec.area,
      spec.profile,
      spec.source,
      tostring(record.runtimeId),
      record.spawn.fuelPct,
      record.ingress.fuelPct,
      record.track.fuelPct,
      record.spawn.fuelPct - record.ingress.fuelPct,
      record.ingress.fuelPct - record.track.fuelPct,
      record.spawn.fuelPct - record.track.fuelPct,
      record.pathSpawnToIngressNm,
      record.pathIngressToTrackNm,
      plannedFirToTrackNm,
      record.ingress.time - record.spawn.time,
      record.track.time - record.ingress.time
    ))
  end
  log("SUMMARY_END")
  log("RESULT PASS allTracks=6 samplesPerTrack=3 points=SPAWN,INGRESS,TRACK fuelLowExcluded=true")
end

SCHEDULER:New(nil, function()
  if complete then return end
  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    fail("TIMEOUT waiting for six tanker telemetry records")
  end

  for _, spec in ipairs(AREAS) do
    local record = records[spec.area]
    local runtime = OMW.AAR.GetActive(spec.area, spec.profile)

    if runtime and not runtime.egressOrdered and not runtime.lossHandled then
      if not record.runtimeId then
        record.runtimeId = runtime.runtimeId
      elseif record.runtimeId ~= runtime.runtimeId and not record.track then
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
  "START pollSec=%d timeoutSec=%d tracks=6 standard=4 reserve=2 fuelPoints=SPAWN,INGRESS,TRACK fuelLowExcluded=true mooseCommit=%s mooseSha256=%s",
  POLL_SEC,
  TIMEOUT_SEC,
  tostring(config.mooseCommit),
  tostring(config.mooseSha256)
))
