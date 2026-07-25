-- Operation Mountain Watch - corrected complete Jalalabad Air Operations validation and activation
local TAG = "[OMW][AirOps.JBAD.COMPLETE]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function getMissionTemplate(name)
  if not _DATABASE or not _DATABASE.Templates or not _DATABASE.Templates.Groups then
    return nil
  end
  local data = _DATABASE.Templates.Groups[name]
  return data and data.Template or nil
end

local function validateMissionGroup(name, expectedType, expectedSize)
  local template = getMissionTemplate(name)
  if not template then
    log("MISSING GROUP_TEMPLATE " .. name)
    return false
  end

  local units = template.units or {}
  if #units ~= expectedSize then
    log(string.format("ERROR GROUP_TEMPLATE %s size=%d expected=%d", name, #units, expectedSize))
    return false
  end

  for index, unit in ipairs(units) do
    local typeName = unit and unit.type or "nil"
    if typeName ~= expectedType then
      log(string.format("ERROR GROUP_TEMPLATE %s unit=%d type=%s expected=%s", name, index, tostring(typeName), tostring(expectedType)))
      return false
    end
  end

  log(string.format("OK GROUP_TEMPLATE %s type=%s size=%d", name, tostring(expectedType), expectedSize))
  return true
end

local function validateStatic(name, expectedType)
  local static = STATIC:FindByName(name, false)
  if not static then
    log("MISSING STATIC " .. name)
    return false
  end

  local typeName = static:GetTypeName()
  if typeName ~= expectedType then
    log(string.format("ERROR STATIC %s type=%s expected=%s", name, tostring(typeName), tostring(expectedType)))
    return false
  end

  log(string.format("OK STATIC %s type=%s", name, tostring(expectedType)))
  return true
end

local function validateOptionalGroups(groups, expectedCount)
  local present = {}
  for _, name in ipairs(groups or {}) do
    local template = getMissionTemplate(name)
    if template then
      present[#present + 1] = { Name = name, Template = template }
    end
  end

  if #present == 0 then
    log(string.format("OPTIONAL UH60L player slots absent=%d accepted=true coreMissionUnaffected=true", expectedCount))
    return true
  end

  if #present ~= expectedCount then
    log(string.format("ERROR OPTIONAL UH60L player slots must be either 0 or %d; present=%d", expectedCount, #present))
    return false
  end

  local detectedType = nil
  for _, item in ipairs(present) do
    local units = item.Template.units or {}
    if #units ~= 1 then
      log(string.format("ERROR OPTIONAL UH60L group %s must contain exactly one aircraft", item.Name))
      return false
    end
    local typeName = units[1] and units[1].type or "nil"
    if detectedType and detectedType ~= typeName then
      log(string.format("ERROR OPTIONAL UH60L groups use inconsistent types %s and %s", detectedType, tostring(typeName)))
      return false
    end
    detectedType = typeName
  end

  log(string.format("OPTIONAL UH60L player slots present=%d type=%s accepted=true", expectedCount, tostring(detectedType)))
  return true
end

local function validateRampModel(cfg)
  local ok = true
  local parking = cfg.Parking or {}
  local caps = cfg.StaticCaps or {}

  if parking.ComparableHelicopterPositions ~= 36 or
     parking.CorePlayerPositions ~= 6 or
     parking.OptionalUH60LPlayerPositions ~= 2 or
     parking.TemplateAuthoringAircraft ~= 7 or
     parking.DynamicAIParkingReserve ~= 4 or
     parking.CoreRuntimeParkingDemand ~= 10 or
     parking.RuntimeParkingDemandWithUH60L ~= 12 then
    log("ERROR: Parking model does not match clients=6+2optional, dynamicAIReserve=4, templates=7(non-runtime), comparablePositions=36.")
    ok = false
  end

  if caps.OH58D ~= 7 or caps.AH64D ~= 4 or caps.UH60 ~= 4 or caps.CH47 ~= 5 then
    log("ERROR: Visible static caps do not match 7/4/4/5.")
    ok = false
  end

  if caps.OH58D > cfg.Inventory.OH58D or caps.AH64D > cfg.Inventory.AH64D or
     caps.UH60 > cfg.Inventory.UH60 or caps.CH47 > cfg.Inventory.CH47 then
    log("ERROR: A visible static cap exceeds its logical inventory.")
    ok = false
  end

  if parking.CoreRuntimeParkingDemand > parking.ComparableHelicopterPositions or
     parking.RuntimeParkingDemandWithUH60L > parking.ComparableHelicopterPositions then
    log("ERROR: Runtime parking demand exceeds comparable helicopter positions.")
    ok = false
  end

  if ok then
    log("OK RAMP_MODEL inventoryVirtual=true clients=6 optionalClients=2 dynamicAIReserve=4 runtimeDemand=10or12 templateAircraft=7nonRuntime comparablePositions=36 staticsFreePlaced=true staticCaps=7/4/4/5.")
  end
  return ok
end

local function validateMedevacModel(cfg)
  local medevac = cfg.Medevac or {}
  local ok = true

  if medevac.PackageSize ~= 2 or medevac.LeadAircraft ~= 1 or
     medevac.CoverAircraft ~= 1 or medevac.AllowSingleShip ~= false then
    log("ERROR: MEDEVAC package policy must be 1 lead + 1 cover with no single-ship fallback.")
    ok = false
  end

  if medevac.DCSGroupModel ~= "TWO_INDEPENDENT_SINGLE_SHIP_GROUPS" or
     medevac.CoordinationModel ~= "ONE_LOGICAL_MEDEVAC_PACKAGE" then
    log("ERROR: MEDEVAC must use two independently taskable single-ship DCS groups coordinated as one logical package.")
    ok = false
  end

  if ok then
    log("OK MEDEVAC_MODEL package=2 DCSgroups=1lead+1cover independentTasking=true logicalPackage=true.")
  end
  return ok
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR: Jalalabad configuration is unavailable.")
    return
  end

  local ok = true
  local ch47Type = cfg.DetectedTypes and cfg.DetectedTypes.CH47 or nil

  if cfg.CorrectionPending and cfg.CorrectionPending.CH47 then
    log("ERROR: CH-47 correction remains pending; template/type/squadron construction did not complete.")
    ok = false
  end
  if not ch47Type then
    log("ERROR: Canonical CH-47 DCS type was not detected from the heavy-lift template.")
    ok = false
  end

  if not cfg.Airwing then
    log("ERROR: AIRWING is not constructed.")
    ok = false
  end

  for key, label in pairs({ OH58D = "OH-58D", AH64D = "AH-64D", UH60 = "UH-60", CH47 = "CH-47" }) do
    if not cfg.Squadrons or not cfg.Squadrons[key] then
      log("ERROR: " .. label .. " SQUADRON is unavailable.")
      ok = false
    end
  end

  if not cfg.Payloads or not cfg.Payloads.OH58DRecon then
    log("ERROR: OH-58D RECON payload is unavailable.")
    ok = false
  end
  if not cfg.Payloads or not cfg.Payloads.AH64DCAS then
    log("ERROR: AH-64D CAS payload is unavailable.")
    ok = false
  end
  if not cfg.Payloads or not cfg.Payloads.UH60MedevacLead or not cfg.Payloads.UH60MedevacCover then
    log("ERROR: UH-60 MEDEVAC lead/cover payloads are unavailable.")
    ok = false
  end
  if not cfg.Payloads or not cfg.Payloads.CH47HeavyLift then
    log("ERROR: CH-47 heavy-lift payload is unavailable.")
    ok = false
  end

  for _, name in ipairs(cfg.PlayerGroups.Required.OH58D or {}) do
    if not validateMissionGroup(name, "OH58D", 1) then ok = false end
  end
  for _, name in ipairs(cfg.PlayerGroups.Required.AH64D or {}) do
    if not validateMissionGroup(name, "AH-64D_BLK_II", 1) then ok = false end
  end
  if ch47Type then
    for _, name in ipairs(cfg.PlayerGroups.Required.CH47 or {}) do
      if not validateMissionGroup(name, ch47Type, 1) then ok = false end
    end
  end

  if not validateMissionGroup(cfg.Templates.OH58DRecon, "OH58D", 2) then ok = false end
  if not validateMissionGroup(cfg.Templates.AH64DCAS, "AH-64D_BLK_II", 2) then ok = false end
  if not validateMissionGroup(cfg.Templates.UH60MedevacLead, "UH-60A", 1) then ok = false end
  if not validateMissionGroup(cfg.Templates.UH60MedevacCover, "UH-60A", 1) then ok = false end
  if ch47Type and not validateMissionGroup(cfg.Templates.CH47HeavyLift, ch47Type, 1) then ok = false end

  for _, name in ipairs(cfg.Statics.OH58D or {}) do
    if not validateStatic(name, "OH58D") then ok = false end
  end
  for _, name in ipairs(cfg.Statics.AH64D or {}) do
    if not validateStatic(name, "AH-64D_BLK_II") then ok = false end
  end
  for _, name in ipairs(cfg.Statics.UH60 or {}) do
    if not validateStatic(name, "UH-60A") then ok = false end
  end
  if ch47Type then
    for _, name in ipairs(cfg.Statics.CH47 or {}) do
      if not validateStatic(name, ch47Type) then ok = false end
    end
  end

  for _, name in ipairs(cfg.Zones or {}) do
    if ZONE:FindByName(name) then
      log("OK ZONE " .. name)
    else
      log("MISSING ZONE " .. name)
      ok = false
    end
  end

  local anchor = STATIC:FindByName(cfg.WarehouseName, false) or UNIT:FindByName(cfg.WarehouseName)
  if anchor then
    log("OK WAREHOUSE_ANCHOR " .. cfg.WarehouseName)
  else
    log("MISSING WAREHOUSE_ANCHOR " .. cfg.WarehouseName)
    ok = false
  end

  if not validateOptionalGroups(cfg.PlayerGroups.Optional.UH60L, 2) then
    ok = false
  end

  if cfg.Inventory.OH58D ~= 24 or cfg.Inventory.AH64D ~= 8 or cfg.Inventory.UH60 ~= 8 or cfg.Inventory.CH47 ~= 8 then
    log("ERROR: Inventory manifest does not match 24/8/8/8.")
    ok = false
  end
  if cfg.Limits.PlayerPerType ~= 2 or cfg.Limits.AIPerType ~= 4 or
     cfg.Limits.ConcurrentSupportMissions ~= 2 or cfg.Limits.AircraftPerMission ~= 2 or
     cfg.Limits.ConcurrentSupportAircraft ~= 4 then
    log("ERROR: Air Operations limits do not match player=2 and locked AI policy.")
    ok = false
  end
  if not validateMedevacModel(cfg) then
    ok = false
  end
  if not validateRampModel(cfg) then
    ok = false
  end

  if not ok then
    cfg.Status = "INCOMPLETE"
    log("RESULT: INCOMPLETE. AIRWING and COMMANDER remain unstarted; correct all preceding ERROR/MISSING lines.")
    return
  end

  if not COMMANDER then
    cfg.Status = "ERROR"
    log("ERROR: MOOSE COMMANDER class is unavailable.")
    return
  end

  local started, result = pcall(function()
    cfg.Airwing:Start()

    OMW.AirOps.BlueCommander = OMW.AirOps.BlueCommander or COMMANDER:New(coalition.side.BLUE, "OMW_BLUE_COMMANDER")
    OMW.AirOps.BlueCommander:AddAirwing(cfg.Airwing)
    OMW.AirOps.BlueCommander:Start()

    return true
  end)

  if not started or not result then
    cfg.Status = "ERROR"
    log("ERROR: AIRWING/COMMANDER activation failed: " .. tostring(result))
    return
  end

  cfg.Status = "OPERATIONAL"
  log("RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.")
  log("SUMMARY inventory=OH58D:24/AH64D:8/UH60:8/CH47:8 corePlayerSlots=6 optionalUH60L=0or2 dynamicAIReserve=4 runtimeParking=10or12 templateAircraft=7nonRuntime staticCaps=OH58D:7/AH64D:4/UH60:4/CH47:5 zones=11 templates=5 squadrons=4 medevac=twoIndependentSinglesAsOnePackage virtualReserve=true.")
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 18)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 18)
end
