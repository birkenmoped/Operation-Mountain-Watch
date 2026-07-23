-- Operation Mountain Watch - Jalalabad CH-47 heavy-lift squadron assembly
-- The actual DCS type string is discovered from the Mission Editor template and
-- becomes the canonical type for player slots and statics in the final validator.
local TAG = "[OMW][AirOps.JBAD.CH47]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function looksLikeCH47(typeName)
  local upper = string.upper(tostring(typeName or ""))
  return string.find(upper, "CH%-47") ~= nil or string.find(upper, "CH47") ~= nil
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR: Jalalabad configuration is unavailable.")
    return
  end

  local airwing = cfg.Airwing
  if not airwing then
    log("WAITING: AIRWING is not constructed.")
    return
  end

  if not GROUP or not SQUADRON or not AUFTRAG then
    log("ERROR: Required MOOSE classes GROUP, SQUADRON or AUFTRAG are unavailable.")
    return
  end

  local templateName = cfg.Templates and cfg.Templates.CH47HeavyLift
  local template = templateName and GROUP:FindByName(templateName) or nil
  if not template then
    log("WAITING: CH-47 heavy-lift template missing: " .. tostring(templateName))
    return
  end

  local units = template:GetUnits() or {}
  if #units ~= 1 then
    log(string.format("ERROR: CH-47 template %s must contain exactly 1 unit; found=%d", templateName, #units))
    return
  end

  local typeName = units[1] and units[1]:GetTypeName() or "nil"
  log(string.format("Template unit name=%s type=%s", units[1] and units[1]:GetName() or "nil", tostring(typeName)))
  if not looksLikeCH47(typeName) then
    log(string.format("ERROR: Template %s is not recognized as a CH-47 type; found=%s", templateName, tostring(typeName)))
    return
  end

  local aircraftCount = cfg.Inventory and cfg.Inventory.CH47 or 0
  if aircraftCount ~= 8 then
    log("ERROR: Jalalabad CH-47 inventory must be exactly 8; found=" .. tostring(aircraftCount))
    return
  end

  local squadronName = cfg.SquadronNames and cfg.SquadronNames.CH47 or "SQ_US_JBAD_CH47_HEAVYLIFT"
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.CH47 then
    log("SKIP: CH-47 squadron already constructed in this mission run.")
    return
  end

  local missionTypes = {
    AUFTRAG.Type.TROOPTRANSPORT,
    AUFTRAG.Type.CARGOTRANSPORT,
    AUFTRAG.Type.LANDATCOORDINATE
  }

  local ok, result = pcall(function()
    local squadron = SQUADRON:New(templateName, aircraftCount, squadronName)
    squadron:SetGrouping(1)
    if AI and AI.Skill and AI.Skill.HIGH then
      squadron:SetSkill(AI.Skill.HIGH)
    end
    squadron:AddMissionCapability(missionTypes, 100)
    airwing:AddSquadron(squadron)

    local payload = airwing:NewPayload(template, -1, missionTypes, 100)
    return { Squadron = squadron, Payload = payload }
  end)

  if not ok or not result or not result.Squadron then
    log("ERROR: CH-47 SQUADRON construction, payload registration or AIRWING linking failed: " .. tostring(result))
    return
  end

  local linked = airwing:GetSquadron(squadronName)
  if linked ~= result.Squadron then
    log("ERROR: AIRWING:GetSquadron did not return the constructed CH-47 squadron.")
    return
  end

  cfg.Squadrons.CH47 = result.Squadron
  cfg.Payloads = cfg.Payloads or {}
  cfg.Payloads.CH47HeavyLift = result.Payload
  cfg.DetectedTypes = cfg.DetectedTypes or {}
  cfg.DetectedTypes.CH47 = typeName
  cfg.CorrectionPending = cfg.CorrectionPending or {}
  cfg.CorrectionPending.CH47 = false

  log(string.format(
    "SQUADRON ready. name=%s type=%s aircraft=%d assetGroups=%d groupSize=1 capabilities=TROOPTRANSPORT/CARGOTRANSPORT/LAND payloads=UNLIMITED.",
    squadronName,
    tostring(typeName),
    aircraftCount,
    aircraftCount
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 15)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 15)
end
