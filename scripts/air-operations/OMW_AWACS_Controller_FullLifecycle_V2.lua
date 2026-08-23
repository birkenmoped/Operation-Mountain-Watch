-- Operation Mountain Watch - full external E-3 AWACS lifecycle controller, revision 3.
--
-- MOOSE-first implementation:
--   * SPAWN materializes the late-activation E-3 template at the visible off-map handoff.
--   * FLIGHTGROUP monitors fuel, provides FuelLow/FuelCritical FSM events, finds compatible
--     tankers and executes the receiver Refuel task.
--   * AUFTRAG provides one persistent APOC racetrack and the dedicated LISA tanker orbit.
--   * MOOSE Refuel pauses the current mission; after refuelling FLIGHTGROUP can unpause it.
--   * CampaignState remains the sole strategic aircraft authority.
--
-- Mission-editor contract:
--   * OMW_C2_E3A_WIZARD is Late Activation and carries approximately 77 percent internal fuel.
--   * The pinned MOOSE SPAWN API has no verified public InitFuel method; no private template
--     mutation is used here. The runtime validates/logs the observed spawn fuel instead.
--
-- Fuel policy - OMW engineering baseline, DCS Acceptance 4 pending:
--   * <=65 percent: pre-dispatch dedicated reserve tanker LISA toward the AWACS rendezvous.
--   * <=40 percent: WIZARD requires AAR. Prefer LISA if already established at rendezvous;
--     otherwise use FLIGHTGROUP:FindNearestTanker() for the nearest compatible active tanker.
--   * <=25 percent without an established refuel task: off-map fuel contingency via ROSIE.
--   * MOOSE automatic FuelLow/FuelCritical RTB is disabled so WIZARD is never sent to an
--     arbitrary Afghan airfield merely because its fuel state crossed a framework threshold.
--   * FLIGHTGROUP:SetFuelLowRefuel(false) is intentional. The pinned implementation's built-in
--     automatic path searches only 50 NM; OMW needs LISA priority plus a wider compatible-
--     tanker fallback. FuelLow/FindNearestTanker/Refuel themselves remain MOOSE-native.
--
-- Service timing:
--   * 15:30 local is evaluated against UTILS.SecondsOfToday(), not elapsed mission time.
--   * Scheduled activation is independent of the aircraft position on the racetrack.
--   * The 5 NM APOC gate is used only to confirm physical arrival/rejoin after AAR.

OMW = OMW or {}

local Controller = {}

local TAG = "[OMW][AWACS.FullLifecycleV2]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local TEMPLATE = "OMW_C2_E3A_WIZARD"
local SOURCE_DOMAIN = "AL_DHAFRA"
local SOURCE_NODE = "OFFMAP_AL_DHAFRA"
local FIR_FIX_NAME = "ROSIE"
local AREA_NAME = "APOC"
local MISSION_DEMAND_ID = "AWACS-CORE-APOC"

local FREQUENCY_MHZ = 357.300
local MODULATION = 0 -- AM

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
local TRACK_ENTRY_RADIUS_NM = 5
local HANDOFF_RADIUS_NM = 10
local DISPATCH_INTERVAL_SEC = 5

local state = {
  strategicAdapter = nil,
  awacsSpawner = nil,
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
  if not flightGroup or not flightGroup:IsAlive() or not coordinate then return nil end
  local current = flightGroup:GetCoordinate()
  return current and current:Get2DDistance(coordinate) / 1852 or nil
end

local function makeAwacsSelection(role)
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

  log(string.format("SENSOR_STATE runtime=%s state=%s reason=%s localSec=%.1f",
    runtime.runtimeId, runtime.sensorState, tostring(reason), clockSec()))
  return true
end

local function addPersistentOrbit(runtime, serviceState, reason)
  if runtime.orbitMission then return false end
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
  return true
end

local function activateService(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled then return false end
  if runtime.orbitMissionKind ~= "PERSISTENT_RACETRACK" then return false end
  runtime.serviceState = "ACTIVE"
  setSensorState(runtime, true, reason or "SERVICE_ACTIVE")
  log(string.format("SERVICE_ACTIVE runtime=%s reason=%s localSec=%.1f",
    runtime.runtimeId, tostring(reason), clockSec()))
  return true
end

local function deactivateService(runtime, reason)
  if not runtime or runtime.lossHandled then return false end
  setSensorState(runtime, false, reason or "SERVICE_INACTIVE")
  if runtime.serviceState ~= "CLOSED" then runtime.serviceState = "STANDBY" end
  log(string.format("SERVICE_INACTIVE runtime=%s reason=%s", runtime.runtimeId, tostring(reason)))
  return true
end

local function cancelOrbitForTrueEgress(runtime)
  if runtime and runtime.orbitMission and runtime.flightGroup and runtime.flightGroup:IsAlive() then
    runtime.flightGroup:MissionCancel(runtime.orbitMission)
  end
  runtime.orbitMission = nil
  runtime.orbitMissionKind = nil
end

local function routeDirectEgress(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.egressOrdered = true
  runtime.egressReason = reason
  runtime.serviceState = "CLOSED"
  setSensorState(runtime, false, "EGRESS")
  cancelOrbitForTrueEgress(runtime)
  local waypoint = runtime.flightGroup:AddWaypoint(runtime.firCoord, TRANSIT_SPEED_KT, nil, TRANSIT_ALTITUDE_FT, true)
  runtime.firEgressWaypointUid = waypoint and waypoint.uid or nil
  log(string.format("EGRESS_ORDERED runtime=%s reason=%s target=%s altitudeFt=%d speedKt=%d",
    runtime.runtimeId, tostring(reason), FIR_FIX_NAME, TRANSIT_ALTITUDE_FT, TRANSIT_SPEED_KT))
  return true
end

local function handleAwacsLoss(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.lossHandled = true
  runtime.serviceState = "LOST"
  state.strategicAdapter:OnLost(runtime.selection, runtime, reason or "DEAD")
  releaseCallsign(runtime)
  if state.activeRuntime == runtime then state.activeRuntime = nil end
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

  return {
    spawn = spawn,
    daverIn = daverIn,
    daverOut = daverOut,
    handoff = handoff,
    rendezvous = rendezvous,
    late = late,
  }
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

local function orderLisaEgress(reason)
  local lisa = state.lisa
  if not lisa or lisa.egressOrdered or lisa.lossHandled or lisa.handoffComplete then return false end
  lisa.egressOrdered = true
  lisa.egressReason = reason
  if lisa.mission then lisa.mission:Cancel() end
  log(string.format("LISA_EGRESS_ORDERED runtime=%s reason=%s", lisa.runtimeId, tostring(reason)))
  return true
end

local function dispatchLisa(reason)
  if state.lisa and not state.lisa.lossHandled and not state.lisa.handoffComplete then
    return true, "ALREADY_DISPATCHED"
  end

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
    orderLisaEgress("LISA_FUEL_LOW")
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

local function selectTanker(runtime)
  local lisa = state.lisa
  if lisa and lisa.onStation and not lisa.egressOrdered and not lisa.lossHandled and not lisa.handoffComplete
      and lisa.flightGroup and lisa.flightGroup:IsAlive() then
    return lisa.group, "LISA_PRIMARY"
  end

  local tanker = runtime.flightGroup:FindNearestTanker(TANKER_SEARCH_RADIUS_NM)
  if tanker then
    return tanker, "NEAREST_COMPATIBLE_FALLBACK"
  end

  return nil, "NO_COMPATIBLE_TANKER"
end

local function beginRefuel(runtime, tanker, selectionReason)
  if not runtime or not tanker or runtime.aarPhase == "REFUELING" then return false end
  local coordinate = tanker:GetCoordinate()
  if not coordinate then return false end

  deactivateService(runtime, "AAR_REQUIRED")
  runtime.serviceState = "INTERRUPTED_AAR"
  runtime.aarPhase = "REFUELING"
  runtime.designatedTankerGroupName = tanker:GetName()
  runtime.aarSelectionReason = selectionReason
  runtime.aarRefuelTaskAt = now()

  -- Do not cancel the APOC mission here. FLIGHTGROUP:Refuel() pauses the current
  -- mission, executes the receiver task and lets FLIGHTGROUP resume the paused
  -- mission after the Refueled FSM path.
  log(string.format("AAR_TANKER_SELECTED runtime=%s tanker=%s reason=%s fuelPct=%.2f action=MOOSE_REFUEL",
    runtime.runtimeId, runtime.designatedTankerGroupName, tostring(selectionReason), runtime.flightGroup:GetFuelMin()))
  runtime.flightGroup:Refuel(coordinate)
  return true
end

local function requireRefuel(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false end
  if runtime.aarPhase == "REFUELING" or runtime.aarPhase == "SEEKING_TANKER" then return false end

  runtime.aarPhase = "SEEKING_TANKER"
  runtime.aarRequiredAt = now()
  runtime.nextTankerRetryAt = 0
  dispatchLisa("AAR_TRIGGER")
  log(string.format("AAR_REQUIRED runtime=%s reason=%s fuelPct=%.2f",
    runtime.runtimeId, tostring(reason), runtime.flightGroup:GetFuelMin()))
  return true
end

local function tryAcquireTanker(runtime)
  if runtime.aarPhase ~= "SEEKING_TANKER" then return false end
  local timestamp = now()
  if timestamp < (runtime.nextTankerRetryAt or 0) then return false end
  runtime.nextTankerRetryAt = timestamp + TANKER_RETRY_INTERVAL_SEC

  local tanker, reason = selectTanker(runtime)
  if tanker then
    return beginRefuel(runtime, tanker, reason)
  end

  log(string.format("AAR_TANKER_SEARCH runtime=%s fuelPct=%.2f radiusNm=%d result=NONE",
    runtime.runtimeId, runtime.flightGroup:GetFuelMin(), TANKER_SEARCH_RADIUS_NM))
  return false
end

local function materialize(role, reason)
  requireMoose()
  local selection = makeAwacsSelection(role)
  local allowed, strategicReason = state.strategicAdapter:CanMaterialize(selection)
  if not allowed then return nil, strategicReason or "STRATEGIC_UNAVAILABLE" end

  state.nextRuntimeId = state.nextRuntimeId + 1
  local runtimeId = string.format("AWACS-%04d", state.nextRuntimeId)
  local callsignNumber = allocateCallsign(runtimeId)
  local coords = buildAwacsCoordinates()

  if not state.awacsSpawner then state.awacsSpawner = SPAWN:New(TEMPLATE) end
  state.awacsSpawner:InitCallSign(CALLSIGN.AWACS.Wizard, "Wizard", callsignNumber, 1)
  state.awacsSpawner:InitHeading(coords.spawn:HeadingTo(coords.rosie))
  state.awacsSpawner:InitSpeedKnots(SPAWN_INITIAL_SPEED_KT)

  local group = state.awacsSpawner:SpawnFromCoordinate(coords.spawn)
  if not group then
    state.callsignInUse[callsignNumber] = nil
    return nil, "AWACS_SPAWN_FAILED"
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then return nil, "AWACS_FLIGHTGROUP_FAILED" end

  -- OMW owns the policy but uses MOOSE fuel FSM/events and MOOSE refuel execution.
  -- Built-in FuelLowRefuel is disabled because the pinned implementation searches
  -- only 50 NM and cannot express LISA priority plus the wider fallback contract.
  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowRefuel(false)
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
    aarCompletedAt = nil,
    nextTankerRetryAt = 0,
    closePending = false,
    egressOrdered = false,
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
      log(string.format("FIR_INGRESS_PASSED runtime=%s fix=%s altitudeFt=%d",
        runtime.runtimeId, FIR_FIX_NAME, TRANSIT_ALTITUDE_FT))
      return
    end

    if Waypoint.uid == runtime.lateWaypointUid and not runtime.latePassed then
      runtime.latePassed = true
      local initialState = clockSec() < SERVICE_START_SEC and "STANDBY" or "ACTIVE"
      addPersistentOrbit(runtime, initialState,
        initialState == "ACTIVE" and "ARRIVED_AFTER_SERVICE_START" or "ARRIVED_BEFORE_SERVICE_START")
      log(string.format("LATE_APPROACH_PASSED runtime=%s action=ADD_PERSISTENT_ORBIT", runtime.runtimeId))
    end
  end

  function flightGroup:OnAfterFuelLow(From, Event, To)
    if runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return end
    requireRefuel(runtime, "MOOSE_FUEL_LOW")
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
    runtime.aarCompletedAt = now()
    runtime.aarPhase = nil
    log(string.format("AAR_REFUELED runtime=%s tanker=%s fuelPct=%.2f",
      runtime.runtimeId, tostring(runtime.designatedTankerGroupName), runtime.flightGroup:GetFuelMin()))

    orderLisaEgress("AWACS_REFUEL_COMPLETE")

    if runtime.closePending or clockSec() >= SERVICE_END_SEC then
      routeDirectEgress(runtime, "SERVICE_WINDOW_ENDED_DURING_AAR")
    else
      runtime.serviceState = "REJOINING"
      -- The paused persistent mission is resumed by the normal FLIGHTGROUP mission
      -- lifecycle. Sensor service is restored only after WIZARD is physically back
      -- within the APOC track-entry radius.
      setSensorState(runtime, false, "AAR_COMPLETE_REJOINING")
    end
  end

  function flightGroup:OnAfterDead(From, Event, To)
    handleAwacsLoss(runtime, "MOOSE_FLIGHTGROUP_DEAD")
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
    log(string.format("SPAWN_FUEL_ACCEPTED runtime=%s observedPct=%s expectedPct=%d",
      runtime.runtimeId, type(fuelPct) == "number" and string.format("%.2f", fuelPct) or "NA", EXPECTED_SPAWN_FUEL_PCT))
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
      local distanceNm = getDistanceNm(lisa.flightGroup, lisa.daverOut)
      if distanceNm and distanceNm <= FIR_RADIUS_NM then
        lisa.firEgressPassed = true
        lisa.flightGroup:AddWaypoint(lisa.handoffCoord, LISA_TRANSIT_SPEED_KT, nil, LISA_EGRESS_ALTITUDE_FT)
        log("LISA_FIR_EGRESS_PASSED runtime=" .. lisa.runtimeId)
      end
    else
      local distanceNm = getDistanceNm(lisa.flightGroup, lisa.handoffCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        lisa.handoffComplete = true
        lisa.adapter:OnHandoff(lisa.selection, lisa)
        lisa.flightGroup:Despawn(1, true)
        log("LISA_EXTERNAL_HANDOFF runtime=" .. lisa.runtimeId)
      end
    end
  end
end

local function monitorAwacs(runtime)
  local fuelPct = runtime.flightGroup:GetFuelMin()
  local localSec = clockSec()

  if type(fuelPct) == "number" and fuelPct <= LISA_PREDISPATCH_FUEL_PCT
      and not runtime.lisaPredispatchRequested and not runtime.egressOrdered and runtime.aarPhase == nil then
    local ok, reason = dispatchLisa("FUEL_PREDISPATCH")
    if ok then runtime.lisaPredispatchRequested = true end
    log(string.format("LISA_PREDISPATCH runtime=%s fuelPct=%.2f result=%s reason=%s",
      runtime.runtimeId, fuelPct, tostring(ok), tostring(reason)))
  end

  if type(fuelPct) == "number" and fuelPct <= AAR_TRIGGER_FUEL_PCT
      and runtime.aarPhase == nil and not runtime.egressOrdered then
    requireRefuel(runtime, "FUEL_THRESHOLD_MONITOR")
  end

  if runtime.aarPhase == "SEEKING_TANKER" then
    tryAcquireTanker(runtime)
  end

  -- Scheduled service activation is a time-domain state change only. Do not gate it
  -- on proximity to the APOC anchor: doing so delayed the 15:30 emission switch by
  -- several minutes while WIZARD happened to be on the far side of the racetrack.
  if runtime.serviceState == "STANDBY" and runtime.orbitMissionKind == "PERSISTENT_RACETRACK"
      and localSec >= SERVICE_START_SEC and localSec < SERVICE_END_SEC and runtime.aarPhase == nil
      and not runtime.egressOrdered then
    activateService(runtime, "SCHEDULED_1100Z_START")
  end

  if runtime.latePassed and not runtime.egressOrdered then
    local distanceNm = getDistanceNm(runtime.flightGroup, runtime.trackCoord)
    if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
      if not runtime.physicalOnTrack then
        runtime.physicalOnTrack = true
        log(string.format("ON_TRACK runtime=%s fuelPct=%.2f serviceState=%s",
          runtime.runtimeId, fuelPct or -1, runtime.serviceState))
      end

      -- The positional gate remains appropriate after AAR: sensor service is restored
      -- only after WIZARD has physically rejoined APOC.
      if runtime.serviceState == "REJOINING" and runtime.aarPhase == nil then
        activateService(runtime, "AAR_RETURN_ON_STATION")
      end
    end
  end

  if localSec >= SERVICE_END_SEC and not runtime.egressOrdered then
    if runtime.aarPhase == "REFUELING" or runtime.aarPhase == "SEEKING_TANKER" then
      if not runtime.closePending then
        runtime.closePending = true
        deactivateService(runtime, "SCHEDULED_1900Z_END_AAR_PENDING")
        log(string.format("SERVICE_CLOSE_PENDING runtime=%s aarPhase=%s", runtime.runtimeId, tostring(runtime.aarPhase)))
      end
    else
      routeDirectEgress(runtime, "SCHEDULED_1900Z_END")
    end
  end

  if runtime.egressOrdered then
    if not runtime.firEgressPassed then
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.firCoord)
      if distanceNm and distanceNm <= FIR_RADIUS_NM then
        runtime.firEgressPassed = true
        runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord, TRANSIT_SPEED_KT, nil, TRANSIT_ALTITUDE_FT)
        runtime.externalHandoffRouted = true
        log(string.format("FIR_EGRESS_PASSED runtime=%s fix=%s", runtime.runtimeId, FIR_FIX_NAME))
      end
    else
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.externalHandoffCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        runtime.handoffComplete = true
        state.strategicAdapter:OnHandoff(runtime.selection, runtime)
        runtime.flightGroup:Despawn(1, true)
        releaseCallsign(runtime)
        state.activeRuntime = nil
        orderLisaEgress("AWACS_EXTERNAL_HANDOFF")
        log(string.format("EXTERNAL_HANDOFF runtime=%s action=DESPAWN_AND_RECREDIT", runtime.runtimeId))
      end
    end
  end
end

local function monitor()
  monitorLisa()
  local runtime = state.activeRuntime
  if not runtime or runtime.lossHandled or runtime.handoffComplete
      or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return end
  monitorAwacs(runtime)
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
  log("STARTED mode=FULL_FUEL_DRIVEN_AAR_V3")
  return runtime
end

function Controller.RequestEgress(reason)
  return routeDirectEgress(state.activeRuntime, reason or "REQUESTED_EGRESS")
end

function Controller.RequestRefuel(rendezvousCoordinate, designatedTankerGroupName)
  local runtime = state.activeRuntime
  if not runtime or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return false, "AWACS_NOT_AVAILABLE" end
  if runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false, "AWACS_NOT_REFUELABLE_STATE" end

  local tanker = nil
  local selectionReason = "MANUAL_NEAREST"
  if type(designatedTankerGroupName) == "string" and designatedTankerGroupName ~= "" then
    local candidate = GROUP:FindByName(designatedTankerGroupName)
    if candidate and candidate:IsAlive() then
      tanker = candidate
      selectionReason = "MANUAL_DESIGNATED"
    end
  end
  if not tanker then
    tanker = runtime.flightGroup:FindNearestTanker(TANKER_SEARCH_RADIUS_NM)
  end
  if not tanker and rendezvousCoordinate then
    runtime.serviceState = "INTERRUPTED_AAR"
    runtime.aarPhase = "REFUELING"
    runtime.designatedTankerGroupName = designatedTankerGroupName or "DCS_NEAREST_AT_RENDEZVOUS"
    deactivateService(runtime, "MANUAL_AAR_COORDINATE")
    runtime.flightGroup:Refuel(rendezvousCoordinate)
    return true
  end
  if not tanker then return false, "NO_COMPATIBLE_TANKER" end
  return beginRefuel(runtime, tanker, selectionReason)
end

function Controller.GetRuntime()
  return state.activeRuntime
end

function Controller.GetLisaRuntime()
  return state.lisa
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
    spawnFuelTolerancePct = SPAWN_FUEL_TOLERANCE_PCT,
    lisaPredispatchFuelPct = LISA_PREDISPATCH_FUEL_PCT,
    aarTriggerFuelPct = AAR_TRIGGER_FUEL_PCT,
    aarCriticalFuelPct = AAR_CRITICAL_FUEL_PCT,
    tankerSearchRadiusNm = TANKER_SEARCH_RADIUS_NM,
    lisaRendezvous = { lat = LISA_RENDEZVOUS.lat, lon = LISA_RENDEZVOUS.lon },
    lisaRendezvousAltitudeFt = LISA_TRACK_ALTITUDE_FT,
    lisaRendezvousSpeedKt = LISA_TRACK_SPEED_KT,
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    persistentOrbit = true,
    awacsTaskUsed = false,
    fuelLowRtb = false,
    fuelLowRefuelBuiltIn = false,
    fuelLowEventDrivenAar = true,
    automaticNearestTankerFallback = true,
    dedicatedLisaPredispatch = true,
    scheduledActivationPositionGated = false,
    dcsValidatedFullLifecycle = false,
  }
end

return Controller
