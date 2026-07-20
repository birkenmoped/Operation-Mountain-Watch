local config = {
  configurationVersion = "TM02W2F-red-direct-offroad-progress-watchdog-8",
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
      primary = "MINIMIZE_COMPLETION_TIME_WITH_COMMAND_BUDGET",
      secondary = "MINIMIZE_TASK_COUNT",
      tertiary = "MINIMIZE_SAFE_NETWORK_DISTANCE",
    },
  },

  commanderTest = {
    planningIntervalSeconds = 30,
    commandBudgetPerCycle = 4,
    maxActiveTransportsGlobal = 4,
    maxActiveTransportsPerFirstEdge = 2,
    spawnIntervalSeconds = 10,
    minimumPredecessorProgressMeters = 150,
    schedulerTickSeconds = 1,
    canaryProgressMeters = 75,
    canaryTimeoutSeconds = 120,
    launchHoldWarningSeconds = 60,
  },

  proxy = {
    sourcePolicy = "LEADER_FROM_TASK_TEMPLATE",
    sourceUnitIndex = 1,
    runtimeAliasPrefix = "TM02W2F_RED_PROXY_",
    expectedUnitCount = 1,
    launchSlots = {
      { x = 0, y = 0 },
      { x = 0, y = 0 },
      { x = 0, y = 0 },
      { x = 0, y = 0 },
    },
  },

  physical = {
    runtimeAliasPrefix = "TM02W2F_RED_GARRISON_",
    transitRuntimeAliasPrefix = "TM02W2F_RED_TRANSIT_FULL_",
  },

  execution = {
    maxActiveTasks = 4,
    maxActiveOutboundPerSource = 4,
    monitorInitialDelaySeconds = 2,
    monitorIntervalSeconds = 2,
    autoStart = false,
  },

  routing = {
    proxyTestSpeedKph = 15,
    formation = "Off Road",
    roadFormation = "On Road",
    offRoadFormation = "Off Road",
    assignmentDelaySeconds = 1,
    physicalMode = "DIRECT_OFFROAD_WITH_PROGRESS_RELOCATION_RECOVERY",
    maximumPhysicalWaypointsPerLeg = 4,
  },

  navigation = {
    blueObjectiveBufferMeters = 250,
    combatCooldownSeconds = 90,
    roadsUsedForNormalMovement = false,
    automaticRecoveryEnabled = true,
  },

  watchdog = {
    enabled = true,
    initialDelaySeconds = 8,
    sampleIntervalSeconds = 3,
    stallWindowSeconds = 18,
    minimumTravelMeters = 5,
    minimumProgressMeters = 4,
    circularTravelMeters = 6,
    circularNetMeters = 12,
    routeEfficiencyFloor = 0.15,
    ineffectiveWindowLimit = 2,
    wrongWayMeters = 12,
    crossTrackLimitMeters = 60,
    minimumDistanceToDestinationMeters = 25,
    postRecoveryGraceSeconds = 18,
    perTaskRecoveryCooldownSeconds = 20,
    globalRecoveryIntervalSeconds = 8,

    -- A confirmed off-road stall may relocate the current representation by
    -- exactly 75 m along the already validated direct leg. Four such attempts
    -- are permitted per recovery episode. Pack/unpack is never used.
    maxOffroadRelocationsPerEpisode = 4,
    relocationAdvanceMeters = 75,

    -- Terminal relocation is only available inside the final 100 m and places
    -- the representation no closer than 25 m before the current leg target.
    terminalRecoveryThresholdMeters = 100,
    terminalRecoveryOffsetMeters = 25,

    -- Four failed off-road relocations switch the same representation to one
    -- road route for the remainder of the current leg.
    maximumRoadSnapDistanceMeters = 250,
    minimumRoadSegmentMeters = 60,

    -- Recovery counters reset only after substantial real movement.
    episodeResetProgressMeters = 200,
  },

  transitRepresentation = {
    enableF10Menu = true,
    menuTitle = "TM02W2F Initial Network Fill",
    startCommand = "RED-Commander mit Progress-Watchdog starten",
    unpackCommand = "Alle Reise-Proxies entpacken",
    packCommand = "Alle Reisegruppen packen",
    statusCommand = "Status anzeigen",
    commanderStatusCommand = "Commander-Status anzeigen",
    listCommand = "Reiseauftraege ins Log schreiben",
    markerCommand = "Task-Marker umschalten",
    transitionIntervalSeconds = 1,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220800,
  },
}

return config
