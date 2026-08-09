-- Operation Mountain Watch - Tarinkot AIRWING/SQUADRON foundation.
--
-- Scope: AIRWING, SQUADRON, parking, mission capabilities and payload registration.
-- No F10 controls, test missions, AUFTRAG instances, OPSTRANSPORT instances or COMMANDER.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.TKOT.Foundation]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local config = {
  airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Tarinkot or "Tarinkot",
  warehouseName = "WH_AIR_US_TARINKOT",
  airwingName = "AW_US_TKOT_TF_ATTACK_3_101_AVN",
  squadrons = {
    AH64D = {
      name = "SQ_US_TKOT_AH64D_3_101_AVN",
      template = "TPL_AIR_US_TKOT_AH64D_CAS_2SHIP",
      assetGroups = 2,
      grouping = 2,
      parkingIDs = { 20, 19 },
      missionTypes = { AUFTRAG.Type.CAS },
    },
    UH60 = {
      name = "SQ_US_TKOT_UH60_TF_ATTACK",
      template = "TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP",
      assetGroups = 2,
      grouping = 1,
      parkingIDs = { 23, 27, 30 },
      missionTypes = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE,
        AUFTRAG.Type.GROUNDESCORT,
      },
    },
    CH47 = {
      name = "SQ_US_TKOT_CH47_B_1_52_AVN",
      template = "TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP",
      assetGroups = 1,
      grouping = 1,
      parkingIDs = { 32, 29, 10 },
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

local function createSquadron(airwing, definition)
  local template = requireTemplate(definition.template)
  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
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
    definition.assetGroups * definition.grouping,
    table.concat(definition.parkingIDs, ",")
  ))

  return squadron, payload
end

local function main()
  log("BEGIN foundation-only Tarinkot AIRWING/SQUADRON initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not AIRWING or not SQUADRON or not GROUP or not AIRBASE or not AUFTRAG then
    error("Required MOOSE AIRWING/SQUADRON foundation classes are unavailable")
  end

  local airbase = AIRBASE:FindByName(config.airbaseName)
  if not airbase then
    error("Tarinkot airbase not found")
  end

  local anchor = (STATIC and STATIC:FindByName(config.warehouseName, false))
    or (UNIT and UNIT:FindByName(config.warehouseName))
  if not anchor then
    error("Warehouse anchor not found: " .. config.warehouseName)
  end

  local airwing = AIRWING:New(config.warehouseName, config.airwingName)
  airwing:SetAirbase(airbase)
  airwing:SetMarker(false)
  airwing:SetTakeoffCold()
  airwing:SetSafeParkingOn()

  if not airwing.SetOptionPreferVerticalLanding then
    error("Pinned MOOSE AIRWING:SetOptionPreferVerticalLanding is unavailable")
  end
  airwing:SetOptionPreferVerticalLanding()

  local squadrons = {}
  local payloads = {}
  for _, key in ipairs({ "AH64D", "UH60", "CH47" }) do
    local squadron, payload = createSquadron(airwing, config.squadrons[key])
    squadrons[key] = squadron
    payloads[key] = payload
  end

  OMW.AirOps.Tarinkot = {
    Status = "FOUNDATION_READY",
    Airbase = airbase,
    Airwing = airwing,
    Squadrons = squadrons,
    Payloads = payloads,
    Config = config,
    Scope = "AIRWING_SQUADRON_FOUNDATION_ONLY",
  }

  airwing:Start()
  OMW.AirOps.Tarinkot.Status = "RUNNING"

  log("RESULT status=RUNNING airwings=1 squadrons=3 registeredGroups=5 aircraft=7 rolePayloads=3 missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false")
end

local ok, err = pcall(main)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.AirOps.Tarinkot = OMW.AirOps.Tarinkot or {}
  OMW.AirOps.Tarinkot.Status = "ERROR"
  OMW.AirOps.Tarinkot.Error = tostring(err)
end
