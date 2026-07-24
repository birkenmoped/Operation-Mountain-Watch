-- Operation Mountain Watch - Jalalabad CH-47 heavy-lift squadron assembly
local TAG = "[OMW][AirOps.JBAD.CH47]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end
local function looksLikeCH47(typeName)
  local upper = string.upper(tostring(typeName or ""))
  return string.find(upper, "CH%-47") ~= nil or string.find(upper, "CH47") ~= nil
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg or not cfg.Airwing then log("ERROR: Jalalabad configuration or AIRWING unavailable.") return end
  if cfg.ParkingPoolsOK ~= true or cfg.NameContractOK ~= true then log("ERROR: Parking/name validation not passed; SQUADRON blocked.") return end
  if not GROUP or not SQUADRON or not AUFTRAG then log("ERROR: Required MOOSE classes unavailable.") return end

  local templateName = cfg.Templates.CH47HeavyLift
  local template = GROUP:FindByName(templateName)
  if not template then log("ERROR: CH-47 template missing: " .. tostring(templateName)) return end
  local units = template:GetUnits() or {}
  if #units ~= 1 then log(string.format("ERROR: CH-47 template %s must contain exactly 1 unit; found=%d", templateName, #units)) return end
  local typeName = units[1] and units[1]:GetTypeName() or "nil"
  if not looksLikeCH47(typeName) then log(string.format("ERROR: Template %s is not recognized as CH-47; found=%s", templateName, tostring(typeName))) return end

  local aircraftCount = cfg.Inventory.CH47
  local squadronName = cfg.SquadronNames.CH47
  local parkingIDs = cfg:GetSquadronParkingIDs("CH47")
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.CH47 then log("SKIP: CH-47 squadron already constructed.") return end

  local missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT, AUFTRAG.Type.LANDATCOORDINATE }
  local ok, result = pcall(function()
    local squadron = SQUADRON:New(templateName, aircraftCount, squadronName)
    squadron:SetGrouping(1)
    squadron:SetParkingIDs(parkingIDs)
    squadron:SetTakeoffCold()
    squadron:SetDespawnAfterLanding(true)
    if AI and AI.Skill and AI.Skill.HIGH then squadron:SetSkill(AI.Skill.HIGH) end
    squadron:AddMissionCapability(missionTypes, 100)
    cfg.Airwing:AddSquadron(squadron)
    local payload = cfg.Airwing:NewPayload(template, -1, missionTypes, 100)
    return { Squadron = squadron, Payload = payload }
  end)
  if not ok or not result or not result.Squadron then log("ERROR: CH-47 SQUADRON construction failed: " .. tostring(result)) return end
  if cfg.Airwing:GetSquadron(squadronName) ~= result.Squadron then log("ERROR: AIRWING link validation failed.") return end

  cfg.Squadrons.CH47 = result.Squadron
  cfg.Payloads = cfg.Payloads or {}
  cfg.Payloads.CH47HeavyLift = result.Payload
  cfg.DetectedTypes = cfg.DetectedTypes or {}
  cfg.DetectedTypes.CH47 = typeName
  cfg.CorrectionPending = cfg.CorrectionPending or {}
  cfg.CorrectionPending.CH47 = false
  log("SQUADRON ready name=" .. squadronName .. " physicalGroups=8 groupSize=1 runtimePrefix=" .. cfg:GetRuntimeGroupPrefix("CH47") .. " parkingIDs=" .. table.concat(parkingIDs, ",") .. " despawnAfterLanding=true")
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 15) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 15) end
