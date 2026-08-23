-- Operation Mountain Watch - external E-3 AWACS physical lifecycle controller.
--
-- MOOSE-first boundary:
--   * SPAWN materializes the late-activation E-3 template outside Kabul FIR.
--   * FLIGHTGROUP executes explicit transit, AAR transfer and physical lifecycle.
--   * AUFTRAG:NewORBIT_RACETRACK provides the persistent APOC physical orbit.
--   * OPSGROUP:SwitchEmission and CONTROLLABLE radar options model the visible
--     AEW sensor state without replacing the physical orbit mission.
--   * No AUFTRAG:NewAWACS / EnRouteTaskAWACS task is required for the current
--     OMW "visible AEW actor" scope; player-side fighter control is out of scope.
--   * FLIGHTGROUP:Refuel executes the DCS receiver task after a designated tanker
--     has been verified as the nearest compatible tanker at the rendezvous.
--   * CampaignState remains the sole strategic aircraft authority through the adapter.
--
-- E-3 transfer-performance baseline:
--   * OMW uses 440 KT for the visible external/ingress/egress/AAR transfer legs.
--   * This represents the upper end of the adopted 420-440 KTAS engineering range
--     for a stabilized high-altitude transit and is not claimed as an exact
--     historical 964th EAACS flight-manual LRC schedule.
--   * APOC remains a distinct FL320 / 300 KT mission profile.

OMW = OMW or {}

local Controller = {}

local TAG = "[OMW][AWACS.Controller]"
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

local SPAWN_ALTITUDE_FT = 34000
local INBOUND_CRUISE_ALTITUDE_FT = 35000
local OUTBOUND_CRUISE_ALTITUDE_FT = 34000
local TRANSIT_SPEED_KT = 440
local SPAWN_INITIAL_SPEED_KT = 440
local LATE_APPROACH_NM = 30
local AAR_LATE_APPROACH_NM = 30
local AAR_NEAREST_TANKER_RADIUS_NM = 40

-- Afghanistan local mission clock. Afghanistan Time is UTC+04:30.
-- Graveyard-derived coverage window: 1100Z-1900Z = 1530L-2330L.
local SERVICE_START_SEC = 15 * 3600 + 30 * 60
local PLANNED_AAR_SEC = 19 * 3600 + 30 * 60
local SERVICE_END_SEC = 23 * 3600 + 30 * 60

local FIR_FIX_RADIUS_NM = 5
local TRACK_ENTRY_RADIUS_NM = 5
local HANDOFF_RADIUS_NM = 5
local DISPATCH_INTERVAL_SEC = 5
local MAX_PHYSICAL_AIRCRAFT = 2

local state = {
  strategicAdapter = nil,
  spawner = nil,
  runtimesById = {},
  activeRuntime = nil,
  nextRuntimeId = 0,
  callsignInUse = {},
  monitor = nil,
  started = false,
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
end

local function countPhysicalRuntimes()
  local count = 0
  for _, runtime in pairs(state.runtimesById) do
    if not runtime.handoffComplete and not runtime.lossHandled then count = count + 1 end
  end
  return count
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not flightGroup:IsAlive() then return nil end
  local current = flightGroup:GetCoordinate()
  return current and current:Get2DDistance(coordinate) / 1852 or nil
end

local function allocateCallsign(runtimeId)
  for number = 1, 2 do
    if not state.callsignInUse[number] then
      state.callsignInUse[number] = runtimeId
      return number
    end
  end
  fail("no free WIZARD callsign number; maximum physical E-3 count is two")
end

local function releaseCallsign(runtime)
  if runtime and runtime.callsignNumber and state.callsignInUse[runtime.callsignNumber] == runtime.runtimeId then
    state.callsignInUse[runtime.callsignNumber] = nil
  end
end

local function buildCoordinates()
  local spawn = COORDINATE:NewFromLLDD(EXTERNAL_POINT.lat, EXTERNAL_POINT.lon)
  spawn:SetAltitude(UTILS.FeetToMeters(SPAWN_ALTITUDE_FT), true)

  local rosieInbound = COORDINATE:NewFromLLDD(ROSIE.lat, ROSIE.lon)
  rosieInbound:SetAltitude(UTILS.FeetToMeters(SPAWN_ALTITUDE_FT), true)

  local rosieOutbound = COORDINATE:NewFromLLDD(ROSIE.lat, ROSIE.lon)
  rosieOutbound:SetAltitude(UTILS.FeetToMeters(OUTBOUND_CRUISE_ALTITUDE_FT), true)

  local handoff = COORDINATE:NewFromLLDD(EXTERNAL_POINT.lat, EXTERNAL_POINT.lon)
  handoff:SetAltitude(UTILS.FeetToMeters(OUTBOUND_CRUISE_ALTITUDE_FT), true)

  local track = COORDINATE:NewFromLLDD(APOC.lat, APOC.lon)
  track:SetAltitude(UTILS.FeetToMeters(TRACK_ALTITUDE_FT), true)

  local firToTrackNm = rosieInbound:Get2DDistance(track) / 1852
  if firToTrackNm <= LATE_APPROACH_NM then
    fail(string.format("ROSIE-to-APOC distance %.1f NM must exceed late approach %.1f NM", firToTrackNm, LATE_APPROACH_NM))
  end

  local lateApproach = track:GetIntermediateCoordinate(rosieInbound, LATE_APPROACH_NM / firToTrackNm)
  lateApproach:SetAltitude(UTILS.FeetToMeters(INBOUND_CRUISE_ALTITUDE_FT), true)

  return {
    spawn = spawn,
    rosieInbound = rosieInbound,
    rosieOutbound = rosieOutbound,
    handoff = handoff,
    track = track,
    lateApproach = lateApproach,
    spawnToRosieNm = spawn:Get2DDistance(rosieInbound) / 1852,
    rosieToTrackNm = firToTrackNm,
    rosieToLateNm = rosieInbound:Get2DDistance(lateApproach) / 1852,
  }
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

local function makePersistentOrbit(runtime)
  local mission = AUFTRAG:NewORBIT_RACETRACK(runtime.trackCoord, TRACK_ALTITUDE_FT, TRACK_SPEED_KT, TRACK_HEADING_DEG, TRACK_LEG_NM)
  mission:SetMissionAltitude(TRACK_ALTITUDE_FT)
  return mission
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

local function cancelPhysicalMission(runtime)
  if runtime and runtime.serviceMission and runtime.flightGroup and runtime.flightGroup:IsAlive() then
    runtime.flightGroup:MissionCancel(runtime.serviceMission)
  end
  runtime.serviceMission = nil
  runtime.serviceMissionKind = nil
end

local function addPersistentOrbit(runtime, serviceState, reason)
  cancelPhysicalMission(runtime)
  runtime.serviceMission = makePersistentOrbit(runtime)
  runtime.serviceMissionKind = "PERSISTENT_RACETRACK"
  runtime.flightGroup:AddMission(runtime.serviceMission)
  runtime.serviceState = serviceState or "STANDBY"

  if runtime.serviceState == "ACTIVE" then
    setSensorState(runtime, true, reason or "ORBIT_ACTIVE")
    runtime.lastServiceActivatedAt = now()
  else
    setSensorState(runtime, false, reason or "ORBIT_STANDBY")
  end

  log(string.format("PERSISTENT_ORBIT runtime=%s serviceState=%s missionKind=%s",
    runtime.runtimeId, runtime.serviceState, runtime.serviceMissionKind))
end

local function activateService(runtime, reason)
  if not runtime or runtime.serviceState == "CLOSED" or runtime.lossHandled or runtime.handoffComplete then return false end
  if runtime.serviceMissionKind ~= "PERSISTENT_RACETRACK" then return false end
  if not setSensorState(runtime, true, reason or "SERVICE_ACTIVE") then return false end
  runtime.serviceState = "ACTIVE"
  runtime.lastServiceActivatedAt = now()
  log(string.format("SERVICE_ACTIVE runtime=%s reason=%s callsign=Wizard%d-1 frequencyMHz=%.3f mode=PERSISTENT_ORBIT_SENSOR_TOGGLE",
    runtime.runtimeId, tostring(reason), runtime.callsignNumber, FREQUENCY_MHZ))
  return true
end

local function deactivateService(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  setSensorState(runtime, false, reason or "SERVICE_INACTIVE")
  if runtime.serviceState ~= "CLOSED" then runtime.serviceState = "STANDBY" end
  log(string.format("SERVICE_INACTIVE runtime=%s reason=%s mode=PERSISTENT_ORBIT_SENSOR_TOGGLE",
    runtime.runtimeId, tostring(reason)))
  return true
end

local function routeDirectEgress(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  if runtime.egressOrdered and runtime.firEgressDirectWaypointUid then return false end
  runtime.egressOrdered = true
  runtime.egressReason = reason
  runtime.serviceState = "CLOSED"
  setSensorState(runtime, false, "EGRESS")
  cancelPhysicalMission(runtime)
  local waypoint = runtime.flightGroup:AddWaypoint(runtime.firEgressCoord, TRANSIT_SPEED_KT, nil, OUTBOUND_CRUISE_ALTITUDE_FT, true)
  runtime.firEgressDirectWaypointUid = waypoint and waypoint.uid or true
  log(string.format("EGRESS_ORDERED runtime=%s reason=%s target=%s altitudeFt=%d speedKt=%d mode=DIRECT_WAYPOINT",
    runtime.runtimeId, tostring(reason), FIR_FIX_NAME, OUTBOUND_CRUISE_ALTITUDE_FT, TRANSIT_SPEED_KT))
  return true
end

local function handleLoss(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.lossHandled = true
  runtime.serviceState = "LOST"
  state.strategicAdapter:OnLost(runtime.selection, runtime, reason or "DEAD")
  releaseCallsign(runtime)
  state.runtimesById[runtime.runtimeId] = nil
  if state.activeRuntime == runtime then state.activeRuntime = nil end
  log(string.format("AIRCRAFT_LOST runtime=%s reason=%s action=NO_RECREDIT", runtime.runtimeId, tostring(reason)))
  return true
end

local function routeReturnFromAar(runtime)
  local distanceNm = runtime.aarRendezvousCoord:Get2DDistance(runtime.trackCoord) / 1852
  if distanceNm <= AAR_LATE_APPROACH_NM then
    fail(string.format("AAR rendezvous too close to APOC runtime=%s distanceNm=%.1f", runtime.runtimeId, distanceNm))
  end
  local approach = runtime.trackCoord:GetIntermediateCoordinate(runtime.aarRendezvousCoord, AAR_LATE_APPROACH_NM / distanceNm)
  approach:SetAltitude(UTILS.FeetToMeters(OUTBOUND_CRUISE_ALTITUDE_FT), true)
  runtime.aarReturnApproachCoord = approach
  local waypoint = runtime.flightGroup:AddWaypoint(approach, TRANSIT_SPEED_KT, nil, OUTBOUND_CRUISE_ALTITUDE_FT, true)
  runtime.aarReturnApproachUid = waypoint.uid
  runtime.aarPhase = "RETURN_TRANSFER"
  log(string.format("AAR_RETURN_TRANSFER runtime=%s altitudeFt=%d speedKt=%d lateApproachNm=%d",
    runtime.runtimeId, OUTBOUND_CRUISE_ALTITUDE_FT, TRANSIT_SPEED_KT, AAR_LATE_APPROACH_NM))
end

local function beginAarTransfer(runtime, rendezvousCoordinate, designatedTankerGroupName)
  local distanceNm = runtime.trackCoord:Get2DDistance(rendezvousCoordinate) / 1852
  if distanceNm <= AAR_LATE_APPROACH_NM then
    return false, "AWACS_AAR_RENDEZVOUS_TOO_CLOSE"
  end

  deactivateService(runtime, "AAR_TRANSFER")
  cancelPhysicalMission(runtime)
  local approach = rendezvousCoordinate:GetIntermediateCoordinate(runtime.trackCoord, AAR_LATE_APPROACH_NM / distanceNm)
  approach:SetAltitude(UTILS.FeetToMeters(OUTBOUND_CRUISE_ALTITUDE_FT), true)

  runtime.aarRendezvousCoord = rendezvousCoordinate
  runtime.designatedTankerGroupName = designatedTankerGroupName
  runtime.aarApproachCoord = approach
  runtime.aarRequested = true
  runtime.aarRequestedAt = now()
  runtime.aarPhase = "OUTBOUND_TRANSFER"
  runtime.serviceState = "INTERRUPTED_AAR"

  local waypoint = runtime.flightGroup:AddWaypoint(approach, TRANSIT_SPEED_KT, nil, OUTBOUND_CRUISE_ALTITUDE_FT, true)
  runtime.aarApproachUid = waypoint.uid

  log(string.format("AAR_TRANSFER_STARTED runtime=%s tanker=%s altitudeFt=%d speedKt=%d rendezvousDistanceNm=%.1f",
    runtime.runtimeId, tostring(designatedTankerGroupName), OUTBOUND_CRUISE_ALTITUDE_FT, TRANSIT_SPEED_KT, distanceNm))
  return true
end

local function materialize(role, reason)
  requireMoose()
  if countPhysicalRuntimes() >= MAX_PHYSICAL_AIRCRAFT then return nil, "MAX_PHYSICAL_AIRCRAFT" end

  local selection = makeSelection(role)
  local allowed, strategicReason = state.strategicAdapter:CanMaterialize(selection)
  if not allowed then return nil, strategicReason or "STRATEGIC_UNAVAILABLE" end

  state.nextRuntimeId = state.nextRuntimeId + 1
  local runtimeId = string.format("AWACS-%04d", state.nextRuntimeId)
  local callsignNumber = allocateCallsign(runtimeId)
  local coords = buildCoordinates()

  if not state.spawner then state.spawner = SPAWN:New(TEMPLATE) end
  state.spawner:InitCallSign(CALLSIGN.AWACS.Wizard, "Wizard", callsignNumber, 1)
  state.spawner:InitHeading(coords.spawn:HeadingTo(coords.rosieInbound))
  state.spawner:InitSpeedKnots(SPAWN_INITIAL_SPEED_KT)

  local group = state.spawner:SpawnFromCoordinate(coords.spawn)
  if not group then
    state.callsignInUse[callsignNumber] = nil
    fail("failed to materialize AWACS template=" .. TEMPLATE)
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then fail("failed to create FLIGHTGROUP group=" .. tostring(group:GetName())) end

  local runtime = {
    runtimeId = runtimeId,
    role = role,
    selection = selection,
    reason = reason,
    group = group,
    flightGroup = flightGroup,
    callsignNumber = callsignNumber,
    spawnCoord = coords.spawn,
    firIngressCoord = coords.rosieInbound,
    firEgressCoord = coords.rosieOutbound,
    lateApproachCoord = coords.lateApproach,
    trackCoord = coords.track,
    externalHandoffCoord = coords.handoff,
    spawnToFirNm = coords.spawnToRosieNm,
    firToTrackNm = coords.rosieToTrackNm,
    firToLateApproachNm = coords.rosieToLateNm,
    routeDistanceNm = coords.spawnToRosieNm + coords.rosieToTrackNm,
    firWaypointUid = nil,
    lateWaypointUid = nil,
    firIngressPassed = false,
    lateApproachPassed = false,
    physicalOnTrack = false,
    serviceState = "INBOUND",
    sensorState = "SILENT",
    serviceMission = nil,
    serviceMissionKind = nil,
    egressOrdered = false,
    firEgressDirectWaypointUid = nil,
    firEgressPassed = false,
    externalHandoffRouted = false,
    handoffComplete = false,
    lossHandled = false,
    materializedAt = now(),
    aarRequested = false,
    aarPhase = nil,
    aarCompletedAt = nil,
    aarApproachUid = nil,
    aarReturnApproachUid = nil,
  }

  setSensorState(runtime, false, "MATERIALIZED_INBOUND")

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or runtime.lossHandled or runtime.handoffComplete then return end

    if Waypoint.uid == runtime.firWaypointUid and not runtime.firIngressPassed then
      runtime.firIngressPassed = true
      runtime.firIngressPassedAt = now()
      log(string.format("FIR_INGRESS_PASSED runtime=%s fix=%s waypointUid=%d", runtime.runtimeId, FIR_FIX_NAME, Waypoint.uid))
      return
    end

    if Waypoint.uid == runtime.lateWaypointUid and not runtime.lateApproachPassed then
      if not runtime.firIngressPassed then fail("late approach reached before ROSIE runtime=" .. runtime.runtimeId) end
      runtime.lateApproachPassed = true
      runtime.lateApproachPassedAt = now()
      local initialState = clockSec() < SERVICE_START_SEC and "STANDBY" or "ACTIVE"
      addPersistentOrbit(runtime, initialState, initialState == "ACTIVE" and "ARRIVED_AFTER_SERVICE_START" or "ARRIVED_BEFORE_SERVICE_START")
      log(string.format("LATE_APPROACH_PASSED runtime=%s distanceToTrackNm=%.1f", runtime.runtimeId, LATE_APPROACH_NM))
      return
    end

    if runtime.aarApproachUid and Waypoint.uid == runtime.aarApproachUid and runtime.aarPhase == "OUTBOUND_TRANSFER" then
      local nearest = runtime.flightGroup:FindNearestTanker(AAR_NEAREST_TANKER_RADIUS_NM)
      if not nearest then
        fail("designated tanker unavailable near AAR rendezvous runtime=" .. runtime.runtimeId)
      end
      if nearest:GetName() ~= runtime.designatedTankerGroupName then
        fail(string.format("nearest tanker mismatch runtime=%s expected=%s actual=%s",
          runtime.runtimeId, tostring(runtime.designatedTankerGroupName), tostring(nearest:GetName())))
      end
      runtime.aarPhase = "REFUELING"
      runtime.aarRefuelTaskAt = now()
      log(string.format("AAR_REFUEL_TASK runtime=%s tanker=%s", runtime.runtimeId, runtime.designatedTankerGroupName))
      runtime.flightGroup:Refuel(runtime.aarRendezvousCoord)
      return
    end

    if runtime.aarReturnApproachUid and Waypoint.uid == runtime.aarReturnApproachUid and runtime.aarPhase == "RETURN_TRANSFER" then
      if runtime.closePending or clockSec() >= SERVICE_END_SEC then
        runtime.aarPhase = "COMPLETE_CLOSED"
        routeDirectEgress(runtime, "SERVICE_WINDOW_ENDED_DURING_AAR_RETURN")
      else
        runtime.aarPhase = "REJOINING"
        addPersistentOrbit(runtime, "REJOINING", "AAR_RETURN_LATE_APPROACH")
        log(string.format("AAR_RETURN_LATE_APPROACH runtime=%s action=ADD_PERSISTENT_ORBIT", runtime.runtimeId))
      end
    end
  end

  function flightGroup:OnAfterRefueled(From, Event, To)
    if runtime.lossHandled or runtime.handoffComplete then return end
    runtime.aarCompletedAt = now()
    runtime.aarPhase = "REFUELED"
    log(string.format("AAR_REFUELED runtime=%s tanker=%s", runtime.runtimeId, tostring(runtime.designatedTankerGroupName)))
    if clockSec() >= SERVICE_END_SEC or runtime.closePending then
      runtime.serviceState = "CLOSED"
      routeDirectEgress(runtime, "SERVICE_WINDOW_ENDED_DURING_AAR")
    else
      routeReturnFromAar(runtime)
    end
  end

  function flightGroup:OnAfterDead(From, Event, To)
    handleLoss(runtime, "MOOSE_FLIGHTGROUP_DEAD")
  end

  local firWaypoint = flightGroup:AddWaypoint(coords.rosieInbound, TRANSIT_SPEED_KT, nil, SPAWN_ALTITUDE_FT, false)
  local lateWaypoint = flightGroup:AddWaypoint(coords.lateApproach, TRANSIT_SPEED_KT, firWaypoint.uid, INBOUND_CRUISE_ALTITUDE_FT, true)
  runtime.firWaypointUid = firWaypoint.uid
  runtime.lateWaypointUid = lateWaypoint.uid

  state.runtimesById[runtimeId] = runtime
  state.activeRuntime = runtime
  state.strategicAdapter:OnMaterialized(selection, runtime)

  log(string.format(
    "MATERIALIZED runtime=%s role=%s source=%s spawnToRosieNm=%.2f rosieToApocNm=%.2f firToLateNm=%.2f callsign=Wizard%d-1 frequencyMHz=%.3f spawnSpeedKt=%d transitSpeedKt=%d serviceStartLocalSec=%d serviceEndLocalSec=%d plannedAarLocalSec=%d",
    runtime.runtimeId, role, SOURCE_DOMAIN, runtime.spawnToFirNm, runtime.firToTrackNm,
    runtime.firToLateApproachNm, callsignNumber, FREQUENCY_MHZ, SPAWN_INITIAL_SPEED_KT, TRANSIT_SPEED_KT,
    SERVICE_START_SEC, SERVICE_END_SEC, PLANNED_AAR_SEC))

  return runtime
end

local function monitor()
  local runtime = state.activeRuntime
  if not runtime or runtime.lossHandled or runtime.handoffComplete or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return end

  local timestamp = now()
  local localSec = clockSec()

  if runtime.lateApproachPassed and not runtime.egressOrdered then
    local distanceNm = getDistanceNm(runtime.flightGroup, runtime.trackCoord)
    if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
      if not runtime.physicalOnTrack then
        runtime.physicalOnTrack = true
        runtime.physicalOnTrackAt = timestamp
        log(string.format("ON_TRACK runtime=%s area=%s serviceState=%s sensorState=%s",
          runtime.runtimeId, AREA_NAME, runtime.serviceState, runtime.sensorState))
      end
      if runtime.serviceState == "REJOINING" then
        runtime.aarPhase = "COMPLETE"
        activateService(runtime, "AAR_RETURN_ON_STATION")
        log(string.format("AAR_RETURN_ON_STATION runtime=%s serviceState=%s sensorState=%s",
          runtime.runtimeId, runtime.serviceState, runtime.sensorState))
      elseif runtime.serviceState == "STANDBY" and localSec >= SERVICE_START_SEC and localSec < SERVICE_END_SEC then
        activateService(runtime, "SCHEDULED_1100Z_START")
      end
    end
  end

  if not runtime.egressOrdered and localSec >= SERVICE_END_SEC and runtime.serviceState ~= "CLOSED" then
    runtime.serviceClosedAt = timestamp
    deactivateService(runtime, "SCHEDULED_1900Z_END")
    runtime.serviceState = "CLOSED"
    log(string.format("SERVICE_CLOSED runtime=%s localSec=%.1f scheduledLocalSec=%d", runtime.runtimeId, localSec, SERVICE_END_SEC))
    if runtime.aarPhase == "OUTBOUND_TRANSFER" or runtime.aarPhase == "REFUELING" or runtime.aarPhase == "RETURN_TRANSFER" then
      runtime.closePending = true
    else
      routeDirectEgress(runtime, "SCHEDULED_1900Z_END")
    end
  end

  if runtime.egressOrdered then
    if not runtime.firEgressPassed then
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.firEgressCoord)
      if distanceNm and distanceNm <= FIR_FIX_RADIUS_NM then
        runtime.firEgressPassed = true
        runtime.firEgressPassedAt = timestamp
        runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord, TRANSIT_SPEED_KT, nil, OUTBOUND_CRUISE_ALTITUDE_FT)
        runtime.externalHandoffRouted = true
        log(string.format("FIR_EGRESS_PASSED runtime=%s fix=%s action=ROUTE_EXTERNAL_HANDOFF", runtime.runtimeId, FIR_FIX_NAME))
      end
    else
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.externalHandoffCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        runtime.handoffComplete = true
        state.strategicAdapter:OnHandoff(runtime.selection, runtime)
        runtime.flightGroup:Despawn(1, true)
        releaseCallsign(runtime)
        state.runtimesById[runtime.runtimeId] = nil
        state.activeRuntime = nil
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
  log("STARTED template=" .. TEMPLATE .. " area=" .. AREA_NAME .. " firFix=" .. FIR_FIX_NAME .. " serviceMode=PERSISTENT_ORBIT_SENSOR_TOGGLE")
  return runtime
end

function Controller.RequestEgress(reason)
  return routeDirectEgress(state.activeRuntime, reason or "REQUESTED_EGRESS")
end

function Controller.RequestRefuel(rendezvousCoordinate, designatedTankerGroupName)
  local runtime = state.activeRuntime
  if not runtime or not runtime.flightGroup or not runtime.flightGroup:IsAlive() then return false, "AWACS_NOT_AVAILABLE" end
  if runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false, "AWACS_NOT_REFUELABLE_STATE" end
  if runtime.aarRequested then return false, "AWACS_AAR_ALREADY_REQUESTED" end
  if runtime.serviceState ~= "ACTIVE" then return false, "AWACS_SERVICE_NOT_ACTIVE" end
  if rendezvousCoordinate == nil then return false, "AWACS_AAR_RENDEZVOUS_REQUIRED" end
  if type(designatedTankerGroupName) ~= "string" or designatedTankerGroupName == "" then
    return false, "AWACS_AAR_TANKER_REQUIRED"
  end

  local nearest = runtime.flightGroup:FindNearestTanker(AAR_NEAREST_TANKER_RADIUS_NM)
  if nearest and nearest:GetName() ~= designatedTankerGroupName then
    log(string.format("AAR_NEAREST_TANKER_PRECHECK expected=%s actual=%s action=TRANSFER_ALLOWED_RECHECK_AT_APPROACH",
      designatedTankerGroupName, nearest:GetName()))
  end

  return beginAarTransfer(runtime, rendezvousCoordinate, designatedTankerGroupName)
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
    spawnAltitudeFt = SPAWN_ALTITUDE_FT,
    spawnInitialSpeedKt = SPAWN_INITIAL_SPEED_KT,
    inboundCruiseAltitudeFt = INBOUND_CRUISE_ALTITUDE_FT,
    outboundCruiseAltitudeFt = OUTBOUND_CRUISE_ALTITUDE_FT,
    transitSpeedKt = TRANSIT_SPEED_KT,
    trackAltitudeFt = TRACK_ALTITUDE_FT,
    trackSpeedKt = TRACK_SPEED_KT,
    trackHeadingDeg = TRACK_HEADING_DEG,
    trackLegNm = TRACK_LEG_NM,
    lateApproachNm = LATE_APPROACH_NM,
    serviceStartLocalSec = SERVICE_START_SEC,
    plannedAarLocalSec = PLANNED_AAR_SEC,
    serviceEndLocalSec = SERVICE_END_SEC,
    serviceWindowSec = SERVICE_END_SEC - SERVICE_START_SEC,
    aarLateApproachNm = AAR_LATE_APPROACH_NM,
    maxPhysicalAircraft = MAX_PHYSICAL_AIRCRAFT,
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    refuelDispatchAccepted = false,
    designatedRefuelReceiverPath = true,
    persistentOrbit = true,
    awacsTaskUsed = false,
    sensorControl = "SWITCH_EMISSION_PLUS_RADAR_OPTION",
  }
end

return Controller