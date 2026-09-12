-- Operation Mountain Watch - installation attack incident runtime.
--
-- Routes installation alarm evidence into one authoritative attack-incident
-- coordinator per installation and forwards its lifecycle through the injected
-- bridge. This module does not scan DCS objects, evaluate resources, or select
-- operational assets.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-RUNTIME-1"
local TAG = "[OMW][FireSupStratResupply.InstallationIncidentRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end

function Runtime.New(spec)
  needTable(spec, "spec")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local incidentCoordinator = needTable(spec.incidentCoordinator, "incidentCoordinator")
  local bridge = needTable(spec.bridge, "bridge")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  needFunction(incidentCoordinator, "New", "incidentCoordinator")
  needFunction(bridge, "OnIncidentStarted", "bridge")
  needFunction(bridge, "OnIncidentUpdated", "bridge")
  needFunction(bridge, "OnIncidentClosed", "bridge")
  if spec.incidentIdFactory ~= nil and type(spec.incidentIdFactory) ~= "function" then fail("incidentIdFactory must be a function when provided") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  return setmetatable({
    siteRegistry=siteRegistry,
    incidentCoordinator=incidentCoordinator,
    bridge=bridge,
    incidentIdFactory=spec.incidentIdFactory,
    logger=spec.logger,
    coordinators={},
    prepared=false,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Prepare()
  if self.prepared then return self, false, "ALREADY_PREPARED" end
  local seen = {}
  for key, site in pairs(self.siteRegistry.Sites) do
    local installationId = type(site) == "table" and site.installationId or nil
    if type(installationId) ~= "string" or installationId == "" then
      return nil, false, "INSTALLATION_ID_MISSING:" .. tostring(key)
    end
    if seen[installationId] then return nil, false, "DUPLICATE_INSTALLATION_ID:" .. installationId end
    seen[installationId] = true

    local bridge = self.bridge
    local coordinator = self.incidentCoordinator.New({
      installationId=installationId,
      incidentIdFactory=self.incidentIdFactory,
      onIncidentStarted=function(instance, incident, evidence) return bridge:OnIncidentStarted(instance, incident, evidence) end,
      onIncidentUpdated=function(instance, incident, evidence) return bridge:OnIncidentUpdated(instance, incident, evidence) end,
      onIncidentClosed=function(instance, incident, reason) return bridge:OnIncidentClosed(instance, incident, reason) end,
    })
    self.coordinators[installationId] = coordinator
  end
  self.prepared = true
  self:_log("prepared installation incident coordinators")
  return self, true, nil
end

function Instance:ReportEvidence(evidence)
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  needTable(evidence, "evidence")
  local installationId = needString(evidence.installationId, "evidence.installationId")
  local coordinator = self.coordinators[installationId]
  if not coordinator then return nil, false, "INSTALLATION_NOT_REGISTERED" end
  return coordinator:ReportEvidence(evidence)
end

function Instance:CloseInstallationIncident(installationId, reason)
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  needString(installationId, "installationId")
  local coordinator = self.coordinators[installationId]
  if not coordinator then return nil, false, "INSTALLATION_NOT_REGISTERED" end
  return coordinator:Close(reason)
end

function Instance:GetCoordinator(installationId)
  needString(installationId, "installationId")
  return self.coordinators[installationId]
end

return Runtime
