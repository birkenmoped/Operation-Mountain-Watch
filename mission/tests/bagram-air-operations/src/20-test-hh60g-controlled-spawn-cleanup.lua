-- Operation Mountain Watch - isolated Bagram HH-60G controlled spawn/cleanup test.
-- Test-only harness. It runs only when cfg.Tests.HH60GControlledSpawn is true.
local TAG = "[OMW][AirOps.BGRAM.Test.HH60G]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function runTest()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Bagram
  if not cfg then
    log("ERROR: Bagram configuration unavailable.")
    return
  end
  if not cfg.Tests or cfg.Tests.HH60GControlledSpawn ~= true then
    log("SKIP: isolated HH-60G controlled-spawn test is disabled.")
    return
  end
  if cfg.Tests.HH60GControlledSpawnStarted then
    log("SKIP: test already started in this mission run.")
    return
  end
  if not cfg.Started or cfg.ParkingContractOK ~= true then
    log("WAITING: AIRWING or parking contract not ready.")
    return
  end
  if not AUFTRAG or not cfg.Airwing or not cfg.Squadrons or not cfg.Squadrons.HH60G then
    log("ERROR: required AUFTRAG/AIRWING/HH60G objects unavailable.")
    return
  end

  cfg.Tests.HH60GControlledSpawnStarted = true

  local ok, missionOrError = pcall(function()
    -- ALERT5 is deliberately used for this parking-only increment: one HH-60G
    -- asset is spawned uncontrolled and receives no operational tasking.
    local mission = AUFTRAG:NewALERT5(AUFTRAG.Type.LANDATCOORDINATE)
    mission:SetName("TEST_BGRM_HH60G_CONTROLLED_SPAWN")
    mission:SetRequiredAssets(1, 1)
    mission:AssignSquadrons({ cfg.Squadrons.HH60G })
    mission:SetRepeat(0)
    mission:SetReturnToLegion(false)
    cfg.Airwing:AddMission(mission)
    return mission
  end)

  if not ok or not missionOrError then
    cfg.Tests.HH60GControlledSpawnFailed = true
    log("ERROR: mission construction/queue failed: " .. tostring(missionOrError))
    return
  end

  local mission = missionOrError
  cfg.Tests.HH60GControlledSpawnMission = mission
  log("MISSION_QUEUED name=TEST_BGRM_HH60G_CONTROLLED_SPAWN requiredAssets=1 squadron=" .. cfg.SquadronNames.HH60G)

  local function inspectSpawn()
    local groups = mission:GetOpsGroups() or {}
    local count = #groups
    log("SPAWN_INSPECT opsGroups=" .. tostring(count) .. " status=" .. tostring(mission.status))
    if count == 1 then
      local opsGroup = groups[1]
      local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
      local groupName = group and group:GetName() or "N/A"
      local unitCount = group and #(group:GetUnits() or {}) or 0
      log("SPAWN_PASS group=" .. tostring(groupName) .. " units=" .. tostring(unitCount))
    elseif count > 1 then
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("ERROR: more than one HH-60G OPSGROUP recruited: " .. tostring(count))
    else
      log("WAITING: HH-60G asset has not spawned yet.")
    end
  end

  local function cancelMission()
    log("CLEANUP_REQUEST missionStatus=" .. tostring(mission.status))
    mission:Cancel()
  end

  local function inspectCleanup()
    local groups = mission:GetOpsGroups() or {}
    local alive = 0
    for _, opsGroup in ipairs(groups) do
      local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
      if group and group:IsAlive() then alive = alive + 1 end
    end
    log("CLEANUP_INSPECT missionStatus=" .. tostring(mission.status) .. " aliveGroups=" .. tostring(alive))
    if alive == 0 and mission:IsCancelled() then
      cfg.Tests.HH60GControlledSpawnPassed = true
      log("TEST_PASS spawnedExactlyOne=true cleanupComplete=true")
    else
      log("TEST_PENDING cleanupComplete=false")
    end
  end

  if SCHEDULER then
    SCHEDULER:New(nil, inspectSpawn, {}, 30)
    SCHEDULER:New(nil, cancelMission, {}, 90)
    SCHEDULER:New(nil, inspectCleanup, {}, 150)
  else
    timer.scheduleFunction(function() inspectSpawn() return nil end, nil, timer.getTime() + 30)
    timer.scheduleFunction(function() cancelMission() return nil end, nil, timer.getTime() + 90)
    timer.scheduleFunction(function() inspectCleanup() return nil end, nil, timer.getTime() + 150)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, runTest, {}, 24)
else
  timer.scheduleFunction(function() runTest() return nil end, nil, timer.getTime() + 24)
end
