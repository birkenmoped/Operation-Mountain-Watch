-- Operation Mountain Watch - MOOSE-first local QRF mission factory.
--
-- Honaker-reconciled contract:
--   AUFTRAG:NewONGUARD(initial threat coordinate) recruits/materializes the QRF.
--   As soon as the physical ARMYGROUP is on mission, the runtime binds it to the
--   nearest living known incident UNIT with ARMYGROUP:EngageTarget(). MOOSE owns
--   moving-target pursuit. The motorized QRF uses MOOSE "On Road" formation for
--   transit; pinned ARMYGROUP routing inserts road waypoints and leaves the road
--   for the final approach when the target waypoint itself is off-road.
--   After Disengage (target dead), the same ARMYGROUP acquires the next living
--   incident UNIT. No remaining authorized target ends the mission and lets
--   MOOSE ReturnToLegion recover the group.

local Factory = {}
local Instance = {}
Instance.__index = Instance

Factory.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8"

local TAG = "[OMW][FireSupStratResupply.QrfMissionFactory]"
local DEFAULT_ENGAGE_SPEED_KNOTS = 20
local DEFAULT_ENGAGE_FORMATION = "On Road"

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
  local resolveTargets = needFunction(spec.resolveTargets, "resolveTargets")
  local resolveEngageZone = needFunction(spec.resolveEngageZone, "resolveEngageZone")
  local requiredAssetsMin = spec.requiredAssetsMin or 1
  local requiredAssetsMax = spec.requiredAssetsMax or requiredAssetsMin
  if not finite(requiredAssetsMin) or requiredAssetsMin < 1 then fail("requiredAssetsMin must be at least one") end
  if not finite(requiredAssetsMax) or requiredAssetsMax < requiredAssetsMin then fail("requiredAssetsMax must be >= requiredAssetsMin") end

  local engageSpeedKnots = spec.engageSpeedKnots or DEFAULT_ENGAGE_SPEED_KNOTS
  if not finite(engageSpeedKnots) or engageSpeedKnots <= 0 then fail("engageSpeedKnots must be positive") end
  local engageFormation = spec.engageFormation or DEFAULT_ENGAGE_FORMATION
  if type(engageFormation) ~= "string" or engageFormation == "" then fail("engageFormation must be a non-empty string") end

  local requiredAttributes = validateRequirement(spec.requiredAttributes, "requiredAttributes")
  local requiredProperties = validateRequirement(spec.requiredProperties, "requiredProperties")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  return setmetatable({
    resolveTarget = resolveTarget,
    resolveTargets = resolveTargets,
    resolveEngageZone = resolveEngageZone,
    requiredAssetsMin = requiredAssetsMin,
    requiredAssetsMax = requiredAssetsMax,
    engageSpeedKnots = engageSpeedKnots,
    engageFormation = engageFormation,
    requiredAttributes = requiredAttributes,
    requiredProperties = requiredProperties,
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:_selectNextTarget(demand, context, tacticalZone, armyGroup)
  local candidates, reason = self.resolveTargets(demand, context, armyGroup)
  if candidates == nil then return nil, reason or "QRF_INCIDENT_TARGETS_UNAVAILABLE" end
  if type(candidates) ~= "table" then fail("resolveTargets must return a table") end

  local valid = {}
  for _, target in pairs(candidates) do
    if type(target) == "table" and type(target.IsAlive) == "function" and target:IsAlive() == true
        and type(target.GetCoordinate) == "function" then
      local coordinate = target:GetCoordinate()
      local inZone = coordinate ~= nil and type(tacticalZone.IsCoordinateInZone) == "function"
        and tacticalZone:IsCoordinateInZone(coordinate) == true
      if inZone then valid[#valid + 1] = target end
    end
  end

  if #valid == 0 then return nil, "QRF_NO_LIVING_INCIDENT_TARGETS_IN_TACTICAL_ZONE" end

  local origin = type(armyGroup.GetCoordinate) == "function" and armyGroup:GetCoordinate() or nil
  if origin and type(origin.Get2DDistance) == "function" then
    table.sort(valid, function(a, b)
      return origin:Get2DDistance(a:GetCoordinate()) < origin:Get2DDistance(b:GetCoordinate())
    end)
  end
  return valid[1], nil
end

function Instance:_bindDirectTargetCycle(mission, demand, context, tacticalZone, armyGroup)
  needTable(armyGroup, "QRF ARMYGROUP")
  if mission._OMWQrfArmyGroups[armyGroup] then return false end
  if type(armyGroup.EngageTarget) ~= "function" then fail("QRF ARMYGROUP:EngageTarget() is required") end
  if type(armyGroup.GetCoordinate) ~= "function" then fail("QRF ARMYGROUP:GetCoordinate() is required") end

  mission._OMWQrfArmyGroups[armyGroup] = true
  local factory = self
  local previousDisengage = armyGroup.OnAfterDisengage

  local function acquireNext(reason)
    if mission._OMWQrfCompleting then return false end
    local target, targetReason = factory:_selectNextTarget(demand, context, tacticalZone, armyGroup)
    if not target then
      mission._OMWQrfCompleting = true
      mission._OMWQrfCompletionReason = targetReason
      local over = type(mission.IsOver) == "function" and mission:IsOver() or false
      if not over then mission:Cancel() end
      factory:_log(string.format(
        "local QRF target cycle complete demandId=%s siteId=%s armyGroup=%s reason=%s -> MOOSE ReturnToLegion",
        tostring(demand.demandId), tostring(demand.siteId),
        tostring(armyGroup.groupname or armyGroup.alias or armyGroup.ClassName or armyGroup), tostring(targetReason)))
      return false
    end

    mission._OMWQrfCurrentTargetByGroup[armyGroup] = target
    mission._OMWQrfTargetAcquisitions = (mission._OMWQrfTargetAcquisitions or 0) + 1
    armyGroup:EngageTarget(target, factory.engageSpeedKnots, factory.engageFormation)
    factory:_log(string.format(
      "local QRF concrete target acquired demandId=%s siteId=%s armyGroup=%s target=%s reason=%s acquisition=%d formation=%s",
      tostring(demand.demandId), tostring(demand.siteId),
      tostring(armyGroup.groupname or armyGroup.alias or armyGroup.ClassName or armyGroup),
      tostring(target.GetName and target:GetName() or target), tostring(reason),
      mission._OMWQrfTargetAcquisitions, tostring(factory.engageFormation)))
    return true
  end

  function armyGroup:OnAfterDisengage(From, Event, To)
    if previousDisengage then previousDisengage(self, From, Event, To) end
    mission._OMWQrfCurrentTargetByGroup[self] = nil
    acquireNext("MOOSE_DISENGAGE_REACQUIRE")
  end

  mission._OMWQrfAcquireNext = acquireNext
  acquireNext("ARMY_ON_MISSION_INITIAL_ACQUIRE")
  return true
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
  if type(target.GetCoordinate) ~= "function" then return nil, false, "QRF_PHYSICAL_TARGET_COORDINATE_UNAVAILABLE" end
  local targetCoordinate = target:GetCoordinate()
  if type(targetCoordinate) ~= "table" then return nil, false, "QRF_PHYSICAL_TARGET_COORDINATE_UNAVAILABLE" end

  local tacticalZone, zoneReason = self.resolveEngageZone(demand, context, legion)
  if tacticalZone == nil then return nil, false, zoneReason or "QRF_ENGAGE_ZONE_UNAVAILABLE" end

  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewONGUARD) ~= "function" then fail("MOOSE AUFTRAG:NewONGUARD() is required") end
  local mission = AUFTRAG:NewONGUARD(targetCoordinate)
  needTable(mission, "QRF ONGUARD AUFTRAG")
  if type(mission.SetTeleport) ~= "function" then fail("QRF AUFTRAG:SetTeleport() is required") end
  if type(mission.SetRequiredAssets) ~= "function" then fail("QRF AUFTRAG:SetRequiredAssets() is required") end
  if type(mission.SetPriority) ~= "function" then fail("QRF AUFTRAG:SetPriority() is required") end
  if type(mission.SetReturnToLegion) ~= "function" then fail("QRF AUFTRAG:SetReturnToLegion() is required") end
  if type(mission.Cancel) ~= "function" then fail("QRF AUFTRAG:Cancel() is required") end
  if self.requiredAttributes ~= nil and type(mission.SetRequiredAttribute) ~= "function" then fail("QRF AUFTRAG:SetRequiredAttribute() is required when requiredAttributes are configured") end
  if self.requiredProperties ~= nil and type(mission.SetRequiredProperty) ~= "function" then fail("QRF AUFTRAG:SetRequiredProperty() is required when requiredProperties are configured") end

  mission:SetRequiredAssets(self.requiredAssetsMin, self.requiredAssetsMax)
  mission:SetReturnToLegion(true)
  mission:SetTeleport(false)
  mission._OMWQrfPhase = "DIRECT_TARGET_RESPONSE"
  mission._OMWQrfDemandId = demand.demandId
  mission._OMWQrfSiteId = demand.siteId
  mission._OMWQrfArmyGroups = {}
  mission._OMWQrfCurrentTargetByGroup = {}
  mission._OMWQrfCompleting = false
  if self.requiredAttributes ~= nil then mission:SetRequiredAttribute(self.requiredAttributes) end
  if self.requiredProperties ~= nil then mission:SetRequiredProperty(self.requiredProperties) end
  if finite(demand.priority) then mission:SetPriority(demand.priority, false) end

  local factory = self
  function mission:_OMWQrfBindArmyGroup(armyGroup)
    return factory:_bindDirectTargetCycle(self, demand, context, tacticalZone, armyGroup)
  end

  self:_log(string.format(
    "created local QRF ONGUARD recruitment anchor demandId=%s siteId=%s roadDirectionTarget=%s directTargetCycle=MOOSE_EngageTarget transitFormation=%s requiredAssets=%s-%s attributes=%s properties=%s priority=%s",
    tostring(demand.demandId), tostring(demand.siteId), tostring(target.GetName and target:GetName() or "UNKNOWN"),
    tostring(self.engageFormation), tostring(self.requiredAssetsMin), tostring(self.requiredAssetsMax),
    tostring(self.requiredAttributes ~= nil), tostring(self.requiredProperties ~= nil), tostring(demand.priority)))
  return mission, true, nil
end

return Factory
