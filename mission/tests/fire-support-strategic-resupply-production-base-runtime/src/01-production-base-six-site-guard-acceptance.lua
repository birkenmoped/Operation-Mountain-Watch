-- Operation Mountain Watch - Production Base Acceptance 1.
--
-- Validates the generated OMW.FireSupStratResupply package in DCS by exercising
-- the already accepted six-site Guard path through the production composition root.
-- No QRF/ARTY/CAS/resupply geometry is invented or exercised in this acceptance.

local ID = "FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1"
local TAG = "[OMW][" .. ID .. "]"
local OBSERVATION_SECONDS = 300
local TELEMETRY_SECONDS = 30
local MIN_MOVEMENT_M = 25

local SITE_KEYS = {
  "JALALABAD_FENTY",
  "COP_FORTRESS",
  "FOB_JOYCE",
  "FOB_WRIGHT",
  "COP_HONAKER",
  "FOB_BOSTICK",
}

local state = {
  failed = false,
  passed = false,
  sites = {},
  brigades = {},
  runtime = nil,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function announce(kind, message, duration)
  local text = "[PRODUCTION BASE][" .. tostring(kind) .. "] " .. tostring(message)
  log(text)
  MESSAGE:New(text, duration or 10):ToAll()
end

local function fail(message)
  if state.failed or state.passed then return end
  state.failed = true
  announce("FAIL", message, 25)
end

local function createBrigade(siteKey, site, templateGroup)
  local brigade = BRIGADE:New(site.warehouseName, "BDE_FSSR_PROD_A1_" .. siteKey)
  local platoon = PLATOON:New(site.guardTemplateName, 1, "PLT_FSSR_PROD_A1_" .. siteKey)
  platoon:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
  brigade:AddPlatoon(platoon)

  local siteState = {
    site = site,
    brigade = brigade,
    platoon = platoon,
    group = nil,
    startCoordinate = nil,
    movementM = 0,
    missionObserved = false,
  }
  state.sites[siteKey] = siteState

  brigade.OnAfterArmyOnMission = function(self, From, Event, To, armyGroup, mission)
    local group = armyGroup and armyGroup:GetGroup() or nil
    if not group then
      fail(siteKey .. " GROUP_WRAPPER_MISSING")
      return
    end
    siteState.group = group
    siteState.startCoordinate = group:GetCoordinate()
    siteState.missionObserved = true
    log("GUARD_ARMY_ON_MISSION siteId=" .. site.siteId .. " mission=" .. tostring(mission and mission.name))
  end

  state.brigades[siteKey] = brigade
  return brigade
end

local function telemetry()
  for _, siteKey in ipairs(SITE_KEYS) do
    local siteState = state.sites[siteKey]
    if siteState then
      local alive = siteState.group ~= nil and siteState.group:IsAlive()
      if alive and siteState.startCoordinate then
        local coordinate = siteState.group:GetCoordinate()
        if coordinate then
          siteState.movementM = siteState.startCoordinate:Get2DDistance(coordinate)
        end
      end
      log(string.format(
        "TELEMETRY siteId=%s missionObserved=%s alive=%s movementM=%.1f",
        siteState.site.siteId,
        tostring(siteState.missionObserved),
        tostring(alive),
        siteState.movementM or 0
      ))
    end
  end
end

local function finish()
  if state.failed or state.passed then return end
  telemetry()

  local failures = {}
  for _, siteKey in ipairs(SITE_KEYS) do
    local siteState = state.sites[siteKey]
    if not siteState then
      failures[#failures + 1] = siteKey .. ":NO_STATE"
    else
      if not siteState.missionObserved then
        failures[#failures + 1] = siteKey .. ":MISSION_NOT_OBSERVED"
      end
      if not siteState.group or not siteState.group:IsAlive() then
        failures[#failures + 1] = siteKey .. ":GUARD_NOT_ALIVE"
      end
      if (siteState.movementM or 0) < MIN_MOVEMENT_M then
        failures[#failures + 1] = string.format(
          "%s:MOVEMENT_%.1f_LT_%d",
          siteKey,
          siteState.movementM or 0,
          MIN_MOVEMENT_M
        )
      end
    end
  end

  if #failures > 0 then
    fail("production package Guard runtime incomplete: " .. table.concat(failures, ", "))
    return
  end

  state.passed = true
  announce("PASS", "6/6 production-package Guards recruited, routed and >=25 m movement observed", 30)
end

local function startSites()
  if state.failed then return end
  for _, siteKey in ipairs(SITE_KEYS) do
    local _, created, reason = state.runtime:StartSite(siteKey, {})
    if created == false then
      fail(siteKey .. " START_SITE_FAILED " .. tostring(reason))
      return
    end
    log("SITE_STARTED siteId=" .. siteKey .. " reason=" .. tostring(reason))
  end

  SCHEDULER:New(nil, telemetry, {}, TELEMETRY_SECONDS, TELEMETRY_SECONDS)
  SCHEDULER:New(nil, finish, {}, OBSERVATION_SECONDS)
  announce("READY", "production Base package started for six-site Guard runtime observation", 15)
end

local function start()
  if type(OMW) ~= "table" or type(OMW.FireSupStratResupply) ~= "table" then
    fail("OMW.FireSupStratResupply package unavailable")
    return
  end
  local package = OMW.FireSupStratResupply
  if package.SchemaVersion ~= "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1" then
    fail("unexpected package schema " .. tostring(package.SchemaVersion))
    return
  end
  if type(package.New) ~= "function" then
    fail("OMW.FireSupStratResupply.New() unavailable")
    return
  end
  if type(package.SiteRegistry) ~= "table" or type(package.SiteRegistry.Sites) ~= "table" then
    fail("production SiteRegistry unavailable")
    return
  end

  local templateGroup = GROUP:FindByName(package.SiteRegistry.GuardTemplateName)
  if not templateGroup then
    fail("Guard template unavailable: " .. tostring(package.SiteRegistry.GuardTemplateName))
    return
  end

  for _, siteKey in ipairs(SITE_KEYS) do
    local site = package.SiteRegistry.Sites[siteKey]
    if not site then
      fail(siteKey .. " REGISTRY_MISSING")
      return
    end
    local pathline = PATHLINE:FindByName(site.guardRoute.pathlineName)
    if not pathline then
      fail(site.guardRoute.pathlineName .. " missing")
      return
    end
    createBrigade(siteKey, site, templateGroup)
  end

  local ok, runtimeOrError = pcall(function()
    return package.New({
      brigades = state.brigades,
      resolveGuardPathline = function(pathlineName)
        return PATHLINE:FindByName(pathlineName)
      end,
      resolveGuardTemplateGroup = function(templateName)
        return GROUP:FindByName(templateName)
      end,
      -- Required QRF boundary only. Acceptance 1 deliberately does not create a QRF demand.
      resolveQrfCoordinate = function()
        return nil
      end,
      logger = log,
    }):Prepare()
  end)
  if not ok then
    fail("RUNTIME_PREPARE_FAILED " .. tostring(runtimeOrError))
    return
  end

  state.runtime = runtimeOrError
  if not state.runtime then
    fail("RUNTIME_PREPARE_RETURNED_NIL")
    return
  end

  for _, siteKey in ipairs(SITE_KEYS) do
    state.brigades[siteKey]:Start()
  end

  SCHEDULER:New(nil, startSites, {}, 3)
end

SCHEDULER:New(nil, start, {}, 10)
