-- Operation Mountain Watch - generic Fire Support / Strategic Resupply runtime.
--
-- Composition root for the generic Base. This module owns wiring only. It does not
-- select operational assets, invent tactical geometry, scan threats, own strategic
-- resources, or implement a second retry/queue authority.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-6"
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
    "guardMissionFactory", "qrfMissionFactory", "guardMaterializationAdapter", "guardRouteAdapter",
    "installationIncidentBridge", "installationIncidentRuntime", "installationAttackIncident"
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
  if spec.qrfRequiredAttributes ~= nil and type(spec.qrfRequiredAttributes) ~= "string" and type(spec.qrfRequiredAttributes) ~= "table" then fail("qrfRequiredAttributes must be a string or table when provided") end
  if spec.qrfRequiredProperties ~= nil and type(spec.qrfRequiredProperties) ~= "string" and type(spec.qrfRequiredProperties) ~= "table" then fail("qrfRequiredProperties must be a string or table when provided") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  if spec.externalAdapters ~= nil and type(spec.externalAdapters) ~= "table" then fail("externalAdapters must be a table when provided") end
  if spec.incidentIdFactory ~= nil and type(spec.incidentIdFactory) ~= "function" then fail("incidentIdFactory must be a function when provided") end

  if spec.externalSupport ~= nil then
    local externalSupport=needTable(spec.externalSupport,"externalSupport")
    for _,name in ipairs({"externalSupportRuntime","commanderBridge","artyMissionFactory","casMissionFactory"}) do
      needTable(modules[name],"modules." .. name)
      needFunction(modules[name],"New","modules." .. name)
    end
    needTable(externalSupport.commander,"externalSupport.commander")
    needFunction(externalSupport.commander,"AddMission","externalSupport.commander")
    if type(externalSupport.resolveArtyTarget)~="function" then fail("externalSupport.resolveArtyTarget must be a function") end
    if type(externalSupport.resolveCasGeometry)~="function" then fail("externalSupport.resolveCasGeometry must be a function") end
  end

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

    if resupply.transport ~= nil then
      local transport=needTable(resupply.transport,"resupply.transport")
      for _,name in ipairs({"resupplyTransportRuntime","storageTransportFactory","transportSettlement","commanderBridge"}) do
        needTable(modules[name],"modules." .. name)
        needFunction(modules[name],"New","modules." .. name)
      end
      needTable(transport.campaignState,"resupply.transport.campaignState")
      local groundConfigured=transport.groundCommander~=nil or transport.resolveGroundTransport~=nil
      local airConfigured=transport.airCommander~=nil or transport.resolveAirTransport~=nil
      if not groundConfigured and not airConfigured then fail("resupply.transport requires ground or air transport configuration") end
      if groundConfigured then
        needTable(transport.groundCommander,"resupply.transport.groundCommander")
        needFunction(transport.groundCommander,"AddOpsTransport","resupply.transport.groundCommander")
        if type(transport.resolveGroundTransport)~="function" then fail("resupply.transport.resolveGroundTransport must be a function") end
      end
      if airConfigured then
        needTable(transport.airCommander,"resupply.transport.airCommander")
        needFunction(transport.airCommander,"AddOpsTransport","resupply.transport.airCommander")
        if type(transport.resolveAirTransport)~="function" then fail("resupply.transport.resolveAirTransport must be a function") end
      end
      for _,name in ipairs({"resolveTransfer","transactionIdFactory","onTerminal","onPartial"}) do
        if transport[name]~=nil and type(transport[name])~="function" then fail("resupply.transport."..name.." must be a function when provided") end
      end
    end
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
    qrfRequiredAttributes = spec.qrfRequiredAttributes,
    qrfRequiredProperties = spec.qrfRequiredProperties,
    externalAdapters = spec.externalAdapters or {},
    externalSupport = spec.externalSupport,
    perimeters = spec.perimeters,
    blueCoalition = spec.blueCoalition,
    redCoalition = spec.redCoalition,
    incidentIdFactory = spec.incidentIdFactory,
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
    requiredAttributes = self.qrfRequiredAttributes,
    requiredProperties = self.qrfRequiredProperties,
    logger = self.logger,
  })

  local adapters = {}
  for supportType, adapter in pairs(self.externalAdapters) do adapters[supportType] = adapter end
  if adapters.GUARD ~= nil or adapters.QRF ~= nil then fail("externalAdapters must not override GUARD or QRF") end
  adapters.GUARD = guard
  adapters.QRF = qrf

  local externalSupportRuntime
  if self.externalSupport ~= nil then
    if adapters.ARTY ~= nil or adapters.CAS ~= nil then fail("externalAdapters must not override configured externalSupport ARTY/CAS") end
    externalSupportRuntime=m.externalSupportRuntime.New({
      commander=self.externalSupport.commander,
      commanderBridge=m.commanderBridge,
      artyMissionFactory=m.artyMissionFactory,
      casMissionFactory=m.casMissionFactory,
      resolveArtyTarget=self.externalSupport.resolveArtyTarget,
      resolveCasGeometry=self.externalSupport.resolveCasGeometry,
      artyRequiredAssetsMin=self.externalSupport.artyRequiredAssetsMin,
      artyRequiredAssetsMax=self.externalSupport.artyRequiredAssetsMax,
      casRequiredAssetsMin=self.externalSupport.casRequiredAssetsMin,
      casRequiredAssetsMax=self.externalSupport.casRequiredAssetsMax,
      logger=self.logger,
    })
    local external=externalSupportRuntime:GetAdapters()
    adapters.ARTY=external.ARTY
    adapters.CAS=external.CAS
  end

  local resupplyMonitor
  local transportSettlement
  local resupplyTransportRuntime
  if self.resupply~=nil and self.resupply.transport~=nil then
    local transport=self.resupply.transport
    if adapters.GROUND_RESUPPLY~=nil or adapters.AIR_RESUPPLY~=nil then
      fail("externalAdapters must not override configured resupply transport adapters")
    end
    transportSettlement=m.transportSettlement.New({
      campaignState=transport.campaignState,
      store=self.resupply.store,
      resolveTransfer=transport.resolveTransfer,
      transactionIdFactory=transport.transactionIdFactory,
      onTerminal=function(demand,outcome,transaction,detail,binding)
        if resupplyMonitor~=nil then resupplyMonitor:ReleaseDemand(demand.demandId,outcome) end
        if transport.onTerminal~=nil then transport.onTerminal(demand,outcome,transaction,detail,binding) end
      end,
      onPartial=transport.onPartial,
      logger=self.logger,
    })
    resupplyTransportRuntime=m.resupplyTransportRuntime.New({
      commanderBridge=m.commanderBridge,
      storageTransportFactory=m.storageTransportFactory,
      settlement=transportSettlement,
      groundCommander=transport.groundCommander,
      resolveGroundTransport=transport.resolveGroundTransport,
      airCommander=transport.airCommander,
      resolveAirTransport=transport.resolveAirTransport,
      logger=self.logger,
    })
    local transportAdapters=resupplyTransportRuntime:GetAdapters()
    for supportType,adapter in pairs(transportAdapters) do adapters[supportType]=adapter end
  end

  local lifecycle = m.lifecycleAdapter.New({ logger=self.logger })
  local base = m.base.New({
    siteRegistry = self.siteRegistry,
    supportProfiles = self.supportProfiles,
    idContract = self.idContract,
    lifecycleAdapter = lifecycle,
    adapters = adapters,
    logger = self.logger,
  })

  local installationIncidentBridge = m.installationIncidentBridge.New({
    base=base,
    siteRegistry=self.siteRegistry,
    logger=self.logger,
  })
  local installationIncidentRuntime = m.installationIncidentRuntime.New({
    siteRegistry=self.siteRegistry,
    incidentCoordinator=m.installationAttackIncident,
    bridge=installationIncidentBridge,
    incidentIdFactory=self.incidentIdFactory,
    logger=self.logger,
  })
  local _, incidentPrepared, incidentReason = installationIncidentRuntime:Prepare()
  if incidentPrepared == false and incidentReason ~= "ALREADY_PREPARED" then
    return nil, false, "INSTALLATION_INCIDENT_PREPARE_FAILED:" .. tostring(incidentReason)
  end

  local perimeterBridge, perimeterRuntime
  if self.perimeters ~= nil then
    perimeterBridge = m.perimeterBridge.New({
      incidentRuntime = installationIncidentRuntime,
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
  self.externalSupportRuntime=externalSupportRuntime
  self.lifecycle = lifecycle
  self.base = base
  self.installationIncidentBridge = installationIncidentBridge
  self.installationIncidentRuntime = installationIncidentRuntime
  self.perimeterBridge = perimeterBridge
  self.perimeterRuntime = perimeterRuntime
  self.resupplyMonitor = resupplyMonitor
  self.transportSettlement = transportSettlement
  self.resupplyTransportRuntime = resupplyTransportRuntime
  self.adapters = adapters
  self.prepared = true
  self:_log(string.format("prepared generic runtime; installationIncidents=true externalSupport=%s perimeters=%s resupplyMonitor=%s resupplyTransport=%s",
    tostring(externalSupportRuntime~=nil),tostring(perimeterRuntime ~= nil), tostring(resupplyMonitor ~= nil), tostring(resupplyTransportRuntime~=nil)))
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

function Instance:ReportInstallationEvidence(evidence)
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  return self.installationIncidentRuntime:ReportEvidence(evidence)
end

function Instance:CloseInstallationIncident(installationId, reason)
  if not self.prepared then return nil, false, "RUNTIME_NOT_PREPARED" end
  return self.installationIncidentRuntime:CloseInstallationIncident(installationId, reason)
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
