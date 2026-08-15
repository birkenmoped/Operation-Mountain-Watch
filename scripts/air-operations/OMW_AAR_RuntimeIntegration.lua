-- Operation Mountain Watch - production AAR CampaignState composition boundary.
--
-- The caller owns CampaignState NEW/RESTORE creation. This module only binds
-- that single authoritative store to the AAR strategic adapter and controller.
-- It deliberately creates no DCS airbase, MOOSE WAREHOUSE or AIRWING.

local Integration = {}

local TAG = "[OMW][AAR.RuntimeIntegration]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

function Integration.Attach(spec)
  requireTable(spec, "spec")

  local store = requireTable(spec.store, "store")
  local campaignState = requireTable(spec.campaignState, "campaignState")
  local adapterModule = requireTable(spec.adapterModule, "adapterModule")
  local controller = requireTable(spec.controller, "controller")

  if type(adapterModule.New) ~= "function" then
    fail("adapterModule.New is required")
  end
  if type(controller.SetStrategicAdapter) ~= "function" then
    fail("controller.SetStrategicAdapter is required")
  end

  local adapter = adapterModule.New(store, campaignState)
  local reconciliation = nil
  if spec.restored == true then
    if type(adapter.ReconcileRestore) ~= "function" then
      fail("adapter.ReconcileRestore is required for restored CampaignState")
    end
    reconciliation = adapter:ReconcileRestore()
  end

  -- OMW.AAR exposes SetStrategicAdapter as a module function, not an instance method.
  controller.SetStrategicAdapter(adapter)

  -- Continuous core coverage is a controller capability. Minimal capture controllers
  -- used by pure restore checks intentionally omit it and therefore do not start DCS activity.
  if type(controller.StartContinuousCoreCoverage) == "function" then
    controller.StartContinuousCoreCoverage()
  end

  return {
    store = store,
    adapter = adapter,
    controller = controller,
    restored = spec.restored == true,
    reconciliation = reconciliation,
  }
end

return Integration
