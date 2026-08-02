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

local function appendUnique(target, seen, values)
  for _, value in ipairs(values or {}) do
    value = tonumber(value)
    if value and not seen[value] then
      seen[value] = true
      target[#target + 1] = value
    end
  end
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

  -- Calibrated MOOSE Runtime TerminalIDs.
  -- CH-47 only: left heavy-lift apron, ME labels 7-12 and 14-20.
  local leftHeavy = copy({ 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 21, 22 })

  -- Type-specific right-apron pools requested from the accepted ME layout.
  -- AH-64: ME 39,41 -> TerminalIDs 28,30.
  local apache = copy({ 28, 30 })

  -- UH-60 assault and MEDEVAC: ME 30,31,34 -> TerminalIDs 33,34,37.
  local blackhawk = copy({ 33, 34, 37 })

  -- OH-58D: ME 26,27 -> TerminalIDs 43,44.
  local kiowa = copy({ 43, 44 })

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

  local globalAllowed, globalSeen = {}, {}
  appendUnique(globalAllowed, globalSeen, leftHeavy)
  appendUnique(globalAllowed, globalSeen, apache)
  appendUnique(globalAllowed, globalSeen, blackhawk)
  appendUnique(globalAllowed, globalSeen, kiowa)
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

  if #apache ~= 2 then fail("APACHE_POOL_SIZE expected=2 actual=" .. tostring(#apache)) end
  if #kiowa ~= 2 then fail("KIOWA_POOL_SIZE expected=2 actual=" .. tostring(#kiowa)) end
  if #blackhawk < 2 then fail("BLACKHAWK_POOL_TOO_SMALL actual=" .. tostring(#blackhawk)) end

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
    local ids, pool

    if name:find("CH47", 1, true) then
      ids, pool = leftHeavy, "LEFT_HEAVY_CH47"
    elseif name:find("AH64D", 1, true) then
      ids, pool = apache, "RIGHT_APACHE"
    elseif name:find("OH58D", 1, true) then
      ids, pool = kiowa, "RIGHT_KIOWA"
    elseif name:find("UH60", 1, true) then
      ids, pool = blackhawk, "RIGHT_BLACKHAWK"
    else
      fail("UNKNOWN_SQUADRON_PARKING_POOL name=" .. name)
    end

    if ids then
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
        log("SQUADRON_SYNCED name=" .. name .. " pool=" .. pool .. " parkingIDs=" .. join(ids))
      end
    end
  end

  cfg.ParkingContract = cfg.ParkingContract or {}
  cfg.ParkingContract.Calibrated = true
  cfg.ParkingContract.TypeSpecific = true
  cfg.ParkingContract.BlockedIDs = copy(blocked)
  cfg.ParkingContract.AllowedLeftHeavy = copy(leftHeavy)
  cfg.ParkingContract.AllowedApache = copy(apache)
  cfg.ParkingContract.AllowedBlackhawk = copy(blackhawk)
  cfg.ParkingContract.AllowedKiowa = copy(kiowa)
  cfg.ParkingContract.AllowedRightRotary = copy({ 28, 30, 33, 34, 37, 43, 44 })
  cfg.ParkingContract.Violations = violations
  cfg.ParkingSectors = {
    LEFT_HEAVY = copy(leftHeavy),
    RIGHT_APACHE = copy(apache),
    RIGHT_BLACKHAWK = copy(blackhawk),
    RIGHT_KIOWA = copy(kiowa)
  }

  log("ME_TO_TERMINAL critical=24:41,25:42,35:38")
  log("CLIENT_TERMINALS=13:18,21:20,22:39,23:40,36:25,40:29")
  log("TYPE_POOL APACHE me=39,41 terminalIDs=" .. join(apache))
  log("TYPE_POOL BLACKHAWK me=30,31,34 terminalIDs=" .. join(blackhawk))
  log("TYPE_POOL KIOWA me=26,27 terminalIDs=" .. join(kiowa))
  log("BLOCKED_IDS=" .. join(blocked))
  log("LEFT_HEAVY_IDS=" .. join(leftHeavy))
  log("GLOBAL_ALLOWED_IDS=" .. join(globalAllowed))
  log("SUMMARY runtimeParkingNodes=" .. tostring(#spots) .. " syncedAssets=" .. tostring(syncedAssets) .. " violations=" .. tostring(violations))
  log("COMPLETE status=" .. (violations == 0 and "PASS" or "FAIL"))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 14)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 14)
end
