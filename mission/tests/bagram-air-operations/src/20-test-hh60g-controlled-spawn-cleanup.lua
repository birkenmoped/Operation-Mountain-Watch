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
  if not AUFTRAG.Type or not AUFTRAG.Type.ALERT5 or not AUFTRAG.Type.TROOPTRANSPORT then
    log("ERROR: required AUFTRAG mission types ALERT5/TROOPTRANSPORT unavailable.")
    return
  end
  if not cfg.Payloads or not cfg.Payloads.HH60G then
    log("ERROR: HH-60G payload registration unavailable.")
    return
  end

  cfg.Tests.HH60GControlledSpawnStarted = true
  cfg.Tests.HH60GControlledSpawnPassed = nil
  cfg.Tests.HH60GControlledSpawnFailed = nil

  local ok, missionOrError = pcall(function()
    -- ALERT5 spawns an uncontrolled aircraft prepared for the supplied operational
    -- mission type. The already registered HH-60G payload is bound explicitly,
    -- matching the accepted Jalalabad AUFTRAG construction pattern.
    local mission = AUFTRAG:NewALERT5(AUFTRAG.Type.TROOPTRANSPORT)
    mission:SetName("TEST_BGRM_HH60G_CONTROLLED_SPAWN")
    mission:SetRequiredAssets(1, 1)
    mission:AssignSquadrons({ cfg.Squadrons.HH60G })
    mission:AddRequiredPayload(cfg.Payloads.HH60G)
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
  log("MISSION_QUEUED name=TEST_BGRM_HH60G_CONTROLLED_SPAWN requiredAssets=1 squadron=" .. cfg.SquadronNames.HH60G .. " cohortCapability=ALERT5 payloadMissionType=TROOPTRANSPORT requiredPayloadBound=true")

  local SPAWN_POLL_START_SECONDS = 30
  local SPAWN_POLL_INTERVAL_SECONDS = 5
  local SPAWN_TIMEOUT_SECONDS = 150
  local CANCEL_DELAY_AFTER_SPAWN_SECONDS = 10
  local CLEANUP_INSPECT_DELAY_SECONDS = 45

  local queuedAt = timer.getTime()
  local pollCount = 0
  local spawnedExactlyOne = false
  local spawnObservationComplete = false
  local cancellationRequested = false
  local cleanupInspectionScheduled = false
  local spawnPollScheduler = nil
  local spawnPollScheduleID = nil

  local function scheduleOnce(fn, delay)
    if SCHEDULER then
      return SCHEDULER:New(nil, fn, {}, delay)
    end
    timer.scheduleFunction(function()
      fn()
      return nil
    end, nil, timer.getTime() + delay)
    return nil, nil
  end

  local function stopSpawnPolling()
    if spawnPollScheduler and spawnPollScheduleID then
      spawnPollScheduler:Stop(spawnPollScheduleID)
    end
  end

  local function inspectOpsGroups(phase)
    local groups = mission:GetOpsGroups() or {}
    local count = #groups
    local alive = 0
    local details = {}

    for index, opsGroup in ipairs(groups) do
      local opsGroupName = opsGroup and opsGroup.GetName and opsGroup:GetName() or "N/A"
      local assetId = string.match(tostring(opsGroupName), "AID%-?%d+") or "N/A"
      local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
      local groupName = group and group.GetName and group:GetName() or "N/A"
      local units = group and group.GetUnits and group:GetUnits() or {}
      local unitCount = #units
      local isAlive = opsGroup and opsGroup.IsAlive and opsGroup:IsAlive() or false
      if isAlive then alive = alive + 1 end
      details[#details + 1] = string.format(
        "idx=%d opsGroup=%s assetId=%s group=%s units=%d alive=%s",
        index,
        tostring(opsGroupName),
        tostring(assetId),
        tostring(groupName),
        unitCount,
        tostring(isAlive)
      )
    end

    log(string.format(
      "%s opsGroups=%d aliveGroups=%d status=%s details=[%s]",
      tostring(phase),
      count,
      alive,
      tostring(mission.status),
      table.concat(details, "; ")
    ))

    return groups, count, alive
  end

  local function inspectCleanup()
    local _, _, alive = inspectOpsGroups("CLEANUP_INSPECT")
    log("CLEANUP_RESULT missionStatus=" .. tostring(mission.status) .. " aliveGroups=" .. tostring(alive) .. " spawnedExactlyOne=" .. tostring(spawnedExactlyOne))
    if spawnedExactlyOne and alive == 0 and cfg.Tests.HH60GControlledSpawnFailed ~= true then
      cfg.Tests.HH60GControlledSpawnPassed = true
      log("TEST_PASS spawnedExactlyOne=true cleanupComplete=true")
    else
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("TEST_FAIL spawnedExactlyOne=" .. tostring(spawnedExactlyOne) .. " cleanupComplete=" .. tostring(alive == 0))
    end
  end

  local function scheduleCleanupInspection()
    if cleanupInspectionScheduled then return end
    cleanupInspectionScheduled = true
    scheduleOnce(inspectCleanup, CLEANUP_INSPECT_DELAY_SECONDS)
  end

  local function cancelMission(reason)
    if cancellationRequested then return end

    -- Re-inspect immediately before cancellation so a spawn completing between
    -- polling ticks cannot be missed and misclassified as a cleanup-only result.
    local groups, count = inspectOpsGroups("PRE_CANCEL_INSPECT")
    if not spawnedExactlyOne and count == 1 then
      local opsGroup = groups[1]
      local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
      local unitCount = group and group.GetUnits and #(group:GetUnits() or {}) or 0
      if unitCount == 1 then
        spawnedExactlyOne = true
        log("SPAWN_PASS source=pre-cancel units=1")
      end
    end

    cancellationRequested = true
    log("CLEANUP_REQUEST reason=" .. tostring(reason) .. " missionStatus=" .. tostring(mission.status) .. " spawnedExactlyOne=" .. tostring(spawnedExactlyOne))
    if not spawnedExactlyOne then
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("ERROR: refusing to classify cancellation as cleanup success because no HH-60G spawn was confirmed.")
    end

    local cancelOK, cancelError = pcall(function() mission:Cancel() end)
    if not cancelOK then
      cfg.Tests.HH60GControlledSpawnFailed = true
      log("ERROR: mission cancellation failed: " .. tostring(cancelError))
    end
    scheduleCleanupInspection()
  end

  local function confirmSpawn(groups, source)
    if #groups ~= 1 then return false end

    local opsGroup = groups[1]
    local opsGroupName = opsGroup and opsGroup.GetName and opsGroup:GetName() or "N/A"
    local assetId = string.match(tostring(opsGroupName), "AID%-?%d+") or "N/A"
    local group = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup() or nil
    local groupName = group and group.GetName and group:GetName() or "N/A"
    local unitCount = group and group.GetUnits and #(group:GetUnits() or {}) or 0
    local isAlive = opsGroup and opsGroup.IsAlive and opsGroup:IsAlive() or false

    if unitCount ~= 1 then
      cfg.Tests.HH60GControlledSpawnFailed = true
      spawnObservationComplete = true
      stopSpawnPolling()
      log("ERROR: recruited HH-60G group has unexpected unit count=" .. tostring(unitCount))
      cancelMission("invalid-unit-count")
      return false
    end

    spawnedExactlyOne = true
    spawnObservationComplete = true
    stopSpawnPolling()
    log("SPAWN_PASS source=" .. tostring(source) .. " opsGroup=" .. tostring(opsGroupName) .. " assetId=" .. tostring(assetId) .. " group=" .. tostring(groupName) .. " units=1 alive=" .. tostring(isAlive))
    scheduleOnce(function() cancelMission("spawn-confirmed") end, CANCEL_DELAY_AFTER_SPAWN_SECONDS)
    return true
  end

  local function inspectSpawn()
    if spawnObservationComplete then return end

    pollCount = pollCount + 1
    local elapsed = timer.getTime() - queuedAt
    local groups, count = inspectOpsGroups("SPAWN_INSPECT poll=" .. tostring(pollCount) .. " elapsed=" .. string.format("%.1f", elapsed))

    if count == 1 then
      confirmSpawn(groups, "poll")
      return
    end

    if count > 1 then
      cfg.Tests.HH60GControlledSpawnFailed = true
      spawnObservationComplete = true
      stopSpawnPolling()
      log("ERROR: more than one HH-60G OPSGROUP recruited: " .. tostring(count))
      cancelMission("multiple-opsgroups")
      return
    end

    if elapsed >= SPAWN_TIMEOUT_SECONDS then
      cfg.Tests.HH60GControlledSpawnFailed = true
      spawnObservationComplete = true
      stopSpawnPolling()
      log("SPAWN_TIMEOUT elapsed=" .. string.format("%.1f", elapsed) .. " opsGroups=0 status=" .. tostring(mission.status))
      cancelMission("spawn-timeout")
      return
    end

    log("WAITING: HH-60G asset has not spawned yet.")
  end

  if SCHEDULER then
    spawnPollScheduler, spawnPollScheduleID = SCHEDULER:New(
      nil,
      inspectSpawn,
      {},
      SPAWN_POLL_START_SECONDS,
      SPAWN_POLL_INTERVAL_SECONDS
    )
  else
    timer.scheduleFunction(function()
      inspectSpawn()
      if spawnObservationComplete then return nil end
      return timer.getTime() + SPAWN_POLL_INTERVAL_SECONDS
    end, nil, timer.getTime() + SPAWN_POLL_START_SECONDS)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, runTest, {}, 24)
else
  timer.scheduleFunction(function() runTest() return nil end, nil, timer.getTime() + 24)
end
