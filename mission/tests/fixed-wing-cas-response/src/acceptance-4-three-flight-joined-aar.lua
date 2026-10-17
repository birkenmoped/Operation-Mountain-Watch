-- OMW Fixed-Wing CAS Response Acceptance 4
-- Three genuine MOOSE COMMANDER/AIRWING/AUFTRAG CAS missions, one DCS run.
-- No DCS event handlers, manually spawned aircraft, fuel interventions or route controllers.
-- Bagram: MOOSE holding waypoint and conditional release after two-aircraft airborne join.

local ID = "OMW-FIXED-WING-CAS-RESPONSE-A4"
local AO_NAME = "ZON_BLUE_GND_HONAKER_ACCESS"
local AO_RADIUS_M = 9260
local START_DELAY_S = 30
local A10_REQUEST_DELAY_S = 60
local OBSERVER_PERIOD_S = 15
local JOIN_RADIUS_M = 3704 -- Two NM: release criterion, not a flight steering rule.
local KANDAHAR_HOLD_ALT_FT = 12000
local KANDAHAR_HOLD_SPEED_KTS = 210
local BAGRAM_HOLD_ALT_FT = 16000 -- MSL, near departure airfield.
local BAGRAM_HOLD_SPEED_KTS = 250
local HOLD_MAX_S = 3600 -- Source-controlled MOOSE orbit task has a finite stop duration.
local CAS_ALT_FT = 22000 -- MSL; terrain clearance must be validated in DCS.
local CAS_SPEED_KTS = 350
local A10_CAS_SPEED_KTS = 230
local A10_PRE_AO_AAR_TRIGGER_PCT = 65 -- Test-only AWACS-proven early-AAR trigger; not a production CAS rule.
local AAR_CHECK_PERIOD_S = 30
local AAR_SEARCH_MAX_NM = 500
local A10_MISSION_RANGE_NM = 400 -- >330 NM one-way; eligibility only, not a fuel guarantee.
local CRUISE_ALT_FT = 22000 -- Also used by MOOSE for RTB intermediate waypoints.
local CRUISE_SPEED_KTS = { CAS_F16 = 450, CAS_F15E = 460, CAS_A10 = 260 }

local function clock()
  return UTILS.SecondsOfToday()
end

local function log(event, fields)
  local out = { ID, event, "time=" .. tostring(clock()) }
  for _, value in ipairs(fields or {}) do out[#out + 1] = tostring(value) end
  env.info(table.concat(out, " "))
end

local state = {
  requests = {},
  flights = {},
  observers = {},
  commander = nil,
  ao = nil,
}

local config = {
  CAS_F16 = { base = "Bagram", squadron = "F16C", hold = true },
  CAS_A10 = { base = "Kandahar", squadron = "A10C", hold = true },
  CAS_F15E = { base = "Bagram", squadron = "F15E", hold = true },
}

local function getPair(record)
  if not record or not record.group then return nil, nil end
  local units = record.group:GetUnits() or {}
  local eligible = {}
  for _, unit in pairs(units) do
    if unit and unit:IsAlive() then eligible[#eligible + 1] = unit end
  end
  if #eligible ~= 2 then return nil, nil end
  return eligible[1], eligible[2]
end

local function getJoinState(record)
  local u1, u2 = getPair(record)
  if not u1 or not u2 or not record.group:IsAirborne(true) then return false, nil end
  if record.flight:CountElements() ~= 2 or record.airborneCount ~= 2 then
    return false, nil
  end
  local c1, c2 = u1:GetCoordinate(), u2:GetCoordinate()
  if not c1 or not c2 then return false, nil end
  local distanceM = c1:Get2DDistance(c2)
  return distanceM <= JOIN_RADIUS_M, distanceM
end

local function tryCreateF15()
  local f16 = state.flights.CAS_F16
  if not f16 or not state.requests.CAS_A10 or state.requests.CAS_F15E then return end
  if f16.airborneCount ~= 2 or f16.flight:CountElements() ~= 2 then return end
  if not f16.group or not f16.group:IsAirborne(true) then return end
  state.Submit("CAS_F15E")
end

local function tankerCandidate(requestId, flight)
  local aar = OMW and OMW.AAR
  if not aar or type(aar.GetActive) ~= "function" then return nil, "AAR_CONTROLLER_UNAVAILABLE" end
  local allowed = requestId == "CAS_A10" and { "PATTY", "MILHOUSE" } or { "NELSON", "LISA", "MOE" }
  local origin = flight:GetCoordinate()
  if not origin then return nil, "FLIGHT_COORDINATE_UNAVAILABLE" end
  local home = flight.homebase
  local homeDistance = home and home:GetCoordinate() and origin:Get2DDistance(home:GetCoordinate()) or math.huge
  local choice, best = nil, math.huge
  for _, area in ipairs(allowed) do
    local runtime = aar.GetActive(area, requestId == "CAS_A10" and "SLOW" or "FAST")
    if runtime and runtime.onStationAt and not runtime.egressOrdered and not runtime.lossHandled
      and runtime.group and runtime.group:IsAlive() and flight.refueltype then
      local tankerUnit = runtime.group:GetUnit(1)
      local isTanker, refuelSystem = tankerUnit and tankerUnit:IsTanker()
      local compatible = isTanker and refuelSystem == flight.refueltype
      if compatible then
        local coord = runtime.group:GetCoordinate()
        local distance = coord and origin:Get2DDistance(coord) or math.huge
        if distance <= UTILS.NMToMeters(AAR_SEARCH_MAX_NM) and distance < homeDistance and distance < best then
          choice, best = runtime, distance
        end
      end
    end
  end
  if not choice then return nil, "NO_ELIGIBLE_ACTIVE_TANKER_CLOSER_THAN_HOME" end
  return choice, "ELIGIBLE_TRACK_DISTANCE_NM=" .. tostring(best / 1852)
end

local function addObserverHooks(requestId, flight)
  -- MOOSE-owned cruise parameters: used by its own routing and RTB implementation.
  flight:SetDefaultAltitude(CRUISE_ALT_FT)
  flight:SetDefaultSpeed(CRUISE_SPEED_KTS[requestId])
  log("CRUISE_CONFIGURED", {
    "request=" .. requestId, "altitudeFt=" .. tostring(CRUISE_ALT_FT),
    "speedKts=" .. tostring(CRUISE_SPEED_KTS[requestId]),
  })
  local existing = state.flights[requestId]
  if existing then return end

  local record = {
    flight = flight,
    group = flight.group,
    name = flight:GetName(),
    airborneElements = {},
    airborneCount = 0,
    joinedAt = nil,
    firstAo = {},
    fullAo = false,
    lastJoinDistance = nil,
    holdTimeoutSeen = false,
    aarPhase = nil,
    aarCount = 0,
  }
  state.flights[requestId] = record

  log("FLIGHT_ASSIGNED", {
    "request=" .. requestId, "flight=" .. record.name,
    "elements=" .. tostring(flight:CountElements()),
  })

  local beforeTaxi = flight.OnAfterElementTaxiing
  flight.OnAfterElementTaxiing = function(self, from, event, to, element)
    if beforeTaxi then beforeTaxi(self, from, event, to, element) end
    log("ELEMENT_TAXIING", { "request=" .. requestId, "element=" .. tostring(element and element.name) })
  end

  local beforeTakeoff = flight.OnAfterElementTakeoff
  flight.OnAfterElementTakeoff = function(self, from, event, to, element, airbase)
    if beforeTakeoff then beforeTakeoff(self, from, event, to, element, airbase) end
    log("ELEMENT_TAKEOFF", { "request=" .. requestId, "element=" .. tostring(element and element.name) })
  end

  local beforeAirborne = flight.OnAfterElementAirborne
  flight.OnAfterElementAirborne = function(self, from, event, to, element)
    if beforeAirborne then beforeAirborne(self, from, event, to, element) end
    if element and element.name and not record.airborneElements[element.name] then
      record.airborneElements[element.name] = true
      record.airborneCount = record.airborneCount + 1
      log("ELEMENT_AIRBORNE", {
        "request=" .. requestId, "element=" .. element.name,
        "count=" .. tostring(record.airborneCount),
      })
    end
    if requestId == "CAS_F16" then tryCreateF15() end
  end

  local beforeHolding = flight.OnAfterHolding
  flight.OnAfterHolding = function(self, from, event, to, ...)
    if beforeHolding then beforeHolding(self, from, event, to, ...) end
    log("MOOSE_HOLDING", { "request=" .. requestId })
  end

  local beforeExecute = flight.OnAfterMissionExecute
  flight.OnAfterMissionExecute = function(self, from, event, to, mission)
    if beforeExecute then beforeExecute(self, from, event, to, mission) end
    log("MISSION_EXECUTE", { "request=" .. requestId, "joined=" .. tostring(record.joinedAt ~= nil) })
  end

  local function requestAar(reason)
    if record.aarPhase == "REFUELING" then return false end
    local selected, selectionReason = tankerCandidate(requestId, flight)
    if not selected then
      log("AAR_NOT_AVAILABLE", { "request=" .. requestId, "reason=" .. selectionReason, "trigger=" .. reason })
      return false
    end
    local coord = selected.group:GetCoordinate()
    if not coord then return false end
    record.aarPhase = "REFUELING"
    record.aarCount = record.aarCount + 1
    log("AAR_SELECTED", {
      "request=" .. requestId, "callsignFamily=" .. tostring(selected.areaSpec.callsignName),
      "area=" .. selected.selection.area, "tanker=" .. selected.group:GetName(),
      "fuel=" .. tostring(flight:GetFuelMin()), "reason=" .. reason,
      "selection=" .. selectionReason,
    })
    -- MOOSE owns the mission pause, refueling task, and mission continuation.
    flight:Refuel(coord)
    return true
  end
  record.requestAar = requestAar

  -- Explicit CAS test-policy: MOOSE should not call automatic 25%-RTB before
  -- our eligible-tanker check. If no compliant tanker exists, use MOOSE RTB.
  flight:SetFuelLowRTB(false)
  flight:SetFuelLowRefuel(false)
  -- On a real FuelCritical, the pinned MOOSE FSM retains its own RTB contingency.

  local beforeRefueled = flight.OnAfterRefueled
  flight.OnAfterRefueled = function(self, from, event, to, ...)
    record.aarPhase = nil
    log("AAR_REFUELED", { "request=" .. requestId, "count=" .. tostring(record.aarCount),
      "fuel=" .. tostring(self:GetFuelMin()) })
    if beforeRefueled then return beforeRefueled(self, from, event, to, ...) end
  end

  local beforeLow = flight.OnAfterFuelLow
  flight.OnAfterFuelLow = function(self, from, event, to, ...)
    log("MOOSE_FUEL_LOW", {
      "request=" .. requestId, "minFuel=" .. tostring(self:GetFuelMin()),
      "fuellowrtb=" .. tostring(self.fuellowrtb),
      "fuellowrefuel=" .. tostring(self.fuellowrefuel),
      "homebase=" .. tostring(self.homebase ~= nil),
    })
    -- Without suitable tanker, let MOOSE execute the standard RTB lifecycle.
    if not requestAar("FUEL_LOW") then
      local destination = self.destbase or self.homebase
      if destination then
        log("AAR_FALLBACK_MOOSE_RTB", { "request=" .. requestId })
        self:RTB(destination)
      else
        log("AAR_NO_SAFE_ACTION", { "request=" .. requestId, "reason=NO_DESTINATION" })
      end
    end
    if beforeLow then return beforeLow(self, from, event, to, ...) end
  end

  local beforeCritical = flight.OnAfterFuelCritical
  flight.OnAfterFuelCritical = function(self, from, event, to, ...)
    log("MOOSE_FUEL_CRITICAL", {
      "request=" .. requestId, "minFuel=" .. tostring(self:GetFuelMin()),
      "fuelcriticalrtb=" .. tostring(self.fuelcriticalrtb),
      "homebase=" .. tostring(self.homebase ~= nil),
    })
    if record.aarPhase ~= "REFUELING" then
      log("AAR_FUEL_CRITICAL_NO_ACTIVE_REFUEL", { "request=" .. requestId })
    end
    if beforeCritical then return beforeCritical(self, from, event, to, ...) end
  end

  local beforeRTB = flight.OnAfterRTB
  flight.OnAfterRTB = function(self, from, event, to, ...)
    log("MOOSE_RTB", { "request=" .. requestId })
    if beforeRTB then return beforeRTB(self, from, event, to, ...) end
  end
end

local function joinedForMission(requestId)
  local record = state.flights[requestId]
  if not record then return false end
  local joined, distanceM = getJoinState(record)
  record.lastJoinDistance = distanceM
  if joined and not record.joinedAt then
    record.joinedAt = clock()
    log("TWO_SHIP_JOINED", {
      "request=" .. requestId, "flight=" .. record.name,
      "separationM=" .. tostring(distanceM),
    })
  end
  return joined
end

local function submit(requestId)
  if state.requests[requestId] then return end
  local spec = config[requestId]
  if not spec then
    log("ERROR", { "request=" .. tostring(requestId), "reason=UNKNOWN_REQUEST" })
    return
  end
  local ops = OMW and OMW.AirOps and OMW.AirOps[spec.base]
  local squadron = ops and ops.Squadrons and ops.Squadrons[spec.squadron]
  if not squadron then
    log("ERROR", { "request=" .. requestId, "reason=SQUADRON_UNAVAILABLE" })
    return
  end

  local orbitSpeedKts = requestId == "CAS_A10" and A10_CAS_SPEED_KTS or CAS_SPEED_KTS
  local mission = AUFTRAG:NewCAS(state.ao, CAS_ALT_FT, orbitSpeedKts)
  mission:SetName("OMW_A4_" .. requestId)
  if requestId == "CAS_A10" then
    -- Both MOOSE eligibility filters must permit a >330 NM Kandahar CAS request.
    -- No tanker or fuel policy is altered.
    squadron:SetMissionRange(A10_MISSION_RANGE_NM)
    mission:SetMissionRange(A10_MISSION_RANGE_NM)
    log("A10_RANGE_CONFIGURED", {
      "cohortRangeNm=" .. tostring(A10_MISSION_RANGE_NM),
      "missionRangeNm=" .. tostring(A10_MISSION_RANGE_NM),
    })
  end
  mission:SetMissionSpeed(CRUISE_SPEED_KTS[requestId])
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })

  if spec.hold then
    -- Public MOOSE features; native orbit task is owned by FLIGHTGROUP.
    -- A 3600-s DCS task limit remains: do not silently treat timeout as a join.
    local holdCoordinate = requestId == "CAS_A10" and state.kandaharCoordinate or state.bagramCoordinate
    local holdAltitude = requestId == "CAS_A10" and KANDAHAR_HOLD_ALT_FT or BAGRAM_HOLD_ALT_FT
    local holdSpeed = requestId == "CAS_A10" and KANDAHAR_HOLD_SPEED_KTS or BAGRAM_HOLD_SPEED_KTS
    mission:SetMissionHoldingCoord(holdCoordinate, holdAltitude, holdSpeed, HOLD_MAX_S)
    mission:AddConditionPush(function() return joinedForMission(requestId) end)
  end

  state.requests[requestId] = {
    mission = mission,
    requestedAt = clock(),
    spec = spec,
  }
  log("REQUEST_CREATED", {
    "request=" .. requestId, "base=" .. spec.base,
    "mission=" .. mission:GetName(), "holding=" .. tostring(spec.hold),
    "casAltitudeFt=" .. tostring(CAS_ALT_FT),
    "cruiseSpeedKts=" .. tostring(CRUISE_SPEED_KTS[requestId]),
    "casOrbitSpeedKts=" .. tostring(orbitSpeedKts),
  })
  state.commander:AddMission(mission)
  log("REQUEST_SUBMITTED_C2", { "request=" .. requestId })

  if requestId == "CAS_A10" then tryCreateF15() end
end
state.Submit = submit

local function observe()
  tryCreateF15()

  for requestId, requestRecord in pairs(state.requests) do
    if not state.flights[requestId] then
      log("C2_PENDING", {
        "request=" .. requestId,
        "elapsedS=" .. tostring(clock() - requestRecord.requestedAt),
        "missionState=" .. tostring(requestRecord.mission:GetState()),
      })
    end
  end

  for requestId, record in pairs(state.flights) do
    local requestRecord = state.requests[requestId]
    local flight, group = record.flight, record.group
    if group then
      local units = group:GetUnits() or {}
      local alive, inside = 0, 0

      for _, unit in pairs(units) do
        if unit and unit:IsAlive() then
          alive = alive + 1
          local coordinate = unit:GetCoordinate()
          if coordinate and state.ao:IsCoordinateInZone(coordinate) then
            inside = inside + 1
            if not record.firstAo[unit:GetName()] then
              record.firstAo[unit:GetName()] = clock()
              log("ELEMENT_IN_AO", { "request=" .. requestId, "element=" .. unit:GetName() })
            end
          end
          log("ELEMENT_FUEL_OBSERVER", {
            "request=" .. requestId, "element=" .. unit:GetName(),
            "fuelFraction=" .. tostring(unit:GetFuel()),
            "altitudeMslFt=" .. tostring(coordinate and UTILS.MetersToFeet(coordinate.y) or "unknown"),
            "groundSpeedKts=" .. tostring(unit:GetVelocityKNOTS()),
            "trueAirSpeedKts=" .. tostring(UTILS.MpsToKnots(unit:GetAirspeedTrue())),
            "indicatedAirSpeedKts=" .. tostring(UTILS.MpsToKnots(unit:GetAirspeedIndicated())),
          })
        end
      end
      if alive == 2 and inside == 2 and not record.fullAo then
        record.fullAo = true
        log("TWO_SHIP_IN_AO", {
          "request=" .. requestId,
          "elapsedS=" .. tostring(clock() - requestRecord.requestedAt),
        })
      end

      if requestId == "CAS_A10" and not record.aarPhase and record.joinedAt
          and not record.fullAo and record.aarCount == 0 and record.airborneCount == 2
          and record.flight:GetFuelMin() <= A10_PRE_AO_AAR_TRIGGER_PCT then
        record.requestAar("A10_EARLY_AAR_TEST_THRESHOLD")
      end
      if requestRecord.spec.hold and not record.joinedAt then
        local joined, distanceM = getJoinState(record)
        record.lastJoinDistance = distanceM
        if joined then
          joinedForMission(requestId)
        elseif flight.isHoldingAtHoldingPoint == false
            and record.airborneCount == 2 then
          if not record.holdTimeoutSeen then
            record.holdTimeoutSeen = true
            log("HOLD_RELEASED_WITHOUT_JOIN", {
              "request=" .. requestId, "separationM=" .. tostring(distanceM),
            })
          end
        end
      end

      log("FLIGHT_OBSERVER", {
        "request=" .. requestId,
        "alive=" .. tostring(alive), "inAo=" .. tostring(inside),
        "airborne=" .. tostring(record.airborneCount),
        "joined=" .. tostring(record.joinedAt ~= nil),
        "joinDistanceM=" .. tostring(record.lastJoinDistance),
        "holding=" .. tostring(flight.isHoldingAtHoldingPoint),
        "fuelLow=" .. tostring(flight.fuellow),
        "fuelCritical=" .. tostring(flight.fuelcritical),
        "fuelLowRtb=" .. tostring(flight.fuellowrtb),
        "fuelLowRefuel=" .. tostring(flight.fuellowrefuel),
        "fuelCriticalRtb=" .. tostring(flight.fuelcriticalrtb),
        "goingForFuel=" .. tostring(flight.IsGoing4Fuel and flight:IsGoing4Fuel() or "unknown"),
        "missionState=" .. tostring(requestRecord.mission:GetState()),
      })
    end
  end
end

local function start()
  local ops = OMW and OMW.AirOps
  if not ops or not ops.Bagram or not ops.Kandahar then
    log("FATAL", { "reason=FOUNDATIONS_MISSING" })
    return
  end
  if ops.Bagram.Status ~= "RUNNING" or ops.Kandahar.Status ~= "RUNNING" then
    log("FATAL", { "reason=AIRWINGS_NOT_RUNNING" })
    return
  end

  local anchor = ZONE:FindByName(AO_NAME)
  local airbase = AIRBASE:FindByName(AIRBASE.Afghanistan and AIRBASE.Afghanistan.Bagram or "Bagram")
  local kandahar = AIRBASE:FindByName(AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar or "Kandahar")
  if not anchor or not airbase or not kandahar then
    log("FATAL", {
      "reason=ZONE_OR_AIRBASE_MISSING",
      "zone=" .. tostring(anchor ~= nil), "airbase=" .. tostring(airbase ~= nil),
    })
    return
  end

  state.ao = ZONE_RADIUS:New("OMW_A3_FIXED_WING_CAS_AO", anchor:GetCoordinate():GetVec2(), AO_RADIUS_M)
  state.bagramCoordinate = airbase:GetCoordinate()
  state.kandaharCoordinate = kandahar:GetCoordinate()

  state.commander = COMMANDER:New(coalition.side.BLUE, "OMW_A3_CAS_C2")
  state.commander:AddAirwing(ops.Bagram.Airwings.USAF)
  state.commander:AddAirwing(ops.Kandahar.Airwings.Main)

  local previousAssignment = state.commander.OnAfterOpsOnMission
  state.commander.OnAfterOpsOnMission = function(self, from, event, to, flight, mission)
    if previousAssignment then previousAssignment(self, from, event, to, flight, mission) end
    for requestId, requestRecord in pairs(state.requests) do
      if requestRecord.mission == mission then
        addObserverHooks(requestId, flight)
        return
      end
    end
  end

  state.commander:Start()
  log("C2_STARTED", {
    "ao=" .. AO_NAME, "holdBase=Bagram/Kandahar",
    "holdAltitudeFt=" .. tostring(BAGRAM_HOLD_ALT_FT),
    "joinRadiusM=" .. tostring(JOIN_RADIUS_M),
  })

  submit("CAS_F16")
  state.observers.a10 = SCHEDULER:New(nil, function() submit("CAS_A10") end, {}, A10_REQUEST_DELAY_S)
  state.observers.telemetry = SCHEDULER:New(nil, observe, {}, OBSERVER_PERIOD_S, OBSERVER_PERIOD_S)
end

state.observers.initial = SCHEDULER:New(nil, start, {}, START_DELAY_S)
log("HARNESS_LOADED", { "startDelayS=" .. tostring(START_DELAY_S) })
