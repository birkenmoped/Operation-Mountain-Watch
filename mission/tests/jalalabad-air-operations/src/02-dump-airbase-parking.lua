local TAG = "[OMW][DumpAirbaseParking]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  if not AIRBASE then log("ERROR: MOOSE AIRBASE class unavailable") return end
  local name = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad"
  local airbase = AIRBASE:FindByName(name)
  if not airbase then log("ERROR: Airbase not found: " .. tostring(name)) return end

  log(string.format("Airbase=%s ID=%s category=%s", airbase:GetName(), tostring(airbase:GetID()), tostring(airbase:GetCategoryName())))
  local spots = airbase:GetParkingSpotsTable() or {}
  table.sort(spots, function(a, b) return (a.TerminalID or -1) < (b.TerminalID or -1) end)
  log("Parking count=" .. tostring(#spots))

  for _, parking in ipairs(spots) do
    local coordinate = parking.Coordinate
    local vec3 = coordinate and coordinate:GetVec3() or {}
    log(string.format(
      "TerminalID=%s TerminalID0=%s Type=%s Free=%s TOAC=%s OccupiedBy=%s x=%.1f y=%.1f z=%.1f",
      tostring(parking.TerminalID), tostring(parking.TerminalID0), tostring(parking.TerminalType),
      tostring(parking.Free), tostring(parking.TOAC), tostring(parking.OccupiedBy),
      tonumber(vec3.x) or 0, tonumber(vec3.y) or 0, tonumber(vec3.z) or 0
    ))
  end
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 3) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 3) end
