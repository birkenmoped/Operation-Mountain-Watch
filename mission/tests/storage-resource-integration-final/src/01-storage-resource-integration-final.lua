-- Operation Mountain Watch - final read-only STORAGE resource integration gate.
--
-- Requires builder-local modules:
--   OMWCampaignState
--   OMWAirOpsResourceManifest
--   OMWStorageResourceObserver

local TEST_ID = "STORAGE-RESOURCE-INTEGRATION-FINAL-1"
local TAG = "[OMW-TEST][" .. TEST_ID .. "]"
local START_DELAY_SECONDS = 10
local FUEL_TOLERANCE_KG = 0.5

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function assertTrue(condition, message)
  if not condition then
    fail(message)
  end
end

local function copyResources(snapshot)
  local resources = {}
  for resourceId, observation in pairs(snapshot.resources or {}) do
    resources[resourceId] = {
      quantity = observation.quantity,
      unit = observation.canonicalUnit,
    }
  end
  return resources
end

local function copySnapshot(snapshot)
  local result = {
    nodeId = snapshot.nodeId,
    airbaseName = snapshot.airbaseName,
    resources = {},
    variants = {},
  }

  for resourceId, observation in pairs(snapshot.resources or {}) do
    local copy = {}
    for key, value in pairs(observation) do
      copy[key] = value
    end
    result.resources[resourceId] = copy
  end

  for key, observation in pairs(snapshot.variants or {}) do
    local copy = {}
    for field, value in pairs(observation) do
      copy[field] = value
    end
    result.variants[key] = copy
  end

  return result
end

local function findComparison(comparison, resourceId)
  for _, entry in ipairs(comparison.entries or {}) do
    if entry.resourceId == resourceId then
      return entry
    end
  end
  return nil
end

local function run()
  log("START storageMutation=false campaignStateMutationByObserver=false nativeDcs=false")

  local observer = OMWStorageResourceObserver.New(OMWAirOpsResourceManifest)

  local bagram = observer:ReadNode("TEST_NODE_BAGRAM", "Bagram")
  local shindand = observer:ReadNode("TEST_NODE_SHINDAND_HELIPORT", "Shindand Heliport")

  assertTrue(bagram.resources[OMWAirOpsResourceManifest.ResourceId.JP8] ~= nil, "Bagram JP8 observation missing")
  assertTrue(bagram.resources[OMWAirOpsResourceManifest.ResourceId.AVGAS] ~= nil, "Bagram AVGAS observation missing")
  assertTrue(shindand.resources[OMWAirOpsResourceManifest.ResourceId.JP8] ~= nil, "Shindand JP8 observation missing")
  assertTrue(shindand.resources[OMWAirOpsResourceManifest.ResourceId.AVGAS] ~= nil, "Shindand AVGAS observation missing")

  assertTrue(shindand.variants.AH64_AGM_114K ~= nil, "AGM-114K variant observation missing")
  assertTrue(shindand.variants.AH64_HYDRA_70_M151 ~= nil, "M151 variant observation missing")
  assertTrue(shindand.variants.AH64_IAFS_COMBOPAK_100 ~= nil, "IAFS technical observation missing")
  assertTrue(shindand.variants.AH64_AGM_114K.reconciliationEligible == false, "AGM-114K family mapping must remain variant-scoped")
  assertTrue(shindand.variants.AH64_HYDRA_70_M151.reconciliationEligible == false, "M151 family mapping must remain variant-scoped")
  assertTrue(shindand.variants.AH64_IAFS_COMBOPAK_100.resourceId == nil, "IAFS must remain non-strategic")

  log(string.format(
    "OBSERVED node=Bagram jp8Kg=%.3f avgasKg=%.3f f16TankCount=%.3f",
    bagram.resources[OMWAirOpsResourceManifest.ResourceId.JP8].quantity,
    bagram.resources[OMWAirOpsResourceManifest.ResourceId.AVGAS].quantity,
    (bagram.variants.F16_370GAL_TANK and bagram.variants.F16_370GAL_TANK.quantity) or 0
  ))
  log(string.format(
    "OBSERVED node=ShindandHeliport jp8Kg=%.3f avgasKg=%.3f agm114k=%.3f m151=%.3f iafs=%.3f",
    shindand.resources[OMWAirOpsResourceManifest.ResourceId.JP8].quantity,
    shindand.resources[OMWAirOpsResourceManifest.ResourceId.AVGAS].quantity,
    shindand.variants.AH64_AGM_114K.quantity,
    shindand.variants.AH64_HYDRA_70_M151.quantity,
    shindand.variants.AH64_IAFS_COMBOPAK_100.quantity
  ))

  local campaignState = OMWCampaignState.New({
    schemaVersion = "STORAGE-RESOURCE-INTEGRATION-FINAL-1",
    nodes = {
      {
        nodeId = bagram.nodeId,
        airbaseName = bagram.airbaseName,
        resources = copyResources(bagram),
      },
      {
        nodeId = shindand.nodeId,
        airbaseName = shindand.airbaseName,
        resources = copyResources(shindand),
      },
    },
  })

  local tolerances = {
    [OMWAirOpsResourceManifest.Unit.KG] = FUEL_TOLERANCE_KG,
    [OMWAirOpsResourceManifest.Unit.COUNT] = 0,
  }

  local bagramMatch = observer:CompareNode(campaignState, bagram.nodeId, bagram.airbaseName, tolerances)
  local shindandMatch = observer:CompareNode(campaignState, shindand.nodeId, shindand.airbaseName, tolerances)
  assertTrue(bagramMatch.driftCount == 0 and bagramMatch.matchCount == 2, "Bagram baseline reconciliation must match")
  assertTrue(shindandMatch.driftCount == 0 and shindandMatch.matchCount == 2, "Shindand baseline reconciliation must match")
  log("BASELINE_RECONCILIATION_PASS nodes=2 resourcesPerNode=2")

  local driftCampaignState = OMWCampaignState.New({
    schemaVersion = "STORAGE-RESOURCE-INTEGRATION-FINAL-DRIFT-1",
    nodes = {
      {
        nodeId = bagram.nodeId,
        airbaseName = bagram.airbaseName,
        resources = copyResources(bagram),
      },
    },
  })

  local jp8Before = driftCampaignState:GetResourceKg(bagram.nodeId, OMWAirOpsResourceManifest.ResourceId.JP8)
  driftCampaignState.nodesById[bagram.nodeId].resources[OMWAirOpsResourceManifest.ResourceId.JP8].quantity = jp8Before + 100
  local strategicBeforeCompare = driftCampaignState:GetResourceKg(bagram.nodeId, OMWAirOpsResourceManifest.ResourceId.JP8)

  local driftComparison = observer:CompareNode(driftCampaignState, bagram.nodeId, bagram.airbaseName, tolerances)
  local jp8Drift = findComparison(driftComparison, OMWAirOpsResourceManifest.ResourceId.JP8)
  assertTrue(jp8Drift ~= nil and jp8Drift.status == OMWStorageResourceObserver.Status.DRIFT, "Expected JP8 drift not detected")
  assertTrue(math.abs(jp8Drift.delta + 100) <= FUEL_TOLERANCE_KG, "Unexpected JP8 drift magnitude")
  assertTrue(driftCampaignState:GetResourceKg(bagram.nodeId, OMWAirOpsResourceManifest.ResourceId.JP8) == strategicBeforeCompare, "Observer mutated CampaignState during drift comparison")
  log(string.format("DRIFT_GUARD_PASS resourceId=%s delta=%.3f campaignStateMutation=false", OMWAirOpsResourceManifest.ResourceId.JP8, jp8Drift.delta))

  local before = copySnapshot(shindand)
  local after = copySnapshot(shindand)
  after.resources[OMWAirOpsResourceManifest.ResourceId.JP8].quantity = after.resources[OMWAirOpsResourceManifest.ResourceId.JP8].quantity - 125
  after.variants.AH64_AGM_114K.quantity = after.variants.AH64_AGM_114K.quantity - 4
  local measured = observer:MeasureDelta(before, after)
  assertTrue(measured.resources[OMWAirOpsResourceManifest.ResourceId.JP8].delta == -125, "Synthetic JP8 delta mismatch")
  assertTrue(measured.variants.AH64_AGM_114K.delta == -4, "Synthetic AGM-114K delta mismatch")
  log("DELTA_MEASUREMENT_PASS jp8Delta=-125 agm114kDelta=-4")

  log("MAPPING_SCOPE_PASS completeResource=FUEL_JP8,FUEL_AVGAS variantOnly=AGM_114K,HYDRA_70_M151 technicalNonStrategic=IAFS")
  log("RESULT status=PASS storageMutation=false campaignStateMutationByObserver=false schedulerBounded=true nativeDcs=false")
end

SCHEDULER:New(nil, run, {}, START_DELAY_SECONDS)
