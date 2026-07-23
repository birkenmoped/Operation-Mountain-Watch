-- Operation Mountain Watch - Jalalabad Air Operations bootstrap
-- Corrected complete-node assembly based on the 2011 ramp snapshot and DCS parking limits.
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
  Status = "ASSEMBLING_CORRECTED_RAMP",
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad",
  WarehouseName = "WH_AIR_US_JALALABAD",
  AirwingName = "AW_US_JALALABAD",

  -- Logical campaign inventory. This is not a demand for one physical parking
  -- position per airframe. Aircraft not represented by an active group or a
  -- visible static remain in the numerical reserve.
  Inventory = {
    OH58D = 24,
    AH64D = 8,
    UH60 = 8,
    CH47 = 8
  },

  -- Minimum aircraft visible in the supplied February/March 2011 satellite
  -- snapshot. This is evidence for local presence, not the complete inventory.
  ObservedRampMinimum = {
    OH58D = 13,
    AH64D = 7,
    UH60 = 7,
    CH47 = 7,
    MI8 = 1,
    UH1 = 1
  },

  -- Mi-8 and UH-1 are recorded as observed traffic but are not charged to the
  -- US Task Force Shooter campaign inventory until their operator is resolved.
  ObservedExternalOrTransient = {
    MI8 = 1,
    UH1 = 1
  },

  Parking = {
    ComparableHelicopterPositions = 36,
    CorePlayerPositions = 6,
    OptionalUH60LPlayerPositions = 2,
    AITemplateSeedPositions = 7,
    CoreOperationalDemand = 13,
    OperationalDemandWithUH60L = 15,
    Model = "VIRTUAL_INVENTORY_PHYSICAL_SPAWN_POOL_FREEPLACED_STATICS"
  },

  -- Visible caps are deliberately lower than the inventory and lower than the
  -- 2011 snapshot. Statics are free-placed on suitable apron areas and must not
  -- consume or obstruct the operational DCS spawn/return positions.
  StaticCaps = {
    OH58D = 7,
    AH64D = 4,
    UH60 = 4,
    CH47 = 5
  },

  CorrectionPending = {
    CH47 = true,
    Reason = "CH-47 squadron and type consistency must be validated before final activation."
  },

  Limits = {
    PlayerPerType = 2,
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
    UH60MedevacCover = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP",
    CH47HeavyLift = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
  },

  SquadronNames = {
    OH58D = "SQ_US_JBAD_OH58D_6_6_CAV",
    AH64D = "SQ_US_JBAD_AH64D_B_1_10_AVN",
    UH60 = "SQ_US_JBAD_UH60_UTILITY_MEDEVAC",
    CH47 = "SQ_US_JBAD_CH47_HEAVYLIFT"
  },

  PlayerGroups = {
    Required = {
      OH58D = numbered("CLIENT_US_JBAD_OH58D", 2),
      AH64D = numbered("CLIENT_US_JBAD_AH64D", 2),
      CH47 = numbered("CLIENT_US_JBAD_CH47", 2)
    },
    Optional = {
      UH60L = numbered("CLIENT_US_JBAD_UH60L", 2)
    }
  },

  Statics = {
    OH58D = numbered("STATIC_AIR_US_JBAD_OH58D", 7),
    AH64D = numbered("STATIC_AIR_US_JBAD_AH64D", 4),
    UH60 = numbered("STATIC_AIR_US_JBAD_UH60", 4),
    CH47 = numbered("STATIC_AIR_US_JBAD_CH47", 5)
  },

  Zones = {
    "ZONE_AIR_US_JBAD_STATIC_OH58D",
    "ZONE_AIR_US_JBAD_STATIC_AH64D",
    "ZONE_AIR_US_JBAD_STATIC_UH60",
    "ZONE_AIR_US_JBAD_STATIC_CH47",
    "ZONE_AIR_US_JBAD_MEDEVAC_READY",
    "ZONE_AIR_US_JBAD_CH47_READY",
    "ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_JBAD_SLING_PICKUP",
    "ZONE_AIR_US_JBAD_C130_UNLOAD"
  },

  DetectedTypes = {}
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
  log("AIRWING constructed and explicitly linked. Awaiting corrected complete-node assembly before Start().")
  log("RAMP MODEL: inventory=24/8/8/8 visibleCaps=7/4/4/5 playerSlotsPerType=2 operationalParking=13+2optional of 36 comparable positions.")
end

if SCHEDULER then
  SCHEDULER:New(nil, validate, {}, 7)
else
  timer.scheduleFunction(function()
    validate()
    return nil
  end, nil, timer.getTime() + 7)
end
