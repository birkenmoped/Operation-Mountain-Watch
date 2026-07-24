-- Operation Mountain Watch - Jalalabad AIRWING functional test manifest (Phase 1)
local TAG = "[OMW][AirOps.JBAD.PH1.MANIFEST]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
if not cfg then
  log("ERROR: Jalalabad configuration is unavailable.")
else
  local ph1 = cfg.Phase1 or {}
  cfg.Phase1 = ph1

  ph1.Version = "JBAD-PHASE1-2"
  ph1.Enabled = true
  ph1.State = ph1.State or "WAITING_FOR_BASELINE"
  ph1.Classification = ph1.Classification or "NOT_RUN"
  ph1.ActiveTestId = nil
  ph1.ActiveMission = nil
  ph1.ActiveDefinition = nil
  ph1.AutoSequence = false
  ph1.SequenceIndex = 0
  ph1.Results = ph1.Results or {}
  ph1.History = ph1.History or {}
  ph1.Spawners = ph1.Spawners or {}

  ph1.Sequence = { "OH58D_RECON", "AH64D_CAS", "UH60_TROOP", "CH47_CARGO", "UH60_ABORT" }

  ph1.Objects = {
    ReconZones = { "ZONE_TEST_US_JBAD_RECON_01", "ZONE_TEST_US_JBAD_RECON_02", "ZONE_TEST_US_JBAD_RECON_03" },
    CASZone = "ZONE_TEST_US_JBAD_CAS",
    CASTargetTemplate = "TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET",
    UHTroopTemplate = "TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS",
    UHLoadZone = "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
    UHUnloadZone = "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    CH47Cargo = "TEST_CARGO_BLUE_JBAD_CH47_01",
    CH47PickupZone = "ZONE_AIR_US_JBAD_SLING_PICKUP",
    CH47DropZone = "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD"
  }

  ph1.Tests = {
    OH58D_RECON = {
      Id = "OH58D_RECON", Label = "OH-58D Two-Ship RECON",
      SquadronKey = "OH58D", ParkingPoolKey = "OH58D", PayloadKey = "OH58DRecon",
      ExpectedType = "OH58D", ExpectedGroups = 1, ExpectedAircraft = 2,
      MissionType = "RECON", Timeout = 1800,
      RequireEngineStart = true, RequireTakeoff = true, RequireExecution = true,
      RequireRTB = true, RequireLanding = true, RequireObjective = true
    },
    AH64D_CAS = {
      Id = "AH64D_CAS", Label = "AH-64D Two-Ship CAS",
      SquadronKey = "AH64D", ParkingPoolKey = "AH64D", PayloadKey = "AH64DCAS",
      ExpectedType = "AH-64D_BLK_II", ExpectedGroups = 1, ExpectedAircraft = 2,
      MissionType = "CAS", Timeout = 2100,
      RequireEngineStart = true, RequireTakeoff = true, RequireExecution = true,
      RequireRTB = true, RequireLanding = true, RequireObjective = true
    },
    UH60_TROOP = {
      Id = "UH60_TROOP", Label = "UH-60A Single-Ship TROOPTRANSPORT",
      SquadronKey = "UH60", ParkingPoolKey = "UH60", PayloadKey = "UH60MedevacLead",
      ExpectedType = "UH-60A", ExpectedGroups = 1, ExpectedAircraft = 1,
      MissionType = "TROOPTRANSPORT", Timeout = 2100,
      RequireEngineStart = true, RequireTakeoff = true, RequireExecution = true,
      RequireRTB = true, RequireLanding = true, RequireObjective = true
    },
    CH47_CARGO = {
      Id = "CH47_CARGO", Label = "CH-47F Single-Ship CARGOTRANSPORT",
      SquadronKey = "CH47", ParkingPoolKey = "CH47", PayloadKey = "CH47HeavyLift",
      ExpectedType = "CH-47Fbl1", ExpectedGroups = 1, ExpectedAircraft = 1,
      MissionType = "CARGOTRANSPORT", Timeout = 2400,
      RequireEngineStart = true, RequireTakeoff = true, RequireExecution = true,
      RequireRTB = true, RequireLanding = true, RequireObjective = true,
      OneShotObject = true
    },
    UH60_ABORT = {
      Id = "UH60_ABORT", Label = "UH-60A Spawn/Reservation Abort",
      SquadronKey = "UH60", ParkingPoolKey = "UH60", PayloadKey = "UH60MedevacLead",
      ExpectedType = "UH-60A", ExpectedGroups = 1, ExpectedAircraft = 1,
      MissionType = "TROOPTRANSPORT", Timeout = 900, AbortOnBirth = true,
      RequireEngineStart = false, RequireTakeoff = false, RequireExecution = false,
      RequireRTB = false, RequireLanding = false, RequireObjective = false,
      ExpectedTerminalState = "CANCELLED"
    }
  }

  ph1.Limits = {
    PollInterval = 5,
    ReleaseStablePolls = 3,
    ClientParkingMatchMeters = 25,
    ParkingBirthMatchMeters = 30,
    StaticSpawnClearanceMeters = 12,
    JalalabadBirthRadiusMeters = 5000,
    MissionAreaDistanceMeters = 7000,
    RTBDetectionRadiusMeters = 5000,
    NextTestDelaySeconds = 20,
    AbortDelayAfterBirthSeconds = 5
  }

  ph1.ParkingBlacklist = {}
  for _, terminalId in ipairs((cfg.Parking and cfg.Parking.StaticParkingBlacklist) or {}) do
    ph1.ParkingBlacklist[terminalId] = true
  end

  log("READY version=" .. ph1.Version .. " tests=5 exclusiveParkingPools=true sequence=OH58D_RECON>AH64D_CAS>UH60_TROOP>CH47_CARGO>UH60_ABORT")
end
