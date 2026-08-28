do
  local PREFIX = "[OMW][AIR-OPS][TEMPLATE-VALIDATION]"
  local START_DELAY_SECONDS = 9

  local requiredGroups = {
    { name = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP", size = 2, acceptedTypes = { "OH58D" } },
    { name = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP", size = 2, acceptedTypes = { "AH-64D_BLK_II" } },
    { name = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP", size = 1, acceptedTypes = { "UH-60A", "UH-60L" } },
    { name = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP", size = 1, acceptedTypes = { "UH-60A", "UH-60L" } },
  }

  local requiredClientGroups = {
    "CLIENT_US_JBAD_OH58D_01",
    "CLIENT_US_JBAD_OH58D_02",
    "CLIENT_US_JBAD_OH58D_03",
    "CLIENT_US_JBAD_OH58D_04",
    "CLIENT_US_JBAD_AH64D_01",
    "CLIENT_US_JBAD_AH64D_02",
    "CLIENT_US_JBAD_AH64D_03",
    "CLIENT_US_JBAD_AH64D_04",
  }

  local optionalClientGroups = {
    "CLIENT_US_JBAD_UH60L_01",
    "CLIENT_US_JBAD_UH60L_02",
    "CLIENT_US_JBAD_UH60L_03",
    "CLIENT_US_JBAD_UH60L_04",
  }

  local requiredZones = {
    "ZONE_AIR_US_JBAD_STATIC_OH58D",
    "ZONE_AIR_US_JBAD_STATIC_AH64D",
    "ZONE_AIR_US_JBAD_STATIC_UH60",
    "ZONE_AIR_US_JBAD_MEDEVAC_READY",
    "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_JBAD_SLING_PICKUP",
    "ZONE_AIR_US_JBAD_C130_UNLOAD",
  }

  local requiredStaticPrefixes = {
    { prefix = "STATIC_AIR_US_JBAD_OH58D_", expected = 8 },
    { prefix = "STATIC_AIR_US_JBAD_AH64D_", expected = 4 },
    { prefix = "STATIC_AIR_US_JBAD_UH60_", expected = 2 },
  }

  local expectedWarehouseAnchor = "WH_AIR_US_JALALABAD"

  local function log(level, message)
    local text = string.format("%s %s", PREFIX, message)
    if level == "ERROR" then
      env.error(text, false)
    elseif level == "WARN" then
      env.warning(text, false)
    else
      env.info(text, false)
    end
  end

  local function includes(list, value)
    for _, item in ipairs(list) do
      if item == value then return true end
    end
    return false
  end

  local function validateGroup(spec)
    local group = GROUP and GROUP:FindByName(spec.name) or nil
    if not group then
      log("ERROR", "missingGroup=" .. spec.name)
      return false
    end

    local ok = true
    local initialSize = group:GetInitialSize()
    if initialSize ~= spec.size then
      log("ERROR", string.format("group=%s initialSize=%s expected=%s", spec.name, tostring(initialSize), tostring(spec.size)))
      ok = false
    end

    local units = group:GetUnits() or {}
    for index, unit in ipairs(units) do
      local typeName = unit:GetTypeName()
      if not includes(spec.acceptedTypes, typeName) then
        log("ERROR", string.format(
          "group=%s unitIndex=%d unit=%s type=%s accepted=%s",
          spec.name,
          index,
          tostring(unit:GetName()),
          tostring(typeName),
          table.concat(spec.acceptedTypes, ",")
        ))
        ok = false
      end
    end

    log(ok and "INFO" or "ERROR", string.format("group=%s valid=%s", spec.name, tostring(ok)))
    return ok
  end

  local function validateGroupNames(names, optional)
    local ok = true
    for _, name in ipairs(names) do
      local group = GROUP and GROUP:FindByName(name) or nil
      if group then
        log("INFO", string.format("clientGroup=%s present=YES optional=%s", name, tostring(optional)))
      elseif optional then
        log("WARN", string.format("clientGroup=%s present=NO optional=YES", name))
      else
        log("ERROR", string.format("clientGroup=%s present=NO optional=NO", name))
        ok = false
      end
    end
    return ok
  end

  local function validateZones()
    local ok = true
    for _, name in ipairs(requiredZones) do
      local zone = ZONE and ZONE:FindByName(name) or nil
      if zone then
        log("INFO", "zone=" .. name .. " present=YES")
      else
        log("ERROR", "zone=" .. name .. " present=NO")
        ok = false
      end
    end
    return ok
  end

  local function validateStatics()
    local ok = true
    for _, spec in ipairs(requiredStaticPrefixes) do
      local count = 0
      for index = 1, spec.expected do
        local name = string.format("%s%02d", spec.prefix, index)
        local static = STATIC and STATIC:FindByName(name, false) or nil
        if static then
          count = count + 1
        else
          log("ERROR", "static=" .. name .. " present=NO")
          ok = false
        end
      end
      log(ok and "INFO" or "WARN", string.format("staticPrefix=%s present=%d expected=%d", spec.prefix, count, spec.expected))
    end
    return ok
  end

  local function run()
    log("INFO", "BEGIN")
    local valid = true

    for _, spec in ipairs(requiredGroups) do
      if not validateGroup(spec) then valid = false end
    end

    if not validateGroupNames(requiredClientGroups, false) then valid = false end
    validateGroupNames(optionalClientGroups, true)
    if not validateZones() then valid = false end
    if not validateStatics() then valid = false end

    local anchorStatic = STATIC and STATIC:FindByName(expectedWarehouseAnchor, false) or nil
    local anchorUnit = UNIT and UNIT:FindByName(expectedWarehouseAnchor) or nil
    if anchorStatic or anchorUnit then
      log("INFO", "warehouseAnchor=" .. expectedWarehouseAnchor .. " present=YES")
    else
      log("ERROR", "warehouseAnchor=" .. expectedWarehouseAnchor .. " present=NO")
      valid = false
    end

    log("INFO", "END result=" .. (valid and "PASS" or "FAIL"))
    return nil
  end

  timer.scheduleFunction(function()
    local ok, err = pcall(run)
    if not ok then
      log("ERROR", "Unhandled error: " .. tostring(err))
    end
    return nil
  end, nil, timer.getTime() + START_DELAY_SECONDS)
end
