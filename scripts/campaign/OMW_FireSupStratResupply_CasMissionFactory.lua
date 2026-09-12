-- Operation Mountain Watch - MOOSE-first external CAS mission factory.
--
-- Builds one public AUFTRAG:NewCAS() from caller-resolved tactical CAS geometry.
-- The alarm perimeter is not used as an engagement zone by this module. COMMANDER
-- owns provider aggregation/recruitment; this factory does not pick an AIRWING,
-- squadron, cohort or operational asset.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-1"
local TAG = "[OMW][FireSupStratResupply.CasMissionFactory]"

local function fail(message) error(TAG .. " " .. tostring(message),2) end
local function needTable(value,label) if type(value)~="table" then fail(label .. " must be a table") end return value end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end

function Factory.New(spec)
  needTable(spec,"spec")
  if type(spec.resolveGeometry)~="function" then fail("resolveGeometry must be a function") end
  local minAssets=spec.requiredAssetsMin or 1
  local maxAssets=spec.requiredAssetsMax or minAssets
  if not finite(minAssets) or minAssets<1 then fail("requiredAssetsMin must be at least one") end
  if not finite(maxAssets) or maxAssets<minAssets then fail("requiredAssetsMax must be >= requiredAssetsMin") end
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end
  return setmetatable({
    resolveGeometry=spec.resolveGeometry,
    requiredAssetsMin=minAssets,
    requiredAssetsMax=maxAssets,
    logger=spec.logger,
  },Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Create(demand,context)
  needTable(demand,"demand")
  if demand.supportType~="CAS" then fail("supportType CAS is required") end
  if type(demand.demandId)~="string" or demand.demandId=="" then fail("demandId is required") end

  local geometry,reason=self.resolveGeometry(demand,context)
  if geometry==nil then return nil,false,reason or "CAS_GEOMETRY_UNAVAILABLE" end
  needTable(geometry,"CAS geometry")
  if type(geometry.zone)~="table" then return nil,false,"CAS_ZONE_UNAVAILABLE" end
  if geometry.altitudeFt~=nil and not finite(geometry.altitudeFt) then fail("altitudeFt must be finite when provided") end
  if geometry.speedKts~=nil and (not finite(geometry.speedKts) or geometry.speedKts<=0) then fail("speedKts must be positive when provided") end
  if geometry.headingDeg~=nil and not finite(geometry.headingDeg) then fail("headingDeg must be finite when provided") end
  if geometry.legNm~=nil and (not finite(geometry.legNm) or geometry.legNm<=0) then fail("legNm must be positive when provided") end

  if type(AUFTRAG)~="table" or type(AUFTRAG.NewCAS)~="function" then fail("MOOSE AUFTRAG:NewCAS() is required") end
  local mission=AUFTRAG:NewCAS(
    geometry.zone,
    geometry.altitudeFt,
    geometry.speedKts,
    geometry.orbitCoordinate,
    geometry.headingDeg,
    geometry.legNm,
    geometry.targetTypes)
  needTable(mission,"CAS AUFTRAG")
  if type(mission.SetTeleport)~="function" then fail("CAS AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets)~="function" then fail("CAS AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority)~="function" then fail("CAS AUFTRAG:SetPriority() is required") end
  if type(mission.Cancel)~="function" then fail("CAS AUFTRAG:Cancel() is required") end

  mission:SetTeleport(false)
  mission:SetRequiredAssets(self.requiredAssetsMin,self.requiredAssetsMax)
  if finite(demand.priority) then mission:SetPriority(demand.priority,false) end
  self:_log(string.format("created CAS mission demandId=%s siteId=%s requiredAssets=%s-%s altitudeFt=%s speedKts=%s",
    tostring(demand.demandId),tostring(demand.siteId),tostring(self.requiredAssetsMin),tostring(self.requiredAssetsMax),
    tostring(geometry.altitudeFt),tostring(geometry.speedKts)))
  return mission,true,nil
end

return Factory
