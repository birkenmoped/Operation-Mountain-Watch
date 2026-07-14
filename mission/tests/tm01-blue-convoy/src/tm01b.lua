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
  validateFunction("SPAWN.InitPositionCoordinate", function()
    return SPAWN and SPAWN.InitPositionCoordinate
  end, missing)
  validateFunction("SPAWN.Spawn", function()
    return SPAWN and SPAWN.Spawn
  end, missing)

  return #missing == 0, missing
end

local function isInteger(value)
  return type(value) == "number" and value >= 0 and value == math.floor(value)
end

local function validateConfiguration(config)
  local missing = {}
  local errors = {}
  local checked = {}

  local function checkGroup(name)
    if checked["group:" .. name] then
      return
    end
    checked["group:" .. name] = true

    local ok, group = pcall(function()
      return GROUP:FindByName(name)
    end)
    if not ok then
      errors[#errors + 1] = name .. ": " .. tostring(group)
    elseif not group then
      missing[#missing + 1] = name
    end
  end

  local function checkZone(name)
    if checked["zone:" .. name] then
      return
    end
    checked["zone:" .. name] = true

    local ok, zone = pcall(function()
      return ZONE:FindByName(name)
    end)
    if not ok then
      errors[#errors + 1] = name .. ": " .. tostring(zone)
    elseif not zone then
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

  local routeZoneNames = {}
  if requireZoneName(config.zones.start, "global route start") then
    routeZoneNames[config.zones.start] = true
  end
  if requireZoneName(config.zones.target, "global route target") then
    if routeZoneNames[config.zones.target] then
      errors[#errors + 1] = "global route start and target names must differ"
    end
    routeZoneNames[config.zones.target] = true
  end

  if type(config.zones.routeAnchors) ~= "table"
    or #config.zones.routeAnchors ~= 7 then
    errors[#errors + 1] = "TM01B.1 requires exactly seven intermediate global route anchors"
  else
    for _, zoneName in ipairs(config.zones.routeAnchors) do
      if type(zoneName) ~= "string" or zoneName == "" then
        errors[#errors + 1] = "global route anchor name is missing"
      else
        if routeZoneNames[zoneName] then
          errors[#errors + 1] = "global route zone name is duplicated: " .. zoneName
        end
        routeZoneNames[zoneName] = true
        checkZone(zoneName)
      end
    end
  end

  local routeAnchorCount = type(config.zones.routeAnchors) == "table"
    and #config.zones.routeAnchors or 0
  local finalSegmentIndex = routeAnchorCount + 1
  local previousExitSegmentIndex = nil

  if type(config.zones.revealSections) ~= "table"
    or #config.zones.revealSections < 2 then
    errors[#errors + 1] = "at least two reveal sections are required"
  else
    for sectionIndex, section in ipairs(config.zones.revealSections) do
      if type(section.id) ~= "string" or section.id == "" then
        errors[#errors + 1] = "reveal section id is missing"
      end

      if type(section.entry) ~= "string" or section.entry == "" then
        errors[#errors + 1] = "reveal section entry zone is missing"
      else
        if routeZoneNames[section.entry] then
          errors[#errors + 1] = "reveal entry must not reuse a global route zone name: "
            .. section.entry
        end
        checkZone(section.entry)
      end

      if type(section.exit) ~= "string" or section.exit == "" then
        errors[#errors + 1] = "reveal section exit zone is missing"
      else
        if routeZoneNames[section.exit] then
          errors[#errors + 1] = "reveal exit must not reuse a global route zone name: "
            .. section.exit
        end
        if section.exit == section.entry then
          errors[#errors + 1] = "reveal entry and exit zone names must differ: "
            .. tostring(section.id)
        end
        checkZone(section.exit)
      end

      if not isInteger(section.entrySegmentIndex) then
        errors[#errors + 1] = "entry segment index is invalid: "
          .. tostring(section.id)
      elseif section.entrySegmentIndex > finalSegmentIndex then
        errors[#errors + 1] = "entry segment index exceeds the global route: "
          .. tostring(section.id)
      end

      if not isInteger(section.exitSegmentIndex) then
        errors[#errors + 1] = "exit segment index is invalid: "
          .. tostring(section.id)
      elseif section.exitSegmentIndex > finalSegmentIndex then
        errors[#errors + 1] = "exit segment index exceeds the global route: "
          .. tostring(section.id)
      end

      if isInteger(section.entrySegmentIndex)
        and isInteger(section.exitSegmentIndex)
        and section.exitSegmentIndex < section.entrySegmentIndex then
        errors[#errors + 1] = "reveal exit precedes reveal entry on the global route: "
          .. tostring(section.id)
      end

      if previousExitSegmentIndex ~= nil
        and isInteger(section.entrySegmentIndex)
        and section.entrySegmentIndex < previousExitSegmentIndex then
        errors[#errors + 1] = "reveal sections are not ordered on the global route: "
          .. tostring(section.id)
      end

      if sectionIndex == 1 and section.entrySegmentIndex ~= 0 then
        errors[#errors + 1] = "the first reveal section must materialize at segment 0, ZONE_TM01_START_BAGRAM"
      end

      if isInteger(section.exitSegmentIndex) then
        previousExitSegmentIndex = section.exitSegmentIndex
      end
    end
  end

  if config.virtualization.initialSectionIndex ~= 1 then
    errors[#errors + 1] = "initialSectionIndex must be 1 for TM01B.1"
  end
  if type(config.zones.revealSections) == "table"
    and config.virtualization.finalSectionIndex ~= #config.zones.revealSections then
    errors[#errors + 1] = "finalSectionIndex must reference the last reveal section"
  end
  if config.template.expectedVehicleCount ~= 6 then
    errors[#errors + 1] = "TM01B.1 expects exactly six configured vehicle slots"
  end
  if config.virtualization.automaticAdvance ~= false
    or config.virtualization.automaticMaterialization ~= false
    or config.virtualization.automaticDematerialization ~= false then
    errors[#errors + 1] = "TM01B.1 automatic transitions must remain disabled"
  end
  if type(config.virtualization.destroyConfirmationPollSeconds) ~= "number"
    or config.virtualization.destroyConfirmationPollSeconds <= 0 then
    errors[#errors + 1] = "destroy confirmation poll interval must be positive"
  end
  if type(config.virtualization.destroyConfirmationTimeoutSeconds) ~= "number"
    or config.virtualization.destroyConfirmationTimeoutSeconds
      <= config.virtualization.destroyConfirmationPollSeconds then
    errors[#errors + 1] = "destroy confirmation timeout must exceed the poll interval"
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
    local ok, result = pcall(validateConfiguration, config)
    if not ok then
      setOutcome(OUTCOME_FAIL_SCRIPT, "configuration validation raised an error")
      logger:error("configuration_validation_error", { error = result })
      return false
    end

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
      globalRouteStart = config.zones.start,
      globalRouteAnchorCount = #config.zones.routeAnchors,
      globalRoutePointCount = #config.zones.routeAnchors + 2,
      globalRouteTarget = config.zones.target,
      revealSectionCount = #config.zones.revealSections,
      revealZonesAreWaypoints = false,
      revealZonesDetermineSpawn = false,
    })
    setOutcome(OUTCOME_READY, "TM01B global-route and reveal-window configuration completed")
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

  logger:info("native_api_validation_passed", {
    baselineNativeApiCount = 3,
    tm01bAdditionalNativeApiCount = 2,
  })

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

  logger:info("moose_api_validation_passed", {
    baselineMooseApiCount = 13,
    tm01bAdditionalApiCount = 4,
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
  local cacheControllerOk, cacheControllerOrError = pcall(function()
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
  if not cacheControllerOk or type(cacheControllerOrError) ~= "table" then
    setOutcome(OUTCOME_FAIL_SCRIPT, "cache controller initialization failed")
    logger:error("cache_controller_initialization_failed", {
      error = cacheControllerOk
        and "ConvoyCacheController.new returned no table"
        or cacheControllerOrError,
    })
    return state
  end

  local cacheController = cacheControllerOrError

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
      "Show status",
      testMenu,
      protectMenuCallback("Show status", showStatus)
    )
    MENU_MISSION_COMMAND:New(
      "Validate configuration",
      testMenu,
      protectMenuCallback("Validate configuration", validateFromMenu)
    )
    MENU_MISSION_COMMAND:New(
      "Materialize convoy",
      testMenu,
      protectMenuCallback("Materialize convoy", function()
        cacheController:materialize()
      end)
    )
    MENU_MISSION_COMMAND:New(
      "Start physical route",
      testMenu,
      protectMenuCallback("Start physical route", function()
        cacheController:startPhysicalRoute()
      end)
    )
    MENU_MISSION_COMMAND:New(
      "Dematerialize convoy",
      testMenu,
      protectMenuCallback("Dematerialize convoy", function()
        cacheController:dematerialize()
      end)
    )
    MENU_MISSION_COMMAND:New(
      "Advance virtual convoy",
      testMenu,
      protectMenuCallback("Advance virtual convoy", function()
        cacheController:advanceVirtual()
      end)
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
  logger:info("menu_ready", { path = "OMW Tests / " .. build.stageId })

  return state
end

return TM01B
