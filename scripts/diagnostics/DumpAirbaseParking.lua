do
  local PREFIX = "[OMW][AIR-OPS][PARKING]"
  local AIRBASE_NAME = "Jalalabad"
  local START_DELAY_SECONDS = 5

  local terminalTypeNames = {
    [16] = "RUNWAY",
    [40] = "HELICOPTER_ONLY",
    [68] = "SHELTER",
    [72] = "OPEN_MEDIUM",
    [104] = "OPEN_BIG",
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

  local function terminalTypeName(value)
    return terminalTypeNames[value] or ("UNKNOWN_" .. tostring(value))
  end

  local function latitudeLongitude(vec3)
    if type(coord) ~= "table" or type(coord.LOtoLL) ~= "function" then
      return "lat=n/a lon=n/a"
    end
    local ok, lat, lon = pcall(coord.LOtoLL, vec3)
    if not ok or type(lat) ~= "number" or type(lon) ~= "number" then
      return "lat=n/a lon=n/a"
    end
    return string.format("lat=%.7f lon=%.7f", lat, lon)
  end

  local function run()
    log("INFO", "BEGIN airbase=" .. AIRBASE_NAME)

    if type(AIRBASE) ~= "table" or type(AIRBASE.FindByName) ~= "function" then
      log("ERROR", "MOOSE AIRBASE wrapper is unavailable; verify Moose.lua load order")
      log("INFO", "END result=FAILED")
      return nil
    end

    local airbase = AIRBASE:FindByName(AIRBASE_NAME)
    if not airbase then
      log("ERROR", "Airbase not found by exact MOOSE name")
      log("INFO", "Known Afghanistan enum value=" .. tostring(AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad))
      log("INFO", "END result=FAILED")
      return nil
    end

    local vec2 = airbase:GetVec2()
    log("INFO", string.format(
      "airbaseFound=YES name=%s id=%s category=%s centerX=%.2f centerY=%.2f",
      tostring(airbase:GetName()),
      tostring(airbase:GetID(true)),
      tostring(airbase:GetCategoryName()),
      vec2 and vec2.x or -1,
      vec2 and vec2.y or -1
    ))

    local spots = airbase:GetParkingSpotsTable() or {}
    table.sort(spots, function(a, b)
      return (a.TerminalID or -1) < (b.TerminalID or -1)
    end)

    local counts = {}
    for _, spot in ipairs(spots) do
      counts[spot.TerminalType] = (counts[spot.TerminalType] or 0) + 1
      local vec3 = spot.Vec3 or (spot.Coordinate and spot.Coordinate:GetVec3()) or {}
      log("INFO", string.format(
        "spot terminalId=%s terminalId0=%s type=%s(%s) free=%s toac=%s clientSpot=%s clientName=%s x=%.2f y=%.2f z=%.2f %s",
        tostring(spot.TerminalID),
        tostring(spot.TerminalID0),
        tostring(spot.TerminalType),
        terminalTypeName(spot.TerminalType),
        tostring(spot.Free),
        tostring(spot.TOAC),
        tostring(spot.ClientSpot),
        tostring(spot.ClientName),
        vec3.x or -1,
        vec3.y or -1,
        vec3.z or -1,
        latitudeLongitude(vec3)
      ))
    end

    local countParts = {}
    for typeId, count in pairs(counts) do
      countParts[#countParts + 1] = string.format("%s(%s)=%d", tostring(typeId), terminalTypeName(typeId), count)
    end
    table.sort(countParts)

    log("INFO", string.format("summary total=%d %s", #spots, table.concat(countParts, " ")))
    log("INFO", "NOTE terminalId is the MOOSE/DCS scripting parking ID and can differ from the label shown in Mission Editor")
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
