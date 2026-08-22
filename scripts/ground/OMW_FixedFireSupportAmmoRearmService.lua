-- Operation Mountain Watch - fixed fire-support ammunition rearm composition.
--
-- This module joins one configured MOOSE WAREHOUSE/BRIGADE/PLATOON support
-- materialization boundary with the CampaignState-backed ARTY rearm adapter.
-- Site identity is configuration, not code. After MOOSE ARTY reports Rearmed,
-- ARTY owns the physical return movement to the support group's remembered
-- initial coordinate. A low-frequency MOOSE SCHEDULER then confirms that the
-- group is back within the same RearmingDistance and returns the known group to
-- WAREHOUSE stock through the public AddAsset lifecycle.
-- It does not create a second resource ledger, spawn directly, implement
-- routing, or replace the MOOSE ARTY FSM.

local FixedFireSupportAmmoRearmService = {}

local Service = {}
Service.__index = Service

local TAG = "[OMW][Ground.FixedFireSupportAmmoRearm]"

FixedFireSupportAmmoRearmService.SchemaVersion = "OMW-FIXED-FIRE-SUPPORT-AMMO-REARM-SERVICE-2"
FixedFireSupportAmmoRearmService.ResourceId = "GROUND_AMMO_PACKAGE"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function requirePositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
    fail(label .. " requires positive finite number")
  end
  return value
end

local function noop() end

local function defaultSchedulerFactory(callback, startSeconds, repeatSeconds, stopSeconds)
  if type(SCHEDULER) ~= "table" or type(SCHEDULER.New) ~= "function" then
    fail("MOOSE SCHEDULER:New() is required")
  end
  return SCHEDULER:New(nil, callback, {}, startSeconds, repeatSeconds, 0, stopSeconds)
end

function FixedFireSupportAmmoRearmService.New(spec)
  requireTable(spec, "spec")
  local supportModule = requireTable(spec.fixedFireSupportAmmoSupportModule, "spec.fixedFireSupportAmmoSupportModule")
  local rearmModule = requireTable(spec.groundAmmoRearmAdapterModule, "spec.groundAmmoRearmAdapterModule")
  if type(supportModule.New) ~= "function" then fail("spec.fixedFireSupportAmmoSupportModule.New() is required") end
  if type(rearmModule.New) ~= "function" then fail("spec.groundAmmoRearmAdapterModule.New() is required") end

  local service = setmetatable({
    pending = nil,
    contexts = {},
    nodeId = requireNonEmptyString(spec.nodeId, "spec.nodeId"),
    resourceId = spec.resourceId or FixedFireSupportAmmoRearmService.ResourceId,
    carrierEntityId = requireNonEmptyString(spec.carrierEntityId, "spec.carrierEntityId"),
    alias = requireNonEmptyString(spec.alias, "spec.alias"),
    log = spec.log or noop,
    onRearmed = spec.onRearmed or noop,
    onSupportReturned = spec.onSupportReturned or noop,
    onSupportReturnFailed = spec.onSupportReturnFailed or noop,
    schedulerFactory = spec.schedulerFactory or defaultSchedulerFactory,
    returnCheckIntervalSec = requirePositive(spec.returnCheckIntervalSec or 5, "spec.returnCheckIntervalSec"),
    returnTimeoutSec = requirePositive(spec.returnTimeoutSec or 300, "spec.returnTimeoutSec"),
    returnWatchers = {},
  }, Service)

  service.rearm = rearmModule.New({
    store = requireTable(spec.store, "spec.store"),
    campaignState = requireTable(spec.campaignState, "spec.campaignState"),
    artyFactory = spec.artyFactory,
    resourceId = service.resourceId,
    canonicalUnit = spec.canonicalUnit or "count",
    log = spec.log,
    onRearmed = function(context, Controllable, From, Event, To)
      service.contexts[context.transactionId] = context
      service.onRearmed(context, Controllable, From, Event, To)
      service:_StartSupportReturnWatch(context)
    end,
  })

  local supportSpec = {
    brigade = spec.brigade,
    spawnZone = spec.spawnZone,
    spawnZoneMaxDistanceM = spec.spawnZoneMaxDistanceM,
    materializerModule = spec.materializerModule,
    platoonFactory = spec.platoonFactory,
    descriptorGroupName = spec.descriptorGroupName,
    templateName = spec.templateName,
    platoonName = spec.platoonName,
    assignment = spec.assignment,
    entityId = service.carrierEntityId,
    stockCount = spec.stockCount,
    priority = spec.priority,
    log = spec.log,
    onMaterialized = function(group)
      service:_OnSupportMaterialized(group)
    end,
  }
  service.support = supportModule.New(supportSpec)

  return service
end

function Service:_StartRearm(group, request)
  if type(group.GetCoordinate) ~= "function" then
    fail("materialized support GROUP requires GetCoordinate() transactionId=" .. request.transactionId)
  end
  local returnCoordinate = group:GetCoordinate()
  if type(returnCoordinate) ~= "table" or type(returnCoordinate.Get2DDistance) ~= "function" then
    fail("materialized support GROUP returned invalid coordinate transactionId=" .. request.transactionId)
  end

  local context, created = self.rearm:Request({
    transactionId = request.transactionId,
    reservationId = request.reservationId,
    missionDemandId = request.missionDemandId,
    carrierEntityId = request.carrierEntityId,
    nodeId = request.nodeId,
    resourceId = request.resourceId,
    canonicalUnit = request.canonicalUnit,
    quantity = request.quantity,
    artilleryGroup = request.artilleryGroup,
    rearmingGroup = group,
    alias = request.alias,
    onRoad = request.onRoad,
    rearmingDistance = request.rearmingDistance,
    rearmingSpeedKph = request.rearmingSpeedKph,
    startArty = request.startArty,
  })
  context.supportGroup = group
  context.supportReturnCoordinate = returnCoordinate
  context.supportReturnRadiusM = request.supportReturnRadiusM or request.rearmingDistance or 100
  self.contexts[request.transactionId] = context
  self.pending = nil
  return context, created
end

function Service:_OnSupportMaterialized(group)
  if not self.pending then
    self.log("INFO", TAG .. " support materialized without pending rearm request")
    return
  end
  self:_StartRearm(group, self.pending)
end

function Service:_FinishSupportReturn(context)
  self.support:ReturnToStock(context.supportGroup)
  context.status = "RETURNED_TO_STOCK"
  context.supportReturned = true
  self.log("INFO", TAG .. " support returned to Warehouse stock transactionId=" .. context.transactionId)
  self.onSupportReturned(context)
end

function Service:_FailSupportReturn(context, reason)
  context.status = "SUPPORT_RETURN_FAILED"
  context.error = tostring(reason)
  self.log("ERROR", TAG .. " support return failed transactionId=" .. context.transactionId .. " reason=" .. tostring(reason))
  self.onSupportReturnFailed(context, reason)
end

function Service:_StartSupportReturnWatch(context)
  local group = context.supportGroup
  local returnCoordinate = context.supportReturnCoordinate
  local returnRadiusM = requirePositive(context.supportReturnRadiusM or 100, "context.supportReturnRadiusM")
  local interval = self.returnCheckIntervalSec
  local maxChecks = math.max(1, math.ceil(self.returnTimeoutSec / interval))
  local checks = 0

  context.status = "RETURNING_SUPPORT"

  local function checkReturn()
    checks = checks + 1

    if type(group.IsAlive) ~= "function" or group:IsAlive() ~= true then
      self:_FailSupportReturn(context, "support group not alive")
      self.returnWatchers[context.transactionId] = nil
      return false
    end
    if type(group.GetCoordinate) ~= "function" then
      self:_FailSupportReturn(context, "support group GetCoordinate unavailable")
      self.returnWatchers[context.transactionId] = nil
      return false
    end

    local currentCoordinate = group:GetCoordinate()
    if type(currentCoordinate) ~= "table" or type(currentCoordinate.Get2DDistance) ~= "function" then
      self:_FailSupportReturn(context, "support group coordinate unavailable")
      self.returnWatchers[context.transactionId] = nil
      return false
    end

    local distanceM = currentCoordinate:Get2DDistance(returnCoordinate)
    context.supportReturnDistanceM = distanceM
    if distanceM <= returnRadiusM then
      self:_FinishSupportReturn(context)
      self.returnWatchers[context.transactionId] = nil
      return false
    end

    if checks >= maxChecks then
      self:_FailSupportReturn(context, "timeout distanceM=" .. tostring(distanceM))
      self.returnWatchers[context.transactionId] = nil
      return false
    end

    return true
  end

  local scheduler, scheduleId = self.schedulerFactory(
    checkReturn,
    1,
    interval,
    self.returnTimeoutSec + interval
  )
  self.returnWatchers[context.transactionId] = {
    scheduler = scheduler,
    scheduleId = scheduleId,
    checks = function() return checks end,
  }
end

function Service:Request(spec)
  requireTable(spec, "spec")
  local transactionId = requireNonEmptyString(spec.transactionId, "spec.transactionId")
  local artilleryGroup = requireTable(spec.artilleryGroup, "spec.artilleryGroup")

  local existing = self.contexts[transactionId] or self.rearm:Get(transactionId)
  if existing then return existing, false end

  if self.pending and self.pending.transactionId ~= transactionId then
    fail("another fixed fire-support rearm request is waiting for support materialization transactionId=" .. self.pending.transactionId)
  end

  local request = {
    transactionId = transactionId,
    reservationId = spec.reservationId,
    missionDemandId = spec.missionDemandId,
    carrierEntityId = spec.carrierEntityId or self.carrierEntityId,
    nodeId = spec.nodeId or self.nodeId,
    resourceId = spec.resourceId or self.resourceId,
    canonicalUnit = spec.canonicalUnit or "count",
    quantity = requirePositive(spec.quantity or 1, "spec.quantity"),
    artilleryGroup = artilleryGroup,
    alias = spec.alias or self.alias,
    onRoad = spec.onRoad,
    rearmingDistance = spec.rearmingDistance,
    rearmingSpeedKph = spec.rearmingSpeedKph,
    supportReturnRadiusM = spec.supportReturnRadiusM,
    startArty = spec.startArty,
  }

  local group = self.support:GetMaterializedGroup()
  if group then return self:_StartRearm(group, request) end

  self.pending = request
  local _, requested = self.support:Request()

  -- The MOOSE-backed materializer may complete synchronously and invoke the
  -- callback from inside Request(). In that case _OnSupportMaterialized()
  -- already replaced the pending request with the real rearm context. Do not
  -- overwrite that context with a stale WAITING_FOR_SUPPORT placeholder.
  local resolved = self.contexts[transactionId] or self.rearm:Get(transactionId)
  if self.pending == nil and resolved then
    return resolved, requested
  end

  -- Also tolerate a materializer that exposes the group synchronously without
  -- invoking the callback. The normal callback path remains authoritative.
  group = self.support:GetMaterializedGroup()
  if self.pending and group then
    return self:_StartRearm(group, self.pending)
  end

  local waiting = {
    transactionId = transactionId,
    nodeId = request.nodeId,
    resourceId = request.resourceId,
    quantity = request.quantity,
    status = "WAITING_FOR_SUPPORT",
  }
  self.contexts[transactionId] = waiting
  return waiting, requested
end

function Service:Get(transactionId)
  return self.contexts[transactionId] or self.rearm:Get(transactionId)
end

function Service:GetSupport()
  return self.support
end

function Service:GetConfig()
  return {
    schemaVersion = FixedFireSupportAmmoRearmService.SchemaVersion,
    nodeId = self.nodeId,
    resourceId = self.resourceId,
    carrierEntityId = self.carrierEntityId,
    alias = self.alias,
    returnCheckIntervalSec = self.returnCheckIntervalSec,
    returnTimeoutSec = self.returnTimeoutSec,
    support = self.support:GetConfig(),
  }
end

return FixedFireSupportAmmoRearmService
