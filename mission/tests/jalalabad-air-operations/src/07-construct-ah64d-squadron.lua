-- Operation Mountain Watch - Jalalabad AH-64D squadron assembly
local TAG = "[OMW][AirOps.JBAD.AH64D]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg or not cfg.Airwing then log("ERROR: Jalalabad configuration or AIRWING unavailable.") return end
  if cfg.ParkingPoolsOK ~= true or cfg.NameContractOK ~= true or cfg.PackageContractsOK ~= true then log("ERROR: Parking/name/package validation not passed; SQUADRON blocked.") return end
  if not GROUP or not SQUADRON or not AUFTRAG then log("ERROR: Required MOOSE classes unavailable.") return end

  local contract = cfg:GetSquadronContract("AH64D")
  if not contract then log("ERROR: AH-64D package contract unavailable.") return end
  local templateName = cfg.Templates[contract.TemplateKey]
  local template = GROUP:FindByName(templateName)
  if not template then log("ERROR: AH-64D template missing: " .. tostring(templateName)) return end
  local units = template:GetUnits() or {}
  if #units ~= contract.TemplateUnits then log(string.format("ERROR: Template %s units=%d contract=%d", templateName, #units, contract.TemplateUnits)) return end
  for index, unit in ipairs(units) do
    local typeName = unit and unit:GetTypeName() or "nil"
    if typeName ~= "AH-64D_BLK_II" then log(string.format("ERROR: Template %s unit %d type=%s expected=AH-64D_BLK_II", templateName, index, tostring(typeName))) return end
  end

  local aircraftCount = cfg.Inventory.AH64D
  local squadronName = cfg.SquadronNames.AH64D
  local parkingIDs = cfg:GetSquadronParkingIDs("AH64D")
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.AH64D then log("SKIP: AH-64D squadron already constructed.") return end

  local ok, result = pcall(function()
    local squadron = SQUADRON:New(templateName, aircraftCount, squadronName)
    squadron:SetGrouping(contract.Grouping)
    squadron:SetParkingIDs(parkingIDs)
    squadron:SetTakeoffCold()
    squadron:SetDespawnAfterLanding(true)
    if AI and AI.Skill and AI.Skill.HIGH then squadron:SetSkill(AI.Skill.HIGH) end
    squadron:AddMissionCapability({ AUFTRAG.Type.CAS }, 100)
    cfg.Airwing:AddSquadron(squadron)
    local payload = cfg.Airwing:NewPayload(template, -1, { AUFTRAG.Type.CAS }, 100)
    return { Squadron = squadron, Payload = payload }
  end)
  if not ok or not result or not result.Squadron then log("ERROR: AH-64D SQUADRON construction failed: " .. tostring(result)) return end
  if cfg.Airwing:GetSquadron(squadronName) ~= result.Squadron then log("ERROR: AIRWING link validation failed.") return end

  cfg.Squadrons.AH64D = result.Squadron
  cfg.Payloads = cfg.Payloads or {}
  cfg.Payloads.AH64DCAS = result.Payload
  log(string.format("SQUADRON ready name=%s model=%s aircraft=%d assetGroups=%d grouping=%d runtimeUnits=%s parkingIDs=%s despawnAfterLanding=true", squadronName, contract.Model, aircraftCount, contract.AssetGroups, contract.Grouping, table.concat(contract.RuntimeUnitSuffixes, ","), table.concat(parkingIDs, ",")))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 11) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 11) end
