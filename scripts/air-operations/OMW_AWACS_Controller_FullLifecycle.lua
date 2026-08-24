-- Operation Mountain Watch - full external E-3 AWACS lifecycle controller.
--
-- MOOSE-first implementation:
--   * SPAWN materializes WIZARD from the late-activation ME template.
--   * FLIGHTGROUP handles routing, fuel state, nearest-tanker search and refuel tasking.
--   * AUFTRAG provides the persistent APOC racetrack and the dedicated LISA rendezvous tanker orbit.
--   * SCHEDULER performs bounded coordination only; no world scanning or frame scheduler is used.
--   * CampaignState remains the sole strategic aircraft authority.
--
-- Important mission-editor contract:
--   * OMW_C2_E3A_WIZARD must be configured with approximately 77 % internal fuel.
--     MOOSE SPAWN has no verified public InitFuel method in the pinned source, so this
--     controller intentionally does not mutate undocumented SPAWN internals.
--
-- Fuel policy (initial engineering baseline, DCS acceptance required):
--   * LISA pre-dispatch at <=65 % WIZARD fuel.
--   * Refuel required at <=40 % WIZARD fuel.
--   * MOOSE automatic RTB on FuelLow/FuelCritical is disabled.
--   * If LISA is not available or not yet in position, WIZARD uses MOOSE nearest-tanker
--     discovery and refuels from the nearest compatible tanker.
--   * At <=25 % without an established refuel path, WIZARD leaves the theatre via ROSIE
--     for an off-map contingency rather than allowing an arbitrary Afghanistan RTB.

OMW = OMW or {}

local Controller = {}

local TAG = "[OMW][AWACS.FullLifecycle]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local TEMPLATE = "OMW_C2_E3A_WIZARD"
local SOURCE_DOMAIN = "AL_DHAFRA"
local SOURCE_NODE = "OFFMAP_AL_DHAFRA"
local FIR_FIX_NAME = "ROSIE"
local AREA_NAME = "APOC"
local MISSION_DEMAND_ID = "AWACS-CORE-APOC"

local FREQUENCY_MHZ = 357.300
local MODULATION = 0
local TRACK_ALTITUDE_FT = 32000
local TRACK_SPEED_KT = 300
local TRACK_HEADING_DEG = 17
local TRACK_LEG_NM = 30

local EXTERNAL_POINT = { lat = 31.5117470464, lon = 69.2298100106 }
local ROSIE = { lat = 31.6666666667, lon = 68.9997166667 }
local APOC = { lat = 32.6850000000, lon = 69.0500000000 }

local TRANSIT_ALTITUDE_FT = 35000
local TRANSIT_SPEED_KT = 440
local SPAWN_INITIAL_SPEED_KT = 440
local LATE_APPROACH_NM = 30

local SERVICE_START_SEC = 15 * 3600 + 30 * 60
local SERVICE_END_SEC = 23 * 3600 + 30 * 60

local EXPECTED_SPAWN_FUEL_PCT = 77
local SPAWN_FUEL_TOLERANCE_PCT = 4
local LISA_PREDISPATCH_FUEL_PCT = 65
local AAR_TRIGGER_FUEL_PCT = 40
local AAR_CRITICAL_FUEL_PCT = 25
local TANKER_SEARCH_RADIUS_NM = 500
local TANKER_RETRY_INTERVAL_SEC = 15

-- Dedicated reserve tanker staging for WIZARD.
local LISA_TEMPLATE = "OMW_AAR_KC135_LISA"
local LISA_SOURCE_DOMAIN = "AL_UDEID"
local LISA_MISSION_DEMAND_ID = "AWACS-AAR-APOC-FUEL"
local LISA_EXTERNAL = { lat = 28.90264890, lon = 64.61166667 }
local DAVER = { lat = 29.57166667, lon = 64.67666667 }
local LISA_RENDEZVOUS = { lat = 33.6233926368, lon = 68.6395554105 }
local LISA_TRACK_ALTITUDE_FT = 25000
local LISA_TRACK_SPEED_KT = 300
local LISA_TRACK_HEADING_DEG = 340
local LISA_TRACK_LEG_NM = 20
local LISA_LATE_APPROACH_NM = 60
local LISA_INGRESS_ALTITUDE_FT = 35000
local LISA_EGRESS_ALTITUDE_FT = 34000
local LISA_TRANSIT_SPEED_KT = 300
local LISA_FUEL_LOW_PCT = 38
local LISA_TRACK_ENTRY_RADIUS_NM = 5
local FIR_RADIUS_NM = 5
local HANDOFF_RADIUS_NM = 10

local DISPATCH_INTERVAL_SEC = 5
local MAX_PHYSICAL_AIRCRAFT = 2

local state = {
  strategicAdapter = nil,
  spawner = nil,
  activeRuntime = nil,
  nextRuntimeId = 0,
  callsignInUse = {},
  monitor = nil,
  started = false,
  lisa = nil,
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function now()
  return timer.getAbsTime()
end

local function clockSec()
  return UTILS.SecondsOfToday()
end

local function requireMoose()
  if not SPAWN or not FLIGHTGROUP or not AUFTRAG or not COORDINATE or not SCHEDULER or not UTILS then
    fail("required MOOSE classes are unavailable")
  end
  if not CALLSIGN or not CALLSIGN.AWACS or not CALLSIGN.AWACS.Wizard then
    fail("required MOOSE AWACS callsign enumerator is unavailable")
  end
  if not CALLSIGN.Tanker or not CALLSIGN.Tanker.Texaco then
    fail("required MOOSE tanker callsign enumerator is unavailable")
  end
  if not Unit or not Unit.RefuelingSystem or Unit.RefuelingSystem.BOOM_AND_RECEPTACLE == nil then
    fail("DCS boom refueling-system enum is unavailable")
  end
end

local function getAarFacade()
  if not OMW or not OMW.AirOps or not OMW.AirOps.AAR then return nil end
  local facade = OMW.AirOps.AAR
  if facade.Status ~= "RUNNING" or type(facade.StrategicAdapter) ~= "table" then return nil end
  return facade
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not flightGroup:IsAlive() then return nil end
  local current = flightGroup:GetCoordinate()
  return current and current:Get2DDistance(coordinate) / 1852 or nil
end

local function makeSelection(role)
  return {
    missionDemandId = MISSION_DEMAND_ID,
    sourceDomain = SOURCE_DOMAIN,
    sourceNode = SOURCE_NODE,
    operationsArea = AREA_NAME,
    role = role,
  }
end

local function allocateCallsign(runtimeId)
  for number = 1, 2 do
    if not state.callsignInUse[number] then
      state.callsignInUse[number] = runtimeId
      return number
    end
  end
  fail("no free WIZARD callsign number")
end

local function releaseCallsign(runtime)
  if runtime and runtime.callsignNumber and state.callsignInUse[runtime.callsignNumber] == runtime.runtimeId then
    state.callsignInUse[runtime.callsignNumber] = nil
  end
end

local function buildAwacsCoordinates()
  local spawn = COORDINATE:NewFromLLDD(EXTERNAL_POINT.lat, EXTERNAL_POINT.lon)
  spawn:SetAltitude(UTILS.FeetToMeters(TRANSIT_ALTITUDE_FT), true)

  local rosie = COORDINATE:NewFromLLDD(ROSIE.lat, ROSIE.lon)
  rosie:SetAltitude(UTILS.FeetToMeters(TRANSIT_ALTITUDE_FT), true)

  local track = COORDINATE:NewFromLLDD(APOC.lat, APOC.lon)
  track:SetAltitude(UTILS.FeetToMeters(TRACK_ALTITUDE_FT), true)

  local firToTrackNm = rosie:Get2DDistance(track) / 1852
  if firToTrackNm <= LATE_APPROACH_NM then
    fail(string.format("ROSIE-to-APOC distance %.1f NM must exceed late approach %.1f NM", firToTrackNm, LATE_APPROACH_NM))
  end

  local lateApproach = track:GetIntermediateCoordinate(rosie, LATE_APPROACH_NM / firToTrackNm)
  lateApproach:SetAltitude(UTILS.FeetToMeters(TRANSIT_ALTITUDE_FT), true)

  local handoff = COORDINATE:NewFromLLDD(EXTERNAL_POINT.lat, EXTERNAL_POINT.lon)
  handoff:SetAltitude(UTILS.FeetToMeters(TRANSIT_ALTITUDE_FT), true)

  return {
    spawn = spawn,
    rosie = rosie,
    track = track,
    lateApproach = lateApproach,
    handoff = handoff,
    spawnToRosieNm = spawn:Get2DDistance(rosie) / 1852,
    rosieToTrackNm = firToTrackNm,
  }
end

local function setSensorState(runtime, enabled, reason)
  if not runtime or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return false end
  if not runtime.group or not runtime.group:IsAlive() then return false end

  if enabled then
    runtime.group:SetOptionRadarUsingForContinousSearch()
    runtime.flightGroup:SwitchEmission(true)
    runtime.sensorState = "EMITTING"
  else
    runtime.flightGroup:SwitchEmission(false)
    runtime.group:SetOptionRadarUsingNever()
    runtime.sensorState = "SILENT"
  end

  log(string.format("SENSOR_STATE runtime=%s state=%s reason=%s", runtime.runtimeId, runtime.sensorState, tostring(reason)))
  return true
end

local function cancelOrbit(runtime)
  if runtime and runtime.orbitMission and runtime.flightGroup and runtime.flightGroup:IsAlive() then
    runtime.flightGroup:MissionCancel(runtime.orbitMission)
  end
  runtime.orbitMission = nil
  runtime.orbitMissionKind = nil
end

local function addPersistentOrbit(runtime, serviceState, reason)
  cancelOrbit(runtime)
  local mission = AUFTRAG:NewORBIT_RACETRACK(runtime.trackCoord, TRACK_ALTITUDE_FT, TRACK_SPEED_KT, TRACK_HEADING_DEG, TRACK_LEG_NM)
  mission:SetMissionAltitude(TRACK_ALTITUDE_FT)
  runtime.orbitMission = mission
  runtime.orbitMissionKind = "PERSISTENT_RACETRACK"
  runtime.flightGroup:AddMission(mission)
  runtime.serviceState = serviceState or "STANDBY"
  if runtime.serviceState == "ACTIVE" then
    setSensorState(runtime, true, reason or "ORBIT_ACTIVE")
  else
    setSensorState(runtime, false, reason or "ORBIT_STANDBY")
  end
  log(string.format("PERSISTENT_ORBIT runtime=%s serviceState=%s", runtime.runtimeId, runtime.serviceState))
end

local function activateService(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled then return false end
  if runtime.orbitMissionKind ~= "PERSISTENT_RACETRACK" then return false end
  runtime.serviceState = "ACTIVE"
  setSensorState(runtime, true, reason or "SERVICE_ACTIVE")
  log(string.format("SERVICE_ACTIVE runtime=%s reason=%s", runtime.runtimeId, tostring(reason)))
  return true
end

local function deactivateService(runtime, reason)
  if not runtime or runtime.lossHandled then return false end
  setSensorState(runtime, false, reason or "SERVICE_INACTIVE")
  if runtime.serviceState ~= "CLOSED" then runtime.serviceState = "STANDBY" end
  return true
end

local function routeDirectEgress(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.egressOrdered = true
  runtime.egressReason = reason
  runtime.serviceState = "CLOSED"
  setSensorState(runtime, false, "EGRESS")
  cancelOrbit(runtime)
  local waypoint = runtime.flightGroup:AddWaypoint(runtime.firCoord, TRANSIT_SPEED_KT, nil, TRANSIT_ALTITUDE_FT, true)
  runtime.firEgressWaypointUid = waypoint and waypoint.uid or nil
  log(string.format("EGRESS_ORDERED runtime=%s reason=%s altitudeFt=%d speedKt=%d",
    runtime.runtimeId, tostring(reason), TRANSIT_ALTITUDE_FT, TRANSIT_SPEED_KT))
  return true
end

local function handleLoss(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.lossHandled = true
  runtime.serviceState = "LOST"
  state.strategicAdapter:OnLost(runtime.selection, runtime, reason or "DEAD")
  releaseCallsign(runtime)
  state.activeRuntime = nil
  log(string.format("AIRCRAFT_LOST runtime=%s reason=%s action=NO_RECREDIT", runtime.runtimeId, tostring(reason)))
  return true
end

local function buildLisaCoordinates()
  local spawn = COORDINATE:NewFromLLDD(LISA_EXTERNAL.lat, LISA_EXTERNAL.lon)
  spawn:SetAltitude(UTILS.FeetToMeters(LISA_INGRESS_ALTITUDE_FT), true)
  local daverIn = COORDINATE:NewFromLLDD(DAVER.lat, DAVER.lon)
  daverIn:SetAltitude(UTILS.FeetToMeters(LISA_INGRESS_ALTITUDE_FT), true)
  local daverOut = COORDINATE:NewFromLLDD(DAVER.lat, DAVER.lon)
  daverOut:SetAltitude(UTILS.FeetToMeters(LISA_EGRESS_ALTITUDE_FT), true)
  local handoff = COORDINATE:NewFromLLDD(LISA_EXTERNAL.lat, LISA_EXTERNAL.lon)
  handoff:SetAltitude(UTILS.FeetToMeters(LISA_EGRESS_ALTITUDE_FT), true)
  local rendezvous = COORDINATE:NewFromLLDD(LISA_RENDEZVOUS.lat, LISA_RENDEZVOUS.lon)
  rendezvous:SetAltitude(UTILS.FeetToMeters(LISA_TRACK_ALTITUDE_FT), true)
  local firToTrackNm = daverIn:Get2DDistance(rendezvous) / 1852
  if firToTrackNm <= LISA_LATE_APPROACH_NM then fail("DAVER-to-LISA-rendezvous route too short") end
  local late = rendezvous:GetIntermediateCoordinate(daverIn, LISA_LATE_APPROACH_NM / firToTrackNm)
  late:SetAltitude(UTILS.FeetToMeters(LISA_INGRESS_ALTITUDE_FT), true)
  return { spawn = spawn, daverIn = daverIn, daverOut = daverOut, handoff = handoff, rendezvous = rendezvous, late = late }
end

local function lisaSelection()
  return {
    missionDemandId = LISA_MISSION_DEMAND_ID,
    receiverProfile = "FAST",
    requestedReceiverProfile = "FAST",
    operationsArea = "AWACS_APOC",
    supportMode = "SUPPORT",
    priority = "AWACS_FUEL_RESERVE",
    area = "LISA",
    sourceDomain = LISA_SOURCE_DOMAIN,
    transitProfile = "AL_UDEID_NORTH_HIGH",
    firFix = "DAVER",
    continuousCore = false,
    availability = "RESERVE",
  }
end

local function egressLisa(reason)
  local lisa = state.lisa
  if not lisa or lisa.egressOrdered or lisa.lossHandled or lisa.handoffComplete then return false end
  lisa.egressOrdered = true
  lisa.egressReason = reason
  if lisa.mission then lisa.mission:Cancel() end
  log(string.format("LISA_EGRESS_ORDERED runtime=%s reason=%s", lisa.runtimeId, tostring(reason)))
  return true
end

local function dispatchLisa(reason)
  if state.lisa and not state.lisa.lossHandled and not state.lisa.handoffComplete then return true, "ALREADY_DISPATCHED" end

  local aar = getAarFacade()
  if not aar then
    log("LISA_DISPATCH_DEFERRED reason=AAR_FACADE_NOT_RUNNING")
    return false, "AAR_FACADE_NOT_RUNNING"
  end

  local adapter = aar.StrategicAdapter
  local selection = lisaSelection()
  local allowed, denyReason = adapter:CanMaterialize(selection)
  if not allowed then
    log("LISA_DISPATCH_UNAVAILABLE reason=" .. tostring(denyReason or "STRATEGIC_UNAVAILABLE"))
    return false, denyReason or "STRATEGIC_UNAVAILABLE"
  end

  local coords = buildLisaCoordinates()
  local spawner = SPAWN:New(LISA_TEMPLATE)
  spawner:InitCallSign(CALLSIGN.Tanker.Texaco, "Texaco", 3, 1)
  spawner:InitHeading(coords.spawn:HeadingTo(coords.daverIn))
  spawner:InitSpeedKnots(480)
  local group = spawner:SpawnFromCoordinate(coords.spawn)
  if not group then return false, "LISA_SPAWN_FAILED" end
  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then return false, "LISA_FLIGHTGROUP_FAILED" end

  local mission = AUFTRAG:NewTANKER(coords.rendezvous, LISA_TRACK_ALTITUDE_FT, LISA_TRACK_SPEED_KT,
    LISA_TRACK_HEADING_DEG, LISA_TRACK_LEG_NM, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
  mission:SetMissionAltitude(LISA_TRACK_ALTITUDE_FT)
  mission:SetMissionEgressCoord(coords.daverOut, LISA_EGRESS_ALTITUDE_FT, LISA_TRANSIT_SPEED_KT)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(LISA_FUEL_LOW_PCT)

  local lisa = {
    runtimeId = "AWACS-LISA-0001",
    selection = selection,
    adapter = adapter,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    daverIn = coords.daverIn,
    daverOut = coords.daverOut,
    handoffCoord = coords.handoff,
    rendezvousCoord = coords.rendezvous,
    lateCoord = coords.late,
    firWaypointUid = nil,
    lateWaypointUid = nil,
    firPassed = false,
    latePassed = false,
    missionAdded = false,
    onStation = false,
    egressOrdered = false,
    firEgressPassed = false,
    handoffComplete = false,
    lossHandled = false,
  }

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or lisa.lossHandled or lisa.handoffComplete then return end
    if Waypoint.uid == lisa.firWaypointUid and not lisa.firPassed then
      lisa.firPassed = true
      log("LISA_FIR_INGRESS_PASSED runtime=" .. lisa.runtimeId)
      return
    end
    if Waypoint.uid == lisa.lateWaypointUid and not lisa.latePassed then
      lisa.latePassed = true
      if not lisa.missionAdded then
        lisa.missionAdded = true
        lisa.flightGroup:AddMission(lisa.mission)
      end
      log("LISA_LATE_APPROACH_PASSED runtime=" .. lisa.runtimeId)
    end
  end

  function flightGroup:OnAfterFuelLow(From, Event, To)
    egressLisa("LISA_FUEL_LOW")
  end

  function flightGroup:OnAfterDead(From, Event, To)
    if lisa.lossHandled or lisa.handoffComplete then return end
    lisa.lossHandled = true
    lisa.adapter:OnLost(lisa.selection, lisa, "MOOSE_FLIGHTGROUP_DEAD")
    log("LISA_LOST runtime=" .. lisa.runtimeId)
  end

  local firWp = flightGroup:AddWaypoint(coords.daverIn, LISA_TRANSIT_SPEED_KT, nil, LISA_INGRESS_ALTITUDE_FT, false)
  local lateWp = flightGroup:AddWaypoint(coords.late, LISA_TRANSIT_SPEED_KT, firWp.uid, LISA_INGRESS_ALTITUDE_FT, true)
  lisa.firWaypointUid = firWp.uid
  lisa.lateWaypointUid = lateWp.uid

  adapter:OnMaterialized(selection, lisa)
  state.lisa = lisa
  log(string.format("LISA_DISPATCHED runtime=%s reason=%s rendezvousLat=%.6f rendezvousLon=%.6f",
    lisa.runtimeId, tostring(reason), LISA_RENDEZVOUS.lat, LISA_RENDEZVOUS.lon))
  return true, "DISPATCHED"
end

local function startRefuelSearch(runtime, reason)
  if runtime.aarPhase == "REFUELING" or runtime.aarPhase == "SEEKING_TANKER" then return false end
  deactivateService(runtime, "AAR_REQUIRED")
  cancelOrbit(runtime)
  runtime.serviceState = "INTERRUPTED_AAR"
  runtime.aarPhase = "SEEKING_TANKER"
  runtime.aarRequiredAt = now()
  runtime.nextTankerRetryAt = 0
  dispatchLisa("AAR_TRIGGER")
  log(string.format("AAR_REQUIRED runtime=%s reason=%s fuelPct=%.2f", runtime.runtimeId, tostring(reason), runtime.flightGroup:GetFuelMin()))
  return true
end

local function tryRefuel(runtime)
  if runtime.aarPhase ~= "SEEKING_TANKER" then return false end
  local timestamp = now()
  if timestamp < (runtime.nextTankerRetryAt or 0) then return false end
  runtime.nextTankerRetryAt = timestamp + TANKER_RETRY_INTERVAL_SEC

  local tanker = runtime.flightGroup:FindNearestTanker(TANKER_SEARCH_RADIUS_NM)
  if not tanker then
    log(string.format("AAR_TANKER_SEARCH runtime=%s fuelPct=%.2f radiusNm=%d result=NONE",
      runtime.runtimeId, runtime.flightGroup:GetFuelMin(), TANKER_SEARCH_RADIUS_NM))
    return false
  end

  local coordinate = tanker:GetCoordinate()
  if not coordinate then return false end
  runtime.designatedTankerGroupName = tanker:GetName()
  runtime.aarPhase = "REFUELING"
  runtime.aarRefuelTaskAt = timestamp
  log(string.format("AAR_TANKER_SELECTED runtime=%s tanker=%s fuelPct=%.2f action=MOOSE_REFUEL",
    runtime.runtimeId, runtime.designatedTankerGroupName, runtime.flightGroup:GetFuelMin()))
  runtime.flightGroup:Refuel(coordinate)
  return true
end

local function materialize(role, reason)
  requireMoose()
  local selection = makeSelection(role)
  local allowed, strategicReason = state.strategicAdapter:CanMaterialize(selection)
  if not allowed then return nil, strategicReason or "STRATEGIC_UNAVAILABLE" end

  state.nextRuntimeId = state.nextRuntimeId + 1
  local runtimeId = string.format("AWACS-%04d", state.nextRuntimeId)
  local callsignNumber = allocateCallsign(runtimeId)
  local coords = buildAwacsCoordinates()

  if not state.spawner then state.spawner = SPAWN:New(TEMPLATE) end
  state.spawner:InitCallSign(CALLSIGN.AWACS.Wizard, "Wizard", callsignNumber, 1)
  state.spawner:InitHeading(coords.spawn:HeadingTo(coords.rosie))
  state.spawner:InitSpeedKnots(SPAWN_INITIAL_SPEED_KT)
  local group = state.spawner:SpawnFromCoordinate(coords.spawn)
  if not group then
    state.callsignInUse[callsignNumber] = nil
    return nil, "AWACS_SPAWN_FAILED"
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then return nil, "AWACS_FLIGHTGROUP_FAILED" end

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowRefuel(true)
  flightGroup:SetFuelLowThreshold(AAR_TRIGGER_FUEL_PCT)
  flightGroup:SetFuelCriticalThreshold(AAR_CRITICAL_FUEL_PCT)
  flightGroup:SetFuelCriticalRTB(false)

  local runtime = {
    runtimeId = runtimeId,
    role = role,
    selection = selection,
    reason = reason,
    group = group,
    flightGroup = flightGroup,
    callsignNumber = callsignNumber,
    firCoord = coords.rosie,
    trackCoord = coords.track,
    lateApproachCoord = coords.lateApproach,
    externalHandoffCoord = coords.handoff,
    firWaypointUid = nil,
    lateWaypointUid = nil,
    firPassed = false,
    latePassed = false,
    physicalOnTrack = false,
    serviceState = "INBOUND",
    sensorState = "SILENT",
    orbitMission = nil,
    orbitMissionKind = nil,
    lisaPredispatchRequested = false,
    aarPhase = nil,
    nextTankerRetryAt = 0,
    egressOrdered = false,
    firEgressWaypointUid = nil,
    firEgressPassed = false,
    externalHandoffRouted = false,
    handoffComplete = false,
    lossHandled = false,
    materializedAt = now(),
  }

  setSensorState(runtime, false, "MATERIALIZED_INBOUND")

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or runtime.lossHandled or runtime.handoffComplete then return end
    if Waypoint.uid == runtime.firWaypointUid and not runtime.firPassed then
      runtime.firPassed = true
      log(string.format("FIR_INGRESS_PASSED runtime=%s fix=%s altitudeFt=%d", runtime.runtimeId, FIR_FIX_NAME, TRANSIT_ALTITUDE_FT))
      return
    end
    if Waypoint.uid == runtime.lateWaypointUid and not runtime.latePassed then
      runtime.latePassed = true
      local initialState = clockSec() < SERVICE_START_SEC and "STANDBY" or "ACTIVE"
      addPersistentOrbit(runtime, initialState, initialState == "ACTIVE" and "ARRIVED_AFTER_SERVICE_START" or "ARRIVED_BEFORE_SERVICE_START")
      log(string.format("LATE_APPROACH_PASSED runtime=%s action=ADD_PERSISTENT_ORBIT", runtime.runtimeId))
      return
    end
  end

  function flightGroup:OnAfterFuelLow(From, Event, To)
    if runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return end
    startRefuelSearch(runtime, "MOOSE_FUEL_LOW")
  end

  function flightGroup:OnAfterFuelCritical(From, Event, To)
    if runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return end
    if runtime.aarPhase ~= "REFUELING" then
      log(string.format("FUEL_CRITICAL_CONTINGENCY runtime=%s fuelPct=%.2f action=OFFMAP_EGRESS",
        runtime.runtimeId, runtime.flightGroup:GetFuelMin()))
      routeDirectEgress(runtime, "FUEL_CRITICAL_NO_ESTABLISHED_REFUEL_PATH")
    end
  end

  function flightGroup:OnAfterRefueled(From, Event, To)
    if runtime.lossHandled or runtime.handoffComplete then return end
    runtime.aarPhase = "REFUELED"
    runtime.aarCompletedAt = now()
    log(string.format("AAR_REFUELED runtime=%s tanker=%s fuelPct=%.2f",
      runtime.runtimeId, tostring(runtime.designatedTankerGroupName), runtime.flightGroup:GetFuelMin()))
    egressLisa("AWACS_REFUEL_COMPLETE")
    if clockSec() >= SERVICE_END_SEC then
      routeDirectEgress(runtime, "SERVICE_WINDOW_ENDED_DURING_AAR")
    else
      addPersistentOrbit(runtime, "REJOINING", "AAR_COMPLETE_RETURN_APOC")
    end
  end

  function flightGroup:OnAfterDead(From, Event, To)
    handleLoss(runtime, "MOOSE_FLIGHTGROUP_DEAD")
  end

  local firWp = flightGroup:AddWaypoint(coords.rosie, TRANSIT_SPEED_KT, nil, TRANSIT_ALTITUDE_FT, false)
  local lateWp = flightGroup:AddWaypoint(coords.lateApproach, TRANSIT_SPEED_KT, firWp.uid, TRANSIT_ALTITUDE_FT, true)
  runtime.firWaypointUid = firWp.uid
  runtime.lateWaypointUid = lateWp.uid

  state.activeRuntime = runtime
  state.strategicAdapter:OnMaterialized(selection, runtime)

  local fuelPct = flightGroup:GetFuelMin()
  if type(fuelPct) == "number" and math.abs(fuelPct - EXPECTED_SPAWN_FUEL_PCT) > SPAWN_FUEL_TOLERANCE_PCT then
    log(string.format("SPAWN_FUEL_WARNING runtime=%s observedPct=%.2f expectedPct=%d tolerancePct=%d action=CHECK_ME_TEMPLATE_FUEL",
      runtime.runtimeId, fuelPct, EXPECTED_SPAWN_FUEL_PCT, SPAWN_FUEL_TOLERANCE_PCT))
  else
    log(string.format("SPAWN_FUEL_ACCEPTED runtime=%s observedPct=%.2f expectedPct=%d", runtime.runtimeId, fuelPct or -1, EXPECTED_SPAWN_FUEL_PCT))
  end

  log(string.format("MATERIALIZED runtime=%s source=%s altitudeFt=%d speedKt=%d fuelLowPct=%d fuelCriticalPct=%d lisaPredispatchPct=%d",
    runtime.runtimeId, SOURCE_DOMAIN, TRANSIT_ALTITUDE_FT, TRANSIT_SPEED_KT,
    AAR_TRIGGER_FUEL_PCT, AAR_CRITICAL_FUEL_PCT, LISA_PREDISPATCH_FUEL_PCT))
  return runtime
end

local function monitorLisa()
  local lisa = state.lisa
  if not lisa or lisa.lossHandled or lisa.handoffComplete or not lisa.flightGroup or not lisa.flightGroup:IsAlive() then return end

  if lisa.missionAdded and not lisa.onStation then
    local distanceNm = getDistanceNm(lisa.flightGroup, lisa.rendezvousCoord)
    if distanceNm and distanceNm <= LISA_TRACK_ENTRY_RADIUS_NM then
      lisa.onStation = true
      log(string.format("LISA_ON_RENDEZVOUS runtime=%s distanceNm=%.1f", lisa.runtimeId, distanceNm))
    end
  end

  if lisa.egressOrdered then
    if not lisa.firEgressPassed then
      local d = getDistanceNm(lisa.flightGroup, lisa.daverOut)
      if d and d <= FIR_RADIUS_NM then
        lisa.firEgressPassed = true
        lisa.flightGroup:AddWaypoint(lisa.handoffCoord, LISA_TRANSIT_SPEED_KT, nil, LISA_EGRESS_ALTITUDE_FT)
        log("LISA_FIR_EGRESS_PASSED runtime=" .. lisa.runtimeId)
      end
    else
      local d = getDistanceNm(lisa.flightGroup, lisa.handoffCoord)
      if d and d <= HANDOFF_RADIUS_NM then
        lisa.handoffComplete = true
        lisa.adapter:OnHandoff(lisa.selection, lisa)
        lisa.flightGroup:Despawn(1, true)
        log("LISA_EXTERNAL_HANDOFF runtime=" .. lisa.runtimeId)
      end
    end
  end
end

local function monitor()
  local runtime = state.activeRuntime
  monitorLisa()
  if not runtime or runtime.lossHandled or runtime.handoffComplete or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return end

  local fuelPct = runtime.flightGroup:GetFuelMin()
  local localSec = clockSec()

  if type(fuelPct) == "number" and fuelPct <= LISA_PREDISPATCH_FUEL_PCT and not runtime.lisaPredispatchRequested
      and not runtime.egressOrdered and runtime.aarPhase == nil then
    runtime.lisaPredispatchRequested = true
    local ok, reason = dispatchLisa("FUEL_PREDISPATCH")
    log(string.format("LISA_PREDISPATCH runtime=%s fuelPct=%.2f result=%s reason=%s",
      runtime.runtimeId, fuelPct, tostring(ok), tostring(reason)))
  end

  if runtime.latePassed and not runtime.egressOrdered and runtime.aarPhase == nil then
    local distanceNm = getDistanceNm(runtime.flightGroup, runtime.trackCoord)
    if distanceNm and distanceNm <= 5 then
      if not runtime.physicalOnTrack then
        runtime.physicalOnTrack = true
        log(string.format("ON_TRACK runtime=%s fuelPct=%.2f serviceState=%s", runtime.runtimeId, fuelPct or -1, runtime.serviceState))
      end
      if runtime.serviceState == "STANDBY" and localSec >= SERVICE_START_SEC and localSec < SERVICE_END_SEC then
        activateService(runtime, "SCHEDULED_1100Z_START")
      elseif runtime.serviceState == "REJOINING" then
        runtime.aarPhase = nil
        activateService(runtime, "AAR_RETURN_ON_STATION")
      end
    end
  end

  if runtime.aarPhase == "SEEKING_TANKER" then
    tryRefuel(runtime)
  end

  if not runtime.egressOrdered and localSec >= SERVICE_END_SEC and runtime.aarPhase ~= "REFUELING" then
    routeDirectEgress(runtime, "SCHEDULED_1900Z_END")
  end

  if runtime.egressOrdered then
    if not runtime.firEgressPassed then
      local d = getDistanceNm(runtime.flightGroup, runtime.firCoord)
      if d and d <= FIR_RADIUS_NM then
        runtime.firEgressPassed = true
        runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord, TRANSIT_SPEED_KT, nil, TRANSIT_ALTITUDE_FT)
        runtime.externalHandoffRouted = true
        log(string.format("FIR_EGRESS_PASSED runtime=%s fix=%s", runtime.runtimeId, FIR_FIX_NAME))
      end
    else
      local d = getDistanceNm(runtime.flightGroup, runtime.externalHandoffCoord)
      if d and d <= HANDOFF_RADIUS_NM then
        runtime.handoffComplete = true
        state.strategicAdapter:OnHandoff(runtime.selection, runtime)
        runtime.flightGroup:Despawn(1, true)
        releaseCallsign(runtime)
        state.activeRuntime = nil
        egressLisa("AWACS_EXTERNAL_HANDOFF")
        log(string.format("EXTERNAL_HANDOFF runtime=%s action=DESPAWN_AND_RECREDIT", runtime.runtimeId))
      end
    end
  end
end

function Controller.SetStrategicAdapter(adapter)
  if type(adapter) ~= "table" or type(adapter.CanMaterialize) ~= "function"
      or type(adapter.OnMaterialized) ~= "function" or type(adapter.OnHandoff) ~= "function"
      or type(adapter.OnLost) ~= "function" then
    fail("strategic adapter requires CanMaterialize, OnMaterialized, OnHandoff and OnLost")
  end
  state.strategicAdapter = adapter
  return Controller
end

function Controller.Start()
  requireMoose()
  if state.started then return state.activeRuntime end
  if not state.strategicAdapter then fail("strategic adapter must be set before Start()") end
  local runtime, reason = materialize("ACTIVE", "INITIAL_COVERAGE")
  if not runtime then fail("initial AWACS materialization denied: " .. tostring(reason)) end
  state.monitor = SCHEDULER:New(nil, monitor, {}, 1, DISPATCH_INTERVAL_SEC)
  state.started = true
  log("STARTED mode=FULL_FUEL_DRIVEN_AAR")
  return runtime
end

function Controller.RequestEgress(reason)
  return routeDirectEgress(state.activeRuntime, reason or "REQUESTED_EGRESS")
end

function Controller.RequestRefuel(rendezvousCoordinate, designatedTankerGroupName)
  local runtime = state.activeRuntime
  if not runtime or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return false, "AWACS_NOT_AVAILABLE" end
  if runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false, "AWACS_NOT_REFUELABLE_STATE" end
  deactivateService(runtime, "MANUAL_AAR_REQUEST")
  cancelOrbit(runtime)
  runtime.serviceState = "INTERRUPTED_AAR"
  runtime.aarPhase = "REFUELING"
  runtime.designatedTankerGroupName = designatedTankerGroupName or "MANUAL_NEAREST"
  runtime.flightGroup:Refuel(rendezvousCoordinate)
  return true
end

function Controller.GetRuntime()
  return state.activeRuntime
end

function Controller.GetServiceState()
  local runtime = state.activeRuntime
  return runtime and runtime.serviceState or "NONE"
end

function Controller.GetConfig()
  return {
    template = TEMPLATE,
    sourceDomain = SOURCE_DOMAIN,
    sourceNode = SOURCE_NODE,
    firFix = FIR_FIX_NAME,
    area = AREA_NAME,
    callsign = "WIZARD",
    frequencyMHz = FREQUENCY_MHZ,
    modulation = MODULATION,
    externalPoint = { lat = EXTERNAL_POINT.lat, lon = EXTERNAL_POINT.lon },
    rosie = { lat = ROSIE.lat, lon = ROSIE.lon },
    apoc = { lat = APOC.lat, lon = APOC.lon },
    spawnAltitudeFt = TRANSIT_ALTITUDE_FT,
    spawnInitialSpeedKt = SPAWN_INITIAL_SPEED_KT,
    inboundCruiseAltitudeFt = TRANSIT_ALTITUDE_FT,
    outboundCruiseAltitudeFt = TRANSIT_ALTITUDE_FT,
    transitSpeedKt = TRANSIT_SPEED_KT,
    trackAltitudeFt = TRACK_ALTITUDE_FT,
    trackSpeedKt = TRACK_SPEED_KT,
    trackHeadingDeg = TRACK_HEADING_DEG,
    trackLegNm = TRACK_LEG_NM,
    lateApproachNm = LATE_APPROACH_NM,
    serviceStartLocalSec = SERVICE_START_SEC,
    serviceEndLocalSec = SERVICE_END_SEC,
    serviceWindowSec = SERVICE_END_SEC - SERVICE_START_SEC,
    expectedSpawnFuelPct = EXPECTED_SPAWN_FUEL_PCT,
    lisaPredispatchFuelPct = LISA_PREDISPATCH_FUEL_PCT,
    aarTriggerFuelPct = AAR_TRIGGER_FUEL_PCT,
    aarCriticalFuelPct = AAR_CRITICAL_FUEL_PCT,
    tankerSearchRadiusNm = TANKER_SEARCH_RADIUS_NM,
    lisaRendezvous = { lat = LISA_RENDEZVOUS.lat, lon = LISA_RENDEZVOUS.lon },
    lisaRendezvousAltitudeFt = LISA_TRACK_ALTITUDE_FT,
    lisaRendezvousSpeedKt = LISA_TRACK_SPEED_KT,
    maxPhysicalAircraft = MAX_PHYSICAL_AIRCRAFT,
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    persistentOrbit = true,
    awacsTaskUsed = false,
    fuelLowRtb = false,
    fuelLowRefuel = true,
    automaticNearestTankerFallback = true,
    dedicatedLisaPredispatch = true,
    dcsValidatedFullLifecycle = false,
  }
end

return Controller
