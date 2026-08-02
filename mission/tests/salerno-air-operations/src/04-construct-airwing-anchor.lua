local TAG = "[OMW][SALERNO][AIRWING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("COMPLETE status=FAIL reason=configuration-missing") return end
  if not AIRWING or not AIRBASE then log("COMPLETE status=FAIL reason=moose-class-unavailable") return end

  local airbase = AIRBASE:FindByName(cfg.AirbaseName)
  if not airbase then log("COMPLETE status=FAIL reason=airbase-not-found name=" .. tostring(cfg.AirbaseName)) return end

  local anchor = (STATIC and STATIC:FindByName(cfg.WarehouseName, false)) or (UNIT and UNIT:FindByName(cfg.WarehouseName))
  if not anchor then log("COMPLETE status=FAIL reason=warehouse-anchor-not-found name=" .. tostring(cfg.WarehouseName)) return end

  local ok, airwingOrError = pcall(function()
    local airwing = AIRWING:New(cfg.WarehouseName, "AW_US_SALERNO")
    airwing:SetAirbase(airbase)
    airwing:SetTakeoffCold()
    airwing:SetSafeParkingOn()
    return airwing
  end)

  if not ok or not airwingOrError then
    log("COMPLETE status=FAIL reason=construction-error detail=" .. tostring(airwingOrError))
    return
  end

  OMW.AirOps.SalernoDiagnostics.ConstructedAirwing = airwingOrError
  log("CONSTRUCTED name=AW_US_SALERNO warehouse=" .. cfg.WarehouseName)
  log("BOUND airbase=" .. tostring(airbase:GetName()) .. " id=" .. tostring(airbase:GetID()))
  log("CONFIG takeoff=COLD safeParking=true parkingAllocation=SQUADRON_SPECIFIC")
  log("PARKING_CONTRACT globalAllowlist=false delegatedToSquadrons=true")
  log("SAFETY startCalled=false squadronsAdded=0 spawnsExpected=0")
  log("COMPLETE status=PASS")
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 8) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 8) end
