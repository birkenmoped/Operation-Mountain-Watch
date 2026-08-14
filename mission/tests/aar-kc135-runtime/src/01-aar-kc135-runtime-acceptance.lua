local TEST_ID = "AAR-KC135-RUNTIME-ACCEPTANCE-1"
local LOG_PREFIX = "[OMW][" .. TEST_ID .. "] "

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
    testFuelLowPct = 89,
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
    testFuelLowPct = 89,
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
    testFuelLowPct = 95,
  },
}

local STATUS_ORDER = { "CLANCY", "HOMER", "NELSON" }
local runtime = {}
local startArea

local function getFuelPct(flightGroup)
  if not flightGroup then
    return nil
  end
  local ok, value = pcall(function()
    return flightGroup:GetFuelMin()
  end)
  if not ok then
    return nil
  end
  return value
end

local function configureTanker(spec)
  local gateAltitudeM = UTILS.FeetToMeters(spec.altitudeFt)
  local gateCoord = COORDINATE:NewFromLLDD(spec.gate.lat, spec.gate.lon, gateAltitudeM)
  local trackCoord = COORDINATE:NewFromLLDD(spec.track.lat, spec.track.lon, gateAltitudeM)

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
  flightGroup:SetFuelLowThreshold(spec.testFuelLowPct)

  function flightGroup:OnAfterFuelLow(From, Event, To)
    local fuelPct = getFuelPct(self) or -1
    log(string.format(
      "FUEL_LOW_PASS area=%s fuelPct=%.2f thresholdPct=%.2f action=CANCEL_TO_EGRESS",
      spec.area,
      fuelPct,
      spec.testFuelLowPct
    ))
    mission:Cancel()
    local state = runtime[spec.area]
    if state then
      state.egressOrdered = true
    end

    if spec.area == "CLANCY" and not runtime.HOMER then
      log("STAGE_TRANSITION from=CLANCY to=HOMER reason=CLANCY_FUEL_LOW")
      startArea("HOMER")
    end
  end

  flightGroup:AddMission(mission)

  local fuelPct = getFuelPct(flightGroup)
  if fuelPct then
    log(string.format(
      "SPAWN_PASS area=%s group=%s fuelPct=%.2f expectedFuelPct=%.2f deltaPct=%.2f",
      spec.area,
      group:GetName(),
      fuelPct,
      spec.expectedFuelPct,
      fuelPct - spec.expectedFuelPct
    ))
  else
    fail(string.format("FUEL_READBACK area=%s group=%s", spec.area, group:GetName()))
  end

  log(string.format(
    "MISSION_CONFIG_PASS area=%s altitudeFt=%d speedKt=%d headingDeg=%.3f legNm=%.1f radioMHz=%.3f modulation=AM tacan=%d%s ident=%s egressGate=%.6f,%.6f",
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
    spec.gate.lon
  ))

  return {
    spec = spec,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    executingLogged = false,
    egressOrdered = false,
  }
end

startArea = function(area)
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

log("START initialConcurrent=CLANCY,NELSON staged=HOMER preparedInactive=KRUSTY,PATTY maxConcurrentSupportMissions=2")

startArea("CLANCY")
startArea("NELSON")

SCHEDULER:New(nil, function()
  local activeAircraft = 0
  local executingMissions = 0
  local egressOrdered = 0
  local started = 0

  for _, area in ipairs(STATUS_ORDER) do
    local state = runtime[area]
    if state then
      started = started + 1
      if state.group and state.group:IsAlive() then
        activeAircraft = activeAircraft + 1
        local fuelPct = getFuelPct(state.flightGroup) or -1
        local missionExecuting = state.mission:IsExecuting()
        if missionExecuting then
          executingMissions = executingMissions + 1
          if not state.executingLogged then
            state.executingLogged = true
            log(string.format("TANKER_EXECUTING_PASS area=%s fuelPct=%.2f", area, fuelPct))
          end
        end
        if state.egressOrdered then
          egressOrdered = egressOrdered + 1
        end
        log(string.format(
          "STATUS area=%s alive=true fuelPct=%.2f missionStatus=%s egressOrdered=%s",
          area,
          fuelPct,
          tostring(state.mission.status),
          tostring(state.egressOrdered)
        ))
      else
        fail(string.format("GROUP_NOT_ALIVE area=%s", area))
      end
    else
      log(string.format("STATUS area=%s started=false", area))
    end
  end

  if executingMissions > 2 then
    fail(string.format("SUPPORT_CONCURRENCY executingMissions=%d limit=2", executingMissions))
  end

  log(string.format(
    "SUMMARY started=%d activeAircraft=%d executingMissions=%d egressOrdered=%d supportMissionLimit=2",
    started,
    activeAircraft,
    executingMissions,
    egressOrdered
  ))
end, {}, 10, 30)

log("HARNESS_READY initial=CLANCY,NELSON stagedAfterClancyFuelLow=HOMER expectedInitialFuel=CLANCY:90,HOMER:90,NELSON:96 acceleratedFuelLow=CLANCY:89,HOMER:89,NELSON:95")
