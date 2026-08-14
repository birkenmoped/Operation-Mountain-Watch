-- Operation Mountain Watch - Kandahar Main A-10 physical parking compliance test.
--
-- Load order:
--   1. Moose.lua
--   2. OMW_AirOps_Kandahar.lua
--   3. this test bundle
--
-- Scope: exactly one A-10C CAS AUFTRAG assigned to the 74th EFS SQUADRON,
-- native AIRWING dispatch, and physical spawn parking attribution for every unit
-- in the spawned group. No COMMANDER, OPSTRANSPORT, F10 controls, direct SPAWN,
-- native DCS group creation, CampaignState mutation, recovery, or persistence.

local TAG = "[OMW][AirOps.KAF.Parking.A10]"
local EXPECTED_AIRBASE = "Kandahar"
local EXPECTED_AIRBASE_ID = 7
local EXPECTED_SQUADRON = "SQ_US_KAF_A10C_74_EFS"
local EXPECTED_PARKING_IDS = {
  247, 177, 8, 11, 141, 59, 109, 88, 237, 266, 49, 268,
  270, 179, 20, 69, 91, 43, 287, 282, 278, 63, 313, 51,
}
local TARGET_DISTANCE_M = 30000
local TARGET_HEADING_DEG = 90
local CAS_RADIUS_M = 2000
local CAS_ALTITUDE_FT = 12000
local CAS_SPEED_KTS = 250
local START_DELAY_S = 20
local MONITOR_INTERVAL_S = 5
local MONITOR_LIMIT_S = 420

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function containsParkingID(value)
  for _, parkingID in ipairs(EXPECTED_PARKING_IDS) do
    if parkingID == value then
      return true
    end
  end
  return false
end

local function stateName(flightGroup)
  if not flightGroup then
    return "nil"
  end
  if flightGroup.GetState then
    return tostring(flightGroup:GetState())
  end
  return "unknown"
end

local function inspectSpawnParking(state, flightGroup)
  local group = flightGroup and flightGroup:GetGroup() or nil
  if not group then
    return nil, "Assigned A-10 flight is missing runtime GROUP"
  end

  local units = group:GetUnits() or {}
  if #units ~= 2 then
    return nil, "Expected A-10 2-ship but runtime unit count is " .. tostring(#units)
  end

  local observations = {}
  local allAllowed = true

  for index, unit in ipairs(units) do
    local coordinate = unit and unit:GetCoordinate() or nil
    if not coordinate then
      return nil, "A-10 unit coordinate unavailable at index " .. tostring(index)
    end

    local _, terminalID, distanceM = coordinate:GetClosestParkingSpot(state.Airbases.Main, nil, nil)
    local allowed = containsParkingID(terminalID)
    allAllowed = allAllowed and allowed

    observations[#observations + 1] = {
      unit = unit,
      coordinate = coordinate,
      terminalID = terminalID,
      distanceM = distanceM,
      allowed = allowed,
    }

    log(string.format(
      "SPAWN_PARKING unitIndex=%d unitName=%s unitType=%s terminalID=%s parkingAllowed=%s distanceM=%.3f",
      index,
      tostring(unit:GetName()),
      tostring(unit:GetTypeName()),
      tostring(terminalID),
      tostring(allowed),
      tonumber(distanceM) or -1
    ))
  end

  if not allAllowed then
    return observations, "At least one A-10 spawned outside the owner-defined A-10 parking pool"
  end

  return observations, nil
end

local function buildTestMission(state)
  local airbase = state.Airbases and state.Airbases.Main or nil
  local airwing = state.Airwings and state.Airwings.Main or nil
  local squadron = state.Squadrons and state.Squadrons.A10C or nil

  if not airbase or not airwing or not squadron then
    error("Kandahar Main foundation objects are incomplete")
  end
  if state.Status ~= "RUNNING" then
    error("Kandahar foundation is not RUNNING: " .. tostring(state.Status))
  end
  if airbase:GetName() ~= EXPECTED_AIRBASE then
    error("Unexpected airbase name: " .. tostring(airbase:GetName()))
  end
  if airbase:GetID() ~= EXPECTED_AIRBASE_ID then
    error("Unexpected airbase ID: " .. tostring(airbase:GetID()))
  end
  if squadron.name ~= EXPECTED_SQUADRON then
    error("Unexpected A-10 squadron: " .. tostring(squadron.name))
  end

  local baseCoordinate = airbase:GetCoordinate()
  if not baseCoordinate then
    error("Kandahar Main coordinate unavailable")
  end

  local targetCoordinate = baseCoordinate:Translate(TARGET_DISTANCE_M, TARGET_HEADING_DEG)
  local casZone = ZONE_RADIUS:New("OMW_KAF_A10_PARKING_CAS_ZONE", targetCoordinate:GetVec2(), CAS_RADIUS_M)
  local mission = AUFTRAG:NewCAS(casZone, CAS_ALTITUDE_FT, CAS_SPEED_KTS)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MONITOR_LIMIT_S)
  mission:AssignSquadrons({ squadron })

  log(string.format(
    "MISSION_PREPARED type=%s squadron=%s requiredAssets=1 grouping=2 targetDistanceM=%d targetHeadingDeg=%d radiusM=%d altitudeFt=%d speedKts=%d",
    tostring(mission:GetType()),
    EXPECTED_SQUADRON,
    TARGET_DISTANCE_M,
    TARGET_HEADING_DEG,
    CAS_RADIUS_M,
    CAS_ALTITUDE_FT,
    CAS_SPEED_KTS
  ))

  return mission
end

local function startMonitor(flightGroup, mission, observations)
  local elapsed = 0
  local taxiObserved = false
  local airborneObserved = false
  local lastState = nil

  SCHEDULER:New(nil, function()
    elapsed = elapsed + MONITOR_INTERVAL_S

    if not flightGroup then
      fail("Monitor lost FLIGHTGROUP")
      return false
    end

    local currentState = stateName(flightGroup)
    local isTaxiing = flightGroup.IsTaxiing and flightGroup:IsTaxiing() or false
    local isAirborne = flightGroup.IsAirborne and flightGroup:IsAirborne() or false

    if isTaxiing then
      taxiObserved = true
    end
    if isAirborne then
      airborneObserved = true
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

    if airborneObserved then
      local summary = {}
      for _, observation in ipairs(observations) do
        summary[#summary + 1] = tostring(observation.terminalID)
      end

      log(string.format(
        "RESULT status=PASS_PHYSICAL_PARKING_AND_DISPATCH missionType=%s group=%s squadron=%s unitCount=%d spawnTerminalIDs=%s allParkingAllowed=true taxiObserved=%s airborne=true",
        tostring(mission:GetType()),
        tostring(flightGroup:GetName()),
        EXPECTED_SQUADRON,
        #observations,
        table.concat(summary, ","),
        tostring(taxiObserved)
      ))
      return false
    end

    if elapsed >= MONITOR_LIMIT_S then
      fail(string.format(
        "RESULT status=FAIL_TIMEOUT group=%s taxiObserved=%s airborne=%s elapsedS=%d",
        tostring(flightGroup:GetName()),
        tostring(taxiObserved),
        tostring(airborneObserved),
        elapsed
      ))
      return false
    end

    return true
  end, {}, MONITOR_INTERVAL_S, MONITOR_INTERVAL_S)
end

local function run()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Kandahar then
    error("Kandahar foundation state not loaded")
  end
  if not AUFTRAG or not AIRWING or not ZONE_RADIUS or not SCHEDULER then
    error("Required pinned MOOSE classes are unavailable")
  end

  local state = OMW.AirOps.Kandahar
  local mission = buildTestMission(state)
  local airwing = state.Airwings.Main
  local assigned = false

  airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if Mission ~= mission then
      return
    end
    if assigned then
      fail("More than one FlightOnMission event observed for isolated A-10 parking mission")
      return
    end
    assigned = true

    local observations, inspectionError = inspectSpawnParking(state, FlightGroup)
    if inspectionError then
      fail("RESULT status=FAIL_PHYSICAL_PARKING group=" .. tostring(FlightGroup and FlightGroup:GetName()) .. " reason=" .. tostring(inspectionError))
      return
    end

    log(string.format(
      "FLIGHT_ON_MISSION group=%s missionType=%s squadron=%s state=%s unitCount=%d allParkingAllowed=true",
      tostring(FlightGroup:GetName()),
      tostring(Mission:GetType()),
      EXPECTED_SQUADRON,
      stateName(FlightGroup),
      #observations
    ))

    startMonitor(FlightGroup, Mission, observations)
  end

  log("DISPATCH_REQUEST exactlyOneMission=true assignedSquadron=A10C commander=false opstransport=false directSpawn=false f10Controls=false campaignStateMutation=false")
  airwing:AddMission(mission)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
  end
end, {}, START_DELAY_S)
