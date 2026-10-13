-- Operation Mountain Watch - MOOSE-first physical resupply transport runtime.
--
-- Preserves the accepted Stage-3 STORAGE/OPSTRANSPORT carrier recruitment and
-- rotary transport-corridor pattern inside the generic Base.
--
-- CampaignState settlement is attached before recruitment. MOOSE COMMANDER/LEGION
-- remains the concrete carrier-selection authority. When the caller supplies an
-- explicit resolved owner-authored corridor, this runtime binds the existing shared
-- OpsTransportCorridorAdapter to the MOOSE-selected carrier after AssetSpawned.
--
-- No cohort, squadron, airwing, brigade or concrete carrier is selected by OMW.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-TRANSPORT-RUNTIME-5"
local TAG = "[OMW][FireSupStratResupply.ResupplyTransportRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value,label) if type(value)~="table" then fail(label .. " must be a table") end return value end
local function needFunction(container,name,label)
  if type(container)~="table" or type(container[name])~="function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function finitePositive(value)
  return type(value)=="number" and value==value and value>0 and value<math.huge
end
local function hasEntries(value)
  return type(value)=="table" and next(value)~=nil
end
local function entryCount(value)
  local count=0
  for _ in pairs(value or {}) do count=count+1 end
  return count
end

function Runtime.New(spec)
  needTable(spec,"spec")
  local storageTransportFactory=needTable(spec.storageTransportFactory,"storageTransportFactory")
  needFunction(storageTransportFactory,"New","storageTransportFactory")

  local transportCorridorAdapter=spec.transportCorridorAdapter
  if transportCorridorAdapter~=nil then
    needTable(transportCorridorAdapter,"transportCorridorAdapter")
    needFunction(transportCorridorAdapter,"Bind","transportCorridorAdapter")
  end

  if spec.settlement~=nil then
    needTable(spec.settlement,"settlement")
    needFunction(spec.settlement,"Attach","settlement")
  end
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end

  local adapters={}
  local factories={}
  local settlement=spec.settlement
  local logger=spec.logger
  local routePendingByAsset={}
  local routeHooks={}

  local function log(message)
    if logger then logger(TAG .. " " .. tostring(message)) end
  end

  local function clearPending(routeState)
    for _,asset in pairs(routeState.assets or {}) do
      if routePendingByAsset[asset]==routeState then routePendingByAsset[asset]=nil end
    end
  end

  local function bindRoute(asset,routeState)
    if routeState.bound or routeState.failed then return routeState.bound,routeState.failureReason end
    local flightGroup=asset and asset.flightgroup or nil
    if type(flightGroup)~="table" then return false,"FLIGHTGROUP_NOT_READY" end

    local descriptor=routeState.descriptor
    local options={}
    for key,value in pairs(descriptor.corridorOptions or {}) do options[key]=value end
    local ownerOutbound=options.onOutboundInstalled
    local ownerReturn=options.onReturnInstalled
    local ownerError=options.onError

    options.onOutboundInstalled=function(binding)
      routeState.outboundInstalled=true
      routeState.binding=binding
      if type(ownerOutbound)=="function" then ownerOutbound(binding,routeState.demand,asset) end
      log(string.format("corridor outbound installed demandId=%s asset=%s",
        tostring(routeState.demand.demandId),tostring(asset.spawngroupname)))
    end
    options.onReturnInstalled=function(binding)
      routeState.returnInstalled=true
      routeState.binding=binding
      if type(ownerReturn)=="function" then ownerReturn(binding,routeState.demand,asset) end
      log(string.format("corridor return installed demandId=%s asset=%s",
        tostring(routeState.demand.demandId),tostring(asset.spawngroupname)))
    end
    options.onError=function(reason)
      routeState.failed=true
      routeState.failureReason=reason
      clearPending(routeState)
      if type(ownerError)=="function" then ownerError(reason,routeState.demand,asset) end
      if type(routeState.transport.Cancel)=="function" then routeState.transport:Cancel() end
      log(string.format("corridor failed demandId=%s asset=%s reason=%s",
        tostring(routeState.demand.demandId),tostring(asset.spawngroupname),tostring(reason)))
    end

    local binding,ok,reason=transportCorridorAdapter.Bind(
      flightGroup,
      routeState.transport,
      descriptor.resolvedCorridor,
      descriptor.corridorAltitudeFtAgl,
      options)

    if ok~=true or binding==nil then
      routeState.failed=true
      routeState.failureReason=reason or "TRANSPORT_CORRIDOR_BIND_FAILED"
      clearPending(routeState)
      if type(routeState.transport.Cancel)=="function" then routeState.transport:Cancel() end
      log(string.format("corridor bind failed demandId=%s asset=%s reason=%s",
        tostring(routeState.demand.demandId),tostring(asset.spawngroupname),tostring(routeState.failureReason)))
      return false,routeState.failureReason
    end

    routeState.bound=true
    routeState.binding=binding
    clearPending(routeState)
    log(string.format("corridor bound demandId=%s asset=%s",
      tostring(routeState.demand.demandId),tostring(asset.spawngroupname)))
    return true,nil
  end

  local function ensureRouteHook(legion)
    if routeHooks[legion] then return end
    local previous=legion.OnAfterAssetSpawned
    legion.OnAfterAssetSpawned=function(self,From,Event,To,group,asset,request)
      if previous then previous(self,From,Event,To,group,asset,request) end
      local routeState=routePendingByAsset[asset]
      if routeState then bindRoute(asset,routeState) end
    end
    routeHooks[legion]=true
  end

  local function prepareRoute(descriptor,transport,demand,assets,legions,routeMandatory)
    if routeMandatory and descriptor.resolvedCorridor==nil then
      return nil,"TRANSPORT_CORRIDOR_REQUIRED"
    end
    if descriptor.resolvedCorridor==nil then return nil,nil end
    if transportCorridorAdapter==nil then return nil,"TRANSPORT_CORRIDOR_ADAPTER_UNAVAILABLE" end
    if not finitePositive(descriptor.corridorAltitudeFtAgl) then
      return nil,"TRANSPORT_CORRIDOR_ALTITUDE_REQUIRED"
    end
    if descriptor.corridorOptions~=nil and type(descriptor.corridorOptions)~="table" then
      return nil,"TRANSPORT_CORRIDOR_OPTIONS_INVALID"
    end

    -- The inherited Stage-3 routed STORAGE path is a one-carrier contract.
    -- Multi-carrier splitting/routing has not been accepted and must not be implied.
    if entryCount(assets)~=1 then return nil,"TRANSPORT_CORRIDOR_SINGLE_CARRIER_REQUIRED" end

    local routeState={
      demand=demand,
      transport=transport,
      descriptor=descriptor,
      assets=assets,
      legions=legions,
      bound=false,
      failed=false,
      outboundInstalled=false,
      returnInstalled=false,
    }

    for _,legion in pairs(legions) do
      if type(legion)~="table" then return nil,"TRANSPORT_SELECTED_LEGION_INVALID" end
      ensureRouteHook(legion)
    end
    for _,asset in pairs(assets) do
      routePendingByAsset[asset]=routeState
      if asset.flightgroup~=nil then
        local ok,reason=bindRoute(asset,routeState)
        if not ok and reason~="FLIGHTGROUP_NOT_READY" then return nil,reason end
      end
    end
    return routeState,nil
  end

  local function add(supportType,commander,resolver)
    if commander==nil and resolver==nil then return end
    needTable(commander,supportType .. " commander")
    needFunction(commander,"RecruitAssetsForTransport",supportType .. " commander")
    needFunction(commander,"TransportAssign",supportType .. " commander")
    if type(resolver)~="function" then fail(supportType .. " resolveTransport must be a function") end

    local factory=storageTransportFactory.New({resolveTransport=resolver,logger=logger})
    local adapter={items={}}

    function adapter:Dispatch(demand,context)
      needTable(demand,"demand")
      if type(demand.demandId)~="string" or demand.demandId=="" then fail("demandId is required") end
      if self.items[demand.demandId] then return self.items[demand.demandId],false,"ALREADY_DISPATCHED" end

      local transport,created,reason,descriptor=factory:Create(demand,context)
      if transport==nil then return nil,false,reason end
      if created==false then return transport,false,reason end
      needFunction(transport,"AddAsset","transport")
      needFunction(transport,"Cancel","transport")
      needTable(descriptor,"storage transport descriptor")

      local routeMandatory=(supportType=="AIR_RESUPPLY") or descriptor.routeRequired==true
      if routeMandatory and descriptor.resolvedCorridor==nil then
        transport:Cancel()
        return nil,false,"TRANSPORT_CORRIDOR_REQUIRED"
      end

      if settlement~=nil then
        local binding,attached,settlementReason=settlement:Attach(transport,demand,context,descriptor)
        if binding==nil or (attached==false and settlementReason~="ALREADY_ATTACHED") then
          transport:Cancel()
          return nil,false,settlementReason or "STRATEGIC_SETTLEMENT_NOT_ATTACHED"
        end
      end

      local itemWeightKg=descriptor.cargoWeightKg or 1
      local totalWeightKg=descriptor.cargoAmount*itemWeightKg
      if not finitePositive(totalWeightKg) then
        transport:Cancel()
        return nil,false,"PHYSICAL_STORAGE_WEIGHT_UNAVAILABLE"
      end

      local recruited,assets,legions=commander:RecruitAssetsForTransport(
        transport,totalWeightKg,totalWeightKg)

      if recruited~=true or not hasEntries(assets) or not hasEntries(legions) then
        if recruited==true and hasEntries(assets) and type(LEGION)=="table" and type(LEGION.UnRecruitAssets)=="function" then
          LEGION.UnRecruitAssets(assets)
        end
        transport:Cancel()
        log(string.format(
          "carrier recruitment unavailable demandId=%s siteId=%s supportType=%s totalWeightKg=%s",
          tostring(demand.demandId),tostring(demand.siteId),tostring(supportType),tostring(totalWeightKg)))
        return nil,false,"MOOSE_TRANSPORT_CARRIER_UNAVAILABLE"
      end

      local routeState,routeReason=prepareRoute(descriptor,transport,demand,assets,legions,routeMandatory)
      if routeReason~=nil then
        if type(LEGION)=="table" and type(LEGION.UnRecruitAssets)=="function" then LEGION.UnRecruitAssets(assets) end
        transport:Cancel()
        return nil,false,routeReason
      end

      for _,asset in pairs(assets) do transport:AddAsset(asset) end
      commander:TransportAssign(transport,legions)

      local handle={
        runtime=transport,
        assets=assets,
        legions=legions,
        routeState=routeState,
        totalWeightKg=totalWeightKg,
        cancelRequested=false,
      }
      function handle:Cancel()
        if self.cancelRequested then return false end
        self.cancelRequested=true
        if self.routeState then clearPending(self.routeState) end
        self.runtime:Cancel()
        return true
      end

      self.items[demand.demandId]=handle
      log(string.format(
        "transport assigned demandId=%s siteId=%s supportType=%s assets=%d totalWeightKg=%s routed=%s",
        tostring(demand.demandId),tostring(demand.siteId),tostring(supportType),entryCount(assets),
        tostring(totalWeightKg),tostring(routeState~=nil)))
      return handle,true,nil
    end

    adapters[supportType]=adapter
    factories[supportType]=factory
  end

  add("GROUND_RESUPPLY",spec.groundCommander,spec.resolveGroundTransport)
  add("AIR_RESUPPLY",spec.airCommander,spec.resolveAirTransport)
  if next(adapters)==nil then fail("at least one physical resupply transport mode must be configured") end

  return setmetatable({
    adapters=adapters,
    factories=factories,
    settlement=settlement,
    transportCorridorAdapter=transportCorridorAdapter,
    logger=logger,
  },Instance)
end

function Instance:GetAdapters()
  local result={}
  for supportType,adapter in pairs(self.adapters) do result[supportType]=adapter end
  return result
end

function Instance:GetAdapter(supportType)
  return self.adapters[supportType]
end

return Runtime
