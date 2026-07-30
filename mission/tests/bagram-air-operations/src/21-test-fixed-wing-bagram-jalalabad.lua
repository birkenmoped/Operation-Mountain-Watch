-- Operation Mountain Watch - Bagram to Jalalabad fixed-wing movement integration test.
-- Test only: 2x F-15E two-ship, 2x F-16C two-ship, 4x C-130 single-ship.
local TAG = "[OMW][AirOps.BGRAM.Test.FixedWingMove]"
local function log(message) env.info(TAG .. " " .. tostring(message)) end

local READY_INTERVAL = 5
local RECRUIT_START = 30
local RECRUIT_INTERVAL = 5
local RECRUIT_TIMEOUT = 300
local DISPATCH_SPACING = 30
local LIFECYCLE_INTERVAL = 10
local LIFECYCLE_TIMEOUT = 2400
local RETURN_DELAY = 15

local readyScheduler, readyScheduleID
local lastWaitingLog = -1000

local function scheduleOnce(fn, delay)
  if SCHEDULER then return SCHEDULER:New(nil, fn, {}, delay) end
  timer.scheduleFunction(function() fn(); return nil end, nil, timer.getTime() + delay)
end

local function stopScheduler(scheduler, scheduleID)
  if scheduler and scheduleID then scheduler:Stop(scheduleID) end
end

local function callBool(object, methodName)
  local method = object and object[methodName]
  if type(method) ~= "function" then return false end
  local ok, result = pcall(method, object)
  return ok and result == true
end

local function isState(object, state)
  local method = object and object.Is
  if type(method) ~= "function" then return false end
  local ok, result = pcall(method, object, state)
  return ok and result == true
end

local function runTest()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Bagram
  local jbad = OMW and OMW.AirOps and OMW.AirOps.Jalalabad

  if not cfg or not cfg.Tests then
    log("ERROR: Bagram test configuration unavailable.")
    return true
  end
  if cfg.Tests.FixedWingBagramToJalalabad ~= true then
    log("SKIP: fixed-wing movement test disabled.")
    return true
  end
  if cfg.Tests.FixedWingBagramToJalalabadStarted then return true end

  local destination = jbad and (jbad.Airbase or (AIRBASE and AIRBASE:FindByName(jbad.AirbaseName)))
  local ready = cfg.Started == true and cfg.ParkingContractOK == true and cfg.Airwing and
    jbad and jbad.Status == "OPERATIONAL" and jbad.Airwing and destination

  if not ready then
    local now = timer.getTime()
    if now - lastWaitingLog >= 30 then
      lastWaitingLog = now
      log(string.format(
        "WAITING bgramStarted=%s parking=%s bgramAirwing=%s jbadStatus=%s jbadAirwing=%s jbadAirbase=%s",
        tostring(cfg.Started == true), tostring(cfg.ParkingContractOK == true),
        tostring(cfg.Airwing ~= nil), tostring(jbad and jbad.Status or "N/A"),
        tostring(jbad and jbad.Airwing ~= nil or false), tostring(destination ~= nil)
      ))
    end
    return false
  end

  if not AUFTRAG or not AUFTRAG.Type or not AUFTRAG.Type.ALERT5 then
    cfg.Tests.FixedWingBagramToJalalabadFailed = true
    log("TEST_FAIL reason=AUFTRAG-ALERT5-unavailable")
    return true
  end

  local specs = {
    { key="F15E", name="TEST_BGRM_JBAD_F15E_WAVE", type=AUFTRAG.Type.CAS, groups=2, units=2 },
    { key="F16C", name="TEST_BGRM_JBAD_F16C_WAVE", type=AUFTRAG.Type.CAS, groups=2, units=2 },
    { key="C130", name="TEST_BGRM_JBAD_C130_WAVE", type=AUFTRAG.Type.TROOPTRANSPORT, groups=4, units=1 }
  }

  for _, spec in ipairs(specs) do
    if not spec.type or not cfg.Squadrons[spec.key] or not cfg.Payloads[spec.key] then
      cfg.Tests.FixedWingBagramToJalalabadFailed = true
      log("TEST_FAIL reason=missing-squadron-payload-or-type key=" .. spec.key)
      return true
    end
  end

  cfg.Tests.FixedWingBagramToJalalabadStarted = true
  cfg.Tests.FixedWingBagramToJalalabadFailed = false
  cfg.Tests.FixedWingBagramToJalalabadPassed = false

  local EXPECTED_GROUPS, EXPECTED_AIRCRAFT = 8, 12
  local queuedAt = timer.getTime()
  local waveStartedAt
  local failed, completed, waveReady = false, false, false
  local missions, records, baseline = {}, {}, {}
  local recruitScheduler, recruitScheduleID
  local lifecycleScheduler, lifecycleScheduleID
  local recruitPoll, lifecyclePoll = 0, 0

  local function countStock(key)
    local squadron = cfg.Squadrons[key]
    if not squadron or type(squadron.CountAssets) ~= "function" then return nil end
    local ok, count = pcall(squadron.CountAssets, squadron, true)
    return ok and count or nil
  end

  local function stockText()
    return string.format("F15E=%s F16C=%s C130=%s",
      tostring(countStock("F15E")), tostring(countStock("F16C")), tostring(countStock("C130")))
  end

  local function recover()
    for _, mission in pairs(missions) do
      if mission and type(mission.Cancel) == "function" then pcall(mission.Cancel, mission) end
    end
    for _, record in ipairs(records) do
      if record.opsGroup and callBool(record.opsGroup, "IsAlive") and
         type(record.opsGroup.ReturnToLegion) == "function" then
        pcall(record.opsGroup.ReturnToLegion, record.opsGroup, 5)
      end
    end
  end

  local function fail(reason)
    if failed or completed then return end
    failed = true
    cfg.Tests.FixedWingBagramToJalalabadFailed = true
    stopScheduler(recruitScheduler, recruitScheduleID)
    stopScheduler(lifecycleScheduler, lifecycleScheduleID)
    log("TEST_FAIL reason=" .. tostring(reason) .. " stock=[" .. stockText() .. "]")
    recover()
  end

  local expectedInitial = { F15E=6, F16C=6, C130=20 }
  for key, expected in pairs(expectedInitial) do
    baseline[key] = countStock(key)
    if baseline[key] ~= expected then
      fail(string.format("initial-stock-mismatch key=%s expected=%d actual=%s",
        key, expected, tostring(baseline[key])))
      return true
    end
  end
  log("STOCK_BASELINE " .. stockText())

  for _, spec in ipairs(specs) do
    local ok, result = pcall(function()
      local mission = AUFTRAG:NewALERT5(spec.type)
      mission:SetName(spec.name)
      mission:SetRequiredAssets(spec.groups, spec.groups)
      mission:AssignSquadrons({ cfg.Squadrons[spec.key] })
      mission:AddRequiredPayload(cfg.Payloads[spec.key])
      mission:SetRepeat(0)
      cfg.Airwing:AddMission(mission)
      return mission
    end)
    if not ok or not result then
      fail("mission-construction-failed key=" .. spec.key .. " detail=" .. tostring(result))
      return true
    end
    missions[spec.key] = result
    log(string.format(
      "MISSION_QUEUED key=%s requiredGroups=%d unitsPerGroup=%d squadron=%s payloadBound=true alertMissionType=%s",
      spec.key, spec.groups, spec.units, tostring(cfg.SquadronNames[spec.key]), tostring(spec.type)))
  end

  local function dispatch(record, delay)
    scheduleOnce(function()
      if failed or completed then return end
      local group = record.opsGroup
      if not group or not callBool(group, "IsAlive") then
        fail("dispatch-group-not-alive group=" .. tostring(record.name)); return
      end
      if type(group.LandAtAirbase) ~= "function" or type(group.StartUncontrolled) ~= "function" then
        fail("native-flight-method-unavailable group=" .. tostring(record.name)); return
      end
      local ok, err = pcall(function()
        if type(group.SetDestinationbase) == "function" then group:SetDestinationbase(destination) end
        group:LandAtAirbase(destination)
        group:StartUncontrolled()
      end)
      if not ok then fail("dispatch-failed group=" .. tostring(record.name) .. " detail=" .. tostring(err)); return end
      record.dispatched = true
      log(string.format("DISPATCH key=%s group=%s assetId=%s destination=%s spacingDelay=%d",
        record.key, tostring(record.name), tostring(record.assetId), destination:GetName(), delay))
    end, delay)
  end

  local function inspectLifecycle()
    if failed or completed then return end
    lifecyclePoll = lifecyclePoll + 1
    local elapsed = timer.getTime() - waveStartedAt
    local dispatched, airborne, arrived, returned, alive = 0, 0, 0, 0, 0

    for _, record in ipairs(records) do
      local group = record.opsGroup
      local isAlive = callBool(group, "IsAlive")
      local isAirborne = callBool(group, "IsAirborne") or isState(group, "Airborne") or isState(group, "Cruising")
      local isParked = record.wasAirborne and
        (callBool(group, "IsParking") or isState(group, "Parking") or isState(group, "Arrived"))

      if record.dispatched then dispatched = dispatched + 1 end
      if isAlive then alive = alive + 1 end
      if isAirborne and not record.wasAirborne then
        record.wasAirborne = true
        log(string.format("AIRBORNE_PASS key=%s group=%s assetId=%s",
          record.key, tostring(record.name), tostring(record.assetId)))
      end
      if record.wasAirborne then airborne = airborne + 1 end

      if record.wasAirborne and not record.arrived and isParked then
        record.arrived = true
        log(string.format("ARRIVAL_PASS key=%s group=%s destination=%s parkingOrArrived=true",
          record.key, tostring(record.name), destination:GetName()))
        if type(group.ReturnToLegion) ~= "function" then
          fail("ReturnToLegion-unavailable group=" .. tostring(record.name)); return
        end
        local ok, err = pcall(group.ReturnToLegion, group, RETURN_DELAY)
        if not ok then fail("ReturnToLegion-failed group=" .. tostring(record.name) .. " detail=" .. tostring(err)); return end
        record.returnRequested = true
        log(string.format("RETURN_REQUEST key=%s group=%s delay=%d",
          record.key, tostring(record.name), RETURN_DELAY))
      end
      if record.arrived then arrived = arrived + 1 end

      if record.returnRequested and not isAlive and not record.returned then
        record.returned = true
        log(string.format("RETURN_PASS key=%s group=%s assetId=%s",
          record.key, tostring(record.name), tostring(record.assetId)))
      end
      if record.returned then returned = returned + 1 end

      if record.dispatched and not isAlive and not record.returnRequested then
        fail("asset-lost-before-arrival group=" .. tostring(record.name)); return
      end
    end

    local missionGroups = 0
    for _, mission in pairs(missions) do missionGroups = missionGroups + #(mission:GetOpsGroups() or {}) end
    log(string.format(
      "LIFECYCLE_INSPECT poll=%d elapsed=%.1f dispatched=%d airborne=%d arrived=%d returned=%d alive=%d missionOpsGroups=%d stock=[%s]",
      lifecyclePoll, elapsed, dispatched, airborne, arrived, returned, alive, missionGroups, stockText()))

    if returned == EXPECTED_GROUPS then
      local stockRestored = countStock("F15E") == baseline.F15E and
        countStock("F16C") == baseline.F16C and countStock("C130") == baseline.C130
      if stockRestored and missionGroups == 0 then
        completed = true
        stopScheduler(lifecycleScheduler, lifecycleScheduleID)
        cfg.Tests.FixedWingBagramToJalalabadPassed = true
        log(string.format(
          "TEST_PASS groups=%d aircraft=%d allAirborne=true allArrived=true allReturned=true stockRestored=true destination=%s",
          EXPECTED_GROUPS, EXPECTED_AIRCRAFT, destination:GetName()))
        return
      end
    end

    if elapsed >= LIFECYCLE_TIMEOUT then
      fail(string.format("lifecycle-timeout dispatched=%d airborne=%d arrived=%d returned=%d",
        dispatched, airborne, arrived, returned))
    end
  end

  local function startLifecycle()
    waveStartedAt = timer.getTime()
    local index = 0
    for _, spec in ipairs(specs) do
      for _, opsGroup in ipairs(missions[spec.key]:GetOpsGroups() or {}) do
        index = index + 1
        local opsName = opsGroup and opsGroup.GetName and opsGroup:GetName() or "N/A"
        local wrapper = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup()
        local record = {
          key=spec.key,
          opsGroup=opsGroup,
          name=wrapper and wrapper.GetName and wrapper:GetName() or opsName,
          assetId=string.match(tostring(opsName), "AID%-?%d+") or "N/A"
        }
        records[#records + 1] = record
        dispatch(record, (index - 1) * DISPATCH_SPACING)
      end
    end
    if #records ~= EXPECTED_GROUPS then
      fail("record-count-mismatch expected=8 actual=" .. tostring(#records)); return
    end
    if SCHEDULER then
      lifecycleScheduler, lifecycleScheduleID = SCHEDULER:New(nil, inspectLifecycle, {}, LIFECYCLE_INTERVAL, LIFECYCLE_INTERVAL)
    else
      timer.scheduleFunction(function()
        inspectLifecycle()
        if failed or completed then return nil end
        return timer.getTime() + LIFECYCLE_INTERVAL
      end, nil, timer.getTime() + LIFECYCLE_INTERVAL)
    end
    log(string.format("WAVE_DISPATCH_SCHEDULED groups=8 aircraft=12 spacing=%d destination=%s",
      DISPATCH_SPACING, destination:GetName()))
  end

  local function inspectRecruitment()
    if failed or completed or waveReady then return end
    recruitPoll = recruitPoll + 1
    local elapsed = timer.getTime() - queuedAt
    local totalGroups, totalAircraft, allReady = 0, 0, true
    local details = {}

    for _, spec in ipairs(specs) do
      local groups = missions[spec.key]:GetOpsGroups() or {}
      totalGroups = totalGroups + #groups
      if #groups ~= spec.groups then allReady = false end
      if #groups > spec.groups then fail("too-many-opsgroups key=" .. spec.key); return end
      for _, opsGroup in ipairs(groups) do
        local wrapper = opsGroup and opsGroup.GetGroup and opsGroup:GetGroup()
        local unitCount = wrapper and wrapper.GetUnits and #(wrapper:GetUnits() or {}) or 0
        if unitCount ~= spec.units then
          fail(string.format("unit-count-mismatch key=%s expected=%d actual=%d", spec.key, spec.units, unitCount)); return
        end
        totalAircraft = totalAircraft + unitCount
      end
      details[#details + 1] = string.format("%s=%d/%d status=%s",
        spec.key, #groups, spec.groups, tostring(missions[spec.key].status))
    end

    log(string.format(
      "RECRUITMENT_INSPECT poll=%d elapsed=%.1f groups=%d/8 aircraft=%d/12 details=[%s] stock=[%s]",
      recruitPoll, elapsed, totalGroups, totalAircraft, table.concat(details, "; "), stockText()))

    if allReady and totalGroups == EXPECTED_GROUPS and totalAircraft == EXPECTED_AIRCRAFT then
      local reduced = countStock("F15E") == baseline.F15E - 2 and
        countStock("F16C") == baseline.F16C - 2 and countStock("C130") == baseline.C130 - 4
      if not reduced then fail("stock-not-reduced-as-expected actual=" .. stockText()); return end
      waveReady = true
      stopScheduler(recruitScheduler, recruitScheduleID)
      log("WAVE_SPAWN_PASS groups=8 aircraft=12 stockReduced=true")
      startLifecycle()
      return
    end

    if elapsed >= RECRUIT_TIMEOUT then
      fail(string.format("recruitment-timeout groups=%d/8 aircraft=%d/12", totalGroups, totalAircraft))
    end
  end

  if SCHEDULER then
    recruitScheduler, recruitScheduleID = SCHEDULER:New(nil, inspectRecruitment, {}, RECRUIT_START, RECRUIT_INTERVAL)
  else
    timer.scheduleFunction(function()
      inspectRecruitment()
      if failed or completed or waveReady then return nil end
      return timer.getTime() + RECRUIT_INTERVAL
    end, nil, timer.getTime() + RECRUIT_START)
  end

  log(string.format("TEST_STARTED origin=%s destination=%s groups=8 aircraft=12 commanderCreated=false",
    cfg.Airbase and cfg.Airbase:GetName() or cfg.AirbaseName, destination:GetName()))
  return true
end

local function attemptStart()
  if runTest() then stopScheduler(readyScheduler, readyScheduleID) end
end

if SCHEDULER then
  readyScheduler, readyScheduleID = SCHEDULER:New(nil, attemptStart, {}, 28, READY_INTERVAL)
else
  timer.scheduleFunction(function()
    if runTest() then return nil end
    return timer.getTime() + READY_INTERVAL
  end, nil, timer.getTime() + 28)
end
