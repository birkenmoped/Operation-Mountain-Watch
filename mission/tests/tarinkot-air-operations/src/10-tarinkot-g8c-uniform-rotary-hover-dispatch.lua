-- Operation Mountain Watch - Tarinkot G8C uniform rotary hover dispatch.
--
-- This diagnostic dispatch keeps the accepted G7 AIRWING/SQUADRON foundation
-- intact and sends every registered rotary group through the same public MOOSE
-- AUFTRAG.Type.HOVER path. The result deliberately does not infer taxiing from
-- coordinate displacement; vertical departure remains owner visual acceptance.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.TKOT.G8C.UniformRotaryHoverDispatch]"
local BUILD = OMW_TKOT_G8C_BUILD or {}

local ZONE_NAME = "ZONE_AIR_US_TKOT_ROTARY_STAGING"
local START_DELAY_SECONDS = 35
local POLL_INTERVAL_SECONDS = 2
local ASSIGNMENT_TIMEOUT_SECONDS = 720
local TAKEOFF_TIMEOUT_SECONDS = 360
local AGGREGATE_TIMEOUT_SECONDS = 1200
local HOVER_ALTITUDE_FEET = 50
local HOVER_TIME_SECONDS = 300

local dispatches = {
  { Key = "AH64_1", SquadronKey = "AH64", ExpectedUnits = 2, Heading = 0, Distance = 60 },
  { Key = "AH64_2", SquadronKey = "AH64", ExpectedUnits = 2, Heading = 72, Distance = 60 },
  { Key = "UH60_1", SquadronKey = "UH60", ExpectedUnits = 1, Heading = 144, Distance = 60 },
  { Key = "UH60_2", SquadronKey = "UH60", ExpectedUnits = 1, Heading = 216, Distance = 60 },
  { Key = "CH47_1", SquadronKey = "CH47", ExpectedUnits = 1, Heading = 288, Distance = 60 }
}

local state = {
  Finalized = false,
  StartAbsTime = nil,
  Zone = nil,
  Airwing = nil,
  ByMission = {},
  ByKey = {},
  MissionsAdded = 0
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

local function countTable(value)
  local count = 0
  for _ in pairs(value or {}) do count = count + 1 end
  return count
end

local function finalize(status, reason)
  if state.Finalized then return end
  state.Finalized = true

  local assigned, takeoffGroups, runtimeUnits, failedGroups, verticalOptions = 0, 0, 0, 0, 0
  for _, entry in ipairs(dispatches) do
    local runtime = state.ByKey[entry.Key]
    if runtime then
      if runtime.FlightOnMission then assigned = assigned + 1 end
      if runtime.Takeoff then takeoffGroups = takeoffGroups + 1 end
      runtimeUnits = runtimeUnits + (runtime.RuntimeUnits or 0)
      if runtime.Failed then failedGroups = failedGroups + 1 end
      if runtime.OptionPreferVertical then verticalOptions = verticalOptions + 1 end
    end
  end

  log(string.format(
    "RESULT G8C_UNIFORM_ROTARY_HOVER_DISPATCH status=%s reason=%s assigned=%d/5 takeoffGroups=%d/5 runtimeUnits=%d/7 failedGroups=%d optionPreferVertical=%d/5 hoverMissionsAdded=%d/5 ownerVisualRequired=true taxiInference=disabled",
    tostring(status), tostring(reason or "none"), assigned, takeoffGroups,
    runtimeUnits, failedGroups, verticalOptions, state.MissionsAdded
  ))

  OMW.AirOps.TarinkotG8C = OMW.AirOps.TarinkotG8C or {}
  OMW.AirOps.TarinkotG8C.Status = status
  OMW.AirOps.TarinkotG8C.Reason = reason
end

local function failRuntime(runtime, reason)
  if runtime.Failed then return end
  runtime.Failed = true
  log("GROUP_FAILED key=" .. runtime.Key .. " reason=" .. tostring(reason))
  finalize("FAIL", tostring(reason) .. " key=" .. runtime.Key)
end

local function attachMissionCallbacks(runtime)
  function runtime.Mission:OnAfterFailed(from, event, to)
    log(string.format("AUFTRAG_STATE key=%s from=%s event=%s to=%s state=%s", runtime.Key, tostring(from), tostring(event), tostring(to), missionState(runtime.Mission)))
    failRuntime(runtime, "AUFTRAG_FAILED")
  end
  function runtime.Mission:OnAfterCancel(from, event, to)
    log(string.format("AUFTRAG_STATE key=%s from=%s event=%s to=%s state=%s", runtime.Key, tostring(from), tostring(event), tostring(to), missionState(runtime.Mission)))
    failRuntime(runtime, "AUFTRAG_CANCELLED")
  end
end

local function installAirwingObserver(airwing)
  function airwing:OnAfterFlightOnMission(from, event, to, flightGroup, mission)
    local runtime = state.ByMission[mission]
    if not runtime or state.Finalized then return end

    runtime.FlightOnMission = true
    runtime.FlightGroup = flightGroup
    runtime.FlightOnMissionAbsTime = timer.getAbsTime()
    runtime.OptionPreferVertical = flightGroup and flightGroup.OptionPreferVertical == true or false
    local group = flightGroup and flightGroup:GetGroup() or nil
    local units = group and group:GetUnits() or {}
    runtime.RuntimeUnits = #units
    runtime.UnitNames = {}
    for _, unit in ipairs(units) do
      runtime.UnitNames[#runtime.UnitNames + 1] = unit:GetName()
    end

    log(string.format(
      "FLIGHT_ON_MISSION key=%s group=%s mission=%s missionType=%s runtimeUnits=%d expectedUnits=%d optionPreferVertical=%s",
      runtime.Key, tostring(flightGroup and flightGroup:GetName() or "none"),
      tostring(mission and mission:GetName() or "none"), tostring(mission and mission:GetType() or "none"),
      runtime.RuntimeUnits, runtime.ExpectedUnits, tostring(runtime.OptionPreferVertical)
    ))

    if runtime.RuntimeUnits ~= runtime.ExpectedUnits then
      failRuntime(runtime, "RUNTIME_UNIT_COUNT_MISMATCH")
    elseif not runtime.OptionPreferVertical then
      failRuntime(runtime, "FLIGHTGROUP_VERTICAL_OPTION_NOT_APPLIED")
    end
  end
end

local function allGroupsAccepted()
  for _, entry in ipairs(dispatches) do
    local runtime = state.ByKey[entry.Key]
    if not runtime or not runtime.Takeoff then return false end
  end
  return true
end

local function poll()
  if state.Finalized then return end
  local now = timer.getAbsTime()

  for _, entry in ipairs(dispatches) do
    local runtime = state.ByKey[entry.Key]
    if not runtime then
      finalize("FAIL", "RUNTIME_DISPATCH_MISSING key=" .. entry.Key)
      return
    end

    if not runtime.FlightOnMission then
      if now - state.StartAbsTime >= ASSIGNMENT_TIMEOUT_SECONDS then
        failRuntime(runtime, "ASSIGNMENT_TIMEOUT")
        return
      end
    elseif not runtime.Takeoff then
      local anyAirborne = false
      for _, unitName in ipairs(runtime.UnitNames or {}) do
        local unit = Unit.getByName(unitName)
        if unit and unit:isExist() and unit:inAir() then anyAirborne = true end
      end
      if anyAirborne then
        runtime.Takeoff = true
        log("TAKEOFF_OBSERVED key=" .. runtime.Key .. " optionPreferVertical=" .. tostring(runtime.OptionPreferVertical))
      elseif now - runtime.FlightOnMissionAbsTime >= TAKEOFF_TIMEOUT_SECONDS then
        failRuntime(runtime, "TAKEOFF_TIMEOUT")
        return
      end
    end
  end

  if allGroupsAccepted() then
    finalize("PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL", "none")
    return
  end
  if now - state.StartAbsTime >= AGGREGATE_TIMEOUT_SECONDS then
    finalize("FAIL", "AGGREGATE_TIMEOUT")
    return
  end

  timer.scheduleFunction(function()
    poll()
    return nil
  end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

local function startG8C()
  log("BEGIN Tarinkot G8C uniform rotary hover dispatch")
  log(string.format("BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s", tostring(BUILD.Builder), tostring(BUILD.BuilderVersion), tostring(BUILD.GitCommit), tostring(BUILD.GeneratedUtc)))

  local g7 = OMW.AirOps.TarinkotG7
  if not g7 or g7.Status ~= "PASS" then finalize("BLOCKED", "G7_FOUNDATION_NOT_PASS"); return end
  local airwing = g7.Airwing
  if not airwing or not airwing:IsRunning() then finalize("FAIL", "AIRWING_NOT_RUNNING"); return end
  if airwing.OptionPreferVerticalLanding ~= true then finalize("FAIL", "AIRWING_VERTICAL_POLICY_NOT_SET"); return end
  local zone = ZONE and ZONE:FindByName(ZONE_NAME) or nil
  if not zone then finalize("BLOCKED", "MISSING_MISSION_EDITOR_ZONE_" .. ZONE_NAME); return end

  state.StartAbsTime = timer.getAbsTime()
  state.Airwing = airwing
  state.Zone = zone
  installAirwingObserver(airwing)

  for _, entry in ipairs(dispatches) do
    local squadron = g7.Squadrons and g7.Squadrons[entry.SquadronKey] or nil
    local payload = g7.RolePayloads and g7.RolePayloads[entry.SquadronKey] or nil
    if not squadron then finalize("FAIL", "SQUADRON_UNAVAILABLE key=" .. entry.Key); return end
    if not payload then finalize("FAIL", "ROLE_PAYLOAD_UNAVAILABLE key=" .. entry.Key); return end

    squadron:AddMissionCapability(AUFTRAG.Type.HOVER, 100)
    airwing:AddPayloadCapability(payload, AUFTRAG.Type.HOVER, 100)

    local target = zone:GetCoordinate():Translate(entry.Distance, entry.Heading)
    local mission = AUFTRAG:NewHOVER(target, HOVER_ALTITUDE_FEET, HOVER_TIME_SECONDS)
    if not mission then finalize("FAIL", "AUFTRAG_CONSTRUCTION_FAILED key=" .. entry.Key); return end
    mission:SetName("OMW-TKOT-G8C-" .. entry.Key .. "-HOVER")
    mission:SetRequiredAssets(1, 1)
    mission:AssignSquadrons({ squadron })
    mission:AddRequiredPayload(payload)
    mission:SetPriority(10, true)
    mission:SetRepeat(0)
    mission:SetTime(1, 600)
    mission:SetDuration(600)
    mission:SetMissionRange(10)
    mission:SetEvaluationTime(10)

    local runtime = { Key = entry.Key, ExpectedUnits = entry.ExpectedUnits, Mission = mission, RuntimeUnits = 0 }
    state.ByKey[entry.Key] = runtime
    state.ByMission[mission] = runtime
    attachMissionCallbacks(runtime)
    airwing:AddMission(mission)
    state.MissionsAdded = state.MissionsAdded + 1
    log(string.format("MISSION_ADDED key=%s type=%s squadron=%s requiredAssets=1 expectedUnits=%d payloadAircraftType=%s targetHeading=%d targetDistanceM=%d", entry.Key, tostring(mission:GetType()), tostring(squadron.name or entry.SquadronKey), entry.ExpectedUnits, tostring(payload.aircrafttype), entry.Heading, entry.Distance))
  end

  OMW.AirOps.TarinkotG8C = { Status = "DISPATCHED_AWAITING_TAKEOFF", Airwing = airwing, Zone = zone, Dispatches = state.ByKey }
  timer.scheduleFunction(function() poll(); return nil end, nil, timer.getTime() + POLL_INTERVAL_SECONDS)
end

if SCHEDULER then
  SCHEDULER:New(nil, startG8C, {}, START_DELAY_SECONDS)
else
  timer.scheduleFunction(function() startG8C(); return nil end, nil, timer.getTime() + START_DELAY_SECONDS)
end
