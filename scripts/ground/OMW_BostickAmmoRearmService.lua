-- Operation Mountain Watch - Bostick local ammunition rearm composition.
--
-- This module joins the Bostick M1083 support materialization boundary with
-- the CampaignState-backed ARTY rearm adapter. It does not create a second
-- resource ledger, does not spawn directly, and does not implement routing or
-- an operational FSM outside the composed MOOSE lifecycles.

local BostickAmmoRearmService = {}

local Service = {}
Service.__index = Service

local TAG = "[OMW][Ground.BostickAmmoRearm]"

BostickAmmoRearmService.SchemaVersion = "OMW-BOSTICK-AMMO-REARM-SERVICE-1"
BostickAmmoRearmService.NodeId = "GROUND_NODE_BOSTICK"
BostickAmmoRearmService.ResourceId = "GROUND_AMMO_PACKAGE"
BostickAmmoRearmService.CarrierEntityId = "BOSTICK-AMMO-SUPPORT-M1083"

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

function BostickAmmoRearmService.New(spec)
  requireTable(spec, "spec")
  local supportModule = requireTable(spec.bostickAmmoSupportModule, "spec.bostickAmmoSupportModule")
  local rearmModule = requireTable(spec.groundAmmoRearmAdapterModule, "spec.groundAmmoRearmAdapterModule")
  if type(supportModule.New) ~= "function" then fail("spec.bostickAmmoSupportModule.New() is required") end
  if type(rearmModule.New) ~= "function" then fail("spec.groundAmmoRearmAdapterModule.New() is required") end

  local service = setmetatable({
    pending = nil,
    contexts = {},
    log = spec.log or noop,
    onRearmed = spec.onRearmed or noop,
  }, Service)

  service.rearm = rearmModule.New({
    store = requireTable(spec.store, "spec.store"),
    campaignState = requireTable(spec.campaignState, "spec.campaignState"),
    artyFactory = spec.artyFactory,
    resourceId = spec.resourceId or BostickAmmoRearmService.ResourceId,
    canonicalUnit = spec.canonicalUnit or "count",
    log = spec.log,
    onRearmed = function(context, Controllable, From, Event, To)
      service.contexts[context.transactionId] = context
      service.onRearmed(context, Controllable, From, Event, To)
    end,
  })

  local supportSpec = {
    brigade = spec.brigade,
    accessZone = spec.accessZone,
    forwardCoordinate = spec.forwardCoordinate,
    roadSpawnAdapter = spec.roadSpawnAdapter,
    materializerModule = spec.materializerModule,
    platoonFactory = spec.platoonFactory,
    descriptorGroupName = spec.descriptorGroupName,
    templateName = spec.templateName,
    platoonName = spec.platoonName,
    assignment = spec.assignment,
    entityId = spec.carrierEntityId or BostickAmmoRearmService.CarrierEntityId,
    stockCount = spec.stockCount,
    priority = spec.priority,
    roadSpawnLog = spec.roadSpawnLog,
    rearClearanceM = spec.rearClearanceM,
    headingSampleM = spec.headingSampleM,
    maxSnapM = spec.maxSnapM,
    minimumTemplateSpacingM = spec.minimumTemplateSpacingM,
    log = spec.log,
    onMaterialized = function(group)
      service:_OnSupportMaterialized(group)
    end,
  }
  service.support = supportModule.New(supportSpec)

  return service
end

function Service:_StartRearm(group, request)
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

function Service:Request(spec)
  requireTable(spec, "spec")
  local transactionId = requireNonEmptyString(spec.transactionId, "spec.transactionId")
  local artilleryGroup = requireTable(spec.artilleryGroup, "spec.artilleryGroup")

  local existing = self.contexts[transactionId] or self.rearm:Get(transactionId)
  if existing then return existing, false end

  if self.pending and self.pending.transactionId ~= transactionId then
    fail("another Bostick rearm request is waiting for support materialization transactionId=" .. self.pending.transactionId)
  end

  local request = {
    transactionId = transactionId,
    reservationId = spec.reservationId,
    missionDemandId = spec.missionDemandId,
    carrierEntityId = spec.carrierEntityId or BostickAmmoRearmService.CarrierEntityId,
    nodeId = spec.nodeId or BostickAmmoRearmService.NodeId,
    resourceId = spec.resourceId or BostickAmmoRearmService.ResourceId,
    canonicalUnit = spec.canonicalUnit or "count",
    quantity = requirePositive(spec.quantity or 1, "spec.quantity"),
    artilleryGroup = artilleryGroup,
    alias = spec.alias or "Bostick L118",
    onRoad = spec.onRoad,
    rearmingDistance = spec.rearmingDistance,
    rearmingSpeedKph = spec.rearmingSpeedKph,
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

return BostickAmmoRearmService
