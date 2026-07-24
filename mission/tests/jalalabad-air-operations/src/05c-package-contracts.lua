-- Operation Mountain Watch - Jalalabad package and squadron contracts
local TAG = "[OMW][AirOps.JBAD.PACKAGES]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
if not cfg then
  log("ERROR: Jalalabad configuration unavailable.")
else
  local contracts = {
    Version = "JBAD-PACKAGES-1",
    Squadrons = {
      OH58D = {
        TemplateKey = "OH58DRecon",
        TemplateUnits = 2,
        Grouping = 2,
        InventoryAircraft = 24,
        AssetGroups = 12,
        RuntimeUnitSuffixes = { "-01", "-02" },
        Model = "PHYSICAL_TWO_SHIP"
      },
      AH64D = {
        TemplateKey = "AH64DCAS",
        TemplateUnits = 2,
        Grouping = 2,
        InventoryAircraft = 8,
        AssetGroups = 4,
        RuntimeUnitSuffixes = { "-01", "-02" },
        Model = "PHYSICAL_TWO_SHIP"
      },
      UH60 = {
        TemplateKey = "UH60MedevacLead",
        CoverTemplateKey = "UH60MedevacCover",
        TemplateUnits = 1,
        Grouping = 1,
        InventoryAircraft = 8,
        AssetGroups = 8,
        RuntimeUnitSuffixes = { "-01" },
        Model = "INDEPENDENT_SINGLE_SHIP_ASSETS",
        PackageModel = "COORDINATED_LEAD_GUARD_WHEN_MEDEVAC"
      },
      CH47 = {
        TemplateKey = "CH47HeavyLift",
        TemplateUnits = 1,
        Grouping = 1,
        InventoryAircraft = 8,
        AssetGroups = 8,
        RuntimeUnitSuffixes = { "-01" },
        Model = "SINGLE_SHIP"
      }
    },
    Tests = {
      OH58D_RECON = { SquadronKey = "OH58D", RequiredGroups = 1, RequiredAircraft = 2, PackageModel = "PHYSICAL_TWO_SHIP" },
      AH64D_CAS = { SquadronKey = "AH64D", RequiredGroups = 1, RequiredAircraft = 2, PackageModel = "PHYSICAL_TWO_SHIP" },
      UH60_TROOP = { SquadronKey = "UH60", RequiredGroups = 1, RequiredAircraft = 1, PackageModel = "SINGLE_SHIP_TRANSPORT_TEST" },
      CH47_CARGO = { SquadronKey = "CH47", RequiredGroups = 1, RequiredAircraft = 1, PackageModel = "SINGLE_SHIP" },
      UH60_ABORT = { SquadronKey = "UH60", RequiredGroups = 1, RequiredAircraft = 1, PackageModel = "SINGLE_SHIP_ABORT_TEST" }
    }
  }

  cfg.PackageContracts = contracts

  function cfg:GetSquadronContract(key)
    return self.PackageContracts and self.PackageContracts.Squadrons and self.PackageContracts.Squadrons[key] or nil
  end

  function cfg:GetTestPackageContract(testId)
    return self.PackageContracts and self.PackageContracts.Tests and self.PackageContracts.Tests[testId] or nil
  end

  local valid = true
  for key, contract in pairs(contracts.Squadrons) do
    local configured = cfg.Inventory and cfg.Inventory[key] or nil
    if configured ~= contract.InventoryAircraft then
      valid = false
      log(string.format("ERROR inventory mismatch squadron=%s configured=%s contract=%d", key, tostring(configured), contract.InventoryAircraft))
    end
    if contract.AssetGroups * contract.Grouping ~= contract.InventoryAircraft then
      valid = false
      log(string.format("ERROR contract arithmetic squadron=%s assetGroups=%d grouping=%d inventory=%d", key, contract.AssetGroups, contract.Grouping, contract.InventoryAircraft))
    end
  end

  for testId, package in pairs(contracts.Tests) do
    local squadron = contracts.Squadrons[package.SquadronKey]
    if not squadron then
      valid = false
      log("ERROR test contract references unknown squadron testId=" .. testId)
    elseif package.RequiredGroups * squadron.Grouping ~= package.RequiredAircraft then
      valid = false
      log(string.format("ERROR package arithmetic testId=%s groups=%d grouping=%d aircraft=%d", testId, package.RequiredGroups, squadron.Grouping, package.RequiredAircraft))
    end
  end

  cfg.PackageContractsOK = valid
  if valid then
    log("PASS version=JBAD-PACKAGES-1 OH58D=1x2 AH64D=1x2 UH60=independentSingles CH47=1x1 assetGroups=12/4/8/8")
  else
    log("BLOCKED package-contract validation failed")
  end
end
