-- Operation Mountain Watch - external AWACS subsystem bootstrap.
--
-- This bootstrap composes the AWACS physical controller with the single
-- CampaignState authority. Al Dhafra remains an off-map strategic source.

local Bootstrap = {}

local TAG = "[OMW][AirOps.AWACS.Bootstrap]"
Bootstrap.SchemaVersion = "OMW-AIROPS-AWACS-FOUNDATION-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(container, name, label)
  if type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
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
  local offMapStock = requireTable(spec.offMapStrategicStock, "spec.offMapStrategicStock")
  requireFunction(initializer, "CreateStore", "spec.campaignStateInitializer")

  local created = initializer.CreateStore(campaignState, initialStock, offMapStock)
  return {
    store = created.store,
    campaignState = campaignState,
    restored = false,
    source = "AWACS_FOUNDATION_NEW",
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

  if OMW.AirOps.AWACS and OMW.AirOps.AWACS.Status == "RUNNING" then
    log("START_SKIPPED reason=ALREADY_RUNNING")
    return OMW.AirOps.AWACS
  end

  local adapterModule = requireTable(spec.adapterModule, "spec.adapterModule")
  local controller = requireTable(spec.controller, "spec.controller")
  requireFunction(adapterModule, "New", "spec.adapterModule")
  requireFunction(controller, "SetStrategicAdapter", "spec.controller")
  requireFunction(controller, "Start", "spec.controller")
  requireFunction(controller, "RequestEgress", "spec.controller")
  requireFunction(controller, "RequestRefuel", "spec.controller")
  requireFunction(controller, "GetRuntime", "spec.controller")
  requireFunction(controller, "GetServiceState", "spec.controller")
  requireFunction(controller, "GetConfig", "spec.controller")

  local campaignContext, createdContext = resolveCampaignContext(spec)
  local campaignState = campaignContext.campaignState or spec.campaignState
  requireTable(campaignState, "campaignState")

  local adapter = adapterModule.New(campaignContext.store, campaignState)
  if campaignContext.restored == true and type(adapter.ReconcileRestore) == "function" then
    local result = adapter:ReconcileRestore()
    log(string.format("RESTORE_RECONCILED count=%d losses=%d alreadyResolved=%d",
      result.reconciled or 0, result.preservedLosses or 0, result.alreadyResolved or 0))
  end

  controller.SetStrategicAdapter(adapter)
  local config = controller.GetConfig()
  local runtime = controller.Start()

  local facade = {
    Status = "RUNNING",
    SchemaVersion = Bootstrap.SchemaVersion,
    Controller = controller,
    StrategicAdapter = adapter,
    CampaignContext = campaignContext,
    CampaignContextCreated = createdContext,
    Config = config,
    InitialRuntime = runtime,
    Scope = "AWACS_TIMED_COVERAGE_FOUNDATION",
  }

  function facade.RequestEgress(reason)
    return controller.RequestEgress(reason)
  end

  function facade.RequestRefuel(rendezvousCoordinate, designatedTankerGroupName)
    return controller.RequestRefuel(rendezvousCoordinate, designatedTankerGroupName)
  end

  function facade.GetRuntime()
    return controller.GetRuntime()
  end

  function facade.GetServiceState()
    return controller.GetServiceState()
  end

  OMW.AirOps.AWACS = facade

  log(string.format(
    "RUNNING source=%s area=%s fir=%s callsign=%s frequencyMHz=%.3f serviceStartLocalSec=%d plannedAarLocalSec=%d serviceEndLocalSec=%d dcsValidated=false",
    config.sourceDomain, config.area, config.firFix, config.callsign, config.frequencyMHz,
    config.serviceStartLocalSec, config.plannedAarLocalSec, config.serviceEndLocalSec
  ))

  return facade
end

return Bootstrap