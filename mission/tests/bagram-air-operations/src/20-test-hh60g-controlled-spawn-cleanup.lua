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
  if not AUFTRAG.Type or not AUFTRAG.Type.ALERT5 or not AUFTRAG.Type.LANDATCOORDINATE then
    log("ERROR: required AUFTRAG mission types ALERT5/LANDATCOORDINATE unavailable.")
    return
  end
  if not cfg.Payloads or not cfg.Payloads.HH60G then
    log("ERROR: HH-60G payload registration unavailable.")
    return
  end

  cfg.Tests.HH60GControlledSpawnStarted = true

  local ok, missionOrError = pcall(function()
    -- ALERT5 is a real AUFTRAG mission type. The HH-60G cohort must therefore
    -- advertise ALERT5 capability in addition to the mission type used for its
    -- payload/task selection (LANDATCOORDINATE).
    local mission = AUFTRAG:NewALERT5(AUFTRAG.Type.LANDATCOORDINATE)
    mission:SetName("TEST_BGRM_HH60G_CONTROLLED_SPAWN")
    mission:SetRequiredAssets(1, 1)
    mission:AssignSquadrons({ cfg.Squadrons.HH60G })
    mission:SetRepeat(0)
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
  log("MISSION_QUEUED name=TEST_BGRM_HH60G_CONTROLLED_SPAWN requiredAssets=1 squadron=" .. cfg.SquadronNames.HH60G .. " cohortCapability=ALERT5 payloadMissionType=LANDATCOORDINATE")

  local spawnedExactlyOne = false

  local function inspectSpawn()
    local groups = mission:GetOpsGroups() or {}
    local count = #groups
    log("SPAWN_INSPECT opsGroups=" .. tostring(count) .. " status=" .. tostring(mission.status))
    if count == 1 then
      local opsGroup = groups[1]
      local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
      local groupName = group and group:GetName() or "N/A"
      local unitCount = group and #(group:GetUnits() or {}) or 0
      if unitCount == 1 then
        spawnedExactlyOne = true
        log("SPAWN_PASS group=" .. tostring(groupName) .. " units=1")
      else
        cfg.Tests.HH60GControlledSpawnFailed = true
        log("ERROR: recruited HH-60G group has unexpected unit count=" .. tostring(unitCount))
      end
    elseif count > 1 then
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("ERROR: more than one HH-60G OPSGROUP recruited: " .. tostring(count))
    else
      log("WAITING: HH-60G asset has not spawned yet.")
    end
  end

  local function cancelMission()
    log("CLEANUP_REQUEST missionStatus=" .. tostring(mission.status) .. " spawnedExactlyOne=" .. tostring(spawnedExactlyOne))
    if not spawnedExactlyOne then
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("ERROR: refusing to classify cancellation as cleanup success because no HH-60G was spawned.")
    end
    mission:Cancel()
  end

  local function inspectCleanup()
    local groups = mission:GetOpsGroups() or {}
    local alive = 0
    for _, opsGroup in ipairs(groups) do
      local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
      if group and group:IsAlive() then alive = alive + 1 end
    end
    log("CLEANUP_INSPECT missionStatus=" .. tostring(mission.status) .. " aliveGroups=" .. tostring(alive) .. " spawnedExactlyOne=" .. tostring(spawnedExactlyOne))
    if spawnedExactlyOne and alive == 0 then
      cfg.Tests.HH60GControlledSpawnPassed = true
      log("TEST_PASS spawnedExactlyOne=true cleanupComplete=true")
    else
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("TEST_FAIL spawnedExactlyOne=" .. tostring(spawnedExactlyOne) .. " cleanupComplete=" .. tostring(alive == 0))
    end
  end

  if SCHEDULER then
    SCHEDULER:New(nil, inspectSpawn, {}, 45)
    SCHEDULER:New(nil, cancelMission, {}, 120)
    SCHEDULER:New(nil, inspectCleanup, {}, 180)
  else
    timer.scheduleFunction(function() inspectSpawn() return nil end, nil, timer.getTime() + 45)
    timer.scheduleFunction(function() cancelMission() return nil end, nil, timer.getTime() + 120)
    timer.scheduleFunction(function() inspectCleanup() return nil end, nil, timer.getTime() + 180)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, runTest, {}, 24)
else
  timer.scheduleFunction(function() runTest() return nil end, nil, timer.getTime() + 24)
end