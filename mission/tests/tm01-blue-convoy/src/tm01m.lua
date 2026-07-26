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
    route = nil,
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
      { "SPAWN.SpawnFromCoordinate", SPAWN and SPAWN.SpawnFromCoordinate },
      { "GROUP.FindByName", GROUP and GROUP.FindByName },
      { "CONTROLLABLE.Route", CONTROLLABLE and CONTROLLABLE.Route },
      { "CONTROLLABLE.TaskGroundOnRoad", CONTROLLABLE and CONTROLLABLE.TaskGroundOnRoad },
      { "GROUP.CountAliveUnits", GROUP and GROUP.CountAliveUnits },
      { "GROUP.IsCompletelyInZone", GROUP and GROUP.IsCompletelyInZone },
      { "ZONE.FindByName", ZONE and ZONE.FindByName },
      { "ZONE_BASE.GetCoordinate", ZONE_BASE and ZONE_BASE.GetCoordinate },
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

  local function buildRoadRoute(runtimeGroup, objects)
    local destinations = {}
    for _, zone in ipairs(objects.routeZones) do
      destinations[#destinations + 1] = zone:GetCoordinate()
    end
    destinations[#destinations + 1] = objects.targetZone:GetCoordinate()

    local route = {}
    local fromCoordinate = runtimeGroup:GetCoordinate()
    for _, toCoordinate in ipairs(destinations) do
      local segment = runtimeGroup:TaskGroundOnRoad(
        toCoordinate,
        config.routing.speedKph,
        config.routing.offRoadFormation or "Off Road",
        false,
        fromCoordinate
      )
      for index, waypoint in ipairs(segment or {}) do
        if #route == 0 or index > 1 then
          route[#route + 1] = waypoint
        end
      end
      fromCoordinate = toCoordinate
    end
    return route
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

  local function spawnConvoy()
    if state.runtimeGroup and state.runtimeGroup:IsAlive() == true then
      message("Spawn rejected: convoy already exists")
      return false
    end

    state.spawner = SPAWN:NewWithAlias(config.template.groupName, config.template.runtimeAlias)
    state.runtimeGroup = state.spawner:SpawnFromCoordinate(objects.startZone:GetCoordinate())
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

    state.route = nil
    state.routeStarted = false
    state.arrived = false
    state.destroyed = false
    local spawnCoordinate = state.runtimeGroup:GetCoordinate()
    log("INFO", "convoy_spawned", {
      runtimeGroupName = state.runtimeGroup:GetName(),
      aliveUnits = alive,
      spawnZoneName = config.zones.start,
      spawnX = math.floor(spawnCoordinate.x + 0.5),
      spawnY = math.floor(spawnCoordinate.z + 0.5),
    })
    message("MOOSE convoy spawned in " .. config.zones.start .. ": " .. state.runtimeGroup:GetName())
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

    state.route = buildRoadRoute(state.runtimeGroup, objects)
    if not state.route or #state.route < 2 then
      setOutcome(OUTCOME_FAIL_SCRIPT, "MOOSE road path generation produced no usable route")
      message("MOOSE road path generation failed")
      return false
    end

    local assigned = state.runtimeGroup:Route(state.route, config.routing.routeDelaySeconds)
    if not assigned then
      message("MOOSE route assignment failed")
      return false
    end
    state.routeStarted = true
    log("INFO", "convoy_route_started", {
      waypointCount = #state.route,
      anchorCount = #objects.routeZones,
      speedKph = config.routing.speedKph,
      routeMode = "MOOSE_TaskGroundOnRoad",
    })
    message("MOOSE road route started")
    return true
  end

  local function showStatus()
    local alive = state.runtimeGroup and state.runtimeGroup:CountAliveUnits() or 0
    message(table.concat({
      "Outcome: " .. tostring(state.outcome),
      "Convoy alive: " .. tostring(state.runtimeGroup and state.runtimeGroup:IsAlive() == true),
      "Vehicles alive: " .. tostring(alive),
      "Route started: " .. tostring(state.routeStarted),
      "Route waypoints: " .. tostring(state.route and #state.route or 0),
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

  setOutcome(OUTCOME_READY, "TM01M MOOSE-native physical convoy baseline is ready")
  log("INFO", "startup", {
    testId = build.testId,
    stageId = build.stageId,
    configurationVersion = config.configurationVersion,
    routeAnchorCount = #objects.routeZones,
    customCampaignStateLoaded = false,
    customProxyControllerLoaded = false,
    customInterestMonitorLoaded = false,
    customWatchdogLoaded = false,
  })
  message("TM01M READY: MOOSE-native physical convoy baseline")
  return state
end

return TM01M
