local TAG = "[OMW][SALERNO][DISPATCH]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function stateOf(mission)
  if mission and type(mission.GetState) == "function" then
    local ok, state = pcall(function() return mission:GetState() end)
    if ok then return tostring(state) end
  end
  return "UNKNOWN"
end

local function configureMission(mission, name)
  mission:SetName(name)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, 210)
  mission:SetDuration(150)
  mission:SetReturnToLegion(true)
  mission:SetRepeat(0)

  function mission:OnAfterStarted(From, Event, To)
    log(string.format("EVENT name=%s event=Started from=%s to=%s", name, tostring(From), tostring(To)))
  end
  function mission:OnAfterExecuting(From, Event, To)
    log(string.format("EVENT name=%s event=Executing from=%s to=%s", name, tostring(From), tostring(To)))
  end
  function mission:OnAfterDone(From, Event, To)
    log(string.format("EVENT name=%s event=Done from=%s to=%s", name, tostring(From), tostring(To)))
  end
  function mission:OnAfterFailed(From, Event, To)
    log(string.format("EVENT name=%s event=Failed from=%s to=%s", name, tostring(From), tostring(To)))
  end
  function mission:OnAfterCancel(From, Event, To)
    log(string.format("EVENT name=%s event=Cancel from=%s to=%s", name, tostring(From), tostring(To)))
  end
  return mission
end

local function logSnapshot(cfg, label)
  local missions = cfg.DispatchMissions or {}
  local states = {}
  local progressed = 0
  for _, entry in ipairs(missions) do
    local state = stateOf(entry.Mission)
    states[#states + 1] = entry.Name .. "=" .. state
    if state ~= "Planned" and state ~= "UNKNOWN" then progressed = progressed + 1 end
  end
  log(string.format("SNAPSHOT label=%s progressed=%d/%d states=%s",
    tostring(label), progressed, #missions, table.concat(states, ";")))
  return progressed
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg or not cfg.DispatchReadinessValidated then
    log("COMPLETE status=FAIL reason=dispatch-readiness-missing")
    return
  end

  local airwing = cfg.ConstructedAirwing
  local zones = cfg.DispatchTestZones
  if not airwing or not zones or not zones.CAS or not zones.RECON or not zones.LIFT then
    log("COMPLETE status=FAIL reason=dispatch-contract-missing")
    return
  end

  local failures = {}
  local missions = {}
  local okBuild, buildDetail = pcall(function()
    local reconSet = SET_ZONE:New()
    reconSet:AddZone(zones.RECON)

    local troopSet = SET_GROUP:New()

    local cas = configureMission(
      AUFTRAG:NewCAS(zones.CAS, 3000, 110, zones.CAS:GetCoordinate(), 90, 2),
      "OMW-SAL-TEST-CAS")
    local recon = configureMission(
      AUFTRAG:NewRECON(reconSet, 90, 2500, false, false),
      "OMW-SAL-TEST-RECON")
    local lift = configureMission(
      AUFTRAG:NewTROOPTRANSPORT(troopSet, zones.LIFT:GetCoordinate(), nil, 150),
      "OMW-SAL-TEST-LIFT")

    missions = {
      { Name = "CAS", Mission = cas },
      { Name = "RECON", Mission = recon },
      { Name = "LIFT", Mission = lift }
    }
  end)

  if not okBuild then
    log("COMPLETE status=FAIL phase=mission-construction detail=" .. tostring(buildDetail))
    return
  end

  local added = 0
  for _, entry in ipairs(missions) do
    local okAdd, addDetail = pcall(function() airwing:AddMission(entry.Mission) end)
    if okAdd then
      added = added + 1
      log(string.format("ADDED name=%s state=%s requiredAssets=1 durationSec=150",
        entry.Name, stateOf(entry.Mission)))
    else
      failures[#failures + 1] = entry.Name
      log(string.format("ERROR name=%s phase=AddMission detail=%s", entry.Name, tostring(addDetail)))
    end
  end

  cfg.DispatchMissions = missions
  cfg.DispatchMissionsAdded = added
  log(string.format("CONTRACT missionsAdded=%d/3 deliberateGroupSpawnsMax=3 observationSec=105", added))
  log("COMPLETE status=" .. (#failures == 0 and "PENDING-RUNTIME" or "FAIL"))

  if SCHEDULER then
    SCHEDULER:New(nil, function() logSnapshot(cfg, "T+30") end, {}, 30)
    SCHEDULER:New(nil, function() logSnapshot(cfg, "T+60") end, {}, 60)
    SCHEDULER:New(nil, function()
      local progressed = logSnapshot(cfg, "T+105")
      local final = added == 3 and progressed >= 2
      log(string.format("FINAL status=%s missionsAdded=%d progressed=%d expectedMinimum=2",
        final and "PASS" or "FAIL", added, progressed))
    end, {}, 105)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 26)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 26)
end
