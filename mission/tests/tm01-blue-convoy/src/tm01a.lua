local TM01A = {}

local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"

local function join(values)
  if #values == 0 then
    return "none"
  end

  return table.concat(values, ",")
end

function TM01A.start(dependencies)
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
      "missing=" .. join(missingNativeApis)
    )
    return state
  end

  local logger = dependencies.structuredLogger.new("[OMW][TM01A]")

  local function announce(text)
    trigger.action.outText("[OMW][TM01A] " .. text, 15, false)
  end

  local function setOutcome(outcome, detail)
    state.outcome = outcome
    state.detail = detail
    logger:info("bootstrap_outcome", {
      detail = detail,
      outcome = outcome,
    })
  end

  local function validateConfiguration()
    local ok, result = pcall(dependencies.configurationValidator.validate, config)

    if not ok then
      setOutcome(OUTCOME_FAIL_SCRIPT, "configuration validation raised an error")
      logger:error("configuration_validation_error", { error = result })
      return
    end

    state.checkedObjectCount = result.checkedObjectCount

    if #result.errors > 0 then
      setOutcome(OUTCOME_FAIL_SCRIPT, "Mission Editor object lookup failed")
      logger:error("configuration_lookup_error", { errors = join(result.errors) })
      return
    end

    if not result.valid then
      setOutcome(OUTCOME_FAIL_CONFIGURATION, "required Mission Editor objects are missing")
      logger:error("configuration_invalid", {
        checkedObjectCount = result.checkedObjectCount,
        missing = join(result.missing),
      })
      return
    end

    logger:info("configuration_valid", {
      checkedObjectCount = result.checkedObjectCount,
      revealZonesRequired = false,
    })
    setOutcome(OUTCOME_READY, "bootstrap validation completed")
  end

  local function showStatus()
    local text = "Outcome: " .. state.outcome .. "\nDetail: " .. state.detail
    logger:info("status_requested", {
      checkedObjectCount = state.checkedObjectCount,
      detail = state.detail,
      outcome = state.outcome,
    })
    announce(text)
  end

  local function validateFromMenu()
    validateConfiguration()
    showStatus()
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

  logger:info("native_api_validation_passed", { nativeApiCount = 3 })

  local mooseValid, missingMooseApis = dependencies.runtimeGuard.validateMoose()
  if not mooseValid then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required MOOSE APIs are unavailable")
    logger:error("moose_api_validation_failed", { missing = join(missingMooseApis) })
    return state
  end

  logger:info("moose_api_validation_passed", {
    mooseApiCount = 10,
  })

  local convoyController = dependencies.physicalConvoyController.new({
    announce = announce,
    config = config,
    getBootstrapOutcome = function()
      return state.outcome
    end,
    logger = logger,
  })

  local menuOk, menuOrError = pcall(dependencies.testMenu.create, {
    stageId = build.stageId,
    onShowStatus = protectMenuCallback("Show status", showStatus),
    onValidateConfiguration = protectMenuCallback(
      "Validate configuration",
      validateFromMenu
    ),
    onSpawnConvoy = protectMenuCallback("Spawn convoy", function()
      convoyController:requestSpawn()
    end),
    onShowConvoyStatus = protectMenuCallback("Show convoy status", function()
      convoyController:showStatus()
    end),
  })

  if not menuOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "F10 menu creation failed")
    logger:error("menu_creation_failed", { error = menuOrError })
    return state
  end

  state.menu = menuOrError
  state.convoyController = convoyController
  logger:info("menu_ready", { path = "OMW Tests / " .. build.stageId })
  validateConfiguration()

  return state
end

return TM01A
