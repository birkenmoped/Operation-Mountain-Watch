local config = {
  testId = "TM02",
  networkId = "TEST.TM02.RELAY.001",

  stages = {
    physical = "TM02A",
    virtualized = "TM02B",
  },

  templates = {
    headquartersGarrison = "TPL_TEST_RED_HQ_GARRISON_18_01",
    nodeGarrison = "TPL_TEST_RED_NODE_GARRISON_12_01",
    personnelPacket = "TPL_TEST_RED_PACKET_06_01",
  },

  movement = {
    model = "RELAY_FORWARD",
    packetStrength = 6,
    maxActivePackets = 3,
    dispatchIntervalSeconds = 120,
    virtualSpeedKph = 5,
    physicalSpeedKph = 5,
    allowNodeSkipping = false,
    allowPacketSplitting = false,
    allowPacketMerging = false,
    prioritizeUnderstrengthNodes = true,
  },

  nodes = {
    {
      nodeId = "RED_HQ",
      zoneName = "ZONE_TM02_HQ",
      minimumGarrison = 18,
      initialGarrison = 18,
      initialReserve = 30,
      predecessorNodeId = nil,
      successorNodeId = "RED_NODE_01",
    },
    {
      nodeId = "RED_NODE_01",
      zoneName = "ZONE_TM02_NODE_01",
      minimumGarrison = 12,
      initialGarrison = 6,
      initialReserve = 0,
      predecessorNodeId = "RED_HQ",
      successorNodeId = "RED_NODE_02",
    },
    {
      nodeId = "RED_NODE_02",
      zoneName = "ZONE_TM02_NODE_02",
      minimumGarrison = 12,
      initialGarrison = 12,
      initialReserve = 0,
      predecessorNodeId = "RED_NODE_01",
      successorNodeId = "RED_NODE_03",
    },
    {
      nodeId = "RED_NODE_03",
      zoneName = "ZONE_TM02_NODE_03",
      minimumGarrison = 12,
      initialGarrison = 12,
      initialReserve = 0,
      predecessorNodeId = "RED_NODE_02",
      successorNodeId = "RED_NODE_04",
    },
    {
      nodeId = "RED_NODE_04",
      zoneName = "ZONE_TM02_NODE_04",
      minimumGarrison = 12,
      initialGarrison = 12,
      initialReserve = 0,
      predecessorNodeId = "RED_NODE_03",
      successorNodeId = "RED_TARGET_BAGRAM",
    },
    {
      nodeId = "RED_TARGET_BAGRAM",
      zoneName = "ZONE_TM02_TARGET_BAGRAM",
      minimumGarrison = 0,
      initialGarrison = 0,
      initialReserve = 0,
      predecessorNodeId = "RED_NODE_04",
      successorNodeId = nil,
      terminal = true,
    },
  },

  revealSections = {
    {
      id = "INTERMEDIATE",
      entry = "ZONE_TM02_REVEAL_INTERMEDIATE_ENTRY",
      exit = "ZONE_TM02_REVEAL_INTERMEDIATE_EXIT",
    },
    {
      id = "BAGRAM",
      entry = "ZONE_TM02_TARGET_BAGRAM",
      exit = nil,
      terminal = true,
    },
  },

  routing = {
    useValidatedSegments = true,
    allowAutomaticUnstuck = false,
    avoidExtremeSlopes = true,
    avoidUnvalidatedRiverCrossings = true,
  },

  watchdog = {
    intervalSeconds = 10,
    stoppedSpeedKph = 0.5,
    stuckAfterSeconds = 180,
    reportOnly = true,
  },

  virtualization = {
    enabledInStage = "TM02B",
    garrisonsRemainPhysical = true,
    movingPacketsVirtualByDefault = true,
    preservePacketStrength = true,
    preservePacketIdentity = true,
    allowDuplicatePhysicalPacket = false,
    debugTransitionDelaySeconds = 5,
  },

  debug = {
    enabled = true,
    showMessages = true,
    showNodeMarkers = true,
    showPacketState = true,
    showVirtualProgress = true,
    enableF10Menu = true,
  },

  excludedSystems = {
    combatAtBagram = true,
    cargoUnits = true,
    warehouses = true,
    persistence = true,
    dynamicRecruitment = true,
    hostileForces = true,
    automaticVisibilityDetection = true,
    tacticalBounding = true,
  },
}

return config
