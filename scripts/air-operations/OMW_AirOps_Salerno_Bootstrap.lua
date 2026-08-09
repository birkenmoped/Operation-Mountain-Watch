-- Operation Mountain Watch - FOB Salerno AIRWING/SQUADRON foundation.
--
-- Scope: AIRWING, SQUADRON, mission capabilities and payload registration.
-- Parking mutation remains deferred by the binding Salerno manifest.
-- No F10 controls, test missions, AUFTRAG instances, OPSTRANSPORT instances or COMMANDER.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.SAL.Foundation]"
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
  airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.FOB_Salerno or "FOB Salerno",
  warehouseName = "WH_AIR_US_SALERNO",
  airwingName = "AW_US_SALERNO",
  turnoverMin = 20,
  turnoverMax = 40,
  parkingState = "DEFERRED",
  squadrons = {
    AH64D = {
      name = "SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK",
      template = "TPL_AIR_US_SAL_AH64D_CAS_2SHIP",
      assetGroups = 4,
      grouping = 2,
      missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED, AUFTRAG.Type.ESCORT },
    },
    OH58D = {
      name = "SQ_US_SAL_OH58D_B_6_6_CAV",
      template = "TPL_AIR_US_SAL_OH58D_RECON_2SHIP",
      assetGroups = 4,
      grouping = 2,
      missionTypes = { AUFTRAG.Type.RECON, AUFTRAG.Type.FACA, AUFTRAG.Type.ESCORT },
    },
    UH60_ASSAULT = {
      name = "SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT",
      template = "TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP",
      assetGroups = 3,
      grouping = 2,
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
    },
    UH60_MEDEVAC = {
      name = "SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN",
      template = "TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP",
      assetGroups = 3,
      grouping = 1,
      missionTypes = { AUFTRAG.Type.RESCUEHELO, AUFTRAG.Type.CARGOTRANSPORT },
    },
    CH47 = {
      name = "SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT",
      template = "TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP",
      assetGroups = 6,
      grouping = 1,
      missionTypes = { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
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

local function createSquadron(airwing, definition)
  local seed = requireTemplate(definition.template)
  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
  squadron:SetTurnoverTime(config.turnoverMin, config.turnoverMax)
  squadron:AddMissionCapability(definition.missionTypes)
  airwing:AddSquadron(squadron)

  local payload = airwing:NewPayload(seed, -1, definition.missionTypes, 50)

  log(string.format(
    "SQUADRON_REGISTERED name=%s template=%s assetGroups=%d grouping=%d representedAircraft=%d payloads=1 parkingState=%s",
    definition.name,
    definition.template,
    definition.assetGroups,
    definition.grouping,
    definition.assetGroups * definition.grouping,
    config.parkingState
  ))

  return squadron, payload
end

local function constructFoundation()
  log("BEGIN foundation-only Salerno AIRWING/SQUADRON initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not AIRWING or not SQUADRON or not GROUP or not AIRBASE or not AUFTRAG then
    error("Required MOOSE AIRWING/SQUADRON foundation classes are unavailable")
  end

  local airbase = AIRBASE:FindByName(config.airbaseName)
  if not airbase then
    error("FOB Salerno airbase not found")
  end

  local anchor = (STATIC and STATIC:FindByName(config.warehouseName, false))
    or (UNIT and UNIT:FindByName(config.warehouseName))
  if not anchor then
    error("Warehouse anchor not found: " .. config.warehouseName)
  end

  local airwing = AIRWING:New(config.warehouseName, config.airwingName)
  airwing:SetAirbase(airbase)
  airwing:SetTakeoffCold()

  local squadrons = {}
  local payloads = {}
  local registeredGroups = 0
  local representedAircraft = 0

  for _, key in ipairs({ "AH64D", "OH58D", "UH60_ASSAULT", "UH60_MEDEVAC", "CH47" }) do
    local definition = config.squadrons[key]
    local squadron, payload = createSquadron(airwing, definition)
    squadrons[key] = squadron
    payloads[key] = payload
    registeredGroups = registeredGroups + definition.assetGroups
    representedAircraft = representedAircraft + (definition.assetGroups * definition.grouping)
  end

  -- Lifecycle diagnostic only: pre-start Warehouse stock is observed but not
  -- used as an acceptance condition or as strategic inventory authority.
  log("SQUADRON_STOCK_PRESTART airwingStockEntries=" .. tostring(countTable(airwing.stock)))

  OMW.AirOps.Salerno = {
    Status = "FOUNDATION_READY",
    Airbase = airbase,
    Airwing = airwing,
    Squadrons = squadrons,
    Payloads = payloads,
    Config = config,
    Scope = "AIRWING_SQUADRON_FOUNDATION_ONLY",
    RegisteredGroups = registeredGroups,
    RepresentedAircraft = representedAircraft,
  }

  airwing:Start()
  OMW.AirOps.Salerno.Status = "RUNNING"
end

local function inspectIdleFoundation()
  local state = OMW and OMW.AirOps and OMW.AirOps.Salerno or nil
  if not state or not state.Airwing then
    error("Salerno foundation state is unavailable after AIRWING start")
  end

  log(string.format(
    "RESULT status=%s airwings=1 squadrons=5 registeredGroups=%d representedAircraft=%d logicalAircraft=32 logicalReserve=1 rolePayloads=5 parkingState=DEFERRED missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false",
    tostring(state.Status),
    tonumber(state.RegisteredGroups) or -1,
    tonumber(state.RepresentedAircraft) or -1
  ))
end

local ok, err = pcall(function()
  constructFoundation()
  inspectIdleFoundation()
end)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.AirOps.Salerno = OMW.AirOps.Salerno or {}
  OMW.AirOps.Salerno.Status = "ERROR"
  OMW.AirOps.Salerno.Error = tostring(err)
end
