local BostickAmmoSupport = dofile("scripts/ground/OMW_BostickAmmoSupport.lua")

local function fail(message)
  error("BOSTICK_AMMO_SUPPORT_TEST " .. tostring(message), 2)
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

local accessZone = { name = "ZON_BLUE_GND_BOSTICK_ACCESS" }
local forwardCoordinate = { name = "BOSTICK_FORWARD" }

local installedRoadConfig = nil
local roadSpawnAdapter = {
  Install = function(installedBrigade, config)
    expectEqual(installedBrigade, brigade, "ROAD_BRIGADE")
    installedRoadConfig = config
    return installedBrigade, true
  end,
}

local materializerSpec = nil
local materializedGroup = { name = "BOSTICK-M1083-001" }
local materializer = {
  Request = function()
    return nil, true
  end,
  GetMaterializedGroup = function()
    return materializedGroup
  end,
  GetPlatoon = function()
    return { name = "PLT_BLUE_GND_BOSTICK_AMMO_SUPPORT" }
  end,
}
local materializerModule = {
  New = function(spec)
    materializerSpec = spec
    return materializer
  end,
}

local platoonFactory = function() end

local service = BostickAmmoSupport.New({
  brigade = brigade,
  accessZone = accessZone,
  forwardCoordinate = forwardCoordinate,
  roadSpawnAdapter = roadSpawnAdapter,
  materializerModule = materializerModule,
  platoonFactory = platoonFactory,
  descriptorGroupName = "GROUPNAME",
})

expectEqual(materializerSpec.brigade, brigade, "MATERIALIZER_BRIGADE")
expectEqual(materializerSpec.platoonFactory, platoonFactory, "PLATOON_FACTORY")
expectEqual(materializerSpec.descriptorGroupName, "GROUPNAME", "DESCRIPTOR")
expectEqual(materializerSpec.templateName, "TPL_BLUE_GND_SUP_M1083", "TEMPLATE")
expectEqual(materializerSpec.platoonName, "PLT_BLUE_GND_BOSTICK_AMMO_SUPPORT", "PLATOON")
expectEqual(materializerSpec.assignment, "OMW:BOSTICK:AMMO-SUPPORT:M1083", "ASSIGNMENT")
expectEqual(materializerSpec.stockCount, 1, "STOCK_COUNT")
expectEqual(materializerSpec.priority, 20, "PRIORITY")

local wrongTemplate = installedRoadConfig.resolveRoadSpawn(
  brigade,
  { templatename = "TPL_BLUE_GND_LOG_M1083_2" },
  { assignment = "OMW:BOSTICK:AMMO-SUPPORT:M1083" }
)
expectEqual(wrongTemplate, nil, "WRONG_TEMPLATE_NOT_ROAD_BOUND")

local wrongAssignment = installedRoadConfig.resolveRoadSpawn(
  brigade,
  { templatename = "TPL_BLUE_GND_SUP_M1083" },
  { assignment = "OTHER" }
)
expectEqual(wrongAssignment, nil, "WRONG_ASSIGNMENT_NOT_ROAD_BOUND")

local roadSpec = installedRoadConfig.resolveRoadSpawn(
  brigade,
  { templatename = "TPL_BLUE_GND_SUP_M1083" },
  { assignment = "OMW:BOSTICK:AMMO-SUPPORT:M1083" }
)
expectEqual(roadSpec.accessZone, accessZone, "ROAD_ACCESS_ZONE")
expectEqual(roadSpec.forwardCoordinate, forwardCoordinate, "ROAD_FORWARD_COORDINATE")
expectEqual(roadSpec.entityId, "BOSTICK-AMMO-SUPPORT-M1083", "ROAD_ENTITY_ID")

local groupBefore, created = service:Request()
expectEqual(groupBefore, nil, "REQUEST_GROUP_BEFORE")
expectEqual(created, true, "REQUEST_CREATED")
expectEqual(service:GetMaterializedGroup(), materializedGroup, "MATERIALIZED_GROUP")
expectEqual(service:GetConfig().schemaVersion, "OMW-BOSTICK-AMMO-SUPPORT-1", "SCHEMA")

print("PASS Bostick M1083 Ground support materialization binding contract")
