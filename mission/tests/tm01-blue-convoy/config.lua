local config = {
  configurationVersion = "TM01A-bootstrap-1",
  testId = "TM01",
  scenarioId = "TEST.TM01.CONVOY.001",
  routeId = "ROUTE_TM01_BAGRAM_JALALABAD",

  stages = {
    physical = "TM01A",
    virtualized = "TM01B",
  },

  template = {
    groupName = "TPL_TEST_BLUE_CONVOY_STANDARD_01",
    expectedVehicleCount = 6,
    expectedSlots = {
      "LEAD_SECURITY",
      "FORWARD_SECURITY",
      "CARGO_TRUCK_01",
      "CARGO_TRUCK_02",
      "SUPPORT_OR_SECURITY",
      "REAR_SECURITY",
    },
  },

  zones = {
    start = "ZONE_TM01_START_BAGRAM",
    target = "ZONE_TM01_TARGET_JALALABAD",

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
      },
      {
        id = "REVEAL_02",
        entry = "ZONE_TM01_REVEAL_02_ENTRY",
        exit = "ZONE_TM01_REVEAL_02_EXIT",
      },
    },
  },

  routing = {
    roadOnly = true,
    speedKph = 30,
    formation = "ON_ROAD",
    allowAutomaticUnstuck = false,
  },

  watchdog = {
    intervalSeconds = 10,
    slowSpeedKph = 5,
    stoppedSpeedKph = 1,
    stuckAfterSeconds = 120,
    reportOnly = true,
  },

  virtualization = {
    enabledInStage = "TM01B",
    virtualSpeedKph = 30,
    preserveVehicleSlots = true,
    preserveLosses = true,
    allowDuplicatePhysicalGroup = false,
    debugTransitionDelaySeconds = 5,
  },

  debug = {
    enabled = true,
    showMessages = true,
    showRouteMarkers = true,
    showRevealMarkers = true,
    showVirtualProgress = true,
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
  },
}

return config
