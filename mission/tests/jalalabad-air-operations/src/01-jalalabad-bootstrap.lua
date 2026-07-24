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

  Inventory = {
    OH58D = 24,
    AH64D = 8,
    UH60 = 8,
    CH47 = 8
  },

  ObservedRampMinimum = {
    OH58D = 13,
    AH64D = 7,
    UH60 = 7,
    CH47 = 7,
    MI8 = 1,
    UH1 = 1
  },

  ObservedExternalOrTransient = {
    MI8 = 1,
    UH1 = 1
  },

  Parking = {
    ComparableHelicopterPositions = 36,
    CorePlayerPositions = 6,
    OptionalUH60LPlayerPositions = 2,

    -- Templates are technical seed groups and deliberately do not occupy
    -- operational parking positions.
    TemplateAuthoringAircraft = 7,
    TemplateOperationalParkingPositions = 0,
    TemplatesUseOperationalParking = false,
    TemplateMinimumParkingClearanceMeters = 100,

    -- MOOSE TerminalIDs, not the labels displayed in the Mission Editor.
    -- Each pool is exclusive to one SQUADRON; no general-airbase fallback.
    PoolCoordinateToleranceMeters = 2,
    PoolStaticClearanceMeters = 12,
    SquadronPools = {
      OH58D = {
        GroupSize = 2,
        TerminalType = 40,
        Entries = {
          { Label = "G01", TerminalID = 19, X = 73027.2, Z = 389096.3 },
          { Label = "G02", TerminalID = 43, X = 72991.8, Z = 389143.7 },
          { Label = "G03", TerminalID = 6,  X = 72895.0, Z = 389270.4 },
          { Label = "G04", TerminalID = 5,  X = 72857.8, Z = 389318.1 },
          { Label = "G05", TerminalID = 48, X = 72838.7, Z = 389344.2 }
        }
      },
      AH64D = {
        GroupSize = 2,
        TerminalType = 40,
        Entries = {
          { Label = "F04", TerminalID = 26, X = 72760.1, Z = 389173.6 },
          { Label = "F05", TerminalID = 51, X = 72732.7, Z = 389208.3 },
          { Label = "F06", TerminalID = 11, X = 72705.8, Z = 389243.2 }
        }
      },
      UH60 = {
        GroupSize = 1,
        TerminalType = 104,
        Entries = {
          { Label = "F01", TerminalID = 10, X = 72865.1, Z = 389033.6 },
          { Label = "F02", TerminalID = 8,  X = 72836.8, Z = 389063.8 },
          { Label = "F03", TerminalID = 1,  X = 72810.7, Z = 389096.9 }
        }
      },
      CH47 = {
        GroupSize = 1,
        TerminalType = 40,
        Entries = {
          { Label = "C03", TerminalID = 28, X = 72478.5, Z = 389867.0 },
          { Label = "C04", TerminalID = 44, X = 72459.1, Z = 389892.2 },
          { Label = "C05", TerminalID = 0,  X = 72440.1, Z = 389917.6 },
          { Label = "C06", TerminalID = 41, X = 72420.9, Z = 389943.7 },
          { Label = "C07", TerminalID = 9,  X = 72401.8, Z = 389968.6 },
          { Label = "C08", TerminalID = 25, X = 72383.2, Z = 389993.6 },
          { Label = "C09", TerminalID = 18, X = 72364.1, Z = 390019.8 },
          { Label = "C10", TerminalID = 42, X = 72346.4, Z = 390046.0 }
        }
      }
    },

    CH47VisualRampPositions = 14,
    CH47StaticAircraft = 5,
    CH47PlayerPositions = 2,
    CH47RemainingVisualPositions = 7,
    CH47DCSNodeReservations = 4,
    StaticParkingReservations = {
      STATIC_AIR_US_JBAD_CH47_01 = 49,
      STATIC_AIR_US_JBAD_CH47_02 = 37,
      STATIC_AIR_US_JBAD_CH47_03 = 23,
      STATIC_AIR_US_JBAD_CH47_04 = 35
    },
    StaticParkingBlacklist = { 23, 35, 37, 49 },

    Model = "EXCLUSIVE_TYPE_SPECIFIC_SQUADRON_POOLS_TEMPLATES_OFF_PARKING"
  },

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
    AllowSingleShip = false,
    DCSGroupModel = "TWO_INDEPENDENT_SINGLE_SHIP_GROUPS",
    CoordinationModel = "ONE_LOGICAL_MEDEVAC_PACKAGE"
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

  -- Static-display and template-readiness zones were removed. Only functional
  -- logistics zones remain part of the baseline manifest.
  Zones = {
    "ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_LOAD",
    "ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD",
    "ZONE_AIR_US_JBAD_SLING_PICKUP",
    "ZONE_AIR_US_JBAD_C130_UNLOAD"
  },

  DetectedTypes = {},
  ParkingReservationsOK = false,
  ParkingPoolsOK = false
}

local function getPool(key)
  local cfg = OMW.AirOps.Jalalabad
  return cfg.Parking and cfg.Parking.SquadronPools and cfg.Parking.SquadronPools[key] or nil
end

function OMW.AirOps.Jalalabad:GetSquadronParkingIDs(key)
  local result = {}
  local pool = getPool(key)
  for _, entry in ipairs(pool and pool.Entries or {}) do
    result[#result + 1] = entry.TerminalID
  end
  return result
end

function OMW.AirOps.Jalalabad:GetSquadronParkingLabel(key, terminalId)
  local pool = getPool(key)
  for _, entry in ipairs(pool and pool.Entries or {}) do
    if entry.TerminalID == terminalId then return entry.Label end
  end
  return nil
end

function OMW.AirOps.Jalalabad:GetSquadronParkingSet(key)
  local result = {}
  for _, terminalId in ipairs(self:GetSquadronParkingIDs(key)) do
    result[terminalId] = true
  end
  return result
end

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
    if airbase.SetParkingSpotBlacklist then
      airbase:SetParkingSpotBlacklist(cfg.Parking.StaticParkingBlacklist)
    end

    local airwing = AIRWING:New(cfg.WarehouseName, cfg.AirwingName)
    airwing:SetAirbase(airbase)
    airwing:SetTakeoffCold()
    airwing:SetSafeParkingOn()
    return airwing
  end)

  if not ok or not result then
    log("ERROR: AIRWING construction failed: " .. tostring(result))
    return
  end

  cfg.Airbase = airbase
  cfg.Airwing = result
  log("AIRWING constructed and explicitly linked. Awaiting corrected complete-node assembly before Start().")
  log("PARKING BLACKLIST: intentional CH-47 static reservations TerminalIDs=23,35,37,49; Client parking protected by SafeParking.")
  log("RAMP MODEL: inventory=24/8/8/8 visibleCaps=7/4/4/5 clients=6+2optional templatesOffParking=7 exclusivePools=OH58D:G01-G05/AH64D:F04-F06/UH60:F01-F03/CH47:C03-C10.")
end

if SCHEDULER then
  SCHEDULER:New(nil, validate, {}, 7)
else
  timer.scheduleFunction(function()
    validate()
    return nil
  end, nil, timer.getTime() + 7)
end
