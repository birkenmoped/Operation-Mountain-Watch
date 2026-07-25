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
    local altitude = definition.FlightAltitudeFeet
    local speed = definition.FlightSpeedKnots
    if not altitude or not speed then return nil, "OH-58 fixed flight altitude/speed unavailable" end

    -- The outbound profile already behaved correctly in DCS. Keep its explicit
    -- altitude and speed unchanged. Routing:ConfigureMission applies the same
    -- values to the MOOSE egress waypoint; no terrain-derived recovery altitude.
    local mission = AUFTRAG:NewRECON(zones, speed, altitude, false, false)
    if mission then
      mission.OMWIngressAltitudeFeet = altitude
      mission.OMWIngressSpeedKnots = speed
    end
    return configureAuftrag(mission, definition)
  end

  local function createCAS(definition)
    local zone = findZone(ph1.Objects.CASZone)
    local target = spawnGroup(ph1.Objects.CASTargetTemplate, zone and zone:GetCoordinate() or nil)
    if not target then return nil, "CAS target spawn failed" end
    local targetName = target:GetName()
    ph1.Runtime.CASTargetGroupName = targetName
    local altitude = definition.FlightAltitudeFeet
    local speed = definition.FlightSpeedKnots
    if not altitude or not speed then return nil, "AH-64 fixed flight altitude/speed unavailable" end

    -- Preserve the successful outbound CAS profile. The same altitude and speed
    -- are reused by Routing:ConfigureMission for egress and return transit.
    local mission = AUFTRAG:NewCAS(zone, altitude, speed, zone:GetCoordinate(), nil, nil, { "Ground Units" })
    mission.OMWIngressAltitudeFeet = altitude
    mission.OMWIngressSpeedKnots = speed
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

    -- The Mission Editor fixture already defines the safe geometry:
    -- * the pickup-zone centre is the clear helicopter landing point;
    -- * the troop template is positioned near the pickup-zone edge;
    -- * the deploy-zone centre is the clear destination landing point.
    -- Small MOOSE runtime zones constrain only the carrier landing positions.
    local pickupLandingZone = runtimeRadiusZone(
      "OMW_RUNTIME_UH60_PICKUP_LZ",
      pickup:GetCoordinate(),
      UH60_LANDING_RADIUS_METERS)
    local deployLandingZone = runtimeRadiusZone(
      "OMW_RUNTIME_UH60_DROPOFF_LZ",
      objectiveDeploy:GetCoordinate(),
      UH60_LANDING_RADIUS_METERS)
    if not pickupLandingZone or not deployLandingZone then
      return nil, "MOOSE ZONE_RADIUS construction failed for UH-60 carrier landing zones"
    end

    -- Spawn at the template's authored Mission Editor position. This preserves
    -- the intentional separation between infantry and the pickup-zone centre.
    local troops = spawnGroup(ph1.Objects.UHTroopTemplate)
    if not troops then return nil, "troop cargo spawn failed" end
    ph1.Runtime.CargoGroupName = troops:GetName()
    ph1.Runtime.CargoTemplateName = ph1.Objects.UHTroopTemplate
    ph1.Runtime.PickupLandingZone = pickupLandingZone
    ph1.Runtime.DeployLandingZone = deployLandingZone
    ph1.Runtime.DisembarkZone = objectiveDeploy

    -- The constructor receives the original Mission Editor zones so MOOSE can
    -- register the cargo transport combination. Public OPSTRANSPORT setters
    -- then separate carrier landing zones from cargo handling zones.
    local transport, transportError = ph1.Logistics:CreateGroupTransport(definition, troops, pickup, objectiveDeploy)
    if not transport then return nil, transportError or "OPSTRANSPORT construction failed" end
    if not transport.SetPickupZone or not transport.SetDeployZone or not transport.SetEmbarkZone or not transport.SetDisembarkZone then
      return nil, "pinned MOOSE OPSTRANSPORT zone API unavailable"
    end

    transport:SetPickupZone(pickupLandingZone)
    transport:SetEmbarkZone(pickup)
    transport:SetDeployZone(deployLandingZone)
    transport:SetDisembarkZone(objectiveDeploy)
    if transport.OMWMetadata then
      transport.OMWMetadata.PickupZone = pickup
      transport.OMWMetadata.DeployZone = objectiveDeploy
      transport.OMWMetadata.CarrierPickupZone = pickupLandingZone
      transport.OMWMetadata.EmbarkZone = pickup
      transport.OMWMetadata.CarrierDeployZone = deployLandingZone
      transport.OMWMetadata.DisembarkZone = objectiveDeploy
    end

    log(string.format("GROUP_TRANSPORT_GEOMETRY pickupCarrierZone=%s pickupRadius=%.0fm pickupCarrierPosition=ME_ZONE_CENTER troopPosition=ME_TEMPLATE deployCarrierZone=%s deployRadius=%.0fm deployCarrierPosition=ME_ZONE_CENTER disembarkZone=%s authority=OPSTRANSPORT:SetPickupZone/SetEmbarkZone/SetDeployZone/SetDisembarkZone",
      pickupLandingZone:GetName(), UH60_LANDING_RADIUS_METERS,
      deployLandingZone:GetName(), UH60_LANDING_RADIUS_METERS,
      objectiveDeploy:GetName()))
    return transport
  end

  local function bindMooseSlingCargoTaskParameters(mission)
    -- MOOSE 73d3ed1 creates a ComboTask containing the native DCS
    -- CargoTransportation task, but NewCARGOTRANSPORT writes groupId/zoneId
    -- to the outer ComboTask params. DCS executes the inner task, so copy the
    -- already MOOSE-derived values into that task without replacing AUFTRAG.
    local combo = mission and mission.DCStask or nil
    local comboParams = combo and combo.params or nil
    local tasks = comboParams and comboParams.tasks or nil
    if not combo or combo.id ~= "ComboTask" or type(tasks) ~= "table" then
      return false, "MOOSE CARGOTRANSPORT ComboTask unavailable"
    end

    local cargoTask = nil
    for _, task in ipairs(tasks) do
      if task and task.id == "CargoTransportation" then
        cargoTask = task
        break
      end
    end
    if not cargoTask then return false, "MOOSE CargoTransportation task unavailable" end
    if comboParams.groupId == nil or comboParams.zoneId == nil then
      return false, "MOOSE CARGOTRANSPORT groupId/zoneId unavailable"
    end

    cargoTask.params = cargoTask.params or {}
    cargoTask.params.groupId = comboParams.groupId
    cargoTask.params.zoneId = comboParams.zoneId
    log(string.format("CARGOTRANSPORT_TASK_BOUND authority=AUFTRAG:NewCARGOTRANSPORT adapter=INNER_DCS_TASK_PARAMETERS groupId=%s zoneId=%s outerTask=%s innerTask=%s",
      tostring(cargoTask.params.groupId), tostring(cargoTask.params.zoneId), tostring(combo.id), tostring(cargoTask.id)))
    return true
  end

  local function createSlingCargo(definition)
    local cargo = findStatic(ph1.Objects.CH47Cargo)
    local drop = findZone(ph1.Objects.CH47DropZone)
    if not cargo or not drop then return nil, "static cargo or drop zone unavailable" end
    local cargoName = ph1.Objects.CH47Cargo
    local dropName = ph1.Objects.CH47DropZone
    local mission = AUFTRAG:NewCARGOTRANSPORT(cargo, drop)
    if not mission then return nil, "AUFTRAG:NewCARGOTRANSPORT returned nil" end
    local taskBound, taskError = bindMooseSlingCargoTaskParameters(mission)
    if not taskBound then return nil, taskError end
    mission:AddConditionSuccess(function()
      local object = STATIC:FindByName(cargoName, false)
      local zone = ZONE:FindByName(dropName)
      local satisfied = object and zone and object:IsInZone(zone) or false
      if satisfied and ph1.Runtime and ph1.ActiveDefinition == definition then
        ph1.Runtime.ObjectiveSatisfied = true
        if not ph1.Runtime.SlingObjectiveLogged then
          ph1.Runtime.SlingObjectiveLogged = true
          log(string.format("SLING_CARGO_OBJECTIVE PASS testId=%s cargo=%s zone=%s evidence=STATIC:IsInZone latched=true",
            tostring(definition.Id), tostring(cargoName), tostring(dropName)))
        end
      end
      return satisfied
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

  log("READY authority=AUFTRAG/OPSTRANSPORT payloadAPI=AddRequiredPayload objectives=AddConditionSuccess customObjectivePollers=false directDatabaseAccess=false UH60LandingGeometry=ME_AuthoredCenters+OPSTRANSPORT_PublicZoneAPI CH47SlingTaskAdapter=INNER_DCS_TASK_PARAMETERS CH47ObjectiveLatch=STATIC_IN_ZONE reconFormation=ROUTING_CONFIGURED rotorIngressAltitude=FIXED rotorReturnAltitude=MATCH_INGRESS terrainAltitudeCalculation=false")
end
