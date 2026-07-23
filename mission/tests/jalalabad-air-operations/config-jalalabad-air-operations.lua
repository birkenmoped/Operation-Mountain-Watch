-- Operation Mountain Watch - Jalalabad Air Operations manifest.
-- This table is configuration data; it does not create DCS or MOOSE objects.

local config = {
  configurationVersion = "JBAD-air-operations-manifest-1",
  missionFile = "Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz",
  missionSha256 = "898703f5b738a632492e514f8943327634a0d094716fd7f4c971c9b2582fb50b",

  moose = {
    commit = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54",
    buildTimestamp = "2026-06-14T16:11:05+02:00",
    sha256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915",
  },

  airbase = {
    mooseName = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad",
    airwingName = "AW_US_JALALABAD",
    warehouseAnchorName = "WH_AIR_US_JALALABAD",
  },

  policy = {
    maxPlayerAircraftPerType = 4,
    maxAiAircraftPerType = 4,
    maxConcurrentSupportMissions = 2,
    maxAircraftPerSupportMission = 2,
    maxConcurrentSupportAircraft = 4,
    lossesPermanent = true,
    automaticReplacement = false,
    staticsMode = "POOLED",
  },

  pools = {
    oh58d = {
      unit = "6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters",
      aircraftFamily = "OH-58D",
      inventory = 24,
      expectedDcsTypes = { "OH58D" },
      playerSlots = 4,
      maxAiActive = 4,
      initialVisibleStatics = 8,
      squadronName = "SQ_6_6_CAV_OH58D",
      templateName = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
      templateGroups = 2,
      grouping = 2,
    },

    ah64d = {
      unit = "B Company, 1-10 Aviation",
      aircraftFamily = "AH-64D",
      inventory = 8,
      expectedDcsTypes = { "AH-64D_BLK_II" },
      playerSlots = 4,
      maxAiActive = 4,
      initialVisibleStatics = 4,
      squadronName = "SQ_B_1_10_AVN_AH64D",
      templateName = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
      templateGroups = 2,
      grouping = 2,
    },

    uh60 = {
      unit = "Attached Utility / MEDEVAC Element",
      aircraftFamily = "UH-60 family",
      inventory = 6,
      expectedAiDcsTypes = { "UH-60A" },
      expectedPlayerDcsTypes = {},
      playerSlots = 4,
      playerSlotsOptional = true,
      maxAiActive = 4,
      initialVisibleStatics = 2,
      medevacPackageSize = 2,
      leadSquadronName = "SQ_JBAD_UH60_MEDEVAC_LEAD",
      coverSquadronName = "SQ_JBAD_UH60_MEDEVAC_COVER",
      leadTemplateName = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
      coverTemplateName = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP",
      leadTemplateGroups = 2,
      coverTemplateGroups = 2,
      grouping = 1,
    },
  },

  zones = {
    "ZONE_AIR_US_JBAD_STATIC_OH58D",
    "ZONE_AIR_US_JBAD_STATIC_AH64D",
    "ZONE_AIR_US_JBAD_STATIC_UH60",
    "ZONE_AIR_US_JBAD_MEDEVAC_READY",
    "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_JBAD_SLING_PICKUP",
    "ZONE_AIR_US_JBAD_C130_UNLOAD",
  },
}

return config
