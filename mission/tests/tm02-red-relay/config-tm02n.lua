local config = {
  configurationVersion = "TM02N-red-tree-fill-1",
  testId = "TM02",
  stageId = "TM02N",
  networkId = "TEST.TM02.NETWORK.001",

  template = {
    groupName = "TPL_TEST_RED_PACKET_10_01",
    runtimeAliasPrefix = "TM02N_RED_PACKET_",
    expectedFighterCount = 10,
  },

  headquarters = {
    nodeId = "RED_HQ",
    initialPersonnel = 100,
    zoneName = "ZONE_TM02N_HQ",
  },

  shelters = {
    {
      nodeId = "RED_SHELTER_A",
      label = "A",
      parentNodeId = "RED_HQ",
      zoneName = "ZONE_TM02N_A",
      targetStrength = 10,
    },
    {
      nodeId = "RED_SHELTER_B",
      label = "B",
      parentNodeId = "RED_HQ",
      zoneName = "ZONE_TM02N_B",
      targetStrength = 10,
    },
    {
      nodeId = "RED_SHELTER_AA",
      label = "AA",
      parentNodeId = "RED_SHELTER_A",
      zoneName = "ZONE_TM02N_AA",
      targetStrength = 10,
    },
    {
      nodeId = "RED_SHELTER_AB",
      label = "AB",
      parentNodeId = "RED_SHELTER_A",
      zoneName = "ZONE_TM02N_AB",
      targetStrength = 10,
    },
    {
      nodeId = "RED_SHELTER_BA",
      label = "BA",
      parentNodeId = "RED_SHELTER_B",
      zoneName = "ZONE_TM02N_BA",
      targetStrength = 10,
    },
    {
      nodeId = "RED_SHELTER_BB",
      label = "BB",
      parentNodeId = "RED_SHELTER_B",
      zoneName = "ZONE_TM02N_BB",
      targetStrength = 10,
    },
  },

  packets = {
    {
      packetId = "TEST.TM02.NET.PACKET.001",
      runtimeAliasSuffix = "001",
      routeNodeIds = { "RED_HQ", "RED_SHELTER_A", "RED_SHELTER_AA" },
    },
    {
      packetId = "TEST.TM02.NET.PACKET.002",
      runtimeAliasSuffix = "002",
      routeNodeIds = { "RED_HQ", "RED_SHELTER_B", "RED_SHELTER_BA" },
    },
    {
      packetId = "TEST.TM02.NET.PACKET.003",
      runtimeAliasSuffix = "003",
      routeNodeIds = { "RED_HQ", "RED_SHELTER_A", "RED_SHELTER_AB" },
    },
    {
      packetId = "TEST.TM02.NET.PACKET.004",
      runtimeAliasSuffix = "004",
      routeNodeIds = { "RED_HQ", "RED_SHELTER_B", "RED_SHELTER_BB" },
    },
    {
      packetId = "TEST.TM02.NET.PACKET.005",
      runtimeAliasSuffix = "005",
      routeNodeIds = { "RED_HQ", "RED_SHELTER_A" },
    },
    {
      packetId = "TEST.TM02.NET.PACKET.006",
      runtimeAliasSuffix = "006",
      routeNodeIds = { "RED_HQ", "RED_SHELTER_B" },
    },
  },

  movement = {
    packetStrength = 10,
    maxActivePackets = 2,
    monitorInitialDelaySeconds = 5,
    monitorIntervalSeconds = 5,
  },

  routing = {
    speedKph = 5,
    formation = "Off Road",
    assignmentDelaySeconds = 1,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
  },
}

return config
