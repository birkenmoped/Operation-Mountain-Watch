local config = {
  configurationVersion = "TM02W2-red-source-cost-reservation-2",
  testId = "TM02",
  stageId = "TM02W2",

  mission = {
    fileName = "OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz",
    displayName = "OMW TM02W2 - RED Source and Cost Selection",
  },

  -- W2 reuses the exact W1 Mission Editor fixture. All eleven RED locations
  -- are active logical nodes for the planner test; this does not imply that
  -- production missions must occupy every candidate site.
  network = {
    configurationVersion = "TM02W2-network-fixture-1",
    testId = "TM02",
    stageId = "TM02W2_NETWORK",
    mission = {
      fileName = "OMW_TEST_TM02W2_RED_SOURCE_COST_SELECTION.miz",
      displayName = "OMW TM02W2 - RED Source and Cost Selection",
    },
    prefixes = {
      headquarters = "OMW_RED_HQ_",
      subHeadquarters = "OMW_RED_SUBHQ_",
      site = "OMW_RED_SITE_",
      nodeArea = "OMW_RED_NODEAREA_",
      blueObjective = "OMW_BLUE_OBJECTIVE_",
    },
    locations = {
      { siteId = "OMW_RED_HQ_Main", role = "HEADQUARTERS", commandAreaId = "CENTRAL", commandParentId = nil, initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SUBHQ_Left", role = "SUB_HEADQUARTERS", commandAreaId = "LEFT", commandParentId = "OMW_RED_HQ_Main", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SUBHQ_Right", role = "SUB_HEADQUARTERS", commandAreaId = "RIGHT", commandParentId = "OMW_RED_HQ_Main", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Central_01", role = "STATION", commandAreaId = "CENTRAL", commandParentId = "OMW_RED_HQ_Main", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Central_02", role = "STATION", commandAreaId = "CENTRAL", commandParentId = "OMW_RED_HQ_Main", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Central_03", role = "STATION", commandAreaId = "CENTRAL", commandParentId = "OMW_RED_HQ_Main", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Central_04", role = "STATION", commandAreaId = "CENTRAL", commandParentId = "OMW_RED_HQ_Main", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Left_01", role = "STATION", commandAreaId = "LEFT", commandParentId = "OMW_RED_SUBHQ_Left", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Left_02", role = "STATION", commandAreaId = "LEFT", commandParentId = "OMW_RED_SUBHQ_Left", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Right_01", role = "STATION", commandAreaId = "RIGHT", commandParentId = "OMW_RED_SUBHQ_Right", initialNodeStatus = "ACTIVE" },
      { siteId = "OMW_RED_SITE_Right_02", role = "STATION", commandAreaId = "RIGHT", commandParentId = "OMW_RED_SUBHQ_Right", initialNodeStatus = "ACTIVE" },
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
      { objectiveId = "OMW_BLUE_OBJECTIVE_FOB", objectiveType = "FOB", associatedSiteIds = { "OMW_RED_SITE_Left_01", "OMW_RED_SITE_Left_02" } },
      { objectiveId = "OMW_BLUE_OBJECTIVE_Airport", objectiveType = "AIRPORT", associatedSiteIds = { "OMW_RED_SITE_Right_01", "OMW_RED_SITE_Right_02" } },
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
      showMessages = false,
      enableF10Menu = false,
      markersEnabledOnStart = false,
      markerIdBase = 220400,
    },
  },

  personnel = {
    -- currentPersonnel, guardFloor, defensiveTarget and hardCapacity are
    -- deliberately independent. Sources may be used only above guardFloor.
    { siteId = "OMW_RED_HQ_Main", currentPersonnel = 30, guardFloor = 12, defensiveTarget = 24, hardCapacity = 40 },
    { siteId = "OMW_RED_SUBHQ_Left", currentPersonnel = 10, guardFloor = 8, defensiveTarget = 10, hardCapacity = 18 },
    { siteId = "OMW_RED_SUBHQ_Right", currentPersonnel = 10, guardFloor = 8, defensiveTarget = 10, hardCapacity = 18 },
    { siteId = "OMW_RED_SITE_Central_01", currentPersonnel = 10, guardFloor = 4, defensiveTarget = 8, hardCapacity = 16 },
    { siteId = "OMW_RED_SITE_Central_02", currentPersonnel = 10, guardFloor = 4, defensiveTarget = 8, hardCapacity = 16 },
    { siteId = "OMW_RED_SITE_Central_03", currentPersonnel = 12, guardFloor = 4, defensiveTarget = 10, hardCapacity = 16 },
    { siteId = "OMW_RED_SITE_Central_04", currentPersonnel = 12, guardFloor = 4, defensiveTarget = 10, hardCapacity = 16 },
    { siteId = "OMW_RED_SITE_Left_01", currentPersonnel = 2, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, planningPriority = 100 },
    { siteId = "OMW_RED_SITE_Left_02", currentPersonnel = 4, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, planningPriority = 90 },
    { siteId = "OMW_RED_SITE_Right_01", currentPersonnel = 2, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, planningPriority = 100 },
    { siteId = "OMW_RED_SITE_Right_02", currentPersonnel = 6, guardFloor = 2, defensiveTarget = 8, hardCapacity = 12, planningPriority = 80 },
  },

  planning = {
    maxPacketStrength = 6,
    distanceWeight = 1,
    crossAreaPenalty = 750,
    depletionPenaltyPerPersonBelowTarget = 1800,
    fragmentationPenaltyPerMissingPerson = 2500,
    maxTasks = 12,
    requireAllDeficitsReserved = true,
    requireMultipleCandidateEvaluations = true,
    requireMultiHopTask = true,
    requireReservationInfluence = true,

    -- Whether a non-nearest source is optimal depends on the real mission
    -- geometry and inventory state. DCS records the count but does not fail
    -- when the nearest viable source also has the lowest total cost.
    -- The static Lua harness overrides this to true on controlled geometry.
    requireNonNearestSelection = false,
  },

  debug = {
    showMessages = true,
    enableF10Menu = true,
  },
}

return config
