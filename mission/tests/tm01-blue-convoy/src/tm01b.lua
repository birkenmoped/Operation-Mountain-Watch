local TM01B = {}

local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"

local function join(values)
  if #values == 0 then
    return "none"
  end
  return table.concat(values, ",")
end

local function validateFunction(path, getter, missing)
  local ok, value = pcall(getter)
  if not ok or type(value) ~= "function" then
    missing[#missing + 1] = path
  end
end

local function validateTm01bNativeApis()
  local missing = {}
  validateFunction("timer.scheduleFunction", function()
    return timer and timer.scheduleFunction
  end, missing)
  validateFunction("Group.getByName", function()
    return Group and Group.getByName
  end, missing)
  return #missing == 0, missing
end

local function validateTm01bMooseApis()
  local missing = {}
  validateFunction("GROUP.GetUnits", function()
    return GROUP and GROUP.GetUnits
  end, missing)
  validateFunction("POSITIONABLE.Destroy", function()
    return POSITIONABLE and POSITIONABLE.Destroy
  end, missing)
  validateFunction("POSITIONABLE.GetVec2", function()
    return POSITIONABLE and POSITIONABLE.GetVec2
  end, missing)
  validateFunction("SPAWN.InitSetUnitAbsolutePositions", function()
    return SPAWN and SPAWN.InitSetUnitAbsolutePositions
  end, missing)
  validateFunction("SPAWN.Spawn", function()
    return SPAWN and SPAWN.Spawn
  end, missing)
  validateFunction("CONTROLLABLE.Route", function()
    return CONTROLLABLE and CONTROLLABLE.Route
  end, missing)
  validateFunction("ZONE_BASE.GetVec2", function()
    return ZONE_BASE and ZONE_BASE.GetVec2
  end, missing)
  validateFunction("ZONE_BASE.GetCoordinate", function()
    return ZONE_BASE and ZONE_BASE.GetCoordinate
  end, missing)
  validateFunction("ZONE_BASE.IsVec2InZone", function()
    return ZONE_BASE and ZONE_BASE.IsVec2InZone
  end, missing)
  validateFunction("ZONE_RADIUS.GetRadius", function()
    return ZONE_RADIUS and ZONE_RADIUS.GetRadius
  end, missing)
  validateFunction("COORDINATE.NewFromVec2", function()
    return COORDINATE and COORDINATE.NewFromVec2
  end, missing)
  validateFunction("COORDINATE.GetClosestPointToRoad", function()
    return COORDINATE and COORDINATE.GetClosestPointToRoad
  end, missing)
  validateFunction("COORDINATE.GetPathOnRoad", function()
    return COORDINATE and COORDINATE.GetPathOnRoad
  end, missing)
  validateFunction("COORDINATE.Get2DDistance", function()
    return COORDINATE and COORDINATE.Get2DDistance
  end, missing)
  validateFunction("COORDINATE.WaypointGround", function()
    return COORDINATE and COORDINATE.WaypointGround
  end, missing)
  validateFunction("MARKER.New", function()
    return MARKER and MARKER.New
  end, missing)
  validateFunction("MARKER.ReadOnly", function()
    return MARKER and MARKER.ReadOnly
  end, missing)
  validateFunction("MARKER.ToBlue", function()
    return MARKER and MARKER.ToBlue
  end, missing)
  validateFunction("MARKER.UpdateCoordinate", function()
    return MARKER and MARKER.UpdateCoordinate
  end, missing)
  validateFunction("MARKER.UpdateText", function()
    return MARKER and MARKER.UpdateText
  end, missing)
  validateFunction("MARKER.Remove", function()
    return MARKER and MARKER.Remove
  end, missing)
  return #missing == 0, missing
end

local function positiveNumber(value)
  return type(value) == "number" and value > 0
end

local function validateConfiguration(config)
  local missing = {}
  local errors = {}
  local checked = {}

  local function checkGroup(name)
    if checked["group:" .. tostring(name)] then
      return
    end
    checked["group:" .. tostring(name)] = true
    local ok, groupOrError = pcall(function()
      return GROUP:FindByName(name)
    end)
    if not ok then
      errors[#errors + 1] = tostring(name) .. ": " .. tostring(groupOrError)
    elseif not groupOrError then
      missing[#missing + 1] = name
    end
  end

  local function checkZone(name)
    if checked["zone:" .. tostring(name)] then
      return
    end
    checked["zone:" .. tostring(name)] = true
    local ok, zoneOrError = pcall(function()
      return ZONE:FindByName(name)
    end)
    if not ok then
      errors[#errors + 1] = tostring(name) .. ": " .. tostring(zoneOrError)
    elseif not zoneOrError then
      missing[#missing + 1] = name
    end
  end

  local function requireZoneName(name, description)
    if type(name) ~= "string" or name == "" then
      errors[#errors + 1] = description .. " zone name is missing"
      return false
    end
    checkZone(name)
    return true
  end

  checkGroup(config.template.groupName)
  requireZoneName(config.zones.start, "global route start")
  requireZoneName(config.zones.target, "global route target")

  if type(config.zones.routeAnchors) ~= "table"
    or #config.zones.routeAnchors ~= 7 then
    errors[#errors + 1] = "TM01B requires exactly seven intermediate route anchors"
  else
    for index, zoneName in ipairs(config.zones.routeAnchors) do
      requireZoneName(zoneName, "global route anchor " .. tostring(index))
    end
  end

  if type(config.zones.revealWindows) ~= "table"
    or #config.zones.revealWindows < 1 then
    errors[#errors + 1] = "at least one circular reveal window is required"
  else
    local ids = {}
    local zoneNames = {}
    for index, window in ipairs(config.zones.revealWindows) do
      if type(window.id) ~= "string" or window.id == "" then
        errors[#errors + 1] = "reveal window id is missing: " .. tostring(index)
      elseif ids[window.id] then
        errors[#errors + 1] = "duplicate reveal window id: " .. window.id
      else
        ids[window.id] = true
      end

      if requireZoneName(window.zone, "reveal window " .. tostring(index)) then
        if zoneNames[window.zone] then
          errors[#errors + 1] = "duplicate reveal window zone: " .. window.zone
        end
        zoneNames[window.zone] = true
      end
    end
  end

  if config.virtualization.initialSectionIndex ~= 1 then
    errors[#errors + 1] = "initialSectionIndex must be 1"
  end
  if type(config.zones.revealWindows) == "table"
    and config.virtualization.finalSectionIndex ~= #config.zones.revealWindows then
    errors[#errors + 1] = "finalSectionIndex must reference the last reveal window"
  end
  if config.template.expectedVehicleCount ~= 6 then
    errors[#errors + 1] = "TM01B expects exactly six configured vehicle slots"
  end
  if config.virtualization.automaticAdvance ~= true
    or config.virtualization.automaticMaterialization ~= true
    or config.virtualization.automaticDematerialization ~= true then
    errors[#errors + 1] = "TM01B version 5 requires all automatic transitions"
  end
  if config.virtualization.visibilityMode ~= "CIRCULAR_WINDOW_ANY_UNIT_INSIDE" then
    errors[#errors + 1] = "unsupported reveal-window visibility mode"
  end

  local positiveSettings = {
    { config.virtualization.effectiveSpeedKph, "effective virtual speed" },
    { config.virtualization.automationPollSeconds, "automation poll interval" },
    { config.virtualization.minimumVirtualLegSeconds, "minimum virtual leg duration" },
    { config.virtualization.virtualMarkerUpdateSeconds, "virtual marker update interval" },
    { config.virtualization.destroyConfirmationPollSeconds, "destroy confirmation poll interval" },
    { config.virtualization.destroyConfirmationTimeoutSeconds, "destroy confirmation timeout" },
    { config.routing.routeSampleMeters, "road route sample spacing" },
    { config.routing.physicalWaypointSpacingMeters, "physical waypoint spacing" },
    { config.routing.maximumRoadSnapMeters, "maximum road snap distance" },
    { config.routing.roadPositionToleranceMeters, "road position tolerance" },
    { config.routing.vehicleSpacingMeters, "vehicle spacing" },
    { config.routing.spawnInteriorMarginMeters, "spawn interior margin" },
    { config.routing.physicalClearanceMeters, "physical clearance" },
  }
  for _, setting in ipairs(positiveSettings) do
    if not positiveNumber(setting[1]) then
      errors[#errors + 1] = setting[2] .. " must be positive"
    end
  end

  if positiveNumber(config.virtualization.destroyConfirmationPollSeconds)
    and positiveNumber(config.virtualization.destroyConfirmationTimeoutSeconds)
    and config.virtualization.destroyConfirmationTimeoutSeconds
      <= config.virtualization.destroyConfirmationPollSeconds then
    errors[#errors + 1] = "destroy confirmation timeout must exceed poll interval"
  end

  local checkedObjectCount = 0
  for _ in pairs(checked) do
    checkedObjectCount = checkedObjectCount + 1
  end

  return {
    valid = #missing == 0 and #errors == 0,
    missing = missing,
    errors = errors,
    checkedObjectCount = checkedObjectCount,
  }
end

function TM01B.start(dependencies)
  local build = dependencies.build
  local config = dependencies.config
  local state = {
    outcome = OUTCOME_FAIL_SCRIPT,
    detail = "bootstrap not completed",
    checkedObjectCount = 0,
  }

  local nativeValid, missingNativeApis = dependencies.runtimeGuard.validateNative()
  if not nativeValid then
    state.detail = "required native DCS APIs are unavailable"
    dependencies.safeReporter.report(
      "native_api_validation_failed",
      OUTCOME_FAIL_SCRIPT,
      "missing=" .. join(missingNativeApis),
      "[OMW][TM01B]"
    )
    return state
  end

  local logger = dependencies.structuredLogger.new("[OMW][TM01B]")

  local function announce(text)
    trigger.action.outText("[OMW][TM01B] " .. text, 15, false)
  end

  local function setOutcome(outcome, detail)
    state.outcome = outcome
    state.detail = detail
    logger:info("bootstrap_outcome", {
      detail = detail,
      outcome = outcome,
    })
  end

  local function runConfigurationValidation()
    local ok, resultOrError = pcall(validateConfiguration, config)
    if not ok then
      setOutcome(OUTCOME_FAIL_SCRIPT, "configuration validation raised an error")
      logger:error("configuration_validation_error", { error = resultOrError })
      return false
    end

    local result = resultOrError
    state.checkedObjectCount = result.checkedObjectCount
    if #result.errors > 0 then
      setOutcome(OUTCOME_FAIL_SCRIPT, "configuration validation failed")
      logger:error("configuration_lookup_error", {
        checkedObjectCount = result.checkedObjectCount,
        errors = join(result.errors),
      })
      return false
    end
    if not result.valid then
      setOutcome(OUTCOME_FAIL_CONFIGURATION, "required Mission Editor objects are missing")
      logger:error("configuration_invalid", {
        checkedObjectCount = result.checkedObjectCount,
        missing = join(result.missing),
      })
      return false
    end

    logger:info("configuration_valid", {
      checkedObjectCount = result.checkedObjectCount,
      configurationVersion = config.configurationVersion,
      globalRouteStart = config.zones.start,
      globalRouteAnchorCount = #config.zones.routeAnchors,
      globalRouteTarget = config.zones.target,
      revealWindowCount = #config.zones.revealWindows,
      oneCircularZonePerWindow = true,
      visibilityMode = config.virtualization.visibilityMode,
      virtualMarkerEnabled = config.virtualization.showVirtualMarker,
      roadAlignedAbsoluteVehicleSpawn = true,
      oneManualStartCommand = true,
    })
    setOutcome(OUTCOME_READY, "TM01B circular reveal-window caching is ready")
    return true
  end

  local function protectMenuCallback(commandName, callback)
    return function()
      local ok, callbackError = pcall(callback)
      if not ok then
        logger:error("menu_callback_failed", {
          command = commandName,
          error = callbackError,
          outcome = OUTCOME_FAIL_SCRIPT,
        })
        announce("Menu command failed: " .. commandName)
      end
    end
  end

  logger:info("startup", {
    buildTimestamp = build.buildTimestamp,
    configurationVersion = build.configurationVersion,
    dcsVersion = tostring(_G.DCS_VERSION or _G._DCS_VERSION or "unavailable"),
    expectedMooseBuildCommit = build.expectedMooseBuildCommit,
    expectedMooseBuildTimestamp = build.expectedMooseBuildTimestamp,
    expectedMooseCompression = build.expectedMooseCompression,
    expectedMooseFileSha256 = build.expectedMooseFileSha256,
    expectedMooseIncludeFamily = build.expectedMooseIncludeFamily,
    expectedMooseVersion = build.expectedMooseVersion,
    missionTimeSeconds = timer.getTime(),
    mooseVerificationMode = build.mooseVerificationMode,
    stageId = build.stageId,
    testId = build.testId,
  })

  local tm01bNativeValid, missingTm01bNativeApis = validateTm01bNativeApis()
  if not tm01bNativeValid then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required TM01B native APIs are unavailable")
    logger:error("tm01b_native_api_validation_failed", {
      missing = join(missingTm01bNativeApis),
    })
    return state
  end

  local baseMooseValid, missingBaseMooseApis = dependencies.runtimeGuard.validateMoose()
  if not baseMooseValid then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required baseline MOOSE APIs are unavailable")
    logger:error("moose_api_validation_failed", {
      missing = join(missingBaseMooseApis),
    })
    return state
  end

  local tm01bMooseValid, missingTm01bMooseApis = validateTm01bMooseApis()
  if not tm01bMooseValid then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required TM01B MOOSE APIs are unavailable")
    logger:error("tm01b_moose_api_validation_failed", {
      missing = join(missingTm01bMooseApis),
    })
    return state
  end

  logger:info("runtime_api_validation_passed", {
    additionalNativeApiCount = 2,
    additionalMooseApiCount = 21,
  })

  if not runConfigurationValidation() then
    return state
  end

  local campaignStateOk, campaignStateOrError = pcall(function()
    return dependencies.inMemoryCampaignState.new(config)
  end)
  if not campaignStateOk or type(campaignStateOrError) ~= "table" then
    setOutcome(OUTCOME_FAIL_SCRIPT, "CampaignState initialization failed")
    logger:error("campaign_state_initialization_failed", {
      error = campaignStateOk
        and "InMemoryCampaignState.new returned no table"
        or campaignStateOrError,
    })
    return state
  end

  local campaignState = campaignStateOrError
  local controllerOk, controllerOrError = pcall(function()
    return dependencies.convoyCacheController.new({
      announce = announce,
      campaignState = campaignState,
      config = config,
      getBootstrapOutcome = function()
        return state.outcome
      end,
      logger = logger,
    })
  end)
  if not controllerOk or type(controllerOrError) ~= "table" then
    setOutcome(OUTCOME_FAIL_SCRIPT, "cache controller initialization failed")
    logger:error("cache_controller_initialization_failed", {
      error = controllerOk
        and "ConvoyCacheController.new returned no table"
        or controllerOrError,
    })
    return state
  end

  local cacheController = controllerOrError

  local function showStatus()
    logger:info("status_requested", {
      checkedObjectCount = state.checkedObjectCount,
      detail = state.detail,
      outcome = state.outcome,
    })
    announce("Outcome: " .. state.outcome .. "\nDetail: " .. state.detail)
    cacheController:showStatus()
  end

  local function validateFromMenu()
    runConfigurationValidation()
    showStatus()
  end

  local menuOk, menuOrError = pcall(function()
    local rootMenu = MENU_MISSION:New("OMW Tests")
    local testMenu = MENU_MISSION:New(build.stageId, rootMenu)

    MENU_MISSION_COMMAND:New(
      "Start convoy",
      testMenu,
      protectMenuCallback("Start convoy", function()
        cacheController:start()
      end)
    )
    MENU_MISSION_COMMAND:New(
      "Show status",
      testMenu,
      protectMenuCallback("Show status", showStatus)
    )
    MENU_MISSION_COMMAND:New(
      "Validate configuration",
      testMenu,
      protectMenuCallback("Validate configuration", validateFromMenu)
    )

    return {
      root = rootMenu,
      test = testMenu,
    }
  end)

  if not menuOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "F10 menu creation failed")
    logger:error("menu_creation_failed", { error = menuOrError })
    return state
  end

  state.menu = menuOrError
  state.campaignState = campaignState
  state.cacheController = cacheController
  logger:info("campaign_state_ready", {
    entityId = config.scenarioId,
    initialRoutePosition = config.zones.start,
    persistenceEnabled = false,
  })
  logger:info("menu_ready", {
    path = "OMW Tests / " .. build.stageId,
    primaryCommand = "Start convoy",
  })

  return state
end

return TM01B
