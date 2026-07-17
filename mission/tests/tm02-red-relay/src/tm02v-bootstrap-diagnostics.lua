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
    if type(config.proxy.templateGroupName) ~= "string"
      or not GROUP:FindByName(config.proxy.templateGroupName) then
      missing[#missing + 1] = tostring(config.proxy.templateGroupName)
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
    })
    announce(table.concat({
      "TM02V diagnostic validation",
      "Mission objects: " .. tostring(#missing == 0),
      "Missing: " .. (#missing == 0 and "none" or join(missing, ", ")),
      #missing == 0 and "Restart the mission to complete normal bootstrap."
        or "Correct the Mission Editor objects, save, and restart the mission.",
    }, "\n"))
  end

  local function showBootstrapStatus()
    local packet = state and state.packet or {}
    log("INFO", "red_proxy_bootstrap_status", {
      failed = state and state.failed == true,
      started = state and state.started == true,
      movementState = packet.movementState or "unknown",
      representationState = packet.representationState or "unknown",
    })
    announce(table.concat({
      "TM02V bootstrap status",
      "Failed: " .. tostring(state and state.failed == true),
      "Started: " .. tostring(state and state.started == true),
      "Movement: " .. tostring(packet.movementState or "unknown"),
      "Representation: " .. tostring(packet.representationState or "unknown"),
    }, "\n"))
  end

  local root = MENU_MISSION:New("OMW Tests")
  local menu = MENU_MISSION:New("TM02V Proxy Movement", root)
  MENU_MISSION_COMMAND:New("Validate test", menu, validateFromMenu)
  MENU_MISSION_COMMAND:New("Show bootstrap status", menu, showBootstrapStatus)
  log("INFO", "red_proxy_diagnostic_menu_ready", {
    path = "OMW Tests/TM02V Proxy Movement",
    commands = "Validate test,Show bootstrap status",
  })
  return { root = root, menu = menu }
end

return TM02VDiagnostics
