-- Operation Mountain Watch - FOB Salerno transition-strip correction.
-- Stage 11 runtime evidence proved that TerminalIDs 21-24 were geometrically
-- admitted to RIGHT_ROTARY although they belong to the eastern connector / special
-- parking strip. This stage removes every runtime node inside TRANSITION_EXCLUDED,
-- reapplies AIRBASE/AIRWING contracts, and synchronizes all registered assets.

local TAG = "[OMW][SALERNO][PARKING-TRANSITION]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function inBounds(vec3, bounds)
  return vec3 and bounds and
    vec3.x >= bounds.XMin and vec3.x <= bounds.XMax and
    vec3.z >= bounds.ZMin and vec3.z <= bounds.ZMax
end

local function copy(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then result[#result + 1] = number end
  end
  table.sort(result)
  return result
end

local function toSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do result[tonumber(value)] = true end
  return result
end

local function filter(values, excluded)
  local result = {}
  for _, value in ipairs(values or {}) do
    if not excluded[tonumber(value)] then result[#result + 1] = tonumber(value) end
  end
  table.sort(result)
  return result
end

local function join(values)
  local text = {}
  for _, value in ipairs(values or {}) do text[#text + 1] = tostring(value) end
  return #text > 0 and table.concat(text, ",") or "none"
end

local function squadronName(squadron)
  return tostring(squadron and (squadron.name or squadron.squadronname or squadron.SquadronName) or "UNKNOWN")
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  local contract = cfg and cfg.ParkingContract or nil
  local bounds = cfg and cfg.ParkingGeometry and cfg.ParkingGeometry.TRANSITION_EXCLUDED or nil
  local airwing = cfg and cfg.ConstructedAirwing or nil
  local squadrons = cfg and (cfg.RegisteredSquadrons or cfg.ConstructedSquadrons) or nil
  local airbase = cfg and AIRBASE and AIRBASE:FindByName(cfg.AirbaseName) or nil

  if not cfg or not contract or not bounds or not airwing or not airbase or type(squadrons) ~= "table" then
    log("COMPLETE status=FAIL reason=prerequisite-missing")
    return
  end

  local excluded = {}
  local excludedIDs = {}
  for terminalID, spot in pairs(contract.SpotsByID or {}) do
    local vec3 = spot.Coordinate and spot.Coordinate:GetVec3() or nil
    if inBounds(vec3, bounds) then
      terminalID = tonumber(terminalID)
      excluded[terminalID] = true
      excludedIDs[#excludedIDs + 1] = terminalID
      contract.Blocked[terminalID] = true
      contract.BlockReasons[terminalID] = contract.BlockReasons[terminalID] or {}
      contract.BlockReasons[terminalID].TRANSITION_CONNECTOR_EXCLUDED = true
      log(string.format("EXCLUDE terminalID=%d x=%.1f z=%.1f reason=TRANSITION_CONNECTOR_EXCLUDED",
        terminalID, vec3.x, vec3.z))
    end
  end
  table.sort(excludedIDs)

  local right = filter(contract.AllowedRightRotary, excluded)
  local left = copy(contract.AllowedLeftHeavy)
  if #excludedIDs == 0 then
    log("COMPLETE status=FAIL reason=no-transition-nodes-resolved")
    return
  end
  if #right < 6 then
    log("COMPLETE status=FAIL reason=insufficient-right-rotary-after-exclusion count=" .. tostring(#right))
    return
  end

  local blockedSet = toSet(contract.BlockedIDs or {})
  for _, value in ipairs(excludedIDs) do blockedSet[value] = true end
  local blocked = {}
  for value in pairs(blockedSet) do blocked[#blocked + 1] = value end
  table.sort(blocked)

  local globalAllowed = {}
  for _, value in ipairs(left) do globalAllowed[#globalAllowed + 1] = value end
  for _, value in ipairs(right) do globalAllowed[#globalAllowed + 1] = value end
  table.sort(globalAllowed)

  local ok, detail = pcall(function()
    airbase:SetParkingSpotBlacklist(blocked)
    airwing:SetParkingIDs(globalAllowed)
    airwing:SetSafeParkingOn()
    for _, squadron in ipairs(squadrons) do
      local name = squadronName(squadron)
      local parkingIDs = name:find("CH47", 1, true) and left or right
      squadron:SetParkingIDs(parkingIDs)
      for _, asset in pairs(squadron.assets or {}) do
        asset.parkingIDs = copy(parkingIDs)
      end
      log(string.format("SQUADRON_RESYNCED name=%s sector=%s parkingIDs=%s assets=%d",
        name, name:find("CH47", 1, true) and "LEFT_HEAVY" or "RIGHT_ROTARY",
        join(parkingIDs), (function() local n=0 for _ in pairs(squadron.assets or {}) do n=n+1 end return n end)()))
    end
  end)
  if not ok then
    log("COMPLETE status=FAIL reason=application-error detail=" .. tostring(detail))
    return
  end

  contract.BlockedIDs = blocked
  contract.AllowedRightRotary = right
  contract.AllowedLeftHeavy = left
  cfg.ParkingSectors = { LEFT_HEAVY = copy(left), RIGHT_ROTARY = copy(right) }
  cfg.ParkingTransitionExclusionApplied = true

  log("TRANSITION_IDS=" .. join(excludedIDs))
  log("LEFT_HEAVY_IDS=" .. join(left))
  log("RIGHT_ROTARY_IDS=" .. join(right))
  log(string.format("CONTRACT excluded=%d blocked=%d leftAllowed=%d rightAllowed=%d", #excludedIDs, #blocked, #left, #right))
  log("COMPLETE status=PASS")
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 13.5)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 13.5)
end
