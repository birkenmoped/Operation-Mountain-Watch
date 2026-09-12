-- Operation Mountain Watch - MOOSE-first persistent Guard mission factory.
--
-- Creates the public ONGUARD AUFTRAG for a prepared Guard PATHLINE materializer.
-- No cohort/asset is assigned here; the local LEGION/BRIGADE performs recruitment.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-1"
local TAG = "[OMW][FireSupStratResupply.GuardMissionFactory]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end

function Factory.New(spec)
  needTable(spec, "spec")
  local materializers = needTable(spec.materializers, "materializers")
  local routeAdapters = needTable(spec.routeAdapters, "routeAdapters")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  return setmetatable({ materializers=materializers, routeAdapters=routeAdapters, logger=spec.logger }, Instance)
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

  mission:SetTeleport(false)
  mission:SetRequiredAssets(1, 1)
  if finite(demand.priority) then mission:SetPriority(demand.priority, false) end
  routeAdapter:TrackMission(mission)

  self:_log(string.format("created persistent Guard mission demandId=%s siteId=%s", tostring(demand.demandId), siteId))
  return mission, true, nil
end

return Factory
