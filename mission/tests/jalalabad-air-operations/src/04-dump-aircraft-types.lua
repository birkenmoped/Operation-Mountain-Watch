local TAG = "[OMW][DumpAircraftTypes]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function appendUnique(target, seen, name)
  if name and name ~= "" and not seen[name] then
    seen[name] = true
    target[#target + 1] = name
  end
end

local function getMissionTemplate(name)
  if not name or not _DATABASE or not _DATABASE.GetGroupTemplate then return nil end
  local ok, template = pcall(function() return _DATABASE:GetGroupTemplate(name) end)
  if not ok or type(template) ~= "table" then return nil end
  return template
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR: Jalalabad configuration unavailable")
    return
  end
  if not _DATABASE or not _DATABASE.GetGroupTemplate then
    log("ERROR: MOOSE DATABASE:GetGroupTemplate unavailable")
    return
  end

  local groupNames, seen = {}, {}
  for _, name in pairs(cfg.Templates or {}) do appendUnique(groupNames, seen, name) end
  for _, key in ipairs({ "OH58D", "AH64D", "CH47" }) do
    for _, name in ipairs((cfg.PlayerGroups.Required and cfg.PlayerGroups.Required[key]) or {}) do
      appendUnique(groupNames, seen, name)
    end
  end
  for _, name in ipairs((cfg.PlayerGroups.Optional and cfg.PlayerGroups.Optional.UH60L) or {}) do
    appendUnique(groupNames, seen, name)
  end
  table.sort(groupNames)

  local found = 0
  for _, groupName in ipairs(groupNames) do
    local template = getMissionTemplate(groupName)
    if template then
      found = found + 1
      for index, unit in ipairs(template.units or {}) do
        log(string.format("Group=%s Unit=%d Name=%s Type=%s Skill=%s Livery=%s",
          groupName, index, tostring(unit.name), tostring(unit.type), tostring(unit.skill), tostring(unit.livery_id)))
      end
    else
      log("MISSING GROUP_TEMPLATE " .. tostring(groupName))
    end
  end

  log(string.format("Matching configured template groups=%d configured=%d source=DATABASE:GetGroupTemplate", found, #groupNames))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 6) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 6) end
