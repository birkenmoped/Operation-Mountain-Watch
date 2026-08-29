-- Operation Mountain Watch - Stage 2 FOB/COP perimeter-threat Acceptance 1.
-- Uses the existing Fortress rifle-squad template and authoritative Ground context.

local TEST_ID = "FOB-ATTACK-THREAT-ACCEPTANCE-1"
local INSTALLATION_ID = "BLUE_GROUND_COP_FORTRESS"
local NODE_ID = "GROUND_NODE_FORTRESS"
local PERSONNEL_RESOURCE_ID = "GROUND_PERSONNEL"
local PERSONNEL_COUNT = 9
local PRIORITY = 90
local TEMPLATE_NAME = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local WAREHOUSE_NAME = "WH_BLUE_GND_FORTRESS"
local ACCESS_ZONE_NAME = "ZON_BLUE_GND_FORTRESS_ACCESS"
local BRIGADE_NAME = "BDE_BLUE_GND_FORTRESS_STAGE2_A1"
local PLATOON_NAME = "PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A1"
local COMMITMENT_ID = "STAGE2-A1-FORTRESS-SENTRY-PERSONNEL"
local SECURITY_ZONE_NAME = "OMW_SECURITY_BLUE_GROUND_COP_FORTRESS"
local SECURITY_RADIUS_M = 1000
local SECURITY_SCAN_SECONDS = 5
local POST_START_DELAY_SEC = 5

local MissionDemand = OMW_STAGE2_MISSION_DEMAND
local DemandPolicy = OMW_STAGE2_FOB_ATTACK_DEMAND_POLICY
local ThreatAdapter = OMW_STAGE2_FOB_THREAT_OPSZONE_ADAPTER

local logger = BASE:New()
local registry = MissionDemand.New()
local state = {
  threatCount = 0,
  demandResults = {},
  passed = false,
  adapter = nil,
  brigade = nil,
  platoon = nil,
  guardMission = nil,
  guardCoordinate = nil,
  runtimeGroupName = nil,
  personnelBefore = nil,
  personnelAfterCommit = nil,
}

local function log(message)
  logger:I(string.format("[OMW][%s] %s", TEST_ID, tostring(message)))
end

local function fail(message)
  error(string.format("[OMW][%s] FAIL %s", TEST_ID, tostring(message)), 2)
end

local function requireObject(value, label)
  if not value then
    fail("missing object=" .. tostring(label))
  end
  return value
end

local function requireGroundContext()
  if type(OMW) ~= "table"
      or type(OMW.Ground) ~= "table"
      or type(OMW.Ground.Base) ~= "table"
      or type(OMW.Ground.Base.GetContext) ~= "function" then
    fail("OMW Ground Base must be loaded and attached before this acceptance bundle")
  end
  local context = OMW.Ground.Base.GetContext()
  if type(context) ~= "table" or type(context.store) ~= "table" or type(context.campaignState) ~= "table" then
    fail("OMW Ground Base has no active authoritative CampaignState context")
  end
  return context
end

local function commitFortressPersonnel()
  local context = requireGroundContext()
  local store = context.store
  local campaignState = context.campaignState
  local before = store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  if before.canonicalUnit ~= "count" or before.available < PERSONNEL_COUNT then
    fail("Fortress GROUND_PERSONNEL unavailable or wrong unit")
  end
  store:ReserveResource({
    transactionId = COMMITMENT_ID,
    reservationId = COMMITMENT_ID,
    missionDemandId = TEST_ID,
    carrierEntityId = PLATOON_NAME,
    kind = campaignState.TransactionKind.CONSUMPTION,
    resourceId = PERSONNEL_RESOURCE_ID,
    quantity = PERSONNEL_COUNT,
    canonicalUnit = "count",
    originNodeId = NODE_ID,
  })
  store:Consume(COMMITMENT_ID)
  local afterCommit = store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  if afterCommit.available ~= before.available - PERSONNEL_COUNT then
    fail("Fortress GROUND_PERSONNEL commitment mismatch")
  end
  state.personnelBefore = before.available
  state.personnelAfterCommit = afterCommit.available
  log(string.format("PERSONNEL_COMMITTED nodeId=%s quantity=%d before=%s after=%s", NODE_ID, PERSONNEL_COUNT, tostring(before.available), tostring(afterCommit.available)))
end

local observedPolicy = {}
function observedPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  local demand, created, reason = DemandPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  state.demandResults[#state.demandResults + 1] = {
    incidentId = incident.incidentId,
    demandId = demand and demand.id or nil,
    created = created,
    reason = reason,
  }
  log(string.format("DEMAND_RESULT threat=%d incidentId=%s demandId=%s created=%s reason=%s", state.threatCount, tostring(incident.incidentId), tostring(demand and demand.id), tostring(created), tostring(reason)))
  return demand, created, reason
end

local function startThreatAdapter()
  if state.adapter then return end
  state.adapter = ThreatAdapter.New({
    missionDemand = MissionDemand,
    registry = registry,
    policy = observedPolicy,
    anchorCoordinate = state.guardCoordinate,
    installationId = INSTALLATION_ID,
    zoneName = SECURITY_ZONE_NAME,
    priority = PRIORITY,
    radiusM = SECURITY_RADIUS_M,
    blueCoalition = coalition.side.BLUE,
    redCoalition = coalition.side.RED,
    updateSeconds = SECURITY_SCAN_SECONDS,
    captureThreatlevel = 0,
    captureNunits = 1,
    incidentIdFactory = function(_, sequence)
      state.threatCount = state.threatCount + 1
      local incidentId = string.format("INC-STAGE2-A1|%s|PERIMETER|%d", INSTALLATION_ID, sequence)
      log(string.format("QUALIFIED_THREAT count=%d installationId=%s zone=%s radiusM=%d evidence=OPSZONE_ATTACKED", state.threatCount, INSTALLATION_ID, SECURITY_ZONE_NAME, SECURITY_RADIUS_M))
      return incidentId
    end,
  })
  local _, started = state.adapter:Start()
  if started ~= true then fail("MOOSE OPSZONE threat adapter failed to start") end
  log(string.format("READY targetGroup=%s installationId=%s personnelCommitted=%d guardMission=ONGUARD guardSource=warehouse-coordinate securityZone=%s securityRadiusM=%d detection=OPSZONE_ATTACKED scanSeconds=%d", tostring(state.runtimeGroupName), INSTALLATION_ID, PERSONNEL_COUNT, SECURITY_ZONE_NAME, SECURITY_RADIUS_M, SECURITY_SCAN_SECONDS))
end

local function attachArmyGroupCallbacks(armyGroup)
  if armyGroup.__omwStage2A1Callbacks then return end
  armyGroup.__omwStage2A1Callbacks = true
  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if Mission ~= state.guardMission then return end
    state.runtimeGroupName = self:GetName()
    log(string.format("SENTRY_ONGUARD_EXECUTING group=%s warehouse=%s", tostring(state.runtimeGroupName), WAREHOUSE_NAME))
    startThreatAdapter()
  end
end

local function setupFortressSentry()
  local templateGroup = requireObject(GROUP:FindByName(TEMPLATE_NAME), TEMPLATE_NAME)
  local accessZone = requireObject(ZONE:FindByName(ACCESS_ZONE_NAME), ACCESS_ZONE_NAME)
  if templateGroup:GetInitialSize() ~= PERSONNEL_COUNT then fail("rifle squad template size mismatch") end

  state.brigade = requireObject(BRIGADE:New(WAREHOUSE_NAME, BRIGADE_NAME), BRIGADE_NAME)
  state.brigade:SetSpawnZone(accessZone, 1000)
  state.guardCoordinate = requireObject(state.brigade:GetCoordinate(), WAREHOUSE_NAME .. " coordinate")

  state.platoon = requireObject(PLATOON:New(TEMPLATE_NAME, 1, PLATOON_NAME), PLATOON_NAME)
  state.platoon:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
  state.brigade:AddPlatoon(state.platoon)

  state.brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
    if Mission ~= state.guardMission then return end
    if not ArmyGroup then fail("BRIGADE OnAfterArmyOnMission returned nil ARMYGROUP") end
    attachArmyGroupCallbacks(ArmyGroup)
    log(string.format("SENTRY_ON_MISSION group=%s mission=%s", tostring(ArmyGroup:GetName()), tostring(state.guardMission:GetName())))
  end

  state.brigade.OnAfterStart = function(self, From, Event, To)
    SCHEDULER:New(nil, function()
      local availableAssets = state.platoon:CountAssets(true, AUFTRAG.Type.ONGUARD)
      if availableAssets ~= 1 then fail("Fortress sentry platoon expected exactly one ONGUARD-capable asset actual=" .. tostring(availableAssets)) end
      commitFortressPersonnel()
      state.guardMission = AUFTRAG:NewONGUARD(state.guardCoordinate)
      state.guardMission:SetName("OMW_STAGE2_A1_FORTRESS_SENTRY")
      state.guardMission:SetReturnToLegion(false)
      state.brigade:AddMission(state.guardMission)
      log(string.format("SENTRY_QUEUED template=%s platoon=%s warehouse=%s guardSource=warehouse-coordinate personnel=%d", TEMPLATE_NAME, PLATOON_NAME, WAREHOUSE_NAME, PERSONNEL_COUNT))
    end, {}, POST_START_DELAY_SEC)
  end

  state.brigade:Start()
end

setupFortressSentry()

SCHEDULER:New(nil, function()
  if state.passed or state.threatCount < 1 or #state.demandResults < 1 then return end
  local active = registry:ListActive()
  local first = state.demandResults[1]
  local demand = active[1]
  local ok = #active == 1
    and first.created == true
    and first.reason == nil
    and demand ~= nil
    and demand.id == first.demandId
    and demand.missionType == MissionDemand.Type.CAS_IMMEDIATE
    and demand.origin == INSTALLATION_ID
    and demand.dedupeKey == ("CAS_IMMEDIATE|FOB_ATTACK|" .. INSTALLATION_ID)
    and state.personnelAfterCommit == state.personnelBefore - PERSONNEL_COUNT
  if not ok then fail("demand or personnel-state assertion failed") end
  state.passed = true
  log(string.format("PASS qualifiedThreats=%d activeDemands=%d demandId=%s missionType=%s installationId=%s sentryGroup=%s personnelCommitted=%d personnelBefore=%s personnelAfterCommit=%s securityRadiusM=%d detection=OPSZONE_ATTACKED", state.threatCount, #active, tostring(demand.id), tostring(demand.missionType), tostring(demand.origin), tostring(state.runtimeGroupName), PERSONNEL_COUNT, tostring(state.personnelBefore), tostring(state.personnelAfterCommit), SECURITY_RADIUS_M))
  state.adapter:Stop()
end, {}, 2, 2)
