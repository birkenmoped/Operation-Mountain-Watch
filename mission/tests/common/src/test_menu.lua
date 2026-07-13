local TestMenu = {}

function TestMenu.create(options)
  local rootMenu = MENU_MISSION:New("OMW Tests")
  local testMenu = MENU_MISSION:New(options.stageId, rootMenu)

  MENU_MISSION_COMMAND:New("Show status", testMenu, options.onShowStatus)
  MENU_MISSION_COMMAND:New("Validate configuration", testMenu, options.onValidateConfiguration)

  return {
    root = rootMenu,
    test = testMenu,
  }
end

return TestMenu
