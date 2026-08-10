-- Operation Mountain Watch - Shindand Heliport ME parking to MOOSE TerminalID map.
--
-- Read-only mapping pass. No group activation, no spawn, no AIRWING/SQUADRON,
-- no parking assignment and no MIZ mutation.
--
-- Mapping anchors are late-activation single-aircraft groups whose group name
-- starts with DIAG_SHND_HP_ME_. The suffix is the Mission Editor parking label
-- chosen by the project owner. The group position stored in env.mission is
-- mapped with MOOSE COORDINATE:GetClosestParkingSpot() against the native
-- AIRBASE.Afghanistan.Shindand_Heliport parking domain.

local TAG = "[OMW][AirOps.SHND.HP.PARKMAP]"
local PREFIX = "DIAG_SHND_HP_ME_"
local EXPECTED_ANCHOR_COUNT = 45
local MAX_ACCEPTED_DISTANCE_M = 5.0

local build = OMW_SHND_HP_PARKMAP_BUILD or {}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function startsWith(value, prefix)
  return type(value) == "string" and value:sub(1, #prefix) == prefix
end

local function suffix(value)
  if not startsWith(value, PREFIX) then
    return nil
  end

  local result = value:sub(#PREFIX + 1)
  return result ~= "" and result or nil
end

local function collectMissionAnchors()
  local anchors = {}
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
                if type(group) == "table" then
                  local meParking = suffix(group.name)
                  if meParking then
                    local units = type(group.units) == "table" and group.units or {}
                    local unitCount = 0
                    for _ in pairs(units) do
                      unitCount = unitCount + 1
                    end

                    for unitIndex, unit in pairs(units) do
                      if type(unit) == "table" then
                        anchors[#anchors + 1] = {
                          Coalition = tostring(coalitionName),
                          Country = tostring(country.name or country.id or "unknown"),
                          Category = tostring(categoryName),
                          GroupName = tostring(group.name or "none"),
                          UnitName = tostring(unit.name or "none"),
                          MEParking = tostring(meParking),
                          UnitIndex = tonumber(unitIndex) or -1,
                          GroupUnitCount = unitCount,
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

  table.sort(anchors, function(a, b)
    local an = tonumber(a.MEParking:match("^(%d+)$"))
    local bn = tonumber(b.MEParking:match("^(%d+)$"))

    if an and bn and an ~= bn then
      return an < bn
    end

    if a.MEParking ~= b.MEParking then
      return a.MEParking < b.MEParking
    end

    return a.GroupName < b.GroupName
  end)

  return anchors, nil
end

local function main()
  log("BEGIN Shindand Heliport ME parking map")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder), tostring(build.BuilderVersion),
    tostring(build.GitCommit), tostring(build.GeneratedUtc)
  ))
  log("READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 ACTIVATE=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_ASSIGNMENT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0")
  log("MAPPING_PREFIX=" .. PREFIX)

  if not AIRBASE or not COORDINATE then
    log("RESULT SHND_HP_ME_PARKING_MAP status=FAIL reason=MOOSE_CLASS_UNAVAILABLE anchors=0 mapped=0 rejected=0 duplicates=0")
    return
  end

  local airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Shindand_Heliport or nil
  if not airbaseName then
    log("RESULT SHND_HP_ME_PARKING_MAP status=FAIL reason=SHINDAND_HELIPORT_ENUM_UNAVAILABLE anchors=0 mapped=0 rejected=0 duplicates=0")
    return
  end

  local airbase = AIRBASE:FindByName(airbaseName)
  if not airbase then
    log("RESULT SHND_HP_ME_PARKING_MAP status=FAIL reason=SHINDAND_HELIPORT_NOT_FOUND anchors=0 mapped=0 rejected=0 duplicates=0")
    return
  end

  local parking = airbase:GetParkingSpotsTable() or {}
  table.sort(parking, function(a, b)
    return tonumber(a.TerminalID) < tonumber(b.TerminalID)
  end)

  log(string.format(
    "AIRBASE name=%s id=%s parkingCount=%d enumName=%s",
    tostring(airbase:GetName()), tostring(airbase:GetID()), #parking, tostring(airbaseName)
  ))

  for _, spot in ipairs(parking) do
    local vec = spot.Coordinate and spot.Coordinate:GetVec3() or nil
    log(string.format(
      "PARKING_SPOT terminalID=%s terminalID0=%s terminalType=%s free=%s toac=%s distToRwyM=%s x=%.3f z=%.3f",
      tostring(spot.TerminalID), tostring(spot.TerminalID0), tostring(spot.TerminalType),
      tostring(spot.Free), tostring(spot.TOAC), tostring(spot.DistToRwy),
      tonumber(vec and vec.x) or -1, tonumber(vec and vec.z) or -1
    ))
  end

  local anchors, collectionError = collectMissionAnchors()
  if collectionError then
    log("RESULT SHND_HP_ME_PARKING_MAP status=FAIL reason=" .. collectionError .. " anchors=0 mapped=0 rejected=0 duplicates=0")
    return
  end

  log(string.format("ANCHOR_COUNT actual=%d expected=%d", #anchors, EXPECTED_ANCHOR_COUNT))

  local mapped = 0
  local rejected = 0
  local duplicates = 0
  local malformed = 0
  local terminalOwner = {}
  local meOwner = {}

  for _, anchor in ipairs(anchors) do
    local positionValid = anchor.X ~= nil and anchor.Z ~= nil
    local sourceCoordinate = positionValid and COORDINATE:NewFromVec2({ x = anchor.X, y = anchor.Z }) or nil
    local closestCoordinate, terminalID, distanceM, parkingSpot = nil, nil, nil, nil

    if sourceCoordinate then
      closestCoordinate, terminalID, distanceM, parkingSpot = sourceCoordinate:GetClosestParkingSpot(airbase, nil, nil)
    end

    local parkingVec = closestCoordinate and closestCoordinate:GetVec3() or nil
    local accepted = terminalID ~= nil and distanceM ~= nil and distanceM <= MAX_ACCEPTED_DISTANCE_M

    if anchor.GroupUnitCount ~= 1 or anchor.LateActivation ~= true or not positionValid then
      malformed = malformed + 1
      accepted = false
    end

    if accepted then
      mapped = mapped + 1
    else
      rejected = rejected + 1
    end

    if terminalID ~= nil then
      if terminalOwner[terminalID] then
        duplicates = duplicates + 1
        log(string.format(
          "DUPLICATE_TERMINAL terminalID=%s firstME=%s secondME=%s",
          tostring(terminalID), tostring(terminalOwner[terminalID]), tostring(anchor.MEParking)
        ))
      else
        terminalOwner[terminalID] = anchor.MEParking
      end
    end

    if meOwner[anchor.MEParking] then
      duplicates = duplicates + 1
      log(string.format(
        "DUPLICATE_ME_LABEL meParking=%s firstGroup=%s secondGroup=%s",
        tostring(anchor.MEParking), tostring(meOwner[anchor.MEParking]), tostring(anchor.GroupName)
      ))
    else
      meOwner[anchor.MEParking] = anchor.GroupName
    end

    log(string.format(
      "PARKING_MAP status=%s meParking=%s groupName=%s unitName=%s groupUnitCount=%d lateActivation=%s unitType=%s missionParkingField=%s missionX=%.3f missionZ=%.3f mooseTerminalID=%s terminalID0=%s terminalType=%s free=%s toac=%s parkingX=%.3f parkingZ=%.3f distanceM=%.3f",
      accepted and "MAPPED" or "REJECTED",
      tostring(anchor.MEParking), tostring(anchor.GroupName), tostring(anchor.UnitName),
      tonumber(anchor.GroupUnitCount) or -1, tostring(anchor.LateActivation), tostring(anchor.TypeName),
      tostring(anchor.ParkingField), tonumber(anchor.X) or -1, tonumber(anchor.Z) or -1,
      tostring(terminalID or "none"), tostring(parkingSpot and parkingSpot.TerminalID0 or "none"),
      tostring(parkingSpot and parkingSpot.TerminalType or "none"),
      tostring(parkingSpot and parkingSpot.Free or "none"), tostring(parkingSpot and parkingSpot.TOAC or "none"),
      tonumber(parkingVec and parkingVec.x) or -1, tonumber(parkingVec and parkingVec.z) or -1,
      tonumber(distanceM) or -1
    ))
  end

  local status = "PASS_MAP"
  local reason = "none"

  if #parking == 0 then
    status = "FAIL"
    reason = "NO_HELIPORT_PARKING_DATA"
  elseif #anchors ~= EXPECTED_ANCHOR_COUNT then
    status = "FAIL"
    reason = "ANCHOR_COUNT_MISMATCH"
  elseif rejected > 0 then
    status = "PARTIAL"
    reason = "UNMAPPED_OR_INVALID_ANCHORS"
  elseif duplicates > 0 then
    status = "PARTIAL"
    reason = "DUPLICATE_MAPPING"
  end

  log(string.format(
    "RESULT SHND_HP_ME_PARKING_MAP status=%s reason=%s airbaseName=%s airbaseID=%s parkingCount=%d anchors=%d mapped=%d rejected=%d duplicates=%d malformed=%d maxAcceptedDistanceM=%.1f",
    status, reason, tostring(airbase:GetName()), tostring(airbase:GetID()), #parking,
    #anchors, mapped, rejected, duplicates, malformed, MAX_ACCEPTED_DISTANCE_M
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 12)
else
  log("RESULT SHND_HP_ME_PARKING_MAP status=FAIL reason=SCHEDULER_CLASS_UNAVAILABLE anchors=0 mapped=0 rejected=0 duplicates=0")
end
