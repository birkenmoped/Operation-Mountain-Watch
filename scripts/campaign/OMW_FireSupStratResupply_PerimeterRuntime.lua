-- Operation Mountain Watch - generic Fire Support / Strategic Resupply perimeter runtime assembly.
--
-- This module owns only assembly/wiring. Site-specific installation anchors and
-- alarm radii remain injected configuration. Threat qualification remains MOOSE
-- OPSZONE through OMW_FobThreatOpsZoneAdapter; incident/QRF handling remains in
-- OMW_FireSupStratResupply_PerimeterBridge and Base.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FireSupStratResupply.PerimeterRuntime]"
Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME-1"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end
local function isFinite(value) return type(value) == "number" and value == value and value > -math.huge and value < math.huge end

local function sortedSiteIds(sites)
  local ids = {}
  for siteId in pairs(sites) do ids[#ids + 1] = siteId end
  table.sort(ids)
  return ids
end

function Runtime.New(spec)
  needTable(spec, "spec")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local perimeterBridge = needTable(spec.perimeterBridge, "perimeterBridge")
  local threatAdapter = needTable(spec.threatAdapter, "threatAdapter")
  local perimeters = needTable(spec.perimeters, "perimeters")

  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  needFunction(perimeterBridge, "HandleThreat", "perimeterBridge")
  needFunction(perimeterBridge, "HandleClear", "perimeterBridge")
  needFunction(threatAdapter, "New", "threatAdapter")

  if not isFinite(spec.blueCoalition) or not isFinite(spec.redCoalition) or spec.blueCoalition == spec.redCoalition then
    fail("blueCoalition and redCoalition must be distinct finite values")
  end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  for siteId, site in pairs(siteRegistry.Sites) do
    needTable(site, "siteRegistry.Sites[" .. tostring(siteId) .. "]")
    needString(site.installationId, "site.installationId")
    local perimeter = needTable(perimeters[siteId], "perimeters[" .. tostring(siteId) .. "]")
    needTable(perimeter.anchorCoordinate, "perimeters[" .. tostring(siteId) .. "].anchorCoordinate")
    needFunction(perimeter.anchorCoordinate, "GetVec2", "perimeters[" .. tostring(siteId) .. "].anchorCoordinate")
    if not isFinite(perimeter.radiusM) or perimeter.radiusM <= 0 then fail("perimeters[" .. tostring(siteId) .. "].radiusM must be positive finite") end
    if not isFinite(perimeter.priority) then fail("perimeters[" .. tostring(siteId) .. "].priority must be finite") end
    if perimeter.updateSeconds ~= nil and (not isFinite(perimeter.updateSeconds) or perimeter.updateSeconds <= 0) then
      fail("perimeters[" .. tostring(siteId) .. "].updateSeconds must be positive finite when provided")
    end
    if perimeter.captureThreatlevel ~= nil and not isFinite(perimeter.captureThreatlevel) then
      fail("perimeters[" .. tostring(siteId) .. "].captureThreatlevel must be finite when provided")
    end
    if perimeter.captureNunits ~= nil and (not isFinite(perimeter.captureNunits) or perimeter.captureNunits < 1) then
      fail("perimeters[" .. tostring(siteId) .. "].captureNunits must be at least one when provided")
    end
  end

  return setmetatable({
    siteRegistry = siteRegistry,
    perimeterBridge = perimeterBridge,
    threatAdapter = threatAdapter,
    perimeters = perimeters,
    blueCoalition = spec.blueCoalition,
    redCoalition = spec.redCoalition,
    logger = spec.logger,
    siteRuntimes = {},
    startOrder = {},
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:StartSite(siteId)
  needString(siteId, "siteId")
  local site = self.siteRegistry.Sites[siteId]
  if not site then return nil, false, "SITE_NOT_FOUND" end
  if self.siteRuntimes[siteId] then return self.siteRuntimes[siteId], false, "ALREADY_STARTED" end

  local perimeter = self.perimeters[siteId]
  local bridge = self.perimeterBridge
  local zoneName = perimeter.zoneName or ("OMW_SECURITY_" .. site.installationId)

  local adapter = self.threatAdapter.New({
    anchorCoordinate = perimeter.anchorCoordinate,
    installationId = site.installationId,
    zoneName = zoneName,
    priority = perimeter.priority,
    radiusM = perimeter.radiusM,
    blueCoalition = self.blueCoalition,
    redCoalition = self.redCoalition,
    updateSeconds = perimeter.updateSeconds,
    captureThreatlevel = perimeter.captureThreatlevel,
    captureNunits = perimeter.captureNunits,
    threatHandler = function(threatRuntime, opsZone, incident)
      return bridge:HandleThreat(threatRuntime, opsZone, incident)
    end,
    onThreatCleared = function(threatRuntime, opsZone, defeatedCoalition, incident)
      return bridge:HandleClear(threatRuntime, opsZone, defeatedCoalition, incident)
    end,
  })

  needFunction(adapter, "Start", "threat adapter instance")
  needFunction(adapter, "Stop", "threat adapter instance")
  local _, started = adapter:Start()
  if started == false then return nil, false, "THREAT_ADAPTER_NOT_STARTED" end

  local state = {
    siteId = siteId,
    installationId = site.installationId,
    zoneName = zoneName,
    radiusM = perimeter.radiusM,
    priority = perimeter.priority,
    threatAdapter = adapter,
  }
  self.siteRuntimes[siteId] = state
  self.startOrder[#self.startOrder + 1] = siteId
  self:_log(string.format("started siteId=%s installationId=%s zone=%s radiusM=%s", siteId, site.installationId, zoneName, tostring(perimeter.radiusM)))
  return state, true, nil
end

function Instance:StartAll()
  local started = {}
  for _, siteId in ipairs(sortedSiteIds(self.siteRegistry.Sites)) do
    local state, created, reason = self:StartSite(siteId)
    if not state then
      for index = #started, 1, -1 do self:StopSite(started[index]) end
      return nil, false, string.format("SITE_START_FAILED:%s:%s", siteId, tostring(reason))
    end
    if created then started[#started + 1] = siteId end
  end
  return self.siteRuntimes, true, nil
end

function Instance:StopSite(siteId)
  needString(siteId, "siteId")
  local state = self.siteRuntimes[siteId]
  if not state then return nil, false, "NOT_STARTED" end
  local _, stopped = state.threatAdapter:Stop()
  self.siteRuntimes[siteId] = nil
  for index = #self.startOrder, 1, -1 do
    if self.startOrder[index] == siteId then table.remove(self.startOrder, index); break end
  end
  self:_log(string.format("stopped siteId=%s installationId=%s", siteId, state.installationId))
  return state, stopped ~= false, nil
end

function Instance:StopAll()
  local order = {}
  for index, siteId in ipairs(self.startOrder) do order[index] = siteId end
  for index = #order, 1, -1 do self:StopSite(order[index]) end
  return self, true, nil
end

function Instance:GetSiteRuntime(siteId)
  needString(siteId, "siteId")
  return self.siteRuntimes[siteId]
end

return Runtime
