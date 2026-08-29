-- Operation Mountain Watch - MOOSE-first FOB/COP Hit event qualification adapter.
--
-- This module does not create a parallel DCS event handler. Runtime event capture
-- uses MOOSE BASE:HandleEvent(EVENTS.Hit, ...). Strategic demand creation remains
-- delegated to OMW_FobAttackDemandPolicy and the existing MissionDemand registry.

local Adapter = {}

local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobAttackHitAdapter]"

Adapter.SchemaVersion = "OMW-FOB-ATTACK-HIT-ADAPTER-1"

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

local function validateTargetRegistration(registration, label)
  requireTable(registration, label)
  requireNonEmptyString(registration.installationId, label .. ".installationId")
  if not isFinite(registration.priority) then
    fail(label .. ".priority must be a finite number")
  end
  return registration
end

local function normalizeRegistrationMap(source, label)
  local result = {}
  if source == nil then
    return result
  end
  requireTable(source, label)
  for targetName, registration in pairs(source) do
    requireNonEmptyString(targetName, label .. " target name")
    result[targetName] = validateTargetRegistration(registration, label .. "[" .. targetName .. "]")
  end
  return result
end

local function resolveRegistration(instance, eventData)
  local groupName = eventData.TgtGroupName
  if type(groupName) == "string" and groupName ~= "" then
    local registration = instance.targetGroups[groupName]
    if registration then
      return registration, "GROUP", groupName
    end
  end

  local unitName = eventData.TgtUnitName
  if type(unitName) == "string" and unitName ~= "" then
    local registration = instance.targetUnits[unitName]
    if registration then
      return registration, "UNIT", unitName
    end
  end

  return nil, nil, nil
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

  requireFunction(registry, "Create", "registry")
  requireFunction(policy, "CreateDemand", "policy")

  if type(missionDemand.Type) ~= "table" or missionDemand.Type.CAS_IMMEDIATE == nil then
    fail("missionDemand.Type.CAS_IMMEDIATE is required")
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
  if type(spec.incidentIdFactory) ~= "function" then
    fail("incidentIdFactory(eventData, registration) is required")
  end
  if spec.positionResolver ~= nil and type(spec.positionResolver) ~= "function" then
    fail("positionResolver must be a function when provided")
  end
  if spec.eventBaseFactory ~= nil and type(spec.eventBaseFactory) ~= "function" then
    fail("eventBaseFactory must be a function when provided")
  end
  if spec.eventsHit ~= nil and not isFinite(spec.eventsHit) then
    fail("eventsHit must be a finite number when provided")
  end

  local self = setmetatable({
    missionDemand = missionDemand,
    registry = registry,
    policy = policy,
    blueCoalition = spec.blueCoalition,
    redCoalition = spec.redCoalition,
    incidentIdFactory = spec.incidentIdFactory,
    positionResolver = spec.positionResolver,
    eventBaseFactory = spec.eventBaseFactory,
    eventsHit = spec.eventsHit,
    targetGroups = normalizeRegistrationMap(spec.targetGroups, "targetGroups"),
    targetUnits = normalizeRegistrationMap(spec.targetUnits, "targetUnits"),
    listener = nil,
    started = false,
  }, Instance)

  return self
end

function Instance:_log(message)
  if self.listener and type(self.listener.I) == "function" then
    self.listener:I(TAG .. " " .. tostring(message))
  end
end

function Instance:QualifyHit(eventData)
  if type(eventData) ~= "table" then
    return nil, "INVALID_EVENT_DATA"
  end

  if eventData.IniCoalition ~= self.redCoalition then
    return nil, "INITIATOR_NOT_RED"
  end
  if eventData.TgtCoalition ~= self.blueCoalition then
    return nil, "TARGET_NOT_BLUE"
  end

  local registration, targetKind, targetName = resolveRegistration(self, eventData)
  if not registration then
    return nil, "TARGET_NOT_REGISTERED"
  end

  local incidentId = self.incidentIdFactory(eventData, registration)
  requireNonEmptyString(incidentId, "incidentIdFactory result")

  local position = nil
  if self.positionResolver then
    position = copyPosition(self.positionResolver(eventData, registration))
  end

  return {
    incidentId = incidentId,
    installationId = registration.installationId,
    priority = registration.priority,
    position = position,
    reportedTarget = {
      targetKind = targetKind,
      targetName = targetName,
      targetUnitName = eventData.TgtUnitName,
      targetGroupName = eventData.TgtGroupName,
      initiatorUnitName = eventData.IniUnitName,
      initiatorGroupName = eventData.IniGroupName,
      weaponName = eventData.WeaponName,
    },
  }, nil
end

function Instance:ProcessHitEvent(eventData)
  local incident, qualificationReason = self:QualifyHit(eventData)
  if not incident then
    return nil, false, qualificationReason
  end

  local demand, created, demandReason = self.policy.CreateDemand(
    self.missionDemand,
    self.registry,
    incident
  )

  self:_log(string.format(
    "installationId=%s incidentId=%s demandId=%s created=%s reason=%s",
    tostring(incident.installationId),
    tostring(incident.incidentId),
    tostring(demand and demand.id),
    tostring(created),
    tostring(demandReason)
  ))

  return demand, created, demandReason
end

function Instance:Start()
  if self.started then
    return self, false
  end

  local hitEventId = self.eventsHit
  if hitEventId == nil then
    if type(EVENTS) ~= "table" or EVENTS.Hit == nil then
      fail("MOOSE EVENTS.Hit is required")
    end
    hitEventId = EVENTS.Hit
  end

  local listener = nil
  if self.eventBaseFactory then
    listener = self.eventBaseFactory()
  else
    if type(BASE) ~= "table" or type(BASE.New) ~= "function" then
      fail("MOOSE BASE:New() is required")
    end
    listener = BASE:New()
  end

  requireTable(listener, "event listener")
  requireFunction(listener, "HandleEvent", "event listener")
  requireFunction(listener, "UnHandleEvent", "event listener")

  self.listener = listener
  self.eventsHit = hitEventId
  listener:HandleEvent(hitEventId, function(_, eventData)
    self:ProcessHitEvent(eventData)
  end)

  self.started = true
  self:_log("started MOOSE EVENTS.Hit listener")
  return self, true
end

function Instance:Stop()
  if not self.started then
    return self, false
  end

  self.listener:UnHandleEvent(self.eventsHit)
  self:_log("stopped MOOSE EVENTS.Hit listener")
  self.started = false
  self.listener = nil
  return self, true
end

return Adapter
