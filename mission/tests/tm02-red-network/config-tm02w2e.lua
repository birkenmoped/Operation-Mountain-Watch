local config = {
  configurationVersion = "TM02W2E-red-route-progress-watchdog-5",
  testId = "TM02",
  stageId = "TM02W2E",
  mission = {
    fileName = "OMW_TEST_TM02W2E_RED_TASK_EXECUTION.miz",
    displayName = "OMW TM02W2E - RED Route Progress Watchdog",
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
  proxy = {
    sourcePolicy = "LEADER_FROM_TASK_TEMPLATE",
    sourceUnitIndex = 1,
    runtimeAliasPrefix = "TM02W2E_RED_PROXY_",
    expectedUnitCount = 1,
    launchSlots = {
      { x = -15, y = -10 },
      { x = 0, y = -10 },
      { x = 15, y = -10 },
      { x = -15, y = 10 },
      { x = 0, y = 10 },
      { x = 15, y = 10 },
    },
  },
  physical = {
    runtimeAliasPrefix = "TM02W2E_RED_FULL_",
  },
  execution = {
    maxActiveTasks = 4,
    maxActiveOutboundPerSource = 1,
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
    maximumRoadSnapMeters = 1500,
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

    -- First confirmed navigation failure advances the abstract one-man proxy
    -- 75 m along the already validated safe route. A second confirmed failure
    -- places it 25 m before the portal, still on that safe route. This keeps the
    -- recovery bounded and prevents endless DCS courtyard loops.
    recoveryAdvanceSequenceMeters = { 75 },
    recoveryRoadSnapMeters = 180,
    terminalRecoveryDistanceFromPortalMeters = 25,
  },
  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220600,
  },
}
return config
