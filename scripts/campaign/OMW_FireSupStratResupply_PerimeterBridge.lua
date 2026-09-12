-- Operation Mountain Watch - perimeter-to-FireSupStratResupply bridge.
--
-- Converts a qualified OPSZONE perimeter incident into the generic Base incident
-- contract. It requests only the local QRF at initial detection. External ARTY/CAS
-- remain explicit C2-escalation demands and are not triggered by perimeter entry.

local Bridge = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FireSupStratResupply.PerimeterBridge]"
Bridge.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-1"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end

function Bridge.New(spec)
  needTable(spec, "spec")
  local base = needTable(spec.base, "base")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  needFunction(base, "OpenIncident", "base")
  needFunction(base, "RequestIncidentSupport", "base")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  local byInstallationId = {}
  for key, site in pairs(siteRegistry.Sites) do
    if type(site) == "table" and type(site.installationId) == "string" and site.installationId ~= "" then
      if byInstallationId[site.installationId] then fail("duplicate installationId " .. site.installationId) end
      byInstallationId[site.installationId] = site
      if site.siteId == nil then site.siteId = key end
    end
  end

  return setmetatable({
    base = base,
    siteRegistry = siteRegistry,
    byInstallationId = byInstallationId,
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:HandleThreat(_, _, incident)
  needTable(incident, "incident")
  local site = self.byInstallationId[incident.installationId]
  if not site then return nil, false, "INSTALLATION_NOT_REGISTERED" end
  if type(incident.incidentId) ~= "string" or incident.incidentId == "" then return nil, false, "INCIDENT_ID_MISSING" end

  local opened, created, reason = self.base:OpenIncident({
    siteId = site.siteId,
    incidentKey = incident.incidentId,
    priority = incident.priority,
    context = {
      source = "OPSZONE_SECURITY_PERIMETER",
      installationId = incident.installationId,
      position = incident.position,
      reportedTarget = incident.reportedTarget,
      sourceIncidentId = incident.incidentId,
    },
  })
  if not opened then return nil, false, reason end

  local qrf, qrfCreated, qrfReason = self.base:RequestIncidentSupport(opened.incidentId, "QRF", {
    requestKey = "PERIMETER_INITIAL_QRF",
    priority = incident.priority,
    context = {
      activation = "INCIDENT_LOCAL_DEFENSE",
      source = "OPSZONE_SECURITY_PERIMETER",
    },
  })

  self:_log(string.format(
    "perimeter incident installationId=%s siteId=%s incidentId=%s opened=%s qrfCreated=%s qrfReason=%s",
    tostring(incident.installationId), tostring(site.siteId), tostring(opened.incidentId), tostring(created),
    tostring(qrfCreated), tostring(qrfReason)))

  -- The incident itself is the handler result. QRF dispatch state remains in Base.
  -- No ARTY/CAS request is made here; those remain explicit C2 escalation actions.
  return opened, created, qrfReason or reason, qrf
end

function Instance:HandleClear(_, _, defeatedCoalition, incident)
  -- Alarm-perimeter clear is observation state only. It must not end tactical
  -- support or close the Base incident automatically.
  self:_log(string.format(
    "perimeter clear observed installationId=%s sourceIncidentId=%s defeatedCoalition=%s; incident remains open",
    tostring(incident and incident.installationId), tostring(incident and incident.incidentId), tostring(defeatedCoalition)))
  return incident, false, "PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT"
end

return Bridge
