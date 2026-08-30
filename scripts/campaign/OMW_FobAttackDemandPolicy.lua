-- Operation Mountain Watch - qualified FOB/COP attack to CAS MissionDemand policy.
--
-- Campaign-domain only. Runtime hit qualification belongs to the MOOSE adapter;
-- this module receives an already qualified strategic installation incident and
-- creates/deduplicates the corresponding MissionDemand.

local Policy = {}

local TAG = "[OMW][FobAttackDemandPolicy]"

Policy.SchemaVersion = "OMW-FOB-ATTACK-DEMAND-POLICY-1"
Policy.CreatedReason = "FOB_ATTACK_QUALIFIED"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
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

local function deepCopy(value, seen)
  if type(value) ~= "table" then
    return value
  end

  seen = seen or {}
  if seen[value] then
    fail("cyclic incident data is not supported")
  end

  seen[value] = true
  local result = {}
  for key, item in pairs(value) do
    result[deepCopy(key, seen)] = deepCopy(item, seen)
  end
  seen[value] = nil
  return result
end

local function validateRegistry(registry)
  if type(registry) ~= "table" or type(registry.Create) ~= "function" then
    fail("registry requires MissionDemand Registry:Create")
  end
end

local function validateIncident(incident)
  if type(incident) ~= "table" then
    fail("incident must be a table")
  end

  requireNonEmptyString(incident.incidentId, "incidentId")
  requireNonEmptyString(incident.installationId, "installationId")

  if not isFinite(incident.priority) then
    fail("priority must be a finite number")
  end
end

function Policy.BuildDemandSpec(MissionDemand, incident)
  if type(MissionDemand) ~= "table"
      or type(MissionDemand.Type) ~= "table"
      or MissionDemand.Type.CAS_IMMEDIATE == nil then
    fail("MissionDemand.Type.CAS_IMMEDIATE is required")
  end

  validateIncident(incident)

  return {
    id = "MD-CAS-FOB-ATTACK|" .. incident.incidentId,
    missionType = MissionDemand.Type.CAS_IMMEDIATE,
    origin = incident.installationId,
    objective = "Defend attacked BLUE Ground installation",
    target = {
      installationId = incident.installationId,
      incidentId = incident.incidentId,
      position = deepCopy(incident.position),
      reportedTarget = deepCopy(incident.reportedTarget),
    },
    priority = incident.priority,
    playerCapable = true,
    aiCapable = true,
    reservationState = "NOT_APPLICABLE",
    successCriteria = {
      incidentResolved = true,
    },
    failureConsequences = {
      incidentRemainsUnresolved = true,
    },
    resourceReservation = nil,
    createdReason = Policy.CreatedReason,
    dedupeKey = "CAS_IMMEDIATE|FOB_ATTACK|" .. incident.installationId,
  }
end

function Policy.CreateDemand(MissionDemand, registry, incident)
  validateRegistry(registry)
  local spec = Policy.BuildDemandSpec(MissionDemand, incident)
  return registry:Create(spec)
end

return Policy
