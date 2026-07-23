do
  local PREFIX = "[OMW][AIR-OPS][AIRCRAFT-TYPES]"
  local START_DELAY_SECONDS = 3

  local candidates = {
    { role = "Jalalabad player/recon", typeName = "OH58D" },
    { role = "Jalalabad player/CAS", typeName = "AH-64D_BLK_II" },
    { role = "Jalalabad AI utility/MEDEVAC core candidate", typeName = "UH-60A" },
    { role = "Jalalabad player/MEDEVAC community candidate", typeName = "UH-60L" },
    { role = "Heavy lift player", typeName = "CH-47Fbl1" },
    { role = "Heavy lift AI legacy candidate", typeName = "CH-47D" },
    { role = "Tactical airlift AI", typeName = "C-130" },
    { role = "Strategic airlift AI", typeName = "C-17A" },
    { role = "Bagram player/strike", typeName = "F-15ESE" },
    { role = "Kandahar player/CAS", typeName = "A-10C_2" },
    { role = "Camp Bastion AI attack", typeName = "AH-1W" },
    { role = "Camp Bastion AI heavy lift", typeName = "CH-53E" },
    { role = "Legacy utility player", typeName = "UH-1H" },
    { role = "Legacy risk module", typeName = "AV8BNA" },
  }

  local categoryNames = {
    [0] = "AIRPLANE",
    [1] = "HELICOPTER",
    [2] = "GROUND_UNIT",
    [3] = "SHIP",
    [4] = "STRUCTURE",
  }

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

  local function safeNumber(value)
    if type(value) == "number" then
      return string.format("%.2f", value)
    end
    return "n/a"
  end

  local function dimensions(desc)
    if type(desc) ~= "table" or type(desc.box) ~= "table" then
      return "n/a"
    end
    local min = desc.box.min
    local max = desc.box.max
    if type(min) ~= "table" or type(max) ~= "table" then
      return "n/a"
    end
    local length = (max.x or 0) - (min.x or 0)
    local height = (max.y or 0) - (min.y or 0)
    local width = (max.z or 0) - (min.z or 0)
    return string.format("L=%.2f H=%.2f W=%.2f", length, height, width)
  end

  local function attributeList(desc)
    if type(desc) ~= "table" or type(desc.attributes) ~= "table" then
      return ""
    end
    local names = {}
    for name, enabled in pairs(desc.attributes) do
      if enabled then
        names[#names + 1] = tostring(name)
      end
    end
    table.sort(names)
    return table.concat(names, ",")
  end

  local function run()
    log("INFO", "BEGIN")
    if type(Unit) ~= "table" or type(Unit.getDescByName) ~= "function" then
      log("ERROR", "Unit.getDescByName is unavailable in this mission scripting environment")
      log("INFO", "END result=FAILED")
      return nil
    end

    for _, candidate in ipairs(candidates) do
      local ok, desc = pcall(Unit.getDescByName, candidate.typeName)
      if not ok then
        log("ERROR", string.format(
          "type=%s role=%s query=ERROR detail=%s",
          candidate.typeName,
          candidate.role,
          tostring(desc)
        ))
      elseif type(desc) ~= "table" then
        log("WARN", string.format(
          "type=%s role=%s available=NO",
          candidate.typeName,
          candidate.role
        ))
      else
        log("INFO", string.format(
          "type=%s role=%s available=YES displayName=%s category=%s(%s) massEmpty=%s speedMax=%s dimensions=%s attributes=%s",
          candidate.typeName,
          candidate.role,
          tostring(desc.displayName or desc.typeName or "n/a"),
          tostring(desc.category),
          categoryNames[desc.category] or "UNKNOWN",
          safeNumber(desc.massEmpty),
          safeNumber(desc.speedMax),
          dimensions(desc),
          attributeList(desc)
        ))
      end
    end

    log("INFO", "END result=COMPLETE")
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
