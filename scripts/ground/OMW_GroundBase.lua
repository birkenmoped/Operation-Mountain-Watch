-- Operation Mountain Watch - production ARMY Ground base facade.
--
-- This module packages the already accepted strategic Ground foundation behind
-- one stable production entry point. It does not create CampaignState, does not
-- own strategic resources, and contains no MOOSE or DCS calls.
--
-- The caller must provide the single authoritative CampaignState store and the
-- CampaignState module. The embedded Ground initial stock, settlement adapter,
-- local-rearm settlement adapter and runtime integration modules remain the
-- accepted implementation sources.

local GroundBase = {}

local TAG = "[OMW][Ground.Base]"

GroundBase.SchemaVersion = "OMW-GROUND-PRODUCTION-BASE-2"

local GroundInitialStock = nil
local GroundCampaignStateAdapter = nil
local GroundAmmoRearmAdapter = nil
local GroundRuntimeIntegration = nil
local activeContext = nil

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

function GroundBase.Configure(modules)
  requireTable(modules, "modules")
  GroundInitialStock = requireTable(modules.groundInitialStock, "modules.groundInitialStock")
  GroundCampaignStateAdapter = requireTable(modules.groundCampaignStateAdapter, "modules.groundCampaignStateAdapter")
  GroundAmmoRearmAdapter = requireTable(modules.groundAmmoRearmAdapter, "modules.groundAmmoRearmAdapter")
  GroundRuntimeIntegration = requireTable(modules.groundRuntimeIntegration, "modules.groundRuntimeIntegration")

  if type(GroundRuntimeIntegration.Attach) ~= "function" then
    fail("groundRuntimeIntegration.Attach() is required")
  end
  if type(GroundCampaignStateAdapter.New) ~= "function" then
    fail("groundCampaignStateAdapter.New() is required")
  end
  if type(GroundAmmoRearmAdapter.ReconcileRestore) ~= "function" then
    fail("groundAmmoRearmAdapter.ReconcileRestore() is required")
  end
  if type(GroundInitialStock.Rows) ~= "table" then
    fail("groundInitialStock.Rows is required")
  end

  return GroundBase
end

function GroundBase.Attach(spec)
  requireTable(spec, "spec")
  if not GroundInitialStock or not GroundCampaignStateAdapter or not GroundAmmoRearmAdapter or not GroundRuntimeIntegration then
    fail("Configure() must be called before Attach()")
  end

  activeContext = GroundRuntimeIntegration.Attach({
    store = spec.store,
    campaignState = spec.campaignState,
    adapterModule = GroundCampaignStateAdapter,
    ammoRearmAdapterModule = GroundAmmoRearmAdapter,
    groundInitialStock = GroundInitialStock,
    restored = spec.restored == true,
  })

  return activeContext
end

function GroundBase.GetContext()
  return activeContext
end

function GroundBase.GetInitialStock()
  if not GroundInitialStock then
    fail("Configure() must be called before GetInitialStock()")
  end
  return GroundInitialStock
end

function GroundBase.GetConfig()
  return {
    schemaVersion = GroundBase.SchemaVersion,
    configured = GroundInitialStock ~= nil
      and GroundCampaignStateAdapter ~= nil
      and GroundAmmoRearmAdapter ~= nil
      and GroundRuntimeIntegration ~= nil,
    attached = activeContext ~= nil,
    groundInitialStockSchemaVersion = GroundInitialStock and GroundInitialStock.SchemaVersion or nil,
    groundAmmoRearmAdapterSchemaVersion = GroundAmmoRearmAdapter and GroundAmmoRearmAdapter.SchemaVersion or nil,
    groundRuntimeIntegrationSchemaVersion = GroundRuntimeIntegration and GroundRuntimeIntegration.SchemaVersion or nil,
  }
end

return GroundBase