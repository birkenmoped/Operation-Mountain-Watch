local config = {
  configurationVersion = "TM02W2E-red-reserved-task-execution-1",
  testId = "TM02",
  stageId = "TM02W2E",

  mission = {
    fileName = "OMW_TEST_TM02W2E_RED_TASK_EXECUTION.miz",
    displayName = "OMW TM02W2E - RED Reserved Task Execution",
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
    -- Technical acceleration for the geographically large real test fixture.
    -- This is proxy travel speed, not a doctrinal infantry movement rate.
    proxyTestSpeedKph = 120,
    formation = "Off Road",
    assignmentDelaySeconds = 1,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220600,
  },
}

return config
