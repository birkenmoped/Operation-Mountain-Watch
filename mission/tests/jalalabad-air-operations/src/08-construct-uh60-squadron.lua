-- Operation Mountain Watch - Jalalabad UH-60 Utility/MEDEVAC squadron assembly
local TAG = "[OMW][AirOps.JBAD.UH60]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function getTemplateLivery(templateName)
  local entry = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[templateName] or nil
  local unit = entry and entry.Template and entry.Template.units and entry.Template.units[1] or nil
  return unit and (unit.livery_id or unit.livery) or nil
end

local function validateTemplate(templateName, role, expectedUnits)
  local template = templateName and GROUP:FindByName(templateName) or nil
  if not template then log("ERROR: " .. role .. " template missing: " .. tostring(templateName)) return nil end
  local units = template:GetUnits() or {}
  if #units ~= expectedUnits then log(string.format("ERROR: %s template %s units=%d contract=%d", role, templateName, #units, expectedUnits)) return nil end
  local typeName = units[1] and units[1]:GetTypeName() or "nil"
  local livery = getTemplateLivery(templateName)
  if typeName ~= "UH-60A" then log(string.format("ERROR: %s template %s type=%s expected=UH-60A", role, templateName, tostring(typeName))) return nil end
  if tostring(livery) ~= "standard" then log(string.format("ERROR: %s template %s livery=%s expected=standard", role, templateName, tostring(livery))) return nil end
  return template
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg or not cfg.Airwing then log("ERROR: Jalalabad configuration or AIRWING unavailable.") return end
  if cfg.ParkingPoolsOK ~= true or cfg.NameContractOK ~= true or cfg.PackageContractsOK ~= true then log("ERROR: Parking/name/package validation not passed; SQUADRON blocked.") return end
  if not GROUP or not SQUADRON or not AUFTRAG then log("ERROR: Required MOOSE classes unavailable.") return end

  local contract = cfg:GetSquadronContract("UH60")
  if not contract then log("ERROR: UH-60 package contract unavailable.") return end
  local leadName = cfg.Templates[contract.TemplateKey]
  local coverName = cfg.Templates[contract.CoverTemplateKey]
  local leadTemplate = validateTemplate(leadName, "MEDEVAC_LEAD", contract.TemplateUnits)
  local coverTemplate = validateTemplate(coverName, "MEDEVAC_GUARD", contract.TemplateUnits)
  if not leadTemplate or not coverTemplate then return end

  local aircraftCount = cfg.Inventory.UH60
  local squadronName = cfg.SquadronNames.UH60
  local parkingIDs = cfg:GetSquadronParkingIDs("UH60")
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.UH60 then log("SKIP: UH-60 squadron already constructed.") return end

  local missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT, AUFTRAG.Type.LANDATCOORDINATE, AUFTRAG.Type.GROUNDESCORT }
  local ok, result = pcall(function()
    local squadron = SQUADRON:New(leadName, aircraftCount, squadronName)
    squadron:SetGrouping(contract.Grouping)
    squadron:SetParkingIDs(parkingIDs)
    squadron:SetTakeoffCold()
    squadron:SetDespawnAfterLanding(true)
    if AI and AI.Skill and AI.Skill.HIGH then squadron:SetSkill(AI.Skill.HIGH) end
    squadron:AddMissionCapability(missionTypes, 100)
    cfg.Airwing:AddSquadron(squadron)
    local leadPayload = cfg.Airwing:NewPayload(leadTemplate, -1, { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT, AUFTRAG.Type.LANDATCOORDINATE }, 100)
    local coverPayload = cfg.Airwing:NewPayload(coverTemplate, -1, { AUFTRAG.Type.GROUNDESCORT }, 100)
    return { Squadron = squadron, LeadPayload = leadPayload, CoverPayload = coverPayload }
  end)
  if not ok or not result or not result.Squadron then log("ERROR: UH-60 SQUADRON construction failed: " .. tostring(result)) return end
  if cfg.Airwing:GetSquadron(squadronName) ~= result.Squadron then log("ERROR: AIRWING link validation failed.") return end

  cfg.Squadrons.UH60 = result.Squadron
  cfg.Payloads = cfg.Payloads or {}
  cfg.Payloads.UH60MedevacLead = result.LeadPayload
  cfg.Payloads.UH60MedevacCover = result.CoverPayload
  log(string.format("SQUADRON ready name=%s model=%s medevacPackage=%s aircraft=%d assetGroups=%d grouping=%d parkingIDs=%s despawnAfterLanding=true", squadronName, contract.Model, contract.PackageModel, aircraftCount, contract.AssetGroups, contract.Grouping, table.concat(parkingIDs, ",")))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 13) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 13) end
