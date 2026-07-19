local config = {
  configurationVersion = "TM02W2F-red-initial-network-fill-3",
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
    maxActiveTasks = 20,
    maxActiveOutboundPerSource = 20,
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

    watchdogInitialDelaySeconds = 5,
    watchdogIntervalSeconds = 3,
    stuckWindowSeconds = 18,
    minimumTravelMeters = 5,
    minimumProgressMeters = 4,
    circularTravelMeters = 6,
    circularNetMeters = 12,
    routeEfficiencyFloor = 0.15,
    ineffectiveWindowLimit = 2,
    wrongWayMeters = 12,
    crossTrackLimitMeters = 60,
    combatCooldownSeconds = 90,

    localRecoveryStepMeters = 20,
    maxLocalRecoveryAttemptsPerEpisode = 5,
    maxLocalRelocationMetersPerEpisode = 100,
    roadRecoverySearchStartMeters = 50,
    roadRecoverySearchEndMeters = 500,
    roadRecoverySearchStepMeters = 25,
    roadRecoverySnapLimitMeters = 120,
    maxRoadRecoveriesPerLeg = 3,
    progressRequiredToResetEpisodeMeters = 300,
    progressRequiredToResetEpisodeSeconds = 60,
    terminalRecoveryEnabled = false,

    -- The inherited V5 watchdog is still used in this stacked test. Give it
    -- only 20-metre relocations, so it cannot reach its terminal-jump branch
    -- during a normal TM02W2F run. Any terminal-relocation log is a hard FAIL.
    recoveryAdvanceSequenceMeters = {},
    terminalRecoveryDistanceFromPortalMeters = 25,
  },

  transitRepresentation = {
    enableF10Menu = true,
    menuTitle = "TM02W2F Initial Network Fill",
    startCommand = "Initiales Auffuellen starten",
    unpackCommand = "Alle Reise-Proxies entpacken",
    packCommand = "Alle Reisegruppen packen",
    statusCommand = "Status anzeigen",
    listCommand = "Reiseauftraege ins Log schreiben",
    markerCommand = "Task-Marker umschalten",
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220800,
  },
}

for index = 1, 250 do
  config.navigation.recoveryAdvanceSequenceMeters[index] = 20
end

return config
