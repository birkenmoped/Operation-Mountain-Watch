-- Operation Mountain Watch - Jalalabad Phase 1 compatibility for pinned MOOSE mission semantics
-- The pinned MOOSE commit evaluates user success conditions by transitioning through CANCELLED
-- before SUCCESS/FAILED. Transport missions can also create intentional remote landing events.
local TAG = "[OMW][AirOps.JBAD.PH1.COMPAT]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Controller or not ph1.Observer or not ph1.EventHandler then
  log("ERROR: Phase 1 runtime components are unavailable.")
else
  local controller = ph1.Controller
  local handler = ph1.EventHandler

  local function eventGroupName(eventData)
    if eventData.IniGroupName then return eventData.IniGroupName end
    if eventData.IniGroup and eventData.IniGroup.GetName then
      local ok, value = pcall(function() return eventData.IniGroup:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function eventUnitName(eventData)
    if eventData.IniUnitName then return eventData.IniUnitName end
    if eventData.IniUnit and eventData.IniUnit.GetName then
      local ok, value = pcall(function() return eventData.IniUnit:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function eventTypeName(eventData)
    if eventData.IniTypeName then return eventData.IniTypeName end
    if eventData.IniUnit and eventData.IniUnit.GetTypeName then
      local ok, value = pcall(function() return eventData.IniUnit:GetTypeName() end)
      if ok then return value end
    end
    return nil
  end

  local function eventCoordinate(eventData)
    if eventData.IniUnit and eventData.IniUnit.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniUnit:GetCoordinate() end)
      if ok then return value end
    end
    if eventData.IniGroup and eventData.IniGroup.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniGroup:GetCoordinate() end)
      if ok then return value end
    end
    return nil
  end

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx = (a.x or 0) - (b.x or 0)
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function isExpectedEvent(groupName, typeName)
    if not ph1.ActiveMission or not ph1.Runtime then return false end
    if groupName and ph1.Runtime.ExpectedGroupNames and ph1.Runtime.ExpectedGroupNames[groupName] then return true end
    return ph1.ActiveDefinition and typeName == ph1.ActiveDefinition.ExpectedType and
           groupName and ph1.Runtime.ProvisionalGroupNames and ph1.Runtime.ProvisionalGroupNames[groupName] == true
  end

  -- A deliberate manual abort of a regular test is a test failure. The defined abort test is exempt.
  local originalAbortActive = controller.AbortActive
  function controller:AbortActive(reason)
    if ph1.Runtime and not (ph1.ActiveDefinition and ph1.ActiveDefinition.AbortOnBirth) and reason ~= "failure-cleanup" then
      ph1.Runtime.PendingFailure = ph1.Runtime.PendingFailure or ("manual-abort: " .. tostring(reason or "unspecified"))
    end
    return originalAbortActive(self, reason)
  end

  -- The defined abort test only requires that the CANCELLED transition was observed. MOOSE may
  -- subsequently evaluate the surviving transport as SUCCESS while the asset is returning.
  local originalLifecycleSatisfied = controller.LifecycleSatisfied
  function controller:LifecycleSatisfied()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if runtime and definition and definition.ExpectedTerminalState == "CANCELLED" and
       runtime.MissionStateSeen and runtime.MissionStateSeen.CANCELLED then
      local currentState = runtime.MissionState
      runtime.MissionState = "CANCELLED"
      local ok, reason = originalLifecycleSatisfied(self)
      runtime.MissionState = currentState
      return ok, reason
    end
    return originalLifecycleSatisfied(self)
  end

  -- Do not classify MOOSE's internal CANCELLED step as an unexpected abort while a user success
  -- condition is awaiting Evaluate() and the final SUCCESS/FAILED transition.
  local originalPollActive = controller.PollActive
  function controller:PollActive()
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    local evaluatingSuccess = runtime and definition and definition.ExpectedTerminalState ~= "CANCELLED" and
                              runtime.MissionState == "CANCELLED" and not runtime.PendingFailure
    if evaluatingSuccess then runtime.MissionState = "EVALUATING" end
    originalPollActive(self)
    if ph1.Runtime == runtime and evaluatingSuccess and runtime.MissionState == "EVALUATING" then
      runtime.MissionState = "CANCELLED"
    end
  end

  -- Transport pickup/dropoff landings are expected and must not satisfy the final Jalalabad landing
  -- criterion. Only a landing inside the Jalalabad RTB radius is counted as the final landing.
  function handler:OnEventLand(eventData)
    local groupName = eventGroupName(eventData)
    local unitName = eventUnitName(eventData)
    local typeName = eventTypeName(eventData)
    if not isExpectedEvent(groupName, typeName) then return end

    local coordinate = eventCoordinate(eventData)
    local nearBase, distance = ph1.Observer:IsNearJalalabad(coordinate, ph1.Limits.RTBDetectionRadiusMeters)
    if nearBase then
      ph1.Runtime.LandedUnits = ph1.Runtime.LandedUnits or {}
      local key = unitName or ("landing-unknown-" .. tostring(timer.getTime()))
      if not ph1.Runtime.LandedUnits[key] then
        ph1.Runtime.LandedUnits[key] = true
        ph1.Runtime.LandingCount = (ph1.Runtime.LandingCount or 0) + 1
        increment("landings")
      end
      ph1.Runtime.RTBObserved = true
      log(string.format("EVENT testId=%s stage=LAND_AT_JALALABAD group=%s unit=%s type=%s distance=%.0fm count=%d",
        tostring(ph1.ActiveTestId), tostring(groupName), tostring(unitName), tostring(typeName), distance or -1,
        ph1.Runtime.LandingCount or 0))
    else
      ph1.Runtime.RemoteLandingCount = (ph1.Runtime.RemoteLandingCount or 0) + 1
      increment("remoteLandings")
      log(string.format("EVENT testId=%s stage=REMOTE_LANDING group=%s unit=%s type=%s distanceFromJalalabad=%s",
        tostring(ph1.ActiveTestId), tostring(groupName), tostring(unitName), tostring(typeName),
        distance and string.format("%.0fm", distance) or "unknown"))
    end
  end

  -- Extend the existing Birth validator with an explicit maximum distance to a parking centroid.
  local originalOnEventBirth = handler.OnEventBirth
  function handler:OnEventBirth(eventData)
    originalOnEventBirth(self, eventData)
    if not ph1.ActiveMission or not ph1.Runtime then return end
    local groupName = eventGroupName(eventData)
    local typeName = eventTypeName(eventData)
    if not isExpectedEvent(groupName, typeName) then return end

    local coordinate = eventCoordinate(eventData)
    local nearestId, nearestDistance
    for _, spot in ipairs((cfg.Airbase and cfg.Airbase:GetParkingSpotsTable()) or {}) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then
        nearestDistance = distance
        nearestId = spot.TerminalID
      end
    end
    if not nearestId or not nearestDistance or nearestDistance > ph1.Limits.ParkingBirthMatchMeters then
      increment("parkingViolations")
      ph1.Runtime.HardFailure = "spawn-parking-unresolved"
      log(string.format("ERROR SPAWN_PARKING_UNRESOLVED testId=%s TerminalID=%s distance=%s maximum=%.1fm",
        tostring(ph1.ActiveTestId), tostring(nearestId),
        nearestDistance and string.format("%.1fm", nearestDistance) or "unknown",
        ph1.Limits.ParkingBirthMatchMeters))
    end
  end

  log("READY pinnedMooseCancelEvaluation=true remoteTransportLandings=true parkingCentroidValidation=true")
end
