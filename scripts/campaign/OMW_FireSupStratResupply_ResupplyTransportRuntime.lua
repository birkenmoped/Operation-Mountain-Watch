-- Operation Mountain Watch - MOOSE-first physical resupply transport runtime.
--
-- Creates Base-compatible GROUND_RESUPPLY/AIR_RESUPPLY adapters using public
-- OPSTRANSPORT + COMMANDER:AddOpsTransport(). Strategic resource authority and
-- settlement remain outside this module. Carrier/provider selection remains MOOSE.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-TRANSPORT-RUNTIME-1"
local TAG = "[OMW][FireSupStratResupply.ResupplyTransportRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value,label) if type(value)~="table" then fail(label .. " must be a table") end return value end
local function needFunction(container,name,label)
  if type(container)~="table" or type(container[name])~="function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end

function Runtime.New(spec)
  needTable(spec,"spec")
  local commanderBridge=needTable(spec.commanderBridge,"commanderBridge")
  local storageTransportFactory=needTable(spec.storageTransportFactory,"storageTransportFactory")
  needFunction(commanderBridge,"New","commanderBridge")
  needFunction(storageTransportFactory,"New","storageTransportFactory")
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end

  local adapters={}
  local factories={}

  local function add(supportType, commander, resolver)
    if commander==nil and resolver==nil then return end
    needTable(commander,supportType .. " commander")
    needFunction(commander,"AddOpsTransport",supportType .. " commander")
    if type(resolver)~="function" then fail(supportType .. " resolveTransport must be a function") end
    local factory=storageTransportFactory.New({resolveTransport=resolver,logger=spec.logger})
    local bridge=commanderBridge.New({
      commander=commander,
      kind=commanderBridge.Kind and commanderBridge.Kind.TRANSPORT or "TRANSPORT",
      factory=function(demand,context) return factory:Create(demand,context) end,
      logger=spec.logger,
    })
    adapters[supportType]=bridge
    factories[supportType]=factory
  end

  add("GROUND_RESUPPLY",spec.groundCommander,spec.resolveGroundTransport)
  add("AIR_RESUPPLY",spec.airCommander,spec.resolveAirTransport)
  if next(adapters)==nil then fail("at least one physical resupply transport mode must be configured") end

  return setmetatable({adapters=adapters,factories=factories,logger=spec.logger},Instance)
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
