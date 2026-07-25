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

  function factory:ValidateMissionEditorObjects()
    local missing = {}
    for _, zoneName in ipairs(ph1.Objects.ReconZones or {}) do if not findZone(zoneName) then missing[#missing + 1] = zoneName end end
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

  local function attachAuftragCallbacks(mission, definition)
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
    mission.OMWDefinition = definition
  end

  local function configureAuftrag(mission, definition)
    if not mission then return nil end
    mission:SetName("OMW JBAD PH1 " .. definition.Id)
    mission:SetRequiredAssets(definition.ExpectedGroups, definition.ExpectedGroups)
    local squadron = cfg.Squadrons and cfg.Squadrons[definition.SquadronKey] or nil
    if squadron and mission.AssignSquadrons then mission:AssignSquadrons({ squadron }) end
    local payload = cfg.Payloads and cfg.Payloads[definition.PayloadKey] or nil
    if payload and mission.SetRequiredPayloads then mission:SetRequiredPayloads({ payload }) end
    mission:SetPriority(20, true)
    if mission.SetRepeat then mission:SetRepeat(0) end
    if mission.SetTime then mission:SetTime(1) end
    if mission.SetDuration then mission:SetDuration(definition.Timeout) end
    if mission.SetMissionRange and definition.MissionRangeNM then mission:SetMissionRange(definition.MissionRangeNM) end
    if mission.SetEvaluationTime then mission:SetEvaluationTime(10) end
    attachAuftragCallbacks(mission, definition)
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
    if mission and zone2 and mission.SetMissionEgressCoord then mission:SetMissionEgressCoord(zone2:GetCoordinate(), altitude, speed) end
    return configureAuftrag(mission, definition)
  end

  local function createCAS(definition)
    local zone = findZone(ph1.Objects.CASZone)
    local target = spawnGroup(ph1.Objects.CASTargetTemplate, zone and zone:GetCoordinate() or nil)
    if not target then return nil, "CAS target spawn failed" end
    ph1.Runtime.CASTargetGroupName = target:GetName()
    local mission = AUFTRAG:NewCAS(zone, 1000, 120, zone:GetCoordinate())
    mission:AddConditionSuccess(function(groupName)
      local group = GROUP:FindByName(groupName)
      return not group or not group:IsAlive()
    end, target:GetName())
    return configureAuftrag(mission, definition)
  end

  local function createGroupTransport(definition)
    local pickup = findZone(ph1.Objects.UHLoadZone)
    local deploy = findZone(ph1.Objects.UHUnloadZone)
    local troops = spawnGroup(ph1.Objects.UHTroopTemplate, pickup and pickup:GetCoordinate() or nil)
    if not troops then return nil, "troop cargo spawn failed" end
    ph1.Runtime.CargoGroupName = troops:GetName()
    ph1.Runtime.CargoTemplateName = ph1.Objects.UHTroopTemplate
    local transport, err = ph1.Logistics:CreateGroupTransport(definition, troops, pickup, deploy)
    if not transport then return nil, err end
    return transport
  end

  local function createSlingCargo(definition)
    local cargo = findStatic(ph1.Objects.CH47Cargo)
    local drop = findZone(ph1.Objects.CH47DropZone)
    if not cargo or not drop then return nil, "static cargo or drop zone unavailable" end
    local mission = AUFTRAG:NewCARGOTRANSPORT(cargo, drop)
    mission:AddConditionSuccess(function(cargoName, zoneName)
      local object = STATIC:FindByName(cargoName, false)
      local zone = ZONE:FindByName(zoneName)
      return object and zone and object:IsInZone(zone) or false
    end, ph1.Objects.CH47Cargo, ph1.Objects.CH47DropZone)
    return configureAuftrag(mission, definition)
  end

  local function createAbort(definition)
    local zone = findZone(ph1.Objects.UHLoadZone)
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
    if testId == "OH58D_RECON" then mission = createRecon(definition)
    elseif testId == "AH64D_CAS" then mission, err = createCAS(definition)
    elseif testId == "CH47_CARGO" then mission, err = createSlingCargo(definition)
    elseif testId == "UH60_ABORT" then mission = createAbort(definition)
    end
    if not mission then return nil, nil, err or "AUFTRAG construction failed" end
    return "AUFTRAG", mission
  end

  log("READY factoryAuthority=AUFTRAG/OPSTRANSPORT objectiveConditions=AUFTRAG_AddConditionSuccess customObjectivePollers=false directDatabaseAccess=false")
end
