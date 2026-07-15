local config = {
  configurationVersion = "TM01C-manual-proxy-pack-unpack-1",
  testId = "TM01",
  stageId = "TM01C",
  scenarioId = "TEST.TM01.CONVOY.001",
  routeId = "ROUTE_TM01_BAGRAM_JALALABAD",

  template = {
    groupName = "TPL_TEST_BLUE_CONVOY_STANDARD_01",
    runtimeAliasPrefix = "TM01C_BLUE_CONVOY_001",
    expectedVehicleCount = 6,

    -- Stable original slots, listed from rear to front in the intended march order.
    -- The front-most surviving slot is always the current lead/proxy role.
    slotOrderRearToFront = { 6, 5, 4, 3, 2, 1 },
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
  },

  routing = {
    roadOnly = true,
    speedKph = 30,
    formation = "ON_ROAD",
    routeSampleMeters = 10,
    maximumRoadSnapMeters = 1500,
    roadPositionToleranceMeters = 30,
    vehicleSpacingMeters = 15,
    minimumVehicleSeparationMeters = 8,

    -- Manual unpack first tries the exact proxy progress and then small forward
    -- offsets. The selected offset is always logged; there is no silent teleport.
    unpackLeadOffsetCandidatesMeters = { 0, 15, 30, 45, 60 },
  },

  transitions = {
    pollSeconds = 1,
    markerUpdateSeconds = 5,
    destroyConfirmationPollSeconds = 0.5,
    destroyConfirmationTimeoutSeconds = 10,
    automaticUnpackAtTarget = true,
  },

  debug = {
    enabled = true,
    showMessages = true,
    enableF10Menu = true,
  },

  excludedSystems = {
    revealWindows = true,
    automaticPlayerInterestDetection = true,
    automaticEnemyInterestDetection = true,
    persistenceAcrossMissionRestart = true,
    cargoUnits = true,
    manifests = true,
    warehouses = true,
  },
}

return config
