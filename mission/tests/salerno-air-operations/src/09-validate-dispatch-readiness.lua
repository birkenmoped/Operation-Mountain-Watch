local TAG = "[OMW][SALERNO][DISPATCH-READY]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function requireFunction(owner, name, label, failures)
  local ok = owner ~= nil and type(owner[name]) == "function"
  log(string.format("API label=%s available=%s", tostring(label), tostring(ok)))
  if not ok then failures[#failures + 1] = label end
  return ok
end

local function requireValue(owner, name, label, failures)
  local ok = owner ~= nil and owner[name] ~= nil
  log(string.format("ENUM label=%s available=%s value=%s", tostring(label), tostring(ok), tostring(ok and owner[name] or nil)))
  if not ok then failures[#failures + 1] = label end
  return ok
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then
    log("COMPLETE status=FAIL reason=configuration-missing")
    return
  end

  local failures = {}
  local airwing = cfg.ConstructedAirwing
  local squadrons = cfg.ConstructedSquadrons or {}

  requireFunction(AUFTRAG, "NewCAS", "AUFTRAG.NewCAS", failures)
  requireFunction(AUFTRAG, "NewRECON", "AUFTRAG.NewRECON", failures)
  requireFunction(AUFTRAG, "NewTROOPTRANSPORT", "AUFTRAG.NewTROOPTRANSPORT", failures)
  requireFunction(AUFTRAG, "NewCARGOTRANSPORT", "AUFTRAG.NewCARGOTRANSPORT", failures)
  requireFunction(airwing, "AddMission", "AIRWING.AddMission", failures)
  requireFunction(ZONE_RADIUS, "New", "ZONE_RADIUS.New", failures)
  requireFunction(COORDINATE, "Translate", "COORDINATE.Translate", failures)

  requireValue(AUFTRAG and AUFTRAG.Type, "CAS", "AUFTRAG.Type.CAS", failures)
  requireValue(AUFTRAG and AUFTRAG.Type, "RECON", "AUFTRAG.Type.RECON", failures)
  requireValue(AUFTRAG and AUFTRAG.Type, "TROOPTRANSPORT", "AUFTRAG.Type.TROOPTRANSPORT", failures)
  requireValue(AUFTRAG and AUFTRAG.Type, "CARGOTRANSPORT", "AUFTRAG.Type.CARGOTRANSPORT", failures)

  local airbase = AIRBASE and AIRBASE:FindByName(cfg.AirbaseName) or nil
  if not airbase or type(airbase.GetCoordinate) ~= "function" then
    failures[#failures + 1] = "AIRBASE.GetCoordinate"
    log("CONTRACT airbaseCoordinate=false")
  else
    local okZones, zoneDetail = pcall(function()
      local origin = airbase:GetCoordinate()
      local casCoord = origin:Translate(6000, 90)
      local reconCoord = origin:Translate(8000, 45)
      local liftCoord = origin:Translate(4000, 180)
      cfg.DispatchTestZones = {
        CAS = ZONE_RADIUS:New("ZONE_TEST_US_SAL_CAS", casCoord:GetVec2(), 1500),
        RECON = ZONE_RADIUS:New("ZONE_TEST_US_SAL_RECON", reconCoord:GetVec2(), 1500),
        LIFT = ZONE_RADIUS:New("ZONE_TEST_US_SAL_LIFT", liftCoord:GetVec2(), 800)
      }
    end)
    if okZones then
      log("CONTRACT syntheticZones=3 casOffsetM=6000 reconOffsetM=8000 liftOffsetM=4000")
    else
      failures[#failures + 1] = "synthetic-zone-construction"
      log("ERROR phase=synthetic-zone-construction detail=" .. tostring(zoneDetail))
    end
  end

  local callsignMethods = 0
  for _, squadron in ipairs(squadrons) do
    if type(squadron.SetCallsign) == "function" then callsignMethods = callsignMethods + 1 end
  end
  log(string.format("CALLSIGN explicitMethod=%d/%d policy=inherit-template-callsigns-until-authoritative-contract",
    callsignMethods, cfg.Expected.Squadrons))
  if callsignMethods ~= cfg.Expected.Squadrons then
    failures[#failures + 1] = "SQUADRON.SetCallsign"
  end

  cfg.DispatchReadinessValidated = #failures == 0
  log(string.format("SAFETY missionsAdded=0 newSpawnsExpected=0 zonesConstructed=%d failures=%d",
    cfg.DispatchTestZones and 3 or 0, #failures))
  log("COMPLETE status=" .. (#failures == 0 and "PASS" or "FAIL") ..
    (#failures > 0 and (" missing=" .. table.concat(failures, ",")) or ""))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 22)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 22)
end
