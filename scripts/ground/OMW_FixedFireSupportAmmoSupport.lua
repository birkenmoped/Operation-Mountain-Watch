-- Operation Mountain Watch - fixed fire-support ammunition materialization binding.
--
-- This module composes the public MOOSE BRIGADE/PLATOON/WAREHOUSE self-request
-- materializer for one configured local ammunition-support asset. Site identity
-- is configuration, not code. The support asset is materialized inside a
-- dedicated local Warehouse spawn zone that must be placed on free ground in
-- the Mission Editor. The pinned MOOSE SetValidateAndRepositionGroundUnits path
-- is intentionally not enabled because its UTILS helper chain is broken in the
-- pinned source/runtime. This module owns starting its dedicated support BRIGADE
-- after all PLATOON/materializer registrations are complete so later self-
-- requests can actually materialize through the MOOSE WAREHOUSE lifecycle.
-- It does not own CampaignState ammunition, create ARTY tasking, route the
-- support group after materialization, or spawn outside MOOSE WAREHOUSE.

local FixedFireSupportAmmoSupport = {}

local Service = {}
Service.__index = Service

local TAG = "[OMW][Ground.FixedFireSupportAmmoSupport]"

FixedFireSupportAmmoSupport.SchemaVersion = "OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-4"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then
    fail(label .. " must be a function")
  end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requirePositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
    fail(label .. " requires positive finite number")
  end
  return value
end

function FixedFireSupportAmmoSupport.New(spec)
  requireTable(spec, "spec")

  local brigade = requireTable(spec.brigade, "spec.brigade")
  local spawnZone = requireTable(spec.spawnZone, "spec.spawnZone")
  local materializerModule = requireTable(spec.materializerModule, "spec.materializerModule")
  local platoonFactory = requireFunction(spec.platoonFactory, "spec.platoonFactory")

  if type(brigade.SetSpawnZone) ~= "function" then
    fail("spec.brigade.SetSpawnZone() is required")
  end
  if type(brigade.AddAsset) ~= "function" then
    fail("spec.brigade.AddAsset() is required")
  end
  if type(brigade.Start) ~= "function" then
    fail("spec.brigade.Start() is required")
  end
  if type(materializerModule.New) ~= "function" then
    fail("spec.materializerModule.New() is required")
  end

  local descriptorGroupName = spec.descriptorGroupName
  if descriptorGroupName == nil then
    fail("spec.descriptorGroupName is required")
  end

  local templateName = requireNonEmptyString(spec.templateName, "spec.templateName")
  local platoonName = requireNonEmptyString(spec.platoonName, "spec.platoonName")
  local assignment = requireNonEmptyString(spec.assignment, "spec.assignment")
  local entityId = requireNonEmptyString(spec.entityId, "spec.entityId")
  local spawnZoneMaxDistanceM = requirePositive(spec.spawnZoneMaxDistanceM or 500, "spec.spawnZoneMaxDistanceM")

  brigade:SetSpawnZone(spawnZone, spawnZoneMaxDistanceM)

  local materializer = materializerModule.New({
    brigade = brigade,
    platoonFactory = platoonFactory,
    descriptorGroupName = descriptorGroupName,
    templateName = templateName,
    platoonName = platoonName,
    assignment = assignment,
    stockCount = spec.stockCount or 1,
    priority = spec.priority or 20,
    onMaterialized = spec.onMaterialized,
    log = spec.log,
  })

  -- The dedicated support warehouse must be started only after all materializer
  -- assets/callbacks are registered. Otherwise MOOSE accepts the later self-
  -- request but has no running BRIGADE lifecycle that can materialize it.
  brigade:Start()
  if spec.log then
    spec.log("INFO", TAG .. " dedicated support BRIGADE started after materializer registration")
  end

  return setmetatable({
    brigade = brigade,
    spawnZone = spawnZone,
    spawnZoneMaxDistanceM = spawnZoneMaxDistanceM,
    materializer = materializer,
    templateName = templateName,
    platoonName = platoonName,
    assignment = assignment,
    entityId = entityId,
  }, Service)
end

function Service:Request()
  return self.materializer:Request()
end

function Service:GetMaterializedGroup()
  return self.materializer:GetMaterializedGroup()
end

function Service:GetPlatoon()
  return self.materializer:GetPlatoon()
end

function Service:ReturnToStock(group)
  return self.materializer:ReturnToStock(group)
end

function Service:GetConfig()
  return {
    schemaVersion = FixedFireSupportAmmoSupport.SchemaVersion,
    templateName = self.templateName,
    platoonName = self.platoonName,
    assignment = self.assignment,
    entityId = self.entityId,
    spawnZoneMaxDistanceM = self.spawnZoneMaxDistanceM,
  }
end

return FixedFireSupportAmmoSupport
