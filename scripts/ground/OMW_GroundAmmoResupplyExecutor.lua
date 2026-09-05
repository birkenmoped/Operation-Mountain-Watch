-- Operation Mountain Watch - generic Ground AMMO RESUPPLY executor.
--
-- CampaignState is the sole strategic stock/transfer authority. MissionDemand is
-- demand/assignment/status authority. MOOSE BRIGADE/PLATOON/ARMYGROUP/AUFTRAG
-- own physical mission execution. This module composes the already accepted
-- Stage-1 Ground AMMO lifecycle; it does not define cargo-capacity semantics.

local Executor = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][GroundAmmoResupplyExecutor]"
Executor.SchemaVersion = "OMW-GROUND-AMMO-RESUPPLY-EXECUTOR-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function isFinitePositive(value)
  return type(value) == "number" and value == value and value > 0 and value < math.huge
end

local function missionName(mission)
  if mission and type(mission.GetName) == "function" then return mission:GetName() end
  return nil
end

function Executor.New(spec)
  requireTable(spec, "spec")
  local campaignState = requireTable(spec.campaignState, "campaignState")
  local store = requireTable(spec.store, "store")
  local missionDemand = requireTable(spec.missionDemand, "missionDemand")
  local registry = requireTable(spec.registry, "registry")
  local brigade = requireTable(spec.brigade, "brigade")
  local destinationZone = requireTable(spec.destinationZone, "destinationZone")
  local originZone = requireTable(spec.originZone, "originZone")

  for _, name in ipairs({ "ReserveResource", "MarkLoading", "MarkInTransit", "MarkDelivered", "MarkLost", "Cancel", "GetTransaction" }) do
    requireFunction(store, name, "store")
  end
  for _, name in ipairs({ "Get", "AssignAI", "Activate", "Succeed", "Fail", "SetReservationState" }) do
    requireFunction(registry, name, "registry")
  end
  requireFunction(brigade, "AddMission", "brigade")

  if type(missionDemand.Type) ~= "table" or missionDemand.Type.RESUPPLY == nil then fail("missionDemand.Type.RESUPPLY is required") end
  if type(missionDemand.Status) ~= "table" then fail("missionDemand.Status is required") end
  if type(campaignState.TransactionKind) ~= "table" or campaignState.TransactionKind.TRANSFER == nil then
    fail("campaignState.TransactionKind.TRANSFER is required")
  end
  if type(campaignState.TransactionStatus) ~= "table" then fail("campaignState.TransactionStatus is required") end
  requireNonEmptyString(spec.ammoResourceId, "ammoResourceId")
  requireNonEmptyString(spec.assigneeId, "assigneeId")
  requireNonEmptyString(spec.carrierEntityId, "carrierEntityId")
  if spec.returnDelaySeconds ~= nil and (type(spec.returnDelaySeconds) ~= "number" or spec.returnDelaySeconds < 0) then
    fail("returnDelaySeconds must be non-negative when provided")
  end
  if spec.missionFactory ~= nil and type(spec.missionFactory) ~= "function" then fail("missionFactory must be function when provided") end
  if spec.defer ~= nil and type(spec.defer) ~= "function" then fail("defer must be function when provided") end
  if spec.returnToOrigin ~= nil and type(spec.returnToOrigin) ~= "function" then fail("returnToOrigin must be function when provided") end

  return setmetatable({
    campaignState = campaignState,
    store = store,
    missionDemand = missionDemand,
    registry = registry,
    brigade = brigade,
    destinationZone = destinationZone,
    originZone = originZone,
    ammoResourceId = spec.ammoResourceId,
    assigneeId = spec.assigneeId,
    carrierEntityId = spec.carrierEntityId,
    missionSpeedKts = spec.missionSpeedKts,
    formation = spec.formation,
    returnDelaySeconds = spec.returnDelaySeconds or 30,
    missionFactory = spec.missionFactory,
    defer = spec.defer,
    returnToOrigin = spec.returnToOrigin,
    executionsByDemandId = {},
  }, Instance)
end

function Instance:_log(message)
  if type(self.brigade.I) == "function" then self.brigade:I(TAG .. " " .. tostring(message)) end
end

function Instance:_newMission()
  if self.missionFactory then return self.missionFactory(self.destinationZone) end
  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewAMMOSUPPLY) ~= "function" then
    fail("MOOSE AUFTRAG:NewAMMOSUPPLY() is required")
  end
  return AUFTRAG:NewAMMOSUPPLY(self.destinationZone)
end

function Instance:_defer(callback, seconds)
  if self.defer then return self.defer(callback, seconds) end
  if type(SCHEDULER) ~= "table" or type(SCHEDULER.New) ~= "function" then fail("MOOSE SCHEDULER:New() is required") end
  return SCHEDULER:New(nil, callback, {}, seconds)
end

function Instance:_return(armyGroup)
  if self.returnToOrigin then return self.returnToOrigin(armyGroup, self.originZone) end
  if type(armyGroup.RTZ) ~= "function" then fail("ARMYGROUP:RTZ() is required") end
  if type(ENUMS) ~= "table" or type(ENUMS.Formation) ~= "table" or type(ENUMS.Formation.Vehicle) ~= "table" then
    fail("MOOSE ENUMS.Formation.Vehicle.OnRoad is required")
  end
  return armyGroup:RTZ(self.originZone, ENUMS.Formation.Vehicle.OnRoad)
end

function Instance:_failExecution(execution, reason)
  if execution.closed then return false end
  execution.closed = true

  local transaction = self.store:GetTransaction(execution.transactionId)
  if transaction.status == self.campaignState.TransactionStatus.RESERVED
      or transaction.status == self.campaignState.TransactionStatus.LOADING then
    self.store:Cancel(execution.transactionId)
  elseif transaction.status == self.campaignState.TransactionStatus.IN_TRANSIT then
    self.store:MarkLost(execution.transactionId)
  end

  local current = self.registry:Get(execution.demandId)
  if current and current.status ~= self.missionDemand.Status.SUCCESS
      and current.status ~= self.missionDemand.Status.FAILED
      and current.status ~= self.missionDemand.Status.EXPIRED then
    self.registry:Fail(execution.demandId, reason)
  end

  self:_log("resupply failed demandId=" .. tostring(execution.demandId) .. " reason=" .. tostring(reason))
  return true
end

function Instance:_attachArmyLifecycle(execution, armyGroup)
  if execution.armyGroup then return end
  execution.armyGroup = armyGroup
  local executor = self

  local previousExecute = armyGroup.OnAfterMissionExecute
  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if previousExecute then previousExecute(self, From, Event, To, Mission) end
    if Mission ~= execution.mission or execution.closed then return end

    -- Accepted Stage-1 contract: AMMOSUPPLY does not self-complete. The exact
    -- mission executing while the same ARMYGROUP is physically in the
    -- destination ACCESS zone is the delivery evidence.
    if type(self.IsInZone) ~= "function" or self:IsInZone(executor.destinationZone) ~= true then
      executor:_failExecution(execution, "AMMO_RESUPPLY_MISSION_EXECUTE_OUTSIDE_DESTINATION")
      return
    end

    local transaction = executor.store:GetTransaction(execution.transactionId)
    if transaction.status ~= executor.campaignState.TransactionStatus.IN_TRANSIT then
      executor:_failExecution(execution, "AMMO_RESUPPLY_INVALID_DELIVERY_TRANSACTION_STATE")
      return
    end

    executor.store:MarkDelivered(execution.transactionId)
    executor.registry:SetReservationState(execution.demandId, "DELIVERED", {
      transactionId = execution.transactionId,
      carrierEntityId = executor.carrierEntityId,
    })

    local current = executor.registry:Get(execution.demandId)
    if current and current.status == executor.missionDemand.Status.ACTIVE then
      executor.registry:Succeed(execution.demandId, {
        transactionId = execution.transactionId,
        carrierEntityId = executor.carrierEntityId,
        mission = missionName(execution.mission),
        delivered = true,
      })
    end

    execution.delivered = true
    if type(execution.mission.__Cancel) == "function" then execution.mission:__Cancel(1) end
    executor:_log("resupply delivered demandId=" .. tostring(execution.demandId))
  end

  local previousDone = armyGroup.OnAfterMissionDone
  function armyGroup:OnAfterMissionDone(From, Event, To, Mission)
    if previousDone then previousDone(self, From, Event, To, Mission) end
    if Mission ~= execution.mission or execution.closed then return end
    if execution.delivered ~= true then
      executor:_failExecution(execution, "AMMO_RESUPPLY_MISSION_DONE_BEFORE_DELIVERY")
      return
    end

    executor:_defer(function()
      if execution.returnOrdered or execution.returned then return end
      execution.returnOrdered = true
      executor:_return(armyGroup)
      executor:_log("resupply return ordered demandId=" .. tostring(execution.demandId))
    end, executor.returnDelaySeconds)
  end

  local previousReturned = armyGroup.OnAfterReturned
  function armyGroup:OnAfterReturned(From, Event, To)
    if previousReturned then previousReturned(self, From, Event, To) end
    execution.returned = true
    execution.closed = true
    executor:_log("resupply returned demandId=" .. tostring(execution.demandId))
  end

  local previousDead = armyGroup.OnAfterDead
  function armyGroup:OnAfterDead(From, Event, To)
    if previousDead then previousDead(self, From, Event, To) end
    if execution.delivered then
      execution.closed = true
      return
    end
    executor:_failExecution(execution, "AMMO_RESUPPLY_CARRIER_DESTROYED")
  end
end

function Instance:Start(demand)
  requireTable(demand, "demand")
  requireNonEmptyString(demand.id, "demand.id")

  if demand.missionType ~= self.missionDemand.Type.RESUPPLY then return nil, false, "UNSUPPORTED_MISSION_TYPE" end
  if demand.aiCapable ~= true then return nil, false, "DEMAND_NOT_AI_CAPABLE" end
  if demand.status ~= self.missionDemand.Status.OPEN then
    local existing = self.executionsByDemandId[demand.id]
    if existing then return existing, false, "ALREADY_STARTED" end
    return nil, false, "DEMAND_NOT_OPEN"
  end

  local target = requireTable(demand.target, "demand.target")
  if target.resourceId ~= self.ammoResourceId then return nil, false, "UNSUPPORTED_RESOURCE" end
  requireNonEmptyString(demand.origin, "demand.origin")
  requireNonEmptyString(target.nodeId, "demand.target.nodeId")
  if not isFinitePositive(target.requestedQuantity) then fail("demand.target.requestedQuantity must be positive finite") end

  local existing = self.executionsByDemandId[demand.id]
  if existing then return existing, false, "ALREADY_STARTED" end

  local transactionId = "TRANSFER|" .. demand.id
  local transaction, reserved = self.store:ReserveResource({
    transactionId = transactionId,
    reservationId = transactionId,
    cargoId = "CARGO|" .. demand.id,
    missionDemandId = demand.id,
    carrierEntityId = self.carrierEntityId,
    kind = self.campaignState.TransactionKind.TRANSFER,
    resourceId = target.resourceId,
    quantity = target.requestedQuantity,
    canonicalUnit = target.canonicalUnit,
    originNodeId = demand.origin,
    destinationNodeId = target.nodeId,
  })

  local mission = requireTable(self:_newMission(), "AMMOSUPPLY AUFTRAG")
  if self.missionSpeedKts ~= nil and type(mission.SetMissionSpeed) == "function" then mission:SetMissionSpeed(self.missionSpeedKts) end
  if self.formation ~= nil and type(mission.SetFormation) == "function" then mission:SetFormation(self.formation) end
  if type(mission.SetReturnToLegion) == "function" then mission:SetReturnToLegion(false) end
  if type(mission.SetPriority) == "function" then mission:SetPriority(demand.priority) end

  local execution = {
    demandId = demand.id,
    transactionId = transaction.transactionId,
    mission = mission,
    armyGroup = nil,
    delivered = false,
    returnOrdered = false,
    returned = false,
    closed = false,
  }
  self.executionsByDemandId[demand.id] = execution

  local executor = self
  local previousSpawned = self.brigade.OnAfterAssetSpawned
  self.brigade.OnAfterAssetSpawned = function(brigade, From, Event, To, Group, Asset, Request)
    if previousSpawned then previousSpawned(brigade, From, Event, To, Group, Asset, Request) end
    if execution.closed or execution.loadingMarked then return end
    execution.loadingMarked = true
    executor.store:MarkLoading(execution.transactionId)
    executor.registry:SetReservationState(execution.demandId, "LOADING", {
      transactionId = execution.transactionId,
      carrierEntityId = executor.carrierEntityId,
    })
    executor:_log("resupply loading demandId=" .. tostring(execution.demandId))
  end

  local previousArmyMission = self.brigade.OnAfterArmyOnMission
  self.brigade.OnAfterArmyOnMission = function(brigade, From, Event, To, ArmyGroup, Mission)
    if previousArmyMission then previousArmyMission(brigade, From, Event, To, ArmyGroup, Mission) end
    if Mission ~= execution.mission or not ArmyGroup or execution.closed then return end

    executor:_attachArmyLifecycle(execution, ArmyGroup)

    local transactionState = executor.store:GetTransaction(execution.transactionId)
    if transactionState.status ~= executor.campaignState.TransactionStatus.LOADING then
      executor:_failExecution(execution, "AMMO_RESUPPLY_ARMY_ON_MISSION_BEFORE_LOADING")
      return
    end

    executor.store:MarkInTransit(execution.transactionId)
    executor.registry:SetReservationState(execution.demandId, "IN_TRANSIT", {
      transactionId = execution.transactionId,
      carrierEntityId = executor.carrierEntityId,
    })
    local current = executor.registry:Get(execution.demandId)
    if current and current.status == executor.missionDemand.Status.AI_ASSIGNED then
      executor.registry:Activate(execution.demandId)
    end
    executor:_log("resupply in transit demandId=" .. tostring(execution.demandId))
  end

  self.registry:SetReservationState(demand.id, "RESERVED", {
    transactionId = transaction.transactionId,
    carrierEntityId = self.carrierEntityId,
  })
  self.registry:AssignAI(demand.id, self.assigneeId)
  self.brigade:AddMission(mission)

  self:_log(string.format(
    "resupply started demandId=%s transferId=%s resourceId=%s quantity=%s origin=%s destination=%s newlyReserved=%s",
    tostring(demand.id), tostring(transaction.transactionId), tostring(target.resourceId),
    tostring(target.requestedQuantity), tostring(demand.origin), tostring(target.nodeId), tostring(reserved)
  ))
  return execution, true, nil
end

function Instance:GetExecution(demandId)
  requireNonEmptyString(demandId, "demandId")
  return self.executionsByDemandId[demandId]
end

return Executor
