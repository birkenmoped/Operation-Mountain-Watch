-- Operation Mountain Watch - validate and start complete Bagram node.
local TAG = "[OMW][AirOps.BGRAM.Finalize]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function countTableEntries(t)
  local count = 0
  for _ in pairs(t or {}) do count = count + 1 end
  return count
end

local function validateAndStart()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Bagram
  if not cfg or not cfg.Airwing then
    log("WAITING: Bagram AIRWING is unavailable.")
    return
  end
  if cfg.Started then
    log("SKIP: Bagram AIRWING already started.")
    return
  end

  local required = { "F15E", "F16C", "C130", "HH60G", "UH60", "CH47" }
  for _, key in ipairs(required) do
    local squadron = cfg.Squadrons and cfg.Squadrons[key] or nil
    if not squadron then
      log("WAITING: required squadron missing: " .. key)
      return
    end
    local expectedName = cfg.SquadronNames[key]
    if cfg.Airwing:GetSquadron(expectedName) ~= squadron then
      log("ERROR: AIRWING linkage mismatch for " .. key .. " name=" .. tostring(expectedName))
      return
    end
  end

  if countTableEntries(cfg.Squadrons) ~= 6 then
    log("ERROR: expected exactly 6 active Bagram squadrons; found=" .. tostring(countTableEntries(cfg.Squadrons)))
    return
  end

  local logicalTotal =
    cfg.Inventory.F15E + cfg.Inventory.F16C + cfg.Inventory.C130 +
    cfg.Inventory.HH60G + cfg.Inventory.UH60 + cfg.Inventory.CH47
  if logicalTotal ~= 75 then
    log("ERROR: binding logical inventory must total 75; found=" .. tostring(logicalTotal))
    return
  end

  local managedAircraft =
    (6 * 2) + (6 * 2) + 20 + 6 + 10 + 13
  local logicalReserve =
    (cfg.LogicalReserve.F15E or 0) + (cfg.LogicalReserve.F16C or 0)
  if managedAircraft ~= 73 or logicalReserve ~= 2 or managedAircraft + logicalReserve ~= logicalTotal then
    log(string.format(
      "ERROR: inventory accounting mismatch managed=%d reserve=%d logical=%d",
      managedAircraft,
      logicalReserve,
      logicalTotal
    ))
    return
  end

  local ok, result = pcall(function()
    cfg.Airwing:Start()
    return true
  end)
  if not ok or not result then
    log("ERROR: AIRWING Start() failed: " .. tostring(result))
    return
  end

  cfg.Started = true
  cfg.Status = "STARTED_NO_TASKING_BASELINE"
  log("PASS: AW_US_BAGRAM started with exactly 6 squadrons and 75 logical airframes.")
  log("ACCOUNTING: MOOSE-managed=73 fighterLogicalReserve=2 total=75.")
  log("SCOPE: no spontaneous AUFTRAG, OPSTRANSPORT or CSAR execution is created by this baseline.")
end

if SCHEDULER then
  SCHEDULER:New(nil, validateAndStart, {}, 19)
else
  timer.scheduleFunction(function()
    validateAndStart()
    return nil
  end, nil, timer.getTime() + 19)
end
