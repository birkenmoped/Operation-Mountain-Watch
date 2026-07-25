local TAG = "[OMW][DumpAircraftTypes]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end
local prefixes = { "CLIENT_US_JBAD_", "TPL_AIR_US_JBAD_" }

local function main()
  if not _DATABASE or not _DATABASE.Templates or not _DATABASE.Templates.Groups then
    log("ERROR: MOOSE group template database unavailable")
    return
  end

  local found = 0
  for groupName, data in pairs(_DATABASE.Templates.Groups) do
    local matches = false
    for _, prefix in ipairs(prefixes) do
      if string.sub(groupName, 1, #prefix) == prefix then matches = true break end
    end

    if matches then
      found = found + 1
      local units = data.Template and data.Template.units or {}
      for index, unit in ipairs(units) do
        log(string.format("Group=%s Unit=%d Name=%s Type=%s Skill=%s Livery=%s",
          groupName, index, tostring(unit.name), tostring(unit.type), tostring(unit.skill), tostring(unit.livery_id)))
      end
    end
  end

  log("Matching template groups=" .. tostring(found))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 6) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 6) end
