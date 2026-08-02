-- Operation Mountain Watch - FOB Salerno staged diagnostics
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][SALERNO][DIAG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local RIGHT_APRON = { 26, 27, 28, 29, 30, 31, 32, 33, 34, 37, 38, 39, 41, 42, 43, 44, 45 }
local LEFT_HEAVY_APRON = { 8, 9, 10, 11, 12, 14, 15, 16, 17, 19 }

OMW.AirOps.SalernoDiagnostics = {
  Version = "SAL-SQUADRON-PARKING-SECTORS-10",
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.FOB_Salerno or "FOB Salerno",
  ControlAirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Khost or "Khost",
  ExpectedAirbaseID = 23,
  WarehouseName = "WH_AIR_US_SALERNO",
  ParkingBlacklist = { 13, 21, 22, 23, 24, 25, 35, 36, 40 },
  ParkingBlacklistReasons = {
    [13] = "CLIENT_RESERVED", [21] = "CLIENT_RESERVED", [22] = "CLIENT_RESERVED",
    [23] = "CLIENT_RESERVED", [24] = "STATIC_OH58_PAIR", [25] = "STATIC_OH58_PAIR",
    [35] = "MAIN_APRON_ACCESS_AND_ROLE2_CSAR_UNLOAD", [36] = "CLIENT_RESERVED", [40] = "CLIENT_RESERVED"
  },
  ParkingSectors = {
    RIGHT_ROTARY = RIGHT_APRON,
    LEFT_HEAVY = LEFT_HEAVY_APRON
  },
  Clients = {
    "CLIENT_US_SAL_AH64D_01", "CLIENT_US_SAL_AH64D_02",
    "CLIENT_US_SAL_OH58D_01", "CLIENT_US_SAL_OH58D_02",
    "CLIENT_US_SAL_CH47F_01", "CLIENT_US_SAL_CH47F_02"
  },
  Templates = {
    "TPL_AIR_US_SAL_AH64D_CAS_2SHIP",
    "TPL_AIR_US_SAL_OH58D_RECON_2SHIP",
    "TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP",
    "TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP",
    "TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP"
  },
  SquadronContracts = {
    { Name="SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK", Template="TPL_AIR_US_SAL_AH64D_CAS_2SHIP", LogicalAircraft=8, UnitsPerTemplate=2, Ngroups=4, ResidualAircraft=0, ParkingSector="RIGHT_ROTARY", ParkingIDs=RIGHT_APRON },
    { Name="SQ_US_SAL_OH58D_B_6_6_CAV", Template="TPL_AIR_US_SAL_OH58D_RECON_2SHIP", LogicalAircraft=8, UnitsPerTemplate=2, Ngroups=4, ResidualAircraft=0, ParkingSector="RIGHT_ROTARY", ParkingIDs=RIGHT_APRON },
    { Name="SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT", Template="TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP", LogicalAircraft=7, UnitsPerTemplate=2, Ngroups=3, ResidualAircraft=1, ParkingSector="RIGHT_ROTARY", ParkingIDs=RIGHT_APRON },
    { Name="SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN", Template="TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP", LogicalAircraft=3, UnitsPerTemplate=1, Ngroups=3, ResidualAircraft=0, ParkingSector="RIGHT_ROTARY", ParkingIDs=RIGHT_APRON },
    { Name="SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT", Template="TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP", LogicalAircraft=6, UnitsPerTemplate=1, Ngroups=6, ResidualAircraft=0, ParkingSector="LEFT_HEAVY", ParkingIDs=LEFT_HEAVY_APRON }
  },
  Zones = { "ZONE_AIR_US_SAL_CSAR_UNLOAD" },
  Expected = { ClientGroups=6, TemplateGroups=5, TemplateUnits=8, AircraftStatics=15, Warehouses=1, Zones=1, Squadrons=5 }
}

log("BOOT Version=" .. OMW.AirOps.SalernoDiagnostics.Version)
log("STAGED_TEST=true AIRWING_CONSTRUCT=true SQUADRON_PARKING_SECTORS=true SQUADRON_CONSTRUCT=true SQUADRON_REGISTRATION=true SQUADRON_CONFIG=true MISSION_CAPABILITIES=true PAYLOADS=true AIRWING_START=true DISPATCH_READINESS=true MISSIONS=true spawn=true mutation=true")
