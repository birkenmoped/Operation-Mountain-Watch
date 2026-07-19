local config = {
  configurationVersion = "TM02W2F-red-commander-timeslice-4",
  testId = "TM02",
  stageId = "TM02W2F",

  mission = {
    fileName = "OMW_TEST_TM02W2F_RED_INITIAL_NETWORK_FILL.miz",
    displayName = "OMW TM02W2F - RED Initial Network Fill",
  },

  templatesByStrength = {
    [1] = "TPL_TEST_RED_PACKET_01_01",
    [2] = "TPL_TEST_RED_PACKET_02_01",
    [3] = "TPL_TEST_RED_PACKET_03_01",
    [4] = "TPL_TEST_RED_PACKET_04_01",
    [5] = "TPL_TEST_RED_PACKET_05_01",
    [6] = "TPL_TEST_RED_PACKET_06_01",
    [7] = "TPL_TEST_RED_PACKET_07_01",
    [8] = "TPL_TEST_RED_PACKET_08_01",
    [9] = "TPL_TEST_RED_PACKET_09_01",
    [10] = "TPL_TEST_RED_PACKET_10_01",
  },

  initialFill = {
    supplySiteId = "OMW_RED_HQ_Main",
    totalPersonnel = 112,
    maxPacketStrength = 6,
    targetPersonnelBySiteId = {
      OMW_RED_HQ_Main = 24,
      OMW_RED_SUBHQ_Left = 10,
      OMW_RED_SUBHQ_Right = 10,
      OMW_RED_SITE_Central_01 = 8,
      OMW_RED_SITE_Central_02 = 8,
      OMW_RED_SITE_Central_03 = 10,
      OMW_RED_SITE_Central_04 = 10,
      OMW_RED_SITE_Left_01 = 8,
      OMW_RED_SITE_Left_02 = 8,
      OMW_RED_SITE_Right_01 = 8,
      OMW_RED_SITE_Right_02 = 8,
    },
    optimization = {
      primary = "MINIMIZE_COMPLETION_TIME",
      secondary = "MINIMIZE_TASK_COUNT",
      tertiary = "MINIMIZE_SAFE_ROUTE_DISTANCE",
    },
  },

  commanderTest = {
    planningIntervalSeconds = 30,
    commandBudgetPerCycle = 4,
    maxActiveTransportsGlobal = 8,
    maxActiveTransportsPerFirstEdge = 2,
    spawnIntervalSeconds = 8,
    minimumPredecessorProgressMeters = 250,
    maximumLaunchHoldSeconds = 45,
    schedulerTickSeconds = 1,
  },

  proxy = {
    sourcePolicy = "LEADER_FROM_TASK_TEMPLATE",
    sourceUnitIndex = 1,
    runtimeAliasPrefix = "TM02W2F_RED_PROXY_",
    expectedUnitCount = 1,
    launchSlots = {
      { x = -16, y = -12 }, { x = -8, y = -12 }, { x = 0, y = -12 }, { x = 8, y = -12 }, { x = 16, y = -12 },
      { x = -16, y = -4 },  { x = -8, y = -4 },  { x = 0, y = -4 },  { x = 8, y = -4 },  { x = 16, y = -4 },
      { x = -16, y = 4 },   { x = -8, y = 4 },   { x = 0, y = 4 },   { x = 8, y = 4 },   { x = 16, y = 4 },
      { x = -16, y = 12 },  { x = -8, y = 12 },  { x = 0, y = 12 },  { x = 8, y = 12 },  { x = 16, y = 12 },
    },
  },

  physical = {
    runtimeAliasPrefix = "TM02W2F_RED_GARRISON_",
    transitRuntimeAliasPrefix = "TM02W2F_RED_TRANSIT_FULL_",
  },

  execution = {
    maxActiveTasks = 8,
    maxActiveOutboundPerSource = 8,
    monitorInitialDelaySeconds = 2,
    monitorIntervalSeconds = 2,
    autoStart = false,
  },

  routing = {
    proxyTestSpeedKph = 120,
    formation = "Off Road",
    roadFormation = "On Road",
    offRoadFormation = "Off Road",
    assignmentDelaySeconds = 1,
  },

  navigation = {
    blueObjectiveBufferMeters = 250,
    exclusionClearanceMeters = 200,
    avoidanceRingPointCount = 48,
    maximumRoadSnapMeters = 6000,
    maximumRoadPathMeters = 50000,
    maximumRoadDetourFactor = 8,
    routeWaypointSpacingMeters = 100,
    offRoadWaypointSpacingMeters = 150,
    portalArrivalRadiusMeters = 100,
    combatCooldownSeconds = 90,
  },

  routeReassignmentWatchdog = {
    initialDelaySeconds = 10,
    intervalSeconds = 3,
    sampleWindowSeconds = 24,
    minimumTravelMeters = 5,
    minimumProgressMeters = 4,
    crossTrackLimitMeters = 60,
    maximumRouteReassignmentsPerTask = 3,
    perTaskRecoveryCooldownSeconds = 30,
    globalRecoveryIntervalSeconds = 8,
    blockedResetProgressMeters = 100,
  },

  transitRepresentation = {
    enableF10Menu = true,
    menuTitle = "TM02W2F Initial Network Fill",
    startCommand = "Beschleunigten RED-Commander starten",
    unpackCommand = "Alle Reise-Proxies entpacken",
    packCommand = "Alle Reisegruppen packen",
    statusCommand = "Status anzeigen",
    commanderStatusCommand = "Commander-Status anzeigen",
    listCommand = "Reiseauftraege ins Log schreiben",
    markerCommand = "Task-Marker umschalten",
    transitionIntervalSeconds = 0.75,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220800,
  },
}

return config
