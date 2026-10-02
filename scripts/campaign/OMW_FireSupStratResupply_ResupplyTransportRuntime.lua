-- Operation Mountain Watch - MOOSE-first physical resupply transport runtime.
--
-- Reconciles the accepted Stage-3 STORAGE/OPSTRANSPORT recruitment pattern into
-- the generic Base. CampaignState settlement is attached before recruitment.
-- The concrete carrier remains selected by MOOSE COMMANDER/LEGION logic.
--
-- Important pinned-MOOSE boundary:
-- COMMANDER:AddOpsTransport() alone cannot recruit a STORAGE-only transport because
-- the queue path derives weight from GetCargoOpsGroups(false). Therefore this
-- runtime uses the public COMMANDER:RecruitAssetsForTransport(...) selection path,
-- then hands the MOOSE-selected assets back to COMMANDER:TransportAssign(...).
-- No cohort, squadron, airwing, brigade or concrete carrier is selected by OMW.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-TRANSPORT-RUNTIME-3"
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

function Runtime.New(spec)
  needTable(spec,"spec")
  local storageTransportFactory=needTable(spec.storageTransportFactory,"storageTransportFactory")
  needFunction(storageTransportFactory,"New","storageTransportFactory")
  if spec.settlement~=nil then
    needTable(spec.settlement,"settlement")
    needFunction(spec.settlement,"Attach","settlement")
  end
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end

  local adapters={}
  local factories={}
  local settlement=spec.settlement
  local logger=spec.logger

  local function log(message)
    if logger then logger(TAG .. " " .. tostring(message)) end
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

      for _,asset in pairs(assets) do
        transport:AddAsset(asset)
      end
      commander:TransportAssign(transport,legions)

      local handle={
        runtime=transport,
        assets=assets,
        legions=legions,
        totalWeightKg=totalWeightKg,
        cancelRequested=false,
      }
      function handle:Cancel()
        if self.cancelRequested then return false end
        self.cancelRequested=true
        self.runtime:Cancel()
        return true
      end

      self.items[demand.demandId]=handle
      log(string.format(
        "transport assigned demandId=%s siteId=%s supportType=%s assets=%d totalWeightKg=%s",
        tostring(demand.demandId),tostring(demand.siteId),tostring(supportType),#assets,tostring(totalWeightKg)))
      return handle,true,nil
    end

    adapters[supportType]=adapter
    factories[supportType]=factory
  end

  add("GROUND_RESUPPLY",spec.groundCommander,spec.resolveGroundTransport)
  add("AIR_RESUPPLY",spec.airCommander,spec.resolveAirTransport)
  if next(adapters)==nil then fail("at least one physical resupply transport mode must be configured") end

  return setmetatable({adapters=adapters,factories=factories,settlement=settlement,logger=logger},Instance)
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
