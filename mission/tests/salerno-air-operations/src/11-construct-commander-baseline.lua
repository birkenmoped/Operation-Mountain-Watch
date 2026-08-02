local TAG = "[OMW][SALERNO][COMMANDER]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function tableCount(value)
  local count = 0
  if type(value) == "table" then for _ in pairs(value) do count = count + 1 end end
  return count
end

local function objectState(object)
  if object and type(object.GetState) == "function" then
    local ok, state = pcall(function() return object:GetState() end)
    if ok then return tostring(state) end
  end
  return "UNKNOWN"
end

local function missionName(mission)
  if mission and type(mission.GetName) == "function" then
    local ok, name = pcall(function() return mission:GetName() end)
    if ok and name then return tostring(name) end
  end
  return tostring(mission and mission.name or "UNKNOWN")
end

local function legionNames(legions)
  local names = {}
  if type(legions) == "table" then
    for _, legion in pairs(legions) do
      names[#names + 1] = tostring(legion and (legion.alias or legion.ClassName) or "UNKNOWN")
    end
  end
  table.sort(names)
  return table.concat(names, ",")
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg or not cfg.OperationalBaselineActivated then
    log("COMPLETE status=FAIL reason=operational-baseline-missing")
    return
  end
  if not COMMANDER or type(COMMANDER.New) ~= "function" then
    log("COMPLETE status=FAIL reason=COMMANDER.New-unavailable")
    return
  end
  if not coalition or not coalition.side or coalition.side.BLUE == nil then
    log("COMPLETE status=FAIL reason=coalition.side.BLUE-unavailable")
    return
  end

  local airwing = cfg.ConstructedAirwing
  if not airwing then
    log("COMPLETE status=FAIL reason=airwing-missing")
    return
  end

  local commander
  local stateBeforeStart = "UNKNOWN"
  local ok, detail = pcall(function()
    commander = COMMANDER:New(coalition.side.BLUE, "CMD_BLUE_AFGHANISTAN_TEST")

    if type(commander.SetVerbosity) == "function" then
      commander:SetVerbosity(2)
    end
    if type(airwing.SetVerbosity) == "function" then
      airwing:SetVerbosity(2)
    end

    if type(commander.AddAirwing) == "function" then
      commander:AddAirwing(airwing)
    elseif type(commander.AddLegion) == "function" then
      commander:AddLegion(airwing)
    else
      error("COMMANDER AddAirwing/AddLegion unavailable")
    end

    function commander:OnAfterMissionAssign(From, Event, To, Mission, Legions)
      cfg.CommanderMissionAssigned = true
      cfg.CommanderAssignedMission = Mission
      cfg.CommanderAssignedLegions = Legions
      log(string.format(
        "EVENT event=MissionAssign from=%s to=%s mission=%s legions=%d names=%s",
        tostring(From), tostring(To), missionName(Mission), tableCount(Legions), legionNames(Legions)))
    end

    function commander:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
      cfg.CommanderOpsOnMission = true
      log(string.format(
        "EVENT event=OpsOnMission from=%s to=%s mission=%s opsGroup=%s",
        tostring(From), tostring(To), missionName(Mission),
        tostring(OpsGroup and (OpsGroup.groupname or OpsGroup.alias or OpsGroup.ClassName) or "UNKNOWN")))
    end

    function airwing:OnAfterMissionAssign(From, Event, To, Mission, Legions)
      cfg.AirwingMissionAssigned = true
      log(string.format(
        "AIRWING_EVENT event=MissionAssign from=%s to=%s mission=%s sourceLegions=%d names=%s",
        tostring(From), tostring(To), missionName(Mission), tableCount(Legions), legionNames(Legions)))
    end

    function airwing:OnAfterMissionRequest(From, Event, To, Mission, Assets)
      cfg.AirwingMissionRequested = true
      log(string.format(
        "AIRWING_EVENT event=MissionRequest from=%s to=%s mission=%s assets=%d",
        tostring(From), tostring(To), missionName(Mission), tableCount(Assets)))
    end

    function airwing:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
      cfg.AirwingOpsOnMission = true
      log(string.format(
        "AIRWING_EVENT event=OpsOnMission from=%s to=%s mission=%s opsGroup=%s",
        tostring(From), tostring(To), missionName(Mission),
        tostring(OpsGroup and (OpsGroup.groupname or OpsGroup.alias or OpsGroup.ClassName) or "UNKNOWN")))
    end

    stateBeforeStart = objectState(commander)
    if type(commander.Start) ~= "function" then
      error("COMMANDER.Start unavailable")
    end
    commander:Start()
  end)

  if not ok or not commander then
    log("COMPLETE status=FAIL phase=construction-or-start detail=" .. tostring(detail))
    return
  end

  local stateAfterStart = objectState(commander)
  local legionCount = tableCount(commander.legions)
  local linked = airwing.commander == commander
  local started = string.lower(stateAfterStart) == "onduty"
  local valid = started and legionCount == 1 and linked

  cfg.ConstructedCommander = commander
  cfg.CommanderBaselineConstructed = valid
  cfg.CommanderStarted = started

  log(string.format(
    "SOURCE mooseTag=2.9.18 commanderClassVersion=%s requiredSequence=New-AddAirwing-Start",
    tostring(COMMANDER.version)))
  log("CONSTRUCTED alias=CMD_BLUE_AFGHANISTAN_TEST coalition=BLUE")
  log(string.format(
    "FSM beforeStart=%s afterStart=%s expectedAfterStart=OnDuty started=%s",
    stateBeforeStart, stateAfterStart, tostring(started)))
  log(string.format(
    "BOUND airwing=AW_US_SALERNO legionTableCount=%d reverseLink=%s airwingState=%s",
    legionCount, tostring(linked), objectState(airwing)))
  log("SAFETY isolated=true directAirwingMissions=0 missionsAdded=0 commanderDispatch=false newSpawnsExpected=0 parkingControl=DEFERRED")
  log("COMPLETE status=" .. (valid and "PASS" or "FAIL"))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 30)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 30)
end
