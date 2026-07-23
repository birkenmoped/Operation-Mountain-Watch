local TAG = "[OMW][ValidateMissionTemplates]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function appendAll(target, source)
  for _, value in ipairs(source or {}) do
    target[#target + 1] = value
  end
end

local function check(kind, names, finder)
  local present, missing = 0, 0
  for _, name in ipairs(names or {}) do
    local ok, object = pcall(finder, name)
    if ok and object then
      present = present + 1
      log("OK " .. kind .. " " .. name)
    else
      missing = missing + 1
      log("MISSING " .. kind .. " " .. name)
    end
  end
  log(string.format("SUMMARY %s present=%d missing=%d", kind, present, missing))
  return present, missing
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR Jalalabad manifest unavailable")
    return
  end

  local requiredGroups = {}
  appendAll(requiredGroups, cfg.PlayerGroups.Required.OH58D)
  appendAll(requiredGroups, cfg.PlayerGroups.Required.AH64D)
  requiredGroups[#requiredGroups + 1] = cfg.Templates.OH58DRecon
  requiredGroups[#requiredGroups + 1] = cfg.Templates.AH64DCAS
  requiredGroups[#requiredGroups + 1] = cfg.Templates.UH60MedevacLead
  requiredGroups[#requiredGroups + 1] = cfg.Templates.UH60MedevacCover

  local optionalGroups = {}
  appendAll(optionalGroups, cfg.PlayerGroups.Optional.UH60L)

  local statics = {}
  appendAll(statics, cfg.Statics.OH58D)
  appendAll(statics, cfg.Statics.AH64D)
  appendAll(statics, cfg.Statics.UH60)

  check("REQUIRED_GROUP", requiredGroups, function(name) return GROUP and GROUP:FindByName(name) end)
  local optionalPresent, optionalMissing = check("OPTIONAL_UH60L_GROUP", optionalGroups, function(name) return GROUP and GROUP:FindByName(name) end)
  if optionalPresent ~= 0 and optionalPresent ~= 4 then
    log(string.format("ERROR OPTIONAL_UH60L_GROUP partial-set present=%d missing=%d expected=0-or-4", optionalPresent, optionalMissing))
  end

  check("STATIC", statics, function(name) return STATIC and STATIC:FindByName(name, false) end)
  check("ZONE", cfg.Zones, function(name) return ZONE and ZONE:FindByName(name) end)

  local warehouse = (STATIC and STATIC:FindByName(cfg.WarehouseName, false)) or
                    (UNIT and UNIT:FindByName(cfg.WarehouseName))
  log("WAREHOUSE_ANCHOR " .. (warehouse and "OK" or "MISSING") .. " " .. cfg.WarehouseName)
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 5)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 5)
end
