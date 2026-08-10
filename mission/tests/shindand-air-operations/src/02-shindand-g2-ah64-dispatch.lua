-- Operation Mountain Watch - Shindand G2 isolated AH-64 native AIRWING/AUFTRAG dispatch test.
--
-- Load order:
--   1. Moose.lua
--   2. OMW_AirOps_Shindand.lua
--   3. this test bundle
--
-- Scope: exactly one AH-64 CAS AUFTRAG, native AIRWING dispatch, spawn parking
-- attribution and departure telemetry. No COMMANDER, OPSTRANSPORT, F10 controls,
-- direct SPAWN, native coalition.addGroup, CampaignState mutation, recovery or persistence.

local TAG = "[OMW][AirOps.SHND.G2.AH64]"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_AIRBASE_ID = 14
local EXPECTED_SQUADRON = "SQ_US_SHND_AH64D_ATTACK"
local EXPECTED_PARKING_IDS = { 21, 3, 34, 15 }
local TARGET_DISTANCE_M = 10000
local TARGET_HEADING_DEG = 90
local CAS_RADIUS_M = 1500
local CAS_ALTITUDE_FT = 5500
local CAS_SPEED_KTS = 100
local START_DELAY_S = 20
local MONITOR_INTERVAL_S = 5
local MONITOR_LIMIT_S = 360

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

local function buildTestMission(state)
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
  if not airwing.OptionPreferVerticalLanding then
    error("AIRWING vertical landing preference is not configured")
  end

  local baseCoordinate = airbase:GetCoordinate()
  if not baseCoordinate then
    error("Shindand Heliport coordinate unavailable")
  end

  local targetCoordinate = baseCoordinate:Translate(TARGET_DISTANCE_M, TARGET_HEADING_DEG)
  local casZone = ZONE_RADIUS:New("OMW_SHND_G2_AH64_CAS_ZONE", targetCoordinate:GetVec2(), CAS_RADIUS_M)
  local mission = AUFTRAG:NewCAS(casZone, CAS_ALTITUDE_FT, CAS_SPEED_KTS)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MONITOR_LIMIT_S)

  log(string.format(
    "MISSION_PREPARED type=%s requiredAssets=1 targetDistanceM=%d targetHeadingDeg=%d radiusM=%d altitudeFt=%d speedKts=%d verticalPolicyConfigured=true",
    tostring(mission:GetType()),
    TARGET_DISTANCE_M,
    TARGET_HEADING_DEG,
    CAS_RADIUS_M,
    CAS_ALTITUDE_FT,
    CAS_SPEED_KTS
  ))

  return mission
end

local function startMonitor(state, flightGroup, mission, spawnCoordinate, spawnTerminalID, spawnDistanceM)
  local elapsed = 0
  local taxiObserved = false
  local airborneObserved = false
  local lastState = nil

  SCHEDULER:New(nil, function()
    elapsed = elapsed + MONITOR_INTERVAL_S

    if not flightGroup then
      fail("monitor lost FLIGHTGROUP")
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
      local group = flightGroup:GetGroup()
      local leader = group and group:GetUnit(1) or nil
      local airborneCoordinate = leader and leader:GetCoordinate() or nil
      local displacementM = airborneCoordinate and spawnCoordinate and spawnCoordinate:Get2DDistance(airborneCoordinate) or -1

      log(string.format(
        "RESULT status=PASS_DISPATCH_AIRBORNE missionType=%s group=%s squadron=%s spawnTerminalID=%s spawnParkingAllowed=%s spawnDistanceM=%.3f taxiObserved=%s airborne=true takeoffDisplacementM=%.3f verticalPolicyConfigured=%s",
        tostring(mission:GetType()),
        tostring(flightGroup:GetName()),
        EXPECTED_SQUADRON,
        tostring(spawnTerminalID),
        tostring(containsParkingID(spawnTerminalID)),
        tonumber(spawnDistanceM) or -1,
        tostring(taxiObserved),
        tonumber(displacementM) or -1,
        tostring(state.Airwing.OptionPreferVerticalLanding == true)
      ))
      return false
    end

    if elapsed >= MONITOR_LIMIT_S then
      fail(string.format(
        "RESULT status=FAIL_TIMEOUT group=%s spawnTerminalID=%s spawnParkingAllowed=%s taxiObserved=%s airborne=%s elapsedS=%d",
        tostring(flightGroup:GetName()),
        tostring(spawnTerminalID),
        tostring(containsParkingID(spawnTerminalID)),
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
  if not OMW or not OMW.AirOps or not OMW.AirOps.Shindand then
    error("Shindand foundation state not loaded")
  end
  if not AUFTRAG or not AIRWING or not ZONE_RADIUS or not SCHEDULER then
    error("Required pinned MOOSE classes are unavailable")
  end

  local state = OMW.AirOps.Shindand
  local mission = buildTestMission(state)
  local airwing = state.Airwing
  local assigned = false

  airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if Mission ~= mission then
      return
    end
    if assigned then
      fail("More than one FlightOnMission event observed for isolated G2 mission")
      return
    end
    assigned = true

    local group = FlightGroup and FlightGroup:GetGroup() or nil
    local leader = group and group:GetUnit(1) or nil
    local leaderCoordinate = leader and leader:GetCoordinate() or nil
    if not group or not leader or not leaderCoordinate then
      fail("Assigned AH-64 flight is missing runtime group/leader coordinate")
      return
    end

    local _, terminalID, distanceM = leaderCoordinate:GetClosestParkingSpot(state.Airbase, nil, nil)
    local allowed = containsParkingID(terminalID)

    log(string.format(
      "FLIGHT_ON_MISSION group=%s missionType=%s unitType=%s terminalID=%s parkingAllowed=%s distanceM=%.3f state=%s",
      tostring(FlightGroup:GetName()),
      tostring(Mission:GetType()),
      tostring(leader:GetTypeName()),
      tostring(terminalID),
      tostring(allowed),
      tonumber(distanceM) or -1,
      stateName(FlightGroup)
    ))

    if not allowed then
      fail("Assigned AH-64 spawned outside owner-defined AH-64 parking pool: terminalID=" .. tostring(terminalID))
      return
    end

    startMonitor(state, FlightGroup, Mission, leaderCoordinate, terminalID, distanceM)
  end

  log("DISPATCH_REQUEST exactlyOneMission=true commander=false opstransport=false directSpawn=false f10Controls=false campaignStateMutation=false")
  airwing:AddMission(mission)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
  end
end, {}, START_DELAY_S)
