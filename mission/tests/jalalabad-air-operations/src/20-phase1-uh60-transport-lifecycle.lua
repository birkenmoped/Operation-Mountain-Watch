-- Operation Mountain Watch - strict UH-60 troop-transport lifecycle
--
-- This module is deliberately limited to runtime transport behaviour. It does
-- not redefine inventory, grouping or package contracts. It prevents an
-- intermediate pickup/drop-off landing from being treated as the final base
-- landing and requires native MOOSE cargo lifecycle events before the physical
-- transport objective can pass.
local TAG = "[OMW][AirOps.JBAD.PH1.UH60.TRANSPORT]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local factory = ph1 and ph1.Factory
local controller = ph1 and ph1.Controller
local observer = ph1 and ph1.Observer

if not cfg or not ph1 or not factory or not controller or not observer then
  log("ERROR: Phase 1 runtime components unavailable.")
else
  ph1.Version = "JBAD-PHASE1-9"

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function startsWith(value, prefix)
    return value and prefix and string.sub(value, 1, #prefix) == prefix
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

  local function getGroupName(eventData)
    if eventData and eventData.IniGroupName then return eventData.IniGroupName end
    if eventData and eventData.IniGroup and eventData.IniGroup.GetName then
      local ok, value = pcall(function() return eventData.IniGroup:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function getUnitName(eventData)
    if eventData and eventData.IniUnitName then return eventData.IniUnitName end
    if eventData and eventData.IniUnit and eventData.IniUnit.GetName then
      local ok, value = pcall(function() return eventData.IniUnit:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function getTypeName(eventData)
    if eventData and eventData.IniTypeName then return eventData.IniTypeName end
    if eventData and eventData.IniUnit and eventData.IniUnit.GetTypeName then
      local ok, value = pcall(function() return eventData.IniUnit:GetTypeName() end)
      if ok then return value end
    end
    return nil
  end

  local function getCoordinate(eventData)
    if eventData and eventData.IniUnit and eventData.IniUnit.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniUnit:GetCoordinate() end)
      if ok then return value end
    end
    if eventData and eventData.IniGroup and eventData.IniGroup.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniGroup:GetCoordinate() end)
      if ok then return value end
    end
    return nil
  end

  local function getPlaceName(eventData)
    if not eventData then return nil end
    for _, field in ipairs({ "PlaceName", "placeName" }) do
      local value = eventData[field]
      if type(value) == "string" and value ~= "" then return value end
    end
    for _, field in ipairs({ "Place", "place" }) do
      local value = eventData[field]
      if type(value) == "string" and value ~= "" then return value end
      if value and value.GetName then
        local ok, name = pcall(function() return value:GetName() end)
        if ok and type(name) == "string" and name ~= "" then return name end
      end
    end
    return nil
  end

  local function normalized(value)
    return string.lower(tostring(value or ""))
  end

  local function jalalabadNames()
    local names = { normalized(cfg.AirbaseName), "jalalabad" }
    if cfg.Airbase and cfg.Airbase.GetName then
      local ok, value = pcall(function() return cfg.Airbase:GetName() end)
      if ok then names[#names + 1] = normalized(value) end
    end
    return names
  end

  local function isJalalabadPlace(placeName)
    local actual = normalized(placeName)
    if actual == "" then return false end
    for _, expected in ipairs(jalalabadNames()) do
      if expected ~= "" and actual == expected then return true end
    end
    return false
  end

  local function coordinateInZone(coordinate, zone)
    if not coordinate or not zone then return false end
    if zone.IsCoordinateInZone then
      local ok, value = pcall(function() return zone:IsCoordinateInZone(coordinate) end)
      if ok then return value == true end
    end
    local distance = distance2D(coordinate, zone:GetCoordinate())
    return distance and distance <= zone:GetRadius() or false
  end

  local function groupInZone(groupName, zone)
    local group = groupName and GROUP and GROUP:FindByName(groupName) or nil
    if not group or not group:IsAlive() then return false end
    if group.IsAnyInZone then
      local ok, value = pcall(function() return group:IsAnyInZone(zone) end)
      if ok then return value == true end
    end
    local ok, coordinate = pcall(function() return group:GetCoordinate() end)
    return ok and coordinateInZone(coordinate, zone) or false
  end

  local function exactTransportEvent(eventData)
    if ph1.ActiveTestId ~= "UH60_TROOP" or not ph1.ActiveMission or not ph1.Runtime or not ph1.ActiveDefinition then return false end
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    if typeName ~= "UH-60A" then return false end
    if not startsWith(groupName, ph1.ActiveDefinition.ExpectedGroupPrefix) then return false end
    observer:RefreshMissionGroups()
    return ph1.Runtime.ExpectedUnitNames and ph1.Runtime.ExpectedUnitNames[unitName] == groupName
  end

  local function transportState()
    local runtime = ph1.Runtime
    if not runtime then return nil end
    runtime.TransportLifecycle = runtime.TransportLifecycle or {
      AttachedGroups = {},
      PickupLandingObserved = false,
      LoadingDone = false,
      PostPickupTakeoffObserved = false,
      DropoffLandingObserved = false,
      CargoUnloadedObserved = false,
      UnloadingDone = false,
      PostDropoffTakeoffObserved = false,
      FinalDespawnArmed = false,
      TransportTakeoffEvents = 0,
      OperationalLandingEvents = 0
    }
    return runtime.TransportLifecycle
  end

  local function opsGroupName(opsgroup)
    if not opsgroup then return nil end
    if opsgroup.groupname then return opsgroup.groupname end
    if opsgroup.GetName then
      local ok, value = pcall(function() return opsgroup:GetName() end)
      if ok then return value end
    end
    if opsgroup.group and opsgroup.group.GetName then
      local ok, value = pcall(function() return opsgroup.group:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function cargoName(cargo)
    if not cargo then return "nil" end
    if cargo.groupname then return tostring(cargo.groupname) end
    if cargo.GetName then
      local ok, value = pcall(function() return cargo:GetName() end)
      if ok then return tostring(value) end
    end
    if cargo.group and cargo.group.GetName then
      local ok, value = pcall(function() return cargo.group:GetName() end)
      if ok then return tostring(value) end
    end
    return tostring(cargo)
  end

  local function setHardFailure(reason)
    local runtime = ph1.Runtime
    if not runtime then return end
    if not runtime.HardFailure then
      runtime.HardFailure = reason
      runtime.PendingFailure = runtime.PendingFailure or reason
      log("ERROR testId=UH60_TROOP reason=" .. tostring(reason))
    end
  end

  local function transportCarrierAlive()
    local runtime = ph1.Runtime
    if not runtime then return false end
    local foundExpected = false
    for groupName in pairs(runtime.ExpectedGroupNames or {}) do
      foundExpected = true
      local group = GROUP and GROUP:FindByName(groupName) or nil
      if group and group:IsAlive() then return true end
    end
    return not foundExpected
  end

  local function strictObjectiveReady(logMissing)
    local runtime = ph1.Runtime
    local lifecycle = transportState()
    if not runtime or not lifecycle then return false end
    local loadZone = ZONE and ZONE:FindByName(ph1.Objects.UHLoadZone) or nil
    local dropZone = ZONE and ZONE:FindByName(ph1.Objects.UHUnloadZone) or nil
    local requirements = {
      { "initial-takeoff", (runtime.TakeoffCount or 0) >= 1 },
      { "pickup-landing", lifecycle.PickupLandingObserved == true },
      { "moose-loading-done", lifecycle.LoadingDone == true },
      { "post-pickup-takeoff", lifecycle.PostPickupTakeoffObserved == true },
      { "dropoff-landing", lifecycle.DropoffLandingObserved == true },
      { "moose-cargo-unloaded", lifecycle.CargoUnloadedObserved == true },
      { "moose-unloading-done", lifecycle.UnloadingDone == true },
      { "troops-alive-in-drop-zone", dropZone and groupInZone(runtime.TroopGroupName, dropZone) or false }
    }
    for _, requirement in ipairs(requirements) do
      if not requirement[2] then
        if logMissing then log("OBJECTIVE_PENDING missing=" .. requirement[1]) end
        return false
      end
    end
    if loadZone and groupInZone(runtime.TroopGroupName, loadZone) then
      if logMissing then log("OBJECTIVE_PENDING missing=troops-left-pickup-zone") end
      return false
    end
    return true
  end

  local function armFinalDespawn(opsgroup)
    local lifecycle = transportState()
    if not lifecycle or lifecycle.FinalDespawnArmed then return lifecycle and lifecycle.FinalDespawnArmed or false end
    if not opsgroup or not opsgroup.SetDespawnAfterLanding then
      setHardFailure("flightgroup-final-despawn-method-unavailable")
      return false
    end
    local ok, err = pcall(function() opsgroup:SetDespawnAfterLanding() end)
    if not ok then
      setHardFailure("flightgroup-final-despawn-arm-failed: " .. tostring(err))
      return false
    end
    lifecycle.FinalDespawnArmed = true
    log("TROOP_EVENT stage=FINAL_LANDING_DESPAWN_ARMED onlyAfterVerifiedUnload=true")
    return true
  end

  local function attachTransportCallbacks(mission, attempt)
    if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "UH60_TROOP" or not ph1.Runtime then return end
    local lifecycle = transportState()
    local ok, groups = pcall(function() return mission:GetOpsGroups() end)
    if ok then
      for _, opsgroup in pairs(groups or {}) do
        local groupName = opsGroupName(opsgroup)
        if groupName and startsWith(groupName, ph1.ActiveDefinition.ExpectedGroupPrefix) and not lifecycle.AttachedGroups[groupName] then
          local previousLoadingDone = opsgroup.OnAfterLoadingDone
          function opsgroup:OnAfterLoadingDone(from, event, to)
            if previousLoadingDone then pcall(previousLoadingDone, self, from, event, to) end
            if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "UH60_TROOP" then return end
            local state = transportState()
            state.LoadingDone = true
            ph1.Runtime.TroopsPickedUpObserved = true
            log(string.format("TROOP_EVENT stage=LOADING_DONE group=%s pickupLandingObserved=%s", tostring(groupName), tostring(state.PickupLandingObserved)))
          end

          local previousUnloaded = opsgroup.OnAfterUnloaded
          function opsgroup:OnAfterUnloaded(from, event, to, cargo)
            if previousUnloaded then pcall(previousUnloaded, self, from, event, to, cargo) end
            if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "UH60_TROOP" then return end
            local state = transportState()
            state.CargoUnloadedObserved = true
            state.UnloadedCargoName = cargoName(cargo)
            log(string.format("TROOP_EVENT stage=CARGO_UNLOADED group=%s cargo=%s dropoffLandingObserved=%s", tostring(groupName), tostring(state.UnloadedCargoName), tostring(state.DropoffLandingObserved)))
          end

          local previousUnloadingDone = opsgroup.OnAfterUnloadingDone
          function opsgroup:OnAfterUnloadingDone(from, event, to)
            if previousUnloadingDone then pcall(previousUnloadingDone, self, from, event, to) end
            if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "UH60_TROOP" then return end
            local state = transportState()
            state.UnloadingDone = true
            log(string.format("TROOP_EVENT stage=UNLOADING_DONE group=%s loadingDone=%s cargoUnloaded=%s dropoffLandingObserved=%s", tostring(groupName), tostring(state.LoadingDone), tostring(state.CargoUnloadedObserved), tostring(state.DropoffLandingObserved)))
            armFinalDespawn(self)
          end

          lifecycle.AttachedGroups[groupName] = true
          lifecycle.OpsGroup = opsgroup
          log("TROOP_EVENT stage=CARRIER_CALLBACKS_ATTACHED group=" .. tostring(groupName))
        end
      end
    end

    for _ in pairs(lifecycle.AttachedGroups) do return end
    local nextAttempt = (attempt or 1) + 1
    if nextAttempt <= 60 then
      SCHEDULER:New(nil, function() attachTransportCallbacks(mission, nextAttempt) end, {}, 2)
    else
      setHardFailure("transport-carrier-callbacks-not-attached")
    end
  end

  -- Replace only the UH-60 objective observer. The AUFTRAG constructor and all
  -- other test factories remain unchanged.
  local previousFactoryCreate = factory.Create
  function factory:Create(testId)
    local mission, createError = previousFactoryCreate(self, testId)
    if not mission or testId ~= "UH60_TROOP" then return mission, createError end

    local runtime = ph1.Runtime
    runtime.TransportLifecycle = nil
    transportState()
    runtime.TroopsPickedUpObserved = false
    runtime.TroopsDeliveredObserved = false
    runtime.ObjectiveCheck = function()
      local state = transportState()
      if (runtime.TakeoffCount or 0) > 0 and not state.UnloadingDone and not transportCarrierAlive() then
        setHardFailure("transport-carrier-despawned-before-verified-dropoff")
        return false
      end
      if strictObjectiveReady(false) then
        runtime.TroopsDeliveredObserved = true
        ph1:MarkObjectiveDrivenSuccess("native-loading-and-unloading-lifecycle-confirmed")
        log("TROOP_EVENT stage=PHYSICAL_OBJECTIVE_CONFIRMED strictLifecycle=true")
        return true
      end
      return false
    end
    log("TROOP_LIFECYCLE_CONFIGURED pickupVia=OnAfterLoadingDone dropoffVia=OnAfterUnloaded+OnAfterUnloadingDone baseLanding=exactAirbaseIdentity autoDespawnAtIntermediateLZ=false")
    return mission, createError
  end

  -- Suppress the old broad radius-based RTB detector for this transport. RTB is
  -- confirmed only by an actual DCS landing event whose place is Jalalabad.
  local previousUpdateDistanceTracking = observer.UpdateDistanceTracking
  function observer:UpdateDistanceTracking()
    if ph1.ActiveTestId ~= "UH60_TROOP" or not ph1.Runtime then
      return previousUpdateDistanceTracking(self)
    end
    local base = cfg.Airbase and cfg.Airbase:GetCoordinate() or nil
    if not base then return end
    for _, item in ipairs(self:GetRuntimeGroupCoordinates()) do
      local distance = distance2D(item.Coordinate, base)
      if distance then
        ph1.Runtime.MaxDistanceFromBase = math.max(ph1.Runtime.MaxDistanceFromBase or 0, distance)
      end
    end
  end

  -- Count all transport takeoffs by phase while retaining the ordinary unique
  -- aircraft takeoff count from the original observer.
  local eventHandler = ph1.EventHandler
  if not eventHandler then
    log("ERROR: Phase 1 event handler unavailable.")
  else
    local previousTakeoff = eventHandler.OnEventTakeoff
    function eventHandler:OnEventTakeoff(eventData)
      if previousTakeoff then previousTakeoff(self, eventData) end
      if not exactTransportEvent(eventData) then return end
      local state = transportState()
      state.TransportTakeoffEvents = (state.TransportTakeoffEvents or 0) + 1
      local stage = "DEPART_BASE"
      if state.UnloadingDone then
        state.PostDropoffTakeoffObserved = true
        stage = "DEPART_DROPOFF"
      elseif state.LoadingDone then
        state.PostPickupTakeoffObserved = true
        stage = "DEPART_PICKUP"
      end
      log(string.format("TROOP_EVENT stage=%s takeoffEvents=%d loadingDone=%s unloadingDone=%s", stage, state.TransportTakeoffEvents, tostring(state.LoadingDone), tostring(state.UnloadingDone)))
    end

    local previousLand = eventHandler.OnEventLand
    function eventHandler:OnEventLand(eventData)
      if ph1.ActiveTestId ~= "UH60_TROOP" or not exactTransportEvent(eventData) then
        if previousLand then return previousLand(self, eventData) end
        return
      end

      local runtime = ph1.Runtime
      local state = transportState()
      local groupName = getGroupName(eventData)
      local unitName = getUnitName(eventData)
      local coordinate = getCoordinate(eventData)
      local placeName = getPlaceName(eventData)
      local loadZone = ZONE and ZONE:FindByName(ph1.Objects.UHLoadZone) or nil
      local dropZone = ZONE and ZONE:FindByName(ph1.Objects.UHUnloadZone) or nil
      local atPickup = loadZone and coordinateInZone(coordinate, loadZone) or false
      local atDropoff = dropZone and coordinateInZone(coordinate, dropZone) or false

      if isJalalabadPlace(placeName) then
        runtime.LandedUnits = runtime.LandedUnits or {}
        if not runtime.LandedUnits[unitName] then
          runtime.LandedUnits[unitName] = true
          increment("landings")
          runtime.LandingCount = (runtime.LandingCount or 0) + 1
        end
        runtime.RTBObserved = true
        state.FinalBaseLandingObserved = true
        log(string.format("EVENT testId=UH60_TROOP stage=LAND_AT_JALALABAD_EXACT group=%s unit=%s place=%s count=%d expected=%d", tostring(groupName), tostring(unitName), tostring(placeName), runtime.LandingCount or 0, ph1.ActiveDefinition.ExpectedAircraft))
        return
      end

      state.OperationalLandingEvents = (state.OperationalLandingEvents or 0) + 1
      increment("remoteLandings")
      runtime.RemoteLandingCount = (runtime.RemoteLandingCount or 0) + 1
      if atPickup and not state.LoadingDone then
        state.PickupLandingObserved = true
        log(string.format("TROOP_EVENT stage=PICKUP_LANDING_OBSERVED group=%s unit=%s place=%s landingEvents=%d", tostring(groupName), tostring(unitName), tostring(placeName or "none"), state.OperationalLandingEvents))
      elseif atDropoff and state.LoadingDone then
        state.DropoffLandingObserved = true
        log(string.format("TROOP_EVENT stage=DROPOFF_LANDING_OBSERVED group=%s unit=%s place=%s landingEvents=%d", tostring(groupName), tostring(unitName), tostring(placeName or "none"), state.OperationalLandingEvents))
      else
        log(string.format("TROOP_EVENT stage=UNCLASSIFIED_OPERATIONAL_LANDING group=%s unit=%s place=%s atPickup=%s atDropoff=%s loadingDone=%s", tostring(groupName), tostring(unitName), tostring(placeName or "none"), tostring(atPickup), tostring(atDropoff), tostring(state.LoadingDone)))
      end
    end
  end

  -- Attach native MOOSE cargo callbacks when the FLIGHTGROUP appears and reject
  -- every native terminal state that precedes a verified unload at the drop LZ.
  local previousOnMissionState = controller.OnMissionState
  function controller:OnMissionState(state, mission, from, event, to)
    local result = previousOnMissionState(self, state, mission, from, event, to)
    if mission ~= ph1.ActiveMission or ph1.ActiveTestId ~= "UH60_TROOP" or not ph1.Runtime then return result end

    if state == "SCHEDULED" or state == "STARTED" or state == "EXECUTING" then
      SCHEDULER:New(nil, function() attachTransportCallbacks(mission, 1) end, {}, 1)
    end

    if state == "DONE" or state == "SUCCESS" or state == "FAILED" or state == "CANCELLED" then
      if strictObjectiveReady(false) then
        ph1.Runtime.TroopsDeliveredObserved = true
        ph1:MarkObjectiveDrivenSuccess("terminal-after-strict-transport-objective")
      elseif not ph1.Runtime.ObjectiveDrivenSuccess then
        ph1.Runtime.MissionTerminal = true
        ph1.Runtime.MissionState = state
        setHardFailure("transport-terminal-before-verified-dropoff-" .. string.lower(state))
      end
    end
    return result
  end

  log("READY version=JBAD-PHASE1-9 intermediateLandingDespawn=false nativeCargoCallbacks=true exactBaseLanding=true falsePickupHeuristic=false earlyTerminalFails=true")
end
