local config = {
  configurationVersion = "TM01C-automatic-player-and-enemy-interest-8",
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

    -- Unpack first tries the exact proxy progress and then small forward offsets.
    -- The selected offset is always logged; there is no silent teleport.
    unpackLeadOffsetCandidatesMeters = { 0, 15, 30, 45, 60 },
  },

  representationInterest = {
    -- Shared transition policy. Packing is allowed only while every enabled
    -- relevance source is outside its own pack boundary for the full delay.
    enabled = true,
    packDelaySeconds = 30,
    retrySeconds = 5,
  },

  playerInterest = {
    -- Visual proof-of-concept only. This is horizontal proximity, not line of sight,
    -- sensor detection, threat relevance, or a production relevance radius.
    enabled = true,
    unpackRadiusMeters = 500,
    packRadiusMeters = 750,
  },

  enemyInterest = {
    -- Deterministic enemy-proximity proof of concept. Each listed name identifies
    -- one separate RED one-unit picket group placed along the convoy route.
    -- Only living units in these explicit groups count. This is not DCS detection,
    -- LOS, hostile intent, sensor contact, or fire-event processing.
    enabled = true,
    unpackRadiusMeters = 750,
    packRadiusMeters = 1000,
    groupNames = {
      "TEST_TM01E_RED_INFANTRY_01",
      "TEST_TM01E_RED_INFANTRY_02",
      "TEST_TM01E_RED_INFANTRY_03",
      "TEST_TM01E_RED_INFANTRY_04",
      "TEST_TM01E_RED_INFANTRY_05",
      "TEST_TM01E_RED_INFANTRY_06",
      "TEST_TM01E_RED_INFANTRY_07",
      "TEST_TM01E_RED_INFANTRY_08",
      "TEST_TM01E_RED_INFANTRY_09",
      "TEST_TM01E_RED_INFANTRY_10",
    },
  },

  transitions = {
    pollSeconds = 1,
    markerUpdateSeconds = 5,
    destroyConfirmationPollSeconds = 0.5,
    destroyConfirmationTimeoutSeconds = 10,
    automaticUnpackAtTarget = true,

    -- A newly spawned DCS group normally remains in ACTIVATING_ROUTE until its
    -- controller accepted the route and measurable physical movement occurred.
    -- Enemy-triggered unpack is the deliberate exception: DCS ground AI may
    -- accept the route but hold position to engage the nearby threat. In that
    -- context successful route assignment plus verified damage restoration is
    -- sufficient; the controller must remain serviceable for later auto-pack.
    routeActivationInitialDelaySeconds = 1,
    routeActivationPollSeconds = 1,
    routeActivationReissueSeconds = 5,
    routeActivationTimeoutSeconds = 30,
    routeActivationMovementThresholdMeters = 2,
    allowStationaryEnemyTriggeredUnpack = true,

    -- Damage is domain state keyed by stable vehicle slot. It is sampled while
    -- physical and explicitly restored and verified after a representation spawn.
    damageCaptureTolerancePercent = 0.05,
    damageRestoreTolerancePercent = 1,
    damageRestoreRetrySeconds = 1,
    damageRestoreMaxAttempts = 5,
  },

  debug = {
    enabled = true,
    showMessages = true,
    enableF10Menu = true,
  },

  excludedSystems = {
    revealWindows = true,
    automaticPlayerInterestDetection = false,
    automaticEnemyInterestDetection = false,
    persistenceAcrossMissionRestart = true,
    cargoUnits = true,
    manifests = true,
    warehouses = true,
  },
}

return config
