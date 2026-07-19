local TM02W2FLaunchSpreadAdapter = {}

local function startsWith(value, prefix)
  return type(value) == "string"
    and type(prefix) == "string"
    and value:sub(1, #prefix) == prefix
end

local function slotIndexFromAlias(alias)
  local value = type(alias) == "string" and alias:match("_SLOT(%d+)_G") or nil
  return value and tonumber(value) or nil
end

function TM02W2FLaunchSpreadAdapter.install(config)
  if SPAWN.__OMWTM02W2FLaunchSpreadInstalled == true then
    return true
  end
  if type(SPAWN) ~= "table" or type(SPAWN.NewWithAlias) ~= "function" then
    error("TM02W2F requires SPAWN.NewWithAlias")
  end
  if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec3) ~= "function" then
    error("TM02W2F requires COORDINATE.NewFromVec3")
  end

  local originalNewWithAlias = SPAWN.NewWithAlias
  SPAWN.NewWithAlias = function(spawnClass, templateName, alias)
    local spawner = originalNewWithAlias(spawnClass, templateName, alias)
    local slotIndex = startsWith(alias, config.proxy.runtimeAliasPrefix)
      and slotIndexFromAlias(alias)
      or nil
    local offset = slotIndex and config.proxy.launchSlots[slotIndex] or nil
    if offset and type(spawner.SpawnFromCoordinate) == "function" then
      local originalSpawnFromCoordinate = spawner.SpawnFromCoordinate
      function spawner:SpawnFromCoordinate(coordinate)
        local point = coordinate and coordinate:GetVec3() or nil
        if not point then
          error("TM02W2F launch portal coordinate unavailable for " .. tostring(alias))
        end
        local spreadCoordinate = COORDINATE:NewFromVec3({
          x = point.x + offset.x,
          y = point.y,
          z = point.z + offset.y,
        })
        env.info(
          "[OMW][TM02W2F] level=INFO event=initial_fill_launch_spread"
            .. " alias=" .. tostring(alias)
            .. " slotIndex=" .. tostring(slotIndex)
            .. " offsetX=" .. tostring(offset.x)
            .. " offsetY=" .. tostring(offset.y)
            .. " launchX=" .. tostring(point.x + offset.x)
            .. " launchZ=" .. tostring(point.z + offset.y)
        )
        return originalSpawnFromCoordinate(self, spreadCoordinate)
      end
    end
    return spawner
  end

  SPAWN.__OMWTM02W2FLaunchSpreadInstalled = true
  env.info(
    "[OMW][TM02W2F] level=INFO event=initial_fill_launch_spread_adapter_installed"
      .. " launchSlotCount=" .. tostring(#config.proxy.launchSlots)
  )
  return true
end

return TM02W2FLaunchSpreadAdapter
