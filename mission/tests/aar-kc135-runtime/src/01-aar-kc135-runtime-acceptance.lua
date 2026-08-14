local TEST_ID = "AAR-KC135-RUNTIME-ACCEPTANCE-3"
local LOG_PREFIX = "[OMW][" .. TEST_ID .. "] "
local STATUS_INTERVAL_SEC = 15
local SAFE_FUEL_LOW_PCT = 20
local ACCELERATED_FUEL_LOW_PCT = 99
local EGRESS_GATE_RADIUS_NM = 10
local RECEIVER_TIMEOUT_SEC = 1800
local RECEIVER_TEMPLATE = "TPL_AIR_US_BGRM_F16C_CAS_2SHIP"
local RECEIVER_SQUADRON = "SQ_US_BGRM_F16C_121_EFS"

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
    gate = { lat = 28.90264890, lon = 64.61166667 },
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
    gateDomain = "SOUTH",
  },
  NELSON = {
    area = "NELSON",
    template = "OMW_AAR_KC135_NELSON",
    gate = { lat = 37.64268794, lon = 70.96231552 },
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
    gateDomain = "NORTH_EAST",
  },
}

local ACTIVE_TANKERS = { "CLANCY", "NELSON" }
local runtime = {}
local acceleratedFuelLowArmed = false
local receiver = {
  mission = nil,
  flightGroup = nil,
  assignedAt = nil,
  refuelOrdered = false,
  refuelOrderedAt = nil,
  fuelBeforePct = nil,
  refueled = false,
  fuelAfterPct = nil,
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

local function configureTanker(spec)
  local altitudeM = UTILS.FeetToMeters(spec.altitudeFt)
  local gateCoord = COORDINATE:NewFromLLDD(spec.gate.lat, spec.gate.lon, altitudeM)
  local trackCoord = COORDINATE:NewFromLLDD(spec.track.lat, spec.track.lon, altitudeM)

  local group = SPAWN:New(spec.template):SpawnFromCoordinate(gateCoord)
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
      "FUEL_LOW_PASS area=%s fuelPct=%.2f thresholdPct=%d action=CANCEL_TO_EGRESS",
      spec.area,
      fuelPct,
      ACCELERATED_FUEL_LOW_PCT
    ))
    mission:Cancel()
    local state = runtime[spec.area]
    if state then
      state.egressOrdered = true
    end
  end

  flightGroup:AddMission(mission)

  log(string.format(
    "TANKER_START_PASS area=%s gateDomain=%s group=%s gateLat=%.8f gateLon=%.8f radioMHz=%.3f modulation=AM tacan=%d%s ident=%s",
    spec.area,
    spec.gateDomain,
    group:GetName(),
    spec.gate.lat,
    spec.gate.lon,
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
    executingLogged = false,
    seedFuelLogged = false,
    egressOrdered = false,
    egressGatePassed = false,
    despawnedAtGate = false,
  }
end

local function configureExistingBagramReceiver()
  local bagram = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  if not bagram or bagram.Status ~= "RUNNING" then
    return false
  end

  local airwing = bagram.Airwings and bagram.Airwings.USAF or nil
  local squadron = bagram.Squadrons and bagram.Squadrons.F16C or nil
  local payload = bagram.Payloads and bagram.Payloads.F16C and bagram.Payloads.F16C[1] or nil
  if not airwing or not squadron or not payload then
    fail("BAGRAM_RECEIVER_FOUNDATION_MISSING")
    return true
  end

  local clancy = runtime.CLANCY
  if not clancy then
    fail("CLANCY_RUNTIME_MISSING_FOR_RECEIVER")
    return true
  end

  local casZone = ZONE_RADIUS:New("OMW_AAR_RECEIVER_CAS_ZONE", clancy.trackCoord:GetVec2(), UTILS.NMToMeters(20))
  local mission = AUFTRAG:NewCAS(casZone, 22000, 300, clancy.trackCoord, 225, 20, {})
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
    if Mission == mission and not receiver.flightGroup then
      receiver.flightGroup = FlightGroup
      receiver.assignedAt = timer.getAbsTime()
      receiver.fuelBeforePct = getFuelPct(FlightGroup)
      log(string.format(
        "RECEIVER_ASSIGNED_PASS template=%s squadron=%s group=%s fuelPct=%.2f",
        RECEIVER_TEMPLATE,
        RECEIVER_SQUADRON,
        FlightGroup:GetName(),
        receiver.fuelBeforePct or -1
      ))

      local previousOnAfterRefueled = FlightGroup.OnAfterRefueled
      function FlightGroup:OnAfterRefueled(RefuelFrom, RefuelEvent, RefuelTo)
        if previousOnAfterRefueled then
          previousOnAfterRefueled(self, RefuelFrom, RefuelEvent, RefuelTo)
        end
        receiver.refueled = true
        receiver.fuelAfterPct = getFuelPct(self)
        log(string.format(
          "AI_BOOM_REFUELED_PASS group=%s fuelBeforePct=%.2f fuelAfterPct=%.2f",
          self:GetName(),
          receiver.fuelBeforePct or -1,
          receiver.fuelAfterPct or -1
        ))
      end
    end
  end

  receiver.mission = mission
  airwing:AddMission(mission)
  log(string.format(
    "RECEIVER_MISSION_ADDED_PASS template=%s squadron=%s existingBagramFoundation=true",
    RECEIVER_TEMPLATE,
    RECEIVER_SQUADRON
  ))
  return true
end

for _, area in ipairs(ACTIVE_TANKERS) do
  runtime[area] = configureTanker(TANKERS[area])
end

log("START simultaneousDifferentGateDomains=CLANCY,NELSON sameGateMinimumSpawnSeparationSec=60 productionSupportMissionLimit=2")

local receiverFoundationResolved = false
SCHEDULER:New(nil, function()
  if not receiverFoundationResolved then
    receiverFoundationResolved = configureExistingBagramReceiver()
  end

  local now = timer.getAbsTime()
  for _, area in ipairs(ACTIVE_TANKERS) do
    local state = runtime[area]
    if state then
      if state.group and state.group:IsAlive() then
        local fuelPct = getFuelPct(state.flightGroup)
        local distanceTrackNm = getDistanceNm(state.flightGroup, state.trackCoord) or -1
        local distanceGateNm = getDistanceNm(state.flightGroup, state.gateCoord) or -1
        if fuelPct and not state.seedFuelLogged then
          state.seedFuelLogged = true
          log(string.format(
            "SEED_FUEL_PASS area=%s fuelPct=%.2f expectedFuelPct=%.2f",
            area,
            fuelPct,
            state.spec.expectedFuelPct
          ))
        end
        if state.mission:IsExecuting() and not state.executingLogged then
          state.executingLogged = true
          log(string.format(
            "TANKER_EXECUTING_PASS area=%s fuelPct=%.2f distanceTrackNm=%.2f",
            area,
            fuelPct or -1,
            distanceTrackNm
          ))
        end
        if state.egressOrdered and not state.egressGatePassed and distanceGateNm >= 0 and distanceGateNm <= EGRESS_GATE_RADIUS_NM then
          state.egressGatePassed = true
          log(string.format(
            "EGRESS_GATE_PASS area=%s distanceGateNm=%.2f fuelPct=%.2f action=DESPAWN_OFFMAP_HANDOFF",
            area,
            distanceGateNm,
            fuelPct or -1
          ))
          state.flightGroup:Despawn(1, true)
          state.despawnedAtGate = true
        end
      elseif not state.despawnedAtGate then
        fail(string.format("GROUP_NOT_ALIVE area=%s", area))
      end
    end
  end

  local clancy = runtime.CLANCY
  if receiver.flightGroup and clancy and clancy.mission:IsExecuting() and not receiver.refuelOrdered then
    if receiver.flightGroup:IsAirborne() then
      receiver.fuelBeforePct = getFuelPct(receiver.flightGroup) or receiver.fuelBeforePct
      receiver.refuelOrdered = true
      receiver.refuelOrderedAt = now
      receiver.flightGroup:Refuel(clancy.trackCoord)
      log(string.format(
        "AI_BOOM_REFUEL_ORDER_PASS group=%s tankerArea=CLANCY fuelBeforePct=%.2f",
        receiver.flightGroup:GetName(),
        receiver.fuelBeforePct or -1
      ))
    end
  end

  if receiver.refuelOrdered and not receiver.refueled and receiver.refuelOrderedAt and now - receiver.refuelOrderedAt > RECEIVER_TIMEOUT_SEC then
    fail(string.format("AI_BOOM_REFUEL_TIMEOUT group=%s", receiver.flightGroup and receiver.flightGroup:GetName() or "unknown"))
    receiver.refuelOrderedAt = nil
  end

  if receiver.refueled and not acceleratedFuelLowArmed then
    acceleratedFuelLowArmed = true
    for _, area in ipairs(ACTIVE_TANKERS) do
      local state = runtime[area]
      if state and state.flightGroup then
        state.flightGroup:SetFuelLowThreshold(ACCELERATED_FUEL_LOW_PCT)
      end
    end
    log(string.format(
      "ACCELERATED_FUEL_LOW_ARMED thresholdPct=%d afterAiBoomRefueled=true",
      ACCELERATED_FUEL_LOW_PCT
    ))
  end

  log(string.format(
    "SUMMARY clancyExecuting=%s nelsonExecuting=%s receiverAssigned=%s receiverAirborne=%s refuelOrdered=%s refueled=%s fuelLowArmed=%s clancyEgress=%s nelsonEgress=%s",
    tostring(runtime.CLANCY and runtime.CLANCY.mission:IsExecuting() or false),
    tostring(runtime.NELSON and runtime.NELSON.mission:IsExecuting() or false),
    tostring(receiver.flightGroup ~= nil),
    tostring(receiver.flightGroup and receiver.flightGroup:IsAirborne() or false),
    tostring(receiver.refuelOrdered),
    tostring(receiver.refueled),
    tostring(acceleratedFuelLowArmed),
    tostring(runtime.CLANCY and runtime.CLANCY.egressGatePassed or false),
    tostring(runtime.NELSON and runtime.NELSON.egressGatePassed or false)
  ))
end, {}, 10, STATUS_INTERVAL_SEC)

log("HARNESS_READY activeTankers=CLANCY,NELSON manualRadioTacanExemplars=2 aiBoomReceiverTemplate=TPL_AIR_US_BGRM_F16C_CAS_2SHIP acceleratedFuelLowAfterAiBoomRefueled=true egressGateRadiusNm=10 newMissionEditorTemplates=0 mizMutation=false")
