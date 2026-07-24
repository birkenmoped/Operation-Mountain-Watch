-- Operation Mountain Watch - Jalalabad Phase 1 compatibility for pinned MOOSE mission semantics
-- Event filtering, parking enforcement and landing evaluation now live entirely
-- in 12-phase1-runtime-observer.lua. This file only adapts MOOSE's internal
-- CANCELLED transition while custom success conditions are evaluated.
local TAG = "[OMW][AirOps.JBAD.PH1.COMPAT]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Controller then
  log("ERROR: Phase 1 controller unavailable.")
else
  local controller = ph1.Controller

  local originalAbortActive = controller.AbortActive
  function controller:AbortActive(reason)
    if ph1.Runtime and not (ph1.ActiveDefinition and ph1.ActiveDefinition.AbortOnBirth) and reason ~= "failure-cleanup" then
      ph1.Runtime.PendingFailure = ph1.Runtime.PendingFailure or ("manual-abort: " .. tostring(reason or "unspecified"))
    end
    return originalAbortActive(self, reason)
  end

  local originalLifecycleSatisfied = controller.LifecycleSatisfied
  function controller:LifecycleSatisfied()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if runtime and definition and definition.ExpectedTerminalState == "CANCELLED" and
       runtime.MissionStateSeen and runtime.MissionStateSeen.CANCELLED then
      local currentState = runtime.MissionState
      runtime.MissionState = "CANCELLED"
      local ok, reason = originalLifecycleSatisfied(self)
      runtime.MissionState = currentState
      return ok, reason
    end
    return originalLifecycleSatisfied(self)
  end

  log("READY pinnedMooseCancelEvaluation=true observerOwnsAllRuntimeEvents=true")
end
