local TAG = "[OMW][SALERNO][REGISTRATION]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function countTable(value)
  if type(value) ~= "table" then return -1 end
  local count = 0
  for _ in pairs(value) do count = count + 1 end
  return count
end

local function snapshot(airwing)
  return {
    squadronsLower = countTable(airwing and airwing.squadrons),
    squadronsUpper = countTable(airwing and airwing.Squadrons),
    assets = countTable(airwing and airwing.assets),
    stock = countTable(airwing and airwing.stock),
    queue = countTable(airwing and airwing.queue),
  }
end

local function formatSnapshot(prefix, state)
  log(string.format(
    "%s squadronsLower=%d squadronsUpper=%d assets=%d stock=%d queue=%d",
    prefix,
    state.squadronsLower,
    state.squadronsUpper,
    state.assets,
    state.stock,
    state.queue))
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then
    log("COMPLETE status=FAIL reason=configuration-missing")
    return
  end

  local airwing = cfg.ConstructedAirwing
  local squadrons = cfg.ConstructedSquadrons or {}
  if not airwing then
    log("COMPLETE status=FAIL reason=constructed-airwing-missing")
    return
  end
  if #squadrons ~= cfg.Expected.Squadrons then
    log("COMPLETE status=FAIL reason=constructed-squadron-count actual=" .. tostring(#squadrons) .. " expected=" .. tostring(cfg.Expected.Squadrons))
    return
  end
  if type(airwing.AddSquadron) ~= "function" then
    log("COMPLETE status=FAIL reason=add-squadron-method-unavailable")
    return
  end

  local before = snapshot(airwing)
  formatSnapshot("BEFORE", before)

  local registered = 0
  local failures = 0
  for _, squadron in ipairs(squadrons) do
    local squadronName = squadron.squadronname or squadron.SquadronName or squadron.name or "UNKNOWN"
    local ok, result = pcall(function()
      return airwing:AddSquadron(squadron)
    end)
    if ok then
      registered = registered + 1
      log("REGISTERED name=" .. tostring(squadronName) .. " return=" .. tostring(result))
    else
      failures = failures + 1
      log("ERROR registration name=" .. tostring(squadronName) .. " detail=" .. tostring(result))
    end
  end

  local after = snapshot(airwing)
  formatSnapshot("AFTER", after)

  cfg.RegisteredSquadrons = squadrons
  cfg.RegistrationSnapshot = { Before = before, After = after }

  log(string.format(
    "SAFETY airwingStartCalled=false missionsAdded=0 payloadsAdded=0 spawnsExpected=0 registered=%d failures=%d",
    registered, failures))

  local pass = failures == 0 and registered == cfg.Expected.Squadrons
  log(string.format("SUMMARY registered=%d/%d failures=%d",
    registered, cfg.Expected.Squadrons, failures))
  log("COMPLETE status=" .. (pass and "PASS" or "FAIL"))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 12)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 12)
end
