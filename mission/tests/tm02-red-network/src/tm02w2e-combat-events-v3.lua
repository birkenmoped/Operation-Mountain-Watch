local TM02W2ECombatEventsV3 = {}

local function eventGroupName(eventData, prefixValue)
  if type(eventData) ~= "table" then return nil end
  local directName = eventData[prefixValue .. "GroupName"]
    or eventData[prefixValue .. "DCSGroupName"]
  if type(directName) == "string" and directName ~= "" then return directName end
  local wrapper = eventData[prefixValue .. "Group"]
  if type(wrapper) == "table" and type(wrapper.GetName) == "function" then
    local ok, name = pcall(function() return wrapper:GetName() end)
    if ok and type(name) == "string" and name ~= "" then return name end
  end
  return nil
end

function TM02W2ECombatEventsV3.install(config, executionState)
  local prefix = "[OMW][TM02W2E][COMBAT]"
  local state = {
    valid = false,
    errors = {},
    handler = nil,
    observedEventCount = 0,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info(prefix .. " level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function addError(code, detail)
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "combat_event_error", { code = code, detail = detail })
  end

  if type(EVENTHANDLER) ~= "table" or type(EVENTHANDLER.New) ~= "function" then
    addError("MOOSE_API_MISSING", "EVENTHANDLER.New")
  end
  local requiredEvents = {
    { "ShootingStart", EVENTS and EVENTS.ShootingStart },
    { "ShootingEnd", EVENTS and EVENTS.ShootingEnd },
    { "Shot", EVENTS and EVENTS.Shot },
    { "Hit", EVENTS and EVENTS.Hit },
  }
  for _, definition in ipairs(requiredEvents) do
    if definition[2] == nil then addError("MOOSE_EVENT_MISSING", definition[1]) end
  end
  if type(executionState) ~= "table" or type(executionState.tasks) ~= "table" then
    addError("EXECUTION_STATE_INVALID", "tasks unavailable")
  end
  if #state.errors > 0 then return state end

  local handler = EVENTHANDLER:New()
  if not handler or type(handler.HandleEvent) ~= "function" then
    addError("EVENT_HANDLER_INSTANCE_INVALID", "HandleEvent unavailable")
    return state
  end

  local function activeTaskByGroupName(groupName)
    if type(groupName) ~= "string" then return nil end
    for _, task in ipairs(executionState.tasks or {}) do
      if task.movementState == "EN_ROUTE" and task.proxyGroupName == groupName then
        return task
      end
    end
    return nil
  end

  local function cooldownSeconds(eventName)
    if eventName == "Hit" then
      return config.navigation.hitCooldownSeconds
        or config.navigation.combatCooldownSeconds
        or 300
    end
    return config.navigation.combatCooldownSeconds or 180
  end

  local function extendCooldown(groupName, eventName, role)
    local task = activeTaskByGroupName(groupName)
    if not task then return false end
    local now = timer.getTime()
    local seconds = cooldownSeconds(eventName)
    task.navCombatUntil = math.max(task.navCombatUntil or 0, now + seconds)
    state.observedEventCount = state.observedEventCount + 1
    log("INFO", "combat_activity_observed", {
      taskId = task.taskId,
      runtimeGroupName = groupName,
      eventName = eventName,
      eventRole = role,
      cooldownSeconds = seconds,
      combatUntil = task.navCombatUntil,
      observedEventCount = state.observedEventCount,
    })
    return true
  end

  local function observe(eventName, eventData, includeTarget)
    local initiatorName = eventGroupName(eventData, "Ini")
    local targetName = eventGroupName(eventData, "Tgt")
    if initiatorName then extendCooldown(initiatorName, eventName, "INITIATOR") end
    if includeTarget and targetName and targetName ~= initiatorName then
      extendCooldown(targetName, eventName, "TARGET")
    end
  end

  local ok, registrationError = pcall(function()
    handler:HandleEvent(EVENTS.ShootingStart)
    handler:HandleEvent(EVENTS.ShootingEnd)
    handler:HandleEvent(EVENTS.Shot)
    handler:HandleEvent(EVENTS.Hit)
  end)
  if not ok then
    addError("EVENT_REGISTRATION_FAILED", registrationError)
    return state
  end

  function handler:OnEventShootingStart(eventData)
    observe("ShootingStart", eventData, true)
  end
  function handler:OnEventShootingEnd(eventData)
    observe("ShootingEnd", eventData, false)
  end
  function handler:OnEventShot(eventData)
    observe("Shot", eventData, false)
  end
  function handler:OnEventHit(eventData)
    observe("Hit", eventData, true)
  end

  state.handler = handler
  state.valid = true
  log("INFO", "combat_event_guard_started", {
    combatCooldownSeconds = config.navigation.combatCooldownSeconds,
    hitCooldownSeconds = config.navigation.hitCooldownSeconds,
    shootingStart = EVENTS.ShootingStart,
    shootingEnd = EVENTS.ShootingEnd,
    shot = EVENTS.Shot,
    hit = EVENTS.Hit,
  })
  return state
end

return TM02W2ECombatEventsV3
