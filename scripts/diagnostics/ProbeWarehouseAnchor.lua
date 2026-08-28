do
  local PREFIX = "[OMW][AIR-OPS][WAREHOUSE-PROBE]"
  local AIRBASE_NAME = "Jalalabad"
  local EXPECTED_ANCHOR_NAME = "WH_AIR_US_JALALABAD"
  local SEARCH_RADIUS_METERS = 2500
  local MAX_NEAREST_SCENERY = 40
  local START_DELAY_SECONDS = 7

  local candidateTokens = {
    "warehouse",
    "storage",
    "depot",
    "hangar",
    "shelter",
    "fuel",
    "tank",
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

  local function safeCall(object, methodName, fallback)
    if not object or type(object[methodName]) ~= "function" then
      return fallback
    end
    local ok, value = pcall(object[methodName], object)
    if not ok then
      return fallback
    end
    return value
  end

  local function containsCandidateToken(value)
    local lower = string.lower(tostring(value or ""))
    for _, token in ipairs(candidateTokens) do
      if string.find(lower, token, 1, true) then
        return true
      end
    end
    return false
  end

  local function distance2D(a, b)
    local dx = (a.x or 0) - (b.x or 0)
    local dz = (a.z or 0) - (b.z or 0)
    return math.sqrt(dx * dx + dz * dz)
  end

  local function describeObject(object, categoryName, centerPoint)
    local name = safeCall(object, "getName", "n/a")
    local typeName = safeCall(object, "getTypeName", "n/a")
    local point = safeCall(object, "getPoint", {}) or {}
    local desc = safeCall(object, "getDesc", {}) or {}
    return {
      categoryName = categoryName,
      name = tostring(name),
      typeName = tostring(typeName),
      displayName = tostring(desc.displayName or "n/a"),
      distance = distance2D(point, centerPoint),
      point = point,
      candidate = containsCandidateToken(name) or containsCandidateToken(typeName) or containsCandidateToken(desc.displayName),
    }
  end

  local function searchCategory(category, categoryName, volume, centerPoint, results)
    local ok, err = pcall(function()
      world.searchObjects(category, volume, function(object)
        results[#results + 1] = describeObject(object, categoryName, centerPoint)
        return true
      end)
    end)
    if not ok then
      log("ERROR", string.format("world.searchObjects failed category=%s detail=%s", categoryName, tostring(err)))
    end
  end

  local function run()
    log("INFO", "BEGIN airbase=" .. AIRBASE_NAME .. " expectedAnchor=" .. EXPECTED_ANCHOR_NAME)

    local airbase = AIRBASE and AIRBASE:FindByName(AIRBASE_NAME) or nil
    if not airbase then
      log("ERROR", "MOOSE airbase not found")
      log("INFO", "END result=FAILED")
      return nil
    end

    local staticAnchor = STATIC and STATIC:FindByName(EXPECTED_ANCHOR_NAME, false) or nil
    local unitAnchor = UNIT and UNIT:FindByName(EXPECTED_ANCHOR_NAME) or nil

    log("INFO", "namedStaticAnchor=" .. tostring(staticAnchor ~= nil))
    log("INFO", "namedUnitAnchor=" .. tostring(unitAnchor ~= nil))

    local dcsWarehouse = nil
    local storage = nil
    local okWarehouse, warehouseResult = pcall(function() return airbase:GetWarehouse() end)
    if okWarehouse then dcsWarehouse = warehouseResult end
    local okStorage, storageResult = pcall(function() return airbase:GetStorage() end)
    if okStorage then storage = storageResult end
    log("INFO", "dcsAirbaseWarehouseAvailable=" .. tostring(dcsWarehouse ~= nil))
    log("INFO", "dcsAirbaseStorageAvailable=" .. tostring(storage ~= nil))
    log("INFO", "NOTE DCS airbase storage is not the named STATIC/UNIT anchor required by AIRWING:New")

    local vec2 = airbase:GetVec2()
    local altitude = 0
    if land and type(land.getHeight) == "function" then
      local okHeight, height = pcall(land.getHeight, { x = vec2.x, y = vec2.y })
      if okHeight and type(height) == "number" then altitude = height end
    end
    local centerPoint = { x = vec2.x, y = altitude, z = vec2.y }
    local volume = {
      id = world.VolumeType.SPHERE,
      params = {
        point = centerPoint,
        radius = SEARCH_RADIUS_METERS,
      },
    }

    local objects = {}
    searchCategory(Object.Category.UNIT, "UNIT", volume, centerPoint, objects)
    searchCategory(Object.Category.STATIC, "STATIC", volume, centerPoint, objects)
    searchCategory(Object.Category.SCENERY, "SCENERY", volume, centerPoint, objects)

    table.sort(objects, function(a, b) return a.distance < b.distance end)

    local counts = { UNIT = 0, STATIC = 0, SCENERY = 0 }
    local sceneryPrinted = 0
    for _, item in ipairs(objects) do
      counts[item.categoryName] = (counts[item.categoryName] or 0) + 1
      local printItem = item.categoryName ~= "SCENERY" or item.candidate or sceneryPrinted < MAX_NEAREST_SCENERY
      if printItem then
        if item.categoryName == "SCENERY" then sceneryPrinted = sceneryPrinted + 1 end
        log("INFO", string.format(
          "object category=%s candidate=%s distance=%.1f name=%s type=%s displayName=%s x=%.2f y=%.2f z=%.2f",
          item.categoryName,
          tostring(item.candidate),
          item.distance,
          item.name,
          item.typeName,
          item.displayName,
          item.point.x or -1,
          item.point.y or -1,
          item.point.z or -1
        ))
      end
    end

    log("INFO", string.format(
      "summary radius=%dm units=%d statics=%d scenery=%d sceneryPrinted=%d",
      SEARCH_RADIUS_METERS,
      counts.UNIT or 0,
      counts.STATIC or 0,
      counts.SCENERY or 0,
      sceneryPrinted
    ))

    if staticAnchor or unitAnchor then
      log("INFO", "recommendation=USE_NAMED_MISSION_ANCHOR")
    else
      log("WARN", "recommendation=PLACE_TECHNICAL_STATIC name=" .. EXPECTED_ANCHOR_NAME)
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
