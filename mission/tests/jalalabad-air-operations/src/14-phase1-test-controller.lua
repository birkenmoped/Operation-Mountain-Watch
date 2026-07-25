-- Operation Mountain Watch - MOOSE-first Phase-1 test controller
-- AUFTRAG and OPSTRANSPORT remain the operative FSMs. This controller only
-- dispatches native objects, applies a watchdog and evaluates independent DCS
-- acceptance evidence after the native operation and MOOSE asset lifecycle have completed.
local TAG = "[OMW][AirOps.JBAD.PH1]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Factory or not ph1.Observer or not ph1.Logistics then
  log("ERROR: Phase-1 dependencies unavailable.")
else
  local controller = ph1.Controller or {}
  ph1.Controller = controller

  local function coalitionMessage(text, seconds)
    if trigger and trigger.action and trigger.action.outTextForCoalition then
      trigger.action.outTextForCoalition(coalition.side.BLUE, "OMW Jalalabad Phase 1\n" .. tostring(text), seconds or 15)
    end
  end

  local function newCounters()
    return {
      missionsCreated = 0, missionsQueued = 0, assetsReserved = 0,
      groupsSpawned = 0, aircraftSpawned = 0, engineStarts = 0, takeoffs = 0,
      landings = 0, remoteLandings = 0, engineShutdowns = 0, assetsReturned = 0,
      parkingViolations = 0, unexpectedSpawns = 0, losses = 0, timeouts = 0
    }
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or newCounters()
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function nativeTerminalReached(runtime, definition)
    return runtime.NativeStates and runtime.NativeStates[definition.NativeTerminal] == true
  end

  local function physicalObjectiveSatisfied()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition then return false end
    if not definition.RequireObjective then return true end
    if definition.LogisticsProfile then return ph1.Logistics:RefreshObjective() end
    if definition.ObjectiveKind == "TARGET_GROUP_DESTROYED" then
      local group = runtime.CASTargetGroupName and GROUP:FindByName(runtime.CASTargetGroupName) or nil
      runtime.ObjectiveSatisfied = not group or not group:IsAlive()
    elseif definition.ObjectiveKind == "RECON_NATIVE_SUCCESS" then
      runtime.ObjectiveSatisfied = runtime.NativeStates.SUCCESS == true
    end
    return runtime.ObjectiveSatisfied == true
  end

  function controller:InitializeWhenReady()
    if ph1.State ~= "WAITING_FOR_BASELINE" and ph1.State ~= "BLOCKED" then return true end
    if cfg.Status ~= "OPERATIONAL" or not cfg.Airwing or cfg.PackageContractsOK ~= true or ph1.ManifestOK ~= true then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = "Jalalabad AIRWING/package baseline unavailable"
      return false
    end
    if cfg.ParkingReservationsOK ~= true or cfg.ParkingPoolsOK ~= true or cfg.NameContractOK ~= true then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "parking-or-name-contract-regression"
      return false
    end
    local objectsReady, missing = ph1.Factory:ValidateMissionEditorObjects()
    if not objectsReady then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "missing Mission Editor objects: " .. table.concat(missing or {}, ",")
      return false
    end
    if not ph1.ClientParkingResolved and not ph1.Observer:ResolveClientParkingIDs() then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "client-parking-unresolved"
      return false
    end
    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local clean, reason = ph1.Observer:IsInventoryClean(snapshots)
    if not clean then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = reason
      return false
    end
    local queue = ph1.Observer:GetMissionQueueCount()
    if queue ~= 0 then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "pre-existing-MOOSE-mission-queue-" .. tostring(queue)
      return false
    end
    ph1.State = "READY"
    ph1.BlockReason = nil
    cfg.BaselineReady = true
    ph1.Observer:LogSnapshot("PHASE1_READY", snapshots)
    log("READY MOOSE-authorities=true missionQueue=CountMissionsInQueue inventory=CountAssets/CountAssetsOnMission")
    return true
  end

  function controller:ResetRuntime(definition)
    ph1.Runtime = {
      TestId = definition.Id,
      StartedAt = timer.getTime(),
      Deadline = timer.getTime() + definition.Timeout,
      NativeState = "CREATED",
      NativeStates = { CREATED = true },
      BoundGroupNames = {},
      FlightGroups = {},
      ExpectedUnitNames = {},
      BornUnits = {}, EngineUnits = {}, TakeoffUnits = {}, LandedUnits = {}, ShutdownUnits = {}, LostUnits = {},
      BirthCount = 0, EngineStartCount = 0, TakeoffCount = 0, LandingCount = 0, EngineShutdownCount = 0,
      RemoteLandingCount = 0, ObjectiveSatisfied = false, RTBObserved = false,
      HardFailure = nil, PendingFailure = nil, ReleaseStablePolls = 0,
      LegionAssetReturnedCount = 0, AssetReleaseConfirmed = false,
      FinalDespawnArmed = false, AbortRequested = false, AbortScheduled = false
    }
  end

  function controller:OnNativeState(kind, state, object, from, event, to)
    if object ~= ph1.ActiveObject or not ph1.Runtime then return end
    local runtime = ph1.Runtime
    runtime.NativeKind = kind
    runtime.NativeState = state
    runtime.NativeStates[state] = true
    log(string.format("NATIVE_STATE testId=%s authority=%s state=%s from=%s to=%s", tostring(ph1.ActiveTestId), tostring(kind), tostring(state), tostring(from), tostring(to)))

    if state == "SCHEDULED" then increment("assetsReserved") end
    if state == "FAILED" then runtime.PendingFailure = runtime.PendingFailure or "native-operation-failed" end
    if state == "CANCELLED" and ph1.ActiveDefinition.NativeTerminal ~= "CANCELLED" then
      runtime.PendingFailure = runtime.PendingFailure or "unexpected-native-cancellation"
    end
    physicalObjectiveSatisfied()
  end

  function controller:OnFlightGroupBound(flightgroup, owner, source)
    if not ph1.Runtime or not ph1.ActiveDefinition then return end
    local definition = ph1.ActiveDefinition
    if definition.AbortOnBind and not ph1.Runtime.AbortScheduled then
      ph1.Runtime.AbortScheduled = true
      SCHEDULER:New(nil, function()
        if ph1.ActiveDefinition == definition and ph1.ActiveObject then controller:AbortActive("defined-abort-after-MOOSE-bind") end
      end, {}, ph1.Limits.AbortDelayAfterBindSeconds)
      log("ABORT_SCHEDULED testId=" .. definition.Id .. " source=" .. tostring(source))
    end
  end

  function controller:StartTest(testId)
    if ph1.ActiveObject then coalitionMessage("Abgelehnt: Test aktiv: " .. tostring(ph1.ActiveTestId), 12) return false end
    if not self:InitializeWhenReady() then coalitionMessage("Nicht bereit: " .. tostring(ph1.BlockReason), 15) return false end
    local definition = ph1.Tests[testId]
    if not definition then coalitionMessage("Unbekannter Test: " .. tostring(testId), 10) return false end
    local ready, reason = ph1.Factory:ValidateTestReady(testId, true)
    if not ready then
      ph1.BlockReason = testId .. ": " .. tostring(reason)
      coalitionMessage("Nicht bereit: " .. ph1.BlockReason, 20)
      return false
    end
    if ph1.Observer:GetMissionQueueCount() ~= 0 then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "MOOSE-mission-queue-not-empty"
      return false
    end
    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local clean, inventoryReason = ph1.Observer:IsInventoryClean(snapshots)
    if not clean then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "inventory-not-clean: " .. tostring(inventoryReason)
      return false
    end

    ph1.ActiveTestId = testId
    ph1.ActiveDefinition = definition
    self:ResetRuntime(definition)
    ph1.BaselineInventory = snapshots
    ph1.Observer:LogSnapshot("BEFORE_" .. testId, snapshots)

    local kind, object, createError = ph1.Factory:Create(testId)
    if not object then
      ph1.Runtime.PendingFailure = "operation-create-failed: " .. tostring(createError)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end
    ph1.ActiveKind = kind
    ph1.ActiveObject = object
    increment("missionsCreated")
    ph1.State = "ACTIVE"

    local ok, dispatchError
    if kind == "AUFTRAG" then
      ok, dispatchError = pcall(function() return cfg.Airwing:AddMission(object) end)
      if ok then increment("missionsQueued") end
    elseif kind == "OPSTRANSPORT" then
      ok, dispatchError = ph1.Logistics:DispatchTransport(object)
    else
      ok, dispatchError = false, "unknown-operation-kind-" .. tostring(kind)
    end
    if not ok then
      ph1.Runtime.PendingFailure = "native-dispatch-failed: " .. tostring(dispatchError)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    log(string.format("START testId=%s authority=%s package=%s expectedGroups=%d expectedAircraft=%d nativeTerminal=%s",
      testId, kind, definition.PackageModel, definition.ExpectedGroups, definition.ExpectedAircraft, definition.NativeTerminal))
    coalitionMessage("Gestartet: " .. definition.Label, 12)
    return true
  end

  function controller:AbortActive(reason)
    if not ph1.ActiveObject or not ph1.Runtime then return false end
    if ph1.Runtime.AbortRequested then return true end
    ph1.Runtime.AbortRequested = true
    ph1.Runtime.AbortReason = reason or "manual-abort"
    local ok, err
    if ph1.ActiveKind == "AUFTRAG" then
      ok, err = pcall(function() ph1.ActiveObject:Cancel() end)
    else
      ok, err = pcall(function() cfg.Airwing:TransportCancel(ph1.ActiveObject) end)
    end
    if not ok then ph1.Runtime.PendingFailure = "native-cancel-failed: " .. tostring(err) end
    log("ABORT_REQUEST authority=" .. tostring(ph1.ActiveKind) .. " reason=" .. tostring(ph1.Runtime.AbortReason))
    return ok
  end

  function controller:RequestFailure(reason)
    if not ph1.Runtime then return end
    ph1.Runtime.PendingFailure = ph1.Runtime.PendingFailure or reason
    if ph1.ActiveObject and not ph1.Runtime.AbortRequested then self:AbortActive("failure-cleanup") end
  end

  local function acceptanceSatisfied(runtime, definition)
    if runtime.HardFailure then return false, runtime.HardFailure end
    if not nativeTerminalReached(runtime, definition) then return false, "awaiting-native-terminal-" .. definition.NativeTerminal end
    if definition.RequireObjective and not physicalObjectiveSatisfied() then return false, "awaiting-physical-objective" end
    if runtime.BirthCount ~= definition.ExpectedAircraft then return false, "spawn-count-mismatch" end
    if definition.RequireTakeoff and runtime.TakeoffCount ~= definition.ExpectedAircraft then return false, "takeoff-count-mismatch" end
    if definition.RequireRTB and not runtime.RTBObserved then return false, "rtb-not-observed" end
    if definition.RequireLanding and runtime.LandingCount ~= definition.ExpectedAircraft then return false, "landing-count-mismatch" end
    return true
  end

  function controller:FinalizeTest(classification, reason, released)
    local testId = ph1.ActiveTestId or "UNKNOWN"
    local definition = ph1.ActiveDefinition or {}
    local runtime = ph1.Runtime or {}
    local result = {
      Classification = classification, Reason = reason, Released = released == true,
      Authority = ph1.ActiveKind, NativeState = runtime.NativeState,
      Births = runtime.BirthCount or 0, EngineStarts = runtime.EngineStartCount or 0,
      Takeoffs = runtime.TakeoffCount or 0, Landings = runtime.LandingCount or 0,
      Objective = runtime.ObjectiveSatisfied == true, RTB = runtime.RTBObserved == true,
      Duration = timer.getTime() - (runtime.StartedAt or timer.getTime())
    }
    ph1.Results[testId] = result
    ph1.History[#ph1.History + 1] = { TestId = testId, Result = result }
    ph1.LastRuntime = runtime
    log(string.format("RESULT testId=%s classification=%s reason=%s authority=%s nativeState=%s released=%s births=%d takeoffs=%d objective=%s rtb=%s landings=%d duration=%.1fs",
      testId, classification, tostring(reason), tostring(result.Authority), tostring(result.NativeState), tostring(result.Released),
      result.Births, result.Takeoffs, tostring(result.Objective), tostring(result.RTB), result.Landings, result.Duration))
    coalitionMessage((definition.Label or testId) .. ": " .. classification .. "\n" .. tostring(reason), 18)

    local continueSequence = ph1.AutoSequence and classification == "PASS"
    ph1.ActiveObject, ph1.ActiveKind, ph1.ActiveTestId, ph1.ActiveDefinition = nil, nil, nil, nil
    ph1.Runtime, ph1.BaselineInventory = nil, nil
    ph1.State = "READY"
    if continueSequence then
      SCHEDULER:New(nil, function() controller:StartNextSequenceTest() end, {}, ph1.Limits.NextTestDelaySeconds)
    elseif ph1.AutoSequence and classification ~= "PASS" then
      ph1.AutoSequence = false
      ph1.Classification = classification
    end
  end

  function controller:PollActive()
    local runtime, definition = ph1.Runtime, ph1.ActiveDefinition
    if not runtime or not definition or not ph1.ActiveObject then return end
    if definition.LogisticsProfile then ph1.Logistics:RefreshObjective() end
    if runtime.HardFailure then self:RequestFailure(runtime.HardFailure) end
    if timer.getTime() >= runtime.Deadline and not runtime.PendingFailure then
      increment("timeouts")
      self:RequestFailure("watchdog-timeout")
    end

    -- Successful MOOSE-managed assets are released by the authoritative LEGION
    -- FSM edge. Inventory equality is deliberately not a second success gate:
    -- LEGION:onafterNewAsset has already returned the asset to the cohort before
    -- LegionAssetReturned is triggered.
    local expectedReturns = tonumber(definition.ExpectedGroups) or 0
    local returnedCount = tonumber(runtime.LegionAssetReturnedCount) or 0
    local authoritativeReleased = expectedReturns > 0 and returnedCount >= expectedReturns
    runtime.AssetReleaseConfirmed = authoritativeReleased

    -- Inventory/queue polling remains a cleanup fallback only after a real
    -- failure. It must never classify an untouched pre-spawn baseline as a
    -- completed successful sortie and must never block a MOOSE return event.
    local restored, restoreReason, restoredData = ph1.Observer:IsInventoryRestored(ph1.BaselineInventory)
    local queueClean = ph1.Observer:GetMissionQueueCount() == 0
    local cleanupReleased = false
    if runtime.PendingFailure then
      if restored and queueClean then
        runtime.ReleaseStablePolls = runtime.ReleaseStablePolls + 1
      else
        runtime.ReleaseStablePolls = 0
      end
      cleanupReleased = runtime.ReleaseStablePolls >= ph1.Limits.ReleaseStablePolls
    else
      runtime.ReleaseStablePolls = 0
    end

    local released = authoritativeReleased or cleanupReleased
    if released and not runtime.ReleaseLogged then
      runtime.ReleaseLogged = true
      increment("assetsReturned")
      local afterSnapshot = restoredData or ph1.Observer:SnapshotAllSquadrons()
      ph1.Observer:LogSnapshot("AFTER_" .. definition.Id, afterSnapshot)
      if authoritativeReleased then
        log(string.format("ACCEPTANCE event=ASSET_RELEASED authority=MOOSE_LEGION_FSM returnedGroups=%d expectedGroups=%d inventoryRestored=%s queueClean=%s inventoryDiagnosticNonBlocking=true",
          returnedCount, expectedReturns, tostring(restored), tostring(queueClean)))
      else
        log("ACCEPTANCE event=ASSET_RELEASED authority=INVENTORY_CLEANUP_FALLBACK stablePolls=" .. tostring(runtime.ReleaseStablePolls))
      end
    end

    if runtime.PendingFailure then
      if released or timer.getTime() >= runtime.Deadline + 300 then
        self:FinalizeTest("FAIL", runtime.PendingFailure .. (released and "" or "; " .. tostring(restoreReason or "assets-not-released")), released)
      end
      return
    end

    local accepted, pending = acceptanceSatisfied(runtime, definition)
    runtime.LastPendingCriterion = pending
    if accepted and authoritativeReleased then
      self:FinalizeTest("PASS", "native-operation-independent-acceptance-and-MOOSE-asset-return-complete", true)
    end
  end

  function controller:StartSequence()
    if ph1.ActiveObject then return false end
    ph1.Results, ph1.Counters = {}, newCounters()
    ph1.SequenceIndex, ph1.AutoSequence, ph1.Classification = 0, true, "RUNNING"
    return self:StartNextSequenceTest()
  end

  function controller:StartNextSequenceTest()
    if not ph1.AutoSequence then return false end
    ph1.SequenceIndex = ph1.SequenceIndex + 1
    local testId = ph1.Sequence[ph1.SequenceIndex]
    if testId then return self:StartTest(testId) end
    ph1.AutoSequence = false
    local allPassed = true
    for _, id in ipairs(ph1.Sequence) do
      local result = ph1.Results[id]
      if not result or result.Classification ~= "PASS" or result.Released ~= true then allPassed = false break end
    end
    local clean = ph1.Observer:IsInventoryClean(ph1.Observer:SnapshotAllSquadrons())
    ph1.Classification = allPassed and clean and "PASS" or "FAIL"
    log("SEQUENCE_RESULT classification=" .. ph1.Classification)
    coalitionMessage("GESAMTERGEBNIS: " .. ph1.Classification, 25)
    return ph1.Classification == "PASS"
  end

  function controller:ResetController()
    if ph1.ActiveObject then return false end
    ph1.Results, ph1.History, ph1.Counters = {}, {}, newCounters()
    ph1.SequenceIndex, ph1.AutoSequence, ph1.Classification = 0, false, "NOT_RUN"
    ph1.State, ph1.BlockReason = "WAITING_FOR_BASELINE", nil
    ph1.ClientParkingResolved = false
    self:InitializeWhenReady()
    return true
  end

  function controller:GetStatusText()
    local lines = {
      "State: " .. tostring(ph1.State), "Overall: " .. tostring(ph1.Classification),
      "Active: " .. tostring(ph1.ActiveTestId or "none"), "Authority: " .. tostring(ph1.ActiveKind or "none"),
      "MOOSE mission queue: " .. tostring(ph1.Observer:GetMissionQueueCount()), "Block: " .. tostring(ph1.BlockReason or "none")
    }
    if ph1.Runtime then
      lines[#lines + 1] = "Native state: " .. tostring(ph1.Runtime.NativeState)
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

  SCHEDULER:New(nil, function()
    if ph1.ActiveObject then controller:PollActive() else controller:InitializeWhenReady() end
  end, {}, 20, ph1.Limits.PollIntervalSeconds)
  ph1.Counters = ph1.Counters or newCounters()
  log("READY controllerRole=dispatch/watchdog/acceptance-only operativeFSM=AUFTRAG-or-OPSTRANSPORT successReleaseAuthority=MOOSE_LEGION_FSM inventoryPolling=diagnostic-or-failure-cleanup-only customMissionFSM=false")
end