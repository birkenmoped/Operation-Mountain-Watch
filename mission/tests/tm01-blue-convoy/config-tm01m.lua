local config = {
  configurationVersion = "TM01M-moose-native-five-convoys-3",
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
      displayName = "MSR HORSESHOE Bagram to Kabul",
      runtimeAlias = "TM01M_E3_BGR_KBL",
      startZone = "MSR_HORSESHOE_START_BAGRAM",
      targetZone = "MSR_HORSESHOE_E3_TARGET_KABUL",
      msrPathlines = { "MSR_EAST_E03" },
    },
    {
      id = "EAST_E2_KBL_JBAD",
      displayName = "MSR ILLINOIS-E2 Kabul to Jalalabad",
      runtimeAlias = "TM01M_E2_KBL_JBAD",
      startZone = "MSR_ILLINOIS_E2_START_KABUL",
      targetZone = "MSR_ILLINOIS_E2_TARGET_JALALABAD",
      msrPathlines = { "MSR_EAST_E02" },
    },
    {
      id = "EAST_E1_TRK_JBAD",
      displayName = "MSR ILLINOIS-E1 Torkham to Jalalabad",
      runtimeAlias = "TM01M_E1_TRK_JBAD",
      startZone = "MSR_ILLINOIS_E1_START_TORKHAM",
      targetZone = "MSR_ILLINOIS_E1_TARGET_JALALABAD",
      msrPathlines = { "MSR_EAST_E01" },
    },
    {
      id = "KUNAR_K1_JBAD_ASAD",
      displayName = "MSR CALIFORNIA-C1 Jalalabad to Asadabad",
      runtimeAlias = "TM01M_K1_JBAD_ASAD",
      startZone = "MSR_CALIFORNIA-C1_START_JALALABAD",
      targetZone = "MSR_CALIFORNIA-C1_TARGET_ASADABAD",
      msrPathlines = { "MSR_KUNAR_K01" },
    },
    {
      id = "CAL_ASAD_BOSTIK",
      displayName = "MSR CALIFORNIA-C2/C3 Asadabad to FOB Bostik",
      runtimeAlias = "TM01M_CAL_ASAD_BOS",
      startZone = "MSR_CALIFORNIA-C2_START_ASADABAD",
      targetZone = "MSR_CALIFORNIA-C03_TARGET_FOB_BOSTIK",
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

  arrival = {
    despawnDelaySeconds = 60,
    generateDestroyEvents = false,
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
