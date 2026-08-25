-- Operation Mountain Watch - Bagram parking TerminalID correlation diagnostic.
-- Test-only. Reads the runtime MOOSE AIRBASE parking table and verifies that
-- the 187 TerminalID candidates extracted from the dedicated BAGRAM.miz
-- reference mission form the complete runtime TerminalID set for Bagram.
-- The reference marker groups are intentionally NOT required in the OMW test MIZ.

local TEST_ID = "BAGRAM-PARKING-CORRELATION-2"
local AIRBASE_NAME = "Bagram"

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
local runtimeDuplicateIDs = 0
local runtimeUniqueIDs = 0

for _, spot in pairs(parkingSpots) do
  if parkingByID[spot.TerminalID] then
    runtimeDuplicateIDs = runtimeDuplicateIDs + 1
    fail(string.format(
      "RUNTIME status=FAIL reason=DUPLICATE_TERMINAL_ID terminalID=%d",
      spot.TerminalID
    ))
  else
    parkingByID[spot.TerminalID] = spot
    runtimeUniqueIDs = runtimeUniqueIDs + 1
  end
end

local total = #candidates
local mapped = 0
local missingSpots = 0

log(string.format(
  "START airbase=%s candidates=%d runtimeParkingSpots=%d runtimeUniqueTerminalIDs=%d",
  AIRBASE_NAME,
  total,
  #parkingSpots,
  runtimeUniqueIDs
))

for _, candidate in ipairs(candidates) do
  local spot = parkingByID[candidate.terminalID]

  if not spot then
    missingSpots = missingSpots + 1
    fail(string.format(
      "ENTRY status=FAIL reason=TERMINAL_ID_NOT_FOUND referenceGroup=%s meParkingID=%s candidateTerminalID=%d",
      candidate.groupLabel,
      candidate.meParkingID,
      candidate.terminalID
    ))
  else
    mapped = mapped + 1
    log(string.format(
      "ENTRY status=MATCH referenceGroup=%s meParkingID=%s candidateTerminalID=%d runtimeTerminalID=%d terminalType=%s",
      candidate.groupLabel,
      candidate.meParkingID,
      candidate.terminalID,
      spot.TerminalID,
      tostring(spot.TerminalType)
    ))
  end
end

local unexpectedRuntimeIDs = 0
for runtimeTerminalID, _ in pairs(parkingByID) do
  local expected = false
  for _, candidate in ipairs(candidates) do
    if candidate.terminalID == runtimeTerminalID then
      expected = true
      break
    end
  end
  if not expected then
    unexpectedRuntimeIDs = unexpectedRuntimeIDs + 1
    fail(string.format(
      "RUNTIME status=FAIL reason=UNEXPECTED_TERMINAL_ID terminalID=%d",
      runtimeTerminalID
    ))
  end
end

local status = "FAIL"
if mapped == total
  and missingSpots == 0
  and runtimeDuplicateIDs == 0
  and unexpectedRuntimeIDs == 0
  and #parkingSpots == total
  and runtimeUniqueIDs == total then
  status = "PASS"
end

log(string.format(
  "RESULT status=%s airbase=%s candidates=%d mapped=%d missingSpots=%d runtimeParkingSpots=%d runtimeUniqueTerminalIDs=%d runtimeDuplicateIDs=%d unexpectedRuntimeIDs=%d",
  status,
  AIRBASE_NAME,
  total,
  mapped,
  missingSpots,
  #parkingSpots,
  runtimeUniqueIDs,
  runtimeDuplicateIDs,
  unexpectedRuntimeIDs
))
