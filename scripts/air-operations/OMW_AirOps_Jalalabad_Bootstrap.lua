-- Operation Mountain Watch - Jalalabad AIRWING/SQUADRON foundation.
--
-- Scope: AIRWING, SQUADRON, parking, mission capabilities and payload registration.
-- No F10 controls, test missions, AUFTRAG instances, OPSTRANSPORT instances or COMMANDER.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.JBAD.Foundation]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local config = {
  airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad",
  warehouseName = "WH_AIR_US_JALALABAD",
  airwingName = "AW_US_JALALABAD",
  parkingBlacklist = { 23, 35, 37, 49 },
  squadrons = {
    OH58D = {
      name = "SQ_US_JBAD_OH58D_6_6_CAV",
      template = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
      assetGroups = 12,
      grouping = 2,
      parkingIDs = { 19, 43, 6, 5, 48 },
      missionTypes = { AUFTRAG.Type.RECON },
      payloads = {
        { template = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP", missionTypes = { AUFTRAG.Type.RECON } },
      },
    },
    AH64D = {
      name = "SQ_US_JBAD_AH64D_B_1_10_AVN",
      template = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
      assetGroups = 4,
      grouping = 2,
      parkingIDs = { 26, 51, 11 },
      missionTypes = { AUFTRAG.Type.CAS },
      payloads = {
        { template = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP", missionTypes = { AUFTRAG.Type.CAS } },
      },
    },
    UH60 = {
      name = "SQ_US_JBAD_UH60_UTILITY_MEDEVAC",
      template = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
      assetGroups = 8,
      grouping = 1,
      parkingIDs = { 10, 8, 1 },
      missionTypes = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE,
        AUFTRAG.Type.GROUNDESCORT,
      },
      payloads = {
        {
          template = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
          missionTypes = {
            AUFTRAG.Type.TROOPTRANSPORT,
            AUFTRAG.Type.CARGOTRANSPORT,
            AUFTRAG.Type.LANDATCOORDINATE,
          },
        },
        {
          template = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP",
          missionTypes = { AUFTRAG.Type.GROUNDESCORT },
        },
      },
    },
    CH47 = {
      name = "SQ_US_JBAD_CH47_HEAVYLIFT",
      template = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP",
      assetGroups = 8,
      grouping = 1,
      parkingIDs = { 28, 44, 0, 41, 9, 25, 18, 42 },
      missionTypes = {
        AUFTRAG.Type.TROOPTRANSPORT,
        AUFTRAG.Type.CARGOTRANSPORT,
        AUFTRAG.Type.LANDATCOORDINATE,
      },
      payloads = {
        {
          template = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP",
          missionTypes = {
            AUFTRAG.Type.TROOPTRANSPORT,
            AUFTRAG.Type.CARGOTRANSPORT,
            AUFTRAG.Type.LANDATCOORDINATE,
          },
        },
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
  local seed = requireTemplate(definition.template)
  local squadron = SQUADRON:New(definition.template, definition.assetGroups, definition.name)
  squadron:SetGrouping(definition.grouping)
  squadron:SetParkingIDs(definition.parkingIDs)
  squadron:SetTakeoffCold()
  if AI and AI.Skill and AI.Skill.HIGH then
    squadron:SetSkill(AI.Skill.HIGH)
  end
  squadron:AddMissionCapability(definition.missionTypes, 100)
  airwing:AddSquadron(squadron)

  local payloads = {}
  for _, payloadDefinition in ipairs(definition.payloads) do
    local payloadTemplate = payloadDefinition.template == definition.template
      and seed
      or requireTemplate(payloadDefinition.template)
    payloads[#payloads + 1] = airwing:NewPayload(payloadTemplate, -1, payloadDefinition.missionTypes, 100)
  end

  log(string.format(
    "SQUADRON_REGISTERED name=%s template=%s assetGroups=%d grouping=%d aircraft=%d parkingIDs=%s payloads=%d",
    definition.name,
    definition.template,
    definition.assetGroups,
    definition.grouping,
    definition.assetGroups * definition.grouping,
    table.concat(definition.parkingIDs, ","),
    #payloads
  ))

  return squadron, payloads
end

local function main()
  log("BEGIN foundation-only Jalalabad AIRWING/SQUADRON initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not AIRWING or not SQUADRON or not GROUP or not AIRBASE or not AUFTRAG then
    error("Required MOOSE AIRWING/SQUADRON foundation classes are unavailable")
  end

  local airbase = AIRBASE:FindByName(config.airbaseName)
  if not airbase then
    error("Jalalabad airbase not found")
  end

  local anchor = (STATIC and STATIC:FindByName(config.warehouseName, false))
    or (UNIT and UNIT:FindByName(config.warehouseName))
  if not anchor then
    error("Warehouse anchor not found: " .. config.warehouseName)
  end

  if airbase.SetParkingSpotBlacklist then
    airbase:SetParkingSpotBlacklist(config.parkingBlacklist)
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
  for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
    local squadron, squadronPayloads = createSquadron(airwing, config.squadrons[key])
    squadrons[key] = squadron
    payloads[key] = squadronPayloads
  end

  OMW.AirOps.Jalalabad = {
    Status = "FOUNDATION_READY",
    Airbase = airbase,
    Airwing = airwing,
    Squadrons = squadrons,
    Payloads = payloads,
    Config = config,
    Scope = "AIRWING_SQUADRON_FOUNDATION_ONLY",
  }

  airwing:Start()
  OMW.AirOps.Jalalabad.Status = "RUNNING"

  log("RESULT status=RUNNING airwings=1 squadrons=4 aircraft=48 payloads=5 missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false")
end

local ok, err = pcall(main)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.AirOps.Jalalabad = OMW.AirOps.Jalalabad or {}
  OMW.AirOps.Jalalabad.Status = "ERROR"
  OMW.AirOps.Jalalabad.Error = tostring(err)
end
