-- Operation Mountain Watch - Ground ammunition rearm adapter.
--
-- CampaignState remains the sole strategic resource authority. This adapter
-- only coordinates an authorized local GROUND_AMMO_PACKAGE consumption with
-- the public MOOSE ARTY rearming lifecycle. It does not spawn assets, select
-- supply nodes, dispatch convoys, or own ammunition quantities.

local GroundAmmoRearmAdapter = {}

local Service = {}
Service.__index = Service

local TAG = "[OMW][Ground.AmmoRearm]"

GroundAmmoRearmAdapter.SchemaVersion = "OMW-GROUND-AMMO-REARM-ADAPTER-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then fail(label .. " must be a function") end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function requirePositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then fail(label .. " requires positive finite number") end
  return value
end

local function noop() end

function GroundAmmoRearmAdapter.New(spec)
  requireTable(spec, "spec")
  local store = requireTable(spec.store, "spec.store")
  local campaignState = requireTable(spec.campaignState, "spec.campaignState")
  local artyFactory = requireFunction(spec.artyFactory, "spec.artyFactory")
  if type(store.ReserveResource) ~= "function" or type(store.Consume) ~= "function" or type(store.Cancel) ~= "function" or type(store.GetTransaction) ~= "function" then
    fail("spec.store requires ReserveResource(), Consume(), Cancel(), and GetTransaction()")
  end
  if type(campaignState.TransactionKind) ~= "table" or campaignState.TransactionKind.CONSUMPTION == nil then
    fail("spec.campaignState.TransactionKind.CONSUMPTION is required")
  end
  return setmetatable({
    store = store,
    campaignState = campaignState,
    artyFactory = artyFactory,
    resourceId = spec.resourceId or "GROUND_AMMO_PACKAGE",
    canonicalUnit = spec.canonicalUnit or "count",
    log = spec.log or noop,
    onRearmed = spec.onRearmed or noop,
    activeByTransactionId = {},
  }, Service)
end

function Service:_log(level, message, context)
  self.log(level, TAG .. " " .. tostring(message), context)
end

function Service:Get(transactionId)
  return self.activeByTransactionId[transactionId]
end

function Service:Request(spec)
  requireTable(spec, "spec")
  local transactionId = requireNonEmptyString(spec.transactionId, "spec.transactionId")
  local nodeId = requireNonEmptyString(spec.nodeId, "spec.nodeId")
  local artilleryGroup = requireTable(spec.artilleryGroup, "spec.artilleryGroup")
  local rearmingGroup = requireTable(spec.rearmingGroup, "spec.rearmingGroup")
  local quantity = requirePositive(spec.quantity or 1, "spec.quantity")

  local existing = self.activeByTransactionId[transactionId]
  if existing then return existing, false end

  local transaction, created = self.store:ReserveResource({
    transactionId = transactionId,
    reservationId = spec.reservationId or transactionId,
    missionDemandId = spec.missionDemandId,
    carrierEntityId = spec.carrierEntityId,
    kind = self.campaignState.TransactionKind.CONSUMPTION,
    resourceId = spec.resourceId or self.resourceId,
    quantity = quantity,
    canonicalUnit = spec.canonicalUnit or self.canonicalUnit,
    originNodeId = nodeId,
  })

  local arty = self.artyFactory(artilleryGroup, spec.alias)
  if type(arty) ~= "table" then
    if created then self.store:Cancel(transactionId) end
    fail("artyFactory returned no ARTY object transactionId=" .. transactionId)
  end

  local requiredMethods = { "SetRearmingGroup", "SetRearmingGroupOnRoad", "Start", "Rearm" }
  for _, methodName in ipairs(requiredMethods) do
    if type(arty[methodName]) ~= "function" then
      if created then self.store:Cancel(transactionId) end
      fail("ARTY object requires " .. methodName .. "() transactionId=" .. transactionId)
    end
  end

  arty:SetRearmingGroup(rearmingGroup)
  arty:SetRearmingGroupOnRoad(spec.onRoad ~= false)

  if spec.rearmingDistance ~= nil then
    if type(arty.SetRearmingDistance) ~= "function" then
      if created then self.store:Cancel(transactionId) end
      fail("ARTY object requires SetRearmingDistance() for configured distance transactionId=" .. transactionId)
    end
    arty:SetRearmingDistance(requirePositive(spec.rearmingDistance, "spec.rearmingDistance"))
  end

  if spec.rearmingSpeedKph ~= nil then
    if type(arty.SetRearmingGroupSpeed) ~= "function" then
      if created then self.store:Cancel(transactionId) end
      fail("ARTY object requires SetRearmingGroupSpeed() for configured speed transactionId=" .. transactionId)
    end
    arty:SetRearmingGroupSpeed(requirePositive(spec.rearmingSpeedKph, "spec.rearmingSpeedKph"))
  end

  local context = {
    transactionId = transactionId,
    nodeId = nodeId,
    resourceId = transaction.resourceId,
    quantity = transaction.quantity,
    artilleryGroup = artilleryGroup,
    rearmingGroup = rearmingGroup,
    arty = arty,
    status = "RESERVED",
  }
  self.activeByTransactionId[transactionId] = context

  arty.OnBeforeRearm = function()
    local ok, consumedOrError = pcall(function() return self.store:Consume(transactionId) end)
    if not ok then
      context.status = "CONSUMPTION_FAILED"
      context.error = tostring(consumedOrError)
      self:_log("ERROR", "consumption failed transactionId=" .. transactionId, context)
      return false
    end
    context.status = "CONSUMED"
    self:_log("INFO", "consumption committed transactionId=" .. transactionId, context)
    return true
  end

  arty.OnAfterRearmed = function(_, Controllable, From, Event, To)
    context.status = "REARMED"
    self:_log("INFO", "rearm completed transactionId=" .. transactionId, context)
    self.onRearmed(context, Controllable, From, Event, To)
  end

  arty:Start()
  local accepted = arty:Rearm()
  if accepted == false then
    local current = self.store:GetTransaction(transactionId)
    if current.status == "RESERVED" or current.status == "LOADING" then self.store:Cancel(transactionId) end
    context.status = "REJECTED"
    self:_log("INFO", "ARTY rejected rearm transactionId=" .. transactionId, context)
    return context, created
  end
  return context, created
end

return GroundAmmoRearmAdapter
