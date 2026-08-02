local TAG = "[OMW][SALERNO][COMMANDER-DISPATCH]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function stateOf(mission)
  if mission and type(mission.GetState) == "function" then
    local ok, state = pcall(function() return mission:GetState() end)
    if ok then return string.lower(tostring(state)) end
  end
  return "unknown"
end

local function isProgressed(state)
  return state ~= "planned" and state ~= "unknown"
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

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg or not cfg.CommanderBaselineConstructed then
    log("COMPLETE status=FAIL reason=commander-baseline-missing")
    return
  end

  if cfg.DispatchMissionsAdded and cfg.DispatchMissionsAdded > 0 then
    log("COMPLETE status=FAIL reason=direct-airwing-test-not-isolated missionsAdded=" .. tostring(cfg.DispatchMissionsAdded))
    return
  end

  local commander = cfg.ConstructedCommander
  local zones = cfg.DispatchTestZones
  if not commander or type(commander.AddMission) ~= "function" then
    log("COMPLETE status=FAIL reason=COMMANDER.AddMission-unavailable")
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

  local okAdd, addDetail = pcall(function() commander:AddMission(mission) end)
  if not okAdd then
    log("COMPLETE status=FAIL phase=commander-add-mission detail=" .. tostring(addDetail))
    return
  end

  cfg.CommanderDispatchMission = mission
  log(string.format("ADDED name=OMW-SAL-COMMANDER-CAS via=COMMANDER state=%s requiredAssets=1 durationSec=120", stateOf(mission)))
  log("CONTRACT isolated=true directAirwingMissions=0 missionsAdded=1 deliberateGroupSpawnsMax=1 expectedAircraft=AH64 expectedTakeoff=COLD observationSec=90 parkingControl=DEFERRED")
  log("COMPLETE status=PENDING-RUNTIME")

  SCHEDULER:New(nil, function()
    log(string.format("SNAPSHOT label=T+30 state=%s", stateOf(mission)))
  end, {}, 30)

  SCHEDULER:New(nil, function()
    local state = stateOf(mission)
    local progressed = isProgressed(state)
    log(string.format("SNAPSHOT label=T+90 state=%s", state))
    log(string.format("FINAL status=%s state=%s expectedProgress=true plannedIsFailure=true", progressed and "PASS" or "FAIL", state))
    if type(commander.MissionCancel) == "function" then
      local okCancel, cancelDetail = pcall(function() commander:MissionCancel(mission) end)
      log(string.format("CLEANUP cancelCalled=true cancelOk=%s detail=%s", tostring(okCancel), tostring(cancelDetail)))
    else
      log("CLEANUP cancelCalled=false reason=MissionCancel-unavailable")
    end
  end, {}, 90)
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 35)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 35)
end
