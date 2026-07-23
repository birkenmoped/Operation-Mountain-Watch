-- Operation Mountain Watch - Jalalabad Air Operations
-- Dumps MOOSE parking data for Jalalabad and optionally marks usable spots.

local PREFIX = "[OMW-AIROPS-JBAD][PARKING] "
local MARK_SPOTS = true

local function log(message)
  env.info(PREFIX .. tostring(message))
end

local function fail(message)
  env.error(PREFIX .. tostring(message))
end

if not AIRBASE or not AIRBASE.Afghanistan then
  fail("MOOSE AIRBASE Afghanistan enumerations are unavailable. Load Moose.lua first.")
  return
end

local airbase = AIRBASE:FindByName(AIRBASE.Afghanistan.Jalalabad)
if not airbase then
  fail("AIRBASE:FindByName(AIRBASE.Afghanistan.Jalalabad) returned nil.")
  return
end

local categoryNames = {
  [AIRBASE.TerminalType.Runway] = "Runway",
  [AIRBASE.TerminalType.HelicopterOnly] = "HelicopterOnly",
  [AIRBASE.TerminalType.Shelter] = "Shelter",
  [AIRBASE.TerminalType.OpenMed] = "OpenMed",
  [AIRBASE.TerminalType.SmallSizeFighter] = "SmallSizeFighter",
  [AIRBASE.TerminalType.OpenBig] = "OpenBig",
}

local spots = airbase:GetParkingSpotsTable() or {}
table.sort(spots, function(a, b)
  return (a.TerminalID or -1) < (b.TerminalID or -1)
end)

log(string.format(
  "AIRBASE name=%s id=%s category=%s parkingCount=%d",
  tostring(airbase:GetName()),
  tostring(airbase:GetID()),
  tostring(airbase:GetAirbaseCategory()),
  #spots
))

local counts = {}
for _, spot in ipairs(spots) do
  local terminalType = spot.TerminalType or -1
  counts[terminalType] = (counts[terminalType] or 0) + 1

  local vec2 = spot.Coordinate and spot.Coordinate:GetVec2() or { x = 0, y = 0 }
  local terminalName = categoryNames[terminalType] or "Other"
  local text = string.format(
    "id=%s id0=%s type=%s(%s) free=%s TOAC=%s client=%s clientName=%s distToRwy=%.1f x=%.3f y=%.3f",
    tostring(spot.TerminalID),
    tostring(spot.TerminalID0),
    tostring(terminalType),
    terminalName,
    tostring(spot.Free),
    tostring(spot.TOAC),
    tostring(spot.ClientSpot),
    tostring(spot.ClientName),
    tonumber(spot.DistToRwy) or -1,
    tonumber(vec2.x) or 0,
    tonumber(vec2.y) or 0
  )
  log(text)

  if MARK_SPOTS and spot.Coordinate and terminalType ~= AIRBASE.TerminalType.Runway then
    spot.Coordinate:MarkToAll(string.format(
      "JBAD P%s T%s %s",
      tostring(spot.TerminalID),
      tostring(terminalType),
      spot.Free and "FREE" or "OCCUPIED"
    ))
  end
end

for terminalType, count in pairs(counts) do
  log(string.format(
    "COUNT type=%s(%s) count=%d",
    tostring(terminalType),
    categoryNames[terminalType] or "Other",
    count
  ))
end

log("Parking dump complete. Mission Editor parking labels and MOOSE TerminalID values are not assumed to be identical.")
