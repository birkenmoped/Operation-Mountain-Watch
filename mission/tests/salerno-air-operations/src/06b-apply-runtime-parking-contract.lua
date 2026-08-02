-- Operation Mountain Watch - FOB Salerno runtime parking contract.
--
-- This stage deliberately does not trust Mission Editor parking labels. It derives
-- the actual MOOSE TerminalIDs from the runtime parking table, classifies the two
-- physical aprons by world coordinates, blocks clients/statics/the Role-2 unload
-- node on AIRBASE level, and synchronizes the resulting IDs into every registered
-- SQUADRON warehouse asset before AIRWING start.

local TAG = "[OMW][SALERNO][PARKING-RUNTIME]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function copyNumericList(values)
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
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then result[number] = true end
  end
  return result
end

local function sameNumericSet(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" then return false end
  local a, e = toSet(actual), toSet(expected)
  for value in pairs(a) do if not e[value] then return false end end
  for value in pairs(e) do if not a[value] then return false end end
  return true
end

local function join(values)
  local text = {}
  for _, value in ipairs(values or {}) do text[#text + 1] = tostring(value) end
  return #text > 0 and table.concat(text, ",") or "none"
end

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function inBounds(vec3, bounds)
  if not vec3 or not bounds then return false end
  return vec3.x >= bounds.XMin and vec3.x <= bounds.XMax and
         vec3.z >= bounds.ZMin and vec3.z <= bounds.ZMax
end

local function addBlock(contract, terminalID, reason)
  terminalID = tonumber(terminalID)
  if not terminalID then return end
  contract.Blocked[terminalID] = true
  contract.BlockReasons[terminalID] = contract.BlockReasons[terminalID] or {}
  contract.BlockReasons[terminalID][reason] = true
end

local function sortedKeys(set)
  local values = {}
  for value in pairs(set or {}) do values[#values + 1] = tonumber(value) end
  table.sort(values)
  return values
end

local function findSquadronName(squadron)
  return tostring(squadron and (squadron.name or squadron.squadronname or squadron.SquadronName) or "UNKNOWN")
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.SalernoDiagnostics
  if not cfg then log("COMPLETE status=FAIL reason=configuration-missing") return end

  local airwing = cfg.ConstructedAirwing
  local squadrons = cfg.RegisteredSquadrons or cfg.ConstructedSquadrons or {}
  if not airwing then log("COMPLETE status=FAIL reason=airwing-missing") return end
  if #squadrons ~= cfg.Expected.Squadrons then
    log("COMPLETE status=FAIL reason=squadron-count actual=" .. tostring(#squadrons) .. " expected=" .. tostring(cfg.Expected.Squadrons))
    return
  end

  local airbase = AIRBASE and AIRBASE:FindByName(cfg.AirbaseName) or nil
  if not airbase then log("COMPLETE status=FAIL reason=airbase-missing") return end
  if type(airbase.SetParkingSpotBlacklist) ~= "function" then
    log("COMPLETE status=FAIL reason=AIRBASE.SetParkingSpotBlacklist-unavailable")
    return
  end

  local geometry = cfg.ParkingGeometry or {}
  local spots = airbase:GetParkingSpotsTable() or {}
  local contract = {
    Spots = spots,
    SpotsByID = {},
    LeftHeavy = {},
    RightRotary = {},
    Unclassified = {},
    Blocked = {},
    BlockReasons = {},
    AllowedLeftHeavy = {},
    AllowedRightRotary = {},
    Violations = 0
  }

  local function fail(reason)
    contract.Violations = contract.Violations + 1
    log("VIOLATION reason=" .. tostring(reason))
  end

  for _, spot in ipairs(spots) do
    local terminalID = tonumber(spot.TerminalID)
    local vec3 = spot.Coordinate and spot.Coordinate:GetVec3() or nil
    if terminalID and vec3 then
      contract.SpotsByID[terminalID] = spot
      local sector = nil
      if inBounds(vec3, geometry.LEFT_HEAVY) then sector = "LEFT_HEAVY" end
      if inBounds(vec3, geometry.RIGHT_ROTARY) then
        if sector then
          fail("SECTOR_OVERLAP terminalID=" .. terminalID)
        else
          sector = "RIGHT_ROTARY"
        end
      end

      if sector == "LEFT_HEAVY" then
        contract.LeftHeavy[#contract.LeftHeavy + 1] = terminalID
      elseif sector == "RIGHT_ROTARY" then
        contract.RightRotary[#contract.RightRotary + 1] = terminalID
      else
        contract.Unclassified[#contract.Unclassified + 1] = terminalID
      end

      if spot.ClientSpot == true or spot.ClientName ~= nil then
        addBlock(contract, terminalID, "CLIENT_RESERVED")
      end
      if spot.TOAC == true then
        addBlock(contract, terminalID, "RUNTIME_TOAC_OCCUPIED")
      end

      log(string.format(
        "CALIBRATE terminalID=%d terminalID0=%s sector=%s x=%.1f z=%.1f client=%s toac=%s",
        terminalID,
        tostring(spot.TerminalID0),
        tostring(sector or "UNCLASSIFIED"),
        vec3.x,
        vec3.z,
        tostring(spot.ClientSpot == true or spot.ClientName ~= nil),
        tostring(spot.TOAC == true)
      ))
    end
  end

  table.sort(contract.LeftHeavy)
  table.sort(contract.RightRotary)
  table.sort(contract.Unclassified)

  local clearance = geometry.StaticClearanceRadius or {}
  local defaultRadius = tonumber(geometry.DefaultStaticClearanceRadius) or 20
  local staticCount = 0
  if SET_STATIC then
    local statics = SET_STATIC:New():FilterPrefixes(geometry.StaticPrefix or "STATIC_AIR_US_SAL_"):FilterOnce()
    statics:ForEachStatic(function(static)
      staticCount = staticCount + 1
      local coordinate = static:GetCoordinate()
      local typeName = tostring(static:GetTypeName())
      local radius = tonumber(clearance[typeName]) or defaultRadius
      local blockedNodes = 0
      local nearestID, nearestDistance = nil, nil

      for terminalID, spot in pairs(contract.SpotsByID) do
        local distance = distance2D(coordinate, spot.Coordinate)
        if distance and (not nearestDistance or distance < nearestDistance) then
          nearestID, nearestDistance = terminalID, distance
        end
        if distance and distance <= radius then
          addBlock(contract, terminalID, "STATIC:" .. tostring(static:GetName()))
          blockedNodes = blockedNodes + 1
        end
      end

      log(string.format(
        "STATIC name=%s type=%s radius=%.1f nearestTerminalID=%s nearestDistance=%.1f blockedNodes=%d",
        tostring(static:GetName()), typeName, radius, tostring(nearestID), tonumber(nearestDistance) or -1, blockedNodes))
    end)
  end

  local unloadZoneName = geometry.CSARUnloadZone or "ZONE_AIR_US_SAL_CSAR_UNLOAD"
  local unloadZone = ZONE and ZONE:FindByName(unloadZoneName) or nil
  if not unloadZone then
    fail("CSAR_UNLOAD_ZONE_MISSING name=" .. unloadZoneName)
  else
    local coordinate = unloadZone:GetCoordinate()
    local nearestID, nearestDistance = nil, nil
    for terminalID, spot in pairs(contract.SpotsByID) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then
        nearestID, nearestDistance = terminalID, distance
      end
    end
    if nearestID then
      addBlock(contract, nearestID, "CSAR_UNLOAD_AND_MAIN_APRON_ACCESS")
      log(string.format("CSAR_UNLOAD zone=%s nearestTerminalID=%d distance=%.1f blocked=true",
        unloadZoneName, nearestID, tonumber(nearestDistance) or -1))
    else
      fail("CSAR_UNLOAD_TERMINAL_UNRESOLVED name=" .. unloadZoneName)
    end
  end

  contract.BlockedIDs = sortedKeys(contract.Blocked)
  local blockedSet = toSet(contract.BlockedIDs)
  for _, terminalID in ipairs(contract.LeftHeavy) do
    if not blockedSet[terminalID] then contract.AllowedLeftHeavy[#contract.AllowedLeftHeavy + 1] = terminalID end
  end
  for _, terminalID in ipairs(contract.RightRotary) do
    if not blockedSet[terminalID] then contract.AllowedRightRotary[#contract.AllowedRightRotary + 1] = terminalID end
  end

  if #contract.AllowedLeftHeavy == 0 then fail("NO_LEFT_HEAVY_PARKING") end
  if #contract.AllowedRightRotary == 0 then fail("NO_RIGHT_ROTARY_PARKING") end

  for _, terminalID in ipairs(contract.BlockedIDs) do
    local reasons = {}
    for reason in pairs(contract.BlockReasons[terminalID] or {}) do reasons[#reasons + 1] = reason end
    table.sort(reasons)
    log(string.format("BLOCKED terminalID=%d reasons=%s", terminalID, table.concat(reasons, ",")))
  end

  if contract.Violations == 0 then
    local ok, result = pcall(function()
      return airbase:SetParkingSpotBlacklist(contract.BlockedIDs)
    end)
    if not ok then fail("AIRBASE_BLACKLIST_FAILED error=" .. tostring(result)) end
  end

  local globalAllowed = {}
  for _, value in ipairs(contract.AllowedLeftHeavy) do globalAllowed[#globalAllowed + 1] = value end
  for _, value in ipairs(contract.AllowedRightRotary) do globalAllowed[#globalAllowed + 1] = value end
  table.sort(globalAllowed)

  if contract.Violations == 0 then
    local ok, result = pcall(function()
      airwing:SetParkingIDs(globalAllowed)
      airwing:SetSafeParkingOn()
      return true
    end)
    if not ok then fail("AIRWING_ALLOWLIST_FAILED error=" .. tostring(result)) end
  end

  local syncedAssets = 0
  for _, squadron in ipairs(squadrons) do
    local name = findSquadronName(squadron)
    local parkingIDs = name:find("CH47", 1, true) and contract.AllowedLeftHeavy or contract.AllowedRightRotary
    local sector = name:find("CH47", 1, true) and "LEFT_HEAVY" or "RIGHT_ROTARY"

    local ok, result = pcall(function()
      squadron:SetParkingIDs(parkingIDs)
      for _, asset in pairs(squadron.assets or {}) do
        asset.parkingIDs = copyNumericList(parkingIDs)
        syncedAssets = syncedAssets + 1
      end
      return true
    end)
    if not ok then
      fail("SQUADRON_SYNC_FAILED name=" .. name .. " error=" .. tostring(result))
    else
      if not sameNumericSet(squadron.parkingIDs, parkingIDs) then
        fail("SQUADRON_IDS_MISMATCH name=" .. name)
      end
      local assetCount = 0
      for _, asset in pairs(squadron.assets or {}) do
        assetCount = assetCount + 1
        if not sameNumericSet(asset.parkingIDs, parkingIDs) then
          fail("ASSET_IDS_MISMATCH squadron=" .. name .. " asset=" .. tostring(asset.spawngroupname or asset.uid))
        end
      end
      log(string.format("SQUADRON_SYNCED name=%s sector=%s parkingIDs=%s assets=%d",
        name, sector, join(parkingIDs), assetCount))
    end
  end

  cfg.ParkingContract = contract
  cfg.ParkingSectors = {
    LEFT_HEAVY = copyNumericList(contract.AllowedLeftHeavy),
    RIGHT_ROTARY = copyNumericList(contract.AllowedRightRotary)
  }

  log(string.format(
    "CONTRACT total=%d leftRaw=%d rightRaw=%d unclassified=%d blocked=%d leftAllowed=%d rightAllowed=%d statics=%d syncedAssets=%d violations=%d",
    #spots, #contract.LeftHeavy, #contract.RightRotary, #contract.Unclassified,
    #contract.BlockedIDs, #contract.AllowedLeftHeavy, #contract.AllowedRightRotary,
    staticCount, syncedAssets, contract.Violations))
  log("LEFT_HEAVY_IDS=" .. join(contract.AllowedLeftHeavy))
  log("RIGHT_ROTARY_IDS=" .. join(contract.AllowedRightRotary))
  log("COMPLETE status=" .. (contract.Violations == 0 and "PASS" or "FAIL"))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 13)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 13)
end
