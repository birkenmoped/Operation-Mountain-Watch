-- Operation Mountain Watch - MOOSE-first FOB/COP perimeter-threat qualification adapter.
--
-- The adapter creates a runtime ZONE_RADIUS around an installation anchor and lets
-- MOOSE OPSZONE own presence scanning and the Attacked/Defeated FSM transitions.
-- Strategic demand creation remains delegated to OMW_FobAttackDemandPolicy and
-- MissionDemand.

local Adapter = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobThreatOpsZoneAdapter]"
Adapter.SchemaVersion = "OMW-FOB-THREAT-OPSZONE-ADAPTER-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function isFinite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function copyPosition(position)
  if type(position) ~= "table" then return nil end
  return { x = position.x, y = position.y, z = position.z }
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
  if not isFinite(spec.priority) then fail("priority must be a finite number") end
  if not isFinite(spec.radiusM) or spec.radiusM <= 0 then fail("radiusM must be a positive finite number") end
  if not isFinite(spec.blueCoalition) or not isFinite(spec.redCoalition) or spec.blueCoalition == spec.redCoalition then
    fail("blueCoalition and redCoalition must be distinct finite values")
  end
  if spec.updateSeconds ~= nil and (not isFinite(spec.updateSeconds) or spec.updateSeconds <= 0) then
    fail("updateSeconds must be a positive finite number when provided")
  end
  if spec.captureThreatlevel ~= nil and not isFinite(spec.captureThreatlevel) then fail("captureThreatlevel must be finite") end
  if spec.captureNunits ~= nil and (not isFinite(spec.captureNunits) or spec.captureNunits < 1) then fail("captureNunits must be at least one") end
  for _, name in ipairs({ "zoneRadiusFactory", "opsZoneFactory", "incidentIdFactory", "onThreatStarted", "onThreatCleared" }) do
    if spec[name] ~= nil and type(spec[name]) ~= "function" then fail(name .. " must be a function when provided") end
  end

  return setmetatable({
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
    onThreatStarted = spec.onThreatStarted,
    onThreatCleared = spec.onThreatCleared,
    securityZone = nil,
    opsZone = nil,
    started = false,
    incidentSequence = 0,
  }, Instance)
end

function Instance:_log(message)
  if self.opsZone and type(self.opsZone.I) == "function" then self.opsZone:I(TAG .. " " .. tostring(message)) end
end

function Instance:_makeIncidentId()
  self.incidentSequence = self.incidentSequence + 1
  if self.incidentIdFactory then
    return requireNonEmptyString(self.incidentIdFactory(self.opsZone, self.incidentSequence), "incidentIdFactory result")
  end
  return string.format("FOB-THREAT|%s|%d", self.installationId, self.incidentSequence)
end

function Instance:ProcessThreat(attackerCoalition)
  if attackerCoalition ~= self.redCoalition then return nil, false, "ATTACKER_NOT_RED" end

  local position = nil
  if type(self.anchorCoordinate.GetVec3) == "function" then position = copyPosition(self.anchorCoordinate:GetVec3()) end
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

  local demand, created, reason = self.policy.CreateDemand(self.missionDemand, self.registry, incident)
  self:_log(string.format(
    "installationId=%s zone=%s radiusM=%s incidentId=%s demandId=%s created=%s reason=%s",
    tostring(self.installationId), tostring(self.zoneName), tostring(self.radiusM), tostring(incident.incidentId),
    tostring(demand and demand.id), tostring(created), tostring(reason)))
  return demand, created, reason, incident
end

function Instance:Start()
  if self.started then return self, false end
  local vec2 = self.anchorCoordinate:GetVec2()
  requireTable(vec2, "anchorCoordinate:GetVec2 result")

  local zone
  if self.zoneRadiusFactory then
    zone = self.zoneRadiusFactory(self.zoneName, vec2, self.radiusM)
  else
    if type(ZONE_RADIUS) ~= "table" or type(ZONE_RADIUS.New) ~= "function" then fail("MOOSE ZONE_RADIUS:New() is required") end
    zone = ZONE_RADIUS:New(self.zoneName, vec2, self.radiusM)
  end
  requireTable(zone, "security ZONE_RADIUS")

  local opsZone
  if self.opsZoneFactory then
    opsZone = self.opsZoneFactory(zone, self.blueCoalition)
  else
    if type(OPSZONE) ~= "table" or type(OPSZONE.New) ~= "function" then fail("MOOSE OPSZONE:New() is required") end
    opsZone = OPSZONE:New(zone, self.blueCoalition)
  end
  requireTable(opsZone, "OPSZONE")

  for _, name in ipairs({ "SetObjectCategories", "SetUnitCategories", "SetCaptureThreatlevel", "SetCaptureNunits", "SetDrawZone", "SetMarkZone", "Start", "Stop" }) do
    requireFunction(opsZone, name, "OPSZONE")
  end
  if type(Object) ~= "table" or type(Object.Category) ~= "table" or Object.Category.UNIT == nil then fail("DCS Object.Category.UNIT is required") end
  if type(Unit) ~= "table" or type(Unit.Category) ~= "table" or Unit.Category.GROUND_UNIT == nil then fail("DCS Unit.Category.GROUND_UNIT is required") end

  opsZone:SetObjectCategories({ Object.Category.UNIT })
  opsZone:SetUnitCategories({ Unit.Category.GROUND_UNIT })
  opsZone:SetCaptureThreatlevel(self.captureThreatlevel)
  opsZone:SetCaptureNunits(self.captureNunits)
  opsZone:SetDrawZone(false)
  opsZone:SetMarkZone(false)
  if self.updateSeconds ~= nil then opsZone.UpdateSeconds = self.updateSeconds end

  local adapter = self
  function opsZone:OnAfterAttacked(From, Event, To, AttackerCoalition)
    local demand, created, reason, incident = adapter:ProcessThreat(AttackerCoalition)
    if demand ~= nil and adapter.onThreatStarted then
      adapter.onThreatStarted(adapter, self, demand, created, reason, incident)
    end
  end
  function opsZone:OnAfterDefeated(From, Event, To, DefeatedCoalition)
    if DefeatedCoalition ~= adapter.redCoalition then return end
    adapter:_log(string.format("installationId=%s threat cleared by OPSZONE Defeated coalition=%s", tostring(adapter.installationId), tostring(DefeatedCoalition)))
    if adapter.onThreatCleared then adapter.onThreatCleared(adapter, self, DefeatedCoalition) end
  end

  self.securityZone = zone
  self.opsZone = opsZone
  self.started = true
  opsZone:Start()
  self:_log(string.format(
    "started MOOSE OPSZONE security perimeter zone=%s radiusM=%s owner=%s updateSeconds=%s threatlevel=%s captureNunits=%s",
    tostring(self.zoneName), tostring(self.radiusM), tostring(self.blueCoalition), tostring(self.updateSeconds or opsZone.UpdateSeconds),
    tostring(self.captureThreatlevel), tostring(self.captureNunits)))
  return self, true
end

function Instance:Stop()
  if not self.started then return self, false end
  self.opsZone:Stop()
  self.started = false
  self:_log("stopped MOOSE OPSZONE security perimeter")
  return self, true
end

return Adapter
