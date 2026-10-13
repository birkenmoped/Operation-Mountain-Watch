-- Operation Mountain Watch - Fire Support / Strategic Resupply production mission bootstrap.
--
-- Mission integration only. The accepted Production Base bundle owns Guard/QRF,
-- external ARTY/CAS, incident/perimeter and optional Strategic Resupply runtime.
-- This module resolves the already-running OMW Ground/AirOps foundations and
-- starts one shared FSSR composition. It does not contain Acceptance fixtures,
-- artificial resource shortages, a second operational queue or asset preselection.

local Bootstrap = {}

Bootstrap.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-4"

local TAG = "[OMW][FireSupStratResupply.Production]"
local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"
local CAS_RADIUS_NM = 5
local CAS_RANGE_NM = 5
local CAS_SPEED_KTS = 125
local CAS_ALTITUDE_FT_AGL = 2500

local SITE_IDS = {
  "JALALABAD_FENTY",
  "COP_FORTRESS",
  "FOB_JOYCE",
  "FOB_WRIGHT",
  "COP_HONAKER",
  "FOB_BOSTICK",
}

local FIXED_ASSETS = {
  {
    id = "BOSTICK",
    siteId = "FOB_BOSTICK",
    templateName = "TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",
    platoonName = "BostickArtillery",
    weaponTypeName = "L118_Unit",
    performance = 50,
  },
  {
    id = "WRIGHT",
    siteId = "FOB_WRIGHT",
    templateName = "TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",
    platoonName = "WrightArtillery",
    weaponTypeName = "L118_Unit",
    performance = 50,
  },
  {
    id = "FORTRESS",
    siteId = "COP_FORTRESS",
    templateName = "TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1",
    platoonName = "FortressArtillery",
    weaponTypeName = "L118_Unit",
    performance = 50,
  },
  {
    id = "HONAKER",
    siteId = "COP_HONAKER",
    templateName = "TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2",
    platoonName = "HonakerMortar",
    weaponTypeName = "2B11 mortar",
    performance = 50,
  },
}

local state = {
  status = "LOADED",
  runtime = nil,
  base = nil,
  commander = nil,
  brigades = {},
  perimeters = {},
  artyRegistry = nil,
  artyOwners = {},
  airwingCount = 0,
  resupplyConfigured = false,
  commanderStarted = false,
  perimetersStarted = false,
  error = nil,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do result[key] = item end
  return result
end

local function userFlagValue(name)
  if type(USERFLAG) ~= "table" or type(USERFLAG.New) ~= "function" then
    fail("MOOSE USERFLAG class is required for " .. tostring(name))
  end
  local flag = USERFLAG:New(name)
  return flag:Get()
end

local function requireUserFlag(name, expected)
  local actual = userFlagValue(name)
  if actual ~= expected then
    fail("user flag not ready name=" .. tostring(name)
      .. " expected=" .. tostring(expected)
      .. " actual=" .. tostring(actual))
  end
  return actual
end

local function setReadyFlag(name, value)
  if type(USERFLAG) ~= "table" or type(USERFLAG.New) ~= "function" then
    fail("MOOSE USERFLAG class is required for " .. tostring(name))
  end
  local flag = USERFLAG:New(name)
  flag:Set(value)
  if flag:Get() ~= value then
    fail("user flag readback failed name=" .. tostring(name) .. " expected=" .. tostring(value))
  end
end

local function setReadyState(coreReady, resupplyReady)
  OMW_FSSR_READY = coreReady and 1 or 0
  OMW_FSSR_RESUPPLY_READY = resupplyReady and 1 or 0
  setReadyFlag("OMW_FSSR_READY", OMW_FSSR_READY)
  setReadyFlag("OMW_FSSR_RESUPPLY_READY", OMW_FSSR_RESUPPLY_READY)
end

local function requireMOOSE()
  for _, item in ipairs({
    {"BRIGADE", BRIGADE},
    {"PLATOON", PLATOON},
    {"COMMANDER", COMMANDER},
    {"AUFTRAG", AUFTRAG},
    {"GROUP", GROUP},
    {"ZONE", ZONE},
    {"ZONE_RADIUS", ZONE_RADIUS},
    {"PATHLINE", PATHLINE},
    {"ARTY", ARTY},
    {"UTILS", UTILS},
  }) do
    if type(item[2]) ~= "table" then
      fail("required MOOSE class unavailable: " .. item[1])
    end
  end
end

local function package()
  if OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED ~= 1 then
    fail("Production Base load flag is not set")
  end
  local value = OMW and OMW.FireSupStratResupply or nil
  if type(value) ~= "table" or type(value.New) ~= "function" or type(value.Modules) ~= "table" then
    fail("OMW.FireSupStratResupply package is unavailable")
  end
  return value
end

local function groundContext()
  requireUserFlag("OMW_GROUND_READY", 1)
  if type(OMW) ~= "table" or type(OMW.Ground) ~= "table" or type(OMW.Ground.Base) ~= "table" then
    fail("OMW.Ground.Base is unavailable")
  end
  if type(OMW.Ground.Base.GetContext) ~= "function" or type(OMW.Ground.Base.GetInitialStock) ~= "function" then
    fail("Ground Base context/initial-stock API is unavailable")
  end
  local context = OMW.Ground.Base.GetContext()
  if type(context) ~= "table" or type(context.store) ~= "table" or type(context.campaignState) ~= "table" then
    fail("Ground Base authoritative CampaignState context is unavailable")
  end
  local airContext = OMW.AirOps and OMW.AirOps.CampaignContext or nil
  if type(airContext) ~= "table" or airContext.store ~= context.store or airContext.campaignState ~= context.campaignState then
    fail("Ground Base and AirOps must share the same authoritative CampaignState context")
  end
  return context
end

local function discoverAirwings(commander)
  if type(OMW) ~= "table" or type(OMW.AirOps) ~= "table" then
    return 0
  end

  local count = 0
  local seen = {}
  local function add(airwing, owner)
    if type(airwing) ~= "table" or seen[airwing] then return end
    seen[airwing] = true
    commander:AddAirwing(airwing)
    count = count + 1
    log("AIRWING_REGISTERED owner=" .. tostring(owner) .. " alias=" .. tostring(airwing.alias or airwing.name or airwing))
  end

  for name, node in pairs(OMW.AirOps) do
    if type(node) == "table" and node.Status == "RUNNING" then
      add(node.Airwing, name)
      for _, airwing in pairs(node.Airwings or {}) do
        add(airwing, name)
      end
    end
  end

  return count
end

local function ensureTemplate(name, requireLateActivation)
  local group = GROUP:FindByName(name)
  if not group then fail("Mission Editor template missing: " .. tostring(name)) end
  if requireLateActivation == true and group:IsAlive() == true then
    fail("template must be Late Activation: " .. tostring(name))
  end
  return group
end

local function createSiteBrigades(p)
  ensureTemplate(QRF_TEMPLATE, true)

  local brigades = {}
  for _, siteId in ipairs(SITE_IDS) do
    local site = p.SiteRegistry.Sites[siteId]
    if type(site) ~= "table" then fail("SiteRegistry entry missing: " .. siteId) end
    ensureTemplate(site.guardTemplateName, true)

    local brigade = BRIGADE:New(site.warehouseName, "BDE_FSSR_" .. siteId)
    if not brigade then fail("BRIGADE creation failed siteId=" .. siteId) end

    local guard = PLATOON:New(site.guardTemplateName, 1, "PLT_FSSR_GUARD_" .. siteId)
    local qrf = PLATOON:New(QRF_TEMPLATE, 1, "PLT_FSSR_QRF_" .. siteId)
    guard:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
    qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
    brigade:AddPlatoon(guard)
    brigade:AddPlatoon(qrf)

    brigades[siteId] = brigade
  end
  return brigades
end

local function buildPerimeters(p, brigades)
  local result = {}
  for _, siteId in ipairs(SITE_IDS) do
    local site = p.SiteRegistry.Sites[siteId]
    local alarm = site and site.alarm or nil
    if type(alarm) ~= "table" or type(alarm.radiusM) ~= "number" or alarm.radiusM <= 0 then
      fail("invalid alarm configuration siteId=" .. siteId)
    end

    local anchor = nil
    if alarm.anchorKind == "WAREHOUSE" then
      anchor = brigades[siteId] and brigades[siteId]:GetCoordinate() or nil
    elseif alarm.anchorKind == "MOOSE_ZONE" then
      local zone = ZONE:FindByName(alarm.anchorName)
      anchor = zone and zone:GetCoordinate() or nil
    else
      fail("unsupported alarm anchor kind siteId=" .. siteId .. " kind=" .. tostring(alarm.anchorKind))
    end

    if not anchor then fail("alarm anchor unavailable siteId=" .. siteId) end
    result[siteId] = {
      anchorCoordinate = anchor,
      zoneName = "OMW_SECURITY_" .. site.installationId,
      radiusM = alarm.radiusM,
      priority = 0,
    }
    log(string.format("PERIMETER_CONFIG siteId=%s radiusM=%.1f", siteId, alarm.radiusM))
  end
  return result
end

local function resolveFunctionalOwner(definition, asset, legion, group)
  local existing = state.artyOwners[definition.id]
  if existing then return existing, nil end

  local arty = ARTY:New(group, definition.id .. " FSSR")
  if not arty then return nil, "ARTY_CREATE_FAILED assetId=" .. tostring(definition.id) end
  arty:SetReportOFF()
  arty:SetWaitForShotTime(120)
  arty:Start()

  local owner = {
    arty = arty,
    priority = 10,
    maxEngagements = 1,
    acceptedRadiusM = 50,
    acceptedShots = 4,
    weaponType = ARTY.WeaponType.Auto,
  }
  state.artyOwners[definition.id] = owner
  log("FUNCTIONAL_ARTY_OWNER_CREATED assetId=" .. definition.id .. " group=" .. tostring(group:GetName()))
  return owner, nil
end

local function resolvePhysicalTarget(context, label)
  local incident = context and context.incident or nil
  local physical = incident and incident.context and incident.context.physicalTargetGroup or nil
  if not physical or physical:IsAlive() ~= true then
    return nil, label .. "_PHYSICAL_TARGET_UNAVAILABLE"
  end
  local coordinate = physical:GetCoordinate()
  if not coordinate then return nil, label .. "_TARGET_COORDINATE_UNAVAILABLE" end
  return coordinate, nil
end

local function resolveArtyTarget(_, context)
  local coordinate, reason = resolvePhysicalTarget(context, "ARTY")
  if not coordinate then return nil, reason end
  return { coordinate = coordinate, shots = 4, radiusM = 50 }, nil
end

local function resolveCasGeometry(demand, context)
  local coordinate, reason = resolvePhysicalTarget(context, "CAS")
  if not coordinate then return nil, reason end

  local zone = ZONE_RADIUS:New(
    "OMW_FSSR_CAS_" .. tostring(demand.demandId),
    coordinate:GetVec2(),
    UTILS.NMToMeters(CAS_RADIUS_NM)
  )
  local altitudeFt = UTILS.MetersToFeet(zone:GetCoordinate():GetLandHeight()) + CAS_ALTITUDE_FT_AGL

  return {
    missionMode = "PATROLZONE_ENGAGE",
    zone = zone,
    altitudeFt = altitudeFt,
    speedKts = CAS_SPEED_KTS,
    engageDetectedRangeNm = CAS_RANGE_NM,
    engageDetectedTargetTypes = { "Ground Units" },
    targetTypes = { "Ground Units" },
    requiredAttributes = GROUP.Attribute.AIR_ATTACKHELO,
    configureMission = function(mission)
      mission:SetName("OMW_FSSR_CAS_" .. tostring(demand.siteId))
    end,
  }, nil
end

local function onCasEvidence(fields)
  log(
    "CAS_EVIDENCE event=" .. tostring(fields and fields.event)
      .. " demandId=" .. tostring(fields and fields.demandId)
      .. " provider=" .. tostring(fields and fields.provider)
      .. " asset=" .. tostring(fields and fields.asset)
      .. " reason=" .. tostring(fields and fields.reason)
  )
end

local function requestExternalSupport(base, incident, escalationContext)
  if type(base) ~= "table" or type(base.RequestIncidentSupport) ~= "function" then
    return nil, "BASE_SUPPORT_REQUEST_UNAVAILABLE"
  end
  if type(incident) ~= "table" or type(incident.incidentId) ~= "string" then
    return nil, "INCIDENT_UNAVAILABLE"
  end

  local priority = escalationContext and escalationContext.priority or incident.priority or 20
  local results = {}

  local function request(supportType, requestKey)
    local demand, created, reason = base:RequestIncidentSupport(
      incident.incidentId,
      supportType,
      {
        requestKey = requestKey,
        priority = priority,
        cancelWhenIncidentClosed = false,
        context = {
          activation = "C2_ESCALATION_EXTERNAL",
          source = "INSTALLATION_ATTACK_INCIDENT",
          sourceIncidentId = escalationContext
            and escalationContext.sourceIncident
            and escalationContext.sourceIncident.incidentId
            or nil,
        },
      }
    )
    results[supportType] = {
      demand = demand,
      created = created,
      reason = reason,
    }
    log(
      "C2_EXTERNAL_SUPPORT_REQUEST"
        .. " siteId=" .. tostring(incident.siteId)
        .. " supportType=" .. tostring(supportType)
        .. " demandId=" .. tostring(demand and demand.demandId)
        .. " created=" .. tostring(created)
        .. " status=" .. tostring(demand and demand.status)
        .. " reason=" .. tostring(reason)
    )
    return demand, created, reason
  end

  -- Preserve the documented full-response authority split:
  -- the supported installation creates the external support requirement,
  -- while MOOSE COMMANDER/LEGION owns operational provider and asset selection.
  -- CAS is not a fallback after QRF/ARTY failure; it is an independent support
  -- requirement. ARTY is requested in the same incident response and remains
  -- deconflicted by its own fire-control/provider lifecycle.
  request("CAS", "INSTALLATION_ATTACK_C2_CAS")
  request("ARTY", "INSTALLATION_ATTACK_C2_ARTY_INITIAL")

  return results, nil
end

local function buildResupplySpec(config, context, commander)
  if config.resupply == nil or config.resupply == false then
    return nil, false
  end
  if type(config.resupply) ~= "table" then
    fail("config.resupply must be a table, false or nil")
  end

  local resupply = copy(config.resupply)
  resupply.policy = resupply.policy or ResourceDemandPolicy
  resupply.store = context.store
  if resupply.rows == nil then
    resupply.rows = OMW.Ground.Base.GetInitialStock().Rows
  end
  if type(resupply.selectSupportType) ~= "function" then
    fail("config.resupply.selectSupportType must be a function for production resupply")
  end
  if type(resupply.transport) ~= "table" then
    fail("config.resupply.transport is required for production physical Strategic Resupply")
  end

  resupply.transport = copy(resupply.transport)
  resupply.transport.campaignState = context.campaignState

  local groundConfigured = type(resupply.transport.resolveGroundTransport) == "function"
  local airConfigured = type(resupply.transport.resolveAirTransport) == "function"
  if not groundConfigured and not airConfigured then
    fail("production resupply requires resolveGroundTransport or resolveAirTransport")
  end

  if groundConfigured and resupply.transport.groundCommander == nil then
    resupply.transport.groundCommander = commander
  end
  if airConfigured and resupply.transport.airCommander == nil then
    resupply.transport.airCommander = commander
  end

  return resupply, true
end

local function casLifecycleSpec(config)
  if config.casLifecycle ~= nil then
    if type(config.casLifecycle) ~= "table" then fail("config.casLifecycle must be a table") end
    return config.casLifecycle
  end

  return {
    executionProfiles = {
      AW_US_JBAD_TF_SHOOTER_6_6_CAV = {
        pathlineBase = "OMW_FlightPath",
        pathlineNames = { "OMW_FlightPath", "OMW_FlightPath_WEST" },
        segmentProfiles = {
          { altitudeFtAgl = 500 },
          { altitudeFtAgl = 2500, formation = ENUMS.Formation.RotaryWing.Column.D70 },
        },
        maxJunctionDistanceM = 1000,
        routeGateDistanceNm = 3.5,
        transitAltitudeFtAgl = 2500,
        missionAltitudeFtAgl = 2500,
        speedKts = CAS_SPEED_KTS,
      },
    },
    pathlineRegistry = _DATABASE.PATHLINES,
    releasePolicy = {
      mode = "SUPPORTED_ELEMENT_STABLE_NO_CONTACT",
      stableNoContactSec = 30,
    },
    updateSeconds = 5,
    redCoalition = coalition.side.RED,
    onEvidence = onCasEvidence,
  }
end

local function startInternal(config)
  requireMOOSE()
  requireUserFlag("OMW_WAREHOUSE_READY", 1)

  local p = package()
  local context = groundContext()

  if type(_DATABASE) ~= "table" or type(_DATABASE.PATHLINES) ~= "table" then
    fail("MOOSE PATHLINE registry is unavailable")
  end

  local commander = COMMANDER:New(coalition.side.BLUE, "OMW_FSSR_C2")
  if not commander then fail("COMMANDER creation failed") end
  if type(commander.SetVerbosity) == "function" then commander:SetVerbosity(2) end

  local brigades = createSiteBrigades(p)
  local airwingCount = discoverAirwings(commander)
  if airwingCount < 1 then fail("no running AIRWING available for FSSR") end

  for _, definition in ipairs(FIXED_ASSETS) do
    ensureTemplate(definition.templateName, true)
  end

  local registry = p.Modules.artyRealAssetRegistry.New({
    commander = commander,
    brigades = brigades,
    assets = FIXED_ASSETS,
    platoonFactory = function(templateName, count, platoonName)
      return PLATOON:New(templateName, count, platoonName)
    end,
    resolveTemplateGroup = function(name)
      return GROUP:FindByName(name)
    end,
    resolveFunctionalArty = resolveFunctionalOwner,
    logger = log,
  })

  local perimeters = buildPerimeters(p, brigades)
  local resupply, resupplyConfigured = buildResupplySpec(config, context, commander)

  local runtime
  runtime = p.New({
    siteRegistry = p.SiteRegistry,
    brigades = brigades,
    resolveGuardPathline = function(name)
      return PATHLINE:FindByName(name)
    end,
    resolveGuardTemplateGroup = function(name)
      return GROUP:FindByName(name)
    end,
    guardRequiredAttributes = GROUP.Attribute.GROUND_INFANTRY,
    resolveQrfCoordinate = function(_, runtimeContext)
      local incident = runtimeContext and runtimeContext.incident or nil
      local physical = incident and incident.context and incident.context.physicalTargetGroup or nil
      if not physical then return nil, "QRF_PHYSICAL_TARGET_UNAVAILABLE" end
      return physical, nil
    end,
    qrfRequiredAttributes = GROUP.Attribute.GROUND_APC,
    blueCoalition = coalition.side.BLUE,
    redCoalition = coalition.side.RED,
    perimeters = perimeters,
    onExternalSupportRequired = function(incident, escalationContext)
      return requestExternalSupport(runtime and runtime:GetBase() or nil, incident, escalationContext)
    end,
    externalSupport = {
      commander = commander,
      resolveArtyTarget = resolveArtyTarget,
      resolveCasGeometry = resolveCasGeometry,
      artyRequiredAssetsMin = 1,
      artyRequiredAssetsMax = 1,
      artyFunctionalSelection = {
        resolveFunctionalArty = registry:GetResolver(),
      },
      casRequiredAssetsMin = 1,
      casRequiredAssetsMax = 1,
      casLifecycle = casLifecycleSpec(config),
    },
    resupply = resupply,
    logger = log,
  })

  local preparedRuntime, prepared, prepareReason = runtime:Prepare()
  if prepared ~= true and prepareReason ~= "ALREADY_PREPARED" then
    fail("runtime Prepare failed reason=" .. tostring(prepareReason))
  end
  runtime = preparedRuntime or runtime

  state.runtime = runtime
  state.base = runtime:GetBase()
  state.commander = commander
  state.brigades = brigades
  state.perimeters = perimeters
  state.artyRegistry = registry
  state.airwingCount = airwingCount
  state.resupplyConfigured = resupplyConfigured
  state.commanderStarted = false
  state.perimetersStarted = false

  for _, siteId in ipairs(SITE_IDS) do
    local _, started, reason = runtime:StartSite(siteId, {})
    if started ~= true and reason ~= "ALREADY_STARTED" then
      fail("site start failed siteId=" .. siteId .. " reason=" .. tostring(reason))
    end
  end

  local function allFixedFireAssetsMaterialized()
    for _, definition in ipairs(FIXED_ASSETS) do
      if registry:IsMaterialized(definition.id) ~= true then return false end
    end
    return true
  end

  local activationInProgress = false
  local function activatePerimetersWhenReady()
    if state.perimetersStarted then return true end
    if activationInProgress then return false end
    if state.commanderStarted ~= true or not allFixedFireAssetsMaterialized() then return false end

    activationInProgress = true
    local _, perimetersStarted, perimeterReason = runtime:StartPerimeters()
    if perimetersStarted ~= true then
      activationInProgress = false
      fail("perimeter start failed reason=" .. tostring(perimeterReason))
    end

    state.perimetersStarted = true
    state.status = "RUNNING"
    setReadyState(true, resupplyConfigured)

    log(
      "RESULT status=RUNNING sites=" .. tostring(#SITE_IDS)
        .. " airwings=" .. tostring(airwingCount)
        .. " fixedFireAssets=" .. tostring(#FIXED_ASSETS)
        .. " fixedFireMaterialized=true"
        .. " strategicResupplyConfigured=" .. tostring(resupplyConfigured)
        .. " acceptanceFixtures=false artificialShortage=false"
    )
    if not resupplyConfigured then
      log("STRATEGIC_RESUPPLY_NOT_CONFIGURED reason=PRODUCTION_PHYSICAL_TRANSPORT_DESCRIPTOR_REQUIRED")
    end

    activationInProgress = false
    return true
  end

  for siteId, brigade in pairs(brigades) do
    local previous = brigade.OnAfterAssetSpawned
    function brigade:OnAfterAssetSpawned(From, Event, To, group, asset, request)
      if previous then previous(self, From, Event, To, group, asset, request) end
      log(
        "FIXED_FIRE_READINESS_EVENT siteId=" .. tostring(siteId)
          .. " asset=" .. tostring(asset and asset.spawngroupname)
      )
      activatePerimetersWhenReady()
    end
  end

  for _, brigade in pairs(brigades) do
    brigade:Start()
  end
  commander:Start()
  state.commanderStarted = true

  if not activatePerimetersWhenReady() then
    log("WAITING_FOR_FIXED_FIRE_ASSETS required=" .. tostring(#FIXED_ASSETS))
  end

  return state
end

function Bootstrap.Start(config)
  if state.status == "RUNNING" then return state, false, "ALREADY_STARTED" end
  if state.status == "STARTING" then return nil, false, "START_IN_PROGRESS" end

  config = config or {}
  if type(config) ~= "table" then fail("config must be a table") end

  state.status = "STARTING"
  state.error = nil
  setReadyState(false, false)

  local ok, result = pcall(startInternal, config)
  if not ok then
    state.status = "ERROR"
    state.error = tostring(result)
    setReadyState(false, false)
    env.error(TAG .. " ERROR " .. state.error, false)
    return nil, false, state.error
  end

  return result, true, nil
end

function Bootstrap.GetState()
  return state
end

function Bootstrap.GetRuntime()
  return state.runtime
end

function Bootstrap.GetBase()
  return state.base
end

function Bootstrap.GetCommander()
  return state.commander
end

function Bootstrap.GetBrigade(siteId)
  return state.brigades[siteId]
end

function Bootstrap.GetArtyRegistry()
  return state.artyRegistry
end

return Bootstrap
