-- Operation Mountain Watch - MOOSE-first local QRF mission factory.
--
-- Response phase: accepted Honaker contract
--   AUFTRAG:NewONGUARD(initial threat coordinate) + SetEngageDetected(...)
--   + SetReturnToLegion(true).
-- Clearance phase: owner-approved 2026-09-13 extension
--   same physical ARMYGROUP -> AUFTRAG:NewPATROLZONE(site-local tactical zone)
--   + ARMYGROUP:SetPatrolAdInfinitum(true)
--   + ARMYGROUP:EnableHuntingPatrol(...).
-- Release authority remains external Supported-Element/C2 only.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-6"

local TAG = "[OMW][FireSupStratResupply.QrfMissionFactory]"
local DEFAULT_ENGAGE_RANGE_NM = 5
local DEFAULT_TARGET_TYPES = { "Ground Units" }
local DEFAULT_CLEARANCE_SPEED_KNOTS = 20
local DEFAULT_CLEARANCE_SCAN_INTERVAL_SECONDS = 5
local DEFAULT_CLEARANCE_FORMATION = "Off Road"

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

  local clearanceSpeedKnots = spec.clearanceSpeedKnots or DEFAULT_CLEARANCE_SPEED_KNOTS
  if not finite(clearanceSpeedKnots) or clearanceSpeedKnots <= 0 then fail("clearanceSpeedKnots must be positive") end
  local clearanceScanIntervalSeconds = spec.clearanceScanIntervalSeconds or DEFAULT_CLEARANCE_SCAN_INTERVAL_SECONDS
  if not finite(clearanceScanIntervalSeconds) or clearanceScanIntervalSeconds <= 0 then fail("clearanceScanIntervalSeconds must be positive") end
  local clearanceFormation = spec.clearanceFormation or DEFAULT_CLEARANCE_FORMATION
  if type(clearanceFormation) ~= "string" or clearanceFormation == "" then fail("clearanceFormation must be a non-empty string") end

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
    clearanceSpeedKnots = clearanceSpeedKnots,
    clearanceScanIntervalSeconds = clearanceScanIntervalSeconds,
    clearanceFormation = clearanceFormation,
    requiredAttributes = requiredAttributes,
    requiredProperties = requiredProperties,
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:_installClearanceTransition(responseMission, tacticalZone, demand)
  local factory = self
  responseMission._OMWQrfClearanceByGroup = {}

  function responseMission:OnAfterExecuting(From, Event, To)
    if type(self.GetOpsGroups) ~= "function" then fail("QRF response AUFTRAG:GetOpsGroups() is required") end
    if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewPATROLZONE) ~= "function" then fail("MOOSE AUFTRAG:NewPATROLZONE() is required") end

    local opsGroups = self:GetOpsGroups()
    for _, opsGroup in ipairs(opsGroups or {}) do
      if self._OMWQrfClearanceByGroup[opsGroup] == nil then
        needTable(opsGroup, "QRF response OPSGROUP")
        if type(opsGroup.AddMission) ~= "function" then fail("QRF OPSGROUP:AddMission() is required") end
        if type(opsGroup.__MissionDone) ~= "function" then fail("QRF OPSGROUP:__MissionDone() is required") end
        if type(opsGroup.SetPatrolAdInfinitum) ~= "function" then fail("QRF ARMYGROUP:SetPatrolAdInfinitum() is required") end
        if type(opsGroup.EnableHuntingPatrol) ~= "function" then fail("QRF ARMYGROUP:EnableHuntingPatrol() is required") end

        local clearanceMission = AUFTRAG:NewPATROLZONE(
          tacticalZone,
          factory.clearanceSpeedKnots,
          nil,
          factory.clearanceFormation)
        needTable(clearanceMission, "QRF PATROLZONE AUFTRAG")
        if type(clearanceMission.SetReturnToLegion) ~= "function" then fail("QRF clearance AUFTRAG:SetReturnToLegion() is required") end
        if type(clearanceMission.SetTeleport) ~= "function" then fail("QRF clearance AUFTRAG:SetTeleport() is required") end
        if type(clearanceMission.Cancel) ~= "function" then fail("QRF clearance AUFTRAG:Cancel() is required") end

        clearanceMission:SetReturnToLegion(true)
        clearanceMission:SetTeleport(false)
        clearanceMission._OMWQrfPhase = "CLEARANCE"
        clearanceMission._OMWQrfDemandId = demand.demandId
        clearanceMission._OMWQrfSiteId = demand.siteId

        -- Queue the second MOOSE mission before completing ONGUARD. This keeps the
        -- same physical ARMYGROUP employed instead of allowing an intermediate RTZ.
        opsGroup:AddMission(clearanceMission)
        opsGroup:SetPatrolAdInfinitum(true)
        opsGroup:EnableHuntingPatrol(
          tacticalZone,
          factory.clearanceSpeedKnots,
          factory.clearanceFormation,
          factory.clearanceScanIntervalSeconds)

        self._OMWQrfClearanceByGroup[opsGroup] = clearanceMission
        self._OMWQrfActiveMission = clearanceMission

        factory:_log(string.format(
          "transitioned local QRF response->clearance demandId=%s siteId=%s opsGroup=%s speedKt=%s formation=%s scanIntervalSec=%s",
          tostring(demand.demandId), tostring(demand.siteId),
          tostring(opsGroup.groupname or opsGroup.alias or opsGroup.ClassName or opsGroup),
          tostring(factory.clearanceSpeedKnots), tostring(factory.clearanceFormation),
          tostring(factory.clearanceScanIntervalSeconds)))

        -- MOOSE FSM delayed event avoids re-entering MissionDone from the
        -- AUFTRAG Executing callback. The PATROLZONE mission is already queued.
        opsGroup:__MissionDone(0.1, self)
      end
    end
  end
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
  mission._OMWQrfPhase = "RESPONSE"
  if self.requiredAttributes ~= nil then mission:SetRequiredAttribute(self.requiredAttributes) end
  if self.requiredProperties ~= nil then mission:SetRequiredProperty(self.requiredProperties) end
  if finite(demand.priority) then mission:SetPriority(demand.priority, false) end

  self:_installClearanceTransition(mission, engageZone, demand)

  self:_log(string.format(
    "created local QRF ONGUARD response demandId=%s siteId=%s initialTarget=%s engageRangeNm=%s returnToLegion=true clearance=PATROLZONE+HuntingPatrol requiredAssets=%s-%s attributes=%s properties=%s priority=%s",
    tostring(demand.demandId), tostring(demand.siteId), tostring(target.GetName and target:GetName() or "UNKNOWN"),
    tostring(self.engageRangeNm), tostring(self.requiredAssetsMin), tostring(self.requiredAssetsMax),
    tostring(self.requiredAttributes ~= nil), tostring(self.requiredProperties ~= nil), tostring(demand.priority)))
  return mission, true, nil
end

return Factory
