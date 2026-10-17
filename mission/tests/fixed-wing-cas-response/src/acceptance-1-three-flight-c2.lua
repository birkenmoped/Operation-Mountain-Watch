-- OMW Fixed-Wing CAS Response Acceptance 1
-- Observer-triggered scenario, not a second mission execution engine.
-- Load after Moose.lua, OMW_AirOps_Bagram.lua and OMW_AirOps_Kandahar.lua.
-- No native DCS event handlers, controller tasks, fuel policies or route overrides.

local TEST_ID = "OMW-FIXED-WING-CAS-RESPONSE-A1"
local AO_ANCHOR = "ZON_BLUE_GND_HONAKER_ACCESS"
local AO_RADIUS_M = 9260 -- Five nautical miles, observation/CAS-area selection only.
local SECOND_REQUEST_DELAY_S = 60 -- Scenario incident separation, not an aircraft readiness constraint.
local OBSERVER_INTERVAL_S = 15
local START_DELAY_S = 30 -- Allow mission-editor AirOps start triggers to complete.

local function now()
  return UTILS.SecondsOfToday()
end

local function report(event, fields)
  local parts = { TEST_ID, event, "time=" .. tostring(now()) }
  for _, item in ipairs(fields or {}) do
    parts[#parts + 1] = item
  end
  env.info(table.concat(parts, " "))
end

local state = {
  flights = {},
  requests = {},
  commander = nil,
  ao = nil,
  observers = {},
}

local function maybeRequestF15()
  local f16 = state.flights.CAS_F16
  if not f16 or not state.requests.CAS_A10 or state.requests.CAS_F15E then return end
  if f16.airborneCount ~= 2 or f16.flight:CountElements() ~= 2 then return end
  if not f16.flight.group or not f16.flight.group:IsAirborne(true) then return end
  state.Request("CAS_F15E")
end

local function markFlight(id, flight)
  if state.flights[id] then
    return
  end
  local record = {
    id = id,
    flight = flight,
    name = flight:GetName(),
    takenOff = {},
    airborneCount = 0,
    firstAo = {},
    fullAoLogged = false,
    onMissionLogged = false,
    startTime = now(),
  }
  state.flights[id] = record
  report("FLIGHT_ASSIGNED", {
    "request=" .. id,
    "flight=" .. tostring(record.name),
    "elements=" .. tostring(flight:CountElements()),
  })

  -- Public MOOSE extension hooks: preserve any pre-existing user callback.
  local previousTaxi = flight.OnAfterElementTaxiing
  flight.OnAfterElementTaxiing = function(self, from, event, to, element)
    if previousTaxi then previousTaxi(self, from, event, to, element) end
    report("ELEMENT_TAXIING", { "request=" .. id, "element=" .. tostring(element and element.name) })
  end

  local previousTakeoff = flight.OnAfterElementTakeoff
  flight.OnAfterElementTakeoff = function(self, from, event, to, element, airbase)
    if previousTakeoff then previousTakeoff(self, from, event, to, element, airbase) end
    report("ELEMENT_TAKEOFF", {
      "request=" .. id,
      "element=" .. tostring(element and element.name),
      "airbase=" .. tostring(airbase and airbase:GetName() or "unknown"),
    })
  end

  local previousAirborne = flight.OnAfterElementAirborne
  flight.OnAfterElementAirborne = function(self, from, event, to, element)
    if previousAirborne then previousAirborne(self, from, event, to, element) end
    if element and element.name and not record.takenOff[element.name] then
      record.takenOff[element.name] = true
      record.airborneCount = record.airborneCount + 1
      report("ELEMENT_AIRBORNE", {
        "request=" .. id,
        "element=" .. tostring(element.name),
        "count=" .. tostring(record.airborneCount),
      })
    end

    -- The third incident is created only when BOTH F-16 elements are airborne.
    if id == "CAS_F16" then maybeRequestF15() end
  end

  local previousExecute = flight.OnAfterMissionExecute
  flight.OnAfterMissionExecute = function(self, from, event, to, mission)
    if previousExecute then previousExecute(self, from, event, to, mission) end
    report("MOOSE_MISSION_EXECUTE", { "request=" .. id, "flight=" .. tostring(record.name) })
  end
end

local definitions = {
  CAS_F16 = { base = "Bagram", squadronKey = "F16C", origin = "Bagram", label = "F16" },
  CAS_A10 = { base = "Kandahar", squadronKey = "A10C", origin = "Kandahar", label = "A10" },
  CAS_F15E = { base = "Bagram", squadronKey = "F15E", origin = "Bagram", label = "F15E" },
}

local function request(id)
  if state.requests[id] then return end
  local definition = definitions[id]
  if not definition then
    report("ERROR", { "reason=UNKNOWN_REQUEST", "request=" .. tostring(id) })
    return
  end
  local airOps = OMW.AirOps[definition.base]
  local squadron = airOps and airOps.Squadrons and airOps.Squadrons[definition.squadronKey]
  if not squadron then
    report("ERROR", { "reason=SQUADRON_MISSING", "request=" .. id })
    return
  end

  -- Source-confirmed AUFTRAG:NewCAS + AssignSquadrons + SetRequiredAssets.
  -- One asset group is an existing two-aircraft CAS template, not two groups.
  local mission = AUFTRAG:NewCAS(state.ao)
  mission:SetName("OMW_A1_" .. id)
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  state.requests[id] = { mission = mission, requestedAt = now() }
  report("REQUEST_CREATED", { "request=" .. id, "origin=" .. definition.origin, "mission=" .. mission:GetName() })
  state.commander:AddMission(mission)
  report("REQUEST_SUBMITTED_C2", { "request=" .. id })
  if id == "CAS_A10" then maybeRequestF15() end
end

state.Request = request

local function observe()
  -- Recheck in case the DCS unit airborne flag settles after the MOOSE element event.
  maybeRequestF15()
  for id, record in pairs(state.flights) do
    local flight = record.flight
    local group = flight.group
    local units = group and group:GetUnits() or nil
    if units then
      local seen = 0
      local inside = 0
      for _, unit in pairs(units) do
        if unit and unit:IsAlive() then
          seen = seen + 1
          local coord = unit:GetCoordinate()
          if coord and state.ao:IsCoordinateInZone(coord) then
            inside = inside + 1
            local name = unit:GetName()
            if not record.firstAo[name] then
              record.firstAo[name] = now()
              report("ELEMENT_IN_AO", { "request=" .. id, "element=" .. name })
            end
          end
        end
      end
      if not record.fullAoLogged and seen == 2 and inside == 2 then
        record.fullAoLogged = true
        report("TWO_SHIP_IN_AO", {
          "request=" .. id,
          "elapsedS=" .. tostring(now() - state.requests[id].requestedAt),
        })
      end
      report("POSITION_OBSERVER", {
        "request=" .. id, "alive=" .. tostring(seen), "insideAo=" .. tostring(inside),
        "airborneEvents=" .. tostring(record.airborneCount),
      })
      for _, unit in pairs(units) do
        if unit and unit:IsAlive() then
          report("ELEMENT_FUEL_OBSERVER", {
            "request=" .. id,
            "element=" .. tostring(unit:GetName()),
            "fuelFraction=" .. tostring(unit:GetFuel()),
          })
        end
      end
    end
  end
end

local function start()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Bagram
      or not OMW.AirOps.Kandahar then
    report("FATAL", { "reason=FOUNDATION_NOT_READY" })
    return
  end
  local bagram = OMW.AirOps.Bagram
  local kandahar = OMW.AirOps.Kandahar
  if bagram.Status ~= "RUNNING" or kandahar.Status ~= "RUNNING" then
    report("FATAL", { "reason=AIRWING_NOT_RUNNING" })
    return
  end

  local anchor = ZONE:FindByName(AO_ANCHOR)
  if not anchor then
    report("FATAL", { "reason=AO_ANCHOR_MISSING", "name=" .. AO_ANCHOR })
    return
  end
  state.ao = ZONE_RADIUS:New("OMW_A1_FIXED_WING_CAS_AO", anchor:GetCoordinate():GetVec2(), AO_RADIUS_M)

  state.commander = COMMANDER:New(coalition.side.BLUE, "OMW_A1_CAS_C2")
  state.commander:AddAirwing(bagram.Airwings.USAF)
  state.commander:AddAirwing(kandahar.Airwings.Main)
  local priorOps = state.commander.OnAfterOpsOnMission
  state.commander.OnAfterOpsOnMission = function(self, from, event, to, opsGroup, mission)
    if priorOps then priorOps(self, from, event, to, opsGroup, mission) end
    for id, requestRecord in pairs(state.requests) do
      if requestRecord.mission == mission then
        markFlight(id, opsGroup)
        return
      end
    end
  end
  state.commander:Start()
  report("C2_STARTED", { "ao=" .. AO_ANCHOR, "radiusM=" .. tostring(AO_RADIUS_M) })

  request("CAS_F16")
  -- A second independent incident, while the first is still active.
  state.observers.secondRequest = SCHEDULER:New(nil, function() request("CAS_A10") end, {}, SECOND_REQUEST_DELAY_S)
  -- Passive observer; does not set tasks, fuel limits, navigation or RTB.
  state.observers.positions = SCHEDULER:New(nil, observe, {}, OBSERVER_INTERVAL_S, OBSERVER_INTERVAL_S)
end

state.observers.start = SCHEDULER:New(nil, start, {}, START_DELAY_S)
report("HARNESS_LOADED", { "startDelayS=" .. tostring(START_DELAY_S) })
