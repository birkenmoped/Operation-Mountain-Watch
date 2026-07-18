local TM02VDiagnostics = {}

local function join(values, separator)
  local parts = {}
  for index, value in ipairs(values or {}) do
    parts[index] = tostring(value)
  end
  return table.concat(parts, separator or ",")
end

function TM02VDiagnostics.install(config, state)
  local prefix = "[OMW][TM02V]"

  local function log(level, event, fields)
    local keys = {}
    local parts = {}
    for key in pairs(fields or {}) do
      keys[#keys + 1] = key
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info(prefix .. " level=" .. level .. " event=" .. event
      .. (#parts > 0 and " " .. table.concat(parts, " ") or ""))
  end

  local function announce(text)
    trigger.action.outText(text, 14)
  end

  local function inspectMissionObjects()
    local missing = {}
    for strength = 1, 10 do
      local templateName = config.templatesByStrength[strength]
      if type(templateName) ~= "string" or not GROUP:FindByName(templateName) then
        missing[#missing + 1] = tostring(templateName)
      end
    end
    local zoneNames = { config.headquarters.zoneName }
    for _, definition in ipairs(config.shelters or {}) do
      zoneNames[#zoneNames + 1] = definition.zoneName
    end
    for _, zoneName in ipairs(zoneNames) do
      if type(zoneName) ~= "string" or not ZONE:FindByName(zoneName) then
        missing[#missing + 1] = tostring(zoneName)
      end
    end
    return missing
  end

  local function validateFromMenu()
    local missing = inspectMissionObjects()
    log("INFO", "red_proxy_diagnostic_validation", {
      missionObjectsValid = #missing == 0,
      missingObjects = #missing == 0 and "none" or join(missing, ","),
      missionRestartRequired = #missing > 0,
      dynamicPacketGeneration = true,
    })
    announce(table.concat({
      "TM02V diagnostic validation",
      "Mission objects: " .. tostring(#missing == 0),
      "Dynamic packet generation: true",
      "Missing: " .. (#missing == 0 and "none" or join(missing, ", ")),
      #missing == 0 and "Restart the mission to complete normal bootstrap."
        or "Correct the Mission Editor objects, save, and restart the mission.",
    }, "\n"))
  end

  local function showBootstrapStatus()
    log("INFO", "red_proxy_bootstrap_status", {
      failed = state and state.failed == true,
      started = state and state.started == true,
      generatedPacketCount = state and state.packets and #state.packets or 0,
      activePacketCount = state and state.activePacketCount or 0,
      dynamicPacketGeneration = true,
    })
    announce(table.concat({
      "TM02V bootstrap status",
      "Failed: " .. tostring(state and state.failed == true),
      "Started: " .. tostring(state and state.started == true),
      "Dynamic packet generation: true",
      "Generated packets: " .. tostring(state and state.packets and #state.packets or 0),
      "Active packets: " .. tostring(state and state.activePacketCount or 0),
    }, "\n"))
  end

  local root = MENU_MISSION:New("OMW Tests")
  local menu = MENU_MISSION:New("TM02V Dynamic Proxy Fill", root)
  MENU_MISSION_COMMAND:New("Validate test", menu, validateFromMenu)
  MENU_MISSION_COMMAND:New("Show bootstrap status", menu, showBootstrapStatus)
  log("INFO", "red_proxy_diagnostic_menu_ready", {
    path = "OMW Tests/TM02V Dynamic Proxy Fill",
    commands = "Validate test,Show bootstrap status",
  })
  return { root = root, menu = menu }
end

return TM02VDiagnostics
