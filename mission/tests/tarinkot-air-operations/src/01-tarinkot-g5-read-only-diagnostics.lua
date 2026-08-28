-- Operation Mountain Watch - Tarinkot G5 read-only diagnostics
-- This source must not create AIRWING, SQUADRON, AUFTRAG, COMMANDER,
-- OPSTRANSPORT or SPAWN objects and must not modify CampaignState or the MIZ.

local TAG = "[OMW][AirOps.TKOT.G5]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G5_BUILD or {}

local EXPECTED = {
  Mission = "OMW_Template_v5_Salerno.miz",
  MissionSHA256 = "203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5",
  MooseSHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915",
  MooseCommit = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54",
  AirbaseID = 9,
  WarehouseName = "WH_AIR_US_TARINKOT",
  Clients = {
    "CLIENT_US_TKOT_AH64D_01",
    "CLIENT_US_TKOT_AH64D_02",
    "CLIENT_US_TKOT_CH47F_01"
  },
  Seeds = {
    "TPL_AIR_US_TKOT_AH64D_CAS_2SHIP",
    "TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP",
    "TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP"
  },
  Statics = {
    "STATIC_AIR_US_TKOT_AH64_01",
    "STATIC_AIR_US_TKOT_AH64_02",
    "STATIC_AIR_US_TKOT_AH64_03",
    "STATIC_AIR_US_TKOT_AH64_04",
    "STATIC_AIR_US_TKOT_AH64_05",
    "STATIC_AIR_US_TKOT_AH64_06",
    "STATIC_AIR_US_TKOT_AH64_07",
    "STATIC_AIR_US_TKOT_AH64_08",
    "STATIC_AIR_US_TKOT_UH60_UTILITY_01",
    "STATIC_AIR_US_TKOT_UH60_UTILITY_02",
    "STATIC_AIR_US_TKOT_UH60_UTILITY_03",
    "STATIC_AIR_US_TKOT_UH60_MEDEVAC_01"
  },
  Zones = {
    "OMW_LOG_NODE_TARINKOT",
    "ZONE_AIR_US_TKOT_AH64_RAMP",
    "ZONE_AIR_US_TKOT_UH60_RAMP",
    "ZONE_AIR_US_TKOT_MEDEVAC_READY",
    "ZONE_AIR_US_TKOT_CH47_READY",
    "ZONE_AIR_US_TKOT_ROTARY_STAGING",
    "ZONE_AIR_US_TKOT_LOGISTICS_LOAD",
    "ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_TKOT_HELO_RECOVERY",
    "ZONE_AIR_US_TKOT_TRANSIENT_FIXED_WING",
    "ZONE_AIR_US_TKOT_FARP"
  }
}

local function typed(value)
  return string.format("value=%s luaType=%s", tostring(value), type(value))
end

local function safe(label, callback)
  local ok, result = pcall(callback)
  if not ok then
    log("ERROR " .. label .. " exception=" .. tostring(result))
    return nil, false
  end
  return result, true
end

local function getGroupTemplate(name)
  local groups = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups
  local entry = groups and groups[name] or nil
  return entry and entry.Template or nil
end

local function inspectTemplate(kind, name)
  local template = getGroupTemplate(name)
  if not template then
    log("MISSING " .. kind .. " name=" .. name)
    return false
  end

  local units = template.units or {}
  local routePoint = template.route and template.route.points and template.route.points[1] or nil
  log(string.format(
    "OK %s name=%s units=%d lateActivation=%s task=%s routeParking{%s} routeParkingId{%s} routeAirdromeId{%s}",
    kind,
    name,
    #units,
    tostring(template.lateActivation),
    tostring(template.task),
    typed(routePoint and routePoint.parking or nil),
    typed(routePoint and routePoint.parking_id or nil),
    typed(routePoint and routePoint.airdromeId or nil)
  ))

  for index, unit in ipairs(units) do
    log(string.format(
      "%s_UNIT group=%s index=%d name=%s type=%s skill=%s livery=%s unitParking{%s} unitParkingId{%s} x=%s y=%s",
      kind,
      name,
      index,
      tostring(unit.name),
      tostring(unit.type),
      tostring(unit.skill),
      tostring(unit.livery_id or unit.livery),
      typed(unit.parking),
      typed(unit.parking_id),
      tostring(unit.x),
      tostring(unit.y)
    ))
  end

  return true
end

local function inspectAirbase()
  if not AIRBASE then
    log("ERROR AIRBASE class unavailable")
    return nil, false
  end

  local airbase, callOK = safe("AIRBASE_FIND_BY_ID", function()
    return AIRBASE:FindByID(EXPECTED.AirbaseID)
  end)

  if not callOK or not airbase then
    log("ERROR AIRBASE id=" .. tostring(EXPECTED.AirbaseID) .. " not found")
  else
    local idNormal = safe("AIRBASE_GET_ID", function() return airbase:GetID() end)
    local idUnique = safe("AIRBASE_GET_UNIQUE_ID", function() return airbase:GetID(true) end)
    local category = safe("AIRBASE_GET_CATEGORY_NAME", function() return airbase:GetCategoryName() end)
    local coalitionName = safe("AIRBASE_GET_COALITION_NAME", function() return airbase:GetCoalitionName() end)
    local countryName = safe("AIRBASE_GET_COUNTRY_NAME", function() return airbase:GetCountryName() end)

    log(string.format(
      "AIRBASE idRequested=%s name=%s id{%s} uniqueId{%s} category=%s coalition=%s country=%s",
      tostring(EXPECTED.AirbaseID),
      tostring(airbase:GetName()),
      typed(idNormal),
      typed(idUnique),
      tostring(category),
      tostring(coalitionName),
      tostring(countryName)
    ))
  end

  local candidates = 0
  local airbaseDB = _DATABASE and _DATABASE.AIRBASES or {}
  for name, candidate in pairs(airbaseDB or {}) do
    local normal = safe("AIRBASE_ENUM_ID_" .. tostring(name), function() return candidate:GetID() end)
    local unique = safe("AIRBASE_ENUM_UNIQUE_ID_" .. tostring(name), function() return candidate:GetID(true) end)
    if tonumber(normal) == EXPECTED.AirbaseID or tonumber(unique) == EXPECTED.AirbaseID then
      candidates = candidates + 1
      log(string.format("AIRBASE_ID_CANDIDATE name=%s id{%s} uniqueId{%s}", tostring(name), typed(normal), typed(unique)))
    end
  end
  log("AIRBASE_ID_CANDIDATE_COUNT=" .. tostring(candidates))

  return airbase, airbase ~= nil
end

local function inspectParking(airbase)
  if not airbase then
    log("PARKING_SKIPPED reason=no-airbase")
    return false
  end

  local spots, ok = safe("AIRBASE_GET_PARKING_SPOTS_TABLE", function()
    return airbase:GetParkingSpotsTable()
  end)
  if not ok or not spots then
    log("ERROR PARKING table unavailable")
    return false
  end

  table.sort(spots, function(left, right)
    local a = tonumber(left.TerminalID)
    local b = tonumber(right.TerminalID)
    if a and b then return a < b end
    if a then return true end
    if b then return false end
    return tostring(left.TerminalID) < tostring(right.TerminalID)
  end)

  log("PARKING_COUNT=" .. tostring(#spots))
  for _, parking in ipairs(spots) do
    local vec3 = parking.Coordinate and parking.Coordinate:GetVec3() or {}
    log(string.format(
      "PARKING TerminalID{%s} TerminalID0{%s} TerminalType{%s} Free{%s} TOAC{%s} OccupiedBy=%s x=%.3f y=%.3f z=%.3f",
      typed(parking.TerminalID),
      typed(parking.TerminalID0),
      typed(parking.TerminalType),
      typed(parking.Free),
      typed(parking.TOAC),
      tostring(parking.OccupiedBy),
      tonumber(vec3.x) or 0,
      tonumber(vec3.y) or 0,
      tonumber(vec3.z) or 0
    ))
  end

  return true
end

local function inspectWarehouse()
  local static = STATIC and STATIC:FindByName(EXPECTED.WarehouseName, false) or nil
  local unit = UNIT and UNIT:FindByName(EXPECTED.WarehouseName) or nil
  local count = (static and 1 or 0) + (unit and 1 or 0)

  log(string.format(
    "WAREHOUSE_ANCHOR name=%s staticFound=%s unitFound=%s wrapperCount=%d",
    EXPECTED.WarehouseName,
    tostring(static ~= nil),
    tostring(unit ~= nil),
    count
  ))

  local object = static or unit
  if object then
    local vec3 = object:GetVec3() or {}
    local typeName = safe("WAREHOUSE_GET_TYPE", function() return object:GetTypeName() end)
    local coalitionName = safe("WAREHOUSE_GET_COALITION", function() return object:GetCoalitionName() end)
    local countryName = safe("WAREHOUSE_GET_COUNTRY", function() return object:GetCountryName() end)
    log(string.format(
      "WAREHOUSE_DETAILS type=%s coalition=%s country=%s x=%.3f y=%.3f z=%.3f",
      tostring(typeName),
      tostring(coalitionName),
      tostring(countryName),
      tonumber(vec3.x) or 0,
      tonumber(vec3.y) or 0,
      tonumber(vec3.z) or 0
    ))
  end

  if count ~= 1 then
    log("ERROR WAREHOUSE_ANCHOR expectedExactlyOne found=" .. tostring(count))
    return false
  end
  return true
end

local function inspectStatics()
  local missing = 0
  for _, name in ipairs(EXPECTED.Statics) do
    local object = STATIC and STATIC:FindByName(name, false) or nil
    if not object then
      missing = missing + 1
      log("MISSING STATIC name=" .. name)
    else
      local vec3 = object:GetVec3() or {}
      local typeName = safe("STATIC_GET_TYPE_" .. name, function() return object:GetTypeName() end)
      log(string.format(
        "OK STATIC name=%s type=%s x=%.3f y=%.3f z=%.3f",
        name,
        tostring(typeName),
        tonumber(vec3.x) or 0,
        tonumber(vec3.y) or 0,
        tonumber(vec3.z) or 0
      ))
    end
  end
  log(string.format("STATIC_SUMMARY expected=%d missing=%d", #EXPECTED.Statics, missing))
  return missing
end

local function inspectZones()
  local present = 0
  local missing = 0
  for _, name in ipairs(EXPECTED.Zones) do
    local zone = nil
    local ok, result = pcall(function() return ZONE and ZONE:FindByName(name) or nil end)
    if ok then zone = result end
    if zone then
      present = present + 1
      log("OK ZONE name=" .. name)
    else
      missing = missing + 1
      log("MISSING_EXPECTED_ZONE name=" .. name)
    end
  end
  log(string.format("ZONE_SUMMARY expected=%d present=%d missing=%d", #EXPECTED.Zones, present, missing))
  return present, missing
end

local function inspectNameCollisions()
  local names = {}
  local function add(kind, name)
    names[name] = names[name] or {}
    names[name][#names[name] + 1] = kind
  end

  for _, name in ipairs(EXPECTED.Clients) do add("CLIENT_TEMPLATE", name) end
  for _, name in ipairs(EXPECTED.Seeds) do add("AI_TEMPLATE", name) end
  for _, name in ipairs(EXPECTED.Statics) do add("STATIC", name) end
  for _, name in ipairs(EXPECTED.Zones) do add("ZONE", name) end
  add("WAREHOUSE", EXPECTED.WarehouseName)

  local duplicates = 0
  for name, kinds in pairs(names) do
    if #kinds > 1 then
      duplicates = duplicates + 1
      log("ERROR CONTRACT_NAME_DUPLICATE name=" .. name .. " kinds=" .. table.concat(kinds, ","))
    end
  end
  log("CONTRACT_NAME_DUPLICATE_COUNT=" .. tostring(duplicates))
  return duplicates
end

local function main()
  log("BEGIN Tarinkot G5 read-only diagnostics")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder),
    tostring(build.BuilderVersion),
    tostring(build.GitCommit),
    tostring(build.GeneratedUtc)
  ))
  log("EXPECTED mission=" .. EXPECTED.Mission .. " missionSHA256=" .. EXPECTED.MissionSHA256)
  log("EXPECTED mooseSHA256=" .. EXPECTED.MooseSHA256 .. " mooseCommit=" .. EXPECTED.MooseCommit)
  log("READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0")

  local coreMissing = 0

  local airbase, airbaseOK = inspectAirbase()
  if not airbaseOK then coreMissing = coreMissing + 1 end
  if not inspectParking(airbase) then coreMissing = coreMissing + 1 end
  if not inspectWarehouse() then coreMissing = coreMissing + 1 end

  for _, name in ipairs(EXPECTED.Clients) do
    if not inspectTemplate("CLIENT_TEMPLATE", name) then coreMissing = coreMissing + 1 end
  end
  for _, name in ipairs(EXPECTED.Seeds) do
    if not inspectTemplate("AI_TEMPLATE", name) then coreMissing = coreMissing + 1 end
  end

  coreMissing = coreMissing + inspectStatics()
  local _, missingZones = inspectZones()
  coreMissing = coreMissing + inspectNameCollisions()

  if coreMissing == 0 then
    log(string.format("RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=%d mutationCount=0", missingZones))
  else
    log(string.format("RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=FAIL_STRUCTURE coreMissing=%d zonesMissing=%d mutationCount=0", coreMissing, missingZones))
  end
end

if not SCHEDULER then
  log("ERROR SCHEDULER class unavailable; diagnostics not scheduled")
else
  SCHEDULER:New(nil, main, {}, 8)
end
