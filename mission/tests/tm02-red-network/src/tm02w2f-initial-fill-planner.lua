local TM02W2FInitialFillPlanner = {}

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function formatFields(fields)
  local parts = {}
  for _, key in ipairs(sortedKeys(fields)) do
    parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
  end
  return table.concat(parts, " ")
end

local function personnelDefinitionBySite(basePlannerConfig)
  local result = {}
  for _, definition in ipairs(basePlannerConfig.personnel or {}) do
    result[definition.siteId] = definition
  end
  return result
end

function TM02W2FInitialFillPlanner.start(config, basePlannerConfig, registryState, build)
  local prefix = "[OMW][TM02W2F][PLANNER]"
  local state = {
    configurationValid = false,
    errors = {},
    warnings = {},
    tasks = {},
    taskById = {},
    inventoryBySiteId = {},
    totalReservedInbound = 0,
    totalReservedOutbound = 0,
    unresolvedDeficit = 0,
    targetPersonnel = 0,
    packetCount = 0,
  }

  local function log(level, event, fields)
    local suffix = formatFields(fields)
    env.info(prefix .. " level=" .. level .. " event=" .. event
      .. (suffix ~= "" and (" " .. suffix) or ""))
  end

  local function addError(code, detail)
    state.errors[#state.errors + 1] = tostring(code) .. ": " .. tostring(detail)
    log("ERROR", "initial_fill_planner_error", { code = code, detail = detail })
  end

  local function addWarning(code, detail)
    state.warnings[#state.warnings + 1] = tostring(code) .. ": " .. tostring(detail)
    log("WARNING", "initial_fill_planner_warning", { code = code, detail = detail })
  end

  if type(registryState) ~= "table" or registryState.configurationValid ~= true then
    addError("REGISTRY_INVALID", "TM02W1 registry unavailable or invalid")
  end
  if type(config) ~= "table" or type(config.initialFill) ~= "table" then
    addError("CONFIG_INVALID", "initialFill configuration unavailable")
  end

  local supplySiteId = config.initialFill and config.initialFill.supplySiteId or nil
  local totalPersonnel = config.initialFill and config.initialFill.totalPersonnel or nil
  local maxPacketStrength = config.initialFill and config.initialFill.maxPacketStrength or nil
  local targetBySiteId = config.initialFill and config.initialFill.targetPersonnelBySiteId or nil

  if type(supplySiteId) ~= "string" or supplySiteId == "" then
    addError("SUPPLY_SITE_INVALID", tostring(supplySiteId))
  elseif not registryState.siteById[supplySiteId] then
    addError("SUPPLY_SITE_MISSING", supplySiteId)
  end
  if type(totalPersonnel) ~= "number" or totalPersonnel % 1 ~= 0 or totalPersonnel < 1 then
    addError("TOTAL_PERSONNEL_INVALID", tostring(totalPersonnel))
  end
  if type(maxPacketStrength) ~= "number"
    or maxPacketStrength % 1 ~= 0
    or maxPacketStrength < 1
    or maxPacketStrength > 6 then
    addError("MAX_PACKET_STRENGTH_INVALID", tostring(maxPacketStrength))
  end
  if type(targetBySiteId) ~= "table" then
    addError("TARGET_MAP_INVALID", type(targetBySiteId))
  end

  local baseBySiteId = personnelDefinitionBySite(basePlannerConfig or {})
  local targetSum = 0
  for _, siteId in ipairs(sortedKeys(registryState.siteById or {})) do
    local target = targetBySiteId and targetBySiteId[siteId] or nil
    local base = baseBySiteId[siteId] or {}
    if type(target) ~= "number" or target % 1 ~= 0 or target < 0 then
      addError("TARGET_PERSONNEL_INVALID", siteId .. " target=" .. tostring(target))
      target = 0
    end
    if siteId ~= supplySiteId and type(base.hardCapacity) == "number" and target > base.hardCapacity then
      addError("TARGET_EXCEEDS_CAPACITY", siteId .. " target=" .. target .. " capacity=" .. base.hardCapacity)
    end
    targetSum = targetSum + target
    state.inventoryBySiteId[siteId] = {
      siteId = siteId,
      currentPersonnel = siteId == supplySiteId and totalPersonnel or 0,
      guardFloor = siteId == supplySiteId and target or 0,
      defensiveTarget = target,
      hardCapacity = siteId == supplySiteId and totalPersonnel or (base.hardCapacity or target),
      reservedInbound = 0,
      reservedOutbound = 0,
    }
  end

  for siteId in pairs(targetBySiteId or {}) do
    if not registryState.siteById[siteId] then
      addError("TARGET_SITE_NOT_IN_REGISTRY", siteId)
    end
  end

  state.targetPersonnel = targetSum
  if targetSum ~= totalPersonnel then
    addError("TARGET_TOTAL_MISMATCH", "targets=" .. tostring(targetSum) .. " total=" .. tostring(totalPersonnel))
  end

  local taskNumber = 0
  for _, targetSiteId in ipairs(sortedKeys(state.inventoryBySiteId)) do
    if targetSiteId ~= supplySiteId then
      local remaining = state.inventoryBySiteId[targetSiteId].defensiveTarget
      while remaining > 0 do
        local strength = math.min(maxPacketStrength, remaining)
        taskNumber = taskNumber + 1
        local taskId = string.format("W2F-FILL-%03d", taskNumber)
        local task = {
          taskId = taskId,
          sourceSiteId = supplySiteId,
          targetSiteId = targetSiteId,
          strength = strength,
          path = { supplySiteId, targetSiteId },
          linkIds = {},
          optimizationRank = taskNumber,
        }
        state.tasks[#state.tasks + 1] = task
        state.taskById[taskId] = task
        state.inventoryBySiteId[supplySiteId].reservedOutbound =
          state.inventoryBySiteId[supplySiteId].reservedOutbound + strength
        state.inventoryBySiteId[targetSiteId].reservedInbound =
          state.inventoryBySiteId[targetSiteId].reservedInbound + strength
        state.totalReservedOutbound = state.totalReservedOutbound + strength
        state.totalReservedInbound = state.totalReservedInbound + strength
        remaining = remaining - strength
      end
    end
  end

  state.packetCount = #state.tasks
  local retained = state.inventoryBySiteId[supplySiteId]
    and (state.inventoryBySiteId[supplySiteId].currentPersonnel
      - state.inventoryBySiteId[supplySiteId].reservedOutbound)
    or -1
  local expectedRetained = targetBySiteId and targetBySiteId[supplySiteId] or nil
  if retained ~= expectedRetained then
    addError("SUPPLY_RETAINED_MISMATCH", "retained=" .. tostring(retained)
      .. " expected=" .. tostring(expectedRetained))
  end
  if state.totalReservedInbound ~= state.totalReservedOutbound then
    addError("RESERVATION_TOTAL_MISMATCH", "in=" .. state.totalReservedInbound
      .. " out=" .. state.totalReservedOutbound)
  end
  if #state.tasks ~= 20 then
    addWarning("EXPECTED_STRESS_PACKET_COUNT_CHANGED", "expected=20 actual=" .. #state.tasks)
  end

  state.configurationValid = #state.errors == 0
  log(state.configurationValid and "INFO" or "ERROR", "initial_fill_plan_created", {
    configurationVersion = config.configurationVersion,
    buildTimestamp = build and build.buildTimestamp or "unknown",
    supplySiteId = supplySiteId,
    totalPersonnel = totalPersonnel,
    retainedAtSupply = retained,
    reservedPersonnel = state.totalReservedOutbound,
    taskCount = #state.tasks,
    maxPacketStrength = maxPacketStrength,
    maxConcurrentTasks = config.execution and config.execution.maxActiveTasks or "unknown",
    optimizationPrimary = config.initialFill.optimization and config.initialFill.optimization.primary or "unknown",
    optimizationSecondary = config.initialFill.optimization and config.initialFill.optimization.secondary or "unknown",
    optimizationTertiary = config.initialFill.optimization and config.initialFill.optimization.tertiary or "unknown",
    errorCount = #state.errors,
    warningCount = #state.warnings,
  })

  return state
end

return TM02W2FInitialFillPlanner
