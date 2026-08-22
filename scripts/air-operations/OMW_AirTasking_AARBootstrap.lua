-- Operation Mountain Watch - additive Air Tasking attachment to the accepted AAR base.
--
-- Architecture boundary:
--   * OMW.AirOps.AAR must already be RUNNING.
--   * The accepted AAR base/controller/adapter are not recreated, replaced or mutated.
--   * Air Tasking observes runtimes exposed by the existing controller through its
--     public GetStation(...) interface.
--   * MOOSE SCHEDULER provides the bounded observation cadence.
--   * CampaignState remains the strategic resource authority.

local Bootstrap = {}

local TAG = "[OMW][AirTasking.AARBootstrap]"
local OBSERVER_INTERVAL_SEC = 5

Bootstrap.SchemaVersion = "OMW-AIR-TASKING-AAR-BOOTSTRAP-4"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(container, name, label)
  if type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
end

local function log(message)
  if env and type(env.info) == "function" then env.info(TAG .. " " .. tostring(message)) end
end

local function validateRunningAAR(aar)
  requireTable(aar, "spec.aarFacade")
  if aar.Status ~= "RUNNING" then fail("spec.aarFacade must already be RUNNING") end
  requireTable(aar.Controller, "spec.aarFacade.Controller")
  requireTable(aar.StrategicAdapter, "spec.aarFacade.StrategicAdapter")
  requireFunction(aar.Controller, "SelectArea", "spec.aarFacade.Controller")
  requireFunction(aar.Controller, "SubmitDemand", "spec.aarFacade.Controller")
  requireFunction(aar.Controller, "EndDemand", "spec.aarFacade.Controller")
  requireFunction(aar.Controller, "GetStation", "spec.aarFacade.Controller")
  return aar
end

local function createObserver(bridge, aar)
  if not SCHEDULER then fail("MOOSE SCHEDULER is unavailable") end

  local watchedByMissionId = {}
  local observedByRuntimeId = {}
  local scheduler = nil

  local function observeRuntime(record, runtime)
    if not runtime or type(runtime.runtimeId) ~= "string" then return end

    if not observedByRuntimeId[runtime.runtimeId] then
      observedByRuntimeId[runtime.runtimeId] = {
        runtime = runtime,
        record = record,
        terminalObserved = false,
      }
      -- This is an Air-Tasking-internal companion call. It does not invoke or
      -- replace the strategic adapter; it only correlates the already existing
      -- physical runtime with the stable ATM/EXE domain record.
      bridge:_OnMaterialized(record.selection, runtime, nil)
      log(string.format("RUNTIME_OBSERVED mission=%s runtime=%s area=%s",
        tostring(record.mission.mission_id), tostring(runtime.runtimeId), tostring(record.selection.area)))
    end
  end

  local function poll()
    for _, record in pairs(watchedByMissionId) do
      local selection = record.selection
      local station = aar.Controller.GetStation(selection.area, selection.receiverProfile)
      if station then
        observeRuntime(record, station.activeRuntime)
        observeRuntime(record, station.reliefRuntime)
      end
    end

    for runtimeId, item in pairs(observedByRuntimeId) do
      if not item.terminalObserved then
        local runtime = item.runtime
        if runtime.lossHandled == true then
          item.terminalObserved = true
          bridge:_OnLost(item.record.selection, runtime, "OBSERVED_CONTROLLER_LOSS")
          observedByRuntimeId[runtimeId] = nil
          log("RUNTIME_TERMINAL_OBSERVED runtime=" .. tostring(runtimeId) .. " result=LOSS")
        elseif runtime.handoffComplete == true then
          item.terminalObserved = true
          bridge:_OnHandoff(item.record.selection, runtime)
          observedByRuntimeId[runtimeId] = nil
          log("RUNTIME_TERMINAL_OBSERVED runtime=" .. tostring(runtimeId) .. " result=HANDOFF")
        end
      end
    end
  end

  scheduler = SCHEDULER:New(nil, poll, {}, 1, OBSERVER_INTERVAL_SEC)

  return {
    Watch = function(record)
      watchedByMissionId[record.mission.mission_id] = record
      return record
    end,
    Stop = function()
      if scheduler then scheduler:Stop() end
    end,
  }
end

function Bootstrap.Start(spec)
  spec = requireTable(spec, "spec")

  OMW = OMW or {}
  OMW.AirTasking = OMW.AirTasking or {}

  if OMW.AirTasking.AAR and OMW.AirTasking.AAR.Status == "RUNNING" then
    log("START_SKIPPED reason=ALREADY_RUNNING")
    return OMW.AirTasking.AAR
  end

  local bridgeModule = requireTable(spec.bridgeModule, "spec.bridgeModule")
  local aar = validateRunningAAR(spec.aarFacade)
  requireFunction(bridgeModule, "New", "spec.bridgeModule")
  if type(spec.nextExecutionId) ~= "function" then fail("spec.nextExecutionId must be a function") end

  local bridge = bridgeModule.New({
    controller = aar.Controller,
    nextExecutionId = spec.nextExecutionId,
    logger = spec.logger,
  })

  local observer = createObserver(bridge, aar)

  local facade = {
    Status = "RUNNING",
    SchemaVersion = Bootstrap.SchemaVersion,
    Scope = "AIR_TASKING_AAR_ADDITIVE",
    AAR = aar,
    Bridge = bridge,
    Observer = observer,
  }

  function facade.SubmitApprovedAAR(requestSpec)
    local record, reason = bridge:SubmitApprovedAAR(requestSpec)
    if record then observer.Watch(record) end
    return record, reason
  end

  function facade.EndAAR(missionId, outcome)
    return bridge:EndAAR(missionId, outcome)
  end

  function facade.GetMission(missionId)
    return bridge:GetMission(missionId)
  end

  function facade.GetRequest(requestId)
    return bridge:GetRequest(requestId)
  end

  function facade.GetExecutionAttempts(missionId)
    return bridge:GetExecutionAttempts(missionId)
  end

  function facade.ExportSnapshot()
    return bridge:ExportSnapshot()
  end

  function facade.StopObserver()
    observer.Stop()
  end

  OMW.AirTasking.AAR = facade

  log(string.format(
    "RUNNING scope=AIR_TASKING_AAR_ADDITIVE existingAARBase=true adapterRecreated=false adapterMutated=false observerIntervalSec=%d",
    OBSERVER_INTERVAL_SEC))
  return facade
end

return Bootstrap
