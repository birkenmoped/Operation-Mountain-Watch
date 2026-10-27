-- OMW Fixed-Wing CAS Response Acceptance 5-3: Racetrack + native MOOSE holding push
-- Three genuine MOOSE COMMANDER/AIRWING/AUFTRAG CAS missions, one DCS run.
-- No DCS event handlers, manually spawned aircraft, fuel interventions or route controllers.
-- Bagram: MOOSE holding waypoint and conditional release after two-aircraft airborne join.

local ID = "OMW-FIXED-WING-CAS-RESPONSE-A5"
local AO_NAME = "ZON_BLUE_GND_HONAKER_ACCESS"
local AO_RADIUS_M = 9260
local START_DELAY_S = 30
local A10_REQUEST_DELAY_S = 60
local OBSERVER_PERIOD_S = 15
local JOIN_RADIUS_M = 3704 -- Two NM: release criterion, not a flight steering rule.
local KANDAHAR_HOLD_ALT_FT = 6500 -- MSL minimum; terrain sampled at runtime.
local KANDAHAR_HOLD_SPEED_KTS = 195
local BAGRAM_HOLD_ALT_FT = 8500 -- MSL minimum; final altitude rises with measured track terrain.
local BAGRAM_HOLD_SPEED_KTS = 230
local HOLD_MAX_S = 3600 -- Finite MOOSE-controlled orbit task; join must release before timeout.
local RACETRACK_STANDOFF_NM = 5
local RACETRACK_LEG_NM = 8
local RACETRACK_TERRAIN_CLEARANCE_FT = 2500
local RACETRACK_ANGLES_DEG = { 45, 90, 135, 180, 225, 270, 315, 0 } -- Native MOOSE COORDINATE:Translate angles.
local CAS_ALT_FT = 22000 -- MSL; terrain clearance must be validated in DCS.
local CAS_SPEED_KTS = 350
local A10_CAS_SPEED_KTS = 230
local A10_PRE_AO_AAR_TRIGGER_PCT = 65 -- Test-only AWACS-proven early-AAR trigger; not a production CAS rule.
local AAR_CHECK_PERIOD_S = 30
local AAR_SEARCH_MAX_NM = 500
local A10_MISSION_RANGE_NM = 400 -- >330 NM one-way; eligibility only, not a fuel guarantee.
local CRUISE_ALT_FT = 22000 -- Also used by MOOSE for RTB intermediate waypoints.
local CRUISE_SPEED_KTS = { CAS_F16 = 450, CAS_F15E = 460, CAS_A10 = 260 }
-- A5-4 owner-approved sortie ceilings: clocks run from first aircraft takeoff.
-- Long-range A-10 normal eight hours; ten hours is an exceptional ceiling,
-- not automatic permission to extend any scheduled flight.
local SORTIE_POLICY = {
  CAS_F16 = { stationS = 150 * 60, plannedS = 4 * 3600, absoluteS = 5 * 3600 },
  CAS_F15E = { stationS = 180 * 60, plannedS = 5 * 3600, absoluteS = 6 * 3600 },
  CAS_A10 = { stationS = 240 * 60, plannedS = 8 * 3600, absoluteS = 10 * 3600 },
}
local RTB_APPROACH_RESERVE_S = 45 * 60 -- Approach, vectoring and landing planning allowance.
local RTB_MIN_ESTIMATE_S = 60 * 60 -- Do not assume even a short return is instantaneous.

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
      local isTanker, refuelSystem = nil, nil
      if tankerUnit then isTanker, refuelSystem = tankerUnit:IsTanker() end
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
    departureHoldClearedAt = nil,
    departureReleaseDelayedLogged = false,
    firstAo = {},
    fullAo = false,
    lastJoinDistance = nil,
    holdTimeoutSeen = false,
    aarPhase = nil,
    aarCount = 0,
    firstTakeoffS = nil,
    onStationAtS = nil,
    stationSeconds = 0,
    lastStationSampleS = nil,
    finalRtbAtS = nil,
    finalRtbReason = nil,
    sortieAarDeferredLogged = false,
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
    if not record.firstTakeoffS then
      record.firstTakeoffS = timer.getTime()
      log("SORTIE_CLOCK_STARTED", {
        "request=" .. requestId, "flight=" .. record.name,
        "firstElement=" .. tostring(element and element.name),
        "plannedS=" .. tostring(SORTIE_POLICY[requestId].plannedS),
        "absoluteS=" .. tostring(SORTIE_POLICY[requestId].absoluteS),
      })
    end
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
    if record.finalRtbAtS then
      log("AAR_BLOCKED_FINAL_RTB", { "request=" .. requestId, "reason=" .. reason })
      return false
    end
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
  flight:SetFuelLowThreshold(30) -- Owner-approved CAS FLIGHTGROUP scope only; A4 early AAR remains test-only.
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
    -- Without a tanker, MOOSE alone owns the RTB lifecycle.
    if not record.finalRtbAtS and not requestAar("FUEL_LOW") then
      local destination = self.destbase or self.homebase
      if destination then
        record.finalRtbAtS = timer.getTime()
        record.finalRtbReason = "AAR_UNAVAILABLE"
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
    if not record.finalRtbAtS then
      record.finalRtbAtS = timer.getTime()
      record.finalRtbReason = "MOOSE_RTB_EVENT"
    end
    log("MOOSE_RTB", { "request=" .. requestId })
    if beforeRTB then return beforeRTB(self, from, event, to, ...) end
  end
end

-- A5 approved minimal MOOSE-internal exception: clear only completed departure holding.
-- Keep the CAS AUFTRAG, MOOSE route/FSM, refueling and recovery fully framework-owned.
local function joinedForMission(requestId)
  local record = state.flights[requestId]
  if not record then return false end

  -- Once the departure formation has joined, later AAR separation must not
  -- invalidate the one-time push permission.
  if record.joinedAt then return true end

  local joined, distanceM = getJoinState(record)
  record.lastJoinDistance = distanceM
  if not joined then return false end

  record.joinedAt = clock()
  log("TWO_SHIP_JOINED", {
    "request=" .. requestId, "flight=" .. record.name,
    "separationM=" .. tostring(distanceM),
  })

  return true
end

-- MOOSE must first release the live controlled orbit via its own Status()
-- transition (IsReadyToPush -> flaghold=1 -> isHoldingAtHoldingPoint=false).
-- Clearing missionHoldingCoord before that transition masks MOOSE's release check.
local function clearCompletedDepartureHolding(requestId, record, requestRecord)
  if not record.joinedAt or record.departureHoldClearedAt then return end
  if not requestRecord or not requestRecord.spec.hold then return end
  local mission = requestRecord.mission
  local flight = record.flight
  if not mission or not flight then return end

  -- USERFLAG:Is(1) is the pinned public MOOSE flag accessor.
  -- The additional holding-state check proves that MOOSE, not OMW,
  -- performed the release before the approved internal field clear.
  if flight.isHoldingAtHoldingPoint == false
      and flight.flaghold and flight.flaghold:Is(1) then
    if mission:GetMissionHoldingCoord() then
      mission.missionHoldingCoord = nil -- Owner-approved single internal exception.
      record.departureHoldClearedAt = clock()
      log("DEPARTURE_HOLD_CLEARED", {
        "request=" .. requestId, "mission=" .. mission:GetName(),
        "holdingPresentAfter=" .. tostring(mission:GetMissionHoldingCoord() ~= nil),
        "releaseFlag=" .. tostring(flight.flaghold:Get()),
      })
    else
      log("DEPARTURE_HOLD_ALREADY_ABSENT", {
        "request=" .. requestId, "mission=" .. mission:GetName(),
      })
    end
  end
end

-- Choose a near-airfield, terrain-cleared valley corridor using the actual DCS terrain.
-- This determines only the two MOOSE-orbit points: DCS/MOOSE still fly the aircraft.
-- Sample the outbound corridor and the full eight-NM holding leg. No 11k/16k
-- fixed altitude is imposed on the Bagram wingman before the join.
local function makeRacetrack(requestId, airbaseCoordinate)
  local terrainBest, result = math.huge, nil
  for _, angle in ipairs(RACETRACK_ANGLES_DEG) do
    local peak = -math.huge
    local first, last = nil, nil
    for i = 0, 13 do
      local point = airbaseCoordinate:Translate(UTILS.NMToMeters(i), angle, true)
      local terrain = point:GetLandHeight()
      if not terrain then
        log("FATAL", { "request=" .. requestId, "reason=RACETRACK_TERRAIN_UNAVAILABLE" })
        return nil
      end
      if terrain > peak then peak = terrain end
      if i == RACETRACK_STANDOFF_NM then first = point end
      if i == RACETRACK_STANDOFF_NM + RACETRACK_LEG_NM then last = point end
    end
    if peak < terrainBest then
      terrainBest = peak
      result = { startCoord = first, endCoord = last, angle = angle, terrainM = peak }
    end
  end
  if not result then return nil end

  local floor = requestId == "CAS_A10" and KANDAHAR_HOLD_ALT_FT or BAGRAM_HOLD_ALT_FT
  result.altitudeFt = math.max(floor, UTILS.MetersToFeet(result.terrainM) + RACETRACK_TERRAIN_CLEARANCE_FT)
  result.speedKts = requestId == "CAS_A10" and KANDAHAR_HOLD_SPEED_KTS or BAGRAM_HOLD_SPEED_KTS
  log("DEPARTURE_RACETRACK_CONFIGURED", {
    "request=" .. requestId, "angleDeg=" .. tostring(result.angle),
    "standoffNm=" .. tostring(RACETRACK_STANDOFF_NM), "legNm=" .. tostring(RACETRACK_LEG_NM),
    "peakTerrainFt=" .. tostring(UTILS.MetersToFeet(result.terrainM)),
    "altitudeMslFt=" .. tostring(result.altitudeFt), "speedKts=" .. tostring(result.speedKts),
    "startX=" .. tostring(result.startCoord.x), "startZ=" .. tostring(result.startCoord.z),
    "endX=" .. tostring(result.endCoord.x), "endZ=" .. tostring(result.endCoord.z),
  })
  return result
end

-- Narrow, owner-approved extension at the MOOSE TaskOrbit constructor boundary.
-- The native MOOSE RouteToMission still creates the waypoint, controlled task,
-- stop flag, DCS route and CAS lifecycle. We only supply TaskOrbit's *public*
-- optional second coordinate to create a genuine RACETRACK rather than CIRCLE.
-- Install before any C2 request to avoid the LEGION mission-start queue race.
local originalTaskOrbit = CONTROLLABLE.TaskOrbit
CONTROLLABLE.TaskOrbit = function(controllable, coord, altitude, speed, coordRaceTrack)
  if not coordRaceTrack and coord then
    for requestId, request in pairs(state.requests) do
      local track = request.racetrack
      if track and request.mission:GetMissionHoldingCoord() == coord then
        local name = controllable.GetName and controllable:GetName() or ""
        local flight = state.flights[requestId]
        -- Before FLIGHT_ASSIGNED the coordinate identity still scopes this
        -- constructor call to this exact AUFTRAG holding waypoint.
        if not flight or (flight.group and flight.group:GetName() == name) then
          log("DEPARTURE_RACETRACK_TASK_CREATED", {
            "request=" .. requestId, "group=" .. tostring(name),
            "pattern=RACE_TRACK",
          })
          return originalTaskOrbit(controllable, coord, altitude, speed, track.endCoord)
        end
      end
    end
  end
  return originalTaskOrbit(controllable, coord, altitude, speed, coordRaceTrack)
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
  mission:SetName("OMW_A5_" .. requestId)
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

  local departureTrack = nil
  if spec.hold then
    -- Public MOOSE features; native orbit task is owned by FLIGHTGROUP.
    -- A 3600-s DCS task limit remains: do not silently treat timeout as a join.
    local baseCoord = requestId == "CAS_A10" and state.kandaharCoordinate or state.bagramCoordinate
    local track = makeRacetrack(requestId, baseCoord)
    if not track then
      log("FATAL", { "request=" .. requestId, "reason=RACETRACK_CONFIGURATION_FAILED" })
      return
    end
    mission:SetMissionHoldingCoord(track.startCoord, track.altitudeFt, track.speedKts, HOLD_MAX_S)
    mission:AddConditionPush(function() return joinedForMission(requestId) end)
    departureTrack = track
  end

  state.requests[requestId] = {
    mission = mission,
    requestedAt = clock(),
    spec = spec,
    racetrack = departureTrack,
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

-- Bound each flight's fuel-dependent endurance by a monotonic sortie clock.
-- The observer only requests the existing MOOSE FLIGHTGROUP:RTB lifecycle;
-- it does not issue waypoints, refueling tasks or controller commands.
local function enforceSortieLimit(requestId, record, requestRecord)
  if not record.firstTakeoffS or record.finalRtbAtS then return end
  local policy = SORTIE_POLICY[requestId]
  if not policy then return end
  local elapsedS = timer.getTime() - record.firstTakeoffS
  local flight = record.flight
  local base = flight.destbase or flight.homebase
  local current = flight:GetCoordinate()
  local home = base and base:GetCoordinate()
  if not home or not current then
    log("SORTIE_RETURN_ESTIMATE_UNAVAILABLE", {
      "request=" .. requestId, "elapsedS=" .. tostring(elapsedS),
    })
    return
  end

  local rangeM = current:Get2DDistance(home)
  local speedMps = UTILS.KnotsToMps(CRUISE_SPEED_KTS[requestId])
  local returnEstimateS = math.max(RTB_MIN_ESTIMATE_S,
    rangeM / speedMps + RTB_APPROACH_RESERVE_S)
  local stationElapsedS = record.onStationAtS and record.stationSeconds or nil
  local stationExpired = stationElapsedS and stationElapsedS >= policy.stationS
  local plannedReturnDue = elapsedS + returnEstimateS >= policy.plannedS
  local absoluteReturnDue = elapsedS + returnEstimateS >= policy.absoluteS
  if not stationExpired and not plannedReturnDue and not absoluteReturnDue then return end

  local reason = absoluteReturnDue and "ABSOLUTE_SORTIE_CEILING"
    or plannedReturnDue and "PLANNED_SORTIE_LIMIT" or "ON_STATION_LIMIT"

  -- Do not repeatedly abort an ongoing MOOSE refueling task merely because
  -- the planned duty window has elapsed. The hard ceiling remains mandatory.
  if record.aarPhase == "REFUELING" and not absoluteReturnDue then
    if not record.sortieAarDeferredLogged then
      record.sortieAarDeferredLogged = true
      log("SORTIE_RTB_WAITING_FOR_AAR", {
        "request=" .. requestId, "reason=" .. reason,
        "elapsedS=" .. tostring(elapsedS),
        "returnEstimateS=" .. tostring(returnEstimateS),
      })
    end
    return
  end

  record.finalRtbAtS = timer.getTime()
  record.finalRtbReason = reason
  log("SORTIE_FINAL_RTB_ORDERED", {
    "request=" .. requestId, "reason=" .. reason,
    "elapsedS=" .. tostring(elapsedS),
    "stationElapsedS=" .. tostring(stationElapsedS),
    "returnEstimateS=" .. tostring(returnEstimateS),
    "plannedLimitS=" .. tostring(policy.plannedS),
    "absoluteLimitS=" .. tostring(policy.absoluteS),
    "fuelPct=" .. tostring(flight:GetFuelMin()),
  })
  flight:RTB(base)
end

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
      -- Accumulate true full-two-ship AO occupancy, not wall-clock time
      -- spent outside the AO during repeated AAR excursions.
      local sampleS = timer.getTime()
      if alive == 2 and inside == 2 then
        if record.lastStationSampleS then
          record.stationSeconds = record.stationSeconds
            + math.max(0, sampleS - record.lastStationSampleS)
        end
        record.lastStationSampleS = sampleS
      else
        record.lastStationSampleS = nil
      end
      if alive == 2 and inside == 2 and not record.fullAo then
        record.fullAo = true
        record.onStationAtS = timer.getTime()
        log("SORTIE_ON_STATION_STARTED", {
          "request=" .. requestId,
          "targetS=" .. tostring(SORTIE_POLICY[requestId].stationS),
        })
        log("TWO_SHIP_IN_AO", {
          "request=" .. requestId,
          "elapsedS=" .. tostring(clock() - requestRecord.requestedAt),
        })
      end

      enforceSortieLimit(requestId, record, requestRecord)

      if requestId == "CAS_A10" and not record.finalRtbAtS
          and not record.aarPhase and record.joinedAt
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

      clearCompletedDepartureHolding(requestId, record, requestRecord)
      if record.joinedAt and not record.departureHoldClearedAt
          and not record.departureReleaseDelayedLogged
          and clock() - record.joinedAt > 45 then
        record.departureReleaseDelayedLogged = true
        log("DEPARTURE_RELEASE_DELAYED", {
          "request=" .. requestId,
          "holding=" .. tostring(flight.isHoldingAtHoldingPoint),
          "holdFlag=" .. tostring(flight.flaghold and flight.flaghold:Get() or "none"),
        })
      end

      log("FLIGHT_OBSERVER", {
        "request=" .. requestId,
        "alive=" .. tostring(alive), "inAo=" .. tostring(inside),
        "airborne=" .. tostring(record.airborneCount),
        "joined=" .. tostring(record.joinedAt ~= nil),
        "departureHoldCleared=" .. tostring(record.departureHoldClearedAt ~= nil),
        "missionHoldingPresent=" .. tostring(requestRecord.mission:GetMissionHoldingCoord() ~= nil),
        "joinDistanceM=" .. tostring(record.lastJoinDistance),
        "holding=" .. tostring(flight.isHoldingAtHoldingPoint),
        "holdReleaseFlag=" .. tostring(flight.flaghold and flight.flaghold:Get() or "none"),
        "sortieElapsedS=" .. tostring(record.firstTakeoffS and timer.getTime() - record.firstTakeoffS or "none"),
        "stationElapsedS=" .. tostring(record.onStationAtS and record.stationSeconds or "none"),
        "finalRtb=" .. tostring(record.finalRtbReason),
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
