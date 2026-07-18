local config = {
  configurationVersion = "TM02W1-red-network-registry-1",
  testId = "TM02",
  stageId = "TM02W1",

  mission = {
    fileName = "OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz",
    displayName = "OMW TM02W1 - RED Network Registry",
    routeCoalition = "red",
  },

  prefixes = {
    headquarters = "OMW_RED_HQ_",
    subHeadquarters = "OMW_RED_SUBHQ_",
    site = "OMW_RED_SITE_",
    nodeArea = "OMW_RED_NODEAREA_",
    route = "OMW_RED_ROUTE_",
  },

  expected = {
    headquarters = {
      "OMW_RED_HQ_Test",
    },
    subHeadquarters = {
      "OMW_RED_SUBHQ_Test",
    },
    sites = {
      "OMW_RED_SITE_RearCompound",
      "OMW_RED_SITE_FrontFarm",
      "OMW_RED_SITE_ValleyHouse",
      "OMW_RED_SITE_ReplacementFarm",
    },
    nodeAreas = {},
    routes = {
      "OMW_RED_ROUTE_HQ_SubHQ",
      "OMW_RED_ROUTE_SubHQ_Rear",
      "OMW_RED_ROUTE_Rear_Front",
      "OMW_RED_ROUTE_Front_Valley",
      "OMW_RED_ROUTE_Rear_Valley",
      "OMW_RED_ROUTE_Rear_Replacement",
    },
  },

  graph = {
    direction = "BIDIRECTIONAL",
    defaultWalkingSpeedKph = 5,
    endpointToleranceMeters = 0,
    requireAllLocationsConnectedToHq = true,
    requireAlternativeConnection = true,
    requireLateActivationRoutes = true,
    requireSingleUnitRouteGroups = true,
    minimumRouteWaypointCount = 2,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220300,
  },
}

return config
