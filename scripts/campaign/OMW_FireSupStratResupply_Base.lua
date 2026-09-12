-- Operation Mountain Watch - site-independent Fire Support / Strategic Resupply base.
-- Gate 3 coordinator only. No asset selection, retry queue, scheduler or resource stock.

local Base = {}
local Instance = {}
Instance.__index = Instance
Base.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-1"

local TAG = "[OMW][FireSupStratResupply.Base]"
local ORDER = {
  { key="guards", type="GUARD" }, { key="qrf", type="QRF" },
  { key="artillery", type="ARTY" }, { key="cas", type="CAS" },
  { key="groundResupply", type="GROUND_RESUPPLY" }, { key="airResupply", type="AIR_RESUPPLY" },
}

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end

local function enabled(profile, entry)
  if entry.type == "GROUND_RESUPPLY" then return profile.support.resupply and profile.support.resupply.enabled == true and profile.support.resupply.ground == true end
  if entry.type == "AIR_RESUPPLY" then return profile.support.resupply and profile.support.resupply.enabled == true and profile.support.resupply.air == true end
  return profile.support[entry.key] and profile.support[entry.key].enabled == true
end

local function route(profile, supportType)
  if supportType == "CAS" or supportType == "AIR_RESUPPLY" then return profile.routes and profile.routes.helicopterProfile or nil end
  if supportType == "GUARD" or supportType == "QRF" or supportType == "GROUND_RESUPPLY" then return profile.routes and profile.routes.groundProfile or nil end
  return nil
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

function Instance:_buildDemand(incident, site, profile, supportType)
  local demandId = self.idContract.Demand(incident.incidentId, supportType)
  local resourceIds = nil
  if supportType == "GROUND_RESUPPLY" or supportType == "AIR_RESUPPLY" then
    resourceIds = {}
    for _, resourceId in ipairs((profile.support.resupply and profile.support.resupply.resourceIds) or {}) do resourceIds[#resourceIds+1] = resourceId end
  end
  return {
    incidentId=incident.incidentId, demandId=demandId, siteId=incident.siteId, supportType=supportType,
    requestedAt=incident.requestedAt, priority=incident.priority,
    tacticalContext={alarmZone=site.alarmZoneName, tacticalZone=site.tacticalZoneName, campaignNodeId=site.campaignNodeId, supplyParentNodeId=site.supplyParentNodeId, fireSupportNodeId=site.fireSupportNodeId, routeProfile=route(profile, supportType)},
    validity={expiresAt=incident.expiresAt, cancelWhenIncidentClosed=incident.cancelWhenIncidentClosed},
    resourceIds=resourceIds, correlationId=demandId, status="CREATED",
  }
end

function Instance:OpenIncident(spec)
  needTable(spec, "spec")
  local siteId = needString(spec.siteId, "siteId")
  local incidentKey = needString(spec.incidentKey, "incidentKey")
  local site = self.siteRegistry.Sites[siteId]
  if not site then return nil, false, "SITE_NOT_FOUND" end
  local profile = self.supportProfiles.Profiles[site.supportProfileId]
  if not profile then return nil, false, "SUPPORT_PROFILE_NOT_FOUND" end
  local incidentId = self.idContract.Incident(siteId, incidentKey)
  if self.incidents[incidentId] then return self.incidents[incidentId], false, "ALREADY_OPEN" end
  local incident = {incidentId=incidentId, siteId=siteId, requestedAt=spec.requestedAt, priority=spec.priority, expiresAt=spec.expiresAt, cancelWhenIncidentClosed=spec.cancelWhenIncidentClosed ~= false, context=spec.context or {}, demandIds={}, closed=false}
  self.incidents[incidentId] = incident

  for _, entry in ipairs(ORDER) do
    if enabled(profile, entry) then
      local demand = self:_buildDemand(incident, site, profile, entry.type)
      self.demands[demand.demandId] = demand
      incident.demandIds[#incident.demandIds+1] = demand.demandId
      local adapter = self.adapters[entry.type]
      if not adapter or type(adapter.Dispatch) ~= "function" then
        demand.status = "NO_ADAPTER"
        self:_log(string.format("support unavailable incidentId=%s demandId=%s siteId=%s supportType=%s", incidentId, demand.demandId, siteId, entry.type))
      else
        local handle, created, reason = adapter:Dispatch(demand, {site=site, profile=profile, incident=incident, context=incident.context})
        demand.dispatchReason = reason
        if handle then self.lifecycle:Register(demand.demandId, handle); demand.status = created == false and "ALREADY_DISPATCHED" or "DISPATCHED" else demand.status = "NOT_DISPATCHED" end
        self:_log(string.format("support dispatch incidentId=%s demandId=%s siteId=%s supportType=%s status=%s reason=%s", incidentId, demand.demandId, siteId, entry.type, tostring(demand.status), tostring(reason)))
      end
    end
  end
  self:_log(string.format("incident opened incidentId=%s siteId=%s demands=%d", incidentId, siteId, #incident.demandIds))
  return incident, true, nil
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
