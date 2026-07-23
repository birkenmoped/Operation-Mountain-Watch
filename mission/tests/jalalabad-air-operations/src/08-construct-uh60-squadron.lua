-- Operation Mountain Watch - Jalalabad UH-60 Utility/MEDEVAC squadron assembly
-- One eight-aircraft squadron uses separate one-ship lead and cover payload templates.
local TAG = "[OMW][AirOps.JBAD.UH60]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function getTemplateLivery(templateName)
  if not _DATABASE or not _DATABASE.Templates or not _DATABASE.Templates.Groups then
    return nil
  end

  local entry = _DATABASE.Templates.Groups[templateName]
  local template = entry and entry.Template or nil
  local unit = template and template.units and template.units[1] or nil
  return unit and (unit.livery_id or unit.livery) or nil
end

local function validateTemplate(templateName, expectedType, role, expectedLivery)
  local template = templateName and GROUP:FindByName(templateName) or nil
  if not template then
    log("WAITING: " .. role .. " template missing: " .. tostring(templateName))
    return nil
  end

  local units = template:GetUnits() or {}
  if #units ~= 1 then
    log(string.format("ERROR: %s template %s must contain exactly 1 unit; found=%d", role, templateName, #units))
    return nil
  end

  local typeName = units[1] and units[1]:GetTypeName() or "nil"
  local livery = getTemplateLivery(templateName)
  log(string.format(
    "%s template unit name=%s type=%s livery=%s",
    role,
    units[1] and units[1]:GetName() or "nil",
    tostring(typeName),
    tostring(livery)
  ))

  if typeName ~= expectedType then
    log(string.format("ERROR: %s template %s must use type %s; found=%s", role, templateName, expectedType, tostring(typeName)))
    return nil
  end

  if expectedLivery and tostring(livery) ~= expectedLivery then
    log(string.format(
      "ERROR: %s template %s must use livery %s; found=%s",
      role,
      templateName,
      expectedLivery,
      tostring(livery)
    ))
    return nil
  end

  return template
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

  local leadName = cfg.Templates and cfg.Templates.UH60MedevacLead
  local coverName = cfg.Templates and cfg.Templates.UH60MedevacCover
  local requiredLivery = "standard"
  local leadTemplate = validateTemplate(leadName, "UH-60A", "MEDEVAC_LEAD", requiredLivery)
  local coverTemplate = validateTemplate(coverName, "UH-60A", "MEDEVAC_COVER", requiredLivery)
  if not leadTemplate or not coverTemplate then
    return
  end

  local aircraftCount = cfg.Inventory and cfg.Inventory.UH60 or 0
  if aircraftCount ~= 8 then
    log("ERROR: Jalalabad UH-60 inventory must be exactly 8; found=" .. tostring(aircraftCount))
    return
  end

  local squadronName = cfg.SquadronNames and cfg.SquadronNames.UH60 or "SQ_US_JBAD_UH60_UTILITY_MEDEVAC"
  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.UH60 then
    log("SKIP: UH-60 squadron already constructed in this mission run.")
    return
  end

  local missionTypes = {
    AUFTRAG.Type.TROOPTRANSPORT,
    AUFTRAG.Type.CARGOTRANSPORT,
    AUFTRAG.Type.LANDATCOORDINATE,
    AUFTRAG.Type.GROUNDESCORT
  }

  local ok, result = pcall(function()
    local squadron = SQUADRON:New(leadName, aircraftCount, squadronName)
    squadron:SetGrouping(1)
    if AI and AI.Skill and AI.Skill.HIGH then
      squadron:SetSkill(AI.Skill.HIGH)
    end
    squadron:AddMissionCapability(missionTypes, 100)
    airwing:AddSquadron(squadron)

    local leadPayload = airwing:NewPayload(
      leadTemplate,
      -1,
      { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT, AUFTRAG.Type.LANDATCOORDINATE },
      100
    )
    local coverPayload = airwing:NewPayload(
      coverTemplate,
      -1,
      { AUFTRAG.Type.GROUNDESCORT },
      100
    )

    return {
      Squadron = squadron,
      LeadPayload = leadPayload,
      CoverPayload = coverPayload
    }
  end)

  if not ok or not result or not result.Squadron then
    log("ERROR: SQUADRON construction, payload registration or AIRWING linking failed: " .. tostring(result))
    return
  end

  local linked = airwing:GetSquadron(squadronName)
  if linked ~= result.Squadron then
    log("ERROR: AIRWING:GetSquadron did not return the constructed squadron.")
    return
  end

  cfg.Squadrons.UH60 = result.Squadron
  cfg.Payloads = cfg.Payloads or {}
  cfg.Payloads.UH60MedevacLead = result.LeadPayload
  cfg.Payloads.UH60MedevacCover = result.CoverPayload

  log(string.format(
    "SQUADRON ready. name=%s aircraft=%d assetGroups=%d groupSize=1 capabilities=TRANSPORT/LAND/GROUNDESCORT medevacPackage=1+1 livery=%s payloads=UNLIMITED.",
    squadronName,
    aircraftCount,
    aircraftCount,
    requiredLivery
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 13)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 13)
end
