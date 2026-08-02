local TAG = "[OMW][SALERNO][CONFIG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("COMPLETE status=FAIL reason=configuration-missing") return end

  local squadrons = cfg.RegisteredSquadrons or cfg.ConstructedSquadrons or {}
  local contracts = cfg.SquadronContracts or {}
  local parking = cfg.ParkingContract
  if #squadrons ~= cfg.Expected.Squadrons or #contracts ~= cfg.Expected.Squadrons then
    log(string.format("COMPLETE status=FAIL reason=count-mismatch squadrons=%d contracts=%d expected=%d",
      #squadrons, #contracts, cfg.Expected.Squadrons))
    return
  end
  if not parking or tonumber(parking.Violations) ~= 0 then
    log("COMPLETE status=FAIL reason=runtime-parking-contract-not-ready")
    return
  end

  local configured, failures = 0, 0
  local turnoverMin, turnoverMax = 20, 40

  for index, squadron in ipairs(squadrons) do
    local contract = contracts[index]
    local grouping = contract and contract.UnitsPerTemplate or nil
    local name = contract and contract.Name or ("index-" .. tostring(index))
    local expectedParking = contract.ParkingSector == "LEFT_HEAVY" and parking.AllowedLeftHeavy or parking.AllowedRightRotary

    if type(squadron.SetGrouping) ~= "function" then
      failures = failures + 1
      log("ERROR name=" .. tostring(name) .. " reason=SetGrouping-unavailable")
    elseif type(squadron.SetTurnoverTime) ~= "function" then
      failures = failures + 1
      log("ERROR name=" .. tostring(name) .. " reason=SetTurnoverTime-unavailable")
    elseif type(grouping) ~= "number" or grouping < 1 then
      failures = failures + 1
      log("ERROR name=" .. tostring(name) .. " reason=invalid-grouping value=" .. tostring(grouping))
    elseif type(expectedParking) ~= "table" or #expectedParking == 0 then
      failures = failures + 1
      log("ERROR name=" .. tostring(name) .. " reason=parking-sector-empty sector=" .. tostring(contract.ParkingSector))
    else
      local ok, detail = pcall(function()
        squadron:SetGrouping(grouping)
        squadron:SetTurnoverTime(turnoverMin, turnoverMax)
      end)

      if ok then
        configured = configured + 1
        log(string.format("CONFIGURED name=%s grouping=%d turnoverMin=%d turnoverMax=%d parkingSector=%s parkingCount=%d",
          tostring(name), grouping, turnoverMin, turnoverMax, tostring(contract.ParkingSector), #expectedParking))
      else
        failures = failures + 1
        log("ERROR name=" .. tostring(name) .. " detail=" .. tostring(detail))
      end
    end
  end

  cfg.SquadronBaselineConfigured = failures == 0 and configured == cfg.Expected.Squadrons

  log(string.format("SAFETY airwingStartCalled=false missionsAdded=0 payloadsAdded=0 spawnsExpected=0 configured=%d failures=%d",
    configured, failures))
  log(string.format("SUMMARY configured=%d/%d failures=%d", configured, cfg.Expected.Squadrons, failures))
  log("COMPLETE status=" .. ((failures == 0 and configured == cfg.Expected.Squadrons) and "PASS" or "FAIL"))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 14) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 14) end
