-- Operation Mountain Watch - Gate 5B six-site perimeter runtime acceptance.
--
-- Scope: persistent Guard readiness -> runtime ZONE_RADIUS/OPSZONE perimeter ->
-- physical RED intrusion -> PROXIMITY_INTRUSION evidence -> authoritative
-- installation incident -> exactly one initial QRF demand.
--
-- The harness does not inject evidence, close incidents, release/cancel QRFs,
-- validate QRF movement, or introduce Mission Editor alarm zones.

local TAG = "[OMW][FSSR-GATE5B-PERIMETER-A1]"
local GUARD_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local FIXTURE_ROUTE_SPEED_KMH = 20
local INTRUSION_DEPTH_FRACTION = 0.65
local TELEMETRY_SEC = 20
local TEST_TIMEOUT_SEC = 900
local PERIMETER_SETTLE_SEC = 5
local RADIUS_TOLERANCE_M = 0.5
local ALARM_PRIORITY = 0

local sites = {
  { id = "JALALABAD_FENTY", fixture = "BadGuys_A3_FENTY" },
  { id = "COP_FORTRESS", fixture = "BadGuys_A3_FORTRESS" },
  { id = "FOB_JOYCE", fixture = "BadGuys_A3_JOYCE" },
  { id = "FOB_WRIGHT", fixture = "BadGuys_A3_WRIGHT" },
  { id = "COP_HONAKER", fixture = "BadGuys_A3_HONAKER" },
  { id = "FOB_BOSTICK", fixture = "BadGuys_A3_BOSTICK" },
}

local state = {
  failed = false,
  passed = false,
  runtime = nil,
  brigades = {},
  site = {},
  perimeters = {},
  perimeterStates = nil,
  perimetersStarted = false,
  perimetersStartedAt = nil,
  fixturesReleased = false,
  startedAt = nil,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function announce(kind, message, seconds)
  local text = "[GATE 5B PERIMETER A1][" .. kind .. "] " .. message
  log(text)
  MESSAGE:New(text, seconds or 10):ToAll()
end

local function fail(message)
  if state.failed or state.passed then return end
  state.failed = true
  announce("FAIL", message, 30)
end

local function package()
  return OMW and OMW.FireSupStratResupply or nil
end

local function activeInstallationIncident(siteId)
  local p = package()
  local site = p and p.SiteRegistry and p.SiteRegistry.Sites[siteId] or nil
  local incidentRuntime = state.runtime and state.runtime.installationIncidentRuntime or nil
  if not site or not incidentRuntime then return nil end
  local coordinator = incidentRuntime:GetCoordinator(site.installationId)
  return coordinator and coordinator:GetActive() or nil
end

local function updateSiteState(def)
  local p = package()
  local s = state.site[def.id]
  local perimeterState = state.perimeterStates and state.perimeterStates[def.id] or nil
  local securityZone = perimeterState and perimeterState.securityZone or nil

  if s.guard and s.guard:IsAlive() then
    local guardCoordinate = s.guard:GetCoordinate()
    s.guardInsidePerimeter = securityZone ~= nil and guardCoordinate ~= nil
      and securityZone:IsCoordinateInZone(guardCoordinate) == true
  end

  local fixture = GROUP:FindByName(def.fixture)
  if fixture and fixture:IsAlive() then
    s.fixtureAlive = true
    local fixtureCoordinate = fixture:GetCoordinate()
    s.fixtureInsidePerimeter = securityZone ~= nil and fixtureCoordinate ~= nil
      and securityZone:IsCoordinateInZone(fixtureCoordinate) == true
  end

  local active = activeInstallationIncident(def.id)
  if active then
    s.sourceIncident = true
    s.proximity = false
    for _, evidence in ipairs(active.evidence or {}) do
      if evidence.evidenceType == "PROXIMITY_INTRUSION" then
        s.proximity = true
        break
      end
    end

    local base = state.runtime:GetBase()
    local baseIncidentId = p.IdContract.Incident(def.id, active.incidentId)
    local incident = base and base:GetIncident(baseIncidentId) or nil
    if incident then
      s.baseIncident = true
      s.demandCount = #incident.demandIds
      if s.demandCount == 1 then
        local demand = base:GetDemand(incident.demandIds[1])
        s.qrfDemand = demand ~= nil
          and demand.supportType == "QRF"
          and demand.requestKey == "INSTALLATION_ATTACK_INITIAL_QRF"
          and demand.validity ~= nil
          and demand.validity.cancelWhenIncidentClosed == false
      end
    end
  end
end

local function allGuardsObserved()
  for _, def in ipairs(sites) do
    local s = state.site[def.id]
    if not s.guardObserved or not s.guard or s.guard:IsAlive() ~= true then return false end
  end
  return true
end

local function buildBrigades(p)
  for _, def in ipairs(sites) do
    local site = p.SiteRegistry.Sites[def.id]
    state.site[def.id] = {
      guardObserved = false,
      guardInsidePerimeter = false,
      fixtureAlive = false,
      fixtureInsidePerimeter = false,
      sourceIncident = false,
      proximity = false,
      baseIncident = false,
      demandCount = 0,
      qrfDemand = false,
    }

    local brigade = BRIGADE:New(site.warehouseName, "BDE_FSSR_GATE5B_" .. def.id)
    local guard = PLATOON:New(site.guardTemplateName, 1, "PLT_FSSR_GATE5B_GUARD_" .. def.id)
    guard:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
    brigade:AddPlatoon(guard)

    local s = state.site[def.id]
    local previous = brigade.OnAfterArmyOnMission
    brigade.OnAfterArmyOnMission = function(self, From, Event, To, armyGroup, mission)
      if previous then previous(self, From, Event, To, armyGroup, mission) end
      local group = armyGroup and armyGroup:GetGroup() or nil
      if not group then return end
      if group:GetAttribute() == GROUP.Attribute.GROUND_INFANTRY then
        s.guard = group
        s.guardObserved = true
        log(string.format("GUARD_ON_MISSION siteId=%s group=%s missionType=%s",
          def.id, tostring(group:GetName()), tostring(mission and mission:GetType())))
      end
    end

    state.brigades[def.id] = brigade
  end
end

local function buildPerimeters(p)
  if type(ZONE) ~= "table" or type(ZONE.FindByName) ~= "function" then
    return nil, "MOOSE_ZONE_FIND_UNAVAILABLE"
  end

  for _, def in ipairs(sites) do
    local site = p.SiteRegistry.Sites[def.id]
    local alarm = site and site.alarm or nil
    if type(alarm) ~= "table" or type(alarm.radiusM) ~= "number" or alarm.radiusM <= 0 then
      return nil, "ALARM_CONFIG_INVALID:" .. def.id
    end

    local anchor = nil
    local anchorSource = nil
    if alarm.anchorKind == "WAREHOUSE" then
      local brigade = state.brigades[def.id]
      if not brigade or type(brigade.GetCoordinate) ~= "function" then
        return nil, "WAREHOUSE_COORDINATE_UNAVAILABLE:" .. def.id
      end
      anchor = brigade:GetCoordinate()
      anchorSource = "WAREHOUSE_COORDINATE"
    elseif alarm.anchorKind == "MOOSE_ZONE" then
      local sourceZone = ZONE:FindByName(alarm.anchorName)
      if not sourceZone or type(sourceZone.GetCoordinate) ~= "function" then
        return nil, "MOOSE_ZONE_UNAVAILABLE:" .. tostring(alarm.anchorName)
      end
      anchor = sourceZone:GetCoordinate()
      anchorSource = "EXISTING_MOOSE_ZONE_CENTER"
    else
      return nil, "ALARM_ANCHOR_KIND_UNSUPPORTED:" .. def.id .. ":" .. tostring(alarm.anchorKind)
    end

    if not anchor or type(anchor.GetVec2) ~= "function" then
      return nil, "ALARM_ANCHOR_COORDINATE_INVALID:" .. def.id
    end

    state.site[def.id].anchor = anchor
    state.site[def.id].expectedRadiusM = alarm.radiusM
    state.site[def.id].anchorSource = anchorSource
    state.perimeters[def.id] = {
      anchorCoordinate = anchor,
      securityZone = nil,
      zoneName = "OMW_SECURITY_" .. site.installationId,
      radiusM = alarm.radiusM,
      priority = ALARM_PRIORITY,
    }

    log(string.format(
      "PERIMETER_CONFIG siteId=%s anchorKind=%s anchorName=%s radiusM=%.1f anchorSource=%s zoneSource=RUNTIME_ZONE_RADIUS",
      def.id, tostring(alarm.anchorKind), tostring(alarm.anchorName or site.warehouseName),
      alarm.radiusM, anchorSource))
  end

  return state.perimeters, nil
end

local function validateStartedPerimeters()
  for _, def in ipairs(sites) do
    local s = state.site[def.id]
    local perimeterState = state.perimeterStates and state.perimeterStates[def.id] or nil
    local zone = perimeterState and perimeterState.securityZone or nil
    if not perimeterState or not zone then
      return false, def.id .. ":PERIMETER_STATE_MISSING"
    end
    if type(zone.GetRadius) ~= "function" or type(zone.IsCoordinateInZone) ~= "function" then
      return false, def.id .. ":RUNTIME_ZONE_API_MISSING"
    end
    local actualRadius = zone:GetRadius()
    if type(actualRadius) ~= "number" or math.abs(actualRadius - s.expectedRadiusM) > RADIUS_TOLERANCE_M then
      return false, string.format("%s:RADIUS_MISMATCH expected=%.1f actual=%s",
        def.id, s.expectedRadiusM, tostring(actualRadius))
    end
    local guardCoordinate = s.guard and s.guard:GetCoordinate() or nil
    if not guardCoordinate or zone:IsCoordinateInZone(guardCoordinate) ~= true then
      return false, def.id .. ":GUARD_NOT_INSIDE_RUNTIME_PERIMETER"
    end
    s.guardInsidePerimeter = true
    s.perimeterStarted = true
    s.actualRadiusM = actualRadius
  end
  return true, nil
end

local function routeFixtureIntoPerimeter(def)
  local s = state.site[def.id]
  local fixture = GROUP:FindByName(def.fixture)
  if not fixture then return false, "FIXTURE_GROUP_MISSING" end
  if fixture:IsAlive() ~= true then fixture:Activate() end
  if fixture:IsAlive() ~= true then return false, "FIXTURE_NOT_ALIVE_AFTER_ACTIVATE" end

  local from = fixture:GetCoordinate()
  local anchor = s.anchor
  if not from or not anchor then return false, "COORDINATE_UNAVAILABLE" end

  local startDistance = anchor:Get2DDistance(from)
  local target = anchor:GetIntermediateCoordinate(from, s.expectedRadiusM * INTRUSION_DEPTH_FRACTION)
  if not target then return false, "INTRUSION_TARGET_UNAVAILABLE" end

  s.fixture = fixture
  s.fixtureStartDistanceM = startDistance
  s.intrusionTarget = target
  fixture:RouteGroundTo(target, FIXTURE_ROUTE_SPEED_KMH, "Off Road", 1)

  log(string.format(
    "FIXTURE_ROUTE siteId=%s group=%s startDistanceM=%.1f targetDistanceFromAnchorM=%.1f radiusM=%.1f speedKmh=%d",
    def.id, def.fixture, startDistance, s.expectedRadiusM * INTRUSION_DEPTH_FRACTION,
    s.expectedRadiusM, FIXTURE_ROUTE_SPEED_KMH))
  return true, nil
end

local function releaseFixtures()
  if state.fixturesReleased or state.failed then return end
  for _, def in ipairs(sites) do
    local ok, reason = routeFixtureIntoPerimeter(def)
    if not ok then
      fail(def.id .. ":FIXTURE_ROUTE_FAILED:" .. tostring(reason))
      return
    end
  end
  state.fixturesReleased = true
  announce("ARMED", "6/6 runtime perimeters verified with live Guards; physical RED fixtures released toward the approved alarm perimeters", 20)
end

local function telemetry()
  if state.failed or state.passed or not state.runtime then return end

  for _, def in ipairs(sites) do updateSiteState(def) end

  if not state.perimetersStarted and allGuardsObserved() then
    local perimeterStates, started, reason = state.runtime:StartPerimeters()
    if started ~= true or not perimeterStates then
      fail("PERIMETER_START_FAILED:" .. tostring(reason))
      return
    end
    state.perimeterStates = perimeterStates
    local valid, validateReason = validateStartedPerimeters()
    if not valid then
      fail("PERIMETER_RUNTIME_VALIDATION_FAILED:" .. tostring(validateReason))
      return
    end
    state.perimetersStarted = true
    state.perimetersStartedAt = timer.getTime()
    announce("PERIMETERS", "6/6 approved runtime ZONE_RADIUS/OPSZONE perimeters started; waiting for initial MOOSE evaluation before RED release", 15)
  end

  if state.perimetersStarted and not state.fixturesReleased
      and timer.getTime() - state.perimetersStartedAt >= PERIMETER_SETTLE_SEC then
    releaseFixtures()
  end

  for _, def in ipairs(sites) do
    local s = state.site[def.id]
    log(string.format(
      "SITE_TELEMETRY siteId=%s anchorSource=%s radiusM=%s perimeterStarted=%s guardObserved=%s guardInside=%s fixtureAlive=%s fixtureInside=%s proximity=%s sourceIncident=%s baseIncident=%s demandCount=%s qrfDemand=%s",
      def.id, tostring(s.anchorSource), tostring(s.actualRadiusM or s.expectedRadiusM),
      tostring(s.perimeterStarted), tostring(s.guardObserved), tostring(s.guardInsidePerimeter),
      tostring(s.fixtureAlive), tostring(s.fixtureInsidePerimeter), tostring(s.proximity),
      tostring(s.sourceIncident), tostring(s.baseIncident), tostring(s.demandCount), tostring(s.qrfDemand)))
  end
end

local function evaluate()
  if state.failed or state.passed then return end
  telemetry()
  if state.failed or state.passed then return end

  local pending = false
  local errors = {}
  for _, def in ipairs(sites) do
    local s = state.site[def.id]
    if not s.perimeterStarted then pending = true end
    if not s.guardObserved or not s.guardInsidePerimeter then pending = true end
    if not state.fixturesReleased or not s.fixtureInsidePerimeter then pending = true end
    if not s.proximity or not s.sourceIncident or not s.baseIncident then pending = true end
    if s.baseIncident and s.demandCount ~= 1 then
      errors[#errors + 1] = def.id .. ":QRF_DEMAND_COUNT_" .. tostring(s.demandCount)
    end
    if s.baseIncident and s.demandCount == 1 and not s.qrfDemand then
      errors[#errors + 1] = def.id .. ":INITIAL_QRF_DEMAND_CONTRACT"
    end
  end

  if #errors > 0 then
    fail(table.concat(errors, ","))
    return
  end

  if not pending and state.fixturesReleased then
    state.passed = true
    announce("PASS", "6/6 approved runtime ZONE_RADIUS/OPSZONE perimeters observed physical RED intrusion, PROXIMITY_INTRUSION evidence, authoritative installation incidents, and exactly one initial non-auto-cancel QRF demand per site. No acceptance-owned evidence injection, incident close, or QRF release was used.", 40)
    return
  end

  if state.startedAt and timer.getTime() - state.startedAt > TEST_TIMEOUT_SEC then
    fail("TIMEOUT_INCOMPLETE_SIX_SITE_PERIMETER_CHAIN")
  end
end

local function start()
  local p = package()
  if type(p) ~= "table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) then fail("GUARD_TEMPLATE_MISSING"); return end
  for _, def in ipairs(sites) do
    if not GROUP:FindByName(def.fixture) then fail("FIXTURE_GROUP_MISSING:" .. def.fixture); return end
  end

  local jalalabad = p.SiteRegistry.Sites.JALALABAD_FENTY
  if not jalalabad or not jalalabad.alarm
      or jalalabad.alarm.anchorKind ~= "MOOSE_ZONE"
      or jalalabad.alarm.anchorName ~= "OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT"
      or math.abs(jalalabad.alarm.radiusM - 2438.4) > RADIUS_TOLERANCE_M then
    fail("JALALABAD_OWNER_APPROVED_ALARM_CONTRACT_MISMATCH")
    return
  end

  buildBrigades(p)
  local perimeters, perimeterReason = buildPerimeters(p)
  if not perimeters then fail("PERIMETER_CONFIG_FAILED:" .. tostring(perimeterReason)); return end

  local ok, runtimeOrError = pcall(function()
    return p.New({
      brigades = state.brigades,
      resolveGuardPathline = function(name) return PATHLINE:FindByName(name) end,
      resolveGuardTemplateGroup = function(name) return GROUP:FindByName(name) end,
      guardRequiredAttributes = GROUP.Attribute.GROUND_INFANTRY,
      resolveQrfCoordinate = function(_, context)
        local incident = context and context.incident or nil
        local incidentContext = incident and incident.context or nil
        local target = incidentContext and incidentContext.physicalTargetGroup or nil
        if not target then return nil, "QRF_PHYSICAL_TARGET_UNAVAILABLE" end
        return target, nil
      end,
      qrfRequiredAttributes = GROUP.Attribute.GROUND_APC,
      blueCoalition = coalition.side.BLUE,
      redCoalition = coalition.side.RED,
      perimeters = perimeters,
      logger = log,
    }):Prepare()
  end)
  if not ok or not runtimeOrError then
    fail("RUNTIME_PREPARE_FAILED:" .. tostring(runtimeOrError))
    return
  end
  state.runtime = runtimeOrError

  for _, brigade in pairs(state.brigades) do brigade:Start() end
  for _, def in ipairs(sites) do
    local _, created, reason = state.runtime:StartSite(def.id, {})
    if created == false then
      fail(def.id .. ":GUARD_START_FAILED:" .. tostring(reason))
      return
    end
  end

  state.startedAt = timer.getTime()
  announce("READY", "six production Guard organisations starting; Gate 5B will start the approved runtime perimeters only after all six Guards are physically present", 20)
  SCHEDULER:New(nil, evaluate, {}, 2, TELEMETRY_SEC)
end

SCHEDULER:New(nil, start, {}, 5)
