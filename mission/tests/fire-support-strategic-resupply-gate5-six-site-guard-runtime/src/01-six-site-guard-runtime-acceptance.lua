-- Operation Mountain Watch - Gate 5 six-site Guard runtime acceptance.
-- Test-ID: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-1
-- Scope: six persistent Guard groups, existing v23 PATHLINEs, physical movement only.

local TEST_ID = "FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local Sites = OMW_GATE5_SITE_REGISTRY

local SPEED_KMH = 5
local OBSERVE_SEC = 300
local TELEMETRY_SEC = 30
local MIN_MOVE_M = 25

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
}

local function log(text)
  env.info(TAG .. " " .. tostring(text), false)
end

local function message(topic, text, seconds)
  local line = "[GATE 5][" .. tostring(topic) .. "] " .. tostring(text)
  log(line)
  MESSAGE:New(line, seconds or 10):ToAll()
end

local function fail(reason)
  if state.failed or state.passed then return end
  state.failed = true
  message("FAIL", reason, 20)
end

local function buildGuardPatrolRoute(group, pathline)
  local coordinates = pathline:GetCoordinates()
  if type(coordinates) ~= "table" or #coordinates < 2 then
    return nil, "PATHLINE_REQUIRES_AT_LEAST_TWO_COORDINATES"
  end

  local route = {}
  for _, coordinate in ipairs(coordinates) do
    route[#route + 1] = coordinate:WaypointGround(SPEED_KMH, "Off Road")
  end

  local repeatTask = group:TaskFunction("CONTROLLABLE.Route", route, 2)
  group:SetTaskWaypoint(route[#route], repeatTask)
  return route, nil
end

local function setupSite(siteKey)
  local site = Sites.Sites[siteKey]
  if not site then
    fail(siteKey .. " registry entry missing")
    return false
  end

  local accessZone = ZONE:FindByName(site.accessZoneName)
  local pathline = PATHLINE:FindByName(site.guardRoute.pathlineName)
  if not accessZone then
    fail(site.accessZoneName .. " missing")
    return false
  end
  if not pathline then
    fail(site.guardRoute.pathlineName .. " missing")
    return false
  end

  local siteState = {
    site = site,
    pathline = pathline,
    brigade = nil,
    platoon = nil,
    mission = nil,
    armyGroup = nil,
    group = nil,
    startCoordinate = nil,
    movementM = 0,
    routeStarted = false,
  }
  state.sites[siteKey] = siteState

  siteState.brigade = BRIGADE:New(site.warehouseName, "BDE_G5_GUARD_" .. siteKey)
  siteState.brigade:SetSpawnZone(accessZone)

  siteState.platoon = PLATOON:New(site.guardTemplateName, 1, "PLT_G5_GUARD_" .. siteKey)
  siteState.platoon:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
  siteState.brigade:AddPlatoon(siteState.platoon)

  siteState.brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
    if Mission ~= siteState.mission then return end

    siteState.armyGroup = ArmyGroup
    siteState.group = ArmyGroup:GetGroup()
    if not siteState.group then
      fail(siteKey .. " ArmyGroup has no MOOSE GROUP wrapper")
      return
    end

    siteState.startCoordinate = siteState.group:GetCoordinate()
    if not siteState.startCoordinate then
      fail(siteKey .. " Guard has no start coordinate")
      return
    end

    local route, reason = buildGuardPatrolRoute(siteState.group, siteState.pathline)
    if not route then
      fail(siteKey .. " Guard PATHLINE route build failed: " .. tostring(reason))
      return
    end

    siteState.group:Route(route, 2)
    siteState.routeStarted = true
    message("GUARD", siteKey .. " materialized and routed on " .. site.guardRoute.pathlineName, 8)
  end

  siteState.brigade.OnAfterStart = function()
    SCHEDULER:New(nil, function()
      if state.failed then return end

      local coordinates = siteState.pathline:GetCoordinates()
      if type(coordinates) ~= "table" or not coordinates[1] then
        fail(siteKey .. " PATHLINE start coordinate unavailable")
        return
      end

      siteState.mission = AUFTRAG:NewONGUARD(coordinates[1])
      siteState.mission:SetRequiredAssets(1, 1)
      siteState.mission:SetName("OMW_G5_GUARD_" .. siteKey)
      siteState.mission:AssignCohort(siteState.platoon)
      siteState.brigade:AddMission(siteState.mission)
      log("GUARD_MISSION_ADDED siteId=" .. site.siteId .. " pathline=" .. site.guardRoute.pathlineName)
    end, {}, 3)
  end

  siteState.brigade:Start()
  return true
end

local function updateTelemetry()
  for _, siteKey in ipairs(SITE_KEYS) do
    local siteState = state.sites[siteKey]
    if siteState and siteState.group and siteState.startCoordinate and siteState.group:IsAlive() then
      local currentCoordinate = siteState.group:GetCoordinate()
      if currentCoordinate then
        siteState.movementM = siteState.startCoordinate:Get2DDistance(currentCoordinate)
      end
    end

    if siteState then
      local alive = siteState.group ~= nil and siteState.group:IsAlive()
      log(string.format(
        "TELEMETRY siteId=%s routeStarted=%s alive=%s movementM=%.1f",
        tostring(siteState.site.siteId),
        tostring(siteState.routeStarted),
        tostring(alive),
        siteState.movementM or 0
      ))
    end
  end
end

local function finishAcceptance()
  if state.failed or state.passed then return end
  updateTelemetry()

  local failures = {}
  for _, siteKey in ipairs(SITE_KEYS) do
    local siteState = state.sites[siteKey]
    if not siteState then
      failures[#failures + 1] = siteKey .. ":NO_SITE_STATE"
    else
      if not siteState.routeStarted then
        failures[#failures + 1] = siteKey .. ":ROUTE_NOT_STARTED"
      end
      if not siteState.group or not siteState.group:IsAlive() then
        failures[#failures + 1] = siteKey .. ":GUARD_NOT_ALIVE"
      end
      if (siteState.movementM or 0) < MIN_MOVE_M then
        failures[#failures + 1] = string.format(
          "%s:MOVEMENT_%.1f_LT_%d",
          siteKey,
          siteState.movementM or 0,
          MIN_MOVE_M
        )
      end
    end
  end

  if #failures > 0 then
    fail("six-site Guard runtime incomplete: " .. table.concat(failures, ", "))
    return
  end

  state.passed = true
  message("PASS", "6/6 Guards materialized, existing PATHLINE routes active, >=25 m physical movement observed", 25)
end

local function start()
  if type(Sites) ~= "table" or type(Sites.Sites) ~= "table" then
    fail("embedded SiteRegistry unavailable")
    return
  end
  if OMW_GROUND_READY ~= 1 then
    fail("Ground Base not ready; expected OMW_GROUND_READY=1")
    return
  end

  for _, siteKey in ipairs(SITE_KEYS) do
    if not setupSite(siteKey) then return end
  end

  SCHEDULER:New(nil, updateTelemetry, {}, TELEMETRY_SEC, TELEMETRY_SEC)
  SCHEDULER:New(nil, finishAcceptance, {}, OBSERVE_SEC)
  message("READY", "six-site Guard runtime started on existing v23 PATHLINEs; observation window 300 seconds", 15)
end

SCHEDULER:New(nil, start, {}, 10)
