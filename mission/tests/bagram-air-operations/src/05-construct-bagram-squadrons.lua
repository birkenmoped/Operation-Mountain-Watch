-- Operation Mountain Watch - construct the six binding Bagram squadrons.
local TAG = "[OMW][AirOps.BGRAM.Squadrons]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function validateTemplate(key, templateName, expectedCount)
  if not templateName or templateName == "" then
    log("ERROR: template configuration missing for " .. tostring(key))
    return nil
  end

  local group = GROUP:FindByName(templateName)
  if not group then
    log("ERROR: required template missing: " .. tostring(templateName))
    return nil
  end

  if _DATABASE and _DATABASE.GetGroupTemplate then
    local databaseTemplate = _DATABASE:GetGroupTemplate(templateName)
    if not databaseTemplate then
      log("ERROR: template not available through _DATABASE:GetGroupTemplate: " .. tostring(templateName))
      return nil
    end
  end

  local units = group:GetUnits() or {}
  if #units ~= expectedCount then
    log(string.format(
      "ERROR: template=%s expectedUnits=%d found=%d",
      templateName,
      expectedCount,
      #units
    ))
    return nil
  end

  log(string.format("TEMPLATE OK key=%s name=%s units=%d", key, templateName, #units))
  return group
end

local function addPayload(airwing, template, missionTypes)
  return airwing:NewPayload(template, -1, missionTypes, 100)
end

local function construct()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Bagram
  if not cfg or not cfg.Airwing then
    log("WAITING: Bagram AIRWING is not ready.")
    return
  end
  if not GROUP or not SQUADRON or not AUFTRAG then
    log("ERROR: Required MOOSE classes GROUP, SQUADRON or AUFTRAG are unavailable.")
    return
  end
  if next(cfg.Squadrons or {}) then
    log("SKIP: Bagram squadrons already constructed in this mission run.")
    return
  end

  local templateOrder = {
    { key = "F15E", name = cfg.Templates.F15E, units = 2 },
    { key = "F16C", name = cfg.Templates.F16C, units = 2 },
    { key = "C130", name = cfg.Templates.C130, units = 1 },
    { key = "HH60G", name = cfg.Templates.HH60G, units = 1 },
    { key = "UH60", name = cfg.Templates.UH60, units = 1 },
    { key = "CH47", name = cfg.Templates.CH47, units = 1 }
  }

  local templates = {}
  for _, item in ipairs(templateOrder) do
    local template = validateTemplate(item.key, item.name, item.units)
    if not template then
      log("ERROR: fail-closed before SQUADRON construction; invalid template key=" .. item.key)
      return
    end
    templates[item.key] = template
  end

  local specs = {
    {
      key = "F15E",
      template = cfg.Templates.F15E,
      groups = 6,
      grouping = 2,
      name = cfg.SquadronNames.F15E,
      missions = { AUFTRAG.Type.CAS }
    },
    {
      key = "F16C",
      template = cfg.Templates.F16C,
      groups = 6,
      grouping = 2,
      name = cfg.SquadronNames.F16C,
      missions = { AUFTRAG.Type.CAS }
    },
    {
      key = "C130",
      template = cfg.Templates.C130,
      groups = 20,
      grouping = 1,
      name = cfg.SquadronNames.C130,
      missions = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT }
    },
    {
      key = "HH60G",
      template = cfg.Templates.HH60G,
      groups = 6,
      grouping = 1,
      name = cfg.SquadronNames.HH60G,
      missions = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE,
        AUFTRAG.Type.GROUNDESCORT
      }
    },
    {
      key = "UH60",
      template = cfg.Templates.UH60,
      groups = 10,
      grouping = 1,
      name = cfg.SquadronNames.UH60,
      missions = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE
      }
    },
    {
      key = "CH47",
      template = cfg.Templates.CH47,
      groups = 13,
      grouping = 1,
      name = cfg.SquadronNames.CH47,
      missions = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE
      }
    }
  }

  local made = {}
  local payloads = {}

  for _, spec in ipairs(specs) do
    log(string.format(
      "CONSTRUCT key=%s template=%s groups=%d grouping=%d name=%s",
      spec.key,
      spec.template,
      spec.groups,
      spec.grouping,
      spec.name
    ))

    local ok, result = pcall(function()
      local squadron = SQUADRON:New(spec.template, spec.groups, spec.name)
      squadron:SetGrouping(spec.grouping)
      if AI and AI.Skill and AI.Skill.HIGH then squadron:SetSkill(AI.Skill.HIGH) end
      squadron:AddMissionCapability(spec.missions, 100)
      cfg.Airwing:AddSquadron(squadron)
      local payload = addPayload(cfg.Airwing, templates[spec.key], spec.missions)
      return { squadron = squadron, payload = payload }
    end)

    if not ok or not result or not result.squadron then
      log("ERROR: SQUADRON construction failed key=" .. spec.key .. " detail=" .. tostring(result))
      return
    end

    made[spec.key] = result.squadron
    payloads[spec.key] = result.payload
    log("SQUADRON OK key=" .. spec.key .. " name=" .. spec.name)
  end

  cfg.Squadrons = made
  cfg.Payloads = payloads
  cfg.Status = "SQUADRONS_READY"

  log("SQUADRONS ready: F15E=6x2+1reserve F16C=6x2+1reserve C130=20x1 HH60G=6x1 UH60=10x1 CH47=13x1.")
  log("HH60G NOTE: baseline registers only verified generic mission capabilities; dedicated CSAR execution remains a later isolated MOOSE-first test.")
end

if SCHEDULER then
  SCHEDULER:New(nil, construct, {}, 13)
else
  timer.scheduleFunction(function()
    construct()
    return nil
  end, nil, timer.getTime() + 13)
end