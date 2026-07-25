-- Operation Mountain Watch - Jalalabad exclusive SQUADRON parking-pool validation
local TAG = "[OMW][AirOps.JBAD.PARKING-POOLS]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function distance2D(first, second)
  if not first or not second then return nil end
  local a = first.GetVec3 and first:GetVec3() or first
  local b = second.GetVec3 and second:GetVec3() or second
  if not a or not b then return nil end
  local az = a.z == nil and (a.y or 0) or a.z
  local bz = b.z == nil and (b.y or 0) or b.z
  local dx = (a.x or 0) - (b.x or 0)
  local dz = az - bz
  return math.sqrt(dx * dx + dz * dz)
end

local function addStaticNames(cfg)
  local result = {}
  for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
    for _, name in ipairs((cfg.Statics and cfg.Statics[key]) or {}) do
      result[#result + 1] = name
    end
  end
  return result
end

local function missionTemplate(name)
  if not name or not _DATABASE or not _DATABASE.GetGroupTemplate then return nil end
  local ok, template = pcall(function() return _DATABASE:GetGroupTemplate(name) end)
  if not ok or type(template) ~= "table" then return nil end
  return template
end

local function resolveClientParking(cfg, spots)
  local result = {}
  local ok = true
  for _, key in ipairs({ "OH58D", "AH64D", "CH47" }) do
    for _, groupName in ipairs((cfg.PlayerGroups.Required and cfg.PlayerGroups.Required[key]) or {}) do
      local template = missionTemplate(groupName)
      local unit = template and template.units and template.units[1] or nil
      local nearestId, nearestDistance
      if unit then
        local point = { x = unit.x or 0, z = unit.y or unit.z or 0 }
        for _, spot in ipairs(spots) do
          local distance = distance2D(point, spot.Coordinate)
          if distance and (not nearestDistance or distance < nearestDistance) then
            nearestDistance = distance
            nearestId = spot.TerminalID
          end
        end
      end
      if nearestId and nearestDistance and nearestDistance <= 2 then
        result[nearestId] = groupName
        log(string.format("CLIENT_RESERVED group=%s TerminalID=%s distance=%.1fm", groupName, tostring(nearestId), nearestDistance))
      else
        ok = false
        log(string.format("ERROR CLIENT_PARKING_UNRESOLVED group=%s TerminalID=%s distance=%s", groupName, tostring(nearestId), nearestDistance and string.format("%.1fm", nearestDistance) or "unknown"))
      end
    end
  end
  return result, ok
end

local function validateTemplatesOffParking(cfg, spots)
  local ok = true
  local minimum = cfg.Parking.TemplateMinimumParkingClearanceMeters or 100
  for _, templateName in ipairs({
    cfg.Templates.OH58DRecon,
    cfg.Templates.AH64DCAS,
    cfg.Templates.UH60MedevacLead,
    cfg.Templates.UH60MedevacCover,
    cfg.Templates.CH47HeavyLift
  }) do
    local template = missionTemplate(templateName)
    for index, unit in ipairs(template and template.units or {}) do
      local point = { x = unit.x or 0, z = unit.y or unit.z or 0 }
      local nearestId, nearestDistance
      for _, spot in ipairs(spots) do
        local distance = distance2D(point, spot.Coordinate)
        if distance and (not nearestDistance or distance < nearestDistance) then
          nearestDistance = distance
          nearestId = spot.TerminalID
        end
      end
      if not nearestDistance or nearestDistance < minimum then
        ok = false
        log(string.format("ERROR TEMPLATE_OCCUPIES_OPERATIONAL_PARKING template=%s unit=%d nearestTerminalID=%s distance=%s minimum=%.1fm", templateName, index, tostring(nearestId), nearestDistance and string.format("%.1fm", nearestDistance) or "unknown", minimum))
      else
        log(string.format("TEMPLATE_OFF_PARKING template=%s unit=%d nearestTerminalID=%s distance=%.1fm", templateName, index, tostring(nearestId), nearestDistance))
      end
    end
  end
  return ok
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg or not cfg.Airbase then
    log("ERROR: Jalalabad configuration or airbase is unavailable.")
    return
  end

  cfg.ParkingPoolsOK = false
  local parking = cfg.Parking or {}
  local pools = parking.SquadronPools or {}
  local spots = cfg.Airbase:GetParkingSpotsTable() or {}
  local spotById = {}
  for _, spot in ipairs(spots) do spotById[spot.TerminalID] = spot end

  local blacklist = {}
  for _, id in ipairs(parking.StaticParkingBlacklist or {}) do blacklist[id] = true end
  local clientIds, clientsOK = resolveClientParking(cfg, spots)
  local templatesOK = validateTemplatesOffParking(cfg, spots)
  local staticNames = addStaticNames(cfg)
  local usedIds = {}
  local poolSets = {}
  local ok = clientsOK and templatesOK
  local counts = {}

  for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
    local pool = pools[key]
    local count = 0
    poolSets[key] = {}
    if not pool or not pool.Entries or #pool.Entries < (pool.GroupSize or 1) then
      ok = false
      log("ERROR POOL_MISSING_OR_TOO_SMALL squadron=" .. key)
    else
      for _, entry in ipairs(pool.Entries) do
        count = count + 1
        local id = entry.TerminalID
        local spot = spotById[id]
        local entryOK = true
        if usedIds[id] then
          entryOK = false
          log(string.format("ERROR POOL_ID_DUPLICATE squadron=%s label=%s TerminalID=%s alreadyUsedBy=%s", key, tostring(entry.Label), tostring(id), usedIds[id]))
        end
        usedIds[id] = key
        if blacklist[id] then
          entryOK = false
          log(string.format("ERROR POOL_USES_STATIC_BLACKLIST squadron=%s label=%s TerminalID=%s", key, tostring(entry.Label), tostring(id)))
        end
        if clientIds[id] then
          entryOK = false
          log(string.format("ERROR POOL_USES_CLIENT_PARKING squadron=%s label=%s TerminalID=%s client=%s", key, tostring(entry.Label), tostring(id), clientIds[id]))
        end
        if not spot then
          entryOK = false
          log(string.format("ERROR POOL_TERMINAL_NOT_FOUND squadron=%s label=%s TerminalID=%s", key, tostring(entry.Label), tostring(id)))
        else
          local coordinateError = distance2D(spot.Coordinate, { x = entry.X, z = entry.Z })
          if spot.TerminalType ~= pool.TerminalType then
            entryOK = false
            log(string.format("ERROR POOL_TERMINAL_TYPE squadron=%s label=%s TerminalID=%s type=%s expected=%s", key, tostring(entry.Label), tostring(id), tostring(spot.TerminalType), tostring(pool.TerminalType)))
          end
          if not coordinateError or coordinateError > (parking.PoolCoordinateToleranceMeters or 2) then
            entryOK = false
            log(string.format("ERROR POOL_COORDINATE_MISMATCH squadron=%s label=%s TerminalID=%s delta=%s", key, tostring(entry.Label), tostring(id), coordinateError and string.format("%.1fm", coordinateError) or "unknown"))
          end

          local nearestStatic, nearestStaticDistance
          for _, staticName in ipairs(staticNames) do
            local static = STATIC and STATIC:FindByName(staticName, false) or nil
            if static then
              local distance = distance2D(spot.Coordinate, static:GetCoordinate())
              if distance and (not nearestStaticDistance or distance < nearestStaticDistance) then
                nearestStatic = staticName
                nearestStaticDistance = distance
              end
            end
          end
          if nearestStaticDistance and nearestStaticDistance < (parking.PoolStaticClearanceMeters or 12) then
            entryOK = false
            log(string.format("ERROR POOL_STATIC_CLEARANCE squadron=%s label=%s TerminalID=%s static=%s distance=%.1fm minimum=%.1fm", key, tostring(entry.Label), tostring(id), tostring(nearestStatic), nearestStaticDistance, parking.PoolStaticClearanceMeters or 12))
          end

          if entryOK then
            log(string.format("POOL_ENTRY squadron=%s label=%s TerminalID=%s type=%s coordinateDelta=%.1fm nearestStatic=%s staticDistance=%s", key, tostring(entry.Label), tostring(id), tostring(spot.TerminalType), coordinateError or -1, tostring(nearestStatic), nearestStaticDistance and string.format("%.1fm", nearestStaticDistance) or "unknown"))
          end
        end
        if not entryOK then ok = false end
        poolSets[key][id] = true
      end
    end
    counts[key] = count
  end

  cfg.ParkingPoolTerminalIDs = poolSets
  cfg.ParkingPoolsOK = ok and counts.OH58D == 5 and counts.AH64D == 3 and counts.UH60 == 3 and counts.CH47 == 8
  if cfg.ParkingPoolsOK then
    log("RESULT: PASS pools=OH58D:5/AH64D:3/UH60:3/CH47:8 templatesOffParking=true poolOverlap=0 clientOverlap=0 blacklistOverlap=0 staticClearance=PASS templateLookup=DATABASE:GetGroupTemplate")
  else
    log(string.format("RESULT: FAIL pools=OH58D:%s/AH64D:%s/UH60:%s/CH47:%s AIRWING_START_BLOCKED=true", tostring(counts.OH58D), tostring(counts.AH64D), tostring(counts.UH60), tostring(counts.CH47)))
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 8)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 8)
end
