-- Operation Mountain Watch - Kandahar UAV G-apron calibration.
-- Maps seven Mission Editor calibration markers to native Kandahar runtime TerminalIDs.
-- Requires registration and parking-contract preflights. Does not start AIRWINGs or spawn assets.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVGApronCalibration]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local MARKERS = {
  { Label = "G01", Group = "CAL_AIR_US_KAF_UAV_G01" },
  { Label = "G04", Group = "CAL_AIR_US_KAF_UAV_G04" },
  { Label = "G05", Group = "CAL_AIR_US_KAF_UAV_G05" },
  { Label = "G07", Group = "CAL_AIR_US_KAF_UAV_G07" },
  { Label = "G08", Group = "CAL_AIR_US_KAF_UAV_G08" },
  { Label = "G10", Group = "CAL_AIR_US_KAF_UAV_G10" },
  { Label = "G11", Group = "CAL_AIR_US_KAF_UAV_G11" }
}

local EXPECTED_AIRBASE_ID = 7
local MAX_COORDINATE_DELTA_METERS = 5
local violations = 0

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function spotVec2(spot)
  if not spot or not spot.Coordinate or not spot.Coordinate.GetVec3 then return nil end
  local vec3 = spot.Coordinate:GetVec3()
  if not vec3 then return nil end
  return { x = tonumber(vec3.x), y = tonumber(vec3.z) }
end

local function distance2D(a, b)
  if not a or not b or not a.x or not a.y or not b.x or not b.y then return nil end
  local dx = a.x - b.x
  local dy = a.y - b.y
  return math.sqrt(dx * dx + dy * dy)
end

local function extractMarkerCoordinate(template)
  local unit = template and template.units and template.units[1] or nil
  if unit and tonumber(unit.x) and tonumber(unit.y) then
    return { x = tonumber(unit.x), y = tonumber(unit.y) }, "unit"
  end

  local point = template and template.route and template.route.points and template.route.points[1] or nil
  if point and tonumber(point.x) and tonumber(point.y) then
    return { x = tonumber(point.x), y = tonumber(point.y) }, "route"
  end

  return nil, "none"
end

local function extractParkingFields(template)
  local unit = template and template.units and template.units[1] or {}
  local point = template and template.route and template.route.points and template.route.points[1] or {}
  return {
    UnitParking = unit.parking,
    UnitParkingId = unit.parking_id,
    UnitParkingIdAlt = unit.parkingId,
    RouteParking = point.parking,
    RouteParkingId = point.parking_id,
    RouteParkingIdAlt = point.parkingId,
    AirdromeId = point.airdromeId or point.airdrome_id
  }
end

local function nearestSpots(markerCoordinate, spots)
  local nearest, second = nil, nil
  for _, spot in ipairs(spots or {}) do
    local coordinate = spotVec2(spot)
    local distance = distance2D(markerCoordinate, coordinate)
    if distance then
      local candidate = { Spot = spot, Distance = distance }
      if not nearest or distance < nearest.Distance then
        second = nearest
        nearest = candidate
      elseif not second or distance < second.Distance then
        second = candidate
      end
    end
  end
  return nearest, second
end

local function sameNumericSet(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" then return false end
  local a, e = {}, {}
  for _, value in ipairs(actual) do a[tonumber(value)] = true end
  for _, value in ipairs(expected) do e[tonumber(value)] = true end
  for value in pairs(a) do if not e[value] then return false end end
  for value in pairs(e) do if not a[value] then return false end end
  return true
end

local function main()
  log("BEGIN mode=marker-to-runtime-terminal calibration=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true")

  if OMW.AirOps.KandaharUAVGApronCalibration then
    log("RESULT: FAIL reason=CALIBRATION_ALREADY_EXECUTED noStart=true noSpawn=true")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  local parking = OMW.AirOps.KandaharParkingContractPreflight
  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_PREFLIGHT_NOT_PASSED noStart=true noSpawn=true")
    return
  end
  if not parking or parking.Applied ~= true or tonumber(parking.Violations) ~= 0 then
    log("RESULT: FAIL reason=PARKING_CONTRACT_NOT_PASSED noStart=true noSpawn=true")
    return
  end

  local mainAirwing = registration.Airwings and registration.Airwings.Main or nil
  local mainContract = parking.Contracts and parking.Contracts.Main or nil
  local mainAirbase = mainContract and mainContract.Airbase or nil
  if not mainAirwing or not mainContract or not mainAirbase then
    log("RESULT: FAIL reason=MAIN_CONTRACT_UNAVAILABLE noStart=true noSpawn=true")
    return
  end

  if tonumber(mainAirbase:GetID()) ~= EXPECTED_AIRBASE_ID then
    log("RESULT: FAIL reason=MAIN_AIRBASE_ID_MISMATCH noStart=true noSpawn=true")
    return
  end

  if mainAirwing.IsRunning and mainAirwing:IsRunning() then
    log("RESULT: FAIL reason=MAIN_AIRWING_ALREADY_RUNNING noStart=true noSpawn=true")
    return
  end

  local spots = mainAirbase:GetParkingSpotsTable() or {}
  local mappedIDs = {}
  local mapping = {}
  local seenIDs = {}

  for _, marker in ipairs(MARKERS) do
    local template = _DATABASE:GetGroupTemplate(marker.Group)
    if not template then
      fail("MARKER_TEMPLATE_MISSING label=" .. marker.Label .. " group=" .. marker.Group)
    else
      if template.lateActivation ~= true then
        fail("MARKER_NOT_LATE_ACTIVATION label=" .. marker.Label .. " group=" .. marker.Group)
      end
      if not template.units or #template.units ~= 1 then
        fail("MARKER_GROUP_SIZE_MISMATCH label=" .. marker.Label .. " expected=1 actual=" .. tostring(template.units and #template.units or 0))
      end

      local coordinate, coordinateSource = extractMarkerCoordinate(template)
      if not coordinate then
        fail("MARKER_COORDINATE_MISSING label=" .. marker.Label .. " group=" .. marker.Group)
      else
        local nearest, second = nearestSpots(coordinate, spots)
        if not nearest or not nearest.Spot then
          fail("RUNTIME_TERMINAL_UNRESOLVED label=" .. marker.Label)
        else
          local terminalID = tonumber(nearest.Spot.TerminalID)
          local terminalID0 = tonumber(nearest.Spot.TerminalID0)
          local terminalType = tonumber(nearest.Spot.TerminalType)
          local secondDistance = second and tonumber(second.Distance) or -1
          local fields = extractParkingFields(template)

          if not terminalID then
            fail("RUNTIME_TERMINAL_ID_MISSING label=" .. marker.Label)
          elseif seenIDs[terminalID] then
            fail(string.format("DUPLICATE_RUNTIME_TERMINAL label=%s terminalID=%d previousLabel=%s", marker.Label, terminalID, seenIDs[terminalID]))
          else
            seenIDs[terminalID] = marker.Label
            mappedIDs[#mappedIDs + 1] = terminalID
          end

          if tonumber(nearest.Distance) > MAX_COORDINATE_DELTA_METERS then
            fail(string.format("MARKER_TOO_FAR_FROM_TERMINAL label=%s terminalID=%s distance=%.2f max=%d", marker.Label, tostring(terminalID), tonumber(nearest.Distance), MAX_COORDINATE_DELTA_METERS))
          end

          if terminalID and mainContract.Blocked and mainContract.Blocked[terminalID] then
            fail(string.format("MAPPED_TERMINAL_BLOCKED label=%s terminalID=%d", marker.Label, terminalID))
          end

          local allowed = false
          for _, allowedID in ipairs(mainContract.AllowedIDs or {}) do
            if tonumber(allowedID) == terminalID then
              allowed = true
              break
            end
          end
          if not allowed then
            fail(string.format("MAPPED_TERMINAL_NOT_IN_MAIN_ALLOWLIST label=%s terminalID=%s", marker.Label, tostring(terminalID)))
          end

          if fields.AirdromeId and tonumber(fields.AirdromeId) ~= EXPECTED_AIRBASE_ID then
            fail(string.format("MARKER_AIRDROME_MISMATCH label=%s expected=%d actual=%s", marker.Label, EXPECTED_AIRBASE_ID, tostring(fields.AirdromeId)))
          end

          mapping[marker.Label] = {
            Group = marker.Group,
            RuntimeTerminalID = terminalID,
            RuntimeTerminalID0 = terminalID0,
            RuntimeTerminalType = terminalType,
            CoordinateDelta = tonumber(nearest.Distance),
            SecondNearestDelta = secondDistance,
            CoordinateSource = coordinateSource,
            MissionParking = fields
          }

          log(string.format(
            "MAP label=%s group=%s runtimeTerminalID=%s runtimeTerminalID0=%s terminalType=%s coordinateDelta=%.2f secondNearestDelta=%.2f coordinateSource=%s unitParking=%s unitParkingId=%s unitParkingIdAlt=%s routeParking=%s routeParkingId=%s routeParkingIdAlt=%s airdromeId=%s allowed=%s blocked=%s",
            marker.Label,
            marker.Group,
            tostring(terminalID),
            tostring(terminalID0),
            tostring(terminalType),
            tonumber(nearest.Distance) or -1,
            secondDistance,
            coordinateSource,
            tostring(fields.UnitParking),
            tostring(fields.UnitParkingId),
            tostring(fields.UnitParkingIdAlt),
            tostring(fields.RouteParking),
            tostring(fields.RouteParkingId),
            tostring(fields.RouteParkingIdAlt),
            tostring(fields.AirdromeId),
            tostring(allowed),
            tostring(terminalID and mainContract.Blocked and mainContract.Blocked[terminalID] == true or false)
          ))
        end
      end
    end
  end

  table.sort(mappedIDs)

  local mq1 = registration.Squadrons and registration.Squadrons["SQ_US_KAF_MQ1_361_ERS"] or nil
  local mq9 = registration.Squadrons and registration.Squadrons["SQ_US_KAF_MQ9_361_ERS"] or nil
  if not mq1 or not mq9 then
    fail("UAV_SQUADRONS_UNAVAILABLE")
  end

  if violations == 0 then
    mq1:SetParkingIDs(mappedIDs)
    mq9:SetParkingIDs(mappedIDs)

    if not sameNumericSet(mq1.parkingIDs, mappedIDs) then
      fail("MQ1_SQUADRON_PARKING_IDS_MISMATCH")
    end
    if not sameNumericSet(mq9.parkingIDs, mappedIDs) then
      fail("MQ9_SQUADRON_PARKING_IDS_MISMATCH")
    end
  end

  OMW.AirOps.KandaharUAVGApronCalibration = {
    Labels = { "G01", "G04", "G05", "G07", "G08", "G10", "G11" },
    Mapping = mapping,
    RuntimeTerminalIDs = mappedIDs,
    Violations = violations,
    AppliedToSquadrons = violations == 0,
    Started = false
  }

  if violations == 0 then
    log(string.format(
      "RESULT: PASS labels=7 mapped=7 runtimeTerminalIDs=%s mq1Restricted=true mq9Restricted=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      table.concat(mappedIDs, ",")
    ))
  else
    log(string.format(
      "RESULT: FAIL violations=%d labels=7 mapped=%d noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      violations,
      #mappedIDs
    ))
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 24)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 24)
end
