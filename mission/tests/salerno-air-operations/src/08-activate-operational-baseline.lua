local TAG = "[OMW][SALERNO][OPERATIONAL]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function tableCount(value)
  local count = 0
  if type(value) == "table" then for _ in pairs(value) do count = count + 1 end end
  return count
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("COMPLETE status=FAIL reason=configuration-missing") return end

  local airwing = cfg.ConstructedAirwing
  local squadrons = cfg.RegisteredSquadrons or cfg.ConstructedSquadrons or {}
  local contracts = cfg.SquadronContracts or {}
  if not airwing or #squadrons ~= cfg.Expected.Squadrons or #contracts ~= cfg.Expected.Squadrons then
    log(string.format("COMPLETE status=FAIL reason=prerequisite-missing airwing=%s squadrons=%d contracts=%d expected=%d",
      tostring(airwing ~= nil), #squadrons, #contracts, cfg.Expected.Squadrons))
    return
  end
  if not AUFTRAG or not AUFTRAG.Type then log("COMPLETE status=FAIL reason=AUFTRAG.Type-unavailable") return end

  local capabilityMap = {
    { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED, AUFTRAG.Type.ESCORT },
    { AUFTRAG.Type.RECON, AUFTRAG.Type.FACA, AUFTRAG.Type.ESCORT },
    { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT },
    { AUFTRAG.Type.RESCUEHELO, AUFTRAG.Type.CARGOTRANSPORT },
    { AUFTRAG.Type.TROOPTRANSPORT, AUFTRAG.Type.CARGOTRANSPORT }
  }

  local failures, capabilitiesConfigured, payloadsAdded = 0, 0, 0
  cfg.OperationalPayloads = {}

  for index, squadron in ipairs(squadrons) do
    local contract = contracts[index]
    local name = contract and contract.Name or ("index-" .. tostring(index))
    local template = contract and contract.Template or nil
    local missionTypes = capabilityMap[index]

    if type(squadron.AddMissionCapability) ~= "function" then
      failures = failures + 1
      log("ERROR name=" .. tostring(name) .. " reason=AddMissionCapability-unavailable")
    elseif not template or type(missionTypes) ~= "table" then
      failures = failures + 1
      log("ERROR name=" .. tostring(name) .. " reason=invalid-contract")
    else
      local okCapability, capabilityDetail = pcall(function() squadron:AddMissionCapability(missionTypes) end)
      if okCapability then
        capabilitiesConfigured = capabilitiesConfigured + 1
        log(string.format("CAPABILITY name=%s missionTypes=%s", tostring(name), table.concat(missionTypes, ",")))
      else
        failures = failures + 1
        log("ERROR name=" .. tostring(name) .. " phase=capability detail=" .. tostring(capabilityDetail))
      end

      local okPayload, payloadOrError = pcall(function() return airwing:NewPayload(template, -1, missionTypes, 50) end)
      if okPayload and payloadOrError then
        payloadsAdded = payloadsAdded + 1
        cfg.OperationalPayloads[#cfg.OperationalPayloads + 1] = payloadOrError
        log(string.format("PAYLOAD name=%s template=%s unlimited=true missionTypes=%s",
          tostring(name), tostring(template), table.concat(missionTypes, ",")))
      else
        failures = failures + 1
        log("ERROR name=" .. tostring(name) .. " phase=payload detail=" .. tostring(payloadOrError))
      end
    end
  end

  local startCalled, startOk, startDetail = false, false, nil
  if failures == 0 and type(airwing.Start) == "function" then
    startCalled = true
    startOk, startDetail = pcall(function() airwing:Start() end)
    if not startOk then failures = failures + 1 log("ERROR phase=airwing-start detail=" .. tostring(startDetail)) end
  elseif type(airwing.Start) ~= "function" then
    failures = failures + 1
    log("ERROR phase=airwing-start reason=Start-unavailable")
  end

  cfg.OperationalBaselineActivated = failures == 0
  cfg.AirwingStartCalled = startCalled

  log(string.format("STATE capabilities=%d/%d payloads=%d/%d payloadTable=%d airwingStartCalled=%s airwingStartOk=%s parkingControl=DEFERRED",
    capabilitiesConfigured, cfg.Expected.Squadrons, payloadsAdded, cfg.Expected.Squadrons,
    tableCount(airwing.payloads), tostring(startCalled), tostring(startOk)))
  log(string.format("SAFETY missionsAdded=0 deliberateSpawnsExpected=0 failures=%d", failures))
  log("COMPLETE status=" .. (failures == 0 and "PASS" or "FAIL"))
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 18) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 18) end
