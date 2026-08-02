local TAG = "[OMW][SALERNO][DIAG]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function dumpAirbase(label, name)
  local airbase = AIRBASE and AIRBASE:FindByName(name) or nil
  if not airbase then
    log("AIRBASE " .. label .. " MISSING name=" .. tostring(name))
    return nil
  end

  log(string.format("AIRBASE %s OK name=%s id=%s category=%s",
    label, tostring(airbase:GetName()), tostring(airbase:GetID()), tostring(airbase:GetCategoryName())))
  return airbase
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("ERROR configuration missing") return end

  local salerno = dumpAirbase("SALERNO", cfg.AirbaseName)
  dumpAirbase("KHOST_CONTROL", cfg.ControlAirbaseName)
  if not salerno then return end

  local idOK = salerno:GetID() == cfg.ExpectedAirbaseID
  log("AIRBASE_ID expected=" .. tostring(cfg.ExpectedAirbaseID) .. " actual=" .. tostring(salerno:GetID()) .. " pass=" .. tostring(idOK))

  local blacklisted = {}
  for _, id in ipairs(cfg.ParkingBlacklist or {}) do blacklisted[id] = true end
  local spots = salerno:GetParkingSpotsTable() or {}
  table.sort(spots, function(a, b) return (a.TerminalID or -1) < (b.TerminalID or -1) end)
  log("PARKING count=" .. tostring(#spots))

  for _, parking in ipairs(spots) do
    local vec3 = parking.Coordinate and parking.Coordinate:GetVec3() or {}
    local reason = cfg.ParkingBlacklistReasons and cfg.ParkingBlacklistReasons[parking.TerminalID] or nil
    log(string.format(
      "PARKING terminal=%s terminal0=%s type=%s free=%s toac=%s occupiedBy=%s spawnBlocked=%s blockReason=%s x=%.1f y=%.1f z=%.1f",
      tostring(parking.TerminalID), tostring(parking.TerminalID0), tostring(parking.TerminalType),
      tostring(parking.Free), tostring(parking.TOAC), tostring(parking.OccupiedBy),
      tostring(blacklisted[parking.TerminalID] == true), tostring(reason),
      tonumber(vec3.x) or 0, tonumber(vec3.y) or 0, tonumber(vec3.z) or 0))
  end
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 3) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 3) end
