-- Operation Mountain Watch - Kandahar AIRWING/SQUADRON foundation.
--
-- Scope: dual AIRWING, nine SQUADRONs, inventory registration, grouping,
-- turnover, takeoff configuration, mission capabilities, approved role payloads,
-- parking allocation, and AIRWING start.
--
-- Deliberately excluded: COMMANDER, AUFTRAG instances, OPSTRANSPORT, F10/test
-- controls, tactical mission orchestration, recovery, persistence and dispatch.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.Foundation]"
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

local config = {
  turnoverMin = 20,
  turnoverMax = 40,
  registeredAirframes = 112,
  deferredMC12 = 6,
  deferredRolePayloads = 2,
  main = {
    airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar or "Kandahar",
    warehouseName = "WH_AIR_US_KANDAHAR",
    airwingName = "AW_US_KAF_451_AEW",
    expectedParkingSpots = 316,
    expectedBlacklistSpots = 247,
    parkingWhitelist = {
      189, 303, 202, 224, 46, 291, 129, 143, 27, 54, 263,
      309, 232, 107, 260, 299, 194, 294, 92, 201, 174, 156, 124, 238, 280, 28, 16, 40, 136, 281, 314, 25, 229,
      66, 190, 111, 158, 73, 14, 60, 274, 145, 191, 168, 125,
      247, 177, 8, 11, 141, 59, 109, 88, 237, 266, 49, 268, 270, 179, 20, 69, 91, 43, 287, 282, 278, 63, 313, 51,
    },
  },
  heliport = {
    airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar_Heliport or "Kandahar Heliport",
    warehouseName = "WH_AIR_US_KANDAHAR_HELI",
    airwingName = "AW_US_KAF_159_CAB_TF_THUNDER",
    expectedParkingSpots = 86,
    expectedBlacklistSpots = 0,
    parkingWhitelist = {
      80, 79, 73, 39, 3, 24, 28, 34, 62, 57, 23, 85, 78, 51, 33, 35, 10, 63, 0,
      13, 12, 75, 54, 76, 69, 29, 43, 7, 53, 19, 86, 83, 87, 20, 55, 49, 74, 30, 64, 71, 67, 59, 11, 50, 36,
      60, 52, 9, 22, 31, 21, 61, 42, 72, 41, 84, 8, 32, 15, 46, 56, 27, 66, 82, 17, 1, 6, 37, 68, 40, 16, 14, 26, 65,
      4, 25, 18, 81, 58, 38, 45, 47, 2, 70, 5, 48,
    },
  },
  squadrons = {
    A10C = {
      wing = "main",
      name = "SQ_US_KAF_A10C_74_EFS",
      template = "TPL_AIR_US_KAF_A10C_CAS_2SHIP",
      assetGroups = 8,
      grouping = 2,
      logicalAircraft = 16,
      parkingIDs = { 247, 177, 8, 11, 141, 59, 109, 88, 237, 266, 49, 268, 270, 179, 20, 69, 91, 43, 287, 282, 278, 63, 313, 51 },
      missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED },
      payloadTemplates = { "TPL_AIR_US_KAF_A10C_CAS_2SHIP" },
    },
    HH60G = {
      wing = "main",
      name = "SQ_US_KAF_HH60G_26_ERQS",
      template = "TPL_AIR_US_KAF_HH60G_CSAR_1SHIP",
      assetGroups = 6,
      grouping = 1,
      logicalAircraft = 6,
      parkingIDs = { 66, 190, 111, 158, 73, 14, 60, 274, 145, 191, 168, 125 },
      missionTypes = { AUFTRAG.Type.RESCUEHELO, AUFTRAG.Type.CARGOTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_KAF_HH60G_CSAR_1SHIP" },
    },
    C130 = {
      wing = "main",
      name = "SQ_US_KAF_C130_772_EAS",
      template = "TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP",
      assetGroups = 12,
      grouping = 1,
      logicalAircraft = 12,
      parkingIDs = { 309, 232, 107, 260, 299, 194, 294, 92, 201, 174, 156, 124, 238, 280, 28, 16, 40, 136, 281, 314, 25, 229 },
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP" },
    },
    MQ1 = {
      wing = "main",
      name = "SQ_US_KAF_MQ1_361_ERS",
      template = "TPL_AIR_US_KAF_MQ1A_RECON_1SHIP",
      assetGroups = 4,
      grouping = 1,
      logicalAircraft = 4,
      parkingIDs = { 189, 303, 202, 224, 46, 291, 129, 143, 27, 54, 263 },
      missionTypes = { AUFTRAG.Type.RECON },
      payloadTemplates = {},
      payloadState = "DEFERRED_ISR_PAYLOAD_RECONCILIATION",
    },
    MQ9 = {
      wing = "main",
      name = "SQ_US_KAF_MQ9_361_ERS",
      template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
      assetGroups = 2,
      grouping = 1,
      logicalAircraft = 2,
      parkingIDs = { 189, 303, 202, 224, 46, 291, 129, 143, 27, 54, 263 },
      missionTypes = { AUFTRAG.Type.RECON },
      payloadTemplates = {},
      payloadState = "DEFERRED_ISR_PAYLOAD_RECONCILIATION",
    },
    AH64D = {
      wing = "heliport",
      name = "SQ_US_KAF_AH64_4_227_AVN",
      template = "TPL_AIR_US_KAF_AH64D_CAS_2SHIP",
      assetGroups = 4,
      grouping = 2,
      logicalAircraft = 8,
      parkingIDs = { 13, 12, 75, 54, 76, 69, 29, 43, 7, 53, 19, 86, 83, 87, 20, 55, 49, 74, 30, 64, 71, 67, 59, 11, 50, 36 },
      missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED, AUFTRAG.Type.ESCORT },
      payloadTemplates = { "TPL_AIR_US_KAF_AH64D_CAS_2SHIP" },
    },
    OH58D = {
      wing = "heliport",
      name = "SQ_US_KAF_OH58D_7_17_CAV",
      template = "TPL_AIR_US_KAF_OH58D_RECON_2SHIP",
      assetGroups = 8,
      grouping = 2,
      logicalAircraft = 16,
      parkingIDs = { 80, 79, 73, 39, 3, 24, 28, 34, 62, 57, 23, 85, 78, 51, 33, 35, 10, 63, 0 },
      missionTypes = { AUFTRAG.Type.RECON, AUFTRAG.Type.FACA, AUFTRAG.Type.ESCORT },
      payloadTemplates = { "TPL_AIR_US_KAF_OH58D_RECON_2SHIP" },
    },
    CH47 = {
      wing = "heliport",
      name = "SQ_US_KAF_CH47_7_101_GSAB",
      template = "TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP",
      assetGroups = 16,
      grouping = 1,
      logicalAircraft = 16,
      parkingIDs = { 4, 25, 18, 81, 58, 38, 45, 47, 2, 70, 5, 48 },
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP" },
    },
    UH60 = {
      wing = "heliport",
      name = "SQ_US_KAF_UH60_7_101_GSAB",
      template = "TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP",
      assetGroups = 16,
      grouping = 2,
      logicalAircraft = 32,
      parkingIDs = { 60, 52, 9, 22, 31, 21, 61, 42, 72, 41, 84, 8, 32, 15, 46, 56, 27, 66, 82, 17, 1, 6, 37, 68, 40, 16, 14, 26, 65 },
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT, AUFTRAG.Type.RESCUEHELO },
      payloadTemplates = {
        "TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP",
        "TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP",
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

local function applyParkingPolicy(airbase, definition)
  local allowed = {}
  for _, terminalID in ipairs(definition.parkingWhitelist) do
    if allowed[terminalID] then
      error("Duplicate parking whitelist TerminalID " .. tostring(terminalID) .. " at " .. tostring(definition.airbaseName))
    end
    allowed[terminalID] = true
  end

  local parkingSpots = airbase:GetParkingSpotsTable()
  if #parkingSpots ~= definition.expectedParkingSpots then
    error(string.format(
      "Parking schema mismatch at %s: expected=%d actual=%d",
      tostring(definition.airbaseName),
      definition.expectedParkingSpots,
      #parkingSpots
    ))
  end

  local present = {}
  local blacklist = {}
  for _, parkingSpot in ipairs(parkingSpots) do
    present[parkingSpot.TerminalID] = true
    if not allowed[parkingSpot.TerminalID] then
      blacklist[#blacklist + 1] = parkingSpot.TerminalID
    end
  end

  for _, terminalID in ipairs(definition.parkingWhitelist) do
    if not present[terminalID] then
      error("Configured parking TerminalID not present at " .. tostring(definition.airbaseName) .. ": " .. tostring(terminalID))
    end
  end

  if #blacklist ~= definition.expectedBlacklistSpots then
    error(string.format(
      "Parking blacklist size mismatch at %s: expected=%d actual=%d",
      tostring(definition.airbaseName),
      definition.expectedBlacklistSpots,
      #blacklist
    ))
  end

  airbase:SetParkingSpotWhitelist(definition.parkingWhitelist)
  airbase:SetParkingSpotBlacklist(blacklist)

  log(string.format(
    "PARKING_POLICY airbase=%s total=%d whitelist=%d blacklist=%d",
    tostring(definition.airbaseName),
    #parkingSpots,
    #definition.parkingWhitelist,
    #blacklist
  ))
end

local function createAirwing(definition)
  local airbase = AIRBASE:FindByName(definition.airbaseName)
  if not airbase then
    error("Airbase not found: " .. tostring(definition.airbaseName))
  end

  applyParkingPolicy(airbase, definition)
  requireAnchor(definition.warehouseName)

  local airwing = AIRWING:New(definition.warehouseName, definition.airwingName)
  airwing:SetAirbase(airbase)
  airwing:SetTakeoffCold()
  return airbase, airwing
end

local function createSquadron(airwing, definition)
  requireTemplate(definition.template)

  if definition.assetGroups * definition.grouping ~= definition.logicalAircraft then
    error("Inventory/grouping mismatch: " .. tostring(definition.name))
  end

  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
  squadron:SetParkingIDs(definition.parkingIDs)
  squadron:SetTurnoverTime(config.turnoverMin, config.turnoverMax)
  squadron:AddMissionCapability(definition.missionTypes)
  airwing:AddSquadron(squadron)

  local payloads = {}
  for _, payloadTemplate in ipairs(definition.payloadTemplates) do
    local seed = requireTemplate(payloadTemplate)
    payloads[#payloads + 1] = airwing:NewPayload(seed, -1, definition.missionTypes, 50)
  end

  log(string.format(
    "SQUADRON_REGISTERED name=%s wing=%s template=%s assetGroups=%d grouping=%d logicalAircraft=%d parkingIDs=%d payloads=%d payloadState=%s",
    definition.name,
    definition.wing,
    definition.template,
    definition.assetGroups,
    definition.grouping,
    definition.logicalAircraft,
    #definition.parkingIDs,
    #payloads,
    tostring(definition.payloadState or "REGISTERED")
  ))

  return squadron, payloads
end

local function constructFoundation()
  log("BEGIN foundation-only Kandahar AIRWING/SQUADRON initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not AIRWING or not SQUADRON or not GROUP or not AIRBASE or not AUFTRAG then
    error("Required MOOSE AIRWING/SQUADRON foundation classes are unavailable")
  end

  local mainAirbase, mainAirwing = createAirwing(config.main)
  local heliportAirbase, heliportAirwing = createAirwing(config.heliport)

  local squadrons = {}
  local payloads = {}
  local registeredGroups = 0
  local logicalAircraft = 0
  local rolePayloads = 0

  for _, key in ipairs({ "A10C", "HH60G", "C130", "MQ1", "MQ9", "AH64D", "OH58D", "CH47", "UH60" }) do
    local definition = config.squadrons[key]
    local airwing = definition.wing == "main" and mainAirwing or heliportAirwing
    local squadron, squadronPayloads = createSquadron(airwing, definition)
    squadrons[key] = squadron
    payloads[key] = squadronPayloads
    registeredGroups = registeredGroups + definition.assetGroups
    logicalAircraft = logicalAircraft + definition.logicalAircraft
    rolePayloads = rolePayloads + #squadronPayloads
  end

  if logicalAircraft ~= config.registeredAirframes then
    error("Registered airframe total mismatch")
  end

  log("SQUADRON_STOCK_PRESTART mainAirwingStockEntries=" .. tostring(countTable(mainAirwing.stock)))
  log("SQUADRON_STOCK_PRESTART heliportAirwingStockEntries=" .. tostring(countTable(heliportAirwing.stock)))

  OMW.AirOps.Kandahar = {
    Status = "FOUNDATION_READY",
    Airbases = { Main = mainAirbase, Heliport = heliportAirbase },
    Airwings = { Main = mainAirwing, Heliport = heliportAirwing },
    Squadrons = squadrons,
    Payloads = payloads,
    Config = config,
    Scope = "AIRWING_SQUADRON_FOUNDATION_ONLY",
    RegisteredGroups = registeredGroups,
    RegisteredAirframes = logicalAircraft,
    RolePayloads = rolePayloads,
  }

  mainAirwing:Start()
  heliportAirwing:Start()
  OMW.AirOps.Kandahar.Status = "RUNNING"
end

local function inspectIdleFoundation()
  local state = OMW and OMW.AirOps and OMW.AirOps.Kandahar or nil
  if not state or not state.Airwings or not state.Airwings.Main or not state.Airwings.Heliport then
    error("Kandahar foundation state is unavailable after AIRWING start")
  end

  local mainRunning = state.Airwings.Main.IsRunning and state.Airwings.Main:IsRunning() or false
  local heliportRunning = state.Airwings.Heliport.IsRunning and state.Airwings.Heliport:IsRunning() or false

  log(string.format(
    "RESULT status=%s airwings=2 squadrons=9 registeredGroups=%d registeredAirframes=%d deferredMC12=6 rolePayloads=%d deferredRolePayloads=2 mainRunning=%s heliportRunning=%s missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false",
    tostring(state.Status),
    tonumber(state.RegisteredGroups) or -1,
    tonumber(state.RegisteredAirframes) or -1,
    tonumber(state.RolePayloads) or -1,
    tostring(mainRunning),
    tostring(heliportRunning)
  ))
end

local ok, err = pcall(function()
  constructFoundation()
  inspectIdleFoundation()
end)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.AirOps.Kandahar = OMW.AirOps.Kandahar or {}
  OMW.AirOps.Kandahar.Status = "ERROR"
  OMW.AirOps.Kandahar.Error = tostring(err)
end