-- Operation Mountain Watch - Jalalabad Air Operations
-- Validates the named MOOSE warehouse anchor and its distance to Jalalabad.

local PREFIX = "[OMW-AIROPS-JBAD][WAREHOUSE] "
local ANCHOR_NAME = "WH_AIR_US_JALALABAD"
local MAX_RECOMMENDED_DISTANCE_METERS = 3000

local function log(message)
  env.info(PREFIX .. tostring(message))
end

local function fail(message)
  env.error(PREFIX .. tostring(message))
end

if not AIRBASE or not STATIC or not UNIT then
  fail("Required MOOSE wrappers are unavailable. Load Moose.lua first.")
  return
end

local airbase = AIRBASE:FindByName(AIRBASE.Afghanistan.Jalalabad)
if not airbase then
  fail("Jalalabad AIRBASE wrapper was not found.")
  return
end

local anchor = STATIC:FindByName(ANCHOR_NAME, false)
local anchorKind = "STATIC"

if not anchor then
  anchor = UNIT:FindByName(ANCHOR_NAME)
  anchorKind = "UNIT"
end

if not anchor then
  fail(string.format(
    "No named STATIC or UNIT '%s' exists. Map scenery and the DCS airfield warehouse are not a valid AIRWING constructor anchor by name.",
    ANCHOR_NAME
  ))
  return
end

local anchorCoordinate = anchor:GetCoordinate()
local airbaseCoordinate = airbase:GetCoordinate()
if not anchorCoordinate or not airbaseCoordinate then
  fail("Anchor or airbase coordinate is unavailable.")
  return
end

local distance = anchorCoordinate:Get2DDistance(airbaseCoordinate)
local vec2 = anchorCoordinate:GetVec2()

log(string.format(
  "FOUND name=%s kind=%s type=%s alive=%s x=%.3f y=%.3f distanceToJalalabad=%.1f",
  ANCHOR_NAME,
  anchorKind,
  tostring(anchor:GetTypeName()),
  tostring(anchor:IsAlive()),
  tonumber(vec2.x) or 0,
  tonumber(vec2.y) or 0,
  tonumber(distance) or -1
))

if distance > MAX_RECOMMENDED_DISTANCE_METERS then
  fail(string.format(
    "Anchor distance %.1f m exceeds the recommended %d m. Reposition or explicitly review the AIRWING airbase association.",
    distance,
    MAX_RECOMMENDED_DISTANCE_METERS
  ))
else
  log("PASS named anchor exists and is within the recommended Jalalabad association distance.")
end
