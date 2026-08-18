-- Operation Mountain Watch - additive Air Tasking attachment to the accepted AAR base.
--
-- Architecture boundary:
--   * OMW.AirOps.AAR must already be RUNNING.
--   * The accepted AAR base/controller/adapter are not recreated or replaced.
--   * Air Tasking observes the existing strategic adapter instance by wrapping its
--     public settlement callbacks and always delegates to the original callback first.
--   * CampaignState remains the strategic resource authority.

local Bootstrap = {}

local TAG = "[OMW][AirTasking.AARBootstrap]"

Bootstrap.SchemaVersion = "OMW-AIR-TASKING-AAR-BOOTSTRAP-2"

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
  requireFunction(aar.StrategicAdapter, "OnMaterialized", "spec.aarFacade.StrategicAdapter")
  requireFunction(aar.StrategicAdapter, "OnHandoff", "spec.aarFacade.StrategicAdapter")
  requireFunction(aar.StrategicAdapter, "OnLost", "spec.aarFacade.StrategicAdapter")
  return aar
end

local function attachObserver(bridge, adapter)
  if adapter.__OMW_AIR_TASKING_AAR_OBSERVER_ATTACHED == true then
    fail("AAR strategic adapter already has an Air Tasking observer")
  end

  local onMaterialized = adapter.OnMaterialized
  local onHandoff = adapter.OnHandoff
  local onLost = adapter.OnLost

  adapter.OnMaterialized = function(self, selection, runtime)
    local result = onMaterialized(self, selection, runtime)
    bridge:_OnMaterialized(selection, runtime, result)
    return result
  end

  adapter.OnHandoff = function(self, selection, runtime)
    local result = onHandoff(self, selection, runtime)
    bridge:_OnHandoff(selection, runtime)
    return result
  end

  adapter.OnLost = function(self, selection, runtime, reason)
    local result = onLost(self, selection, runtime, reason)
    bridge:_OnLost(selection, runtime, reason)
    return result
  end

  adapter.__OMW_AIR_TASKING_AAR_OBSERVER_ATTACHED = true
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

  -- Bridge.New currently supports the pre-bootstrap decorator path as well.  For
  -- additive attachment we provide a non-executed adapter-module sentinel; the
  -- running adapter instance is observed directly below and is never recreated.
  local unusedAdapterModule = {
    New = function()
      fail("additive attachment must not create a replacement AAR adapter")
    end,
  }

  local bridge = bridgeModule.New({
    controller = aar.Controller,
    baseAdapterModule = unusedAdapterModule,
    nextExecutionId = spec.nextExecutionId,
    logger = spec.logger,
  })

  attachObserver(bridge, aar.StrategicAdapter)

  local facade = {
    Status = "RUNNING",
    SchemaVersion = Bootstrap.SchemaVersion,
    Scope = "AIR_TASKING_AAR_ADDITIVE",
    AAR = aar,
    Bridge = bridge,
  }

  function facade.SubmitApprovedAAR(requestSpec)
    return bridge:SubmitApprovedAAR(requestSpec)
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

  OMW.AirTasking.AAR = facade

  log("RUNNING scope=AIR_TASKING_AAR_ADDITIVE existingAARBase=true adapterRecreated=false")
  return facade
end

return Bootstrap
