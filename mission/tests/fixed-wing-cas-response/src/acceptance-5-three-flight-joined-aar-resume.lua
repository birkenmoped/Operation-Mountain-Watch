-- OMW Fixed-Wing CAS Response Acceptance 5-6: observer/composition of shared recovery policy
-- Three genuine MOOSE COMMANDER/AIRWING/AUFTRAG CAS missions, one DCS run.
-- No DCS event handlers, manually spawned aircraft, fuel interventions or route controllers.
-- Bagram: MOOSE holding waypoint and conditional release after two-aircraft airborne join.

local FuelPolicy = assert(OMW_FixedWingCasFuelPolicy, "shared fuel module missing")
local Profiles = assert(OMW_FixedWingCasProfiles, "shared profile module missing")
local Recovery = assert(OMW_FixedWingCasRecovery, "shared recovery module missing")

local ID = "OMW-FIXED-WING-CAS-RESPONSE-A5"
local AO_NAME = "ZON_BLUE_GND_HONAKER_ACCESS"
local AO_RADIUS_M = 9260
local START_DELAY_S = 30
local A10_REQUEST_DELAY_S = 60
local OBSERVER_PERIOD_S = 15
local JOIN_RADIUS_M = 3704 -- Two NM: release criterion, not a flight steering rule.
local BAGRAM_HOLD_ALT_FT = 8500 -- Candidate minimum; profile terrain samples can raise it.
local CAS_ALT_FT = 22000
local HOLD_MAX_S = 3600
local A10_MISSION_RANGE_NM = 400

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

local function addObserverHooks(requestId, flight)
  local profile = Profiles.Get(requestId)
  -- Public MOOSE configuration; no independent wingman task or throttle control.
  flight:SetDefaultAltitude(profile.cruiseAltitudeFt)
  flight:SetDefaultSpeed(profile.cruiseKtas)
  flight:SetProhibitAfterburner()
  log("CRUISE_CONFIGURED", {
    "request=" .. requestId, "altitudeFt=" .. tostring(profile.cruiseAltitudeFt),
    "speedKts=" .. tostring(profile.cruiseKtas),
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
    onStationAtS = nil,
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

  record.runtime = Recovery.Bind({
    flight = flight, mission = state.requests[requestId].mission,
    policy = FuelPolicy.New(profile), now = timer.getTime,
    reserveS = profile.reserveS, observerPeriodS = OBSERVER_PERIOD_S, sortie = profile.sortie,
    qualifySample = function(unit, timeS, previous)
      return Profiles.RecoverySample(profile, unit, timeS, previous)
    end,
    routes = function(units, destination, viaAo)
      return Profiles.RouteTimes(profile, units, destination, state.ao:GetCoordinate(), viaAo)
    end,
    tankers = function(adapter)
      return Profiles.SelectTanker(profile, adapter, OMW and OMW.AAR, state.ao:GetCoordinate())
    end,
    log = function(event, values)
      local fields, keys = { "request=" .. requestId }, {}
      for key in pairs(values) do keys[#keys + 1] = key end
      table.sort(keys)
      for _, key in ipairs(keys) do fields[#fields + 1] = key .. "=" .. tostring(values[key]) end
      log(event, fields)
      if event == "SAFETY_FAIL_STOP" then
        MESSAGE:New("OMW A5-6 FAIL/STOP: " .. requestId .. " / " .. tostring(values.reason)
          .. ". Test abbrechen; Recovery-Beobachtung bleibt aktiv.", 60):ToAll()
      end
    end,
  })

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
      record.runtime:DepartureComplete()
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

-- Fixed, basis-specific candidate axis. No lowest-terrain heading search.
local function makeRacetrack(requestId, airbaseCoordinate)
  local track = Profiles.Departure(Profiles.Get(requestId), airbaseCoordinate, state.ao:GetCoordinate())
  log("DEPARTURE_RACETRACK_CONFIGURED", {
    "request=" .. requestId, "angleDeg=" .. tostring(track.angle),
    "offsetHeading=" .. tostring(track.offsetHeading), "offsetNm=" .. tostring(track.offsetNm),
    "legNm=" .. tostring(track.legNm), "peakTerrainFt=" .. tostring(UTILS.MetersToFeet(track.terrainM)),
    "altitudeMslFt=" .. tostring(track.altitudeFt), "speedKtas=" .. tostring(track.speedKts),
    "startX=" .. tostring(track.startCoord.x), "startZ=" .. tostring(track.startCoord.z),
    "endX=" .. tostring(track.endCoord.x), "endZ=" .. tostring(track.endCoord.z),
    "geometryStatus=TEST_CANDIDATE_DCS_PENDING",
  })
  return track
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
          local task = originalTaskOrbit(controllable, coord, altitude, speed, track.endCoord)
          assert(task and task.id == "Orbit" and task.params
            and task.params.pattern == AI.Task.OrbitPattern.RACE_TRACK and task.params.point2,
            "departure constructor did not produce a two-point racetrack")
          log("DEPARTURE_RACETRACK_TASK_CREATED", {
            "request=" .. requestId, "group=" .. tostring(name),
            "pattern=" .. tostring(task.params.pattern),
            "point2X=" .. tostring(task.params.point2.x), "point2Y=" .. tostring(task.params.point2.y),
            "evidence=CONSTRUCTED_TASK_NOT_DCS_EXECUTION",
          })
          return task
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

  local profile = Profiles.Get(requestId)
  local orbitSpeedKts = profile.casKias
  local mission = AUFTRAG:NewCAS(state.ao, CAS_ALT_FT, orbitSpeedKts)
  mission:SetName("OMW_A5_" .. requestId)
  mission:SetProhibitAfterburner()
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
  mission:SetMissionSpeed(profile.cruiseKtas)
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
    "cruiseSpeedKts=" .. tostring(profile.cruiseKtas),
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
      local alive, inside, airborneNow = 0, 0, 0

      for _, unit in pairs(units) do
        if unit and unit:IsAlive() then
          alive = alive + 1
          if unit:InAir() then airborneNow = airborneNow + 1 end
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
            "fuelKg=" .. tostring(unit:GetCurrentFuelKgs()), "airborne=" .. tostring(unit:InAir()),
            "x=" .. tostring(coordinate and coordinate.x), "z=" .. tostring(coordinate and coordinate.z),
            "altitudeAglFt=" .. tostring(coordinate and UTILS.MetersToFeet(coordinate.y - coordinate:GetLandHeight())),
            "altitudeMslFt=" .. tostring(coordinate and UTILS.MetersToFeet(coordinate.y) or "unknown"),
            "groundSpeedKts=" .. tostring(unit:GetVelocityKNOTS()),
            "trueAirSpeedKts=" .. tostring(UTILS.MpsToKnots(unit:GetAirspeedTrue())),
            "indicatedAirSpeedKts=" .. tostring(UTILS.MpsToKnots(unit:GetAirspeedIndicated())),
          })
        end
      end
      if alive == 2 and airborneNow == 2 and inside == 2 and not record.fullAo then
        record.fullAo = true
        record.onStationAtS = timer.getTime()
        log("SORTIE_ON_STATION_STARTED", {
          "request=" .. requestId,
          "targetS=" .. tostring(Profiles.Get(requestId).sortie.stationS),
        })
        log("TWO_SHIP_IN_AO", {
          "request=" .. requestId,
          "elapsedS=" .. tostring(clock() - requestRecord.requestedAt),
        })
      end

      local task = flight:GetTaskCurrent()
      local wp = flight:GetWaypointCurrent()
      log("DEPARTURE_NATIVE_STATE", {
        "request=" .. requestId, "groupState=" .. tostring(flight:GetState()),
        "airborneNow=" .. tostring(airborneNow), "alive=" .. tostring(alive),
        "waypointUid=" .. tostring(wp and wp.uid), "waypointName=" .. tostring(wp and wp.name),
        "taskId=" .. tostring(task and task.dcstask and task.dcstask.id),
        "taskDescription=" .. tostring(task and task.description),
        "evidence=MOOSE_QUEUE_NOT_DCS_CONTROLLER",
      })
      record.runtime:Tick(record.joinedAt ~= nil, alive == 2 and airborneNow == 2 and inside == 2)

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

      local pairA, pairB = getPair(record)
      local pairDistanceM
      if pairA and pairB then
        local a, b = pairA:GetCoordinate(), pairB:GetCoordinate()
        if a and b then pairDistanceM = a:Get2DDistance(b) end
      end
      log("FLIGHT_OBSERVER", {
        "request=" .. requestId,
        "alive=" .. tostring(alive), "inAo=" .. tostring(inside),
        "airborne=" .. tostring(airborneNow),
        "everAirborneCount=" .. tostring(record.airborneCount),
        "joined=" .. tostring(record.joinedAt ~= nil),
        "departureHoldCleared=" .. tostring(record.departureHoldClearedAt ~= nil),
        "missionHoldingPresent=" .. tostring(requestRecord.mission:GetMissionHoldingCoord() ~= nil),
        "joinDistanceM=" .. tostring(record.lastJoinDistance),
        "currentSeparationM=" .. tostring(pairDistanceM),
        "holding=" .. tostring(flight.isHoldingAtHoldingPoint),
        "holdReleaseFlag=" .. tostring(flight.flaghold and flight.flaghold:Get() or "none"),
        "sortieElapsedS=" .. tostring(record.runtime.firstTakeoffS and timer.getTime() - record.runtime.firstTakeoffS or "none"),
        "stationElapsedS=" .. tostring(record.runtime.stationS),
        "finalRtb=" .. tostring(record.runtime.finalReason),
        "fuelLow=" .. tostring(flight.fuellow),
        "fuelCritical=" .. tostring(flight.fuelcritical),
        "fuelLowRtb=" .. tostring(flight.fuellowrtb),
        "fuelLowRefuel=" .. tostring(flight.fuellowrefuel),
        "fuelCriticalRtb=" .. tostring(flight.fuelcriticalrtb),
        "goingForFuel=" .. tostring(flight:IsGoing4Fuel()),
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


