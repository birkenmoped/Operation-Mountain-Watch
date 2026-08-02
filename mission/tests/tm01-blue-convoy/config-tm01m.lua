local config = {
  configurationVersion = "TM01M-moose-native-five-convoys-5",
  testId = "TM01",
  stageId = "TM01M",

  mission = {
    fileName = "OMW_TEST_TM01M_MooseFirst.miz",
    displayName = "OMW TM01M - Five MOOSE Native MSR Convoys",
  },

  template = {
    groupName = "TPL_BLUE_CONVOY_STANDARD_07",
    expectedVehicleCount = 7,
  },

  templateLibrary = {
    activeSelectionMode = "FIXED_STANDARD_07",
    plannedSelectionMode = "MOOSE_InitRandomizeTemplate",
    availableGroups = {
      {
        groupName = "TPL_BLUE_CONVOY_LIGHT_06",
        variant = "LIGHT",
        expectedVehicleCount = 6,
      },
      {
        groupName = "TPL_BLUE_CONVOY_STANDARD_07",
        variant = "STANDARD",
        expectedVehicleCount = 7,
      },
    },
    legacyGroupNames = {
      "TPL_TEST_BLUE_CONVOY_STANDARD_01",
    },
  },

  convoys = {
    {
      id = "EAST_E3_BGR_KBL",
      displayName = "MSR HORSESHOE Bagram to Kabul",
      runtimeAlias = "TM01M_E3_BGR_KBL",
      startZone = "OMW_LOG_NODE_BAGRAM",
      targetZone = "OMW_LOG_NODE_KABUL",
      msrPathlines = { "MSR_EAST_E03" },
    },
    {
      id = "EAST_E2_KBL_JBAD",
      displayName = "MSR ILLINOIS-E2 Kabul to Jalalabad",
      runtimeAlias = "TM01M_E2_KBL_JBAD",
      startZone = "OMW_LOG_NODE_KABUL",
      targetZone = "OMW_LOG_NODE_JALALABAD",
      msrPathlines = { "MSR_EAST_E02" },
    },
    {
      id = "EAST_E1_TRK_JBAD",
      displayName = "MSR ILLINOIS-E1 Torkham to Jalalabad",
      runtimeAlias = "TM01M_E1_TRK_JBAD",
      startZone = "OMW_LOG_NODE_TORKHAM",
      targetZone = "OMW_LOG_NODE_JALALABAD",
      msrPathlines = { "MSR_EAST_E01" },
    },
    {
      id = "KUNAR_K1_JBAD_ASAD",
      displayName = "MSR CALIFORNIA-C1 Jalalabad to Asadabad",
      runtimeAlias = "TM01M_K1_JBAD_ASAD",
      startZone = "OMW_LOG_NODE_JALALABAD",
      targetZone = "OMW_LOG_NODE_ASADABAD",
      msrPathlines = { "MSR_KUNAR_K01" },
    },
    {
      id = "CAL_ASAD_BOSTIK",
      displayName = "MSR CALIFORNIA-C2/C3 Asadabad to FOB Bostick",
      runtimeAlias = "TM01M_CAL_ASAD_BOS",
      startZone = "OMW_LOG_NODE_ASADABAD",
      targetZone = "OMW_LOG_NODE_BOSTICK",
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
