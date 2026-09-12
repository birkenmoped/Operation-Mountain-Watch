-- Operation Mountain Watch - site-independent Fire Support / Strategic Resupply base.
-- Coordinator only. No asset selection, retry queue, scheduler or resource stock.

local Base = {}
local Instance = {}
Instance.__index = Instance
Base.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-3"

local TAG = "[OMW][FireSupStratResupply.Base]"

local INCIDENT_SUPPORT = { QRF=true, ARTY=true, CAS=true }
local RESUPPLY_SUPPORT = { GROUND_RESUPPLY=true, AIR_RESUPPLY=true }

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end
local function needPositiveNumber(value, label) if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then fail(label .. " requires positive finite number") end return value end

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
  if type(idContract.Incident) ~= "function" or type(idContract.Demand) ~= "function" or type(idContract.SiteDemand) ~= "function" then fail("idContract Incident/Demand/SiteDemand functions are required") end
  if type(lifecycle.Register) ~= "function" or type(lifecycle.Cancel) ~= "function" then fail("lifecycle Register/Cancel functions are required") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  return setmetatable({siteRegistry=siteRegistry, supportProfiles=supportProfiles, idContract=idContract, lifecycle=lifecycle, adapters=spec.adapters or {}, logger=spec.logger, incidents={}, demands={}, sites={}}, Instance)
end

function Instance:_log(message) if self.logger then self.logger(TAG .. " " .. tostring(message)) end end

function Instance:_contextForSite(siteId)
  local site = self.siteRegistry.Sites[siteId]
  if not site then return nil, nil, "SITE_NOT_FOUND" end
  local profile = self.supportProfiles.Profiles[site.supportProfileId]
  if not profile then return nil, nil, "SUPPORT_PROFILE_NOT_FOUND" end
  return site, profile, nil
end

function Instance:_dispatch(demand, site, profile, context)
  self.demands[demand.demandId] = demand
  local adapter = self.adapters[demand.supportType]
  if not adapter or type(adapter.Dispatch) ~= "function" then
    demand.status = "NO_ADAPTER"
    self:_log(string.format("support unavailable demandId=%s siteId=%s supportType=%s scope=%s resourceId=%s", demand.demandId, demand.siteId, demand.supportType, tostring(demand.scope), tostring(demand.resourceId)))
    return demand, true, "NO_ADAPTER"
  end
  local handle, created, reason = adapter:Dispatch(demand, context)
  demand.dispatchReason = reason
  if handle then
    self.lifecycle:Register(demand.demandId, handle)
    demand.status = created == false and "ALREADY_DISPATCHED" or "DISPATCHED"
  else
    demand.status = "NOT_DISPATCHED"
  end
  self:_log(string.format("support requested demandId=%s siteId=%s supportType=%s scope=%s resourceId=%s status=%s reason=%s", demand.demandId, demand.siteId, demand.supportType, tostring(demand.scope), tostring(demand.resourceId), tostring(demand.status), tostring(reason)))
  return demand, true, reason
end

function Instance:StartSite(siteId, spec)
  needString(siteId, "siteId")
  spec = spec or {}
  needTable(spec, "spec")
  local site, profile, reason = self:_contextForSite(siteId)
  if not site then return nil, false, reason end
  if self.sites[siteId] then return self.sites[siteId], false, "ALREADY_STARTED" end
  local guard = supportEntry(profile, "GUARD")
  if not guard or guard.enabled ~= true then return nil, false, "GUARD_NOT_ENABLED" end
  local demandId = self.idContract.SiteDemand(siteId, "GUARD", "PERSISTENT")
  local demand = {
    demandId=demandId, incidentId=nil, siteId=siteId, supportType="GUARD", scope="SITE_SECURITY",
    requestKey="PERSISTENT", requestedAt=spec.requestedAt, priority=spec.priority,
    tacticalContext={alarmZone=site.alarmZoneName, tacticalZone=site.tacticalZoneName, campaignNodeId=site.campaignNodeId, routeProfile=route(profile, "GUARD")},
    validity={expiresAt=nil, cancelWhenIncidentClosed=false}, resourceId=nil, quantity=nil,
    correlationId=demandId, context=spec.context or {}, status="CREATED",
  }
  local state = {siteId=siteId, guardDemandId=demandId, started=true}
  self.sites[siteId] = state
  local _, created, dispatchReason = self:_dispatch(demand, site, profile, {site=site, profile=profile, siteState=state, context=demand.context})
  return state, created, dispatchReason
end

function Instance:OpenIncident(spec)
  needTable(spec, "spec")
  local siteId = needString(spec.siteId, "siteId")
  local incidentKey = needString(spec.incidentKey, "incidentKey")
  local site, _, reason = self:_contextForSite(siteId)
  if not site then return nil, false, reason end
  local incidentId = self.idContract.Incident(siteId, incidentKey)
  if self.incidents[incidentId] then return self.incidents[incidentId], false, "ALREADY_OPEN" end
  local incident = {incidentId=incidentId, siteId=siteId, requestedAt=spec.requestedAt, priority=spec.priority, expiresAt=spec.expiresAt, cancelWhenIncidentClosed=spec.cancelWhenIncidentClosed ~= false, context=spec.context or {}, demandIds={}, closed=false}
  self.incidents[incidentId] = incident
  self:_log(string.format("incident opened incidentId=%s siteId=%s", incidentId, siteId))
  return incident, true, nil
end

function Instance:RequestIncidentSupport(incidentId, supportType, spec)
  needString(incidentId, "incidentId")
  needString(supportType, "supportType")
  if not INCIDENT_SUPPORT[supportType] then return nil, false, "SUPPORT_NOT_INCIDENT_SCOPED" end
  spec = spec or {}
  needTable(spec, "spec")
  local incident = self.incidents[incidentId]
  if not incident then return nil, false, "INCIDENT_NOT_FOUND" end
  if incident.closed then return nil, false, "INCIDENT_CLOSED" end
  local site, profile, contextReason = self:_contextForSite(incident.siteId)
  if not site then return nil, false, contextReason end
  local configured = supportEntry(profile, supportType)
  if not configured or configured.enabled == false then return nil, false, "SUPPORT_NOT_ENABLED" end
  local demandId = self.idContract.Demand(incidentId, supportType, spec.requestKey)
  if self.demands[demandId] then return self.demands[demandId], false, "ALREADY_REQUESTED" end
  local demand = {
    incidentId=incidentId, demandId=demandId, siteId=incident.siteId, supportType=supportType, scope="INCIDENT_RESPONSE",
    requestKey=spec.requestKey, requestedAt=spec.requestedAt or incident.requestedAt, priority=spec.priority or incident.priority,
    tacticalContext={alarmZone=site.alarmZoneName, tacticalZone=site.tacticalZoneName, campaignNodeId=site.campaignNodeId, fireSupportNodeId=site.fireSupportNodeId, routeProfile=route(profile, supportType)},
    validity={expiresAt=spec.expiresAt or incident.expiresAt, cancelWhenIncidentClosed=spec.cancelWhenIncidentClosed ~= false and incident.cancelWhenIncidentClosed},
    resourceId=nil, quantity=nil, correlationId=demandId, context=spec.context or {}, status="CREATED",
  }
  incident.demandIds[#incident.demandIds+1] = demandId
  return self:_dispatch(demand, site, profile, {site=site, profile=profile, incident=incident, context=incident.context, requestContext=demand.context})
end

function Instance:RequestResupply(siteId, supportType, spec)
  needString(siteId, "siteId")
  needString(supportType, "supportType")
  if not RESUPPLY_SUPPORT[supportType] then return nil, false, "SUPPORT_NOT_RESUPPLY_SCOPED" end
  needTable(spec, "spec")
  local requestKey = needString(spec.requestKey, "requestKey")
  local resourceId = needString(spec.resourceId, "resourceId")
  local quantity = needPositiveNumber(spec.quantity, "quantity")
  local site, profile, reason = self:_contextForSite(siteId)
  if not site then return nil, false, reason end
  local configured = supportEntry(profile, supportType)
  if not configured or configured.enabled == false then return nil, false, "SUPPORT_NOT_ENABLED" end
  if not resourceAllowed(profile, resourceId) then return nil, false, "RESOURCE_NOT_ALLOWED" end
  local demandId = self.idContract.SiteDemand(siteId, supportType, requestKey)
  if self.demands[demandId] then return self.demands[demandId], false, "ALREADY_REQUESTED" end
  local demand = {
    incidentId=nil, demandId=demandId, siteId=siteId, supportType=supportType, scope="RESOURCE_RESUPPLY",
    requestKey=requestKey, requestedAt=spec.requestedAt, priority=spec.priority,
    tacticalContext={alarmZone=site.alarmZoneName, tacticalZone=site.tacticalZoneName, campaignNodeId=site.campaignNodeId, supplyParentNodeId=site.supplyParentNodeId, routeProfile=route(profile, supportType)},
    validity={expiresAt=spec.expiresAt, cancelWhenIncidentClosed=false},
    resourceId=resourceId, quantity=quantity, correlationId=demandId, context=spec.context or {}, status="CREATED",
  }
  return self:_dispatch(demand, site, profile, {site=site, profile=profile, context=demand.context})
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
function Instance:GetSite(siteId) needString(siteId, "siteId"); return self.sites[siteId] end

return Base
