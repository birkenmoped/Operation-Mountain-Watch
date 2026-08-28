-- Operation Mountain Watch - central AirOps Warehouse/resource bootstrap.
--
-- Coordinates already approved CampaignState/STORAGE adapters. It does not
-- calculate strategic stock, own resources, add schedulers, or implement a
-- reverse DCS-to-CampaignState authority path.

local WarehouseBootstrap = {}

local TAG = "[OMW][Logistics.AirOpsWarehouseBootstrap]"

WarehouseBootstrap.SchemaVersion = "OMW-AIROPS-WAREHOUSE-BOOTSTRAP-1"
WarehouseBootstrap.Mode = { NEW = "NEW", RESTORE = "RESTORE" }

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
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

local function validateDependencies(dependencies)
  requireTable(dependencies, "dependencies")
  local strategic = requireTable(dependencies.storageInitializer, "dependencies.storageInitializer")
  requireFunction(strategic, "Plan", "dependencies.storageInitializer")
  requireFunction(strategic, "Apply", "dependencies.storageInitializer")
  local technical = requireTable(dependencies.technicalAvailabilityInitializer, "dependencies.technicalAvailabilityInitializer")
  requireFunction(technical, "Plan", "dependencies.technicalAvailabilityInitializer")
  requireFunction(technical, "Apply", "dependencies.technicalAvailabilityInitializer")
  requireTable(dependencies.resourceManifest, "dependencies.resourceManifest")
  requireTable(dependencies.technicalAvailability, "dependencies.technicalAvailability")
end

local function validateCampaignContext(campaignContext)
  requireTable(campaignContext, "campaignContext")
  local store = requireTable(campaignContext.store, "campaignContext.store")
  requireFunction(store, "GetResource", "campaignContext.store")
  requireFunction(store, "GetFuelSnapshot", "campaignContext.store")
end

local function validateFuelSync(fuelSync)
  requireTable(fuelSync, "fuelSync")
  requireFunction(fuelSync, "PlanNode", "fuelSync")
  requireFunction(fuelSync, "ApplyNode", "fuelSync")
end

local function copyFuelNodeIds(fuelNodeIds)
  requireTable(fuelNodeIds, "fuelNodeIds")
  local result, seen = {}, {}
  for index, nodeId in ipairs(fuelNodeIds) do
    if type(nodeId) ~= "string" or nodeId == "" then
      fail("fuelNodeIds requires non-empty node IDs index=" .. tostring(index))
    end
    if seen[nodeId] then
      fail("duplicate fuel nodeId=" .. tostring(nodeId))
    end
    seen[nodeId] = true
    result[#result + 1] = nodeId
  end
  table.sort(result)
  return result
end

local function planCount(plan, field)
  if type(plan) ~= "table" then return 0 end
  return tonumber(plan[field]) or 0
end

function WarehouseBootstrap.Plan(spec)
  requireTable(spec, "spec")
  validateDependencies(spec.dependencies)
  validateCampaignContext(spec.campaignContext)
  validateFuelSync(spec.fuelSync)

  local mode = spec.mode or WarehouseBootstrap.Mode.NEW
  if mode ~= WarehouseBootstrap.Mode.NEW and mode ~= WarehouseBootstrap.Mode.RESTORE then
    fail("unsupported mode=" .. tostring(mode))
  end

  local fuelNodeIds = copyFuelNodeIds(spec.fuelNodeIds)
  local dependencies = spec.dependencies
  local strategicItemPlan = dependencies.storageInitializer.Plan(spec.campaignContext, dependencies.resourceManifest)
  local technicalPlan = dependencies.technicalAvailabilityInitializer.Plan(spec.campaignContext, dependencies.resourceManifest, dependencies.technicalAvailability)

  local fuelPlans, fuelChangeCount = {}, 0
  for _, nodeId in ipairs(fuelNodeIds) do
    local fuelPlan = spec.fuelSync:PlanNode(nodeId)
    fuelPlans[#fuelPlans + 1] = fuelPlan
    fuelChangeCount = fuelChangeCount + planCount(fuelPlan, "changeCount")
  end

  return {
    schemaVersion = WarehouseBootstrap.SchemaVersion,
    mode = mode,
    fuelNodeIds = fuelNodeIds,
    strategicItemPlan = strategicItemPlan,
    technicalPlan = technicalPlan,
    fuelPlans = fuelPlans,
    strategicItemChangeCount = planCount(strategicItemPlan, "changeCount"),
    technicalChangeCount = planCount(technicalPlan, "changeCount"),
    fuelChangeCount = fuelChangeCount,
    blockerCount = planCount(strategicItemPlan, "blockerCount") + planCount(technicalPlan, "blockerCount"),
  }
end

function WarehouseBootstrap.Apply(spec)
  local plan = WarehouseBootstrap.Plan(spec)
  if plan.blockerCount > 0 then
    fail("warehouse initialization blocked during preflight blockerCount=" .. tostring(plan.blockerCount))
  end

  local strategicResult = spec.dependencies.storageInitializer.Apply(spec.campaignContext, spec.dependencies.resourceManifest)
  local fuelResults = {}
  for _, nodeId in ipairs(plan.fuelNodeIds) do
    fuelResults[#fuelResults + 1] = spec.fuelSync:ApplyNode(nodeId)
  end
  local technicalResult = spec.dependencies.technicalAvailabilityInitializer.Apply(spec.campaignContext, spec.dependencies.resourceManifest, spec.dependencies.technicalAvailability)

  if strategicResult.verified ~= true then fail("strategic STORAGE item initialization did not verify") end
  if technicalResult.verified ~= true then fail("technical STORAGE availability initialization did not verify") end
  for index, result in ipairs(fuelResults) do
    if type(result) ~= "table" or result.verified ~= true then
      fail("fuel STORAGE initialization did not verify index=" .. tostring(index))
    end
  end

  return {
    schemaVersion = WarehouseBootstrap.SchemaVersion,
    status = "READY",
    mode = plan.mode,
    plan = plan,
    strategicResult = strategicResult,
    fuelResults = fuelResults,
    technicalResult = technicalResult,
    campaignStateAuthority = true,
    reverseOverwrite = false,
    scheduler = false,
    airOpsStartAllowed = true,
  }
end

return WarehouseBootstrap
