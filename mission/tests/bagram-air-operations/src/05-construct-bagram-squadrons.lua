-- Operation Mountain Watch - construct the six binding Bagram squadrons.
local TAG = "[OMW][AirOps.BGRAM.Squadrons]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function templateUnitCount(templateName)
  local group = GROUP:FindByName(templateName)
  if not group then return nil, "template missing" end
  local units = group:GetUnits() or {}
  return #units, nil
end

local function validateTemplate(templateName, expectedCount)
  local count, err = templateUnitCount(templateName)
  if not count then
    log("WAITING: " .. tostring(templateName) .. " " .. tostring(err))
    return nil
  end
  if count ~= expectedCount then
    log(string.format("ERROR: template=%s expectedUnits=%d found=%d", templateName, expectedCount, count))
    return nil
  end
  return GROUP:FindByName(templateName)
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

  local templates = {
    F15E = validateTemplate(cfg.Templates.F15E, 2),
    F16C = validateTemplate(cfg.Templates.F16C, 2),
    C130 = validateTemplate(cfg.Templates.C130, 1),
    HH60GLead = validateTemplate(cfg.Templates.HH60GLead, 1),
    HH60GCover = validateTemplate(cfg.Templates.HH60GCover, 1),
    UH60Transport = validateTemplate(cfg.Templates.UH60Transport, 1),
    UH60Utility = validateTemplate(cfg.Templates.UH60Utility, 1),
    CH47 = validateTemplate(cfg.Templates.CH47, 1)
  }
  for key, value in pairs(templates) do
    if not value then
      log("WAITING: template validation incomplete for " .. key)
      return
    end
  end

  local ok, result = pcall(function()
    -- Only mission types already verified in the pinned MOOSE 2.9.18 project
    -- reference are registered in this no-tasking construction baseline.
    local specs = {
      F15E = {
        template = cfg.Templates.F15E,
        groups = 6,
        grouping = 2,
        name = cfg.SquadronNames.F15E,
        missions = { AUFTRAG.Type.CAS }
      },
      F16C = {
        template = cfg.Templates.F16C,
        groups = 6,
        grouping = 2,
        name = cfg.SquadronNames.F16C,
        missions = { AUFTRAG.Type.CAS }
      },
      C130 = {
        template = cfg.Templates.C130,
        groups = 20,
        grouping = 1,
        name = cfg.SquadronNames.C130,
        missions = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT }
      },
      HH60G = {
        template = cfg.Templates.HH60GLead,
        groups = 6,
        grouping = 1,
        name = cfg.SquadronNames.HH60G,
        missions = {
          AUFTRAG.Type.TROOPTRANSPORT,
          AUFTRAG.Type.LANDATCOORDINATE,
          AUFTRAG.Type.GROUNDESCORT
        }
      },
      UH60 = {
        template = cfg.Templates.UH60Transport,
        groups = 10,
        grouping = 1,
        name = cfg.SquadronNames.UH60,
        missions = {
          AUFTRAG.Type.TROOPTRANSPORT,
          AUFTRAG.Type.CARGOTRANSPORT,
          AUFTRAG.Type.LANDATCOORDINATE
        }
      },
      CH47 = {
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
    for key, spec in pairs(specs) do
      local squadron = SQUADRON:New(spec.template, spec.groups, spec.name)
      squadron:SetGrouping(spec.grouping)
      if AI and AI.Skill and AI.Skill.HIGH then squadron:SetSkill(AI.Skill.HIGH) end
      squadron:AddMissionCapability(spec.missions, 100)
      cfg.Airwing:AddSquadron(squadron)
      made[key] = squadron
    end

    local payloads = {
      F15E = addPayload(cfg.Airwing, templates.F15E, specs.F15E.missions),
      F16C = addPayload(cfg.Airwing, templates.F16C, specs.F16C.missions),
      C130 = addPayload(cfg.Airwing, templates.C130, specs.C130.missions),
      HH60GLead = addPayload(
        cfg.Airwing,
        templates.HH60GLead,
        { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.LANDATCOORDINATE }
      ),
      HH60GCover = addPayload(
        cfg.Airwing,
        templates.HH60GCover,
        { AUFTRAG.Type.GROUNDESCORT }
      ),
      UH60Transport = addPayload(cfg.Airwing, templates.UH60Transport, specs.UH60.missions),
      UH60Utility = addPayload(cfg.Airwing, templates.UH60Utility, specs.UH60.missions),
      CH47 = addPayload(cfg.Airwing, templates.CH47, specs.CH47.missions)
    }

    return { squadrons = made, payloads = payloads }
  end)

  if not ok or not result then
    log("ERROR: Bagram squadron construction failed: " .. tostring(result))
    return
  end

  cfg.Squadrons = result.squadrons
  cfg.Payloads = result.payloads
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
