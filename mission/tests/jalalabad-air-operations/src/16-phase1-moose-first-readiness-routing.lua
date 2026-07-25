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

  local function sampleLeg(first, second, spacing)
    local a, b = first and first:GetVec3() or nil, second and second:GetVec3() or nil
    if not a or not b then return nil, nil, "coordinate-unavailable" end
    local length = distance2D(a, b)
    if not length then return nil, nil, "distance-unavailable" end
    local steps = math.max(1, math.ceil(length / math.max(100, spacing or 750)))
    local maximum = -math.huge
    for index = 0, steps do
      local fraction = index / steps
      local coordinate = COORDINATE:NewFromVec3({ x = a.x + (b.x - a.x) * fraction, y = 0, z = a.z + (b.z - a.z) * fraction })
      local height = landHeight(coordinate)
      if not height then return nil, nil, "terrain-height-unavailable" end
      maximum = math.max(maximum, height)
    end
    return maximum, length
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
    log(string.format("FLIGHTGROUP_OPTION testId=%s group=%s preferVerticalTakeoffAndLanding=true source=MOOSE_FLIGHTGROUP authority=%s beforeEngineStart=true",
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
    if not definition.NativeTerminal or not runtime.NativeStates or runtime.NativeStates[definition.NativeTerminal] ~= true then return false end
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

  function routing:BuildReconProfile(logResult)
    local airbase = cfg.Airbase or (AIRBASE and AIRBASE:FindByName(cfg.AirbaseName))
    if not airbase then return false, "Jalalabad airbase unavailable" end
    local coordinates = { airbase:GetCoordinate() }
    for _, name in ipairs(ph1.Objects.ReconZones) do
      local zone = ZONE and ZONE:FindByName(name) or nil
      if not zone then return false, "missing RECON zone: " .. tostring(name) end
      coordinates[#coordinates + 1] = zone:GetCoordinate()
    end
    coordinates[#coordinates + 1] = ZONE:FindByName(ph1.Objects.ReconZones[2]):GetCoordinate()
    coordinates[#coordinates + 1] = ZONE:FindByName(ph1.Objects.ReconZones[1]):GetCoordinate()
    coordinates[#coordinates + 1] = airbase:GetCoordinate()

    local profile = { TotalRouteMeters = 0, MaximumTerrainMeters = -math.huge, LegDistances = {}, LegTerrain = {}, SpeedKnots = 80 }
    for index = 1, #coordinates - 1 do
      local terrain, length, err = sampleLeg(coordinates[index], coordinates[index + 1], ph1.Limits.TerrainSampleSpacingMeters)
      if not terrain then return false, "RECON terrain scan failed: " .. tostring(err) end
      profile.LegDistances[index], profile.LegTerrain[index] = length, terrain
      profile.TotalRouteMeters = profile.TotalRouteMeters + length
      profile.MaximumTerrainMeters = math.max(profile.MaximumTerrainMeters, terrain)
    end
    profile.AltitudeFeet = math.ceil(((profile.MaximumTerrainMeters + ph1.Limits.ReconClearanceAGLMeters) * 3.280839895) / 100) * 100
    profile.MissionRangeNM = math.max(20, math.ceil(profile.TotalRouteMeters / 2 / 1852) + 5)
    self.ReconProfile = profile
    ph1.Tests.OH58D_RECON.MissionRangeNM = profile.MissionRangeNM
    if logResult then
      log(string.format("RECON_PROFILE READY route=%.0fm maxTerrain=%.0fm altitude=%dft_ASL missionRange=%dNM recovery=03->02->01->Jalalabad fuelLimit=telemetry-only",
        profile.TotalRouteMeters, profile.MaximumTerrainMeters, profile.AltitudeFeet, profile.MissionRangeNM))
    end
    return true, nil, profile
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
    if testId == "OH58D_RECON" then return self:BuildReconProfile(logResult) end
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
      if logResult then log("SLING_CARGO_PROFILE READY authority=AUFTRAG:NewCARGOTRANSPORT physicalSuccess=STATIC:IsInZone") end
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

    if ph1.ActiveTestId == "OH58D_RECON" and ph1.ActiveKind == "AUFTRAG" then
      local zone1 = ZONE:FindByName(ph1.Objects.ReconZones[1])
      local profile = self.ReconProfile
      local egressUID = owner.GetGroupEgressWaypointUID and owner:GetGroupEgressWaypointUID(flightgroup) or nil
      if not zone1 or not profile or not egressUID or not flightgroup.AddWaypoint then
        ph1.Runtime.HardFailure = "recovery-corridor-MOOSE-waypoint-unavailable"
        return
      end
      local ok, waypoint = pcall(function()
        return flightgroup:AddWaypoint(zone1:GetCoordinate(), profile.SpeedKnots, egressUID, profile.AltitudeFeet, false)
      end)
      if not ok or not waypoint then
        ph1.Runtime.HardFailure = "recovery-corridor-add-waypoint-failed"
        return
      end
      if flightgroup.UpdateRoute then flightgroup:UpdateRoute() end
      ph1.Runtime.RecoveryCorridorApplied = true
      log("RECOVERY_CORRIDOR_APPLIED group=" .. groupName .. " route=RECON_03->RECON_02->RECON_01->Jalalabad MOOSE=SetMissionEgressCoord/AddWaypoint/UpdateRoute")
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

  log("READY publicMOOSE=true routeAuthority=AUFTRAG+FLIGHTGROUP verticalHelicopterOps=FLIGHTGROUP:SetOptionPreferVertical terminalAircraftLoss=IMMEDIATE_FAIL expectedFinalDespawn=NON_LOSS_WAIT_FOR_MOOSE_LEGION_RETURN assetRelease=LEGION:OnAfterLegionAssetReturned terrainPolicy=project-specific-advisory fuel=empirical-telemetry selfStoppingSchedulers=true")
end
