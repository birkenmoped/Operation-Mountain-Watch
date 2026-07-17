local Monitor = {}

local EXPANDED = "EXPANDED"
local COLLAPSED = "COLLAPSED_PROXY"
local IDLE = "IDLE"
local UNKNOWN = "UNKNOWN"
local INSIDE = "INSIDE_UNPACK"
local HYSTERESIS = "HYSTERESIS"
local OUTSIDE = "OUTSIDE"

local function positive(value)
  return type(value) == "number" and value > 0
end

local function distance2d(a, b)
  local dx = b.x - a.x
  local dy = b.y - a.y
  return math.sqrt(dx * dx + dy * dy)
end

local function native(object, methodName, fallback)
  local ok, method = pcall(function() return object and object[methodName] end)
  if not ok or type(method) ~= "function" then return fallback end
  local callOk, value = pcall(method, object)
  return callOk and value or fallback
end

local function runtimeIndex(name)
  local suffix = type(name) == "string" and string.match(name, "%-(%d+)$") or nil
  return suffix and tonumber(suffix) or nil
end

local function band(distance, unpackRadius, packRadius)
  if type(distance) ~= "number" then return OUTSIDE end
  if distance <= unpackRadius then return INSIDE end
  if distance <= packRadius then return HYSTERESIS end
  return OUTSIDE
end

function Monitor.attach(options)
  local controller = options.controller
  local config = options.config
  local logger = options.logger
  local announce = options.announce

  if type(controller) ~= "table"
    or type(controller.tick) ~= "function"
    or type(controller.pack) ~= "function"
    or type(controller.unpack) ~= "function"
    or type(controller.getState) ~= "function" then
    error("representation interest monitor requires a complete convoy controller")
  end
  if type(logger) ~= "table"
    or type(logger.info) ~= "function"
    or type(logger.error) ~= "function" then
    error("representation interest monitor requires a structured logger")
  end
  if type(announce) ~= "function" then
    error("representation interest monitor requires an announce callback")
  end

  local shared = config.representationInterest or {}
  local players = config.playerInterest or {}
  local enemies = config.enemyInterest or {}
  local playerEnabled = players.enabled == true
  local enemyEnabled = enemies.enabled == true
  local enabled = shared.enabled ~= false and (playerEnabled or enemyEnabled)
  local packDelay = shared.packDelaySeconds or 30
  local retry = shared.retrySeconds or 5
  local playerUnpack = players.unpackRadiusMeters or 500
  local playerPack = players.packRadiusMeters or 750
  local enemyUnpack = enemies.unpackRadiusMeters or 750
  local enemyPack = enemies.packRadiusMeters or 1000
  local enemyGroupNames = enemies.groupNames or {}

  if enabled and (not positive(packDelay) or not positive(retry)) then
    error("representation interest delay and retry must be positive numbers")
  end
  if playerEnabled then
    if not positive(playerUnpack) or not positive(playerPack) or playerUnpack >= playerPack then
      error("invalid player interest radii")
    end
    if type(coalition) ~= "table" or type(coalition.getPlayers) ~= "function"
      or type(coalition.side) ~= "table" or type(coalition.side.BLUE) ~= "number" then
      error("BLUE player API is unavailable")
    end
  end
  if enemyEnabled then
    if not positive(enemyUnpack) or not positive(enemyPack) or enemyUnpack >= enemyPack then
      error("invalid enemy interest radii")
    end
    if type(enemyGroupNames) ~= "table" or #enemyGroupNames == 0 then
      error("enemyInterest.groupNames must contain at least one group name")
    end
    if type(Group) ~= "table" or type(Group.getByName) ~= "function" then
      error("Group.getByName is unavailable")
    end
  end

  local state = {
    enabled = enabled,
    failed = false,
    failureReason = nil,
    playerBand = UNKNOWN,
    enemyBand = UNKNOWN,
    nearestPlayerDistanceMeters = nil,
    nearestPlayerName = nil,
    nearestPlayerUnitName = nil,
    nearestPlayerUnitType = nil,
    observedPlayerCount = 0,
    validPlayerCount = 0,
    nearestEnemyDistanceMeters = nil,
    nearestEnemyGroupName = nil,
    nearestEnemyUnitName = nil,
    nearestEnemyUnitType = nil,
    resolvedEnemyGroupCount = 0,
    aliveEnemyUnitCount = 0,
    packTimerStartedAt = nil,
    lastUnpackRequestAt = nil,
  }

  local function updateEntity(changes)
    if type(controller.campaignState) == "table"
      and type(controller.campaignState.updateEntity) == "function" then
      controller.entity = controller.campaignState:updateEntity(config.scenarioId, changes)
    end
  end

  local function fields(extra)
    local convoy = controller:getState() or {}
    local result = {
      entityId = convoy.entityId or config.scenarioId,
      routeId = convoy.routeId or config.routeId,
      representationState = convoy.representationState or "unknown",
      transitionState = convoy.transitionState or "unknown",
      movementState = convoy.movementState or "unknown",
      runtimeGroupName = convoy.runtimeGroupName or "none",
      runtimeGeneration = convoy.runtimeGeneration or 0,
      representationInterestEnabled = state.enabled,
      representationInterestFailed = state.failed,
      playerInterestEnabled = playerEnabled,
      playerInterestBand = state.playerBand,
      nearestPlayerDistanceMeters = state.nearestPlayerDistanceMeters or "none",
      nearestPlayerName = state.nearestPlayerName or "none",
      nearestPlayerUnitName = state.nearestPlayerUnitName or "none",
      nearestPlayerUnitType = state.nearestPlayerUnitType or "none",
      observedBluePlayerCount = state.observedPlayerCount,
      validBluePlayerCount = state.validPlayerCount,
      enemyInterestEnabled = enemyEnabled,
      enemyInterestBand = state.enemyBand,
      nearestEnemyDistanceMeters = state.nearestEnemyDistanceMeters or "none",
      nearestEnemyGroupName = state.nearestEnemyGroupName or "none",
      nearestEnemyUnitName = state.nearestEnemyUnitName or "none",
      nearestEnemyUnitType = state.nearestEnemyUnitType or "none",
      configuredEnemyGroupCount = #enemyGroupNames,
      resolvedEnemyGroupCount = state.resolvedEnemyGroupCount,
      aliveEnemyUnitCount = state.aliveEnemyUnitCount,
      automaticPackTimerStartedAt = state.packTimerStartedAt or "none",
      missionTimeSeconds = timer.getTime(),
    }
    for key, value in pairs(extra or {}) do result[key] = value end
    return result
  end

  local function info(event, extra) logger:info(event, fields(extra)) end
  local function fail(event, reason)
    local extra = fields({ reason = tostring(reason) })
    logger:error(event, extra)
  end

  local function disable(reason)
    if state.failed then return end
    state.failed = true
    state.failureReason = tostring(reason)
    state.packTimerStartedAt = nil
    updateEntity({
      representationInterestMonitorState = "FAILED",
      clearFields = { "automaticPackTimerStartedAt" },
    })
    fail("representation_interest_monitor_failed", reason)
    announce("Automatic representation relevance disabled\n" .. tostring(reason))
  end

  local function leadUnit()
    local convoy = controller:getState()
    if type(convoy) ~= "table" then return nil, "convoy state unavailable" end
    local group = controller.runtimeGroup
    if type(group) ~= "table" or type(group.GetUnits) ~= "function" then
      return nil, "runtime group unavailable"
    end
    local ok, units = pcall(function() return group:GetUnits() end)
    if not ok or type(units) ~= "table" then return nil, "runtime units unavailable" end
    local fallback = nil
    for _, unit in pairs(units) do
      local aliveOk, alive = pcall(function() return unit and unit:IsAlive() == true end)
      if aliveOk and alive then
        fallback = fallback or unit
        local nameOk, name = pcall(function() return unit:GetName() end)
        local index = nameOk and runtimeIndex(name) or nil
        local slot = index and convoy.runtimeIndexToStableSlot
          and convoy.runtimeIndexToStableSlot[index] or nil
        if slot == convoy.currentLeadSlot then return unit end
      end
    end
    if convoy.representationState == COLLAPSED and fallback then return fallback end
    return nil, "current lead unit unavailable"
  end

  local function observePlayers(convoyVec2)
    if not playerEnabled then
      return { nearest = nil, observed = 0, valid = 0 }
    end
    local ok, units = pcall(function() return coalition.getPlayers(coalition.side.BLUE) end)
    if not ok or type(units) ~= "table" then return nil, "BLUE player scan failed" end
    local observation = { nearest = nil, observed = 0, valid = 0 }
    for _, unit in pairs(units) do
      observation.observed = observation.observed + 1
      local point = native(unit, "getPoint", nil)
      local playerName = native(unit, "getPlayerName", nil)
      if native(unit, "isExist", false) == true
        and native(unit, "getLife", 0) > 0
        and type(playerName) == "string" and playerName ~= ""
        and type(point) == "table" and type(point.x) == "number"
        and type(point.z) == "number" then
        observation.valid = observation.valid + 1
        local d = distance2d(convoyVec2, { x = point.x, y = point.z })
        if not observation.nearest or d < observation.nearest.distance then
          observation.nearest = {
            distance = d,
            playerName = playerName,
            unitName = native(unit, "getName", "unknown"),
            unitType = native(unit, "getTypeName", "unknown"),
          }
        end
      end
    end
    return observation
  end

  local function observeEnemies(convoyVec2)
    local observation = { nearest = nil, resolved = 0, alive = 0 }
    if not enemyEnabled then return observation end
    for _, groupName in ipairs(enemyGroupNames) do
      local group = Group.getByName(groupName)
      if group and native(group, "isExist", false) == true then
        observation.resolved = observation.resolved + 1
        local units = native(group, "getUnits", {})
        if type(units) == "table" then
          for _, unit in pairs(units) do
            local point = native(unit, "getPoint", nil)
            if native(unit, "isExist", false) == true
              and native(unit, "getLife", 0) > 0
              and type(point) == "table" and type(point.x) == "number"
              and type(point.z) == "number" then
              observation.alive = observation.alive + 1
              local d = distance2d(convoyVec2, { x = point.x, y = point.z })
              if not observation.nearest or d < observation.nearest.distance then
                observation.nearest = {
                  distance = d,
                  groupName = groupName,
                  unitName = native(unit, "getName", "unknown"),
                  unitType = native(unit, "getTypeName", "unknown"),
                }
              end
            end
          end
        end
      end
    end
    return observation
  end

  local function applyPlayer(observation, newBand)
    local previous = state.playerBand
    local nearest = observation.nearest
    state.nearestPlayerDistanceMeters = nearest and nearest.distance or nil
    state.nearestPlayerName = nearest and nearest.playerName or nil
    state.nearestPlayerUnitName = nearest and nearest.unitName or nil
    state.nearestPlayerUnitType = nearest and nearest.unitType or nil
    state.observedPlayerCount = observation.observed
    state.validPlayerCount = observation.valid
    if previous == newBand then return end
    state.playerBand = newBand
    updateEntity({ playerInterestBand = newBand })
    local extra = { previousBand = previous, newBand = newBand,
      unpackRadiusMeters = playerUnpack, packRadiusMeters = playerPack }
    info("player_relevance_band_changed", extra)
    if previous ~= UNKNOWN and newBand == INSIDE then
      info("player_relevance_entered", extra)
    elseif previous ~= UNKNOWN and newBand == OUTSIDE then
      info("player_relevance_exited", extra)
    end
  end

  local function applyEnemy(observation, newBand)
    local previous = state.enemyBand
    local nearest = observation.nearest
    state.nearestEnemyDistanceMeters = nearest and nearest.distance or nil
    state.nearestEnemyGroupName = nearest and nearest.groupName or nil
    state.nearestEnemyUnitName = nearest and nearest.unitName or nil
    state.nearestEnemyUnitType = nearest and nearest.unitType or nil
    state.resolvedEnemyGroupCount = observation.resolved
    state.aliveEnemyUnitCount = observation.alive
    if previous == newBand then return end
    state.enemyBand = newBand
    updateEntity({ enemyInterestBand = newBand })
    local extra = { previousBand = previous, newBand = newBand,
      unpackRadiusMeters = enemyUnpack, packRadiusMeters = enemyPack }
    info("enemy_relevance_band_changed", extra)
    if previous ~= UNKNOWN and newBand == INSIDE then
      info("enemy_relevance_entered", extra)
    elseif previous ~= UNKNOWN and newBand == OUTSIDE then
      info("enemy_relevance_exited", extra)
    end
  end

  local function clearTimer(reason, logCancellation)
    if not state.packTimerStartedAt then return end
    local started = state.packTimerStartedAt
    state.packTimerStartedAt = nil
    updateEntity({ clearFields = { "automaticPackTimerStartedAt" } })
    if logCancellation then
      info("automatic_pack_timer_cancelled", {
        reason = reason,
        timerElapsedSeconds = timer.getTime() - started,
      })
    end
  end

  local function service()
    if not state.enabled or state.failed then return true end
    local convoy = controller:getState()
    if type(convoy) ~= "table" or convoy.transitionState ~= IDLE
      or (convoy.representationState ~= EXPANDED
        and convoy.representationState ~= COLLAPSED) then
      return true
    end

    local lead, leadError = leadUnit()
    if not lead then return false, leadError end
    local ok, convoyVec2 = pcall(function() return lead:GetVec2() end)
    if not ok or type(convoyVec2) ~= "table" then
      return false, "convoy lead position unavailable"
    end

    local playerObservation, playerError = observePlayers(convoyVec2)
    if not playerObservation then return false, playerError end
    local enemyObservation = observeEnemies(convoyVec2)
    local nearestPlayer = playerObservation.nearest
    local nearestEnemy = enemyObservation.nearest
    local playerBand = playerEnabled and band(
      nearestPlayer and nearestPlayer.distance or nil, playerUnpack, playerPack) or OUTSIDE
    local enemyBand = enemyEnabled and band(
      nearestEnemy and nearestEnemy.distance or nil, enemyUnpack, enemyPack) or OUTSIDE
    applyPlayer(playerObservation, playerBand)
    applyEnemy(enemyObservation, enemyBand)

    local unpackForPlayer = playerEnabled and playerBand == INSIDE
    local unpackForEnemy = enemyEnabled and enemyBand == INSIDE
    local mayPack = playerBand == OUTSIDE and enemyBand == OUTSIDE
    local now = timer.getTime()

    if convoy.representationState == EXPANDED then
      state.lastUnpackRequestAt = nil
      if not mayPack then
        clearTimer("player or enemy remains inside pack boundary", true)
        return true
      end
      if not state.packTimerStartedAt then
        state.packTimerStartedAt = now
        updateEntity({ automaticPackTimerStartedAt = now })
        info("automatic_pack_timer_started", {
          timerStartedAt = now,
          packDelaySeconds = packDelay,
          requiredPlayerBand = OUTSIDE,
          requiredEnemyBand = OUTSIDE,
        })
        return true
      end
      local elapsed = now - state.packTimerStartedAt
      if elapsed < packDelay then return true end
      info("automatic_pack_requested", {
        timerElapsedSeconds = elapsed,
        playerOutside = playerBand == OUTSIDE,
        enemyOutside = enemyBand == OUTSIDE,
      })
      clearTimer("automatic pack requested", false)
      local requested = controller:pack()
      if requested and controller.pendingPack then
        controller.pendingPack.automaticRepresentationInterest = true
        controller.pendingPack.playerOutside = true
        controller.pendingPack.enemyOutside = true
      elseif not requested and not controller.halted then
        state.packTimerStartedAt = now
        updateEntity({ automaticPackTimerStartedAt = now })
        info("automatic_pack_request_failed", { retryAfterSeconds = packDelay })
      end
      if requested or not controller.halted then return true end
      return false, "automatic pack request halted the convoy controller"
    end

    clearTimer("convoy is not expanded", false)
    if convoy.representationState == COLLAPSED and (unpackForPlayer or unpackForEnemy) then
      if state.lastUnpackRequestAt and now - state.lastUnpackRequestAt < retry then
        return true
      end
      state.lastUnpackRequestAt = now
      info("automatic_unpack_requested", {
        retrySeconds = retry,
        triggeredByPlayer = unpackForPlayer,
        triggeredByEnemy = unpackForEnemy,
      })
      local requested = controller:unpack(false)
      if requested and controller.pendingUnpack then
        controller.pendingUnpack.automaticRepresentationInterest = true
        controller.pendingUnpack.automaticPlayerInterest = unpackForPlayer
        controller.pendingUnpack.automaticEnemyInterest = unpackForEnemy
      elseif not requested then
        info("automatic_unpack_request_failed", {
          triggeredByPlayer = unpackForPlayer,
          triggeredByEnemy = unpackForEnemy,
        })
      end
      if requested or not controller.halted then return true end
      return false, "automatic unpack request halted the convoy controller"
    end
    return true
  end

  local originalTick = controller.tick
  controller.tick = function(self)
    local result = originalTick(self)
    if result == false or self.halted then return result end
    local callOk, serviceOk, serviceError = pcall(service)
    if not callOk then
      disable(serviceOk)
    elseif serviceOk == false then
      disable(serviceError or "representation relevance service returned false")
    end
    return result
  end

  local originalShowStatus = controller.showStatus
  controller.showStatus = function(self)
    originalShowStatus(self)
    local remaining = "none"
    if state.packTimerStartedAt then
      remaining = math.max(0, packDelay - (timer.getTime() - state.packTimerStartedAt))
    end
    info("representation_interest_status", {
      failureReason = state.failureReason or "none",
      automaticPackSecondsRemaining = remaining,
    })
    announce(
      "Player relevance: " .. tostring(state.playerBand)
        .. "\nPlayer distance: " .. tostring(state.nearestPlayerDistanceMeters or "none") .. " m"
        .. "\nEnemy relevance: " .. tostring(state.enemyBand)
        .. "\nNearest RED unit: " .. tostring(state.nearestEnemyUnitName or "none")
        .. "\nEnemy distance: " .. tostring(state.nearestEnemyDistanceMeters or "none") .. " m"
        .. "\nAuto-pack remaining: " .. tostring(remaining) .. " s"
    )
  end

  updateEntity({
    playerInterestBand = UNKNOWN,
    enemyInterestBand = UNKNOWN,
    representationInterestMonitorState = enabled and "READY" or "DISABLED",
  })
  info("representation_interest_monitor_initialized", {
    enabled = enabled,
    packDelaySeconds = packDelay,
    retrySeconds = retry,
    distanceModel = "HORIZONTAL_2D",
    schedulerModel = "WRAPPED_EXISTING_CONVOY_TICK",
  })
  info("player_interest_monitor_initialized", {
    enabled = playerEnabled,
    unpackRadiusMeters = playerUnpack,
    packRadiusMeters = playerPack,
    packDelaySeconds = packDelay,
    retrySeconds = retry,
    distanceModel = "HORIZONTAL_2D",
    coalition = "BLUE",
    compatibilityEvent = true,
  })
  info("enemy_interest_monitor_initialized", {
    enabled = enemyEnabled,
    unpackRadiusMeters = enemyUnpack,
    packRadiusMeters = enemyPack,
    packDelaySeconds = packDelay,
    retrySeconds = retry,
    distanceModel = "HORIZONTAL_2D",
    coalition = "RED",
    configuredGroupNames = table.concat(enemyGroupNames, ","),
  })
  return state
end

return Monitor