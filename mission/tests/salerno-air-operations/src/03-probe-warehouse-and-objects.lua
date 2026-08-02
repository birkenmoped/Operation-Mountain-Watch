local TAG = "[OMW][SALERNO][DIAG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function findTemplate(name)
  return _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[name] or nil
end

local function countUnits(template)
  local units = template and template.Template and template.Template.units
  return type(units) == "table" and #units or 0
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("ERROR configuration missing") return end

  local static = STATIC and STATIC:FindByName(cfg.WarehouseName, false) or nil
  local unit = UNIT and UNIT:FindByName(cfg.WarehouseName) or nil
  log("WAREHOUSE name=" .. cfg.WarehouseName .. " static=" .. tostring(static ~= nil) .. " unit=" .. tostring(unit ~= nil))
  if static then
    local vec3 = static:GetVec3() or {}
    log(string.format("WAREHOUSE_STATIC coalition=%s country=%s x=%.1f y=%.1f z=%.1f",
      tostring(static:GetCoalitionName()), tostring(static:GetCountryName()),
      tonumber(vec3.x) or 0, tonumber(vec3.y) or 0, tonumber(vec3.z) or 0))
  end

  local clientsPresent = 0
  for _, name in ipairs(cfg.Clients) do
    local template = findTemplate(name)
    if template then clientsPresent = clientsPresent + 1 end
    log("CLIENT_TEMPLATE " .. (template and "OK " or "MISSING ") .. name)
  end

  local templatesPresent, templateUnits = 0, 0
  for _, name in ipairs(cfg.Templates) do
    local template = findTemplate(name)
    if template then
      templatesPresent = templatesPresent + 1
      templateUnits = templateUnits + countUnits(template)
    end
    log("AI_TEMPLATE " .. (template and "OK " or "MISSING ") .. name .. " units=" .. tostring(countUnits(template)))
  end

  local zonesPresent = 0
  for _, name in ipairs(cfg.Zones) do
    local zone = ZONE and ZONE:FindByName(name) or nil
    if zone then zonesPresent = zonesPresent + 1 end
    log("ZONE " .. (zone and "OK " or "MISSING ") .. name)
  end

  local pass = clientsPresent == cfg.Expected.ClientGroups
    and templatesPresent == cfg.Expected.TemplateGroups
    and templateUnits == cfg.Expected.TemplateUnits
    and zonesPresent == cfg.Expected.Zones
    and (static ~= nil or unit ~= nil)

  log(string.format("SUMMARY clients=%d/%d templates=%d/%d templateUnits=%d/%d zones=%d/%d warehouse=%s",
    clientsPresent, cfg.Expected.ClientGroups, templatesPresent, cfg.Expected.TemplateGroups,
    templateUnits, cfg.Expected.TemplateUnits, zonesPresent, cfg.Expected.Zones,
    tostring(static ~= nil or unit ~= nil)))
  log("COMPLETE status=" .. (pass and "PASS" or "FAIL"))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 5) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 5) end
