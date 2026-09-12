-- Operation Mountain Watch - generic Fire Support / Strategic Resupply runtime.
--
-- Composition root for the generic Base. This module owns wiring only. It does not
-- select operational assets, invent tactical geometry, scan threats, own strategic
-- resources, or implement a second retry/queue authority.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-2"
local TAG = "[OMW][FireSupStratResupply.Runtime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function finite(value) return type(value)=="number" and value==value and value>-math.huge and value<math.huge end

function Runtime.New(spec)
  needTable(spec, "spec")
  local modules = needTable(spec.modules, "modules")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local supportProfiles = needTable(spec.supportProfiles, "supportProfiles")
  local idContract = needTable(spec.idContract, "idContract")
  local brigades = needTable(spec.brigades, "brigades")

  for _, name in ipairs({
    "base", "lifecycleAdapter", "guardRuntime", "qrfRuntime", "legionBridge",
    "guardMissionFactory", "qrfMissionFactory", "guardMaterializationAdapter", "guardRouteAdapter"
  }) do
    needTable(modules[name], "modules." .. name)
    needFunction(modules[name], "New", "modules." .. name)
  end

  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  if type(supportProfiles.Profiles) ~= "table" then fail("supportProfiles.Profiles is required") end
  if type(idContract.Incident) ~= "function" then fail("idContract.Incident() is required") end
  if type(spec.resolveGuardPathline) ~= "function" then fail("resolveGuardPathline must be a function") end
  if type(spec.resolveGuardTemplateGroup) ~= "function" then fail("resolveGuardTemplateGroup must be a function") end
  if type(spec.resolveQrfCoordinate) ~= "function" then fail("resolveQrfCoordinate must be a function") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  if spec.externalAdapters ~= nil and type(spec.externalAdapters) ~= "table" then fail("externalAdapters must be a table when provided") end

  if spec.perimeters ~= nil then
    needTable(spec.perimeters, "perimeters")
    for _, name in ipairs({"perimeterBridge", "perimeterRuntime", "threatAdapter"}) do
      needTable(modules[name], "modules." .. name)
      needFunction(modules[name], "New", "modules." .. name)
    end
    if not finite(spec.blueCoalition) or not finite(spec.redCoalition) or spec.blueCoalition == spec.redCoalition then
      fail("blueCoalition and redCoalition must be distinct finite values when perimeters are configured")
    end
  end

  if spec.resupply ~= nil then
    local resupply = needTable(spec.resupply, "resupply")
    needTable(modules.resupplyMonitor, "modules.resupplyMonitor")
    needFunction(modules.resupplyMonitor, "New", "modules.resupplyMonitor")
    needTable(resupply.policy, "resupply.policy")
    needFunction(resupply.policy, "Evaluate", "resupply.policy")
    needTable(resupply.store, "resupply.store")
    needFunction(resupply.store, "GetResource", "resupply.store")
    needTable(resupply.rows, "resupply.rows")
    if type(resupply.selectSupportType) ~= "function" then fail("resupply.selectSupportType must be a function") end
    if resupply.priorityForCandidate ~= nil and type(resupply.priorityForCandidate) ~= "function" then fail("resupply.priorityForCandidate must be a function when provided") end
  end

  return setmetatable({
    modules = modules,
    siteRegistry = siteRegistry,
    supportProfiles = supportProfiles,
    idContract = idContract,
    brigades = brigades,
    resolveGuardPathline = spec.resolveGuardPathline,
    resolveGuardTemplateGroup = spec.resolveGuardTemplateGroup,
    resolveQrfCoordinate = spec.resolveQrfCoordinate,
    qrfRequiredAssetsMin = spec.qrfRequiredAssetsMin or 1,
    qrfRequiredAssetsMax = spec.qrfRequiredAssetsMax or (spec.qrfRequiredAssetsMin or 1),
    externalAdapters = spec.externalAdapters or {},
    perimeters = spec.perimeters,
    blueCoalition = spec.blueCoalition,
    redCoalition = spec.redCoalition,
    resupply = spec.resupply,
    logger = spec.logger,
    prepared = false,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Prepare()
  if self.prepared then return self, false, "ALREADY_PREPARED" end

  local m = self.modules
  local guard = m.guardRuntime.New({
    siteRegistry = self.siteRegistry,
    brigades = self.brigades,
    materializationAdapter = m.guardMaterializationAdapter,
    routeAdapter = m.guardRouteAdapter,
    guardMissionFactory = m.guardMissionFactory,
    legionBridge = m.legionBridge,
    resolvePathline = self.resolveGuardPathline,
    resolveTemplateGroup = self.resolveGuardTemplateGroup,
    logger = self.logger,
  })
  local _, guardPrepared, guardReason = guard:Prepare()
  if guardPrepared == false and guardReason ~= "ALREADY_PREPARED" then
    return nil, false, "GUARD_PREPARE_FAILED:" .. tostring(guardReason)
  end

  local qrf = m.qrfRuntime.New({
    siteRegistry = self.siteRegistry,
    brigades = self.brigades,
    qrfMissionFactory = m.qrfMissionFactory,
    legionBridge = m.legionBridge,
    resolveCoordinate = self.resolveQrfCoordinate,
    requiredAssetsMin = self.qrfRequiredAssetsMin,
    requiredAssetsMax = self.qrfRequiredAssetsMax,
    logger = self.logger,
  })

  local lifecycle = m.lifecycleAdapter.New({ logger=self.logger })
  local adapters = {}
  for supportType, adapter in pairs(self.externalAdapters) do adapters[supportType] = adapter end
  if adapters.GUARD ~= nil or adapters.QRF ~= nil then fail("externalAdapters must not override GUARD or QRF") end
  adapters.GUARD = guard
  adapters.QRF = qrf

  local base = m.base.New({
    siteRegistry = self.siteRegistry,
    supportProfiles = self.supportProfiles,
    idContract = self.idContract,
    lifecycleAdapter = lifecycle,
    adapters = adapters,
    logger = self.logger,
  })

  local perimeterBridge, perimeterRuntime
  if self.perimeters ~= nil then
    perimeterBridge = m.perimeterBridge.New({
      base = base,
      siteRegistry = self.siteRegistry,
      logger = self.logger,
    })
    perimeterRuntime = m.perimeterRuntime.New({
      siteRegistry = self.siteRegistry,
      perimeterBridge = perimeterBridge,
      threatAdapter = m.threatAdapter,
      perimeters = self.perimeters,
      blueCoalition = self.blueCoalition,
      redCoalition = self.redCoalition,
      logger = self.logger,
    })
  end

  local resupplyMonitor
  if self.resupply ~= nil then
    resupplyMonitor = m.resupplyMonitor.New({
      base = base,
      siteRegistry = self.siteRegistry,
      policy = self.resupply.policy,
      store = self.resupply.store,
      rows = self.resupply.rows,
      selectSupportType = self.resupply.selectSupportType,
      priorityForCandidate = self.resupply.priorityForCandidate,
      logger = self.logger,
    })
  end

  self.guardRuntime = guard
  self.qrfRuntime = qrf
  self.lifecycle = lifecycle
  self.base = base
  self.perimeterBridge = perimeterBridge
  self.perimeterRuntime = perimeterRuntime
  self.resupplyMonitor = resupplyMonitor
  self.adapters = adapters
  self.prepared = true
  self:_log(string.format("prepared generic runtime; perimeters=%s resupplyMonitor=%s",
    tostring(perimeterRuntime ~= nil), tostring(resupplyMonitor ~= nil)))
  return self, true, nil
end

function Instance:GetBase()
  if not self.prepared then return nil end
  return self.base
end

function Instance:StartSite(siteId, spec)
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  return self.base:StartSite(siteId, spec or {})
end

function Instance:StartPerimeters()
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  if not self.perimeterRuntime then return nil, false, "PERIMETERS_NOT_CONFIGURED" end
  return self.perimeterRuntime:StartAll()
end

function Instance:StopPerimeters()
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  if not self.perimeterRuntime then return nil, false, "PERIMETERS_NOT_CONFIGURED" end
  return self.perimeterRuntime:StopAll()
end

function Instance:EvaluateResupply()
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  if not self.resupplyMonitor then return nil, false, "RESUPPLY_MONITOR_NOT_CONFIGURED" end
  return self.resupplyMonitor:EvaluateAll(), true, nil
end

function Instance:ReleaseResupplyDemand(demandId, reason)
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  if not self.resupplyMonitor then return nil, false, "RESUPPLY_MONITOR_NOT_CONFIGURED" end
  return self.resupplyMonitor:ReleaseDemand(demandId, reason)
end

function Instance:GetAdapter(supportType)
  if not self.prepared then return nil end
  return self.adapters[supportType]
end

return Runtime
