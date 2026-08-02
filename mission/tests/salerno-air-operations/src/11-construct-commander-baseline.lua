local TAG = "[OMW][SALERNO][COMMANDER]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function tableCount(value)
  local count = 0
  if type(value) == "table" then for _ in pairs(value) do count = count + 1 end end
  return count
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg or not cfg.OperationalBaselineActivated then
    log("COMPLETE status=FAIL reason=operational-baseline-missing")
    return
  end
  if not COMMANDER or type(COMMANDER.New) ~= "function" then
    log("COMPLETE status=FAIL reason=COMMANDER.New-unavailable")
    return
  end
  if not coalition or not coalition.side or coalition.side.BLUE == nil then
    log("COMPLETE status=FAIL reason=coalition.side.BLUE-unavailable")
    return
  end

  local airwing = cfg.ConstructedAirwing
  if not airwing then
    log("COMPLETE status=FAIL reason=airwing-missing")
    return
  end

  local commander
  local ok, detail = pcall(function()
    commander = COMMANDER:New(coalition.side.BLUE, "CMD_BLUE_AFGHANISTAN_TEST")
    if type(commander.AddAirwing) == "function" then
      commander:AddAirwing(airwing)
    elseif type(commander.AddLegion) == "function" then
      commander:AddLegion(airwing)
    else
      error("COMMANDER AddAirwing/AddLegion unavailable")
    end
  end)

  if not ok or not commander then
    log("COMPLETE status=FAIL phase=construction detail=" .. tostring(detail))
    return
  end

  cfg.ConstructedCommander = commander
  cfg.CommanderBaselineConstructed = true

  local legionCount = tableCount(commander.legions)
  log("CONSTRUCTED alias=CMD_BLUE_AFGHANISTAN_TEST coalition=BLUE")
  log(string.format("BOUND airwing=AW_US_SALERNO legionTableCount=%d", legionCount))
  log("SAFETY isolated=true directAirwingMissions=0 missionsAdded=0 commanderDispatch=false newSpawnsExpected=0 parkingControl=DEFERRED")
  log("COMPLETE status=PASS")
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 30)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 30)
end
