local TEST_ID = "AAR-PRODUCTION-INTEGRATION-3R1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local STATUS_INTERVAL_SEC = 10
local TRANSIT_OBSERVATION_SEC = 60
local MIN_TRACK_PROGRESS_NM = 2
local TIMEOUT_SEC = 420
local FUEL_TOLERANCE_PCT = 1.5

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message))
end

local function normalizeCallsign(value)
  if type(value) ~= "string" then
    return nil
  end
  return value:gsub("[%s%-]", "")
end

local function getTrackDistanceNm(runtime)
  if not runtime or not runtime.flightGroup or not runtime.trackCoord then
    return nil
  end
  local coordinate = runtime.flightGroup:GetCoordinate()
  if not coordinate then
    return nil
  end
  local distanceM = coordinate:Get2DDistance(runtime.trackCoord)
  if type(distanceM) ~= "number" then
    return nil
  end
  return distanceM / 1852
end

local function getSpawnedFuelPct(runtime)
  if not runtime or not runtime.group then
    return nil
  end
  local fuelFraction = runtime.group:GetFuelMin()
  if type(fuelFraction) ~= "number" or fuelFraction < 0 or fuelFraction > 1 then
    return nil
  end
  return fuelFraction * 100
end

if not OMW or not OMW.AAR then
  error(TAG .. " production AAR controller is not loaded")
end

local strategicEvents = {
  materialized = 0,
  handoffs = 0,
}

local EXPECTED_BY_ID = {}
local observations = {}
local lastMaterializedAtBySource = {}
local failed = false

local function recordFailure(message)
  failed = true
  fail(message)
end

local TestStrategicAdapter = {}

function TestStrategicAdapter:CanMaterialize(selection)
  log(string.format(
    "STRATEGIC_ALLOW demand=%s area=%s profile=%s source=%s testAdapter=true",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain
  ))
  return true
end

function TestStrategicAdapter:OnMaterialized(selection, runtime)
  strategicEvents.materialized = strategicEvents.materialized + 1

  local expected = EXPECTED_BY_ID[selection.missionDemandId]
  if not expected then
    recordFailure("unexpected materialization demand=" .. tostring(selection.missionDemandId))
    return
  end

  local timestamp = timer.getAbsTime()
  local previousTimestamp = lastMaterializedAtBySource[selection.sourceDomain]
  if previousTimestamp then
    local deltaSec = timestamp - previousTimestamp
    if deltaSec + 0.1 < OMW.AAR.GetConfig().sourceSpawnIntervalSec then
      recordFailure(string.format(
        "SOURCE_SPACING demand=%s source=%s deltaSec=%.1f requiredSec=%d",
        selection.missionDemandId,
        selection.sourceDomain,
        deltaSec,
        OMW.AAR.GetConfig().sourceSpawnIntervalSec
      ))
    else
      log(string.format(
        "SOURCE_SPACING_PASS demand=%s source=%s deltaSec=%.1f requiredSec=%d",
        selection.missionDemandId,
        selection.sourceDomain,
        deltaSec,
        OMW.AAR.GetConfig().sourceSpawnIntervalSec
      ))
    end
  end
  lastMaterializedAtBySource[selection.sourceDomain] = timestamp

  local groupName = runtime.group and runtime.group:GetName() or ""
  local templatePass = runtime.template == expected.expectedTemplate
      and groupName:sub(1, #expected.expectedTemplate) == expected.expectedTemplate
  if not templatePass then
    recordFailure(string.format(
      "TEMPLATE_IDENTITY demand=%s expectedTemplate=%s actualTemplate=%s group=%s",
      selection.missionDemandId,
      expected.expectedTemplate,
      tostring(runtime.template),
      tostring(groupName)
    ))
  else
    log(string.format(
      "TEMPLATE_IDENTITY_PASS demand=%s area=%s template=%s group=%s",
      selection.missionDemandId,
      selection.area,
      runtime.template,
      groupName
    ))
  end

  local actualCallsign = runtime.group and runtime.group:GetCallsign() or nil
  if normalizeCallsign(actualCallsign) ~= normalizeCallsign(expected.expectedCallsign) then
    recordFailure(string.format(
      "CALLSIGN_IDENTITY demand=%s area=%s expected=%s actual=%s group=%s",
      selection.missionDemandId,
      selection.area,
      expected.expectedCallsign,
      tostring(actualCallsign),
      tostring(groupName)
    ))
  else
    log(string.format(
      "CALLSIGN_IDENTITY_PASS demand=%s area=%s expected=%s actual=%s group=%s",
      selection.missionDemandId,
      selection.area,
      expected.expectedCallsign,
      tostring(actualCallsign),
      groupName
    ))
  end

  local initialTrackDistanceNm = getTrackDistanceNm(runtime)
  if not initialTrackDistanceNm then
    recordFailure("initial track distance unavailable demand=" .. selection.missionDemandId)
  end

  observations[selection.missionDemandId] = {
    materializedAt = timestamp,
    initialTrackDistanceNm = initialTrackDistanceNm,
    transitPass = false,
    fuelPass = false,
    fuelChecked = false,
  }

  log(string.format(
    "STRATEGIC_MATERIALIZED demand=%s area=%s profile=%s group=%s count=%d testAdapter=true initialTrackDistanceNm=%.2f",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    groupName,
    strategicEvents.materialized,
    initialTrackDistanceNm or -1
  ))
end

function TestStrategicAdapter:OnHandoff(selection, runtime)
  strategicEvents.handoffs = strategicEvents.handoffs + 1
  log(string.format(
    "STRATEGIC_HANDOFF demand=%s area=%s profile=%s count=%d testAdapter=true",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    strategicEvents.handoffs
  ))
end

OMW.AAR.SetStrategicAdapter(TestStrategicAdapter)

local DEMANDS = {
  {
    missionDemandId = "AAR-TEST-NELSON",
    receiverProfile = "FAST",
    operationsArea = "NORTHEAST",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "NELSON",
    expectedSource = "MANAS",
    expectedTemplate = "OMW_AAR_KC135_NELSON",
    expectedCallsign = "Texaco11",
    expectedInitialFuelPct = 96,
  },
  {
    missionDemandId = "AAR-TEST-KRUSTY",
    receiverProfile = "SLOW",
    operationsArea = "SOUTHEAST",
    supportMode = "RECOVERY",
    priority = "TEST",
    expectedArea = "KRUSTY",
    expectedSource = "AL_UDEID",
    expectedTemplate = "OMW_AAR_KC135_KRUSTY",
    expectedCallsign = "Arco21",
    expectedInitialFuelPct = 90,
  },
  {
    missionDemandId = "AAR-TEST-PATTY",
    receiverProfile = "SLOW",
    operationsArea = "EAST",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "PATTY",
    expectedSource = "MANAS",
    expectedTemplate = "OMW_AAR_KC135_PATTY",
    expectedCallsign = "Texaco21",
    expectedInitialFuelPct = 96,
  },
  {
    missionDemandId = "AAR-TEST-MILHOUSE",
    receiverProfile = "SLOW",
    operationsArea = "SOUTH_CENTRAL",
    supportMode = "RECOVERY",
    priority = "TEST",
    expectedArea = "MILHOUSE",
    expectedSource = "AL_UDEID",
    expectedTemplate = "OMW_AAR_KC135_MILHOUSE",
    expectedCallsign = "Shell21",
    expectedInitialFuelPct = 90,
  },
  {
    missionDemandId = "AAR-TEST-MOE",
    receiverProfile = "FAST",
    operationsArea = "CENTRAL",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "MOE",
    expectedSource = "MANAS",
    expectedTemplate = "OMW_AAR_KC135_MOE",
    expectedCallsign = "Texaco41",
    expectedInitialFuelPct = 96,
  },
  {
    missionDemandId = "AAR-TEST-LISA",
    receiverProfile = "SLOW",
    operationsArea = "WEST",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "LISA",
    expectedSource = "MANAS",
    expectedTemplate = "OMW_AAR_KC135_LISA",
    expectedCallsign = "Texaco31",
    expectedInitialFuelPct = 96,
  },
}

local EXPECTED = {}
for _, demand in ipairs(DEMANDS) do
  EXPECTED_BY_ID[demand.missionDemandId] = demand
  local selection, reason = OMW.AAR.SelectArea(demand)
  if not selection then
    error(TAG .. " selection failed demand=" .. demand.missionDemandId .. " reason=" .. tostring(reason))
  end
  if selection.area ~= demand.expectedArea
      or selection.sourceDomain ~= demand.expectedSource
      or selection.receiverProfile ~= demand.receiverProfile then
    error(string.format(
      "%s selection mismatch demand=%s area=%s/%s source=%s/%s profile=%s/%s",
      TAG,
      demand.missionDemandId,
      tostring(selection.area),
      demand.expectedArea,
      tostring(selection.sourceDomain),
      demand.expectedSource,
      tostring(selection.receiverProfile),
      demand.receiverProfile
    ))
  end
  EXPECTED[demand.expectedArea .. ":" .. demand.receiverProfile] = demand
  log(string.format(
    "POLICY_PASS demand=%s area=%s profile=%s source=%s transit=%s template=%s callsign=%s",
    demand.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain,
    selection.transitProfile,
    demand.expectedTemplate,
    demand.expectedCallsign
  ))
end

for _, demand in ipairs(DEMANDS) do
  local result, status = OMW.AAR.SubmitDemand(demand)
  if not result then
    error(TAG .. " submit failed demand=" .. demand.missionDemandId .. " status=" .. tostring(status))
  end
  log(string.format("SUBMIT_PASS demand=%s status=%s", demand.missionDemandId, tostring(status)))
end

local startedAt = timer.getAbsTime()
local completed = false

SCHEDULER:New(nil, function()
  if completed then
    return
  end

  local activeCount = 0
  local transitPassCount = 0
  local fuelPassCount = 0

  for _, demand in pairs(EXPECTED) do
    local runtime = OMW.AAR.GetActive(demand.expectedArea, demand.receiverProfile)
    if runtime and runtime.flightGroup and runtime.flightGroup:IsAlive() then
      activeCount = activeCount + 1
      local observation = observations[demand.missionDemandId]

      if observation and not observation.fuelChecked then
        local fuelPct = getSpawnedFuelPct(runtime)
        if type(fuelPct) == "number" then
          observation.fuelChecked = true
          if math.abs(fuelPct - demand.expectedInitialFuelPct) > FUEL_TOLERANCE_PCT then
            recordFailure(string.format(
              "SEED_FUEL demand=%s expectedPct=%.1f actualPct=%.2f tolerancePct=%.1f",
              demand.missionDemandId,
              demand.expectedInitialFuelPct,
              fuelPct,
              FUEL_TOLERANCE_PCT
            ))
          else
            observation.fuelPass = true
            log(string.format(
              "SEED_FUEL_PASS demand=%s area=%s fuelPct=%.2f expectedPct=%.1f tolerancePct=%.1f",
              demand.missionDemandId,
              demand.expectedArea,
              fuelPct,
              demand.expectedInitialFuelPct,
              FUEL_TOLERANCE_PCT
            ))
          end
        end
      end

      if observation and not observation.transitPass
          and timer.getAbsTime() - observation.materializedAt >= TRANSIT_OBSERVATION_SEC then
        local currentTrackDistanceNm = getTrackDistanceNm(runtime)
        if currentTrackDistanceNm
            and observation.initialTrackDistanceNm
            and currentTrackDistanceNm <= observation.initialTrackDistanceNm - MIN_TRACK_PROGRESS_NM then
          observation.transitPass = true
          log(string.format(
            "TRANSIT_PROGRESS_PASS demand=%s area=%s profile=%s template=%s initialTrackDistanceNm=%.2f currentTrackDistanceNm=%.2f progressNm=%.2f observationSec=%d",
            demand.missionDemandId,
            demand.expectedArea,
            demand.receiverProfile,
            demand.expectedTemplate,
            observation.initialTrackDistanceNm,
            currentTrackDistanceNm,
            observation.initialTrackDistanceNm - currentTrackDistanceNm,
            TRANSIT_OBSERVATION_SEC
          ))
        elseif currentTrackDistanceNm then
          recordFailure(string.format(
            "TRANSIT_PROGRESS demand=%s area=%s initialTrackDistanceNm=%.2f currentTrackDistanceNm=%.2f requiredProgressNm=%.1f",
            demand.missionDemandId,
            demand.expectedArea,
            observation.initialTrackDistanceNm or -1,
            currentTrackDistanceNm,
            MIN_TRACK_PROGRESS_NM
          ))
          observation.transitPass = false
        end
      end

      if observation and observation.transitPass then
        transitPassCount = transitPassCount + 1
      end
      if observation and observation.fuelPass then
        fuelPassCount = fuelPassCount + 1
      end
    end
  end

  if failed then
    completed = true
    fail(string.format(
      "INTEGRATION_FAIL active=%d materialized=%d fuelPass=%d transitPass=%d",
      activeCount,
      strategicEvents.materialized,
      fuelPassCount,
      transitPassCount
    ))
    return
  end

  if strategicEvents.materialized == #DEMANDS
      and fuelPassCount == #DEMANDS
      and transitPassCount == #DEMANDS then
    completed = true
    log(string.format(
      "INTEGRATION_PASS demands=%d active=%d materialized=%d fuelPass=%d transitProgress=%d sourceSpacingSec=%d artificialFuelLow=false fullTrackArrivalRequired=false",
      #DEMANDS,
      activeCount,
      strategicEvents.materialized,
      fuelPassCount,
      transitPassCount,
      OMW.AAR.GetConfig().sourceSpawnIntervalSec
    ))
    return
  end

  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    completed = true
    fail(string.format(
      "TIMEOUT expected=%d active=%d materialized=%d fuelPass=%d transitPass=%d",
      #DEMANDS,
      activeCount,
      strategicEvents.materialized,
      fuelPassCount,
      transitPassCount
    ))
  end
end, {}, STATUS_INTERVAL_SEC, STATUS_INTERVAL_SEC)

log(string.format(
  "HARNESS_READY demands=%d sourceSpawnIntervalSec=%d transitObservationSec=%d minTrackProgressNm=%.1f timeoutSec=%d callsignNormalization=true deferredFuelRead=true artificialFuelLow=false fullTrackArrivalRequired=false",
  #DEMANDS,
  OMW.AAR.GetConfig().sourceSpawnIntervalSec,
  TRANSIT_OBSERVATION_SEC,
  MIN_TRACK_PROGRESS_NM,
  TIMEOUT_SEC
))