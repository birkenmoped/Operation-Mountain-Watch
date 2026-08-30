-- Operation Mountain Watch - Stage 2B FOB/COP automatic-response Acceptance 2.
-- MOOSE-first end-to-end proof for Fortress threat, rotary CAS, local infantry
-- counterattack, native return-to-origin, personnel settlement and reorder check.

local TEST_ID = "FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2"
local INSTALLATION_ID = "BLUE_GROUND_COP_FORTRESS"
local NODE_ID = "GROUND_NODE_FORTRESS"
local PERSONNEL_RESOURCE_ID = "GROUND_PERSONNEL"
local PERSONNEL_RESERVE_FLOOR = 80
local GUARD_PERSONNEL = 9
local QRF_PERSONNEL = 9
local PRIORITY = 90
local TEMPLATE_NAME = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local WAREHOUSE_NAME = "WH_BLUE_GND_FORTRESS"
local EXPECTED_HOMEZONE_NAME = "Warehouse WH_BLUE_GND_FORTRESS spawn zone"
local BRIGADE_NAME = "BDE_BLUE_GND_FORTRESS_STAGE2_A2"
local GUARD_PLATOON_NAME = "PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A2"
local QRF_PLATOON_NAME = "PLT_BLUE_GND_FORTRESS_QRF_STAGE2_A2"
local GUARD_DEPLOYMENT_ID = "STAGE2-A2-FORTRESS-GUARD-PERSONNEL"
local QRF_DEPLOYMENT_ID = "STAGE2-A2-FORTRESS-QRF-PERSONNEL"
local SECURITY_ZONE_NAME = "OMW_SECURITY_BLUE_GROUND_COP_FORTRESS_A2"
local SECURITY_RADIUS_M = 1000
local SECURITY_SCAN_SECONDS = 5
local CAS_ASSIGNEE_ID = "AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV"
local CAS_ALTITUDE_FT = 10000
local CAS_SPEED_KTS = 120
local CAS_SQUADRON_NAME = "SQ_US_JBAD_AH64D_B_1_10_AVN"
local CORRIDOR_PATHLINE_NAME = "OMW_FlightPath"
local CORRIDOR_ALTITUDE_FT_AGL = 500
local ROUTE_RETRY_SEC = 2
local ROUTE_RETRY_MAX = 5
local POST_START_DELAY_SEC = 5

local MissionDemand = OMW_STAGE2B_MISSION_DEMAND
local DemandPolicy = OMW_STAGE2B_FOB_ATTACK_DEMAND_POLICY
local ThreatAdapter = OMW_STAGE2B_FOB_THREAT_OPSZONE_ADAPTER
local CasDispatchAdapter = OMW_STAGE2B_FOB_ATTACK_CAS_DISPATCH_ADAPTER
local PersonnelLedger = OMW_STAGE2B_GROUND_PERSONNEL_DEPLOYMENT_LEDGER
local ResourceDemandPolicy = OMW_STAGE2B_RESOURCE_DEMAND_POLICY
local ResourceDemandCoordinator = OMW_STAGE2B_RESOURCE_DEMAND_COORDINATOR
local HelicopterCorridor = OMW_STAGE2B_HELICOPTER_FLIGHTPATH_CORRIDOR

local logger = BASE:New()
local registry = MissionDemand.New()
local state = {
  threatCount=0, dispatchCount=0, passed=false,
  threatAdapter=nil, dispatchAdapter=nil,
  brigade=nil, guardPlatoon=nil, qrfPlatoon=nil,
  guardMission=nil, qrfMission=nil, guardArmy=nil, qrfArmy=nil,
  guardDeployment=nil, qrfDeployment=nil,
  guardSettled=false, qrfSettled=false,
  guardCasualties=nil, qrfCasualties=nil,
  guardCoordinate=nil,
  guardNativeRtz=false, qrfNativeRtz=false,
  guardReturned=false, qrfReturned=false,
  casMission=nil, casFlightGroup=nil, casExecuting=false,
  casClosureRequested=false, casRtb=false, casLanded=false, casArrived=false,
  corridorInstalled=false, routeAttempts=0,
  qrfExecuting=false, threatCleared=false,
  personnelInitialQuantity=nil, personnelInitialAvailable=nil,
  personnelAfterGuardReserve=nil, personnelAfterQrfReserve=nil,
  reorderEvaluated=false, resupplyDemand=nil,
}

local function log(message) logger:I(string.format("[OMW][%s] %s", TEST_ID, tostring(message))) end
local function fail(message) error(string.format("[OMW][%s] FAIL %s", TEST_ID, tostring(message)), 2) end
local function requireObject(value, label) if not value then fail("missing object=" .. tostring(label)) end return value end

local function requireGroundContext()
  if type(OMW) ~= "table" or type(OMW.Ground) ~= "table" or type(OMW.Ground.Base) ~= "table"
      or type(OMW.Ground.Base.GetContext) ~= "function" or type(OMW.Ground.Base.GetInitialStock) ~= "function" then
    fail("OMW Ground Base must be loaded and attached before this acceptance bundle")
  end
  local context = OMW.Ground.Base.GetContext()
  if type(context) ~= "table" or type(context.store) ~= "table" or type(context.campaignState) ~= "table" then
    fail("OMW Ground Base has no active authoritative CampaignState context")
  end
  return context
end

local function requireJalalabadAirwing()
  local airOps = OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(airOps) ~= "table" or airOps.Status ~= "RUNNING" or not airOps.Airwing then
    fail("existing OMW Jalalabad AIRWING foundation must be RUNNING")
  end
  if type(airOps.Squadrons) ~= "table" or not airOps.Squadrons.AH64D then
    fail("existing Jalalabad AH64D CAS squadron is unavailable")
  end
  return airOps.Airwing, airOps.Squadrons.AH64D
end

local function findFortressPersonnelRow()
  for _, row in ipairs(OMW.Ground.Base.GetInitialStock().Rows or {}) do
    if row.nodeId == NODE_ID and row.resourceId == PERSONNEL_RESOURCE_ID then return row end
  end
  fail("Fortress GROUND_PERSONNEL stock row not found")
end

local function reserveDeployment(deploymentId, entityId, quantity)
  local context = requireGroundContext()
  local before = context.store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  if before.available - quantity < PERSONNEL_RESERVE_FLOOR then
    fail(string.format("DEFENCE_RESERVE_FLOOR_VIOLATION available=%s requested=%s floor=%s", tostring(before.available), tostring(quantity), tostring(PERSONNEL_RESERVE_FLOOR)))
  end
  local deployment = PersonnelLedger.New({
    store=context.store, campaignState=context.campaignState,
    nodeId=NODE_ID, resourceId=PERSONNEL_RESOURCE_ID,
    deploymentId=deploymentId, entityId=entityId, quantity=quantity,
    missionDemandId=TEST_ID,
  })
  local after = context.store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  if after.quantity ~= before.quantity or after.available ~= before.available - quantity then
    fail("PERSONNEL_DEPLOYMENT_RESERVATION_MISMATCH")
  end
  log(string.format("PERSONNEL_RESERVED deploymentId=%s entityId=%s quantity=%d strategicQuantity=%s availableBefore=%s availableAfter=%s reserveFloor=%d",
    deploymentId, entityId, quantity, tostring(after.quantity), tostring(before.available), tostring(after.available), PERSONNEL_RESERVE_FLOOR))
  return deployment, before, after
end

local function evaluatePersonnelReorder()
  if not state.guardSettled or not state.qrfSettled or state.reorderEvaluated then return end
  state.reorderEvaluated=true
  local context=requireGroundContext()
  local row=findFortressPersonnelRow()
  local demand, created, reason, candidate=ResourceDemandCoordinator.EvaluateAndCreate({
    policy=ResourceDemandPolicy, missionDemand=MissionDemand, registry=registry,
    store=context.store, row=row,
    demandIdFactory=function(shortage, snapshot)
      return string.format("RESUPPLY|POST-COMBAT|%s|%s|%s", NODE_ID, PERSONNEL_RESOURCE_ID, tostring(snapshot.quantity))
    end,
  })
  state.resupplyDemand=demand
  local snapshot=context.store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  log(string.format("PERSONNEL_REORDER_EVALUATED quantity=%s available=%s reorder=%s comparison=%s shortage=%s demandId=%s created=%s reason=%s",
    tostring(snapshot.quantity), tostring(snapshot.available), tostring(row.reorder), tostring(row.reorderComparison),
    tostring(candidate ~= nil), tostring(demand and demand.id), tostring(created), tostring(reason)))
end

local function settleDeployment(kind, armyGroup)
  local isGuard=kind=="GUARD"
  if isGuard and state.guardSettled then return end
  if (not isGuard) and state.qrfSettled then return end
  local deployment=isGuard and state.guardDeployment or state.qrfDeployment
  if not deployment then fail(kind .. " deployment ledger missing") end
  local survivors=0
  if armyGroup and type(armyGroup.GetNelements)=="function" then survivors=armyGroup:GetNelements() end
  local result, changed=deployment:SettleReturned(survivors)
  if changed ~= true then return end
  if isGuard then
    state.guardSettled=true; state.guardCasualties=result.casualties
  else
    state.qrfSettled=true; state.qrfCasualties=result.casualties
  end
  log(string.format("%s_PERSONNEL_SETTLED survivors=%d casualties=%d quantity=%s available=%s",
    kind, result.survivors, result.casualties, tostring(result.snapshot.quantity), tostring(result.snapshot.available)))
  evaluatePersonnelReorder()
end

local function closeGroundMission(kind, armyGroup, mission)
  if armyGroup and type(armyGroup.GetNelements)=="function" and armyGroup:GetNelements() <= 0 then
    settleDeployment(kind, armyGroup)
    return
  end
  if not mission then
    log(kind .. "_MISSION_CLOSE_SKIPPED mission=nil")
    return
  end
  if type(mission.IsNotOver)=="function" and mission:IsNotOver() and type(mission.Cancel)=="function" then
    mission:Cancel()
    log(string.format("%s_MISSION_CLOSE_REQUESTED mission=%s returnController=MOOSE_RETURN_TO_LEGION explicitRTZ=false",
      kind, tostring(mission:GetName())))
  else
    log(string.format("%s_MISSION_ALREADY_OVER mission=%s returnController=MOOSE_RETURN_TO_LEGION explicitRTZ=false",
      kind, tostring(mission:GetName())))
  end
end

local function attachGroundLifecycle(kind, armyGroup, mission)
  local marker="__omwStage2B" .. kind
  if armyGroup[marker] then return end
  armyGroup[marker]=true

  local previousExecute=armyGroup.OnAfterMissionExecute
  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if previousExecute then previousExecute(self, From, Event, To, Mission) end
    if Mission ~= mission then return end
    if kind=="GUARD" then
      log(string.format("SENTRY_ONGUARD_EXECUTING group=%s warehouse=%s", tostring(self:GetName()), WAREHOUSE_NAME))
      if not state.threatAdapter then state.startThreatAndDispatch() end
    else
      state.qrfExecuting=true
      log(string.format("QRF_GROUNDATTACK_EXECUTING group=%s mission=%s", tostring(self:GetName()), tostring(mission:GetName())))
    end
  end

  local previousRtz=armyGroup.OnAfterRTZ
  function armyGroup:OnAfterRTZ(From, Event, To, Zone, Formation)
    if previousRtz then previousRtz(self, From, Event, To, Zone, Formation) end
    if not Zone then fail(kind .. " native RTZ zone is nil") end
    local zoneName=Zone:GetName()
    if zoneName~=EXPECTED_HOMEZONE_NAME then
      fail(string.format("%s native RTZ wrong origin zone expected=%s actual=%s", kind, EXPECTED_HOMEZONE_NAME, tostring(zoneName)))
    end
    if kind=="GUARD" then state.guardNativeRtz=true else state.qrfNativeRtz=true end
    log(string.format("%s_NATIVE_RTZ_ACTIVE group=%s zone=%s source=ORIGIN_LEGION_SPAWNZONE",
      kind, tostring(self:GetName()), tostring(zoneName)))
  end

  local previousReturned=armyGroup.OnAfterReturned
  function armyGroup:OnAfterReturned(From, Event, To)
    if previousReturned then previousReturned(self, From, Event, To) end
    if kind=="GUARD" then state.guardReturned=true else state.qrfReturned=true end
    log(string.format("%s_RETURNED_ORIGIN group=%s warehouse=%s homezone=%s",
      kind, tostring(self:GetName()), WAREHOUSE_NAME, EXPECTED_HOMEZONE_NAME))
    settleDeployment(kind, self)
  end

  local previousDead=armyGroup.OnAfterDead
  function armyGroup:OnAfterDead(From, Event, To)
    if previousDead then previousDead(self, From, Event, To) end
    log(string.format("%s_GROUP_DEAD group=%s", kind, tostring(self:GetName())))
    settleDeployment(kind, self)
  end
end

local function findRedThreatGroup(opsZone)
  local set=opsZone:GetScannedGroupSet()
  for _, group in pairs(set:GetSet()) do
    if group and group:IsAlive() and group:GetCoalition()==coalition.side.RED then return group end
  end
  return nil
end

local function dispatchQrf(opsZone)
  if state.qrfMission then return end
  local target=findRedThreatGroup(opsZone)
  if not target then fail("MOOSE OPSZONE has no alive RED threat group for QRF GROUNDATTACK") end

  local deployment, _, after=reserveDeployment(QRF_DEPLOYMENT_ID, QRF_PLATOON_NAME, QRF_PERSONNEL)
  state.qrfDeployment=deployment
  state.personnelAfterQrfReserve=after.available

  state.qrfMission=AUFTRAG:NewGROUNDATTACK(target, 8, ENUMS.Formation.Vehicle.OffRoad)
  state.qrfMission:SetName("OMW_STAGE2_A2_FORTRESS_QRF_COUNTERATTACK")
  state.brigade:AddMission(state.qrfMission)
  log(string.format("QRF_QUEUED targetGroup=%s personnel=%d reserveFloor=%d mission=GROUNDATTACK returnToLegion=MOOSE_DEFAULT_TRUE",
    tostring(target:GetName()), QRF_PERSONNEL, PERSONNEL_RESERVE_FLOOR))
end

local function installCorridorWithRetry(flightGroup, mission)
  if state.corridorInstalled then return end
  state.routeAttempts=state.routeAttempts+1
  local resolved=HelicopterCorridor.Resolve({
    pathlineName=CORRIDOR_PATHLINE_NAME,
    originCoordinate=flightGroup:GetCoordinate(),
    destinationCoordinate=state.threatAdapter.securityZone:GetCoordinate(),
  })
  local installed, ok, reason=HelicopterCorridor.Install(flightGroup, mission, resolved, CORRIDOR_ALTITUDE_FT_AGL)
  if ok then
    state.corridorInstalled=true
    log(string.format("CAS_CORRIDOR_INSTALLED group=%s pathline=%s corridorPoints=%d outboundWaypoints=%d returnWaypoints=%d altitudeFtAGL=%d",
      tostring(flightGroup:GetName()), resolved.pathlineName, resolved.corridorPointCount,
      installed.outboundWaypointCount, installed.returnWaypointCount, installed.altitudeFtAgl))
    return
  end
  if reason=="MISSION_ROUTE_UIDS_NOT_READY" and state.routeAttempts < ROUTE_RETRY_MAX then
    SCHEDULER:New(nil, function() installCorridorWithRetry(flightGroup, mission) end, {}, ROUTE_RETRY_SEC)
    return
  end
  fail("CAS_CORRIDOR_INSTALL_FAILED reason=" .. tostring(reason))
end

local function attachCasExecutionObserver(mission)
  local previousExecuting=mission.OnAfterExecuting
  function mission:OnAfterExecuting(From, Event, To)
    if previousExecuting then previousExecuting(self, From, Event, To) end
    state.casExecuting=true
    local demand=registry:Get(state.demandId)
    log(string.format("CAS_EXECUTING demandId=%s mission=%s demandStatus=%s", tostring(state.demandId), tostring(self:GetName()), tostring(demand and demand.status)))
  end
end

local function installAirwingObserver(airwing)
  if airwing.__omwStage2A2Observer then return end
  airwing.__omwStage2A2Observer=true
  local previousFlightOnMission=airwing.OnAfterFlightOnMission
  function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if Mission ~= state.casMission then return end
    state.casFlightGroup=FlightGroup
    log(string.format("CAS_FLIGHT_ON_MISSION demandId=%s group=%s mission=%s", tostring(state.demandId), tostring(FlightGroup:GetName()), tostring(Mission:GetName())))

    local previousRtb=FlightGroup.OnAfterRTB
    function FlightGroup:OnAfterRTB(FFrom, FEvent, FTo, Airbase, SpeedTo, SpeedHold, SpeedLand)
      if previousRtb then previousRtb(self, FFrom, FEvent, FTo, Airbase, SpeedTo, SpeedHold, SpeedLand) end
      state.casRtb=true
      log(string.format("CAS_RTB group=%s airbase=%s", tostring(self:GetName()), tostring(Airbase and Airbase:GetName())))
    end
    local previousLanded=FlightGroup.OnAfterLanded
    function FlightGroup:OnAfterLanded(FFrom, FEvent, FTo, Airbase)
      if previousLanded then previousLanded(self, FFrom, FEvent, FTo, Airbase) end
      state.casLanded=true
      log(string.format("CAS_LANDED group=%s airbase=%s", tostring(self:GetName()), tostring(Airbase and Airbase:GetName())))
    end
    local previousArrived=FlightGroup.OnAfterArrived
    function FlightGroup:OnAfterArrived(FFrom, FEvent, FTo)
      if previousArrived then previousArrived(self, FFrom, FEvent, FTo) end
      state.casArrived=true
      log(string.format("CAS_ARRIVED group=%s airwingAssetReturn=MOOSE_FLIGHTGROUP", tostring(self:GetName())))
    end

    SCHEDULER:New(nil, function() installCorridorWithRetry(FlightGroup, Mission) end, {}, ROUTE_RETRY_SEC)
  end
end

local observedPolicy={}
function observedPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  local demand, created, reason=DemandPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  log(string.format("DEMAND_RESULT incidentId=%s demandId=%s created=%s reason=%s", tostring(incident.incidentId), tostring(demand and demand.id), tostring(created), tostring(reason)))
  if created==true then
    state.demandId=demand.id
    local mission, dispatched, dispatchReason=state.dispatchAdapter:Dispatch(demand, state.threatAdapter.securityZone)
    if dispatched~=true then fail("CAS dispatch failed reason=" .. tostring(dispatchReason)) end
    state.dispatchCount=state.dispatchCount+1
    state.casMission=mission
    attachCasExecutionObserver(mission)
    log(string.format("CAS_DISPATCHED demandId=%s mission=%s assignee=%s altitudeFt=%d speedKts=%d", tostring(demand.id), tostring(mission:GetName()), CAS_ASSIGNEE_ID, CAS_ALTITUDE_FT, CAS_SPEED_KTS))
  end
  return demand, created, reason
end

function state.startThreatAndDispatch()
  local airwing, ah64Squadron=requireJalalabadAirwing()
  local availableCasAssets=ah64Squadron:CountAssets(true, AUFTRAG.Type.CAS)
  if availableCasAssets < 1 then fail("Jalalabad AH64D squadron has no available CAS-capable assets") end
  installAirwingObserver(airwing)
  state.dispatchAdapter=CasDispatchAdapter.New({
    missionDemand=MissionDemand, registry=registry, airwing=airwing, assigneeId=CAS_ASSIGNEE_ID,
    casAltitudeFt=CAS_ALTITUDE_FT, casSpeedKts=CAS_SPEED_KTS,
  })
  state.threatAdapter=ThreatAdapter.New({
    missionDemand=MissionDemand, registry=registry, policy=observedPolicy,
    anchorCoordinate=state.guardCoordinate, installationId=INSTALLATION_ID, zoneName=SECURITY_ZONE_NAME,
    priority=PRIORITY, radiusM=SECURITY_RADIUS_M, blueCoalition=coalition.side.BLUE, redCoalition=coalition.side.RED,
    updateSeconds=SECURITY_SCAN_SECONDS, captureThreatlevel=0, captureNunits=1,
    incidentIdFactory=function(_, sequence)
      state.threatCount=state.threatCount+1
      local incidentId=string.format("INC-STAGE2-A2|%s|PERIMETER|%d", INSTALLATION_ID, sequence)
      log(string.format("QUALIFIED_THREAT count=%d installationId=%s zone=%s evidence=OPSZONE_ATTACKED", state.threatCount, INSTALLATION_ID, SECURITY_ZONE_NAME))
      return incidentId
    end,
    onThreatStarted=function(_, opsZone)
      dispatchQrf(opsZone)
    end,
    onThreatCleared=function()
      if state.threatCleared then return end
      state.threatCleared=true
      log("THREAT_CLEARED evidence=OPSZONE_DEFEATED_RED")
      if state.demandId then
        local _, requested, reason=state.dispatchAdapter:RequestMissionClosure(state.demandId, "OPSZONE_DEFEATED_RED")
        state.casClosureRequested=requested==true or reason=="CLOSURE_ALREADY_REQUESTED"
        log(string.format("CAS_MISSION_CLOSURE requested=%s reason=%s", tostring(requested), tostring(reason)))
      end
      closeGroundMission("QRF", state.qrfArmy, state.qrfMission)
      closeGroundMission("GUARD", state.guardArmy, state.guardMission)
    end,
  })
  local _, started=state.threatAdapter:Start()
  if started~=true then fail("MOOSE OPSZONE threat adapter failed to start") end
  log(string.format("READY sentryGroup=%s installationId=%s securityRadiusM=%d detection=OPSZONE_ATTACKED scanSeconds=%d casAirwing=%s casSquadron=%s casAvailableAssets=%s corridor=%s groundReturn=MOOSE_NATIVE_ORIGIN_HOMEZONE",
    tostring(state.guardArmy and state.guardArmy:GetName()), INSTALLATION_ID, SECURITY_RADIUS_M, SECURITY_SCAN_SECONDS,
    CAS_ASSIGNEE_ID, CAS_SQUADRON_NAME, tostring(availableCasAssets), CORRIDOR_PATHLINE_NAME))
end

local function setupFortressDefence()
  local templateGroup=requireObject(GROUP:FindByName(TEMPLATE_NAME), TEMPLATE_NAME)
  if templateGroup:GetInitialSize()~=GUARD_PERSONNEL then fail("rifle squad template size mismatch") end
  local context=requireGroundContext()
  local initial=context.store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  state.personnelInitialQuantity=initial.quantity
  state.personnelInitialAvailable=initial.available

  state.brigade=requireObject(BRIGADE:New(WAREHOUSE_NAME, BRIGADE_NAME), BRIGADE_NAME)
  state.guardCoordinate=requireObject(state.brigade:GetCoordinate(), WAREHOUSE_NAME .. " coordinate")

  state.guardPlatoon=requireObject(PLATOON:New(TEMPLATE_NAME, 1, GUARD_PLATOON_NAME), GUARD_PLATOON_NAME)
  state.guardPlatoon:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
  state.brigade:AddPlatoon(state.guardPlatoon)
  state.qrfPlatoon=requireObject(PLATOON:New(TEMPLATE_NAME, 1, QRF_PLATOON_NAME), QRF_PLATOON_NAME)
  state.qrfPlatoon:AddMissionCapability(AUFTRAG.Type.GROUNDATTACK, 100)
  state.brigade:AddPlatoon(state.qrfPlatoon)

  state.brigade.OnAfterArmyOnMission=function(self, From, Event, To, ArmyGroup, Mission)
    if not ArmyGroup then fail("BRIGADE OnAfterArmyOnMission returned nil ARMYGROUP") end
    if Mission==state.guardMission then
      state.guardArmy=ArmyGroup
      attachGroundLifecycle("GUARD", ArmyGroup, Mission)
      log(string.format("SENTRY_ON_MISSION group=%s mission=%s", tostring(ArmyGroup:GetName()), tostring(Mission:GetName())))
    elseif Mission==state.qrfMission then
      state.qrfArmy=ArmyGroup
      attachGroundLifecycle("QRF", ArmyGroup, Mission)
      log(string.format("QRF_ON_MISSION group=%s mission=%s", tostring(ArmyGroup:GetName()), tostring(Mission:GetName())))
    end
  end

  state.brigade.OnAfterStart=function()
    SCHEDULER:New(nil, function()
      if state.guardPlatoon:CountAssets(true, AUFTRAG.Type.ONGUARD)~=1 then fail("expected one ONGUARD-capable guard asset") end
      if state.qrfPlatoon:CountAssets(true, AUFTRAG.Type.GROUNDATTACK)~=1 then fail("expected one GROUNDATTACK-capable QRF asset") end
      local deployment, _, after=reserveDeployment(GUARD_DEPLOYMENT_ID, GUARD_PLATOON_NAME, GUARD_PERSONNEL)
      state.guardDeployment=deployment
      state.personnelAfterGuardReserve=after.available
      state.guardMission=AUFTRAG:NewONGUARD(state.guardCoordinate)
      state.guardMission:SetName("OMW_STAGE2_A2_FORTRESS_SENTRY")
      state.brigade:AddMission(state.guardMission)
      log(string.format("SENTRY_QUEUED template=%s platoon=%s warehouse=%s personnel=%d accounting=RESERVED_NOT_CONSUMED spawnZoneOverride=false returnToLegion=MOOSE_DEFAULT_TRUE",
        TEMPLATE_NAME, GUARD_PLATOON_NAME, WAREHOUSE_NAME, GUARD_PERSONNEL))
    end, {}, POST_START_DELAY_SEC)
  end
  state.brigade:Start()
end

setupFortressDefence()

SCHEDULER:New(nil, function()
  if state.passed then return end
  if not (state.threatCleared and state.casClosureRequested and state.casExecuting and state.casRtb and state.casLanded and state.casArrived
      and state.corridorInstalled and state.qrfExecuting and state.guardNativeRtz and state.qrfNativeRtz
      and state.guardReturned and state.qrfReturned and state.guardSettled and state.qrfSettled and state.reorderEvaluated) then return end

  local demand=registry:Get(state.demandId)
  local personnel=requireGroundContext().store:GetResource(NODE_ID, PERSONNEL_RESOURCE_ID)
  if not demand or demand.status~=MissionDemand.Status.SUCCESS then fail("CAS MissionDemand did not reach SUCCESS") end
  if state.dispatchCount~=1 then fail("expected exactly one CAS dispatch") end
  if state.personnelAfterGuardReserve ~= state.personnelInitialAvailable-GUARD_PERSONNEL then fail("guard reservation accounting mismatch") end
  if state.personnelAfterQrfReserve ~= state.personnelInitialAvailable-GUARD_PERSONNEL-QRF_PERSONNEL then fail("QRF reservation accounting mismatch") end
  if state.personnelAfterQrfReserve < PERSONNEL_RESERVE_FLOOR then fail("defence reserve floor violated") end
  local expectedQuantity=state.personnelInitialQuantity-(state.guardCasualties or 0)-(state.qrfCasualties or 0)
  if personnel.quantity~=expectedQuantity then fail("post-combat personnel quantity mismatch") end

  state.passed=true
  log(string.format("PASS qualifiedThreats=%d dispatches=%d demandId=%s demandStatus=%s casFlight=%s corridor=%s threatClear=OPSZONE_DEFEATED_RED casRTB=%s casLanded=%s casArrived=%s qrfMission=GROUNDATTACK guardNativeRtz=%s qrfNativeRtz=%s guardReturned=%s qrfReturned=%s homezone=%s guardCasualties=%s qrfCasualties=%s personnelInitialQuantity=%s personnelInitialAvailable=%s personnelFinal=%s availableFinal=%s defenceReserveFloor=%d resupplyDemand=%s",
    state.threatCount, state.dispatchCount, tostring(demand.id), tostring(demand.status), tostring(state.casFlightGroup and state.casFlightGroup:GetName()),
    CORRIDOR_PATHLINE_NAME, tostring(state.casRtb), tostring(state.casLanded), tostring(state.casArrived),
    tostring(state.guardNativeRtz), tostring(state.qrfNativeRtz), tostring(state.guardReturned), tostring(state.qrfReturned), EXPECTED_HOMEZONE_NAME,
    tostring(state.guardCasualties), tostring(state.qrfCasualties), tostring(state.personnelInitialQuantity), tostring(state.personnelInitialAvailable),
    tostring(personnel.quantity), tostring(personnel.available), PERSONNEL_RESERVE_FLOOR, tostring(state.resupplyDemand and state.resupplyDemand.id)))
  state.threatAdapter:Stop()
end, {}, 2, 2)
