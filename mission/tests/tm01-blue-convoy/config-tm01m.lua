local config = {
  configurationVersion = "TM01M-moose-native-five-convoys-1",
  testId = "TM01",
  stageId = "TM01M",

  mission = {
    fileName = "OMW_TEST_TM01M_MooseFirst.miz",
    displayName = "OMW TM01M - Five MOOSE Native MSR Convoys",
  },

  template = {
    groupName = "TPL_TEST_BLUE_CONVOY_STANDARD_01",
    expectedVehicleCount = 6,
  },

  convoys = {
    {
      id = "EAST_E3_BGR_KBL",
      displayName = "EAST-E3 Bagram to Kabul",
      runtimeAlias = "TM01M_E3_BGR_KBL",
      startZone = "MSR_EAST_E3_START_BAGRAM",
      targetZone = "MSR_EAST_E3_TARGET_KABUL",
      msrPathlines = { "MSR_EAST_E03" },
    },
    {
      id = "EAST_E2_KBL_JBAD",
      displayName = "EAST-E2 Kabul to Jalalabad",
      runtimeAlias = "TM01M_E2_KBL_JBAD",
      startZone = "MSR_EAST_E2_START_KABUL",
      targetZone = "MSR_EAST_E2_TARGET_JALALABAD",
      msrPathlines = { "MSR_EAST_E02" },
    },
    {
      id = "EAST_E1_TRK_JBAD",
      displayName = "EAST-E1 Torkham to Jalalabad",
      runtimeAlias = "TM01M_E1_TRK_JBAD",
      startZone = "MSR_EAST_E1_START_TORKHAM",
      targetZone = "MSR_EAST_E1_TARGET_JALALABAD",
      msrPathlines = { "MSR_EAST_E01" },
    },
    {
      id = "KUNAR_K1_JBAD_ASAD",
      displayName = "KUNAR-K1 Jalalabad to Asadabad",
      runtimeAlias = "TM01M_K1_JBAD_ASAD",
      startZone = "MSR_KUNAR K1_START_JALALABAD",
      targetZone = "MSR_KUNAR K1_TARGET_ASADABAD",
      msrPathlines = { "MSR_KUNAR_K01" },
    },
    {
      id = "CAL_ASAD_BOSTIK",
      displayName = "CALIFORNIA Asadabad to FOB Bostik",
      runtimeAlias = "TM01M_CAL_ASAD_BOS",
      startZone = "MSR_CALIFORNIA_START_ASADABAD",
      targetZone = "MSR_CALIFORNIA_TARGET_FOB_BOSTIK",
      msrPathlines = {
        "MSR_CAL_C01",
        "MSR_CAL_C02",
      },
    },
  },

  routing = {
    speedKph = 50,
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
    enableIndividualMenus = true,
  },
}

return config
