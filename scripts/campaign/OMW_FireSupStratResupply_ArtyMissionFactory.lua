-- Operation Mountain Watch - MOOSE-first external ARTY mission factory.
--
-- Builds one public AUFTRAG:NewARTY() from caller-resolved tactical target geometry.
-- It does not select a provider, battery, cohort or asset. COMMANDER owns provider
-- aggregation/recruitment through OMW_FireSupStratResupply_CommanderBridge.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-MISSION-FACTORY-1"
local TAG = "[OMW][FireSupStratResupply.ArtyMissionFactory]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end

function Factory.New(spec)
  needTable(spec, "spec")
  if type(spec.resolveTarget) ~= "function" then fail("resolveTarget must be a function") end
  local minAssets=spec.requiredAssetsMin or 1
  local maxAssets=spec.requiredAssetsMax or minAssets
  if not finite(minAssets) or minAssets<1 then fail("requiredAssetsMin must be at least one") end
  if not finite(maxAssets) or maxAssets<minAssets then fail("requiredAssetsMax must be >= requiredAssetsMin") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  return setmetatable({
    resolveTarget=spec.resolveTarget,
    requiredAssetsMin=minAssets,
    requiredAssetsMax=maxAssets,
    logger=spec.logger,
  },Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Create(demand, context)
  needTable(demand,"demand")
  if demand.supportType~="ARTY" then fail("supportType ARTY is required") end
  if type(demand.demandId)~="string" or demand.demandId=="" then fail("demandId is required") end

  local target,reason=self.resolveTarget(demand,context)
  if target==nil then return nil,false,reason or "ARTY_TARGET_UNAVAILABLE" end
  needTable(target,"ARTY target")
  local coordinate=target.coordinate
  if type(coordinate)~="table" then return nil,false,"ARTY_TARGET_COORDINATE_UNAVAILABLE" end
  if target.shots~=nil and (not finite(target.shots) or target.shots<=0) then fail("target.shots must be positive when provided") end
  if target.radiusM~=nil and (not finite(target.radiusM) or target.radiusM<=0) then fail("target.radiusM must be positive when provided") end
  if target.altitudeM~=nil and not finite(target.altitudeM) then fail("target.altitudeM must be finite when provided") end

  if type(AUFTRAG)~="table" or type(AUFTRAG.NewARTY)~="function" then fail("MOOSE AUFTRAG:NewARTY() is required") end
  local mission=AUFTRAG:NewARTY(coordinate,target.shots,target.radiusM,target.altitudeM)
  needTable(mission,"ARTY AUFTRAG")
  if type(mission.SetTeleport)~="function" then fail("ARTY AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets)~="function" then fail("ARTY AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority)~="function" then fail("ARTY AUFTRAG:SetPriority() is required") end
  if type(mission.Cancel)~="function" then fail("ARTY AUFTRAG:Cancel() is required") end

  mission:SetTeleport(false)
  mission:SetRequiredAssets(self.requiredAssetsMin,self.requiredAssetsMax)
  if finite(demand.priority) then mission:SetPriority(demand.priority,false) end
  self:_log(string.format("created ARTY mission demandId=%s siteId=%s requiredAssets=%s-%s shots=%s radiusM=%s",
    tostring(demand.demandId),tostring(demand.siteId),tostring(self.requiredAssetsMin),tostring(self.requiredAssetsMax),
    tostring(target.shots),tostring(target.radiusM)))
  return mission,true,nil
end

return Factory
