local TAG = "[OMW][SALERNO][COMMANDER-DISPATCH]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function tableCount(value)
  local count = 0
  if type(value) == "table" then for _ in pairs(value) do count = count + 1 end end
  return count
end

local function stateOf(object)
  if object and type(object.GetState) == "function" then
    local ok, state = pcall(function() return object:GetState() end)
    if ok then return string.lower(tostring(state)) end
  end
  return "unknown"
end

local function commanderStatusOf(mission)
  if mission and mission.statusCommander ~= nil then
    return string.lower(tostring(mission.statusCommander))
  end
  return "unknown"
end

local function isProgressed(state)
  return state ~= "planned" and state ~= "unknown"
end

local function isCommanderSelected(status)
  return status ~= "planned" and status ~= "unknown"
end

local function configureMission(mission)
  mission:SetName("OMW-SAL-COMMANDER-CAS")
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, 180)
  mission:SetDuration(120)
  mission:SetReturnToLegion(true)
  mission:SetRepeat(0)

  function mission:OnAfterStarted(From, Event, To)
    log(string.format("EVENT event=Started from=%s to=%s", tostring(From), tostring(To)))
  end
  function mission:OnAfterExecuting(From, Event, To)
    log(string.format("EVENT event=Executing from=%s to=%s", tostring(From), tostring(To)))
  end
  function mission:OnAfterDone(From, Event, To)
    log(string.format("EVENT event=Done from=%s to=%s", tostring(From), tostring(To)))
  end
  function mission:OnAfterFailed(From, Event, To)
    log(string.format("EVENT event=Failed from=%s to=%s", tostring(From), tostring(To)))
  end
  function mission:OnAfterCancel(From, Event, To)
    log(string.format("EVENT event=Cancel from=%s to=%s", tostring(From), tostring(To)))
  end
  return mission
end

local function logSnapshot(cfg, commander, mission, label)
  local missionState = stateOf(mission)
  local commanderStatus = commanderStatusOf(mission)
  local assigned = cfg.CommanderMissionAssigned == true
  local requested = cfg.AirwingMissionRequested == true
  local opsOnMission = cfg.CommanderOpsOnMission == true or cfg.AirwingOpsOnMission == true

  log(string.format(
    "SNAPSHOT label=%s commanderState=%s missionState=%s commanderMissionStatus=%s commanderQueue=%d airwingQueue=%d assigned=%s requested=%s opsOnMission=%s",
    tostring(label), stateOf(commander), missionState, commanderStatus,
    tableCount(commander and commander.missionqueue),
    tableCount(cfg.ConstructedAirwing and cfg.ConstructedAirwing.missionqueue),
    tostring(assigned), tostring(requested), tostring(opsOnMission)))

  return missionState, commanderStatus, assigned, requested, opsOnMission
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg or not cfg.CommanderBaselineConstructed or not cfg.CommanderStarted then
    log("COMPLETE status=FAIL reason=started-commander-baseline-missing")
    return
  end

  if cfg.DispatchMissionsAdded and cfg.DispatchMissionsAdded > 0 then
    log("COMPLETE status=FAIL reason=direct-airwing-test-not-isolated missionsAdded=" .. tostring(cfg.DispatchMissionsAdded))
    return
  end

  local commander = cfg.ConstructedCommander
  local airwing = cfg.ConstructedAirwing
  local zones = cfg.DispatchTestZones
  if not commander or type(commander.AddMission) ~= "function" then
    log("COMPLETE status=FAIL reason=COMMANDER.AddMission-unavailable")
    return
  end
  if stateOf(commander) ~= "onduty" then
    log("COMPLETE status=FAIL reason=commander-not-onduty state=" .. stateOf(commander))
    return
  end
  if not zones or not zones.CAS then
    log("COMPLETE status=FAIL reason=cas-zone-missing")
    return
  end

  local mission
  local okBuild, buildDetail = pcall(function()
    mission = configureMission(AUFTRAG:NewCAS(zones.CAS, 3000, 110, zones.CAS:GetCoordinate(), 90, 2))
  end)
  if not okBuild or not mission then
    log("COMPLETE status=FAIL phase=mission-construction detail=" .. tostring(buildDetail))
    return
  end

  local eligibility = false
  local okEligibility, eligibilityDetail = pcall(function()
    if type(commander.CanMission) ~= "function" then
      error("COMMANDER.CanMission unavailable")
    end
    eligibility = commander:CanMission(mission) == true
  end)
  if not okEligibility then
    log("COMPLETE status=FAIL phase=eligibility-check detail=" .. tostring(eligibilityDetail))
    return
  end

  log(string.format(
    "ELIGIBILITY commanderCanMission=%s commanderState=%s airwingState=%s commanderLegions=%d airwingCohorts=%d payloads=%d",
    tostring(eligibility), stateOf(commander), stateOf(airwing),
    tableCount(commander.legions), tableCount(airwing and airwing.cohorts), tableCount(airwing and airwing.payloads)))

  local commanderQueueBefore = tableCount(commander.missionqueue)
  local okAdd, addDetail = pcall(function() commander:AddMission(mission) end)
  if not okAdd then
    log("COMPLETE status=FAIL phase=commander-add-mission detail=" .. tostring(addDetail))
    return
  end

  cfg.CommanderDispatchMission = mission
  cfg.CommanderEligibility = eligibility

  local commanderQueueAfter = tableCount(commander.missionqueue)
  log(string.format(
    "ADDED name=OMW-SAL-COMMANDER-CAS via=COMMANDER missionState=%s commanderMissionStatus=%s queueBefore=%d queueAfter=%d requiredAssets=1 durationSec=120",
    stateOf(mission), commanderStatusOf(mission), commanderQueueBefore, commanderQueueAfter))

  local statusTriggered = false
  local statusTriggerOk, statusTriggerDetail = pcall(function()
    if type(commander.Status) ~= "function" then
      error("COMMANDER.Status unavailable")
    end
    commander:Status()
    statusTriggered = true
  end)
  log(string.format(
    "SELECTION_TRIGGER method=COMMANDER.Status called=%s ok=%s detail=%s",
    tostring(statusTriggered), tostring(statusTriggerOk), tostring(statusTriggerDetail)))

  log("CONTRACT isolated=true directAirwingMissions=0 missionsAdded=1 commanderStarted=true expectedCommanderState=OnDuty selectionVia=COMMANDER.CheckMissionQueue expectedAircraft=AH64 expectedTakeoff=COLD observationSec=75 parkingControl=DEFERRED")
  log("COMPLETE status=PENDING-RUNTIME")

  SCHEDULER:New(nil, function()
    logSnapshot(cfg, commander, mission, "T+5")
  end, {}, 5)

  SCHEDULER:New(nil, function()
    logSnapshot(cfg, commander, mission, "T+30")
  end, {}, 30)

  SCHEDULER:New(nil, function()
    local missionState, commanderStatus, assigned, requested, opsOnMission = logSnapshot(cfg, commander, mission, "T+75")
    local selected = assigned or isCommanderSelected(commanderStatus)
    local progressed = isProgressed(missionState)
    local final = eligibility and statusTriggerOk and selected and progressed

    log(string.format(
      "DECISION eligible=%s selected=%s assignedEvent=%s requestedEvent=%s opsOnMissionEvent=%s progressed=%s",
      tostring(eligibility), tostring(selected), tostring(assigned), tostring(requested), tostring(opsOnMission), tostring(progressed)))
    log(string.format(
      "FINAL status=%s commanderState=%s missionState=%s commanderMissionStatus=%s expectedEligibility=true expectedSelection=true expectedProgress=true",
      final and "PASS" or "FAIL", stateOf(commander), missionState, commanderStatus))

    if type(commander.MissionCancel) == "function" then
      local okCancel, cancelDetail = pcall(function() commander:MissionCancel(mission) end)
      log(string.format("CLEANUP cancelCalled=true cancelOk=%s detail=%s", tostring(okCancel), tostring(cancelDetail)))
    else
      log("CLEANUP cancelCalled=false reason=MissionCancel-unavailable")
    end
  end, {}, 75)
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 35)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 35)
end
