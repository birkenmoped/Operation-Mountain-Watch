local FixedFireSupportAmmoSupport = dofile("scripts/ground/OMW_FixedFireSupportAmmoSupport.lua")

local function fail(message)
  error("FIXED_FIRE_SUPPORT_AMMO_SUPPORT_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local spawnZone = { name = "ZON_BLUE_GND_WRIGHT_RESUPPLY" }
local configuredSpawnZone = nil
local configuredMaxDistance = nil
local repositionCallCount = 0
local returnedGroup = nil
local brigadeStartCount = 0

local brigade = {}
function brigade:SetSpawnZone(zone, maxDistance)
  configuredSpawnZone = zone
  configuredMaxDistance = maxDistance
  return self
end
function brigade:SetValidateAndRepositionGroundUnits(_)
  repositionCallCount = repositionCallCount + 1
  return self
end
function brigade:AddAsset(group)
  returnedGroup = group
  return self
end
function brigade:Start()
  brigadeStartCount = brigadeStartCount + 1
  return self
end

local materializerSpec = nil
local materializedGroup = { name = "WRIGHT-M1083-001" }
local materializer = {
  Request = function()
    return nil, true
  end,
  GetMaterializedGroup = function()
    return materializedGroup
  end,
  GetPlatoon = function()
    return { name = "PLT_BLUE_GND_WRIGHT_AMMO_SUPPORT" }
  end,
  ReturnToStock = function(_, group)
    brigade:AddAsset(group)
    materializedGroup = nil
    return true
  end,
}
local materializerModule = {
  New = function(spec)
    materializerSpec = spec
    return materializer
  end,
}

local service = FixedFireSupportAmmoSupport.New({
  brigade = brigade,
  spawnZone = spawnZone,
  spawnZoneMaxDistanceM = 400,
  materializerModule = materializerModule,
  platoonFactory = function() end,
  descriptorGroupName = "GROUPNAME",
  templateName = "TPL_BLUE_GND_SUP_M1083",
  platoonName = "PLT_BLUE_GND_WRIGHT_AMMO_SUPPORT",
  assignment = "OMW:WRIGHT:AMMO-SUPPORT:M1083",
  entityId = "WRIGHT-AMMO-SUPPORT-M1083",
})

expectEqual(configuredSpawnZone, spawnZone, "SPAWN_ZONE")
expectEqual(configuredMaxDistance, 400, "SPAWN_ZONE_MAX_DISTANCE")
expectEqual(repositionCallCount, 0, "REPOSITION_PATH_MUST_NOT_BE_CALLED")
expectEqual(brigadeStartCount, 1, "DEDICATED_BRIGADE_START_COUNT")
expectEqual(materializerSpec.templateName, "TPL_BLUE_GND_SUP_M1083", "TEMPLATE")
expectEqual(materializerSpec.platoonName, "PLT_BLUE_GND_WRIGHT_AMMO_SUPPORT", "PLATOON")
expectEqual(materializerSpec.assignment, "OMW:WRIGHT:AMMO-SUPPORT:M1083", "ASSIGNMENT")
expectEqual(materializerSpec.stockCount, 1, "STOCK_COUNT")
expectEqual(materializerSpec.priority, 20, "PRIORITY")

local groupBefore, created = service:Request()
expectEqual(groupBefore, nil, "REQUEST_GROUP_BEFORE")
expectEqual(created, true, "REQUEST_CREATED")
expectEqual(service:GetMaterializedGroup(), materializedGroup, "MATERIALIZED_GROUP")
expectEqual(service:GetConfig().schemaVersion, "OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-4", "SCHEMA")
expectEqual(service:GetConfig().assignment, "OMW:WRIGHT:AMMO-SUPPORT:M1083", "CONFIG_ASSIGNMENT")
expectEqual(service:GetConfig().spawnZoneMaxDistanceM, 400, "CONFIG_SPAWN_MAX_DISTANCE")

service:ReturnToStock(materializedGroup)
expectEqual(returnedGroup.name, "WRIGHT-M1083-001", "RETURNED_GROUP")
expectEqual(service:GetMaterializedGroup(), nil, "MATERIALIZED_GROUP_CLEARED")

print("PASS generic fixed fire-support local Warehouse materialization contract starts dedicated MOOSE BRIGADE after registration")
