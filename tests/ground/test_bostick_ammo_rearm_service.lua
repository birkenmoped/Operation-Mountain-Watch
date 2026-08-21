local ServiceModule = dofile("scripts/ground/OMW_BostickAmmoRearmService.lua")

local function fail(message)
  error("BOSTICK_AMMO_REARM_SERVICE_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local fakeSupport = nil
local supportModule = {}
function supportModule.New(spec)
  fakeSupport = {
    spec = spec,
    group = nil,
    requestCount = 0,
  }
  function fakeSupport:GetMaterializedGroup()
    return self.group
  end
  function fakeSupport:Request()
    self.requestCount = self.requestCount + 1
    return nil, true
  end
  function fakeSupport:Complete(group)
    self.group = group
    self.spec.onMaterialized(group)
  end
  return fakeSupport
end

local fakeRearm = nil
local rearmModule = {}
function rearmModule.New(spec)
  fakeRearm = {
    spec = spec,
    requests = {},
    contexts = {},
  }
  function fakeRearm:Get(transactionId)
    return self.contexts[transactionId]
  end
  function fakeRearm:Request(request)
    self.requests[#self.requests + 1] = request
    local context = {
      transactionId = request.transactionId,
      nodeId = request.nodeId,
      resourceId = request.resourceId,
      quantity = request.quantity,
      rearmingGroup = request.rearmingGroup,
      artilleryGroup = request.artilleryGroup,
      status = "CONSUMED",
    }
    self.contexts[request.transactionId] = context
    return context, true
  end
  return fakeRearm
end

local artilleryGroup = { name = "TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2" }
local materializedGroup = { name = "BOSTICK-M1083-001" }

local service = ServiceModule.New({
  bostickAmmoSupportModule = supportModule,
  groundAmmoRearmAdapterModule = rearmModule,
  store = {},
  campaignState = {},
  artyFactory = function() end,
  brigade = {},
  accessZone = {},
  forwardCoordinate = {},
  roadSpawnAdapter = {},
  materializerModule = {},
  platoonFactory = function() end,
  descriptorGroupName = "GROUPNAME",
})

local waiting, requested = service:Request({
  transactionId = "GROUND-REARM-BOSTICK-INTEGRATION-001",
  missionDemandId = "DEMAND-001",
  artilleryGroup = artilleryGroup,
  quantity = 1,
  rearmingDistance = 100,
  rearmingSpeedKph = 25,
})

expectEqual(requested, true, "SUPPORT_REQUESTED")
expectEqual(waiting.status, "WAITING_FOR_SUPPORT", "WAITING_STATUS")
expectEqual(fakeSupport.requestCount, 1, "SUPPORT_REQUEST_COUNT")
expectEqual(#fakeRearm.requests, 0, "NO_REARM_BEFORE_SUPPORT")

fakeSupport:Complete(materializedGroup)
expectEqual(#fakeRearm.requests, 1, "REARM_REQUEST_COUNT")
expectEqual(fakeRearm.requests[1].transactionId, "GROUND-REARM-BOSTICK-INTEGRATION-001", "TRANSACTION_ID")
expectEqual(fakeRearm.requests[1].nodeId, "GROUND_NODE_BOSTICK", "NODE_ID")
expectEqual(fakeRearm.requests[1].resourceId, "GROUND_AMMO_PACKAGE", "RESOURCE_ID")
expectEqual(fakeRearm.requests[1].carrierEntityId, "BOSTICK-AMMO-SUPPORT-M1083", "CARRIER_ENTITY_ID")
expectEqual(fakeRearm.requests[1].artilleryGroup, artilleryGroup, "ARTILLERY_GROUP")
expectEqual(fakeRearm.requests[1].rearmingGroup, materializedGroup, "REARMING_GROUP")
expectEqual(fakeRearm.requests[1].rearmingDistance, 100, "REARMING_DISTANCE")
expectEqual(fakeRearm.requests[1].rearmingSpeedKph, 25, "REARMING_SPEED")

local context = service:Get("GROUND-REARM-BOSTICK-INTEGRATION-001")
expectEqual(context.status, "CONSUMED", "COMPOSED_STATUS")
expectEqual(context.rearmingGroup, materializedGroup, "COMPOSED_REARMING_GROUP")

local same, createdAgain = service:Request({
  transactionId = "GROUND-REARM-BOSTICK-INTEGRATION-001",
  artilleryGroup = artilleryGroup,
})
expectEqual(same, context, "IDEMPOTENT_CONTEXT")
expectEqual(createdAgain, false, "IDEMPOTENT_CREATED")
expectEqual(fakeSupport.requestCount, 1, "NO_SECOND_SUPPORT_REQUEST")
expectEqual(#fakeRearm.requests, 1, "NO_SECOND_REARM_REQUEST")

print("PASS Bostick support materialization to CampaignState-backed ARTY rearm composition")
