-- Operation Mountain Watch - Phase 1 operational safety corrections
-- Corrects terrain-unsafe OH-58D routing, false UH-60 troop success,
-- transport terminal-state handling and helicopter vertical operation preference.
local TAG = "[OMW][AirOps.JBAD.PH1.OPSAFE]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local factory = ph1 and ph1.Factory
local controller = ph1 and ph1.Controller
if not cfg or not ph1 or not factory or not controller then
  log("ERROR: Phase 1 runtime unavailable.")
else
  ph1.Version = "JBAD-PHASE1-4"

  -- The ordinary base logistics unload zone is deliberately not reused as the
  -- tactical troop destination. A separate, clearly separated test LZ prevents
  -- the ground group from satisfying the objective without a helicopter flight.
  ph1.Objects.UHUnloadZone = "ZONE_TEST_US_JBAD_UH60_DROPOFF"

  ph1.OperationalPolicy = {
    Recon = {
      SpeedKnots = 80,
      ClearanceAGLMeters = 350,
      MaxZoneDistanceFromBaseMeters = 18000,
      MinZoneSeparationMeters = 1500,
      MaxLegDistanceMeters = 11000,
      MaxTotalRouteMeters = 42000,
      TerrainSampleSpacingMeters = 750,
      MaxSampledTerrainMeters = 1300,
      MaxMissionAltitudeFeet = 6500,
      MissionRangeNM = 12
    },
    Troop = {
      MaxTemplateRoutePoints = 1,
      MinimumLoadDropDistanceMeters = 3000,
      MaximumLoadDropDistanceMeters = 12000,
      MinimumZoneEdgeGapMeters = 250,
      MaximumTerrainDifferenceMeters = 300,
      PickupRadiusMeters = 120
    }
  }

  ph1.Tests.UH60_TROOP.AllowObjectiveDrivenTerminal = true
  ph1.Tests.CH47_CARGO.AllowObjectiveDrivenTerminal = true
  ph1.Tests.UH60_ABORT.AllowObjectiveDrivenTerminal = false
  ph1.Tests.OH58D_RECON.MissionRangeNM = ph1.OperationalPolicy.Recon.MissionRangeNM

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z
    if az == nil then az = a.y or 0 end
    local bz = b.z
    if bz == nil then bz = b.y or 0 end
    local dx = (a.x or 0) - (b.x or 0)
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function coordinateInZone(coordinate, zone)
    local distance = coordinate and zone and distance2D(coordinate, zone:GetCoordinate()) or nil
    return distance and distance <= zone:GetRadius() or false
  end

  local function groupInZone(groupName, zone)
    local group = GROUP and GROUP:FindByName(groupName) or nil
    if not group or not group:IsAlive() then return false end
    if group.IsAnyInZone then
      local ok, result = pcall(function() return group:IsAnyInZone(zone) end)
      if ok then return result == true end
    end
    local ok, coordinate = pcall(function() return group:GetCoordinate() end)
    return ok and coordinateInZone(coordinate, zone) or false
  end

  local function staticInZone(staticName, zone)
    local static = STATIC and STATIC:FindByName(staticName, false) or nil
    if not static then return false end
    local ok, coordinate = pcall(function() return static:GetCoordinate() end)
    return ok and coordinateInZone(coordinate, zone) or false
  end

  local function landHeight(coordinate)
    if not coordinate or not coordinate.GetLandHeight then return nil end
    local ok, height = pcall(function() return coordinate:GetLandHeight() end)
    return ok and tonumber(height) or nil
  end

  local function sampleLeg(first, second, spacing)
    local a = first:GetVec3()
    local b = second:GetVec3()
    local length = distance2D(a, b) or 0
    local steps = math.max(1, math.ceil(length / spacing))
    local maximum = -math.huge
    for index = 0, steps do
      local fraction = index / steps
      local coordinate = COORDINATE:NewFromVec3({
        x = a.x + (b.x - a.x) * fraction,
        y = 0,
        z = a.z + (b.z - a.z) * fraction
      })
      local height = landHeight(coordinate)
      if not height then return nil, "terrain-height-unavailable" end
      if height > maximum then maximum = height end
    end
    return maximum, nil, length
  end

  local function validateReconRoute(logResult)
    local policy = ph1.OperationalPolicy.Recon
    local airbase = cfg.Airbase or (AIRBASE and AIRBASE:FindByName(cfg.AirbaseName))
    if not airbase then return false, "Jalalabad airbase unavailable" end

    local coordinates = { airbase:GetCoordinate() }
    local zones = {}
    for _, zoneName in ipairs(ph1.Objects.ReconZones or {}) do
      local zone = ZONE and ZONE:FindByName(zoneName) or nil
      if not zone then return false, "missing RECON zone: " .. tostring(zoneName) end
      zones[#zones + 1] = zone
      coordinates[#coordinates + 1] = zone:GetCoordinate()
    end
    coordinates[#coordinates + 1] = airbase:GetCoordinate()

    local maximumTerrain = -math.huge
    local totalRoute = 0
    for index = 2, #coordinates - 1 do
      local distanceFromBase = distance2D(coordinates[1], coordinates[index])
      if not distanceFromBase or distanceFromBase > policy.MaxZoneDistanceFromBaseMeters then
        return false, string.format("RECON zone %d is %.0fm from Jalalabad; maximum=%dm", index - 1, distanceFromBase or -1, policy.MaxZoneDistanceFromBaseMeters)
      end
      local zoneHeight = landHeight(coordinates[index])
      if not zoneHeight or zoneHeight > policy.MaxSampledTerrainMeters then
        return false, string.format("RECON zone %d terrain=%sm; maximum=%dm", index - 1, zoneHeight and string.format("%.0f", zoneHeight) or "unknown", policy.MaxSampledTerrainMeters)
      end
      if index > 2 then
        local separation = distance2D(coordinates[index - 1], coordinates[index])
        if not separation or separation < policy.MinZoneSeparationMeters then
          return false, string.format("RECON zones %d/%d separation=%.0fm; minimum=%dm", index - 2, index - 1, separation or -1, policy.MinZoneSeparationMeters)
        end
      end
    end

    for index = 1, #coordinates - 1 do
      local terrain, err, length = sampleLeg(coordinates[index], coordinates[index + 1], policy.TerrainSampleSpacingMeters)
      if not terrain then return false, "RECON leg terrain scan failed: " .. tostring(err) end
      if length > policy.MaxLegDistanceMeters then
        return false, string.format("RECON leg %d length=%.0fm; maximum=%dm", index, length, policy.MaxLegDistanceMeters)
      end
      totalRoute = totalRoute + length
      if terrain > maximumTerrain then maximumTerrain = terrain end
      if terrain > policy.MaxSampledTerrainMeters then
        return false, string.format("RECON leg %d terrain=%.0fm; maximum=%dm", index, terrain, policy.MaxSampledTerrainMeters)
      end
    end

    if totalRoute > policy.MaxTotalRouteMeters then
      return false, string.format("RECON route=%.0fm; maximum=%dm", totalRoute, policy.MaxTotalRouteMeters)
    end

    local altitudeFeet = math.ceil(((maximumTerrain + policy.ClearanceAGLMeters) * 3.280839895) / 100) * 100
    if altitudeFeet > policy.MaxMissionAltitudeFeet then
      return false, string.format("RECON safe altitude=%dft ASL; maximum=%dft", altitudeFeet, policy.MaxMissionAltitudeFeet)
    end

    if logResult then
      log(string.format("RECON_ROUTE PASS zones=%d route=%.0fm maxTerrain=%.0fm clearance=%dm altitude=%dft_ASL speed=%dkt", #zones, totalRoute, maximumTerrain, policy.ClearanceAGLMeters, altitudeFeet, policy.SpeedKnots))
    end
    return true, nil, altitudeFeet
  end

  local function troopTemplateRoutePoints()
    local database = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups or nil
    local entry = database and database[ph1.Objects.UHTroopTemplate] or nil
    local route = entry and entry.Template and entry.Template.route or nil
    return route and route.points and #route.points or 0
  end

  local function validateTroopTransport(logResult)
    local policy = ph1.OperationalPolicy.Troop
    local loadZone = ZONE and ZONE:FindByName(ph1.Objects.UHLoadZone) or nil
    local dropZone = ZONE and ZONE:FindByName(ph1.Objects.UHUnloadZone) or nil
    if not loadZone then return false, "missing UH-60 load zone: " .. tostring(ph1.Objects.UHLoadZone) end
    if not dropZone then return false, "missing dedicated UH-60 drop zone: " .. tostring(ph1.Objects.UHUnloadZone) end

    local points = troopTemplateRoutePoints()
    if points > policy.MaxTemplateRoutePoints then
      return false, string.format("troop template has %d route points; maximum=%d", points, policy.MaxTemplateRoutePoints)
    end

    local centerDistance = distance2D(loadZone:GetCoordinate(), dropZone:GetCoordinate())
    if not centerDistance or centerDistance < policy.MinimumLoadDropDistanceMeters then
      return false, string.format("UH-60 load/drop distance=%.0fm; minimum=%dm", centerDistance or -1, policy.MinimumLoadDropDistanceMeters)
    end
    if centerDistance > policy.MaximumLoadDropDistanceMeters then
      return false, string.format("UH-60 load/drop distance=%.0fm; maximum=%dm", centerDistance, policy.MaximumLoadDropDistanceMeters)
    end

    local edgeGap = centerDistance - loadZone:GetRadius() - dropZone:GetRadius()
    if edgeGap < policy.MinimumZoneEdgeGapMeters then
      return false, string.format("UH-60 load/drop zone edge gap=%.0fm; minimum=%dm", edgeGap, policy.MinimumZoneEdgeGapMeters)
    end

    local loadHeight = landHeight(loadZone:GetCoordinate())
    local dropHeight = landHeight(dropZone:GetCoordinate())
    if not loadHeight or not dropHeight then return false, "UH-60 load/drop terrain height unavailable" end
    if math.abs(loadHeight - dropHeight) > policy.MaximumTerrainDifferenceMeters then
      return false, string.format("UH-60 load/drop terrain difference=%.0fm; maximum=%dm", math.abs(loadHeight - dropHeight), policy.MaximumTerrainDifferenceMeters)
    end

    if logResult then
      log(string.format("TROOP_ROUTE PASS templateRoutePoints=%d loadDropDistance=%.0fm edgeGap=%.0fm terrainDelta=%.0fm dedicatedDropZone=%s", points, centerDistance, edgeGap, math.abs(loadHeight - dropHeight), ph1.Objects.UHUnloadZone))
    end
    return true
  end

  local originalValidateObjects = factory.ValidateMissionEditorObjects
  function factory:ValidateMissionEditorObjects()
    local ready, missing = originalValidateObjects(self)
    if not ready then return false, missing end

    local reconOK, reconReason = validateReconRoute(true)
    if not reconOK then
      log("RECON_ROUTE BLOCKED reason=" .. tostring(reconReason))
      ph1.OperationalBlockReason = reconReason
      return false, { reconReason }
    end

    local troopOK, troopReason = validateTroopTransport(true)
    if not troopOK then
      log("TROOP_ROUTE BLOCKED reason=" .. tostring(troopReason))
      ph1.OperationalBlockReason = troopReason
      return false, { troopReason }
    end

    ph1.OperationalBlockReason = nil
    ph1.OperationalSafetyReady = cfg.VerticalHelicopterOpsEnabled == true
    if not ph1.OperationalSafetyReady then
      return false, { "vertical helicopter operation preference not active" }
    end
    return true, {}
  end

  local function attachCallbacks(mission)
    function mission:OnAfterQueued(from, event, to) controller:OnMissionState("QUEUED", self, from, event, to) end
    function mission:OnAfterRequested(from, event, to) controller:OnMissionState("REQUESTED", self, from, event, to) end
    function mission:OnAfterScheduled(from, event, to) controller:OnMissionState("SCHEDULED", self, from, event, to) end
    function mission:OnAfterStarted(from, event, to) controller:OnMissionState("STARTED", self, from, event, to) end
    function mission:OnAfterExecuting(from, event, to) controller:OnMissionState("EXECUTING", self, from, event, to) end
    function mission:OnAfterDone(from, event, to) controller:OnMissionState("DONE", self, from, event, to) end
    function mission:OnAfterSuccess(from, event, to) controller:OnMissionState("SUCCESS", self, from, event, to) end
    function mission:OnAfterFailed(from, event, to) controller:OnMissionState("FAILED", self, from, event, to) end
    function mission:OnAfterCancel(from, event, to) controller:OnMissionState("CANCELLED", self, from, event, to) end
  end

  local function configureMission(mission, definition)
    if not mission then return nil, "AUFTRAG constructor returned nil" end
    local squadron = cfg.Squadrons and cfg.Squadrons[definition.SquadronKey]
    local payload = cfg.Payloads and cfg.Payloads[definition.PayloadKey]
    if not squadron then return nil, "squadron unavailable: " .. tostring(definition.SquadronKey) end
    if not payload then return nil, "payload unavailable: " .. tostring(definition.PayloadKey) end

    mission:SetName("OMW-JBAD-PH1-" .. definition.Id)
    mission:SetRequiredAssets(definition.ExpectedGroups, definition.ExpectedGroups)
    mission:AssignSquadrons({ squadron })
    mission:AddRequiredPayload(payload)
    mission:SetPriority(10, false)
    mission:SetRepeat(0)
    mission:SetTime(1, definition.ExecutionTimeout)
    mission:SetDuration(definition.ExecutionTimeout)
    mission:SetMissionRange(definition.MissionRangeNM or 50)
    mission:SetEvaluationTime(5)
    attachCallbacks(mission)
    return mission
  end

  local function spawnTroops()
    ph1.Spawners.Troops = ph1.Spawners.Troops or SPAWN:New(ph1.Objects.UHTroopTemplate)
    local group = ph1.Spawners.Troops:Spawn()
    if not group then return nil, "troop group spawn failed" end
    ph1.Runtime.TroopGroupName = group:GetName()
    log("OBJECTIVE spawned=TROOPS group=" .. tostring(ph1.Runtime.TroopGroupName))
    return group
  end

  function ph1:MarkObjectiveDrivenSuccess(reason)
    local runtime = self.Runtime
    local definition = self.ActiveDefinition
    if not runtime or not definition or not definition.AllowObjectiveDrivenTerminal then return false end
    if definition.RequireTakeoff and (runtime.TakeoffCount or 0) ~= definition.ExpectedAircraft then return false end
    if runtime.ObjectiveDrivenSuccess then return true end

    runtime.ObjectiveDrivenSuccess = true
    runtime.ObjectiveSatisfied = true
    runtime.MissionState = "SUCCESS"
    runtime.MissionStateSeen.SUCCESS = true
    runtime.MissionTerminal = true
    runtime.PendingFailure = nil
    runtime.Phase = "RECOVERY"
    runtime.PhaseStartedAt = timer.getTime()
    runtime.PhaseDeadline = timer.getTime() + definition.RecoveryTimeout
    increment("objectiveDrivenSuccesses")
    log(string.format("OBJECTIVE_DRIVEN_SUCCESS testId=%s reason=%s recoveryTimeout=%ds", tostring(self.ActiveTestId), tostring(reason), definition.RecoveryTimeout))
    return true
  end

  local originalCreate = factory.Create
  function factory:Create(testId)
    local definition = ph1.Tests[testId]
    if not definition then return nil, "unknown test: " .. tostring(testId) end
    local ready = self:ValidateMissionEditorObjects()
    if not ready then return nil, "operational route or Mission Editor validation failed: " .. tostring(ph1.OperationalBlockReason) end

    if testId == "OH58D_RECON" then
      local routeOK, routeReason, altitudeFeet = validateReconRoute(true)
      if not routeOK then return nil, routeReason end
      local zoneSet = SET_ZONE:New()
      for _, zoneName in ipairs(ph1.Objects.ReconZones) do zoneSet:AddZone(ZONE:FindByName(zoneName)) end
      local policy = ph1.OperationalPolicy.Recon
      local mission = AUFTRAG:NewRECON(zoneSet, policy.SpeedKnots, altitudeFeet, false, false, "Vee")
      ph1.Runtime.ObjectiveCheck = function() return ph1.Runtime.MissionState == "SUCCESS" end
      return configureMission(mission, definition)
    end

    if testId == "UH60_TROOP" then
      local transportOK, transportReason = validateTroopTransport(true)
      if not transportOK then return nil, transportReason end
      local troops, spawnError = spawnTroops()
      if not troops then return nil, spawnError end
      local loadZone = ZONE:FindByName(ph1.Objects.UHLoadZone)
      local dropZone = ZONE:FindByName(ph1.Objects.UHUnloadZone)
      if not groupInZone(ph1.Runtime.TroopGroupName, loadZone) then return nil, "spawned troop group is outside load zone" end
      if groupInZone(ph1.Runtime.TroopGroupName, dropZone) then return nil, "spawned troop group is already inside drop zone" end

      local troopSet = SET_GROUP:New()
      troopSet:AddGroup(troops)
      local mission = AUFTRAG:NewTROOPTRANSPORT(troopSet, dropZone:GetCoordinate(), loadZone:GetCoordinate(), ph1.OperationalPolicy.Troop.PickupRadiusMeters)
      ph1.Runtime.TroopsInitiallyAtPickup = true
      ph1.Runtime.ObjectiveCheck = function()
        local runtime = ph1.Runtime
        if not runtime or (runtime.TakeoffCount or 0) < definition.ExpectedAircraft then return false end
        local group = GROUP and GROUP:FindByName(runtime.TroopGroupName) or nil
        local alive = group and group:IsAlive() or false
        local atPickup = alive and groupInZone(runtime.TroopGroupName, loadZone) or false
        local atDrop = alive and groupInZone(runtime.TroopGroupName, dropZone) or false

        if not runtime.TroopsPickedUpObserved and (not alive or not atPickup) then
          runtime.TroopsPickedUpObserved = true
          log("TROOP_EVENT stage=PICKUP_CONFIRMED group=" .. tostring(runtime.TroopGroupName))
        end
        if runtime.TroopsPickedUpObserved and atDrop then
          runtime.TroopsDeliveredObserved = true
          ph1:MarkObjectiveDrivenSuccess("troops-delivered-to-dedicated-drop-zone")
          return true
        end
        return false
      end
      return configureMission(mission, definition)
    end

    if testId == "CH47_CARGO" then
      local cargo = STATIC:FindByName(ph1.Objects.CH47Cargo, false)
      local pickupZone = ZONE:FindByName(ph1.Objects.CH47PickupZone)
      local dropZone = ZONE:FindByName(ph1.Objects.CH47DropZone)
      if not cargo then return nil, "CH-47 cargo static unavailable" end
      if staticInZone(ph1.Objects.CH47Cargo, dropZone) then return nil, "CH-47 cargo is already inside the drop zone; restart the mission" end
      if not staticInZone(ph1.Objects.CH47Cargo, pickupZone) then return nil, "CH-47 cargo is outside the required pickup zone" end

      local mission = AUFTRAG:NewCARGOTRANSPORT(cargo, dropZone)
      ph1.Runtime.ObjectiveCheck = function()
        local runtime = ph1.Runtime
        if not runtime or (runtime.TakeoffCount or 0) < definition.ExpectedAircraft then return false end
        if staticInZone(ph1.Objects.CH47Cargo, dropZone) then
          runtime.CargoDeliveredObserved = true
          ph1:MarkObjectiveDrivenSuccess("cargo-delivered-to-drop-zone")
          return true
        end
        return false
      end
      return configureMission(mission, definition)
    end

    return originalCreate(self, testId)
  end

  local originalOnMissionState = controller.OnMissionState
  function controller:OnMissionState(state, mission, from, event, to)
    local definition = ph1.ActiveDefinition
    local runtime = ph1.Runtime
    if mission == ph1.ActiveMission and definition and runtime and definition.AllowObjectiveDrivenTerminal then
      if state == "DONE" then
        runtime.MissionStateSeen.DONE = true
        runtime.MissionDone = true
        runtime.MissionState = runtime.ObjectiveDrivenSuccess and "SUCCESS" or "OBJECTIVE_PENDING"
        log(string.format("TERMINAL_DONE testId=%s objectiveDrivenSuccess=%s", tostring(ph1.ActiveTestId), tostring(runtime.ObjectiveDrivenSuccess == true)))
        return
      elseif state == "FAILED" or state == "CANCELLED" then
        runtime.MissionStateSeen[state] = true
        runtime.TerminalReportedState = state
        if runtime.ObjectiveDrivenSuccess then
          runtime.MissionState = "SUCCESS"
          runtime.MissionTerminal = true
          log(string.format("TERMINAL_NORMALIZED testId=%s reported=%s accepted=OBJECTIVE_DRIVEN_SUCCESS", tostring(ph1.ActiveTestId), state))
        else
          runtime.MissionState = "OBJECTIVE_PENDING"
          runtime.MissionTerminal = false
          log(string.format("TERMINAL_DEFERRED testId=%s reported=%s waitingForPhysicalObjective=true", tostring(ph1.ActiveTestId), state))
        end
        return
      end
    end
    return originalOnMissionState(self, state, mission, from, event, to)
  end

  local function applyVerticalPreference()
    if not cfg.Airwing then return false end
    if not cfg.Airwing.SetOptionPreferVerticalLanding then
      log("ERROR: AIRWING:SetOptionPreferVerticalLanding is unavailable in pinned MOOSE.")
      cfg.VerticalHelicopterOpsEnabled = false
      return false
    end
    cfg.Airwing:SetOptionPreferVerticalLanding()
    cfg.VerticalHelicopterOpsEnabled = true
    log("AIRWING_OPTION preferVerticalTakeoffAndLanding=true taxiToRunwayAvoidance=REQUESTED")
    return true
  end

  SCHEDULER:New(nil, function()
    if not applyVerticalPreference() then
      SCHEDULER:New(nil, applyVerticalPreference, {}, 2)
    end
  end, {}, 8)

  log("READY version=JBAD-PHASE1-4 reconTerrainGate=true dedicatedUH60DropZone=true troopPickupDeliveryLifecycle=true cargoObjectiveLifecycle=true verticalTakeoffLandingPreference=true")
end
