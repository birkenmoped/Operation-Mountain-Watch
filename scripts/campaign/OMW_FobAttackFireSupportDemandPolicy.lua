-- Operation Mountain Watch - qualified FOB/COP attack to immediate fire-support MissionDemand policy.
--
-- Campaign-domain only. Threat qualification remains owned by the existing MOOSE
-- OPSZONE adapter. This policy receives the qualified incident plus an already
-- selected/observed target description and creates one deduplicated fire-support
-- demand. It owns no physical artillery and no strategic resources.

local Policy = {}

local TAG = "[OMW][FobAttackFireSupportDemandPolicy]"

Policy.SchemaVersion = "OMW-FOB-ATTACK-FIRE-SUPPORT-DEMAND-POLICY-1"
Policy.CreatedReason = "FOB_ATTACK_FIRE_SUPPORT_REQUIRED"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function isFinite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function deepCopy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then fail("cyclic fire-support target data is not supported") end
  seen[value] = true
  local result = {}
  for key, item in pairs(value) do result[deepCopy(key, seen)] = deepCopy(item, seen) end
  seen[value] = nil
  return result
end

local function validateRegistry(registry)
  if type(registry) ~= "table" or type(registry.Create) ~= "function" then
    fail("registry requires MissionDemand Registry:Create")
  end
end

local function validateIncident(incident)
  if type(incident) ~= "table" then fail("incident must be a table") end
  requireNonEmptyString(incident.incidentId, "incidentId")
  requireNonEmptyString(incident.installationId, "installationId")
  if not isFinite(incident.priority) then fail("priority must be a finite number") end
end

local function validateTarget(target)
  if type(target) ~= "table" then fail("target must be a table") end
  requireNonEmptyString(target.targetKind, "target.targetKind")
  if type(target.position) ~= "table" then fail("target.position must be a table") end
  if not isFinite(target.position.x) or not isFinite(target.position.z) then
    fail("target.position requires finite x and z")
  end
end

function Policy.BuildDemandSpec(MissionDemand, incident, target)
  if type(MissionDemand) ~= "table"
      or type(MissionDemand.Type) ~= "table"
      or MissionDemand.Type.FIRE_SUPPORT_IMMEDIATE == nil then
    fail("MissionDemand.Type.FIRE_SUPPORT_IMMEDIATE is required")
  end

  validateIncident(incident)
  validateTarget(target)

  return {
    id = "MD-FIRE-SUPPORT-FOB-ATTACK|" .. incident.incidentId,
    missionType = MissionDemand.Type.FIRE_SUPPORT_IMMEDIATE,
    origin = incident.installationId,
    objective = "Provide immediate indirect fire support to attacked BLUE Ground installation",
    target = {
      installationId = incident.installationId,
      incidentId = incident.incidentId,
      fireSupportTarget = deepCopy(target),
    },
    priority = incident.priority,
    playerCapable = false,
    aiCapable = true,
    reservationState = "NOT_APPLICABLE",
    successCriteria = {
      fireMissionExecuted = true,
    },
    failureConsequences = {
      fireSupportUnavailable = true,
    },
    resourceReservation = nil,
    createdReason = Policy.CreatedReason,
    dedupeKey = "FIRE_SUPPORT_IMMEDIATE|FOB_ATTACK|" .. incident.installationId,
  }
end

function Policy.CreateDemand(MissionDemand, registry, incident, target)
  validateRegistry(registry)
  return registry:Create(Policy.BuildDemandSpec(MissionDemand, incident, target))
end

return Policy
