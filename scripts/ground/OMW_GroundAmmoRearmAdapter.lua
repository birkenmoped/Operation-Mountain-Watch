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
local REARM_RESERVATION_PREFIX = "GROUND-LOCAL-REARM:"
local RESTART_CREDIT_PREFIX = "GROUND-LOCAL-REARM-RESTART:"

GroundAmmoRearmAdapter.SchemaVersion = "OMW-GROUND-AMMO-REARM-ADAPTER-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then
    fail(label .. " must be a function")
  end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requirePositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
    fail(label .. " requires positive finite number")
  end
  return value
end

local function isLocalRearmTransaction(transaction)
  return type(transaction) == "table"
    and type(transaction.reservationId) == "string"
    and transaction.reservationId:sub(1, #REARM_RESERVATION_PREFIX) == REARM_RESERVATION_PREFIX
end

local function noop() end

local function validateStore(store)
  requireTable(store, "store")
  local required = {
    "ReserveResource",
    "Consume",
    "CompleteConsumption",
    "MarkConsumptionCompensated",
    "Cancel",
    "GetTransaction",
    "CreditResourceOnce",
    "GetResourceCredit",
    "ExportSnapshot",
  }
  for _, methodName in ipairs(required) do
    if type(store[methodName]) ~= "function" then
      fail("store requires " .. methodName .. "()")
    end
  end
  return store
end

local function validateCampaignState(campaignState)
  requireTable(campaignState, "campaignState")
  if type(campaignState.TransactionKind) ~= "table"
      or campaignState.TransactionKind.CONSUMPTION == nil then
    fail("campaignState.TransactionKind.CONSUMPTION is required")
  end
  if type(campaignState.TransactionStatus) ~= "table"
      or campaignState.TransactionStatus.CONSUMED == nil
      or campaignState.TransactionStatus.COMPLETED == nil
      or campaignState.TransactionStatus.COMPENSATED == nil then
    fail("campaignState consumption completion statuses are required")
  end
  return campaignState
end

function GroundAmmoRearmAdapter.ReconcileRestore(store, campaignState)
  store = validateStore(store)
  campaignState = validateCampaignState(campaignState)

  local result = {
    compensated = 0,
    alreadyCompensated = 0,
    completed = 0,
    cancelledBeforeCommit = 0,
  }

  local snapshot = store:ExportSnapshot()
  for _, transaction in ipairs(snapshot.transactions or {}) do
    if isLocalRearmTransaction(transaction) then
      if transaction.status == campaignState.TransactionStatus.CONSUMED then
        local creditId = RESTART_CREDIT_PREFIX .. transaction.transactionId
        local existingCredit = store:GetResourceCredit(creditId)
        if not existingCredit then
          store:CreditResourceOnce({
            creditId = creditId,
            nodeId = transaction.originNodeId,
            resourceId = transaction.resourceId,
            quantity = transaction.quantity,
            canonicalUnit = transaction.canonicalUnit,
            reason = "GROUND_LOCAL_REARM_RESTART_COMPENSATION",
            entityId = transaction.carrierEntityId or transaction.transactionId,
          })
          result.compensated = result.compensated + 1
        else
          result.alreadyCompensated = result.alreadyCompensated + 1
        end
        store:MarkConsumptionCompensated(transaction.transactionId)
      elseif transaction.status == campaignState.TransactionStatus.COMPLETED then
        result.completed = result.completed + 1
      elseif transaction.status == campaignState.TransactionStatus.COMPENSATED then
        result.alreadyCompensated = result.alreadyCompensated + 1
      elseif transaction.status == campaignState.TransactionStatus.RESERVED
          or transaction.status == campaignState.TransactionStatus.LOADING then
        store:Cancel(transaction.transactionId)
        result.cancelledBeforeCommit = result.cancelledBeforeCommit + 1
      end
    end
  end

  return result
end

function GroundAmmoRearmAdapter.New(spec)
  requireTable(spec, "spec")

  local store = validateStore(spec.store)
  local campaignState = validateCampaignState(spec.campaignState)
  local artyFactory = requireFunction(spec.artyFactory, "spec.artyFactory")

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
  local startArty = spec.startArty ~= false

  local existing = self.activeByTransactionId[transactionId]
  if existing then
    return existing, false
  end

  local transaction, created = self.store:ReserveResource({
    transactionId = transactionId,
    reservationId = REARM_RESERVATION_PREFIX .. transactionId,
    missionDemandId = spec.missionDemandId,
    carrierEntityId = spec.carrierEntityId,
    kind = self.campaignState.TransactionKind.CONSUMPTION,
    resourceId = spec.resourceId or self.resourceId,
    quantity = quantity,
    canonicalUnit = spec.canonicalUnit or self.canonicalUnit,
    originNodeId = nodeId,
  })

  if not created then
    fail("local rearm transactionId cannot be reused across service lifecycles=" .. transactionId)
  end

  local arty = self.artyFactory(artilleryGroup, spec.alias)
  if type(arty) ~= "table" then
    self.store:Cancel(transactionId)
    fail("artyFactory returned no ARTY object transactionId=" .. transactionId)
  end

  local requiredMethods = {
    "SetRearmingGroup",
    "SetRearmingGroupOnRoad",
    "Rearm",
  }
  if startArty then
    requiredMethods[#requiredMethods + 1] = "Start"
  end
  for _, methodName in ipairs(requiredMethods) do
    if type(arty[methodName]) ~= "function" then
      self.store:Cancel(transactionId)
      fail("ARTY object requires " .. methodName .. "() transactionId=" .. transactionId)
    end
  end

  arty:SetRearmingGroup(rearmingGroup)
  arty:SetRearmingGroupOnRoad(spec.onRoad ~= false)

  if spec.rearmingDistance ~= nil then
    if type(arty.SetRearmingDistance) ~= "function" then
      self.store:Cancel(transactionId)
      fail("ARTY object requires SetRearmingDistance() for configured distance transactionId=" .. transactionId)
    end
    arty:SetRearmingDistance(requirePositive(spec.rearmingDistance, "spec.rearmingDistance"))
  end

  if spec.rearmingSpeedKph ~= nil then
    if type(arty.SetRearmingGroupSpeed) ~= "function" then
      self.store:Cancel(transactionId)
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
    startArty = startArty,
    status = "RESERVED",
  }
  self.activeByTransactionId[transactionId] = context

  -- MOOSE calls the class onbeforeRearm handler first and the user OnBeforeRearm
  -- hook second. Therefore this hook executes only after ARTY has confirmed that
  -- the battery can rearm and that a live rearming group/place exists, but still
  -- before ARTY:onafterRearm starts physical movement.
  arty.OnBeforeRearm = function(_, Controllable, From, Event, To)
    local ok, consumedOrError = pcall(function()
      return self.store:Consume(transactionId)
    end)
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
    local ok, completedOrError = pcall(function()
      return self.store:CompleteConsumption(transactionId)
    end)
    if not ok then
      context.status = "COMPLETION_FAILED"
      context.error = tostring(completedOrError)
      self:_log("ERROR", "durable rearm completion failed transactionId=" .. transactionId, context)
    else
      context.status = "COMPLETED"
      self:_log("INFO", "rearm completed transactionId=" .. transactionId, context)
    end
    self.onRearmed(context, Controllable, From, Event, To)
  end

  -- A caller that already owns and started the ARTY instance may suppress Start().
  -- This is required when the same ARTY object has already fired: ARTY:onafterStart
  -- records the full-ammo baseline, so restarting after firing would redefine that
  -- baseline to the depleted state and invalidate full-rearm detection.
  if startArty then
    arty:Start()
  end
  local accepted = arty:Rearm()

  if accepted == false then
    local current = self.store:GetTransaction(transactionId)
    if current.status == "RESERVED" or current.status == "LOADING" then
      self.store:Cancel(transactionId)
    end
    context.status = "REJECTED"
    self:_log("INFO", "ARTY rejected rearm transactionId=" .. transactionId, context)
    return context, created
  end

  return context, created
end

function GroundAmmoRearmAdapter.GetConfig()
  return {
    schemaVersion = GroundAmmoRearmAdapter.SchemaVersion,
    reservationPrefix = REARM_RESERVATION_PREFIX,
    restartCreditPrefix = RESTART_CREDIT_PREFIX,
  }
end

return GroundAmmoRearmAdapter