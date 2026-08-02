-- Operation Mountain Watch - FOB Salerno parking calibration.
--
-- Maps deliberately placed late-activation Mission Editor calibration groups to
-- the actual MOOSE runtime parking TerminalIDs. This script does not construct
-- AIRWING/SQUADRON objects, mutate parking contracts, create missions or spawn units.
--
-- Required Mission Editor group naming:
--   CAL_SAL_ME_PARK_01
--   CAL_SAL_ME_PARK_02
--   ...
-- Each group must contain exactly one aircraft/helicopter unit, be late activated,
-- and be anchored with a parking start action on the ME parking position to map.

local TAG = "[OMW][SALERNO][PARKING-MAP]"
local PREFIX = "CAL_SAL_ME_PARK_"
local AIRBASE_NAME = AIRBASE and AIRBASE.Afghanistan and AIRBASE.Afghanistan.FOB_Salerno or "FOB Salerno"
local UNIQUE_MAX_DISTANCE_M = 5.0
local MIN_NEAREST_GAP_M = 2.0

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function distance2D(x1, z1, x2, z2)
  local dx = (x1 or 0) - (x2 or 0)
  local dz = (z1 or 0) - (z2 or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function sortedKeys(map)
  local values = {}
  for key in pairs(map or {}) do values[#values + 1] = key end
  table.sort(values)
  return values
end

local function collectMissionGroups()
  local groups = {}
  local mission = env and env.mission or nil
  local coalitionTable = mission and mission.coalition or nil
  if type(coalitionTable) ~= "table" then return groups end

  for coalitionName, coalitionData in pairs(coalitionTable) do
    if type(coalitionData) == "table" and type(coalitionData.country) == "table" then
      for _, countryData in pairs(coalitionData.country) do
        for _, categoryName in ipairs({ "helicopter", "plane" }) do
          local category = countryData[categoryName]
          if type(category) == "table" and type(category.group) == "table" then
            for _, group in pairs(category.group) do
              local name = tostring(group.name or "")
              local labelText = name:match("^" .. PREFIX .. "(%d+)$")
              if labelText then
                groups[#groups + 1] = {
                  Name = name,
                  Label = tonumber(labelText),
                  Coalition = tostring(coalitionName),
                  Category = categoryName,
                  LateActivation = group.lateActivation == true,
                  Units = group.units or {}
                }
              end
            end
          end
        end
      end
    end
  end

  table.sort(groups, function(a, b)
    if a.Label == b.Label then return a.Name < b.Name end
    return a.Label < b.Label
  end)
  return groups
end

local function buildParkingTable(airbase)
  local parking = {}
  for _, spot in ipairs(airbase:GetParkingSpotsTable() or {}) do
    local terminalID = tonumber(spot.TerminalID)
    local vec3 = spot.Coordinate and spot.Coordinate:GetVec3() or nil
    if terminalID and vec3 then
      parking[#parking + 1] = {
        TerminalID = terminalID,
        TerminalID0 = spot.TerminalID0,
        TerminalType = spot.TerminalType,
        ClientSpot = spot.ClientSpot == true,
        ClientName = spot.ClientName,
        TOAC = spot.TOAC == true,
        X = vec3.x,
        Z = vec3.z
      }
    end
  end
  table.sort(parking, function(a, b) return a.TerminalID < b.TerminalID end)
  return parking
end

local function nearestParking(unit, parking)
  local nearest, second = nil, nil
  for _, spot in ipairs(parking) do
    local distance = distance2D(unit.x, unit.y, spot.X, spot.Z)
    local candidate = { Spot = spot, Distance = distance }
    if not nearest or distance < nearest.Distance then
      second = nearest
      nearest = candidate
    elseif not second or distance < second.Distance then
      second = candidate
    end
  end
  return nearest, second
end

local function main()
  log("BEGIN version=SAL-ME-TERMINAL-CALIBRATION-1 prefix=" .. PREFIX .. " noSpawn=true noAirwing=true noSquadron=true noMission=true noParkingMutation=true")

  if not AIRBASE or type(AIRBASE.FindByName) ~= "function" then
    log("COMPLETE status=FAIL reason=MOOSE_AIRBASE_UNAVAILABLE")
    return
  end

  local airbase = AIRBASE:FindByName(AIRBASE_NAME)
  if not airbase then
    log("COMPLETE status=FAIL reason=AIRBASE_NOT_FOUND name=" .. tostring(AIRBASE_NAME))
    return
  end

  local groups = collectMissionGroups()
  local parking = buildParkingTable(airbase)
  if #groups == 0 then
    log("COMPLETE status=FAIL reason=NO_CALIBRATION_GROUPS_FOUND expectedPrefix=" .. PREFIX)
    return
  end
  if #parking == 0 then
    log("COMPLETE status=FAIL reason=NO_RUNTIME_PARKING_FOUND airbase=" .. tostring(AIRBASE_NAME))
    return
  end

  local failures = 0
  local mappings = 0
  local terminalOwners = {}
  local labelOwners = {}

  log(string.format("INVENTORY calibrationGroups=%d runtimeParkingNodes=%d airbase=%s airbaseID=%s",
    #groups, #parking, tostring(airbase:GetName()), tostring(airbase:GetID())))

  for _, group in ipairs(groups) do
    local status = "UNRESOLVED"
    local reason = nil
    local unit = group.Units[1]

    if labelOwners[group.Label] then
      status = "FAIL"
      reason = "DUPLICATE_ME_LABEL"
    elseif #group.Units ~= 1 then
      status = "FAIL"
      reason = "GROUP_UNIT_COUNT_" .. tostring(#group.Units)
    elseif not group.LateActivation then
      status = "FAIL"
      reason = "NOT_LATE_ACTIVATION"
    elseif not unit or type(unit.x) ~= "number" or type(unit.y) ~= "number" then
      status = "FAIL"
      reason = "UNIT_COORDINATE_MISSING"
    else
      labelOwners[group.Label] = group.Name
      local nearest, second = nearestParking(unit, parking)
      if not nearest then
        status = "FAIL"
        reason = "NO_NEAREST_TERMINAL"
      else
        local gap = second and (second.Distance - nearest.Distance) or math.huge
        if nearest.Distance > UNIQUE_MAX_DISTANCE_M then
          status = "FAIL"
          reason = "DISTANCE_TOO_LARGE"
        elseif gap < MIN_NEAREST_GAP_M then
          status = "FAIL"
          reason = "AMBIGUOUS_NEAREST_TERMINAL"
        elseif terminalOwners[nearest.Spot.TerminalID] then
          status = "FAIL"
          reason = "DUPLICATE_TERMINAL_MAPPING"
        else
          status = "UNIQUE"
          mappings = mappings + 1
          terminalOwners[nearest.Spot.TerminalID] = group.Name
        end

        log(string.format(
          "MAP meLabel=%d group=%s coalition=%s category=%s lateActivation=%s unitType=%s unitX=%.3f unitZ=%.3f terminalID=%s terminalID0=%s terminalType=%s terminalX=%.3f terminalZ=%.3f distance=%.3f secondTerminalID=%s secondDistance=%.3f gap=%.3f client=%s clientName=%s toac=%s status=%s reason=%s",
          group.Label,
          group.Name,
          group.Coalition,
          group.Category,
          tostring(group.LateActivation),
          tostring(unit.type),
          unit.x,
          unit.y,
          tostring(nearest and nearest.Spot.TerminalID or "nil"),
          tostring(nearest and nearest.Spot.TerminalID0 or "nil"),
          tostring(nearest and nearest.Spot.TerminalType or "nil"),
          nearest and nearest.Spot.X or -1,
          nearest and nearest.Spot.Z or -1,
          nearest and nearest.Distance or -1,
          tostring(second and second.Spot.TerminalID or "nil"),
          second and second.Distance or -1,
          gap == math.huge and -1 or gap,
          tostring(nearest and nearest.Spot.ClientSpot or false),
          tostring(nearest and nearest.Spot.ClientName or "nil"),
          tostring(nearest and nearest.Spot.TOAC or false),
          status,
          tostring(reason or "none")
        ))
      end
    end

    if status ~= "UNIQUE" then
      failures = failures + 1
      if reason and (not unit or type(unit.x) ~= "number" or type(unit.y) ~= "number") then
        log(string.format("MAP meLabel=%s group=%s status=FAIL reason=%s",
          tostring(group.Label), group.Name, reason))
      end
    end
  end

  local orderedLabels = sortedKeys(labelOwners)
  local summaryParts = {}
  for _, label in ipairs(orderedLabels) do
    local groupName = labelOwners[label]
    local mappedTerminal = nil
    for terminalID, owner in pairs(terminalOwners) do
      if owner == groupName then mappedTerminal = terminalID break end
    end
    if mappedTerminal then summaryParts[#summaryParts + 1] = tostring(label) .. "=" .. tostring(mappedTerminal) end
  end

  log("MAPPING " .. table.concat(summaryParts, ","))
  log(string.format("SUMMARY groups=%d mappings=%d failures=%d runtimeParkingNodes=%d",
    #groups, mappings, failures, #parking))
  log("SAFETY spawned=0 airwingConstructed=false squadronsConstructed=0 missionsAdded=0 parkingMutation=false")
  log("COMPLETE status=" .. (failures == 0 and mappings == #groups and "PASS" or "FAIL"))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 5)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 5)
end
