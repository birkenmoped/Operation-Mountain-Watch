-- Operation Mountain Watch - ARMY Ground Foundation Acceptance 9.
-- Fortress/Honaker six-node production-stock gate only; no new MOOSE/DCS lifecycle logic.

local TEST_ID = "ARMY-GROUND-ACCEPTANCE-9-1"
local TAG = "OMW_GND_A9"

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

local function expectNode(store, nodeId, personnel, vehicle, supply, ammo, fuel)
  expectEqual(resource(store, nodeId, "GROUND:" .. nodeId .. ":PERSONNEL").available, personnel, nodeId .. "_PERSONNEL")
  expectEqual(resource(store, nodeId, "GROUND:" .. nodeId .. ":VEHICLE").available, vehicle, nodeId .. "_VEHICLE")
  expectEqual(resource(store, nodeId, "GROUND:" .. nodeId .. ":SUPPLY").available, supply, nodeId .. "_SUPPLY")
  expectEqual(resource(store, nodeId, "GROUND:" .. nodeId .. ":AMMO").available, ammo, nodeId .. "_AMMO")
  expectEqual(resource(store, nodeId, "GROUND:" .. nodeId .. ":FUEL").available, fuel, nodeId .. "_FUEL")
end

log("START testId=" .. TEST_ID)

local created = AirOpsCampaignStateInitializer.CreateStore(
  CampaignState,
  AirOpsInitialStock,
  { AARStrategicStock, GroundInitialStock }
)

local fresh = GroundRuntimeIntegration.Attach({
  store = created.store,
  campaignState = CampaignState,
  adapterModule = GroundCampaignStateAdapter,
  groundInitialStock = GroundInitialStock,
  restored = false,
})

expectEqual(fresh.checkedResources, 42, "GROUND_RESOURCE_COUNT")
expectEqual(resource(created.store, "JALALABAD", "AMMUNITION_HELLFIRE").available, 54, "AIROPS_RESOURCE_PRESERVED")
expectEqual(resource(created.store, "OFFMAP_MANAS", "AIRCRAFT_KC135").available, 16, "AAR_RESOURCE_PRESERVED")

expectNode(created.store, "GROUND_NODE_JALALABAD", 480, 48, 120, 100, 120)
expectNode(created.store, "GROUND_NODE_FORTRESS", 160, 18, 44, 48, 40)
expectNode(created.store, "GROUND_NODE_JOYCE", 180, 20, 48, 44, 40)
expectNode(created.store, "GROUND_NODE_WRIGHT", 120, 22, 36, 30, 36)
expectNode(created.store, "GROUND_NODE_HONAKER", 120, 18, 40, 40, 36)
expectNode(created.store, "GROUND_NODE_BOSTICK", 220, 26, 56, 52, 48)
log("SIX_NODE_STOCK_OK fortressVehicle=18 fortressPersonnel=160 honakerVehicle=18 honakerPersonnel=120")

local fortressSpec = {
  runtimeId = "ARMY-GROUND-A9-FORTRESS-1",
  nodeId = "GROUND_NODE_FORTRESS",
  vehicleCount = 4,
  missionDemandId = "A9-FORTRESS",
  perVehicleResources = {
    ["GROUND:GROUND_NODE_FORTRESS:VEHICLE"] = 1,
    ["GROUND:GROUND_NODE_FORTRESS:PERSONNEL"] = 3,
  },
}

local fortressCommitment, fortressInserted = fresh.adapter:OnMaterialized(fortressSpec)
if not fortressCommitment or fortressInserted ~= true then fail("FORTRESS_MATERIALIZE") end
expectEqual(resource(created.store, fortressSpec.nodeId, "GROUND:GROUND_NODE_FORTRESS:VEHICLE").available, 14, "FORTRESS_VEHICLE_CONSUMED")
expectEqual(resource(created.store, fortressSpec.nodeId, "GROUND:GROUND_NODE_FORTRESS:PERSONNEL").available, 148, "FORTRESS_PERSONNEL_CONSUMED")
local fortressReturned = fresh.adapter:OnReturned(fortressSpec.runtimeId, 4)
local fortressReturnedDuplicate = fresh.adapter:OnReturned(fortressSpec.runtimeId, 4)
expectEqual(fortressReturned["GROUND:GROUND_NODE_FORTRESS:VEHICLE"].inserted, true, "FORTRESS_RETURN_INSERT")
expectEqual(fortressReturnedDuplicate["GROUND:GROUND_NODE_FORTRESS:VEHICLE"].inserted, false, "FORTRESS_RETURN_IDEMPOTENT")
expectEqual(resource(created.store, fortressSpec.nodeId, "GROUND:GROUND_NODE_FORTRESS:VEHICLE").available, 18, "FORTRESS_VEHICLE_FINAL")
expectEqual(resource(created.store, fortressSpec.nodeId, "GROUND:GROUND_NODE_FORTRESS:PERSONNEL").available, 160, "FORTRESS_PERSONNEL_FINAL")
log("FORTRESS_SETTLEMENT_OK returnedVehicle=4 returnedPersonnel=12 exactlyOnce=true")

local honakerSpec = {
  runtimeId = "ARMY-GROUND-A9-HONAKER-1",
  nodeId = "GROUND_NODE_HONAKER",
  vehicleCount = 4,
  missionDemandId = "A9-HONAKER",
  perVehicleResources = {
    ["GROUND:GROUND_NODE_HONAKER:VEHICLE"] = 1,
    ["GROUND:GROUND_NODE_HONAKER:PERSONNEL"] = 3,
  },
}

local honakerCommitment, honakerInserted = fresh.adapter:OnMaterialized(honakerSpec)
if not honakerCommitment or honakerInserted ~= true then fail("HONAKER_MATERIALIZE") end
expectEqual(resource(created.store, honakerSpec.nodeId, "GROUND:GROUND_NODE_HONAKER:VEHICLE").available, 14, "HONAKER_VEHICLE_CONSUMED")
expectEqual(resource(created.store, honakerSpec.nodeId, "GROUND:GROUND_NODE_HONAKER:PERSONNEL").available, 108, "HONAKER_PERSONNEL_CONSUMED")

local honakerLoss = fresh.adapter:OnLost(honakerSpec.runtimeId, 1, {
  ["GROUND:GROUND_NODE_HONAKER:VEHICLE"] = "GROUND:GROUND_NODE_HONAKER:VEHICLE_LOST",
  ["GROUND:GROUND_NODE_HONAKER:PERSONNEL"] = "GROUND:GROUND_NODE_HONAKER:PERSONNEL_LOST",
})
expectEqual(honakerLoss["GROUND:GROUND_NODE_HONAKER:VEHICLE"].quantity, 1, "HONAKER_VEHICLE_LOSS")
expectEqual(honakerLoss["GROUND:GROUND_NODE_HONAKER:PERSONNEL"].quantity, 3, "HONAKER_PERSONNEL_LOSS")

local honakerReturned = fresh.adapter:OnReturned(honakerSpec.runtimeId, 3)
local honakerReturnedDuplicate = fresh.adapter:OnReturned(honakerSpec.runtimeId, 3)
expectEqual(honakerReturned["GROUND:GROUND_NODE_HONAKER:VEHICLE"].inserted, true, "HONAKER_RETURN_INSERT")
expectEqual(honakerReturnedDuplicate["GROUND:GROUND_NODE_HONAKER:VEHICLE"].inserted, false, "HONAKER_RETURN_IDEMPOTENT")
expectEqual(resource(created.store, honakerSpec.nodeId, "GROUND:GROUND_NODE_HONAKER:VEHICLE").available, 17, "HONAKER_VEHICLE_FINAL")
expectEqual(resource(created.store, honakerSpec.nodeId, "GROUND:GROUND_NODE_HONAKER:PERSONNEL").available, 117, "HONAKER_PERSONNEL_FINAL")
expectEqual(resource(created.store, honakerSpec.nodeId, "GROUND:GROUND_NODE_HONAKER:VEHICLE_LOST").available, 1, "HONAKER_VEHICLE_LOSS_AUDIT")
expectEqual(resource(created.store, honakerSpec.nodeId, "GROUND:GROUND_NODE_HONAKER:PERSONNEL_LOST").available, 3, "HONAKER_PERSONNEL_LOSS_AUDIT")
log("HONAKER_SETTLEMENT_OK returnedVehicle=3 returnedPersonnel=9 lostVehicle=1 lostPersonnel=3 exactlyOnce=true")

log("RUNTIME_PASS testId=" .. TEST_ID .. " sixGroundNodes=true productionBaselineMutation=false mizMutation=false")
