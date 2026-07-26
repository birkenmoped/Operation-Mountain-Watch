local TM02W2FProgressWatchdog = {}

local function vec3(value)
  if not value then return nil end
  if type(value.GetVec3) == "function" then
    local ok, result = pcall(function() return value:GetVec3() end)
    if ok and type(result) == "table" then return result end
  end
  if type(value) == "table" and type(value.x) == "number" then
    return { x = value.x, y = value.y or 0, z = value.z or value.y or 0 }
  end
  return nil
end

local function distance2D(first, second)
  local a, b = vec3(first), vec3(second)
  if not a or not b then return math.huge end
  local dx, dz = b.x - a.x, b.z - a.z
  return math.sqrt(dx * dx + dz * dz)
end

local function coordinate(value)
  local point = vec3(value)
  if not point then return nil end
  return COORDINATE:NewFromVec3({ x = point.x, y = point.y or 0, z = point.z })
end

local function projectOnSegment(first, second, position)
  local a, b, p = vec3(first), vec3(second), vec3(position)
  if not a or not b or not p then return nil end
  local dx, dz = b.x - a.x, b.z - a.z
  local squared = dx * dx + dz * dz
  local total = math.sqrt(squared)
  if total <= 0 then return nil end
  local fraction = ((p.x - a.x) * dx + (p.z - a.z) * dz) / squared
  fraction = math.max(0, math.min(1, fraction))
  local projected = { x = a.x + dx * fraction, y = 0, z = a.z + dz * fraction }
  return {
    alongMeters = total * fraction,
    crossTrackMeters = distance2D(projected, p),
    totalMeters = total,
  }
end

local function coordinateAtDistance(first, second, requestedMeters)
  local a, b = vec3(first), vec3(second)
  if not a or not b then return nil end
  local total = distance2D(a, b)
  if total == math.huge or total <= 0 then return nil end
  local fraction = math.max(0, math.min(1, requestedMeters / total))
  return coordinate({
    x = a.x + (b.x - a.x) * fraction,
    y = 0,
    z = a.z + (b.z - a.z) * fraction,
  })
end

local function formatFields(fields)
  local keys, parts = {}, {}
  for key in pairs(fields or {}) do keys[#keys + 1] = key end
  table.sort(keys)
  for _, key in ipairs(keys) do
    parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
  end
  return table.concat(parts, " ")
end

function TM02W2FProgressWatchdog.install(config, executionState, navigation)
  local cfg = config.watchdog or {}
  local state = {
    valid = true,
    errors = {},
    warnings = {},
    running = false,
    generation = 0,
    nextGlobalRecoveryAt = -math.huge,
    replacementGeneration = 0,
    stallCount = 0,
    relocationCount = 0,
    roadRecoveryCount = 0,
    terminalRecoveryCount = 0,
    blockedCount = 0,
  }

  local function log(level, event, fields)
    local suffix = formatFields(fields)
    env.info("[OMW][TM02W2F][WATCHDOG] level=" .. level .. " event=" .. event
      .. (suffix ~= "" and (" " .. suffix) or ""))
  end

  local function invalid(code, detail)
    state.valid = false
    state.errors[#state.errors + 1] = code .. ": " .. tostring(detail)
    log("ERROR", "watchdog_validation_error", { code = code, detail = detail })
  end

  local required = {
    "initialDelaySeconds", "sampleIntervalSeconds", "stallWindowSeconds",
    "minimumTravelMeters", "minimumProgressMeters", "circularTravelMeters",
    "circularNetMeters", "wrongWayMeters", "crossTrackLimitMeters",
    "minimumDistanceToDestinationMeters",
    "postRecoveryGraceSeconds", "perTaskRecoveryCooldownSeconds",
    "globalRecoveryIntervalSeconds", "maxOffroadRelocationsPerEpisode",
    "relocationAdvanceMeters", "terminalRecoveryThresholdMeters",
    "terminalRecoveryOffsetMeters", "episodeResetProgressMeters",
    "maximumRoadSnapDistanceMeters", "minimumRoadSegmentMeters",
  }
  for _, name in ipairs(required) do
    if type(cfg[name]) ~= "number" or cfg[name] <= 0 then
      invalid("CONFIG_INVALID", name .. "=" .. tostring(cfg[name]))
    end
  end
  if cfg.enabled ~= true then invalid("WATCHDOG_DISABLED", cfg.enabled) end
  if cfg.maxOffroadRelocationsPerEpisode ~= 4 then
    invalid("RELOCATION_LIMIT_INVALID", cfg.maxOffroadRelocationsPerEpisode)
  end
  if cfg.relocationAdvanceMeters ~= 75 then
    invalid("RELOCATION_DISTANCE_INVALID", cfg.relocationAdvanceMeters)
  end
  if cfg.terminalRecoveryThresholdMeters ~= 100 then
    invalid("TERMINAL_THRESHOLD_INVALID", cfg.terminalRecoveryThresholdMeters)
  end
  if not config.navigation or config.navigation.automaticRecoveryEnabled ~= true then
    invalid("AUTOMATIC_RECOVERY_DISABLED", "navigation.automaticRecoveryEnabled")
  end
  if type(executionState) ~= "table" or executionState.configurationValid ~= true then
    invalid("EXECUTION_INVALID", "execution state")
  end
  if type(navigation) ~= "table" or navigation.valid ~= true
    or navigation.routingReady ~= true or type(navigation.registryState) ~= "table" then
    invalid("NAVIGATION_INVALID", "navigation registry context")
  end
  if type(SPAWN) ~= "table" or type(SPAWN.NewWithAlias) ~= "function" then
    invalid("SPAWN_API_MISSING", "SPAWN.NewWithAlias")
  end

  local function activeGroup(task)
    return task and task.proxyGroup and task.proxyGroup:IsAlive() == true
      and task.proxyGroup or nil
  end

  local function legContext(task)
    local sourceId = task.path and task.path[task.currentLegIndex] or nil
    local targetId = task.path and task.path[task.currentLegIndex + 1] or nil
    local sourceSite = sourceId and navigation.registryState.siteById[sourceId] or nil
    local zone = targetId and ZONE:FindByName(targetId) or nil
    local target = zone and zone:GetCoordinate() or nil
    local source = sourceSite and coordinate(sourceSite.coordinate) or nil
    if not source or not target then return nil end
    return {
      key = tostring(sourceId) .. ">" .. tostring(targetId),
      source = source,
      target = target,
      sourceId = sourceId,
      targetId = targetId,
    }
  end

  local function monitorFor(task)
    task.w2fProgressWatchdog = task.w2fProgressWatchdog or {
      legKey = nil,
      groupName = nil,
      sampleTime = nil,
      sampleStart = nil,
      sampleLast = nil,
      sampleDistance = nil,
      sampleAlong = nil,
      travelled = 0,
      maxAlong = 0,
      highestAlong = 0,
      graceUntil = 0,
      nextRecoveryAt = 0,
      offroadRelocations = 0,
      roadRecoveryUsed = false,
      terminalRecoveryUsed = false,
      recoveryAnchorDistance = nil,
      episode = 1,
      blockedLogged = false,
    }
    return task.w2fProgressWatchdog
  end

  local function resetSample(monitor, now, position, projection, remaining)
    local point = vec3(position)
    monitor.sampleTime = now
    monitor.sampleStart = point
    monitor.sampleLast = point
    monitor.sampleDistance = remaining
    monitor.sampleAlong = projection.alongMeters
    monitor.travelled = 0
