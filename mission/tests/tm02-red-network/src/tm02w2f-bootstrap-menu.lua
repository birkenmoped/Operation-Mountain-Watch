local TM02W2FBootstrapMenu = {}

function TM02W2FBootstrapMenu.install(config, build)
  local state = {
    phase = "INITIALIZING",
    detail = "bootstrap started",
    navigationValid = false,
    routingReady = false,
    executionReady = false,
    errorCount = 0,
    warningCount = 0,
    menu = nil,
  }

  local function log(level, event, fields)
    local keys, parts = {}, {}
    for key in pairs(fields or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key]):gsub("[\r\n]", " ")
    end
    env.info("[OMW][TM02W2F][BOOTSTRAP] level=" .. level .. " event=" .. event
      .. (#parts > 0 and (" " .. table.concat(parts, " ")) or ""))
  end

  local function showStatus()
    trigger.action.outText(table.concat({
      "TM02W2F bootstrap: " .. tostring(state.phase),
      "Detail: " .. tostring(state.detail),
      "Navigation valid: " .. tostring(state.navigationValid),
      "Task routing ready: " .. tostring(state.routingReady),
      "Execution ready: " .. tostring(state.executionReady),
      "Errors / warnings: " .. tostring(state.errorCount) .. " / " .. tostring(state.warningCount),
    }, "\n"), 20)
    log("INFO", "bootstrap_status_requested", {
      phase = state.phase,
      detail = state.detail,
      navigationValid = state.navigationValid,
      routingReady = state.routingReady,
      executionReady = state.executionReady,
      errorCount = state.errorCount,
      warningCount = state.warningCount,
    })
  end

  function state:update(values)
    for key, value in pairs(values or {}) do self[key] = value end
    log(self.phase == "READY" and "INFO" or "WARNING", "bootstrap_state_changed", {
      configurationVersion = config.configurationVersion,
      buildTimestamp = build and build.buildTimestamp or "unknown",
      phase = self.phase,
      detail = self.detail,
      navigationValid = self.navigationValid,
      routingReady = self.routingReady,
      executionReady = self.executionReady,
      errorCount = self.errorCount,
      warningCount = self.warningCount,
    })
  end

  if type(MENU_MISSION) == "table" and type(MENU_MISSION_COMMAND) == "table" then
    local root = MENU_MISSION:New("OMW Tests")
    local menu = MENU_MISSION:New("TM02W2F Bootstrap", root)
    MENU_MISSION_COMMAND:New("Bootstrap-Status anzeigen", menu, showStatus)
    state.menu = { root = root, menu = menu }
  else
    log("ERROR", "bootstrap_menu_unavailable", {
      menuMissionType = type(MENU_MISSION),
      menuCommandType = type(MENU_MISSION_COMMAND),
    })
  end

  state.showStatus = showStatus
  log("INFO", "bootstrap_menu_installed", {
    configurationVersion = config.configurationVersion,
    buildTimestamp = build and build.buildTimestamp or "unknown",
    menuInstalled = state.menu ~= nil,
  })
  return state
end

return TM02W2FBootstrapMenu
