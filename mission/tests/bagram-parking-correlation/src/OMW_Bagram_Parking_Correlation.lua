-- Operation Mountain Watch - Bagram parking correlation diagnostic.
-- Test-only. Reads MOOSE AIRBASE parking data and correlates it with the
-- parking-marker groups in the dedicated BAGRAM.miz marker mission.

local TEST_ID = "BAGRAM-PARKING-CORRELATION-1"
local AIRBASE_NAME = "Bagram"
local MATCH_DISTANCE_METERS = 5

local candidates = __BAGRAM_PARKING_CANDIDATES__

local function log(message)
  env.info(string.format("[OMW][%s] %s", TEST_ID, message))
end

local function fail(message)
  env.error(string.format("[OMW][%s] %s", TEST_ID, message))
end

local airbase = AIRBASE:FindByName(AIRBASE_NAME)
if not airbase then
  fail("RESULT status=FAIL reason=AIRBASE_NOT_FOUND airbase=" .. AIRBASE_NAME)
  return
end

local parkingSpots = airbase:GetParkingSpotsTable() or {}
local parkingByID = {}
for _, spot in pairs(parkingSpots) do
  parkingByID[spot.TerminalID] = spot
end

local total = #candidates
local mapped = 0
local missingGroups = 0
local missingSpots = 0
local distanceFailures = 0
local maxDistance = 0

log(string.format(
  "START airbase=%s candidates=%d runtimeParkingSpots=%d matchDistanceMeters=%d",
  AIRBASE_NAME,
  total,
  #parkingSpots,
  MATCH_DISTANCE_METERS
))

for _, candidate in ipairs(candidates) do
  local group = GROUP:FindByName(candidate.groupLabel)
  local spot = parkingByID[candidate.terminalID]

  if not group then
    missingGroups = missingGroups + 1
    fail(string.format(
      "ENTRY status=FAIL reason=GROUP_NOT_FOUND group=%s meParkingID=%s candidateTerminalID=%d",
      candidate.groupLabel,
      candidate.meParkingID,
      candidate.terminalID
    ))
  elseif not spot then
    missingSpots = missingSpots + 1
    fail(string.format(
      "ENTRY status=FAIL reason=TERMINAL_ID_NOT_FOUND group=%s meParkingID=%s candidateTerminalID=%d",
      candidate.groupLabel,
      candidate.meParkingID,
      candidate.terminalID
    ))
  else
    local groupCoordinate = group:GetCoordinate()
    local spotCoordinate = spot.Coordinate

    if not groupCoordinate or not spotCoordinate then
      distanceFailures = distanceFailures + 1
      fail(string.format(
        "ENTRY status=FAIL reason=COORDINATE_UNAVAILABLE group=%s meParkingID=%s candidateTerminalID=%d",
        candidate.groupLabel,
        candidate.meParkingID,
        candidate.terminalID
      ))
    else
      local distance = groupCoordinate:Get2DDistance(spotCoordinate)
      if distance > maxDistance then
        maxDistance = distance
      end

      if distance <= MATCH_DISTANCE_METERS then
        mapped = mapped + 1
        log(string.format(
          "ENTRY status=MATCH group=%s meParkingID=%s candidateTerminalID=%d runtimeTerminalID=%d distanceMeters=%.3f terminalType=%s",
          candidate.groupLabel,
          candidate.meParkingID,
          candidate.terminalID,
          spot.TerminalID,
          distance,
          tostring(spot.TerminalType)
        ))
      else
        distanceFailures = distanceFailures + 1
        fail(string.format(
          "ENTRY status=FAIL reason=DISTANCE_MISMATCH group=%s meParkingID=%s candidateTerminalID=%d runtimeTerminalID=%d distanceMeters=%.3f terminalType=%s",
          candidate.groupLabel,
          candidate.meParkingID,
          candidate.terminalID,
          spot.TerminalID,
          distance,
          tostring(spot.TerminalType)
        ))
      end
    end
  end
end

local status = "FAIL"
if mapped == total and missingGroups == 0 and missingSpots == 0 and distanceFailures == 0 then
  status = "PASS"
end

log(string.format(
  "RESULT status=%s airbase=%s candidates=%d mapped=%d missingGroups=%d missingSpots=%d distanceFailures=%d maxDistanceMeters=%.3f matchDistanceMeters=%d",
  status,
  AIRBASE_NAME,
  total,
  mapped,
  missingGroups,
  missingSpots,
  distanceFailures,
  maxDistance,
  MATCH_DISTANCE_METERS
))
