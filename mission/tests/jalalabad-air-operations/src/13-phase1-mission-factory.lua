-- Operation Mountain Watch - MOOSE-first Phase-1 operation factory
local TAG = "[OMW][AirOps.JBAD.PH1.FACTORY]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.ManifestOK or not ph1.Observer or not ph1.Logistics then
  log("ERROR: Phase-1 dependencies unavailable.")
else
  local factory = ph1.Factory or {}
  ph1.Factory = factory

  local UH60_LANDING_RADIUS_METERS = 5
  local UH60_LANDING_CLEARANCE_METERS = 12
  local UH60_CARGO_CLEARANCE_METERS = 8
  local UH60_DESIRED_LZ_CARGO_SEPARATION_METERS = 18
  local UH60_MINIMUM_LZ_CARGO_SEPARATION_METERS = 12
  local UH60_CLEAR_POSITION_CANDIDATES = 100

  local function findZone(name)
    return name and ZONE and ZONE:FindByName(name) or nil
  end

  local function findTemplate(name)
    return name and GROUP and GROUP:FindByName(name) or nil
  end

  local function findStatic(name)
    return name and STATIC and STATIC:FindByName(name, false) or nil
  end

  local function spawnGroup(templateName, coordinate)
    if not SPAWN or not findTemplate(templateName) then return nil end
    local spawner = SPAWN:New(templateName)
    if coordinate then return spawner:SpawnFromVec2(coordinate:GetVec2()) end
    return spawner:Spawn()
  end

  local function runtimeRadiusZone(name, coordinate, radius)
    if not ZONE_RADIUS or not coordinate or not coordinate.GetVec2 then return nil end
    return ZONE_RADIUS:New(name, coordinate:GetVec2(), radius, true)
  end

  local function vec2Distance(first, second)
    if not first or not second then return nil end
    local dx = (first.x or 0) - (second.x or 0)
    local dy = (first.y or 0) - (second.y or 0)
    return math.sqrt(dx * dx + dy * dy)
  end

  local function clearPositions(zone, clearance)
    if not zone or not zone.GetClearZonePositions then
      return nil, "MOOSE ZONE_RADIUS:GetClearZonePositions unavailable"
    end
    local ok, positions = pcall(function()
      return zone:GetClearZonePositions(clearance, UH60_CLEAR_POSITION_CANDIDATES)
    end)
    if not ok then return nil, "MOOSE clear-zone search failed: " .. tostring(positions) end
    if type(positions) ~= "table" or #positions == 0 then
      return nil, string.format("no MOOSE clear position found in %s clearance=%dm", tostring(zone:GetName()), clearance)
    end
    return positions
  end

  local function nearestPosition(positions, reference)
    local selected, selectedDistance
    for _, position in ipairs(positions or {}) do
      local distance = vec2Distance(position, reference)
      if distance and (not selectedDistance or distance < selectedDistance) then
        selected, selectedDistance = position, distance
      end
    end
    return selected
  end

  local function separatedPosition(positions, reference)
    local selected, selectedDistance
    for _, position in ipairs(positions or {}) do
      local distance = vec2Distance(position, reference)
      if distance and distance >= UH60_DESIRED_LZ_CARGO_SEPARATION_METERS and
         (not selectedDistance or distance > selectedDistance) then
        selected, selectedDistance = position, distance
      end
    end
    if selected then return selected, selectedDistance end

    for _, position in ipairs(positions or {}) do
      local distance = vec2Distance(position, reference)
      if distance and distance >= UH60_MINIMUM_LZ_CARGO_SEPARATION_METERS and
         (not selectedDistance or distance > selectedDistance) then
        selected, selectedDistance = position, distance
      end
    end
    return selected, selectedDistance
  end

  local function buildTransportGeometry(zone, label)
    local landingPositions, landingError = clearPositions(zone, UH60_LANDING_CLEARANCE_METERS)
    if not landingPositions then return nil, nil, nil, landingError end

    local cargoPositions, cargoError = clearPositions(zone, UH60_CARGO_CLEARANCE_METERS)
    if not cargoPositions then return nil, nil, nil, cargoError end

    local landingVec2 = nearestPosition(landingPositions, zone:GetVec2())
    local cargoVec2, separation = separatedPosition(cargoPositions, landingVec2)
    if not landingVec2 or not cargoVec2 then
      return nil, nil, nil, string.format("no separated MOOSE clear landing/cargo positions found in %s", tostring(zone:GetName()))
    end

    local landingCoordinate = COORDINATE:NewFromVec2(landingVec2)
    local cargoCoordinate = COORDINATE:NewFromVec2(cargoVec2)
    log(string.format("MOOSE_CLEAR_GEOMETRY role=%s sourceZone=%s landingClearance=%dm cargoClearance=%dm separation=%.1fm authority=ZONE_RADIUS:GetClearZonePositions",
      tostring(label), tostring(zone:GetName()), UH60_LANDING_CLEARANCE_METERS, UH60_CARGO_CLEARANCE_METERS, separation or -1))
    return landingCoordinate, cargoCoordinate, separation
  end

  function factory:ValidateMissionEditorObjects()
    local missing = {}
    for _, zoneName in ipairs(ph1.Objects.ReconZones or {}) do
      if not findZone(zoneName) then missing[#missing + 1] = zoneName end
    end
    for _, zoneName in ipairs({ ph1.Objects.CASZone, ph1.Objects.UHLoadZone, ph1.Objects.UHUnloadZone, ph1.Objects.CH47PickupZone, ph1.Objects.CH47DropZone }) do
      if zoneName and not findZone(zoneName) then missing[#missing + 1] = zoneName end
    end
    for _, groupName in ipairs({ ph1.Objects.CASTargetTemplate, ph1.Objects.UHTroopTemplate }) do
      if groupName and not findTemplate(groupName) then missing[#missing + 1] = groupName end
    end
    if not findStatic(ph1.Objects.CH47Cargo) then missing[#missing + 1] = ph1.Objects.CH47Cargo end
    ph1.MissingMissionEditorObjects = missing
    return #missing == 0, missing
  end

  function factory:ValidateTestReady(testId, logResult)
    local baseOK, missing = self:ValidateMissionEditorObjects()
    if not baseOK then return false, "missing Mission Editor objects: " .. table.concat(missing, ",") end
    if ph1.Routing and ph1.Routing.ValidateTestReady then return ph1.Routing:ValidateTestReady(testId, logResult) end
    if logResult then log("TEST_READINESS READY testId=" .. tostring(testId) .. " routingModule=not-required") end
    return true
  end

  local function attachAuftragCallbacks(mission)
    local function state(name, from, event, to)
      if ph1.Controller and ph1.Controller.OnNativeState then
        ph1.Controller:OnNativeState("AUFTRAG", name, mission, from, event, to)
      end
    end
    function mission:OnAfterQueued(from, event, to) state("QUEUED", from, event, to) end
    function mission:OnAfterRequested(from, event, to) state("REQUESTED", from, event, to) end
    function mission:OnAfterScheduled(from, event, to) state("SCHEDULED", from, event, to) end
    function mission:OnAfterStarted(from, event, to) state("STARTED", from, event, to) end
    function mission:OnAfterExecuting(from, event, to) state("EXECUTING", from, event, to) end
    function mission:OnAfterDone(from, event, to) state("DONE", from, event, to) end
    function mission:OnAfterSuccess(from, event, to) state("SUCCESS", from, event, to) end
    function mission:OnAfterFailed(from, event, to) state("FAILED", from, event, to) end
    function mission:OnAfterCancel(from, event, to) state("CANCELLED", from, event, to) end
  end

  local function configureAuftrag(mission, definition)
    if not mission then return nil, "AUFTRAG constructor returned nil" end
    local squadron = cfg.Squadrons and cfg.Squadrons[definition.SquadronKey] or nil
    local payload = cfg.Payloads and cfg.Payloads[definition.PayloadKey] or nil
    if not squadron then return nil, "squadron unavailable: " .. tostring(definition.SquadronKey) end
    if not payload then return nil, "payload unavailable: " .. tostring(definition.PayloadKey) end

    mission:SetName("OMW-JBAD-PH1-" .. definition.Id)
    mission:SetRequiredAssets(definition.ExpectedGroups, definition.ExpectedGroups)
    mission:AssignSquadrons({ squadron })
    mission:AddRequiredPayload(payload)
    mission:SetPriority(20, true)
    mission:SetRepeat(0)
    mission:SetTime(1, definition.Timeout)
    mission:SetDuration(definition.Timeout)
    mission:SetMissionRange(definition.MissionRangeNM or 50)
    mission:SetEvaluationTime(10)
    attachAuftragCallbacks(mission)
    mission.OMWDefinition = definition
    return mission
  end

  local function createRecon(definition)
    local zones = SET_ZONE:New()
    for _, name in ipairs(ph1.Objects.ReconZones) do zones:AddZone(findZone(name)) end
    local profile = ph1.Routing and ph1.Routing.ReconProfile or nil
    local altitude = profile and profile.AltitudeFeet or 6500
    local speed = profile and profile.SpeedKnots or 80
    local mission = AUFTRAG:NewRECON(zones, speed, altitude, false, false, "Vee")
    if mission and mission.SetFormation then mission:SetFormation("Vee") end
    local zone2 = findZone(ph1.Objects.ReconZones[2])
    if mission and zone2 and mission.SetMissionEgressCoord then
      mission:SetMissionEgressCoord(zone2:GetCoordinate(), altitude, speed)
    end
    return configureAuftrag(mission, definition)
  end

  local function createCAS(definition)
    local zone = findZone(ph1.Objects.CASZone)
    local target = spawnGroup(ph1.Objects.CASTargetTemplate, zone and zone:GetCoordinate() or nil)
    if not target then return nil, "CAS target spawn failed" end
    local targetName = target:GetName()
    ph1.Runtime.CASTargetGroupName = targetName
    local mission = AUFTRAG:NewCAS(zone, 3500, 110, zone:GetCoordinate(), nil, nil, { "Ground Units" })
    mission:AddConditionSuccess(function()
      local group = GROUP:FindByName(targetName)
      return not group or not group:IsAlive()
    end)
    return configureAuftrag(mission, definition)
  end

  local function createGroupTransport(definition)
    local pickup = findZone(ph1.Objects.UHLoadZone)
    local objectiveDeploy = findZone(ph1.Objects.UHUnloadZone)
    if not pickup or not objectiveDeploy then return nil, "UH-60 pickup/deploy zone unavailable" end

    local pickupLandingCoordinate, troopCoordinate, pickupSeparation, pickupError = buildTransportGeometry(pickup, "PICKUP")
    if not pickupLandingCoordinate then return nil, pickupError end
    local deployLandingCoordinate, disembarkCoordinate, deploySeparation, deployError = buildTransportGeometry(objectiveDeploy, "DROPOFF")
    if not deployLandingCoordinate then return nil, deployError end

    local pickupLandingZone = runtimeRadiusZone("OMW_RUNTIME_UH60_PICKUP_LZ", pickupLandingCoordinate, UH60_LANDING_RADIUS_METERS)
    local deployLandingZone = runtimeRadiusZone("OMW_RUNTIME_UH60_DROPOFF_LZ", deployLandingCoordinate, UH60_LANDING_RADIUS_METERS)
    local disembarkZone = runtimeRadiusZone("OMW_RUNTIME_UH60_DISEMBARK", disembarkCoordinate, 2)
    if not pickupLandingZone or not deployLandingZone or not disembarkZone then
      return nil, "MOOSE ZONE_RADIUS construction failed for UH-60 logistics geometry"
    end

    local troops = spawnGroup(ph1.Objects.UHTroopTemplate, troopCoordinate)
    if not troops then return nil, "troop cargo spawn failed" end
    ph1.Runtime.CargoGroupName = troops:GetName()
    ph1.Runtime.CargoTemplateName = ph1.Objects.UHTroopTemplate
    ph1.Runtime.PickupLandingZone = pickupLandingZone
    ph1.Runtime.DeployLandingZone = deployLandingZone
    ph1.Runtime.DisembarkZone = disembarkZone

    -- The constructor receives the original ME zones so MOOSE can register the
    -- cargo in its pickup/deploy combination. Public OPSTRANSPORT setters then
    -- separate carrier landing zones from cargo embark/disembark zones.
    local transport, transportError = ph1.Logistics:CreateGroupTransport(definition, troops, pickup, objectiveDeploy)
    if not transport then return nil, transportError or "OPSTRANSPORT construction failed" end
    if not transport.SetPickupZone or not transport.SetDeployZone or not transport.SetEmbarkZone or not transport.SetDisembarkZone then
      return nil, "pinned MOOSE OPSTRANSPORT zone API unavailable"
    end

    transport:SetPickupZone(pickupLandingZone)
    transport:SetEmbarkZone(pickup)
    transport:SetDeployZone(deployLandingZone)
    transport:SetDisembarkZone(disembarkZone)
    if transport.OMWMetadata then
      transport.OMWMetadata.PickupZone = pickup
      transport.OMWMetadata.DeployZone = objectiveDeploy
      transport.OMWMetadata.CarrierPickupZone = pickupLandingZone
      transport.OMWMetadata.EmbarkZone = pickup
      transport.OMWMetadata.CarrierDeployZone = deployLandingZone
      transport.OMWMetadata.DisembarkZone = disembarkZone
    end

    log(string.format("GROUP_TRANSPORT_GEOMETRY pickupCarrierZone=%s pickupRadius=%.0fm pickupCargoSeparation=%.1fm deployCarrierZone=%s deployRadius=%.0fm deployCargoSeparation=%.1fm authority=OPSTRANSPORT:SetPickupZone/SetEmbarkZone/SetDeployZone/SetDisembarkZone clearAuthority=ZONE_RADIUS:GetClearZonePositions",
      pickupLandingZone:GetName(), UH60_LANDING_RADIUS_METERS, pickupSeparation or -1,
      deployLandingZone:GetName(), UH60_LANDING_RADIUS_METERS, deploySeparation or -1))
    return transport
  end

  local function createSlingCargo(definition)
    local cargo = findStatic(ph1.Objects.CH47Cargo)
    local drop = findZone(ph1.Objects.CH47DropZone)
    if not cargo or not drop then return nil, "static cargo or drop zone unavailable" end
    local cargoName = ph1.Objects.CH47Cargo
    local dropName = ph1.Objects.CH47DropZone
    local mission = AUFTRAG:NewCARGOTRANSPORT(cargo, drop)
    mission:AddConditionSuccess(function()
      local object = STATIC:FindByName(cargoName, false)
      local zone = ZONE:FindByName(dropName)
      return object and zone and object:IsInZone(zone) or false
    end)
    return configureAuftrag(mission, definition)
  end

  local function createAbort(definition)
    local zone = findZone(ph1.Objects.UHLoadZone)
    if not zone then return nil, "UH-60 abort target zone unavailable" end
    local mission = AUFTRAG:NewLANDATCOORDINATE(zone:GetCoordinate(), 0, 0, 60, 80, 1000, false)
    return configureAuftrag(mission, definition)
  end

  function factory:Create(testId)
    local definition = ph1.Tests[testId]
    if not definition then return nil, nil, "unknown test: " .. tostring(testId) end
    if definition.OperationKind == "OPSTRANSPORT" then
      local transport, err = createGroupTransport(definition)
      if not transport then return nil, nil, err end
      return "OPSTRANSPORT", transport
    end

    local mission, err
    if testId == "OH58D_RECON" then mission, err = createRecon(definition)
    elseif testId == "AH64D_CAS" then mission, err = createCAS(definition)
    elseif testId == "CH47_CARGO" then mission, err = createSlingCargo(definition)
    elseif testId == "UH60_ABORT" then mission, err = createAbort(definition)
    end
    if not mission then return nil, nil, err or "AUFTRAG construction failed" end
    return "AUFTRAG", mission
  end

  log("READY authority=AUFTRAG/OPSTRANSPORT payloadAPI=AddRequiredPayload objectives=AddConditionSuccess customObjectivePollers=false directDatabaseAccess=false UH60LandingGeometry=MOOSE_ClearZonePositions+OPSTRANSPORT_PublicZoneAPI")
end
