-- Operation Mountain Watch - exact Mission Editor and MOOSE runtime-name contract
local TAG = "[OMW][AirOps.JBAD.NAMES]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function missionTemplate(name)
  return _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[name] or nil
end

local function append(target, values)
  for _, value in ipairs(values or {}) do target[#target + 1] = value end
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then log("ERROR: Jalalabad configuration unavailable.") return end
  if cfg.PackageContractsOK ~= true then log("ERROR: Package contracts unavailable; name validation blocked.") return end

  cfg.NameContractOK = false
  cfg.AuthoringGroupNames = {}
  cfg.AuthoringUnitNames = {}
  cfg.RuntimeGroupPrefixes = {}
  local ok = true

  local fixedGroups = {}
  for _, name in pairs(cfg.Templates or {}) do fixedGroups[#fixedGroups + 1] = name end
  for _, key in ipairs({ "OH58D", "AH64D", "CH47" }) do append(fixedGroups, cfg.PlayerGroups.Required and cfg.PlayerGroups.Required[key]) end
  append(fixedGroups, cfg.PlayerGroups.Optional and cfg.PlayerGroups.Optional.UH60L)
  for groupName, unitNames in pairs((cfg.PlayerGroups and cfg.PlayerGroups.Excluded) or {}) do
    fixedGroups[#fixedGroups + 1] = groupName
    for _, unitName in ipairs(unitNames or {}) do cfg.AuthoringUnitNames[unitName] = groupName end
  end

  for _, groupName in ipairs(fixedGroups) do
    if cfg.AuthoringGroupNames[groupName] then
      ok = false
      log("ERROR DUPLICATE_CONFIGURED_GROUP_NAME name=" .. tostring(groupName))
    end
    cfg.AuthoringGroupNames[groupName] = true
    local entry = missionTemplate(groupName)
    if not entry or not entry.Template then
      local optional = string.sub(groupName, 1, #"CLIENT_US_JBAD_UH60L_") == "CLIENT_US_JBAD_UH60L_"
      if not optional then ok = false log("ERROR CONFIGURED_GROUP_MISSING name=" .. tostring(groupName)) end
    else
      for _, unit in ipairs(entry.Template.units or {}) do
        local unitName = unit and unit.name
        if not unitName or unitName == "" then
          ok = false
          log("ERROR EMPTY_UNIT_NAME group=" .. tostring(groupName))
        elseif cfg.AuthoringUnitNames[unitName] and cfg.AuthoringUnitNames[unitName] ~= groupName then
          ok = false
          log(string.format("ERROR DUPLICATE_UNIT_NAME unit=%s groups=%s,%s", unitName, cfg.AuthoringUnitNames[unitName], groupName))
        else
          cfg.AuthoringUnitNames[unitName] = groupName
        end
      end
    end
  end

  local prefixOwner = {}
  for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
    local prefix = cfg:GetRuntimeGroupPrefix(key)
    local contract = cfg:GetSquadronContract(key)
    if not prefix or prefix == "" or prefixOwner[prefix] or not contract then
      ok = false
      log(string.format("ERROR RUNTIME_PREFIX_INVALID squadron=%s prefix=%s owner=%s contract=%s", key, tostring(prefix), tostring(prefixOwner[prefix]), tostring(contract ~= nil)))
    else
      prefixOwner[prefix] = key
      cfg.RuntimeGroupPrefixes[key] = prefix
      log(string.format("RUNTIME_PREFIX squadron=%s prefix=%s grouping=%d unitRules=<group>%s model=%s", key, prefix, contract.Grouping, table.concat(contract.RuntimeUnitSuffixes, ",<group>"), contract.Model))
    end
  end

  for groupName in pairs(cfg.AuthoringGroupNames) do
    for key, prefix in pairs(cfg.RuntimeGroupPrefixes) do
      if string.sub(groupName, 1, #prefix) == prefix then
        ok = false
        log(string.format("ERROR AUTHORING_NAME_COLLIDES_WITH_RUNTIME_PREFIX group=%s squadron=%s prefix=%s", groupName, key, prefix))
      end
    end
  end

  cfg.NameContractOK = ok
  if ok then
    local groupCount, unitCount = 0, 0
    for _ in pairs(cfg.AuthoringGroupNames) do groupCount = groupCount + 1 end
    for _ in pairs(cfg.AuthoringUnitNames) do unitCount = unitCount + 1 end
    log(string.format("RESULT: PASS fixedGroups=%d fixedUnits=%d runtimePrefixes=4 typeOnlyMatching=false packageAwareUnitSuffixes=true", groupCount, unitCount))
  else
    log("RESULT: FAIL AIRWING_START_BLOCKED=true")
  end
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 8.5) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 8.5) end
