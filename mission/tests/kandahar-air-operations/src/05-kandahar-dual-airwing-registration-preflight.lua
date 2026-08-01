-- Operation Mountain Watch - Kandahar dual-AIRWING registration preflight.
-- Constructs and registers AIRWING/SQUADRON objects without starting them.
-- No missions, transports, payload stock, parking mutation, or asset spawn is performed.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.RegistrationPreflight]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local CONFIG = {
  SourceMission = "OMW_Template_v4_Kandahar(4).miz",
  SourceMissionSha256 = "0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c",
  ExpectedMooseSha256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915",

  Airwings = {
    Main = {
      AirwingName = "AW_US_KAF_451_AEW",
      WarehouseName = "WH_AIR_US_KANDAHAR",
      WarehouseType = "container_40ft",
      AirbaseName = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar or "Kandahar",
      AirbaseID = 7
    },
    Heliport = {
      AirwingName = "AW_US_KAF_159_CAB_TF_THUNDER",
      WarehouseName = "WH_AIR_US_KANDAHAR_HELI",
      WarehouseType = "container_20ft",
      AirbaseName = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar_Heliport or "Kandahar Heliport",
      AirbaseID = 15
    }
  },

  Squadrons = {
    {
      AirwingKey = "Main",
      Name = "SQ_US_KAF_A10C_74_EFS",
      Template = "TPL_AIR_US_KAF_A10C_CAS_2SHIP",
      Type = "A-10C_2",
      UnitsPerAssetGroup = 2,
      AssetGroups = 8,
      Airframes = 16
    },
    {
      AirwingKey = "Main",
      Name = "SQ_US_KAF_HH60G_26_ERQS",
      Template = "TPL_AIR_US_KAF_HH60G_CSAR_1SHIP",
      Type = "UH-60A",
      UnitsPerAssetGroup = 1,
      AssetGroups = 6,
      Airframes = 6
    },
    {
      AirwingKey = "Main",
      Name = "SQ_US_KAF_C130_772_EAS",
      Template = "TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP",
      Type = "C-130J-30",
      UnitsPerAssetGroup = 1,
      AssetGroups = 12,
      Airframes = 12
    },
    {
      AirwingKey = "Main",
      Name = "SQ_US_KAF_MQ1_361_ERS",
      Template = "TPL_AIR_US_KAF_MQ1A_RECON_1SHIP",
      Type = "RQ-1A Predator",
      UnitsPerAssetGroup = 1,
      AssetGroups = 4,
      Airframes = 4
    },
    {
      AirwingKey = "Main",
      Name = "SQ_US_KAF_MQ9_361_ERS",
      Template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
      Type = "MQ-9 Reaper",
      UnitsPerAssetGroup = 1,
      AssetGroups = 2,
      Airframes = 2
    },
    {
      AirwingKey = "Heliport",
      Name = "SQ_US_KAF_AH64_4_227_AVN",
      Template = "TPL_AIR_US_KAF_AH64D_CAS_2SHIP",
      Type = "AH-64D_BLK_II",
      UnitsPerAssetGroup = 2,
      AssetGroups = 4,
      Airframes = 8
    },
    {
      AirwingKey = "Heliport",
      Name = "SQ_US_KAF_OH58D_7_17_CAV",
      Template = "TPL_AIR_US_KAF_OH58D_RECON_2SHIP",
      Type = "OH58D",
      UnitsPerAssetGroup = 2,
      AssetGroups = 8,
      Airframes = 16
    },
    {
      AirwingKey = "Heliport",
      Name = "SQ_US_KAF_CH47_7_101_GSAB",
      Template = "TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP",
      Type = "CH-47Fbl1",
      UnitsPerAssetGroup = 1,
      AssetGroups = 16,
      Airframes = 16
    },
    {
      AirwingKey = "Heliport",
      Name = "SQ_US_KAF_UH60_7_101_GSAB",
      Template = "TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP",
      Type = "UH-60A",
      UnitsPerAssetGroup = 1,
      AssetGroups = 32,
      Airframes = 32
    }
  },

  Deferred = {
    {
      Unit = "361st Expeditionary Reconnaissance Squadron",
      Type = "MC-12",
      Airframes = 6,
      Reason = "NO_APPROVED_DCS_TEMPLATE_OR_SQUADRON_IDENTIFIER"
    }
  }
}

local violations = 0
local runtime = {
  Airwings = {},
  Squadrons = {}
}

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function countExactStatic(name)
  local count = 0
  local set = SET_STATIC:New():FilterPrefixes(name):FilterOnce()
  set:ForEachStatic(function(static)
    if static:GetName() == name then
      count = count + 1
    end
  end)
  return count
end

local function validateAirbase(spec, key)
  local airbase = AIRBASE:FindByName(spec.AirbaseName)
  if not airbase then
    fail("AIRBASE_MISSING key=" .. key .. " name=" .. tostring(spec.AirbaseName))
    return nil
  end

  if tonumber(airbase:GetID()) ~= tonumber(spec.AirbaseID) then
    fail(string.format(
      "AIRBASE_ID_MISMATCH key=%s expected=%s actual=%s",
      key,
      tostring(spec.AirbaseID),
      tostring(airbase:GetID())
    ))
    return nil
  end

  log(string.format(
    "AIRBASE_OK key=%s name=%s id=%s category=%s",
    key,
    tostring(airbase:GetName()),
    tostring(airbase:GetID()),
    tostring(airbase:GetCategoryName())
  ))
  return airbase
end

local function validateWarehouse(spec, key)
  local count = countExactStatic(spec.WarehouseName)
  if count ~= 1 then
    fail(string.format(
      "WAREHOUSE_COUNT_MISMATCH key=%s name=%s expected=1 actual=%d",
      key,
      spec.WarehouseName,
      count
    ))
    return nil
  end

  local warehouse = STATIC:FindByName(spec.WarehouseName, false)
  if not warehouse then
    fail("WAREHOUSE_MISSING key=" .. key .. " name=" .. spec.WarehouseName)
    return nil
  end

  if tostring(warehouse:GetTypeName()) ~= spec.WarehouseType then
    fail(string.format(
      "WAREHOUSE_TYPE_MISMATCH key=%s name=%s expected=%s actual=%s",
      key,
      spec.WarehouseName,
      spec.WarehouseType,
      tostring(warehouse:GetTypeName())
    ))
  end

  if tonumber(warehouse:GetCoalition()) ~= 2 then
    fail(string.format(
      "WAREHOUSE_COALITION_MISMATCH key=%s name=%s expected=2 actual=%s",
      key,
      spec.WarehouseName,
      tostring(warehouse:GetCoalition())
    ))
  end

  log(string.format(
    "WAREHOUSE_OK key=%s name=%s type=%s coalition=%s",
    key,
    spec.WarehouseName,
    tostring(warehouse:GetTypeName()),
    tostring(warehouse:GetCoalition())
  ))
  return warehouse
end

local function validateTemplate(spec)
  local template = _DATABASE:GetGroupTemplate(spec.Template)
  if not template or not template.units then
    fail("TEMPLATE_MISSING squadron=" .. spec.Name .. " template=" .. spec.Template)
    return false
  end

  if template.lateActivation ~= true then
    fail("TEMPLATE_NOT_LATE_ACTIVATION squadron=" .. spec.Name .. " template=" .. spec.Template)
  end

  local uncontrolled = template.uncontrolled
  if uncontrolled == nil then
    uncontrolled = template.uncontrollable
  end
  if uncontrolled == true then
    fail("TEMPLATE_UNCONTROLLED squadron=" .. spec.Name .. " template=" .. spec.Template)
  end

  if #template.units ~= spec.UnitsPerAssetGroup then
    fail(string.format(
      "TEMPLATE_GROUPING_MISMATCH squadron=%s template=%s expected=%d actual=%d",
      spec.Name,
      spec.Template,
      spec.UnitsPerAssetGroup,
      #template.units
    ))
  end

  for index, unit in ipairs(template.units) do
    if tostring(unit.type) ~= spec.Type then
      fail(string.format(
        "TEMPLATE_TYPE_MISMATCH squadron=%s template=%s unit=%d expected=%s actual=%s",
        spec.Name,
        spec.Template,
        index,
        spec.Type,
        tostring(unit.type)
      ))
    end
  end

  if spec.AssetGroups * spec.UnitsPerAssetGroup ~= spec.Airframes then
    fail(string.format(
      "INVENTORY_ARITHMETIC_MISMATCH squadron=%s groups=%d grouping=%d airframes=%d",
      spec.Name,
      spec.AssetGroups,
      spec.UnitsPerAssetGroup,
      spec.Airframes
    ))
  end

  log(string.format(
    "TEMPLATE_OK squadron=%s template=%s type=%s groups=%d grouping=%d airframes=%d",
    spec.Name,
    spec.Template,
    spec.Type,
    spec.AssetGroups,
    spec.UnitsPerAssetGroup,
    spec.Airframes
  ))
  return true
end

local function constructAirwing(spec, key)
  local ok, airwing = pcall(function()
    return AIRWING:New(spec.WarehouseName, spec.AirwingName)
  end)

  if not ok or not airwing then
    fail("AIRWING_CONSTRUCTION_FAILED key=" .. key .. " error=" .. tostring(airwing))
    return nil
  end

  local running = false
  if airwing.IsRunning then
    local stateOK, stateValue = pcall(function()
      return airwing:IsRunning()
    end)
    if stateOK then
      running = stateValue == true
    end
  end

  if running then
    fail("AIRWING_RUNNING_WITHOUT_AUTHORIZATION key=" .. key .. " name=" .. spec.AirwingName)
  end

  if airwing.alias and tostring(airwing.alias) ~= spec.AirwingName then
    fail(string.format(
      "AIRWING_ALIAS_MISMATCH key=%s expected=%s actual=%s",
      key,
      spec.AirwingName,
      tostring(airwing.alias)
    ))
  end

  local boundAirbase = airwing.airbase
  if not boundAirbase or tonumber(boundAirbase:GetID()) ~= tonumber(spec.AirbaseID) then
    fail(string.format(
      "AIRWING_AIRBASE_BINDING_MISMATCH key=%s airwing=%s expectedID=%s actualID=%s",
      key,
      spec.AirwingName,
      tostring(spec.AirbaseID),
      boundAirbase and tostring(boundAirbase:GetID()) or "nil"
    ))
  end

  runtime.Airwings[key] = airwing
  log(string.format(
    "AIRWING_CONSTRUCTED key=%s name=%s warehouse=%s airbase=%s airbaseID=%s running=%s",
    key,
    spec.AirwingName,
    spec.WarehouseName,
    boundAirbase and tostring(boundAirbase:GetName()) or "nil",
    boundAirbase and tostring(boundAirbase:GetID()) or "nil",
    tostring(running)
  ))
  return airwing
end

local function constructSquadron(spec)
  local airwing = runtime.Airwings[spec.AirwingKey]
  if not airwing then
    fail("SQUADRON_AIRWING_UNAVAILABLE squadron=" .. spec.Name .. " key=" .. spec.AirwingKey)
    return nil
  end

  local ok, squadron = pcall(function()
    local object = SQUADRON:New(spec.Template, spec.AssetGroups, spec.Name)
    object:SetGrouping(spec.UnitsPerAssetGroup)
    airwing:AddSquadron(object)
    return object
  end)

  if not ok or not squadron then
    fail("SQUADRON_CONSTRUCTION_FAILED squadron=" .. spec.Name .. " error=" .. tostring(squadron))
    return nil
  end

  if squadron.GetName and tostring(squadron:GetName()) ~= spec.Name then
    fail(string.format(
      "SQUADRON_NAME_MISMATCH expected=%s actual=%s",
      spec.Name,
      tostring(squadron:GetName())
    ))
  end

  if tostring(squadron.templatename) ~= spec.Template then
    fail(string.format(
      "SQUADRON_TEMPLATE_BINDING_MISMATCH squadron=%s expected=%s actual=%s",
      spec.Name,
      spec.Template,
      tostring(squadron.templatename)
    ))
  end

  if tonumber(squadron.ngrouping) ~= tonumber(spec.UnitsPerAssetGroup) then
    fail(string.format(
      "SQUADRON_GROUPING_MISMATCH squadron=%s expected=%d actual=%s",
      spec.Name,
      spec.UnitsPerAssetGroup,
      tostring(squadron.ngrouping)
    ))
  end

  if squadron.legion ~= airwing then
    fail("SQUADRON_LEGION_BINDING_MISMATCH squadron=" .. spec.Name .. " airwing=" .. spec.AirwingKey)
  end

  if airwing.GetSquadron and airwing:GetSquadron(spec.Name) ~= squadron then
    fail("AIRWING_SQUADRON_LOOKUP_MISMATCH squadron=" .. spec.Name .. " airwing=" .. spec.AirwingKey)
  end

  runtime.Squadrons[spec.Name] = squadron
  log(string.format(
    "SQUADRON_REGISTERED name=%s airwing=%s template=%s type=%s assetGroups=%d grouping=%d airframes=%d",
    spec.Name,
    CONFIG.Airwings[spec.AirwingKey].AirwingName,
    spec.Template,
    spec.Type,
    spec.AssetGroups,
    spec.UnitsPerAssetGroup,
    spec.Airframes
  ))
  return squadron
end

local function main()
  log(string.format(
    "BEGIN sourceMission=%s sourceSha256=%s expectedMooseSha256=%s noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true",
    CONFIG.SourceMission,
    CONFIG.SourceMissionSha256,
    CONFIG.ExpectedMooseSha256
  ))

  if OMW.AirOps.KandaharRegistrationPreflight then
    log("RESULT: FAIL reason=PREFLIGHT_ALREADY_CONSTRUCTED noStart=true noSpawn=true")
    return
  end

  if not AIRBASE or not STATIC or not SET_STATIC or not AIRWING or not SQUADRON then
    log("RESULT: FAIL reason=REQUIRED_MOOSE_CLASSES_UNAVAILABLE noStart=true noSpawn=true")
    return
  end
  if not _DATABASE or not _DATABASE.GetGroupTemplate then
    log("RESULT: FAIL reason=DATABASE_TEMPLATE_API_UNAVAILABLE noStart=true noSpawn=true")
    return
  end

  for key, spec in pairs(CONFIG.Airwings) do
    validateAirbase(spec, key)
    validateWarehouse(spec, key)
  end

  for _, spec in ipairs(CONFIG.Squadrons) do
    validateTemplate(spec)
  end

  if violations == 0 then
    constructAirwing(CONFIG.Airwings.Main, "Main")
    constructAirwing(CONFIG.Airwings.Heliport, "Heliport")
  end

  if violations == 0 then
    for _, spec in ipairs(CONFIG.Squadrons) do
      constructSquadron(spec)
    end
  end

  for _, item in ipairs(CONFIG.Deferred) do
    log(string.format(
      "DEFERRED unit=%s type=%s airframes=%d reason=%s",
      item.Unit,
      item.Type,
      item.Airframes,
      item.Reason
    ))
  end

  OMW.AirOps.KandaharRegistrationPreflight = {
    Config = CONFIG,
    Airwings = runtime.Airwings,
    Squadrons = runtime.Squadrons,
    Violations = violations,
    Constructed = violations == 0,
    Started = false
  }

  if violations == 0 then
    log(string.format(
      "RESULT: PASS airwings=%d squadrons=%d registeredAirframes=112 deferredMC12=6 noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true",
      2,
      #CONFIG.Squadrons
    ))
  else
    log(string.format(
      "RESULT: FAIL violations=%d noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true",
      violations
    ))
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 8)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 8)
end
