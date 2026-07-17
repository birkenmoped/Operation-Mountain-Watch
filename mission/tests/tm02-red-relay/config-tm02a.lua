local config = {
  configurationVersion = "TM02A-red-relay-foundation-1",
  testId = "TM02",
  stageId = "TM02A",
  networkId = "TEST.TM02.RELAY.001",

  template = {
    groupName = "TPL_TEST_RED_PACKET_06_01",
    runtimeAlias = "TM02A_RED_RELAY_001",
    expectedFighterCount = 6,
  },

  movement = {
    movementId = "TEST.TM02.MOVEMENT.001",
    fighterCount = 6,
    maxActiveMovements = 1,
  },

  nodes = {
    {
      nodeId = "RED_NODE_TM02A_SOURCE",
      nodeType = "RED_RELAY_SOURCE",
      zoneName = "ZONE_TM02A_SOURCE",
      garrisonAlive = 24,
      minimumGarrison = 18,
      successorNodeId = "RED_NODE_TM02A_DESTINATION",
      representationState = "DOMAIN_ONLY",
    },
    {
      nodeId = "RED_NODE_TM02A_DESTINATION",
      nodeType = "RED_RELAY_DESTINATION",
      zoneName = "ZONE_TM02A_DESTINATION",
      garrisonAlive = 6,
      minimumGarrison = 12,
      successorNodeId = nil,
      representationState = "DOMAIN_ONLY",
    },
  },

  transfer = {
    sourceNodeId = "RED_NODE_TM02A_SOURCE",
    destinationNodeId = "RED_NODE_TM02A_DESTINATION",
  },

  zones = {
    start = "ZONE_TM02A_SOURCE",
    routeAnchors = {
      "ZONE_TM02A_ROUTE_01",
    },
    target = "ZONE_TM02A_DESTINATION",
  },

  routing = {
    speedKph = 5,
    formation = "ON_ROAD",
    roadOnly = true,
  },

  policy = {
    allowNodeSkipping = false,
    allowRespawn = false,
    allowTeleport = false,
    allowAutomaticUnstuck = false,
    allowAutomaticReroute = false,
    allowVirtualRepresentation = false,
    allowHiddenBlueData = false,
  },

  debug = {
    enabled = true,
    showMessages = true,
    enableF10Menu = true,
  },
}

return config
