-- Operation Mountain Watch - production AAR subsystem bootstrap.
--
-- This bootstrap composes the accepted AAR controller with the single
-- CampaignState authority. It contains no test harness, no artificial FuelLow,
-- no artificial loss injection and no accelerated relief timing.

local Bootstrap = {}

local TAG = "[OMW][AirOps.AAR.Bootstrap]"

Bootstrap.SchemaVersion = "OMW-AIROPS-AAR-BASE-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(container, name, label)
  if type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
end

local function validateController(controller)
  requireTable(controller, "controller")
  requireFunction(controller, "SetStrategicAdapter", "controller")
  requireFunction(controller, "StartContinuousCoreCoverage", "controller")
  requireFunction(controller, "SubmitDemand", "controller")
  requireFunction(controller, "EndDemand", "controller")
  requireFunction(controller, "GetConfig", "controller")
end

local function validateCampaignContext(context)
  requireTable(context, "campaignContext")
  local store = requireTable(context.store, "campaignContext.store")
  requireFunction(store, "GetResource", "campaignContext.store")
  requireFunction(store, "ReserveResource", "campaignContext.store")
  requireFunction(store, "Consume", "campaignContext.store")
  requireFunction(store, "CreditResourceOnce", "campaignContext.store")
  requireFunction(store, "ExportSnapshot", "campaignContext.store")
  return context
end

local function createCampaignContext(spec)
  local campaignState = requireTable(spec.campaignState, "spec.campaignState")
  local initializer = requireTable(spec.campaignStateInitializer, "spec.campaignStateInitializer")
  local initialStock = requireTable(spec.initialStock, "spec.initialStock")
  local aarStrategicStock = requireTable(spec.aarStrategicStock, "spec.aarStrategicStock")
  requireFunction(initializer, "CreateStore", "spec.campaignStateInitializer")

  local created = initializer.CreateStore(campaignState, initialStock, aarStrategicStock)
  return {
    store = created.store,
    campaignState = campaignState,
    restored = false,
    source = "AAR_BASE_NEW",
    initialState = created.initialState,
    metadataByNode = created.metadataByNode,
    initializerSchemaVersion = created.initializerSchemaVersion,
    initialStockSchemaVersion = created.initialStockSchemaVersion,
    additionalStockSchemaVersion = created.additionalStockSchemaVersion,
  }
end

local function resolveCampaignContext(spec)
  OMW = OMW or {}
  OMW.AirOps = OMW.AirOps or {}

  if spec.campaignContext ~= nil then
    local context = validateCampaignContext(spec.campaignContext)
    if OMW.AirOps.CampaignContext and OMW.AirOps.CampaignContext.store ~= context.store then
      fail("a different OMW.AirOps.CampaignContext is already registered")
    end
    OMW.AirOps.CampaignContext = context
    return context, false
  end

  if OMW.AirOps.CampaignContext ~= nil then
    return validateCampaignContext(OMW.AirOps.CampaignContext), false
  end

  local context = createCampaignContext(spec)
  OMW.AirOps.CampaignContext = context
  return context, true
end

function Bootstrap.Start(spec)
  requireTable(spec, "spec")

  OMW = OMW or {}
  OMW.AirOps = OMW.AirOps or {}

  if OMW.AirOps.AAR and OMW.AirOps.AAR.Status == "RUNNING" then
    log("START_SKIPPED reason=ALREADY_RUNNING")
    return OMW.AirOps.AAR
  end

  local adapterModule = requireTable(spec.adapterModule, "spec.adapterModule")
  local runtimeIntegration = requireTable(spec.runtimeIntegration, "spec.runtimeIntegration")
  local controller = requireTable(spec.controller, "spec.controller")
  requireFunction(adapterModule, "New", "spec.adapterModule")
  requireFunction(runtimeIntegration, "Attach", "spec.runtimeIntegration")
  validateController(controller)

  local campaignContext, createdContext = resolveCampaignContext(spec)
  local campaignState = campaignContext.campaignState or spec.campaignState
  requireTable(campaignState, "campaignState")

  local integration = runtimeIntegration.Attach({
    store = campaignContext.store,
    campaignState = campaignState,
    adapterModule = adapterModule,
    controller = controller,
    restored = campaignContext.restored == true,
  })

  local config = controller.GetConfig()
  if config.standardTrackCount ~= 4 or config.reserveTrackCount ~= 2 then
    fail("unexpected AAR availability baseline")
  end
  if config.reserveDemandDriven ~= true or config.continuousAvailabilityPolicy ~= true then
    fail("unexpected AAR standard/reserve policy")
  end

  local facade = {
    Status = "RUNNING",
    SchemaVersion = Bootstrap.SchemaVersion,
    Controller = controller,
    Integration = integration,
    StrategicAdapter = integration.adapter,
    CampaignContext = campaignContext,
    Config = config,
    CampaignContextCreated = createdContext,
    Scope = "PRODUCTION_AAR_BASE",
  }

  function facade.SubmitDemand(demand)
    return controller.SubmitDemand(demand)
  end

  function facade.EndDemand(demand, terminalStatus)
    return controller.EndDemand(demand, terminalStatus)
  end

  function facade.GetStation(area, receiverProfile)
    return controller.GetStation(area, receiverProfile)
  end

  function facade.GetRuntimeCounts()
    return controller.GetRuntimeCounts()
  end

  OMW.AirOps.AAR = facade

  log(string.format(
    "RUNNING standardTracks=%d reserveTracks=%d reserveDemandDriven=%s stationCycleSec=%d fuelLowReal=true lossReplacementReal=true testHarness=false campaignContextCreated=%s",
    config.standardTrackCount,
    config.reserveTrackCount,
    tostring(config.reserveDemandDriven),
    config.stationCycleSec,
    tostring(createdContext)
  ))

  return facade
end

return Bootstrap
