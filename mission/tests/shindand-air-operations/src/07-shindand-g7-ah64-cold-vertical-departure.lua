-- Operation Mountain Watch - Shindand G7 AH-64 cold/vertical departure gate.
--
-- Load order:
--   1. Moose.lua
--   2. OMW_AirOps_Shindand.lua
--   3. this test bundle
--
-- Scope: one native AH-64 CAS AUFTRAG through the running Shindand AIRWING.
-- Parking ownership is deliberately not an acceptance criterion in this gate.
-- The test observes the normal MOOSE FlightOnMission -> FLIGHTGROUP lifecycle,
-- cold-takeoff configuration, vertical-preference propagation, engine start,
-- taxi state, takeoff and airborne transition. No COMMANDER, OPSTRANSPORT,
-- direct SPAWN, native coalition.addGroup, F10 control, CampaignState mutation,
-- recovery, persistence or parking mutation.

local TAG = "[OMW][AirOps.SHND.G7.AH64Departure]"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_AIRBASE_ID = 14
local EXPECTED_SQUADRON = "SQ_US_SHND_AH64D_ATTACK"
local TARGET_DISTANCE_M = 10000
local TARGET_HEADING_DEG = 90
local CAS_RADIUS_M = 1500
local CAS_ALTITUDE_FT = 5500
local CAS_SPEED_KTS = 100
local START_DELAY_S = 20
local MONITOR_INTERVAL_S = 5
local MONITOR_LIMIT_S = 420

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function stateName(flightGroup)
  if flightGroup and flightGroup.GetState then
    return tostring(flightGroup:GetState())
  end
  return "unknown"
end

local function boolText(value)
  return value == true and "true" or "false"
end

local function buildMission(state)
  local airbase = state.Airbase
  local airwing = state.Airwing
  local squadron = state.Squadrons and state.Squadrons.AH64D or nil

  if not airbase or not airwing or not squadron then
    error("Shindand foundation objects are incomplete")
  end
  if state.Status ~= "RUNNING" then
    error("Shindand foundation is not RUNNING: " .. tostring(state.Status))
  end
  if airbase:GetName() ~= EXPECTED_AIRBASE then
    error("Unexpected airbase name: " .. tostring(airbase:GetName()))
  end
  if airbase:GetID() ~= EXPECTED_AIRBASE_ID then
    error("Unexpected airbase ID: " .. tostring(airbase:GetID()))
  end
  if squadron.name ~= EXPECTED_SQUADRON then
    error("Unexpected AH-64 squadron: " .. tostring(squadron.name))
  end
  if airwing.OptionPreferVerticalLanding ~= true then
    error("AIRWING vertical preference is not configured")
  end

  local baseCoordinate = airbase:GetCoordinate()
  if not baseCoordinate then
    error("Shindand Heliport coordinate unavailable")
  end

  local targetCoordinate = baseCoordinate:Translate(TARGET_DISTANCE_M, TARGET_HEADING_DEG)
  local casZone = ZONE_RADIUS:New("OMW_SHND_G7_AH64_CAS_ZONE", targetCoordinate:GetVec2(), CAS_RADIUS_M)
  local mission = AUFTRAG:NewCAS(casZone, CAS_ALTITUDE_FT, CAS_SPEED_KTS)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MONITOR_LIMIT_S)

  log(string.format(
    "MISSION_PREPARED type=%s requiredAssets=1 targetDistanceM=%d targetHeadingDeg=%d radiusM=%d altitudeFt=%d speedKts=%d parkingAcceptance=false",
    tostring(mission:GetType()),
    TARGET_DISTANCE_M,
    TARGET_HEADING_DEG,
    CAS_RADIUS_M,
    CAS_ALTITUDE_FT,
    CAS_SPEED_KTS
  ))

  return mission
end

local function startMonitor(state, flightGroup, mission, spawnCoordinate, telemetry)
  local elapsed = 0
  local lastState = nil

  SCHEDULER:New(nil, function()
    elapsed = elapsed + MONITOR_INTERVAL_S

    if not flightGroup or not flightGroup.GetGroup then
      fail("RESULT status=FAIL_LOST_FLIGHTGROUP elapsedS=" .. tostring(elapsed))
      return false
    end

    local group = flightGroup:GetGroup()
    if not group or not group:IsAlive() then
      fail("RESULT status=FAIL_GROUP_NOT_ALIVE elapsedS=" .. tostring(elapsed))
      return false
    end

    local currentState = stateName(flightGroup)
    local isTaxiing = flightGroup.IsTaxiing and flightGroup:IsTaxiing() or false
    local isAirborne = flightGroup.IsAirborne and flightGroup:IsAirborne() or false

    if isTaxiing then
      telemetry.taxiObserved = true
    end
    if isAirborne then
      telemetry.airborneObserved = true
    end

    if currentState ~= lastState then
      log(string.format(
        "FLIGHT_STATE group=%s state=%s taxiing=%s airborne=%s elapsedS=%d",
        tostring(flightGroup:GetName()),
        currentState,
        tostring(isTaxiing),
        tostring(isAirborne),
        elapsed
      ))
      lastState = currentState
    end

    if telemetry.airborneObserved then
      local leader = group:GetUnit(1)
      local currentCoordinate = leader and leader:GetCoordinate() or nil
      local displacementM = currentCoordinate and spawnCoordinate and spawnCoordinate:Get2DDistance(currentCoordinate) or -1
      local verticalPolicyApplied = flightGroup.OptionPreferVertical == true
      local coldConfigured = flightGroup.IsTakeoffCold and flightGroup:IsTakeoffCold() or false

      if not verticalPolicyApplied then
        fail("RESULT status=FAIL_VERTICAL_POLICY_NOT_APPLIED group=" .. tostring(flightGroup:GetName()))
        return false
      end
      if not coldConfigured then
        fail("RESULT status=FAIL_COLD_POLICY_NOT_APPLIED group=" .. tostring(flightGroup:GetName()))
        return false
      end

      log(string.format(
        "RESULT status=PASS_COLD_VERTICAL_DEPARTURE missionType=%s group=%s squadron=%s coldConfigured=true verticalPolicyApplied=true engineOnObserved=%s taxiObserved=%s takeoffObserved=%s airborne=true takeoffAirbase=%s airborneDisplacementM=%.3f parkingAcceptance=false",
        tostring(mission:GetType()),
        tostring(flightGroup:GetName()),
        EXPECTED_SQUADRON,
        boolText(telemetry.engineOnObserved),
        boolText(telemetry.taxiObserved),
        boolText(telemetry.takeoffObserved),
        tostring(telemetry.takeoffAirbase or "unknown"),
        tonumber(displacementM) or -1
      ))
      return false
    end

    if elapsed >= MONITOR_LIMIT_S then
      fail(string.format(
        "RESULT status=FAIL_DEPARTURE_TIMEOUT group=%s state=%s coldConfigured=%s verticalPolicyApplied=%s engineOnObserved=%s taxiObserved=%s takeoffObserved=%s airborne=false elapsedS=%d parkingAcceptance=false",
        tostring(flightGroup:GetName()),
        currentState,
        boolText(flightGroup.IsTakeoffCold and flightGroup:IsTakeoffCold() or false),
        boolText(flightGroup.OptionPreferVertical == true),
        boolText(telemetry.engineOnObserved),
        boolText(telemetry.taxiObserved),
        boolText(telemetry.takeoffObserved),
        elapsed
      ))
      return false
    end

    return true
  end, {}, MONITOR_INTERVAL_S, MONITOR_INTERVAL_S)
end

local function attachFlightTelemetry(state, flightGroup, mission)
  local group = flightGroup:GetGroup()
  local leader = group and group:GetUnit(1) or nil
  local spawnCoordinate = leader and leader:GetCoordinate() or nil
  if not group or not leader or not spawnCoordinate then
    error("Assigned AH-64 flight is missing runtime group/leader coordinate")
  end

  local telemetry = {
    engineOnObserved = false,
    taxiObserved = false,
    takeoffObserved = false,
    airborneObserved = false,
    takeoffAirbase = nil,
  }

  local previousElementEngineOn = flightGroup.OnAfterElementEngineOn
  function flightGroup:OnAfterElementEngineOn(From, Event, To, Element)
    if previousElementEngineOn then
      previousElementEngineOn(self, From, Event, To, Element)
    end
    telemetry.engineOnObserved = true
    log(string.format(
      "ELEMENT_ENGINE_ON group=%s element=%s state=%s",
      tostring(self:GetName()),
      tostring(Element and Element.name or "unknown"),
      stateName(self)
    ))
  end

  local previousTaxiing = flightGroup.OnAfterTaxiing
  function flightGroup:OnAfterTaxiing(From, Event, To)
    if previousTaxiing then
      previousTaxiing(self, From, Event, To)
    end
    telemetry.taxiObserved = true
    log("TAXIING group=" .. tostring(self:GetName()) .. " state=" .. stateName(self))
  end

  local previousTakeoff = flightGroup.OnAfterTakeoff
  function flightGroup:OnAfterTakeoff(From, Event, To, Airbase)
    if previousTakeoff then
      previousTakeoff(self, From, Event, To, Airbase)
    end
    telemetry.takeoffObserved = true
    telemetry.takeoffAirbase = Airbase and Airbase:GetName() or "unknown"
    log(string.format(
      "TAKEOFF group=%s airbase=%s state=%s",
      tostring(self:GetName()),
      tostring(telemetry.takeoffAirbase),
      stateName(self)
    ))
  end

  local previousAirborne = flightGroup.OnAfterAirborne
  function flightGroup:OnAfterAirborne(From, Event, To)
    if previousAirborne then
      previousAirborne(self, From, Event, To)
    end
    telemetry.airborneObserved = true
    log("AIRBORNE group=" .. tostring(self:GetName()) .. " state=" .. stateName(self))
  end

  local coldConfigured = flightGroup.IsTakeoffCold and flightGroup:IsTakeoffCold() or false
  local verticalPolicyApplied = flightGroup.OptionPreferVertical == true

  log(string.format(
    "FLIGHT_ON_MISSION group=%s missionType=%s unitType=%s state=%s coldConfigured=%s verticalPolicyApplied=%s parkingAcceptance=false",
    tostring(flightGroup:GetName()),
    tostring(mission:GetType()),
    tostring(leader:GetTypeName()),
    stateName(flightGroup),
    boolText(coldConfigured),
    boolText(verticalPolicyApplied)
  ))

  if not coldConfigured then
    error("Assigned AH-64 FLIGHTGROUP is not configured for cold takeoff")
  end
  if not verticalPolicyApplied then
    error("AIRWING FlightOnMission did not propagate vertical preference to FLIGHTGROUP")
  end

  startMonitor(state, flightGroup, mission, spawnCoordinate, telemetry)
end

local function run()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Shindand then
    error("Shindand foundation state not loaded")
  end
  if not AUFTRAG or not AIRWING or not ZONE_RADIUS or not SCHEDULER or not FLIGHTGROUP then
    error("Required pinned MOOSE classes are unavailable")
  end

  local state = OMW.AirOps.Shindand
  local mission = buildMission(state)
  local airwing = state.Airwing
  local assigned = false
  local previousFlightOnMission = airwing.OnAfterFlightOnMission

  function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then
      previousFlightOnMission(self, From, Event, To, FlightGroup, Mission)
    end
    if Mission ~= mission then
      return
    end
    if assigned then
      fail("RESULT status=FAIL_MULTIPLE_FLIGHTS_ON_MISSION")
      return
    end
    assigned = true

    local ok, err = pcall(attachFlightTelemetry, state, FlightGroup, Mission)
    if not ok then
      fail("RESULT status=FAIL_ASSIGNMENT_VALIDATION error=" .. tostring(err))
    end
  end

  log("DISPATCH_REQUEST exactlyOneMission=true path=AIRWING_ADD_MISSION commander=false opstransport=false directSpawn=false parkingMutation=false parkingAcceptance=false")
  airwing:AddMission(mission)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("RESULT status=FAIL_SETUP error=" .. tostring(err))
  end
end, {}, START_DELAY_S)
