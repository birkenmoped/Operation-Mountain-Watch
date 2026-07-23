-- Operation Mountain Watch - Jalalabad Air Operations bootstrap
-- Stage 1: validation only. No missions are generated here.
OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.JBAD]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

OMW.AirOps.Jalalabad = {
  AirbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad",
  WarehouseName = "WH_AIR_US_JALALABAD",
  AirwingName = "AW_US_JALALABAD",
  Inventory = { OH58D = 24, AH64D = 8, UH60 = 6 },
  Limits = {
    PlayerPerType = 4,
    AIPerType = 4,
    ConcurrentSupportMissions = 2,
    AircraftPerMission = 2
  },
  Templates = {
    OH58DRecon = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
    AH64DCAS = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
    UH60MedevacLead = "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
    UH60MedevacCover = "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP"
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

  -- STATIC:FindByName raises an error by default when the object is absent.
  -- The missing anchor is an expected stage-1 condition, so explicitly disable
  -- that error and report a controlled WAITING result instead.
  local anchor = STATIC:FindByName(cfg.WarehouseName, false) or UNIT:FindByName(cfg.WarehouseName)
  if not anchor then
    log("WAITING: Warehouse anchor missing: " .. cfg.WarehouseName)
    return
  end

  local ok, result = pcall(function()
    local airwing = AIRWING:New(cfg.WarehouseName, cfg.AirwingName)
    airwing:SetAirbase(airbase)
    return airwing
  end)

  if not ok or not result then
    log("ERROR: AIRWING construction failed: " .. tostring(result))
    return
  end

  OMW.AirOps.Jalalabad.Airbase = airbase
  OMW.AirOps.Jalalabad.Airwing = result
  log("AIRWING constructed and explicitly linked. Not started in validation stage.")
end

if SCHEDULER then
  SCHEDULER:New(nil, validate, {}, 7)
else
  timer.scheduleFunction(function()
    validate()
    return nil
  end, nil, timer.getTime() + 7)
end
