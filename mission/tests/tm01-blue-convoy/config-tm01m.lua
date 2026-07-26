local config = {
  configurationVersion = "TM01M-moose-native-msr-pathline-1",
  testId = "TM01",
  stageId = "TM01M",

  mission = {
    fileName = "OMW_TEST_TM01M_MooseFirst.miz",
    displayName = "OMW TM01M - MOOSE Native MSR Convoy",
  },

  template = {
    groupName = "TPL_TEST_BLUE_CONVOY_STANDARD_01",
    runtimeAlias = "TM01M_BLUE_CONVOY",
    expectedVehicleCount = 6,
  },

  zones = {
    start = "ZONE_TM01_START_BAGRAM",
    target = "ZONE_TM01_TARGET_JALALABAD",
  },

  routing = {
    msrPathlines = {
      "MSR_EAST_E03",
      "MSR_EAST_E02",
    },
    speedKph = 30,
    formation = "On Road",
    routeDelaySeconds = 1,
    routeStartLeadMeters = 100,
    waypointSpacingMeters = 2500,
    vehicleSpacingMeters = 18,
    minimumVehicleSeparationMeters = 8,
    spawnRearClearanceMeters = 20,
    headingSampleMeters = 10,
    minimumRoutePointSeparationMeters = 2,
    minimumWaypointSeparationMeters = 25,
    maximumZoneRoadSnapMeters = 175,
    maximumSpawnRoadSnapMeters = 30,
    maximumPathlineJoinMeters = 250,
    maximumWaypointRoadSnapMeters = 250,
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
