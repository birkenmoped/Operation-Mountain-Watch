-- Operation Mountain Watch - installation-incident to generic Base bridge.
--
-- Consumes the authoritative installation attack incident lifecycle and forwards
-- only lifecycle state into the generic Fire Support / Strategic Resupply Base.
-- It does not detect threats, select assets, own resources, or close an incident
-- because an alarm/security perimeter becomes clear.

local Bridge = {}
local Instance = {}
Instance.__index = Instance

Bridge.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-1"
local TAG = "[OMW][FireSupStratResupply.InstallationIncidentBridge]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end

function Bridge.New(spec)
  needTable(spec, "spec")
  local base = needTable(spec.base, "base")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  needFunction(base, "OpenIncident", "base")
  needFunction(base, "RequestIncidentSupport", "base")
  needFunction(base, "CloseIncident", "base")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  local byInstallationId = {}
  for key, site in pairs(siteRegistry.Sites) do
    if type(site) == "table" and type(site.installationId) == "string" and site.installationId ~= "" then
      if byInstallationId[site.installationId] ~= nil then fail("duplicate installationId " .. site.installationId) end
      byInstallationId[site.installationId] = { site=site, siteId=site.siteId or key }
    end
  end

  return setmetatable({
    base=base,
    byInstallationId=byInstallationId,
    sourceToBaseIncident={},
    logger=spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:OnIncidentStarted(_, incident, evidence)
  needTable(incident, "incident")
  local sourceIncidentId = needString(incident.incidentId, "incident.incidentId")
  local installationId = needString(incident.installationId, "incident.installationId")
  local entry = self.byInstallationId[installationId]
  if not entry then return nil, false, "INSTALLATION_NOT_REGISTERED" end

  local opened, created, reason = self.base:OpenIncident({
    siteId=entry.siteId,
    incidentKey=sourceIncidentId,
    priority=incident.priority,
    context={
      source="INSTALLATION_ATTACK_INCIDENT",
      installationId=installationId,
      sourceIncidentId=sourceIncidentId,
      initialEvidenceType=evidence and evidence.evidenceType or nil,
    },
  })
  if not opened then return nil, false, reason end
  self.sourceToBaseIncident[sourceIncidentId] = opened.incidentId

  local qrf, qrfCreated, qrfReason = self.base:RequestIncidentSupport(opened.incidentId, "QRF", {
    requestKey="INSTALLATION_ATTACK_INITIAL_QRF",
    priority=incident.priority,
    context={
      activation="INCIDENT_LOCAL_DEFENSE",
      source="INSTALLATION_ATTACK_INCIDENT",
      sourceIncidentId=sourceIncidentId,
    },
  })

  self:_log(string.format(
    "incident started installationId=%s siteId=%s sourceIncidentId=%s baseIncidentId=%s created=%s qrfCreated=%s qrfReason=%s",
    installationId, tostring(entry.siteId), sourceIncidentId, tostring(opened.incidentId), tostring(created), tostring(qrfCreated), tostring(qrfReason)))
  return opened, created, qrfReason or reason, qrf
end

function Instance:OnIncidentUpdated(_, incident, evidence)
  needTable(incident, "incident")
  local sourceIncidentId = needString(incident.incidentId, "incident.incidentId")
  local baseIncidentId = self.sourceToBaseIncident[sourceIncidentId]
  if not baseIncidentId then return nil, false, "BASE_INCIDENT_NOT_BOUND" end
  self:_log(string.format(
    "incident refreshed sourceIncidentId=%s baseIncidentId=%s evidenceType=%s; no duplicate response demand",
    sourceIncidentId, tostring(baseIncidentId), tostring(evidence and evidence.evidenceType)))
  return baseIncidentId, false, "INCIDENT_REFRESH_ONLY"
end

function Instance:OnIncidentClosed(_, incident, reason)
  needTable(incident, "incident")
  local sourceIncidentId = needString(incident.incidentId, "incident.incidentId")
  local baseIncidentId = self.sourceToBaseIncident[sourceIncidentId]
  if not baseIncidentId then return nil, false, "BASE_INCIDENT_NOT_BOUND" end
  local closed, changed, closeReason = self.base:CloseIncident(baseIncidentId, reason or "INSTALLATION_INCIDENT_CLOSED")
  if changed or closeReason == "ALREADY_CLOSED" then self.sourceToBaseIncident[sourceIncidentId] = nil end
  self:_log(string.format(
    "incident closed sourceIncidentId=%s baseIncidentId=%s changed=%s reason=%s",
    sourceIncidentId, tostring(baseIncidentId), tostring(changed), tostring(reason)))
  return closed, changed, closeReason
end

function Instance:GetBaseIncidentId(sourceIncidentId)
  needString(sourceIncidentId, "sourceIncidentId")
  return self.sourceToBaseIncident[sourceIncidentId]
end

return Bridge
