-- Operation Mountain Watch - minimal MOE relief extension for the proven AWACS V3 lifecycle.
--
-- Scope deliberately kept narrow:
--   * do not change the proven WIZARD/LISA track geometry or V3 controller;
--   * first planned AAR remains LISA and is owned by the existing V3 controller;
--   * second planned AAR in the same WIZARD sortie is handled by MOE on the same AWACS_APOC
--     tanker track geometry that was already proven with LISA;
--   * WIZARD receiver execution remains Controller.RequestRefuel() -> FLIGHTGROUP:Refuel();
--   * MOE uses the existing AAR strategic adapter for CampaignState materialize/handoff/loss;
--   * no live retask of an already materialized production-AAR tanker is performed.

local Relief = {}

local TAG = "[OMW][AWACS.MOERelief]"
local POLL_INTERVAL_SEC = 5
local PREDISPATCH_FUEL_PCT = 65
local HANDOFF_RADIUS_NM = 10
local FIR_RADIUS_NM = 5
local READY_RADIUS_NM = 5
local READY_ALTITUDE_TOLERANCE_FT = 1000

-- Preserve the previously proven AWACS tanker geometry exactly.
local TRACK = {
  lat = 33.6233926368,
  lon = 68.6395554105,
  altitudeFt = 25000,
  speedKIAS = 270,
  headingDeg = 340,
  legNm = 20,
  lateApproachNm = 60,
}

-- MOE identity/source values come from the existing production AAR baseline.
local MOE = {
  template = "OMW_AAR_KC135_MOE",
  sourceDomain = "MANAS",
  missionDemandId = "AWACS-AAR-APOC-MOE-SECOND",
  external = { lat = 38.83163, lon = 70.95271 },
  fir = { lat = 37.25000000, lon = 69.10000000 }, -- PINAX
  ingressAltitudeFt = 34000,
  egressAltitudeFt = 35000,
  transitSpeedKt = 300,
  spawnSpeedKt = 480,
  fuelLowPct = 31,
  callsignNumber = 4,
}

local state = {
  controller = nil,
  aarAdapter = nil,
  scheduler = nil,
  spawner = nil,
  runtime = nil,
  firstAarCompletedAt = nil,
  secondAarStartedAt = nil,
  secondAarCompletedAt = nil,
  secondCycleArmed = false,
  dispatched = false,
  completed = false,
  started = false,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function now()
  return timer.getAbsTime()
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not flightGroup:IsAlive() or not coordinate then return nil end
  local current = flightGroup:GetCoordinate()
  return current and current:Get2DDistance(coordinate) / 1852 or nil
end

local function selection()
  return {
    missionDemandId = MOE.missionDemandId,
    receiverProfile = "FAST",
    requestedReceiverProfile = "FAST",
    operationsArea = "AWACS_APOC",
    supportMode = "SUPPORT",
    priority = "AWACS_FUEL_RESERVE",
    area = "MOE",
    sourceDomain = MOE.sourceDomain,
    transitProfile = "MANAS_WEST_HIGH",
    firFix = "PINAX",
    continuousCore = false,
    availability = "RESERVE",
  }
end

local function buildCoordinates()
  local spawn = COORDINATE:NewFromLLDD(MOE.external.lat, MOE.external.lon)
  spawn:SetAltitude(UTILS.FeetToMeters(MOE.ingressAltitudeFt), true)

  local firIn = COORDINATE:NewFromLLDD(MOE.fir.lat, MOE.fir.lon)
  firIn:SetAltitude(UTILS.FeetToMeters(MOE.ingressAltitudeFt), true)

  local firOut = COORDINATE:NewFromLLDD(MOE.fir.lat, MOE.fir.lon)
  firOut:SetAltitude(UTILS.FeetToMeters(MOE.egressAltitudeFt), true)

  local handoff = COORDINATE:NewFromLLDD(MOE.external.lat, MOE.external.lon)
  handoff:SetAltitude(UTILS.FeetToMeters(MOE.egressAltitudeFt), true)

  local rendezvous = COORDINATE:NewFromLLDD(TRACK.lat, TRACK.lon)
  rendezvous:SetAltitude(UTILS.FeetToMeters(TRACK.altitudeFt), true)

  local firToTrackNm = firIn:Get2DDistance(rendezvous) / 1852
  if firToTrackNm <= TRACK.lateApproachNm then
    fail(string.format("PINAX-to-AWACS_APOC distance %.1f NM must exceed late approach %.1f NM",
      firToTrackNm, TRACK.lateApproachNm))
  end

  local late = rendezvous:GetIntermediateCoordinate(firIn, TRACK.lateApproachNm / firToTrackNm)
  late:SetAltitude(UTILS.FeetToMeters(MOE.ingressAltitudeFt), true)

  return {
    spawn = spawn,
    firIn = firIn,
    firOut = firOut,
    handoff = handoff,
    rendezvous = rendezvous,
    late = late,
  }
end

local function orderEgress(reason)
  local moe = state.runtime
  if not moe or moe.egressOrdered or moe.lossHandled or moe.handoffComplete then return false end
  moe.egressOrdered = true
  moe.egressReason = reason
  moe.egressPending = false
  if moe.mission then moe.mission:Cancel() end
  log(string.format("MOE_EGRESS_ORDERED runtime=%s reason=%s", moe.runtimeId, tostring(reason)))
  return true
end

local function dispatchMoe(reason)
  if state.dispatched then return false, "ALREADY_DISPATCHED" end
  local sel = selection()
  local allowed, denyReason = state.aarAdapter:CanMaterialize(sel)
  if not allowed then
    log("MOE_DISPATCH_UNAVAILABLE reason=" .. tostring(denyReason or "STRATEGIC_UNAVAILABLE"))
    return false, denyReason or "STRATEGIC_UNAVAILABLE"
  end

  local coords = buildCoordinates()
  if not state.spawner then state.spawner = SPAWN:New(MOE.template) end
  state.spawner:InitCallSign(CALLSIGN.Tanker.Texaco, "Texaco", MOE.callsignNumber, 1)
  state.spawner:InitHeading(coords.spawn:HeadingTo(coords.firIn))
  state.spawner:InitSpeedKnots(MOE.spawnSpeedKt)

  local group = state.spawner:SpawnFromCoordinate(coords.spawn)
  if not group then return false, "MOE_SPAWN_FAILED" end
  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then return false, "MOE_FLIGHTGROUP_FAILED" end

  local mission = AUFTRAG:NewTANKER(
    coords.rendezvous, TRACK.altitudeFt, TRACK.speedKIAS,
    TRACK.headingDeg, TRACK.legNm, Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
  mission:SetMissionAltitude(TRACK.altitudeFt)
  mission:SetMissionEgressCoord(coords.firOut, MOE.egressAltitudeFt, MOE.transitSpeedKt)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(MOE.fuelLowPct)

  local moe = {
    runtimeId = "AWACS-MOE-0001",
    selection = sel,
    adapter = state.aarAdapter,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    firIn = coords.firIn,
    firOut = coords.firOut,
    handoffCoord = coords.handoff,
    rendezvousCoord = coords.rendezvous,
    lateCoord = coords.late,
    firWaypointUid = nil,
    lateWaypointUid = nil,
    firPassed = false,
    latePassed = false,
    missionAdded = false,
    onStation = false,
    readyAt = nil,
    egressPending = false,
    egressOrdered = false,
    firEgressPassed = false,
    handoffComplete = false,
    lossHandled = false,
  }

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or moe.lossHandled or moe.handoffComplete then return end
    if Waypoint.uid == moe.firWaypointUid and not moe.firPassed then
      moe.firPassed = true
      log("MOE_FIR_INGRESS_PASSED runtime=" .. moe.runtimeId)
      return
    end
    if Waypoint.uid == moe.lateWaypointUid and not moe.latePassed then
      moe.latePassed = true
      if not moe.missionAdded then
        moe.missionAdded = true
        moe.flightGroup:AddMission(moe.mission)
      end
      log(string.format(
        "MOE_LATE_APPROACH_PASSED runtime=%s action=ADD_TANKER_MISSION targetAltitudeFt=%d targetKIAS=%d",
        moe.runtimeId, TRACK.altitudeFt, TRACK.speedKIAS))
    end
  end

  function flightGroup:OnAfterFuelLow(From, Event, To)
    local wizard = state.controller:GetRuntime()
    local activeReceiver = wizard and wizard.aarPhase == "REFUELING"
      and wizard.designatedTankerGroupName == moe.group:GetName()
    if activeReceiver then
      moe.egressPending = true
      log(string.format("MOE_EGRESS_DEFERRED runtime=%s reason=MOE_FUEL_LOW receiver=%s",
        moe.runtimeId, tostring(wizard.runtimeId)))
      return
    end
    orderEgress("MOE_FUEL_LOW")
  end

  function flightGroup:OnAfterDead(From, Event, To)
    if moe.lossHandled or moe.handoffComplete then return end
    moe.lossHandled = true
    moe.adapter:OnLost(moe.selection, moe, "MOOSE_FLIGHTGROUP_DEAD")
    log("MOE_LOST runtime=" .. moe.runtimeId)
  end

  local firWp = flightGroup:AddWaypoint(
    coords.firIn, MOE.transitSpeedKt, nil, MOE.ingressAltitudeFt, false)
  local lateWp = flightGroup:AddWaypoint(
    coords.late, MOE.transitSpeedKt, firWp.uid, MOE.ingressAltitudeFt, true)
  moe.firWaypointUid = firWp.uid
  moe.lateWaypointUid = lateWp.uid

  state.aarAdapter:OnMaterialized(sel, moe)
  state.runtime = moe
  state.dispatched = true
  log(string.format(
    "MOE_DISPATCHED runtime=%s reason=%s rendezvousLat=%.6f rendezvousLon=%.6f trackAltitudeFt=%d trackSpeedKIAS=%d",
    moe.runtimeId, tostring(reason), TRACK.lat, TRACK.lon, TRACK.altitudeFt, TRACK.speedKIAS))
  return true, "DISPATCHED"
end

local function monitorMoe()
  local moe = state.runtime
  if not moe or moe.lossHandled or moe.handoffComplete
      or not moe.flightGroup or not moe.flightGroup:IsAlive() then return end

  if moe.missionAdded and not moe.onStation and not moe.egressOrdered then
    local distanceNm = getDistanceNm(moe.flightGroup, moe.rendezvousCoord)
    local altitudeFt = moe.flightGroup:GetAltitude()
    local altitudeReady = type(altitudeFt) == "number"
      and math.abs(altitudeFt - TRACK.altitudeFt) <= READY_ALTITUDE_TOLERANCE_FT
    if distanceNm and distanceNm <= READY_RADIUS_NM and altitudeReady then
      moe.onStation = true
      moe.readyAt = now()
      log(string.format(
        "MOE_READY runtime=%s distanceNm=%.1f altitudeFt=%.0f targetAltitudeFt=%d trackSpeedKIAS=%d",
        moe.runtimeId, distanceNm, altitudeFt, TRACK.altitudeFt, TRACK.speedKIAS))

      local wizard = state.controller:GetRuntime()
      if wizard and not wizard.egressOrdered and not wizard.lossHandled and not wizard.handoffComplete
          and wizard.aarPhase == nil then
        local ok, reason = state.controller.RequestRefuel(moe.rendezvousCoord, moe.group:GetName())
        if ok then
          state.secondAarStartedAt = now()
          log(string.format("MOE_AAR_STARTED runtime=%s receiver=%s", moe.runtimeId, wizard.runtimeId))
        else
          log(string.format("MOE_AAR_START_FAILED runtime=%s reason=%s", moe.runtimeId, tostring(reason)))
        end
      end
    end
  end

  if moe.egressOrdered then
    if not moe.firEgressPassed then
      local distanceNm = getDistanceNm(moe.flightGroup, moe.firOut)
      if distanceNm and distanceNm <= FIR_RADIUS_NM then
        moe.firEgressPassed = true
        moe.flightGroup:AddWaypoint(moe.handoffCoord, MOE.transitSpeedKt, nil, MOE.egressAltitudeFt)
        log("MOE_FIR_EGRESS_PASSED runtime=" .. moe.runtimeId)
      end
    else
      local distanceNm = getDistanceNm(moe.flightGroup, moe.handoffCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        moe.handoffComplete = true
        moe.adapter:OnHandoff(moe.selection, moe)
        moe.flightGroup:Despawn(1, true)
        log("MOE_EXTERNAL_HANDOFF runtime=" .. moe.runtimeId)
      end
    end
  end
end

local function monitor()
  local wizard = state.controller:GetRuntime()
  if not wizard or wizard.lossHandled or wizard.handoffComplete
      or not wizard.flightGroup or not wizard.flightGroup:IsAlive() then
    monitorMoe()
    return
  end

  if wizard.aarCompletedAt and not state.firstAarCompletedAt then
    state.firstAarCompletedAt = wizard.aarCompletedAt
    state.secondCycleArmed = true
    log(string.format("SECOND_CYCLE_ARMED receiver=%s firstAarCompletedAt=%.1f nextTanker=MOE",
      wizard.runtimeId, state.firstAarCompletedAt))
  end

  if state.secondCycleArmed and not state.dispatched and wizard.aarPhase == nil and not wizard.egressOrdered then
    local fuelPct = wizard.flightGroup:GetFuelMin()
    if type(fuelPct) == "number" and fuelPct <= PREDISPATCH_FUEL_PCT then
      local ok, reason = dispatchMoe("SECOND_CYCLE_FUEL_PREDISPATCH")
      log(string.format("MOE_PREDISPATCH receiver=%s fuelPct=%.2f result=%s reason=%s",
        wizard.runtimeId, fuelPct, tostring(ok), tostring(reason)))
    end
  end

  if state.secondAarStartedAt and wizard.aarCompletedAt
      and wizard.aarCompletedAt > state.firstAarCompletedAt and not state.secondAarCompletedAt then
    state.secondAarCompletedAt = wizard.aarCompletedAt
    state.completed = true
    orderEgress("WIZARD_SECOND_AAR_COMPLETE")
    log(string.format("SECOND_CYCLE_COMPLETE receiver=%s completedAt=%.1f tanker=MOE",
      wizard.runtimeId, state.secondAarCompletedAt))
  end

  monitorMoe()
end

function Relief.Start(controller)
  if state.started then return Relief end
  if type(controller) ~= "table" or type(controller.GetRuntime) ~= "function"
      or type(controller.RequestRefuel) ~= "function" then
    fail("AWACS V3 controller with GetRuntime and RequestRefuel is required")
  end
  if not OMW or not OMW.AirOps or not OMW.AirOps.AAR or OMW.AirOps.AAR.Status ~= "RUNNING"
      or type(OMW.AirOps.AAR.StrategicAdapter) ~= "table" then
    fail("running production AAR facade with StrategicAdapter is required")
  end
  if not SPAWN or not FLIGHTGROUP or not AUFTRAG or not COORDINATE or not SCHEDULER or not UTILS then
    fail("required MOOSE classes are unavailable")
  end

  state.controller = controller
  state.aarAdapter = OMW.AirOps.AAR.StrategicAdapter
  state.scheduler = SCHEDULER:New(nil, monitor, {}, 1, POLL_INTERVAL_SEC)
  state.started = true
  log(string.format(
    "STARTED mode=MINIMAL_SECOND_TANKER_ONLY first=LISA second=MOE awacsTrackLat=%.10f awacsTrackLon=%.10f altFt=%d speedKIAS=%d",
    TRACK.lat, TRACK.lon, TRACK.altitudeFt, TRACK.speedKIAS))
  return Relief
end

function Relief.GetRuntime()
  return state.runtime
end

function Relief.GetState()
  return state
end

return Relief
