  local damageConfig = config.transitions or {}
  local damageCaptureTolerancePercent = damageConfig.damageCaptureTolerancePercent or 0.05
  local damageRestoreTolerancePercent = damageConfig.damageRestoreTolerancePercent or 1
  local damageRestoreRetrySeconds = damageConfig.damageRestoreRetrySeconds or 1
  local damageRestoreMaxAttempts = damageConfig.damageRestoreMaxAttempts or 5

  local positiveDamageSettings = {
    { damageCaptureTolerancePercent, "damageCaptureTolerancePercent" },
    { damageRestoreTolerancePercent, "damageRestoreTolerancePercent" },
    { damageRestoreRetrySeconds, "damageRestoreRetrySeconds" },
    { damageRestoreMaxAttempts, "damageRestoreMaxAttempts" },
  }
  for _, setting in ipairs(positiveDamageSettings) do
    if type(setting[1]) ~= "number" or setting[1] <= 0 then
      error(setting[2] .. " must be a positive number")
    end
  end
  if damageRestoreMaxAttempts ~= math.floor(damageRestoreMaxAttempts) then
    error("damageRestoreMaxAttempts must be an integer")
  end
  if type(UNIT) ~= "table"
    or type(UNIT.GetLifeRelative) ~= "function"
    or type(UNIT.SetLife) ~= "function" then
    error("TM01C damage persistence requires UNIT:GetLifeRelative and UNIT:SetLife")
  end
  if type(net) ~= "table" or type(net.dostring_in) ~= "function" then
    error("TM01C damage persistence requires net.dostring_in")
  end

  local function containsStableSlot(stableSlots, requestedSlot)
    for _, stableSlot in ipairs(stableSlots or {}) do
      if stableSlot == requestedSlot then
        return true
      end
    end
    return false
  end

  local function formatLifeMap(values)
    local parts = {}
    for _, stableSlot in ipairs(controller.entity.survivingVehicleSlotsRearToFront or {}) do
      local percent = values and values[stableSlot]
      parts[#parts + 1] = tostring(stableSlot)
        .. ":"
        .. string.format("%.2f", type(percent) == "number" and percent or 100)
    end
    return #parts > 0 and table.concat(parts, ",") or "none"
  end

  local originalCommonFields = commonFields
  commonFields = function()
    local fields = originalCommonFields()
    fields.vehicleLifePercentByStableSlot = formatLifeMap(
      controller.entity.vehicleLifePercentByStableSlot
    )
    fields.pendingRouteActivation = controller.pendingRouteActivation ~= nil
    return fields
  end

  local function readLifePercent(unit)
    local ok, relativeOrError = pcall(function()
      return unit:GetLifeRelative()
    end)
    if not ok then
      return nil, relativeOrError
    end
    if type(relativeOrError) ~= "number" or relativeOrError < 0 then
      return nil, "relative life is unavailable"
    end
    return clamp(relativeOrError * 100, 0, 100), nil
  end

  local function lifeMapsEqual(left, right, survivors)
    for _, stableSlot in ipairs(survivors or {}) do
      local leftValue = left and left[stableSlot]
      local rightValue = right and right[stableSlot]
      if type(leftValue) ~= "number" or type(rightValue) ~= "number" then
        return false
      end
      if math.abs(leftValue - rightValue) > damageCaptureTolerancePercent then
        return false
      end
    end
    for stableSlot in pairs(left or {}) do
      if not containsStableSlot(survivors, stableSlot) then
        return false
      end
    end
    for stableSlot in pairs(right or {}) do
      if not containsStableSlot(survivors, stableSlot) then
        return false
      end
    end
    return true
  end

  local function commitLifeMap(newMap, eventName)
    local survivors = controller.entity.survivingVehicleSlotsRearToFront
    local oldMap = controller.entity.vehicleLifePercentByStableSlot or {}
    if lifeMapsEqual(oldMap, newMap, survivors) then
      return true
    end

    local damagedVehicleCount = 0
    local minimumLifePercent = 100
    for _, stableSlot in ipairs(survivors) do
      local percent = newMap[stableSlot]
      if type(percent) ~= "number" then
        return false, "life map is incomplete for stable slot " .. tostring(stableSlot)
      end
      if percent < 99.95 then
        damagedVehicleCount = damagedVehicleCount + 1
      end
      minimumLifePercent = math.min(minimumLifePercent, percent)
    end

    updateEntity({ vehicleLifePercentByStableSlot = newMap })
    logInfo(eventName or "convoy_damage_state_updated", {
      damagedVehicleCount = damagedVehicleCount,
      minimumLifePercent = minimumLifePercent,
    })
    return true
  end

  local function captureExpandedLifeState(liveItems)
    local newMap = {}
    for _, item in ipairs(liveItems or {}) do
      if containsStableSlot(
        controller.entity.survivingVehicleSlotsRearToFront,
        item.stableSlot
      ) then
        local percent, lifeError = readLifePercent(item.unit)
        if not percent then
          return false,
            "could not read life for stable slot "
              .. tostring(item.stableSlot)
              .. ": "
              .. tostring(lifeError)
        end
        newMap[item.stableSlot] = percent
      end
    end
    return commitLifeMap(newMap, "convoy_damage_state_updated")
  end

  local function captureCollapsedLeadLifeState(leadItem)
    local newMap = deepCopy(controller.entity.vehicleLifePercentByStableSlot or {})
    for _, stableSlot in ipairs(controller.entity.survivingVehicleSlotsRearToFront) do
      if type(newMap[stableSlot]) ~= "number" then
        newMap[stableSlot] = 100
      end
    end
    local percent, lifeError = readLifePercent(leadItem.unit)
    if not percent then
      return false,
        "could not read proxy life for stable slot "
          .. tostring(leadItem.stableSlot)
          .. ": "
          .. tostring(lifeError)
    end
    newMap[leadItem.stableSlot] = percent
    return commitLifeMap(newMap, "convoy_proxy_damage_state_updated")
  end

  local originalSynchronizeExpandedSurvivors = synchronizeExpandedSurvivors
  synchronizeExpandedSurvivors = function(liveItems)
    local syncOk, leadOrError = originalSynchronizeExpandedSurvivors(liveItems)
    if not syncOk then
      return false, leadOrError
    end
    if controller.pendingRouteActivation then
      return true, leadOrError
    end
    local damageOk, damageError = captureExpandedLifeState(liveItems)
    if not damageOk then
      return false, damageError
    end
    return true, leadOrError
  end

  local originalCurrentLeadItem = currentLeadItem
  currentLeadItem = function()
    local leadItem, leadError = originalCurrentLeadItem()
    if not leadItem then
      return nil, leadError
    end
    if controller.pendingRouteActivation then
      return leadItem, nil
    end
    if controller.entity.representationState == REPRESENTATION_COLLAPSED then
      local damageOk, damageError = captureCollapsedLeadLifeState(leadItem)
      if not damageOk then
        return nil, damageError
      end
    end
    return leadItem, nil
  end

  local function applyStoredDamage(active)
    local units = active.group:GetUnits()
    if type(units) ~= "table" then
      return false, "runtime units are unavailable during damage restore"
    end

    local restoredCount = 0
    local lifeMap = controller.entity.vehicleLifePercentByStableSlot or {}
    for _, unit in pairs(units) do
      if unit and unit:IsAlive() == true then
        local runtimeIndex = parseRuntimeIndex(unit:GetName())
        local stableSlot = runtimeIndex
          and controller.entity.runtimeIndexToStableSlot[runtimeIndex]
        if not stableSlot then
          return false, "damage restore has no stable slot for runtime unit"
        end
        local targetPercent = lifeMap[stableSlot]
        if type(targetPercent) ~= "number" then
          targetPercent = 100
        end
        targetPercent = clamp(targetPercent, 0.01, 100)
        if targetPercent < 99.95 then
          local setOk, setError = pcall(function()
            unit:SetLife(targetPercent)
          end)
          if not setOk then
            return false,
              "could not restore life for stable slot "
                .. tostring(stableSlot)
                .. ": "
                .. tostring(setError)
          end
          restoredCount = restoredCount + 1
        end
      end
    end

    active.damageApplyAttempts = active.damageApplyAttempts + 1
    active.damageAppliedAt = timer.getTime()
    logInfo("convoy_damage_restore_applied", {
      context = active.context,
      restoredVehicleCount = restoredCount,
      damageApplyAttempts = active.damageApplyAttempts,
    })
    return true
  end

  local function verifyStoredDamage(active)
    local units = active.group:GetUnits()
    if type(units) ~= "table" then
      return false, "runtime units are unavailable during damage verification"
    end

    local lifeMap = controller.entity.vehicleLifePercentByStableSlot or {}
    local verifiedDamagedCount = 0
    for _, unit in pairs(units) do
      if unit and unit:IsAlive() == true then
        local runtimeIndex = parseRuntimeIndex(unit:GetName())
        local stableSlot = runtimeIndex
          and controller.entity.runtimeIndexToStableSlot[runtimeIndex]
        if not stableSlot then
          return false, "damage verification has no stable slot for runtime unit"
        end
        local targetPercent = lifeMap[stableSlot]
        if type(targetPercent) == "number" and targetPercent < 99.95 then
          local actualPercent, lifeError = readLifePercent(unit)
          if not actualPercent then
            return false, lifeError
          end
          if math.abs(actualPercent - targetPercent) > damageRestoreTolerancePercent then
            return false,
              "life verification differs for stable slot "
                .. tostring(stableSlot)
                .. "; expected="
                .. tostring(targetPercent)
                .. "; actual="
                .. tostring(actualPercent)
          end
          verifiedDamagedCount = verifiedDamagedCount + 1
        end
      end
    end

    logInfo("convoy_damage_restore_confirmed", {
      context = active.context,
      verifiedDamagedVehicleCount = verifiedDamagedCount,
      damageApplyAttempts = active.damageApplyAttempts,
    })
    return true
  end
