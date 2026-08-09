-- Operation Mountain Watch - Tarinkot G8B combined helicopter dispatch.
--
-- Exercises every G7-registered AI helicopter group in one native AIRWING/AUFTRAG
-- run: two AH-64 two-ship groups, two UH-60 single-ship groups and one CH-47.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.TKOT.G8B.CombinedHelicopterDispatch]"
local BUILD = OMW_TKOT_G8B_BUILD or {}

local ZONE_NAME = "ZONE_AIR_US_TKOT_ROTARY_STAGING"
local START_DELAY_SECONDS = 35
local POLL_INTERVAL_SECONDS = 2
local LOG_INTERVAL_SECONDS = 10
local ASSIGNMENT_TIMEOUT_SECONDS = 720
local TAKEOFF_TIMEOUT_SECONDS = 360
local AGGREGATE_TIMEOUT_SECONDS = 1200
local MAX_GROUND_DISPLACEMENT_METERS = 75

local FLIGHT_CONFIGS = {
  { Key = "AH64_1", SquadronKey = "AH64", ExpectedUnits = 2, MissionKind = "CAS", OffsetM = 35, Heading = 45, AltitudeFt = 1200 },
  { Key = "AH64_2", SquadronKey = "AH64", ExpectedUnits = 2, MissionKind = "CAS", OffsetM = 35, Heading = 225, AltitudeFt = 1800 },
  { Key = "UH60_1", SquadronKey = "UH60", ExpectedUnits = 1, MissionKind = "LAND", OffsetM = 50, Heading = 0 },
  { Key = "UH60_2", SquadronKey = "UH60", ExpectedUnits = 1, MissionKind = "LAND", OffsetM = 50, Heading = 120 },
  { Key = "CH47_1", SquadronKey = "CH47", ExpectedUnits = 1, MissionKind = "LAND", OffsetM = 50, Heading = 240 }
}

local state = {
  Finalized = false,
  StartedAt = nil,
  Flights = {},
  MissionToFlight = {}
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function horizontalDistance(a, b)
  if not a or not b then return nil end
  local dx = (a.x or 0) - (b.x or 0)
  local dz = (a.z or 0) - (b.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function missionStatus(mission)
  if not mission then return "nil" end
  local ok, value = pcall(function() return mission:GetState() end)
  if ok and value ~= nil then return tostring(value) end
  return tostring(mission.status or "unknown")
end

local function summarize()
  local assigned, takeoff, landed, failed, units = 0, 0, 0, 0, 0
  for _, flight in pairs(state.Flights) do
    if flight.AssignedAt then assigned = assigned + 1 end
    if flight.TakeoffAccepted then takeoff = takeoff + 1 end
    if flight.Config.MissionKind == "LAND" and flight.LandingSuccess then
      landed = landed + 1
    end
    if flight.Failed then failed = failed + 1 end
    units = units + (flight.UnitCount or 0)
  end
  return assigned, takeoff, landed, failed, units
end

local function finalize(status, reason)
  if state.Finalized then return end
  state.Finalized = true
  local assigned, takeoff, landed, failed, units = summarize()

  log(string.format(
    "RESULT G8B_COMBINED_HELICOPTER_DISPATCH status=%s reason=%s missions=5 assigned=%d takeoffGroups=%d expectedTakeoffGroups=5 landingMissionsComplete=%d expectedLandingMissions=3 failedGroups=%d runtimeUnits=%d expectedRuntimeUnits=7 maxGroundDisplacementThresholdM=%d commanderCreated=0 opsTransportCreated=0 spawnCreated=0 standaloneFlightGroupCreated=0 ownerVisualRequired=true",
    tostring(status), tostring(reason or "none"), assigned, takeoff, landed,
    failed, units, MAX_GROUND_DISPLACEMENT_METERS
  ))

  OMW.AirOps.TarinkotG8B = OMW.AirOps.TarinkotG8B or {}
  OMW.AirOps.TarinkotG8B.Status = status
  OMW.AirOps.TarinkotG8B.Reason = reason
end

local function evaluateAggregate()
  if state.Finalized then return end
  local assigned, takeoff, landed, failed, units = summarize()
  if failed > 0 then
    finalize("FAIL", "ONE_OR_MORE_GROUPS_FAILED")
  elseif assigned == 5 and takeoff == 5 and landed == 3 and units == 7 then
    finalize("PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL", "none")
  end
end

local function sampleFlight(flight, emitLog)
  local allInAir = #flight.Units == flight.Config.ExpectedUnits
  local maximum = 0

  for _, unitState in ipairs(flight.Units) do
    local dcsUnit = Unit.getByName(unitState.Name)
    if not dcsUnit or not dcsUnit:isExist() then
      allInAir = false
    else
      local point = dcsUnit:getPoint()
      local displacement = horizontalDistance(point, unitState.InitialPoint) or 0
      local inAir = dcsUnit:inAir() == true
      if not inAir and displacement > unitState.MaxGroundDisplacement then
        unitState.MaxGroundDisplacement = displacement
      end
      if unitState.MaxGroundDisplacement > maximum then
        maximum = unitState.MaxGroundDisplacement
      end
      if emitLog then
        log(string.format(
          "UNIT key=%s name=%s inAir=%s displacementM=%.1f maxGroundDisplacementM=%.1f",
          flight.Config.Key, unitState.Name, tostring(inAir), displacement,
          unitState.MaxGroundDisplacement
        ))
      end
      if not inAir then allInAir = false end
    end
  end

  flight.MaxGroundDisplacement = maximum
  return allInAir
end

local function acceptTakeoff(flight, source)
  if state.Finalized or flight.TakeoffAccepted or flight.Failed then return end

  local allInAir = sampleFlight(flight, true)
  local elapsed = timer.getAbsTime() - (flight.AssignedAt or timer.getAbsTime())
  log(string.format(
    "TAKEOFF_EVENT key=%s source=%s elapsedSinceFlightOnMission=%.1f allUnitsInAir=%s unitCount=%d expectedUnits=%d maxGroundDisplacementM=%.1f optionPreferVertical=%s missionState=%s",
    flight.Config.Key, tostring(source), elapsed, tostring(allInAir),
    flight.UnitCount or 0, flight.Config.ExpectedUnits,
    flight.MaxGroundDisplacement or -1, tostring(flight.OptionApplied),
    missionStatus(flight.Mission)
  ))

  if not flight.OptionApplied then
    flight.Failed = true
    flight.FailureReason = "FLIGHTGROUP_VERTICAL_OPTION_NOT_APPLIED"
  elseif flight.UnitCount ~= flight.Config.ExpectedUnits then
    flight.Failed = true
    flight.FailureReason = "UNEXPECTED_RUNTIME_UNIT_COUNT"
  elseif not allInAir and source == "DCS_ALL_UNITS_IN_AIR_POLL" then
    flight.Failed = true
    flight.FailureReason = "INCONSISTENT_IN_AIR_FALLBACK"
  elseif (flight.MaxGroundDisplacement or 0) > MAX_GROUND_DISPLACEMENT_METERS then
    flight.Failed = true
    flight.FailureReason = "GROUND_DISPLACEMENT_EXCEEDED_VERTICAL_TAKEOFF_THRESHOLD"
  else
    flight.TakeoffAccepted = true
    flight.TakeoffSource = source
  end

  if flight.Failed then
    log(string.format("GROUP_FAIL key=%s reason=%s", flight.Config.Key, flight.FailureReason))
  end
  evaluateAggregate()
end

local function captureUnits(flightGroup, flight)
  local group = flightGroup and flightGroup:GetGroup() or nil
  local units = group and group:GetUnits() or {}
  flight.Units = {}

  for _, unit in ipairs(units) do
    local name = unit:GetName()
    local dcsUnit = Unit.getByName(name)
    local point = dcsUnit and dcsUnit:isExist() and dcsUnit:getPoint() or nil
    table.insert(flight.Units, {
      Name = name,
      InitialPoint = point,
      MaxGroundDisplacement = 0
    })
  end
  flight.UnitCount = #flight.Units
end

local function installAirwingObserver(airwing)
  function airwing:OnAfterFlightOnMission(from, event, to, flightGroup, mission)
    local flight = state.MissionToFlight[mission]
    if not flight then return end

    flight.FlightGroup = flightGroup
    flight.AssignedAt = timer.getAbsTime()
    flight.OptionApplied = flightGroup and flightGroup.OptionPreferVertical == true or false
    captureUnits(flightGroup, flight)

    if flightGroup then
      function flightGroup:OnAfterTakeoff(takeoffFrom, takeoffEvent, takeoffTo, airbase)
        log(string.format(
          "FLIGHTGROUP_TAKEOFF key=%s from=%s event=%s to=%s airbase=%s",
          flight.Config.Key, tostring(takeoffFrom), tostring(takeoffEvent),
          tostring(takeoffTo), tostring(airbase and airbase:GetName() or "none")
        ))
        acceptTakeoff(flight, "MOOSE_FLIGHTGROUP_ON_AFTER_TAKEOFF")
      end
    end

    log(string.format(
      "FLIGHT_ON_MISSION key=%s group=%s mission=%s missionType=%s unitCount=%d expectedUnits=%d optionPreferVertical=%s",
      flight.Config.Key, tostring(flightGroup and flightGroup:GetName() or "none"),
      tostring(mission:GetName()), tostring(mission:GetType()), flight.UnitCount,
      flight.Config.ExpectedUnits, tostring(flight.OptionApplied)
    ))
  end
end

local function attachMissionCallbacks(flight)
  local mission = flight.Mission
  function mission:OnAfterFailed(from, event, to)
    flight.Failed = true
    flight.FailureReason = "AUFTRAG_FAILED"
    log(string.format("MISSION_STATE key=%s event=Failed from=%s to=%s", flight.Config.Key, tostring(from), tostring(to)))
    evaluateAggregate()
  end
  function mission:OnAfterCancel(from, event, to)
    flight.Failed = true
    flight.FailureReason = "AUFTRAG_CANCELLED"
    log(string.format("MISSION_STATE key=%s event=Cancel from=%s to=%s", flight.Config.Key, tostring(from), tostring(to)))
    evaluateAggregate()
  end
  function mission:OnAfterSuccess(from, event, to)
    if flight.Config.MissionKind == "LAND" then
      flight.LandingSuccess = true
    end
    log(string.format("MISSION_STATE key=%s event=Success from=%s to=%s landingSuccess=%s", flight.Config.Key, tostring(from), tostring(to), tostring(flight.LandingSuccess == true)))
    evaluateAggregate()
  end
end

local function createMission(config, zone, squadron, payload)
  local targetCoordinate = zone:GetCoordinate():Translate(config.OffsetM, config.Heading, true)
  local mission
  if config.MissionKind == "CAS" then
    mission = AUFTRAG:NewCAS(zone, config.AltitudeFt, 90, targetCoordinate, config.Heading, 1)
  else
    mission = AUFTRAG:NewLANDATCOORDINATE(targetCoordinate, nil, nil, 60, 80, 1000, false, config.Heading)
  end
  if not mission then return nil end

  mission:SetName("OMW-TKOT-G8B-" .. config.Key)
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  mission:AddRequiredPayload(payload)
  mission:SetPriority(10, true)
  mission:SetRepeat(0)
  mission:SetTime(1, 900)
  mission:SetDuration(900)
  mission:SetMissionRange(10)
  mission:SetEvaluationTime(10)
  return mission
end

local function pollBatch()
  if state.Finalized then return end
  local now = timer.getAbsTime()
  local aggregateElapsed = now - (state.StartedAt or now)

  for _, flight in pairs(state.Flights) do
    if not flight.AssignedAt and aggregateElapsed >= ASSIGNMENT_TIMEOUT_SECONDS then
      flight.Failed = true
      flight.FailureReason = "FLIGHT_ASSIGNMENT_TIMEOUT"
      log(string.format("GROUP_FAIL key=%s reason=%s", flight.Config.Key, flight.FailureReason))
    elseif flight.AssignedAt and not flight.TakeoffAccepted and not flight.Failed then
      local takeoffElapsed = now - flight.AssignedAt
      local emitLog = not flight.LastLogAt or now - flight.LastLogAt >= LOG_INTERVAL_SECONDS
      local allInAir = sampleFlight(flight, emitLog)
      if emitLog then
        flight.LastLogAt = now
        log(string.format(
          "GROUP_POLL key=%s takeoffElapsed=%.1f allUnitsInAir=%s missionState=%s",
          flight.Config.Key, takeoffElapsed, tostring(allInAir), missionStatus(flight.Mission)
        ))
      end
      if allInAir then
        acceptTakeoff(flight, "DCS_ALL_UNITS_IN_AIR_POLL")
      elseif takeoffElapsed >= TAKEOFF_TIMEOUT_SECONDS then
        flight.Failed = true
        flight.FailureReason = "TAKEOFF_TIMEOUT"
        log(string.format("GROUP_FAIL key=%s reason=%s", flight.Config.Key, flight.FailureReason))
      end
    end
  end

  evaluateAggregate()
  if state.Finalized then return end
  if aggregateElapsed >= AGGREGATE_TIMEOUT_SECONDS then
    finalize("FAIL", "AGGREGATE_TIMEOUT")
    return
  end

  timer.scheduleFunction(function()
    pollBatch()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

local function startG8B()
  log("BEGIN Tarinkot G8B combined all-registered-helicopter dispatch")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(BUILD.Builder), tostring(BUILD.BuilderVersion),
    tostring(BUILD.GitCommit), tostring(BUILD.GeneratedUtc)
  ))
  log("SCOPE missions=5 groups=5 aircraft=7 AH64Groups=2 UH60Groups=2 CH47Groups=1 commander=0 opstransport=0 spawn=0 standaloneFlightGroup=0 syntheticZone=0")

  local g7 = OMW.AirOps.TarinkotG7
  if not g7 or g7.Status ~= "PASS" then
    finalize("BLOCKED", "G7_FOUNDATION_NOT_PASS")
    return
  end

  local zone = ZONE and ZONE:FindByName(ZONE_NAME) or nil
  if not zone then
    finalize("BLOCKED", "MISSING_MISSION_EDITOR_ZONE_" .. ZONE_NAME)
    return
  end

  local airwing = g7.Airwing
  if not airwing or not airwing:IsRunning() then
    finalize("FAIL", "AIRWING_NOT_RUNNING")
    return
  end
  if airwing.OptionPreferVerticalLanding ~= true then
    finalize("FAIL", "AIRWING_VERTICAL_POLICY_NOT_SET")
    return
  end

  installAirwingObserver(airwing)
  state.StartedAt = timer.getAbsTime()

  for _, config in ipairs(FLIGHT_CONFIGS) do
    local squadron = g7.Squadrons and g7.Squadrons[config.SquadronKey] or nil
    local payload = g7.RolePayloads and g7.RolePayloads[config.SquadronKey] or nil
    if not squadron or not payload then
      finalize("FAIL", "SQUADRON_OR_PAYLOAD_MISSING_" .. config.Key)
      return
    end

    local mission = createMission(config, zone, squadron, payload)
    if not mission then
      finalize("FAIL", "MISSION_CONSTRUCTION_FAILED_" .. config.Key)
      return
    end

    local flight = {
      Config = config,
      Mission = mission,
      Units = {},
      UnitCount = 0,
      MaxGroundDisplacement = 0,
      LandingSuccess = false
    }
    state.Flights[config.Key] = flight
    state.MissionToFlight[mission] = flight
    attachMissionCallbacks(flight)
    airwing:AddMission(mission)

    log(string.format(
      "MISSION_ADDED key=%s name=%s kind=%s squadron=%s expectedUnits=%d offsetM=%d heading=%d requiredAssets=1 verticalPolicy=true",
      config.Key, mission:GetName(), config.MissionKind,
      tostring(squadron.name or config.SquadronKey), config.ExpectedUnits,
      config.OffsetM, config.Heading
    ))
  end

  OMW.AirOps.TarinkotG8B = {
    Status = "DISPATCHED_AWAITING_ALL_REGISTERED_HELICOPTER_GROUPS",
    Airwing = airwing,
    Zone = zone,
    Flights = state.Flights
  }

  timer.scheduleFunction(function()
    pollBatch()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

if SCHEDULER then
  SCHEDULER:New(nil, startG8B, {}, START_DELAY_SECONDS)
else
  timer.scheduleFunction(function()
    startG8B()
    return nil
  end, nil, timer.getTime() + START_DELAY_SECONDS)
end
