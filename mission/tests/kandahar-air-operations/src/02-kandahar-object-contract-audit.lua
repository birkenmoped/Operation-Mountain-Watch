-- Operation Mountain Watch - Kandahar read-only object contract audit.
local TAG = "[OMW][AirOps.KAF.ObjectAudit]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function boolText(value)
  if value == nil then return "nil" end
  return tostring(value)
end

local function serialize(value)
  if UTILS and UTILS.OneLineSerialize and type(value) == "table" then
    local ok, result = pcall(UTILS.OneLineSerialize, value)
    if ok then return tostring(result) end
  end
  return tostring(value)
end

local function addViolation(cfg, reason)
  cfg.Violations = (cfg.Violations or 0) + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function getRouteStart(template)
  local route = template and template.route
  local points = route and route.points
  return points and points[1] or nil
end

local function validateAirbase(cfg, key)
  local spec = cfg.Airbases[key]
  local airbase = AIRBASE:FindByName(spec.Name)
  if not airbase then
    addViolation(cfg, "AIRBASE_MISSING key=" .. key .. " name=" .. tostring(spec.Name))
    return nil
  end

  local actualID = airbase:GetID()
  if tonumber(actualID) ~= tonumber(spec.ExpectedID) then
    addViolation(cfg, string.format(
      "AIRBASE_ID_MISMATCH key=%s expected=%s actual=%s",
      key,
      tostring(spec.ExpectedID),
      tostring(actualID)
    ))
  end

  cfg.AirbaseObjects[key] = airbase
  log(string.format(
    "AIRBASE_OK key=%s name=%s id=%s category=%s role=%s",
    key,
    tostring(airbase:GetName()),
    tostring(actualID),
    tostring(airbase:GetCategoryName()),
    tostring(spec.Role)
  ))
  return airbase
end

local function validateWarehouse(cfg)
  local anchor = STATIC:FindByName(cfg.MainWarehouseName, false) or UNIT:FindByName(cfg.MainWarehouseName)
  if not anchor then
    addViolation(cfg, "MAIN_WAREHOUSE_MISSING name=" .. tostring(cfg.MainWarehouseName))
  else
    if tostring(anchor:GetTypeName()) ~= "container_40ft" then
      addViolation(cfg, "MAIN_WAREHOUSE_TYPE_MISMATCH expected=container_40ft actual=" .. tostring(anchor:GetTypeName()))
    end
    if tonumber(anchor:GetCoalition()) ~= 2 then
      addViolation(cfg, "MAIN_WAREHOUSE_COALITION_MISMATCH expected=2 actual=" .. tostring(anchor:GetCoalition()))
    end
    local vec3 = anchor:GetCoordinate():GetVec3()
    log(string.format(
      "WAREHOUSE_OK role=MAIN name=%s type=%s coalition=%s x=%.1f y=%.1f z=%.1f",
      tostring(anchor:GetName()),
      tostring(anchor:GetTypeName()),
      tostring(anchor:GetCoalition()),
      tonumber(vec3.x) or 0,
      tonumber(vec3.y) or 0,
      tonumber(vec3.z) or 0
    ))
  end

  if cfg.HeliportWarehouseName then
    local heliAnchor = STATIC:FindByName(cfg.HeliportWarehouseName, false) or UNIT:FindByName(cfg.HeliportWarehouseName)
    if heliAnchor then
      log("WAREHOUSE_UNEXPECTED role=HELIPORT name=" .. tostring(cfg.HeliportWarehouseName))
    else
      log("BLOCKER code=HELIPORT_WAREHOUSE_ANCHOR_MISSING configuredName=" .. tostring(cfg.HeliportWarehouseName))
    end
  else
    log("BLOCKER code=HELIPORT_WAREHOUSE_NAME_UNAPPROVED configuredName=nil")
    log("BLOCKER code=HELIPORT_WAREHOUSE_ANCHOR_MISSING expectedByArchitecture=true")
  end
end

local function validateClient(cfg, spec)
  local template = _DATABASE:GetGroupTemplate(spec.Name)
  if not template or not template.units or #template.units ~= 1 then
    addViolation(cfg, "CLIENT_TEMPLATE_INVALID name=" .. spec.Name)
    return
  end

  local unit = template.units[1]
  local start = getRouteStart(template)
  local airbaseSpec = cfg.Airbases[spec.AirbaseKey]
  local actualType = tostring(unit.type)
  if actualType ~= spec.Type then
    addViolation(cfg, string.format(
      "CLIENT_TYPE_MISMATCH name=%s expected=%s actual=%s",
      spec.Name,
      spec.Type,
      actualType
    ))
  end

  if start and tonumber(start.airdromeId) ~= tonumber(airbaseSpec.ExpectedID) then
    addViolation(cfg, string.format(
      "CLIENT_AIRBASE_MISMATCH name=%s expected=%s actual=%s",
      spec.Name,
      tostring(airbaseSpec.ExpectedID),
      tostring(start.airdromeId)
    ))
  end

  log(string.format(
    "CLIENT_OK name=%s unit=%s type=%s skill=%s airbaseKey=%s airdromeId=%s parking=%s parkingId=%s x=%.1f y=%.1f",
    spec.Name,
    tostring(unit.name),
    actualType,
    tostring(unit.skill),
    spec.AirbaseKey,
    start and tostring(start.airdromeId) or "nil",
    tostring(unit.parking),
    tostring(unit.parking_id),
    tonumber(unit.x) or 0,
    tonumber(unit.y) or 0
  ))
end

local function validateTemplate(cfg, spec)
  local template = _DATABASE:GetGroupTemplate(spec.Name)
  if not template or not template.units then
    addViolation(cfg, "TEMPLATE_MISSING name=" .. spec.Name)
    return
  end

  if #template.units ~= spec.Count then
    addViolation(cfg, string.format(
      "TEMPLATE_COUNT_MISMATCH name=%s expected=%d actual=%d",
      spec.Name,
      spec.Count,
      #template.units
    ))
  end

  local start = getRouteStart(template)
  local uncontrolled = template.uncontrolled
  if uncontrolled == nil then uncontrolled = template.uncontrollable end
  if template.lateActivation ~= true then
    addViolation(cfg, "TEMPLATE_NOT_LATE_ACTIVATION name=" .. spec.Name)
  end
  if uncontrolled == true then
    addViolation(cfg, "TEMPLATE_UNCONTROLLED name=" .. spec.Name)
  end
  log(string.format(
    "TEMPLATE_BEGIN name=%s domain=%s count=%d task=%s lateActivation=%s uncontrolled=%s startAction=%s airdromeId=%s",
    spec.Name,
    spec.Domain,
    #template.units,
    tostring(template.task),
    boolText(template.lateActivation),
    boolText(uncontrolled),
    start and tostring(start.action) or "nil",
    start and tostring(start.airdromeId) or "nil"
  ))

  for index, unit in ipairs(template.units) do
    if tostring(unit.type) ~= spec.Type then
      addViolation(cfg, string.format(
        "TEMPLATE_TYPE_MISMATCH name=%s unit=%d expected=%s actual=%s",
        spec.Name,
        index,
        spec.Type,
        tostring(unit.type)
      ))
    end

    log(string.format(
      "TEMPLATE_UNIT name=%s unit=%d unitName=%s type=%s skill=%s payload=%s",
      spec.Name,
      index,
      tostring(unit.name),
      tostring(unit.type),
      tostring(unit.skill),
      serialize(unit.payload or {})
    ))
  end

  log("TEMPLATE_END name=" .. spec.Name)
end

local function validateForbiddenTemplates(cfg)
  for _, templateName in ipairs(cfg.ForbiddenTemplates or {}) do
    if _DATABASE:GetGroupTemplate(templateName) then
      addViolation(cfg, "OBSOLETE_TEMPLATE_PRESENT name=" .. templateName)
    else
      log("OBSOLETE_TEMPLATE_ABSENT name=" .. templateName)
    end
  end
end

local function collectStaticSet(prefix)
  return SET_STATIC:New():FilterPrefixes(prefix):FilterOnce()
end

local function auditStaticSet(cfg, prefix, expectedTypes, label)
  local set = collectStaticSet(prefix)
  local counts = {}
  local total = 0

  set:ForEachStatic(function(static)
    total = total + 1
    local typeName = tostring(static:GetTypeName())
    counts[typeName] = (counts[typeName] or 0) + 1
    local vec3 = static:GetCoordinate():GetVec3()
    log(string.format(
      "STATIC label=%s name=%s type=%s coalition=%s x=%.1f y=%.1f z=%.1f",
      label,
      tostring(static:GetName()),
      typeName,
      tostring(static:GetCoalition()),
      tonumber(vec3.x) or 0,
      tonumber(vec3.y) or 0,
      tonumber(vec3.z) or 0
    ))
  end)

  for typeName, expected in pairs(expectedTypes) do
    local actual = counts[typeName] or 0
    if actual ~= expected then
      addViolation(cfg, string.format(
        "STATIC_COUNT_MISMATCH label=%s type=%s expected=%d actual=%d",
        label,
        typeName,
        expected,
        actual
      ))
    end
  end

  for typeName, actual in pairs(counts) do
    if expectedTypes[typeName] == nil then
      addViolation(cfg, string.format(
        "STATIC_TYPE_UNEXPECTED label=%s type=%s actual=%d",
        label,
        typeName,
        actual
      ))
    end
  end

  log(string.format("STATIC_SUMMARY label=%s total=%d counts=%s", label, total, serialize(counts)))
end

local function validateZones(cfg)
  for _, zoneName in ipairs(cfg.RequiredZones) do
    local zone = ZONE:FindByName(zoneName)
    if not zone then
      addViolation(cfg, "ZONE_MISSING name=" .. zoneName)
    else
      local vec3 = zone:GetCoordinate():GetVec3()
      local radius = zone.GetRadius and zone:GetRadius() or nil
      log(string.format(
        "ZONE_OK name=%s radius=%s x=%.1f y=%.1f z=%.1f",
        zoneName,
        tostring(radius),
        tonumber(vec3.x) or 0,
        tonumber(vec3.y) or 0,
        tonumber(vec3.z) or 0
      ))
    end
  end
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.KandaharDiagnostic
  if not cfg then
    log("RESULT: FAIL reason=CONFIG_UNAVAILABLE noSpawn=true")
    return
  end

  log("BEGIN noSpawn=true noAirwingConstruction=true noSquadronRegistration=true")

  if OMW.AirOps.Kandahar ~= nil then
    addViolation(cfg, "KANDAHAR_RUNTIME_NAMESPACE_UNEXPECTED")
  end

  if not AIRBASE or not STATIC or not UNIT or not SET_STATIC or not ZONE or not COORDINATE then
    addViolation(cfg, "REQUIRED_MOOSE_CLASSES_UNAVAILABLE")
  end
  if not _DATABASE or not _DATABASE.GetGroupTemplate then
    addViolation(cfg, "DATABASE_GROUP_TEMPLATE_API_UNAVAILABLE")
  end
  if not UTILS or not UTILS.OneLineSerialize then
    addViolation(cfg, "UTILS_SERIALIZER_UNAVAILABLE")
  end

  if cfg.Violations == 0 then
    validateAirbase(cfg, "Main")
    validateAirbase(cfg, "Heliport")
    validateWarehouse(cfg)

    for _, spec in ipairs(cfg.Clients) do validateClient(cfg, spec) end
    for _, spec in ipairs(cfg.Templates) do validateTemplate(cfg, spec) end
    validateForbiddenTemplates(cfg)

    auditStaticSet(cfg, "STATIC_AIR_US_KAF_", cfg.ExpectedUSStaticTypes, "US_AIR")
    auditStaticSet(cfg, "STATIC_AIR_UN_KAF_", cfg.ExpectedUNStaticTypes, "UN_AIR")
    validateZones(cfg)

    local medic = STATIC:FindByName("STATIC_GND_US_KAF_M113_MEDIC", false) or UNIT:FindByName("STATIC_GND_US_KAF_M113_MEDIC")
    if medic then
      log("STATIC_OK role=CSAR_MEDIC name=STATIC_GND_US_KAF_M113_MEDIC type=" .. tostring(medic:GetTypeName()))
    else
      addViolation(cfg, "CSAR_MEDIC_STATIC_MISSING")
    end
  end

  cfg.ObjectContractOK = cfg.Violations == 0
  cfg.Status = cfg.ObjectContractOK and "OBJECT_CONTRACT_AUDITED" or "OBJECT_CONTRACT_FAILED"

  if cfg.ObjectContractOK then
    log("RESULT: PASS objectContract=true runtimeReady=false expectedBlockers=" .. table.concat(cfg.ExpectedBlockers, ",") .. " noSpawn=true")
  else
    log("RESULT: FAIL objectContract=false violations=" .. tostring(cfg.Violations) .. " runtimeReady=false noSpawn=true")
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 7)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 7)
end
