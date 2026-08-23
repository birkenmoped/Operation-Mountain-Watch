-- Operation Mountain Watch - AWACS full-duration coverage and AAR acceptance.
--
-- Test-only MOOSE-first observer/coordinator for the production AWACS foundation.
-- It validates one complete 1530L-2330L coverage period and creates one visible
-- LISA reserve-tanker rendezvous using the already-running AAR subsystem's shared
-- CampaignState adapter. It does not create a second strategic resource authority.

local Acceptance2 = {}

local TAG = "[OMW][AWACS.Acceptance2]"
local SAMPLE_INTERVAL_SEC = 60
local DISPATCH_INTERVAL_SEC = 5
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local SERVICE_START_SEC = 15 * 3600 + 30 * 60
local TANKER_DISPATCH_SEC = 18 * 3600 + 10 * 60
local AAR_TARGET_SEC = 19 * 3600 + 30 * 60
local SERVICE_END_SEC = 23 * 3600 + 30 * 60

local TANKER_TEMPLATE = "OMW_AAR_KC135_LISA"
local TANKER_SOURCE_DOMAIN = "AL_UDEID"
local TANKER_MISSION_DEMAND_ID = "AWACS-AAR-APOC-1930"
local TANKER_TRACK_ALTITUDE_FT = 25000
local TANKER_TRACK_SPEED_KT = 300
local TANKER_TRACK_HEADING_DEG = 340
local TANKER_TRACK_LEG_NM = 20
local TANKER_LATE_APPROACH_NM = 60
local TANKER_INGRESS_ALTITUDE_FT = 35000
local TANKER_EGRESS_ALTITUDE_FT = 34000
local TRANSIT_SPEED_KT = 300
local TANKER_TRACK_ENTRY_RADIUS_NM = 5
local TANKER_FIR_RADIUS_NM = 5
local TANKER_HANDOFF_RADIUS_NM = 10

local AL_UDEID_EXTERNAL = { lat = 28.90264890, lon = 64.61166667 }
local DAVER = { lat = 29.57166667, lon = 64.67666667 }
-- 60 NM from APOC on bearing 340T. Keeps the AAR orbit separated from APOC and
-- more than 60 NM from the nearest standard KRUSTY tanker anchor.
local AAR_RENDEZVOUS = { lat = 33.6233926368, lon = 68.6395554105 }

local state = {
  sampleScheduler = nil,
  controlScheduler = nil,
  samples = 0,
  tanker = nil,
  tankerDispatched = false,
  tankerReady = false,
  awacsAarRequested = false,
  awacsAarCompleted = false,
  tankerEgressOrdered = false,
  tankerFirEgressPassed = false,
  tankerHandoffComplete = false,
  complete = false,
  lastAwacsServiceState = nil,
  serviceActiveObserved = false,
  serviceClosedObserved = false,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireMoose()
  if not SCHEDULER or not SPAWN or not FLIGHTGROUP or not AUFTRAG or not COORDINATE or not UTILS then
    fail("required MOOSE classes/utilities are unavailable")
  end
  if not CALLSIGN or not CALLSIGN.Tanker or not CALLSIGN.Tanker.Texaco then
    fail("required tanker callsign enumerator is unavailable")
  end
  if not Unit or not Unit.RefuelingSystem or Unit.RefuelingSystem.BOOM_AND_RECEPTACLE == nil then
    fail("DCS boom refueling-system enum is unavailable")
  end
end

local function getAwacsFacade()
  if not OMW or not OMW.AirOps or not OMW.AirOps.AWACS then return nil end
  local facade = OMW.AirOps.AWACS
  if facade.Status ~= "RUNNING" or type(facade.GetRuntime) ~= "function"
      or type(facade.GetServiceState) ~= "function" or type(facade.RequestRefuel) ~= "function" then
    return nil
  end
  return facade
end

local function getAarFacade()
  if not OMW or not OMW.AirOps or not OMW.AirOps.AAR then return nil end
  local facade = OMW.AirOps.AAR
  if facade.Status ~= "RUNNING" or type(facade.StrategicAdapter) ~= "table" then return nil end
  return facade
end

local function fmt(value, format, fallback)
  if type(value) ~= "number" then return fallback or "NA" end
  return string.format(format, value)
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not flightGroup:IsAlive() then return nil end
  local current = flightGroup:GetCoordinate()
  return current and current:Get2DDistance(coordinate) / 1852 or nil
end

local function readAwacsTelemetry(runtime)
  local flightGroup = runtime and runtime.flightGroup or nil
  if not flightGroup or not flightGroup:IsAlive() then return nil end

  local coordinate = flightGroup:GetCoordinate()
  local velocityMps = flightGroup:GetVelocity()
  local altitudeFt = flightGroup:GetAltitude()
  local headingDeg = flightGroup:GetHeading()
  local fuelPct = flightGroup:GetFuelMin()

  local group = flightGroup:GetGroup()
  local unit = group and group:GetUnit(1) or nil
  local fuelKg = nil
  local fuelMaxKg = nil
  if unit and unit:IsAlive() then
    fuelKg = unit:GetCurrentFuelKgs()
    local _, maxFuel = unit:GetFuelMassMax()
    fuelMaxKg = maxFuel
  end

  local lat, lon = nil, nil
  if coordinate then lat, lon = coordinate:GetLLDDM() end

  return {
    altitudeFt = altitudeFt,
    speedKt = velocityMps and UTILS.MpsToKnots(velocityMps) or nil,
    headingDeg = headingDeg,
    fuelPct = fuelPct,
    fuelKg = fuelKg,
    fuelMaxKg = fuelMaxKg,
    lat = lat,
    lon = lon,
  }
end

local function logAwacsTelemetry(runtime, telemetry)
  state.samples = state.samples + 1
  log(string.format(
    "TELEMETRY seq=%d runtime=%s localSec=%.1f serviceState=%s aarPhase=%s altFt=%s speedKt=%s headingDeg=%s fuelPct=%s fuelKg=%s fuelMaxKg=%s lat=%s lon=%s",
    state.samples,
    tostring(runtime.runtimeId),
    UTILS.SecondsOfToday(),
    tostring(runtime.serviceState),
    tostring(runtime.aarPhase or "NONE"),
    fmt(telemetry.altitudeFt, "%.0f"),
    fmt(telemetry.speedKt, "%.1f"),
    fmt(telemetry.headingDeg, "%.1f"),
    fmt(telemetry.fuelPct, "%.3f"),
    fmt(telemetry.fuelKg, "%.1f"),
    fmt(telemetry.fuelMaxKg, "%.1f"),
    fmt(telemetry.lat, "%.6f"),
    fmt(telemetry.lon, "%.6f")
  ))
end

local function buildTankerCoordinates()
  local spawn = COORDINATE:NewFromLLDD(AL_UDEID_EXTERNAL.lat, AL_UDEID_EXTERNAL.lon)
  spawn:SetAltitude(UTILS.FeetToMeters(TANKER_INGRESS_ALTITUDE_FT), true)

  local daverInbound = COORDINATE:NewFromLLDD(DAVER.lat, DAVER.lon)
  daverInbound:SetAltitude(UTILS.FeetToMeters(TANKER_INGRESS_ALTITUDE_FT), true)

  local daverOutbound = COORDINATE:NewFromLLDD(DAVER.lat, DAVER.lon)
  daverOutbound:SetAltitude(UTILS.FeetToMeters(TANKER_EGRESS_ALTITUDE_FT), true)

  local handoff = COORDINATE:NewFromLLDD(AL_UDEID_EXTERNAL.lat, AL_UDEID_EXTERNAL.lon)
  handoff:SetAltitude(UTILS.FeetToMeters(TANKER_EGRESS_ALTITUDE_FT), true)

  local rendezvous = COORDINATE:NewFromLLDD(AAR_RENDEZVOUS.lat, AAR_RENDEZVOUS.lon)
  rendezvous:SetAltitude(UTILS.FeetToMeters(TANKER_TRACK_ALTITUDE_FT), true)

  local firToTrackNm = daverInbound:Get2DDistance(rendezvous) / 1852
  if firToTrackNm <= TANKER_LATE_APPROACH_NM then
    fail("DAVER-to-AAR rendezvous distance is too short")
  end
  local lateApproach = rendezvous:GetIntermediateCoordinate(daverInbound, TANKER_LATE_APPROACH_NM / firToTrackNm)
  lateApproach:SetAltitude(UTILS.FeetToMeters(TANKER_INGRESS_ALTITUDE_FT), true)

  return {
    spawn = spawn,
    daverInbound = daverInbound,
    daverOutbound = daverOutbound,
    handoff = handoff,
    rendezvous = rendezvous,
    lateApproach = lateApproach,
    routeDistanceNm = spawn:Get2DDistance(daverInbound) / 1852 + firToTrackNm,
  }
end

local function tankerSelection()
  return {
    missionDemandId = TANKER_MISSION_DEMAND_ID,
    receiverProfile = "FAST",
    requestedReceiverProfile = "FAST",
    operationsArea = "AWACS_APOC",
    supportMode = "SUPPORT",
    priority = "AWACS_PLANNED_AAR",
    area = "LISA",
    sourceDomain = TANKER_SOURCE_DOMAIN,
    transitProfile = "AL_UDEID_NORTH_HIGH",
    firFix = "DAVER",
    continuousCore = false,
    availability = "RESERVE",
  }
end

local function orderTankerEgress(reason)
  local tanker = state.tanker
  if not tanker or tanker.egressOrdered or tanker.lossHandled or tanker.handoffComplete then return false end
  tanker.egressOrdered = true
  tanker.egressReason = reason
  tanker.mission:Cancel()
  state.tankerEgressOrdered = true
  log(string.format("TANKER_EGRESS_ORDERED runtime=%s reason=%s target=DAVER altitudeFt=%d speedKt=%d",
    tanker.runtimeId, tostring(reason), TANKER_EGRESS_ALTITUDE_FT, TRANSIT_SPEED_KT))
  return true
end

local function handleTankerLoss(reason)
  local tanker = state.tanker
  if not tanker or tanker.lossHandled or tanker.handoffComplete then return false end
  tanker.lossHandled = true
  tanker.adapter:OnLost(tanker.selection, tanker, reason or "DEAD")
  log(string.format("TANKER_LOST runtime=%s reason=%s action=NO_RECREDIT", tanker.runtimeId, tostring(reason)))
  return true
end

local function dispatchTanker()
  if state.tankerDispatched then return end
  local aar = getAarFacade()
  if not aar then fail("AAR facade must be running before AWACS tanker dispatch") end

  local adapter = aar.StrategicAdapter
  if type(adapter.CanMaterialize) ~= "function" or type(adapter.OnMaterialized) ~= "function"
      or type(adapter.OnHandoff) ~= "function" or type(adapter.OnLost) ~= "function" then
    fail("AAR strategic adapter lifecycle API is unavailable")
  end

  local selection = tankerSelection()
  local allowed, reason = adapter:CanMaterialize(selection)
  if not allowed then fail("planned AWACS reserve tanker unavailable: " .. tostring(reason)) end

  local coords = buildTankerCoordinates()
  local spawner = SPAWN:New(TANKER_TEMPLATE)
  spawner:InitCallSign(CALLSIGN.Tanker.Texaco, "Texaco", 3, 1)
  spawner:InitHeading(coords.spawn:HeadingTo(coords.daverInbound))
  spawner:InitSpeedKnots(480)

  local group = spawner:SpawnFromCoordinate(coords.spawn)
  if not group then fail("failed to materialize AWACS reserve tanker template=" .. TANKER_TEMPLATE) end
  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then fail("failed to create AWACS reserve tanker FLIGHTGROUP") end

  local mission = AUFTRAG:NewTANKER(
    coords.rendezvous,
    TANKER_TRACK_ALTITUDE_FT,
    TANKER_TRACK_SPEED_KT,
    TANKER_TRACK_HEADING_DEG,
    TANKER_TRACK_LEG_NM,
    Unit.RefuelingSystem.BOOM_AND_RECEPTACLE
  )
  mission:SetMissionAltitude(TANKER_TRACK_ALTITUDE_FT)
  mission:SetMissionEgressCoord(coords.daverOutbound, TANKER_EGRESS_ALTITUDE_FT, TRANSIT_SPEED_KT)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(38)

  local runtime = {
    runtimeId = "AWACS-AAR-LISA-0001",
    selection = selection,
    adapter = adapter,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    rendezvousCoord = coords.rendezvous,
    daverOutboundCoord = coords.daverOutbound,
    externalHandoffCoord = coords.handoff,
    firWaypointUid = nil,
    lateWaypointUid = nil,
    firIngressPassed = false,
    lateApproachPassed = false,
    missionAdded = false,
    onStationAt = nil,
    egressOrdered = false,
    firEgressPassed = false,
    handoffComplete = false,
    lossHandled = false,
    materializedAt = timer.getAbsTime(),
    routeDistanceNm = coords.routeDistanceNm,
  }

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or runtime.egressOrdered or runtime.lossHandled then return end
    if Waypoint.uid == runtime.firWaypointUid and not runtime.firIngressPassed then
      runtime.firIngressPassed = true
      log(string.format("TANKER_FIR_INGRESS runtime=%s fix=DAVER", runtime.runtimeId))
      return
    end
    if Waypoint.uid == runtime.lateWaypointUid and not runtime.lateApproachPassed then
      runtime.lateApproachPassed = true
      runtime.missionAdded = true
      runtime.flightGroup:AddMission(runtime.mission)
      log(string.format("TANKER_LATE_APPROACH runtime=%s distanceToRendezvousNm=%d action=ADD_TANKER_MISSION",
        runtime.runtimeId, TANKER_LATE_APPROACH_NM))
    end
  end

  function flightGroup:OnAfterDead(From, Event, To)
    handleTankerLoss("MOOSE_FLIGHTGROUP_DEAD")
  end

  local firWaypoint = flightGroup:AddWaypoint(coords.daverInbound, TRANSIT_SPEED_KT, nil, TANKER_INGRESS_ALTITUDE_FT, false)
  local lateWaypoint = flightGroup:AddWaypoint(coords.lateApproach, TRANSIT_SPEED_KT, firWaypoint.uid, TANKER_INGRESS_ALTITUDE_FT, true)
  runtime.firWaypointUid = firWaypoint.uid
  runtime.lateWaypointUid = lateWaypoint.uid

  adapter:OnMaterialized(selection, runtime)
  state.tanker = runtime
  state.tankerDispatched = true

  log(string.format(
    "TANKER_DISPATCHED runtime=%s template=%s callsign=Texaco3-1 source=AL_UDEID routeDistanceNm=%.1f plannedAarLocalSec=%d rendezvousLat=%.6f rendezvousLon=%.6f altitudeFt=%d speedKt=%d",
    runtime.runtimeId, TANKER_TEMPLATE, runtime.routeDistanceNm, AAR_TARGET_SEC,
    AAR_RENDEZVOUS.lat, AAR_RENDEZVOUS.lon, TANKER_TRACK_ALTITUDE_FT, TANKER_TRACK_SPEED_KT
  ))
end

local function monitorTanker()
  local tanker = state.tanker
  if not tanker or tanker.lossHandled or tanker.handoffComplete or not tanker.flightGroup:IsAlive() then return end

  if tanker.missionAdded and not tanker.egressOrdered and not tanker.onStationAt then
    local distanceNm = getDistanceNm(tanker.flightGroup, tanker.rendezvousCoord)
    if distanceNm and distanceNm <= TANKER_TRACK_ENTRY_RADIUS_NM then
      tanker.onStationAt = timer.getAbsTime()
      state.tankerReady = true
      log(string.format("TANKER_READY runtime=%s localSec=%.1f distanceNm=%.2f", tanker.runtimeId, UTILS.SecondsOfToday(), distanceNm))
    end
  end

  if tanker.egressOrdered then
    if not tanker.firEgressPassed then
      local distanceNm = getDistanceNm(tanker.flightGroup, tanker.daverOutboundCoord)
      if distanceNm and distanceNm <= TANKER_FIR_RADIUS_NM then
        tanker.firEgressPassed = true
        state.tankerFirEgressPassed = true
        tanker.flightGroup:AddWaypoint(tanker.externalHandoffCoord, TRANSIT_SPEED_KT, nil, TANKER_EGRESS_ALTITUDE_FT)
        log(string.format("TANKER_FIR_EGRESS runtime=%s fix=DAVER action=ROUTE_EXTERNAL_HANDOFF", tanker.runtimeId))
      end
    else
      local distanceNm = getDistanceNm(tanker.flightGroup, tanker.externalHandoffCoord)
      if distanceNm and distanceNm <= TANKER_HANDOFF_RADIUS_NM then
        tanker.handoffComplete = true
        tanker.adapter:OnHandoff(tanker.selection, tanker)
        tanker.flightGroup:Despawn(1, true)
        state.tankerHandoffComplete = true
        log(string.format("TANKER_EXTERNAL_HANDOFF runtime=%s action=DESPAWN_AND_RECREDIT", tanker.runtimeId))
      end
    end
  end
end

local function controlTick()
  local localSec = UTILS.SecondsOfToday()
  local awacs = getAwacsFacade()

  if not state.tankerDispatched and localSec >= TANKER_DISPATCH_SEC then
    dispatchTanker()
  end

  monitorTanker()

  if awacs then
    local serviceState = awacs.GetServiceState()
    if serviceState ~= state.lastAwacsServiceState then
      log(string.format("SERVICE_STATE from=%s to=%s localSec=%.1f",
        tostring(state.lastAwacsServiceState or "NONE"), tostring(serviceState), localSec))
      state.lastAwacsServiceState = serviceState
    end

    if serviceState == "ACTIVE" then state.serviceActiveObserved = true end
    if serviceState == "CLOSED" then state.serviceClosedObserved = true end

    if state.tankerReady and not state.awacsAarRequested and localSec >= AAR_TARGET_SEC and serviceState == "ACTIVE" then
      local ok, reason = awacs.RequestRefuel(state.tanker.rendezvousCoord, state.tanker.group:GetName())
      if not ok then fail("AWACS RequestRefuel failed: " .. tostring(reason)) end
      state.awacsAarRequested = true
      log(string.format("AWACS_AAR_REQUESTED localSec=%.1f tanker=%s", localSec, state.tanker.group:GetName()))
    end

    local runtime = awacs.GetRuntime()
    if runtime and runtime.aarCompletedAt and not state.awacsAarCompleted then
      state.awacsAarCompleted = true
      log(string.format("AWACS_AAR_COMPLETED runtime=%s localSec=%.1f", runtime.runtimeId, localSec))
      orderTankerEgress("AWACS_REFUEL_COMPLETE")
    end

    if not runtime and state.serviceActiveObserved and state.serviceClosedObserved
        and state.awacsAarCompleted and state.tankerHandoffComplete and not state.complete then
      state.complete = true
      log(string.format(
        "AUTOMATED_CAPTURE_COMPLETE localSec=%.1f samples=%d serviceActiveObserved=true serviceClosedObserved=true visibleAarComplete=true tankerHandoffComplete=true manualRadioCheckRequired=true callsign=WIZARD frequencyMHz=357.300",
        localSec, state.samples
      ))
      if state.sampleScheduler and type(state.sampleScheduler.Clear) == "function" then state.sampleScheduler:Clear() end
      if state.controlScheduler and type(state.controlScheduler.Clear) == "function" then state.controlScheduler:Clear() end
    end
  end
end

local function sampleTick()
  local awacs = getAwacsFacade()
  if not awacs then
    log("WAITING reason=AWACS_FACADE_NOT_RUNNING")
    return
  end
  local runtime = awacs.GetRuntime()
  if not runtime then return end
  local telemetry = readAwacsTelemetry(runtime)
  if telemetry then logAwacsTelemetry(runtime, telemetry) end
end

function Acceptance2.Start()
  requireMoose()
  if state.controlScheduler then return Acceptance2 end

  log(string.format(
    "START test=AWACS_FULL_DURATION_AAR_ACCEPTANCE sampleIntervalSec=%d serviceStartLocalSec=%d tankerDispatchLocalSec=%d plannedAarLocalSec=%d serviceEndLocalSec=%d mooseCommit=%s mooseSha256=%s",
    SAMPLE_INTERVAL_SEC, SERVICE_START_SEC, TANKER_DISPATCH_SEC, AAR_TARGET_SEC, SERVICE_END_SEC, MOOSE_COMMIT, MOOSE_SHA256
  ))

  state.controlScheduler = SCHEDULER:New(nil, controlTick, {}, 1, DISPATCH_INTERVAL_SEC)
  state.sampleScheduler = SCHEDULER:New(nil, sampleTick, {}, 2, SAMPLE_INTERVAL_SEC)
  return Acceptance2
end

Acceptance2.Start()

return Acceptance2