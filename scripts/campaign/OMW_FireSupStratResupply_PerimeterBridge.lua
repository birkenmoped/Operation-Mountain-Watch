-- Operation Mountain Watch - perimeter evidence bridge.
--
-- Converts a qualified MOOSE OPSZONE proximity intrusion into one evidence item
-- for the authoritative installation attack incident layer. Physical hostile groups
-- qualified by the OPSZONE scanned group set are carried as transient incident
-- participants so the local QRF can receive actual MOOSE target wrappers.

local Bridge = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FireSupStratResupply.PerimeterBridge]"
Bridge.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-4"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end

local function collectThreatGroups(opsZone, incident)
  if type(opsZone) ~= "table" or type(opsZone.GetScannedGroupSet) ~= "function" then
    return {}, nil, "OPSZONE_SCANNED_GROUP_SET_UNAVAILABLE"
  end
  local reported = incident and incident.reportedTarget
  local attackerCoalition = reported and reported.attackerCoalition
  if type(attackerCoalition) ~= "number" then
    return {}, nil, "ATTACKER_COALITION_UNAVAILABLE"
  end

  local scanned = opsZone:GetScannedGroupSet()
  if type(scanned) ~= "table" or type(scanned.GetSetObjects) ~= "function"
      or type(scanned.GetClosestGroup) ~= "function" then
    return {}, nil, "OPSZONE_SCANNED_GROUP_SET_INVALID"
  end

  local groups = {}
  for _, group in pairs(scanned:GetSetObjects() or {}) do
    if type(group) == "table" and type(group.IsAlive) == "function"
        and type(group.GetCoalition) == "function"
        and group:IsAlive() and group:GetCoalition() == attackerCoalition then
      groups[#groups + 1] = group
    end
  end
  table.sort(groups, function(left, right)
    local ln = type(left.GetName) == "function" and left:GetName() or ""
    local rn = type(right.GetName) == "function" and right:GetName() or ""
    return tostring(ln) < tostring(rn)
  end)

  local reference = nil
  if incident.position ~= nil then
    if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec3) ~= "function" then
      return groups, nil, "MOOSE_COORDINATE_NEW_FROM_VEC3_UNAVAILABLE"
    end
    reference = COORDINATE:NewFromVec3(incident.position)
  end
  if reference == nil then return groups, nil, "INCIDENT_REFERENCE_COORDINATE_UNAVAILABLE" end

  local closest = scanned:GetClosestGroup(reference, { attackerCoalition })
  if closest ~= nil and type(closest.IsAlive) == "function" and closest:IsAlive() then
    return groups, closest, nil
  end
  return groups, nil, "PHYSICAL_THREAT_GROUP_UNAVAILABLE"
end

function Bridge.New(spec)
  needTable(spec, "spec")
  local incidentRuntime = needTable(spec.incidentRuntime, "incidentRuntime")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  needFunction(incidentRuntime, "ReportEvidence", "incidentRuntime")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  local byInstallationId = {}
  for key, site in pairs(siteRegistry.Sites) do
    if type(site) == "table" and type(site.installationId) == "string" and site.installationId ~= "" then
      if byInstallationId[site.installationId] then fail("duplicate installationId " .. site.installationId) end
      byInstallationId[site.installationId] = {site=site,siteId=site.siteId or key}
    end
  end

  return setmetatable({
    incidentRuntime=incidentRuntime,
    byInstallationId=byInstallationId,
    logger=spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:HandleThreat(_, opsZone, incident)
  needTable(incident, "incident")
  local entry = self.byInstallationId[incident.installationId]
  if not entry then return nil, false, "INSTALLATION_NOT_REGISTERED" end

  local participantGroups, primaryThreatGroup, threatReason = collectThreatGroups(opsZone, incident)
  local sourceIncidentId = incident.incidentId
  local evidence = {
    installationId=incident.installationId,
    evidenceType="PROXIMITY_INTRUSION",
    priority=incident.priority,
    position=incident.position,
    reportedTarget=incident.reportedTarget,
    sourceEvent="MOOSE_OPSZONE_RED_PRESENCE",
    sourceIncidentId=sourceIncidentId,
    initiatorGroup=primaryThreatGroup,
    participantGroups=participantGroups,
  }
  local authoritativeIncident, created, reason = self.incidentRuntime:ReportEvidence(evidence)
  self:_log(string.format(
    "proximity evidence installationId=%s siteId=%s sourceIncidentId=%s authoritativeIncidentId=%s created=%s reason=%s physicalThreat=%s participants=%d threatReason=%s",
    tostring(incident.installationId), tostring(entry.siteId), tostring(sourceIncidentId),
    tostring(authoritativeIncident and authoritativeIncident.incidentId), tostring(created), tostring(reason),
    tostring(primaryThreatGroup and primaryThreatGroup:GetName()), #participantGroups, tostring(threatReason)))
  return authoritativeIncident, created, reason, evidence
end

function Instance:HandleClear(_, _, defeatedCoalition, incident)
  -- Perimeter clear is evidence state only. The authoritative installation attack
  -- incident layer decides tactical completion and explicit incident closure.
  self:_log(string.format(
    "perimeter RED presence cleared installationId=%s sourceIncidentId=%s coalition=%s; no incident close",
    tostring(incident and incident.installationId), tostring(incident and incident.incidentId), tostring(defeatedCoalition)))
  return incident, false, "PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT"
end

return Bridge
