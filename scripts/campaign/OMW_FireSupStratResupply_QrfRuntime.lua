-- Operation Mountain Watch - local QRF runtime assembly.
--
-- Wires incident-scoped QRF demands to the site-local MOOSE BRIGADE without
-- operational asset preselection. Tactical response coordinates remain injected.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-1"
local TAG = "[OMW][FireSupStratResupply.QrfRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needCallable(value, label) if type(value) ~= "function" then fail(label .. " must be a function") end return value end

function Runtime.New(spec)
  needTable(spec, "spec")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local brigades = needTable(spec.brigades, "brigades")
  local qrfMissionFactory = needTable(spec.qrfMissionFactory, "qrfMissionFactory")
  local legionBridge = needTable(spec.legionBridge, "legionBridge")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  needFunction(qrfMissionFactory, "New", "qrfMissionFactory")
  needFunction(legionBridge, "New", "legionBridge")
  local resolveCoordinate = needCallable(spec.resolveCoordinate, "resolveCoordinate")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  for siteId in pairs(siteRegistry.Sites) do
    needTable(brigades[siteId], "brigades[" .. tostring(siteId) .. "]")
  end

  local factory = qrfMissionFactory.New({
    resolveCoordinate = resolveCoordinate,
    requiredAssetsMin = spec.requiredAssetsMin or 1,
    requiredAssetsMax = spec.requiredAssetsMax or (spec.requiredAssetsMin or 1),
    logger = spec.logger,
  })
  local bridge = legionBridge.New({
    resolveLegion = function(siteId)
      local brigade = brigades[siteId]
      if not brigade then return nil, "SITE_LEGION_NOT_CONFIGURED" end
      return brigade
    end,
    factory = function(demand, context, legion)
      return factory:Create(demand, context, legion)
    end,
    logger = spec.logger,
  })

  return setmetatable({
    siteRegistry = siteRegistry,
    brigades = brigades,
    factory = factory,
    dispatchBridge = bridge,
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Dispatch(demand, context)
  if type(demand) ~= "table" then fail("demand must be a table") end
  if demand.supportType ~= "QRF" then fail("supportType QRF is required") end
  if not self.siteRegistry.Sites[demand.siteId] then return nil, false, "SITE_NOT_FOUND" end
  return self.dispatchBridge:Dispatch(demand, context)
end

return Runtime
