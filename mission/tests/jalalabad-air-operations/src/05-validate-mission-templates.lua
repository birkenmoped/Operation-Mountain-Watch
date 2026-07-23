local TAG = "[OMW][ValidateMissionTemplates]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local expectedGroups = {
  "CLIENT_US_JBAD_OH58D_01", "CLIENT_US_JBAD_OH58D_02", "CLIENT_US_JBAD_OH58D_03", "CLIENT_US_JBAD_OH58D_04",
  "CLIENT_US_JBAD_AH64D_01", "CLIENT_US_JBAD_AH64D_02", "CLIENT_US_JBAD_AH64D_03", "CLIENT_US_JBAD_AH64D_04",
  "CLIENT_US_JBAD_UH60L_01", "CLIENT_US_JBAD_UH60L_02", "CLIENT_US_JBAD_UH60L_03", "CLIENT_US_JBAD_UH60L_04",
  "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP", "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
  "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP", "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP"
}

local expectedStatics = {
  "STATIC_AIR_US_JBAD_OH58D_01", "STATIC_AIR_US_JBAD_AH64D_01", "STATIC_AIR_US_JBAD_UH60_01"
}

local expectedZones = {
  "ZONE_AIR_US_JBAD_STATIC_OH58D", "ZONE_AIR_US_JBAD_STATIC_AH64D", "ZONE_AIR_US_JBAD_STATIC_UH60",
  "ZONE_AIR_US_JBAD_MEDEVAC_READY", "ZONE_AIR_US_JBAD_LOGISTICS_LOAD", "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
  "ZONE_AIR_US_JBAD_SLING_PICKUP", "ZONE_AIR_US_JBAD_C130_UNLOAD"
}

local function check(kind, names, finder)
  local present, missing = 0, 0
  for _, name in ipairs(names) do
    local ok, object = pcall(finder, name)
    if ok and object then
      present = present + 1
      log("OK " .. kind .. " " .. name)
    else
      missing = missing + 1
      log("MISSING " .. kind .. " " .. name)
    end
  end
  log(string.format("SUMMARY %s present=%d missing=%d", kind, present, missing))
end

local function main()
  check("GROUP", expectedGroups, function(name) return GROUP and GROUP:FindByName(name) end)
  check("STATIC", expectedStatics, function(name) return STATIC and STATIC:FindByName(name, false) end)
  check("ZONE", expectedZones, function(name) return ZONE and ZONE:FindByName(name) end)

  -- The warehouse is intentionally absent in the initial fixture. Query it
  -- without raising so that the validator can emit a normal MISSING result.
  local warehouse = (STATIC and STATIC:FindByName("WH_AIR_US_JALALABAD", false)) or
                    (UNIT and UNIT:FindByName("WH_AIR_US_JALALABAD"))
  log("WAREHOUSE_ANCHOR " .. (warehouse and "OK" or "MISSING") .. " WH_AIR_US_JALALABAD")
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 5) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 5) end
