-- Operation Mountain Watch - Tarinkot G8 native UH-60 vertical-departure dispatch.
--
-- Loaded after the accepted G7 foundation in the same generated bundle.
-- Creates exactly one native AIRWING/AUFTRAG dispatch. No COMMANDER,
-- OPSTRANSPORT, SPAWN, standalone FLIGHTGROUP or synthetic zone is permitted.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.TKOT.G8.UH60.VerticalDispatch]"
local BUILD = OMW_TKOT_G8_BUILD or {}

local ZONE_NAME = "ZONE_AIR_US_TKOT_ROTARY_STAGING"
local SQUADRON_KEY = "UH60"
local MISSION_NAME = "OMW-TKOT-G8-UH60-VERTICAL-DISPATCH"
local START_DELAY_SECONDS = 35
local POLL_INTERVAL_SECONDS = 2
local TAKEOFF_TIMEOUT_SECONDS = 240
local MAX_GROUND_DISPLACEMENT_METERS = 75

local state = {
  Finalized = false,
  Mission = nil,
  FlightGroup = nil,
  UnitName = nil,
  InitialPoint = nil,
  MaxGroundDisplacement = 0,
  AirborneDistance = nil,
  OptionApplied = false,
  FlightOnMissionObserved = false,
  MissionAdded = false,
  StartAbsTime = nil
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

local function speedMetersPerSecond(velocity)
  if not velocity then return 0 end
  local x = velocity.x or 0
  local y = velocity.y or 0
  local z = velocity.z or 0
  return math.sqrt(x * x + y * y + z * z)
end

local function missionStatus(mission)
  if not mission then return "nil" end
  local ok, value = pcall(function() return mission:GetState() end)
  if ok and value ~= nil then return tostring(value) end
  return tostring(mission.status or "unknown")
end

local function finalize(status, reason)
  if state.Finalized then return end
  state.Finalized = true

  log(string.format(
    "RESULT G8_UH60_NATIVE_VERTICAL_DEPARTURE status=%s reason=%s missionAdded=%s flightOnMission=%s optionPreferVertical=%s unit=%s maxGroundDisplacementM=%.1f airborneDistanceM=%.1f taxiThresholdM=%d missionState=%s commanderCreated=0 opsTransportCreated=0 spawnCreated=0 standaloneFlightGroupCreated=0 ownerVisualRequired=true",
    tostring(status), tostring(reason or "none"), tostring(state.MissionAdded),
    tostring(state.FlightOnMissionObserved), tostring(state.OptionApplied),
    tostring(state.UnitName or "none"), tonumber(state.MaxGroundDisplacement) or -1,
    tonumber(state.AirborneDistance) or -1, MAX_GROUND_DISPLACEMENT_METERS,
    missionStatus(state.Mission)
  ))

  OMW.AirOps.TarinkotG8 = OMW.AirOps.TarinkotG8 or {}
  OMW.AirOps.TarinkotG8.Status = status
  OMW.AirOps.TarinkotG8.Reason = reason
end

local function recordMissionState(name, from, event, to)
  log(string.format(
    "AUFTRAG_STATE name=%s from=%s event=%s to=%s missionState=%s",
    tostring(name), tostring(from), tostring(event), tostring(to),
    missionStatus(state.Mission)
  ))
end

local function attachMissionCallbacks(mission)
  function mission:OnAfterQueued(from, event, to) recordMissionState("QUEUED", from, event, to) end
  function mission:OnAfterRequested(from, event, to) recordMissionState("REQUESTED", from, event, to) end
  function mission:OnAfterScheduled(from, event, to) recordMissionState("SCHEDULED", from, event, to) end
  function mission:OnAfterStarted(from, event, to) recordMissionState("STARTED", from, event, to) end
  function mission:OnAfterExecuting(from, event, to) recordMissionState("EXECUTING", from, event, to) end
  function mission:OnAfterDone(from, event, to) recordMissionState("DONE", from, event, to) end
  function mission:OnAfterSuccess(from, event, to) recordMissionState("SUCCESS", from, event, to) end
  function mission:OnAfterFailed(from, event, to)
    recordMissionState("FAILED", from, event, to)
    if not state.Finalized then finalize("FAIL", "AUFTRAG_FAILED_BEFORE_ACCEPTED_TAKEOFF") end
  end
  function mission:OnAfterCancel(from, event, to)
    recordMissionState("CANCELLED", from, event, to)
    if not state.Finalized then finalize("FAIL", "AUFTRAG_CANCELLED_BEFORE_ACCEPTED_TAKEOFF") end
  end
end

local function firstUnitFromFlightGroup(flightGroup)
  if not flightGroup or type(flightGroup.GetGroup) ~= "function" then return nil end
  local group = flightGroup:GetGroup()
  if not group then return nil end
  local units = group:GetUnits() or {}
  return units[1]
end

local function installAirwingObserver(airwing)
  function airwing:OnAfterFlightOnMission(from, event, to, flightGroup, mission)
    if mission ~= state.Mission then return end

    state.FlightGroup = flightGroup
    state.FlightOnMissionObserved = true
    state.OptionApplied = flightGroup and flightGroup.OptionPreferVertical == true or false

    local unit = firstUnitFromFlightGroup(flightGroup)
    if unit then
      state.UnitName = unit:GetName()
      local dcsUnit = Unit.getByName(state.UnitName)
      if dcsUnit and dcsUnit:isExist() then
        state.InitialPoint = dcsUnit:getPoint()
      end
    end

    log(string.format(
      "FLIGHT_ON_MISSION group=%s mission=%s missionType=%s unit=%s optionPreferVertical=%s initialX=%s initialY=%s initialZ=%s",
      tostring(flightGroup and flightGroup:GetName() or "none"),
      tostring(mission and mission:GetName() or "none"),
      tostring(mission and mission:GetType() or "none"),
      tostring(state.UnitName or "none"), tostring(state.OptionApplied),
      tostring(state.InitialPoint and state.InitialPoint.x or "none"),
      tostring(state.InitialPoint and state.InitialPoint.y or "none"),
      tostring(state.InitialPoint and state.InitialPoint.z or "none")
    ))
  end
end

local function pollTakeoff()
  if state.Finalized then return end

  local elapsed = timer.getAbsTime() - (state.StartAbsTime or timer.getAbsTime())
  local currentMissionState = string.lower(missionStatus(state.Mission))

  if state.UnitName then
    local dcsUnit = Unit.getByName(state.UnitName)
    if dcsUnit and dcsUnit:isExist() then
      local point = dcsUnit:getPoint()
      if not state.InitialPoint then state.InitialPoint = point end

      local displacement = horizontalDistance(point, state.InitialPoint) or 0
      local inAir = dcsUnit:inAir() == true
      local speed = speedMetersPerSecond(dcsUnit:getVelocity())

      if not inAir and displacement > state.MaxGroundDisplacement then
        state.MaxGroundDisplacement = displacement
      end

      log(string.format(
        "TAKEOFF_POLL elapsed=%.1f unit=%s inAir=%s displacementM=%.1f maxGroundDisplacementM=%.1f speedMps=%.1f optionPreferVertical=%s missionState=%s",
        elapsed, state.UnitName, tostring(inAir), displacement,
        state.MaxGroundDisplacement, speed, tostring(state.OptionApplied),
        missionStatus(state.Mission)
      ))

      if inAir then
        state.AirborneDistance = displacement
        local taxiExceeded = state.MaxGroundDisplacement > MAX_GROUND_DISPLACEMENT_METERS or
          displacement > MAX_GROUND_DISPLACEMENT_METERS

        if not state.OptionApplied then
          finalize("FAIL", "FLIGHTGROUP_VERTICAL_OPTION_NOT_APPLIED")
        elseif taxiExceeded then
          finalize("FAIL", "GROUND_DISPLACEMENT_EXCEEDED_VERTICAL_TAKEOFF_THRESHOLD")
        else
          finalize("PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL", "none")
        end
        return
      end
    end
  end

  if currentMissionState == "failed" or currentMissionState == "cancelled" then
    finalize("FAIL", "MISSION_TERMINATED_BEFORE_TAKEOFF")
    return
  end

  if elapsed >= TAKEOFF_TIMEOUT_SECONDS then
    finalize("FAIL", "TAKEOFF_TIMEOUT")
    return
  end

  timer.scheduleFunction(function()
    pollTakeoff()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

local function startG8()
  log("BEGIN Tarinkot G8 native UH-60 vertical-departure dispatch")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(BUILD.Builder), tostring(BUILD.BuilderVersion),
    tostring(BUILD.GitCommit), tostring(BUILD.GeneratedUtc)
  ))
  log(string.format(
    "SCOPE zone=%s squadronKey=%s mission=%s commander=0 opstransport=0 spawn=0 standaloneFlightGroup=0 syntheticZone=0",
    ZONE_NAME, SQUADRON_KEY, MISSION_NAME
  ))

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
  local squadron = g7.Squadrons and g7.Squadrons[SQUADRON_KEY] or nil
  local payload = g7.RolePayloads and g7.RolePayloads[SQUADRON_KEY] or nil

  if not airwing or not airwing:IsRunning() then
    finalize("FAIL", "AIRWING_NOT_RUNNING")
    return
  end
  if not squadron then
    finalize("FAIL", "UH60_SQUADRON_UNAVAILABLE")
    return
  end
  if not payload then
    finalize("FAIL", "UH60_ROLE_PAYLOAD_UNAVAILABLE")
    return
  end
  if airwing.OptionPreferVerticalLanding ~= true then
    finalize("FAIL", "AIRWING_VERTICAL_POLICY_NOT_SET")
    return
  end

  local mission = AUFTRAG:NewLANDATCOORDINATE(
    zone:GetCoordinate(),
    30,
    10,
    90,
    80,
    1000,
    false
  )
  if not mission then
    finalize("FAIL", "AUFTRAG_CONSTRUCTION_FAILED")
    return
  end

  mission:SetName(MISSION_NAME)
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  mission:AddRequiredPayload(payload)
  mission:SetPriority(10, true)
  mission:SetRepeat(0)
  mission:SetTime(1, 600)
  mission:SetDuration(600)
  mission:SetMissionRange(10)
  mission:SetEvaluationTime(10)
  attachMissionCallbacks(mission)

  state.Mission = mission
  state.StartAbsTime = timer.getAbsTime()
  installAirwingObserver(airwing)

  OMW.AirOps.TarinkotG8 = {
    Status = "DISPATCHED_AWAITING_TAKEOFF",
    Zone = zone,
    Airwing = airwing,
    Squadron = squadron,
    Payload = payload,
    Mission = mission
  }

  airwing:AddMission(mission)
  state.MissionAdded = true

  log(string.format(
    "MISSION_ADDED name=%s type=%s squadron=%s payloadAircraftType=%s destinationZone=%s requiredAssets=1 verticalPolicy=true",
    mission:GetName(), mission:GetType(), tostring(squadron.name or SQUADRON_KEY),
    tostring(payload.aircrafttype), ZONE_NAME
  ))

  timer.scheduleFunction(function()
    pollTakeoff()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

if SCHEDULER then
  SCHEDULER:New(nil, startG8, {}, START_DELAY_SECONDS)
else
  timer.scheduleFunction(function()
    startG8()
    return nil
  end, nil, timer.getTime() + START_DELAY_SECONDS)
end
