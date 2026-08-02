-- Operation Mountain Watch - Kandahar Heliport warehouse read-only audit.
-- This diagnostic does not construct AIRWING/SQUADRON objects, spawn assets,
-- create missions, or mutate parking.
local TAG = "[OMW][AirOps.KAF.HeliWarehouse]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local MAIN_AIRBASE_NAME = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar or "Kandahar"
local HELIPORT_AIRBASE_NAME = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar_Heliport or "Kandahar Heliport"
local MAIN_WAREHOUSE_NAME = "WH_AIR_US_KANDAHAR"
local HELIPORT_WAREHOUSE_NAME = "WH_AIR_US_KANDAHAR_HELI"
local MIN_PARKING_CLEARANCE_METERS = 25
local MAX_HELIPORT_ASSOCIATION_METERS = 500

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function nearestParking(coordinate, airbase)
  local nearest, nearestDistance = nil, nil
  local spots = airbase and airbase:GetParkingSpotsTable() or {}
  for _, spot in ipairs(spots) do
    local d = distance2D(coordinate, spot.Coordinate)
    if d and (not nearestDistance or d < nearestDistance) then
      nearest = spot
      nearestDistance = d
    end
  end
  return nearest, nearestDistance, #spots
end

local function countExactStatic(name)
  local count = 0
  local set = SET_STATIC:New():FilterPrefixes(name):FilterOnce()
  set:ForEachStatic(function(static)
    if static:GetName() == name then count = count + 1 end
  end)
  return count
end

local function validateAirbase(name, expectedID, role)
  local airbase = AIRBASE:FindByName(name)
  if not airbase then
    return nil, "AIRBASE_MISSING role=" .. role .. " name=" .. tostring(name)
  end
  if tonumber(airbase:GetID()) ~= tonumber(expectedID) then
    return nil, string.format(
      "AIRBASE_ID_MISMATCH role=%s expected=%s actual=%s",
      role,
      tostring(expectedID),
      tostring(airbase:GetID())
    )
  end
  log(string.format(
    "AIRBASE_OK role=%s name=%s id=%s category=%s",
    role,
    tostring(airbase:GetName()),
    tostring(airbase:GetID()),
    tostring(airbase:GetCategoryName())
  ))
  return airbase, nil
end

local function validateWarehouse(name, expectedType, role)
  local exactCount = countExactStatic(name)
  if exactCount ~= 1 then
    return nil, string.format(
      "WAREHOUSE_COUNT_MISMATCH role=%s name=%s expected=1 actual=%d",
      role,
      name,
      exactCount
    )
  end

  local anchor = STATIC:FindByName(name, false)
  if not anchor then
    return nil, "WAREHOUSE_STATIC_MISSING role=" .. role .. " name=" .. name
  end
  if tostring(anchor:GetTypeName()) ~= expectedType then
    return nil, string.format(
      "WAREHOUSE_TYPE_MISMATCH role=%s name=%s expected=%s actual=%s",
      role,
      name,
      expectedType,
      tostring(anchor:GetTypeName())
    )
  end
  if tonumber(anchor:GetCoalition()) ~= 2 then
    return nil, string.format(
      "WAREHOUSE_COALITION_MISMATCH role=%s name=%s expected=2 actual=%s",
      role,
      name,
      tostring(anchor:GetCoalition())
    )
  end

  local vec3 = anchor:GetCoordinate():GetVec3()
  log(string.format(
    "WAREHOUSE_OK role=%s name=%s type=%s coalition=%s x=%.1f y=%.1f z=%.1f",
    role,
    tostring(anchor:GetName()),
    tostring(anchor:GetTypeName()),
    tostring(anchor:GetCoalition()),
    tonumber(vec3.x) or 0,
    tonumber(vec3.y) or 0,
    tonumber(vec3.z) or 0
  ))
  return anchor, nil
end

local function main()
  log("BEGIN noSpawn=true noParkingMutation=true runtimeReady=false")

  if not AIRBASE or not STATIC or not SET_STATIC then
    log("RESULT: FAIL reason=REQUIRED_MOOSE_CLASSES_UNAVAILABLE noSpawn=true")
    return
  end

  local mainAirbase, mainAirbaseError = validateAirbase(MAIN_AIRBASE_NAME, 7, "MAIN")
  if not mainAirbase then
    log("RESULT: FAIL reason=" .. tostring(mainAirbaseError) .. " noSpawn=true")
    return
  end

  local heliport, heliportError = validateAirbase(HELIPORT_AIRBASE_NAME, 15, "HELIPORT")
  if not heliport then
    log("RESULT: FAIL reason=" .. tostring(heliportError) .. " noSpawn=true")
    return
  end

  local mainWarehouse, mainWarehouseError = validateWarehouse(MAIN_WAREHOUSE_NAME, "container_40ft", "MAIN")
  if not mainWarehouse then
    log("RESULT: FAIL reason=" .. tostring(mainWarehouseError) .. " noSpawn=true")
    return
  end

  local heliWarehouse, heliWarehouseError = validateWarehouse(HELIPORT_WAREHOUSE_NAME, "container_20ft", "HELIPORT")
  if not heliWarehouse then
    log("RESULT: FAIL reason=" .. tostring(heliWarehouseError) .. " noSpawn=true")
    return
  end

  local heliSpot, heliDistance, heliParkingCount = nearestParking(heliWarehouse:GetCoordinate(), heliport)
  local mainSpot, mainDistance, mainParkingCount = nearestParking(heliWarehouse:GetCoordinate(), mainAirbase)

  if not heliSpot or not heliDistance or heliParkingCount == 0 then
    log("RESULT: FAIL reason=HELIPORT_PARKING_UNAVAILABLE noSpawn=true")
    return
  end
  if not mainSpot or not mainDistance or mainParkingCount == 0 then
    log("RESULT: FAIL reason=MAIN_PARKING_UNAVAILABLE noSpawn=true")
    return
  end
  if heliDistance < MIN_PARKING_CLEARANCE_METERS then
    log(string.format(
      "RESULT: FAIL reason=HELIPORT_WAREHOUSE_OVERLAPS_PARKING TerminalID=%s distance=%.2f minimum=%d noSpawn=true",
      tostring(heliSpot.TerminalID),
      heliDistance,
      MIN_PARKING_CLEARANCE_METERS
    ))
    return
  end
  if heliDistance > MAX_HELIPORT_ASSOCIATION_METERS then
    log(string.format(
      "RESULT: FAIL reason=HELIPORT_WAREHOUSE_TOO_FAR TerminalID=%s distance=%.2f maximum=%d noSpawn=true",
      tostring(heliSpot.TerminalID),
      heliDistance,
      MAX_HELIPORT_ASSOCIATION_METERS
    ))
    return
  end
  if heliDistance >= mainDistance then
    log(string.format(
      "RESULT: FAIL reason=HELIPORT_WAREHOUSE_CLOSER_TO_MAIN heliportDistance=%.2f mainDistance=%.2f noSpawn=true",
      heliDistance,
      mainDistance
    ))
    return
  end

  log(string.format(
    "ASSOCIATION_OK warehouse=%s heliportTerminalID=%s heliportType=%s heliportDistance=%.2f mainTerminalID=%s mainType=%s mainDistance=%.2f heliportParking=%d mainParking=%d",
    HELIPORT_WAREHOUSE_NAME,
    tostring(heliSpot.TerminalID),
    tostring(heliSpot.TerminalType),
    heliDistance,
    tostring(mainSpot.TerminalID),
    tostring(mainSpot.TerminalType),
    mainDistance,
    heliParkingCount,
    mainParkingCount
  ))

  log(string.format(
    "RESULT: PASS warehouseContract=true mainWarehouse=true heliportWarehouse=true heliportWarehouseName=%s heliportNearestTerminalID=%s heliportDistance=%.2f noSpawn=true noParkingMutation=true runtimeReady=false remainingBlocker=HELIPORT_AIRWING_NAME_UNAPPROVED",
    HELIPORT_WAREHOUSE_NAME,
    tostring(heliSpot.TerminalID),
    heliDistance
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 7)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 7)
end
