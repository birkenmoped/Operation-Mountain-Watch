-- Operation Mountain Watch - Bagram Air Operations bootstrap
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.BGRAM]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

OMW.AirOps.Bagram = {
  Status = "ASSEMBLING",
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Bagram or "Bagram",
  WarehouseName = "WH_AIR_US_BAGRAM",
  AirwingName = "AW_US_BAGRAM",

  Inventory = {
    F15E = 13,
    F16C = 13,
    C130 = 20,
    HH60G = 6,
    UH60 = 10,
    CH47 = 13
  },

  LogicalReserve = {
    F15E = 1,
    F16C = 1
  },

  -- Exact Mission Editor template contract in OMW_Template_v4_Bagram.miz.
  -- The current baseline has one HH-60G seed and one UH-60 utility seed.
  Templates = {
    F15E = "TPL_AIR_US_BGRM_F15E_CAS_2SHIP",
    F16C = "TPL_AIR_US_BGRM_F16_CAS_2SHIP",
    C130 = "TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP",
    HH60G = "TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP",
    UH60 = "TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP",
    CH47 = "TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP"
  },

  SquadronNames = {
    F15E = "SQ_US_BGRM_F15E_335_EFS",
    F16C = "SQ_US_BGRM_F16C_121_EFS",
    C130 = "SQ_US_BGRM_C130_774_EAS",
    HH60G = "SQ_US_BGRM_HH60G_83_ERQS",
    UH60 = "SQ_US_BGRM_UH60_A_1_169",
    CH47 = "SQ_US_BGRM_CH47_B_7_158"
  },

  ExcludedTypes = {
    "OH-58D",
    "MC-12W",
    "EC-130H",
    "EA-6B",
    "SEPARATE_ARMY_MEDEVAC_POOL"
  },

  -- Test-only switches. The isolated HH-60G recruitment/spawn/cleanup test is
  -- accepted and therefore disabled. The next active increment is the larger
  -- Bagram-to-Jalalabad fixed-wing movement wave.
  Tests = {
    HH60GControlledSpawn = false,
    FixedWingBagramToJalalabad = true
  },

  Squadrons = {},
  Payloads = {},
  Airbase = nil,
  Airwing = nil,
  Started = false
}

local function validateAndConstructAirwing()
  local cfg = OMW.AirOps.Bagram
  if not AIRBASE or not AIRWING or not STATIC or not UNIT then
    log("ERROR: Required MOOSE classes are unavailable.")
    return
  end

  local airbase = AIRBASE:FindByName(cfg.AirbaseName)
  if not airbase then
    log("ERROR: Airbase not found: " .. tostring(cfg.AirbaseName))
    return
  end

  local anchor = STATIC:FindByName(cfg.WarehouseName, false) or UNIT:FindByName(cfg.WarehouseName)
  if not anchor then
    log("WAITING: Warehouse anchor missing: " .. cfg.WarehouseName)
    return
  end

  local ok, result = pcall(function()
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
  cfg.Status = "AIRWING_READY"

  log(string.format(
    "AIRWING ready. name=%s airbase=%s inventory=13/13/20/6/10/13 excluded=OH58D,MC12W,EC130H,EA6B,SEPARATE_ARMY_MEDEVAC.",
    cfg.AirwingName,
    airbase:GetName()
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, validateAndConstructAirwing, {}, 7)
else
  timer.scheduleFunction(function()
    validateAndConstructAirwing()
    return nil
  end, nil, timer.getTime() + 7)
end
