local TM02A = {}

local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"

local function join(values)
  if #values == 0 then
    return "none"
  end
  return table.concat(values, ",")
end

function TM02A.start(dependencies)
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
      "[OMW][TM02A]"
    )
    return state
  end

  local logger = dependencies.structuredLogger.new("[OMW][TM02A]")

  local function announce(text)
    trigger.action.outText("[OMW][TM02A] " .. text, 20, false)
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
      return false
    end

    state.checkedObjectCount = result.checkedObjectCount
    if #result.errors > 0 then
      setOutcome(OUTCOME_FAIL_SCRIPT, "Mission Editor object lookup failed")
      logger:error("configuration_lookup_error", { errors = join(result.errors) })
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
      destinationNodeId = config.transfer.destinationNodeId,
      fighterCount = config.movement.fighterCount,
      routeAnchorCount = #config.zones.routeAnchors,
      sourceNodeId = config.transfer.sourceNodeId,
      virtualRepresentationAllowed = config.policy.allowVirtualRepresentation,
    })
    setOutcome(OUTCOME_READY, "TM02A configuration validation completed")
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
  logger:info("native_api_validation_passed", { nativeApiCount = 3 })

  local mooseValid, missingMooseApis = dependencies.runtimeGuard.validateMoose()
  if not mooseValid then
    setOutcome(OUTCOME_FAIL_SCRIPT, "required MOOSE APIs are unavailable")
    logger:error("moose_api_validation_failed", { missing = join(missingMooseApis) })
    return state
  end
  logger:info("moose_api_validation_passed", { mooseApiCount = 19 })

  local campaignStateOk, campaignStateOrError = pcall(
    dependencies.inMemoryRedCampaignState.new,
    {
      config = config,
      logger = logger,
    }
  )
  if not campaignStateOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "CampaignState initialization failed")
    logger:error("campaign_state_initialization_failed", {
      error = campaignStateOrError,
    })
    return state
  end
  local campaignState = campaignStateOrError

  local relayController = dependencies.physicalRelayController.new({
    announce = announce,
    campaignState = campaignState,
    config = config,
    getBootstrapOutcome = function()
      return state.outcome
    end,
    logger = logger,
  })

  local function showRelayStatus()
    local snapshot = campaignState:getStatusSnapshot()
    local source = snapshot.nodes[config.transfer.sourceNodeId]
    local destination = snapshot.nodes[config.transfer.destinationNodeId]
    local movement = snapshot.movement
    local accountingValid, accountedPersonnel, initialPersonnel =
      campaignState:validatePersonnelAccounting()

    logger:info("red_relay_status", {
      accountedPersonnel = accountedPersonnel,
      accountingValid = accountingValid,
      activeMovementId = snapshot.activeMovementId or "none",
      destinationAvailableSurplus = destination.availableSurplus,
      destinationGarrisonAlive = destination.garrisonAlive,
      destinationMinimumGarrison = destination.minimumGarrison,
      initialPersonnel = initialPersonnel,
      movementState = movement and movement.movementState or "NONE",
      sourceAvailableSurplus = source.availableSurplus,
      sourceGarrisonAlive = source.garrisonAlive,
      sourceMinimumGarrison = source.minimumGarrison,
      transferAttempted = snapshot.transferAttempted,
    })

    announce(
      "Source " .. source.nodeId
        .. ": " .. source.garrisonAlive
        .. " alive, minimum " .. source.minimumGarrison
        .. ", surplus " .. source.availableSurplus
        .. "\nDestination " .. destination.nodeId
        .. ": " .. destination.garrisonAlive
        .. " alive, minimum " .. destination.minimumGarrison
        .. ", surplus " .. destination.availableSurplus
        .. "\nMovement: " .. (movement and movement.movementState or "NONE")
        .. "\nPersonnel accounting valid: " .. tostring(accountingValid)
    )
  end

  local function validateFromMenu()
    validateConfiguration()
    announce("Outcome: " .. state.outcome .. "\nDetail: " .. state.detail)
  end

  local menuOk, menuOrError = pcall(dependencies.tm02aMenu.create, {
    onShowActiveMovement = protectMenuCallback(
      "Show active movement",
      function()
        relayController:showActiveMovement()
      end
    ),
    onShowRelayStatus = protectMenuCallback(
      "Show RED relay status",
      showRelayStatus
    ),
    onStartTransfer = protectMenuCallback(
      "Start one relay transfer",
      function()
        relayController:startOneTransfer()
      end
    ),
    onValidateConfiguration = protectMenuCallback(
      "Validate configuration",
      validateFromMenu
    ),
  })
  if not menuOk then
    setOutcome(OUTCOME_FAIL_SCRIPT, "F10 menu creation failed")
    logger:error("menu_creation_failed", { error = menuOrError })
    return state
  end

  state.menu = menuOrError
  state.campaignState = campaignState
  state.relayController = relayController
  logger:info("menu_ready", { path = "OMW Tests / TM02A" })
  validateConfiguration()
  return state
end

return TM02A
