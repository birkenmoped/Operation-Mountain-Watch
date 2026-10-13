-- Operation Mountain Watch - MOOSE-first FOB/COP perimeter-threat qualification adapter.
--
-- The adapter uses either a caller-provided MOOSE zone or creates a runtime
-- ZONE_RADIUS around an installation anchor. MOOSE OPSZONE owns the periodic zone
-- scan and Evaluated FSM callback. OMW qualifies RED ground-group presence from the
-- public OPSZONE scanned group set as the installation alarm stimulus. This avoids
-- requiring a permanently materialized BLUE Guard merely to make OPSZONE enter its
-- contested Attacked state. Strategic handling remains injected.

local Adapter = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobThreatOpsZoneAdapter]"
Adapter.SchemaVersion = "OMW-FOB-THREAT-OPSZONE-ADAPTER-6"

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

local function hasLivingCoalitionGroup(opsZone, coalitionId)
  local scanned = opsZone:GetScannedGroupSet()
  requireTable(scanned, "OPSZONE:GetScannedGroupSet result")
  requireFunction(scanned, "GetSetObjects", "OPSZONE scanned group set")
  for _, group in pairs(scanned:GetSetObjects() or {}) do
    if type(group) == "table"
        and type(group.IsAlive) == "function"
        and type(group.GetCoalition) == "function"
        and group:IsAlive() == true
        and group:GetCoalition() == coalitionId then
      return true
    end
  end
  return false
end

function Adapter.New(spec)
  requireTable(spec, "spec")
  local anchorCoordinate = requireTable(spec.anchorCoordinate, "anchorCoordinate")
  requireFunction(anchorCoordinate, "GetVec2", "anchorCoordinate")

  local securityZone = spec.securityZone
  if securityZone ~= nil then requireTable(securityZone, "securityZone") end

  local threatHandler = spec.threatHandler
  if threatHandler ~= nil and type(threatHandler) ~= "function" then fail("threatHandler must be a function when provided") end

  local missionDemand, registry, policy
  if threatHandler == nil then
    missionDemand = requireTable(spec.missionDemand, "missionDemand")
    registry = requireTable(spec.registry, "registry")
    policy = requireTable(spec.policy, "policy")
    requireFunction(registry, "Create", "registry")
    requireFunction(policy, "CreateDemand", "policy")
    if type(missionDemand.Type) ~= "table" or missionDemand.Type.CAS_IMMEDIATE == nil then
      fail("missionDemand.Type.CAS_IMMEDIATE is required")
    end
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
  for _, name in ipairs({ "zoneRadiusFactory", "opsZoneFactory", "incidentIdFactory", "onThreatStarted", "onThreatEvaluated", "onThreatCleared" }) do
    if spec[name] ~= nil and type(spec[name]) ~= "function" then fail(name .. " must be a function when provided") end
  end

  return setmetatable({
    missionDemand = missionDemand,
    registry = registry,
    policy = policy,
    threatHandler = threatHandler,
    anchorCoordinate = anchorCoordinate,
    securityZone = securityZone,
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
    onThreatEvaluated = spec.onThreatEvaluated,
    onThreatCleared = spec.onThreatCleared,
    opsZone = nil,
    started = false,
    incidentSequence = 0,
    activeIncident = nil,
    activeResult = nil,
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

function Instance:_buildIncident(attackerCoalition)
  local position = nil
  if type(self.anchorCoordinate.GetVec3) == "function" then position = copyPosition(self.anchorCoordinate:GetVec3()) end
  return {
    incidentId = self:_makeIncidentId(),
    installationId = self.installationId,
    priority = self.priority,
    position = position,
    reportedTarget = {
      targetKind = "INSTALLATION_SECURITY_PERIMETER",
      targetName = self.zoneName,
      radiusM = self.radiusM,
      evidence = "MOOSE_OPSZONE_RED_PRESENCE",
      attackerCoalition = attackerCoalition,
    },
  }
end

function Instance:ProcessThreat(attackerCoalition)
  if attackerCoalition ~= self.redCoalition then return nil, false, "ATTACKER_NOT_RED" end

  if self.threatHandler and self.activeIncident then
    return self.activeResult, false, "ACTIVE_INCIDENT", self.activeIncident
  end

  local incident = self:_buildIncident(attackerCoalition)
  if self.threatHandler then
    local result, created, reason = self.threatHandler(self, self.opsZone, incident)
    if result ~= nil then
      self.activeIncident = incident
      self.activeResult = result
    end
    self:_log(string.format(
      "installationId=%s zone=%s radiusM=%s incidentId=%s handled=%s created=%s reason=%s",
      tostring(self.installationId), tostring(self.zoneName), tostring(self.radiusM), tostring(incident.incidentId),
      tostring(result ~= nil), tostring(created), tostring(reason)))
    return result, created, reason, incident
  end

  local demand, created, reason = self.policy.CreateDemand(self.missionDemand, self.registry, incident)
  self:_log(string.format(
    "installationId=%s zone=%s radiusM=%s incidentId=%s demandId=%s created=%s reason=%s",
    tostring(self.installationId), tostring(self.zoneName), tostring(self.radiusM), tostring(incident.incidentId),
    tostring(demand and demand.id), tostring(created), tostring(reason)))
  return demand, created, reason, incident
end

function Instance:ClearThreat(defeatedCoalition, source)
  if defeatedCoalition ~= self.redCoalition then return nil, false, "CLEARED_COALITION_NOT_RED" end
  if not self.activeIncident then return nil, false, "NO_ACTIVE_INCIDENT" end
  local clearedIncident = self.activeIncident
  self.activeIncident = nil
  self.activeResult = nil
  self:_log(string.format(
    "installationId=%s alarm perimeter RED presence cleared source=%s coalition=%s",
    tostring(self.installationId), tostring(source), tostring(defeatedCoalition)))
  if self.onThreatCleared then self.onThreatCleared(self, self.opsZone, defeatedCoalition, clearedIncident) end
  return clearedIncident, true, nil
end

function Instance:Start()
  if self.started then return self, false end

  local zone = self.securityZone
  local zoneSource = "CALLER_PROVIDED"
  if zone == nil then
    local vec2 = self.anchorCoordinate:GetVec2()
    requireTable(vec2, "anchorCoordinate:GetVec2 result")
    zoneSource = "RUNTIME_ZONE_RADIUS"
    if self.zoneRadiusFactory then
      zone = self.zoneRadiusFactory(self.zoneName, vec2, self.radiusM)
    else
      if type(ZONE_RADIUS) ~= "table" or type(ZONE_RADIUS.New) ~= "function" then fail("MOOSE ZONE_RADIUS:New() is required") end
      zone = ZONE_RADIUS:New(self.zoneName, vec2, self.radiusM)
    end
  end
  requireTable(zone, "security zone")

  local opsZone
  if self.opsZoneFactory then
    opsZone = self.opsZoneFactory(zone, self.blueCoalition)
  else
    if type(OPSZONE) ~= "table" or type(OPSZONE.New) ~= "function" then fail("MOOSE OPSZONE:New() is required") end
    opsZone = OPSZONE:New(zone, self.blueCoalition)
  end
  requireTable(opsZone, "OPSZONE")

  for _, name in ipairs({ "SetObjectCategories", "SetUnitCategories", "SetCaptureThreatlevel", "SetCaptureNunits", "SetDrawZone", "SetMarkZone", "GetScannedGroupSet", "Start", "Stop" }) do
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
  function opsZone:OnAfterEvaluated(From, Event, To)
    local scanned = self:GetScannedGroupSet()
    if adapter.onThreatEvaluated then
      adapter.onThreatEvaluated(adapter, self, scanned, From, Event, To)
    end

    -- The perimeter is an alarm boundary, not a capture objective. Hostile presence
    -- therefore qualifies directly from MOOSE's own OPSZONE scan, independent of
    -- whether a BLUE Guard is already materialized inside the zone.
    local redPresent = hasLivingCoalitionGroup(self, adapter.redCoalition)
    if redPresent then
      local result, created, reason, incident = adapter:ProcessThreat(adapter.redCoalition)
      if result ~= nil and created ~= false and adapter.onThreatStarted then
        adapter.onThreatStarted(adapter, self, result, created, reason, incident)
      end
    elseif adapter.activeIncident then
      adapter:ClearThreat(adapter.redCoalition, "OPSZONE_EVALUATED_NO_RED")
    end
  end

  function opsZone:OnAfterAttacked(From, Event, To, AttackerCoalition)
    -- Preserve the native OPSZONE Attacked callback as a compatible fast path when
    -- friendly ground presence already exists. Active-incident idempotency prevents
    -- duplicate strategic evidence when Evaluated follows in the same status cycle.
    local result, created, reason, incident = adapter:ProcessThreat(AttackerCoalition)
    if result ~= nil and created ~= false and adapter.onThreatStarted then
      adapter.onThreatStarted(adapter, self, result, created, reason, incident)
    end
  end

  function opsZone:OnAfterDefeated(From, Event, To, DefeatedCoalition)
    adapter:ClearThreat(DefeatedCoalition, "OPSZONE_DEFEATED")
  end

  self.securityZone = zone
  self.opsZone = opsZone
  self.started = true
  opsZone:Start()
  self:_log(string.format(
    "started MOOSE OPSZONE security perimeter zone=%s radiusM=%s owner=%s updateSeconds=%s threatlevel=%s captureNunits=%s handler=%s zoneSource=%s alarmQualification=MOOSE_SCANNED_RED_PRESENCE",
    tostring(self.zoneName), tostring(self.radiusM), tostring(self.blueCoalition), tostring(self.updateSeconds or opsZone.UpdateSeconds),
    tostring(self.captureThreatlevel), tostring(self.captureNunits), self.threatHandler and "RAW_INCIDENT" or "MISSION_DEMAND_POLICY", zoneSource))
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
