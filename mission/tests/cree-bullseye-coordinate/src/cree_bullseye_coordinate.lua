local TEST_ID = "OMW_CREE_BULLSEYE_COORDINATE"
local CREE_LAT_DD = 35.2833333333333
local CREE_LON_DD = 70.2666666666667

local function fail(message)
  env.error(string.format("[OMW][%s][FAIL] %s", TEST_ID, message))
  if trigger and trigger.action and trigger.action.outText then
    trigger.action.outText("OMW CREE bullseye coordinate diagnostic FAILED - see dcs.log", 20)
  end
end

if not COORDINATE or type(COORDINATE.NewFromLLDD) ~= "function" then
  fail("MOOSE COORDINATE:NewFromLLDD is unavailable; ensure Moose.lua is loaded before this diagnostic")
  return
end

if type(COORDINATE.GetVec2) ~= "function" or type(COORDINATE.GetLLDDM) ~= "function" then
  fail("Required MOOSE COORDINATE methods GetVec2/GetLLDDM are unavailable")
  return
end

local cree = COORDINATE:NewFromLLDD(CREE_LAT_DD, CREE_LON_DD)
if not cree then
  fail("COORDINATE:NewFromLLDD returned nil")
  return
end

local vec2 = cree:GetVec2()
if not vec2 or type(vec2.x) ~= "number" or type(vec2.y) ~= "number" then
  fail("COORDINATE:GetVec2 returned an invalid Vec2")
  return
end

local roundTripLat, roundTripLon = cree:GetLLDDM()
if type(roundTripLat) ~= "number" or type(roundTripLon) ~= "number" then
  fail("COORDINATE:GetLLDDM returned invalid latitude/longitude")
  return
end

local latDelta = roundTripLat - CREE_LAT_DD
local lonDelta = roundTripLon - CREE_LON_DD

local result = string.format(
  "[OMW][%s][PASS] CREE lat=%.13f lon=%.13f -> mission_x=%.10f mission_y=%.10f -> roundtrip_lat=%.13f roundtrip_lon=%.13f delta_lat=%.13g delta_lon=%.13g",
  TEST_ID,
  CREE_LAT_DD,
  CREE_LON_DD,
  vec2.x,
  vec2.y,
  roundTripLat,
  roundTripLon,
  latDelta,
  lonDelta
)

env.info(result)

if trigger and trigger.action and trigger.action.outText then
  trigger.action.outText(
    string.format("CREE mission coordinates: x=%.3f y=%.3f - copy PASS line from dcs.log", vec2.x, vec2.y),
    30
  )
end
