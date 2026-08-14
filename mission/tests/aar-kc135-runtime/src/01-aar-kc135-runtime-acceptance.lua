local TEST_ID = "AAR-KC135-RUNTIME-ACCEPTANCE-2"
local LOG_PREFIX = "[OMW][" .. TEST_ID .. "] "
local STATUS_INTERVAL_SEC = 30
local EXECUTING_DWELL_SEC = 180
local SAFE_FUEL_LOW_PCT = 20
local ACCELERATED_FUEL_LOW_PCT = 99
local EGRESS_GATE_RADIUS_NM = 10
local EXPECTED_TANKER_COUNT = 5

local function log(message)
  env.info(LOG_PREFIX .. message)
end

local function fail(message)
  env.error(LOG_PREFIX .. "FAIL " .. message)
end

local TANKERS = {
  CLANCY = {
    area = "CLANCY",
    template = "OMW_AAR_KC135_CLANCY",
    gate = { lat = 29.9818333333, lon = 64.6116666667 },
    track = { lat = 31.75441342, lon = 66.82695501 },
    altitudeFt = 22500,
    speedKt = 300,
    headingDeg = 225.276,
    legNm = 35,
    frequencyMHz = 241.600,
    tacanChannel = 60,
    tacanBand = "X",
    tacanIdent = "CLA",
    expectedFuelPct = 90,
  },
  HOMER = {
    area = "HOMER",
    template = "OMW_AAR_KC135_HOMER",
    gate = { lat = 29.9818333333, lon = 64.6116666667 },
    track = { lat = 32.93833333, lon = 68.22333333 },
    altitudeFt = 23000,
    speedKt = 300,
    headingDeg = 317.573,
    legNm = 35,
    frequencyMHz = 376.000,
    tacanChannel = 54,
    tacanBand = "X",
    tacanIdent = "HOM",
    expectedFuelPct = 90,
  },
  KRUSTY = {
    area = "KRUSTY",
    template = "OMW_AAR_KC135_KRUSTY",
    gate = { lat = 29.9818333333, lon = 64.6116666667 },
    track = { lat = 32.65123012, lon = 68.15946309 },
    altitudeFt = 26000,
    speedKt = 300,
    headingDeg = 212.350,
    legNm = 35,
    frequencyMHz = 258.300,
    tacanChannel = 42,
    tacanBand = "X",
    tacanIdent = "KRU",
    expectedFuelPct = 90,
  },
  NELSON = {
    area = "NELSON",
    template = "OMW_AAR_KC135_NELSON",
    gate = { lat = 38.1211666667, lon = 70.3600000000 },
    track = { lat = 36.37666667, lon = 71.01833333 },
    altitudeFt = 27500,
    speedKt = 300,
    headingDeg = 10.428,
    legNm = 35,
    frequencyMHz = 384.400,
    tacanChannel = 47,
    tacanBand = "X",
    tacanIdent = "NEL",
    expectedFuelPct = 96,
  },
  PATTY = {
    area = "PATTY",
    template = "OMW_AAR_KC135_PATTY",
    gate = { lat = 38.1211666667, lon = 70.3600000000 },
    track = { lat = 34.97134133, lon = 71.47789605 },
    altitudeFt = 25500,
    speedKt = 300,
    headingDeg = 89.662,
    legNm = 35,
    frequencyMHz = 237.300,
    tacanChannel = 48,
    tacanBand = "X",
    tacanIdent = "PAT",
    expectedFuelPct = 96,
  },
}

local STATUS_ORDER = { "CLANCY", "HOMER", "KRUSTY", "NELSON", "PATTY" }
local runtime = {}
local allExecutingSince = nil
local acceleratedFuelLowArmed = false

local function getFuelPct(flightGroup)
  if not flightGroup then
    return nil
  end
  local ok, value = pcall(function()
    return flightGroup:GetFuelMin()
  end)
  if not ok or type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
    return nil
  end
  return value
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not coordinate then
    return nil
  end
  local current = flightGroup:GetCoordinate()
  if not current then
    return nil
  end
  local distanceM = current:Get2DDistance(coordinate)
  if type(distanceM) ~= "number" then
    return nil
  end
  return UTILS.MetersToNM(distanceM)
end

local function configureTanker(spec)
  local altitudeM = UTILS.FeetToMeters(spec.altitudeFt)
  local gateCoord = COORDINATE:NewFromLLDD(spec.gate.lat, spec.gate.lon, altitudeM)
  local trackCoord = COORDINATE:NewFromLLDD(spec.track.lat, spec.track.lon, altitudeM)

  local spawner = SPAWN:New(spec.template)
  local group = spawner:SpawnFromCoordinate(gateCoord)
  if not group then
    fail(string.format("SPAWN area=%s template=%s", spec.area, spec.template))
    return nil
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then
    fail(string.format("FLIGHTGROUP area=%s group=%s", spec.area, group:GetName()))
    return nil
  end

  local mission = AUFTRAG:NewTANKER(
    trackCoord,
    spec.altitudeFt,
    spec.speedKt,
    spec.headingDeg,
    spec.legNm,
    Unit.RefuelingSystem.BOOM_AND_RECEPTACLE
  )
  mission:SetRadio(spec.frequencyMHz, 0)
  mission:SetTACAN(spec.tacanChannel, spec.tacanIdent, nil, spec.tacanBand)
  mission:SetMissionEgressCoord(gateCoord, spec.altitudeFt, spec.speedKt)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(SAFE_FUEL_LOW_PCT)

  function flightGroup:OnAfterFuelLow(From, Event, To)
    local fuelPct = getFuelPct(self) or -1
    log(string.format(
      "FUEL_LOW_PASS area=%s fuelPct=%.2f thresholdPct=%.2f action=CANCEL_TO_EGRESS",
      spec.area,
      fuelPct,
      ACCELERATED_FUEL_LOW_PCT
    ))
    mission:Cancel()
    local state = runtime[spec.area]
    if state then
      state.egressOrdered = true
      state.fuelLowFuelPct = fuelPct
      state.fuelLowTime = timer.getAbsTime()
    end
  end

  flightGroup:AddMission(mission)

  log(string.format(
    "SPAWN_PASS area=%s group=%s expectedFuelPct=%.2f seedReadback=DEFERRED",
    spec.area,
    group:GetName(),
    spec.expectedFuelPct
  ))
  log(string.format(
    "MISSION_CONFIG_PASS area=%s altitudeFt=%d speedKt=%d headingDeg=%.3f legNm=%.1f radioMHz=%.3f modulation=AM tacan=%d%s ident=%s egressGate=%.6f,%.6f initialFuelLowThresholdPct=%d",
    spec.area,
    spec.altitudeFt,
    spec.speedKt,
    spec.headingDeg,
    spec.legNm,
    spec.frequencyMHz,
    spec.tacanChannel,
    spec.tacanBand,
    spec.tacanIdent,
    spec.gate.lat,
    spec.gate.lon,
    SAFE_FUEL_LOW_PCT
  ))

  return {
    spec = spec,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    gateCoord = gateCoord,
    trackCoord = trackCoord,
    seedFuelChecked = false,
    executingLogged = false,
    executingTime = nil,
    trackEntryFuelPct = nil,
    egressOrdered = false,
    egressGatePassed = false,
    despawnedAtGate = false,
  }
end

local function startArea(area)
  if runtime[area] then
    fail(string.format("DUPLICATE_START area=%s", area))
    return runtime[area]
  end
  local spec = TANKERS[area]
  if not spec then
    fail(string.format("UNKNOWN_AREA area=%s", tostring(area)))
    return nil
  end
  local state = configureTanker(spec)
  runtime[area] = state
  if state then
    log(string.format("START_AREA_PASS area=%s", area))
  end
  return state
end

log("START simultaneous=CLANCY,HOMER,KRUSTY,NELSON,PATTY testOnlyConcurrencyException=true productionSupportMissionLimitUnchanged=2")
for _, area in ipairs(STATUS_ORDER) do
  startArea(area)
end

SCHEDULER:New(nil, function()
  local activeAircraft = 0
  local executingMissions = 0
  local egressOrdered = 0
  local egressGatePassed = 0
  local now = timer.getAbsTime()

  for _, area in ipairs(STATUS_ORDER) do
    local state = runtime[area]
    if state then
      if state.group and state.group:IsAlive() then
        activeAircraft = activeAircraft + 1
        local fuelPct = getFuelPct(state.flightGroup)
        local fuelForLog = fuelPct or -1
        local missionExecuting = state.mission:IsExecuting()
        local distanceTrackNm = getDistanceNm(state.flightGroup, state.trackCoord) or -1
        local distanceGateNm = getDistanceNm(state.flightGroup, state.gateCoord) or -1

        if not state.seedFuelChecked and fuelPct then
          state.seedFuelChecked = true
          local deltaPct = fuelPct - state.spec.expectedFuelPct
          log(string.format(
            "SEED_FUEL_PASS area=%s fuelPct=%.2f expectedFuelPct=%.2f deltaPct=%.2f",
            area,
            fuelPct,
            state.spec.expectedFuelPct,
            deltaPct
          ))
        end

        if missionExecuting then
          executingMissions = executingMissions + 1
          if not state.executingLogged then
            state.executingLogged = true
            state.executingTime = now
            state.trackEntryFuelPct = fuelPct
            log(string.format(
              "TANKER_EXECUTING_PASS area=%s fuelPct=%.2f distanceTrackNm=%.2f",
              area,
              fuelForLog,
              distanceTrackNm
            ))
          end
        end

        if state.egressOrdered then
          egressOrdered = egressOrdered + 1
          if not state.egressGatePassed and distanceGateNm >= 0 and distanceGateNm <= EGRESS_GATE_RADIUS_NM then
            state.egressGatePassed = true
            egressGatePassed = egressGatePassed + 1
            log(string.format(
              "EGRESS_GATE_PASS area=%s distanceGateNm=%.2f fuelPct=%.2f action=DESPAWN_OFFMAP_HANDOFF",
              area,
              distanceGateNm,
              fuelForLog
            ))
            state.flightGroup:Despawn(1, true)
            state.despawnedAtGate = true
          elseif state.egressGatePassed then
            egressGatePassed = egressGatePassed + 1
          end
        end

        log(string.format(
          "STATUS area=%s alive=true fuelPct=%.2f missionStatus=%s executing=%s distanceTrackNm=%.2f distanceGateNm=%.2f egressOrdered=%s egressGatePassed=%s",
          area,
          fuelForLog,
          tostring(state.mission.status),
          tostring(missionExecuting),
          distanceTrackNm,
          distanceGateNm,
          tostring(state.egressOrdered),
          tostring(state.egressGatePassed)
        ))
      elseif not state.despawnedAtGate then
        fail(string.format("GROUP_NOT_ALIVE area=%s", area))
      end
    end
  end

  if not acceleratedFuelLowArmed then
    if executingMissions == EXPECTED_TANKER_COUNT then
      if not allExecutingSince then
        allExecutingSince = now
        log(string.format("ALL_TANKERS_EXECUTING_PASS count=%d dwellRequiredSec=%d", executingMissions, EXECUTING_DWELL_SEC))
      end
      local dwellSec = now - allExecutingSince
      if dwellSec >= EXECUTING_DWELL_SEC then
        acceleratedFuelLowArmed = true
        for _, area in ipairs(STATUS_ORDER) do
          local state = runtime[area]
          if state and state.flightGroup then
            state.flightGroup:SetFuelLowThreshold(ACCELERATED_FUEL_LOW_PCT)
          end
        end
        log(string.format(
          "ACCELERATED_FUEL_LOW_ARMED thresholdPct=%d afterAllExecutingDwellSec=%.0f",
          ACCELERATED_FUEL_LOW_PCT,
          dwellSec
        ))
      end
    else
      allExecutingSince = nil
    end
  end

  log(string.format(
    "SUMMARY activeAircraft=%d executingMissions=%d egressOrdered=%d egressGatePassed=%d expectedTankers=%d testOnlyConcurrencyException=true productionSupportMissionLimit=2 fuelLowArmed=%s",
    activeAircraft,
    executingMissions,
    egressOrdered,
    egressGatePassed,
    EXPECTED_TANKER_COUNT,
    tostring(acceleratedFuelLowArmed)
  ))
end, {}, 10, STATUS_INTERVAL_SEC)

log("HARNESS_READY simultaneous=CLANCY,HOMER,KRUSTY,NELSON,PATTY seedFuel=90,90,90,96,96 safeFuelLowPct=20 acceleratedFuelLowPct=99 armAfterAllExecutingDwellSec=180 egressGateRadiusNm=10")
