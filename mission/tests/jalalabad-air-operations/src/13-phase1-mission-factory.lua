-- Operation Mountain Watch - Jalalabad AIRWING Phase 1 mission factory
local TAG = "[OMW][AirOps.JBAD.PH1.FACTORY]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 then
  log("ERROR: Phase 1 manifest is unavailable.")
else
  local factory = ph1.Factory or {}
  ph1.Factory = factory

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local dx = (a.x or 0) - (b.x or 0)
    local az = a.z
    if az == nil then az = a.y or 0 end
    local bz = b.z
    if bz == nil then bz = b.y or 0 end
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function coordinateInZone(coordinate, zone)
    if not coordinate or not zone then return false end
    local radius = zone.GetRadius and zone:GetRadius() or nil
    local center = zone.GetCoordinate and zone:GetCoordinate() or nil
    local distance = distance2D(coordinate, center)
    return distance and radius and distance <= radius or false
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

  local function missionObjectsAvailable()
    local missing = {}
    for _, zoneName in ipairs(ph1.Objects.ReconZones or {}) do
      if not (ZONE and ZONE:FindByName(zoneName)) then missing[#missing + 1] = zoneName end
    end
    for _, zoneName in ipairs({
      ph1.Objects.CASZone,
      ph1.Objects.UHLoadZone,
      ph1.Objects.UHUnloadZone,
      ph1.Objects.CH47PickupZone,
      ph1.Objects.CH47DropZone
    }) do
      if zoneName and not (ZONE and ZONE:FindByName(zoneName)) then missing[#missing + 1] = zoneName end
    end

    local templateDatabase = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups or nil
    for _, groupName in ipairs({ ph1.Objects.CASTargetTemplate, ph1.Objects.UHTroopTemplate }) do
      if groupName and not (templateDatabase and templateDatabase[groupName]) then missing[#missing + 1] = groupName end
    end

    if not (STATIC and STATIC:FindByName(ph1.Objects.CH47Cargo, false)) then
      missing[#missing + 1] = ph1.Objects.CH47Cargo
    end

    ph1.MissingMissionEditorObjects = missing
    ph1.FactoryReady = #missing == 0
    if ph1.FactoryReady then
      log("ME_OBJECTS PASS reconZones=3 casZone=1 targetTemplates=2 cargo=1 loadUnloadZones=3")
    else
      log("ME_OBJECTS BLOCKED missing=" .. table.concat(missing, ","))
    end
    return ph1.FactoryReady, missing
  end

  function factory:ValidateMissionEditorObjects()
    return missionObjectsAvailable()
  end

  local function spawnCASObjective()
    ph1.Spawners.CAS = ph1.Spawners.CAS or SPAWN:New(ph1.Objects.CASTargetTemplate)
    local group = ph1.Spawners.CAS:Spawn()
    if not group then return nil, "CAS target spawn failed" end
    ph1.Runtime.CASTargetGroupName = group:GetName()
    log("OBJECTIVE spawned=CAS_TARGET group=" .. tostring(ph1.Runtime.CASTargetGroupName))
    return group
  end

  local function spawnTroops()
    ph1.Spawners.Troops = ph1.Spawners.Troops or SPAWN:New(ph1.Objects.UHTroopTemplate)
    local group = ph1.Spawners.Troops:Spawn()
    if not group then return nil, "troop group spawn failed" end
    ph1.Runtime.TroopGroupName = group:GetName()
    log("OBJECTIVE spawned=TROOPS group=" .. tostring(ph1.Runtime.TroopGroupName))
    return group
  end

  local function attachCallbacks(mission)
    function mission:OnAfterQueued(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("QUEUED", self, from, event, to) end
    end
    function mission:OnAfterRequested(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("REQUESTED", self, from, event, to) end
    end
    function mission:OnAfterScheduled(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("SCHEDULED", self, from, event, to) end
    end
    function mission:OnAfterStarted(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("STARTED", self, from, event, to) end
    end
    function mission:OnAfterExecuting(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("EXECUTING", self, from, event, to) end
    end
    function mission:OnAfterDone(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("DONE", self, from, event, to) end
    end
    function mission:OnAfterSuccess(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("SUCCESS", self, from, event, to) end
    end
    function mission:OnAfterFailed(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("FAILED", self, from, event, to) end
    end
    function mission:OnAfterCancel(from, event, to)
      if ph1.Controller then ph1.Controller:OnMissionState("CANCELLED", self, from, event, to) end
    end
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
    mission:SetMissionRange(50)
    mission:SetEvaluationTime(5)
    attachCallbacks(mission)
    return mission
  end

  local function createRecon(definition)
    local zoneSet = SET_ZONE:New()
    for _, zoneName in ipairs(ph1.Objects.ReconZones) do
      zoneSet:AddZone(ZONE:FindByName(zoneName))
    end
    local mission = AUFTRAG:NewRECON(zoneSet, 90, 4000, false, false, "Vee")
    ph1.Runtime.ObjectiveCheck = function()
      return ph1.Runtime.MissionState == "SUCCESS"
    end
    return configureMission(mission, definition)
  end

  local function createCAS(definition)
    local target, spawnError = spawnCASObjective()
    if not target then return nil, spawnError end
    local zone = ZONE:FindByName(ph1.Objects.CASZone)
    local mission = AUFTRAG:NewCAS(zone, 3500, 110, zone:GetCoordinate(), nil, nil, { "Ground Units" })
    mission:AddConditionSuccess(function()
      local group = GROUP:FindByName(ph1.Runtime.CASTargetGroupName)
      return not group or not group:IsAlive()
    end)
    ph1.Runtime.ObjectiveCheck = function()
      local group = GROUP:FindByName(ph1.Runtime.CASTargetGroupName)
      return not group or not group:IsAlive()
    end
    return configureMission(mission, definition)
  end

  local function createTroopTransport(definition)
    local troops, spawnError = spawnTroops()
    if not troops then return nil, spawnError end
    local loadZone = ZONE:FindByName(ph1.Objects.UHLoadZone)
    local unloadZone = ZONE:FindByName(ph1.Objects.UHUnloadZone)
    local mission = AUFTRAG:NewTROOPTRANSPORT(troops, unloadZone:GetCoordinate(), loadZone:GetCoordinate(), math.max(100, loadZone:GetRadius()))
    if not definition.AbortOnBirth then
      mission:AddConditionSuccess(function()
        return groupInZone(ph1.Runtime.TroopGroupName, unloadZone)
      end)
    end
    ph1.Runtime.ObjectiveCheck = function()
      return groupInZone(ph1.Runtime.TroopGroupName, unloadZone)
    end
    return configureMission(mission, definition)
  end

  local function createCargoTransport(definition)
    local cargo = STATIC:FindByName(ph1.Objects.CH47Cargo, false)
    local pickupZone = ZONE:FindByName(ph1.Objects.CH47PickupZone)
    local dropZone = ZONE:FindByName(ph1.Objects.CH47DropZone)
    if not cargo then return nil, "CH-47 cargo static unavailable" end
    if staticInZone(ph1.Objects.CH47Cargo, dropZone) then
      return nil, "CH-47 cargo is already inside the drop zone; restart the mission"
    end
    if not staticInZone(ph1.Objects.CH47Cargo, pickupZone) then
      return nil, "CH-47 cargo is outside the required pickup zone"
    end
    local mission = AUFTRAG:NewCARGOTRANSPORT(cargo, dropZone)
    mission:AddConditionSuccess(function()
      return staticInZone(ph1.Objects.CH47Cargo, dropZone)
    end)
    ph1.Runtime.ObjectiveCheck = function()
      return staticInZone(ph1.Objects.CH47Cargo, dropZone)
    end
    return configureMission(mission, definition)
  end

  function factory:Create(testId)
    local definition = ph1.Tests[testId]
    if not definition then return nil, "unknown test: " .. tostring(testId) end
    local ready = self:ValidateMissionEditorObjects()
    if not ready then return nil, "required Mission Editor objects are missing" end
    if not AUFTRAG or not SPAWN or not SET_ZONE then return nil, "required MOOSE classes are unavailable" end

    if testId == "OH58D_RECON" then
      return createRecon(definition)
    elseif testId == "AH64D_CAS" then
      return createCAS(definition)
    elseif testId == "UH60_TROOP" or testId == "UH60_ABORT" then
      return createTroopTransport(definition)
    elseif testId == "CH47_CARGO" then
      return createCargoTransport(definition)
    end
    return nil, "no factory for test: " .. tostring(testId)
  end

  log("READY constructors=RECON,CAS,TROOPTRANSPORT,CARGOTRANSPORT restrictions=Squadron+Payload+ExactRequiredAssetCount")
end
