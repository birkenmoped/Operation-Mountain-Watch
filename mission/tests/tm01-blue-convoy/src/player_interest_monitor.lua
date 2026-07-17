local PlayerInterestMonitor = {}

local REPRESENTATION_EXPANDED = "EXPANDED"
local REPRESENTATION_COLLAPSED = "COLLAPSED_PROXY"
local TRANSITION_IDLE = "IDLE"

local BAND_UNKNOWN = "UNKNOWN"
local BAND_INSIDE = "INSIDE_UNPACK"
local BAND_HYSTERESIS = "HYSTERESIS"
local BAND_OUTSIDE = "OUTSIDE"

local function positiveNumber(value)
  return type(value) == "number" and value > 0
end

local function distance2d(left, right)
  local dx = right.x - left.x
  local dy = right.y - left.y
  return math.sqrt(dx * dx + dy * dy)
end

local function parseRuntimeIndex(unitName)
  if type(unitName) ~= "string" then
    return nil
  end
  local suffix = string.match(unitName, "%-(%d+)$")
  return suffix and tonumber(suffix) or nil
end

local function safeNativeField(unit, methodName, fallback)
  local lookupOk, method = pcall(function()
    return unit and unit[methodName]
  end)
  if not lookupOk or type(method) ~= "function" then
    return fallback
  end
  local ok, valueOrError = pcall(method, unit)
  if not ok then
    return fallback
  end
  return valueOrError
end

function PlayerInterestMonitor.attach(options)
  local controller = options.controller
  local config = options.config
  local logger = options.logger
  local announce = options.announce

  if type(controller) ~= "table"
    or type(controller.tick) ~= "function"
    or type(controller.pack) ~= "function"
    or type(controller.unpack) ~= "function"
    or type(controller.getState) ~= "function" then
    error("player interest monitor requires a complete convoy controller")
  end
  if type(logger) ~= "table"
    or type(logger.info) ~= "function"
    or type(logger.error) ~= "function" then
    error("player interest monitor requires a structured logger")
  end
  if type(announce) ~= "function" then
    error("player interest monitor requires an announce callback")
  end

  local interestConfig = config.playerInterest or {}
  local enabled = interestConfig.enabled == true
  local unpackRadiusMeters = interestConfig.unpackRadiusMeters or 500
  local packRadiusMeters = interestConfig.packRadiusMeters or 750
  local packDelaySeconds = interestConfig.packDelaySeconds or 30
  local retrySeconds = interestConfig.retrySeconds or 5

  if enabled then
    local positiveSettings = {
      { unpackRadiusMeters, "playerInterest.unpackRadiusMeters" },
      { packRadiusMeters, "playerInterest.packRadiusMeters" },
      { packDelaySeconds, "playerInterest.packDelaySeconds" },
      { retrySeconds, "playerInterest.retrySeconds" },
    }
    for _, setting in ipairs(positiveSettings) do
      if not positiveNumber(setting[1]) then
        error(setting[2] .. " must be a positive number")
      end
    end
    if unpackRadiusMeters >= packRadiusMeters then
      error("playerInterest.unpackRadiusMeters must be smaller than packRadiusMeters")
    end
    if type(coalition) ~= "table" or type(coalition.getPlayers) ~= "function" then
      error("coalition.getPlayers is unavailable")
    end
    if type(coalition.side) ~= "table" or type(coalition.side.BLUE) ~= "number" then
      error("coalition.side.BLUE is unavailable")
    end
  end

  local monitor = {
    enabled = enabled,
    failed = false,
    failureReason = nil,
    band = BAND_UNKNOWN,
    nearestPlayerDistanceMeters = nil,
    nearestPlayerName = nil,
    nearestPlayerUnitName = nil,
    nearestPlayerUnitType = nil,
    observedPlayerCount = 0,
    validPlayerCount = 0,
    packTimerStartedAt = nil,
    lastAutomaticUnpackRequestAt = nil,
  }

  local function updateEntity(changes)
    if type(controller.campaignState) ~= "table"
      or type(controller.campaignState.updateEntity) ~= "function" then
      return
    end
    controller.entity = controller.campaignState:updateEntity(config.scenarioId, changes)
  end

  local function commonFields(extra)
    local state = controller:getState() or {}
    local fields = {
      entityId = state.entityId or config.scenarioId,
      routeId = state.routeId or config.routeId,
      representationState = state.representationState or "unknown",
      transitionState = state.transitionState or "unknown",
      movementState = state.movementState or "unknown",
      runtimeGroupName = state.runtimeGroupName or "none",
      runtimeGeneration = state.runtimeGeneration or 0,
      playerInterestEnabled = monitor.enabled,
      playerInterestFailed = monitor.failed,
      playerInterestBand = monitor.band,
      nearestPlayerDistanceMeters = monitor.nearestPlayerDistanceMeters or "none",
      nearestPlayerName = monitor.nearestPlayerName or "none",
      nearestPlayerUnitName = monitor.nearestPlayerUnitName or "none",
      nearestPlayerUnitType = monitor.nearestPlayerUnitType or "none",
      observedBluePlayerCount = monitor.observedPlayerCount,
      validBluePlayerCount = monitor.validPlayerCount,
      automaticPackTimerStartedAt = monitor.packTimerStartedAt or "none",
      missionTimeSeconds = timer.getTime(),
    }
    for key, value in pairs(extra or {}) do
      fields[key] = value
    end
    return fields
  end

  local function logInfo(event, extra)
    logger:info(event, commonFields(extra))
  end

  local function logError(event, reason, extra)
    local fields = commonFields(extra)
    fields.reason = tostring(reason)
    logger:error(event, fields)
  end

  local function markFailed(reason)
    if monitor.failed then
      return
    end
    monitor.failed = true
    monitor.failureReason = tostring(reason)
    monitor.packTimerStartedAt = nil
    updateEntity({
      playerInterestMonitorState = "FAILED",
      clearFields = { "automaticPackTimerStartedAt" },
    })
    logError("player_interest_monitor_failed", reason)
    announce("Automatic player relevance disabled\n" .. tostring(reason))
  end

  local function currentLeadUnit()
    local state = controller:getState()
    if type(state) ~= "table" then
      return nil, "convoy state snapshot is unavailable"
    end
    local group = controller.runtimeGroup
    if type(group) ~= "table" or type(group.GetUnits) ~= "function" then
      return nil, "runtime group is unavailable"
    end

    local unitsOk, unitsOrError = pcall(function()
      return group:GetUnits()
    end)
    if not unitsOk or type(unitsOrError) ~= "table" then
      return nil, unitsOk and "runtime units are unavailable" or unitsOrError
    end

    local fallback = nil
    for _, unit in pairs(unitsOrError) do
      local aliveOk, alive = pcall(function()
        return unit and unit:IsAlive() == true
      end)
      if aliveOk and alive then
        fallback = fallback or unit
        local nameOk, unitName = pcall(function()
          return unit:GetName()
        end)
        local runtimeIndex = nameOk and parseRuntimeIndex(unitName) or nil
        local stableSlot = runtimeIndex
          and state.runtimeIndexToStableSlot
          and state.runtimeIndexToStableSlot[runtimeIndex]
          or nil
        if stableSlot == state.currentLeadSlot then
          return unit, nil
        end
      end
    end

    if state.representationState == REPRESENTATION_COLLAPSED and fallback then
      return fallback, nil
    end
    return nil, "current lead unit is unavailable"
  end

  local function nearestBluePlayerTo(convoyVec2)
    local playersOk, playersOrError = pcall(function()
      return coalition.getPlayers(coalition.side.BLUE)
    end)
    if not playersOk then
      return nil, playersOrError
    end
    if type(playersOrError) ~= "table" then
      return nil, "coalition.getPlayers did not return a table"
    end

    local nearest = nil
    local observedCount = 0
    local validCount = 0

    for _, unit in pairs(playersOrError) do
      observedCount = observedCount + 1
      local exists = safeNativeField(unit, "isExist", false) == true
      local life = safeNativeField(unit, "getLife", 0)
      local playerName = safeNativeField(unit, "getPlayerName", nil)
      local point = safeNativeField(unit, "getPoint", nil)

      if exists
        and type(life) == "number"
        and life > 0
        and type(playerName) == "string"
        and playerName ~= ""
        and type(point) == "table"
        and type(point.x) == "number"
        and type(point.z) == "number" then
        validCount = validCount + 1
        local distanceMeters = distance2d(convoyVec2, { x = point.x, y = point.z })
        if not nearest or distanceMeters < nearest.distanceMeters then
          nearest = {
            distanceMeters = distanceMeters,
            playerName = playerName,
            unitName = safeNativeField(unit, "getName", "unknown"),
            unitType = safeNativeField(unit, "getTypeName", "unknown"),
          }
        end
      end
    end

    return {
      nearest = nearest,
      observedCount = observedCount,
      validCount = validCount,
    }, nil
  end

  local function bandForDistance(distanceMeters)
    if type(distanceMeters) ~= "number" then
      return BAND_OUTSIDE
    end
    if distanceMeters <= unpackRadiusMeters then
      return BAND_INSIDE
    end
    if distanceMeters <= packRadiusMeters then
      return BAND_HYSTERESIS
    end
    return BAND_OUTSIDE
  end

  local function observationFields(observation, previousBand, newBand)
    local nearest = observation.nearest
    return {
      previousBand = previousBand or BAND_UNKNOWN,
      newBand = newBand,
      nearestPlayerDistanceMeters = nearest and nearest.distanceMeters or "none",
      nearestPlayerName = nearest and nearest.playerName or "none",
      nearestPlayerUnitName = nearest and nearest.unitName or "none",
      nearestPlayerUnitType = nearest and nearest.unitType or "none",
      observedBluePlayerCount = observation.observedCount,
      validBluePlayerCount = observation.validCount,
      unpackRadiusMeters = unpackRadiusMeters,
      packRadiusMeters = packRadiusMeters,
      packDelaySeconds = packDelaySeconds,
    }
  end

  local function applyObservation(observation, newBand)
    local nearest = observation.nearest
    local previousBand = monitor.band

    monitor.nearestPlayerDistanceMeters = nearest and nearest.distanceMeters or nil
    monitor.nearestPlayerName = nearest and nearest.playerName or nil
    monitor.nearestPlayerUnitName = nearest and nearest.unitName or nil
    monitor.nearestPlayerUnitType = nearest and nearest.unitType or nil
    monitor.observedPlayerCount = observation.observedCount
    monitor.validPlayerCount = observation.validCount

    if previousBand == newBand then
      return
    end

    monitor.band = newBand
    updateEntity({ playerInterestBand = newBand })
    local fields = observationFields(observation, previousBand, newBand)
    logInfo("player_relevance_band_changed", fields)
    if previousBand ~= BAND_UNKNOWN and newBand == BAND_INSIDE then
      logInfo("player_relevance_entered", fields)
    elseif previousBand ~= BAND_UNKNOWN and newBand == BAND_OUTSIDE then
      logInfo("player_relevance_exited", fields)
    end
  end

  local function clearPackTimer(reason, observation, logCancellation)
    if not monitor.packTimerStartedAt then
      return
    end
    local startedAt = monitor.packTimerStartedAt
    monitor.packTimerStartedAt = nil
    updateEntity({ clearFields = { "automaticPackTimerStartedAt" } })
    if logCancellation then
      local fields = observationFields(observation, monitor.band, monitor.band)
      fields.reason = reason
      fields.timerElapsedSeconds = timer.getTime() - startedAt
      logInfo("automatic_pack_timer_cancelled", fields)
    end
  end

  local function service()
    if not monitor.enabled or monitor.failed then
      return true
    end

    local state = controller:getState()
    if type(state) ~= "table"
      or state.transitionState ~= TRANSITION_IDLE
      or (state.representationState ~= REPRESENTATION_EXPANDED
        and state.representationState ~= REPRESENTATION_COLLAPSED) then
      return true
    end

    local leadUnit, leadError = currentLeadUnit()
    if not leadUnit then
      return false, leadError
    end
    local vecOk, convoyVecOrError = pcall(function()
      return leadUnit:GetVec2()
    end)
    if not vecOk or type(convoyVecOrError) ~= "table" then
      return false, vecOk and "convoy lead position is unavailable" or convoyVecOrError
    end

    local observation, playerError = nearestBluePlayerTo(convoyVecOrError)
    if not observation then
      return false, playerError
    end
    local nearest = observation.nearest
    local newBand = bandForDistance(nearest and nearest.distanceMeters or nil)
    applyObservation(observation, newBand)

    local now = timer.getTime()
    if state.representationState == REPRESENTATION_EXPANDED then
      monitor.lastAutomaticUnpackRequestAt = nil
      if newBand ~= BAND_OUTSIDE then
        clearPackTimer("player returned inside pack boundary", observation, true)
        return true
      end

      if not monitor.packTimerStartedAt then
        monitor.packTimerStartedAt = now
        updateEntity({ automaticPackTimerStartedAt = now })
        local fields = observationFields(observation, newBand, newBand)
        fields.timerStartedAt = now
        logInfo("automatic_pack_timer_started", fields)
        return true
      end

      local elapsed = now - monitor.packTimerStartedAt
      if elapsed < packDelaySeconds then
        return true
      end

      local fields = observationFields(observation, newBand, newBand)
      fields.timerElapsedSeconds = elapsed
      logInfo("automatic_pack_requested", fields)
      clearPackTimer("automatic pack requested", observation, false)
      local requested = controller:pack()
      if requested and controller.pendingPack then
        controller.pendingPack.automaticPlayerInterest = true
      elseif not requested and not controller.halted then
        monitor.packTimerStartedAt = now
        updateEntity({ automaticPackTimerStartedAt = now })
        logInfo("automatic_pack_request_failed", fields)
      end
      if requested or not controller.halted then
        return true
      end
      return false, "automatic pack request halted the convoy controller"
    end

    clearPackTimer("convoy is not expanded", observation, false)
    if state.representationState == REPRESENTATION_COLLAPSED and newBand == BAND_INSIDE then
      local lastRequestAt = monitor.lastAutomaticUnpackRequestAt
      if lastRequestAt and now - lastRequestAt < retrySeconds then
        return true
      end

      monitor.lastAutomaticUnpackRequestAt = now
      local fields = observationFields(observation, newBand, newBand)
      fields.retrySeconds = retrySeconds
      logInfo("automatic_unpack_requested", fields)
      local requested = controller:unpack(false)
      if requested and controller.pendingUnpack then
        controller.pendingUnpack.automaticPlayerInterest = true
      elseif not requested then
        logInfo("automatic_unpack_request_failed", fields)
      end
      if requested or not controller.halted then
        return true
      end
      return false, "automatic unpack request halted the convoy controller"
    end

    return true
  end

  local originalTick = controller.tick
  controller.tick = function(self)
    local originalResult = originalTick(self)
    if originalResult == false or self.halted then
      return originalResult
    end
    local callOk, serviceOk, serviceError = pcall(service)
    if not callOk then
      markFailed(serviceOk)
      return originalResult
    end
    if serviceOk == false then
      markFailed(serviceError or "player relevance service returned false")
    end
    return originalResult
  end

  local originalShowStatus = controller.showStatus
  controller.showStatus = function(self)
    originalShowStatus(self)
    local remaining = "none"
    if monitor.packTimerStartedAt then
      remaining = math.max(0, packDelaySeconds - (timer.getTime() - monitor.packTimerStartedAt))
    end
    logInfo("player_interest_status", {
      failureReason = monitor.failureReason or "none",
      automaticPackSecondsRemaining = remaining,
    })
    announce(
      "Player relevance: " .. tostring(monitor.band)
        .. "\nNearest BLUE player: " .. tostring(monitor.nearestPlayerName or "none")
        .. "\nDistance: " .. tostring(monitor.nearestPlayerDistanceMeters or "none") .. " m"
        .. "\nAuto-pack remaining: " .. tostring(remaining) .. " s"
    )
  end

  updateEntity({
    playerInterestBand = BAND_UNKNOWN,
    playerInterestMonitorState = enabled and "READY" or "DISABLED",
  })
  logInfo("player_interest_monitor_initialized", {
    enabled = enabled,
    unpackRadiusMeters = unpackRadiusMeters,
    packRadiusMeters = packRadiusMeters,
    packDelaySeconds = packDelaySeconds,
    retrySeconds = retrySeconds,
    distanceModel = "HORIZONTAL_2D",
    coalition = "BLUE",
    schedulerModel = "WRAPPED_EXISTING_CONVOY_TICK",
  })

  return monitor
end

return PlayerInterestMonitor
