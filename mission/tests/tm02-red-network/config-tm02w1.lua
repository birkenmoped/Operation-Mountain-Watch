local config = {
  configurationVersion = "TM02W1-red-network-registry-2",
  testId = "TM02",
  stageId = "TM02W1",

  mission = {
    fileName = "OMW_TEST_TM02W1_RED_NETWORK_REGISTRY.miz",
    displayName = "OMW TM02W1 - RED Network Registry",
  },

  prefixes = {
    headquarters = "OMW_RED_HQ_",
    subHeadquarters = "OMW_RED_SUBHQ_",
    site = "OMW_RED_SITE_",
    nodeArea = "OMW_RED_NODEAREA_",
  },

  expected = {
    headquarters = {
      "OMW_RED_HQ_Test",
    },
    subHeadquarters = {
      "OMW_RED_SUBHQ_A",
      "OMW_RED_SUBHQ_B",
    },
    sites = {
      "OMW_RED_SITE_AA",
      "OMW_RED_SITE_AB",
      "OMW_RED_SITE_BA",
      "OMW_RED_SITE_BB",
    },
    nodeAreas = {},
  },

  -- W1 uses explicit logical links between the seven existing TM02 zones.
  -- No additional Mission Editor route groups or route waypoints are required.
  links = {
    {
      linkId = "TM02W1_LINK_HQ_A",
      sourceSiteId = "OMW_RED_HQ_Test",
      targetSiteId = "OMW_RED_SUBHQ_A",
      direction = "BIDIRECTIONAL",
    },
    {
      linkId = "TM02W1_LINK_HQ_B",
      sourceSiteId = "OMW_RED_HQ_Test",
      targetSiteId = "OMW_RED_SUBHQ_B",
      direction = "BIDIRECTIONAL",
    },
    {
      linkId = "TM02W1_LINK_A_AA",
      sourceSiteId = "OMW_RED_SUBHQ_A",
      targetSiteId = "OMW_RED_SITE_AA",
      direction = "BIDIRECTIONAL",
    },
    {
      linkId = "TM02W1_LINK_A_AB",
      sourceSiteId = "OMW_RED_SUBHQ_A",
      targetSiteId = "OMW_RED_SITE_AB",
      direction = "BIDIRECTIONAL",
    },
    {
      linkId = "TM02W1_LINK_B_BA",
      sourceSiteId = "OMW_RED_SUBHQ_B",
      targetSiteId = "OMW_RED_SITE_BA",
      direction = "BIDIRECTIONAL",
    },
    {
      linkId = "TM02W1_LINK_B_BB",
      sourceSiteId = "OMW_RED_SUBHQ_B",
      targetSiteId = "OMW_RED_SITE_BB",
      direction = "BIDIRECTIONAL",
    },
    {
      -- Cross-link proves that the production graph is not restricted to a tree.
      linkId = "TM02W1_LINK_AB_BA",
      sourceSiteId = "OMW_RED_SITE_AB",
      targetSiteId = "OMW_RED_SITE_BA",
      direction = "BIDIRECTIONAL",
    },
  },

  graph = {
    defaultWalkingSpeedKph = 5,
    requireAllLocationsConnectedToHq = true,
    requireAlternativeConnection = true,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220300,
  },
}

return config
