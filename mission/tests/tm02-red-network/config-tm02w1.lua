local config = {
  configurationVersion = "TM02W1-red-network-command-movement-3",
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
    blueObjective = "OMW_BLUE_OBJECTIVE_",
  },

  -- This is a fixed W1 test fixture, not a production minimum or maximum.
  locations = {
    {
      siteId = "OMW_RED_HQ_Main",
      role = "HEADQUARTERS",
      commandAreaId = "CENTRAL",
      commandParentId = nil,
      initialNodeStatus = "ACTIVE",
    },
    {
      siteId = "OMW_RED_SUBHQ_Left",
      role = "SUB_HEADQUARTERS",
      commandAreaId = "LEFT",
      commandParentId = "OMW_RED_HQ_Main",
      initialNodeStatus = "ACTIVE",
    },
    {
      siteId = "OMW_RED_SUBHQ_Right",
      role = "SUB_HEADQUARTERS",
      commandAreaId = "RIGHT",
      commandParentId = "OMW_RED_HQ_Main",
      initialNodeStatus = "ACTIVE",
    },
    {
      siteId = "OMW_RED_SITE_Central_01",
      role = "STATION",
      commandAreaId = "CENTRAL",
      commandParentId = "OMW_RED_HQ_Main",
    },
    {
      siteId = "OMW_RED_SITE_Central_02",
      role = "STATION",
      commandAreaId = "CENTRAL",
      commandParentId = "OMW_RED_HQ_Main",
    },
    {
      siteId = "OMW_RED_SITE_Central_03",
      role = "STATION",
      commandAreaId = "CENTRAL",
      commandParentId = "OMW_RED_HQ_Main",
    },
    {
      siteId = "OMW_RED_SITE_Central_04",
      role = "STATION",
      commandAreaId = "CENTRAL",
      commandParentId = "OMW_RED_HQ_Main",
    },
    {
      siteId = "OMW_RED_SITE_Left_01",
      role = "STATION",
      commandAreaId = "LEFT",
      commandParentId = "OMW_RED_SUBHQ_Left",
    },
    {
      siteId = "OMW_RED_SITE_Left_02",
      role = "STATION",
      commandAreaId = "LEFT",
      commandParentId = "OMW_RED_SUBHQ_Left",
    },
    {
      siteId = "OMW_RED_SITE_Right_01",
      role = "STATION",
      commandAreaId = "RIGHT",
      commandParentId = "OMW_RED_SUBHQ_Right",
    },
    {
      siteId = "OMW_RED_SITE_Right_02",
      role = "STATION",
      commandAreaId = "RIGHT",
      commandParentId = "OMW_RED_SUBHQ_Right",
    },
  },

  movementLinks = {
    { linkId = "MOVE_HQ_C01", sourceSiteId = "OMW_RED_HQ_Main", targetSiteId = "OMW_RED_SITE_Central_01" },
    { linkId = "MOVE_HQ_C02", sourceSiteId = "OMW_RED_HQ_Main", targetSiteId = "OMW_RED_SITE_Central_02" },
    { linkId = "MOVE_C01_C02", sourceSiteId = "OMW_RED_SITE_Central_01", targetSiteId = "OMW_RED_SITE_Central_02" },
    { linkId = "MOVE_C01_C03", sourceSiteId = "OMW_RED_SITE_Central_01", targetSiteId = "OMW_RED_SITE_Central_03" },
    { linkId = "MOVE_C02_C04", sourceSiteId = "OMW_RED_SITE_Central_02", targetSiteId = "OMW_RED_SITE_Central_04" },
    { linkId = "MOVE_C03_C04", sourceSiteId = "OMW_RED_SITE_Central_03", targetSiteId = "OMW_RED_SITE_Central_04" },
    { linkId = "MOVE_C03_SHQ_LEFT", sourceSiteId = "OMW_RED_SITE_Central_03", targetSiteId = "OMW_RED_SUBHQ_Left" },
    { linkId = "MOVE_C04_SHQ_RIGHT", sourceSiteId = "OMW_RED_SITE_Central_04", targetSiteId = "OMW_RED_SUBHQ_Right" },
    { linkId = "MOVE_C03_SHQ_RIGHT", sourceSiteId = "OMW_RED_SITE_Central_03", targetSiteId = "OMW_RED_SUBHQ_Right" },
    { linkId = "MOVE_C04_SHQ_LEFT", sourceSiteId = "OMW_RED_SITE_Central_04", targetSiteId = "OMW_RED_SUBHQ_Left" },
    { linkId = "MOVE_SHQ_LEFT_L01", sourceSiteId = "OMW_RED_SUBHQ_Left", targetSiteId = "OMW_RED_SITE_Left_01" },
    { linkId = "MOVE_SHQ_LEFT_L02", sourceSiteId = "OMW_RED_SUBHQ_Left", targetSiteId = "OMW_RED_SITE_Left_02" },
    { linkId = "MOVE_L01_L02", sourceSiteId = "OMW_RED_SITE_Left_01", targetSiteId = "OMW_RED_SITE_Left_02" },
    { linkId = "MOVE_SHQ_RIGHT_R01", sourceSiteId = "OMW_RED_SUBHQ_Right", targetSiteId = "OMW_RED_SITE_Right_01" },
    { linkId = "MOVE_SHQ_RIGHT_R02", sourceSiteId = "OMW_RED_SUBHQ_Right", targetSiteId = "OMW_RED_SITE_Right_02" },
    { linkId = "MOVE_R01_R02", sourceSiteId = "OMW_RED_SITE_Right_01", targetSiteId = "OMW_RED_SITE_Right_02" },
    { linkId = "MOVE_L02_R01", sourceSiteId = "OMW_RED_SITE_Left_02", targetSiteId = "OMW_RED_SITE_Right_01" },
  },

  objectives = {
    {
      objectiveId = "OMW_BLUE_OBJECTIVE_FOB",
      objectiveType = "FOB",
      associatedSiteIds = {
        "OMW_RED_SITE_Left_01",
        "OMW_RED_SITE_Left_02",
      },
    },
    {
      objectiveId = "OMW_BLUE_OBJECTIVE_Airport",
      objectiveType = "AIRPORT",
      associatedSiteIds = {
        "OMW_RED_SITE_Right_01",
        "OMW_RED_SITE_Right_02",
      },
    },
  },

  graph = {
    defaultWalkingSpeedKph = 5,
    requireAllCommandLocationsReachableFromHq = true,
    requireCommandGraphAcyclic = true,
    requireAllMovementLocationsReachableFromHq = true,
    requireMovementCycle = true,
    requireCrossAreaMovementLink = true,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
    markersEnabledOnStart = true,
    markerIdBase = 220300,
  },
}

return config
