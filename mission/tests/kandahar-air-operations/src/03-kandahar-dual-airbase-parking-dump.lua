-- Operation Mountain Watch - Kandahar dual-airbase parking inventory diagnostic.
-- Read-only diagnostic. It does not set blacklists, reserve spots, or spawn assets.
local TAG = "[OMW][AirOps.KAF.ParkingDump]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function boolText(value)
  if value == nil then return "nil" end
  return tostring(value)
end

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function nearestSpot(coordinate, spots)
  local nearest, nearestDistance = nil, nil
  for _, spot in ipairs(spots or {}) do
    local distance = distance2D(coordinate, spot.Coordinate)
    if distance and (not nearestDistance or distance < nearestDistance) then
      nearest = spot
      nearestDistance = distance
    end
  end
  return nearest, nearestDistance
end

local function groupCoordinate(groupName)
  local template = _DATABASE:GetGroupTemplate(groupName)
  local unit = template and template.units and template.units[1] or nil
  if not unit or not unit.x or not unit.y then return nil end
  return COORDINATE:New(unit.x, land.getHeight({ x = unit.x, y = unit.y }), unit.y)
end

local function dumpAirbase(key, airbase)
  local spots = airbase:GetParkingSpotsTable() or {}
  table.sort(spots, function(a, b)
    return (tonumber(a.TerminalID) or -1) < (tonumber(b.TerminalID) or -1)
  end)

  local freeCount = 0
  local occupiedCount = 0
  local typeCounts = {}

  log(string.format(
    "AIRBASE_BEGIN key=%s name=%s id=%s category=%s parkingCount=%d",
    key,
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
      "SPOT key=%s TerminalID=%s TerminalID0=%s Type=%s Free=%s TOAC=%s OccupiedBy=%s DistToRwy=%s x=%.1f y=%.1f z=%.1f",
      key,
      tostring(parking.TerminalID),
      tostring(parking.TerminalID0),
      terminalType,
      boolText(parking.Free),
      tostring(parking.TOAC),
      tostring(parking.OccupiedBy),
      tostring(parking.DistToRwy),
      tonumber(vec3.x) or 0,
      tonumber(vec3.y) or 0,
      tonumber(vec3.z) or 0
    ))
  end

  local typeKeys = {}
  for terminalType in pairs(typeCounts) do typeKeys[#typeKeys + 1] = terminalType end
  table.sort(typeKeys)
  for _, terminalType in ipairs(typeKeys) do
    log(string.format("TYPE_SUMMARY key=%s Type=%s Count=%d", key, terminalType, typeCounts[terminalType]))
  end

  log(string.format(
    "AIRBASE_RESULT key=%s parkingCount=%d free=%d occupiedOrReserved=%d typeClasses=%d",
    key,
    #spots,
    freeCount,
    occupiedCount,
    #typeKeys
  ))

  return spots
end

local function auditClients(cfg, spotsByKey)
  for _, spec in ipairs(cfg.Clients) do
    local coordinate = groupCoordinate(spec.Name)
    local spots = spotsByKey[spec.AirbaseKey]
    if not coordinate or not spots then
      log("CLIENT_NEAREST_FAIL name=" .. spec.Name .. " reason=coordinate_or_airbase_missing")
    else
      local spot, distance = nearestSpot(coordinate, spots)
      log(string.format(
        "CLIENT_NEAREST name=%s airbaseKey=%s TerminalID=%s TerminalID0=%s Type=%s Free=%s distance=%.2f",
        spec.Name,
        spec.AirbaseKey,
        spot and tostring(spot.TerminalID) or "nil",
        spot and tostring(spot.TerminalID0) or "nil",
        spot and tostring(spot.TerminalType) or "nil",
        spot and boolText(spot.Free) or "nil",
        tonumber(distance) or -1
      ))
    end
  end
end

local function auditStatics(spotsByKey)
  local statics = SET_STATIC:New():FilterPrefixes("STATIC_AIR_US_KAF_"):FilterOnce()
  statics:ForEachStatic(function(static)
    local coordinate = static:GetCoordinate()
    local mainSpot, mainDistance = nearestSpot(coordinate, spotsByKey.Main)
    local heliSpot, heliDistance = nearestSpot(coordinate, spotsByKey.Heliport)

    local selectedKey = "Main"
    local selectedSpot = mainSpot
    local selectedDistance = mainDistance
    if heliDistance and (not selectedDistance or heliDistance < selectedDistance) then
      selectedKey = "Heliport"
      selectedSpot = heliSpot
      selectedDistance = heliDistance
    end

    log(string.format(
      "STATIC_NEAREST name=%s type=%s nearestAirbase=%s TerminalID=%s TerminalID0=%s Type=%s Free=%s distance=%.2f mainDistance=%s heliportDistance=%s",
      tostring(static:GetName()),
      tostring(static:GetTypeName()),
      selectedKey,
      selectedSpot and tostring(selectedSpot.TerminalID) or "nil",
      selectedSpot and tostring(selectedSpot.TerminalID0) or "nil",
      selectedSpot and tostring(selectedSpot.TerminalType) or "nil",
      selectedSpot and boolText(selectedSpot.Free) or "nil",
      tonumber(selectedDistance) or -1,
      mainDistance and string.format("%.2f", mainDistance) or "nil",
      heliDistance and string.format("%.2f", heliDistance) or "nil"
    ))
  end)
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.KandaharDiagnostic
  if not cfg then
    log("RESULT: FAIL reason=CONFIG_UNAVAILABLE noSpawn=true")
    return
  end
  if not AIRBASE or not _DATABASE or not COORDINATE or not SET_STATIC then
    log("RESULT: FAIL reason=REQUIRED_MOOSE_API_UNAVAILABLE noSpawn=true")
    return
  end

  local mainAirbase = cfg.AirbaseObjects.Main or AIRBASE:FindByName(cfg.Airbases.Main.Name)
  local heliport = cfg.AirbaseObjects.Heliport or AIRBASE:FindByName(cfg.Airbases.Heliport.Name)
  if not mainAirbase or not heliport then
    log("RESULT: FAIL reason=AIRBASE_UNAVAILABLE noSpawn=true")
    return
  end

  local spotsByKey = {
    Main = dumpAirbase("Main", mainAirbase),
    Heliport = dumpAirbase("Heliport", heliport)
  }

  auditClients(cfg, spotsByKey)
  auditStatics(spotsByKey)

  cfg.ParkingDiagnosticOK = true
  cfg.Status = cfg.ObjectContractOK and "DIAGNOSTIC_COMPLETE" or "DIAGNOSTIC_COMPLETE_WITH_OBJECT_VIOLATIONS"

  log(string.format(
    "RESULT: PASS diagnosticComplete=true objectContract=%s mainParking=%d heliportParking=%d noBlacklistMutation=true noSpawn=true runtimeReady=false",
    tostring(cfg.ObjectContractOK),
    #spotsByKey.Main,
    #spotsByKey.Heliport
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 12)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 12)
end
