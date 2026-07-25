-- Operation Mountain Watch - Jalalabad static parking reservation validation
-- Some visible CH-47 statics intentionally occupy real DCS parking nodes because
-- the heavy-lift ramp has no credible alternative placement. Those terminal IDs
-- must be blacklisted so MOOSE never treats the apparently free nodes as spawn spots.
local TAG = "[OMW][AirOps.JBAD.PARKING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local ALIGNMENT_TOLERANCE_METERS = 8
local NON_RESERVED_CLEARANCE_METERS = 8

local function appendAll(target, source)
  for _, value in ipairs(source or {}) do
    target[#target + 1] = value
  end
end

local function distance2D(firstCoordinate, secondCoordinate)
  local first = firstCoordinate and firstCoordinate:GetVec3() or nil
  local second = secondCoordinate and secondCoordinate:GetVec3() or nil
  if not first or not second then return nil end
  local dx = (first.x or 0) - (second.x or 0)
  local dz = (first.z or 0) - (second.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function joinNumbers(values)
  local text = {}
  for _, value in ipairs(values or {}) do
    text[#text + 1] = tostring(value)
  end
  return table.concat(text, ",")
end

local function blockStart(cfg, reason)
  cfg.ParkingReservationsOK = false
  cfg.CorrectionPending = cfg.CorrectionPending or {}
  cfg.CorrectionPending.CH47 = true
  cfg.CorrectionPending.Reason = reason
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR: Jalalabad configuration is unavailable.")
    return
  end

  local airbase = cfg.Airbase or (AIRBASE and AIRBASE:FindByName(cfg.AirbaseName))
  if not airbase then
    log("ERROR: Jalalabad airbase is unavailable.")
    blockStart(cfg, "Jalalabad airbase unavailable during static parking reservation validation.")
    return
  end

  local parking = cfg.Parking or {}
  local reservations = parking.StaticParkingReservations or {}
  local blacklist = parking.StaticParkingBlacklist or {}

  if airbase.SetParkingSpotBlacklist then
    airbase:SetParkingSpotBlacklist(blacklist)
  else
    log("ERROR: AIRBASE:SetParkingSpotBlacklist is unavailable.")
    blockStart(cfg, "MOOSE parking blacklist API unavailable.")
    return
  end

  if cfg.Airwing and cfg.Airwing.SetSafeParkingOn then
    cfg.Airwing:SetSafeParkingOn()
  end

  local parkingSpots = airbase:GetParkingSpotsTable() or {}
  local staticNames = {}
  appendAll(staticNames, cfg.Statics and cfg.Statics.OH58D)
  appendAll(staticNames, cfg.Statics and cfg.Statics.AH64D)
  appendAll(staticNames, cfg.Statics and cfg.Statics.UH60)
  appendAll(staticNames, cfg.Statics and cfg.Statics.CH47)

  local violations = 0
  local confirmedReservations = 0

  for _, staticName in ipairs(staticNames) do
    local static = STATIC and STATIC:FindByName(staticName, false) or nil
    if static then
      local staticCoordinate = static:GetCoordinate()
      local nearestDistance = nil
      local nearestTerminalID = nil

      for _, spot in ipairs(parkingSpots) do
        local distance = distance2D(staticCoordinate, spot.Coordinate)
        if distance and (not nearestDistance or distance < nearestDistance) then
          nearestDistance = distance
          nearestTerminalID = spot.TerminalID
        end
      end

      local expectedTerminalID = reservations[staticName]
      if expectedTerminalID then
        if nearestTerminalID == expectedTerminalID and nearestDistance and nearestDistance <= ALIGNMENT_TOLERANCE_METERS then
          confirmedReservations = confirmedReservations + 1
          log(string.format(
            "OK STATIC_PARKING_RESERVED name=%s TerminalID=%s distance=%.1fm blacklisted=true",
            staticName,
            tostring(nearestTerminalID),
            nearestDistance
          ))
        else
          violations = violations + 1
          log(string.format(
            "ERROR STATIC_PARKING_RESERVATION_MISMATCH name=%s expectedTerminalID=%s nearestTerminalID=%s distance=%s tolerance=%.1fm",
            staticName,
            tostring(expectedTerminalID),
            tostring(nearestTerminalID),
            nearestDistance and string.format("%.1fm", nearestDistance) or "unknown",
            ALIGNMENT_TOLERANCE_METERS
          ))
        end
      elseif nearestDistance and nearestDistance < NON_RESERVED_CLEARANCE_METERS then
        violations = violations + 1
        log(string.format(
          "ERROR UNDECLARED_STATIC_PARKING_OVERLAP name=%s nearestTerminalID=%s distance=%.1fm minimum=%.1fm",
          staticName,
          tostring(nearestTerminalID),
          nearestDistance,
          NON_RESERVED_CLEARANCE_METERS
        ))
      else
        log(string.format(
          "OK STATIC_PARKING_CLEAR name=%s nearestTerminalID=%s distance=%s minimum=%.1fm",
          staticName,
          tostring(nearestTerminalID),
          nearestDistance and string.format("%.1fm", nearestDistance) or "unknown",
          NON_RESERVED_CLEARANCE_METERS
        ))
      end
    end
  end

  cfg.ParkingReservationsOK = violations == 0 and confirmedReservations == parking.CH47DCSNodeReservations
  if not cfg.ParkingReservationsOK then
    blockStart(cfg, "Static parking reservation validation failed.")
    log(string.format(
      "RESULT: FAIL intentionalReservationsConfirmed=%d expected=%s violations=%d blacklistedTerminalIDs=%s AIRWING_START_BLOCKED=true",
      confirmedReservations,
      tostring(parking.CH47DCSNodeReservations),
      violations,
      joinNumbers(blacklist)
    ))
    return
  end

  log(string.format(
    "RESULT: PASS intentionalReservationsConfirmed=%d blacklistedTerminalIDs=%s ch47VisualPositionsRemaining=%s unexpectedOverlaps=0 AIRWING_START_BLOCKED=false",
    confirmedReservations,
    joinNumbers(blacklist),
    tostring(parking.CH47RemainingVisualPositions)
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 17)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 17)
end
