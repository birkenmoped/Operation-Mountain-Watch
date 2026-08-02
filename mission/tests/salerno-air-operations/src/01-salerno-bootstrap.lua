-- Operation Mountain Watch - FOB Salerno staged diagnostics
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][SALERNO][DIAG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

OMW.AirOps.SalernoDiagnostics = {
  Version = "SAL-OPERATIONAL-BASELINE-6",
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.FOB_Salerno or "FOB Salerno",
  ControlAirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Khost or "Khost",
  ExpectedAirbaseID = 23,
  WarehouseName = "WH_AIR_US_SALERNO",
  ClientParkingBlacklist = { 13, 21, 22, 23, 36, 40 },
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
    {
      Name = "SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK",
      Template = "TPL_AIR_US_SAL_AH64D_CAS_2SHIP",
      LogicalAircraft = 8,
      UnitsPerTemplate = 2,
      Ngroups = 4,
      ResidualAircraft = 0
    },
    {
      Name = "SQ_US_SAL_OH58D_B_6_6_CAV",
      Template = "TPL_AIR_US_SAL_OH58D_RECON_2SHIP",
      LogicalAircraft = 8,
      UnitsPerTemplate = 2,
      Ngroups = 4,
      ResidualAircraft = 0
    },
    {
      Name = "SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT",
      Template = "TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP",
      LogicalAircraft = 7,
      UnitsPerTemplate = 2,
      Ngroups = 3,
      ResidualAircraft = 1
    },
    {
      Name = "SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN",
      Template = "TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP",
      LogicalAircraft = 3,
      UnitsPerTemplate = 1,
      Ngroups = 3,
      ResidualAircraft = 0
    },
    {
      Name = "SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT",
      Template = "TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP",
      LogicalAircraft = 6,
      UnitsPerTemplate = 1,
      Ngroups = 6,
      ResidualAircraft = 0
    }
  },
  Zones = { "ZONE_AIR_US_SAL_CSAR_UNLOAD" },
  Expected = { ClientGroups = 6, TemplateGroups = 5, TemplateUnits = 8, AircraftStatics = 15, Warehouses = 1, Zones = 1, Squadrons = 5 }
}

log("BOOT Version=" .. OMW.AirOps.SalernoDiagnostics.Version)
log("STAGED_TEST=true AIRWING_CONSTRUCT=true SQUADRON_CONSTRUCT=true SQUADRON_REGISTRATION=true SQUADRON_CONFIG=true MISSION_CAPABILITIES=true PAYLOADS=true AIRWING_START=true MISSIONS=false spawn=false mutation=true")
