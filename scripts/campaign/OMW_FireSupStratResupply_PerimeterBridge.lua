-- Operation Mountain Watch - perimeter evidence bridge.
--
-- Converts a qualified MOOSE OPSZONE proximity intrusion into one evidence item
-- for the authoritative installation attack incident layer. It does not open or
-- close Base incidents directly and it does not request QRF/ARTY/CAS itself.

local Bridge = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FireSupStratResupply.PerimeterBridge]"
Bridge.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-2"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
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

function Instance:HandleThreat(_, _, incident)
  needTable(incident, "incident")
  local entry = self.byInstallationId[incident.installationId]
  if not entry then return nil, false, "INSTALLATION_NOT_REGISTERED" end

  local sourceIncidentId = incident.incidentId
  local evidence = {
    installationId=incident.installationId,
    evidenceType="PROXIMITY_INTRUSION",
    priority=incident.priority,
    position=incident.position,
    reportedTarget=incident.reportedTarget,
    sourceEvent="OPSZONE_Attacked",
    sourceIncidentId=sourceIncidentId,
  }
  local authoritativeIncident, created, reason = self.incidentRuntime:ReportEvidence(evidence)
  self:_log(string.format(
    "proximity evidence installationId=%s siteId=%s sourceIncidentId=%s authoritativeIncidentId=%s created=%s reason=%s",
    tostring(incident.installationId), tostring(entry.siteId), tostring(sourceIncidentId),
    tostring(authoritativeIncident and authoritativeIncident.incidentId), tostring(created), tostring(reason)))
  return authoritativeIncident, created, reason, evidence
end

function Instance:HandleClear(_, _, defeatedCoalition, incident)
  -- Perimeter clear is evidence state only. The authoritative installation attack
  -- incident layer decides tactical completion and explicit incident closure.
  self:_log(string.format(
    "perimeter clear observed installationId=%s sourceIncidentId=%s defeatedCoalition=%s; no incident close",
    tostring(incident and incident.installationId), tostring(incident and incident.incidentId), tostring(defeatedCoalition)))
  return incident, false, "PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT"
end

return Bridge
