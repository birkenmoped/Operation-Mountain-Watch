-- Operation Mountain Watch - Jalalabad AH-64D squadron construction test
-- Validation stage only: constructs and links the squadron, but does not start the AIRWING.
local TAG = "[OMW][AirOps.JBAD.AH64D]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

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

  local templateName = cfg.Templates and cfg.Templates.AH64DCAS
  local template = templateName and GROUP:FindByName(templateName) or nil
  if not template then
    log("WAITING: AH-64D template missing: " .. tostring(templateName))
    return
  end

  local units = template:GetUnits() or {}
  local groupSize = #units
  if groupSize ~= 2 then
    log(string.format("ERROR: Template %s must contain exactly 2 units; found=%d", templateName, groupSize))
    return
  end

  for index, unit in ipairs(units) do
    local typeName = unit and unit:GetTypeName() or "nil"
    log(string.format("Template unit=%d name=%s type=%s", index, unit and unit:GetName() or "nil", tostring(typeName)))
    if typeName ~= "AH-64D_BLK_II" then
      log(string.format("ERROR: Template %s unit %d must be type AH-64D_BLK_II; found=%s", templateName, index, tostring(typeName)))
      return
    end
  end

  local aircraftCount = cfg.Inventory and cfg.Inventory.AH64D or 0
  if aircraftCount <= 0 or aircraftCount % groupSize ~= 0 then
    log(string.format("ERROR: Invalid AH-64D inventory=%s for groupSize=%d", tostring(aircraftCount), groupSize))
    return
  end

  local assetGroups = aircraftCount / groupSize
  local squadronName = "SQ_US_JBAD_AH64D_B_1_10_AVN"

  cfg.Squadrons = cfg.Squadrons or {}
  if cfg.Squadrons.AH64D then
    log("SKIP: AH-64D squadron already constructed in this mission run.")
    return
  end

  local ok, result = pcall(function()
    local squadron = SQUADRON:New(templateName, assetGroups, squadronName)
    squadron:SetGrouping(groupSize)
    squadron:AddMissionCapability({ AUFTRAG.Type.CAS }, 100)
    airwing:AddSquadron(squadron)
    return squadron
  end)

  if not ok or not result then
    log("ERROR: SQUADRON construction or AIRWING linking failed: " .. tostring(result))
    return
  end

  local linked = airwing:GetSquadron(squadronName)
  if linked ~= result then
    log("ERROR: AIRWING:GetSquadron did not return the constructed squadron.")
    return
  end

  cfg.Squadrons.AH64D = result
  log(string.format(
    "SQUADRON constructed and linked. name=%s aircraft=%d assetGroups=%d groupSize=%d capability=CAS. AIRWING not started.",
    squadronName,
    aircraftCount,
    assetGroups,
    groupSize
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 11)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 11)
end
