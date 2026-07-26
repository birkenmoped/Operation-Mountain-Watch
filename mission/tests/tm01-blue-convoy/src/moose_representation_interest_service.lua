local Service = {}

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

local function band(distance, unpackRadius, packRadius)
  if type(distance) ~= "number" then return OUTSIDE end
  if distance <= unpackRadius then return INSIDE end
  if distance <= packRadius then return HYSTERESIS end
  return OUTSIDE
end

local function safeDistance(origin, target)
  if not origin or not target then return nil end
  local ok, distance = pcall(function() return origin:Get2DDistance(target) end)
  return ok and distance or nil
end

function Service.attach(options)
  local controller = assert(options.controller, "controller required")
  local config = assert(options.config, "config required")
  local logger = assert(options.logger, "logger required")

  local shared = config.representationInterest or {}
  local playerConfig = config.playerInterest or {}
  local enemyConfig = config.enemyInterest or {}
  local playerEnabled = playerConfig.enabled == true
  local enemyEnabled = enemyConfig.enabled == true
  local enabled = shared.enabled ~= false and (playerEnabled or enemyEnabled)
  local interval = shared.schedulerSeconds or config.transitions.pollSeconds or 5
  local packDelay = shared.packDelaySeconds or 30
  local retry = shared.retrySeconds or 5
  local playerUnpack = playerConfig.unpackRadiusMeters or 500
  local playerPack = playerConfig.packRadiusMeters or 750
  local enemyUnpack = enemyConfig.unpackRadiusMeters or 750
  local enemyPack = enemyConfig.packRadiusMeters or 1000

  assert(type(SCHEDULER) == "table" and type(SCHEDULER.New) == "function", "MOOSE SCHEDULER unavailable")
  assert(type(SET_CLIENT) == "table" and type(SET_CLIENT.New) == "function", "MOOSE SET_CLIENT unavailable")
  assert(type(SET_GROUP) == "table" and type(SET_GROUP.New) == "function", "MOOSE SET_GROUP unavailable")
  assert(type(GROUP) == "table" and type(GROUP.FindByName) == "function", "MOOSE GROUP lookup unavailable")
  assert(type(MESSAGE) == "table" and type(MESSAGE.New) == "function", "MOOSE MESSAGE unavailable")
  assert(positive(interval) and positive(packDelay) and positive(retry), "invalid scheduler or delay setting")

  local state = {
    enabled = enabled,
    failed = false,
    playerBand = UNKNOWN,
    enemyBand = UNKNOWN,
    packTimerStartedAt = nil,
    lastUnpackRequestAt = nil,
    scheduler = nil,
  }

  local playerSet = SET_CLIENT:New():FilterCoalitions("blue"):FilterStart()
  local enemySet = SET_GROUP:New()
  for _, groupName in ipairs(enemyConfig.groupNames or {}) do
    local group = GROUP:FindByName(groupName)
    if group then enemySet:AddGroup(group) end
  end

  local function announce(text)
    MESSAGE:New("[OMW][TM01C] " .. tostring(text), 15, "OMW TEST"):ToAll()
  end

  local function updateEntity(changes)
    if controller.campaignState and type(controller.campaignState.updateEntity) == "function" then
      controller.entity = controller.campaignState:updateEntity(config.scenarioId, changes)
    end
  end

  local function log(event, extra)
    local fields = extra or {}
    fields.schedulerModel = "MOOSE_SCHEDULER"
    fields.playerCollection = "SET_CLIENT"
    fields.enemyCollection = "SET_GROUP"
    fields.missionTimeSeconds = timer.getTime()
    logger:info(event, fields)
  end

  local function leadCoordinate()
    local group = controller.runtimeGroup
    if not group or group:IsAlive() ~= true then return nil end
    local units = group:GetUnits() or {}
    for _, unit in pairs(units) do
      if unit and unit:IsAlive() == true then
        return unit:GetCoordinate()
      end
    end
    return nil
  end

  local function nearestPlayer(origin)
    local nearest = nil
    if not playerEnabled then return nil end
    playerSet:ForEachClient(function(client)
      if client and client:IsAlive() == true then
        local distance = safeDistance(origin, client:GetCoordinate())
        if distance and (not nearest or distance < nearest) then nearest = distance end
      end
    end)
    return nearest
  end

  local function nearestEnemy(origin)
    local nearest = nil
    if not enemyEnabled then return nil end
    enemySet:ForEachGroup(function(group)
      if group and group:IsAlive() == true then
        for _, unit in pairs(group:GetUnits() or {}) do
          if unit and unit:IsAlive() == true then
            local distance = safeDistance(origin, unit:GetCoordinate())
            if distance and (not nearest or distance < nearest) then nearest = distance end
          end
        end
      end
    end)
    return nearest
  end

  local function clearPackTimer(reason)
    if not state.packTimerStartedAt then return end
    state.packTimerStartedAt = nil
    updateEntity({ clearFields = { "automaticPackTimerStartedAt" } })
    log("automatic_pack_timer_cancelled", { reason = reason })
  end

  local function serviceTick()
    if not state.enabled or state.failed or controller.halted then return end
    local convoy = controller:getState()
    if type(convoy) ~= "table" or convoy.transitionState ~= IDLE then return end
    if convoy.representationState ~= EXPANDED and convoy.representationState ~= COLLAPSED then return end

    local origin = leadCoordinate()
    if not origin then return end

    local playerDistance = nearestPlayer(origin)
    local enemyDistance = nearestEnemy(origin)
    local playerBand = playerEnabled and band(playerDistance, playerUnpack, playerPack) or OUTSIDE
    local enemyBand = enemyEnabled and band(enemyDistance, enemyUnpack, enemyPack) or OUTSIDE
    local now = timer.getTime()

    if state.playerBand ~= playerBand then
      log("player_relevance_band_changed", { previousBand = state.playerBand, newBand = playerBand, nearestDistanceMeters = playerDistance or "none" })
      state.playerBand = playerBand
      updateEntity({ playerInterestBand = playerBand })
    end
    if state.enemyBand ~= enemyBand then
      log("enemy_relevance_band_changed", { previousBand = state.enemyBand, newBand = enemyBand, nearestDistanceMeters = enemyDistance or "none" })
      state.enemyBand = enemyBand
      updateEntity({ enemyInterestBand = enemyBand })
    end

    local unpackForPlayer = playerBand == INSIDE
    local unpackForEnemy = enemyBand == INSIDE
    local mayPack = playerBand == OUTSIDE and enemyBand == OUTSIDE

    if convoy.representationState == EXPANDED then
      state.lastUnpackRequestAt = nil
      if not mayPack then
        clearPackTimer("interest remains inside pack boundary")
        return
      end
      if not state.packTimerStartedAt then
        state.packTimerStartedAt = now
        updateEntity({ automaticPackTimerStartedAt = now })
        log("automatic_pack_timer_started", { packDelaySeconds = packDelay })
        return
      end
      if now - state.packTimerStartedAt >= packDelay then
        state.packTimerStartedAt = nil
        updateEntity({ clearFields = { "automaticPackTimerStartedAt" } })
        log("automatic_pack_requested", {})
        controller:pack()
      end
      return
    end

    clearPackTimer("convoy is collapsed")
    if unpackForPlayer or unpackForEnemy then
      if state.lastUnpackRequestAt and now - state.lastUnpackRequestAt < retry then return end
      state.lastUnpackRequestAt = now
      log("automatic_unpack_requested", { triggeredByPlayer = unpackForPlayer, triggeredByEnemy = unpackForEnemy })
      controller:unpack(false)
    end
  end

  state.scheduler = SCHEDULER:New(nil, function()
    local ok, err = pcall(serviceTick)
    if not ok then
      state.failed = true
      logger:error("representation_interest_service_failed", { error = tostring(err), schedulerModel = "MOOSE_SCHEDULER" })
      announce("Automatic representation relevance disabled: " .. tostring(err))
      if state.scheduler then state.scheduler:Stop() end
    end
  end, {}, 0, interval)

  updateEntity({
    playerInterestBand = UNKNOWN,
    enemyInterestBand = UNKNOWN,
    representationInterestMonitorState = enabled and "READY" or "DISABLED",
  })
  log("representation_interest_service_initialized", {
    enabled = enabled,
    intervalSeconds = interval,
    packDelaySeconds = packDelay,
    retrySeconds = retry,
  })

  return state
end

return Service
