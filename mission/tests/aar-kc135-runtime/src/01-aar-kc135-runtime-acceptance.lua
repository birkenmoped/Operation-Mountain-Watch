local TEST_ID = "AAR-KC135-RUNTIME-ACCEPTANCE-6"
local LOG_PREFIX = "[OMW][" .. TEST_ID .. "] "
local STATUS_INTERVAL_SEC = 15
local SAFE_FUEL_LOW_PCT = 20
local ACCELERATED_FUEL_LOW_PCT = 99
local EGRESS_GATE_RADIUS_NM = 10
local RECEIVER_TIMEOUT_SEC = 1800
local C130_OPTIONAL_TIMEOUT_SEC = 600
local RECEIVER_MISSION_RANGE_NM = 250
local POST_REFUEL_DWELL_SEC = 60
local MIN_VERTICAL_SEPARATION_FT = 3000

local function log(message)
  env.info(LOG_PREFIX .. message)
end

local function fail(message)
  env.error(LOG_PREFIX .. "FAIL " .. message)
end

local TANKERS = {
  SLOW = {
    key = "SLOW",
    profile = "A10_SLOW",
    area = "CLANCY",
    template = "OMW_AAR_KC135_CLANCY",
    gate = { lat = 28.90264890, lon = 64.61166667 },
    track = { lat = 31.75441342, lon = 66.82695501 },
    altitudeFt = 22000,
    speedKt = 220,
    headingDeg = 225.276,
    legNm = 35,
    frequencyMHz = 241.600,
    tacanChannel = 60,
    tacanBand = "Y",
    tacanIdent = "CLA",
    expectedFuelPct = 90,
    spawnDelaySec = 0,
    gateDomain = "SOUTH",
  },
  FAST = {
    key = "FAST",
    profile = "FAST_JET",
    area = "CLANCY",
    template = "OMW_AAR_KC135_PATTY",
    gate = { lat = 28.90264890, lon = 64.61166667 },
    track = { lat = 31.75441342, lon = 66.82695501 },
    altitudeFt = 25000,
    speedKt = 300,
    headingDeg = 225.276,
    legNm = 35,
    frequencyMHz = 237.300,
    tacanChannel = 48,
    tacanBand = "Y",
    tacanIdent = "TX2",
    expectedFuelPct = 96,
    spawnDelaySec = 60,
    gateDomain = "SOUTH",
  },
  HOMER = {
    key = "HOMER",
    profile = "FAST_JET",
    area = "HOMER",
    template = "OMW_AAR_KC135_HOMER",
    gate = { lat = 28.90264890, lon = 64.61166667 },
    track = { lat = 32.93833333, lon = 68.22333333 },
    altitudeFt = 23000,
    speedKt = 300,
    headingDeg = 317.573,
    legNm = 35,
    frequencyMHz = 376.000,
    tacanChannel = 54,
    tacanBand = "Y",
    tacanIdent = "HOM",
    expectedFuelPct = 90,
    spawnDelaySec = 120,
    gateDomain = "SOUTH",
  },
  KRUSTY = {
    key = "KRUSTY",
    profile = "FAST_JET",
    area = "KRUSTY",
    template = "OMW_AAR_KC135_KRUSTY",
    gate = { lat = 28.90264890, lon = 64.61166667 },
    track = { lat = 32.65123012, lon = 68.15946309 },
    altitudeFt = 26000,
    speedKt = 300,
    headingDeg = 212.350,
    legNm = 35,
    frequencyMHz = 258.300,
    tacanChannel = 42,
    tacanBand = "Y",
    tacanIdent = "KRU",
    expectedFuelPct = 90,
    spawnDelaySec = 180,
    gateDomain = "SOUTH",
  },
  NELSON = {
    key = "NELSON",
    profile = "FAST_JET",
    area = "NELSON",
    template = "OMW_AAR_KC135_NELSON",
    gate = { lat = 38.83163, lon = 70.95271 },
    track = { lat = 36.37666667, lon = 71.01833333 },
    altitudeFt = 27500,
    speedKt = 300,
    headingDeg = 10.428,
    legNm = 35,
    frequencyMHz = 384.400,
    tacanChannel = 47,
    tacanBand = "Y",
    tacanIdent = "NEL",
    expectedFuelPct = 96,
    spawnDelaySec = 0,
    gateDomain = "NORTH_EGPAN",
  },
}

local TANKER_KEYS = { "SLOW", "FAST", "HOMER", "KRUSTY", "NELSON" }
local MANDATORY_RECEIVER_KEYS = { "A10", "F15E", "F16" }
local runtime = {}
local allFiveTankersExecutingLogged = false
local mandatoryReceiversRefueledAt = nil
local acceleratedFuelLowArmed = false

local RECEIVERS = {
  A10 = {
    key = "A10",
    profile = "A10_SLOW",
    template = "TPL_AIR_US_KAF_A10C_CAS_2SHIP",
    squadronName = "SQ_US_KAF_A10C_74_EFS",
    intendedTankerKey = "SLOW",
    missionAltitudeFt = 22000,
    missionSpeedKt = 220,
  },
  F15E = {
    key = "F15E",
    profile = "FAST_JET",
    template = "TPL_AIR_US_BGRM_F15E_CAS_2SHIP",
    squadronName = "SQ_US_BGRM_F15E_335_EFS",
    intendedTankerKey = "FAST",
    missionAltitudeFt = 25000,
    missionSpeedKt = 300,
  },
  F16 = {
    key = "F16",
    profile = "FAST_JET",
    template = "TPL_AIR_US_BGRM_F16C_CAS_2SHIP",
    squadronName = "SQ_US_BGRM_F16C_121_EFS",
    intendedTankerKey = "FAST",
    missionAltitudeFt = 25000,
    missionSpeedKt = 300,
  },
}

for _, receiverSpec in pairs(RECEIVERS) do
  receiverSpec.mission = nil
  receiverSpec.flightGroup = nil
  receiverSpec.assignedAt = nil
  receiverSpec.refuelOrdered = false
  receiverSpec.refuelOrderedAt = nil
  receiverSpec.fuelBeforePct = nil
  receiverSpec.refueled = false
  receiverSpec.refueledAt = nil
  receiverSpec.fuelAfterPct = nil
  receiverSpec.proximityPass = false
end

local OPTIONAL_C130 = {
  key = "C130J",
  template = "TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP",
  intendedTankerKey = "FAST",
  spawn = { lat = 31.98000000, lon = 67.32000000 },
  altitudeFt = 25000,
  flightGroup = nil,
  group = nil,
  refuelOrdered = false,
  refuelOrderedAt = nil,
  refueled = false,
  refueledAt = nil,
  fuelBeforePct = nil,
  fuelAfterPct = nil,
  concluded = false,
}

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

local function get3DDistanceNm(sourceFlightGroup, targetFlightGroup)
  if not sourceFlightGroup or not targetFlightGroup then
    return nil
  end
  local sourceCoord = sourceFlightGroup:GetCoordinate()
  local targetCoord = targetFlightGroup:GetCoordinate()
  if not sourceCoord or not targetCoord then
    return nil
  end
  local distanceM = sourceCoord:Get3DDistance(targetCoord)
  if type(distanceM) ~= "number" then
    return nil
  end
  return UTILS.MetersToNM(distanceM)
end

local function configureTanker(spec)
  local altitudeM = UTILS.FeetToMeters(spec.altitudeFt)
  local gateCoord = COORDINATE:NewFromLLDD(spec.gate.lat, spec.gate.lon, altitudeM)
  local trackCoord = COORDINATE:NewFromLLDD(spec.track.lat, spec.track.lon, altitudeM)
  local spawnHeadingDeg = gateCoord:HeadingTo(trackCoord)

  local spawner = SPAWN:New(spec.template)
  spawner:InitHeading(spawnHeadingDeg)
  local group = spawner:SpawnFromCoordinate(gateCoord)
  if not group then
    fail(string.format("SPAWN tankerProfile=%s area=%s template=%s", spec.key, spec.area, spec.template))
    return nil
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then
    fail(string.format("FLIGHTGROUP tankerProfile=%s group=%s", spec.key, group:GetName()))
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
      "FUEL_LOW_PASS tankerProfile=%s area=%s fuelPct=%.2f thresholdPct=%d action=CANCEL_TO_EGRESS",
      spec.key,
      spec.area,
      fuelPct,
      ACCELERATED_FUEL_LOW_PCT
    ))
    mission:Cancel()
    local state = runtime[spec.key]
    if state then
      state.egressOrdered = true
    end
  end

  flightGroup:AddMission(mission)

  log(string.format(
    "TANKER_START_PASS tankerProfile=%s receiverFocus=%s area=%s gateDomain=%s group=%s gateLat=%.8f gateLon=%.8f spawnHeadingDeg=%.3f altitudeFt=%d speedKt=%d radioMHz=%.3f modulation=AM tacan=%d%s ident=%s spawnDelaySec=%d",
    spec.key,
    spec.profile,
    spec.area,
    spec.gateDomain,
    group:GetName(),
    spec.gate.lat,
    spec.gate.lon,
    spawnHeadingDeg,
    spec.altitudeFt,
    spec.speedKt,
    spec.frequencyMHz,
    spec.tacanChannel,
    spec.tacanBand,
    spec.tacanIdent,
    spec.spawnDelaySec
  ))

  return {
    spec = spec,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    gateCoord = gateCoord,
    trackCoord = trackCoord,
    spawnHeadingDeg = spawnHeadingDeg,
    executingLogged = false,
    seedFuelLogged = false,
    egressOrdered = false,
    egressGatePassed = false,
    despawnedAtGate = false,
  }
end

local function startTanker(tankerKey)
  if runtime[tankerKey] then
    return
  end
  runtime[tankerKey] = configureTanker(TANKERS[tankerKey])
end

local function scheduleTankers()
  for _, tankerKey in ipairs(TANKER_KEYS) do
    local delay = TANKERS[tankerKey].spawnDelaySec
    if delay <= 0 then
      startTanker(tankerKey)
    else
      SCHEDULER:New(nil, function()
        startTanker(tankerKey)
      end, {}, delay)
    end
  end
end

local function logReceiverProximity(receiverSpec)
  local slow = runtime.SLOW
  local fast = runtime.FAST
  if not slow or not fast then
    fail(string.format("RECEIVER_TANKER_PROXIMITY receiver=%s reason=TANKER_RUNTIME_MISSING", receiverSpec.key))
    return false
  end

  local slowDistanceNm = get3DDistanceNm(receiverSpec.flightGroup, slow.flightGroup)
  local fastDistanceNm = get3DDistanceNm(receiverSpec.flightGroup, fast.flightGroup)
  if not slowDistanceNm or not fastDistanceNm then
    fail(string.format("RECEIVER_TANKER_PROXIMITY receiver=%s reason=DISTANCE_UNAVAILABLE", receiverSpec.key))
    return false
  end

  local nearestTankerKey = slowDistanceNm <= fastDistanceNm and "SLOW" or "FAST"
  local pass = nearestTankerKey == receiverSpec.intendedTankerKey
  receiverSpec.proximityPass = pass
  log(string.format(
    "RECEIVER_TANKER_PROXIMITY_%s receiver=%s receiverProfile=%s intendedTanker=%s nearestTanker=%s slowDistanceNm=%.3f fastDistanceNm=%.3f evidence=SPATIAL_INFERENCE_NOT_DONOR_ID",
    pass and "PASS" or "FAIL",
    receiverSpec.key,
    receiverSpec.profile,
    receiverSpec.intendedTankerKey,
    nearestTankerKey,
    slowDistanceNm,
    fastDistanceNm
  ))
  return pass
end

local function addReceiverMission(receiverSpec, airwing, squadron, payload, targetTanker)
  local zoneName = "OMW_AAR_RECEIVER_" .. receiverSpec.key .. "_ZONE"
  local casZone = ZONE_RADIUS:New(zoneName, targetTanker.trackCoord:GetVec2(), UTILS.NMToMeters(20))
  local mission = AUFTRAG:NewCAS(
    casZone,
    receiverSpec.missionAltitudeFt,
    receiverSpec.missionSpeedKt,
    targetTanker.trackCoord,
    225,
    20,
    {}
  )
  mission:SetMissionRange(RECEIVER_MISSION_RANGE_NM)
  mission:SetROE(ENUMS.ROE.WeaponHold)
  mission:SetROT(ENUMS.ROT.NoReaction)
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  mission:AddRequiredPayload(payload)
  mission:SetDuration(RECEIVER_TIMEOUT_SEC)

  local previousOnAfterFlightOnMission = airwing.OnAfterFlightOnMission
  function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousOnAfterFlightOnMission then
      previousOnAfterFlightOnMission(self, From, Event, To, FlightGroup, Mission)
    end
    if Mission == mission and not receiverSpec.flightGroup then
      receiverSpec.flightGroup = FlightGroup
      receiverSpec.assignedAt = timer.getAbsTime()
      receiverSpec.fuelBeforePct = getFuelPct(FlightGroup)
      log(string.format(
        "RECEIVER_ASSIGNED_PASS receiver=%s profile=%s template=%s squadron=%s intendedTanker=%s group=%s fuelPct=%.2f",
        receiverSpec.key,
        receiverSpec.profile,
        receiverSpec.template,
        receiverSpec.squadronName,
        receiverSpec.intendedTankerKey,
        FlightGroup:GetName(),
        receiverSpec.fuelBeforePct or -1
      ))

      local previousOnAfterRefueled = FlightGroup.OnAfterRefueled
      function FlightGroup:OnAfterRefueled(RefuelFrom, RefuelEvent, RefuelTo)
        if previousOnAfterRefueled then
          previousOnAfterRefueled(self, RefuelFrom, RefuelEvent, RefuelTo)
        end
        receiverSpec.refueled = true
        receiverSpec.refueledAt = timer.getAbsTime()
        receiverSpec.fuelAfterPct = getFuelPct(self)
        log(string.format(
          "AI_BOOM_REFUELED_PASS receiver=%s profile=%s group=%s intendedTanker=%s fuelBeforePct=%.2f fuelAfterPct=%.2f",
          receiverSpec.key,
          receiverSpec.profile,
          self:GetName(),
          receiverSpec.intendedTankerKey,
          receiverSpec.fuelBeforePct or -1,
          receiverSpec.fuelAfterPct or -1
        ))
        logReceiverProximity(receiverSpec)
      end
    end
  end

  receiverSpec.mission = mission
  airwing:AddMission(mission)
  log(string.format(
    "RECEIVER_MISSION_ADDED_PASS receiver=%s profile=%s template=%s squadron=%s intendedTanker=%s missionAltitudeFt=%d missionSpeedKt=%d missionRangeNm=%d",
    receiverSpec.key,
    receiverSpec.profile,
    receiverSpec.template,
    receiverSpec.squadronName,
    receiverSpec.intendedTankerKey,
    receiverSpec.missionAltitudeFt,
    receiverSpec.missionSpeedKt,
    RECEIVER_MISSION_RANGE_NM
  ))
end

local function configureExistingReceivers()
  local bagram = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  local kandahar = OMW and OMW.AirOps and OMW.AirOps.Kandahar or nil
  if not bagram or bagram.Status ~= "RUNNING" or not kandahar or kandahar.Status ~= "RUNNING" then
    return false
  end
  if not runtime.SLOW or not runtime.FAST then
    return false
  end

  local bagramAirwing = bagram.Airwings and bagram.Airwings.USAF or nil
  local f15Squadron = bagram.Squadrons and bagram.Squadrons.F15E or nil
  local f15Payload = bagram.Payloads and bagram.Payloads.F15E and bagram.Payloads.F15E[1] or nil
  local f16Squadron = bagram.Squadrons and bagram.Squadrons.F16C or nil
  local f16Payload = bagram.Payloads and bagram.Payloads.F16C and bagram.Payloads.F16C[1] or nil
  local kandaharAirwing = kandahar.Airwings and kandahar.Airwings.Main or nil
  local a10Squadron = kandahar.Squadrons and kandahar.Squadrons.A10C or nil
  local a10Payload = kandahar.Payloads and kandahar.Payloads.A10C and kandahar.Payloads.A10C[1] or nil

  if not bagramAirwing or not f15Squadron or not f15Payload then
    fail("BAGRAM_F15E_RECEIVER_FOUNDATION_MISSING")
    return true
  end
  if not f16Squadron or not f16Payload then
    fail("BAGRAM_F16_RECEIVER_FOUNDATION_MISSING")
    return true
  end
  if not kandaharAirwing or not a10Squadron or not a10Payload then
    fail("KANDAHAR_A10_RECEIVER_FOUNDATION_MISSING")
    return true
  end

  addReceiverMission(RECEIVERS.A10, kandaharAirwing, a10Squadron, a10Payload, runtime.SLOW)
  addReceiverMission(RECEIVERS.F15E, bagramAirwing, f15Squadron, f15Payload, runtime.FAST)
  addReceiverMission(RECEIVERS.F16, bagramAirwing, f16Squadron, f16Payload, runtime.FAST)
  return true
end

local function configureOptionalC130Receiver()
  if OPTIONAL_C130.flightGroup or not runtime.FAST then
    return
  end

  local altitudeM = UTILS.FeetToMeters(OPTIONAL_C130.altitudeFt)
  local spawnCoord = COORDINATE:NewFromLLDD(OPTIONAL_C130.spawn.lat, OPTIONAL_C130.spawn.lon, altitudeM)
  local spawnHeadingDeg = spawnCoord:HeadingTo(runtime.FAST.trackCoord)
  local spawner = SPAWN:New(OPTIONAL_C130.template)
  spawner:InitHeading(spawnHeadingDeg)
  local group = spawner:SpawnFromCoordinate(spawnCoord)
  if not group then
    log("OPTIONAL_C130_AAR_RESULT status=NOT_TESTED reason=SPAWN_FAILED blocking=false")
    OPTIONAL_C130.concluded = true
    return
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then
    log("OPTIONAL_C130_AAR_RESULT status=NOT_TESTED reason=FLIGHTGROUP_FAILED blocking=false")
    OPTIONAL_C130.concluded = true
    return
  end

  OPTIONAL_C130.group = group
  OPTIONAL_C130.flightGroup = flightGroup
  OPTIONAL_C130.fuelBeforePct = getFuelPct(flightGroup)

  local previousOnAfterRefueled = flightGroup.OnAfterRefueled
  function flightGroup:OnAfterRefueled(RefuelFrom, RefuelEvent, RefuelTo)
    if previousOnAfterRefueled then
      previousOnAfterRefueled(self, RefuelFrom, RefuelEvent, RefuelTo)
    end
    OPTIONAL_C130.refueled = true
    OPTIONAL_C130.refueledAt = timer.getAbsTime()
    OPTIONAL_C130.fuelAfterPct = getFuelPct(self)
    OPTIONAL_C130.concluded = true
    log(string.format(
      "OPTIONAL_C130_AAR_PASS group=%s intendedTanker=FAST fuelBeforePct=%.2f fuelAfterPct=%.2f blocking=false",
      self:GetName(),
      OPTIONAL_C130.fuelBeforePct or -1,
      OPTIONAL_C130.fuelAfterPct or -1
    ))
  end

  log(string.format(
    "OPTIONAL_C130_SPAWN_PASS template=%s group=%s spawnLat=%.8f spawnLon=%.8f altitudeFt=%d intendedTanker=FAST blocking=false",
    OPTIONAL_C130.template,
    group:GetName(),
    OPTIONAL_C130.spawn.lat,
    OPTIONAL_C130.spawn.lon,
    OPTIONAL_C130.altitudeFt
  ))
end

local verticalSeparationFt = TANKERS.FAST.altitudeFt - TANKERS.SLOW.altitudeFt
if verticalSeparationFt < MIN_VERTICAL_SEPARATION_FT then
  error(string.format("FAST/SLOW vertical separation below minimum: %d ft", verticalSeparationFt))
end

scheduleTankers()

log(string.format(
  "START fiveTankerStressException=true tankerCount=%d sameAreaDualTanker=true area=CLANCY slowAltitudeFt=%d slowSpeedKt=%d fastAltitudeFt=%d fastSpeedKt=%d verticalSeparationFt=%d minimumVerticalSeparationFt=%d receiverMissionRangeNm=%d postRefuelDwellSec=%d optionalC130=true",
  #TANKER_KEYS,
  TANKERS.SLOW.altitudeFt,
  TANKERS.SLOW.speedKt,
  TANKERS.FAST.altitudeFt,
  TANKERS.FAST.speedKt,
  verticalSeparationFt,
  MIN_VERTICAL_SEPARATION_FT,
  RECEIVER_MISSION_RANGE_NM,
  POST_REFUEL_DWELL_SEC
))

local receiverFoundationsResolved = false
SCHEDULER:New(nil, function()
  if not receiverFoundationsResolved then
    receiverFoundationsResolved = configureExistingReceivers()
  end

  local now = timer.getAbsTime()
  local executingCount = 0
  for _, tankerKey in ipairs(TANKER_KEYS) do
    local state = runtime[tankerKey]
    if state then
      if state.group and state.group:IsAlive() then
        local fuelPct = getFuelPct(state.flightGroup)
        local distanceTrackNm = getDistanceNm(state.flightGroup, state.trackCoord) or -1
        local distanceGateNm = getDistanceNm(state.flightGroup, state.gateCoord) or -1
        if fuelPct and not state.seedFuelLogged then
          state.seedFuelLogged = true
          log(string.format(
            "SEED_FUEL_PASS tankerProfile=%s area=%s fuelPct=%.2f expectedFuelPct=%.2f",
            tankerKey,
            state.spec.area,
            fuelPct,
            state.spec.expectedFuelPct
          ))
        end
        if state.mission:IsExecuting() then
          executingCount = executingCount + 1
          if not state.executingLogged then
            state.executingLogged = true
            log(string.format(
              "TANKER_EXECUTING_PASS tankerProfile=%s area=%s fuelPct=%.2f distanceTrackNm=%.2f altitudeFt=%d speedKt=%d",
              tankerKey,
              state.spec.area,
              fuelPct or -1,
              distanceTrackNm,
              state.spec.altitudeFt,
              state.spec.speedKt
            ))
          end
        end
        if state.egressOrdered and not state.egressGatePassed and distanceGateNm >= 0 and distanceGateNm <= EGRESS_GATE_RADIUS_NM then
          state.egressGatePassed = true
          log(string.format(
            "EGRESS_GATE_PASS tankerProfile=%s area=%s distanceGateNm=%.2f fuelPct=%.2f action=DESPAWN_OFFMAP_HANDOFF",
            tankerKey,
            state.spec.area,
            distanceGateNm,
            fuelPct or -1
          ))
          state.flightGroup:Despawn(1, true)
          state.despawnedAtGate = true
        end
      elseif not state.despawnedAtGate then
        fail(string.format("GROUP_NOT_ALIVE tankerProfile=%s", tankerKey))
      end
    end
  end

  local allFiveTankersExecuting = executingCount == #TANKER_KEYS
  if allFiveTankersExecuting and not allFiveTankersExecutingLogged then
    allFiveTankersExecutingLogged = true
    log(string.format(
      "FIVE_TANKER_EXECUTING_PASS count=%d sameAreaDualTanker=true separationFt=%d slowAltitudeFt=%d fastAltitudeFt=%d",
      executingCount,
      verticalSeparationFt,
      TANKERS.SLOW.altitudeFt,
      TANKERS.FAST.altitudeFt
    ))
    configureOptionalC130Receiver()
  end

  if allFiveTankersExecuting then
    for _, receiverKey in ipairs(MANDATORY_RECEIVER_KEYS) do
      local receiverSpec = RECEIVERS[receiverKey]
      local targetTanker = runtime[receiverSpec.intendedTankerKey]
      if receiverSpec.flightGroup and not receiverSpec.refuelOrdered and receiverSpec.flightGroup:IsAirborne() then
        receiverSpec.fuelBeforePct = getFuelPct(receiverSpec.flightGroup) or receiverSpec.fuelBeforePct
        receiverSpec.refuelOrdered = true
        receiverSpec.refuelOrderedAt = now
        receiverSpec.flightGroup:Refuel(targetTanker.trackCoord)
        log(string.format(
          "AI_BOOM_REFUEL_ORDER_PASS receiver=%s profile=%s group=%s intendedTanker=%s targetAltitudeFt=%d fuelBeforePct=%.2f",
          receiverSpec.key,
          receiverSpec.profile,
          receiverSpec.flightGroup:GetName(),
          receiverSpec.intendedTankerKey,
          targetTanker.spec.altitudeFt,
          receiverSpec.fuelBeforePct or -1
        ))
      end
    end

    if OPTIONAL_C130.flightGroup and not OPTIONAL_C130.refuelOrdered and OPTIONAL_C130.flightGroup:IsAirborne() then
      OPTIONAL_C130.fuelBeforePct = getFuelPct(OPTIONAL_C130.flightGroup) or OPTIONAL_C130.fuelBeforePct
      OPTIONAL_C130.refuelOrdered = true
      OPTIONAL_C130.refuelOrderedAt = now
      local ok, err = pcall(function()
        OPTIONAL_C130.flightGroup:Refuel(runtime.FAST.trackCoord)
      end)
      if ok then
        log(string.format(
          "OPTIONAL_C130_REFUEL_ORDER_PASS group=%s intendedTanker=FAST fuelBeforePct=%.2f blocking=false",
          OPTIONAL_C130.flightGroup:GetName(),
          OPTIONAL_C130.fuelBeforePct or -1
        ))
      else
        OPTIONAL_C130.concluded = true
        log(string.format(
          "OPTIONAL_C130_AAR_RESULT status=NOT_CONFIRMED reason=REFUEL_ORDER_ERROR detail=%s blocking=false",
          tostring(err)
        ))
      end
    end
  end

  for _, receiverKey in ipairs(MANDATORY_RECEIVER_KEYS) do
    local receiverSpec = RECEIVERS[receiverKey]
    if receiverSpec.refuelOrdered and not receiverSpec.refueled and receiverSpec.refuelOrderedAt
      and now - receiverSpec.refuelOrderedAt > RECEIVER_TIMEOUT_SEC then
      fail(string.format("AI_BOOM_REFUEL_TIMEOUT receiver=%s group=%s", receiverSpec.key, receiverSpec.flightGroup and receiverSpec.flightGroup:GetName() or "unknown"))
      receiverSpec.refuelOrderedAt = nil
    end
  end

  if OPTIONAL_C130.refuelOrdered and not OPTIONAL_C130.refueled and not OPTIONAL_C130.concluded
    and OPTIONAL_C130.refuelOrderedAt and now - OPTIONAL_C130.refuelOrderedAt > C130_OPTIONAL_TIMEOUT_SEC then
    OPTIONAL_C130.concluded = true
    log(string.format(
      "OPTIONAL_C130_AAR_RESULT status=NOT_CONFIRMED reason=TIMEOUT timeoutSec=%d blocking=false",
      C130_OPTIONAL_TIMEOUT_SEC
    ))
  end

  local allMandatoryRefueled = true
  local latestRefueledAt = 0
  for _, receiverKey in ipairs(MANDATORY_RECEIVER_KEYS) do
    local receiverSpec = RECEIVERS[receiverKey]
    if not receiverSpec.refueled then
      allMandatoryRefueled = false
      break
    end
    latestRefueledAt = math.max(latestRefueledAt, receiverSpec.refueledAt or 0)
  end

  if allMandatoryRefueled and not mandatoryReceiversRefueledAt then
    mandatoryReceiversRefueledAt = latestRefueledAt
    log(string.format(
      "RECEIVER_MATRIX_REFUEL_PASS mandatoryReceivers=A10,F15E,F16 a10Mapping=%s f15eMapping=%s f16Mapping=%s postRefuelDwellSec=%d",
      tostring(RECEIVERS.A10.proximityPass),
      tostring(RECEIVERS.F15E.proximityPass),
      tostring(RECEIVERS.F16.proximityPass),
      POST_REFUEL_DWELL_SEC
    ))
  end

  if mandatoryReceiversRefueledAt and OPTIONAL_C130.concluded and not acceleratedFuelLowArmed then
    local dwellElapsedSec = now - mandatoryReceiversRefueledAt
    if dwellElapsedSec >= POST_REFUEL_DWELL_SEC then
      log(string.format(
        "POST_REFUEL_DWELL_PASS elapsedSec=%.1f requiredSec=%d startsAfterMandatoryReceiverMatrix=true optionalC130Concluded=true",
        dwellElapsedSec,
        POST_REFUEL_DWELL_SEC
      ))
      acceleratedFuelLowArmed = true
      for _, tankerKey in ipairs(TANKER_KEYS) do
        local state = runtime[tankerKey]
        if state and state.flightGroup then
          state.flightGroup:SetFuelLowThreshold(ACCELERATED_FUEL_LOW_PCT)
        end
      end
      log(string.format(
        "ACCELERATED_FUEL_LOW_ARMED thresholdPct=%d afterMandatoryReceiverMatrix=true postRefuelDwellSec=%d tankerCount=%d",
        ACCELERATED_FUEL_LOW_PCT,
        POST_REFUEL_DWELL_SEC,
        #TANKER_KEYS
      ))
    end
  end

  log(string.format(
    "SUMMARY tankerExecutingCount=%d allFiveExecuting=%s a10Assigned=%s a10Refueled=%s a10Mapping=%s f15eAssigned=%s f15eRefueled=%s f15eMapping=%s f16Assigned=%s f16Refueled=%s f16Mapping=%s c130Spawned=%s c130RefuelOrdered=%s c130Refueled=%s c130Concluded=%s fuelLowArmed=%s",
    executingCount,
    tostring(allFiveTankersExecuting),
    tostring(RECEIVERS.A10.flightGroup ~= nil),
    tostring(RECEIVERS.A10.refueled),
    tostring(RECEIVERS.A10.proximityPass),
    tostring(RECEIVERS.F15E.flightGroup ~= nil),
    tostring(RECEIVERS.F15E.refueled),
    tostring(RECEIVERS.F15E.proximityPass),
    tostring(RECEIVERS.F16.flightGroup ~= nil),
    tostring(RECEIVERS.F16.refueled),
    tostring(RECEIVERS.F16.proximityPass),
    tostring(OPTIONAL_C130.flightGroup ~= nil),
    tostring(OPTIONAL_C130.refuelOrdered),
    tostring(OPTIONAL_C130.refueled),
    tostring(OPTIONAL_C130.concluded),
    tostring(acceleratedFuelLowArmed)
  ))
end, {}, 10, STATUS_INTERVAL_SEC)

log("HARNESS_READY acceptance=6 tankerCount=5 tankerTemplates=CLANCY,PATTY,HOMER,KRUSTY,NELSON fiveTankerStressException=true sameAreaDualTanker=CLANCY slowAltitudeFt=22000 slowSpeedKt=220 fastAltitudeFt=25000 fastSpeedKt=300 verticalSeparationFt=3000 mandatoryReceivers=A10,F15E,F16 a10IntendedTanker=SLOW f15eIntendedTanker=FAST f16IntendedTanker=FAST optionalC130Template=TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP optionalC130Blocking=false donorEvidence=3D_PROXIMITY_INFERENCE postRefuelDwellSec=60 newMissionEditorTemplates=0 mizMutation=false")