-- Operation Mountain Watch - Phase 1 phased lifecycle and timeout model
-- Package selection and inventory readiness are handled by the canonical package
-- contract module. This file only manages the lifecycle of the active test.
local TAG = "[OMW][AirOps.JBAD.PH1.LIFECYCLE]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local controller = ph1 and ph1.Controller
if not cfg or not ph1 or not controller then
  log("ERROR: Phase 1 controller unavailable.")
else
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

  local function setPhase(runtime, phase, timeout)
    if not runtime then return end
    runtime.Phase = phase
    runtime.PhaseStartedAt = timer.getTime()
    runtime.PhaseDeadline = timer.getTime() + timeout
    log(string.format("PHASE testId=%s phase=%s timeout=%ds deadline=%.1f", tostring(ph1.ActiveTestId), phase, timeout, runtime.PhaseDeadline))
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
      if ok and satisfied then
        runtime.ObjectiveSatisfied = true
        log("EVENT testId=" .. tostring(ph1.ActiveTestId) .. " stage=OBJECTIVE_CONFIRMED")
      end
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
      runtime.LastPendingCriterion = "moose-evaluating-custom-success"
    elseif runtime.LandingCount == definition.ExpectedAircraft and not released then
      runtime.LastPendingCriterion = "awaiting-inventory-release"
    end
  end

  local originalStatus = controller.GetStatusText
  function controller:GetStatusText()
    local text = originalStatus(self)
    if ph1.Runtime then
      local remaining = math.max(0, (ph1.Runtime.PhaseDeadline or timer.getTime()) - timer.getTime())
      text = text .. "\nPhase: " .. tostring(ph1.Runtime.Phase) .. string.format(" (%.0fs)", remaining)
      text = text .. "\nExpected exact groups: " .. tostring(countKeys(ph1.Runtime.ExpectedGroupNames)) .. "/" .. tostring(ph1.ActiveDefinition and ph1.ActiveDefinition.ExpectedGroups or 0)
      text = text .. "\nExpected aircraft: " .. tostring(ph1.Runtime.BirthCount or 0) .. "/" .. tostring(ph1.ActiveDefinition and ph1.ActiveDefinition.ExpectedAircraft or 0)
      if ph1.Runtime.LastPendingCriterion then text = text .. "\nPending: " .. tostring(ph1.Runtime.LastPendingCriterion) end
    end
    return text
  end

  log("READY phasedTimeouts=SPAWN/EXECUTION/RECOVERY/RELEASE packageCounts=definition-driven")
end
