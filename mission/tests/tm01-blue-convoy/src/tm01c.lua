local TM01C = {}

local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"

local function join(values)
  return #(values or {}) > 0 and table.concat(values, ",") or "none"
end

local function validateFunction(path, getter, missing)
  local ok, value = pcall(getter)
  if not ok or type(value) ~= "function" then
    missing[#missing + 1] = path
  end
end

local function validateNativeApis()
  local missing = {}
  validateFunction("timer.scheduleFunction", function()
    return timer and timer.scheduleFunction
  end, missing)
  validateFunction("Group.getByName", function()
    return Group and Group.getByName
  end, missing)
  validateFunction("land.getSurfaceType", function()
    return land and land.getSurfaceType
  end, missing)
  if type(land) ~= "table" or type(land.SurfaceType) ~= "table" then
    missing[#missing + 1] = "land.SurfaceType"
  else
    if land.SurfaceType.WATER == nil then
      missing[#missing + 1] = "land.SurfaceType.WATER"
    end
    if land.SurfaceType.SHALLOW_WATER == nil then
      missing[#missing + 1] = "land.SurfaceType.SHALLOW_WATER"
    end
  end
  return #missing == 0, missing
end

local function validateMooseApis()
  local missing = {}
  validateFunction("GROUP.GetUnits", function()
    return GROUP and GROUP.GetUnits
  end, missing)
  validateFunction("GROUP.CountAliveUnits", function()
    return GROUP and GROUP.CountAliveUnits
  end, missing)
  validateFunction("GROUP.IsCompletelyInZone", function()
    return GROUP and GROUP.IsCompletelyInZone
  end, missing)
  validateFunction("POSITIONABLE.Destroy", function()
    return POSITIONABLE and POSITIONABLE.Destroy
  end, missing)
  validateFunction("POSITIONABLE.GetVec2", function()
    return POSITIONABLE and POSITIONABLE.GetVec2
  end, missing)
  validateFunction("POSITIONABLE.GetTypeName", function()
    return POSITIONABLE and POSITIONABLE.GetTypeName
  end, missing)
  validateFunction("SPAWN.NewWithAlias", function()
    return SPAWN and SPAWN.NewWithAlias
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
  validateFunction("ZONE_BASE.GetCoordinate", function()
    return ZONE_BASE and ZONE_BASE.GetCoordinate
  end, missing)
  validateFunction("ZONE_BASE.IsVec2InZone", function()
    return ZONE_BASE and ZONE_BASE.IsVec2InZone
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

  checkGroup(config.template.groupName)
  checkZone(config.zones.start)
  checkZone(config.zones.target)

  if type(config.zones.routeAnchors) ~= "table" or #config.zones.routeAnchors ~= 7 then
    errors[#errors + 1] = "TM01C requires exactly seven route anchors"
  else
    for _, zoneName in ipairs(config.zones.routeAnchors) do
      checkZone(zoneName)
    end
  end

  if config.template.expectedVehicleCount ~= 6 then
    errors[#errors + 1] = "TM01C expects exactly six original stable vehicle slots"
  end

  local slotOrder = config.template.slotOrderRearToFront
  if type(slotOrder) ~= "table" or #slotOrder ~= config.template.expectedVehicleCount then
    errors[#errors + 1] = "slotOrderRearToFront must contain all six slots"
  else
    local seen = {}
    for _, slot in ipairs(slotOrder) do
      if type(slot) ~= "number"
        or slot < 1
        or slot > config.template.expectedVehicleCount
        or seen[slot] then
        errors[#errors + 1] = "slotOrderRearToFront is not a unique 1..6 permutation"
        break
      end
      seen[slot] = true
    end
  end

  local positiveSettings = {
    { config.routing.speedKph, "speedKph" },
    { config.routing.routeSampleMeters, "routeSampleMeters" },
    { config.routing.maximumRoadSnapMeters, "maximumRoadSnapMeters" },
    { config.routing.roadPositionToleranceMeters, "roadPositionToleranceMeters" },
    { config.routing.vehicleSpacingMeters, "vehicleSpacingMeters" },
    { config.routing.minimumVehicleSeparationMeters, "minimumVehicleSeparationMeters" },
    { config.transitions.pollSeconds, "pollSeconds" },
    { config.transitions.markerUpdateSeconds, "markerUpdateSeconds" },
    { config.transitions.destroyConfirmationPollSeconds, "destroyConfirmationPollSeconds" },
    { config.transitions.destroyConfirmationTimeoutSeconds, "destroyConfirmationTimeoutSeconds" },
  }
  for _, setting in ipairs(positiveSettings) do
    if not positiveNumber(setting[1]) then
      errors[#errors + 1] = setting[2] .. " must be positive"
    end
  end

  if type(config.routing.unpackLeadOffsetCandidatesMeters) ~= "table"
    or #config.routing.unpackLeadOffsetCandidatesMeters < 1
    or config.routing.unpackLeadOffsetCandidatesMeters[1] ~= 0 then
    errors[#errors + 1] = "unpack lead offsets must start with exact position offset 0"
  end

  if config.routing.roadOnly ~= true or config.routing.formation ~= "ON_ROAD" then
    errors[#errors + 1] = "TM01C requires road-only ON_ROAD routing"
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

function TM01C.start(dependencies)
  local config = dependencies.config
  local build = dependencies.build
  local state = {
    outcome = OUTCOME_FAIL_SCRIPT,
    detail = "bootstrap not completed",
    checkedObjectCount = 0,
  }

  local baseNativeOk, baseNativeMissing = dependencies.runtimeGuard.validateNative()
  if not baseNativeOk then
    dependencies.safeReporter.report(
      "native_api_validation_failed",
      OUTCOME_FAIL_SCRIPT,
      "missing=" .. join(baseNativeMissing),
      "[OMW][TM01C]"
    )
    state.detail = "required baseline native APIs are unavailable"
    return state
  end

  local logger = dependencies.structuredLogger.new("[OMW][TM01C]")

  local function announce(text)
    trigger.action.outText("[OMW][TM01C] " .. text, 15, false)
  end

  local function setOutcome(outcome, detail)
    state.outcome = outcome
    state.detail = detail
    logger:info("bootstrap_outcome", {
      outcome = outcome,
      detail = detail,
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
        errors = join(result.errors),
        checkedObjectCount = result.checkedObjectCount,
      })
      return false
    end
    if not result.valid then
      setOutcome(OUTCOME_FAIL_CONFIGURATION, "required Mission Editor objects are missing")
      logger:error("configuration_invalid", {
        missing = join(result.missing),
        checkedObjectCount = result.checkedObjectCount,
      })
      return false
    end

    logger:info("configuration_valid", {
      configurationVersion = config.configurationVersion,
      routeAnchorCount = #config.zones.routeAnchors,
      revealWindowCount = 0,
      manualPackUnpack = true,
      expectedVehicleCount = config.template.expectedVehicleCount,
      checkedObjectCount = result.checkedObjectCount,
    })
    setOutcome(OUTCOME_READY, "TM01C manual proxy pack/unpack test is ready")
    return true
  end

  local function protectMenuCallback(commandName, callback)
    return function()
      local ok, callbackError = pcall(callback)
      if not ok then
        logger:error("menu_callback_failed", {
          command = commandName,
          error = callbackError,
        })
        announce("Menu command failed: " .. commandName)
      end
    end
  end

  logger:info("startup", {
    testId = build.testId,
    stageId = build.stageId,
    configurationVersion = build.configurationVersion,
    buildTimestamp = build.buildTimestamp,
    expectedMooseVersion = build.expectedMooseVersion,
    expectedMooseFileSha256 = build.expectedMooseFileSha256,
    expectedMooseBuildCommit = build.expectedMooseBuildCommit,
    expectedMooseBuildTimestamp = build.expectedMooseBuildTimestamp,
    expectedMooseIncludeFamily = build.expectedMooseIncludeFamily,
    expectedMooseCompression = build.expectedMooseCompression,
    mooseVerificationMode = build.mooseVerificationMode,
    dcsVersion = tostring(_G.DCS_VERSION or _G._DCS_VERSION or "unavailable"),
    missionTimeSeconds = timer.getTime(),
  })

  local nativeOk, nativeMissing = validateNativeApis()
  if not nativeOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required TM01C native APIs are unavailable")
    logger:error("tm01c_native_api_validation_failed", { missing = join(nativeMissing) })
    return state
  end

  local baseMooseOk, baseMooseMissing = dependencies.runtimeGuard.validateMoose()
  if not baseMooseOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required baseline MOOSE APIs are unavailable")
    logger:error("moose_api_validation_failed", { missing = join(baseMooseMissing) })
    return state
  end

  local mooseOk, mooseMissing = validateMooseApis()
  if not mooseOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required TM01C MOOSE APIs are unavailable")
    logger:error("tm01c_moose_api_validation_failed", { missing = join(mooseMissing) })
    return state
  end

  if not runConfigurationValidation() then
    return state
  end

  local campaignStateOk, campaignStateOrError = pcall(function()
    return dependencies.proxyCampaignState.new(config)
  end)
  if not campaignStateOk or type(campaignStateOrError) ~= "table" then
    setOutcome(OUTCOME_FAIL_SCRIPT, "CampaignState initialization failed")
    logger:error("campaign_state_initialization_failed", {
      error = campaignStateOk and "state factory returned no table" or campaignStateOrError,
    })
    return state
  end

  local controllerOk, controllerOrError = pcall(function()
    return dependencies.convoyProxyController.new({
      announce = announce,
      campaignState = campaignStateOrError,
      config = config,
      getBootstrapOutcome = function()
        return state.outcome
      end,
      logger = logger,
    })
  end)
  if not controllerOk or type(controllerOrError) ~= "table" then
    setOutcome(OUTCOME_FAIL_SCRIPT, "proxy controller initialization failed")
    logger:error("proxy_controller_initialization_failed", {
      error = controllerOk and "controller factory returned no table" or controllerOrError,
    })
    return state
  end

  local controller = controllerOrError

  local function showStatus()
    logger:info("status_requested", {
      outcome = state.outcome,
      detail = state.detail,
      checkedObjectCount = state.checkedObjectCount,
    })
    announce("Outcome: " .. state.outcome .. "\nDetail: " .. state.detail)
    controller:showStatus()
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
        controller:start()
      end)
    )
    MENU_MISSION_COMMAND:New(
      "Pack convoy",
      testMenu,
      protectMenuCallback("Pack convoy", function()
        controller:pack()
      end)
    )
    MENU_MISSION_COMMAND:New(
      "Unpack convoy",
      testMenu,
      protectMenuCallback("Unpack convoy", function()
        controller:unpack(false)
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
    return { root = rootMenu, test = testMenu }
  end)

  if not menuOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "F10 menu creation failed")
    logger:error("menu_creation_failed", { error = menuOrError })
    return state
  end

  state.menu = menuOrError
  state.campaignState = campaignStateOrError
  state.proxyController = controller
  logger:info("menu_ready", {
    path = "OMW Tests / " .. build.stageId,
    commands = "Start convoy,Pack convoy,Unpack convoy,Show status,Validate configuration",
  })
  return state
end

return TM01C
