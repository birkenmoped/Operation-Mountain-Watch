-- Operation Mountain Watch - Jalalabad AIRWING functional test manifest (Phase 1)
local TAG = "[OMW][AirOps.JBAD.PH1.MANIFEST]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
if not cfg then
  log("ERROR: Jalalabad configuration unavailable.")
elseif cfg.PackageContractsOK ~= true then
  log("ERROR: Package contracts unavailable or invalid.")
else
  local ph1 = cfg.Phase1 or {}
  cfg.Phase1 = ph1

  ph1.Version = "JBAD-PHASE1-7"
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
    UHUnloadZone = "ZONE_TEST_US_JBAD_UH60_DROPOFF",
    CH47Cargo = "TEST_CARGO_BLUE_JBAD_CH47_01",
    CH47PickupZone = "ZONE_AIR_US_JBAD_SLING_PICKUP",
    CH47DropZone = "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD"
  }

  local labels = {
    OH58D_RECON = "OH-58D physical Two-Ship RECON",
    AH64D_CAS = "AH-64D physical Two-Ship CAS",
    UH60_TROOP = "UH-60A Single-Ship TROOPTRANSPORT",
    CH47_CARGO = "CH-47F Single-Ship CARGOTRANSPORT",
    UH60_ABORT = "UH-60A Single-Ship Spawn/Reservation Abort"
  }
  local payloads = {
    OH58D_RECON = "OH58DRecon",
    AH64D_CAS = "AH64DCAS",
    UH60_TROOP = "UH60MedevacLead",
    CH47_CARGO = "CH47HeavyLift",
    UH60_ABORT = "UH60MedevacLead"
  }
  local types = {
    OH58D_RECON = "OH58D",
    AH64D_CAS = "AH-64D_BLK_II",
    UH60_TROOP = "UH-60A",
    CH47_CARGO = "CH-47Fbl1",
    UH60_ABORT = "UH-60A"
  }
  local missionTypes = {
    OH58D_RECON = "RECON",
    AH64D_CAS = "CAS",
    UH60_TROOP = "TROOPTRANSPORT",
    CH47_CARGO = "CARGOTRANSPORT",
    UH60_ABORT = "TROOPTRANSPORT"
  }

  local function definition(testId)
    local package = cfg:GetTestPackageContract(testId)
    local squadron = package and cfg:GetSquadronContract(package.SquadronKey) or nil
    if not package or not squadron then return nil end
    return {
      Id = testId,
      Label = labels[testId],
      SquadronKey = package.SquadronKey,
      ParkingPoolKey = package.SquadronKey,
      PayloadKey = payloads[testId],
      ExpectedType = types[testId],
      ExpectedGroups = package.RequiredGroups,
      ExpectedAircraft = package.RequiredAircraft,
      ExpectedGroupPrefix = cfg:GetRuntimeGroupPrefix(package.SquadronKey),
      ExpectedUnitSuffix = squadron.RuntimeUnitSuffixes[1],
      ExpectedUnitSuffixes = squadron.RuntimeUnitSuffixes,
      PackageModel = package.PackageModel,
      SquadronModel = squadron.Model,
      MissionType = missionTypes[testId],
      SpawnTimeout = 600,
      ExecutionTimeout = 5400,
      RecoveryTimeout = 2400,
      ReleaseTimeout = 300,
      RequireEngineStart = true,
      RequireTakeoff = true,
      RequireExecution = true,
      RequireRTB = true,
      RequireLanding = true,
      RequireObjective = true
    }
  end

  ph1.Tests = {
    OH58D_RECON = definition("OH58D_RECON"),
    AH64D_CAS = definition("AH64D_CAS"),
    UH60_TROOP = definition("UH60_TROOP"),
    CH47_CARGO = definition("CH47_CARGO"),
    UH60_ABORT = definition("UH60_ABORT")
  }

  for _, testId in ipairs(ph1.Sequence) do
    if not ph1.Tests[testId] then
      ph1.Enabled = false
      log("ERROR: Test definition failed: " .. tostring(testId))
    end
  end

  ph1.Tests.UH60_TROOP.AllowObjectiveDrivenTerminal = true
  ph1.Tests.CH47_CARGO.OneShotObject = true
  ph1.Tests.CH47_CARGO.AllowObjectiveDrivenTerminal = true
  ph1.Tests.UH60_ABORT.AbortOnBirth = true
  ph1.Tests.UH60_ABORT.AllowObjectiveDrivenTerminal = false
  ph1.Tests.UH60_ABORT.RequireEngineStart = false
  ph1.Tests.UH60_ABORT.RequireTakeoff = false
  ph1.Tests.UH60_ABORT.RequireExecution = false
  ph1.Tests.UH60_ABORT.RequireRTB = false
  ph1.Tests.UH60_ABORT.RequireLanding = false
  ph1.Tests.UH60_ABORT.RequireObjective = false
  ph1.Tests.UH60_ABORT.ExpectedTerminalState = "CANCELLED"
  ph1.Tests.UH60_ABORT.ExecutionTimeout = 900
  ph1.Tests.UH60_ABORT.RecoveryTimeout = 600

  ph1.AssetGroupInventory = {}
  for key, contract in pairs(cfg.PackageContracts.Squadrons) do
    ph1.AssetGroupInventory[key] = contract.AssetGroups
  end

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
  for _, terminalId in ipairs((cfg.Parking and cfg.Parking.StaticParkingBlacklist) or {}) do ph1.ParkingBlacklist[terminalId] = true end

  log("READY version=JBAD-PHASE1-7 contracts=OH58D:1x2/AH64D:1x2/UH60:1x1/CH47:1x1 assetGroups=12/4/8/8 exactRuntimeNames=true")
end
