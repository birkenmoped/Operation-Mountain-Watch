local config = {
  configurationVersion = "TM02V-red-proxy-movement-2",
  testId = "TM02",
  stageId = "TM02V",
  movementId = "TEST.TM02.VIRTUAL.PACKET.001",

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
    sourcePolicy = "LEADER_FROM_MOVEMENT_TEMPLATE",
    sourceUnitIndex = 1,
    runtimeAliasPrefix = "TM02V_RED_PROXY_",
    expectedUnitCount = 1,
  },

  physical = {
    runtimeAliasPrefix = "TM02V_RED_FULL_",
  },

  headquarters = {
    nodeId = "RED_HQ",
    initialPersonnel = 40,
    zoneName = "ZONE_TM02N_HQ",
  },

  shelters = {
    { nodeId = "RED_SHELTER_A", label = "A", parentNodeId = "RED_HQ", zoneName = "ZONE_TM02N_A", targetStrength = 10, initialGarrison = 10 },
    { nodeId = "RED_SHELTER_B", label = "B", parentNodeId = "RED_HQ", zoneName = "ZONE_TM02N_B", targetStrength = 10, initialGarrison = 10 },
    { nodeId = "RED_SHELTER_AA", label = "AA", parentNodeId = "RED_SHELTER_A", zoneName = "ZONE_TM02N_AA", targetStrength = 10, initialGarrison = 4 },
    { nodeId = "RED_SHELTER_AB", label = "AB", parentNodeId = "RED_SHELTER_A", zoneName = "ZONE_TM02N_AB", targetStrength = 10, initialGarrison = 10 },
    { nodeId = "RED_SHELTER_BA", label = "BA", parentNodeId = "RED_SHELTER_B", zoneName = "ZONE_TM02N_BA", targetStrength = 10, initialGarrison = 10 },
    { nodeId = "RED_SHELTER_BB", label = "BB", parentNodeId = "RED_SHELTER_B", zoneName = "ZONE_TM02N_BB", targetStrength = 10, initialGarrison = 10 },
  },

  recordedLosses = 6,

  movement = {
    strength = 6,
    routeNodeIds = { "RED_HQ", "RED_SHELTER_A", "RED_SHELTER_AA" },
    finalDestinationNodeId = "RED_SHELTER_AA",
    monitorInitialDelaySeconds = 2,
    monitorIntervalSeconds = 2,
  },

  routing = {
    speedKph = 5,
    formation = "Off Road",
    assignmentDelaySeconds = 1,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markerEnabledOnStart = true,
    markerId = 220201,
  },
}

return config
