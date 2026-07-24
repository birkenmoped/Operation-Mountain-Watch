-- Operation Mountain Watch - Phase 1 compatibility for pinned MOOSE mission semantics
local TAG = "[OMW][AirOps.JBAD.PH1.COMPAT]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Controller then
  log("ERROR: Phase 1 runtime components unavailable.")
else
  local controller = ph1.Controller

  local originalAbortActive = controller.AbortActive
  function controller:AbortActive(reason)
    if ph1.Runtime and not (ph1.ActiveDefinition and ph1.ActiveDefinition.AbortOnBirth) and reason ~= "failure-cleanup" then
      ph1.Runtime.PendingFailure = ph1.Runtime.PendingFailure or ("manual-abort: " .. tostring(reason or "unspecified"))
    end
    if ph1.Runtime then
      ph1.Runtime.FailureCleanupDeadline = ph1.Runtime.FailureCleanupDeadline or (timer.getTime() + ((ph1.ActiveDefinition and ph1.ActiveDefinition.ReleaseTimeout) or 300))
    end
    return originalAbortActive(self, reason)
  end

  local originalLifecycleSatisfied = controller.LifecycleSatisfied
  function controller:LifecycleSatisfied()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if runtime and definition and definition.ExpectedTerminalState == "CANCELLED" and runtime.MissionStateSeen and runtime.MissionStateSeen.CANCELLED then
      local currentState = runtime.MissionState
      runtime.MissionState = "CANCELLED"
      local ok, reason = originalLifecycleSatisfied(self)
      runtime.MissionState = currentState
      return ok, reason
    end
    return originalLifecycleSatisfied(self)
  end

  log("READY pinnedMooseCancelEvaluation=true exactObserverOwnsAllEvents=true failureCleanupDeadline=true")
end
