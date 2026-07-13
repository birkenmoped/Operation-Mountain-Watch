local TestMenu = {}

function TestMenu.create(options)
  local rootMenu = MENU_MISSION:New("OMW Tests")
  local testMenu = MENU_MISSION:New(options.stageId, rootMenu)

  MENU_MISSION_COMMAND:New("Show status", testMenu, options.onShowStatus)
  MENU_MISSION_COMMAND:New("Validate configuration", testMenu, options.onValidateConfiguration)
  MENU_MISSION_COMMAND:New("Spawn convoy", testMenu, options.onSpawnConvoy)
  MENU_MISSION_COMMAND:New("Show convoy status", testMenu, options.onShowConvoyStatus)
  MENU_MISSION_COMMAND:New("Start convoy route", testMenu, options.onStartConvoyRoute)
  MENU_MISSION_COMMAND:New("Show route status", testMenu, options.onShowRouteStatus)

  return {
    root = rootMenu,
    test = testMenu,
  }
end

return TestMenu
