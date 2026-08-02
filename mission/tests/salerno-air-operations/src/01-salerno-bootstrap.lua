-- Operation Mountain Watch - FOB Salerno staged diagnostics
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][SALERNO][DIAG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

OMW.AirOps.SalernoDiagnostics = {
  Version = "SAL-COMMANDER-ISOLATED-17",
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.FOB_Salerno or "FOB Salerno",
  ControlAirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Khost or "Khost",
  ExpectedAirbaseID = 23,
  WarehouseName = "WH_AIR_US_SALERNO",

  ParkingStatus = {
    State = "DEFERRED",
    Reason = "Multi-unit AIRWING spawns did not reliably honor configured asset parkingIDs or client exclusions.",
    CalibrationRetained = true,
    OperationalMutationEnabled = false
  },

  ReservedMissionEditorParkingLabels = {
    [24] = "STATIC_OH58_PAIR",
    [25] = "STATIC_OH58_PAIR",
    [35] = "MAIN_APRON_ACCESS_AND_ROLE2_CSAR_UNLOAD"
  },

  ParkingGeometry = {
    LEFT_HEAVY = { XMin = -46230, XMax = -46100, ZMin = 347620, ZMax = 347850 },
    RIGHT_ROTARY = { XMin = -46250, XMax = -45920, ZMin = 347780, ZMax = 348090 },
    StaticPrefix = "STATIC_AIR_US_SAL_",
    DefaultStaticClearanceRadius = 20,
    StaticClearanceRadius = {
      ["OH58D"] = 14,
      ["AH-64D_BLK_II"] = 18,
      ["UH-60A"] = 18,
      ["CH-47Fbl1"] = 30
    },
    CSARUnloadZone = "ZONE_AIR_US_SAL_CSAR_UNLOAD"
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
    { Name="SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK", Template="TPL_AIR_US_SAL_AH64D_CAS_2SHIP", LogicalAircraft=8, UnitsPerTemplate=2, Ngroups=4, ResidualAircraft=0, ParkingSector="DEFERRED_RIGHT_APACHE" },
    { Name="SQ_US_SAL_OH58D_B_6_6_CAV", Template="TPL_AIR_US_SAL_OH58D_RECON_2SHIP", LogicalAircraft=8, UnitsPerTemplate=2, Ngroups=4, ResidualAircraft=0, ParkingSector="DEFERRED_RIGHT_KIOWA" },
    { Name="SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT", Template="TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP", LogicalAircraft=7, UnitsPerTemplate=2, Ngroups=3, ResidualAircraft=1, ParkingSector="DEFERRED_RIGHT_BLACKHAWK" },
    { Name="SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN", Template="TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP", LogicalAircraft=3, UnitsPerTemplate=1, Ngroups=3, ResidualAircraft=0, ParkingSector="DEFERRED_RIGHT_BLACKHAWK" },
    { Name="SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT", Template="TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP", LogicalAircraft=6, UnitsPerTemplate=1, Ngroups=6, ResidualAircraft=0, ParkingSector="DEFERRED_LEFT_HEAVY" }
  },
  Zones = { "ZONE_AIR_US_SAL_CSAR_UNLOAD" },
  Expected = { ClientGroups=6, TemplateGroups=5, TemplateUnits=8, AircraftStatics=15, Warehouses=1, Zones=1, Squadrons=5 }
}

log("BOOT Version=" .. OMW.AirOps.SalernoDiagnostics.Version)
log("PARKING state=DEFERRED calibrationRetained=true operationalMutation=false")
log("STAGED_TEST=true AIRWING_CONSTRUCT=true PARKING_CONTROL=false SQUADRON_CONSTRUCT=true SQUADRON_REGISTRATION=true SQUADRON_CONFIG=true MISSION_CAPABILITIES=true PAYLOADS=true AIRWING_START=true DIRECT_DISPATCH_BASELINE=false COMMANDER_CONSTRUCT=true COMMANDER_ADD_AIRWING=true COMMANDER_DISPATCH=true COMMANDER_ISOLATED=true spawn=true mutation=true")
