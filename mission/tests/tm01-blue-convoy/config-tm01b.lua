local config = {
  configurationVersion = "TM01B-controlled-caching-5",
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

    -- Each circular Mission Editor trigger zone is the complete visibility
    -- window: inside = physical, outside = virtual. Entry and exit are derived
    -- automatically from the ordered road path through the circle.
    revealWindows = {
      {
        id = "REVEAL_01",
        zone = "ZONE_TM01_REVEAL_01",
      },
      {
        id = "REVEAL_02",
        zone = "ZONE_TM01_REVEAL_02",
      },
    },
  },

  routing = {
    roadOnly = true,
    speedKph = 30,
    formation = "ON_ROAD",

    -- Global road geometry and physical route resolution.
    routeSampleMeters = 20,
    physicalWaypointSpacingMeters = 250,
    maximumRoadSnapMeters = 1500,
    roadPositionToleranceMeters = 3,

    -- Six template slots are placed individually on the road centerline.
    vehicleSpacingMeters = 18,
    spawnInteriorMarginMeters = 12,
    physicalClearanceMeters = 40,
  },

  virtualization = {
    configuredSpeedKph = 30,
    effectiveSpeedKph = 23,
    initialSectionIndex = 1,
    finalSectionIndex = 2,
    preserveVehicleSlots = true,
    preserveLosses = true,
    allowDuplicatePhysicalGroup = false,

    automaticAdvance = true,
    automaticMaterialization = true,
    automaticDematerialization = true,
    visibilityMode = "CIRCULAR_WINDOW_ANY_UNIT_INSIDE",
    automationPollSeconds = 1,
    minimumVirtualLegSeconds = 1,

    -- The virtual convoy position is shown to BLUE and updated periodically.
    showVirtualMarker = true,
    virtualMarkerUpdateSeconds = 5,
    showRevealWindowMarkers = true,

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
    automaticPlayerInterestDetection = true,
    automaticUnstuck = true,
    automaticRouteRecalculation = true,
  },
}

return config
