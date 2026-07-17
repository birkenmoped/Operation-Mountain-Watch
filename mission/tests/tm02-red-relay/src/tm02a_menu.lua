local TM02AMenu = {}

function TM02AMenu.create(options)
  local rootMenu = MENU_MISSION:New("OMW Tests")
  local testMenu = MENU_MISSION:New("TM02A", rootMenu)

  MENU_MISSION_COMMAND:New(
    "Validate configuration",
    testMenu,
    options.onValidateConfiguration
  )
  MENU_MISSION_COMMAND:New(
    "Show RED relay status",
    testMenu,
    options.onShowRelayStatus
  )
  MENU_MISSION_COMMAND:New(
    "Start one relay transfer",
    testMenu,
    options.onStartTransfer
  )
  MENU_MISSION_COMMAND:New(
    "Show active movement",
    testMenu,
    options.onShowActiveMovement
  )

  return {
    root = rootMenu,
    test = testMenu,
  }
end

return TM02AMenu
