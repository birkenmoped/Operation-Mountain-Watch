-- Operation Mountain Watch - MOOSE-first external CAS mission factory.
--
-- Builds one public MOOSE AUFTRAG from caller-resolved tactical CAS geometry.
-- The alarm perimeter is not used as an engagement zone by this module. COMMANDER
-- owns provider aggregation/recruitment; this factory does not pick an AIRWING,
-- squadron, cohort or operational asset.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-2"
Factory.MissionMode = {
  CAS = "CAS",
  PATROLZONE_ENGAGE = "PATROLZONE_ENGAGE",
}
local TAG = "[OMW][FireSupStratResupply.CasMissionFactory]"

local function fail(message) error(TAG .. " " .. tostring(message),2) end
local function needTable(value,label) if type(value)~="table" then fail(label .. " must be a table") end return value end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end
local function positive(value) return finite(value) and value>0 end

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

local function validateGeometry(geometry)
  needTable(geometry,"CAS geometry")
  if type(geometry.zone)~="table" then return nil,"CAS_ZONE_UNAVAILABLE" end
  if geometry.altitudeFt~=nil and not finite(geometry.altitudeFt) then fail("altitudeFt must be finite when provided") end
  if geometry.speedKts~=nil and not positive(geometry.speedKts) then fail("speedKts must be positive when provided") end
  if geometry.headingDeg~=nil and not finite(geometry.headingDeg) then fail("headingDeg must be finite when provided") end
  if geometry.legNm~=nil and not positive(geometry.legNm) then fail("legNm must be positive when provided") end
  if geometry.targetTypes~=nil and type(geometry.targetTypes)~="table" then fail("targetTypes must be a table when provided") end
  if geometry.engageDetectedTargetTypes~=nil and type(geometry.engageDetectedTargetTypes)~="table" then fail("engageDetectedTargetTypes must be a table when provided") end
  if geometry.configureMission~=nil and type(geometry.configureMission)~="function" then fail("configureMission must be a function when provided") end
  local mode=geometry.missionMode or Factory.MissionMode.CAS
  if mode~=Factory.MissionMode.CAS and mode~=Factory.MissionMode.PATROLZONE_ENGAGE then
    fail("missionMode must be CAS or PATROLZONE_ENGAGE")
  end
  if mode==Factory.MissionMode.PATROLZONE_ENGAGE and not positive(geometry.engageDetectedRangeNm) then
    fail("engageDetectedRangeNm must be positive for PATROLZONE_ENGAGE")
  end
  return mode,nil
end

function Instance:Create(demand,context)
  needTable(demand,"demand")
  if demand.supportType~="CAS" then fail("supportType CAS is required") end
  if type(demand.demandId)~="string" or demand.demandId=="" then fail("demandId is required") end

  local geometry,reason=self.resolveGeometry(demand,context)
  if geometry==nil then return nil,false,reason or "CAS_GEOMETRY_UNAVAILABLE" end
  local mode,geometryReason=validateGeometry(geometry)
  if not mode then return nil,false,geometryReason end

  if type(AUFTRAG)~="table" then fail("MOOSE AUFTRAG is required") end
  local mission
  if mode==Factory.MissionMode.PATROLZONE_ENGAGE then
    if type(AUFTRAG.NewPATROLZONE)~="function" then fail("MOOSE AUFTRAG:NewPATROLZONE() is required") end
    mission=AUFTRAG:NewPATROLZONE(geometry.zone,geometry.speedKts,geometry.altitudeFt)
    needTable(mission,"PATROLZONE AUFTRAG")
    if type(mission.SetEngageDetected)~="function" then fail("PATROLZONE AUFTRAG:SetEngageDetected() is required") end
    mission:SetEngageDetected(
      geometry.engageDetectedRangeNm,
      geometry.engageDetectedTargetTypes or geometry.targetTypes or {"Ground Units"},
      geometry.zone,
      nil)
  else
    if type(AUFTRAG.NewCAS)~="function" then fail("MOOSE AUFTRAG:NewCAS() is required") end
    mission=AUFTRAG:NewCAS(
      geometry.zone,
      geometry.altitudeFt,
      geometry.speedKts,
      geometry.orbitCoordinate,
      geometry.headingDeg,
      geometry.legNm,
      geometry.targetTypes)
  end

  needTable(mission,"CAS AUFTRAG")
  if type(mission.SetTeleport)~="function" then fail("CAS AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets)~="function" then fail("CAS AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority)~="function" then fail("CAS AUFTRAG:SetPriority() is required") end
  if type(mission.Cancel)~="function" then fail("CAS AUFTRAG:Cancel() is required") end

  mission:SetTeleport(false)
  mission:SetRequiredAssets(self.requiredAssetsMin,self.requiredAssetsMax)
  if finite(demand.priority) then mission:SetPriority(demand.priority,false) end
  if geometry.configureMission then geometry.configureMission(mission,geometry,demand,context) end

  self:_log(string.format("created CAS mission demandId=%s siteId=%s mode=%s requiredAssets=%s-%s altitudeFt=%s speedKts=%s engageDetectedRangeNm=%s",
    tostring(demand.demandId),tostring(demand.siteId),tostring(mode),
    tostring(self.requiredAssetsMin),tostring(self.requiredAssetsMax),
    tostring(geometry.altitudeFt),tostring(geometry.speedKts),tostring(geometry.engageDetectedRangeNm)))
  return mission,true,nil
end

return Factory
