local TAG = "[OMW][SALERNO][SQUADRON]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("COMPLETE status=FAIL reason=configuration-missing") return end
  if not SQUADRON then log("COMPLETE status=FAIL reason=moose-squadron-class-unavailable") return end

  local contracts = cfg.SquadronContracts or {}
  local constructed, failures, residualAircraft = {}, 0, 0

  for _, contract in ipairs(contracts) do
    local representedAircraft = contract.Ngroups * contract.UnitsPerTemplate
    local expectedResidual = contract.LogicalAircraft - representedAircraft
    log(string.format("CONTRACT name=%s template=%s logicalAircraft=%d unitsPerTemplate=%d ngroups=%d representedAircraft=%d residualAircraft=%d parkingSector=%s parkingAssignment=DEFERRED_TO_RUNTIME_CONTRACT",
      tostring(contract.Name), tostring(contract.Template), tonumber(contract.LogicalAircraft) or -1,
      tonumber(contract.UnitsPerTemplate) or -1, tonumber(contract.Ngroups) or -1,
      tonumber(representedAircraft) or -1, tonumber(contract.ResidualAircraft) or -1,
      tostring(contract.ParkingSector)))

    if expectedResidual ~= contract.ResidualAircraft or expectedResidual < 0 then
      failures = failures + 1
      log("ERROR contract-arithmetic name=" .. tostring(contract.Name) .. " calculatedResidual=" .. tostring(expectedResidual))
    else
      local ok, squadronOrError = pcall(function()
        return SQUADRON:New(contract.Template, contract.Ngroups, contract.Name)
      end)

      if ok and squadronOrError then
        constructed[#constructed + 1] = squadronOrError
        residualAircraft = residualAircraft + contract.ResidualAircraft
        log(string.format("CONSTRUCTED name=%s template=%s ngroups=%d parkingSector=%s parkingAssignment=PENDING",
          contract.Name, contract.Template, contract.Ngroups, tostring(contract.ParkingSector)))
      else
        failures = failures + 1
        log("ERROR construction name=" .. tostring(contract.Name) .. " detail=" .. tostring(squadronOrError))
      end
    end
  end

  cfg.ConstructedSquadrons = constructed
  log(string.format("SAFETY airwingStartCalled=false squadronsAddedToAirwing=0 missionsAdded=0 spawnsExpected=0 residualAircraft=%d", residualAircraft))

  local pass = failures == 0 and #constructed == cfg.Expected.Squadrons
  log(string.format("SUMMARY constructed=%d/%d failures=%d residualAircraft=%d", #constructed, cfg.Expected.Squadrons, failures, residualAircraft))
  log("COMPLETE status=" .. (pass and "PASS" or "FAIL"))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 10) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 10) end
