-- Operation Mountain Watch - Jalalabad Air Operations diagnostics

local function omwLog(scope, message)
  env.info("[OMW-AIROPS][" .. scope .. "] " .. tostring(message), false)
end

local function safe(value)
  if value == nil then return "<nil>" end
  return tostring(value)
end

local function dumpAircraftTypes()
  local expected = {
    "TEST_TM01A_CLIENT_01",
    "CLIENT_US_JBAD_OH58D_01",
    "CLIENT_US_JBAD_AH64D_01",
    "CLIENT_US_JBAD_UH60L_01",
    "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
    "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
    "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
    "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP"
  }

  omwLog("TYPES", "BEGIN")
  if not _DATABASE or not _DATABASE.Templates or not _DATABASE.Templates.Groups then
    omwLog("TYPES", "ERROR MOOSE template database not available; load bundle after Moose.lua")
    return
  end

  for _, groupName in ipairs(expected) do
    local template = _DATABASE.Templates.Groups[groupName]
    if not template then
      omwLog("TYPES", "GROUP missing name=" .. groupName)
    else
      local units = template.Template and template.Template.units or template.units
      omwLog("TYPES", "GROUP found name=" .. groupName .. " category=" .. safe(template.CategoryName or template.CategoryID))
      if units then
        for index, unit in ipairs(units) do
          omwLog("TYPES", "UNIT group=" .. groupName .. " index=" .. index .. " name=" .. safe(unit.name) .. " type=" .. safe(unit.type) .. " skill=" .. safe(unit.skill))
          if Unit and Unit.getDescByName and unit.type then
            local ok, desc = pcall(Unit.getDescByName, unit.type)
            if ok and desc then
              omwLog("TYPES", "DESC type=" .. unit.type .. " displayName=" .. safe(desc.displayName) .. " category=" .. safe(desc.category))
            else
              omwLog("TYPES", "DESC unavailable type=" .. safe(unit.type))
            end
          end
        end
      end
    end
  end
  omwLog("TYPES", "END")
end

local function dumpAirbaseParking()
  local function dumpParking(airbase)
    local ok, parking = pcall(function() return airbase:getParking(false) end)
    if not ok or not parking then
      omwLog("PARKING", "ERROR getParking failed airbase=" .. safe(airbase:getName()))
      return
    end
    omwLog("PARKING", "PARKING_COUNT airbase=" .. safe(airbase:getName()) .. " count=" .. #parking)
    for index, spot in ipairs(parking) do
      local v = spot.vTerminalPos or spot.TerminalPos or spot.point or {}
      omwLog("PARKING", string.format(
        "SPOT index=%d TerminalID=%s TerminalType=%s TO_AC=%s x=%s y=%s z=%s",
        index, safe(spot.TerminalID), safe(spot.TerminalType), safe(spot.TO_AC),
        safe(v.x), safe(v.y), safe(v.z)
      ))
    end
  end

  omwLog("PARKING", "BEGIN")
  local coalitions = { coalition.side.BLUE, coalition.side.RED, coalition.side.NEUTRAL }
  local jalalabad = nil
  for _, side in ipairs(coalitions) do
    local ok, airbases = pcall(coalition.getAirbases, side)
    if ok and airbases then
      for _, airbase in ipairs(airbases) do
        local name = airbase:getName()
        local id = airbase:getID()
        omwLog("PARKING", "AIRBASE side=" .. safe(side) .. " id=" .. safe(id) .. " name=" .. safe(name))
        local lower = string.lower(name or "")
        if id == 16 or string.find(lower, "jalalabad", 1, true) then
          jalalabad = airbase
        end
      end
    end
  end

  if jalalabad then
    omwLog("PARKING", "JALALABAD_FOUND id=" .. safe(jalalabad:getID()) .. " name=" .. safe(jalalabad:getName()))
    dumpParking(jalalabad)
  else
    omwLog("PARKING", "ERROR Jalalabad not found by id=16 or name")
  end
  omwLog("PARKING", "END")
end

local function probeWarehouseAnchor()
  local anchorName = "WH_AIR_US_JALALABAD"
  local zoneName = "ZONE_TM01_TARGET_JALALABAD"

  omwLog("WAREHOUSE", "BEGIN")
  if STATIC and STATIC.FindByName then
    local ok, object = pcall(function() return STATIC:FindByName(anchorName, false) end)
    omwLog("WAREHOUSE", "MOOSE_STATIC name=" .. anchorName .. " found=" .. safe(ok and object ~= nil))
  end
  if UNIT and UNIT.FindByName then
    local ok, object = pcall(function() return UNIT:FindByName(anchorName) end)
    omwLog("WAREHOUSE", "MOOSE_UNIT name=" .. anchorName .. " found=" .. safe(ok and object ~= nil))
  end

  local dcsStatic = StaticObject.getByName(anchorName)
  omwLog("WAREHOUSE", "DCS_STATIC name=" .. anchorName .. " found=" .. safe(dcsStatic ~= nil))
  local dcsUnit = Unit.getByName(anchorName)
  omwLog("WAREHOUSE", "DCS_UNIT name=" .. anchorName .. " found=" .. safe(dcsUnit ~= nil))

  local center = nil
  local radius = 1200
  if trigger and trigger.misc and trigger.misc.getZone then
    local zone = trigger.misc.getZone(zoneName)
    if zone then
      center = { x = zone.point.x, y = zone.point.y, z = zone.point.z }
      radius = math.max(zone.radius or 0, radius)
      omwLog("WAREHOUSE", "ZONE found name=" .. zoneName .. " x=" .. safe(center.x) .. " z=" .. safe(center.z) .. " radius=" .. safe(radius))
    end
  end

  if center and world and world.searchObjects then
    local count = 0
    local volume = { id = world.VolumeType.SPHERE, params = { point = center, radius = radius } }
    world.searchObjects(Object.Category.SCENERY, volume, function(object)
      count = count + 1
      local desc = object:getDesc() or {}
      local point = object:getPoint() or {}
      local typeName = desc.typeName or desc.displayName or "<unknown>"
      local lower = string.lower(typeName)
      if string.find(lower, "warehouse", 1, true)
        or string.find(lower, "hangar", 1, true)
        or string.find(lower, "depot", 1, true)
        or string.find(lower, "fuel", 1, true)
        or string.find(lower, "storage", 1, true) then
        omwLog("WAREHOUSE", "SCENERY_CANDIDATE name=" .. safe(object:getName()) .. " type=" .. safe(typeName) .. " x=" .. safe(point.x) .. " z=" .. safe(point.z))
      end
      return true
    end)
    omwLog("WAREHOUSE", "SCENERY_SCANNED count=" .. count .. " radius=" .. radius)
  else
    omwLog("WAREHOUSE", "WARNING scenery scan skipped; Jalalabad reference zone missing")
  end
  omwLog("WAREHOUSE", "END")
end

local function validateMissionTemplates()
  local requiredGroups = {
    "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
    "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
    "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
    "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP"
  }
  local optionalGroups = {
    "CLIENT_US_JBAD_OH58D_01", "CLIENT_US_JBAD_OH58D_02", "CLIENT_US_JBAD_OH58D_03", "CLIENT_US_JBAD_OH58D_04",
    "CLIENT_US_JBAD_AH64D_01", "CLIENT_US_JBAD_AH64D_02", "CLIENT_US_JBAD_AH64D_03", "CLIENT_US_JBAD_AH64D_04",
    "CLIENT_US_JBAD_UH60L_01", "CLIENT_US_JBAD_UH60L_02", "CLIENT_US_JBAD_UH60L_03", "CLIENT_US_JBAD_UH60L_04"
  }
  local requiredZones = {
    "ZONE_AIR_US_JBAD_STATIC_OH58D", "ZONE_AIR_US_JBAD_STATIC_AH64D",
    "ZONE_AIR_US_JBAD_STATIC_UH60", "ZONE_AIR_US_JBAD_MEDEVAC_READY",
    "ZONE_AIR_US_JBAD_LOGISTICS_LOAD", "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_JBAD_SLING_PICKUP", "ZONE_AIR_US_JBAD_C130_UNLOAD"
  }
  local requiredStatics = {}
  for i = 1, 8 do requiredStatics[#requiredStatics + 1] = string.format("STATIC_AIR_US_JBAD_OH58D_%02d", i) end
  for i = 1, 4 do requiredStatics[#requiredStatics + 1] = string.format("STATIC_AIR_US_JBAD_AH64D_%02d", i) end
  for i = 1, 2 do requiredStatics[#requiredStatics + 1] = string.format("STATIC_AIR_US_JBAD_UH60_%02d", i) end

  local errors = 0
  local warnings = 0
  local function groupTemplate(name)
    return _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[name]
  end

  omwLog("VALIDATE", "BEGIN")
  for _, name in ipairs(requiredGroups) do
    local template = groupTemplate(name)
    if not template then
      errors = errors + 1
      omwLog("VALIDATE", "ERROR missing required group=" .. name)
    else
      local units = template.Template and template.Template.units or template.units or {}
      omwLog("VALIDATE", "PASS group=" .. name .. " units=" .. #units)
    end
  end
  for _, name in ipairs(optionalGroups) do
    if groupTemplate(name) then
      omwLog("VALIDATE", "PASS optional group=" .. name)
    else
      warnings = warnings + 1
      omwLog("VALIDATE", "WARNING optional group missing=" .. name)
    end
  end
  for _, name in ipairs(requiredZones) do
    local zone = trigger.misc.getZone(name)
    if zone then
      omwLog("VALIDATE", "PASS zone=" .. name .. " radius=" .. tostring(zone.radius))
    else
      errors = errors + 1
      omwLog("VALIDATE", "ERROR missing zone=" .. name)
    end
  end
  for _, name in ipairs(requiredStatics) do
    local object = StaticObject.getByName(name)
    if object then
      omwLog("VALIDATE", "PASS static=" .. name)
    else
      errors = errors + 1
      omwLog("VALIDATE", "ERROR missing static=" .. name)
    end
  end
  local warehouse = StaticObject.getByName("WH_AIR_US_JALALABAD") or Unit.getByName("WH_AIR_US_JALALABAD")
  if warehouse then
    omwLog("VALIDATE", "PASS warehouse anchor=WH_AIR_US_JALALABAD")
  else
    warnings = warnings + 1
    omwLog("VALIDATE", "WARNING warehouse anchor missing=WH_AIR_US_JALALABAD")
  end
  omwLog("VALIDATE", "SUMMARY errors=" .. errors .. " warnings=" .. warnings)
  omwLog("VALIDATE", "END")
end

local ok, err = pcall(function()
  dumpAircraftTypes()
  dumpAirbaseParking()
  probeWarehouseAnchor()
  validateMissionTemplates()
end)
if not ok then
  omwLog("FATAL", err)
end
