-- Operation Mountain Watch - MOOSE-first local QRF mission factory.
--
-- Reuses the accepted Honaker QRF mission contract:
-- AUFTRAG:NewONGUARD(initial threat coordinate) + SetEngageDetected(...)
-- + SetReturnToLegion(true). The transient hostile group is used only to derive
-- the initial QRF guard coordinate and correlation evidence. MOOSE remains the
-- operational recruitment, detection, engagement and physical lifecycle authority.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-5"

local TAG = "[OMW][FireSupStratResupply.QrfMissionFactory]"
local DEFAULT_ENGAGE_RANGE_NM = 5
local DEFAULT_TARGET_TYPES = { "Ground Units" }

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

local function validateRequirement(value, label)
  if value ~= nil and type(value) ~= "string" and type(value) ~= "table" then
    fail(label .. " must be a string or table when provided")
  end
  return value
end

function Factory.New(spec)
  needTable(spec, "spec")
  local resolveTarget = needFunction(spec.resolveTarget, "resolveTarget")
  local resolveEngageZone = needFunction(spec.resolveEngageZone, "resolveEngageZone")
  local requiredAssetsMin = spec.requiredAssetsMin or 1
  local requiredAssetsMax = spec.requiredAssetsMax or requiredAssetsMin
  if not finite(requiredAssetsMin) or requiredAssetsMin < 1 then fail("requiredAssetsMin must be at least one") end
  if not finite(requiredAssetsMax) or requiredAssetsMax < requiredAssetsMin then fail("requiredAssetsMax must be >= requiredAssetsMin") end
  local engageRangeNm = spec.engageRangeNm or DEFAULT_ENGAGE_RANGE_NM
  if not finite(engageRangeNm) or engageRangeNm <= 0 then fail("engageRangeNm must be positive") end
  local targetTypes = spec.targetTypes or DEFAULT_TARGET_TYPES
  if type(targetTypes) ~= "table" or #targetTypes < 1 then fail("targetTypes must be a non-empty table") end
  local requiredAttributes = validateRequirement(spec.requiredAttributes, "requiredAttributes")
  local requiredProperties = validateRequirement(spec.requiredProperties, "requiredProperties")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  return setmetatable({
    resolveTarget = resolveTarget,
    resolveEngageZone = resolveEngageZone,
    requiredAssetsMin = requiredAssetsMin,
    requiredAssetsMax = requiredAssetsMax,
    engageRangeNm = engageRangeNm,
    targetTypes = targetTypes,
    requiredAttributes = requiredAttributes,
    requiredProperties = requiredProperties,
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

  local target, reason = self.resolveTarget(demand, context, legion)
  if target == nil then return nil, false, reason or "QRF_PHYSICAL_TARGET_UNAVAILABLE" end
  needTable(target, "QRF physical target")
  if type(target.IsInstanceOf) ~= "function" or target:IsInstanceOf("GROUP") ~= true then
    return nil, false, "QRF_PHYSICAL_TARGET_NOT_GROUP"
  end
  if type(target.IsAlive) ~= "function" or target:IsAlive() ~= true then
    return nil, false, "QRF_PHYSICAL_TARGET_NOT_ALIVE"
  end
  if type(target.GetCoordinate) ~= "function" then
    return nil, false, "QRF_PHYSICAL_TARGET_COORDINATE_UNAVAILABLE"
  end
  local targetCoordinate = target:GetCoordinate()
  if type(targetCoordinate) ~= "table" then
    return nil, false, "QRF_PHYSICAL_TARGET_COORDINATE_UNAVAILABLE"
  end

  local engageZone, zoneReason = self.resolveEngageZone(demand, context, legion)
  if engageZone == nil then return nil, false, zoneReason or "QRF_ENGAGE_ZONE_UNAVAILABLE" end

  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewONGUARD) ~= "function" then fail("MOOSE AUFTRAG:NewONGUARD() is required") end
  local mission = AUFTRAG:NewONGUARD(targetCoordinate)
  needTable(mission, "QRF ONGUARD AUFTRAG")
  if type(mission.SetEngageDetected) ~= "function" then fail("QRF AUFTRAG:SetEngageDetected() is required") end
  if type(mission.SetTeleport) ~= "function" then fail("QRF AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets) ~= "function" then fail("QRF AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority) ~= "function" then fail("QRF AUFTRAG:SetPriority() is required") end
  if type(mission.SetReturnToLegion) ~= "function" then fail("QRF AUFTRAG:SetReturnToLegion() is required") end
  if type(mission.Cancel) ~= "function" then fail("QRF AUFTRAG:Cancel() is required") end
  if self.requiredAttributes ~= nil and type(mission.SetRequiredAttribute) ~= "function" then
    fail("QRF AUFTRAG:SetRequiredAttribute() is required when requiredAttributes are configured")
  end
  if self.requiredProperties ~= nil and type(mission.SetRequiredProperty) ~= "function" then
    fail("QRF AUFTRAG:SetRequiredProperty() is required when requiredProperties are configured")
  end

  mission:SetRequiredAssets(self.requiredAssetsMin, self.requiredAssetsMax)
  mission:SetEngageDetected(self.engageRangeNm, self.targetTypes, engageZone)
  mission:SetReturnToLegion(true)
  mission:SetTeleport(false)
  if self.requiredAttributes ~= nil then mission:SetRequiredAttribute(self.requiredAttributes) end
  if self.requiredProperties ~= nil then mission:SetRequiredProperty(self.requiredProperties) end
  if finite(demand.priority) then mission:SetPriority(demand.priority, false) end

  self:_log(string.format(
    "created local QRF ONGUARD demandId=%s siteId=%s initialTarget=%s engageRangeNm=%s returnToLegion=true requiredAssets=%s-%s attributes=%s properties=%s priority=%s",
    tostring(demand.demandId), tostring(demand.siteId), tostring(target.GetName and target:GetName() or "UNKNOWN"),
    tostring(self.engageRangeNm), tostring(self.requiredAssetsMin), tostring(self.requiredAssetsMax),
    tostring(self.requiredAttributes ~= nil), tostring(self.requiredProperties ~= nil), tostring(demand.priority)))
  return mission, true, nil
end

return Factory