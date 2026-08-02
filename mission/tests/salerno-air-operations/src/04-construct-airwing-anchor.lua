local TAG = "[OMW][SALERNO][AIRWING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then
    log("COMPLETE status=FAIL reason=configuration-missing")
    return
  end

  if not AIRWING or not AIRBASE then
    log("COMPLETE status=FAIL reason=moose-class-unavailable")
    return
  end

  local airbase = AIRBASE:FindByName(cfg.AirbaseName)
  if not airbase then
    log("COMPLETE status=FAIL reason=airbase-not-found name=" .. tostring(cfg.AirbaseName))
    return
  end

  local anchor = (STATIC and STATIC:FindByName(cfg.WarehouseName, false)) or
                 (UNIT and UNIT:FindByName(cfg.WarehouseName))
  if not anchor then
    log("COMPLETE status=FAIL reason=warehouse-anchor-not-found name=" .. tostring(cfg.WarehouseName))
    return
  end

  local blocked = {}
  for _, terminalID in ipairs(cfg.ParkingBlacklist or {}) do blocked[terminalID] = true end
  local allowedParkingIDs = {}
  for _, spot in ipairs(airbase:GetParkingSpotsTable() or {}) do
    if spot.TerminalID and not blocked[spot.TerminalID] then
      allowedParkingIDs[#allowedParkingIDs + 1] = spot.TerminalID
    end
  end
  table.sort(allowedParkingIDs)

  local ok, airwingOrError = pcall(function()
    local airwing = AIRWING:New(cfg.WarehouseName, "AW_US_SALERNO")
    airwing:SetAirbase(airbase)
    airwing:SetTakeoffCold()
    airwing:SetSafeParkingOn()
    if type(airwing.SetParkingIDs) ~= "function" then
      error("AIRWING.SetParkingIDs unavailable")
    end
    airwing:SetParkingIDs(allowedParkingIDs)
    return airwing
  end)

  if not ok or not airwingOrError then
    log("COMPLETE status=FAIL reason=construction-error detail=" .. tostring(airwingOrError))
    return
  end

  cfg.AllowedParkingIDs = allowedParkingIDs
  OMW.AirOps.SalernoDiagnostics.ConstructedAirwing = airwingOrError
  log("CONSTRUCTED name=AW_US_SALERNO warehouse=" .. cfg.WarehouseName)
  log("BOUND airbase=" .. tostring(airbase:GetName()) .. " id=" .. tostring(airbase:GetID()))
  log("CONFIG takeoff=COLD safeParking=true parkingAllowlist=true")
  log(string.format("PARKING_CONTRACT allowed=%d blocked=%d blockedIDs=%s",
    #allowedParkingIDs, #(cfg.ParkingBlacklist or {}), table.concat(cfg.ParkingBlacklist or {}, ",")))
  log("SAFETY startCalled=false squadronsAdded=0 spawnsExpected=0")
  log("COMPLETE status=PASS")
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 8)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 8)
end
