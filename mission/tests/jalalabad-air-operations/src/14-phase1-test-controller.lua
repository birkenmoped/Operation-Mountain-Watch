-- Operation Mountain Watch - Jalalabad AIRWING Phase 1 test controller
local TAG = "[OMW][AirOps.JBAD.PH1]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Observer or not ph1.Factory then
  log("ERROR: Phase 1 dependencies are unavailable.")
else
  local controller = ph1.Controller or {}
  ph1.Controller = controller

  local expectedAssetGroups = { OH58D = 12, AH64D = 4, UH60 = 8, CH47 = 8 }

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
  end

  local function queueCount()
    local count = 0
    for _ in pairs((cfg.Airwing and cfg.Airwing.missionqueue) or {}) do count = count + 1 end
    return count
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function coalitionMessage(text, seconds)
    if trigger and trigger.action and trigger.action.outTextForCoalition then
      trigger.action.outTextForCoalition(coalition.side.BLUE, "OMW Jalalabad Phase 1\n" .. tostring(text), seconds or 15)
    end
  end

  local function inventoryReady(snapshots)
    for key, expected in pairs(expectedAssetGroups) do
      local item = snapshots and snapshots[key]
      if not item or item.total ~= expected or item.busy ~= 0 or item.available ~= expected then
        return false, string.format("%s total=%s available=%s busy=%s expected=%d", key, item and item.total or "nil", item and item.available or "nil", item and item.busy or "nil", expected)
      end
    end
    return true
  end

  local function newCounters()
    return {
      missionsCreated = 0,
      missionsQueued = 0,
      assetsReserved = 0,
      groupsSpawned = 0,
      aircraftSpawned = 0,
      engineStarts = 0,
      takeoffs = 0,
      missionsExecuting = 0,
      missionsSucceeded = 0,
      missionsFailed = 0,
      missionsCancelled = 0,
      landings = 0,
      engineShutdowns = 0,
      assetsReturned = 0,
      parkingViolations = 0,
      unexpectedSpawns = 0,
      losses = 0,
      timeouts = 0
    }
  end

  ph1.Counters = ph1.Counters or newCounters()

  function controller:InitializeWhenReady()
    if ph1.State ~= "WAITING_FOR_BASELINE" and ph1.State ~= "BLOCKED" then return true end
    if cfg.Status ~= "OPERATIONAL" or not cfg.Airwing then
      ph1.State = "WAITING_FOR_BASELINE"
      return false
    end
    cfg.BaselineReady = true
    if cfg.ParkingReservationsOK ~= true then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "parking-reservation-regression"
      return false
    end
    local objectsReady = ph1.Factory:ValidateMissionEditorObjects()
    if not objectsReady then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "mission-editor-objects-missing"
      return false
    end
    if not ph1.ClientParkingResolved and not ph1.Observer:ResolveClientParkingIDs() then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "client-parking-unresolved"
      return false
    end

    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local ready, reason = inventoryReady(snapshots)
    if not ready then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = reason
      return false
    end
    if queueCount() ~= 0 then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "pre-existing-airwing-mission-queue"
      return false
    end

    ph1.State = "READY"
    ph1.BlockReason = nil
    ph1.Observer:LogSnapshot("PHASE1_READY", snapshots)
    log("READY baselineOperational=true parkingPASS=true clientParkingResolved=true missionQueue=0 inventory=12/4/8/8")
    coalitionMessage("Testpaket ist READY.", 10)
    return true
  end

  function controller:ResetRuntime(definition)
    ph1.Runtime = {
      TestId = definition.Id,
      StartedAt = timer.getTime(),
      Deadline = timer.getTime() + definition.Timeout,
      MissionState = "CREATED",
      MissionStateSeen = {},
      ExpectedGroupNames = {},
      ProvisionalGroupNames = {},
      BornUnits = {},
      BornGroupNames = {},
      EngineUnits = {},
      TakeoffUnits = {},
      LandedUnits = {},
      ShutdownUnits = {},
      BirthCount = 0,
      EngineStartCount = 0,
      TakeoffCount = 0,
      LandingCount = 0,
      EngineShutdownCount = 0,
      MaxDistanceFromBase = 0,
      RTBObserved = false,
      ObjectiveSatisfied = false,
      MissionTerminal = false,
      ReleaseStablePolls = 0,
      AbortScheduled = false,
      AbortRequested = false,
      HardFailure = nil,
      PendingFailure = nil,
      MaxExpectedSquadronBusy = 0
    }
  end

  function controller:StartTest(testId)
    if ph1.ActiveMission then
      coalitionMessage("Abgelehnt: Es ist bereits ein Test aktiv: " .. tostring(ph1.ActiveTestId), 12)
      return false
    end
    if not self:InitializeWhenReady() then
      coalitionMessage("Nicht bereit: " .. tostring(ph1.BlockReason or ph1.State), 15)
      return false
    end

    local definition = ph1.Tests[testId]
    if not definition then
      coalitionMessage("Unbekannter Test: " .. tostring(testId), 10)
      return false
    end
    if queueCount() ~= 0 then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "airwing-mission-queue-not-empty"
      coalitionMessage("Abgelehnt: AIRWING-Auftragsschlange ist nicht leer.", 15)
      return false
    end

    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local ready, reason = inventoryReady(snapshots)
    if not ready then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "inventory-not-clean: " .. tostring(reason)
      coalitionMessage("Abgelehnt: Bestand nicht vollständig frei.", 15)
      ph1.Observer:LogSnapshot("START_BLOCKED", snapshots)
      return false
    end

    ph1.ActiveTestId = testId
    ph1.ActiveDefinition = definition
    self:ResetRuntime(definition)
    ph1.BaselineInventory = snapshots
    ph1.Observer:LogSnapshot("BEFORE_" .. testId, snapshots)

    local mission, createError = ph1.Factory:Create(testId)
    if not mission then
      ph1.Runtime.PendingFailure = "mission-create-failed: " .. tostring(createError)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    ph1.ActiveMission = mission
    increment("missionsCreated")
    ph1.State = "QUEUING"

    local ok, result = pcall(function() return cfg.Airwing:AddMission(mission) end)
    if not ok then
      ph1.Runtime.PendingFailure = "airwing-add-mission-failed: " .. tostring(result)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    increment("missionsQueued")
    ph1.State = "ACTIVE"
    log(string.format("START testId=%s label=%s mission=%s squadron=%s payload=%s expectedGroups=%d expectedAircraft=%d queue=%d timeout=%ds",
      testId, definition.Label, mission:GetName(), definition.SquadronKey, definition.PayloadKey,
      definition.ExpectedGroups, definition.ExpectedAircraft, queueCount(), definition.Timeout))
    coalitionMessage("Gestartet: " .. definition.Label, 12)
    return true
  end

  function controller:OnMissionState(state, mission, from, event, to)
    if mission ~= ph1.ActiveMission or not ph1.Runtime then return end
    ph1.Runtime.MissionState = state
    if not ph1.Runtime.MissionStateSeen[state] then
      ph1.Runtime.MissionStateSeen[state] = true
      log(string.format("EVENT testId=%s stage=MISSION_%s from=%s to=%s", tostring(ph1.ActiveTestId), state, tostring(from), tostring(to)))
      if state == "SCHEDULED" then
        increment("assetsReserved")
        ph1.Observer:RefreshMissionGroups()
      elseif state == "EXECUTING" then
        increment("missionsExecuting")
      elseif state == "SUCCESS" then
        increment("missionsSucceeded")
        ph1.Runtime.MissionTerminal = true
      elseif state == "FAILED" then
        increment("missionsFailed")
        ph1.Runtime.MissionTerminal = true
        ph1.Runtime.PendingFailure = ph1.Runtime.PendingFailure or "auftrag-failed"
      elseif state == "CANCELLED" then
        increment("missionsCancelled")
        ph1.Runtime.MissionTerminal = true
      elseif state == "DONE" then
        ph1.Runtime.MissionDone = true
      end
    end
  end

  function controller:OnExpectedBirth(groupName, unitName, typeName)
    local definition = ph1.ActiveDefinition
    if not definition or not ph1.Runtime then return end
    if typeName ~= definition.ExpectedType then
      ph1.Runtime.HardFailure = "wrong-aircraft-type-" .. tostring(typeName)
      log("ERROR WRONG_TYPE testId=" .. tostring(ph1.ActiveTestId) .. " expected=" .. tostring(definition.ExpectedType) .. " actual=" .. tostring(typeName))
    end
    if countKeys(ph1.Runtime.BornUnits) == 1 then increment("groupsSpawned") end

    if definition.AbortOnBirth and not ph1.Runtime.AbortScheduled then
      ph1.Runtime.AbortScheduled = true
      local delay = ph1.Limits.AbortDelayAfterBirthSeconds
      log("ABORT_SCHEDULED testId=" .. tostring(ph1.ActiveTestId) .. " delay=" .. tostring(delay) .. "s")
      SCHEDULER:New(nil, function()
        if ph1.ActiveTestId == definition.Id and ph1.ActiveMission then
          controller:AbortActive("defined-abort-after-birth")
        end
      end, {}, delay)
    end
  end

  function controller:AbortActive(reason)
    if not ph1.ActiveMission or not ph1.Runtime then return false end
    if ph1.Runtime.AbortRequested then return true end
    ph1.Runtime.AbortRequested = true
    ph1.Runtime.AbortReason = reason or "manual-abort"
    log("ABORT_REQUEST testId=" .. tostring(ph1.ActiveTestId) .. " reason=" .. tostring(ph1.Runtime.AbortReason))
    local ok, err = pcall(function() ph1.ActiveMission:Cancel() end)
    if not ok then
      ph1.Runtime.PendingFailure = "cancel-call-failed: " .. tostring(err)
      return false
    end
    return true
  end

  function controller:RequestFailure(reason)
    if not ph1.Runtime then return end
    if not ph1.Runtime.PendingFailure then
      ph1.Runtime.PendingFailure = reason
      log("FAIL_PENDING testId=" .. tostring(ph1.ActiveTestId) .. " reason=" .. tostring(reason))
    end
    if ph1.ActiveMission and not ph1.Runtime.MissionTerminal then
      self:AbortActive("failure-cleanup")
    end
  end

  function controller:CheckReservationBounds(current)
    local definition = ph1.ActiveDefinition
    local baseline = ph1.BaselineInventory
    if not definition or not current or not baseline then return true end
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      local busyDelta = (current[key].busy or 0) - (baseline[key].busy or 0)
      local allowed = key == definition.SquadronKey and definition.ExpectedGroups or 0
      if key == definition.SquadronKey and ph1.Runtime then
        ph1.Runtime.MaxExpectedSquadronBusy = math.max(ph1.Runtime.MaxExpectedSquadronBusy or 0, busyDelta)
      end
      if busyDelta > allowed then
        return false, string.format("reservation-overrun-%s delta=%d allowed=%d", key, busyDelta, allowed)
      end
      if key ~= definition.SquadronKey and busyDelta ~= 0 then
        return false, string.format("wrong-squadron-reserved-%s delta=%d", key, busyDelta)
      end
    end
    return true
  end

  function controller:LifecycleSatisfied()
    local definition = ph1.ActiveDefinition
    local runtime = ph1.Runtime
    if not definition or not runtime then return false, "runtime-missing" end

    if runtime.HardFailure then return false, runtime.HardFailure end
    for _, state in ipairs({ "QUEUED", "REQUESTED", "SCHEDULED" }) do
      if not runtime.MissionStateSeen[state] then return false, "mission-state-missing-" .. string.lower(state) end
    end
    if (runtime.MaxExpectedSquadronBusy or 0) ~= definition.ExpectedGroups then
      return false, "asset-reservation-not-confirmed"
    end
    if (runtime.BirthCount or 0) ~= definition.ExpectedAircraft then return false, "spawn-count-mismatch" end
    if countKeys(runtime.BornGroupNames) ~= definition.ExpectedGroups then return false, "spawn-group-count-mismatch" end
    if definition.RequireEngineStart and (runtime.EngineStartCount or 0) ~= definition.ExpectedAircraft then return false, "engine-start-count-mismatch" end
    if definition.RequireTakeoff and (runtime.TakeoffCount or 0) ~= definition.ExpectedAircraft then return false, "takeoff-count-mismatch" end
    if definition.RequireExecution and not runtime.MissionStateSeen.STARTED then return false, "mission-not-started" end
    if definition.RequireExecution and not runtime.MissionStateSeen.EXECUTING then return false, "mission-not-executing" end
    if definition.RequireObjective and not runtime.ObjectiveSatisfied then return false, "objective-not-confirmed" end
    if definition.RequireRTB and not runtime.RTBObserved then return false, "rtb-not-observed" end
    if definition.RequireLanding and (runtime.LandingCount or 0) ~= definition.ExpectedAircraft then return false, "landing-count-mismatch" end

    if definition.ExpectedTerminalState == "CANCELLED" then
      if runtime.MissionState ~= "CANCELLED" then return false, "mission-not-cancelled" end
      if (runtime.TakeoffCount or 0) > 0 then return false, "abort-test-aircraft-took-off" end
    else
      if runtime.MissionState ~= "SUCCESS" then return false, "mission-not-success" end
    end
    return true
  end

  function controller:FinalizeTest(classification, reason, released)
    local testId = ph1.ActiveTestId or "UNKNOWN"
    local definition = ph1.ActiveDefinition or {}
    local runtime = ph1.Runtime or {}
    local result = {
      Classification = classification,
      Reason = reason,
      Released = released == true,
      MissionState = runtime.MissionState,
      Births = runtime.BirthCount or 0,
      EngineStarts = runtime.EngineStartCount or 0,
      Takeoffs = runtime.TakeoffCount or 0,
      Landings = runtime.LandingCount or 0,
      Objective = runtime.ObjectiveSatisfied == true,
      RTB = runtime.RTBObserved == true,
      Duration = timer.getTime() - (runtime.StartedAt or timer.getTime())
    }
    ph1.Results[testId] = result
    ph1.History[#ph1.History + 1] = { TestId = testId, Result = result }
    ph1.LastRuntime = runtime

    log(string.format("RESULT testId=%s classification=%s reason=%s missionState=%s released=%s births=%d engineStarts=%d takeoffs=%d objective=%s rtb=%s landings=%d duration=%.1fs",
      testId, classification, tostring(reason), tostring(result.MissionState), tostring(result.Released), result.Births,
      result.EngineStarts, result.Takeoffs, tostring(result.Objective), tostring(result.RTB), result.Landings, result.Duration))
    coalitionMessage((definition.Label or testId) .. ": " .. classification .. "\n" .. tostring(reason), 18)

    local continueSequence = ph1.AutoSequence and classification == "PASS"
    ph1.ActiveMission = nil
    ph1.ActiveTestId = nil
    ph1.ActiveDefinition = nil
    ph1.Runtime = nil
    ph1.BaselineInventory = nil
    ph1.State = "READY"

    if continueSequence then
      SCHEDULER:New(nil, function() controller:StartNextSequenceTest() end, {}, ph1.Limits.NextTestDelaySeconds)
    elseif ph1.AutoSequence and classification ~= "PASS" then
      ph1.AutoSequence = false
      ph1.Classification = classification
      log("SEQUENCE STOP classification=" .. classification .. " failedTest=" .. testId)
    end
  end

  function controller:PollActive()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition or not ph1.ActiveMission then return end

    ph1.Observer:RefreshMissionGroups()
    ph1.Observer:UpdateDistanceTracking()

    if runtime.HardFailure then self:RequestFailure(runtime.HardFailure) end
    if timer.getTime() >= runtime.Deadline then
      increment("timeouts")
      self:RequestFailure("test-timeout")
    end

    if runtime.ObjectiveCheck and not runtime.ObjectiveSatisfied then
      local ok, satisfied = pcall(runtime.ObjectiveCheck)
      if ok and satisfied then
        runtime.ObjectiveSatisfied = true
        log("EVENT testId=" .. tostring(ph1.ActiveTestId) .. " stage=OBJECTIVE_CONFIRMED")
      end
    end

    local current = ph1.Observer:SnapshotAllSquadrons()
    local reservationOk, reservationReason = self:CheckReservationBounds(current)
    if not reservationOk then self:RequestFailure(reservationReason) end

    local restored, restoredData = ph1.Observer:IsInventoryRestored(ph1.BaselineInventory)
    if restored and queueCount() == 0 then
      runtime.ReleaseStablePolls = runtime.ReleaseStablePolls + 1
    else
      runtime.ReleaseStablePolls = 0
    end

    local released = runtime.ReleaseStablePolls >= ph1.Limits.ReleaseStablePolls
    if released and not runtime.ReleaseLogged then
      runtime.ReleaseLogged = true
      increment("assetsReturned")
      ph1.Observer:LogSnapshot("AFTER_" .. definition.Id, restoredData)
      log("EVENT testId=" .. tostring(ph1.ActiveTestId) .. " stage=ASSET_RELEASED stablePolls=" .. tostring(runtime.ReleaseStablePolls) .. " queue=0")
    end

    if runtime.PendingFailure then
      if released then
        self:FinalizeTest("FAIL", runtime.PendingFailure, true)
      elseif timer.getTime() >= runtime.Deadline + 300 then
        self:FinalizeTest("FAIL", runtime.PendingFailure .. "; assets-not-released", false)
      end
      return
    end

    local lifecycleOk, lifecycleReason = self:LifecycleSatisfied()
    if lifecycleOk and released then
      self:FinalizeTest("PASS", "complete-lifecycle-and-inventory-release", true)
    elseif runtime.MissionTerminal and runtime.MissionState == "FAILED" then
      self:RequestFailure("auftrag-failed")
    elseif runtime.MissionTerminal and definition.ExpectedTerminalState ~= "CANCELLED" and runtime.MissionState == "CANCELLED" then
      self:RequestFailure("unexpected-cancellation")
    elseif runtime.MissionState == "SUCCESS" and not lifecycleOk then
      runtime.LastPendingCriterion = lifecycleReason
    end
  end

  function controller:StartSequence()
    if ph1.ActiveMission then
      coalitionMessage("Sequenz kann nicht starten: Test aktiv.", 10)
      return false
    end
    ph1.Results = {}
    ph1.Counters = newCounters()
    ph1.SequenceIndex = 0
    ph1.AutoSequence = true
    ph1.Classification = "RUNNING"
    log("SEQUENCE START tests=5")
    return self:StartNextSequenceTest()
  end

  function controller:StartNextSequenceTest()
    if not ph1.AutoSequence then return false end
    ph1.SequenceIndex = ph1.SequenceIndex + 1
    local testId = ph1.Sequence[ph1.SequenceIndex]
    if not testId then
      ph1.AutoSequence = false
      local snapshots = ph1.Observer:SnapshotAllSquadrons()
      local inventoryOk = inventoryReady(snapshots)
      local allPassed = true
      for _, completedId in ipairs(ph1.Sequence) do
        local result = ph1.Results[completedId]
        if not result or result.Classification ~= "PASS" or result.Released ~= true then
          allPassed = false
          break
        end
      end
      local cleanCounters = (ph1.Counters.unexpectedSpawns or 0) == 0 and
                            (ph1.Counters.parkingViolations or 0) == 0 and
                            (ph1.Counters.losses or 0) == 0 and
                            (ph1.Counters.timeouts or 0) == 0
      local finalPass = allPassed and inventoryOk and queueCount() == 0 and cleanCounters
      ph1.Classification = finalPass and "PASS" or "FAIL"
      if finalPass then
        log("RESULT: PASS testsPassed=5/5 abortRelease=PASS unexpectedSpawns=0 parkingViolations=0 losses=0 blockedAssets=0 finalInventoryRestored=true")
      else
        log(string.format("RESULT: FAIL testsPassed=%s abortRelease=%s unexpectedSpawns=%d parkingViolations=%d losses=%d timeouts=%d blockedAssets=%s finalInventoryRestored=%s",
          allPassed and "5/5" or "incomplete",
          ph1.Results.UH60_ABORT and ph1.Results.UH60_ABORT.Classification or "NOT_RUN",
          ph1.Counters.unexpectedSpawns or 0, ph1.Counters.parkingViolations or 0, ph1.Counters.losses or 0,
          ph1.Counters.timeouts or 0, inventoryOk and "0" or "nonzero", tostring(inventoryOk and queueCount() == 0)))
      end
      coalitionMessage(finalPass and "GESAMTERGEBNIS: PASS\n5/5 Tests einschließlich Abbruchfreigabe bestanden." or
        "GESAMTERGEBNIS: FAIL\nStatus und dcs.log prüfen.", 25)
      return finalPass
    end
    return self:StartTest(testId)
  end

  function controller:ResetController()
    if ph1.ActiveMission then
      coalitionMessage("Reset abgelehnt: aktiver Test muss zuerst beendet werden.", 12)
      return false
    end
    ph1.Results = {}
    ph1.History = {}
    ph1.Counters = newCounters()
    ph1.SequenceIndex = 0
    ph1.AutoSequence = false
    ph1.Classification = "NOT_RUN"
    ph1.State = "WAITING_FOR_BASELINE"
    ph1.BlockReason = nil
    ph1.ClientParkingResolved = false
    self:InitializeWhenReady()
    log("RESET controller-only=true cargoAndDestroyedTargetsNotRespawned=true")
    coalitionMessage("Controller zurückgesetzt. Bereits bewegte Fracht erfordert einen Missionsneustart.", 15)
    return true
  end

  function controller:GetStatusText()
    local lines = {
      "State: " .. tostring(ph1.State),
      "Overall: " .. tostring(ph1.Classification),
      "Active: " .. tostring(ph1.ActiveTestId or "none"),
      "Queue: " .. tostring(queueCount()),
      "Block: " .. tostring(ph1.BlockReason or "none")
    }
    if ph1.Runtime then
      lines[#lines + 1] = "Mission: " .. tostring(ph1.Runtime.MissionState)
      lines[#lines + 1] = string.format("Birth/Engine/TO/Land: %d/%d/%d/%d", ph1.Runtime.BirthCount or 0, ph1.Runtime.EngineStartCount or 0, ph1.Runtime.TakeoffCount or 0, ph1.Runtime.LandingCount or 0)
      lines[#lines + 1] = "Objective/RTB: " .. tostring(ph1.Runtime.ObjectiveSatisfied) .. "/" .. tostring(ph1.Runtime.RTBObserved)
      lines[#lines + 1] = "Pending: " .. tostring(ph1.Runtime.PendingFailure or ph1.Runtime.LastPendingCriterion or "none")
    end
    for _, testId in ipairs(ph1.Sequence) do
      local result = ph1.Results[testId]
      lines[#lines + 1] = testId .. ": " .. tostring(result and result.Classification or "NOT_RUN")
    end
    return table.concat(lines, "\n")
  end

  function controller:ShowStatus()
    local text = self:GetStatusText()
    log("STATUS " .. string.gsub(text, "\n", " | "))
    coalitionMessage(text, 25)
  end

  local function poll()
    if ph1.ActiveMission then
      controller:PollActive()
    else
      controller:InitializeWhenReady()
    end
  end

  SCHEDULER:New(nil, poll, {}, 20, ph1.Limits.PollInterval)
  log("READY controllerPoll=5s directAIRWING=true commanderTasking=false maxConcurrentTests=1")
end
