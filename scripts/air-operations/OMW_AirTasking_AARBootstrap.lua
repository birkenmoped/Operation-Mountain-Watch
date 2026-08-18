-- Operation Mountain Watch - Air Tasking composition wrapper for the accepted AAR production bootstrap.
--
-- This module does not replace the accepted AAR controller, runtime integration,
-- CampaignState adapter, or bootstrap. It creates the Air Tasking correlation
-- bridge first, decorates the existing AAR adapter, and then delegates startup
-- to the accepted AAR production bootstrap.

local Bootstrap = {}

local TAG = "[OMW][AirTasking.AARBootstrap]"

Bootstrap.SchemaVersion = "OMW-AIR-TASKING-AAR-BOOTSTRAP-1"

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

function Bootstrap.Start(spec)
  spec = requireTable(spec, "spec")

  OMW = OMW or {}
  OMW.AirTasking = OMW.AirTasking or {}

  if OMW.AirTasking.AAR and OMW.AirTasking.AAR.Status == "RUNNING" then
    log("START_SKIPPED reason=ALREADY_RUNNING")
    return OMW.AirTasking.AAR
  end

  local bridgeModule = requireTable(spec.bridgeModule, "spec.bridgeModule")
  local aarBootstrap = requireTable(spec.aarBootstrap, "spec.aarBootstrap")
  local controller = requireTable(spec.controller, "spec.controller")
  local baseAdapterModule = requireTable(spec.baseAdapterModule, "spec.baseAdapterModule")
  requireFunction(bridgeModule, "New", "spec.bridgeModule")
  requireFunction(aarBootstrap, "Start", "spec.aarBootstrap")
  requireFunction(baseAdapterModule, "New", "spec.baseAdapterModule")
  if type(spec.nextExecutionId) ~= "function" then fail("spec.nextExecutionId must be a function") end

  local bridge = bridgeModule.New({
    controller = controller,
    baseAdapterModule = baseAdapterModule,
    nextExecutionId = spec.nextExecutionId,
    logger = spec.logger,
  })

  local wrappedAdapterModule = bridge:GetAdapterModule()

  local aar = aarBootstrap.Start({
    campaignState = spec.campaignState,
    initialStock = spec.initialStock,
    aarStrategicStock = spec.aarStrategicStock,
    campaignStateInitializer = spec.campaignStateInitializer,
    campaignContext = spec.campaignContext,
    adapterModule = wrappedAdapterModule,
    runtimeIntegration = spec.runtimeIntegration,
    controller = controller,
  })

  local facade = {
    Status = "RUNNING",
    SchemaVersion = Bootstrap.SchemaVersion,
    Scope = "AIR_TASKING_AAR_VERTICAL",
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

  log("RUNNING scope=AIR_TASKING_AAR_VERTICAL acceptedAARBootstrap=true decoratedAdapter=true")
  return facade
end

return Bootstrap
