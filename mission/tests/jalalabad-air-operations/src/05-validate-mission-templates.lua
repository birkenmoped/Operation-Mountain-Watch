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

-- Public MOOSE wrapper path for Mission Editor templates, including unoccupied
-- Client groups and Late-Activation templates. GROUP:Register() creates a
-- wrapper reference only; GROUP:GetTemplate() remains the template source.
local function findMissionTemplate(name)
  if not name or not GROUP then return nil end

  local group = GROUP:FindByName(name)
  if not group and GROUP.Register then
    local registerOK, registered = pcall(function() return GROUP:Register(name) end)
    if registerOK then group = registered end
  end
  if not group or not group.GetTemplate then return nil end

  local templateOK, template = pcall(function() return group:GetTemplate() end)
  if not templateOK or type(template) ~= "table" then return nil end
  return template
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR Jalalabad manifest unavailable")
    return
  end

  local requiredPlayerGroups = {}
  appendAll(requiredPlayerGroups, cfg.PlayerGroups.Required.OH58D)
  appendAll(requiredPlayerGroups, cfg.PlayerGroups.Required.AH64D)
  appendAll(requiredPlayerGroups, cfg.PlayerGroups.Required.CH47)

  local requiredAITemplates = {
    cfg.Templates.OH58DRecon,
    cfg.Templates.AH64DCAS,
    cfg.Templates.UH60MedevacLead,
    cfg.Templates.UH60MedevacCover,
    cfg.Templates.CH47HeavyLift
  }

  local optionalGroups = {}
  appendAll(optionalGroups, cfg.PlayerGroups.Optional.UH60L)

  local statics = {}
  appendAll(statics, cfg.Statics.OH58D)
  appendAll(statics, cfg.Statics.AH64D)
  appendAll(statics, cfg.Statics.UH60)
  appendAll(statics, cfg.Statics.CH47)

  check("REQUIRED_PLAYER_TEMPLATE", requiredPlayerGroups, findMissionTemplate)
  check("REQUIRED_AI_TEMPLATE", requiredAITemplates, findMissionTemplate)

  local optionalPresent, optionalMissing = check("OPTIONAL_UH60L_TEMPLATE", optionalGroups, findMissionTemplate)
  if optionalPresent ~= 0 and optionalPresent ~= 2 then
    log(string.format("ERROR OPTIONAL_UH60L_TEMPLATE partial-set present=%d missing=%d expected=0-or-2", optionalPresent, optionalMissing))
  end

  check("STATIC", statics, function(name) return STATIC and STATIC:FindByName(name, false) end)
  check("ZONE", cfg.Zones, function(name) return ZONE and ZONE:FindByName(name) end)

  local warehouse = (STATIC and STATIC:FindByName(cfg.WarehouseName, false)) or
                    (UNIT and UNIT:FindByName(cfg.WarehouseName))
  log("WAREHOUSE_ANCHOR " .. (warehouse and "OK" or "MISSING") .. " " .. cfg.WarehouseName)
  log("RAMP_MODEL inventory=24/8/8/8 playerPerType=2 staticCaps=7/4/4/5 comparableParking=36 templateLookup=GROUP:Register+GetTemplate")
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 5)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 5)
end
