-- Operation Mountain Watch - Jalalabad Air Operations
-- Validates the first Mission Editor fixture before AIRWING startup.

local PREFIX = "[OMW-AIROPS-JBAD][VALIDATE] "

local function log(message)
  env.info(PREFIX .. tostring(message))
end

local function fail(message)
  env.error(PREFIX .. tostring(message))
end

if not GROUP or not STATIC or not UNIT or not ZONE then
  fail("Required MOOSE wrappers are unavailable. Load Moose.lua first.")
  return
end

local expectedGroups = {
  {
    name = "CLIENT_US_JBAD_OH58D_01",
    required = true,
    lateActivation = false,
    unitCount = 1,
    allowedTypes = { OH58D = true },
  },
  {
    name = "CLIENT_US_JBAD_AH64D_01",
    required = true,
    lateActivation = false,
    unitCount = 1,
    allowedTypes = { ["AH-64D_BLK_II"] = true },
  },
  {
    name = "CLIENT_US_JBAD_UH60L_01",
    required = false,
    lateActivation = false,
    unitCount = 1,
    allowedTypes = nil,
  },
  {
    name = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
    required = true,
    lateActivation = true,
    unitCount = 2,
    allowedTypes = { OH58D = true },
  },
  {
    name = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
    required = true,
    lateActivation = true,
    unitCount = 2,
    allowedTypes = { ["AH-64D_BLK_II"] = true },
  },
  {
    name = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
    required = true,
    lateActivation = true,
    unitCount = 1,
    allowedTypes = { ["UH-60A"] = true },
  },
  {
    name = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP",
    required = true,
    lateActivation = true,
    unitCount = 1,
    allowedTypes = { ["UH-60A"] = true },
  },
}

local expectedZones = {
  "ZONE_AIR_US_JBAD_STATIC_OH58D",
  "ZONE_AIR_US_JBAD_STATIC_AH64D",
  "ZONE_AIR_US_JBAD_STATIC_UH60",
  "ZONE_AIR_US_JBAD_MEDEVAC_READY",
  "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
  "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
  "ZONE_AIR_US_JBAD_SLING_PICKUP",
  "ZONE_AIR_US_JBAD_C130_UNLOAD",
}

local errors = 0
local warnings = 0

local function addError(message)
  errors = errors + 1
  fail("ERROR " .. message)
end

local function addWarning(message)
  warnings = warnings + 1
  log("WARNING " .. message)
end

for _, expected in ipairs(expectedGroups) do
  local group = GROUP:FindByName(expected.name)
  if not group then
    if expected.required then
      addError("missing group " .. expected.name)
    else
      addWarning("optional group absent " .. expected.name)
    end
  else
    local template = group:GetTemplate() or {}
    local units = template.units or {}
    local lateActivation = template.lateActivation == true

    if #units ~= expected.unitCount then
      addError(string.format(
        "group %s has %d template units; expected %d",
        expected.name,
        #units,
        expected.unitCount
      ))
    end

    if lateActivation ~= expected.lateActivation then
      addError(string.format(
        "group %s lateActivation=%s; expected %s",
        expected.name,
        tostring(lateActivation),
        tostring(expected.lateActivation)
      ))
    end

    for index, unitTemplate in ipairs(units) do
      if expected.allowedTypes and not expected.allowedTypes[unitTemplate.type] then
        addError(string.format(
          "group %s unit %d has type %s which is not allowed",
          expected.name,
          index,
          tostring(unitTemplate.type)
        ))
      end
      log(string.format(
        "GROUP_OK name=%s unit=%d type=%s skill=%s parking=%s parking_id=%s",
        expected.name,
        index,
        tostring(unitTemplate.type),
        tostring(unitTemplate.skill),
        tostring(unitTemplate.parking),
        tostring(unitTemplate.parking_id)
      ))
    end
  end
end

local anchor = STATIC:FindByName("WH_AIR_US_JALALABAD", false) or UNIT:FindByName("WH_AIR_US_JALALABAD")
if not anchor then
  addError("missing warehouse anchor WH_AIR_US_JALALABAD")
else
  log("WAREHOUSE_OK name=WH_AIR_US_JALALABAD")
end

for _, zoneName in ipairs(expectedZones) do
  local zone = ZONE:FindByName(zoneName)
  if not zone then
    addError("missing zone " .. zoneName)
  else
    log("ZONE_OK name=" .. zoneName)
  end
end

log(string.format(
  "SUMMARY errors=%d warnings=%d result=%s",
  errors,
  warnings,
  errors == 0 and "PASS" or "FAIL"
))
