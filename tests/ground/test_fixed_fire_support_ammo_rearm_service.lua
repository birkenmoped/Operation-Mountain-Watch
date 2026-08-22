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
    returnedGroup = nil,
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
  function fakeSupport:ReturnToStock(group)
    self.returnedGroup = group
    self.group = nil
    return true
  end
  function fakeSupport:GetConfig()
    return {
      schemaVersion = "OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-2",
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

local scheduledCallback = nil
local function schedulerFactory(callback, startSeconds, repeatSeconds, stopSeconds)
  scheduledCallback = callback
  expectEqual(startSeconds, 1, "RETURN_WATCH_START")
  expectEqual(repeatSeconds, 5, "RETURN_WATCH_REPEAT")
  expectEqual(stopSeconds, 305, "RETURN_WATCH_STOP")
  return { name = "SCHEDULER" }, "SCHEDULE-1"
end

local supportReturnedContext = nil
local supportReturnFailure = nil
local function newService()
  return ServiceModule.New({
    fixedFireSupportAmmoSupportModule = supportModule,
    groundAmmoRearmAdapterModule = rearmModule,
    store = {},
    campaignState = {},
    artyFactory = function() end,
    brigade = {},
    spawnZone = {},
    materializerModule = {},
    platoonFactory = function() end,
    descriptorGroupName = "GROUPNAME",
    templateName = "TPL_BLUE_GND_SUP_M1083",
    platoonName = "PLT_BLUE_GND_HONAKER_AMMO_SUPPORT",
    assignment = "OMW:HONAKER:AMMO-SUPPORT:M1083",
    carrierEntityId = "HONAKER-AMMO-SUPPORT-M1083",
    nodeId = "GROUND_NODE_HONAKER",
    alias = "Honaker 2B11",
    schedulerFactory = schedulerFactory,
    returnCheckIntervalSec = 5,
    returnTimeoutSec = 300,
    onSupportReturned = function(context)
      supportReturnedContext = context
    end,
    onSupportReturnFailed = function(context, reason)
      supportReturnFailure = { context = context, reason = reason }
    end,
  })
end

local artilleryGroup = { name = "TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2" }
local returnDistance = 150
local initialCoordinate = {}
local currentCoordinate = {
  Get2DDistance = function(_, other)
    expectEqual(other, initialCoordinate, "RETURN_COORDINATE")
    return returnDistance
  end,
}
local materializedGroup
materializedGroup = {
  name = "HONAKER-M1083-001",
  GetCoordinate = function()
    if not materializedGroup.coordinateCaptured then
      materializedGroup.coordinateCaptured = true
      return initialCoordinate
    end
    return currentCoordinate
  end,
  IsAlive = function()
    return true
  end,
}
initialCoordinate.Get2DDistance = function(_, other)
  expectEqual(other, initialCoordinate, "INITIAL_RETURN_COORDINATE")
  return 0
end

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
expectEqual(context.supportReturnRadiusM, 100, "RETURN_RADIUS")

fakeRearm.spec.onRearmed(context)
expectEqual(context.status, "RETURNING_SUPPORT", "RETURNING_STATUS")
expectEqual(type(scheduledCallback), "function", "RETURN_WATCH_SCHEDULED")
expectEqual(scheduledCallback(), true, "RETURN_WATCH_CONTINUES")
expectEqual(fakeSupport.returnedGroup, nil, "NOT_RETURNED_WHILE_DISTANT")

returnDistance = 50
expectEqual(scheduledCallback(), false, "RETURN_WATCH_STOPS")
expectEqual(fakeSupport.returnedGroup, materializedGroup, "RETURNED_GROUP")
expectEqual(context.status, "RETURNED_TO_STOCK", "RETURNED_STATUS")
expectEqual(context.supportReturned, true, "RETURNED_FLAG")
expectEqual(supportReturnedContext, context, "RETURN_CALLBACK_CONTEXT")
expectEqual(supportReturnFailure, nil, "NO_RETURN_FAILURE")

local config = service:GetConfig()
expectEqual(config.schemaVersion, "OMW-FIXED-FIRE-SUPPORT-AMMO-REARM-SERVICE-2", "SCHEMA")
expectEqual(config.nodeId, "GROUND_NODE_HONAKER", "CONFIG_NODE")
expectEqual(config.carrierEntityId, "HONAKER-AMMO-SUPPORT-M1083", "CONFIG_CARRIER")
expectEqual(config.returnCheckIntervalSec, 5, "CONFIG_RETURN_INTERVAL")
expectEqual(config.returnTimeoutSec, 300, "CONFIG_RETURN_TIMEOUT")

materializedGroup.coordinateCaptured = false
returnDistance = 0
synchronousGroup = materializedGroup
scheduledCallback = nil
supportReturnedContext = nil
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

print("PASS generic fixed fire-support CampaignState-backed ARTY rearm and Warehouse return composition")
