local FixedFireSupportAmmoSupport = dofile("scripts/ground/OMW_FixedFireSupportAmmoSupport.lua")

local function fail(message)
  error("FIXED_FIRE_SUPPORT_AMMO_SUPPORT_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local brigade = {}
function brigade:GetAssignment(request)
  return request.assignment
end

local accessZone = { name = "ZON_BLUE_GND_WRIGHT_ACCESS" }
local forwardCoordinate = { name = "WRIGHT_FORWARD" }

local installedRoadConfig = nil
local roadSpawnAdapter = {
  Install = function(installedBrigade, config)
    expectEqual(installedBrigade, brigade, "ROAD_BRIGADE")
    installedRoadConfig = config
    return installedBrigade, true
  end,
}

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
}
local materializerModule = {
  New = function(spec)
    materializerSpec = spec
    return materializer
  end,
}

local service = FixedFireSupportAmmoSupport.New({
  brigade = brigade,
  accessZone = accessZone,
  forwardCoordinate = forwardCoordinate,
  roadSpawnAdapter = roadSpawnAdapter,
  materializerModule = materializerModule,
  platoonFactory = function() end,
  descriptorGroupName = "GROUPNAME",
  templateName = "TPL_BLUE_GND_SUP_M1083",
  platoonName = "PLT_BLUE_GND_WRIGHT_AMMO_SUPPORT",
  assignment = "OMW:WRIGHT:AMMO-SUPPORT:M1083",
  entityId = "WRIGHT-AMMO-SUPPORT-M1083",
})

expectEqual(materializerSpec.templateName, "TPL_BLUE_GND_SUP_M1083", "TEMPLATE")
expectEqual(materializerSpec.platoonName, "PLT_BLUE_GND_WRIGHT_AMMO_SUPPORT", "PLATOON")
expectEqual(materializerSpec.assignment, "OMW:WRIGHT:AMMO-SUPPORT:M1083", "ASSIGNMENT")
expectEqual(materializerSpec.stockCount, 1, "STOCK_COUNT")
expectEqual(materializerSpec.priority, 20, "PRIORITY")

local wrongAssignment = installedRoadConfig.resolveRoadSpawn(
  brigade,
  { templatename = "TPL_BLUE_GND_SUP_M1083" },
  { assignment = "OMW:BOSTICK:AMMO-SUPPORT:M1083" }
)
expectEqual(wrongAssignment, nil, "SITE_ASSIGNMENT_ISOLATION")

local roadSpec = installedRoadConfig.resolveRoadSpawn(
  brigade,
  { templatename = "TPL_BLUE_GND_SUP_M1083" },
  { assignment = "OMW:WRIGHT:AMMO-SUPPORT:M1083" }
)
expectEqual(roadSpec.accessZone, accessZone, "ROAD_ACCESS_ZONE")
expectEqual(roadSpec.forwardCoordinate, forwardCoordinate, "ROAD_FORWARD_COORDINATE")
expectEqual(roadSpec.entityId, "WRIGHT-AMMO-SUPPORT-M1083", "ROAD_ENTITY_ID")

local groupBefore, created = service:Request()
expectEqual(groupBefore, nil, "REQUEST_GROUP_BEFORE")
expectEqual(created, true, "REQUEST_CREATED")
expectEqual(service:GetMaterializedGroup(), materializedGroup, "MATERIALIZED_GROUP")
expectEqual(service:GetConfig().schemaVersion, "OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-1", "SCHEMA")
expectEqual(service:GetConfig().assignment, "OMW:WRIGHT:AMMO-SUPPORT:M1083", "CONFIG_ASSIGNMENT")

print("PASS generic fixed fire-support M1083 materialization contract")
