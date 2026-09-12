-- Operation Mountain Watch - MOOSE-first local QRF mission factory.
--
-- Converts one QRF demand into a public Ground AUFTRAG. The caller supplies the
-- response coordinate; this module does not infer tactical geometry and does not
-- select cohorts/assets. The resolved local LEGION/BRIGADE performs recruitment.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-1"

local TAG = "[OMW][FireSupStratResupply.QrfMissionFactory]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function needTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function needFunction(value, label)
  if type(value) ~= "function" then fail(label .. " must be a function") end
  return value
end

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function Factory.New(spec)
  needTable(spec, "spec")
  local resolveCoordinate = needFunction(spec.resolveCoordinate, "resolveCoordinate")
  local requiredAssetsMin = spec.requiredAssetsMin or 1
  local requiredAssetsMax = spec.requiredAssetsMax or requiredAssetsMin
  if not finite(requiredAssetsMin) or requiredAssetsMin < 1 then fail("requiredAssetsMin must be at least one") end
  if not finite(requiredAssetsMax) or requiredAssetsMax < requiredAssetsMin then fail("requiredAssetsMax must be >= requiredAssetsMin") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  return setmetatable({
    resolveCoordinate = resolveCoordinate,
    requiredAssetsMin = requiredAssetsMin,
    requiredAssetsMax = requiredAssetsMax,
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Create(demand, context, legion)
  needTable(demand, "demand")
  if demand.supportType ~= "QRF" then fail("supportType QRF is required") end
  if type(demand.demandId) ~= "string" or demand.demandId == "" then fail("demandId is required") end

  local coordinate, reason = self.resolveCoordinate(demand, context, legion)
  if coordinate == nil then return nil, false, reason or "QRF_RESPONSE_COORDINATE_UNAVAILABLE" end
  needTable(coordinate, "QRF response coordinate")

  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewONGUARD) ~= "function" then fail("MOOSE AUFTRAG:NewONGUARD() is required") end
  local mission = AUFTRAG:NewONGUARD(coordinate)
  needTable(mission, "QRF AUFTRAG")
  if type(mission.SetTeleport) ~= "function" then fail("QRF AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets) ~= "function" then fail("QRF AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority) ~= "function" then fail("QRF AUFTRAG:SetPriority() is required") end
  if type(mission.Cancel) ~= "function" then fail("QRF AUFTRAG:Cancel() is required") end

  -- Visible teleporting is forbidden for OMW Ground response missions.
  mission:SetTeleport(false)
  mission:SetRequiredAssets(self.requiredAssetsMin, self.requiredAssetsMax)
  if finite(demand.priority) then mission:SetPriority(demand.priority, false) end

  self:_log(string.format(
    "created local QRF mission demandId=%s siteId=%s requiredAssets=%s-%s priority=%s",
    tostring(demand.demandId), tostring(demand.siteId), tostring(self.requiredAssetsMin),
    tostring(self.requiredAssetsMax), tostring(demand.priority)))
  return mission, true, nil
end

return Factory
