local config = {
  configurationVersion = "TM01B-controlled-caching-1",
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
    revealSections = {
      {
        id = "REVEAL_01",
        entry = "ZONE_TM01_REVEAL_01_ENTRY",
        exit = "ZONE_TM01_REVEAL_01_EXIT",
        entrySegmentIndex = 0,
        exitSegmentIndex = 2,
        physicalRouteZones = {
          "ZONE_TM01_ROUTE_01",
          "ZONE_TM01_ROUTE_02",
          "ZONE_TM01_REVEAL_01_EXIT",
        },
      },
      {
        id = "REVEAL_02",
        entry = "ZONE_TM01_REVEAL_02_ENTRY",
        exit = "ZONE_TM01_REVEAL_02_EXIT",
        entrySegmentIndex = 5,
        exitSegmentIndex = 7,
        physicalRouteZones = {
          "ZONE_TM01_ROUTE_06",
          "ZONE_TM01_ROUTE_07",
          "ZONE_TM01_REVEAL_02_EXIT",
          "ZONE_TM01_TARGET_JALALABAD",
        },
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