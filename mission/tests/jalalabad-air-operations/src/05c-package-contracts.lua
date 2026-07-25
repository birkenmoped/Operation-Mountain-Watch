-- Operation Mountain Watch - canonical Jalalabad package and operation contracts
local TAG = "[OMW][AirOps.JBAD.PACKAGES]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
if not cfg then
  log("ERROR: Jalalabad configuration unavailable.")
else
  local contracts = {
    Version = "JBAD-PACKAGES-3",
    Squadrons = {
      OH58D = {
        TemplateKey = "OH58DRecon", TemplateUnits = 2, Grouping = 2,
        InventoryAircraft = 24, AssetGroups = 12,
        RuntimeUnitSuffixes = { "-01", "-02" }, Model = "PHYSICAL_TWO_SHIP"
      },
      AH64D = {
        TemplateKey = "AH64DCAS", TemplateUnits = 2, Grouping = 2,
        InventoryAircraft = 8, AssetGroups = 4,
        RuntimeUnitSuffixes = { "-01", "-02" }, Model = "PHYSICAL_TWO_SHIP"
      },
      UH60 = {
        TemplateKey = "UH60MedevacLead", CoverTemplateKey = "UH60MedevacCover",
        TemplateUnits = 1, Grouping = 1, InventoryAircraft = 8, AssetGroups = 8,
        RuntimeUnitSuffixes = { "-01" }, Model = "INDEPENDENT_SINGLE_SHIP_ASSETS",
        PackageModel = "COORDINATED_LEAD_GUARD_WHEN_MEDEVAC"
      },
      CH47 = {
        TemplateKey = "CH47HeavyLift", TemplateUnits = 1, Grouping = 1,
        InventoryAircraft = 8, AssetGroups = 8,
        RuntimeUnitSuffixes = { "-01" }, Model = "SINGLE_SHIP"
      }
    },
    Tests = {
      OH58D_RECON = {
        SquadronKey = "OH58D", RequiredGroups = 1, RequiredAircraft = 2,
        PackageModel = "PHYSICAL_TWO_SHIP", OperationKind = "AUFTRAG"
      },
      AH64D_CAS = {
        SquadronKey = "AH64D", RequiredGroups = 1, RequiredAircraft = 2,
        PackageModel = "PHYSICAL_TWO_SHIP", OperationKind = "AUFTRAG"
      },
      UH60_TROOP = {
        SquadronKey = "UH60", RequiredGroups = 1, RequiredAircraft = 1,
        PackageModel = "SINGLE_SHIP_TRANSPORT_TEST", OperationKind = "OPSTRANSPORT",
        LogisticsProfile = "GROUP_CARGO"
      },
      CH47_CARGO = {
        SquadronKey = "CH47", RequiredGroups = 1, RequiredAircraft = 1,
        PackageModel = "SINGLE_SHIP", OperationKind = "AUFTRAG",
        LogisticsProfile = "STATIC_SLING_CARGO"
      },
      UH60_ABORT = {
        SquadronKey = "UH60", RequiredGroups = 1, RequiredAircraft = 1,
        PackageModel = "SINGLE_SHIP_ABORT_TEST", OperationKind = "AUFTRAG"
      }
    },
    LogisticsProfiles = {
      GROUP_CARGO = {
        NativeAuthority = "OPSTRANSPORT",
        NativeEvents = { "Loaded", "Unloaded", "Delivered" },
        Supports = { "troops", "vehicles", "ops-groups" }
      },
      STORAGE_CARGO = {
        NativeAuthority = "OPSTRANSPORT",
        NativeEvents = { "Loaded", "Unloaded", "Delivered" },
        Supports = { "fuel", "weapons", "equipment", "warehouse-storage" }
      },
      STATIC_SLING_CARGO = {
        NativeAuthority = "AUFTRAG_CARGOTRANSPORT",
        NativeEvents = { "Queued", "Requested", "Scheduled", "Executing", "Success", "Failed", "Cancel" },
        Supports = { "static-slingload" }
      },
      STATIC_FREIGHT_CARGO = {
        NativeAuthority = "AUFTRAG_FREIGHTTRANSPORT",
        NativeEvents = { "Queued", "Requested", "Scheduled", "Executing", "Success", "Failed", "Cancel" },
        Supports = { "internal-static-freight" }
      },
      DYNAMIC_CARGO = {
        NativeAuthority = "MOOSE_EVENT_DISPATCHER",
        NativeEvents = { "DynamicCargoLoaded", "DynamicCargoUnloaded", "DynamicCargoRemoved" },
        Supports = { "dcs-dynamic-cargo" }
      }
    }
  }

  cfg.PackageContracts = contracts
  function cfg:GetSquadronContract(key)
    return self.PackageContracts and self.PackageContracts.Squadrons and self.PackageContracts.Squadrons[key] or nil
  end
  function cfg:GetTestPackageContract(testId)
    return self.PackageContracts and self.PackageContracts.Tests and self.PackageContracts.Tests[testId] or nil
  end
  function cfg:GetLogisticsProfile(key)
    return self.PackageContracts and self.PackageContracts.LogisticsProfiles and self.PackageContracts.LogisticsProfiles[key] or nil
  end

  local valid = true
  for key, contract in pairs(contracts.Squadrons) do
    local configured = cfg.Inventory and cfg.Inventory[key] or nil
    if configured ~= contract.InventoryAircraft then
      valid = false
      log(string.format("ERROR inventory mismatch squadron=%s configured=%s contract=%d", key, tostring(configured), contract.InventoryAircraft))
    end
    if type(contract.AssetGroups) ~= "number" or contract.AssetGroups < 1 or contract.AssetGroups % 1 ~= 0 then
      valid = false
      log(string.format("ERROR invalid asset-group count squadron=%s assetGroups=%s", key, tostring(contract.AssetGroups)))
    end
    if contract.AssetGroups * contract.Grouping ~= contract.InventoryAircraft then
      valid = false
      log(string.format("ERROR contract arithmetic squadron=%s groups=%d grouping=%d aircraft=%d", key, contract.AssetGroups, contract.Grouping, contract.InventoryAircraft))
    end
    local pool = cfg.Parking and cfg.Parking.SquadronPools and cfg.Parking.SquadronPools[key] or nil
    if not pool then
      valid = false
      log("ERROR parking pool missing squadron=" .. tostring(key))
    else
      pool.GroupSize = contract.Grouping
    end
  end

  for testId, package in pairs(contracts.Tests) do
    local squadron = contracts.Squadrons[package.SquadronKey]
    if not squadron then
      valid = false
      log("ERROR test references unknown squadron testId=" .. testId)
    elseif package.RequiredGroups * squadron.Grouping ~= package.RequiredAircraft then
      valid = false
      log(string.format("ERROR package arithmetic testId=%s groups=%d grouping=%d aircraft=%d", testId, package.RequiredGroups, squadron.Grouping, package.RequiredAircraft))
    end
    if package.LogisticsProfile and not contracts.LogisticsProfiles[package.LogisticsProfile] then
      valid = false
      log("ERROR unknown logistics profile testId=" .. testId .. " profile=" .. tostring(package.LogisticsProfile))
    end
  end

  if cfg.Parking then
    cfg.Parking.Model = "CONTRACT_DRIVEN_PHYSICAL_GROUPS_OH58D2_AH64D2_UH60_1_CH47_1"
  end
  cfg.PackageContractsOK = valid
  if valid then
    log("PASS version=JBAD-PACKAGES-3 MOOSEAuthorities=AUFTRAG/OPSTRANSPORT/FLIGHTGROUP publicAssetCounts=true logisticsProfiles=GROUP/STORAGE/SLING/FREIGHT/DYNAMIC")
  else
    log("BLOCKED package-contract validation failed")
  end
end
