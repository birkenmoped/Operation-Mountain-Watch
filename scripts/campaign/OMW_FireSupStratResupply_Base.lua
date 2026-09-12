-- Operation Mountain Watch - site-independent Fire Support / Strategic Resupply base.
-- Coordinator only. No asset selection, retry queue, scheduler or resource stock.

local Base = {}
local Instance = {}
Instance.__index = Instance
Base.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-2"

local TAG = "[OMW][FireSupStratResupply.Base]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end

local function supportEntry(profile, supportType)
  if supportType == "GUARD" then return profile.support.guards end
  if supportType == "QRF" then return profile.support.qrf end
  if supportType == "ARTY" then return profile.support.artillery end
  if supportType == "CAS" then return profile.support.cas end
  if supportType == "GROUND_RESUPPLY" then
    local r = profile.support.resupply
    return r and r.enabled == true and r.ground == true and r or nil
  end
  if supportType == "AIR_RESUPPLY" then
    local r = profile.support.resupply
    return r and r.enabled == true and r.air == true and r or nil
  end
  return nil
end

local function route(profile, supportType)
  if supportType == "CAS" or supportType == "AIR_RESUPPLY" then return profile.routes and profile.routes.helicopterProfile or nil end
  if supportType == "GUARD" or supportType == "QRF" or supportType == "GROUND_RESUPPLY" then return profile.routes and profile.routes.groundProfile or nil end
  return nil
end

local function resourceAllowed(profile, resourceId)
  if resourceId == nil then return true end
  local resupply = profile.support and profile.support.resupply
  for _, configured in ipairs((resupply and resupply.resourceIds) or {}) do
    if configured == resourceId then return true end
  end
  return false
end

function Base.New(spec)
  needTable(spec, "spec")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local supportProfiles = needTable(spec.supportProfiles, "supportProfiles")
  local idContract = needTable(spec.idContract, "idContract")
  local lifecycle = needTable(spec.lifecycleAdapter, "lifecycleAdapter")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  if type(supportProfiles.Profiles) ~= "table" then fail("supportProfiles.Profiles is required") end
  if type(idContract.Incident) ~= "function" or type(idContract.Demand) ~= "function" then fail("idContract Incident/Demand functions are required") end
  if type(lifecycle.Register) ~= "function" or type(lifecycle.Cancel) ~= "function" then fail("lifecycle Register/Cancel functions are required") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  return setmetatable({siteRegistry=siteRegistry, supportProfiles=supportProfiles, idContract=idContract, lifecycle=lifecycle, adapters=spec.adapters or {}, logger=spec.logger, incidents={}, demands={}}, Instance)
end

function Instance:_log(message) if self.logger then self.logger(TAG .. " " .. tostring(message)) end end

function Instance:_contextForIncident(incident)
  local site = self.siteRegistry.Sites[incident.siteId]
  if not site then return nil, nil, "SITE_NOT_FOUND" end
  local profile = self.supportProfiles.Profiles[site.supportProfileId]
  if not profile then return nil, nil, "SUPPORT_PROFILE_NOT_FOUND" end
  return site, profile, nil
end

function Instance:OpenIncident(spec)
  needTable(spec, "spec")
  local siteId = needString(spec.siteId, "siteId")
  local incidentKey = needString(spec.incidentKey, "incidentKey")
  local site = self.siteRegistry.Sites[siteId]
  if not site then return nil, false, "SITE_NOT_FOUND" end
  if not self.supportProfiles.Profiles[site.supportProfileId] then return nil, false, "SUPPORT_PROFILE_NOT_FOUND" end
  local incidentId = self.idContract.Incident(siteId, incidentKey)
  if self.incidents[incidentId] then return self.incidents[incidentId], false, "ALREADY_OPEN" end
  local incident = {incidentId=incidentId, siteId=siteId, requestedAt=spec.requestedAt, priority=spec.priority, expiresAt=spec.expiresAt, cancelWhenIncidentClosed=spec.cancelWhenIncidentClosed ~= false, context=spec.context or {}, demandIds={}, closed=false}
  self.incidents[incidentId] = incident
  self:_log(string.format("incident opened incidentId=%s siteId=%s", incidentId, siteId))
  return incident, true, nil
end

function Instance:RequestSupport(incidentId, supportType, spec)
  needString(incidentId, "incidentId")
  needString(supportType, "supportType")
  spec = spec or {}
  needTable(spec, "spec")
  local incident = self.incidents[incidentId]
  if not incident then return nil, false, "INCIDENT_NOT_FOUND" end
  if incident.closed then return nil, false, "INCIDENT_CLOSED" end
  local site, profile, contextReason = self:_contextForIncident(incident)
  if not site then return nil, false, contextReason end
  local configured = supportEntry(profile, supportType)
  if not configured or configured.enabled == false then return nil, false, "SUPPORT_NOT_ENABLED" end
  if (supportType == "GROUND_RESUPPLY" or supportType == "AIR_RESUPPLY") and not resourceAllowed(profile, spec.resourceId) then
    return nil, false, "RESOURCE_NOT_ALLOWED"
  end

  local demandId = self.idContract.Demand(incidentId, supportType, spec.requestKey)
  if self.demands[demandId] then return self.demands[demandId], false, "ALREADY_REQUESTED" end
  local demand = {
    incidentId=incidentId, demandId=demandId, siteId=incident.siteId, supportType=supportType,
    requestKey=spec.requestKey, requestedAt=spec.requestedAt or incident.requestedAt, priority=spec.priority or incident.priority,
    tacticalContext={alarmZone=site.alarmZoneName, tacticalZone=site.tacticalZoneName, campaignNodeId=site.campaignNodeId, supplyParentNodeId=site.supplyParentNodeId, fireSupportNodeId=site.fireSupportNodeId, routeProfile=route(profile, supportType)},
    validity={expiresAt=spec.expiresAt or incident.expiresAt, cancelWhenIncidentClosed=spec.cancelWhenIncidentClosed ~= false and incident.cancelWhenIncidentClosed},
    resourceId=spec.resourceId, quantity=spec.quantity, correlationId=demandId, context=spec.context or {}, status="CREATED",
  }
  self.demands[demandId] = demand
  incident.demandIds[#incident.demandIds+1] = demandId

  local adapter = self.adapters[supportType]
  if not adapter or type(adapter.Dispatch) ~= "function" then
    demand.status = "NO_ADAPTER"
    self:_log(string.format("support unavailable incidentId=%s demandId=%s siteId=%s supportType=%s resourceId=%s", incidentId, demandId, incident.siteId, supportType, tostring(spec.resourceId)))
    return demand, true, "NO_ADAPTER"
  end

  local handle, created, reason = adapter:Dispatch(demand, {site=site, profile=profile, incident=incident, context=incident.context, requestContext=demand.context})
  demand.dispatchReason = reason
  if handle then
    self.lifecycle:Register(demandId, handle)
    demand.status = created == false and "ALREADY_DISPATCHED" or "DISPATCHED"
  else
    demand.status = "NOT_DISPATCHED"
  end
  self:_log(string.format("support requested incidentId=%s demandId=%s siteId=%s supportType=%s resourceId=%s status=%s reason=%s", incidentId, demandId, incident.siteId, supportType, tostring(spec.resourceId), tostring(demand.status), tostring(reason)))
  return demand, true, reason
end

function Instance:ExpireDemand(demandId, reason)
  needString(demandId, "demandId")
  local demand = self.demands[demandId]
  if not demand then return nil, false, "DEMAND_NOT_FOUND" end
  local _, changed, why = self.lifecycle:Cancel(demandId, reason or "DEMAND_EXPIRED")
  if changed then demand.status = "CANCEL_REQUESTED" end
  self:_log(string.format("demand expiry incidentId=%s demandId=%s siteId=%s supportType=%s changed=%s", tostring(demand.incidentId), demandId, tostring(demand.siteId), tostring(demand.supportType), tostring(changed)))
  return demand, changed, why
end

function Instance:CloseIncident(incidentId, reason)
  needString(incidentId, "incidentId")
  local incident = self.incidents[incidentId]
  if not incident then return nil, false, "INCIDENT_NOT_FOUND" end
  if incident.closed then return incident, false, "ALREADY_CLOSED" end
  incident.closed = true
  for _, demandId in ipairs(incident.demandIds) do
    local demand = self.demands[demandId]
    if demand and demand.validity.cancelWhenIncidentClosed then
      local _, changed = self.lifecycle:Cancel(demandId, reason or "INCIDENT_CLOSED")
      if changed then demand.status = "CANCEL_REQUESTED" end
      self:_log(string.format("incident close forwarded incidentId=%s demandId=%s siteId=%s supportType=%s changed=%s", incidentId, demandId, tostring(demand.siteId), tostring(demand.supportType), tostring(changed)))
    end
  end
  return incident, true, nil
end

function Instance:GetDemand(demandId) needString(demandId, "demandId"); return self.demands[demandId] end
function Instance:GetIncident(incidentId) needString(incidentId, "incidentId"); return self.incidents[incidentId] end

return Base
