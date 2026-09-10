-- Operation Mountain Watch - MOOSE-first installation alarm evidence adapter.
--
-- Converts MOOSE event/weapon evidence into OMW installation attack evidence.
-- It does not own MissionDemand, CampaignState, response dispatch, or tactical
-- completion. The installation alarm zone is only an alarm/trigger boundary.

local Adapter = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][GroundInstallationAlarmEvidenceAdapter]"
Adapter.SchemaVersion = "OMW-GROUND-INSTALLATION-ALARM-EVIDENCE-2"

Adapter.EvidenceType = {
  PROXIMITY_INTRUSION = "PROXIMITY_INTRUSION",
  DIRECT_FIRE_ATTACK = "DIRECT_FIRE_ATTACK",
  INDIRECT_FIRE_ATTACK = "INDIRECT_FIRE_ATTACK",
  CONFIRMED_HIT_ATTACK = "CONFIRMED_HIT_ATTACK",
  OTHER_CONFIRMED_ATTACK = "OTHER_CONFIRMED_ATTACK",
}

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

function Adapter.New(spec)
  requireTable(spec, "spec")
  local alarmZone = requireTable(spec.alarmZone, "alarmZone")
  requireFunction(alarmZone, "IsCoordinateInZone", "alarmZone")
  requireFunction(spec, "onEvidence", "spec")

  requireNonEmptyString(spec.installationId, "installationId")
  if not isFinite(spec.blueCoalition) or not isFinite(spec.redCoalition) or spec.blueCoalition == spec.redCoalition then
    fail("blueCoalition and redCoalition must be distinct finite values")
  end
  if spec.weaponTrackStepSec ~= nil and (not isFinite(spec.weaponTrackStepSec) or spec.weaponTrackStepSec <= 0) then
    fail("weaponTrackStepSec must be a positive finite number when provided")
  end
  for _, name in ipairs({ "eventHandlerFactory", "weaponFactory", "shouldTrackWeapon", "targetInAlarmZone" }) do
    if spec[name] ~= nil and type(spec[name]) ~= "function" then fail(name .. " must be a function when provided") end
  end

  return setmetatable({
    installationId = spec.installationId,
    alarmZone = alarmZone,
    blueCoalition = spec.blueCoalition,
    redCoalition = spec.redCoalition,
    onEvidence = spec.onEvidence,
    eventHandlerFactory = spec.eventHandlerFactory,
    weaponFactory = spec.weaponFactory,
    shouldTrackWeapon = spec.shouldTrackWeapon,
    targetInAlarmZone = spec.targetInAlarmZone,
    weaponTrackStepSec = spec.weaponTrackStepSec or 0.10,
    handler = nil,
    started = false,
  }, Instance)
end

function Instance:_emit(evidenceType, data)
  local evidence = data or {}
  evidence.installationId = self.installationId
  evidence.evidenceType = evidenceType
  self.onEvidence(self, evidence)
  return evidence
end

function Instance:_isRedInitiator(eventData)
  return type(eventData) == "table" and eventData.IniCoalition == self.redCoalition
end

function Instance:_isBlueTarget(eventData)
  return type(eventData) == "table" and eventData.TgtCoalition == self.blueCoalition
end

function Instance:_targetCoalitionIsBlue(target, eventData)
  if type(target) == "table" and type(target.GetCoalition) == "function" then
    return target:GetCoalition() == self.blueCoalition
  end
  return self:_isBlueTarget(eventData)
end

function Instance:_targetIsInAlarmZone(target, eventData)
  if self.targetInAlarmZone then
    return self.targetInAlarmZone(target, eventData, self.alarmZone) == true
  end
  if type(target) ~= "table" then return false end
  if type(target.IsInZone) == "function" then
    return target:IsInZone(self.alarmZone) == true
  end
  if type(target.GetCoordinate) == "function" then
    local coordinate = target:GetCoordinate()
    if coordinate ~= nil then return self.alarmZone:IsCoordinateInZone(coordinate) == true end
  end
  return false
end

function Instance:ProcessHit(eventData)
  if not self:_isRedInitiator(eventData) or not self:_isBlueTarget(eventData) then return nil, "NOT_HOSTILE_BLUE_HIT" end
  if not self:_targetIsInAlarmZone(eventData.TgtUnit or eventData.TgtStatic, eventData) then return nil, "TARGET_OUTSIDE_ALARM_ZONE" end
  return self:_emit(Adapter.EvidenceType.CONFIRMED_HIT_ATTACK, {
    sourceEvent = "Hit",
    initiatorUnitName = eventData.IniUnitName,
    targetUnitName = eventData.TgtUnitName,
  }), "EVIDENCE_EMITTED"
end

function Instance:ProcessShootingStart(eventData)
  if not self:_isRedInitiator(eventData) or not self:_isBlueTarget(eventData) then return nil, "NOT_HOSTILE_BLUE_FIRE" end
  if not self:_targetIsInAlarmZone(eventData.TgtUnit or eventData.TgtStatic, eventData) then return nil, "TARGET_OUTSIDE_ALARM_ZONE" end
  return self:_emit(Adapter.EvidenceType.DIRECT_FIRE_ATTACK, {
    sourceEvent = "ShootingStart",
    initiatorUnitName = eventData.IniUnitName,
    targetUnitName = eventData.TgtUnitName,
  }), "EVIDENCE_EMITTED"
end

function Instance:_newWeapon(dcsWeapon)
  if self.weaponFactory then return self.weaponFactory(dcsWeapon) end
  if type(WEAPON) ~= "table" or type(WEAPON.New) ~= "function" then fail("MOOSE WEAPON:New() is required") end
  return WEAPON:New(dcsWeapon)
end

function Instance:_trackImpact(weapon, eventData)
  if type(weapon.SetTimeStepTrack) ~= "function" or type(weapon.SetFuncImpact) ~= "function" or type(weapon.StartTrack) ~= "function" then
    fail("MOOSE WEAPON tracking methods are required")
  end

  weapon:SetTimeStepTrack(self.weaponTrackStepSec)
  local adapter = self
  weapon:SetFuncImpact(function(trackedWeapon)
    if type(trackedWeapon) ~= "table" or type(trackedWeapon.GetImpactCoordinate) ~= "function" then return end
    local impactCoordinate = trackedWeapon:GetImpactCoordinate()
    if impactCoordinate ~= nil and adapter.alarmZone:IsCoordinateInZone(impactCoordinate) then
      adapter:_emit(Adapter.EvidenceType.INDIRECT_FIRE_ATTACK, {
        sourceEvent = "WeaponImpact",
        initiatorUnitName = eventData.IniUnitName,
        weaponTypeName = type(trackedWeapon.GetTypeName) == "function" and trackedWeapon:GetTypeName() or nil,
        impactCoordinate = impactCoordinate,
      })
    end
  end)
  weapon:StartTrack()
end

function Instance:ProcessShot(eventData)
  if not self:_isRedInitiator(eventData) then return nil, "INITIATOR_NOT_RED" end
  if eventData.weapon == nil then return nil, "NO_WEAPON" end

  local weapon = self:_newWeapon(eventData.weapon)
  requireTable(weapon, "WEAPON")

  local targetInAlarmZone = false
  if type(weapon.GetTarget) == "function" then
    local target = weapon:GetTarget()
    if target ~= nil and self:_targetCoalitionIsBlue(target, eventData) and self:_targetIsInAlarmZone(target, eventData) then
      targetInAlarmZone = true
      self:_emit(Adapter.EvidenceType.DIRECT_FIRE_ATTACK, {
        sourceEvent = "ShotTarget",
        initiatorUnitName = eventData.IniUnitName,
        targetUnitName = type(target.GetName) == "function" and target:GetName() or nil,
        weaponTypeName = type(weapon.GetTypeName) == "function" and weapon:GetTypeName() or nil,
      })
    end
  end

  local categoryRelevant = false
  if type(weapon.IsShell) == "function" and weapon:IsShell() then categoryRelevant = true end
  if type(weapon.IsRocket) == "function" and weapon:IsRocket() then categoryRelevant = true end
  if type(weapon.IsMissile) == "function" and weapon:IsMissile() then categoryRelevant = true end
  if not categoryRelevant then return weapon, "WEAPON_CATEGORY_NOT_TRACKED" end

  -- A positively correlated target in the alarm zone already produced immediate
  -- evidence. Do not also start high-frequency impact tracking for that weapon.
  if targetInAlarmZone then return weapon, "DIRECT_TARGET_EVIDENCE" end

  -- Indirect/stand-off impact tracking is deliberately opt-in. MOOSE WEAPON
  -- tracking defaults to 0.01 s and must not be started globally for every shot.
  if not self.shouldTrackWeapon then return weapon, "NO_TRACK_FILTER" end
  if self.shouldTrackWeapon(eventData, weapon, self.alarmZone) ~= true then
    return weapon, "TRACK_FILTER_REJECTED"
  end

  self:_trackImpact(weapon, eventData)
  return weapon, "TRACKING_STARTED"
end

function Instance:ProcessProximityIntrusion(data)
  local payload = data or {}
  payload.sourceEvent = payload.sourceEvent or "OPSZONE_Attacked"
  return self:_emit(Adapter.EvidenceType.PROXIMITY_INTRUSION, payload)
end

function Instance:Start()
  if self.started then return self, false end

  local handler
  if self.eventHandlerFactory then
    handler = self.eventHandlerFactory()
  else
    if type(EVENTHANDLER) ~= "table" or type(EVENTHANDLER.New) ~= "function" then fail("MOOSE EVENTHANDLER:New() is required") end
    handler = EVENTHANDLER:New()
  end
  requireTable(handler, "EVENTHANDLER")
  requireFunction(handler, "HandleEvent", "EVENTHANDLER")
  requireFunction(handler, "UnHandleEvent", "EVENTHANDLER")

  if type(EVENTS) ~= "table" or EVENTS.Hit == nil or EVENTS.Shot == nil or EVENTS.ShootingStart == nil then
    fail("MOOSE EVENTS.Hit, EVENTS.Shot and EVENTS.ShootingStart are required")
  end

  local adapter = self
  function handler:OnEventHit(eventData) adapter:ProcessHit(eventData) end
  function handler:OnEventShot(eventData) adapter:ProcessShot(eventData) end
  function handler:OnEventShootingStart(eventData) adapter:ProcessShootingStart(eventData) end

  handler:HandleEvent(EVENTS.Hit)
  handler:HandleEvent(EVENTS.Shot)
  handler:HandleEvent(EVENTS.ShootingStart)

  self.handler = handler
  self.started = true
  return self, true
end

function Instance:Stop()
  if not self.started then return self, false end
  self.handler:UnHandleEvent(EVENTS.Hit)
  self.handler:UnHandleEvent(EVENTS.Shot)
  self.handler:UnHandleEvent(EVENTS.ShootingStart)
  self.handler = nil
  self.started = false
  return self, true
end

return Adapter
