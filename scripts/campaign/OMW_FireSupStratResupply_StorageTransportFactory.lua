-- Operation Mountain Watch - MOOSE-first strategic resupply STORAGE transport factory.
--
-- Builds one public OPSTRANSPORT storage assignment from caller-resolved physical
-- transport data. It does not choose carrier assets, legions, routes, strategic
-- resource quantities or settlement outcomes. COMMANDER/LEGION owns recruitment.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-STORAGE-TRANSPORT-FACTORY-1"
local TAG = "[OMW][FireSupStratResupply.StorageTransportFactory]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function finitePositive(value) return type(value)=="number" and value==value and value>0 and value<math.huge end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end

function Factory.New(spec)
  needTable(spec, "spec")
  if type(spec.resolveTransport) ~= "function" then fail("resolveTransport must be a function") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  return setmetatable({ resolveTransport=spec.resolveTransport, logger=spec.logger }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Create(demand, context)
  needTable(demand, "demand")
  if demand.supportType ~= "GROUND_RESUPPLY" and demand.supportType ~= "AIR_RESUPPLY" then
    fail("supportType GROUND_RESUPPLY or AIR_RESUPPLY is required")
  end
  if type(demand.demandId) ~= "string" or demand.demandId == "" then fail("demandId is required") end
  if not finitePositive(demand.quantity) then fail("demand.quantity must be positive finite") end

  local descriptor, reason = self.resolveTransport(demand, context)
  if descriptor == nil then return nil, false, reason or "STORAGE_TRANSPORT_DESCRIPTOR_UNAVAILABLE" end
  needTable(descriptor, "storage transport descriptor")

  for _, name in ipairs({"pickupZone", "deployZone", "sourceStorage", "destinationStorage"}) do
    needTable(descriptor[name], "descriptor." .. name)
  end
  if descriptor.cargoType == nil then fail("descriptor.cargoType is required") end
  local amount = descriptor.cargoAmount or demand.quantity
  if not finitePositive(amount) then fail("descriptor.cargoAmount must be positive finite") end
  if amount ~= demand.quantity then fail("descriptor.cargoAmount must equal demand.quantity") end
  local cargoWeightKg = descriptor.cargoWeightKg
  if cargoWeightKg ~= nil and not finitePositive(cargoWeightKg) then fail("descriptor.cargoWeightKg must be positive finite when provided") end
  local carriersMin = descriptor.requiredCarriersMin or 1
  local carriersMax = descriptor.requiredCarriersMax or carriersMin
  if not finitePositive(carriersMin) then fail("descriptor.requiredCarriersMin must be positive finite") end
  if not finitePositive(carriersMax) or carriersMax < carriersMin then fail("descriptor.requiredCarriersMax must be >= requiredCarriersMin") end

  if type(OPSTRANSPORT) ~= "table" or type(OPSTRANSPORT.New) ~= "function" then fail("MOOSE OPSTRANSPORT:New() is required") end
  local transport = OPSTRANSPORT:New(nil, descriptor.pickupZone, descriptor.deployZone)
  needTable(transport, "OPSTRANSPORT")
  for _, name in ipairs({"AddCargoStorage", "SetRequiredCarriers", "SetPriority", "Cancel"}) do
    if type(transport[name]) ~= "function" then fail("OPSTRANSPORT:" .. name .. "() is required") end
  end

  transport:AddCargoStorage(
    descriptor.sourceStorage,
    descriptor.destinationStorage,
    descriptor.cargoType,
    amount,
    cargoWeightKg)
  transport:SetRequiredCarriers(carriersMin, carriersMax)
  if finite(demand.priority) then
    -- OPSTRANSPORT signature is (priority, importance, urgent).
    transport:SetPriority(demand.priority, nil, false)
  end

  self:_log(string.format(
    "created storage transport demandId=%s siteId=%s supportType=%s resourceId=%s amount=%s carriers=%s-%s",
    tostring(demand.demandId), tostring(demand.siteId), tostring(demand.supportType), tostring(demand.resourceId),
    tostring(amount), tostring(carriersMin), tostring(carriersMax)))
  return transport, true, nil, descriptor
end

return Factory
