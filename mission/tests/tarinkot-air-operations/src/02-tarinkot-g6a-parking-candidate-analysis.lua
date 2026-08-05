-- Operation Mountain Watch - Tarinkot G6A parking candidate analysis.
--
-- This stage is read-only. It does not construct AIRWING, SQUADRON, AUFTRAG,
-- COMMANDER, OPSTRANSPORT or SPAWN objects; it does not assign parking IDs,
-- activate groups, spawn aircraft or modify CampaignState/the MIZ.
--
-- MOOSE-first basis:
--   AIRBASE:GetParkingSpotsTable()
--   COORDINATE:ScanObjects()
--   POSITIONABLE:GetBoundingRadius()
--
-- The overlap test is the exact MOOSE 2.9.18 formula used internally by
-- AIRBASE:FindFreeParkingSpotForAircraft():
--   safe distance = (aircraftRadius + obstacleRadius) * 1.1

local TAG = "[OMW][AirOps.TKOT.G6A]"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G6A_BUILD or {}

local EXPECTED = {
  AirbaseID = 9,
  ParkingCount = 33,
  ScanRadiusM = 50,
  ClientTerminalIDs = {
    [3] = "CLIENT_US_TKOT_CH47F_01",
    [8] = "CLIENT_US_TKOT_AH64D_02",
    [20] = "CLIENT_US_TKOT_AH64D_01"
  },
  Families = {
    {
      Key = "AH64",
      TypeName = "AH-64D_BLK_II",
      TemplateGroup = "TPL_AIR_US_TKOT_AH64D_CAS_2SHIP",
      ClientUnit = "CLIENT_US_TKOT_AH64D_02_UNIT_01",
      StaticRepresentative = "STATIC_AIR_US_TKOT_AH64_01",
      RequiredSimultaneousSpots = 2
    },
    {
      Key = "UH60",
      TypeName = "UH-60A",
      TemplateGroup = "TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP",
      ClientUnit = nil,
      StaticRepresentative = "STATIC_AIR_US_TKOT_UH60_UTILITY_01",
      RequiredSimultaneousSpots = 2
    },
    {
      Key = "CH47",
      TypeName = "CH-47Fbl1",
      TemplateGroup = "TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP",
      ClientUnit = "CLIENT_US_TKOT_CH47F_01_UNIT_01",
      StaticRepresentative = nil,
      RequiredSimultaneousSpots = 1
    }
  },
  ClientUnits = {
    "CLIENT_US_TKOT_AH64D_01_UNIT_01",
    "CLIENT_US_TKOT_AH64D_02_UNIT_01",
    "CLIENT_US_TKOT_CH47F_01_UNIT_01"
  }
}

local function safe(label, callback)
  local ok, resultA, resultB, resultC, resultD = pcall(callback)
  if not ok then
    log("ERROR " .. label .. " exception=" .. tostring(resultA))
    return nil, nil, nil, nil, false
  end
  return resultA, resultB, resultC, resultD, true
end

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function terminalTypeAccepted(terminalType)
  return AIRBASE and AIRBASE._CheckTerminalType and
    AIRBASE._CheckTerminalType(terminalType, AIRBASE.TerminalType.HelicopterUsable) == true
end

local function getPositionableRadius(positionable)
  if not positionable then return nil end
  local radius = safe("GET_BOUNDING_RADIUS_" .. tostring(positionable:GetName()), function()
    return positionable:GetBoundingRadius(2)
  end)
  return tonumber(radius)
end

local function resolveFamilyRepresentative(family)
  local candidates = {}

  if family.TemplateGroup and GROUP then
    local group = GROUP:FindByName(family.TemplateGroup)
    if group then
      local unit = safe("TEMPLATE_GROUP_GET_UNIT_" .. family.Key, function()
        return group:GetUnit(1)
      end)
      if unit then
        candidates[#candidates + 1] = {
          Source = "template-group-unit",
          Name = unit:GetName(),
          Object = unit
        }
      end
    end
  end

  if family.ClientUnit and UNIT then
    local unit = UNIT:FindByName(family.ClientUnit)
    if unit then
      candidates[#candidates + 1] = {
        Source = "client-unit",
        Name = family.ClientUnit,
        Object = unit
      }
    end
  end

  if family.StaticRepresentative and STATIC then
    local static = STATIC:FindByName(family.StaticRepresentative, false)
    if static then
      candidates[#candidates + 1] = {
        Source = "static-representative",
        Name = family.StaticRepresentative,
        Object = static
      }
    end
  end

  for _, candidate in ipairs(candidates) do
    local radius = getPositionableRadius(candidate.Object)
    if radius and radius > 0 then
      local longest, length, height, width = safe("GET_OBJECT_SIZE_" .. family.Key, function()
        return candidate.Object:GetObjectSize()
      end)
      log(string.format(
        "MODEL family=%s type=%s source=%s name=%s radius=%.3f longest=%.3f length=%.3f height=%.3f width=%.3f",
        family.Key,
        family.TypeName,
        candidate.Source,
        candidate.Name,
        radius,
        tonumber(longest) or -1,
        tonumber(length) or -1,
        tonumber(height) or -1,
        tonumber(width) or -1
      ))
      return candidate.Object, radius, candidate.Source
    end
  end

  log(string.format(
    "MODEL_UNAVAILABLE family=%s type=%s template=%s clientUnit=%s static=%s",
    family.Key,
    family.TypeName,
    tostring(family.TemplateGroup),
    tostring(family.ClientUnit),
    tostring(family.StaticRepresentative)
  ))
  return nil, nil, nil
end

local function collectObstacles(spotCoordinate, scanRadius)
  local ok, scanResult1, scanResult2, scanResult3, units, statics = pcall(function()
    return spotCoordinate:ScanObjects(scanRadius, true, true, false)
  end)
  if not ok then
    log("ERROR SCAN_OBJECTS exception=" .. tostring(scanResult1))
    units = {}
    statics = {}
  end

  units = units or {}
  statics = statics or {}
  local obstacles = {}

  for _, unit in pairs(units) do
    local coord = safe("UNIT_COORDINATE", function() return unit:GetCoordinate() end)
    local radius = getPositionableRadius(unit)
    local distance = coord and distance2D(coord, spotCoordinate) or nil
    obstacles[#obstacles + 1] = {
      Kind = "UNIT",
      Name = safe("UNIT_NAME", function() return unit:GetName() end) or "unknown",
      TypeName = safe("UNIT_TYPE", function() return unit:GetTypeName() end) or "unknown",
      Radius = radius,
      Distance = distance
    }
  end

  for _, dcsStatic in pairs(statics) do
    local static = STATIC and STATIC:Find(dcsStatic) or nil
    if static then
      local coord = safe("STATIC_COORDINATE", function() return static:GetCoordinate() end)
      local radius = getPositionableRadius(static)
      local distance = coord and distance2D(coord, spotCoordinate) or nil
      obstacles[#obstacles + 1] = {
        Kind = "STATIC",
        Name = safe("STATIC_NAME", function() return static:GetName() end) or "unknown",
        TypeName = safe("STATIC_TYPE", function() return static:GetTypeName() end) or "unknown",
        Radius = radius,
        Distance = distance
      }
    end
  end

  table.sort(obstacles, function(left, right)
    local a = left.Distance or math.huge
    local b = right.Distance or math.huge
    if a == b then return tostring(left.Name) < tostring(right.Name) end
    return a < b
  end)

  return obstacles
end

local function obstacleSafe(aircraftRadius, obstacle)
  if not aircraftRadius then
    return false, nil
  end
  if not obstacle.Radius or not obstacle.Distance then
    return true, nil
  end
  local required = (aircraftRadius + obstacle.Radius) * 1.1
  return obstacle.Distance > required, required
end

local function playerClientCount()
  local count = 0
  for _, unitName in ipairs(EXPECTED.ClientUnits) do
    local unit = UNIT and UNIT:FindByName(unitName) or nil
    if unit then
      local playerName = safe("GET_PLAYER_NAME_" .. unitName, function()
        return unit:GetPlayerName()
      end)
      if playerName and tostring(playerName) ~= "" then
        count = count + 1
        log("ACTIVE_PLAYER_CLIENT unit=" .. unitName .. " player=" .. tostring(playerName))
      end
    end
  end
  log("ACTIVE_PLAYER_CLIENT_COUNT=" .. tostring(count))
  return count
end

local function main()
  log("BEGIN Tarinkot G6A parking candidate analysis")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder),
    tostring(build.BuilderVersion),
    tostring(build.GitCommit),
    tostring(build.GeneratedUtc)
  ))
  log("READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_ASSIGNMENT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0")
  log("MOOSE_PARKING_FORMULA safeDistance=(aircraftRadius+obstacleRadius)*1.1 scanRadiusM=" .. tostring(EXPECTED.ScanRadiusM))

  if not AIRBASE or not AIRBASE.TerminalType then
    log("RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=FAIL reason=AIRBASE_CLASS_UNAVAILABLE")
    return
  end

  local airbase = AIRBASE:FindByID(EXPECTED.AirbaseID)
  if not airbase then
    log("RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=FAIL reason=AIRBASE_ID_NOT_FOUND")
    return
  end

  local activePlayers = playerClientCount()
  local parking = airbase:GetParkingSpotsTable() or {}
  table.sort(parking, function(left, right)
    return tonumber(left.TerminalID) < tonumber(right.TerminalID)
  end)

  log(string.format(
    "AIRBASE name=%s id=%s parkingCount=%d expectedParkingCount=%d",
    tostring(airbase:GetName()),
    tostring(airbase:GetID()),
    #parking,
    EXPECTED.ParkingCount
  ))

  local familyData = {}
  local modelMissing = 0
  for _, family in ipairs(EXPECTED.Families) do
    local object, radius, source = resolveFamilyRepresentative(family)
    familyData[family.Key] = {
      Definition = family,
      Object = object,
      Radius = radius,
      Source = source,
      Candidates = {}
    }
    if not radius then modelMissing = modelMissing + 1 end
  end

  for _, spot in ipairs(parking) do
    local terminalID = tonumber(spot.TerminalID)
    local spotCoordinate = spot.Coordinate
    local reservedClient = EXPECTED.ClientTerminalIDs[terminalID]
    local acceptedType = terminalTypeAccepted(spot.TerminalType)
    local runtimeAvailable = spot.Free == true and spot.TOAC ~= true
    local obstacles = collectObstacles(spotCoordinate, EXPECTED.ScanRadiusM)

    local nearest = obstacles[1]
    log(string.format(
      "SPOT id=%s type=%s typeAccepted=%s free=%s toac=%s clientReservation=%s obstacleCount=%d nearestKind=%s nearestName=%s nearestType=%s nearestDistance=%.3f nearestRadius=%.3f",
      tostring(terminalID),
      tostring(spot.TerminalType),
      tostring(acceptedType),
      tostring(spot.Free),
      tostring(spot.TOAC),
      tostring(reservedClient or "none"),
      #obstacles,
      tostring(nearest and nearest.Kind or "none"),
      tostring(nearest and nearest.Name or "none"),
      tostring(nearest and nearest.TypeName or "none"),
      tonumber(nearest and nearest.Distance) or -1,
      tonumber(nearest and nearest.Radius) or -1
    ))

    for _, family in ipairs(EXPECTED.Families) do
      local data = familyData[family.Key]
      local candidate = data.Radius ~= nil and acceptedType and runtimeAvailable and reservedClient == nil
      local blocking = nil
      local requiredDistance = nil

      if candidate then
        for _, obstacle in ipairs(obstacles) do
          local safeFromObstacle, required = obstacleSafe(data.Radius, obstacle)
          if not safeFromObstacle then
            candidate = false
            blocking = obstacle
            requiredDistance = required
            break
          end
        end
      end

      if candidate then
        data.Candidates[#data.Candidates + 1] = terminalID
      end

      log(string.format(
        "FAMILY_SPOT family=%s id=%s candidate=%s aircraftRadius=%.3f blockKind=%s blockName=%s blockType=%s blockDistance=%.3f requiredDistance=%.3f",
        family.Key,
        tostring(terminalID),
        tostring(candidate),
        tonumber(data.Radius) or -1,
        tostring(blocking and blocking.Kind or "none"),
        tostring(blocking and blocking.Name or "none"),
        tostring(blocking and blocking.TypeName or "none"),
        tonumber(blocking and blocking.Distance) or -1,
        tonumber(requiredDistance) or -1
      ))
    end
  end

  local pairFailures = 0
  for _, family in ipairs(EXPECTED.Families) do
    local data = familyData[family.Key]
    table.sort(data.Candidates)
    local candidateLabels = {}
    for _, terminalID in ipairs(data.Candidates) do
      candidateLabels[#candidateLabels + 1] = tostring(terminalID)
    end
    log("CANDIDATES family=" .. family.Key .. " ids=" .. table.concat(candidateLabels, ","))

    local pairCount = 0
    if family.RequiredSimultaneousSpots >= 2 and data.Radius then
      local spotByID = {}
      for _, spot in ipairs(parking) do spotByID[tonumber(spot.TerminalID)] = spot end
      for leftIndex = 1, #data.Candidates - 1 do
        for rightIndex = leftIndex + 1, #data.Candidates do
          local leftID = data.Candidates[leftIndex]
          local rightID = data.Candidates[rightIndex]
          local leftSpot = spotByID[leftID]
          local rightSpot = spotByID[rightID]
          local distance = distance2D(leftSpot.Coordinate, rightSpot.Coordinate)
          local required = data.Radius * 2 * 1.1
          local safePair = distance and distance > required
          if safePair then
            pairCount = pairCount + 1
            log(string.format(
              "PAIR family=%s left=%d right=%d distance=%.3f requiredDistance=%.3f candidate=true",
              family.Key, leftID, rightID, distance, required
            ))
          end
        end
      end
      if pairCount == 0 then pairFailures = pairFailures + 1 end
    elseif family.RequiredSimultaneousSpots == 1 and #data.Candidates == 0 then
      pairFailures = pairFailures + 1
    end

    log(string.format(
      "FAMILY_SUMMARY family=%s modelAvailable=%s candidates=%d requiredSimultaneousSpots=%d validPairs=%d",
      family.Key,
      tostring(data.Radius ~= nil),
      #data.Candidates,
      family.RequiredSimultaneousSpots,
      pairCount
    ))
  end

  local status = "PASS_DATASET"
  local reason = "none"
  if activePlayers > 0 then
    status = "INVALID_ACTIVE_PLAYER_CLIENT"
    reason = "ACTIVE_PLAYER_CLIENT"
  elseif #parking ~= EXPECTED.ParkingCount then
    status = "FAIL"
    reason = "PARKING_COUNT_MISMATCH"
  elseif modelMissing > 0 then
    status = "PARTIAL"
    reason = "MODEL_RADIUS_UNAVAILABLE"
  elseif pairFailures > 0 then
    status = "PARTIAL"
    reason = "INSUFFICIENT_CANDIDATE_SET"
  end

  log(string.format(
    "RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=%s reason=%s parkingCount=%d modelMissing=%d candidateSetFailures=%d activePlayerClients=%d parkingMutation=0 spawns=0",
    status,
    reason,
    #parking,
    modelMissing,
    pairFailures,
    activePlayers
  ))
end

if not SCHEDULER then
  log("ERROR SCHEDULER class unavailable; analysis not scheduled")
else
  SCHEDULER:New(nil, main, {}, 8)
end
