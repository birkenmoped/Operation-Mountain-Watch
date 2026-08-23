-- Operation Mountain Watch - external E-3 AWACS physical lifecycle controller.
--
-- MOOSE-first boundary:
--   * SPAWN materializes the late-activation E-3 template outside Kabul FIR.
--   * FLIGHTGROUP executes explicit transit waypoints and the physical lifecycle.
--   * AUFTRAG:NewAWACS executes the DCS AWACS racetrack mission.
--   * CampaignState is the sole strategic aircraft authority through the injected adapter.
--   * The MOOSE AWACS AI-controller class is intentionally not used here; its FEZ/SRS/
--     home-airbase lifecycle does not match the off-map Afghanistan support contract.
--
-- Runtime status: source-reviewed/staged. DCS acceptance is still required.

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

-- External materialization point: geodetic point on the modern ZHOB->BIROS geometry,
-- exactly 15 NM before the period-correct ROSIE fix. This is an OMW abstraction,
-- not a claim that the 2010/11 Pakistan ATS segment used the modern BIROS naming.
local EXTERNAL_POINT = { lat = 31.5117470464, lon = 69.2298100106 }
local ROSIE = { lat = 31.6666666667, lon = 68.9997166667 }
local APOC = { lat = 32.6850000000, lon = 69.0500000000 }

-- No-RVSM semi-circular transit planning:
-- external point -> ROSIE is westbound, therefore FL340;
-- ROSIE -> APOC is north/eastbound, therefore FL350 until late approach;
-- AWACS mission then transitions to FL320.
local SPAWN_ALTITUDE_FT = 34000
local INBOUND_CRUISE_ALTITUDE_FT = 35000
local OUTBOUND_CRUISE_ALTITUDE_FT = 34000
local TRANSIT_SPEED_KT = 300
local SPAWN_INITIAL_SPEED_KT = 400
local LATE_APPROACH_NM = 30

local FIR_FIX_RADIUS_NM = 5
local TRACK_ENTRY_RADIUS_NM = 5
local HANDOFF_RADIUS_NM = 5
local DISPATCH_INTERVAL_SEC = 5
local STATION_CYCLE_SEC = 6 * 60 * 60
local RELIEF_HANDOVER_ETA_SEC = 5 * 60
local MAX_PHYSICAL_AIRCRAFT = 2

local state = {
  strategicAdapter = nil,
  spawner = nil,
  runtimesById = {},
  activeRuntime = nil,
  reliefRuntime = nil,
  nextRuntimeId = 0,
  callsignInUse = {},
  monitor = nil,
  started = false,
  reliefQueued = false,
  nextPlannedHandoverAt = nil,
  reliefLaunchAt = nil,
}

local ensureRelief

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function now()
  return timer.getAbsTime()
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

local function cancelToEgress(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.egressOrdered = true
  runtime.egressReason = reason
  if not runtime.missionAdded then
    runtime.missionAdded = true
    runtime.missionAddedAt = now()
    runtime.flightGroup:AddMission(runtime.mission)
    log(string.format("MISSION_ADDED runtime=%s reason=PRETRACK_EGRESS", runtime.runtimeId))
  end
  runtime.mission:Cancel()
  log(string.format("EGRESS_ORDERED runtime=%s reason=%s target=%s altitudeFt=%d speedKt=%d",
    runtime.runtimeId, tostring(reason), FIR_FIX_NAME, OUTBOUND_CRUISE_ALTITUDE_FT, TRANSIT_SPEED_KT))
  return true
end

local function handleLoss(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.lossHandled = true
  state.strategicAdapter:OnLost(runtime.selection, runtime, reason or "DEAD")
  releaseCallsign(runtime)
  state.runtimesById[runtime.runtimeId] = nil
  if state.activeRuntime == runtime then state.activeRuntime = nil end
  if state.reliefRuntime == runtime then state.reliefRuntime = nil end

  if state.started then
    if state.activeRuntime and state.activeRuntime.flightGroup and state.activeRuntime.flightGroup:IsAlive() then
      ensureRelief("LOSS_REPLACEMENT")
    else
      ensureRelief("ACTIVE_LOSS")
    end
  end

  log(string.format("AIRCRAFT_LOST runtime=%s reason=%s action=NO_RECREDIT", runtime.runtimeId, tostring(reason)))
  return true
end

local function scheduleCycle(runtime, timestamp)
  runtime.onStationAt = timestamp
  local visibleTransitSec = (runtime.routeDistanceNm / TRANSIT_SPEED_KT) * 3600
  state.nextPlannedHandoverAt = timestamp + STATION_CYCLE_SEC
  state.reliefLaunchAt = state.nextPlannedHandoverAt - math.max(0, visibleTransitSec - RELIEF_HANDOVER_ETA_SEC)
  log(string.format("ON_STATION runtime=%s area=%s cycleSec=%d reliefLaunchInSec=%.0f",
    runtime.runtimeId, AREA_NAME, STATION_CYCLE_SEC, state.reliefLaunchAt - timestamp))
end

local function promoteRelief(relief, timestamp)
  local outgoing = state.activeRuntime
  if outgoing and outgoing ~= relief and not outgoing.egressOrdered then
    cancelToEgress(outgoing, "SCHEDULED_RELIEF")
  end
  state.reliefRuntime = nil
  state.reliefQueued = false
  state.activeRuntime = relief
  relief.role = "ACTIVE"
  scheduleCycle(relief, timestamp)
  log(string.format("RELIEF_ON_STATION runtime=%s outgoingRuntime=%s", relief.runtimeId,
    outgoing and outgoing.runtimeId or "NONE"))
end

local function materialize(role, reason)
  requireMoose()
  if countPhysicalRuntimes() >= MAX_PHYSICAL_AIRCRAFT then
    return nil, "MAX_PHYSICAL_AIRCRAFT"
  end

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

  local mission = AUFTRAG:NewAWACS(coords.track, TRACK_ALTITUDE_FT, TRACK_SPEED_KT, TRACK_HEADING_DEG, TRACK_LEG_NM)
  mission:SetMissionAltitude(TRACK_ALTITUDE_FT)
  mission:SetMissionEgressCoord(coords.rosieOutbound, OUTBOUND_CRUISE_ALTITUDE_FT, TRANSIT_SPEED_KT)

  local runtime = {
    runtimeId = runtimeId,
    role = role,
    selection = selection,
    reason = reason,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
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
    missionAdded = false,
    onStationAt = nil,
    egressOrdered = false,
    firEgressPassed = false,
    externalHandoffRouted = false,
    handoffComplete = false,
    lossHandled = false,
    refuelRequested = false,
    materializedAt = now(),
  }

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or runtime.egressOrdered or runtime.lossHandled then return end
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
      if not runtime.missionAdded then
        runtime.missionAdded = true
        runtime.missionAddedAt = runtime.lateApproachPassedAt
        runtime.flightGroup:AddMission(runtime.mission)
      end
      log(string.format("LATE_APPROACH_PASSED runtime=%s distanceToTrackNm=%.1f action=ADD_AWACS_MISSION",
        runtime.runtimeId, LATE_APPROACH_NM))
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
  if role == "RELIEF" then
    state.reliefRuntime = runtime
    state.reliefQueued = false
  else
    state.activeRuntime = runtime
  end

  state.strategicAdapter:OnMaterialized(selection, runtime)

  log(string.format(
    "MATERIALIZED runtime=%s role=%s source=%s spawnToRosieNm=%.2f rosieToApocNm=%.2f firToLateNm=%.2f callsign=Wizard%d-1 frequencyMHz=%.3f",
    runtime.runtimeId, role, SOURCE_DOMAIN, runtime.spawnToFirNm, runtime.firToTrackNm,
    runtime.firToLateApproachNm, callsignNumber, FREQUENCY_MHZ))

  return runtime
end

ensureRelief = function(reason)
  if state.reliefRuntime and state.reliefRuntime.flightGroup and state.reliefRuntime.flightGroup:IsAlive()
      and not state.reliefRuntime.egressOrdered and not state.reliefRuntime.lossHandled then
    return state.reliefRuntime, false
  end
  if state.reliefQueued then return nil, false end
  if countPhysicalRuntimes() >= MAX_PHYSICAL_AIRCRAFT then return nil, false end

  state.reliefQueued = true
  local runtime, err = materialize("RELIEF", reason or "SCHEDULED")
  if not runtime then
    state.reliefQueued = false
    log(string.format("RELIEF_DEFERRED reason=%s", tostring(err)))
    return nil, false
  end
  return runtime, true
end

local function monitor()
  local timestamp = now()
  local active = state.activeRuntime
  if active and active.flightGroup and active.flightGroup:IsAlive() and not active.egressOrdered and not active.lossHandled then
    if active.firIngressPassed and active.lateApproachPassed and active.missionAdded and not active.onStationAt then
      local distanceNm = getDistanceNm(active.flightGroup, active.trackCoord)
      if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then scheduleCycle(active, timestamp) end
    end
    if active.onStationAt and state.reliefLaunchAt and timestamp >= state.reliefLaunchAt then
      ensureRelief("SCHEDULED")
    end
  end

  local relief = state.reliefRuntime
  if relief and relief.flightGroup and relief.flightGroup:IsAlive() and not relief.egressOrdered and not relief.lossHandled
      and relief.firIngressPassed and relief.lateApproachPassed and relief.missionAdded then
    local distanceNm = getDistanceNm(relief.flightGroup, relief.trackCoord)
    if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then promoteRelief(relief, timestamp) end
  end

  for runtimeId, runtime in pairs(state.runtimesById) do
    if runtime.egressOrdered and not runtime.handoffComplete and not runtime.lossHandled
        and runtime.flightGroup and runtime.flightGroup:IsAlive() then
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
          state.runtimesById[runtimeId] = nil
          if state.activeRuntime == runtime then state.activeRuntime = nil end
          if state.reliefRuntime == runtime then state.reliefRuntime = nil end
          log(string.format("EXTERNAL_HANDOFF runtime=%s action=DESPAWN_AND_RECREDIT", runtime.runtimeId))
        end
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
  log("STARTED template=" .. TEMPLATE .. " area=" .. AREA_NAME .. " firFix=" .. FIR_FIX_NAME)
  return runtime
end

function Controller.RequestEgress(reason)
  return cancelToEgress(state.activeRuntime, reason or "REQUESTED_EGRESS")
end

-- Source-reviewed MOOSE integration boundary for later DCS acceptance.
-- FLIGHTGROUP:Refuel(...) pauses the current mission and resumes it after the
-- refuelling task, but it does not provide an OMW policy for selecting a
-- specific reserve tanker. Until that end-to-end path is accepted in DCS,
-- the production controller must not silently dispatch the E-3 to an arbitrary
-- nearest tanker. The AAR subsystem may instead bring a reserve tanker to APOC.
function Controller.RequestRefuel(rendezvousCoordinate)
  if rendezvousCoordinate == nil then
    return false, "AWACS_AAR_RENDEZVOUS_REQUIRED"
  end
  return false, "AWACS_AAR_DCS_ACCEPTANCE_REQUIRED"
end

function Controller.GetRuntime()
  return state.activeRuntime
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
    inboundCruiseAltitudeFt = INBOUND_CRUISE_ALTITUDE_FT,
    outboundCruiseAltitudeFt = OUTBOUND_CRUISE_ALTITUDE_FT,
    transitSpeedKt = TRANSIT_SPEED_KT,
    trackAltitudeFt = TRACK_ALTITUDE_FT,
    trackSpeedKt = TRACK_SPEED_KT,
    trackHeadingDeg = TRACK_HEADING_DEG,
    trackLegNm = TRACK_LEG_NM,
    lateApproachNm = LATE_APPROACH_NM,
    stationCycleSec = STATION_CYCLE_SEC,
    maxPhysicalAircraft = MAX_PHYSICAL_AIRCRAFT,
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    refuelDispatchAccepted = false,
  }
end

return Controller