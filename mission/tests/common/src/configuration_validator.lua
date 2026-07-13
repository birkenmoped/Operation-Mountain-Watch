local ConfigurationValidator = {}

local function findObject(finder, name)
  local ok, object = pcall(finder, name)
  if not ok then
    return false, object
  end

  return object ~= nil, nil
end

function ConfigurationValidator.validate(config)
  local missing = {}
  local errors = {}

  local groupFound, groupError = findObject(function(name)
    return GROUP:FindByName(name)
  end, config.template.groupName)

  if not groupFound then
    missing[#missing + 1] = config.template.groupName
  end
  if groupError then
    errors[#errors + 1] = config.template.groupName .. ": " .. tostring(groupError)
  end

  local requiredZones = {
    config.zones.start,
    config.zones.target,
  }

  for _, zoneName in ipairs(config.zones.routeAnchors) do
    requiredZones[#requiredZones + 1] = zoneName
  end

  for _, zoneName in ipairs(requiredZones) do
    local zoneFound, zoneError = findObject(function(name)
      return ZONE:FindByName(name)
    end, zoneName)

    if not zoneFound then
      missing[#missing + 1] = zoneName
    end
    if zoneError then
      errors[#errors + 1] = zoneName .. ": " .. tostring(zoneError)
    end
  end

  return {
    valid = #missing == 0 and #errors == 0,
    missing = missing,
    errors = errors,
    checkedObjectCount = 1 + #requiredZones,
  }
end

return ConfigurationValidator
