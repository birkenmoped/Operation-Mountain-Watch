-- Operation Mountain Watch - Bostick ammunition support materialization binding.
--
-- This module composes the existing Ground road-spawn adapter and the public
-- MOOSE BRIGADE/PLATOON/WAREHOUSE self-request materializer for exactly one
-- Bostick M1083 support asset. It does not own CampaignState ammunition,
-- create ARTY tasking, route the support group after materialization, or spawn
-- assets outside the existing MOOSE WAREHOUSE lifecycle.

local BostickAmmoSupport = {}

local Service = {}
Service.__index = Service

local TAG = "[OMW][Ground.BostickAmmoSupport]"

BostickAmmoSupport.SchemaVersion = "OMW-BOSTICK-AMMO-SUPPORT-1"
BostickAmmoSupport.TemplateName = "TPL_BLUE_GND_SUP_M1083"
BostickAmmoSupport.PlatoonName = "PLT_BLUE_GND_BOSTICK_AMMO_SUPPORT"
BostickAmmoSupport.Assignment = "OMW:BOSTICK:AMMO-SUPPORT:M1083"
BostickAmmoSupport.EntityId = "BOSTICK-AMMO-SUPPORT-M1083"

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

function BostickAmmoSupport.New(spec)
  requireTable(spec, "spec")

  local brigade = requireTable(spec.brigade, "spec.brigade")
  local accessZone = requireTable(spec.accessZone, "spec.accessZone")
  local forwardCoordinate = requireTable(spec.forwardCoordinate, "spec.forwardCoordinate")
  local roadSpawnAdapter = requireTable(spec.roadSpawnAdapter, "spec.roadSpawnAdapter")
  local materializerModule = requireTable(spec.materializerModule, "spec.materializerModule")
  local platoonFactory = requireFunction(spec.platoonFactory, "spec.platoonFactory")

  if type(brigade.GetAssignment) ~= "function" then
    fail("spec.brigade.GetAssignment() is required")
  end
  if type(roadSpawnAdapter.Install) ~= "function" then
    fail("spec.roadSpawnAdapter.Install() is required")
  end
  if type(materializerModule.New) ~= "function" then
    fail("spec.materializerModule.New() is required")
  end

  local descriptorGroupName = spec.descriptorGroupName
  if descriptorGroupName == nil then
    fail("spec.descriptorGroupName is required")
  end

  local templateName = spec.templateName or BostickAmmoSupport.TemplateName
  local platoonName = spec.platoonName or BostickAmmoSupport.PlatoonName
  local assignment = spec.assignment or BostickAmmoSupport.Assignment
  local entityId = spec.entityId or BostickAmmoSupport.EntityId

  roadSpawnAdapter.Install(brigade, {
    resolveRoadSpawn = function(_, asset, request)
      if type(asset) ~= "table" or asset.templatename ~= templateName then
        return nil
      end
      if brigade:GetAssignment(request) ~= assignment then
        return nil
      end
      return {
        accessZone = accessZone,
        forwardCoordinate = forwardCoordinate,
        entityId = entityId,
      }
    end,
    log = spec.roadSpawnLog,
    rearClearanceM = spec.rearClearanceM,
    headingSampleM = spec.headingSampleM,
    maxSnapM = spec.maxSnapM,
    minimumTemplateSpacingM = spec.minimumTemplateSpacingM,
  })

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

  return setmetatable({
    brigade = brigade,
    accessZone = accessZone,
    forwardCoordinate = forwardCoordinate,
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

function Service:GetConfig()
  return {
    schemaVersion = BostickAmmoSupport.SchemaVersion,
    templateName = self.templateName,
    platoonName = self.platoonName,
    assignment = self.assignment,
    entityId = self.entityId,
  }
end

return BostickAmmoSupport
