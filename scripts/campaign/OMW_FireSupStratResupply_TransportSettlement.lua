-- Operation Mountain Watch - CampaignState settlement for one MOOSE STORAGE transport.
--
-- CampaignState remains strategic resource authority. MOOSE OPSTRANSPORT remains
-- physical transport authority. This adapter reserves one strategic transfer and
-- settles only from confirmed MOOSE/physical lifecycle evidence. It has no retry.

local Settlement = {}
local Instance = {}
Instance.__index = Instance

Settlement.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-TRANSPORT-SETTLEMENT-1"
local TAG = "[OMW][FireSupStratResupply.TransportSettlement]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value,label) if type(value)~="table" then fail(label .. " must be a table") end return value end
local function needFunction(container,name,label)
  if type(container)~="table" or type(container[name])~="function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function finitePositive(value) return type(value)=="number" and value==value and value>0 and value<math.huge end

local function chain(object,name,callback)
  local previous=object[name]
  if previous~=nil and type(previous)~="function" then fail(name .. " must be a function when present") end
  object[name]=function(self,...)
    if previous then previous(self,...) end
    return callback(self,...)
  end
end

function Settlement.New(spec)
  needTable(spec,"spec")
  local campaignState=needTable(spec.campaignState,"campaignState")
  local store=needTable(spec.store,"store")
  if type(campaignState.TransactionKind)~="table" or campaignState.TransactionKind.TRANSFER==nil then fail("campaignState.TransactionKind.TRANSFER is required") end
  if type(campaignState.TransactionStatus)~="table" then fail("campaignState.TransactionStatus is required") end
  for _,name in ipairs({"ReserveResource","MarkLoading","MarkInTransit","MarkDelivered","MarkLost","Cancel","GetTransaction"}) do
    needFunction(store,name,"store")
  end
  if spec.transactionIdFactory~=nil and type(spec.transactionIdFactory)~="function" then fail("transactionIdFactory must be a function when provided") end
  if spec.onTerminal~=nil and type(spec.onTerminal)~="function" then fail("onTerminal must be a function when provided") end
  if spec.onPartial~=nil and type(spec.onPartial)~="function" then fail("onPartial must be a function when provided") end
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end
  return setmetatable({campaignState=campaignState,store=store,transactionIdFactory=spec.transactionIdFactory,onTerminal=spec.onTerminal,onPartial=spec.onPartial,logger=spec.logger,bindings={}},Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:_transactionId(demand)
  if self.transactionIdFactory then return self.transactionIdFactory(demand) end
  return "RESUPPLY|" .. tostring(demand.demandId)
end

function Instance:_storageOutcome(transport,quantity)
  needFunction(transport,"GetCargoStorages","transport")
  local storages=transport:GetCargoStorages()
  if type(storages)~="table" or #storages~=1 then return nil,"STORAGE_CARGO_CARDINALITY_NOT_ONE" end
  local storage=storages[1]
  if type(storage)~="table" then return nil,"STORAGE_CARGO_INVALID" end
  local total=storage.cargoAmount
  local delivered=storage.cargoDelivered or 0
  local lost=storage.cargoLost or 0
  if not finitePositive(total) or total~=quantity then return nil,"STORAGE_CARGO_AMOUNT_MISMATCH" end
  if delivered==total and lost==0 then return "DELIVERED",nil,{total=total,delivered=delivered,lost=lost} end
  if lost==total and delivered==0 then return "LOST",nil,{total=total,delivered=delivered,lost=lost} end
  if delivered+lost>=total then return "PARTIAL",nil,{total=total,delivered=delivered,lost=lost} end
  return "INCOMPLETE",nil,{total=total,delivered=delivered,lost=lost}
end

function Instance:Attach(transport,demand,context,descriptor)
  needTable(transport,"transport")
  needTable(demand,"demand")
  needTable(descriptor,"descriptor")
  if type(demand.demandId)~="string" or demand.demandId=="" then fail("demandId is required") end
  if type(demand.resourceId)~="string" or demand.resourceId=="" then fail("resourceId is required") end
  if not finitePositive(demand.quantity) then fail("quantity must be positive finite") end
  local tactical=needTable(demand.tacticalContext,"demand.tacticalContext")
  local originNodeId=tactical.supplyParentNodeId
  local destinationNodeId=tactical.campaignNodeId
  if type(originNodeId)~="string" or originNodeId=="" then return nil,false,"SUPPLY_PARENT_NODE_MISSING" end
  if type(destinationNodeId)~="string" or destinationNodeId=="" then return nil,false,"DESTINATION_NODE_MISSING" end
  if type(descriptor.installInTransitObserver)~="function" then return nil,false,"IN_TRANSIT_OBSERVER_REQUIRED" end
  needFunction(transport,"GetCargoStorages","transport")

  local transactionId=self:_transactionId(demand)
  if type(transactionId)~="string" or transactionId=="" then fail("transactionIdFactory must return non-empty string") end
  if self.bindings[demand.demandId] then return self.bindings[demand.demandId],false,"ALREADY_ATTACHED" end

  local snapshot=self.store:GetResource(originNodeId,demand.resourceId)
  local transaction,created=self.store:ReserveResource({
    transactionId=transactionId,
    reservationId=transactionId,
    missionDemandId=demand.demandId,
    kind=self.campaignState.TransactionKind.TRANSFER,
    resourceId=demand.resourceId,
    quantity=demand.quantity,
    canonicalUnit=snapshot.canonicalUnit,
    originNodeId=originNodeId,
    destinationNodeId=destinationNodeId,
  })

  local binding={demand=demand,transport=transport,descriptor=descriptor,transactionId=transactionId,terminal=nil}
  self.bindings[demand.demandId]=binding
  local adapter=self

  function binding:ConfirmInTransit(evidence)
    local current=adapter.store:GetTransaction(self.transactionId)
    local status=current.status
    local S=adapter.campaignState.TransactionStatus
    if status==S.IN_TRANSIT or status==S.DELIVERED or status==S.LOST then return current,false end
    local updated,changed=adapter.store:MarkInTransit(self.transactionId)
    adapter:_log(string.format("in transit demandId=%s transactionId=%s changed=%s evidence=%s",tostring(self.demand.demandId),self.transactionId,tostring(changed),tostring(evidence)))
    return updated,changed
  end

  function binding:_terminal(outcome,detail)
    if self.terminal then return adapter.store:GetTransaction(self.transactionId),false,"ALREADY_TERMINAL" end
    local S=adapter.campaignState.TransactionStatus
    local current=adapter.store:GetTransaction(self.transactionId)
    local updated,changed,reason
    if outcome=="DELIVERED" then
      if current.status~=S.IN_TRANSIT then return current,false,"DELIVERY_BEFORE_CONFIRMED_IN_TRANSIT" end
      updated,changed=adapter.store:MarkDelivered(self.transactionId)
      self.terminal="DELIVERED"
    elseif outcome=="LOST" then
      if current.status~=S.IN_TRANSIT then return current,false,"LOSS_BEFORE_CONFIRMED_IN_TRANSIT" end
      updated,changed=adapter.store:MarkLost(self.transactionId)
      self.terminal="LOST"
    elseif outcome=="CANCELLED" then
      if current.status~=S.RESERVED and current.status~=S.LOADING then return current,false,"CANCEL_AFTER_CONFIRMED_IN_TRANSIT" end
      updated,changed=adapter.store:Cancel(self.transactionId)
      self.terminal="CANCELLED"
    else
      return current,false,"UNSUPPORTED_TERMINAL_OUTCOME"
    end
    adapter:_log(string.format("terminal demandId=%s transactionId=%s outcome=%s changed=%s",tostring(self.demand.demandId),self.transactionId,outcome,tostring(changed)))
    if adapter.onTerminal then adapter.onTerminal(self.demand,outcome,updated,detail,self) end
    return updated,changed,nil
  end

  descriptor.installInTransitObserver(transport,function(evidence) return binding:ConfirmInTransit(evidence) end,demand,context)

  chain(transport,"OnAfterExecuting",function()
    local current=adapter.store:GetTransaction(transactionId)
    local S=adapter.campaignState.TransactionStatus
    if current.status==S.RESERVED then adapter.store:MarkLoading(transactionId) end
  end)
  chain(transport,"OnAfterDelivered",function(selfTransport)
    local outcome,outcomeReason,detail=adapter:_storageOutcome(selfTransport,demand.quantity)
    if not outcome then adapter:_log("delivery outcome unresolved demandId="..tostring(demand.demandId).." reason="..tostring(outcomeReason));return end
    if outcome=="DELIVERED" or outcome=="LOST" then
      binding:_terminal(outcome,detail)
    elseif outcome=="PARTIAL" then
      adapter:_log(string.format("partial storage outcome demandId=%s delivered=%s lost=%s total=%s",tostring(demand.demandId),tostring(detail.delivered),tostring(detail.lost),tostring(detail.total)))
      if adapter.onPartial then adapter.onPartial(demand,detail,binding) end
    end
  end)
  chain(transport,"OnAfterCancel",function()
    local current=adapter.store:GetTransaction(transactionId)
    local S=adapter.campaignState.TransactionStatus
    if current.status==S.RESERVED or current.status==S.LOADING then binding:_terminal("CANCELLED",{source="OPSTRANSPORT_CANCEL"}) end
  end)

  self:_log(string.format("reserved demandId=%s transactionId=%s origin=%s destination=%s resourceId=%s quantity=%s created=%s",
    tostring(demand.demandId),transactionId,originNodeId,destinationNodeId,demand.resourceId,tostring(demand.quantity),tostring(created)))
  return binding,true,nil,transaction
end

function Instance:GetBinding(demandId)
  return self.bindings[demandId]
end

return Settlement
