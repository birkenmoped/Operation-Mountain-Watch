local config = {
  configurationVersion = "TM01B-controlled-caching-2",
  testId = "TM01",
  stageId = "TM01B",
  scenarioId = "TEST.TM01.CONVOY.001",
  routeId = "ROUTE_TM01_BAGRAM_JALALABAD",

  template = {
    groupName = "TPL_TEST_BLUE_CONVOY_STANDARD_01",
    runtimeAliasPrefix = "TM01B_BLUE_CONVOY_001",
    expectedVehicleCount = 6,
  },

  zones = {
    target = "ZONE_TM01_TARGET_JALALABAD",

    -- The route anchors define one global route corridor. Reveal entry and exit
    -- zones are visibility windows only and are never inserted as waypoints.
    routeAnchors = {
      "ZONE_TM01_ROUTE_01",
      "ZONE_TM01_ROUTE_02",
      "ZONE_TM01_ROUTE_03",
      "ZONE_TM01_ROUTE_04",
      "ZONE_TM01_ROUTE_05",
      "ZONE_TM01_ROUTE_06",
      "ZONE_TM01_ROUTE_07",
    },

    revealSections = {
      {
        id = "REVEAL_01",
        entry = "ZONE_TM01_REVEAL_01_ENTRY",
        exit = "ZONE_TM01_REVEAL_01_EXIT",
        entrySegmentIndex = 0,
        exitSegmentIndex = 2,
      },
      {
        id = "REVEAL_02",
        entry = "ZONE_TM01_REVEAL_02_ENTRY",
        exit = "ZONE_TM01_REVEAL_02_EXIT",
        entrySegmentIndex = 5,
        exitSegmentIndex = 7,
      },
    },
  },

  routing = {
    roadOnly = true,
    speedKph = 30,
    formation = "ON_ROAD",
  },

  virtualization = {
    configuredSpeedKph = 30,
    effectiveSpeedKph = 23,
    initialSectionIndex = 1,
    finalSectionIndex = 2,
    preserveVehicleSlots = true,
    preserveLosses = true,
    allowDuplicatePhysicalGroup = false,
    automaticAdvance = false,
    automaticMaterialization = false,
    automaticDematerialization = false,
    destroyConfirmationPollSeconds = 0.5,
    destroyConfirmationTimeoutSeconds = 10,
  },

  debug = {
    enabled = true,
    showMessages = true,
    enableF10Menu = true,
  },

  excludedSystems = {
    cargoUnits = true,
    manifests = true,
    warehouses = true,
    persistence = true,
    hostileForces = true,
    automaticVisibilityDetection = true,
    automaticUnstuck = true,
    automaticRouteRecalculation = true,
  },
}

return config
