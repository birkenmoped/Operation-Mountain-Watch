-- Operation Mountain Watch - Kandahar dual-AIRWING parking contract preflight.
-- Reuses the validated registration preflight objects, registers all runtime parking IDs,
-- blocks client and static-occupied positions, enables safe parking, and does not start or spawn assets.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.ParkingContract]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local CLIENT_RESERVED = {
  Main = { 92, 282, 287, 294 },
  Heliport = { 4, 19, 23, 30, 47, 80 }
}

-- Conservative obstacle radii in metres. They are only used to determine which native
-- parking-node centres are physically covered by a Mission Editor aircraft static.
local STATIC_CLEARANCE_RADIUS = {
  ["A-10C_2"] = 20,
  ["C-130J-30"] = 32,
  ["UH-60A"] = 18,
  ["RQ-1A Predator"] = 16,
  ["MQ-9 Reaper"] = 20,
  ["AH-64D_BLK_II"] = 18,
  ["OH58D"] = 14,
  ["CH-47Fbl1"] = 30
}

local DEFAULT_STATIC_CLEARANCE_RADIUS = 20
local EXPECTED_STATIC_COUNT = 47
local violations = 0

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function sortedNumericKeys(set)
  local values = {}
  for value in pairs(set or {}) do
    values[#values + 1] = tonumber(value)
  end
  table.sort(values)
  return values
end

local function toSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[tonumber(value)] = true
  end
  return result
end

local function sameNumericSet(actual, expected)
  if type(actual) ~= "table" then return false end
  local actualSet = {}
  for key, value in pairs(actual) do
    if type(key) == "number" and type(value) == "number" then
      actualSet[tonumber(value)] = true
    elseif type(key) == "number" and value == true then
      actualSet[tonumber(key)] = true
    elseif tonumber(value) then
      actualSet[tonumber(value)] = true
    end
  end
  local expectedSet = toSet(expected)
  for value in pairs(expectedSet) do
    if not actualSet[value] then return false end
  end
  for value in pairs(actualSet) do
    if not expectedSet[value] then return false end
  end
  return true
end

local function getRunning(airwing)
  if not airwing or not airwing.IsRunning then return false end
  local ok, value = pcall(function() return airwing:IsRunning() end)
  return ok and value == true
end

local function newContract(key, airbase)
  local spots = airbase:GetParkingSpotsTable() or {}
  local byID = {}
  local allIDs = {}
  for _, spot in ipairs(spots) do
    local terminalID = tonumber(spot.TerminalID)
    if terminalID then
      byID[terminalID] = spot
      allIDs[#allIDs + 1] = terminalID
    end
  end
  table.sort(allIDs)
  return {
    Key = key,
    Airbase = airbase,
    AirbaseID = airbase:GetID(),
    Spots = spots,
    SpotsByID = byID,
    AllIDs = allIDs,
    Blocked = {},
    BlockReasons = {},
    AllowedIDs = {},
    BlockedIDs = {},
    StaticCount = 0,
    StaticNoParkingOverlap = 0
  }
end

local function addBlock(contract, terminalID, reason)
  terminalID = tonumber(terminalID)
  if not terminalID then return end
  contract.Blocked[terminalID] = true
  contract.BlockReasons[terminalID] = contract.BlockReasons[terminalID] or {}
  contract.BlockReasons[terminalID][reason] = true
end

local function reserveClients(contract, terminalIDs)
  for _, terminalID in ipairs(terminalIDs) do
    local spot = contract.SpotsByID[terminalID]
    if not spot then
      fail(string.format("CLIENT_TERMINAL_MISSING key=%s terminalID=%d", contract.Key, terminalID))
    else
      addBlock(contract, terminalID, "CLIENT_RESERVED")
      log(string.format(
        "CLIENT_RESERVED key=%s terminalID=%d terminalType=%s clientSpot=%s clientName=%s",
        contract.Key,
        terminalID,
        tostring(spot.TerminalType),
        tostring(spot.ClientSpot),
        tostring(spot.ClientName)
      ))
    end
  end
end

local function nearestAirbaseKey(coordinate, contracts)
  local selectedKey, selectedDistance = nil, nil
  for key, contract in pairs(contracts) do
    for _, spot in ipairs(contract.Spots) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not selectedDistance or distance < selectedDistance) then
        selectedKey = key
        selectedDistance = distance
      end
    end
  end
  return selectedKey, selectedDistance
end

local function blockStatics(contracts)
  local staticCount = 0
  local statics = SET_STATIC:New():FilterPrefixes("STATIC_AIR_US_KAF_"):FilterOnce()
  statics:ForEachStatic(function(static)
    staticCount = staticCount + 1
    local name = tostring(static:GetName())
    local typeName = tostring(static:GetTypeName())
    local coordinate = static:GetCoordinate()
    local key, nearestDistance = nearestAirbaseKey(coordinate, contracts)
    local radius = STATIC_CLEARANCE_RADIUS[typeName] or DEFAULT_STATIC_CLEARANCE_RADIUS
    local blockedForStatic = 0

    if not key or not coordinate then
      fail("STATIC_AIRBASE_UNRESOLVED name=" .. name .. " type=" .. typeName)
      return
    end

    local contract = contracts[key]
    contract.StaticCount = contract.StaticCount + 1
    for _, spot in ipairs(contract.Spots) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and distance <= radius then
        addBlock(contract, spot.TerminalID, "STATIC:" .. name)
        blockedForStatic = blockedForStatic + 1
      end
    end

    if blockedForStatic == 0 then
      contract.StaticNoParkingOverlap = contract.StaticNoParkingOverlap + 1
    end

    log(string.format(
      "STATIC_CLASSIFIED name=%s type=%s airbaseKey=%s nearestDistance=%.2f clearanceRadius=%.1f blockedNodes=%d",
      name,
      typeName,
      key,
      tonumber(nearestDistance) or -1,
      radius,
      blockedForStatic
    ))
  end)

  if staticCount ~= EXPECTED_STATIC_COUNT then
    fail(string.format("STATIC_COUNT_MISMATCH expected=%d actual=%d", EXPECTED_STATIC_COUNT, staticCount))
  end
  return staticCount
end

local function finalizeContract(contract)
  contract.BlockedIDs = sortedNumericKeys(contract.Blocked)
  local blockedSet = toSet(contract.BlockedIDs)
  for _, terminalID in ipairs(contract.AllIDs) do
    if not blockedSet[terminalID] then
      contract.AllowedIDs[#contract.AllowedIDs + 1] = terminalID
    end
  end

  if #contract.AllowedIDs == 0 then
    fail("NO_ALLOWED_PARKING key=" .. contract.Key)
  end

  local allowedSet = toSet(contract.AllowedIDs)
  for _, terminalID in ipairs(contract.BlockedIDs) do
    if allowedSet[terminalID] then
      fail(string.format("PARKING_OVERLAP key=%s terminalID=%d", contract.Key, terminalID))
    end
  end

  for _, terminalID in ipairs(contract.BlockedIDs) do
    local reasons = {}
    for reason in pairs(contract.BlockReasons[terminalID] or {}) do
      reasons[#reasons + 1] = reason
    end
    table.sort(reasons)
    log(string.format(
      "BLOCKED key=%s terminalID=%d reasons=%s",
      contract.Key,
      terminalID,
      table.concat(reasons, ",")
    ))
  end

  log(string.format(
    "CONTRACT_BUILT key=%s airbaseID=%s total=%d allowed=%d blocked=%d statics=%d staticsWithoutParkingOverlap=%d",
    contract.Key,
    tostring(contract.AirbaseID),
    #contract.AllIDs,
    #contract.AllowedIDs,
    #contract.BlockedIDs,
    contract.StaticCount,
    contract.StaticNoParkingOverlap
  ))
end

local function applyContract(contract, airwing)
  if not airwing then
    fail("AIRWING_UNAVAILABLE key=" .. contract.Key)
    return
  end
  if getRunning(airwing) then
    fail("AIRWING_RUNNING_BEFORE_PARKING_CONTRACT key=" .. contract.Key)
    return
  end

  local blacklistOK, blacklistResult = pcall(function()
    return contract.Airbase:SetParkingSpotBlacklist(contract.BlockedIDs)
  end)
  if not blacklistOK then
    fail("BLACKLIST_APPLICATION_FAILED key=" .. contract.Key .. " error=" .. tostring(blacklistResult))
  end

  local allowOK, allowResult = pcall(function()
    return airwing:SetParkingIDs(contract.AllowedIDs)
  end)
  if not allowOK then
    fail("ALLOWLIST_APPLICATION_FAILED key=" .. contract.Key .. " error=" .. tostring(allowResult))
  end

  local safeOK, safeResult = pcall(function()
    return airwing:SetSafeParkingOn()
  end)
  if not safeOK then
    fail("SAFE_PARKING_APPLICATION_FAILED key=" .. contract.Key .. " error=" .. tostring(safeResult))
  end

  if airwing.safeparking ~= true then
    fail("SAFE_PARKING_NOT_ENABLED key=" .. contract.Key .. " actual=" .. tostring(airwing.safeparking))
  end
  if not sameNumericSet(airwing.parkingIDs, contract.AllowedIDs) then
    fail("AIRWING_PARKING_IDS_MISMATCH key=" .. contract.Key)
  end
  if getRunning(airwing) then
    fail("AIRWING_STARTED_DURING_PARKING_CONTRACT key=" .. contract.Key)
  end

  log(string.format(
    "CONTRACT_APPLIED key=%s airwing=%s allowed=%d blocked=%d safeParking=%s running=false",
    contract.Key,
    tostring(airwing.alias),
    #contract.AllowedIDs,
    #contract.BlockedIDs,
    tostring(airwing.safeparking)
  ))
end

local function main()
  log("BEGIN mode=parking-contract noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true")

  if OMW.AirOps.KandaharParkingContractPreflight then
    log("RESULT: FAIL reason=PARKING_PREFLIGHT_ALREADY_EXECUTED noStart=true noSpawn=true")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_PREFLIGHT_NOT_PASSED noStart=true noSpawn=true")
    return
  end

  if not AIRBASE or not SET_STATIC then
    log("RESULT: FAIL reason=REQUIRED_MOOSE_CLASSES_UNAVAILABLE noStart=true noSpawn=true")
    return
  end

  local mainAirbase = AIRBASE:FindByName(AIRBASE.Afghanistan.Kandahar)
  local heliport = AIRBASE:FindByName(AIRBASE.Afghanistan.Kandahar_Heliport)
  if not mainAirbase or not heliport then
    log("RESULT: FAIL reason=AIRBASE_UNAVAILABLE noStart=true noSpawn=true")
    return
  end
  if tonumber(mainAirbase:GetID()) ~= 7 or tonumber(heliport:GetID()) ~= 15 then
    log("RESULT: FAIL reason=AIRBASE_ID_CONTRACT_MISMATCH noStart=true noSpawn=true")
    return
  end

  local contracts = {
    Main = newContract("Main", mainAirbase),
    Heliport = newContract("Heliport", heliport)
  }

  reserveClients(contracts.Main, CLIENT_RESERVED.Main)
  reserveClients(contracts.Heliport, CLIENT_RESERVED.Heliport)
  local staticCount = blockStatics(contracts)
  finalizeContract(contracts.Main)
  finalizeContract(contracts.Heliport)

  if violations == 0 then
    applyContract(contracts.Main, registration.Airwings.Main)
    applyContract(contracts.Heliport, registration.Airwings.Heliport)
  end

  OMW.AirOps.KandaharParkingContractPreflight = {
    Contracts = contracts,
    Violations = violations,
    Applied = violations == 0,
    Started = false
  }

  if violations == 0 then
    log(string.format(
      "RESULT: PASS airwings=2 mainTotal=%d mainAllowed=%d mainBlocked=%d heliportTotal=%d heliportAllowed=%d heliportBlocked=%d clientReservations=10 statics=%d safeParking=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      #contracts.Main.AllIDs,
      #contracts.Main.AllowedIDs,
      #contracts.Main.BlockedIDs,
      #contracts.Heliport.AllIDs,
      #contracts.Heliport.AllowedIDs,
      #contracts.Heliport.BlockedIDs,
      staticCount
    ))
  else
    log(string.format(
      "RESULT: FAIL violations=%d noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      violations
    ))
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 16)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 16)
end
