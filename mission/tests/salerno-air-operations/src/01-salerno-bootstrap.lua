-- Operation Mountain Watch - FOB Salerno read-only diagnostics
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][SALERNO][DIAG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

OMW.AirOps.SalernoDiagnostics = {
  Version = "SAL-READONLY-1",
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
  Zones = { "ZONE_AIR_US_SAL_CSAR_UNLOAD" },
  Expected = { ClientGroups = 6, TemplateGroups = 5, TemplateUnits = 8, AircraftStatics = 15, Warehouses = 1, Zones = 1 }
}

log("BOOT Version=" .. OMW.AirOps.SalernoDiagnostics.Version)
log("READ_ONLY=true no AIRWING no SQUADRON no spawn no mutation")
