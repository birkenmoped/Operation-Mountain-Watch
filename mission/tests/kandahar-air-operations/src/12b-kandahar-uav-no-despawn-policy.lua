-- Operation Mountain Watch - Kandahar UAV no-despawn compatibility policy.
--
-- MOOSE AIRWING v0.9.7 and SQUADRON v0.8.1 treat
-- SetDespawnAfterLanding(false) as an enable operation because the implementation
-- uses `if Switch then ... else self.despawnAfterLanding=true end`.
--
-- This narrowly scoped compatibility stage therefore clears the state directly
-- on the Kandahar Main AIRWING, both UAV SQUADRONs and every assigned UAV
-- FLIGHTGROUP. It does not alter the global MOOSE classes or their methods.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVNoDespawnPolicy]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local ATTEMPT_INTERVAL = 0.25
local MAX_ATTEMPTS = 120
local attempts = 0
local applied = false

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

local function clearState(object, label)
  if not object then
    log("STATE_CLEAR_FAILED object=" .. tostring(label) .. " reason=OBJECT_MISSING")
    return false
  end
  object.despawnAfterLanding = false
  local ok = object.despawnAfterLanding == false
  log(string.format(
    "STATE_CLEARED object=%s despawnAfterLanding=%s ok=%s",
    tostring(label),
    tostring(object.despawnAfterLanding),
    tostring(ok)
  ))
  return ok
end

local function applyToFlight(runtime, caseKey, flightGroup)
  if not flightGroup then return false end
  flightGroup.despawnAfterLanding = false
  local ok = flightGroup.despawnAfterLanding == false
  log(string.format(
    "FLIGHT_POLICY_APPLIED case=%s group=%s despawnAfterLanding=%s ok=%s",
    tostring(caseKey),
    groupName(flightGroup),
    tostring(flightGroup.despawnAfterLanding),
    tostring(ok)
  ))
  return ok
end

local function install()
  if applied then return end
  attempts = attempts + 1

  local runtime = OMW.AirOps.KandaharUAVReturnParking
  local mq1 = runtime and runtime.Cases and runtime.Cases.MQ1 or nil
  local mq9 = runtime and runtime.Cases and runtime.Cases.MQ9 or nil

  if not runtime or not runtime.MainAirwing or not mq1 or not mq9 then
    if attempts < MAX_ATTEMPTS then
      schedule(ATTEMPT_INTERVAL, install)
    else
      log(string.format(
        "RESULT: FAIL reason=RETURN_PARKING_RUNTIME_NOT_READY attempts=%d",
        attempts
      ))
    end
    return
  end

  local airwingOK = clearState(runtime.MainAirwing, "AIRWING AW_US_KAF_451_AEW")
  local mq1SquadronOK = clearState(mq1.Squadron, "SQUADRON SQ_US_KAF_MQ1_361_ERS")
  local mq9SquadronOK = clearState(mq9.Squadron, "SQUADRON SQ_US_KAF_MQ9_361_ERS")

  local previousFlightOnMission = runtime.MainAirwing.OnAfterFlightOnMission
  function runtime.MainAirwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then
      pcall(previousFlightOnMission, self, From, Event, To, FlightGroup, Mission)
    end

    local caseKey = "UNKNOWN"
    local caseState = runtime.MissionCases and runtime.MissionCases[Mission] or nil
    if caseState and caseState.Definition and caseState.Definition.Key then
      caseKey = caseState.Definition.Key
    end
    applyToFlight(runtime, caseKey, FlightGroup)
  end

  if mq1.FlightGroup then applyToFlight(runtime, "MQ1", mq1.FlightGroup) end
  if mq9.FlightGroup then applyToFlight(runtime, "MQ9", mq9.FlightGroup) end

  applied = true
  OMW.AirOps.KandaharUAVNoDespawnPolicy = {
    Applied = airwingOK and mq1SquadronOK and mq9SquadronOK,
    Attempts = attempts,
    AirwingCleared = airwingOK,
    MQ1SquadronCleared = mq1SquadronOK,
    MQ9SquadronCleared = mq9SquadronOK,
    FlightPolicyWrapped = true,
    PublicFalseSetterUsed = false
  }

  if OMW.AirOps.KandaharUAVNoDespawnPolicy.Applied then
    log(string.format(
      "RESULT: PASS airwing=false mq1Squadron=false mq9Squadron=false flightPolicyWrapped=true publicFalseSetterUsed=false attempts=%d",
      attempts
    ))
  else
    log(string.format(
      "RESULT: FAIL reason=STATE_CLEAR_FAILED airwing=%s mq1Squadron=%s mq9Squadron=%s attempts=%d",
      tostring(airwingOK),
      tostring(mq1SquadronOK),
      tostring(mq9SquadronOK),
      attempts
    ))
  end
end

-- Source 12 schedules its main routine at 36 seconds. Apply immediately after it
-- has created the runtime objects, and retry briefly if scheduler ordering varies.
schedule(36.25, install)
