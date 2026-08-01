-- Operation Mountain Watch - Kandahar UAV full-cycle return and final parking test.
--
-- Starts one MQ-1 and one MQ-9 through AIRWING/AUFTRAG ORBIT missions, observes
-- engine start, taxi, takeoff, airborne mission execution, RTB, landing, taxi-in
-- and final parking. The test does not force a parking position after landing;
-- it validates the position selected by MOOSE/DCS against the accepted type pool.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVReturnParking]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local CONFIG = {
  ExpectedAirbaseID = 7,
  MissionDuration = 180,
  MissionStagger = 45,
  OverallTimeout = 2400,
  OrbitDistanceNM = 8,
  Cases = {
    MQ1 = {
      Key = "MQ1",
      Squadron = "SQ_US_KAF_MQ1_361_ERS",
      Template = "TPL_AIR_US_KAF_MQ1A_RECON_1SHIP",
      Type = "RQ-1A Predator",
      AltitudeFeet = 10000,
      SpeedKnots = 110,
      Heading = 90,
      LegNM = 2
    },
    MQ9 = {
      Key = "MQ9",
      Squadron = "SQ_US_KAF_MQ9_361_ERS",
      Template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
      Type = "MQ-9 Reaper",
      AltitudeFeet = 12000,
      SpeedKnots = 160,
      Heading = 90,
      LegNM = 2
    }
  }
}

local runtime = {
  Started = false,
  Completed = false,
  Violations = 0,
  Cases = {},
  MissionCases = {},
  MainAirwing = nil,
  MainAirbase = nil,
  MainContract = nil,
  UAVContract = nil
}

local function fail(reason)
  runtime.Violations = runtime.Violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function schedule(delay, fn)
  if SCHEDULER then
    SCHEDULER:New(nil, fn, {}, delay)
  else
    timer.scheduleFunction(function()
      fn()
      return nil
    end, nil, timer.getTime() + delay)
  end
end

local function toNumericSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then result[number] = true end
  end
  return result
end

local function join(values)
  if not values or #values == 0 then return "none" end
  local text = {}
  for _, value in ipairs(values) do text[#text + 1] = tostring(value) end
  return table.concat(text, ",")
end

local function elementName(element)
  if not element then return "nil" end
  return tostring(element.name or element.unitname or element.groupname or element.uid or "unknown")
end

local function groupName(flightGroup)
  if not flightGroup then return "nil" end
  if flightGroup.GetName then
    local ok, value = pcall(function() return flightGroup:GetName() end)
    if ok and value then return tostring(value) end
  end
  if flightGroup.GetGroup then
    local ok, group = pcall(function() return flightGroup:GetGroup() end)
    if ok and group and group.GetName then return tostring(group:GetName()) end
  end
  return tostring(flightGroup.groupname or flightGroup.alias or "unknown")
end

local function airbaseID(airbase)
  if not airbase or not airbase.GetID then return nil end
  local ok, value = pcall(function() return airbase:GetID() end)
  if ok then return tonumber(value) end
  return nil
end

local function validateFinalSpot(caseState, terminalID, source)
  terminalID = tonumber(terminalID)
  if not terminalID then
    fail("FINAL_TERMINAL_ID_MISSING case=" .. caseState.Definition.Key .. " source=" .. tostring(source))
    return false
  end

  local inTypePool = caseState.PoolSet[terminalID] == true
  local mainAllowed = caseState.MainAllowedSet[terminalID] == true
  local blocked = caseState.BlockedSet[terminalID] == true

  log(string.format(
    "FINAL_PARKING_CHECK case=%s source=%s terminalID=%d inTypePool=%s mainAllowed=%s blocked=%s",
    caseState.Definition.Key,
    tostring(source),
    terminalID,
    tostring(inTypePool),
    tostring(mainAllowed),
    tostring(blocked)
  ))

  if not inTypePool then
    fail(string.format(
      "FINAL_PARKING_OUTSIDE_TYPE_POOL case=%s terminalID=%d pool=%s",
      caseState.Definition.Key,
      terminalID,
      join(caseState.Pool.AvailableIDs)
    ))
  end
  if not mainAllowed then
    fail(string.format("FINAL_PARKING_NOT_MAIN_ALLOWED case=%s terminalID=%d", caseState.Definition.Key, terminalID))
  end
  if blocked then
    fail(string.format("FINAL_PARKING_BLOCKED case=%s terminalID=%d", caseState.Definition.Key, terminalID))
  end

  if inTypePool and mainAllowed and not blocked then
    caseState.FinalTerminalID = terminalID
    caseState.FinalParking = true
    return true
  end
  return false
end

local function caseReady(caseState)
  return caseState.EngineOn == true
    and caseState.TaxiOut == true
    and caseState.Takeoff == true
    and caseState.Airborne == true
    and caseState.Landed == true
    and caseState.FinalParking == true
    and caseState.Arrived == true
    and caseState.Dead ~= true
    and caseState.Destroyed ~= true
end

local function finishIfComplete()
  if runtime.Completed then return end

  local mq1 = runtime.Cases.MQ1
  local mq9 = runtime.Cases.MQ9
  if not mq1 or not mq9 then return end
  if mq1.Arrived ~= true or mq9.Arrived ~= true then return end

  runtime.Completed = true
  local mq1Ready = caseReady(mq1)
  local mq9Ready = caseReady(mq9)

  if not mq1Ready then
    fail(string.format(
      "CASE_INCOMPLETE case=MQ1 engineOn=%s taxiOut=%s takeoff=%s airborne=%s landed=%s finalParking=%s arrived=%s dead=%s destroyed=%s",
      tostring(mq1.EngineOn), tostring(mq1.TaxiOut), tostring(mq1.Takeoff), tostring(mq1.Airborne),
      tostring(mq1.Landed), tostring(mq1.FinalParking), tostring(mq1.Arrived), tostring(mq1.Dead), tostring(mq1.Destroyed)
    ))
  end
  if not mq9Ready then
    fail(string.format(
      "CASE_INCOMPLETE case=MQ9 engineOn=%s taxiOut=%s takeoff=%s airborne=%s landed=%s finalParking=%s arrived=%s dead=%s destroyed=%s",
      tostring(mq9.EngineOn), tostring(mq9.TaxiOut), tostring(mq9.Takeoff), tostring(mq9.Airborne),
      tostring(mq9.Landed), tostring(mq9.FinalParking), tostring(mq9.Arrived), tostring(mq9.Dead), tostring(mq9.Destroyed)
    ))
  end

  if runtime.Violations == 0 and mq1Ready and mq9Ready then
    log(string.format(
      "RESULT: PASS cases=2 passed=2 failed=0 mq1FinalTerminalID=%s mq1Pool=G01-G08 mq9FinalTerminalID=%s mq9Pool=G09-G11 engineStart=true taxiOut=true takeoff=true airborne=true orbit=true rtb=true landing=true taxiIn=true finalParking=true separatePools=true noFallback=true mainAirwingStarted=true heliportAirwingStopped=true auftrag=true payloadsFromApprovedTemplates=true despawnAfterLanding=false warehouseReturnNotClaimed=true",
      tostring(mq1.FinalTerminalID),
      tostring(mq9.FinalTerminalID)
    ))
  else
    log(string.format(
      "RESULT: FAIL cases=2 mq1Ready=%s mq9Ready=%s violations=%d mq1FinalTerminalID=%s mq9FinalTerminalID=%s warehouseReturnNotClaimed=true",
      tostring(mq1Ready),
      tostring(mq9Ready),
      runtime.Violations,
      tostring(mq1.FinalTerminalID),
      tostring(mq9.FinalTerminalID)
    ))
  end
end

local function attachFlightCallbacks(caseState, flightGroup)
  caseState.FlightGroup = flightGroup
  caseState.GroupName = groupName(flightGroup)

  log(string.format(
    "FLIGHT_ASSIGNED case=%s group=%s missionDuration=%d pool=%s",
    caseState.Definition.Key,
    caseState.GroupName,
    CONFIG.MissionDuration,
    join(caseState.Pool.AvailableIDs)
  ))

  local previousEngineOn = flightGroup.OnAfterElementEngineOn
  function flightGroup:OnAfterElementEngineOn(From, Event, To, Element)
    if previousEngineOn then pcall(previousEngineOn, self, From, Event, To, Element) end
    caseState.EngineOn = true
    log(string.format("ENGINE_ON case=%s group=%s element=%s", caseState.Definition.Key, caseState.GroupName, elementName(Element)))
  end

  local previousTaxiing = flightGroup.OnAfterElementTaxiing
  function flightGroup:OnAfterElementTaxiing(From, Event, To, Element)
    if previousTaxiing then pcall(previousTaxiing, self, From, Event, To, Element) end
    if caseState.Landed then
      caseState.TaxiIn = true
      log(string.format("TAXI_IN case=%s group=%s element=%s", caseState.Definition.Key, caseState.GroupName, elementName(Element)))
    else
      caseState.TaxiOut = true
      log(string.format("TAXI_OUT case=%s group=%s element=%s", caseState.Definition.Key, caseState.GroupName, elementName(Element)))
    end
  end

  local previousTakeoff = flightGroup.OnAfterElementTakeoff
  function flightGroup:OnAfterElementTakeoff(From, Event, To, Element, Airbase)
    if previousTakeoff then pcall(previousTakeoff, self, From, Event, To, Element, Airbase) end
    caseState.Takeoff = true
    log(string.format(
      "TAKEOFF case=%s group=%s element=%s airbaseID=%s",
      caseState.Definition.Key,
      caseState.GroupName,
      elementName(Element),
      tostring(airbaseID(Airbase))
    ))
  end

  local previousAirborne = flightGroup.OnAfterElementAirborne
  function flightGroup:OnAfterElementAirborne(From, Event, To, Element)
    if previousAirborne then pcall(previousAirborne, self, From, Event, To, Element) end
    caseState.Airborne = true
    log(string.format("AIRBORNE case=%s group=%s element=%s", caseState.Definition.Key, caseState.GroupName, elementName(Element)))
  end

  local previousLanded = flightGroup.OnAfterElementLanded
  function flightGroup:OnAfterElementLanded(From, Event, To, Element, Airbase)
    if previousLanded then pcall(previousLanded, self, From, Event, To, Element, Airbase) end
    caseState.Landed = true
    caseState.LandingAirbaseID = airbaseID(Airbase)
    log(string.format(
      "LANDED case=%s group=%s element=%s airbaseID=%s expectedAirbaseID=%d",
      caseState.Definition.Key,
      caseState.GroupName,
      elementName(Element),
      tostring(caseState.LandingAirbaseID),
      CONFIG.ExpectedAirbaseID
    ))
    if caseState.LandingAirbaseID ~= CONFIG.ExpectedAirbaseID then
      fail(string.format(
        "LANDED_AT_WRONG_AIRBASE case=%s expected=%d actual=%s",
        caseState.Definition.Key,
        CONFIG.ExpectedAirbaseID,
        tostring(caseState.LandingAirbaseID)
      ))
    end
  end

  local previousParking = flightGroup.OnAfterElementParking
  function flightGroup:OnAfterElementParking(From, Event, To, Element, Spot)
    if previousParking then pcall(previousParking, self, From, Event, To, Element, Spot) end
    local terminalID = Spot and Spot.TerminalID or nil
    if caseState.Landed then
      caseState.TaxiIn = true
      validateFinalSpot(caseState, terminalID, "ElementParking")
      log(string.format(
        "FINAL_PARKED case=%s group=%s element=%s terminalID=%s",
        caseState.Definition.Key,
        caseState.GroupName,
        elementName(Element),
        tostring(terminalID)
      ))
    else
      log(string.format(
        "INITIAL_PARKING_EVENT case=%s group=%s element=%s terminalID=%s",
        caseState.Definition.Key,
        caseState.GroupName,
        elementName(Element),
        tostring(terminalID)
      ))
    end
  end

  local previousArrived = flightGroup.OnAfterElementArrived
  function flightGroup:OnAfterElementArrived(From, Event, To, Element, Airbase, Parking)
    if previousArrived then pcall(previousArrived, self, From, Event, To, Element, Airbase, Parking) end
    caseState.Arrived = true
    caseState.ArrivalAirbaseID = airbaseID(Airbase)
    local terminalID = Parking and Parking.TerminalID or caseState.FinalTerminalID
    if not caseState.FinalParking then
      validateFinalSpot(caseState, terminalID, "ElementArrived")
    end
    log(string.format(
      "ARRIVED case=%s group=%s element=%s airbaseID=%s terminalID=%s finalParking=%s",
      caseState.Definition.Key,
      caseState.GroupName,
      elementName(Element),
      tostring(caseState.ArrivalAirbaseID),
      tostring(terminalID),
      tostring(caseState.FinalParking)
    ))
    if caseState.ArrivalAirbaseID ~= CONFIG.ExpectedAirbaseID then
      fail(string.format(
        "ARRIVED_AT_WRONG_AIRBASE case=%s expected=%d actual=%s",
        caseState.Definition.Key,
        CONFIG.ExpectedAirbaseID,
        tostring(caseState.ArrivalAirbaseID)
      ))
    end
    finishIfComplete()
  end

  local previousDead = flightGroup.OnAfterElementDead
  function flightGroup:OnAfterElementDead(From, Event, To, Element)
    if previousDead then pcall(previousDead, self, From, Event, To, Element) end
    caseState.Dead = true
    fail("ELEMENT_DEAD case=" .. caseState.Definition.Key .. " element=" .. elementName(Element))
  end

  local previousDestroyed = flightGroup.OnAfterElementDestroyed
  function flightGroup:OnAfterElementDestroyed(From, Event, To, Element)
    if previousDestroyed then pcall(previousDestroyed, self, From, Event, To, Element) end
    caseState.Destroyed = true
    fail("ELEMENT_DESTROYED case=" .. caseState.Definition.Key .. " element=" .. elementName(Element))
  end
end

local function createMission(caseState, orbitCoordinate)
  local definition = caseState.Definition
  local squadron = caseState.Squadron
  local templateGroup = GROUP:FindByName(definition.Template)
  if not templateGroup then
    fail("PAYLOAD_TEMPLATE_GROUP_MISSING case=" .. definition.Key .. " template=" .. definition.Template)
    return nil
  end

  squadron:AddMissionCapability({AUFTRAG.Type.ORBIT})

  local payload = runtime.MainAirwing:NewPayload(
    templateGroup,
    -1,
    {AUFTRAG.Type.ORBIT},
    100
  )
  if not payload then
    fail("ORBIT_PAYLOAD_REGISTRATION_FAILED case=" .. definition.Key)
    return nil
  end
  caseState.Payload = payload

  local mission = AUFTRAG:NewORBIT(
    orbitCoordinate,
    definition.AltitudeFeet,
    definition.SpeedKnots,
    definition.Heading,
    definition.LegNM
  )
  if not mission then
    fail("ORBIT_MISSION_CONSTRUCTION_FAILED case=" .. definition.Key)
    return nil
  end

  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({squadron})
  mission:AddRequiredPayload(payload)
  mission:SetDuration(CONFIG.MissionDuration)
  mission:SetRepeat(0)

  caseState.Mission = mission
  runtime.MissionCases[mission] = caseState
  return mission
end

local function addMission(caseState, orbitCoordinate)
  if runtime.Completed then return end
  local mission = createMission(caseState, orbitCoordinate)
  if not mission then return end

  local ok, result = pcall(function()
    return runtime.MainAirwing:AddMission(mission)
  end)
  if not ok then
    fail("AIRWING_ADD_MISSION_FAILED case=" .. caseState.Definition.Key .. " error=" .. tostring(result))
    return
  end

  caseState.MissionQueued = true
  log(string.format(
    "MISSION_QUEUED case=%s squadron=%s template=%s type=%s altitudeFeet=%d speedKnots=%d duration=%d",
    caseState.Definition.Key,
    caseState.Definition.Squadron,
    caseState.Definition.Template,
    caseState.Definition.Type,
    caseState.Definition.AltitudeFeet,
    caseState.Definition.SpeedKnots,
    CONFIG.MissionDuration
  ))
end

local function main()
  log("BEGIN cases=2 fullCycle=true auftrag=ORBIT engineStart=true taxiOut=true takeoff=true airborne=true rtb=true landing=true taxiIn=true finalParking=true typePools=true noFallback=true warehouseReturnNotClaimed=true")

  if OMW.AirOps.KandaharUAVReturnParking then
    log("RESULT: FAIL reason=UAV_RETURN_PARKING_ALREADY_EXECUTED")
    return
  end
  if not AUFTRAG or not AUFTRAG.Type or not AUFTRAG.Type.ORBIT then
    log("RESULT: FAIL reason=AUFTRAG_ORBIT_UNAVAILABLE")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  local parking = OMW.AirOps.KandaharParkingContractPreflight
  local uavContract = OMW.AirOps.KandaharUAVParkingContract
  local assetSync = OMW.AirOps.KandaharUAVAssetParkingSync

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
  if not assetSync or assetSync.Applied ~= true or tonumber(assetSync.Violations) ~= 0 then
    log("RESULT: FAIL reason=UAV_ASSET_PARKING_SYNC_NOT_PASSED")
    return
  end

  runtime.MainAirwing = registration.Airwings and registration.Airwings.Main or nil
  runtime.MainContract = parking.Contracts and parking.Contracts.Main or nil
  runtime.MainAirbase = runtime.MainContract and runtime.MainContract.Airbase or nil
  runtime.UAVContract = uavContract
  local heliportAirwing = registration.Airwings and registration.Airwings.Heliport or nil

  if not runtime.MainAirwing or not runtime.MainContract or not runtime.MainAirbase then
    log("RESULT: FAIL reason=MAIN_RUNTIME_OBJECT_MISSING")
    return
  end
  if tonumber(runtime.MainAirbase:GetID()) ~= CONFIG.ExpectedAirbaseID then
    log("RESULT: FAIL reason=MAIN_AIRBASE_ID_MISMATCH")
    return
  end
  if heliportAirwing and heliportAirwing.IsRunning then
    local ok, running = pcall(function() return heliportAirwing:IsRunning() end)
    if ok and running == true then
      log("RESULT: FAIL reason=HELIPORT_AIRWING_ALREADY_RUNNING")
      return
    end
  end

  local mainAllowedSet = toNumericSet(runtime.MainContract.AllowedIDs)
  local blockedSet = toNumericSet(runtime.MainContract.BlockedIDs)

  for key, definition in pairs(CONFIG.Cases) do
    local squadron = registration.Squadrons and registration.Squadrons[definition.Squadron] or nil
    local pool = uavContract[key]
    if not squadron or not pool or not pool.AvailableIDs or #pool.AvailableIDs == 0 then
      log("RESULT: FAIL reason=CASE_RUNTIME_OBJECT_MISSING case=" .. key)
      return
    end
    runtime.Cases[key] = {
      Definition = definition,
      Squadron = squadron,
      Pool = pool,
      PoolSet = toNumericSet(pool.AvailableIDs),
      MainAllowedSet = mainAllowedSet,
      BlockedSet = blockedSet,
      EngineOn = false,
      TaxiOut = false,
      TaxiIn = false,
      Takeoff = false,
      Airborne = false,
      Landed = false,
      FinalParking = false,
      Arrived = false,
      Dead = false,
      Destroyed = false
    }
  end

  local previousFlightOnMission = runtime.MainAirwing.OnAfterFlightOnMission
  function runtime.MainAirwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then pcall(previousFlightOnMission, self, From, Event, To, FlightGroup, Mission) end
    local caseState = runtime.MissionCases[Mission]
    if not caseState then
      log("FLIGHT_ON_MISSION_IGNORED mission=" .. tostring(Mission and Mission.name or Mission))
      return
    end
    attachFlightCallbacks(caseState, FlightGroup)
  end

  if runtime.MainAirwing.SetStatusUpdate then runtime.MainAirwing:SetStatusUpdate(5) end
  if runtime.MainAirwing.SetTakeoffCold then runtime.MainAirwing:SetTakeoffCold() end
  if runtime.MainAirwing.SetLandingStraightIn then runtime.MainAirwing:SetLandingStraightIn() end
  if runtime.MainAirwing.SetDespawnAfterLanding then runtime.MainAirwing:SetDespawnAfterLanding(false) end

  local startOK, startResult = pcall(function() return runtime.MainAirwing:Start() end)
  if not startOK then
    log("RESULT: FAIL reason=MAIN_AIRWING_START_FAILED error=" .. tostring(startResult))
    return
  end

  local running = false
  if runtime.MainAirwing.IsRunning then
    local ok, value = pcall(function() return runtime.MainAirwing:IsRunning() end)
    running = ok and value == true
  end
  if not running then
    log("RESULT: FAIL reason=MAIN_AIRWING_NOT_RUNNING_AFTER_START")
    return
  end

  runtime.Started = true
  OMW.AirOps.KandaharUAVReturnParking = runtime

  local distanceMeters = UTILS and UTILS.NMToMeters and UTILS.NMToMeters(CONFIG.OrbitDistanceNM) or CONFIG.OrbitDistanceNM * 1852
  local orbitCoordinate = runtime.MainAirbase:GetCoordinate():Translate(distanceMeters, 180)

  addMission(runtime.Cases.MQ1, orbitCoordinate)
  schedule(CONFIG.MissionStagger, function()
    addMission(runtime.Cases.MQ9, orbitCoordinate)
  end)

  schedule(CONFIG.OverallTimeout, function()
    if runtime.Completed then return end
    runtime.Completed = true
    fail(string.format(
      "OVERALL_TIMEOUT mq1EngineOn=%s mq1Takeoff=%s mq1Landed=%s mq1Arrived=%s mq1FinalTerminalID=%s mq9EngineOn=%s mq9Takeoff=%s mq9Landed=%s mq9Arrived=%s mq9FinalTerminalID=%s",
      tostring(runtime.Cases.MQ1.EngineOn), tostring(runtime.Cases.MQ1.Takeoff), tostring(runtime.Cases.MQ1.Landed), tostring(runtime.Cases.MQ1.Arrived), tostring(runtime.Cases.MQ1.FinalTerminalID),
      tostring(runtime.Cases.MQ9.EngineOn), tostring(runtime.Cases.MQ9.Takeoff), tostring(runtime.Cases.MQ9.Landed), tostring(runtime.Cases.MQ9.Arrived), tostring(runtime.Cases.MQ9.FinalTerminalID)
    ))
    log(string.format(
      "RESULT: FAIL cases=2 reason=OVERALL_TIMEOUT violations=%d warehouseReturnNotClaimed=true",
      runtime.Violations
    ))
  end)
end

schedule(36, main)
