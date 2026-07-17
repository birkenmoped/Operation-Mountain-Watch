local TM02VLeaderProxyAdapter = {}

local function deepCopy(source, seen)
  if type(source) ~= "table" then
    return source
  end
  seen = seen or {}
  if seen[source] then
    return seen[source]
  end
  local result = {}
  seen[source] = result
  for key, value in pairs(source) do
    result[deepCopy(key, seen)] = deepCopy(value, seen)
  end
  return result
end

local function startsWith(value, prefix)
  return type(value) == "string"
    and type(prefix) == "string"
    and value:sub(1, #prefix) == prefix
end

local function deriveLeaderSpawner(rule, templateGroupName, alias)
  local sourceSpawner = SPAWN:New(templateGroupName)
  if type(sourceSpawner) ~= "table"
    or type(sourceSpawner.SpawnTemplate) ~= "table"
    or type(sourceSpawner.SpawnTemplate.units) ~= "table" then
    error("SPAWN source template data is unavailable for " .. tostring(templateGroupName))
  end

  local reducedTemplate = deepCopy(sourceSpawner.SpawnTemplate)
  local sourceUnit = reducedTemplate.units[rule.sourceUnitIndex]
  if type(sourceUnit) ~= "table" then
    error(
      "leader unit slot "
        .. tostring(rule.sourceUnitIndex)
        .. " is unavailable in "
        .. tostring(templateGroupName)
    )
  end
  reducedTemplate.units = { deepCopy(sourceUnit) }

  local categoryId = reducedTemplate.CategoryID
  local countryId = reducedTemplate.CountryID
  local coalitionId = reducedTemplate.CoalitionID
  if type(categoryId) ~= "number"
    or type(countryId) ~= "number"
    or type(coalitionId) ~= "number" then
    error("derived leader template coalition metadata is unavailable")
  end

  local spawner = SPAWN:NewFromTemplate(
    reducedTemplate,
    alias .. "_LEADER_TEMPLATE",
    alias
  )
  if type(spawner) ~= "table" then
    error("SPAWN:NewFromTemplate returned no leader spawner")
  end
  spawner:InitCategory(categoryId)
  spawner:InitCountry(countryId)
  spawner:InitCoalition(coalitionId)

  env.info(
    "[OMW][TM02V] level=INFO event=red_proxy_leader_template_derived"
      .. " sourceTemplate=" .. tostring(templateGroupName)
      .. " sourceUnitIndex=" .. tostring(rule.sourceUnitIndex)
      .. " alias=" .. tostring(alias)
  )
  return spawner
end

function TM02VLeaderProxyAdapter.install(config)
  if type(config) ~= "table" or type(config.proxy) ~= "table" then
    error("TM02V proxy configuration is unavailable")
  end
  if type(config.templatesByStrength) ~= "table"
    or type(config.movement) ~= "table"
    or type(config.movement.strength) ~= "number" then
    error("TM02V movement template configuration is unavailable")
  end
  if type(SPAWN) ~= "table"
    or type(SPAWN.NewWithAlias) ~= "function"
    or type(SPAWN.NewFromTemplate) ~= "function" then
    error("MOOSE SPAWN API is unavailable")
  end

  local sourceUnitIndex = config.proxy.sourceUnitIndex or 1
  if type(sourceUnitIndex) ~= "number"
    or sourceUnitIndex % 1 ~= 0
    or sourceUnitIndex < 1 then
    error("proxy sourceUnitIndex must be a positive integer")
  end
  local movementTemplateName = config.templatesByStrength[config.movement.strength]
  if type(movementTemplateName) ~= "string" or movementTemplateName == "" then
    error("movement-strength template is unavailable for the leader proxy")
  end

  config.proxy.templateGroupName = movementTemplateName
  config.proxy.sourcePolicy = "LEADER_FROM_MOVEMENT_TEMPLATE"
  config.proxy.sourceUnitIndex = sourceUnitIndex

  SPAWN.__OMWLeaderProxyRules = SPAWN.__OMWLeaderProxyRules or {}
  SPAWN.__OMWLeaderProxyRules[config.proxy.runtimeAliasPrefix] = {
    runtimeAliasPrefix = config.proxy.runtimeAliasPrefix,
    sourceUnitIndex = sourceUnitIndex,
  }

  if SPAWN.__OMWLeaderProxyPatched ~= true then
    SPAWN.__OMWLeaderProxyOriginalNewWithAlias = SPAWN.NewWithAlias
    function SPAWN:NewWithAlias(templateGroupName, alias)
      for _, rule in pairs(SPAWN.__OMWLeaderProxyRules or {}) do
        if startsWith(alias, rule.runtimeAliasPrefix) then
          return deriveLeaderSpawner(rule, templateGroupName, alias)
        end
      end
      return SPAWN.__OMWLeaderProxyOriginalNewWithAlias(self, templateGroupName, alias)
    end
    SPAWN.__OMWLeaderProxyPatched = true
  end

  env.info(
    "[OMW][TM02V] level=INFO event=red_proxy_leader_adapter_installed"
      .. " sourcePolicy=LEADER_FROM_MOVEMENT_TEMPLATE"
      .. " sourceTemplate=" .. tostring(movementTemplateName)
      .. " sourceUnitIndex=" .. tostring(sourceUnitIndex)
      .. " runtimeAliasPrefix=" .. tostring(config.proxy.runtimeAliasPrefix)
  )
  return true
end

return TM02VLeaderProxyAdapter
