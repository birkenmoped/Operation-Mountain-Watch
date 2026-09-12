-- Operation Mountain Watch - MOOSE-first persistent Guard mission factory.
--
-- Creates the public ONGUARD AUFTRAG for a prepared Guard PATHLINE materializer.
-- No cohort/asset is assigned here; the local LEGION/BRIGADE performs recruitment.
-- Optional attribute/property requirements are forwarded to MOOSE recruitment.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-2"
local TAG = "[OMW][FireSupStratResupply.GuardMissionFactory]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end
local function validateRequirement(value, label)
  if value ~= nil and type(value) ~= "string" and type(value) ~= "table" then
    fail(label .. " must be a string or table when provided")
  end
  return value
end

function Factory.New(spec)
  needTable(spec, "spec")
  local materializers = needTable(spec.materializers, "materializers")
  local routeAdapters = needTable(spec.routeAdapters, "routeAdapters")
  local requiredAttributes = validateRequirement(spec.requiredAttributes, "requiredAttributes")
  local requiredProperties = validateRequirement(spec.requiredProperties, "requiredProperties")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  return setmetatable({
    materializers=materializers,
    routeAdapters=routeAdapters,
    requiredAttributes=requiredAttributes,
    requiredProperties=requiredProperties,
    logger=spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Create(demand, context, legion)
  needTable(demand, "demand")
  if demand.supportType ~= "GUARD" then fail("supportType GUARD is required") end
  local siteId = demand.siteId
  if type(siteId) ~= "string" or siteId == "" then fail("siteId is required") end
  local materializer = self.materializers[siteId]
  if not materializer then return nil, false, "GUARD_MATERIALIZER_NOT_CONFIGURED" end
  local routeAdapter = self.routeAdapters[siteId]
  if not routeAdapter then return nil, false, "GUARD_ROUTE_ADAPTER_NOT_CONFIGURED" end
  if type(materializer.GetLeadCoordinate) ~= "function" then fail("materializer.GetLeadCoordinate() is required") end
  if type(routeAdapter.TrackMission) ~= "function" then fail("routeAdapter.TrackMission() is required") end

  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewONGUARD) ~= "function" then fail("MOOSE AUFTRAG:NewONGUARD() is required") end
  local mission = AUFTRAG:NewONGUARD(materializer:GetLeadCoordinate())
  needTable(mission, "Guard AUFTRAG")
  if type(mission.SetTeleport) ~= "function" then fail("Guard AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets) ~= "function" then fail("Guard AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority) ~= "function" then fail("Guard AUFTRAG:SetPriority() is required") end
  if type(mission.Cancel) ~= "function" then fail("Guard AUFTRAG:Cancel() is required") end
  if self.requiredAttributes ~= nil and type(mission.SetRequiredAttribute) ~= "function" then
    fail("Guard AUFTRAG:SetRequiredAttribute() is required when requiredAttributes are configured")
  end
  if self.requiredProperties ~= nil and type(mission.SetRequiredProperty) ~= "function" then
    fail("Guard AUFTRAG:SetRequiredProperty() is required when requiredProperties are configured")
  end

  mission:SetTeleport(false)
  mission:SetRequiredAssets(1, 1)
  if self.requiredAttributes ~= nil then mission:SetRequiredAttribute(self.requiredAttributes) end
  if self.requiredProperties ~= nil then mission:SetRequiredProperty(self.requiredProperties) end
  if finite(demand.priority) then mission:SetPriority(demand.priority, false) end
  routeAdapter:TrackMission(mission)

  self:_log(string.format(
    "created persistent Guard mission demandId=%s siteId=%s attributes=%s properties=%s",
    tostring(demand.demandId), siteId, tostring(self.requiredAttributes ~= nil), tostring(self.requiredProperties ~= nil)))
  return mission, true, nil
end

return Factory
