-- Operation Mountain Watch - complete Jalalabad Air Operations node validation and activation
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
      log(string.format("ERROR GROUP_TEMPLATE %s unit=%d type=%s expected=%s", name, index, tostring(typeName), expectedType))
      return false
    end
  end

  log(string.format("OK GROUP_TEMPLATE %s type=%s size=%d", name, expectedType, expectedSize))
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
    log(string.format("ERROR STATIC %s type=%s expected=%s", name, tostring(typeName), expectedType))
    return false
  end

  log(string.format("OK STATIC %s type=%s", name, expectedType))
  return true
end

local function validateOptionalUH60L(groups)
  local present = {}
  for _, name in ipairs(groups or {}) do
    local template = getMissionTemplate(name)
    if template then
      present[#present + 1] = { Name = name, Template = template }
    end
  end

  if #present == 0 then
    log("OPTIONAL UH60L player slots absent=4 accepted=true coreMissionUnaffected=true")
    return true
  end

  if #present ~= 4 then
    log(string.format("ERROR OPTIONAL UH60L player slots must be either 0 or 4; present=%d", #present))
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

  log(string.format("OPTIONAL UH60L player slots present=4 type=%s accepted=true", tostring(detectedType)))
  return true
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR: Jalalabad configuration is unavailable.")
    return
  end

  -- The previously declared 24/8/6 manifest omitted the locally based CH-47
  -- heavy-lift element visible in 2011 imagery and documented in contemporary
  -- Task Force Shooter reporting. Never activate the node while this correction
  -- is pending; doing so would produce a false COMPLETE result.
  if cfg.CorrectionPending and cfg.CorrectionPending.CH47 then
    cfg.Status = "INCOMPLETE_CH47_CORRECTION"
    log("ERROR: CH-47 heavy-lift component is required but not yet implemented in the complete-node manifest.")
    log("RESULT: INCOMPLETE. AIRWING and COMMANDER remain unstarted pending the revised CH-47 squadron, templates, slots, statics and parking plan.")
    return
  end

  local ok = true

  if not cfg.Airwing then
    log("ERROR: AIRWING is not constructed.")
    ok = false
  end

  if not cfg.Squadrons or not cfg.Squadrons.OH58D then
    log("ERROR: OH-58D SQUADRON is unavailable.")
    ok = false
  end
  if not cfg.Squadrons or not cfg.Squadrons.AH64D then
    log("ERROR: AH-64D SQUADRON is unavailable.")
    ok = false
  end
  if not cfg.Squadrons or not cfg.Squadrons.UH60 then
    log("ERROR: UH-60 SQUADRON is unavailable.")
    ok = false
  end
  if not cfg.Squadrons or not cfg.Squadrons.CH47 then
    log("ERROR: CH-47 SQUADRON is unavailable.")
    ok = false
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

  for _, name in ipairs(cfg.PlayerGroups.Required.OH58D) do
    if not validateMissionGroup(name, "OH58D", 1) then ok = false end
  end
  for _, name in ipairs(cfg.PlayerGroups.Required.AH64D) do
    if not validateMissionGroup(name, "AH-64D_BLK_II", 1) then ok = false end
  end

  if not validateMissionGroup(cfg.Templates.OH58DRecon, "OH58D", 2) then ok = false end
  if not validateMissionGroup(cfg.Templates.AH64DCAS, "AH-64D_BLK_II", 2) then ok = false end
  if not validateMissionGroup(cfg.Templates.UH60MedevacLead, "UH-60A", 1) then ok = false end
  if not validateMissionGroup(cfg.Templates.UH60MedevacCover, "UH-60A", 1) then ok = false end

  for _, name in ipairs(cfg.Statics.OH58D) do
    if not validateStatic(name, "OH58D") then ok = false end
  end
  for _, name in ipairs(cfg.Statics.AH64D) do
    if not validateStatic(name, "AH-64D_BLK_II") then ok = false end
  end
  for _, name in ipairs(cfg.Statics.UH60) do
    if not validateStatic(name, "UH-60A") then ok = false end
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

  if not validateOptionalUH60L(cfg.PlayerGroups.Optional.UH60L) then
    ok = false
  end

  if cfg.Inventory.OH58D ~= 24 or cfg.Inventory.AH64D ~= 8 or cfg.Inventory.UH60 ~= 6 or cfg.Inventory.CH47 ~= 8 then
    log("ERROR: Inventory manifest does not match 24/8/6/8.")
    ok = false
  end
  if cfg.Limits.PlayerPerType ~= 4 or cfg.Limits.AIPerType ~= 4 or
     cfg.Limits.ConcurrentSupportMissions ~= 2 or cfg.Limits.AircraftPerMission ~= 2 or
     cfg.Limits.ConcurrentSupportAircraft ~= 4 then
    log("ERROR: Air Operations limits do not match the locked policy.")
    ok = false
  end
  if cfg.Medevac.PackageSize ~= 2 or cfg.Medevac.LeadAircraft ~= 1 or
     cfg.Medevac.CoverAircraft ~= 1 or cfg.Medevac.AllowSingleShip ~= false then
    log("ERROR: MEDEVAC package policy must be 1 lead + 1 cover with no single-ship fallback.")
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
  log("SUMMARY inventory=OH58D:24/AH64D:8/UH60:6/CH47:8 medevac=1+1.")
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 16)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 16)
end
