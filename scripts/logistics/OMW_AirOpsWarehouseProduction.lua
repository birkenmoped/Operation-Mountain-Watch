-- Operation Mountain Watch - permanent AirOps Warehouse production bootstrap.
--
-- Composes the accepted one-shot CampaignState -> MOOSE STORAGE mirror without
-- acceptance fixtures, test assertions or a production scheduler. CampaignState
-- remains the sole strategic resource authority.

local Production = {}

local TAG = "[OMW][Logistics.AirOpsWarehouseProduction]"
local READY_FLAG_NAME = "OMW_WAREHOUSE_READY"
local FUEL_NODE_IDS = {
  "BAGRAM",
  "JALALABAD",
  "KANDAHAR_MAIN",
  "KANDAHAR_HELI",
  "SALERNO",
  "SHINDAND_HELI",
  "TARINKOT",
}
local FUEL_RESOURCE_IDS_BY_NODE = {
  BAGRAM = { "FUEL_JP8" },
  JALALABAD = { "FUEL_JP8" },
  KANDAHAR_MAIN = { "FUEL_JP8", "FUEL_AVGAS" },
  KANDAHAR_HELI = { "FUEL_JP8" },
  SALERNO = { "FUEL_JP8" },
  SHINDAND_HELI = { "FUEL_JP8" },
  TARINKOT = { "FUEL_JP8" },
}

Production.SchemaVersion = "OMW-AIROPS-WAREHOUSE-PRODUCTION-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message), false)
  end
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

local function validateReadyFlagApi()
  if type(USERFLAG) ~= "table" or type(USERFLAG.New) ~= "function" then
    fail("MOOSE USERFLAG:New() is unavailable")
  end
end

local function validateCampaignContext(context)
  requireTable(context, "campaignContext")
  local store = requireTable(context.store, "campaignContext.store")
  requireFunction(store, "GetResource", "campaignContext.store")
  requireFunction(store, "GetFuelSnapshot", "campaignContext.store")
  requireTable(context.initialState, "campaignContext.initialState")
  requireTable(context.metadataByNode, "campaignContext.metadataByNode")
  return context
end

local function createCampaignContext(spec)
  local campaignState = requireTable(spec.campaignState, "spec.campaignState")
  local initializer = requireTable(spec.campaignStateInitializer, "spec.campaignStateInitializer")
  local initialStock = requireTable(spec.initialStock, "spec.initialStock")
  local initialJP8Stock = requireTable(spec.initialJP8Stock, "spec.initialJP8Stock")
  local fuelSupplement = requireTable(spec.fuelSupplement, "spec.fuelSupplement")
  local aarStrategicStock = requireTable(spec.aarStrategicStock, "spec.aarStrategicStock")
  requireFunction(initializer, "CreateStore", "spec.campaignStateInitializer")

  -- The Warehouse base starts before the AAR base. Therefore the single NEW
  -- CampaignState context contains the approved on-map JP-8 baseline, Kandahar
  -- AVGAS supplement and off-map AAR pools before any physical mirror is applied.
  local created = initializer.CreateStore(
    campaignState,
    initialStock,
    { initialJP8Stock, fuelSupplement, aarStrategicStock }
  )

  return {
    store = created.store,
    campaignState = campaignState,
    restored = false,
    source = "WAREHOUSE_BASE_NEW",
    initialState = created.initialState,
    metadataByNode = created.metadataByNode,
    initializerSchemaVersion = created.initializerSchemaVersion,
    initialStockSchemaVersion = created.initialStockSchemaVersion,
    additionalStockSchemaVersions = created.additionalStockSchemaVersions,
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

local function buildWarehouseSpec(spec, campaignContext)
  local fuelSyncModule = requireTable(spec.fuelSyncModule, "spec.fuelSyncModule")
  local fuelAdapter = requireTable(spec.fuelAdapter, "spec.fuelAdapter")
  local initializer = requireTable(spec.campaignStateInitializer, "spec.campaignStateInitializer")
  requireFunction(fuelSyncModule, "New", "spec.fuelSyncModule")
  requireTable(initializer.NodeAirbaseName, "spec.campaignStateInitializer.NodeAirbaseName")

  local mode = campaignContext.restored == true
    and spec.warehouseBootstrap.Mode.RESTORE
    or spec.warehouseBootstrap.Mode.NEW

  return {
    mode = mode,
    campaignContext = campaignContext,
    fuelSync = fuelSyncModule.New(campaignContext.store, fuelAdapter, {
      resourceIdsByNode = FUEL_RESOURCE_IDS_BY_NODE,
      airbaseNameByNode = initializer.NodeAirbaseName,
    }),
    fuelNodeIds = FUEL_NODE_IDS,
    dependencies = {
      storageInitializer = requireTable(spec.storageInitializer, "spec.storageInitializer"),
      technicalAvailabilityInitializer = requireTable(spec.technicalAvailabilityInitializer, "spec.technicalAvailabilityInitializer"),
      resourceManifest = requireTable(spec.resourceManifest, "spec.resourceManifest"),
      technicalAvailability = requireTable(spec.technicalAvailability, "spec.technicalAvailability").ByNode,
    },
  }
end

local function startInternal(spec, readyFlag)
  local warehouseBootstrap = requireTable(spec.warehouseBootstrap, "spec.warehouseBootstrap")
  requireFunction(warehouseBootstrap, "Apply", "spec.warehouseBootstrap")
  requireTable(warehouseBootstrap.Mode, "spec.warehouseBootstrap.Mode")

  OMW = OMW or {}
  OMW.AirOps = OMW.AirOps or {}

  if OMW.AirOps.Warehouse and OMW.AirOps.Warehouse.Status == "READY" then
    readyFlag:Set(1)
    if readyFlag:Get() ~= 1 then
      fail("Warehouse READY flag readback failed for existing production facade")
    end
    log("START_SKIPPED reason=ALREADY_READY readyFlag=1")
    return OMW.AirOps.Warehouse
  end

  local campaignContext, createdContext = resolveCampaignContext(spec)
  local warehouseSpec = buildWarehouseSpec(spec, campaignContext)
  local result = warehouseBootstrap.Apply(warehouseSpec)

  if type(result) ~= "table" or result.status ~= "READY" or result.airOpsStartAllowed ~= true then
    fail("Warehouse bootstrap did not reach READY")
  end

  readyFlag:Set(1)
  if readyFlag:Get() ~= 1 then
    fail("Warehouse READY flag readback failed")
  end

  local facade = {
    Status = "READY",
    SchemaVersion = Production.SchemaVersion,
    Scope = "PRODUCTION_WAREHOUSE_BASE",
    TestHarness = false,
    CampaignContext = campaignContext,
    CampaignContextCreated = createdContext,
    BootstrapResult = result,
    ReadyFlagName = READY_FLAG_NAME,
  }

  OMW.AirOps.Warehouse = facade

  log(string.format(
    "READY mode=%s campaignContextCreated=%s campaignStateAuthority=true reverseOverwrite=false scheduler=false readyFlag=1",
    tostring(warehouseSpec.mode),
    tostring(createdContext)
  ))

  return facade
end

function Production.Start(spec)
  requireTable(spec, "spec")
  validateReadyFlagApi()

  local readyFlag = USERFLAG:New(READY_FLAG_NAME)
  readyFlag:Set(0)

  local ok, result = pcall(startInternal, spec, readyFlag)
  if not ok then
    readyFlag:Set(0)
    if env and env.error then
      env.error(TAG .. " START_FAILED readyFlag=0 error=" .. tostring(result), false)
    end
    error(result, 0)
  end

  return result
end

return Production
