local config = {
  configurationVersion = "TM01M-moose-native-physical-1",
  testId = "TM01",
  stageId = "TM01M",

  mission = {
    fileName = "OMW_TEST_TM01M_MOOSE_NATIVE_CONVOY.miz",
    displayName = "OMW TM01M - MOOSE Native Physical Convoy",
  },

  template = {
    groupName = "TPL_TEST_BLUE_CONVOY_01",
    runtimeAlias = "TM01M_BLUE_CONVOY",
    expectedVehicleCount = 6,
  },

  zones = {
    start = "ZONE_TM01_START_BAGRAM",
    target = "ZONE_TM01_TARGET_JALALABAD",
    routeAnchors = {
      "ZONE_TM01_ROUTE_01",
      "ZONE_TM01_ROUTE_02",
      "ZONE_TM01_ROUTE_03",
      "ZONE_TM01_ROUTE_04",
      "ZONE_TM01_ROUTE_05",
      "ZONE_TM01_ROUTE_06",
      "ZONE_TM01_ROUTE_07",
    },
  },

  routing = {
    speedKph = 30,
    formation = "On Road",
    routeDelaySeconds = 1,
  },

  supervision = {
    initialDelaySeconds = 5,
    intervalSeconds = 5,
  },

  messages = {
    durationSeconds = 15,
    category = "OMW TM01M",
  },

  debug = {
    enableF10Menu = true,
  },
}

return config
