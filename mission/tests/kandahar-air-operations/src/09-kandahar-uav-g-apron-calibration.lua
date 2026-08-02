-- Operation Mountain Watch - Kandahar UAV G-apron calibration.
-- Maps all eleven Mission Editor G-apron positions to native Kandahar runtime TerminalIDs.
-- Applies separate MQ-1 and MQ-9 squadron parking pools after intersecting them with the accepted Main parking contract.
-- Requires registration and parking-contract preflights. Does not start AIRWINGs or spawn assets.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVGApronCalibration]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local SOURCE = {
  Artifact = "OMW_Template_v4_Kandahar(9).miz",
  SizeBytes = 2191639,
  Sha256 = "47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c"
}

local MARKER_GROUPS = {
  "CAL_AIR_US_KAF_UAV_G01",
  "CAL_AIR_US_KAF_UAV_G02",
  "CAL_AIR_US_KAF_UAV_G03",
  "CAL_AIR_US_KAF_UAV_G04",
  "CAL_AIR_US_KAF_UAV_G05",
  "CAL_AIR_US_KAF_UAV_G06",
  "CAL_AIR_US_KAF_UAV_G07",
  "CAL_AIR_US_KAF_UAV_G08",
  "CAL_AIR_US_KAF_UAV_G09",
  "CAL_AIR_US_KAF_UAV_G10",
  "CAL_AIR_US_KAF_UAV_G11"
}

local LABEL_POLICY = {
  G01 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G02 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G03 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G04 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G05 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G06 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G07 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G08 = { Pool = "MQ1", ExpectedType = "RQ-1A Predator" },
  G09 = { Pool = "MQ9", ExpectedType = "MQ-9 Reaper" },
  G10 = { Pool = "MQ9", ExpectedType = "MQ-9 Reaper" },
  G11 = { Pool = "MQ9", ExpectedType = "MQ-9 Reaper" }
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
    UnitType = unit.type,
    UnitParking = unit.parking,
    UnitParkingId = unit.parking_id,
    UnitParkingIdAlt = unit.parkingId,
    RouteParking = point.parking,
    RouteParkingId = point.parking_id,
    RouteParkingIdAlt = point.parkingId,
    AirdromeId = point.airdromeId or point.airdrome_id
  }
end

local function resolveLabel(fields)
  return tostring(
    fields.UnitParkingId
      or fields.UnitParkingIdAlt
      or fields.RouteParkingId
      or fields.RouteParkingIdAlt
      or ""
  )
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

local function containsNumeric(values, expected)
  for _, value in ipairs(values or {}) do
    if tonumber(value) == tonumber(expected) then
      return true
    end
  end
  return false
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

local function sortedNumericCopy(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[#result + 1] = tonumber(value)
  end
  table.sort(result)
  return result
end

local function main()
  log(string.format(
    "BEGIN mode=marker-to-runtime-terminal calibration=true sourceArtifact=%s sourceSize=%d sourceSha256=%s noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
    SOURCE.Artifact,
    SOURCE.SizeBytes,
    SOURCE.Sha256
  ))

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
  local mapping = {}
  local seenLabels = {}
  local seenIDs = {}
  local mq1MappedIDs = {}
  local mq9MappedIDs = {}
  local mq1AvailableIDs = {}
  local mq9AvailableIDs = {}
  local unavailableLabels = {}

  for _, groupName in ipairs(MARKER_GROUPS) do
    local template = _DATABASE:GetGroupTemplate(groupName)
    if not template then
      fail("MARKER_TEMPLATE_MISSING group=" .. groupName)
    else
      if template.lateActivation ~= true then
        fail("MARKER_NOT_LATE_ACTIVATION group=" .. groupName)
      end
      if not template.units or #template.units ~= 1 then
        fail("MARKER_GROUP_SIZE_MISMATCH group=" .. groupName .. " expected=1 actual=" .. tostring(template.units and #template.units or 0))
      end

      local fields = extractParkingFields(template)
      local label = resolveLabel(fields)
      local policy = LABEL_POLICY[label]
      if not policy then
        fail("UNAPPROVED_OR_MISSING_PARKING_LABEL group=" .. groupName .. " label=" .. tostring(label))
      elseif seenLabels[label] then
        fail(string.format("DUPLICATE_PARKING_LABEL label=%s group=%s previousGroup=%s", label, groupName, seenLabels[label]))
      else
        seenLabels[label] = groupName
      end

      if policy and tostring(fields.UnitType) ~= tostring(policy.ExpectedType) then
        fail(string.format(
          "MARKER_TYPE_MISMATCH label=%s group=%s expected=%s actual=%s",
          label,
          groupName,
          policy.ExpectedType,
          tostring(fields.UnitType)
        ))
      end

      local coordinate, coordinateSource = extractMarkerCoordinate(template)
      if not coordinate then
        fail("MARKER_COORDINATE_MISSING group=" .. groupName .. " label=" .. tostring(label))
      else
        local nearest, second = nearestSpots(coordinate, spots)
        if not nearest or not nearest.Spot then
          fail("RUNTIME_TERMINAL_UNRESOLVED group=" .. groupName .. " label=" .. tostring(label))
        else
          local terminalID = tonumber(nearest.Spot.TerminalID)
          local terminalID0 = tonumber(nearest.Spot.TerminalID0)
          local terminalType = tonumber(nearest.Spot.TerminalType)
          local secondDistance = second and tonumber(second.Distance) or -1
          local missionParking = tonumber(fields.UnitParking or fields.RouteParking)

          if not terminalID then
            fail("RUNTIME_TERMINAL_ID_MISSING group=" .. groupName .. " label=" .. tostring(label))
          elseif seenIDs[terminalID] then
            fail(string.format("DUPLICATE_RUNTIME_TERMINAL label=%s terminalID=%d previousLabel=%s", tostring(label), terminalID, seenIDs[terminalID]))
          else
            seenIDs[terminalID] = label
          end

          if tonumber(nearest.Distance) > MAX_COORDINATE_DELTA_METERS then
            fail(string.format("MARKER_TOO_FAR_FROM_TERMINAL label=%s terminalID=%s distance=%.2f max=%d", tostring(label), tostring(terminalID), tonumber(nearest.Distance), MAX_COORDINATE_DELTA_METERS))
          end

          if fields.AirdromeId and tonumber(fields.AirdromeId) ~= EXPECTED_AIRBASE_ID then
            fail(string.format("MARKER_AIRDROME_MISMATCH label=%s expected=%d actual=%s", tostring(label), EXPECTED_AIRBASE_ID, tostring(fields.AirdromeId)))
          end

          if missionParking and terminalID and missionParking ~= terminalID then
            fail(string.format(
              "MISSION_PARKING_RUNTIME_ID_MISMATCH label=%s missionParking=%d runtimeTerminalID=%d",
              tostring(label),
              missionParking,
              terminalID
            ))
          end

          local blocked = terminalID and mainContract.Blocked and mainContract.Blocked[terminalID] == true or false
          local allowed = terminalID and containsNumeric(mainContract.AllowedIDs, terminalID) or false
          local available = terminalID ~= nil and allowed and not blocked

          if policy and terminalID then
            if policy.Pool == "MQ1" then
              mq1MappedIDs[#mq1MappedIDs + 1] = terminalID
              if available then mq1AvailableIDs[#mq1AvailableIDs + 1] = terminalID end
            elseif policy.Pool == "MQ9" then
              mq9MappedIDs[#mq9MappedIDs + 1] = terminalID
              if available then mq9AvailableIDs[#mq9AvailableIDs + 1] = terminalID end
            end
          end

          if not available then
            unavailableLabels[#unavailableLabels + 1] = tostring(label)
          end

          mapping[label] = {
            Group = groupName,
            Pool = policy and policy.Pool or "UNRESOLVED",
            MarkerType = fields.UnitType,
            MissionParking = missionParking,
            RuntimeTerminalID = terminalID,
            RuntimeTerminalID0 = terminalID0,
            RuntimeTerminalType = terminalType,
            CoordinateDelta = tonumber(nearest.Distance),
            SecondNearestDelta = secondDistance,
            CoordinateSource = coordinateSource,
            AirdromeId = fields.AirdromeId,
            Allowed = allowed,
            Blocked = blocked,
            Available = available
          }

          log(string.format(
            "MAP label=%s sourceGroup=%s pool=%s markerType=%s missionParking=%s runtimeTerminalID=%s runtimeTerminalID0=%s terminalType=%s coordinateDelta=%.2f secondNearestDelta=%.2f coordinateSource=%s airdromeId=%s allowed=%s blocked=%s available=%s",
            tostring(label),
            groupName,
            policy and policy.Pool or "UNRESOLVED",
            tostring(fields.UnitType),
            tostring(missionParking),
            tostring(terminalID),
            tostring(terminalID0),
            tostring(terminalType),
            tonumber(nearest.Distance) or -1,
            secondDistance,
            coordinateSource,
            tostring(fields.AirdromeId),
            tostring(allowed),
            tostring(blocked),
            tostring(available)
          ))
        end
      end
    end
  end

  for label in pairs(LABEL_POLICY) do
    if not seenLabels[label] then
      fail("REQUIRED_LABEL_NOT_MAPPED label=" .. label)
    end
  end

  mq1MappedIDs = sortedNumericCopy(mq1MappedIDs)
  mq9MappedIDs = sortedNumericCopy(mq9MappedIDs)
  mq1AvailableIDs = sortedNumericCopy(mq1AvailableIDs)
  mq9AvailableIDs = sortedNumericCopy(mq9AvailableIDs)
  table.sort(unavailableLabels)

  if #mq1MappedIDs ~= 8 then
    fail("MQ1_MAPPED_POOL_SIZE_MISMATCH expected=8 actual=" .. tostring(#mq1MappedIDs))
  end
  if #mq9MappedIDs ~= 3 then
    fail("MQ9_MAPPED_POOL_SIZE_MISMATCH expected=3 actual=" .. tostring(#mq9MappedIDs))
  end
  if #mq1AvailableIDs < 1 then
    fail("MQ1_NO_AVAILABLE_G_APRON_POSITION")
  end
  if #mq9AvailableIDs < 1 then
    fail("MQ9_NO_AVAILABLE_G_APRON_POSITION")
  end

  local mq1 = registration.Squadrons and registration.Squadrons["SQ_US_KAF_MQ1_361_ERS"] or nil
  local mq9 = registration.Squadrons and registration.Squadrons["SQ_US_KAF_MQ9_361_ERS"] or nil
  if not mq1 or not mq9 then
    fail("UAV_SQUADRONS_UNAVAILABLE")
  end

  if violations == 0 then
    mq1:SetParkingIDs(mq1AvailableIDs)
    mq9:SetParkingIDs(mq9AvailableIDs)

    if not sameNumericSet(mq1.parkingIDs, mq1AvailableIDs) then
      fail("MQ1_SQUADRON_PARKING_IDS_MISMATCH")
    end
    if not sameNumericSet(mq9.parkingIDs, mq9AvailableIDs) then
      fail("MQ9_SQUADRON_PARKING_IDS_MISMATCH")
    end
  end

  OMW.AirOps.KandaharUAVGApronCalibration = {
    Source = SOURCE,
    Labels = { "G01", "G02", "G03", "G04", "G05", "G06", "G07", "G08", "G09", "G10", "G11" },
    Mapping = mapping,
    MQ1MappedTerminalIDs = mq1MappedIDs,
    MQ9MappedTerminalIDs = mq9MappedIDs,
    MQ1AvailableTerminalIDs = mq1AvailableIDs,
    MQ9AvailableTerminalIDs = mq9AvailableIDs,
    UnavailableLabels = unavailableLabels,
    Violations = violations,
    AppliedToSquadrons = violations == 0,
    Started = false
  }

  if violations == 0 then
    log(string.format(
      "RESULT: PASS labels=11 mapped=11 mq1Labels=8 mq1Available=%d mq1TerminalIDs=%s mq9Labels=3 mq9Available=%d mq9TerminalIDs=%s unavailableLabels=%s mq1Restricted=true mq9Restricted=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      #mq1AvailableIDs,
      table.concat(mq1AvailableIDs, ","),
      #mq9AvailableIDs,
      table.concat(mq9AvailableIDs, ","),
      #unavailableLabels > 0 and table.concat(unavailableLabels, ",") or "none"
    ))
  else
    log(string.format(
      "RESULT: FAIL violations=%d labels=11 mapped=%d mq1Mapped=%d mq1Available=%d mq9Mapped=%d mq9Available=%d unavailableLabels=%s noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      violations,
      #mq1MappedIDs + #mq9MappedIDs,
      #mq1MappedIDs,
      #mq1AvailableIDs,
      #mq9MappedIDs,
      #mq9AvailableIDs,
      #unavailableLabels > 0 and table.concat(unavailableLabels, ",") or "none"
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
