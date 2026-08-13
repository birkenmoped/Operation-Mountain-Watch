-- Operation Mountain Watch - AirOps Warehouse bootstrap acceptance harness.

local TEST_ID = "AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1"
local TAG = "[OMW-TEST][" .. TEST_ID .. "]"
local START_DELAY_SECONDS = 10
local FUEL_TOLERANCE_KG = 0.5
local KANDAHAR_NODE_ID = "KANDAHAR_MAIN"
local KANDAHAR_AIRBASE = "Kandahar"
local EXPECTED_AVGAS_KG = 20270.13583056

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function expect(condition, message)
  if not condition then fail(message) end
end

local function findNode(initialState, nodeId)
  for _, node in ipairs(initialState.nodes or {}) do
    if node.nodeId == nodeId then return node end
  end
  return nil
end

local function injectPreservedJp8Fixture(initialState, metadataByNode, jp8Kg)
  local node = findNode(initialState, KANDAHAR_NODE_ID)
  expect(node ~= nil, "Kandahar Main node missing from initial state")
  expect(node.resources.FUEL_JP8 == nil, "test fixture must not overwrite productive FUEL_JP8")
  expect(node.resources.FUEL_AVGAS ~= nil, "approved Kandahar AVGAS row missing")

  node.resources.FUEL_JP8 = { quantity = jp8Kg, unit = "kg" }
  metadataByNode[KANDAHAR_NODE_ID] = metadataByNode[KANDAHAR_NODE_ID] or {}
  metadataByNode[KANDAHAR_NODE_ID].FUEL_JP8 = {
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    thresholds = { target = jp8Kg, reorder = 0, critical = 0 },
    supplyParent = "OFF_MAP",
    mappingStatus = "TEST_PRESERVE_EXISTING_CLOSED_JP8",
  }
end

local function buildCampaignContext(existingJp8Kg)
  local initialState, metadataByNode = OMWAirOpsCampaignStateInitializer.BuildInitialState(
    OMWAirOpsInitialStock,
    OMWAirOpsInitialFuelSupplement
  )
  injectPreservedJp8Fixture(initialState, metadataByNode, existingJp8Kg)
  local kandahar = findNode(initialState, KANDAHAR_NODE_ID)
  expect(math.abs(kandahar.resources.FUEL_AVGAS.quantity - EXPECTED_AVGAS_KG) <= 0.000001, "Kandahar AVGAS initial quantity mismatch")
  expect(kandahar.resources.FUEL_AVGAS.unit == "kg", "Kandahar AVGAS unit mismatch")
  return {
    store = OMWCampaignState.New(initialState),
    initialState = initialState,
    metadataByNode = metadataByNode,
    initialStockSchemaVersion = OMWAirOpsInitialStock.SchemaVersion,
    additionalStockSchemaVersion = OMWAirOpsInitialFuelSupplement.SchemaVersion,
    initializerSchemaVersion = OMWAirOpsCampaignStateInitializer.SchemaVersion,
  }
end

local function buildSpec(campaignContext, mode)
  local fuelSync = OMWCampaignStateStorageSync.New(campaignContext.store, OMWStorageFuelAdapter)
  return {
    mode = mode,
    campaignContext = campaignContext,
    fuelSync = fuelSync,
    fuelNodeIds = { KANDAHAR_NODE_ID },
    dependencies = {
      storageInitializer = OMWAirOpsStorageInitializer,
      technicalAvailabilityInitializer = OMWAirOpsTechnicalAvailabilityInitializer,
      resourceManifest = OMWAirOpsResourceManifest,
      technicalAvailability = OMWAirOpsTechnicalAvailability.ByNode,
    },
  }
end

local function assertPlan(plan, phase)
  expect(plan.blockerCount == 0, phase .. " preflight contains blockers")
  expect(type(plan.strategicItemPlan) == "table", phase .. " strategic item plan missing")
  expect(type(plan.technicalPlan) == "table", phase .. " technical plan missing")
  expect(#(plan.fuelPlans or {}) == 1, phase .. " fuel plan count mismatch")
end

local function run()
  log("START mode=NEW_AND_RESTORE campaignStateAuthority=true closedStockRecalculation=false")

  local observedBefore = OMWStorageFuelAdapter.ReadNode(KANDAHAR_NODE_ID, KANDAHAR_AIRBASE)
  local existingJp8Kg = observedBefore.resourcesKg.FUEL_JP8
  expect(type(existingJp8Kg) == "number" and existingJp8Kg >= 0, "existing Kandahar JP8 observation invalid")
  log(string.format("JP8_PRESERVATION_FIXTURE observedKg=%.3f source=DCS_STORAGE testOnly=true strategicRecalculation=false", existingJp8Kg))

  local campaignContext = buildCampaignContext(existingJp8Kg)
  local newSpec = buildSpec(campaignContext, OMWAirOpsWarehouseBootstrap.Mode.NEW)
  local newPlan = OMWAirOpsWarehouseBootstrap.Plan(newSpec)
  assertPlan(newPlan, "NEW")
  log(string.format("NEW_PREFLIGHT_PASS strategicChanges=%d fuelChanges=%d technicalChanges=%d blockers=%d", newPlan.strategicItemChangeCount, newPlan.fuelChangeCount, newPlan.technicalChangeCount, newPlan.blockerCount))

  local newResult = OMWAirOpsWarehouseBootstrap.Apply(newSpec)
  expect(newResult.status == "READY", "NEW bootstrap did not reach READY")
  expect(newResult.airOpsStartAllowed == true, "NEW bootstrap did not open AirOps start gate")
  expect(newResult.strategicResult.verified == true, "strategic item readback failed")
  expect(newResult.technicalResult.verified == true, "technical availability readback failed")
  expect(#newResult.fuelResults == 1 and newResult.fuelResults[1].verified == true, "fuel readback failed")

  local observedAfter = OMWStorageFuelAdapter.ReadNode(KANDAHAR_NODE_ID, KANDAHAR_AIRBASE)
  expect(math.abs(observedAfter.resourcesKg.FUEL_AVGAS - EXPECTED_AVGAS_KG) <= FUEL_TOLERANCE_KG, "Kandahar AVGAS STORAGE readback mismatch")
  expect(math.abs(observedAfter.resourcesKg.FUEL_JP8 - existingJp8Kg) <= FUEL_TOLERANCE_KG, "closed Kandahar JP8 quantity changed")
  log(string.format("NEW_APPLY_PASS status=READY avgasKg=%.3f jp8PreservedKg=%.3f strategicEntries=%d technicalEntries=%d", observedAfter.resourcesKg.FUEL_AVGAS, observedAfter.resourcesKg.FUEL_JP8, #(newResult.strategicResult.results or {}), #(newResult.technicalResult.results or {})))

  local snapshot = campaignContext.store:ExportSnapshot()
  local restoreContext = {
    store = OMWCampaignState.Restore(snapshot),
    initialState = campaignContext.initialState,
    metadataByNode = campaignContext.metadataByNode,
    initialStockSchemaVersion = campaignContext.initialStockSchemaVersion,
    additionalStockSchemaVersion = campaignContext.additionalStockSchemaVersion,
    initializerSchemaVersion = campaignContext.initializerSchemaVersion,
  }
  local restoreSpec = buildSpec(restoreContext, OMWAirOpsWarehouseBootstrap.Mode.RESTORE)
  local restorePlan = OMWAirOpsWarehouseBootstrap.Plan(restoreSpec)
  assertPlan(restorePlan, "RESTORE")
  expect(restorePlan.strategicItemChangeCount == 0, "RESTORE strategic item mirror is not idempotent")
  expect(restorePlan.fuelChangeCount == 0, "RESTORE fuel mirror is not idempotent")
  expect(restorePlan.technicalChangeCount == 0, "RESTORE technical availability is not idempotent")
  local restoreResult = OMWAirOpsWarehouseBootstrap.Apply(restoreSpec)
  expect(restoreResult.status == "READY", "RESTORE bootstrap did not reach READY")
  expect(restoreResult.airOpsStartAllowed == true, "RESTORE bootstrap did not open AirOps start gate")
  log("RESTORE_PASS strategicChanges=0 fuelChanges=0 technicalChanges=0 initialReset=false status=READY")
  log("RESULT status=PASS campaignStateAuthority=true strategicItemMirror=true fuelMirror=true avgassupplement=true technicalAvailability=true reverseOverwrite=false productionScheduler=false newRestore=true airOpsStartGate=READY")
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then env.error(TAG .. " RESULT status=FAIL error=" .. tostring(err), false) end
end, {}, START_DELAY_SECONDS)
