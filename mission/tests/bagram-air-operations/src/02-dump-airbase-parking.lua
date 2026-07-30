-- Operation Mountain Watch - Bagram parking inventory diagnostic
-- Read-only diagnostic. It does not modify parking, spawn assets, or create missions.
local TAG = "[OMW][AirOps.BGRAM.ParkingDump]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function boolText(value)
  if value == nil then return "nil" end
  return tostring(value)
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Bagram
  if not cfg then
    log("ERROR: Bagram configuration is unavailable.")
    return
  end
  if not AIRBASE then
    log("ERROR: MOOSE AIRBASE class unavailable.")
    return
  end

  local airbase = cfg.Airbase or AIRBASE:FindByName(cfg.AirbaseName)
  if not airbase then
    log("ERROR: Airbase not found: " .. tostring(cfg.AirbaseName))
    return
  end

  local spots = airbase:GetParkingSpotsTable() or {}
  table.sort(spots, function(a, b)
    return (tonumber(a.TerminalID) or -1) < (tonumber(b.TerminalID) or -1)
  end)

  local freeCount = 0
  local occupiedCount = 0
  local typeCounts = {}

  log(string.format(
    "BEGIN airbase=%s id=%s category=%s parkingCount=%d",
    tostring(airbase:GetName()),
    tostring(airbase:GetID()),
    tostring(airbase:GetCategoryName()),
    #spots
  ))

  for _, parking in ipairs(spots) do
    local coordinate = parking.Coordinate
    local vec3 = coordinate and coordinate:GetVec3() or {}
    local terminalType = tostring(parking.TerminalType)
    typeCounts[terminalType] = (typeCounts[terminalType] or 0) + 1

    if parking.Free == true then
      freeCount = freeCount + 1
    else
      occupiedCount = occupiedCount + 1
    end

    log(string.format(
      "SPOT TerminalID=%s TerminalID0=%s Type=%s Free=%s TOAC=%s OccupiedBy=%s x=%.1f y=%.1f z=%.1f",
      tostring(parking.TerminalID),
      tostring(parking.TerminalID0),
      terminalType,
      boolText(parking.Free),
      tostring(parking.TOAC),
      tostring(parking.OccupiedBy),
      tonumber(vec3.x) or 0,
      tonumber(vec3.y) or 0,
      tonumber(vec3.z) or 0
    ))
  end

  local typeKeys = {}
  for terminalType in pairs(typeCounts) do typeKeys[#typeKeys + 1] = terminalType end
  table.sort(typeKeys)
  for _, terminalType in ipairs(typeKeys) do
    log(string.format("TYPE_SUMMARY Type=%s Count=%d", terminalType, typeCounts[terminalType]))
  end

  log(string.format(
    "RESULT parkingCount=%d free=%d occupiedOrReserved=%d typeClasses=%d",
    #spots,
    freeCount,
    occupiedCount,
    #typeKeys
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 3)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 3)
end
