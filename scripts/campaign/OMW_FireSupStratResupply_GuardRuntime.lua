-- Operation Mountain Watch - production Guard runtime assembly.
--
-- Wires the accepted Guard materializer and PATHLINE route adapter to the generic
-- local LEGION bridge. Injected BRIGADEs remain the MOOSE organisational boundary;
-- MOOSE selects/recruits the concrete Guard cohort/asset.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-1"
local TAG = "[OMW][FireSupStratResupply.GuardRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needCallable(value, label) if type(value) ~= "function" then fail(label .. " must be a function") end return value end

local function sortedSiteIds(sites)
  local ids = {}
  for siteId in pairs(sites) do ids[#ids + 1] = siteId end
  table.sort(ids)
  return ids
end

function Runtime.New(spec)
  needTable(spec, "spec")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local brigades = needTable(spec.brigades, "brigades")
  local materializationAdapter = needTable(spec.materializationAdapter, "materializationAdapter")
  local routeAdapter = needTable(spec.routeAdapter, "routeAdapter")
  local guardMissionFactory = needTable(spec.guardMissionFactory, "guardMissionFactory")
  local legionBridge = needTable(spec.legionBridge, "legionBridge")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  needFunction(materializationAdapter, "New", "materializationAdapter")
  needFunction(routeAdapter, "New", "routeAdapter")
  needFunction(guardMissionFactory, "New", "guardMissionFactory")
  needFunction(legionBridge, "New", "legionBridge")
  local resolvePathline = needCallable(spec.resolvePathline, "resolvePathline")
  local resolveTemplateGroup = needCallable(spec.resolveTemplateGroup, "resolveTemplateGroup")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  for siteId, site in pairs(siteRegistry.Sites) do
    needTable(site, "siteRegistry.Sites[" .. tostring(siteId) .. "]")
    if type(site.guardTemplateName) ~= "string" or site.guardTemplateName == "" then fail("guardTemplateName missing for " .. tostring(siteId)) end
    if type(site.guardRoute) ~= "table" or type(site.guardRoute.pathlineName) ~= "string" or site.guardRoute.pathlineName == "" then
      fail("guardRoute.pathlineName missing for " .. tostring(siteId))
    end
    needTable(brigades[siteId], "brigades[" .. tostring(siteId) .. "]")
  end

  return setmetatable({
    siteRegistry = siteRegistry,
    brigades = brigades,
    materializationAdapter = materializationAdapter,
    routeAdapter = routeAdapter,
    guardMissionFactory = guardMissionFactory,
    legionBridge = legionBridge,
    resolvePathline = resolvePathline,
    resolveTemplateGroup = resolveTemplateGroup,
    logger = spec.logger,
    materializers = {},
    routeAdapters = {},
    prepared = false,
    dispatchBridge = nil,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Prepare()
  if self.prepared then return self, false, "ALREADY_PREPARED" end

  for _, siteId in ipairs(sortedSiteIds(self.siteRegistry.Sites)) do
    local site = self.siteRegistry.Sites[siteId]
    local brigade = self.brigades[siteId]
    local pathline = self.resolvePathline(site.guardRoute.pathlineName, siteId, site)
    if not pathline then fail("Guard PATHLINE unavailable for " .. siteId .. ": " .. site.guardRoute.pathlineName) end
    local templateGroup = self.resolveTemplateGroup(site.guardTemplateName, siteId, site)
    if not templateGroup then fail("Guard template unavailable for " .. siteId .. ": " .. site.guardTemplateName) end

    local materializer = self.materializationAdapter.New({
      siteId = site.siteId or siteId,
      guardTemplateName = site.guardTemplateName,
      pathline = pathline,
      templateGroup = templateGroup,
      targetSpacingM = 2,
      minimumSpacingM = 0.75,
      logger = self.logger,
    }):Prepare()
    materializer:Install(brigade)

    local router = self.routeAdapter.New({
      siteId = site.siteId or siteId,
      pathline = pathline,
      materializer = materializer,
      speedKmph = 5,
      formation = "Off Road",
      formationIntervalM = 2,
      logger = self.logger,
    })
    router:Install(brigade)

    self.materializers[siteId] = materializer
    self.routeAdapters[siteId] = router
    self:_log(string.format("prepared siteId=%s pathline=%s template=%s", siteId, site.guardRoute.pathlineName, site.guardTemplateName))
  end

  local factory = self.guardMissionFactory.New({
    materializers = self.materializers,
    routeAdapters = self.routeAdapters,
    logger = self.logger,
  })
  self.dispatchBridge = self.legionBridge.New({
    resolveLegion = function(siteId)
      local brigade = self.brigades[siteId]
      if not brigade then return nil, "SITE_LEGION_NOT_CONFIGURED" end
      return brigade
    end,
    factory = function(demand, context, legion)
      return factory:Create(demand, context, legion)
    end,
    logger = self.logger,
  })
  self.guardFactory = factory
  self.prepared = true
  return self, true, nil
end

function Instance:Dispatch(demand, context)
  if not self.prepared or not self.dispatchBridge then return nil, false, "GUARD_RUNTIME_NOT_PREPARED" end
  return self.dispatchBridge:Dispatch(demand, context)
end

function Instance:GetMaterializer(siteId)
  return self.materializers[siteId]
end

function Instance:GetRouteAdapter(siteId)
  return self.routeAdapters[siteId]
end

return Runtime
