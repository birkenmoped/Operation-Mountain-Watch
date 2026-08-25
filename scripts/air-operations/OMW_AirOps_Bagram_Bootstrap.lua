-- Operation Mountain Watch - Bagram AIRWING/SQUADRON foundation.
--
-- Scope: dual AIRWING, seven SQUADRONs, inventory registration, grouping,
-- turnover, takeoff configuration, mission capabilities, role payloads,
-- validated Bagram parking policy and AIRWING start.
--
-- Deliberately excluded: COMMANDER, AUFTRAG instances, OPSTRANSPORT, F10/test
-- controls, tactical mission orchestration, recovery and persistence.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.BGRAM.Foundation]"
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

local function sameNumberSet(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" or #actual ~= #expected then
    return false
  end
  local seen = {}
  for _, id in ipairs(actual) do
    seen[id] = (seen[id] or 0) + 1
  end
  for _, id in ipairs(expected) do
    if not seen[id] then
      return false
    end
    seen[id] = seen[id] - 1
    if seen[id] == 0 then
      seen[id] = nil
    end
  end
  return next(seen) == nil
end

local config = {
  turnoverMin = 20,
  turnoverMax = 40,
  logicalAirframes = 83,
  representedAirframes = 81,
  logicalReserve = 2,

  -- Hard airbase-level exclusions. These are the currently authored Bagram
  -- client positions plus the two HAZ survey positions. SQUADRON parkingIDs
  -- are authoritative for the AIRWING asset path and intentionally do not
  -- include any of these IDs.
  parkingBlacklist = {
    111, -- A08 C-130 client
    21,  -- A09 C-130 client
    24,  -- M27 F-15E client
    158, -- M28 F-15E client
    114, -- M29 F-16C client
    145, -- M30 F-16C client
    88,  -- R21 CH-47 client
    85,  -- R22 CH-47 client
    188, -- HAZ01
    31,  -- HAZ02
  },

  usaf = {
    airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Bagram or "Bagram",
    warehouseName = "WH_AIR_US_BAGRAM",
    airwingName = "AW_US_BGRM_455_AEW",
  },
  army = {
    airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Bagram or "Bagram",
    warehouseName = "WH_AIR_US_BAGRAM_ARMY",
    airwingName = "AW_US_BGRM_TF_FALCON_10_CAB",
  },
  squadrons = {
    F15E = {
      wing = "usaf",
      name = "SQ_US_BGRM_F15E_335_EFS",
      template = "TPL_AIR_US_BGRM_F15E_CAS_2SHIP",
      assetGroups = 6,
      grouping = 2,
      logicalAircraft = 13,
      residualAircraft = 1,
      parkingLabels = "M01-M12",
      parkingIDs = { 121, 120, 1, 35, 190, 108, 27, 60, 103, 80, 16, 71 },
      missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.STRIKE },
      payloadTemplates = {
        "TPL_AIR_US_BGRM_F15E_CAS_2SHIP",
        "TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP",
      },
    },
    F16C = {
      wing = "usaf",
      name = "SQ_US_BGRM_F16C_121_EFS",
      template = "TPL_AIR_US_BGRM_F16C_CAS_2SHIP",
      assetGroups = 6,
      grouping = 2,
      logicalAircraft = 13,
      residualAircraft = 1,
      parkingLabels = "M13-M24",
      parkingIDs = { 183, 133, 119, 12, 117, 82, 64, 126, 137, 148, 159, 151 },
      missionTypes = { AUFTRAG.Type.CAS },
      payloadTemplates = { "TPL_AIR_US_BGRM_F16C_CAS_2SHIP" },
    },
    MQ1A = {
      wing = "usaf",
      name = "SQ_US_BGRM_MQ1A_62_ERS",
      template = "TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP",
      assetGroups = 8,
      grouping = 1,
      logicalAircraft = 8,
      residualAircraft = 0,
      parkingLabels = "B01-B08",
      parkingIDs = { 56, 40, 175, 22, 179, 9, 124, 123 },
      missionTypes = { AUFTRAG.Type.RECON },
      payloadTemplates = { "TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP" },
    },
    C130 = {
      wing = "usaf",
      name = "SQ_US_BGRM_C130_774_EAS",
      template = "TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP",
      assetGroups = 20,
      grouping = 1,
      logicalAircraft = 20,
      residualAircraft = 0,
      parkingLabels = "A10,S01-S05",
      parkingIDs = { 4, 185, 125, 37, 97, 141 },
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP" },
    },
    HH60G = {
      wing = "usaf",
      name = "SQ_US_BGRM_HH60G_83_ERQS",
      template = "TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP",
      assetGroups = 6,
      grouping = 1,
      logicalAircraft = 6,
      residualAircraft = 0,
      parkingLabels = "R15-R16",
      parkingIDs = { 90, 0 },
      missionTypes = { AUFTRAG.Type.RESCUEHELO },
      payloadTemplates = { "TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP" },
    },
    UH60 = {
      wing = "army",
      name = "SQ_US_BGRM_UH60_A_1_169",
      template = "TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP",
      assetGroups = 10,
      grouping = 1,
      logicalAircraft = 10,
      residualAircraft = 0,
      parkingLabels = "R17-R18",
      parkingIDs = { 163, 96 },
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP" },
    },
    CH47 = {
      wing = "army",
      name = "SQ_US_BGRM_CH47_B_7_158",
      template = "TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP",
      assetGroups = 13,
      grouping = 1,
      logicalAircraft = 13,
      residualAircraft = 0,
      parkingLabels = "R19-R20",
      parkingIDs = { 164, 61 },
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP" },
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

local function validateParkingPolicy()
  local blacklisted = {}
  for _, terminalID in ipairs(config.parkingBlacklist) do
    if blacklisted[terminalID] then
      error("Duplicate Bagram parking blacklist TerminalID: " .. tostring(terminalID))
    end
    blacklisted[terminalID] = true
  end

  local assigned = {}
  for key, definition in pairs(config.squadrons) do
    if type(definition.parkingIDs) ~= "table" or #definition.parkingIDs == 0 then
      error("Missing parkingIDs for Bagram squadron: " .. tostring(key))
    end
    for _, terminalID in ipairs(definition.parkingIDs) do
      if blacklisted[terminalID] then
        error(string.format("Bagram squadron %s includes blacklisted TerminalID %d", key, terminalID))
      end
      if assigned[terminalID] then
        error(string.format("Bagram TerminalID %d assigned to multiple squadrons: %s and %s", terminalID, assigned[terminalID], key))
      end
      assigned[terminalID] = key
    end
  end

  log(string.format("PARKING_POLICY_PRESTART status=PASS blacklist=%d assignedAI=%d", #config.parkingBlacklist, countTable(assigned)))
end

local function createAirwing(definition)
  local airbase = AIRBASE:FindByName(definition.airbaseName)
  if not airbase then
    error("Airbase not found: " .. tostring(definition.airbaseName))
  end

  airbase:SetParkingSpotBlacklist(config.parkingBlacklist)
  requireAnchor(definition.warehouseName)

  local airwing = AIRWING:New(definition.warehouseName, definition.airwingName)
  airwing:SetAirbase(airbase)
  airwing:SetTakeoffCold()
  return airbase, airwing
end

local function createSquadron(airwing, definition)
  requireTemplate(definition.template)

  local representedAircraft = definition.assetGroups * definition.grouping
  local residualAircraft = definition.logicalAircraft - representedAircraft
  if residualAircraft ~= definition.residualAircraft or residualAircraft < 0 then
    error("Inventory/grouping mismatch: " .. tostring(definition.name))
  end

  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
  squadron:SetTurnoverTime(config.turnoverMin, config.turnoverMax)
  squadron:SetParkingIDs(definition.parkingIDs)
  squadron:AddMissionCapability(definition.missionTypes)
  airwing:AddSquadron(squadron)

  local payloads = {}
  for _, payloadTemplate in ipairs(definition.payloadTemplates) do
    local seed = requireTemplate(payloadTemplate)
    payloads[#payloads + 1] = airwing:NewPayload(seed, -1, definition.missionTypes, 50)
  end

  log(string.format(
    "SQUADRON_REGISTERED name=%s wing=%s template=%s assetGroups=%d grouping=%d representedAircraft=%d logicalAircraft=%d residualAircraft=%d payloads=%d parkingLabels=%s parkingIDs=%d",
    definition.name,
    definition.wing,
    definition.template,
    definition.assetGroups,
    definition.grouping,
    representedAircraft,
    definition.logicalAircraft,
    residualAircraft,
    #payloads,
    definition.parkingLabels,
    #definition.parkingIDs
  ))

  return squadron, payloads, representedAircraft, residualAircraft
end

local function constructFoundation()
  log("BEGIN Bagram dual-AIRWING/SQUADRON initialization with parking policy")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not AIRWING or not SQUADRON or not GROUP or not AIRBASE or not AUFTRAG then
    error("Required MOOSE AIRWING/SQUADRON foundation classes are unavailable")
  end

  if config.usaf.warehouseName == config.army.warehouseName then
    error("Bagram dual-AIRWING foundation requires distinct Warehouse anchors")
  end

  validateParkingPolicy()

  local usafAirbase, usafAirwing = createAirwing(config.usaf)
  local armyAirbase, armyAirwing = createAirwing(config.army)

  local squadrons = {}
  local payloads = {}
  local registeredGroups = 0
  local representedAircraft = 0
  local logicalAircraft = 0
  local logicalReserve = 0
  local rolePayloads = 0

  for _, key in ipairs({ "F15E", "F16C", "MQ1A", "C130", "HH60G", "UH60", "CH47" }) do
    local definition = config.squadrons[key]
    local airwing = definition.wing == "usaf" and usafAirwing or armyAirwing
    local squadron, squadronPayloads, represented, residual = createSquadron(airwing, definition)
    squadrons[key] = squadron
    payloads[key] = squadronPayloads
    registeredGroups = registeredGroups + definition.assetGroups
    representedAircraft = representedAircraft + represented
    logicalAircraft = logicalAircraft + definition.logicalAircraft
    logicalReserve = logicalReserve + residual
    rolePayloads = rolePayloads + #squadronPayloads
  end

  if representedAircraft ~= config.representedAirframes then
    error("Represented airframe total mismatch")
  end
  if logicalAircraft ~= config.logicalAirframes then
    error("Logical airframe total mismatch")
  end
  if logicalReserve ~= config.logicalReserve then
    error("Logical reserve total mismatch")
  end

  log("SQUADRON_STOCK_PRESTART usafAirwingStockEntries=" .. tostring(countTable(usafAirwing.stock)))
  log("SQUADRON_STOCK_PRESTART armyAirwingStockEntries=" .. tostring(countTable(armyAirwing.stock)))

  OMW.AirOps.Bagram = {
    Status = "FOUNDATION_READY",
    Airbases = { USAF = usafAirbase, Army = armyAirbase },
    Airwings = { USAF = usafAirwing, Army = armyAirwing },
    Squadrons = squadrons,
    Payloads = payloads,
    Config = config,
    Scope = "AIRWING_SQUADRON_FOUNDATION_WITH_PARKING_POLICY",
    RegisteredGroups = registeredGroups,
    RepresentedAirframes = representedAircraft,
    LogicalAirframes = logicalAircraft,
    LogicalReserve = logicalReserve,
    RolePayloads = rolePayloads,
  }

  usafAirwing:Start()
  armyAirwing:Start()
  OMW.AirOps.Bagram.Status = "RUNNING"
end

local function inspectIdleFoundation()
  local state = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  if not state or not state.Airwings or not state.Airwings.USAF or not state.Airwings.Army then
    error("Bagram foundation state is unavailable after AIRWING start")
  end

  local usafRunning = state.Airwings.USAF.IsRunning and state.Airwings.USAF:IsRunning() or false
  local armyRunning = state.Airwings.Army.IsRunning and state.Airwings.Army:IsRunning() or false
  local parkingAssetsChecked = 0
  local parkingAssetsFailed = 0

  for key, squadron in pairs(state.Squadrons) do
    local definition = state.Config.squadrons[key]
    for _, asset in pairs(squadron.assets or {}) do
      parkingAssetsChecked = parkingAssetsChecked + 1
      if not sameNumberSet(asset.parkingIDs, definition.parkingIDs) then
        parkingAssetsFailed = parkingAssetsFailed + 1
        env.error(string.format("%s PARKING_ASSET status=FAIL squadron=%s asset=%s", TAG, definition.name, tostring(asset.uid or asset.spawngroupname or "unknown")), false)
      end
    end
  end

  local parkingStatus = parkingAssetsFailed == 0 and parkingAssetsChecked == state.RegisteredGroups and "PASS" or "FAIL"
  log(string.format("PARKING_POLICY_POSTSTART status=%s assetsChecked=%d expectedAssets=%d failed=%d", parkingStatus, parkingAssetsChecked, state.RegisteredGroups, parkingAssetsFailed))

  if parkingStatus ~= "PASS" then
    error("Bagram parking policy did not propagate to all AIRWING assets")
  end

  log(string.format(
    "RESULT status=%s airwings=2 squadrons=7 registeredGroups=%d representedAirframes=%d logicalAirframes=%d logicalReserve=%d rolePayloads=%d usafRunning=%s armyRunning=%s parkingPolicy=PASS parkingAssetsChecked=%d missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false",
    tostring(state.Status),
    tonumber(state.RegisteredGroups) or -1,
    tonumber(state.RepresentedAirframes) or -1,
    tonumber(state.LogicalAirframes) or -1,
    tonumber(state.LogicalReserve) or -1,
    tonumber(state.RolePayloads) or -1,
    tostring(usafRunning),
    tostring(armyRunning),
    parkingAssetsChecked
  ))
end

local ok, err = pcall(function()
  constructFoundation()
  inspectIdleFoundation()
end)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.AirOps.Bagram = OMW.AirOps.Bagram or {}
  OMW.AirOps.Bagram.Status = "ERROR"
  OMW.AirOps.Bagram.Error = tostring(err)
end
