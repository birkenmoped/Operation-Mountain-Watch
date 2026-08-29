-- Operation Mountain Watch - Stage 2B FOB/COP threat -> real MOOSE CAS execution Acceptance 2.
-- Reuses the Stage-2A Fortress threat path and the already running Jalalabad AIRWING foundation.

local TEST_ID = "FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2"
local INSTALLATION_ID = "BLUE_GROUND_COP_FORTRESS"
local NODE_ID = "GROUND_NODE_FORTRESS"
local PERSONNEL_RESOURCE_ID = "GROUND_PERSONNEL"
local PERSONNEL_COUNT = 9
local PRIORITY = 90
local TEMPLATE_NAME = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local WAREHOUSE_NAME = "WH_BLUE_GND_FORTRESS"
local ACCESS_ZONE_NAME = "ZON_BLUE_GND_FORTRESS_ACCESS"
local BRIGADE_NAME = "BDE_BLUE_GND_FORTRESS_STAGE2_A2"
local PLATOON_NAME = "PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A2"
local COMMITMENT_ID = "STAGE2-A2-FORTRESS-SENTRY-PERSONNEL"
local SECURITY_ZONE_NAME = "OMW_SECURITY_BLUE_GROUND_COP_FORTRESS_A2"
local SECURITY_RADIUS_M = 1000
local SECURITY_SCAN_SECONDS = 5
local CAS_ASSIGNEE_ID = "AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV"
local CAS_ALTITUDE_FT = 10000
local CAS_SPEED_KTS = 120
local POST_START_DELAY_SEC = 5

local MissionDemand = OMW_STAGE2B_MISSION_DEMAND
local DemandPolicy = OMW_STAGE2B_FOB_ATTACK_DEMAND_POLICY
local ThreatAdapter = OMW_STAGE2B_FOB_THREAT_OPSZONE_ADAPTER
local CasDispatchAdapter = OMW_STAGE2B_FOB_ATTACK_CAS_DISPATCH_ADAPTER

local logger = BASE:New()
local registry = MissionDemand.New()
local state = {
  threatCount = 0,
  dispatchCount = 0,
  passed = false,
  threatAdapter = nil,
  dispatchAdapter = nil,
  brigade = nil,
  platoon = nil,
  guardMission = nil,
  guardCoordinate = nil,
  sentryGroupName = nil,
  casMission = nil,
  casFlightGroup = nil,
  casExecuting = false,
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

local function requireJalalabadAirwing()
  local stateAirOps = OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(stateAirOps) ~= "table" or stateAirOps.Status ~= "RUNNING" or not stateAirOps.Airwing then
    fail("existing OMW Jalalabad AIRWING foundation must be RUNNING before Stage 2B acceptance")
  end
  if type(stateAirOps.Squadrons) ~= "table" or not stateAirOps.Squadrons.AH64D then
    fail("existing Jalalabad AH64D CAS squadron is unavailable")
  end
  return stateAirOps.Airwing, stateAirOps.Squadrons.AH64D
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

local function attachCasExecutionObserver(mission)
  local previousExecuting = mission.OnAfterExecuting
  function mission:OnAfterExecuting(From, Event, To)
    if previousExecuting then
      previousExecuting(self, From, Event, To)
    end
    state.casExecuting = true
    local demand = registry:ListActive()[1] or registry:Get(state.demandId)
    log(string.format("CAS_EXECUTING demandId=%s mission=%s demandStatus=%s", tostring(state.demandId), tostring(self:GetName()), tostring(demand and demand.status)))
  end
end

local function installAirwingObserver(airwing)
  if airwing.__omwStage2A2Observer then return end
  airwing.__omwStage2A2Observer = true
  local previousFlightOnMission = airwing.OnAfterFlightOnMission
  function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then
      previousFlightOnMission(self, From, Event, To, FlightGroup, Mission)
    end
    if Mission ~= state.casMission then return end
    state.casFlightGroup = FlightGroup
    log(string.format("CAS_FLIGHT_ON_MISSION demandId=%s group=%s mission=%s", tostring(state.demandId), tostring(FlightGroup and FlightGroup:GetName()), tostring(Mission:GetName())))
  end
end

local observedPolicy = {}
function observedPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  local demand, created, reason = DemandPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  log(string.format("DEMAND_RESULT incidentId=%s demandId=%s created=%s reason=%s", tostring(incident.incidentId), tostring(demand and demand.id), tostring(created), tostring(reason)))

  if created == true then
    state.demandId = demand.id
    local mission, dispatched, dispatchReason = state.dispatchAdapter:Dispatch(demand, state.threatAdapter.securityZone)
    if dispatched ~= true then
      fail("CAS dispatch failed reason=" .. tostring(dispatchReason))
    end
    state.dispatchCount = state.dispatchCount + 1
    state.casMission = mission
    attachCasExecutionObserver(mission)
    log(string.format("CAS_DISPATCHED demandId=%s mission=%s assignee=%s altitudeFt=%d speedKts=%d", tostring(demand.id), tostring(mission:GetName()), CAS_ASSIGNEE_ID, CAS_ALTITUDE_FT, CAS_SPEED_KTS))
  end

  return demand, created, reason
end

local function startThreatAndDispatch()
  if state.threatAdapter then return end

  local airwing, ah64Squadron = requireJalalabadAirwing()
  local availableCasAssets = ah64Squadron:CountAssets(true, AUFTRAG.Type.CAS)
  if availableCasAssets < 1 then
    fail("Jalalabad AH64D squadron has no available CAS-capable assets")
  end

  installAirwingObserver(airwing)
  state.dispatchAdapter = CasDispatchAdapter.New({
    missionDemand = MissionDemand,
    registry = registry,
    airwing = airwing,
    assigneeId = CAS_ASSIGNEE_ID,
    casAltitudeFt = CAS_ALTITUDE_FT,
    casSpeedKts = CAS_SPEED_KTS,
  })

  state.threatAdapter = ThreatAdapter.New({
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
      local incidentId = string.format("INC-STAGE2-A2|%s|PERIMETER|%d", INSTALLATION_ID, sequence)
      log(string.format("QUALIFIED_THREAT count=%d installationId=%s zone=%s evidence=OPSZONE_ATTACKED", state.threatCount, INSTALLATION_ID, SECURITY_ZONE_NAME))
      return incidentId
    end,
  })

  local _, started = state.threatAdapter:Start()
  if started ~= true then fail("MOOSE OPSZONE threat adapter failed to start") end
  log(string.format("READY sentryGroup=%s installationId=%s securityRadiusM=%d detection=OPSZONE_ATTACKED scanSeconds=%d casAirwing=%s casSquadron=%s casAvailableAssets=%s", tostring(state.sentryGroupName), INSTALLATION_ID, SECURITY_RADIUS_M, SECURITY_SCAN_SECONDS, CAS_ASSIGNEE_ID, "SQ_US_JBAD_AH64D_B_1_10_AVN", tostring(availableCasAssets)))
end

local function attachArmyGroupCallbacks(armyGroup)
  if armyGroup.__omwStage2A2Callbacks then return end
  armyGroup.__omwStage2A2Callbacks = true
  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if Mission ~= state.guardMission then return end
    state.sentryGroupName = self:GetName()
    log(string.format("SENTRY_ONGUARD_EXECUTING group=%s warehouse=%s", tostring(state.sentryGroupName), WAREHOUSE_NAME))
    startThreatAndDispatch()
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
      state.guardMission:SetName("OMW_STAGE2_A2_FORTRESS_SENTRY")
      state.guardMission:SetReturnToLegion(false)
      state.brigade:AddMission(state.guardMission)
      log(string.format("SENTRY_QUEUED template=%s platoon=%s warehouse=%s personnel=%d", TEMPLATE_NAME, PLATOON_NAME, WAREHOUSE_NAME, PERSONNEL_COUNT))
    end, {}, POST_START_DELAY_SEC)
  end

  state.brigade:Start()
end

setupFortressSentry()

SCHEDULER:New(nil, function()
  if state.passed or not state.casExecuting or not state.casFlightGroup or not state.demandId then return end

  local demand = registry:Get(state.demandId)
  local acceptableStatus = demand and (demand.status == MissionDemand.Status.ACTIVE or demand.status == MissionDemand.Status.SUCCESS)
  local ok = state.threatCount >= 1
    and state.dispatchCount == 1
    and state.casMission ~= nil
    and acceptableStatus
    and demand.assignedTo == CAS_ASSIGNEE_ID
    and state.personnelAfterCommit == state.personnelBefore - PERSONNEL_COUNT

  if not ok then fail("Stage 2B demand/dispatch/execution assertion failed") end

  state.passed = true
  log(string.format("PASS qualifiedThreats=%d dispatches=%d demandId=%s demandStatus=%s casMission=%s casFlightGroup=%s assignee=%s personnelBefore=%s personnelAfterCommit=%s", state.threatCount, state.dispatchCount, tostring(demand.id), tostring(demand.status), tostring(state.casMission:GetName()), tostring(state.casFlightGroup:GetName()), CAS_ASSIGNEE_ID, tostring(state.personnelBefore), tostring(state.personnelAfterCommit)))
  state.threatAdapter:Stop()
end, {}, 2, 2)
