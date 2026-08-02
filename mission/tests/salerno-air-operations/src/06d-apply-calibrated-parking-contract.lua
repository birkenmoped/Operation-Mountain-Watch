-- Operation Mountain Watch - FOB Salerno calibrated parking contract.
-- Uses the accepted ME-label -> MOOSE TerminalID calibration from 2026-08-02.
-- No Mission Editor label is passed directly to a MOOSE API.

local TAG = "[OMW][SALERNO][PARKING-CALIBRATED]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function copy(values)
  local result = {}
  for _, value in ipairs(values or {}) do result[#result + 1] = tonumber(value) end
  table.sort(result)
  return result
end

local function join(values)
  local t = {}
  for _, value in ipairs(values or {}) do t[#t + 1] = tostring(value) end
  return #t > 0 and table.concat(t, ",") or "none"
end

local function sameSet(a, b)
  local sa, sb = {}, {}
  for _, v in ipairs(a or {}) do sa[tonumber(v)] = true end
  for _, v in ipairs(b or {}) do sb[tonumber(v)] = true end
  for v in pairs(sa) do if not sb[v] then return false end end
  for v in pairs(sb) do if not sa[v] then return false end end
  return true
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("COMPLETE status=FAIL reason=configuration-missing") return end

  local airwing = cfg.ConstructedAirwing
  local squadrons = cfg.RegisteredSquadrons or cfg.ConstructedSquadrons or {}
  local airbase = AIRBASE and AIRBASE:FindByName(cfg.AirbaseName) or nil
  if not airwing or not airbase then
    log("COMPLETE status=FAIL reason=airwing-or-airbase-missing")
    return
  end

  -- Calibrated 2026-08-02. These are MOOSE Runtime TerminalIDs.
  -- LEFT_HEAVY corresponds to ME labels 7-12, 14-20. ME 13 is a client spot.
  local leftHeavy = copy({ 8, 13, 14, 15, 16, 17, 9, 10, 11, 12, 21, 22, 19 })

  -- RIGHT_ROTARY corresponds to ME labels 26-34, 37-39, 41-44.
  -- ME 24,25,35 are blocked; ME 21-23,36,40 are client spots.
  local rightRotary = copy({ 43, 44, 45, 32, 33, 34, 35, 36, 37, 26, 27, 28, 30, 31, 23, 24 })

  -- Explicit exclusions from the calibration and current mission layout.
  local blocked = copy({
    41, -- ME 24: static OH-58 pair
    42, -- ME 25: static OH-58 pair
    38, -- ME 35: main apron access and Role-2/CSAR unload
    18, -- ME 13: CH-47 client
    20, -- ME 21: CH-47 client
    39, -- ME 22: OH-58 client
    40, -- ME 23: OH-58 client
    25, -- ME 36: AH-64 client
    29  -- ME 40: AH-64 client
  })

  local globalAllowed = {}
  for _, v in ipairs(leftHeavy) do globalAllowed[#globalAllowed + 1] = v end
  for _, v in ipairs(rightRotary) do globalAllowed[#globalAllowed + 1] = v end
  table.sort(globalAllowed)

  local violations = 0
  local function fail(reason)
    violations = violations + 1
    log("VIOLATION reason=" .. tostring(reason))
  end

  local spots = airbase:GetParkingSpotsTable() or {}
  local exists = {}
  for _, spot in ipairs(spots) do
    if spot.TerminalID then exists[tonumber(spot.TerminalID)] = true end
  end
  for _, id in ipairs(globalAllowed) do if not exists[id] then fail("ALLOWED_ID_MISSING terminalID=" .. tostring(id)) end end
  for _, id in ipairs(blocked) do if not exists[id] then fail("BLOCKED_ID_MISSING terminalID=" .. tostring(id)) end end

  if violations == 0 then
    local ok, err = pcall(function()
      airbase:SetParkingSpotBlacklist(blocked)
      airwing:SetParkingIDs(globalAllowed)
      airwing:SetSafeParkingOn()
    end)
    if not ok then fail("AIRBASE_OR_AIRWING_APPLY_FAILED error=" .. tostring(err)) end
  end

  local syncedAssets = 0
  for _, squadron in ipairs(squadrons) do
    local name = tostring(squadron.name or squadron.squadronname or squadron.SquadronName or "UNKNOWN")
    local ids = name:find("CH47", 1, true) and leftHeavy or rightRotary
    local sector = name:find("CH47", 1, true) and "LEFT_HEAVY" or "RIGHT_ROTARY"
    local ok, err = pcall(function()
      squadron:SetParkingIDs(ids)
      for _, asset in pairs(squadron.assets or {}) do
        asset.parkingIDs = copy(ids)
        syncedAssets = syncedAssets + 1
      end
    end)
    if not ok then
      fail("SQUADRON_SYNC_FAILED name=" .. name .. " error=" .. tostring(err))
    else
      if not sameSet(squadron.parkingIDs, ids) then fail("SQUADRON_IDS_MISMATCH name=" .. name) end
      for _, asset in pairs(squadron.assets or {}) do
        if not sameSet(asset.parkingIDs, ids) then
          fail("ASSET_IDS_MISMATCH squadron=" .. name .. " asset=" .. tostring(asset.spawngroupname or asset.uid))
        end
      end
      log("SQUADRON_SYNCED name=" .. name .. " sector=" .. sector .. " parkingIDs=" .. join(ids))
    end
  end

  cfg.ParkingContract = cfg.ParkingContract or {}
  cfg.ParkingContract.Calibrated = true
  cfg.ParkingContract.BlockedIDs = copy(blocked)
  cfg.ParkingContract.AllowedLeftHeavy = copy(leftHeavy)
  cfg.ParkingContract.AllowedRightRotary = copy(rightRotary)
  cfg.ParkingContract.Violations = violations
  cfg.ParkingSectors = { LEFT_HEAVY = copy(leftHeavy), RIGHT_ROTARY = copy(rightRotary) }

  log("ME_TO_TERMINAL critical=24:41,25:42,35:38")
  log("CLIENT_TERMINALS=13:18,21:20,22:39,23:40,36:25,40:29")
  log("BLOCKED_IDS=" .. join(blocked))
  log("LEFT_HEAVY_IDS=" .. join(leftHeavy))
  log("RIGHT_ROTARY_IDS=" .. join(rightRotary))
  log("SUMMARY runtimeParkingNodes=" .. tostring(#spots) .. " syncedAssets=" .. tostring(syncedAssets) .. " violations=" .. tostring(violations))
  log("COMPLETE status=" .. (violations == 0 and "PASS" or "FAIL"))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 14)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 14)
end
