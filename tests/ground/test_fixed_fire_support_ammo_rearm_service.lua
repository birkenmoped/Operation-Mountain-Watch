local ServiceModule = dofile("scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua")

local function fail(message)
  error("FIXED_FIRE_SUPPORT_AMMO_REARM_SERVICE_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local fakeSupport = nil
local synchronousGroup = nil
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
    if synchronousGroup then
      self:Complete(synchronousGroup)
    end
    return nil, true
  end
  function fakeSupport:Complete(group)
    self.group = group
    self.spec.onMaterialized(group)
  end
  function fakeSupport:GetConfig()
    return {
      schemaVersion = "OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-1",
      entityId = self.spec.entityId,
      assignment = self.spec.assignment,
    }
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

local function newService()
  return ServiceModule.New({
    fixedFireSupportAmmoSupportModule = supportModule,
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
    templateName = "TPL_BLUE_GND_SUP_M1083",
    platoonName = "PLT_BLUE_GND_HONAKER_AMMO_SUPPORT",
    assignment = "OMW:HONAKER:AMMO-SUPPORT:M1083",
    carrierEntityId = "HONAKER-AMMO-SUPPORT-M1083",
    nodeId = "GROUND_NODE_HONAKER",
    alias = "Honaker 2B11",
  })
end

local artilleryGroup = { name = "TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2" }
local materializedGroup = { name = "HONAKER-M1083-001" }

synchronousGroup = nil
local service = newService()

local waiting, requested = service:Request({
  transactionId = "GROUND-REARM-HONAKER-INTEGRATION-001",
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
expectEqual(fakeRearm.requests[1].transactionId, "GROUND-REARM-HONAKER-INTEGRATION-001", "TRANSACTION_ID")
expectEqual(fakeRearm.requests[1].nodeId, "GROUND_NODE_HONAKER", "NODE_ID")
expectEqual(fakeRearm.requests[1].resourceId, "GROUND_AMMO_PACKAGE", "RESOURCE_ID")
expectEqual(fakeRearm.requests[1].carrierEntityId, "HONAKER-AMMO-SUPPORT-M1083", "CARRIER_ENTITY_ID")
expectEqual(fakeRearm.requests[1].artilleryGroup, artilleryGroup, "ARTILLERY_GROUP")
expectEqual(fakeRearm.requests[1].rearmingGroup, materializedGroup, "REARMING_GROUP")
expectEqual(fakeRearm.requests[1].alias, "Honaker 2B11", "ALIAS")
expectEqual(fakeRearm.requests[1].rearmingDistance, 100, "REARMING_DISTANCE")
expectEqual(fakeRearm.requests[1].rearmingSpeedKph, 25, "REARMING_SPEED")

local context = service:Get("GROUND-REARM-HONAKER-INTEGRATION-001")
expectEqual(context.status, "CONSUMED", "COMPOSED_STATUS")
expectEqual(context.rearmingGroup, materializedGroup, "COMPOSED_REARMING_GROUP")

local config = service:GetConfig()
expectEqual(config.schemaVersion, "OMW-FIXED-FIRE-SUPPORT-AMMO-REARM-SERVICE-1", "SCHEMA")
expectEqual(config.nodeId, "GROUND_NODE_HONAKER", "CONFIG_NODE")
expectEqual(config.carrierEntityId, "HONAKER-AMMO-SUPPORT-M1083", "CONFIG_CARRIER")

synchronousGroup = materializedGroup
local synchronousService = newService()
local synchronousContext, synchronousRequested = synchronousService:Request({
  transactionId = "GROUND-REARM-HONAKER-SYNCHRONOUS-001",
  artilleryGroup = artilleryGroup,
})
expectEqual(synchronousRequested, true, "SYNCHRONOUS_SUPPORT_REQUESTED")
expectEqual(synchronousContext.status, "CONSUMED", "SYNCHRONOUS_CONTEXT_NOT_WAITING")
expectEqual(synchronousService:Get("GROUND-REARM-HONAKER-SYNCHRONOUS-001"), synchronousContext, "SYNCHRONOUS_CONTEXT_PRESERVED")
expectEqual(#fakeRearm.requests, 1, "SYNCHRONOUS_REARM_REQUEST_COUNT")
expectEqual(fakeRearm.requests[1].rearmingGroup, materializedGroup, "SYNCHRONOUS_REARMING_GROUP")

print("PASS generic fixed fire-support CampaignState-backed ARTY rearm composition")
