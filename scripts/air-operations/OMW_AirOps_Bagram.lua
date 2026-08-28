-- Operation Mountain Watch - Bagram AIRWING/SQUADRON production base.
--
-- Scope: dual AIRWING, seven SQUADRONs, inventory registration, grouping,
-- turnover, takeoff configuration, mission capabilities, role payloads,
-- owner-authored Bagram parking policy, and AIRWING start.
--
-- Parking authority: docs/data/bagram-parking-policy.csv.
-- Only rows with Status=AI are eligible for MOOSE AIRWING parking.
-- Rows marked Static, Client, or BLOCKED are excluded at airbase level.
--
-- Deliberately excluded: COMMANDER, AUFTRAG instances, OPSTRANSPORT, F10/test
-- controls, tactical mission orchestration, recovery and persistence.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.BGRAM]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"
local PARKING_POLICY_SOURCE = "docs/data/bagram-parking-policy.csv"

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

  -- Exact complement of the 69 owner-authored Status=AI rows.
  -- Static, Client, and BLOCKED rows are never eligible for MOOSE AIRWING parking.
  parkingBlacklist = { 66, 2, 41, 92, 149, 52, 102, 111, 21, 4, 56, 40, 175, 22, 179, 9, 124, 123, 109, 23, 136, 105, 58, 140, 154, 93, 115, 169, 33, 25, 81, 44, 142, 19, 6, 91, 83, 162, 112, 184, 63, 94, 129, 131, 170, 75, 134, 186, 29, 48, 10, 101, 34, 107, 165, 62, 32, 14, 20, 168, 13, 178, 160, 3, 116, 49, 55, 130, 78, 110, 177, 99, 43, 166, 28, 155, 188, 31, 121, 120, 35, 27, 16, 71, 82, 64, 126, 159, 151, 24, 158, 114, 145, 30, 173, 47, 139, 11, 106, 90, 0, 88, 85, 135, 122, 59, 26, 72, 8, 161, 185, 125, 141, 171, 53, 73, 113, 100 },

  parkingProfiles = {
    F15E = {
      csvAsset = "F-15E",
      parkingLabels = "E01, E02, E03, E04, E05, M03, M05, M06, M08, M09, M10, M21, M22, M25, M26",
      parkingIDs = { 189, 157, 138, 39, 84, 1, 190, 108, 60, 103, 80, 137, 148, 128, 42 },
    },
    F16C = {
      csvAsset = "F-16",
      parkingLabels = "M13, M14, M15, M16, M17",
      parkingIDs = { 183, 133, 119, 12, 117 },
    },
    MQ1A = {
      csvAsset = "MQ-1A",
      parkingLabels = "N09, N10, N11",
      parkingIDs = { 50, 180, 152 },
    },
    C130 = {
      csvAsset = "C-130J-30",
      parkingLabels = "S03, S04",
      parkingIDs = { 37, 97 },
    },
    UH60 = {
      csvAsset = "UH-60",
      parkingLabels = "N01, N02, N03, N04, N05, N06, N07, N08, P01, P02, P03, P04, P07, P08, P09, P10, P11, P12, P13, P14, R01, R02, R03, R04, R05, R06, R07, R26, R28, R29, R31, R32, R33, R34, R35",
      parkingIDs = { 79, 51, 57, 187, 15, 68, 181, 7, 76, 132, 38, 174, 176, 150, 146, 17, 89, 70, 143, 5, 95, 46, 167, 127, 65, 45, 54, 118, 74, 87, 147, 18, 77, 36, 153 },
    },
    CH47 = {
      csvAsset = "CH-47F",
      parkingLabels = "R08, R09, R10, R13, R14, R17, R18, R19, R20",
      parkingIDs = { 144, 104, 182, 172, 67, 163, 96, 164, 61 },
    },
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
      parkingProfile = "F15E",
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
      parkingProfile = "F16C",
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
      parkingProfile = "MQ1A",
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
      parkingProfile = "C130",
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
      -- DCS represents this OMW HH-60G seed as UH-60A, so it uses the
      -- owner-authored CSV Asset=UH-60 parking compatibility profile.
      parkingProfile = "UH60",
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
      parkingProfile = "UH60",
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
      parkingProfile = "CH47",
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
      payloadTemplates = { "TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP" },
    },
  },
}

local parkingValidation = {
  expectedAssets = 69,
  assetsChecked = 0,
  failed = 0,
  seen = {},
  completed = false,
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

local function getSquadronDefinition(name)
  for _, definition in pairs(config.squadrons) do
    if definition.name == name then
      return definition
    end
  end
  return nil
end

local function getParkingProfile(definition)
  local profile = definition and config.parkingProfiles[definition.parkingProfile] or nil
  if not profile then
    error("Missing Bagram parking profile for squadron: " .. tostring(definition and definition.name or "unknown"))
  end
  return profile
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
  for profileName, profile in pairs(config.parkingProfiles) do
    if type(profile.parkingIDs) ~= "table" or #profile.parkingIDs == 0 then
      error("Missing parkingIDs for Bagram parking profile: " .. tostring(profileName))
    end
    for _, terminalID in ipairs(profile.parkingIDs) do
      if blacklisted[terminalID] then
        error(string.format("Bagram parking profile %s includes excluded TerminalID %d", profileName, terminalID))
      end
      if assigned[terminalID] then
        error(string.format("Bagram TerminalID %d assigned to multiple CSV asset profiles: %s and %s", terminalID, assigned[terminalID], profileName))
      end
      assigned[terminalID] = profileName
    end
  end

  if countTable(assigned) ~= 69 or #config.parkingBlacklist ~= 118 then
    error(string.format(
      "Bagram CSV parking partition mismatch: ai=%d excluded=%d expected=69/118",
      countTable(assigned),
      #config.parkingBlacklist
    ))
  end

  log(string.format(
    "PARKING_POLICY_PRESTART status=PASS source=%s csvRows=187 ai=69 excluded=118 assetProfiles=%d",
    PARKING_POLICY_SOURCE,
    countTable(config.parkingProfiles)
  ))
end

local function finalizeParkingValidation()
  if parkingValidation.completed or parkingValidation.assetsChecked < parkingValidation.expectedAssets then
    return
  end

  parkingValidation.completed = true
  local state = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  local parkingStatus = parkingValidation.failed == 0 and parkingValidation.assetsChecked == parkingValidation.expectedAssets and "PASS" or "FAIL"

  log(string.format(
    "PARKING_POLICY_POSTSTART status=%s assetsChecked=%d expectedAssets=%d failed=%d lifecycle=WAREHOUSE_NEWASSET",
    parkingStatus,
    parkingValidation.assetsChecked,
    parkingValidation.expectedAssets,
    parkingValidation.failed
  ))

  if not state then
    env.error(TAG .. " ERROR Bagram foundation state unavailable during NewAsset parking validation", false)
    return
  end

  if parkingStatus ~= "PASS" then
    state.Status = "ERROR"
    state.Error = "Bagram parking policy did not propagate to all AIRWING assets"
    env.error(TAG .. " ERROR " .. state.Error, false)
    return
  end

  local usafRunning = state.Airwings.USAF.IsRunning and state.Airwings.USAF:IsRunning() or false
  local armyRunning = state.Airwings.Army.IsRunning and state.Airwings.Army:IsRunning() or false

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
    parkingValidation.assetsChecked
  ))
end

local function validateNewAssetParking(asset, assignment)
  local squadronName = assignment ~= nil and assignment ~= "" and assignment or asset.assignment
  local definition = getSquadronDefinition(squadronName)
  if not definition then
    return
  end

  local uid = asset.uid or asset.spawngroupname
  if parkingValidation.seen[uid] then
    return
  end
  parkingValidation.seen[uid] = true
  parkingValidation.assetsChecked = parkingValidation.assetsChecked + 1

  local profile = getParkingProfile(definition)
  if not sameNumberSet(asset.parkingIDs, profile.parkingIDs) then
    parkingValidation.failed = parkingValidation.failed + 1
    env.error(string.format(
      "%s PARKING_ASSET status=FAIL squadron=%s profile=%s asset=%s",
      TAG,
      definition.name,
      definition.parkingProfile,
      tostring(uid or "unknown")
    ), false)
  end

  finalizeParkingValidation()
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

  function airwing:OnAfterNewAsset(From, Event, To, asset, assignment)
    validateNewAssetParking(asset, assignment)
  end

  return airbase, airwing
end

local function createSquadron(airwing, definition)
  requireTemplate(definition.template)

  local representedAircraft = definition.assetGroups * definition.grouping
  local residualAircraft = definition.logicalAircraft - representedAircraft
  if residualAircraft ~= definition.residualAircraft or residualAircraft < 0 then
    error("Inventory/grouping mismatch: " .. tostring(definition.name))
  end

  local profile = getParkingProfile(definition)
  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
  squadron:SetTurnoverTime(config.turnoverMin, config.turnoverMax)
  squadron:SetParkingIDs(profile.parkingIDs)
  squadron:AddMissionCapability(definition.missionTypes)
  airwing:AddSquadron(squadron)

  local payloads = {}
  for _, payloadTemplate in ipairs(definition.payloadTemplates) do
    local seed = requireTemplate(payloadTemplate)
    payloads[#payloads + 1] = airwing:NewPayload(seed, -1, definition.missionTypes, 50)
  end

  log(string.format(
    "SQUADRON_REGISTERED name=%s wing=%s template=%s assetGroups=%d grouping=%d representedAircraft=%d logicalAircraft=%d residualAircraft=%d payloads=%d parkingProfile=%s csvAsset=%s parkingLabels=%s parkingIDs=%d",
    definition.name,
    definition.wing,
    definition.template,
    definition.assetGroups,
    definition.grouping,
    representedAircraft,
    definition.logicalAircraft,
    residualAircraft,
    #payloads,
    definition.parkingProfile,
    profile.csvAsset,
    profile.parkingLabels,
    #profile.parkingIDs
  ))

  return squadron, payloads, representedAircraft, residualAircraft
end

local function constructFoundation()
  log("BEGIN Bagram dual-AIRWING/SQUADRON production initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)
  log("PARKING_POLICY source=" .. PARKING_POLICY_SOURCE)

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
  if registeredGroups ~= parkingValidation.expectedAssets then
    error("Parking validation expected asset count mismatch")
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
    Scope = "AIRWING_SQUADRON_BASE_WITH_OWNER_PARKING_POLICY",
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

  local expectedAssets = state.RegisteredGroups
  local observedAssets = 0
  local parkingProfilesReferenced = {}

  for key, squadron in pairs(state.Squadrons) do
    local definition = state.Config.squadrons[key]
    observedAssets = observedAssets + countTable(squadron.assets)
    parkingProfilesReferenced[definition.parkingProfile] = true
  end

  log(string.format(
    "PARKING_POLICY_POSTSTART status=PENDING assetsChecked=%d expectedAssets=%d failed=%d parkingProfiles=%d lifecycle=AWAITING_WAREHOUSE_NEWASSET",
    observedAssets,
    expectedAssets,
    parkingValidation.failed,
    countTable(parkingProfilesReferenced)
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
