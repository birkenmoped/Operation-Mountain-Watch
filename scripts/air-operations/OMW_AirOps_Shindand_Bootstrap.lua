-- Operation Mountain Watch - Shindand Heliport AIRWING/SQUADRON foundation.
--
-- Scope: one AIRWING, three SQUADRONs, the owner-defined type-specific parking
-- pools, inventory registration, grouping, turnover, cold takeoff, vertical
-- preference, mission capabilities, role payloads and AIRWING start.
--
-- Deliberately excluded: COMMANDER, AUFTRAG instances, OPSTRANSPORT, F10/test
-- controls, tactical orchestration, recovery, persistence and CampaignState mutation.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.SHND.Foundation]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function countTable(value)
  local count = 0
  if type(value) == "table" then
    for _ in pairs(value) do
      count = count + 1
    end
  end
  return count
end

local function parkingIDsEqual(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" then
    return false
  end
  if #actual ~= #expected then
    return false
  end
  for index, value in ipairs(expected) do
    if actual[index] ~= value then
      return false
    end
  end
  return true
end

local config = {
  turnoverMin = 20,
  turnoverMax = 40,
  logicalAirframes = 20,
  representedAirframes = 20,
  logicalReserve = 0,
  airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Shindand_Heliport or "Shindand Heliport",
  warehouseName = "WH_AIR_US_SHINDAND_HELIPORT",
  airwingName = "AW_US_SHINDAND",
  squadrons = {
    AH64D = {
      name = "SQ_US_SHND_AH64D_ATTACK",
      template = "TPL_AIR_US_SHND_AH64D_CAS_2SHIP",
      assetGroups = 4,
      grouping = 2,
      logicalAircraft = 8,
      parkingIDs = { 21, 3, 34, 15 },
      missionTypes = { AUFTRAG.Type.CAS },
    },
    UH60 = {
      name = "SQ_US_SHND_UH60_UTILITY_MEDEVAC",
      template = "TPL_AIR_US_SHND_UH60_UTILITY_1SHIP",
      assetGroups = 8,
      grouping = 1,
      logicalAircraft = 8,
      parkingIDs = { 41, 18, 13, 20, 19 },
      missionTypes = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE,
        AUFTRAG.Type.GROUNDESCORT,
      },
    },
    CH47 = {
      name = "SQ_US_SHND_CH47_HEAVYLIFT",
      template = "TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP",
      assetGroups = 4,
      grouping = 1,
      logicalAircraft = 4,
      parkingIDs = { 30, 10, 23 },
      missionTypes = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE,
      },
    },
  },
}

local function requireTemplate(name)
  local group = GROUP and GROUP:FindByName(name) or nil
  if not group then
    error("Missing Mission Editor template: " .. tostring(name))
  end
  return group
end

local function requireAnchor(name)
  local anchor = (STATIC and STATIC:FindByName(name, false))
    or (UNIT and UNIT:FindByName(name))
  if not anchor then
    error("Warehouse anchor not found: " .. tostring(name))
  end
  return anchor
end

local function createSquadron(airwing, definition)
  local template = requireTemplate(definition.template)
  local representedAircraft = definition.assetGroups * definition.grouping
  if representedAircraft ~= definition.logicalAircraft then
    error("Inventory/grouping mismatch: " .. tostring(definition.name))
  end

  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
  squadron:SetTurnoverTime(config.turnoverMin, config.turnoverMax)
  squadron:SetParkingIDs(definition.parkingIDs)
  if AI and AI.Skill and AI.Skill.HIGH then
    squadron:SetSkill(AI.Skill.HIGH)
  end
  squadron:AddMissionCapability(definition.missionTypes, 100)
  airwing:AddSquadron(squadron)

  local payload = airwing:NewPayload(template, -1, definition.missionTypes, 100)

  log(string.format(
    "SQUADRON_REGISTERED name=%s template=%s assetGroups=%d grouping=%d aircraft=%d parkingIDs=%s payloads=1",
    definition.name,
    definition.template,
    definition.assetGroups,
    definition.grouping,
    representedAircraft,
    table.concat(definition.parkingIDs, ",")
  ))

  return squadron, payload, representedAircraft
end

local function constructFoundation()
  log("BEGIN foundation-only Shindand Heliport AIRWING/SQUADRON initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not AIRWING or not SQUADRON or not GROUP or not AIRBASE or not AUFTRAG or not SCHEDULER then
    error("Required MOOSE AIRWING/SQUADRON foundation classes are unavailable")
  end

  local airbase = AIRBASE:FindByName(config.airbaseName)
  if not airbase then
    error("Shindand Heliport airbase not found")
  end
  if airbase:GetName() ~= "Shindand Heliport" then
    error("Resolved unexpected airbase: " .. tostring(airbase:GetName()))
  end

  requireAnchor(config.warehouseName)

  local airwing = AIRWING:New(config.warehouseName, config.airwingName)
  airwing:SetAirbase(airbase)
  airwing:SetMarker(false)
  airwing:SetTakeoffCold()

  if not airwing.SetOptionPreferVerticalLanding then
    error("Pinned MOOSE AIRWING:SetOptionPreferVerticalLanding is unavailable")
  end
  airwing:SetOptionPreferVerticalLanding()

  local squadrons = {}
  local payloads = {}
  local registeredGroups = 0
  local representedAircraft = 0
  local logicalAircraft = 0

  for _, key in ipairs({ "AH64D", "UH60", "CH47" }) do
    local definition = config.squadrons[key]
    local squadron, payload, represented = createSquadron(airwing, definition)
    squadrons[key] = squadron
    payloads[key] = payload
    registeredGroups = registeredGroups + definition.assetGroups
    representedAircraft = representedAircraft + represented
    logicalAircraft = logicalAircraft + definition.logicalAircraft
  end

  if representedAircraft ~= config.representedAirframes then
    error("Represented airframe total mismatch")
  end
  if logicalAircraft ~= config.logicalAirframes then
    error("Logical airframe total mismatch")
  end

  log("SQUADRON_STOCK_PRESTART airwingStockEntries=" .. tostring(countTable(airwing.stock)))

  OMW.AirOps.Shindand = {
    Status = "FOUNDATION_READY",
    Airbase = airbase,
    Airwing = airwing,
    Squadrons = squadrons,
    Payloads = payloads,
    Config = config,
    Scope = "AIRWING_SQUADRON_FOUNDATION_ONLY",
    RegisteredGroups = registeredGroups,
    RepresentedAirframes = representedAircraft,
    LogicalAirframes = logicalAircraft,
    LogicalReserve = config.logicalReserve,
    RolePayloads = 3,
  }

  airwing:Start()
  OMW.AirOps.Shindand.Status = "RUNNING"
end

local function inspectIdleFoundation()
  local state = OMW and OMW.AirOps and OMW.AirOps.Shindand or nil
  if not state or not state.Airwing or not state.Squadrons then
    error("Shindand foundation state is unavailable after AIRWING start")
  end

  local running = state.Airwing.IsRunning and state.Airwing:IsRunning() or false
  local postStartValid = true

  for _, key in ipairs({ "AH64D", "UH60", "CH47" }) do
    local squadron = state.Squadrons[key]
    local contract = state.Config.squadrons[key]
    local expectedAssets = contract.assetGroups
    local actualAssets = countTable(squadron.assets)

    if actualAssets ~= expectedAssets then
      postStartValid = false
      log(string.format(
        "SQUADRON_ASSET_COUNT_MISMATCH name=%s expectedAssets=%d actualAssets=%d",
        contract.name,
        expectedAssets,
        actualAssets
      ))
    end

    local parkingValid = true
    if type(squadron.assets) == "table" then
      for _, asset in pairs(squadron.assets) do
        if not parkingIDsEqual(asset.parkingIDs, contract.parkingIDs) then
          parkingValid = false
          postStartValid = false
        end
      end
    end

    log(string.format(
      "SQUADRON_POSTSTART name=%s expectedAssets=%d actualAssets=%d parkingIDs=%s parkingSync=%s",
      contract.name,
      expectedAssets,
      actualAssets,
      table.concat(contract.parkingIDs, ","),
      tostring(parkingValid)
    ))
  end

  if not postStartValid then
    error("Shindand post-start SQUADRON asset/parking validation failed")
  end

  log(string.format(
    "RESULT status=%s airbase=%s airbaseID=%s airwings=1 squadrons=3 registeredGroups=%d representedAirframes=%d logicalAirframes=%d logicalReserve=%d rolePayloads=%d running=%s postStartAssetParkingSync=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false",
    tostring(state.Status),
    tostring(state.Airbase:GetName()),
    tostring(state.Airbase:GetID()),
    tonumber(state.RegisteredGroups) or -1,
    tonumber(state.RepresentedAirframes) or -1,
    tonumber(state.LogicalAirframes) or -1,
    tonumber(state.LogicalReserve) or -1,
    tonumber(state.RolePayloads) or -1,
    tostring(running)
  ))
end

local ok, err = pcall(constructFoundation)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.AirOps.Shindand = OMW.AirOps.Shindand or {}
  OMW.AirOps.Shindand.Status = "ERROR"
  OMW.AirOps.Shindand.Error = tostring(err)
else
  SCHEDULER:New(nil, function()
    local inspectOk, inspectErr = pcall(inspectIdleFoundation)
    if not inspectOk then
      env.error(TAG .. " ERROR " .. tostring(inspectErr), false)
      OMW.AirOps.Shindand.Status = "ERROR"
      OMW.AirOps.Shindand.Error = tostring(inspectErr)
    end
  end, {}, 12)
end
