-- Operation Mountain Watch - Tarinkot G6A2 ME parking to MOOSE TerminalID map.
--
-- Read-only mapping pass. No group activation, no spawn, no AIRWING/SQUADRON,
-- no parking assignment and no MIZ mutation.
--
-- Mapping anchors are late-activation aircraft whose group or unit name starts
-- with TKOT_PARKMAP_ME_. The suffix is treated as the Mission Editor parking
-- identifier. The unit position stored in env.mission is matched to the nearest
-- MOOSE parking coordinate from AIRBASE:GetParkingSpotsTable().

local TAG = "[OMW][AirOps.TKOT.G6A2.PARKMAP]"
local PREFIX = "TKOT_PARKMAP_ME_"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G6A2_PARKMAP_BUILD or {}

local EXPECTED = {
  AirbaseID = 9,
  ParkingCount = 33,
  MaxAcceptedDistanceM = 5.0,
  AmbiguityDeltaM = 0.25,
  ClientReferences = {
    { Name = "CLIENT_US_TKOT_AH64D_01", MEParking = "20", MooseTerminalID = 20 },
    { Name = "CLIENT_US_TKOT_AH64D_02", MEParking = "8", MooseTerminalID = 8 },
    { Name = "CLIENT_US_TKOT_CH47F_01", MEParking = "3", MooseTerminalID = 3 }
  }
}

local function startsWith(value, prefix)
  return type(value) == "string" and value:sub(1, #prefix) == prefix
end

local function suffix(value)
  if not startsWith(value, PREFIX) then return nil end
  local result = value:sub(#PREFIX + 1)
  return result ~= "" and result or nil
end

local function distance2D(ax, az, bx, bz)
  local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
  local dz = (tonumber(az) or 0) - (tonumber(bz) or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function collectMissionAnchors()
  local anchors = {}
  local seen = {}
  local mission = env and env.mission or nil
  local coalitions = mission and mission.coalition or nil

  if type(coalitions) ~= "table" then
    return anchors, "MISSION_COALITION_UNAVAILABLE"
  end

  for coalitionName, coalitionData in pairs(coalitions) do
    if type(coalitionData) == "table" and type(coalitionData.country) == "table" then
      for _, country in pairs(coalitionData.country) do
        if type(country) == "table" then
          for categoryName, category in pairs(country) do
            if type(category) == "table" and type(category.group) == "table" then
              for _, group in pairs(category.group) do
                if type(group) == "table" and type(group.units) == "table" then
                  local groupName = group.name
                  local groupME = suffix(groupName)
                  for unitIndex, unit in pairs(group.units) do
                    if type(unit) == "table" then
                      local unitName = unit.name
                      local unitME = suffix(unitName)
                      local meParking = unitME or groupME
                      if meParking then
                        local key = tostring(groupName) .. "|" .. tostring(unitName)
                        if not seen[key] then
                          seen[key] = true
                          anchors[#anchors + 1] = {
                            Coalition = tostring(coalitionName),
                            Country = tostring(country.name or country.id or "unknown"),
                            Category = tostring(categoryName),
                            GroupName = tostring(groupName or "none"),
                            UnitName = tostring(unitName or "none"),
                            MEParking = tostring(meParking),
                            UnitIndex = tonumber(unitIndex) or -1,
                            LateActivation = group.lateActivation == true,
                            X = tonumber(unit.x),
                            Z = tonumber(unit.y),
                            ParkingField = unit.parking,
                            TypeName = tostring(unit.type or "unknown")
                          }
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  table.sort(anchors, function(a, b)
    local an = tonumber(a.MEParking)
    local bn = tonumber(b.MEParking)
    if an and bn and an ~= bn then return an < bn end
    if a.MEParking ~= b.MEParking then return a.MEParking < b.MEParking end
    if a.GroupName ~= b.GroupName then return a.GroupName < b.GroupName end
    return a.UnitName < b.UnitName
  end)

  return anchors, nil
end

local function nearestParking(anchor, parking)
  local ranked = {}
  for _, spot in ipairs(parking or {}) do
    local vec = spot.Coordinate and spot.Coordinate:GetVec3() or nil
    if vec then
      ranked[#ranked + 1] = {
        Spot = spot,
        X = tonumber(vec.x),
        Z = tonumber(vec.z),
        Distance = distance2D(anchor.X, anchor.Z, vec.x, vec.z)
      }
    end
  end

  table.sort(ranked, function(a, b)
    if a.Distance == b.Distance then
      return tonumber(a.Spot.TerminalID) < tonumber(b.Spot.TerminalID)
    end
    return a.Distance < b.Distance
  end)

  return ranked[1], ranked[2]
end

local function main()
  log("BEGIN Tarinkot G6A2 ME parking map")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder), tostring(build.BuilderVersion),
    tostring(build.GitCommit), tostring(build.GeneratedUtc)
  ))
  log("READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 ACTIVATE=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_ASSIGNMENT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0")
  log("MAPPING_PREFIX=" .. PREFIX)

  if not AIRBASE then
    log("RESULT G6A2_ME_PARKING_MAP status=FAIL reason=AIRBASE_CLASS_UNAVAILABLE anchors=0 mapped=0 rejected=0 ambiguous=0 duplicates=0")
    return
  end

  local airbase = AIRBASE:FindByID(EXPECTED.AirbaseID)
  if not airbase then
    log("RESULT G6A2_ME_PARKING_MAP status=FAIL reason=AIRBASE_ID_NOT_FOUND anchors=0 mapped=0 rejected=0 ambiguous=0 duplicates=0")
    return
  end

  local parking = airbase:GetParkingSpotsTable() or {}
  table.sort(parking, function(a, b)
    return tonumber(a.TerminalID) < tonumber(b.TerminalID)
  end)

  log(string.format(
    "AIRBASE name=%s id=%s parkingCount=%d expectedParkingCount=%d",
    tostring(airbase:GetName()), tostring(airbase:GetID()),
    #parking, EXPECTED.ParkingCount
  ))

  local anchors, collectionError = collectMissionAnchors()
  if collectionError then
    log("RESULT G6A2_ME_PARKING_MAP status=FAIL reason=" .. collectionError .. " anchors=0 mapped=0 rejected=0 ambiguous=0 duplicates=0")
    return
  end

  log("ANCHOR_COUNT=" .. tostring(#anchors))

  local mapped = 0
  local rejected = 0
  local ambiguous = 0
  local duplicates = 0
  local terminalOwner = {}
  local meOwner = {}

  for _, anchor in ipairs(anchors) do
    local first, second = nearestParking(anchor, parking)
    local terminalID = first and tonumber(first.Spot.TerminalID) or nil
    local terminalType = first and tonumber(first.Spot.TerminalType) or nil
    local distance = first and tonumber(first.Distance) or nil
    local secondDistance = second and tonumber(second.Distance) or nil
    local delta = distance and secondDistance and (secondDistance - distance) or nil
    local accepted = terminalID ~= nil and distance ~= nil and distance <= EXPECTED.MaxAcceptedDistanceM
    local isAmbiguous = accepted and delta ~= nil and delta <= EXPECTED.AmbiguityDeltaM

    if isAmbiguous then
      ambiguous = ambiguous + 1
      accepted = false
    end

    if accepted then
      mapped = mapped + 1
    else
      rejected = rejected + 1
    end

    if terminalID then
      if terminalOwner[terminalID] then
        duplicates = duplicates + 1
        log(string.format(
          "DUPLICATE_TERMINAL terminalID=%d first=%s second=%s",
          terminalID, tostring(terminalOwner[terminalID]), tostring(anchor.MEParking)
        ))
      else
        terminalOwner[terminalID] = anchor.MEParking
      end
    end

    if meOwner[anchor.MEParking] then
      duplicates = duplicates + 1
      log(string.format(
        "DUPLICATE_ME_PARKING meParking=%s first=%s second=%s",
        tostring(anchor.MEParking), tostring(meOwner[anchor.MEParking]), tostring(anchor.UnitName)
      ))
    else
      meOwner[anchor.MEParking] = anchor.UnitName
    end

    log(string.format(
      "PARKING_MAP status=%s meParking=%s groupName=%s unitName=%s lateActivation=%s unitType=%s missionParkingField=%s missionX=%.3f missionZ=%.3f mooseTerminalID=%s terminalType=%s parkingX=%.3f parkingZ=%.3f distanceM=%.3f secondDistanceM=%.3f ambiguityDeltaM=%.3f",
      accepted and "MAPPED" or (isAmbiguous and "AMBIGUOUS" or "REJECTED"),
      tostring(anchor.MEParking), tostring(anchor.GroupName), tostring(anchor.UnitName),
      tostring(anchor.LateActivation), tostring(anchor.TypeName), tostring(anchor.ParkingField),
      tonumber(anchor.X) or -1, tonumber(anchor.Z) or -1,
      tostring(terminalID or "none"), tostring(terminalType or "none"),
      tonumber(first and first.X) or -1, tonumber(first and first.Z) or -1,
      tonumber(distance) or -1, tonumber(secondDistance) or -1, tonumber(delta) or -1
    ))
  end

  for _, reference in ipairs(EXPECTED.ClientReferences) do
    local spot = nil
    for _, candidate in ipairs(parking) do
      if tonumber(candidate.TerminalID) == tonumber(reference.MooseTerminalID) then
        spot = candidate
        break
      end
    end
    local vec = spot and spot.Coordinate and spot.Coordinate:GetVec3() or nil
    log(string.format(
      "CLIENT_REFERENCE name=%s meParking=%s mooseTerminalID=%d terminalType=%s parkingX=%.3f parkingZ=%.3f",
      tostring(reference.Name), tostring(reference.MEParking), tonumber(reference.MooseTerminalID),
      tostring(spot and spot.TerminalType or "none"), tonumber(vec and vec.x) or -1,
      tonumber(vec and vec.z) or -1
    ))
  end

  local status = "PASS_MAP"
  local reason = "none"
  if #parking ~= EXPECTED.ParkingCount then
    status = "FAIL"
    reason = "PARKING_COUNT_MISMATCH"
  elseif #anchors == 0 then
    status = "FAIL"
    reason = "NO_MAPPING_ANCHORS"
  elseif rejected > 0 then
    status = "PARTIAL"
    reason = "UNMAPPED_OR_AMBIGUOUS_ANCHORS"
  elseif duplicates > 0 then
    status = "PARTIAL"
    reason = "DUPLICATE_MAPPING"
  end

  log(string.format(
    "RESULT G6A2_ME_PARKING_MAP status=%s reason=%s anchors=%d mapped=%d rejected=%d ambiguous=%d duplicates=%d parkingCount=%d clientReferences=%d",
    status, reason, #anchors, mapped, rejected, ambiguous, duplicates, #parking, #EXPECTED.ClientReferences
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 12)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 12)
end
