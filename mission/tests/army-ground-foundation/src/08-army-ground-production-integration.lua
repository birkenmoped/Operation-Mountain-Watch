-- Operation Mountain Watch - ARMY Ground Foundation Acceptance 8.
-- Production-shaped CampaignState composition only; no MOOSE/DCS lifecycle logic.

local TEST_ID = "ARMY-GROUND-ACCEPTANCE-8-1"
local TAG = "OMW_GND_A8"

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(message)
  error(TAG .. " FAIL reason=" .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local function resource(store, nodeId, resourceId)
  return store:GetResource(nodeId, resourceId)
end

log("START testId=" .. TEST_ID)

local created = AirOpsCampaignStateInitializer.CreateStore(
  CampaignState,
  AirOpsInitialStock,
  { AARStrategicStock, GroundInitialStock }
)

expectEqual(created.initializerSchemaVersion, "OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-4", "INITIALIZER_SCHEMA")
expectEqual(created.additionalStockSchemaVersions[1], AARStrategicStock.SchemaVersion, "AAR_STOCK_SCHEMA")
expectEqual(created.additionalStockSchemaVersions[2], GroundInitialStock.SchemaVersion, "GROUND_STOCK_SCHEMA")

local fresh = GroundRuntimeIntegration.Attach({
  store = created.store,
  campaignState = CampaignState,
  adapterModule = GroundCampaignStateAdapter,
  groundInitialStock = GroundInitialStock,
  restored = false,
})

expectEqual(fresh.checkedResources, #GroundInitialStock.Rows, "GROUND_RESOURCE_COUNT")
expectEqual(resource(created.store, "JALALABAD", "AMMUNITION_HELLFIRE").available, 54, "AIROPS_RESOURCE_PRESERVED")
expectEqual(resource(created.store, "OFFMAP_MANAS", "AIRCRAFT_KC135").available, 16, "AAR_RESOURCE_PRESERVED")
expectEqual(resource(created.store, "GROUND_NODE_JALALABAD", "GROUND:GROUND_NODE_JALALABAD:VEHICLE").available, 48, "GROUND_JALALABAD_VEHICLE")
expectEqual(resource(created.store, "GROUND_NODE_JOYCE", "GROUND:GROUND_NODE_JOYCE:PERSONNEL").available, 180, "GROUND_JOYCE_PERSONNEL")
log("COMPOSITION_OK airOps=true aar=true groundResources=" .. tostring(fresh.checkedResources))

local joyceSpec = {
  runtimeId = "ARMY-GROUND-A8-JOYCE-1",
  nodeId = "GROUND_NODE_JOYCE",
  vehicleCount = 4,
  missionDemandId = "A8-JOYCE",
  perVehicleResources = {
    ["GROUND:GROUND_NODE_JOYCE:VEHICLE"] = 1,
    ["GROUND:GROUND_NODE_JOYCE:PERSONNEL"] = 3,
  },
}

local commitment, inserted = fresh.adapter:OnMaterialized(joyceSpec)
if not commitment or inserted ~= true then fail("JOYCE_MATERIALIZE") end
expectEqual(resource(created.store, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:VEHICLE").available, 16, "JOYCE_VEHICLE_AFTER_CONSUME")
expectEqual(resource(created.store, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:PERSONNEL").available, 168, "JOYCE_PERSONNEL_AFTER_CONSUME")

local loss = fresh.adapter:OnLost(joyceSpec.runtimeId, 1, {
  ["GROUND:GROUND_NODE_JOYCE:VEHICLE"] = "GROUND:GROUND_NODE_JOYCE:VEHICLE_LOST",
  ["GROUND:GROUND_NODE_JOYCE:PERSONNEL"] = "GROUND:GROUND_NODE_JOYCE:PERSONNEL_LOST",
})
expectEqual(loss["GROUND:GROUND_NODE_JOYCE:VEHICLE"].quantity, 1, "JOYCE_VEHICLE_LOSS")
expectEqual(loss["GROUND:GROUND_NODE_JOYCE:PERSONNEL"].quantity, 3, "JOYCE_PERSONNEL_LOSS")

local returned = fresh.adapter:OnReturned(joyceSpec.runtimeId, 3)
local returnedDuplicate = fresh.adapter:OnReturned(joyceSpec.runtimeId, 3)
expectEqual(returned["GROUND:GROUND_NODE_JOYCE:VEHICLE"].inserted, true, "JOYCE_RETURN_INSERT")
expectEqual(returnedDuplicate["GROUND:GROUND_NODE_JOYCE:VEHICLE"].inserted, false, "JOYCE_RETURN_IDEMPOTENT")
expectEqual(resource(created.store, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:VEHICLE").available, 19, "JOYCE_VEHICLE_FINAL")
expectEqual(resource(created.store, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:PERSONNEL").available, 177, "JOYCE_PERSONNEL_FINAL")
expectEqual(resource(created.store, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:VEHICLE_LOST").available, 1, "JOYCE_VEHICLE_LOSS_AUDIT")
expectEqual(resource(created.store, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:PERSONNEL_LOST").available, 3, "JOYCE_PERSONNEL_LOSS_AUDIT")
log("SETTLEMENT_OK site=JOYCE returnedVehicle=3 returnedPersonnel=9 lostVehicle=1 lostPersonnel=3")

local bostickSpec = {
  runtimeId = "ARMY-GROUND-A8-BOSTICK-OPEN-1",
  nodeId = "GROUND_NODE_BOSTICK",
  vehicleCount = 4,
  missionDemandId = "A8-BOSTICK-OPEN",
  perVehicleResources = {
    ["GROUND:GROUND_NODE_BOSTICK:VEHICLE"] = 1,
    ["GROUND:GROUND_NODE_BOSTICK:PERSONNEL"] = 3,
  },
}

local openCommitment, openInserted = fresh.adapter:OnMaterialized(bostickSpec)
if not openCommitment or openInserted ~= true then fail("BOSTICK_OPEN_MATERIALIZE") end
expectEqual(resource(created.store, bostickSpec.nodeId, "GROUND:GROUND_NODE_BOSTICK:VEHICLE").available, 22, "BOSTICK_VEHICLE_OPEN")
expectEqual(resource(created.store, bostickSpec.nodeId, "GROUND:GROUND_NODE_BOSTICK:PERSONNEL").available, 208, "BOSTICK_PERSONNEL_OPEN")

local restoredStore = CampaignState.Restore(created.store:ExportSnapshot())
local restored = GroundRuntimeIntegration.Attach({
  store = restoredStore,
  campaignState = CampaignState,
  adapterModule = GroundCampaignStateAdapter,
  groundInitialStock = GroundInitialStock,
  restored = true,
})

expectEqual(restored.reconciliation.reconciled, 2, "RESTART_RECONCILED_RESOURCES")
expectEqual(resource(restoredStore, bostickSpec.nodeId, "GROUND:GROUND_NODE_BOSTICK:VEHICLE").available, 26, "BOSTICK_VEHICLE_RESTORED")
expectEqual(resource(restoredStore, bostickSpec.nodeId, "GROUND:GROUND_NODE_BOSTICK:PERSONNEL").available, 220, "BOSTICK_PERSONNEL_RESTORED")
expectEqual(resource(restoredStore, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:VEHICLE").available, 19, "JOYCE_LOSS_PRESERVED_AFTER_RESTART")
expectEqual(resource(restoredStore, joyceSpec.nodeId, "GROUND:GROUND_NODE_JOYCE:VEHICLE_LOST").available, 1, "JOYCE_LOSS_AUDIT_PRESERVED_AFTER_RESTART")

local restoredAgain = GroundRuntimeIntegration.Attach({
  store = restoredStore,
  campaignState = CampaignState,
  adapterModule = GroundCampaignStateAdapter,
  groundInitialStock = GroundInitialStock,
  restored = true,
})
expectEqual(restoredAgain.reconciliation.reconciled, 0, "RESTART_IDEMPOTENT")
expectEqual(resource(restoredStore, bostickSpec.nodeId, "GROUND:GROUND_NODE_BOSTICK:VEHICLE").available, 26, "BOSTICK_VEHICLE_RESTART_IDEMPOTENT")
expectEqual(resource(restoredStore, bostickSpec.nodeId, "GROUND:GROUND_NODE_BOSTICK:PERSONNEL").available, 220, "BOSTICK_PERSONNEL_RESTART_IDEMPOTENT")
log("RESTART_OK runtimeId=" .. bostickSpec.runtimeId .. " vehicle=4 personnel=12 exactlyOnce=true")

log("RUNTIME_PASS testId=" .. TEST_ID .. " singleCampaignState=true productionBaselineMutation=false mizMutation=false")
