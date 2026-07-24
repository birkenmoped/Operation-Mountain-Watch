-- Operation Mountain Watch - Phase 1 corrected lifecycle, inventory and timeout model
local TAG = "[OMW][AirOps.JBAD.PH1.LIFECYCLE]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local controller = ph1 and ph1.Controller
if not cfg or not ph1 or not controller then
  log("ERROR: Phase 1 controller unavailable.")
else
  local expectedAssetGroups = { OH58D = 24, AH64D = 8, UH60 = 8, CH47 = 8 }

  local function queueCount()
    local count = 0
    for _ in pairs((cfg.Airwing and cfg.Airwing.missionqueue) or {}) do count = count + 1 end
    return count
  end

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
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

  local function setPhase(runtime, phase, timeout)
    if not runtime then return end
    runtime.Phase = phase
    runtime.PhaseStartedAt = timer.getTime()
    runtime.PhaseDeadline = timer.getTime() + timeout
    log(string.format("PHASE testId=%s phase=%s timeout=%ds deadline=%.1f", tostring(ph1.ActiveTestId), phase, timeout, runtime.PhaseDeadline))
  end

  function controller:InitializeWhenReady()
    if ph1.State ~= "WAITING_FOR_BASELINE" and ph1.State ~= "BLOCKED" then return true end
    if cfg.Status ~= "OPERATIONAL" or not cfg.Airwing then ph1.State = "WAITING_FOR_BASELINE" return false end
    cfg.BaselineReady = true
    if cfg.ParkingReservationsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-reservation-regression" return false end
    if cfg.ParkingPoolsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-pools-invalid" return false end
    if cfg.NameContractOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "runtime-name-contract-invalid" return false end
    if not ph1.Factory:ValidateMissionEditorObjects() then ph1.State = "BLOCKED" ph1.BlockReason = "mission-editor-objects-missing" return false end
    if not ph1.ClientParkingResolved and not ph1.Observer:ResolveClientParkingIDs() then ph1.State = "BLOCKED" ph1.BlockReason = "client-parking-unresolved" return false end

    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local ready, reason = inventoryReady(snapshots)
    if not ready then ph1.State = "WAITING_FOR_BASELINE" ph1.BlockReason = reason return false end
    if queueCount() ~= 0 then ph1.State = "BLOCKED" ph1.BlockReason = "pre-existing-airwing-mission-queue" return false end

    ph1.State = "READY"
    ph1.BlockReason = nil
    ph1.Observer:LogSnapshot("PHASE1_READY", snapshots)
    log("READY inventory=OH58D:24/AH64D:8/UH60:8/CH47:8 exactRuntimeNames=true independentSingleShipGroups=true")
    coalitionMessage("Testpaket ist READY.", 10)
    return true
  end

  function controller:ResetRuntime(definition)
    ph1.Runtime = {
      TestId = definition.Id,
      StartedAt = timer.getTime(),
      MissionState = "CREATED",
      MissionStateSeen = {},
      ExpectedGroupNames = {},
      ExpectedUnitNames = {},
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
    setPhase(ph1.Runtime, "SPAWN", definition.SpawnTimeout)
  end

  function controller:StartTest(testId)
    if ph1.ActiveMission then coalitionMessage("Abgelehnt: Test aktiv: " .. tostring(ph1.ActiveTestId), 12) return false end
    if not self:InitializeWhenReady() then coalitionMessage("Nicht bereit: " .. tostring(ph1.BlockReason or ph1.State), 15) return false end
    local definition = ph1.Tests[testId]
    if not definition then coalitionMessage("Unbekannter Test: " .. tostring(testId), 10) return false end
    if not definition.ExpectedGroupPrefix or definition.ExpectedGroupPrefix == "" then coalitionMessage("Abgelehnt: Runtime-Gruppenpräfix fehlt.", 15) return false end
    if queueCount() ~= 0 then ph1.State = "BLOCKED" ph1.BlockReason = "airwing-mission-queue-not-empty" return false end

    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local ready, reason = inventoryReady(snapshots)
    if not ready then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "inventory-not-clean: " .. tostring(reason)
      ph1.Observer:LogSnapshot("START_BLOCKED", snapshots)
      coalitionMessage("Abgelehnt: Bestand nicht vollständig frei.", 15)
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
    log(string.format("START testId=%s squadron=%s runtimePrefix=%s expectedGroups=%d expectedAircraft=%d spawnTimeout=%ds executionTimeout=%ds recoveryTimeout=%ds releaseTimeout=%ds", testId, definition.SquadronKey, definition.ExpectedGroupPrefix, definition.ExpectedGroups, definition.ExpectedAircraft, definition.SpawnTimeout, definition.ExecutionTimeout, definition.RecoveryTimeout, definition.ReleaseTimeout))
    coalitionMessage("Gestartet: " .. definition.Label, 12)
    return true
  end

  function controller:OnMissionState(state, mission, from, event, to)
    if mission ~= ph1.ActiveMission or not ph1.Runtime then return end
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    runtime.MissionState = state
    if runtime.MissionStateSeen[state] then return end
    runtime.MissionStateSeen[state] = true
    log(string.format("EVENT testId=%s stage=MISSION_%s from=%s to=%s", tostring(ph1.ActiveTestId), state, tostring(from), tostring(to)))

    if state == "SCHEDULED" then
      increment("assetsReserved")
      ph1.Observer:RefreshMissionGroups()
    elseif state == "STARTED" or state == "EXECUTING" then
      if state == "EXECUTING" then increment("missionsExecuting") end
      if runtime.Phase == "SPAWN" then setPhase(runtime, "EXECUTION", definition.ExecutionTimeout) end
    elseif state == "SUCCESS" then
      increment("missionsSucceeded")
      runtime.MissionTerminal = true
      setPhase(runtime, "RECOVERY", definition.RecoveryTimeout)
    elseif state == "FAILED" then
      increment("missionsFailed")
      runtime.MissionTerminal = true
      runtime.PendingFailure = runtime.PendingFailure or "auftrag-failed"
    elseif state == "CANCELLED" then
      increment("missionsCancelled")
      runtime.MissionTerminal = true
      if definition.ExpectedTerminalState == "CANCELLED" then setPhase(runtime, "RELEASE", definition.ReleaseTimeout) end
    elseif state == "DONE" then
      runtime.MissionDone = true
    end
  end

  function controller:PollActive()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition or not ph1.ActiveMission then return end

    ph1.Observer:RefreshMissionGroups()
    ph1.Observer:UpdateDistanceTracking()

    if runtime.ObjectiveCheck and not runtime.ObjectiveSatisfied then
      local ok, satisfied = pcall(runtime.ObjectiveCheck)
      if ok and satisfied then runtime.ObjectiveSatisfied = true log("EVENT testId=" .. tostring(ph1.ActiveTestId) .. " stage=OBJECTIVE_CONFIRMED") end
    end

    local current = ph1.Observer:SnapshotAllSquadrons()
    local reservationOK, reservationReason = self:CheckReservationBounds(current)
    if not reservationOK then self:RequestFailure(reservationReason) end
    if runtime.HardFailure then self:RequestFailure(runtime.HardFailure) end

    local now = timer.getTime()
    if now >= (runtime.PhaseDeadline or math.huge) and not runtime.PendingFailure then
      increment("timeouts")
      self:RequestFailure(string.lower(runtime.Phase or "unknown") .. "-timeout")
      setPhase(runtime, "RELEASE", definition.ReleaseTimeout)
    end

    if runtime.Phase == "SPAWN" and runtime.BirthCount == definition.ExpectedAircraft and countKeys(runtime.BornGroupNames) == definition.ExpectedGroups then
      setPhase(runtime, "EXECUTION", definition.ExecutionTimeout)
    elseif runtime.Phase == "RECOVERY" and definition.RequireLanding and runtime.LandingCount == definition.ExpectedAircraft then
      setPhase(runtime, "RELEASE", definition.ReleaseTimeout)
    elseif runtime.Phase == "RECOVERY" and not definition.RequireLanding and runtime.MissionTerminal then
      setPhase(runtime, "RELEASE", definition.ReleaseTimeout)
    end

    local restored, restoredData = ph1.Observer:IsInventoryRestored(ph1.BaselineInventory)
    if restored and queueCount() == 0 then runtime.ReleaseStablePolls = runtime.ReleaseStablePolls + 1 else runtime.ReleaseStablePolls = 0 end
    local released = runtime.ReleaseStablePolls >= ph1.Limits.ReleaseStablePolls
    if released and not runtime.ReleaseLogged then
      runtime.ReleaseLogged = true
      increment("assetsReturned")
      ph1.Observer:LogSnapshot("AFTER_" .. definition.Id, restoredData)
      log("EVENT testId=" .. tostring(ph1.ActiveTestId) .. " stage=ASSET_RELEASED stablePolls=" .. tostring(runtime.ReleaseStablePolls))
    end

    if runtime.PendingFailure then
      if released then
        self:FinalizeTest("FAIL", runtime.PendingFailure, true)
      elseif runtime.Phase == "RELEASE" and now >= runtime.PhaseDeadline then
        self:FinalizeTest("FAIL", runtime.PendingFailure .. "; assets-not-released", false)
      end
      return
    end

    local lifecycleOK, lifecycleReason = self:LifecycleSatisfied()
    if lifecycleOK and released then
      self:FinalizeTest("PASS", "complete-lifecycle-and-inventory-release", true)
    elseif runtime.MissionState == "FAILED" then
      self:RequestFailure("auftrag-failed")
    elseif runtime.MissionState == "SUCCESS" and not lifecycleOK then
      runtime.LastPendingCriterion = lifecycleReason
    elseif runtime.MissionState == "CANCELLED" and definition.ExpectedTerminalState ~= "CANCELLED" then
      -- Pinned MOOSE temporarily enters CANCELLED while evaluating custom
      -- success conditions. The execution/recovery timeout remains authoritative.
      runtime.LastPendingCriterion = "moose-evaluating-custom-success"
    end
  end

  local originalStatus = controller.GetStatusText
  function controller:GetStatusText()
    local text = originalStatus(self)
    if ph1.Runtime then
      local remaining = math.max(0, (ph1.Runtime.PhaseDeadline or timer.getTime()) - timer.getTime())
      text = text .. "\nPhase: " .. tostring(ph1.Runtime.Phase) .. string.format(" (%.0fs)", remaining)
      text = text .. "\nExpected exact groups: " .. tostring(countKeys(ph1.Runtime.ExpectedGroupNames)) .. "/" .. tostring(ph1.ActiveDefinition and ph1.ActiveDefinition.ExpectedGroups or 0)
    end
    return text
  end

  log("READY correctedInventory=24/8/8/8 phasedTimeouts=SPAWN/EXECUTION/RECOVERY/RELEASE exactGroupCounts=true")
end
