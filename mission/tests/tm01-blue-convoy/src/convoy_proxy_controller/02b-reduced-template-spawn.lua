  -- SPAWN:NewWithAlias keeps an internally prepared copy of the original
  -- template. Mutating only spawner.SpawnTemplate.units therefore leaves the
  -- internal SpawnGroups template at the original unit count. A reduced
  -- absolute-position list then fails inside MOOSE. Rebuild the spawner from
  -- the genuinely reduced template instead.
  spawnDynamicGroup = function(stableSlotsFrontToRear, positions)
    if type(stableSlotsFrontToRear) ~= "table" or #stableSlotsFrontToRear == 0 then
      return nil, "at least one stable survivor slot is required"
    end
    if type(positions) ~= "table" or #positions ~= #stableSlotsFrontToRear then
      return nil, "spawn position count does not match survivor count"
    end

    local generation = controller.entity.runtimeGeneration + 1
    local alias = config.template.runtimeAliasPrefix
      .. "_G"
      .. string.format("%03d", generation)

    local constructionOk, resultOrError = pcall(function()
      local sourceSpawner = SPAWN:New(config.template.groupName)
      if type(sourceSpawner) ~= "table"
        or type(sourceSpawner.SpawnTemplate) ~= "table"
        or type(sourceSpawner.SpawnTemplate.units) ~= "table" then
        error("SPAWN source template data is unavailable")
      end

      local reducedTemplate = deepCopy(sourceSpawner.SpawnTemplate)
      local sourceUnits = reducedTemplate.units
      local filteredUnits = {}
      for index, stableSlot in ipairs(stableSlotsFrontToRear) do
        local sourceUnit = sourceUnits[stableSlot]
        if type(sourceUnit) ~= "table" then
          error("template unit is unavailable for stable slot " .. tostring(stableSlot))
        end
        filteredUnits[index] = deepCopy(sourceUnit)
      end
      reducedTemplate.units = filteredUnits

      local categoryId = reducedTemplate.CategoryID
      local countryId = reducedTemplate.CountryID
      local coalitionId = reducedTemplate.CoalitionID
      if type(categoryId) ~= "number"
        or type(countryId) ~= "number"
        or type(coalitionId) ~= "number" then
        error("reduced template coalition metadata is unavailable")
      end

      local spawner = SPAWN:NewFromTemplate(
        reducedTemplate,
        alias .. "_TEMPLATE",
        alias
      )
      if type(spawner) ~= "table" then
        error("SPAWN:NewFromTemplate returned no spawner")
      end
      spawner:InitCategory(categoryId)
      spawner:InitCountry(countryId)
      spawner:InitCoalition(coalitionId)
      spawner:InitSetUnitAbsolutePositions(positions)

      local group = spawner:Spawn()
      if type(group) ~= "table" then
        error("SPAWN:Spawn returned no GROUP wrapper")
      end
      return {
        spawner = spawner,
        group = group,
        alias = alias,
        generation = generation,
      }
    end)

    if not constructionOk then
      return nil, resultOrError
    end

    local result = resultOrError
    local inspectionOk, runtimeNameOrError = pcall(function()
      if result.group:IsAlive() ~= true then
        error("spawned runtime group is not alive")
      end
      if result.group:CountAliveUnits() ~= #stableSlotsFrontToRear then
        error("spawned runtime unit count does not match survivor count")
      end
      return result.group:GetName()
    end)
    if not inspectionOk then
      pcall(function()
        result.group:Destroy(false)
      end)
      return nil, runtimeNameOrError
    end

    result.runtimeName = runtimeNameOrError
    result.runtimeIndexToStableSlot = {}
    for index, stableSlot in ipairs(stableSlotsFrontToRear) do
      result.runtimeIndexToStableSlot[index] = stableSlot
    end
    return result, nil
  end
