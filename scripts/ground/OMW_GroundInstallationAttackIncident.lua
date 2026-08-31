-- Operation Mountain Watch - installation attack incident coordinator.
--
-- Collects multiple MOOSE-derived alarm evidence items into exactly one active
-- incident per installation. It owns neither CampaignState nor MissionDemand.

local Coordinator = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][GroundInstallationAttackIncident]"
Coordinator.SchemaVersion = "OMW-GROUND-INSTALLATION-ATTACK-INCIDENT-1"
Coordinator.Status = { ACTIVE="ACTIVE", CLOSED="CLOSED" }

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

function Coordinator.New(spec)
  requireTable(spec, "spec")
  requireNonEmptyString(spec.installationId, "installationId")
  for _, name in ipairs({ "incidentIdFactory", "onIncidentStarted", "onIncidentUpdated", "onIncidentClosed" }) do
    if spec[name] ~= nil and type(spec[name]) ~= "function" then fail(name .. " must be a function when provided") end
  end
  return setmetatable({
    installationId=spec.installationId,
    incidentIdFactory=spec.incidentIdFactory,
    onIncidentStarted=spec.onIncidentStarted,
    onIncidentUpdated=spec.onIncidentUpdated,
    onIncidentClosed=spec.onIncidentClosed,
    sequence=0,
    active=nil,
    history={},
  }, Instance)
end

function Instance:_newIncident()
  self.sequence = self.sequence + 1
  local incidentId
  if self.incidentIdFactory then
    incidentId = self.incidentIdFactory(self.installationId, self.sequence)
  else
    incidentId = string.format("INSTALLATION-ATTACK|%s|%d", self.installationId, self.sequence)
  end
  requireNonEmptyString(incidentId, "incidentId")
  return {
    incidentId=incidentId,
    installationId=self.installationId,
    status=Coordinator.Status.ACTIVE,
    evidence={},
    evidenceCount=0,
    participantsByName={},
    closeReason=nil,
  }
end

function Instance:_participantName(group)
  if type(group) ~= "table" or type(group.GetName) ~= "function" then return nil end
  local name = group:GetName()
  if type(name) ~= "string" or name == "" then return nil end
  return name
end

function Instance:AddParticipant(group)
  if not self.active or self.active.status ~= Coordinator.Status.ACTIVE then return false, "NO_ACTIVE_INCIDENT" end
  local name = self:_participantName(group)
  if not name then return false, "INVALID_PARTICIPANT" end
  if self.active.participantsByName[name] == group then return false, "PARTICIPANT_ALREADY_PRESENT" end
  self.active.participantsByName[name] = group
  return true, nil
end

function Instance:AddParticipants(groups)
  if type(groups) ~= "table" then return 0 end
  local added = 0
  for _, group in pairs(groups) do
    local ok = self:AddParticipant(group)
    if ok then added = added + 1 end
  end
  return added
end

function Instance:ReportEvidence(evidence)
  requireTable(evidence, "evidence")
  if evidence.installationId ~= nil and evidence.installationId ~= self.installationId then
    return nil, false, "INSTALLATION_MISMATCH"
  end
  requireNonEmptyString(evidence.evidenceType, "evidence.evidenceType")

  local created = false
  if not self.active or self.active.status ~= Coordinator.Status.ACTIVE then
    self.active = self:_newIncident()
    created = true
  end

  self.active.evidenceCount = self.active.evidenceCount + 1
  self.active.evidence[self.active.evidenceCount] = evidence
  if evidence.initiatorGroup then self:AddParticipant(evidence.initiatorGroup) end
  if evidence.participantGroups then self:AddParticipants(evidence.participantGroups) end

  if created then
    if self.onIncidentStarted then self.onIncidentStarted(self, self.active, evidence) end
  elseif self.onIncidentUpdated then
    self.onIncidentUpdated(self, self.active, evidence)
  end
  return self.active, created, created and nil or "ACTIVE_INCIDENT_REFRESHED"
end

function Instance:GetActive()
  return self.active
end

function Instance:GetParticipants(aliveOnly)
  if not self.active then return {} end
  local result = {}
  for name, group in pairs(self.active.participantsByName) do
    local include = true
    if aliveOnly == true then
      include = type(group) == "table" and type(group.IsAlive) == "function" and group:IsAlive() == true
    end
    if include then result[#result+1] = { name=name, group=group } end
  end
  table.sort(result, function(a,b) return a.name < b.name end)
  local groups = {}
  for index, item in ipairs(result) do groups[index] = item.group end
  return groups
end

function Instance:HasAliveParticipants()
  return #self:GetParticipants(true) > 0
end

function Instance:Close(reason)
  if not self.active or self.active.status ~= Coordinator.Status.ACTIVE then return nil, false, "NO_ACTIVE_INCIDENT" end
  local incident = self.active
  incident.status = Coordinator.Status.CLOSED
  incident.closeReason = reason
  self.history[#self.history+1] = incident
  self.active = nil
  if self.onIncidentClosed then self.onIncidentClosed(self, incident, reason) end
  return incident, true, nil
end

function Instance:GetHistory()
  return self.history
end

return Coordinator
