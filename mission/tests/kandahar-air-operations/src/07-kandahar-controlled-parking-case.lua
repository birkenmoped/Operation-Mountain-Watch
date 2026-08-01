-- Operation Mountain Watch - Kandahar controlled parking case.
-- Starts exactly one approved AIRWING and performs one warehouse self-request.
-- The requested aircraft group remains uncontrolled on the ground. No AUFTRAG,
-- OPSTRANSPORT, payload registration, taxi command, or mission assignment is created.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.ControlledParking]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local CASE = OMW_KAF_CONTROLLED_PARKING_CASE
local violations = 0
local completed = false
local requestIssued = false
local spawnedGroups = {}
local spawnedUnits = {}
local observedTerminalIDs = {}

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function toSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[tonumber(value)] = true
  end
  return result
end

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function nearestSpot(coordinate, contract)
  local selectedSpot, selectedDistance = nil, nil
  for _, spot in ipairs(contract.Spots or {}) do
    local distance = distance2D(coordinate, spot.Coordinate)
    if distance and (not selectedDistance or distance < selectedDistance) then
      selectedSpot = spot
      selectedDistance = distance
    end
  end
  return selectedSpot, selectedDistance
end

local function getRequestAssignment(airwing, request)
  if airwing and airwing.GetAssignment then
    local ok, value = pcall(function()
      return airwing:GetAssignment(request)
    end)
    if ok and value then return tostring(value) end
  end
  if type(request) == "table" then
    return tostring(request.assignment or request.Assignment or "")
  end
  return ""
end

local function verifyOtherAirwingStopped(registration)
  local otherKey = CASE.AirwingKey == "Main" and "Heliport" or "Main"
  local other = registration.Airwings[otherKey]
  if other and other.IsRunning then
    local ok, running = pcall(function() return other:IsRunning() end)
    if ok and running == true then
      fail("NON_TEST_AIRWING_RUNNING key=" .. otherKey)
    end
  end
end

local function finishResult()
  if completed then return end
  completed = true

  if #spawnedGroups ~= tonumber(CASE.ExpectedAssetGroups) then
    fail(string.format(
      "SPAWNED_GROUP_COUNT_MISMATCH case=%s expected=%d actual=%d",
      tostring(CASE.Key),
      tonumber(CASE.ExpectedAssetGroups),
      #spawnedGroups
    ))
  end

  if #spawnedUnits ~= tonumber(CASE.ExpectedUnits) then
    fail(string.format(
      "SPAWNED_UNIT_COUNT_MISMATCH case=%s expected=%d actual=%d",
      tostring(CASE.Key),
      tonumber(CASE.ExpectedUnits),
      #spawnedUnits
    ))
  end

  if violations == 0 then
    log(string.format(
      "RESULT: PASS case=%s airwingKey=%s squadron=%s template=%s type=%s assetGroups=%d units=%d terminalIDs=%s cold=true uncontrolled=true oneAirwingStarted=true noAUFTRAG=true noTransport=true noPayloadMutation=true noClientParking=true",
      tostring(CASE.Key),
      tostring(CASE.AirwingKey),
      tostring(CASE.SquadronName),
      tostring(CASE.Template),
      tostring(CASE.Type),
      #spawnedGroups,
      #spawnedUnits,
      table.concat(observedTerminalIDs, ",")
    ))
  else
    log(string.format(
      "RESULT: FAIL case=%s violations=%d requestIssued=%s spawnedGroups=%d spawnedUnits=%d",
      tostring(CASE.Key),
      violations,
      tostring(requestIssued),
      #spawnedGroups,
      #spawnedUnits
    ))
  end

  local state = OMW.AirOps.KandaharControlledParkingCase
  if state then
    state.Violations = violations
    state.RequestIssued = requestIssued
    state.Completed = completed
    state.SpawnedGroups = spawnedGroups
    state.SpawnedUnits = spawnedUnits
    state.TerminalIDs = observedTerminalIDs
  end
end

local function inspectSpawnedGroups(groupset, contract)
  if not groupset or not groupset.ForEachGroup then
    fail("SELF_REQUEST_GROUPSET_INVALID case=" .. tostring(CASE.Key))
    finishResult()
    return
  end

  local allowedSet = toSet(contract.AllowedIDs)
  local blockedSet = toSet(contract.BlockedIDs)
  local terminalSeen = {}

  groupset:ForEachGroup(function(group)
    local groupName = tostring(group:GetName())
    spawnedGroups[#spawnedGroups + 1] = groupName

    local alive = group:IsAlive() == true
    local airborne = group:IsAirborne() == true
    local onGround = group:AllOnGround() == true
    if not alive then
      fail("SPAWNED_GROUP_NOT_ALIVE group=" .. groupName)
    end
    if airborne then
      fail("SPAWNED_GROUP_AIRBORNE group=" .. groupName)
    end
    if not onGround then
      fail("SPAWNED_GROUP_NOT_ALL_ON_GROUND group=" .. groupName)
    end

    local units = group:GetUnits() or {}
    log(string.format(
      "GROUP_SPAWNED case=%s group=%s units=%d alive=%s airborne=%s allOnGround=%s",
      tostring(CASE.Key),
      groupName,
      #units,
      tostring(alive),
      tostring(airborne),
      tostring(onGround)
    ))

    for _, unit in ipairs(units) do
      local unitName = tostring(unit:GetName())
      local typeName = tostring(unit:GetTypeName())
      local coordinate = unit:GetCoordinate()
      local spot, distance = nearestSpot(coordinate, contract)
      local terminalID = spot and tonumber(spot.TerminalID) or nil
      local allowed = terminalID and allowedSet[terminalID] == true or false
      local blocked = terminalID and blockedSet[terminalID] == true or false

      spawnedUnits[#spawnedUnits + 1] = unitName

      if typeName ~= tostring(CASE.Type) then
        fail(string.format(
          "SPAWNED_TYPE_MISMATCH unit=%s expected=%s actual=%s",
          unitName,
          tostring(CASE.Type),
          typeName
        ))
      end
      if not terminalID then
        fail("SPAWNED_UNIT_TERMINAL_UNRESOLVED unit=" .. unitName)
      else
        if not allowed then
          fail(string.format("SPAWNED_UNIT_NOT_ON_ALLOWLIST unit=%s terminalID=%d", unitName, terminalID))
        end
        if blocked then
          fail(string.format("SPAWNED_UNIT_ON_BLOCKED_TERMINAL unit=%s terminalID=%d", unitName, terminalID))
        end
        if terminalSeen[terminalID] then
          fail(string.format("DUPLICATE_TERMINAL_ASSIGNMENT terminalID=%d unit=%s", terminalID, unitName))
        end
        terminalSeen[terminalID] = true
        observedTerminalIDs[#observedTerminalIDs + 1] = terminalID
      end

      if not distance or distance > tonumber(CASE.MaxNodeDistance) then
        fail(string.format(
          "SPAWNED_UNIT_NODE_DISTANCE_EXCEEDED unit=%s terminalID=%s max=%.1f actual=%s",
          unitName,
          tostring(terminalID),
          tonumber(CASE.MaxNodeDistance),
          distance and string.format("%.2f", distance) or "nil"
        ))
      end

      log(string.format(
        "UNIT_PARKED case=%s group=%s unit=%s type=%s terminalID=%s terminalType=%s distance=%.2f allowed=%s blocked=%s",
        tostring(CASE.Key),
        groupName,
        unitName,
        typeName,
        tostring(terminalID),
        spot and tostring(spot.TerminalType) or "nil",
        tonumber(distance) or -1,
        tostring(allowed),
        tostring(blocked)
      ))
    end
  end)

  table.sort(observedTerminalIDs)
  finishResult()
end

local function issueRequest(registration, parking)
  local airwing = registration.Airwings[CASE.AirwingKey]
  local contract = parking.Contracts[CASE.AirwingKey]
  if not airwing or not contract then
    fail("CASE_RUNTIME_OBJECT_MISSING case=" .. tostring(CASE.Key))
    finishResult()
    return
  end

  local squadron = registration.Squadrons[CASE.SquadronName]
  if not squadron then
    fail("CASE_SQUADRON_MISSING squadron=" .. tostring(CASE.SquadronName))
    finishResult()
    return
  end
  if tostring(squadron.templatename) ~= tostring(CASE.Template) then
    fail(string.format(
      "CASE_TEMPLATE_BINDING_MISMATCH squadron=%s expected=%s actual=%s",
      tostring(CASE.SquadronName),
      tostring(CASE.Template),
      tostring(squadron.templatename)
    ))
    finishResult()
    return
  end

  verifyOtherAirwingStopped(registration)

  local previousSelfRequest = airwing.OnAfterSelfRequest
  function airwing:OnAfterSelfRequest(From, Event, To, groupset, request)
    if previousSelfRequest then
      pcall(previousSelfRequest, self, From, Event, To, groupset, request)
    end

    local assignment = getRequestAssignment(self, request)
    if assignment ~= tostring(CASE.Assignment) then
      log(string.format(
        "SELF_REQUEST_IGNORED case=%s assignment=%s expected=%s",
        tostring(CASE.Key),
        assignment,
        tostring(CASE.Assignment)
      ))
      return
    end

    log(string.format(
      "SELF_REQUEST_FULFILLED case=%s assignment=%s",
      tostring(CASE.Key),
      assignment
    ))
    inspectSpawnedGroups(groupset, contract)
  end

  if airwing.SetStatusUpdate then
    airwing:SetStatusUpdate(5)
  end
  if airwing.SetTakeoffCold then
    airwing:SetTakeoffCold()
  end

  local startOK, startResult = pcall(function()
    return airwing:Start()
  end)
  if not startOK then
    fail("AIRWING_START_FAILED case=" .. tostring(CASE.Key) .. " error=" .. tostring(startResult))
    finishResult()
    return
  end

  local running = false
  if airwing.IsRunning then
    local stateOK, stateValue = pcall(function() return airwing:IsRunning() end)
    running = stateOK and stateValue == true
  end
  if not running then
    fail("AIRWING_NOT_RUNNING_AFTER_START case=" .. tostring(CASE.Key))
    finishResult()
    return
  end

  verifyOtherAirwingStopped(registration)

  local requestOK, requestResult = pcall(function()
    return airwing:AddRequest(
      airwing,
      WAREHOUSE.Descriptor.GROUPNAME,
      CASE.Template,
      tonumber(CASE.ExpectedAssetGroups),
      nil,
      nil,
      1,
      CASE.Assignment
    )
  end)
  requestIssued = requestOK
  if not requestOK then
    fail("SELF_REQUEST_ADD_FAILED case=" .. tostring(CASE.Key) .. " error=" .. tostring(requestResult))
    finishResult()
    return
  end

  log(string.format(
    "REQUEST_ISSUED case=%s airwing=%s squadron=%s template=%s expectedAssetGroups=%d expectedUnits=%d assignment=%s",
    tostring(CASE.Key),
    tostring(airwing.alias),
    tostring(CASE.SquadronName),
    tostring(CASE.Template),
    tonumber(CASE.ExpectedAssetGroups),
    tonumber(CASE.ExpectedUnits),
    tostring(CASE.Assignment)
  ))
end

local function main()
  log("BEGIN mode=controlled-parking-case oneAirwingStarted=true oneAssetGroupRequested=true cold=true uncontrolled=true noAUFTRAG=true noTransport=true noPayloadMutation=true")

  if OMW.AirOps.KandaharControlledParkingCase then
    log("RESULT: FAIL reason=CONTROLLED_PARKING_CASE_ALREADY_EXECUTED")
    return
  end
  if type(CASE) ~= "table" then
    log("RESULT: FAIL reason=CONTROLLED_PARKING_CASE_CONFIG_MISSING")
    return
  end
  if not WAREHOUSE or not WAREHOUSE.Descriptor or not WAREHOUSE.Descriptor.GROUPNAME then
    log("RESULT: FAIL reason=WAREHOUSE_GROUPNAME_DESCRIPTOR_UNAVAILABLE")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  local parking = OMW.AirOps.KandaharParkingContractPreflight
  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_PREFLIGHT_NOT_PASSED")
    return
  end
  if not parking or parking.Applied ~= true or tonumber(parking.Violations) ~= 0 then
    log("RESULT: FAIL reason=PARKING_CONTRACT_PREFLIGHT_NOT_PASSED")
    return
  end

  OMW.AirOps.KandaharControlledParkingCase = {
    Case = CASE,
    Violations = 0,
    RequestIssued = false,
    Completed = false
  }

  issueRequest(registration, parking)

  OMW.AirOps.KandaharControlledParkingCase.RequestIssued = requestIssued

  local function timeout()
    if not completed then
      fail("SELF_REQUEST_TIMEOUT case=" .. tostring(CASE.Key))
      finishResult()
    end
    OMW.AirOps.KandaharControlledParkingCase.Violations = violations
    OMW.AirOps.KandaharControlledParkingCase.Completed = completed
  end

  if SCHEDULER then
    SCHEDULER:New(nil, timeout, {}, 60)
  else
    timer.scheduleFunction(function()
      timeout()
      return nil
    end, nil, timer.getTime() + 60)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 28)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 28)
end
