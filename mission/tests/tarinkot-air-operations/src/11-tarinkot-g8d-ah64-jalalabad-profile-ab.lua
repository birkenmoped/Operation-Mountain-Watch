-- Operation Mountain Watch - Tarinkot G8D AH-64 Jalalabad-profile A/B test.
--
-- Purpose: isolate the Tarinkot AH-64 departure behavior by keeping the accepted
-- G7 AIRWING/SQUADRON/parking foundation intact and dispatching exactly one
-- AH-64D two-ship through the same public MOOSE mission-profile primitives that
-- produced the visually correct Jalalabad departure: CAS, fixed rotor ingress
-- altitude/speed, explicit ingress/egress coordinates, Echelon Right 300 and
-- AIRWING propagated vertical takeoff/landing preference.
--
-- This is an exploratory diagnostic. Runtime telemetry can prove assignment,
-- unit count, vertical-option propagation and airborne state; only the project
-- owner visual check can accept direct ramp departure versus taxi/runway use.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.TKOT.G8D.AH64JalalabadProfileAB]"
local BUILD = OMW_TKOT_G8D_BUILD or {}

local ANCHOR_ZONE_NAME = "ZONE_AIR_US_TKOT_ROTARY_STAGING"
local START_DELAY_SECONDS = 35
local POLL_INTERVAL_SECONDS = 2
local ASSIGNMENT_TIMEOUT_SECONDS = 240
local TAKEOFF_TIMEOUT_SECONDS = 180

local CAS_DISTANCE_METERS = 8000
local CAS_BEARING_DEGREES = 90
local CAS_RADIUS_METERS = 1500
local INGRESS_DISTANCE_METERS = 3000
local EGRESS_DISTANCE_METERS = 5000
local ROTOR_ALTITUDE_FEET = 3500
local ROTOR_SPEED_KNOTS = 110
local ROTOR_FORMATION = ENUMS.Formation.RotaryWing.EchelonRight.D300

local state = {
  Finalized = false,
  StartAbsTime = nil,
  Mission = nil,
  FlightGroup = nil,
  UnitNames = {},
  RuntimeUnits = 0,
  FlightOnMission = false,
  FlightOnMissionAbsTime = nil,
  OptionPreferVertical = false,
  Takeoff = false,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function missionState(mission)
  if not mission then return "nil" end
  local ok, value = pcall(function() return mission:GetState() end)
  if ok and value ~= nil then return tostring(value) end
  return tostring(mission.status or "unknown")
end

local function finalize(status, reason)
  if state.Finalized then return end
  state.Finalized = true

  log(string.format(
    "RESULT G8D_AH64_JALALABAD_PROFILE_AB status=%s reason=%s assigned=%s runtimeUnits=%d/2 takeoff=%s optionPreferVertical=%s missionType=CAS targetDistanceM=%d altitudeFt=%d speedKt=%d formation=EchelonRight300 ownerVisualRequired=true taxiInference=disabled",
    tostring(status), tostring(reason or "none"), tostring(state.FlightOnMission),
    state.RuntimeUnits, tostring(state.Takeoff), tostring(state.OptionPreferVertical),
    CAS_DISTANCE_METERS, ROTOR_ALTITUDE_FEET, ROTOR_SPEED_KNOTS
  ))

  OMW.AirOps.TarinkotG8D = OMW.AirOps.TarinkotG8D or {}
  OMW.AirOps.TarinkotG8D.Status = status
  OMW.AirOps.TarinkotG8D.Reason = reason
end

local function attachMissionCallbacks(mission)
  function mission:OnAfterFailed(from, event, to)
    log(string.format("AUFTRAG_STATE from=%s event=%s to=%s state=%s", tostring(from), tostring(event), tostring(to), missionState(mission)))
    finalize("FAIL", "AUFTRAG_FAILED")
  end

  function mission:OnAfterCancel(from, event, to)
    log(string.format("AUFTRAG_STATE from=%s event=%s to=%s state=%s", tostring(from), tostring(event), tostring(to), missionState(mission)))
    finalize("FAIL", "AUFTRAG_CANCELLED")
  end
end

local function installAirwingObserver(airwing)
  function airwing:OnAfterFlightOnMission(from, event, to, flightGroup, mission)
    if state.Finalized or mission ~= state.Mission then return end

    state.FlightOnMission = true
    state.FlightOnMissionAbsTime = timer.getAbsTime()
    state.FlightGroup = flightGroup
    state.OptionPreferVertical = flightGroup and flightGroup.OptionPreferVertical == true or false

    local group = flightGroup and flightGroup:GetGroup() or nil
    local units = group and group:GetUnits() or {}
    state.RuntimeUnits = #units
    state.UnitNames = {}
    for _, unit in ipairs(units) do
      state.UnitNames[#state.UnitNames + 1] = unit:GetName()
    end

    log(string.format(
      "FLIGHT_ON_MISSION group=%s mission=%s missionType=%s runtimeUnits=%d expectedUnits=2 optionPreferVertical=%s",
      tostring(flightGroup and flightGroup:GetName() or "none"),
      tostring(mission and mission:GetName() or "none"),
      tostring(mission and mission:GetType() or "none"),
      state.RuntimeUnits,
      tostring(state.OptionPreferVertical)
    ))

    if state.RuntimeUnits ~= 2 then
      finalize("FAIL", "RUNTIME_UNIT_COUNT_MISMATCH")
    elseif not state.OptionPreferVertical then
      finalize("FAIL", "FLIGHTGROUP_VERTICAL_OPTION_NOT_APPLIED")
    end
  end
end

local function poll()
  if state.Finalized then return end
  local now = timer.getAbsTime()

  if not state.FlightOnMission then
    if now - state.StartAbsTime >= ASSIGNMENT_TIMEOUT_SECONDS then
      finalize("FAIL", "ASSIGNMENT_TIMEOUT")
      return
    end
  elseif not state.Takeoff then
    local airborne = 0
    for _, unitName in ipairs(state.UnitNames) do
      local unit = Unit.getByName(unitName)
      if unit and unit:isExist() and unit:inAir() then
        airborne = airborne + 1
      end
    end

    if airborne == 2 then
      state.Takeoff = true
      log("TAKEOFF_OBSERVED airborneUnits=2/2 optionPreferVertical=" .. tostring(state.OptionPreferVertical))
      finalize("PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL", "none")
      return
    elseif now - state.FlightOnMissionAbsTime >= TAKEOFF_TIMEOUT_SECONDS then
      finalize("FAIL", "TAKEOFF_TIMEOUT airborneUnits=" .. tostring(airborne) .. "/2")
      return
    end
  end

  timer.scheduleFunction(function()
    poll()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

local function startG8D()
  log("BEGIN Tarinkot G8D AH-64 Jalalabad-profile A/B test")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(BUILD.Builder), tostring(BUILD.BuilderVersion),
    tostring(BUILD.GitCommit), tostring(BUILD.GeneratedUtc)
  ))

  local g7 = OMW.AirOps.TarinkotG7
  if not g7 or g7.Status ~= "PASS" then finalize("BLOCKED", "G7_FOUNDATION_NOT_PASS"); return end

  local airwing = g7.Airwing
  if not airwing or not airwing:IsRunning() then finalize("FAIL", "AIRWING_NOT_RUNNING"); return end
  if airwing.OptionPreferVerticalLanding ~= true then finalize("FAIL", "AIRWING_VERTICAL_POLICY_NOT_SET"); return end

  local squadron = g7.Squadrons and g7.Squadrons.AH64 or nil
  local payload = g7.RolePayloads and g7.RolePayloads.AH64 or nil
  if not squadron then finalize("FAIL", "AH64_SQUADRON_UNAVAILABLE"); return end
  if not payload then finalize("FAIL", "AH64_ROLE_PAYLOAD_UNAVAILABLE"); return end

  local anchorZone = ZONE and ZONE:FindByName(ANCHOR_ZONE_NAME) or nil
  if not anchorZone then finalize("BLOCKED", "MISSING_MISSION_EDITOR_ZONE_" .. ANCHOR_ZONE_NAME); return end

  local anchor = anchorZone:GetCoordinate()
  local casCoordinate = anchor:Translate(CAS_DISTANCE_METERS, CAS_BEARING_DEGREES)
  local ingressCoordinate = anchor:Translate(INGRESS_DISTANCE_METERS, CAS_BEARING_DEGREES)
  local egressCoordinate = anchor:Translate(EGRESS_DISTANCE_METERS, CAS_BEARING_DEGREES + 180)
  local casZone = ZONE_RADIUS:New("OMW_TKOT_G8D_CAS_TARGET", casCoordinate:GetVec2(), CAS_RADIUS_METERS, true)

  squadron:AddMissionCapability(AUFTRAG.Type.CAS, 100)
  airwing:AddPayloadCapability(payload, AUFTRAG.Type.CAS, 100)

  local mission = AUFTRAG:NewCAS(casZone, ROTOR_ALTITUDE_FEET, ROTOR_SPEED_KNOTS, casCoordinate)
  if not mission then finalize("FAIL", "AUFTRAG_CONSTRUCTION_FAILED"); return end

  mission:SetName("OMW-TKOT-G8D-AH64-CAS-JBAD-PROFILE")
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  mission:AddRequiredPayload(payload)
  mission:SetMissionAltitude(ROTOR_ALTITUDE_FEET)
  mission:SetMissionSpeed(ROTOR_SPEED_KNOTS)
  mission:SetMissionIngressCoord(ingressCoordinate, ROTOR_ALTITUDE_FEET, ROTOR_SPEED_KNOTS)
  mission:SetMissionEgressCoord(egressCoordinate, ROTOR_ALTITUDE_FEET, ROTOR_SPEED_KNOTS)
  mission:SetFormation(ROTOR_FORMATION)
  mission:SetPriority(10, true)
  mission:SetRepeat(0)
  mission:SetTime(1, 900)
  mission:SetDuration(900)
  mission:SetMissionRange(20)
  mission:SetEvaluationTime(10)

  state.StartAbsTime = timer.getAbsTime()
  state.Mission = mission
  attachMissionCallbacks(mission)
  installAirwingObserver(airwing)

  log(string.format(
    "MISSION_ADDED key=AH64_1 type=%s requiredAssets=1 expectedUnits=2 targetDistanceM=%d targetBearingDeg=%d casRadiusM=%d ingressDistanceM=%d egressDistanceM=%d altitudeFt=%d speedKt=%d formation=EchelonRight300",
    tostring(mission:GetType()), CAS_DISTANCE_METERS, CAS_BEARING_DEGREES,
    CAS_RADIUS_METERS, INGRESS_DISTANCE_METERS, EGRESS_DISTANCE_METERS,
    ROTOR_ALTITUDE_FEET, ROTOR_SPEED_KNOTS
  ))

  OMW.AirOps.TarinkotG8D = {
    Status = "DISPATCHED_AWAITING_TAKEOFF",
    Airwing = airwing,
    Mission = mission,
    CasZone = casZone,
  }

  airwing:AddMission(mission)

  timer.scheduleFunction(function()
    poll()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

if SCHEDULER then
  SCHEDULER:New(nil, startG8D, {}, START_DELAY_SECONDS)
else
  timer.scheduleFunction(function()
    startG8D()
    return nil
  end, nil, timer.getTime() + START_DELAY_SECONDS)
end
