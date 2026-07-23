-- Operation Mountain Watch - Jalalabad Air Operations bootstrap
-- Complete-node assembly: constructs the AIRWING. Squadrons and final activation are added by later sources.
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.JBAD]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function numbered(prefix, count)
  local result = {}
  for index = 1, count do
    result[#result + 1] = string.format("%s_%02d", prefix, index)
  end
  return result
end

OMW.AirOps.Jalalabad = {
  Status = "ASSEMBLING_CH47_CORRECTION",
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad",
  WarehouseName = "WH_AIR_US_JALALABAD",
  AirwingName = "AW_US_JALALABAD",

  Inventory = {
    OH58D = 24,
    AH64D = 8,
    UH60 = 6,
    CH47 = 8
  },

  CorrectionPending = {
    CH47 = true,
    Reason = "2011 satellite imagery and contemporary TF Shooter reporting confirm a missing Jalalabad CH-47 heavy-lift component."
  },

  Limits = {
    PlayerPerType = 4,
    AIPerType = 4,
    ConcurrentSupportMissions = 2,
    AircraftPerMission = 2,
    ConcurrentSupportAircraft = 4
  },

  Medevac = {
    PackageSize = 2,
    LeadAircraft = 1,
    CoverAircraft = 1,
    AllowSingleShip = false
  },

  Templates = {
    OH58DRecon = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
    AH64DCAS = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
    UH60MedevacLead = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
    UH60MedevacCover = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP"
  },

  SquadronNames = {
    OH58D = "SQ_US_JBAD_OH58D_6_6_CAV",
    AH64D = "SQ_US_JBAD_AH64D_B_1_10_AVN",
    UH60 = "SQ_US_JBAD_UH60_UTILITY_MEDEVAC"
  },

  PlayerGroups = {
    Required = {
      OH58D = numbered("CLIENT_US_JBAD_OH58D", 4),
      AH64D = numbered("CLIENT_US_JBAD_AH64D", 4)
    },
    Optional = {
      UH60L = numbered("CLIENT_US_JBAD_UH60L", 4)
    }
  },

  Statics = {
    OH58D = numbered("STATIC_AIR_US_JBAD_OH58D", 8),
    AH64D = numbered("STATIC_AIR_US_JBAD_AH64D", 4),
    UH60 = numbered("STATIC_AIR_US_JBAD_UH60", 2)
  },

  Zones = {
    "ZONE_AIR_US_JBAD_STATIC_OH58D",
    "ZONE_AIR_US_JBAD_STATIC_AH64D",
    "ZONE_AIR_US_JBAD_STATIC_UH60",
    "ZONE_AIR_US_JBAD_MEDEVAC_READY",
    "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_JBAD_SLING_PICKUP",
    "ZONE_AIR_US_JBAD_C130_UNLOAD"
  }
}

local function validate()
  local cfg = OMW.AirOps.Jalalabad
  local airbase = AIRBASE:FindByName(cfg.AirbaseName)
  if not airbase then
    log("ERROR: Airbase not found: " .. tostring(cfg.AirbaseName))
    return
  end

  log("Airbase OK: " .. airbase:GetName() .. " ID=" .. tostring(airbase:GetID()))

  local anchor = STATIC:FindByName(cfg.WarehouseName, false) or UNIT:FindByName(cfg.WarehouseName)
  if not anchor then
    log("WAITING: Warehouse anchor missing: " .. cfg.WarehouseName)
    return
  end

  local ok, result = pcall(function()
    local airwing = AIRWING:New(cfg.WarehouseName, cfg.AirwingName)
    airwing:SetAirbase(airbase)
    airwing:SetTakeoffCold()
    return airwing
  end)

  if not ok or not result then
    log("ERROR: AIRWING construction failed: " .. tostring(result))
    return
  end

  cfg.Airbase = airbase
  cfg.Airwing = result
  log("AIRWING constructed and explicitly linked. Awaiting complete-node assembly before Start().")
  log("CORRECTION: CH-47 heavy-lift inventory=8 is now required before Jalalabad can become OPERATIONAL.")
end

if SCHEDULER then
  SCHEDULER:New(nil, validate, {}, 7)
else
  timer.scheduleFunction(function()
    validate()
    return nil
  end, nil, timer.getTime() + 7)
end
