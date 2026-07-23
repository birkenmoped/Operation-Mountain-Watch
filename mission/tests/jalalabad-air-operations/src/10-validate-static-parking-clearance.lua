-- Operation Mountain Watch - Jalalabad static-to-parking clearance validation
-- DCS does not mark a parking node occupied when a free-placed static overlaps it.
-- This gate prevents AIRWING activation when a static center is effectively on a
-- functional parking-node center.
local TAG = "[OMW][AirOps.JBAD.PARKING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local CLEARANCE_METERS = 8

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

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
  if not cfg then
    log("ERROR: Jalalabad configuration is unavailable.")
    return
  end

  local airbase = cfg.Airbase or (AIRBASE and AIRBASE:FindByName(cfg.AirbaseName))
  if not airbase then
    log("ERROR: Jalalabad airbase is unavailable.")
    return
  end

  local parkingSpots = airbase:GetParkingSpotsTable() or {}
  local staticNames = {}
  appendAll(staticNames, cfg.Statics and cfg.Statics.OH58D)
  appendAll(staticNames, cfg.Statics and cfg.Statics.AH64D)
  appendAll(staticNames, cfg.Statics and cfg.Statics.UH60)
  appendAll(staticNames, cfg.Statics and cfg.Statics.CH47)

  local violations = 0
  for _, staticName in ipairs(staticNames) do
    local static = STATIC and STATIC:FindByName(staticName, false) or nil
    if static then
      local staticCoordinate = static:GetCoordinate()
      local nearestDistance = nil
      local nearestTerminalID = nil

      for _, parking in ipairs(parkingSpots) do
        local distance = distance2D(staticCoordinate, parking.Coordinate)
        if distance and (not nearestDistance or distance < nearestDistance) then
          nearestDistance = distance
          nearestTerminalID = parking.TerminalID
        end
      end

      if nearestDistance and nearestDistance < CLEARANCE_METERS then
        violations = violations + 1
        log(string.format(
          "ERROR STATIC_PARKING_OVERLAP name=%s nearestTerminalID=%s distance=%.1fm minimum=%.1fm",
          staticName,
          tostring(nearestTerminalID),
          nearestDistance,
          CLEARANCE_METERS
        ))
      else
        log(string.format(
          "OK STATIC_PARKING_CLEARANCE name=%s nearestTerminalID=%s distance=%s minimum=%.1fm",
          staticName,
          tostring(nearestTerminalID),
          nearestDistance and string.format("%.1fm", nearestDistance) or "unknown",
          CLEARANCE_METERS
        ))
      end
    end
  end

  cfg.ParkingClearanceOK = violations == 0
  if violations > 0 then
    -- The complete-node finalizer already uses CorrectionPending.CH47 as an
    -- activation gate. The current observed overlaps are on the CH-47 ramp, so
    -- re-use that gate after CH-47 construction has completed.
    cfg.CorrectionPending = cfg.CorrectionPending or {}
    cfg.CorrectionPending.CH47 = true
    cfg.CorrectionPending.Reason = "Static aircraft overlap functional DCS parking nodes."
    log(string.format(
      "RESULT: FAIL staticParkingOverlapCount=%d clearance=%.1fm AIRWING_START_BLOCKED=true",
      violations,
      CLEARANCE_METERS
    ))
    return
  end

  log(string.format(
    "RESULT: PASS staticParkingOverlapCount=0 clearance=%.1fm AIRWING_START_BLOCKED=false",
    CLEARANCE_METERS
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
