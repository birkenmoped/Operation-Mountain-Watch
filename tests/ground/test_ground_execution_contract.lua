local RouteCatalog = dofile("scripts/ground/OMW_GroundRouteCatalog.lua")
local ExecutionContract = dofile("scripts/ground/OMW_GroundExecutionContract.lua")

local function expectError(fn, label)
  local ok = pcall(fn)
  if ok then
    error("expected error: " .. label)
  end
end

local catalog = RouteCatalog.New()

local route = catalog:Register({
  routeId = "ROUTE_TEST_A",
  originNodeId = "GROUND_NODE_TEST_A",
  destinationId = "GROUND_NODE_TEST_B",
  accessZoneName = "ZON_TEST_A_ACCESS",
  handoffZoneName = "ZON_TEST_B_ACCESS",
  pathlineNames = { "MSR_TEST_01", "MSR_TEST_02" },
  pathlineDirections = { "FORWARD", "REVERSE" },
  speedKph = 45,
  formation = "On Road",
  allowedMissionTypes = { "PATROL", "ROAD_CONVOY" },
})

assert(route.routeId == "ROUTE_TEST_A")
assert(catalog:IsMissionAllowed("ROUTE_TEST_A", "ROAD_CONVOY") == true)
assert(catalog:IsMissionAllowed("ROUTE_TEST_A", "QRF") == false)

local request = ExecutionContract.Normalize({
  executionId = "GEX-TEST-001",
  entityId = "GROUND-ENTITY-001",
  missionDemandId = "DEMAND-001",
  missionType = "ROAD_CONVOY",
  originNodeId = "GROUND_NODE_TEST_A",
  objectiveId = "GROUND_NODE_TEST_B",
  routeId = "ROUTE_TEST_A",
  brigadeId = "BRIGADE_TEST_A",
  platoonId = "PLATOON_TEST_CONVOY",
  templateId = "TPL_TEST_CONVOY",
  settlement = { resourceContract = "TEST" },
})

local validatedRoute = ExecutionContract.ValidateRoute(request, catalog)
assert(validatedRoute.destinationId == "GROUND_NODE_TEST_B")

local copy = catalog:Get("ROUTE_TEST_A")
copy.pathlineNames[1] = "MUTATED"
assert(catalog:Get("ROUTE_TEST_A").pathlineNames[1] == "MSR_TEST_01")

expectError(function()
  catalog:Register({
    routeId = "ROUTE_TEST_A",
    originNodeId = "GROUND_NODE_TEST_A",
    destinationId = "GROUND_NODE_TEST_B",
    accessZoneName = "ZON_TEST_A_ACCESS",
    handoffZoneName = "ZON_TEST_B_ACCESS",
    pathlineNames = { "MSR_TEST_01" },
    pathlineDirections = { "FORWARD" },
    speedKph = 45,
    formation = "On Road",
    allowedMissionTypes = { "ROAD_CONVOY" },
  })
end, "duplicate route")

expectError(function()
  catalog:Register({
    routeId = "ROUTE_BAD_DIRECTION",
    originNodeId = "GROUND_NODE_TEST_A",
    destinationId = "GROUND_NODE_TEST_B",
    accessZoneName = "ZON_TEST_A_ACCESS",
    handoffZoneName = "ZON_TEST_B_ACCESS",
    pathlineNames = { "MSR_TEST_01" },
    pathlineDirections = { "SIDEWAYS" },
    speedKph = 45,
    formation = "On Road",
    allowedMissionTypes = { "ROAD_CONVOY" },
  })
end, "invalid direction")

expectError(function()
  local wrongOrigin = ExecutionContract.Normalize({
    executionId = "GEX-TEST-002",
    entityId = "GROUND-ENTITY-002",
    missionType = "ROAD_CONVOY",
    originNodeId = "GROUND_NODE_WRONG",
    objectiveId = "GROUND_NODE_TEST_B",
    routeId = "ROUTE_TEST_A",
    brigadeId = "BRIGADE_TEST_A",
    platoonId = "PLATOON_TEST_CONVOY",
    templateId = "TPL_TEST_CONVOY",
  })
  ExecutionContract.ValidateRoute(wrongOrigin, catalog)
end, "route origin mismatch")

expectError(function()
  local disallowed = ExecutionContract.Normalize({
    executionId = "GEX-TEST-003",
    entityId = "GROUND-ENTITY-003",
    missionType = "QRF",
    originNodeId = "GROUND_NODE_TEST_A",
    objectiveId = "GROUND_NODE_TEST_B",
    routeId = "ROUTE_TEST_A",
    brigadeId = "BRIGADE_TEST_A",
    platoonId = "PLATOON_TEST_QRF",
    templateId = "TPL_TEST_QRF",
  })
  ExecutionContract.ValidateRoute(disallowed, catalog)
end, "mission type not allowed")

print("GROUND_EXECUTION_CONTRACT_TEST_PASS")
