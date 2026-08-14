local TEST_ID = "AAR-KC135-RUNTIME-ACCEPTANCE-6"
local LOG_PREFIX = "[OMW][" .. TEST_ID .. "] "
local STATUS_INTERVAL_SEC = 15
local SAFE_FUEL_LOW_PCT = 20
local ACCELERATED_FUEL_LOW_PCT = 99
local EGRESS_GATE_RADIUS_NM = 10
local RECEIVER_TIMEOUT_SEC = 1800
local RECEIVER_MISSION_RANGE_NM = 250
local POST_REFUEL_DWELL_SEC = 60
local DUAL_TANKER_SPAWN_STAGGER_SEC = 60
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
  },
}

local TANKER_KEYS = { "SLOW", "FAST" }
local runtime = {}
local acceleratedFuelLowArmed = false
local bothReceiversRefueledAt = nil

local RECEIVERS = {
  A10 = {
    key = "A10",
    profile = "A10_SLOW",
    template = "TPL_AIR_US_KAF_A10C_CAS_2SHIP",
    squadronName = "SQ_US_KAF_A10C_74_EFS",
    intendedTankerKey = "SLOW",
    missionAltitudeFt = 22000,
    missionSpeedKt = 220,
    mission = nil,
    flightGroup = nil,
    assignedAt = nil,
    refuelOrdered = false,
    refuelOrderedAt = nil,
    fuelBeforePct = nil,
    refueled = false,
    refueledAt = nil,
    fuelAfterPct = nil,
    proximityPass = false,
  },
  F16 = {
    key = "F16",
    profile = "FAST_JET",
    template = "TPL_AIR_US_BGRM_F16C_CAS_2SHIP",
    squadronName = "SQ_US_BGRM_F16C_121_EFS",
    intendedTankerKey = "FAST",
    missionAltitudeFt = 25000,
    missionSpeedKt = 300,
    mission = nil,
    flightGroup = nil,
    assignedAt = nil,
    refuelOrdered = false,
    refuelOrderedAt = nil,
    fuelBeforePct = nil,
    refueled = false,
    refueledAt = nil,
    fuelAfterPct = nil,
    proximityPass = false,
  },
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
    "TANKER_START_PASS tankerProfile=%s receiverFocus=%s area=%s group=%s gateLat=%.8f gateLon=%.8f spawnHeadingDeg=%.3f altitudeFt=%d speedKt=%d radioMHz=%.3f modulation=AM tacan=%d%s ident=%s",
    spec.key,
    spec.profile,
    spec.area,
    group:GetName(),
    spec.gate.lat,
    spec.gate.lon,
    spawnHeadingDeg,
    spec.altitudeFt,
    spec.speedKt,
    spec.frequencyMHz,
    spec.tacanChannel,
    spec.tacanBand,
    spec.tacanIdent
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

  local f16Airwing = bagram.Airwings and bagram.Airwings.USAF or nil
  local f16Squadron = bagram.Squadrons and bagram.Squadrons.F16C or nil
  local f16Payload = bagram.Payloads and bagram.Payloads.F16C and bagram.Payloads.F16C[1] or nil
  local a10Airwing = kandahar.Airwings and kandahar.Airwings.Main or nil
  local a10Squadron = kandahar.Squadrons and kandahar.Squadrons.A10C or nil
  local a10Payload = kandahar.Payloads and kandahar.Payloads.A10C and kandahar.Payloads.A10C[1] or nil

  if not f16Airwing or not f16Squadron or not f16Payload then
    fail("BAGRAM_F16_RECEIVER_FOUNDATION_MISSING")
    return true
  end
  if not a10Airwing or not a10Squadron or not a10Payload then
    fail("KANDAHAR_A10_RECEIVER_FOUNDATION_MISSING")
    return true
  end

  addReceiverMission(RECEIVERS.A10, a10Airwing, a10Squadron, a10Payload, runtime.SLOW)
  addReceiverMission(RECEIVERS.F16, f16Airwing, f16Squadron, f16Payload, runtime.FAST)
  return true
end

local verticalSeparationFt = TANKERS.FAST.altitudeFt - TANKERS.SLOW.altitudeFt
if verticalSeparationFt < MIN_VERTICAL_SEPARATION_FT then
  error(string.format("FAST/SLOW vertical separation below minimum: %d ft", verticalSeparationFt))
end

runtime.SLOW = configureTanker(TANKERS.SLOW)
SCHEDULER:New(nil, function()
  if not runtime.FAST then
    runtime.FAST = configureTanker(TANKERS.FAST)
    if runtime.FAST then
      log(string.format(
        "DUAL_TANKER_STACK_PASS area=CLANCY slowAltitudeFt=%d fastAltitudeFt=%d separationFt=%d minimumFt=%d slowSpeedKt=%d fastSpeedKt=%d spawnStaggerSec=%d",
        TANKERS.SLOW.altitudeFt,
        TANKERS.FAST.altitudeFt,
        verticalSeparationFt,
        MIN_VERTICAL_SEPARATION_FT,
        TANKERS.SLOW.speedKt,
        TANKERS.FAST.speedKt,
        DUAL_TANKER_SPAWN_STAGGER_SEC
      ))
    end
  end
end, {}, DUAL_TANKER_SPAWN_STAGGER_SEC)

log(string.format(
  "START sameAreaDualTanker=true area=CLANCY slowProfile=A10_SLOW slowAltitudeFt=%d slowSpeedKt=%d fastProfile=FAST_JET fastAltitudeFt=%d fastSpeedKt=%d verticalSeparationFt=%d minimumVerticalSeparationFt=%d spawnStaggerSec=%d receiverMissionRangeNm=%d postRefuelDwellSec=%d",
  TANKERS.SLOW.altitudeFt,
  TANKERS.SLOW.speedKt,
  TANKERS.FAST.altitudeFt,
  TANKERS.FAST.speedKt,
  verticalSeparationFt,
  MIN_VERTICAL_SEPARATION_FT,
  DUAL_TANKER_SPAWN_STAGGER_SEC,
  RECEIVER_MISSION_RANGE_NM,
  POST_REFUEL_DWELL_SEC
))

local receiverFoundationsResolved = false
SCHEDULER:New(nil, function()
  if not receiverFoundationsResolved then
    receiverFoundationsResolved = configureExistingReceivers()
  end

  local now = timer.getAbsTime()
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
        if state.mission:IsExecuting() and not state.executingLogged then
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

  local bothTankersExecuting = runtime.SLOW and runtime.FAST
    and runtime.SLOW.mission:IsExecuting()
    and runtime.FAST.mission:IsExecuting()

  if bothTankersExecuting then
    for _, receiverKey in ipairs({ "A10", "F16" }) do
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
  end

  for _, receiverKey in ipairs({ "A10", "F16" }) do
    local receiverSpec = RECEIVERS[receiverKey]
    if receiverSpec.refuelOrdered and not receiverSpec.refueled and receiverSpec.refuelOrderedAt
      and now - receiverSpec.refuelOrderedAt > RECEIVER_TIMEOUT_SEC then
      fail(string.format("AI_BOOM_REFUEL_TIMEOUT receiver=%s group=%s", receiverSpec.key, receiverSpec.flightGroup and receiverSpec.flightGroup:GetName() or "unknown"))
      receiverSpec.refuelOrderedAt = nil
    end
  end

  if RECEIVERS.A10.refueled and RECEIVERS.F16.refueled and not bothReceiversRefueledAt then
    bothReceiversRefueledAt = math.max(RECEIVERS.A10.refueledAt or now, RECEIVERS.F16.refueledAt or now)
    log(string.format(
      "DUAL_RECEIVER_REFUEL_PASS a10ProximityPass=%s f16ProximityPass=%s postRefuelDwellSec=%d",
      tostring(RECEIVERS.A10.proximityPass),
      tostring(RECEIVERS.F16.proximityPass),
      POST_REFUEL_DWELL_SEC
    ))
  end

  if bothReceiversRefueledAt and not acceleratedFuelLowArmed then
    local dwellElapsedSec = now - bothReceiversRefueledAt
    if dwellElapsedSec >= POST_REFUEL_DWELL_SEC then
      log(string.format(
        "POST_REFUEL_DWELL_PASS elapsedSec=%.1f requiredSec=%d startsAfterBothReceivers=true",
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
        "ACCELERATED_FUEL_LOW_ARMED thresholdPct=%d afterBothReceiversRefueled=true postRefuelDwellSec=%d",
        ACCELERATED_FUEL_LOW_PCT,
        POST_REFUEL_DWELL_SEC
      ))
    end
  end

  log(string.format(
    "SUMMARY slowExecuting=%s fastExecuting=%s a10Assigned=%s a10Airborne=%s a10RefuelOrdered=%s a10Refueled=%s a10Mapping=%s f16Assigned=%s f16Airborne=%s f16RefuelOrdered=%s f16Refueled=%s f16Mapping=%s fuelLowArmed=%s slowEgress=%s fastEgress=%s",
    tostring(runtime.SLOW and runtime.SLOW.mission:IsExecuting() or false),
    tostring(runtime.FAST and runtime.FAST.mission:IsExecuting() or false),
    tostring(RECEIVERS.A10.flightGroup ~= nil),
    tostring(RECEIVERS.A10.flightGroup and RECEIVERS.A10.flightGroup:IsAirborne() or false),
    tostring(RECEIVERS.A10.refuelOrdered),
    tostring(RECEIVERS.A10.refueled),
    tostring(RECEIVERS.A10.proximityPass),
    tostring(RECEIVERS.F16.flightGroup ~= nil),
    tostring(RECEIVERS.F16.flightGroup and RECEIVERS.F16.flightGroup:IsAirborne() or false),
    tostring(RECEIVERS.F16.refuelOrdered),
    tostring(RECEIVERS.F16.refueled),
    tostring(RECEIVERS.F16.proximityPass),
    tostring(acceleratedFuelLowArmed),
    tostring(runtime.SLOW and runtime.SLOW.egressGatePassed or false),
    tostring(runtime.FAST and runtime.FAST.egressGatePassed or false)
  ))
end, {}, 10, STATUS_INTERVAL_SEC)

log("HARNESS_READY acceptance=6 sameAreaDualTanker=CLANCY slowTemplate=OMW_AAR_KC135_CLANCY slowAltitudeFt=22000 slowSpeedKt=220 slowTacan=60Y_CLA fastTemplate=OMW_AAR_KC135_PATTY fastAltitudeFt=25000 fastSpeedKt=300 fastTacan=48Y_TX2 verticalSeparationFt=3000 a10ReceiverTemplate=TPL_AIR_US_KAF_A10C_CAS_2SHIP a10IntendedTanker=SLOW f16ReceiverTemplate=TPL_AIR_US_BGRM_F16C_CAS_2SHIP f16IntendedTanker=FAST donorEvidence=3D_PROXIMITY_INFERENCE postRefuelDwellSec=60 newMissionEditorTemplates=0 mizMutation=false")
