-- Operation Mountain Watch - MOOSE-first FOB/COP perimeter-threat qualification adapter.
--
-- The adapter creates a runtime ZONE_RADIUS around an installation anchor and lets
-- MOOSE OPSZONE own presence scanning and the Attacked FSM transition. Strategic
-- demand creation remains delegated to OMW_FobAttackDemandPolicy and MissionDemand.

local Adapter = {}

local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobThreatOpsZoneAdapter]"

Adapter.SchemaVersion = "OMW-FOB-THREAT-OPSZONE-ADAPTER-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function isFinite(value)
  return type(value) == "number"
    and value == value
    and value > -math.huge
    and value < math.huge
end

local function copyPosition(position)
  if type(position) ~= "table" then
    return nil
  end
  return {
    x = position.x,
    y = position.y,
    z = position.z,
  }
end

function Adapter.New(spec)
  requireTable(spec, "spec")

  local missionDemand = requireTable(spec.missionDemand, "missionDemand")
  local registry = requireTable(spec.registry, "registry")
  local policy = requireTable(spec.policy, "policy")
  local anchorCoordinate = requireTable(spec.anchorCoordinate, "anchorCoordinate")

  requireFunction(registry, "Create", "registry")
  requireFunction(policy, "CreateDemand", "policy")
  requireFunction(anchorCoordinate, "GetVec2", "anchorCoordinate")

  if type(missionDemand.Type) ~= "table" or missionDemand.Type.CAS_IMMEDIATE == nil then
    fail("missionDemand.Type.CAS_IMMEDIATE is required")
  end

  requireNonEmptyString(spec.installationId, "installationId")
  requireNonEmptyString(spec.zoneName, "zoneName")

  if not isFinite(spec.priority) then
    fail("priority must be a finite number")
  end
  if not isFinite(spec.radiusM) or spec.radiusM <= 0 then
    fail("radiusM must be a positive finite number")
  end
  if not isFinite(spec.blueCoalition) then
    fail("blueCoalition must be a finite number")
  end
  if not isFinite(spec.redCoalition) then
    fail("redCoalition must be a finite number")
  end
  if spec.blueCoalition == spec.redCoalition then
    fail("blueCoalition and redCoalition must differ")
  end
  if spec.updateSeconds ~= nil and (not isFinite(spec.updateSeconds) or spec.updateSeconds <= 0) then
    fail("updateSeconds must be a positive finite number when provided")
  end
  if spec.captureThreatlevel ~= nil and not isFinite(spec.captureThreatlevel) then
    fail("captureThreatlevel must be a finite number when provided")
  end
  if spec.captureNunits ~= nil and (not isFinite(spec.captureNunits) or spec.captureNunits < 1) then
    fail("captureNunits must be at least one when provided")
  end
  if spec.zoneRadiusFactory ~= nil and type(spec.zoneRadiusFactory) ~= "function" then
    fail("zoneRadiusFactory must be a function when provided")
  end
  if spec.opsZoneFactory ~= nil and type(spec.opsZoneFactory) ~= "function" then
    fail("opsZoneFactory must be a function when provided")
  end
  if spec.incidentIdFactory ~= nil and type(spec.incidentIdFactory) ~= "function" then
    fail("incidentIdFactory must be a function when provided")
  end

  local self = setmetatable({
    missionDemand = missionDemand,
    registry = registry,
    policy = policy,
    anchorCoordinate = anchorCoordinate,
    installationId = spec.installationId,
    zoneName = spec.zoneName,
    priority = spec.priority,
    radiusM = spec.radiusM,
    blueCoalition = spec.blueCoalition,
    redCoalition = spec.redCoalition,
    updateSeconds = spec.updateSeconds,
    captureThreatlevel = spec.captureThreatlevel or 0,
    captureNunits = spec.captureNunits or 1,
    zoneRadiusFactory = spec.zoneRadiusFactory,
    opsZoneFactory = spec.opsZoneFactory,
    incidentIdFactory = spec.incidentIdFactory,
    securityZone = nil,
    opsZone = nil,
    started = false,
    incidentSequence = 0,
  }, Instance)

  return self
end

function Instance:_log(message)
  local logger = self.opsZone
  if logger and type(logger.I) == "function" then
    logger:I(TAG .. " " .. tostring(message))
  end
end

function Instance:_makeIncidentId()
  self.incidentSequence = self.incidentSequence + 1
  if self.incidentIdFactory then
    local incidentId = self.incidentIdFactory(self.opsZone, self.incidentSequence)
    return requireNonEmptyString(incidentId, "incidentIdFactory result")
  end
  return string.format("FOB-THREAT|%s|%d", self.installationId, self.incidentSequence)
end

function Instance:ProcessThreat(attackerCoalition)
  if attackerCoalition ~= self.redCoalition then
    return nil, false, "ATTACKER_NOT_RED"
  end

  local position = nil
  if type(self.anchorCoordinate.GetVec3) == "function" then
    position = copyPosition(self.anchorCoordinate:GetVec3())
  end

  local incident = {
    incidentId = self:_makeIncidentId(),
    installationId = self.installationId,
    priority = self.priority,
    position = position,
    reportedTarget = {
      targetKind = "INSTALLATION_SECURITY_PERIMETER",
      targetName = self.zoneName,
      radiusM = self.radiusM,
      evidence = "OPSZONE_ATTACKED",
      attackerCoalition = attackerCoalition,
    },
  }

  local demand, created, reason = self.policy.CreateDemand(
    self.missionDemand,
    self.registry,
    incident
  )

  self:_log(string.format(
    "installationId=%s zone=%s radiusM=%s incidentId=%s demandId=%s created=%s reason=%s",
    tostring(self.installationId),
    tostring(self.zoneName),
    tostring(self.radiusM),
    tostring(incident.incidentId),
    tostring(demand and demand.id),
    tostring(created),
    tostring(reason)
  ))

  return demand, created, reason
end

function Instance:Start()
  if self.started then
    return self, false
  end

  local vec2 = self.anchorCoordinate:GetVec2()
  requireTable(vec2, "anchorCoordinate:GetVec2 result")

  local zone = nil
  if self.zoneRadiusFactory then
    zone = self.zoneRadiusFactory(self.zoneName, vec2, self.radiusM)
  else
    if type(ZONE_RADIUS) ~= "table" or type(ZONE_RADIUS.New) ~= "function" then
      fail("MOOSE ZONE_RADIUS:New() is required")
    end
    zone = ZONE_RADIUS:New(self.zoneName, vec2, self.radiusM)
  end
  requireTable(zone, "security ZONE_RADIUS")

  local opsZone = nil
  if self.opsZoneFactory then
    opsZone = self.opsZoneFactory(zone, self.blueCoalition)
  else
    if type(OPSZONE) ~= "table" or type(OPSZONE.New) ~= "function" then
      fail("MOOSE OPSZONE:New() is required")
    end
    opsZone = OPSZONE:New(zone, self.blueCoalition)
  end
  requireTable(opsZone, "OPSZONE")

  requireFunction(opsZone, "SetObjectCategories", "OPSZONE")
  requireFunction(opsZone, "SetUnitCategories", "OPSZONE")
  requireFunction(opsZone, "SetCaptureThreatlevel", "OPSZONE")
  requireFunction(opsZone, "SetCaptureNunits", "OPSZONE")
  requireFunction(opsZone, "SetDrawZone", "OPSZONE")
  requireFunction(opsZone, "SetMarkZone", "OPSZONE")
  requireFunction(opsZone, "Start", "OPSZONE")
  requireFunction(opsZone, "Stop", "OPSZONE")

  if type(Object) ~= "table" or type(Object.Category) ~= "table" or Object.Category.UNIT == nil then
    fail("DCS Object.Category.UNIT is required")
  end
  if type(Unit) ~= "table" or type(Unit.Category) ~= "table" or Unit.Category.GROUND_UNIT == nil then
    fail("DCS Unit.Category.GROUND_UNIT is required")
  end

  opsZone:SetObjectCategories({ Object.Category.UNIT })
  opsZone:SetUnitCategories({ Unit.Category.GROUND_UNIT })
  opsZone:SetCaptureThreatlevel(self.captureThreatlevel)
  opsZone:SetCaptureNunits(self.captureNunits)
  opsZone:SetDrawZone(false)
  opsZone:SetMarkZone(false)
  if self.updateSeconds ~= nil then
    opsZone.UpdateSeconds = self.updateSeconds
  end

  local adapter = self
  function opsZone:OnAfterAttacked(From, Event, To, AttackerCoalition)
    adapter:ProcessThreat(AttackerCoalition)
  end

  self.securityZone = zone
  self.opsZone = opsZone
  self.started = true
  opsZone:Start()

  self:_log(string.format(
    "started MOOSE OPSZONE security perimeter zone=%s radiusM=%s owner=%s updateSeconds=%s threatlevel=%s nunits=%s",
    tostring(self.zoneName),
    tostring(self.radiusM),
    tostring(self.blueCoalition),
    tostring(self.updateSeconds or opsZone.UpdateSeconds),
    tostring(self.captureThreatlevel),
    tostring(self.captureNunits)
  ))

  return self, true
end

function Instance:Stop()
  if not self.started then
    return self, false
  end

  self.opsZone:Stop()
  self.started = false
  self:_log("stopped MOOSE OPSZONE security perimeter")
  return self, true
end

return Adapter
