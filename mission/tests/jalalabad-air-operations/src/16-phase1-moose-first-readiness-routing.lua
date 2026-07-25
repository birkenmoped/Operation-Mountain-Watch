-- Operation Mountain Watch - MOOSE-first readiness, routing and telemetry
local TAG = "[OMW][AirOps.JBAD.PH1.ROUTING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Observer then
  log("ERROR: Phase-1 dependencies unavailable.")
else
  local routing = ph1.Routing or {}
  ph1.Routing = routing

  local HELICOPTER_SQUADRONS = { OH58D = true, AH64D = true, UH60 = true, CH47 = true }
  local TACTICAL_FORMATIONS = {
    ECHELON_RIGHT_300 = function()
      return ENUMS and ENUMS.Formation and ENUMS.Formation.RotaryWing
        and ENUMS.Formation.RotaryWing.EchelonRight
        and ENUMS.Formation.RotaryWing.EchelonRight.D300 or nil
    end,
    ECHELON_LEFT_300 = function()
      return ENUMS and ENUMS.Formation and ENUMS.Formation.RotaryWing
        and ENUMS.Formation.RotaryWing.EchelonLeft
        and ENUMS.Formation.RotaryWing.EchelonLeft.D300 or nil
    end
  }

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx, dz = (a.x or 0) - (b.x or 0), az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function landHeight(coordinate)
    if not coordinate or not coordinate.GetLandHeight then return nil end
    local ok, value = pcall(function() return coordinate:GetLandHeight() end)
    return ok and tonumber(value) or nil
  end

  local function resolveEgressZone(definition)
    if not definition or not definition.EgressZoneKey then return nil end
    if definition.EgressZoneKey == "RECON_01" then
      return ZONE and ZONE:FindByName(ph1.Objects.ReconZones[1]) or nil
    elseif definition.EgressZoneKey == "RECON_02" then
      return ZONE and ZONE:FindByName(ph1.Objects.ReconZones[2]) or nil
    elseif definition.EgressZoneKey == "RECON_03" then
      return ZONE and ZONE:FindByName(ph1.Objects.ReconZones[3]) or nil
    end
    return nil
  end

  local function applyVerticalHelicopterOption(flightgroup, groupName)
    local runtime, definition = ph1.Runtime, ph1.ActiveDefinition
    if not runtime or not definition or not HELICOPTER_SQUADRONS[definition.SquadronKey] then return true end
    if not flightgroup or not flightgroup.SetOptionPreferVertical then
      runtime.HardFailure = "vertical-option-MOOSE-method-unavailable-" .. tostring(groupName)
      log("ERROR FLIGHTGROUP_OPTION group=" .. tostring(groupName) .. " SetOptionPreferVertical unavailable")
      return false
    end
    local ok, result = pcall(function() return flightgroup:SetOptionPreferVertical() end)
    if not ok or not result or flightgroup.OptionPreferVertical ~= true then
      runtime.HardFailure = "vertical-option-apply-failed-" .. tostring(groupName)
      log("ERROR FLIGHTGROUP_OPTION group=" .. tostring(groupName) .. " preferVerticalTakeoffAndLanding failed=" .. tostring(result))
      return false
    end
    runtime.VerticalOptionAppliedGroups = runtime.VerticalOptionAppliedGroups or {}
    runtime.VerticalOptionAppliedGroups[groupName] = true
    log(string.format("FLIGHTGROUP_OPTION testId=%s group=%s preferVerticalTakeoffAndLanding=true source=MOOSE_FLIGHTGROUP authority=%s beforeEngineStart=true advisory=true",
      tostring(ph1.ActiveTestId), tostring(groupName), tostring(ph1.ActiveKind)))
    return true
  end

  local function groupHasPhysicalLoss(runtime, groupName)
    for unitName, lost in pairs(runtime.LostUnits or {}) do
      if lost and runtime.ExpectedUnitNames and runtime.ExpectedUnitNames[unitName] == groupName then return true end
    end
    return false
  end

  local function groupCompletedFinalLanding(runtime, groupName)
    local expected, landed = 0, 0
    for unitName, expectedGroupName in pairs(runtime.ExpectedUnitNames or {}) do
      if expectedGroupName == groupName then
        expected = expected + 1
        if runtime.LandedUnits and runtime.LandedUnits[unitName] then landed = landed + 1 end
      end
    end
    return expected > 0 and landed == expected
  end

  local function isExpectedFinalDespawn(runtime, groupName)
    local definition = ph1.ActiveDefinition
    if not runtime or not definition or not runtime.BoundGroupNames[groupName] then return false end
    if runtime.FinalDespawnArmed ~= true or runtime.ObjectiveSatisfied ~= true or runtime.RTBObserved ~= true then return false end
    if not definition.NativeTerminal or not runtime.NativeStates or not runtime.NativeStates[definition.NativeTerminal] then return false end
    if not groupCompletedFinalLanding(runtime, groupName) or groupHasPhysicalLoss(runtime, groupName) then return false end
    return true
  end

  local function attachTerminalLossFinalizer(flightgroup, groupName)
    if not flightgroup or flightgroup.OMWPhase1TerminalLossFinalizerAttached then return end
    flightgroup.OMWPhase1TerminalLossFinalizerAttached = true
    local previousDead = flightgroup.OnAfterDead
    function flightgroup:OnAfterDead(from, event, to)
      if previousDead then pcall(previousDead, self, from, event, to) end
      local runtime = ph1.Runtime
      if not runtime or not runtime.BoundGroupNames[groupName] then return end

      if isExpectedFinalDespawn(runtime, groupName) then
        local observerReason = "flightgroup-dead-" .. tostring(groupName)
        if runtime.HardFailure == observerReason then runtime.HardFailure = nil end
        runtime.ExpectedFinalDespawnObservedGroups = runtime.ExpectedFinalDespawnObservedGroups or {}
        if not runtime.ExpectedFinalDespawnObservedGroups[groupName] then
          runtime.ExpectedFinalDespawnObservedGroups[groupName] = true
          log(string.format("EXPECTED_FINAL_DESPAWN testId=%s group=%s objective=true nativeTerminal=%s finalLanding=true physicalLoss=false classification=NON_LOSS waitForAssetRelease=true",
            tostring(ph1.ActiveTestId), tostring(groupName), tostring(ph1.ActiveDefinition and ph1.ActiveDefinition.NativeTerminal)))
        end
        return
      end

      if runtime.TerminalLossFinalized then return end
      runtime.TerminalLossFinalized = true
      local reason = runtime.HardFailure or ("flightgroup-dead-" .. tostring(groupName))
      runtime.HardFailure = reason
      log(string.format("TERMINAL_LOSS testId=%s group=%s reason=%s objective=%s nativeState=%s classification=FAIL immediate=true",
        tostring(ph1.ActiveTestId), tostring(groupName), tostring(reason), tostring(runtime.ObjectiveSatisfied == true), tostring(runtime.NativeState)))
      if ph1.Controller and ph1.Controller.AbortActive then
        pcall(function() ph1.Controller:AbortActive("terminal-aircraft-loss") end)
      end
      if ph1.Controller and ph1.Controller.FinalizeTest then
        ph1.Controller:FinalizeTest("FAIL", reason, false)
      else
        log("ERROR TERMINAL_LOSS controller finalization API unavailable")
      end
    end
  end

  local function attachLegionAssetReturnFinalizer()
    if routing.LegionAssetReturnHookAttached then return routing.LegionAssetReturnHookAirwing == cfg.Airwing end
    local airwing = cfg.Airwing
    if not airwing then return false end

    local previousAssetReturned = airwing.OnAfterLegionAssetReturned
    function airwing:OnAfterLegionAssetReturned(from, event, to, cohort, asset)
      if previousAssetReturned then pcall(previousAssetReturned, self, from, event, to, cohort, asset) end

      local runtime = ph1.Runtime
      local definition = ph1.ActiveDefinition
      local groupName = asset and asset.spawngroupname or nil
      if not runtime or not definition or not groupName or not runtime.BoundGroupNames[groupName] then return end

      runtime.LegionAssetReturnedGroups = runtime.LegionAssetReturnedGroups or {}
      if runtime.LegionAssetReturnedGroups[groupName] then return end
      runtime.LegionAssetReturnedGroups[groupName] = true
      runtime.LegionAssetReturnedCount = (runtime.LegionAssetReturnedCount or 0) + 1

      -- A pre-spawn inventory poll can see the untouched baseline as "released".
      -- The real MOOSE return event re-arms the acceptance edge for the actual asset.
      runtime.ReleaseLogged = false
      runtime.ReleaseStablePolls = math.max(0, (ph1.Limits.ReleaseStablePolls or 1) - 1)
      log(string.format("AIRWING_EVENT testId=%s event=LEGION_ASSET_RETURNED group=%s cohort=%s returnedGroups=%d expectedGroups=%d source=MOOSE_LEGION_FSM",
        tostring(ph1.ActiveTestId), tostring(groupName), tostring(cohort and cohort.name),
        runtime.LegionAssetReturnedCount, tonumber(definition.ExpectedGroups) or 0))

      if SCHEDULER and ph1.Controller and ph1.Controller.PollActive then
        SCHEDULER:New(nil, function()
          if ph1.Runtime == runtime and ph1.ActiveDefinition == definition and ph1.ActiveObject then
            ph1.Controller:PollActive()
          end
        end, {}, 1)
      end
    end

    routing.LegionAssetReturnHookAttached = true
    routing.LegionAssetReturnHookAirwing = airwing
    log("AIRWING_HOOK READY event=OnAfterLegionAssetReturned releaseAuthority=MOOSE_LEGION_FSM")
    return true
  end

  function routing:ConfigureMission(testId, mission, definition)
    if not mission or not definition then return false, "mission/definition unavailable" end

    if definition.TacticalFormation then
      local resolver = TACTICAL_FORMATIONS[definition.TacticalFormation]
      local formation = resolver and resolver() or nil
      if not formation or not mission.SetFormation then
        return false, "MOOSE rotary formation unavailable: " .. tostring(definition.TacticalFormation)
      end
      local ok, result = pcall(function() return mission:SetFormation(formation) end)
      if not ok or not result then return false, "MOOSE SetFormation failed" end
      log(string.format("TACTICAL_FORMATION_APPLIED testId=%s formation=%s value=%s doctrineApproximation=COMBAT_CRUISE_RIGHT authority=AUFTRAG:SetFormation",
        tostring(testId), tostring(definition.TacticalFormation), tostring(formation)))
    end

    if definition.ReturnAltitudePolicy == "MATCH_INGRESS" then
      local egressZone = resolveEgressZone(definition)
      local ingressAltitude = tonumber(mission.OMWIngressAltitudeFeet or definition.FlightAltitudeFeet)
      local ingressSpeed = tonumber(mission.OMWIngressSpeedKnots or definition.FlightSpeedKnots)
      if not egressZone then return false, "fixed-altitude egress zone unavailable: " .. tostring(definition.EgressZoneKey) end
      if not ingressAltitude or not ingressSpeed then return false, "fixed ingress altitude/speed unavailable" end
      if not mission.SetMissionEgressCoord then return false, "AUFTRAG:SetMissionEgressCoord unavailable" end

      local ok, result = pcall(function()
        return mission:SetMissionEgressCoord(egressZone:GetCoordinate(), ingressAltitude, ingressSpeed)
      end)
      if not ok or not result then return false, "MOOSE fixed-altitude egress configuration failed" end

      mission.OMWEgressAltitudeFeet = ingressAltitude
      mission.OMWEgressSpeedKnots = ingressSpeed
      mission.OMWEgressZoneName = egressZone:GetName()
      log(string.format("RETURN_ALTITUDE_MATCH_APPLIED testId=%s ingressAltitude=%dft egressAltitude=%dft equal=true ingressSpeed=%dkt egressSpeed=%dkt egress=%s terrainAltitudeCalculation=false authority=AUFTRAG:SetMissionEgressCoord",
        tostring(testId), ingressAltitude, ingressAltitude, ingressSpeed, ingressSpeed, mission.OMWEgressZoneName))
    end

    return true
  end

  local function templateRoutePointCount(group)
    if not group then return nil end
    if group.GetTemplateRoutePoints then
      local ok, points = pcall(function() return group:GetTemplateRoutePoints() end)
      if ok and type(points) == "table" then return #points end
    end
    if group.GetTaskRoute then
      local ok, points = pcall(function() return group:GetTaskRoute() end)
      if ok and type(points) == "table" then return #points end
    end
    return nil
  end

  function routing:ValidateTestReady(testId, logResult)
    local definition = ph1.Tests[testId]
    if definition and definition.ReturnAltitudePolicy == "MATCH_INGRESS" then
      local egressZone = resolveEgressZone(definition)
      if not egressZone then return false, "fixed-altitude egress zone unavailable" end
      if not definition.FlightAltitudeFeet or not definition.FlightSpeedKnots then
        return false, "fixed flight altitude/speed unavailable"
      end
      if logResult then
        log(string.format("FIXED_FLIGHT_PROFILE READY testId=%s ingressAltitude=%dft returnAltitude=%dft equal=true speed=%dkt egress=%s terrainAltitudeCalculation=false",
          tostring(testId), definition.FlightAltitudeFeet, definition.FlightAltitudeFeet,
          definition.FlightSpeedKnots, egressZone:GetName()))
      end
      return true
    end
    if testId == "UH60_TROOP" or testId == "UH60_ABORT" then
      local pickup, deploy = ZONE:FindByName(ph1.Objects.UHLoadZone), ZONE:FindByName(ph1.Objects.UHUnloadZone)
      if not pickup or not deploy then return false, "UH-60 pickup/deploy zones unavailable" end
      local centerDistance = distance2D(pickup:GetCoordinate(), deploy:GetCoordinate())
      local edgeGap = centerDistance - pickup:GetRadius() - deploy:GetRadius()
      if edgeGap <= 0 then return false, string.format("UH-60 pickup/deploy zones overlap by %.0fm", math.abs(edgeGap)) end
      local template = GROUP:FindByName(ph1.Objects.UHTroopTemplate)
      local routePoints = templateRoutePointCount(template)
      if routePoints and routePoints > 1 then return false, "troop cargo template has autonomous route points=" .. tostring(routePoints) end
      if logResult then log(string.format("GROUP_TRANSPORT_PROFILE READY distance=%.0fm edgeGap=%.0fm templateRoutePoints=%s authority=OPSTRANSPORT", centerDistance, edgeGap, tostring(routePoints or "unknown"))) end
      return true
    end
    if testId == "CH47_CARGO" then
      local cargo, pickup, drop = STATIC:FindByName(ph1.Objects.CH47Cargo, false), ZONE:FindByName(ph1.Objects.CH47PickupZone), ZONE:FindByName(ph1.Objects.CH47DropZone)
      if not cargo or not pickup or not drop then return false, "CH-47 cargo objects unavailable" end
      if not cargo:IsInZone(pickup) then return false, "CH-47 static cargo not inside pickup zone" end
      if cargo:IsInZone(drop) then return false, "CH-47 static cargo already inside drop zone" end
      if logResult then log("SLING_CARGO_PROFILE READY authority=AUFTRAG:NewCARGOTRANSPORT physicalSuccess=STATIC:IsInZone requiredTaskAdapter=CARGOTRANSPORT_TASK_BOUND") end
      return true
    end
    if logResult then log("TEST_READINESS READY testId=" .. tostring(testId) .. " additionalChecks=none") end
    return true
  end

  local function fuelTelemetry(groupName)
    if not ph1.Runtime or not ph1.Runtime.BoundGroupNames[groupName] then return false end
    local group = GROUP and GROUP:FindByName(groupName) or nil
    if not group then return false end
    local groupAliveOK, groupAlive = pcall(function() return group:IsAlive() end)
    if not groupAliveOK or groupAlive ~= true then return false end
    for _, unit in ipairs(group:GetUnits() or {}) do
      local unitAliveOK, unitAlive = pcall(function() return unit:IsAlive() end)
      if not unitAliveOK or unitAlive ~= true then return false end
      local fuel = nil
      local dcs = unit.GetDCSObject and unit:GetDCSObject() or nil
      if dcs and dcs.getFuel then
        local ok, value = pcall(function() return dcs:getFuel() end)
        if ok then fuel = value end
      end
      local coordinateOK, coordinate = pcall(function() return unit:GetCoordinate() end)
      if not coordinateOK or not coordinate then return false end
      log(string.format("FUEL testId=%s group=%s unit=%s fuel=%s altitudeMSL=%.0fm terrainMSL=%.0fm",
        tostring(ph1.ActiveTestId), groupName, unit:GetName(), fuel and string.format("%.1f%%", fuel * 100) or "unknown",
        coordinate.y or -1, landHeight(coordinate) or -1))
    end
    return true
  end

  function routing:OnFlightGroupBound(flightgroup, owner)
    if not ph1.Runtime or not ph1.ActiveDefinition then return end
    local groupName = flightgroup:GetName()
    if not applyVerticalHelicopterOption(flightgroup, groupName) then return end
    attachTerminalLossFinalizer(flightgroup, groupName)
    if not attachLegionAssetReturnFinalizer() then
      ph1.Runtime.HardFailure = "MOOSE-LegionAssetReturned-hook-unavailable"
      return
    end

    if ph1.Runtime.ReleaseLogged or (ph1.Runtime.ReleaseStablePolls or 0) > 0 then
      log(string.format("ACCEPTANCE_RESET testId=%s group=%s reason=asset-now-committed previousReleaseLogged=%s previousStablePolls=%d",
        tostring(ph1.ActiveTestId), tostring(groupName), tostring(ph1.Runtime.ReleaseLogged == true), ph1.Runtime.ReleaseStablePolls or 0))
    end
    ph1.Runtime.ReleaseLogged = false
    ph1.Runtime.ReleaseStablePolls = 0

    local definition = ph1.ActiveDefinition
    if definition.ReturnAltitudePolicy == "MATCH_INGRESS" then
      local ingressAltitude = tonumber(definition.FlightAltitudeFeet)
      local configuredEgressAltitude = ph1.ActiveObject and tonumber(ph1.ActiveObject.OMWEgressAltitudeFeet) or nil
      if not ingressAltitude or configuredEgressAltitude ~= ingressAltitude then
        ph1.Runtime.HardFailure = "return-altitude-does-not-match-ingress-" .. tostring(groupName)
        log(string.format("ERROR RETURN_ALTITUDE_BIND_ASSERT testId=%s group=%s ingress=%s egress=%s equal=false",
          tostring(ph1.ActiveTestId), tostring(groupName), tostring(ingressAltitude), tostring(configuredEgressAltitude)))
        return
      end
      ph1.Runtime.ReturnAltitudeMatchedGroups = ph1.Runtime.ReturnAltitudeMatchedGroups or {}
      ph1.Runtime.ReturnAltitudeMatchedGroups[groupName] = true
      log(string.format("RETURN_ALTITUDE_BIND_ASSERT testId=%s group=%s ingressAltitude=%dft egressAltitude=%dft equal=true egress=%s terrainAltitudeCalculation=false",
        tostring(ph1.ActiveTestId), tostring(groupName), ingressAltitude, configuredEgressAltitude,
        tostring(ph1.ActiveObject and ph1.ActiveObject.OMWEgressZoneName)))
    end

    if SCHEDULER then
      local telemetryScheduler
      telemetryScheduler = SCHEDULER:New(nil, function()
        if not fuelTelemetry(groupName) then
          if telemetryScheduler and telemetryScheduler.Stop then telemetryScheduler:Stop() end
        end
      end, {}, 30, ph1.Limits.FuelTelemetryIntervalSeconds)
    end
  end

  log("READY publicMOOSE=true routeAuthority=AUFTRAG+FLIGHTGROUP verticalHelicopterOps=FLIGHTGROUP:SetOptionPreferVertical(advisory) tacticalFormation=AUFTRAG:SetFormation(EchelonRight300) rotorReturnAltitude=AUFTRAG:SetMissionEgressCoord(MATCH_INGRESS) terrainAltitudeCalculation=false terminalAircraftLoss=IMMEDIATE_FAIL expectedFinalDespawn=NON_LOSS_WAIT_FOR_MOOSE_LEGION_RETURN assetRelease=LEGION:OnAfterLegionAssetReturned fuel=empirical-telemetry selfStoppingSchedulers=true")
end
