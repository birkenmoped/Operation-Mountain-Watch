-- Operation Mountain Watch - Kandahar dual-airbase diagnostic bootstrap.
-- Read-only configuration. This file does not construct AIRWING or SQUADRON objects.
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.Diagnostic]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

OMW.AirOps.KandaharDiagnostic = {
  Status = "CONFIGURED",
  ExpectedMooseSha256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915",
  SourceMission = "OMW_Template_v4_Kandahar(1).miz",
  SourceMissionSha256 = "07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a",

  Airbases = {
    Main = {
      Name = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar or "Kandahar",
      ExpectedID = 7,
      Role = "MAIN_FIXED_WING"
    },
    Heliport = {
      Name = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar_Heliport or "Kandahar Heliport",
      ExpectedID = 15,
      Role = "MUSTANG_ROTARY_WING"
    }
  },

  MainWarehouseName = "WH_AIR_US_KANDAHAR",
  HeliportWarehouseName = nil,

  Clients = {
    { Name = "CLIENT_US_KAF_A10C_01", Type = "A-10C_2", AirbaseKey = "Main" },
    { Name = "CLIENT_US_KAF_A10C_02", Type = "A-10C_2", AirbaseKey = "Main" },
    { Name = "CLIENT_US_KAF_C130_01", Type = "C-130J-30", AirbaseKey = "Main" },
    { Name = "CLIENT_US_KAF_C130_02", Type = "C-130J-30", AirbaseKey = "Main" },
    { Name = "CLIENT_US_KAF_AH64D_01", Type = "AH-64D_BLK_II", AirbaseKey = "Heliport" },
    { Name = "CLIENT_US_KAF_AH64D_02", Type = "AH-64D_BLK_II", AirbaseKey = "Heliport" },
    { Name = "CLIENT_US_KAF_OH58D_01", Type = "OH58D", AirbaseKey = "Heliport" },
    { Name = "CLIENT_US_KAF_OH58D_02", Type = "OH58D", AirbaseKey = "Heliport" },
    { Name = "CLIENT_US_KAF_CH47F_01", Type = "CH-47Fbl1", AirbaseKey = "Heliport" },
    { Name = "CLIENT_US_KAF_CH47F_02", Type = "CH-47Fbl1", AirbaseKey = "Heliport" }
  },

  Templates = {
    { Name = "TPL_AIR_US_KAF_A10C_CAS_2SHIP", Type = "A-10C", Count = 2, Domain = "USAF" },
    { Name = "TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP", Type = "C-130", Count = 1, Domain = "USAF" },
    { Name = "TPL_AIR_US_KAF_HH60G_CSAR_1SHIP", Type = "UH-60A", Count = 1, Domain = "USAF" },
    { Name = "TPL_AIR_US_KAF_MQ1A_RECON_1SHIP", Type = "RQ-1A Predator", Count = 1, Domain = "ISR" },
    { Name = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP", Type = "MQ-9 Reaper", Count = 1, Domain = "ISR" },
    { Name = "TPL_AIR_US_KAF_AH64D_CAS_2SHIP", Type = "AH-64D_BLK_II", Count = 2, Domain = "ARMY" },
    { Name = "TPL_AIR_US_KAF_OH58D_RECON_2SHIP", Type = "OH58D", Count = 2, Domain = "ARMY" },
    { Name = "TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP", Type = "CH-47Fbl1", Count = 1, Domain = "ARMY" },
    { Name = "TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP", Type = "UH-60A", Count = 2, Domain = "ARMY" },
    { Name = "TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP", Type = "UH-60A", Count = 1, Domain = "ARMY" }
  },

  ExpectedUSStaticTypes = {
    ["A-10C_2"] = 6,
    ["C-130J-30"] = 2,
    ["UH-60A"] = 10,
    ["RQ-1A Predator"] = 2,
    ["MQ-9 Reaper"] = 1,
    ["AH-64D_BLK_II"] = 8,
    ["OH58D"] = 8,
    ["CH-47Fbl1"] = 10
  },

  ExpectedUNStaticTypes = {
    ["Mi-26"] = 2,
    ["UH-1H"] = 4
  },

  RequiredZones = {
    "ZONE_AIR_US_KAF_CSAR_UNLOAD"
  },

  ForbiddenTemplates = {
    "TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP",
    "TPL_AIR_US_KAF_HH60G_CSAR_COVER_1SHIP",
    "TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP",
    "TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP",
    "TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP"
  },

  AirbaseObjects = {},
  ObjectContractOK = false,
  ParkingDiagnosticOK = false,
  Violations = 0,
  ExpectedBlockers = {
    "HELIPORT_AIRWING_NAME_UNAPPROVED",
    "HELIPORT_WAREHOUSE_NAME_UNAPPROVED",
    "HELIPORT_WAREHOUSE_ANCHOR_MISSING",
    "NON_A10_LOGICAL_INVENTORIES_UNDECIDED",
    "ISR_PAYLOAD_DECISIONS_OPEN"
  }
}

log(string.format(
  "CONFIGURED sourceMission=%s sourceSha256=%s expectedMooseSha256=%s noSpawn=true",
  OMW.AirOps.KandaharDiagnostic.SourceMission,
  OMW.AirOps.KandaharDiagnostic.SourceMissionSha256,
  OMW.AirOps.KandaharDiagnostic.ExpectedMooseSha256
))
