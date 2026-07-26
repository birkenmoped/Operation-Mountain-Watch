local TM01M = {}

local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"

local function join(values)
  return #(values or {}) > 0 and table.concat(values, ",") or "none"
end

function TM01M.start(dependencies)
  local config = assert(dependencies.config, "config is required")
  local build = assert(dependencies.build, "build metadata is required")

  local state = {
    outcome = OUTCOME_FAIL_SCRIPT,
    detail = "bootstrap not completed",
    runtimeGroup = nil,
    spawner = nil,
    routeStarted = false,
    arrived = false,
    destroyed = false,
    scheduler = nil,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM01M] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function message(text, duration)
    MESSAGE:New(
      text,
      duration or config.messages.durationSeconds,
      config.messages.category
    ):ToAll()
  end

  local function setOutcome(outcome, detail)
    state.outcome = outcome
    state.detail = detail
    log("INFO", "bootstrap_outcome", { outcome = outcome, detail = detail })
  end

  local function requiredMooseApis()
    local required = {
      { "SPAWN.NewWithAlias", SPAWN and SPAWN.NewWithAlias },
      { "GROUP.FindByName", GROUP and GROUP.FindByName },
      { "GROUP.Route", GROUP and GROUP.Route },
      { "GROUP.CountAliveUnits", GROUP and GROUP.CountAliveUnits },
      { "GROUP.IsCompletelyInZone", GROUP and GROUP.IsCompletelyInZone },
      { "ZONE.FindByName", ZONE and ZONE.FindByName },
      { "ZONE_BASE.GetCoordinate", ZONE_BASE and ZONE_BASE.GetCoordinate },
      { "COORDINATE.WaypointGround", COORDINATE and COORDINATE.WaypointGround },
      { "SCHEDULER.New", SCHEDULER and SCHEDULER.New },
      { "MESSAGE.New", MESSAGE and MESSAGE.New },
      { "MENU_MISSION.New", MENU_MISSION and MENU_MISSION.New },
      { "MENU_MISSION_COMMAND.New", MENU_MISSION_COMMAND and MENU_MISSION_COMMAND.New },
    }
    local missing = {}
    for _, item in ipairs(required) do
      if type(item[2]) ~= "function" then missing[#missing + 1] = item[1] end
    end
    return #missing == 0, missing
  end

  local function resolveMissionObjects()
    local missing, errors = {}, {}
    local objects = { routeZones = {} }

    local ok, template = pcall(function() return GROUP:FindByName(config.template.groupName) end)
    if not ok then errors[#errors + 1] = tostring(template)
    elseif not template then missing[#missing + 1] = config.template.groupName
    else objects.template = template end

    local function resolveZone(name)
      local zoneOk, zone = pcall(function() return ZONE:FindByName(name) end)
      if not zoneOk then
        errors[#errors + 1] = tostring(name) .. ":" .. tostring(zone)
        return nil
      end
      if not zone then missing[#missing + 1] = name end
      return zone
    end

    objects.startZone = resolveZone(config.zones.start)
    objects.targetZone = resolveZone(config.zones.target)
    for _, name in ipairs(config.zones.routeAnchors or {}) do
      objects.routeZones[#objects.routeZones + 1] = resolveZone(name)
    end

    return #missing == 0 and #errors == 0, objects, missing, errors
  end

  local function buildRoute(objects)
    local waypoints = {}
    for _, zone in ipairs(objects.routeZones) do
      waypoints[#waypoints + 1] = zone:GetCoordinate():WaypointGround(
        config.routing.speedKph,
        config.routing.formation
      )
    end
    waypoints[#waypoints + 1] = objects.targetZone:GetCoordinate():WaypointGround(
      config.routing.speedKph,
      config.routing.formation
    )
    return waypoints
  end

  local apiOk, missingApis = requiredMooseApis()
  if not apiOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required MOOSE APIs are unavailable")
    log("ERROR", "moose_api_validation_failed", { missing = join(missingApis) })
    return state
  end

  local objectsOk, objects, missingObjects, objectErrors = resolveMissionObjects()
  if #objectErrors > 0 then
    setOutcome(OUTCOME_FAIL_SCRIPT, "Mission Editor object lookup failed")
    log("ERROR", "mission_object_lookup_failed", { errors = join(objectErrors) })
    return state
  end
  if not objectsOk then
    setOutcome(OUTCOME_FAIL_CONFIGURATION, "required Mission Editor objects are missing")
    log("ERROR", "mission_configuration_missing", { missing = join(missingObjects) })
    return state
  end

  local route = buildRoute(objects)

  local function spawnConvoy()
    if state.runtimeGroup and state.runtimeGroup:IsAlive() == true then
      message("Spawn rejected: convoy already exists")
      return false
    end

    state.spawner = SPAWN:NewWithAlias(config.template.groupName, config.template.runtimeAlias)
    state.runtimeGroup = state.spawner:Spawn()
    if not state.runtimeGroup or state.runtimeGroup:IsAlive() ~= true then
      setOutcome(OUTCOME_FAIL_SCRIPT, "SPAWN did not create a living convoy")
      message("Convoy spawn failed")
      return false
    end

    local alive = state.runtimeGroup:CountAliveUnits()
    if alive ~= config.template.expectedVehicleCount then
      setOutcome(OUTCOME_FAIL_SCRIPT, "spawned convoy vehicle count mismatch")
      log("ERROR", "spawn_count_mismatch", {
        expected = config.template.expectedVehicleCount,
        observed = alive,
      })
      message("Convoy spawn failed: vehicle count mismatch")
      return false
    end

    state.routeStarted = false
    state.arrived = false
    state.destroyed = false
    log("INFO", "convoy_spawned", {
      runtimeGroupName = state.runtimeGroup:GetName(),
      aliveUnits = alive,
    })
    message("MOOSE convoy spawned: " .. state.runtimeGroup:GetName())
    return true
  end

  local function startRoute()
    if not state.runtimeGroup or state.runtimeGroup:IsAlive() ~= true then
      message("Route rejected: no living convoy")
      return false
    end
    if state.routeStarted then
      message("Route rejected: already started")
      return false
    end
    local assigned = state.runtimeGroup:Route(route, config.routing.routeDelaySeconds)
    if not assigned then
      message("MOOSE route assignment failed")
      return false
    end
    state.routeStarted = true
    log("INFO", "convoy_route_started", {
      waypointCount = #route,
      speedKph = config.routing.speedKph,
      formation = config.routing.formation,
    })
    message("MOOSE convoy route started")
    return true
  end

  local function showStatus()
    local alive = state.runtimeGroup and state.runtimeGroup:CountAliveUnits() or 0
    message(table.concat({
      "Outcome: " .. tostring(state.outcome),
      "Convoy alive: " .. tostring(state.runtimeGroup and state.runtimeGroup:IsAlive() == true),
      "Vehicles alive: " .. tostring(alive),
      "Route started: " .. tostring(state.routeStarted),
      "Arrived: " .. tostring(state.arrived),
      "Destroyed: " .. tostring(state.destroyed),
    }, "\n"))
  end

  local function supervise()
    if not state.runtimeGroup then return end
    if state.runtimeGroup:IsAlive() ~= true or state.runtimeGroup:CountAliveUnits() < 1 then
      if not state.destroyed then
        state.destroyed = true
        log("INFO", "convoy_destroyed", {})
        message("MOOSE convoy destroyed")
      end
      return
    end
    if state.routeStarted and not state.arrived
      and state.runtimeGroup:IsCompletelyInZone(objects.targetZone) == true then
      state.arrived = true
      log("INFO", "convoy_arrived", {
        runtimeGroupName = state.runtimeGroup:GetName(),
        survivingVehicles = state.runtimeGroup:CountAliveUnits(),
        targetZoneName = config.zones.target,
      })
      message("MOOSE convoy arrived at " .. config.zones.target)
    end
  end

  state.scheduler = SCHEDULER:New(
    nil,
    supervise,
    {},
    config.supervision.initialDelaySeconds,
    config.supervision.intervalSeconds
  )

  if config.debug.enableF10Menu == true then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM01M MOOSE Native Convoy", root)
    MENU_MISSION_COMMAND:New("Spawn convoy", menu, spawnConvoy)
    MENU_MISSION_COMMAND:New("Start route", menu, startRoute)
    MENU_MISSION_COMMAND:New("Show status", menu, showStatus)
  end

  state.spawnConvoy = spawnConvoy
  state.startRoute = startRoute
  state.showStatus = showStatus
  state.objects = objects
  state.route = route

  setOutcome(OUTCOME_READY, "TM01M MOOSE-native physical convoy baseline is ready")
  log("INFO", "startup", {
    testId = build.testId,
    stageId = build.stageId,
    configurationVersion = config.configurationVersion,
    routeWaypointCount = #route,
    customCampaignStateLoaded = false,
    customProxyControllerLoaded = false,
    customInterestMonitorLoaded = false,
    customWatchdogLoaded = false,
  })
  message("TM01M READY: MOOSE-native physical convoy baseline")
  return state
end

return TM01M
