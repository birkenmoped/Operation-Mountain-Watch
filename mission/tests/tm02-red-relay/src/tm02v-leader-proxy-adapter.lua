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

local function movementByAlias(rule, alias)
  for _, movement in ipairs(rule.movements or {}) do
    local expectedPrefix = rule.runtimeAliasPrefix
      .. tostring(movement.runtimeAliasSuffix)
      .. "_G"
    if startsWith(alias, expectedPrefix) then
      return movement
    end
  end
  return nil
end

local function installSeparatedSpawn(spawner, rule, alias)
  local movement = movementByAlias(rule, alias)
  if not movement then
    error("leader proxy alias does not resolve to a configured movement: " .. tostring(alias))
  end

  local offset = movement.launchOffsetMeters
  if type(offset) ~= "table"
    or type(offset.x) ~= "number"
    or type(offset.y) ~= "number" then
    error("leader proxy launchOffsetMeters is unavailable for " .. tostring(movement.packetId))
  end

  if type(spawner.Spawn) ~= "function"
    or type(spawner.InitSetUnitAbsolutePositions) ~= "function" then
    error("MOOSE absolute-position spawn API is unavailable")
  end

  function spawner:SpawnInZone(zone, randomize)
    if randomize ~= false then
      error("TM02V leader proxies require deterministic non-random launch positions")
    end
    if type(zone) ~= "table"
      or type(zone.GetVec2) ~= "function"
      or type(zone.IsVec2InZone) ~= "function" then
      error("TM02V source zone does not expose required vector APIs")
    end

    local center = zone:GetVec2()
    if type(center) ~= "table"
      or type(center.x) ~= "number"
      or type(center.y) ~= "number" then
      error("TM02V source zone center is unavailable")
    end

    local launchVec2 = {
      x = center.x + offset.x,
      y = center.y + offset.y,
    }
    if zone:IsVec2InZone(launchVec2) ~= true then
      error(
        "TM02V launch position is outside source zone for "
          .. tostring(movement.packetId)
      )
    end

    self:InitSetUnitAbsolutePositions({
      {
        x = launchVec2.x,
        y = launchVec2.y,
        heading = movement.launchHeadingDegrees or 0,
      },
    })

    env.info(
      "[OMW][TM02V] level=INFO event=red_proxy_launch_slot_applied"
        .. " packetId=" .. tostring(movement.packetId)
        .. " alias=" .. tostring(alias)
        .. " offsetX=" .. tostring(offset.x)
        .. " offsetY=" .. tostring(offset.y)
        .. " launchX=" .. tostring(launchVec2.x)
        .. " launchY=" .. tostring(launchVec2.y)
    )
    return self:Spawn()
  end
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
  installSeparatedSpawn(spawner, rule, alias)

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
  if type(config.proxy.runtimeAliasPrefix) ~= "string"
    or config.proxy.runtimeAliasPrefix == "" then
    error("proxy runtimeAliasPrefix is required")
  end
  if type(config.movements) ~= "table" or #config.movements < 2 then
    error("TM02V separated proxy launch requires multiple configured movements")
  end

  local seenOffsets = {}
  for _, movement in ipairs(config.movements) do
    local offset = movement.launchOffsetMeters
    if type(offset) ~= "table"
      or type(offset.x) ~= "number"
      or type(offset.y) ~= "number" then
      error("movement launchOffsetMeters must contain numeric x and y")
    end
    local offsetKey = string.format("%.3f:%.3f", offset.x, offset.y)
    if seenOffsets[offsetKey] then
      error("duplicate TM02V proxy launch offset: " .. offsetKey)
    end
    seenOffsets[offsetKey] = true
  end

  SPAWN.__OMWLeaderProxyRules = SPAWN.__OMWLeaderProxyRules or {}
  SPAWN.__OMWLeaderProxyRules[config.proxy.runtimeAliasPrefix] = {
    runtimeAliasPrefix = config.proxy.runtimeAliasPrefix,
    sourceUnitIndex = sourceUnitIndex,
    movements = config.movements,
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
      .. " sourcePolicy=LEADER_FROM_PACKET_TEMPLATE"
      .. " sourceUnitIndex=" .. tostring(sourceUnitIndex)
      .. " runtimeAliasPrefix=" .. tostring(config.proxy.runtimeAliasPrefix)
      .. " separatedLaunchSlots=" .. tostring(#config.movements)
  )
  return true
end

return TM02VLeaderProxyAdapter
