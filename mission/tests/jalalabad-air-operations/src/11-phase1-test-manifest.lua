-- Operation Mountain Watch - Jalalabad MOOSE-first Phase-1 test manifest
local TAG = "[OMW][AirOps.JBAD.PH1.MANIFEST]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
if not cfg or not cfg.PackageContractsOK then
  log("ERROR: Package contracts unavailable or invalid.")
elseif cfg.NameContractInitialized ~= true or cfg.NameContractOK ~= true then
  log(string.format("ERROR: Runtime name contract unavailable or invalid initialized=%s valid=%s", tostring(cfg.NameContractInitialized), tostring(cfg.NameContractOK)))
else
  local ph1 = cfg.Phase1 or {}
  cfg.Phase1 = ph1
  ph1.Version = "JBAD-PHASE1-12"
  ph1.State = ph1.State or "WAITING_FOR_BASELINE"
  ph1.Classification = ph1.Classification or "NOT_RUN"
  ph1.Results = ph1.Results or {}
  ph1.History = ph1.History or {}
  ph1.Sequence = { "OH58D_RECON", "AH64D_CAS", "UH60_TROOP", "CH47_CARGO", "UH60_ABORT" }

  -- Canonical Mission Editor object contract of
  -- OMW_Jalalabad_AirOps_Phase1_Test.miz. These names predate the MOOSE-first
  -- refactor and must not be replaced by invented TZ_/TG_/ST_ aliases unless
  -- the mission itself is explicitly migrated in the Mission Editor.
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

  local function testDefinition(id, label, values)
    local package = cfg:GetTestPackageContract(id)
    local squadron = package and cfg:GetSquadronContract(package.SquadronKey) or nil
    if not package or not squadron then
      log("ERROR: Missing package/squadron contract for " .. tostring(id))
      return nil
    end
    values = values or {}
    values.Id = id
    values.Label = label
    values.SquadronKey = package.SquadronKey
    values.PackageModel = package.PackageModel
    values.OperationKind = package.OperationKind
    values.LogisticsProfile = package.LogisticsProfile
    values.ExpectedGroups = package.RequiredGroups
    values.ExpectedAircraft = package.RequiredAircraft
    values.ExpectedUnitSuffixes = squadron.RuntimeUnitSuffixes
    values.ExpectedGroupPrefix = cfg.RuntimeGroupPrefixes and cfg.RuntimeGroupPrefixes[package.SquadronKey] or nil
    values.ExpectedType = values.ExpectedType or (cfg.DetectedTypes and cfg.DetectedTypes[package.SquadronKey])
    values.Timeout = values.Timeout or 1800
    values.RequireTakeoff = values.RequireTakeoff ~= false
    values.RequireLanding = values.RequireLanding ~= false
    values.RequireRTB = values.RequireRTB ~= false
    return values
  end

  ph1.Tests = {
    OH58D_RECON = testDefinition("OH58D_RECON", "OH-58D RECON physical two-ship", {
      PayloadKey = "OH58DRecon", MissionRangeNM = 50, Timeout = 3600,
      NativeTerminal = "SUCCESS", RequireObjective = true,
      ObjectiveKind = "RECON_NATIVE_SUCCESS"
    }),
    AH64D_CAS = testDefinition("AH64D_CAS", "AH-64D CAS physical two-ship", {
      PayloadKey = "AH64DCAS", Timeout = 2400,
      NativeTerminal = "SUCCESS", RequireObjective = true,
      ObjectiveKind = "TARGET_GROUP_DESTROYED"
    }),
    UH60_TROOP = testDefinition("UH60_TROOP", "UH-60 native OPS transport", {
      PayloadKey = "UH60MedevacLead", Timeout = 3000,
      NativeTerminal = "DELIVERED", RequireObjective = true,
      ObjectiveKind = "OPSTRANSPORT_GROUP_DELIVERED"
    }),
    CH47_CARGO = testDefinition("CH47_CARGO", "CH-47 native sling cargo AUFTRAG", {
      PayloadKey = "CH47HeavyLift", Timeout = 3000,
      NativeTerminal = "SUCCESS", RequireObjective = true,
      ObjectiveKind = "STATIC_CARGO_IN_DROP_ZONE"
    }),
    UH60_ABORT = testDefinition("UH60_ABORT", "UH-60 reservation and cancellation", {
      PayloadKey = "UH60MedevacLead", Timeout = 900,
      NativeTerminal = "CANCELLED", RequireTakeoff = false,
      RequireLanding = false, RequireRTB = false, RequireObjective = false,
      AbortOnBind = true, ObjectiveKind = "ABORT_RELEASE_ONLY"
    })
  }

  ph1.AssetGroupInventory = {}
  for key, contract in pairs(cfg.PackageContracts.Squadrons) do
    ph1.AssetGroupInventory[key] = contract.AssetGroups
  end

  ph1.Limits = {
    PollIntervalSeconds = 5,
    ReleaseStablePolls = 3,
    AbortDelayAfterBindSeconds = 4,
    ClientParkingMatchMeters = 35,
    ParkingBirthMatchMeters = 45,
    StaticSpawnClearanceMeters = 20,
    TerrainSampleSpacingMeters = 750,
    ReconClearanceAGLMeters = 350,
    FuelTelemetryIntervalSeconds = 60,
    NextTestDelaySeconds = 20
  }

  local valid = true
  for testId, definition in pairs(ph1.Tests) do
    if not definition then valid = false else
      local squadron = cfg:GetSquadronContract(definition.SquadronKey)
      if not definition.ExpectedGroupPrefix then
        valid = false
        log("ERROR: Runtime group prefix missing testId=" .. testId)
      end
      if definition.ExpectedGroups * squadron.Grouping ~= definition.ExpectedAircraft then
        valid = false
        log("ERROR: Package arithmetic mismatch testId=" .. testId)
      end
      if definition.LogisticsProfile and not cfg:GetLogisticsProfile(definition.LogisticsProfile) then
        valid = false
        log("ERROR: Logistics profile missing testId=" .. testId)
      end
    end
  end
  ph1.ManifestOK = valid
  if valid then
    log("READY version=JBAD-PHASE1-12 operativeAuthorities=AUFTRAG/OPSTRANSPORT testHarness=acceptance-only sequence=5 nameContract=SYNCHRONOUS missionEditorObjectContract=CANONICAL")
  else
    log("BLOCKED manifest validation failed")
  end
end
