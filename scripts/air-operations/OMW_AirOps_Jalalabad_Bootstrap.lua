do
  local PREFIX = "[OMW][AIR-OPS][JBAD-BOOTSTRAP]"
  local START_DELAY_SECONDS = 12

  local Config = {
    enableRuntimeObjects = false,
    airbaseName = "Jalalabad",
    warehouseAnchorName = "WH_AIR_US_JALALABAD",
    airwingName = "AW_US_JALALABAD",
    squadrons = {
      {
        name = "SQ_6_6_CAV_OH58D",
        template = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
        assetGroups = 2,
        grouping = 2,
      },
      {
        name = "SQ_B_1_10_AVN_AH64D",
        template = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
        assetGroups = 2,
        grouping = 2,
      },
      {
        name = "SQ_JBAD_MEDEVAC_LEAD_UH60",
        template = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
        assetGroups = 3,
        grouping = 1,
      },
      {
        name = "SQ_JBAD_MEDEVAC_COVER_UH60",
        template = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP",
        assetGroups = 3,
        grouping = 1,
      },
    },
  }

  local function log(level, message)
    local text = string.format("%s %s", PREFIX, message)
    if level == "ERROR" then
      env.error(text, false)
    elseif level == "WARN" then
      env.warning(text, false)
    else
      env.info(text, false)
    end
  end

  local function prerequisitesPresent()
    local valid = true
    local airbase = AIRBASE and AIRBASE:FindByName(Config.airbaseName) or nil
    if not airbase then
      log("ERROR", "Missing airbase=" .. Config.airbaseName)
      valid = false
    end

    local anchor = STATIC and STATIC:FindByName(Config.warehouseAnchorName, false) or nil
    if not anchor then
      local unitAnchor = UNIT and UNIT:FindByName(Config.warehouseAnchorName) or nil
      anchor = unitAnchor
    end
    if not anchor then
      log("ERROR", "Missing warehouse anchor=" .. Config.warehouseAnchorName)
      valid = false
    end

    for _, squadron in ipairs(Config.squadrons) do
      local template = GROUP and GROUP:FindByName(squadron.template) or nil
      if not template then
        log("ERROR", "Missing squadron template=" .. squadron.template)
        valid = false
      end
    end

    return valid, airbase
  end

  local function createRuntimeObjects(airbase)
    local airwing = AIRWING:New(Config.warehouseAnchorName, Config.airwingName)
    if not airwing then
      error("AIRWING:New returned nil")
    end
    airwing:SetAirbase(airbase)
    airwing:SetMarker(false)

    for _, squadronConfig in ipairs(Config.squadrons) do
      local squadron = SQUADRON:New(
        squadronConfig.template,
        squadronConfig.assetGroups,
        squadronConfig.name
      )
      squadron:SetGrouping(squadronConfig.grouping)
      squadron:SetTakeoffCold()
      airwing:AddSquadron(squadron)
      log("INFO", string.format(
        "Squadron created name=%s template=%s assetGroups=%d grouping=%d",
        squadronConfig.name,
        squadronConfig.template,
        squadronConfig.assetGroups,
        squadronConfig.grouping
      ))
    end

    airwing:Start()
    log("INFO", "AIRWING created name=" .. Config.airwingName)
  end

  local function run()
    log("INFO", "BEGIN runtimeEnabled=" .. tostring(Config.enableRuntimeObjects))
    local valid, airbase = prerequisitesPresent()
    if not valid then
      log("WARN", "Prerequisites incomplete; runtime objects were not created")
      log("INFO", "END result=PREREQUISITES_MISSING")
      return nil
    end

    if not Config.enableRuntimeObjects then
      log("INFO", "Prerequisites complete; runtime creation intentionally disabled for diagnostic phase")
      log("INFO", "END result=PREFLIGHT_PASS")
      return nil
    end

    createRuntimeObjects(airbase)
    log("INFO", "END result=ACTIVE")
    return nil
  end

  timer.scheduleFunction(function()
    local ok, err = pcall(run)
    if not ok then
      log("ERROR", "Unhandled error: " .. tostring(err))
    end
    return nil
  end, nil, timer.getTime() + START_DELAY_SECONDS)
end
