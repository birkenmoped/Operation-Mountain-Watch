-- Operation Mountain Watch - Jalalabad OH-58D squadron assembly
local TAG = "[OMW][AirOps.JBAD.OH58D]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg or not cfg.Airwing then log("ERROR: Jalalabad configuration or AIRWING unavailable.") return end
  if cfg.ParkingPoolsOK ~= true or cfg.NameContractOK ~= true or cfg.PackageContractsOK ~= true then log("ERROR: Parking/name/package validation not passed; SQUADRON blocked.") return end
  if not GROUP or not SQUADRON or not AUFTRAG then log("ERROR: Required MOOSE classes unavailable.") return end

  local contract = cfg:GetSquadronContract("OH58D")
  if not contract then log("ERROR: OH-58D package contract unavailable.") return end
  local templateName = cfg.Templates[contract.TemplateKey]
  local template = GROUP:FindByName(templateName)
  if not template then log("ERROR: OH-58D template missing: " .. tostring(templateName)) return end
  local units = template:GetUnits() or {}
  if #units ~= contract.TemplateUnits then log(string.format("ERROR: Template %s units=%d contract=%d", templateName, #units, contract.TemplateUnits)) return end
  for index, unit in ipairs(units) do
    local typeName = unit and unit:GetTypeName() or "nil"
    if typeName ~= "OH58D" then log(string.format("ERROR: Template %s unit %d type=%s expected=OH58D", templateName, index, tostring(typeName))) return end
  end

  local aircraftCount = contract.InventoryAircraft
  local assetGroupCount = contract.AssetGroups
  local squadronName = cfg.SquadronNames.OH58D
  local parkingIDs = cfg:GetSquadronParkingIDs("OH58D")
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.OH58D then log("SKIP: OH-58D squadron already constructed.") return end

  local ok, result = pcall(function()
    -- SQUADRON:New() expects the number of MOOSE asset groups, not aircraft.
    -- Each asset group contains contract.Grouping aircraft from the ME template.
    local squadron = SQUADRON:New(templateName, assetGroupCount, squadronName)
    squadron:SetGrouping(contract.Grouping)
    squadron:SetParkingIDs(parkingIDs)
    squadron:SetTakeoffCold()
    squadron:SetDespawnAfterLanding(true)
    if AI and AI.Skill and AI.Skill.HIGH then squadron:SetSkill(AI.Skill.HIGH) end
    squadron:AddMissionCapability({ AUFTRAG.Type.RECON }, 100)
    cfg.Airwing:AddSquadron(squadron)
    local payload = cfg.Airwing:NewPayload(template, -1, { AUFTRAG.Type.RECON }, 100)
    return { Squadron = squadron, Payload = payload }
  end)
  if not ok or not result or not result.Squadron then log("ERROR: OH-58D SQUADRON construction failed: " .. tostring(result)) return end
  if cfg.Airwing:GetSquadron(squadronName) ~= result.Squadron then log("ERROR: AIRWING link validation failed.") return end

  cfg.Squadrons.OH58D = result.Squadron
  cfg.Payloads = cfg.Payloads or {}
  cfg.Payloads.OH58DRecon = result.Payload
  log(string.format("SQUADRON ready name=%s model=%s inventoryAircraft=%d constructorAssetGroups=%d grouping=%d computedAircraft=%d runtimeUnits=%s parkingIDs=%s despawnAfterLanding=true", squadronName, contract.Model, aircraftCount, assetGroupCount, contract.Grouping, assetGroupCount * contract.Grouping, table.concat(contract.RuntimeUnitSuffixes, ","), table.concat(parkingIDs, ",")))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 9) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 9) end
