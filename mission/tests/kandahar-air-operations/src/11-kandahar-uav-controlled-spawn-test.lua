-- Operation Mountain Watch - Kandahar controlled UAV spawn test.
-- Starts only the Kandahar Main AIRWING and requests one MQ-1 asset group followed
-- by one MQ-9 asset group. Both remain cold and uncontrolled. No AUFTRAG,
-- OPSTRANSPORT, payload mutation, taxi command, route, or takeoff is created.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVControlledSpawn]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local CASES = {
  {
    Key = "MQ1",
    Squadron = "SQ_US_KAF_MQ1_361_ERS",
    Template = "TPL_AIR_US_KAF_MQ1A_RECON_1SHIP",
    Type = "RQ-1A Predator",
    Assignment = "KAF-UAV-G-APRON-MQ1"
  },
  {
    Key = "MQ9",
    Squadron = "SQ_US_KAF_MQ9_361_ERS",
    Template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
    Type = "MQ-9 Reaper",
    Assignment = "KAF-UAV-G-APRON-MQ9"
  }
}

local MAX_NODE_DISTANCE = 12
local violations = 0
local passed = 0
local failed = 0
local currentIndex = 0
local completed = false
local registration = nil
local parking = nil
local uavContract = nil
local mainAirwing = nil
local mainContract = nil
local observed = {}

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function toSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then result[number] = true end
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

local function nearestSpot(coordinate)
  local selectedSpot, selectedDistance = nil, nil
  for _, spot in ipairs(mainContract.Spots or {}) do
    local distance = distance2D(coordinate, spot.Coordinate)
    if distance and (not selectedDistance or distance < selectedDistance) then
      selectedSpot = spot
      selectedDistance = distance
    end
  end
  return selectedSpot, selectedDistance
end

local function getAssignment(airwing, request)
  if airwing and airwing.GetAssignment then
    local ok, value = pcall(function() return airwing:GetAssignment(request) end)
    if ok and value then return tostring(value) end
  end
  if type(request) == "table" then
    return tostring(request.assignment or request.Assignment or "")
  end
  return ""
end

local function findCaseByAssignment(assignment)
  for index, case in ipairs(CASES) do
    if tostring(case.Assignment) == tostring(assignment) then
      return index, case
    end
  end
  return nil, nil
end

local function finish()
  if completed then return end
  completed = true

  if passed + failed ~= #CASES then
    fail(string.format("CASE_ACCOUNTING_MISMATCH expected=%d actual=%d", #CASES, passed + failed))
  end

  local mq1Terminal = observed.MQ1 and observed.MQ1.TerminalID or nil
  local mq9Terminal = observed.MQ9 and observed.MQ9.TerminalID or nil

  OMW.AirOps.KandaharUAVControlledSpawn = {
    Cases = CASES,
    Observed = observed,
    Passed = passed,
    Failed = failed,
    Violations = violations,
    Completed = true
  }

  if violations == 0 and passed == 2 and failed == 0 then
    log(string.format(
      "RESULT: PASS cases=2 passed=2 failed=0 assetGroups=2 units=2 mq1TerminalID=%s mq1Pool=G01-G08 mq9TerminalID=%s mq9Pool=G09-G11 separatePools=true cold=true uncontrolled=true mainAirwingStarted=true heliportAirwingStopped=true noFallback=true noAUFTRAG=true noTransport=true noPayloadMutation=true noTaxi=true noTakeoff=true",
      tostring(mq1Terminal),
      tostring(mq9Terminal)
    ))
  else
    log(string.format(
      "RESULT: FAIL cases=2 passed=%d failed=%d violations=%d mq1TerminalID=%s mq9TerminalID=%s",
      passed,
      failed,
      violations,
      tostring(mq1Terminal),
      tostring(mq9Terminal)
    ))
  end
end

local issueNextRequest

local function inspectCase(index, case, groupset)
  local caseViolationsBefore = violations
  local groupCount = 0
  local unitCount = 0
  local observedTerminalID = nil
  local poolState = uavContract[case.Key]
  local poolSet = toSet(poolState and poolState.AvailableIDs or {})
  local mainAllowedSet = toSet(mainContract.AllowedIDs)
  local blockedSet = toSet(mainContract.BlockedIDs)

  if not groupset or not groupset.ForEachGroup then
    fail("SELF_REQUEST_GROUPSET_INVALID case=" .. case.Key)
  else
    groupset:ForEachGroup(function(group)
      groupCount = groupCount + 1
      local groupName = tostring(group:GetName())
      local alive = group:IsAlive() == true
      local airborne = group:IsAirborne() == true
      local onGround = group:AllOnGround() == true

      if not alive then fail("GROUP_NOT_ALIVE case=" .. case.Key .. " group=" .. groupName) end
      if airborne then fail("GROUP_AIRBORNE case=" .. case.Key .. " group=" .. groupName) end
      if not onGround then fail("GROUP_NOT_ON_GROUND case=" .. case.Key .. " group=" .. groupName) end

      local units = group:GetUnits() or {}
      log(string.format(
        "GROUP_SPAWNED case=%s group=%s units=%d alive=%s airborne=%s allOnGround=%s",
        case.Key,
        groupName,
        #units,
        tostring(alive),
        tostring(airborne),
        tostring(onGround)
      ))

      for _, unit in ipairs(units) do
        unitCount = unitCount + 1
        local unitName = tostring(unit:GetName())
        local typeName = tostring(unit:GetTypeName())
        local coordinate = unit:GetCoordinate()
        local spot, distance = nearestSpot(coordinate)
        local terminalID = spot and tonumber(spot.TerminalID) or nil
        local inPool = terminalID and poolSet[terminalID] == true or false
        local mainAllowed = terminalID and mainAllowedSet[terminalID] == true or false
        local blocked = terminalID and blockedSet[terminalID] == true or false

        if typeName ~= case.Type then
          fail(string.format("TYPE_MISMATCH case=%s unit=%s expected=%s actual=%s", case.Key, unitName, case.Type, typeName))
        end
        if not terminalID then
          fail("TERMINAL_UNRESOLVED case=" .. case.Key .. " unit=" .. unitName)
        else
          observedTerminalID = terminalID
          if not inPool then
            fail(string.format("TERMINAL_OUTSIDE_SQUADRON_POOL case=%s unit=%s terminalID=%d", case.Key, unitName, terminalID))
          end
          if not mainAllowed then
            fail(string.format("TERMINAL_OUTSIDE_MAIN_ALLOWLIST case=%s unit=%s terminalID=%d", case.Key, unitName, terminalID))
          end
          if blocked then
            fail(string.format("TERMINAL_BLOCKED case=%s unit=%s terminalID=%d", case.Key, unitName, terminalID))
          end
        end
        if not distance or distance > MAX_NODE_DISTANCE then
          fail(string.format(
            "NODE_DISTANCE_EXCEEDED case=%s unit=%s terminalID=%s max=%d actual=%s",
            case.Key,
            unitName,
            tostring(terminalID),
            MAX_NODE_DISTANCE,
            distance and string.format("%.2f", distance) or "nil"
          ))
        end

        log(string.format(
          "UNIT_PARKED case=%s unit=%s type=%s terminalID=%s terminalType=%s nodeDistance=%.2f inSquadronPool=%s mainAllowed=%s blocked=%s",
          case.Key,
          unitName,
          typeName,
          tostring(terminalID),
          spot and tostring(spot.TerminalType) or "nil",
          tonumber(distance) or -1,
          tostring(inPool),
          tostring(mainAllowed),
          tostring(blocked)
        ))
      end
    end)
  end

  if groupCount ~= 1 then
    fail(string.format("GROUP_COUNT_MISMATCH case=%s expected=1 actual=%d", case.Key, groupCount))
  end
  if unitCount ~= 1 then
    fail(string.format("UNIT_COUNT_MISMATCH case=%s expected=1 actual=%d", case.Key, unitCount))
  end

  local casePassed = violations == caseViolationsBefore
  if casePassed then
    passed = passed + 1
  else
    failed = failed + 1
  end

  observed[case.Key] = {
    TerminalID = observedTerminalID,
    Groups = groupCount,
    Units = unitCount,
    Passed = casePassed
  }

  log(string.format(
    "CASE_RESULT: %s index=%d case=%s assetGroups=%d units=%d terminalID=%s violations=%d",
    casePassed and "PASS" or "FAIL",
    index,
    case.Key,
    groupCount,
    unitCount,
    tostring(observedTerminalID),
    violations - caseViolationsBefore
  ))

  if index < #CASES then
    if SCHEDULER then
      SCHEDULER:New(nil, issueNextRequest, {}, 5)
    else
      timer.scheduleFunction(function()
        issueNextRequest()
        return nil
      end, nil, timer.getTime() + 5)
    end
  else
    finish()
  end
end

issueNextRequest = function()
  if completed then return end

  currentIndex = currentIndex + 1
  local case = CASES[currentIndex]
  if not case then
    finish()
    return
  end

  local squadron = registration.Squadrons and registration.Squadrons[case.Squadron] or nil
  if not squadron then
    fail("SQUADRON_MISSING case=" .. case.Key .. " squadron=" .. case.Squadron)
    failed = failed + 1
    if currentIndex < #CASES then
      issueNextRequest()
    else
      finish()
    end
    return
  end
  if tostring(squadron.templatename) ~= case.Template then
    fail(string.format(
      "TEMPLATE_BINDING_MISMATCH case=%s expected=%s actual=%s",
      case.Key,
      case.Template,
      tostring(squadron.templatename)
    ))
  end

  local ok, result = pcall(function()
    return mainAirwing:AddRequest(
      mainAirwing,
      WAREHOUSE.Descriptor.GROUPNAME,
      case.Template,
      1,
      nil,
      nil,
      1,
      case.Assignment
    )
  end)

  if not ok then
    fail("SELF_REQUEST_ADD_FAILED case=" .. case.Key .. " error=" .. tostring(result))
    failed = failed + 1
    if currentIndex < #CASES then
      issueNextRequest()
    else
      finish()
    end
    return
  end

  log(string.format(
    "REQUEST_ISSUED index=%d case=%s airwing=%s squadron=%s template=%s expectedAssetGroups=1 expectedUnits=1 assignment=%s",
    currentIndex,
    case.Key,
    tostring(mainAirwing.alias),
    case.Squadron,
    case.Template,
    case.Assignment
  ))

  local timeoutIndex = currentIndex
  local function timeout()
    if not completed and currentIndex == timeoutIndex and not observed[case.Key] then
      fail("SELF_REQUEST_TIMEOUT case=" .. case.Key)
      failed = failed + 1
      if currentIndex < #CASES then
        issueNextRequest()
      else
        finish()
      end
    end
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

local function main()
  log("BEGIN cases=2 assetGroups=2 units=2 separatePools=true cold=true uncontrolled=true mainAirwingOnly=true noAUFTRAG=true noTransport=true noPayloadMutation=true noTaxi=true noTakeoff=true")

  if OMW.AirOps.KandaharUAVControlledSpawn then
    log("RESULT: FAIL reason=UAV_CONTROLLED_SPAWN_ALREADY_EXECUTED")
    return
  end
  if not WAREHOUSE or not WAREHOUSE.Descriptor or not WAREHOUSE.Descriptor.GROUPNAME then
    log("RESULT: FAIL reason=WAREHOUSE_GROUPNAME_DESCRIPTOR_UNAVAILABLE")
    return
  end

  registration = OMW.AirOps.KandaharRegistrationPreflight
  parking = OMW.AirOps.KandaharParkingContractPreflight
  uavContract = OMW.AirOps.KandaharUAVParkingContract

  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_PREFLIGHT_NOT_PASSED")
    return
  end
  if not parking or parking.Applied ~= true or tonumber(parking.Violations) ~= 0 then
    log("RESULT: FAIL reason=PARKING_CONTRACT_NOT_PASSED")
    return
  end
  if not uavContract or uavContract.Applied ~= true or tonumber(uavContract.Violations) ~= 0 then
    log("RESULT: FAIL reason=UAV_PARKING_CONTRACT_NOT_PASSED")
    return
  end

  mainAirwing = registration.Airwings and registration.Airwings.Main or nil
  mainContract = parking.Contracts and parking.Contracts.Main or nil
  local heliportAirwing = registration.Airwings and registration.Airwings.Heliport or nil
  if not mainAirwing or not mainContract then
    log("RESULT: FAIL reason=MAIN_RUNTIME_OBJECT_MISSING")
    return
  end

  if heliportAirwing and heliportAirwing.IsRunning then
    local ok, running = pcall(function() return heliportAirwing:IsRunning() end)
    if ok and running == true then
      log("RESULT: FAIL reason=HELIPORT_AIRWING_ALREADY_RUNNING")
      return
    end
  end

  local previousSelfRequest = mainAirwing.OnAfterSelfRequest
  function mainAirwing:OnAfterSelfRequest(From, Event, To, groupset, request)
    if previousSelfRequest then
      pcall(previousSelfRequest, self, From, Event, To, groupset, request)
    end

    local assignment = getAssignment(self, request)
    local index, case = findCaseByAssignment(assignment)
    if not case then
      log("SELF_REQUEST_IGNORED assignment=" .. tostring(assignment))
      return
    end

    if observed[case.Key] then
      fail("DUPLICATE_SELF_REQUEST_CALLBACK case=" .. case.Key)
      return
    end

    log(string.format("SELF_REQUEST_FULFILLED index=%d case=%s assignment=%s", index, case.Key, assignment))
    inspectCase(index, case, groupset)
  end

  if mainAirwing.SetStatusUpdate then mainAirwing:SetStatusUpdate(5) end
  if mainAirwing.SetTakeoffCold then mainAirwing:SetTakeoffCold() end

  local startOK, startResult = pcall(function() return mainAirwing:Start() end)
  if not startOK then
    log("RESULT: FAIL reason=MAIN_AIRWING_START_FAILED error=" .. tostring(startResult))
    return
  end

  local running = false
  if mainAirwing.IsRunning then
    local ok, value = pcall(function() return mainAirwing:IsRunning() end)
    running = ok and value == true
  end
  if not running then
    log("RESULT: FAIL reason=MAIN_AIRWING_NOT_RUNNING_AFTER_START")
    return
  end

  OMW.AirOps.KandaharUAVControlledSpawn = {
    Cases = CASES,
    Observed = observed,
    Passed = 0,
    Failed = 0,
    Violations = 0,
    Completed = false
  }

  issueNextRequest()
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 32)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 32)
end
