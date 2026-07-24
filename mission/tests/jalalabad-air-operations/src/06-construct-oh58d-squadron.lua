-- Operation Mountain Watch - Jalalabad OH-58D squadron assembly
local TAG = "[OMW][AirOps.JBAD.OH58D]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg or not cfg.Airwing then log("ERROR: Jalalabad configuration or AIRWING unavailable.") return end
  if cfg.ParkingPoolsOK ~= true or cfg.NameContractOK ~= true then log("ERROR: Parking/name validation not passed; SQUADRON blocked.") return end
  if not GROUP or not SQUADRON or not AUFTRAG then log("ERROR: Required MOOSE classes unavailable.") return end

  local templateName = cfg.Templates.OH58DRecon
  local template = GROUP:FindByName(templateName)
  if not template then log("ERROR: OH-58D template missing: " .. tostring(templateName)) return end
  local units = template:GetUnits() or {}
  if #units ~= 2 then log(string.format("ERROR: Template %s must contain exactly 2 authoring units; found=%d", templateName, #units)) return end
  for index, unit in ipairs(units) do
    local typeName = unit and unit:GetTypeName() or "nil"
    if typeName ~= "OH58D" then log(string.format("ERROR: Template %s unit %d type=%s expected=OH58D", templateName, index, tostring(typeName))) return end
  end

  local aircraftCount = cfg.Inventory.OH58D
  local squadronName = cfg.SquadronNames.OH58D
  local parkingIDs = cfg:GetSquadronParkingIDs("OH58D")
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.OH58D then log("SKIP: OH-58D squadron already constructed.") return end

  local ok, result = pcall(function()
    local squadron = SQUADRON:New(templateName, aircraftCount, squadronName)
    squadron:SetGrouping(1)
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
  log("SQUADRON ready name=" .. squadronName .. " physicalGroups=24 groupSize=1 logicalTwoShip=2assets runtimePrefix=" .. cfg:GetRuntimeGroupPrefix("OH58D") .. " parkingIDs=" .. table.concat(parkingIDs, ",") .. " despawnAfterLanding=true")
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 9) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 9) end
