local function buildPerimeters()
  local alarm=state.site.alarm
  if type(alarm)~="table" or alarm.anchorKind~="WAREHOUSE" or type(alarm.radiusM)~="number" then return nil,"HONAKER_ALARM_CONFIG_INVALID" end
  local anchor=state.brigade:GetCoordinate(); if not anchor then return nil,"HONAKER_WAREHOUSE_COORDINATE_UNAVAILABLE" end
  return {[SITE_ID]={anchorCoordinate=anchor,zoneName="OMW_SECURITY_"..state.site.installationId,radiusM=alarm.radiusM,priority=0}},nil
end
local function setupProductionRuntime()
  state.package=OMW and OMW.FireSupStratResupply or nil
  if type(state.package)~="table" then fail("FSSR production package unavailable"); return false end
  state.site=state.package.SiteRegistry.Sites[SITE_ID]; if type(state.site)~="table" then fail("COP_HONAKER missing from FSSR SiteRegistry"); return false end
  if state.site.alarm.radiusM~=2743.2 then fail("Honaker production alarm radius must be 2743.2 m"); return false end
  state.brigade=BRIGADE:New(state.site.warehouseName,"BDE_FSSR_STAGE3_A2_"..SITE_ID)
  local guard=PLATOON:New(state.site.guardTemplateName,1,"PLT_FSSR_STAGE3_A2_GUARD_"..SITE_ID)
  local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_STAGE3_A2_QRF_"..SITE_ID)
  guard:AddMissionCapability(AUFTRAG.Type.ONGUARD,100); qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  state.brigade:AddPlatoon(guard); state.brigade:AddPlatoon(qrf)
  local previousArmy=state.brigade.OnAfterArmyOnMission
  function state.brigade:OnAfterArmyOnMission(From,Event,To,armyGroup,mission)
    if previousArmy then previousArmy(self,From,Event,To,armyGroup,mission) end
    local group=armyGroup and armyGroup:GetGroup() or nil; if not group then return end
    local attribute=group:GetAttribute()
    if attribute==GROUP.Attribute.GROUND_INFANTRY then
      if not activeSourceIncident() then fail("GUARD_MATERIALIZED_BEFORE_ALARM"); return end
      state.guardArmy=armyGroup; state.guardGroup=group
      local oldReturned=armyGroup.OnAfterReturned
      function armyGroup:OnAfterReturned(F,E,T) if oldReturned then oldReturned(self,F,E,T) end; state.guardReturned=true end
      log("GUARD_MATERIALIZED missionType="..tostring(mission and mission:GetType()))
    elseif attribute==GROUP.Attribute.GROUND_APC then
      state.qrfArmy=armyGroup; state.qrfGroup=group
      local oldEngage=armyGroup.OnAfterEngageTarget
      function armyGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
        if oldEngage then oldEngage(self,F,E,T,Target,Speed,Formation) end
        state.qrfEngaged=true; log("QRF_ENGAGE target="..tostring(Target and Target.GetName and Target:GetName() or "unknown").." formation="..tostring(Formation))
      end
      local oldReturned=armyGroup.OnAfterReturned
      function armyGroup:OnAfterReturned(F,E,T) if oldReturned then oldReturned(self,F,E,T) end; state.qrfReturned=true end
      log("QRF_MATERIALIZED missionType="..tostring(mission and mission:GetType()))
    end
  end
  local focused={SchemaVersion=state.package.SiteRegistry.SchemaVersion,GuardTemplateName=state.package.SiteRegistry.GuardTemplateName,Sites={[SITE_ID]=state.site}}
  local perimeters,reason=buildPerimeters(); if not perimeters then fail(reason); return false end
  local runtime,prepared,prepareReason=state.package.New({
    siteRegistry=focused,brigades={[SITE_ID]=state.brigade},
    resolveGuardPathline=function(name) return PATHLINE:FindByName(name) end,
    resolveGuardTemplateGroup=function(name) return GROUP:FindByName(name) end,
    guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
    resolveQrfCoordinate=function(_,ctx)
      local inc=ctx and ctx.incident; local physical=inc and inc.context and inc.context.physicalTargetGroup
      if not physical then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
      return physical,nil
    end,
    qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
    externalAdapters={
      ARTY={Dispatch=function(_,demand,ctx) return dispatchStage3Arty(demand,ctx) end},
      CAS={Dispatch=function(_,demand,ctx) return dispatchStage3Cas(demand,ctx) end},
    },
    blueCoalition=coalition.side.BLUE,redCoalition=coalition.side.RED,perimeters=perimeters,logger=log,
  }):Prepare()
  if prepared==false and prepareReason~="ALREADY_PREPARED" then fail("FSSR runtime prepare failed: "..tostring(prepareReason)); return false end
  state.runtime=runtime; state.base=runtime:GetBase()
  local states,started,startReason=runtime:StartPerimeters(); if started~=true then fail("perimeter start failed: "..tostring(startReason)); return false end
  state.perimeterState=states[SITE_ID]
  local _,siteStarted,siteReason=runtime:StartSite(SITE_ID,{})
  if siteStarted~=true and siteReason~="ALREADY_STARTED" then fail("site start failed: "..tostring(siteReason)); return false end
  return true
end
local function startC2Observation()
  local center=state.brigade:GetCoordinate()
  state.c2FireObservationZone=ZONE_RADIUS:New("OMW_C2_FIRE_OBSERVATION_STAGE3_A2",center:GetVec2(),UTILS.NMToMeters(C2_FIRE_OBSERVATION_RADIUS_NM))
  state.c2FireObservationOpsZone=OPSZONE:New(state.c2FireObservationZone,coalition.side.BLUE)
  state.c2FireObservationOpsZone:SetObjectCategories({Object.Category.UNIT})
  state.c2FireObservationOpsZone:SetUnitCategories({Unit.Category.GROUND_UNIT})
  state.c2FireObservationOpsZone:SetCaptureThreatlevel(0); state.c2FireObservationOpsZone:SetCaptureNunits(1)
  state.c2FireObservationOpsZone:SetDrawZone(false); state.c2FireObservationOpsZone:SetMarkZone(false); state.c2FireObservationOpsZone.UpdateSeconds=5
  state.c2FireObservationOpsZone:Start()
end
local function activateFixture()
  local fixture=GROUP:FindByName(RED_FIXTURE); if not fixture then return false,"FIXTURE_GROUP_MISSING" end
  if fixture:IsAlive()~=true then fixture:Activate() end
  state.fixtureStart=fixture:GetCoordinate(); if not state.fixtureStart then return false,"FIXTURE_COORDINATE_UNAVAILABLE" end
  state.fixtureActivated=true; log("FIXTURE_ACTIVATE routeSource=MISSION_EDITOR routeOverride=false"); return true,nil
end
local function requestC2SupportIfReady()
  if not state.baseIncidentId then return end
  if not state.artyBaseDemand and #c2FireObservationGroups()>0 then
    local demand,created,reason=state.base:RequestIncidentSupport(state.baseIncidentId,"ARTY",{requestKey="STAGE3_C2_ARTY",priority=90,cancelWhenIncidentClosed=false,context={allocation="ACCEPTANCE_DETERMINISTIC_WRIGHT"}})
    if not demand or demand.status=="NOT_DISPATCHED" then fail("FSSR ARTY C2 request failed: "..tostring(reason)); return end
    state.artyBaseDemand=demand
  end
  if not state.casBaseDemand and state.airwing and state.ah64d then
    local demand,created,reason=state.base:RequestIncidentSupport(state.baseIncidentId,"CAS",{requestKey="STAGE3_C2_CAS",priority=90,cancelWhenIncidentClosed=false,context={allocation="ACCEPTANCE_DETERMINISTIC_JALALABAD_AH64D"}})
    if not demand or demand.status=="NOT_DISPATCHED" then failCas("FSSR CAS C2 request failed: "..tostring(reason)); return end
    state.casBaseDemand=demand
  end
end
local function closeIncidentIfReady()
  if state.incidentClosed then return end
  local c=sourceCoordinator(); local active=c and c:GetActive() or nil
  if not active or c:HasAliveParticipants()==true then return end
  local closed,changed,reason=state.runtime:CloseInstallationIncident(state.site.installationId,"HONAKER_NO_KNOWN_ATTACKERS")
  if changed~=true or not closed then fail("authoritative incident close failed: "..tostring(reason)); return end
  state.incidentClosed=true; state.honakerNoKnownAttackers=true
  log("AUTHORITATIVE_CLOSE_REQUESTED zeroLivingParticipants=true")
end
local function dispatchFollowOnFire()
  if state.fireCycleActive or not state.rearmComplete or state.casOnStation or not state.sourceIncident then return false end
  state.fireScheduledSourceGroups={}; local target=selectNextFireTarget(); if not target then return false end
  local nextCycle=state.fireCycleNumber+1; local p=target:GetCoordinate():GetVec3()
  local synthetic={incidentId=state.fireDemand and state.fireDemand.target and state.fireDemand.target.incidentId or state.baseIncidentId,installationId=state.site.installationId,priority=90}
  local demand,created,reason=FirePolicy.CreateDemand(MissionDemand,registry,synthetic,{targetKind="DETECTED_RED_GROUND_GROUP",targetName=target:GetName(),position={x=p.x,y=p.y,z=p.z},cycleKey="REARMED-"..tostring(nextCycle)})
  if created~=true then return false end
  local _,dispatched=state.fireAdapter:Dispatch(demand,target); if dispatched~=true then return false end
  state.fireDemands[#state.fireDemands+1]=demand.id; state.fireCycleNumber=nextCycle; state.fireCycleActive=true; state.fireTargetCount=state.fireTargetCount+1; state.fireScheduledSourceGroups[target:GetName()]=true
  log("FIRE_SUPPORT_REARMED_CONTINUATION cycle="..tostring(nextCycle).." sourceGroup="..target:GetName()); return true
end

local function observe()
  if state.passed or not state.runtime then return end
  local elapsed=timer.getTime()-state.startedAt
  if not state.fixtureActivated and elapsed>=STARTUP_NO_GUARD_WINDOW_SEC then
    local siteState=state.base:GetSite(SITE_ID)
    if state.guardArmy or (siteState and siteState.guardDemandId) then fail("PRE_ALARM_GUARD_PRESENT"); return end
    state.preAlarmNoGuard=true
    local ok,reason=activateFixture(); if not ok then fail(reason); return end
  end
  local fixture=GROUP:FindByName(RED_FIXTURE)
  if state.fixtureActivated and fixture and fixture:IsAlive()==true and state.fixtureStart then
    local c=fixture:GetCoordinate(); if c then state.fixtureMove=math.max(state.fixtureMove,state.fixtureStart:Get2DDistance(c)) end
  end
  resolveBaseDemands()
  requestC2SupportIfReady()
  closeIncidentIfReady()
  updateCasSupportState()
  if state.rearmComplete and state.fireComplete and not state.fireCycleActive and not state.casOnStation then dispatchFollowOnFire() end

  if state.incidentClosed then
    if not state.guardDemand or state.guardDemand.status~="CANCEL_REQUESTED" then return end
    if state.qrfDemand and state.qrfDemand.status=="CANCEL_REQUESTED" then fail("INCIDENT_CLOSE_CANCELLED_QRF"); return end
  end
  local casTerminal=state.casFailed or (state.casExecuting and state.casCorridor and state.casClosed and (state.casFired or state.casNoContactReported)
    and state.casRecoveryRequested and state.casHomeLanded and state.casAssetReturned)
  if state.failed then return end
  if state.preAlarmNoGuard and state.fixtureMove>=MIN_FIXTURE_MOVE_M and state.sourceIncident and state.guardDemand and state.qrfDemand
      and state.guardArmy and state.qrfArmy and state.incidentClosed and state.guardReturned and state.qrfReturned and state.artyBaseDemand and state.casBaseDemand
      and state.fireStarted and state.fireComplete and state.rearmComplete and state.supportReturned and state.resupply
      and state.inTransit and state.delivered and state.airCorridor and state.cargoReturnInstalled and state.homeLanded and state.assetReturned and casTerminal then
    if state.casFailed then fail("CAS subsystem failed: "..tostring(state.casFailureReason)); return end
    local ctx=context(); local w=ctx.store:GetResource(WRIGHT_NODE,AMMO_RESOURCE); local j=ctx.store:GetResource(JALALABAD_NODE,AMMO_RESOURCE)
    local rd=registry:Get(RESUPPLY_DEMAND_ID)
    if not w or w.quantity~=30 then fail("Wright final AMMO not 30"); return end
    if not j or j.quantity~=85 then fail("Jalalabad final AMMO not 85"); return end
    if not rd or rd.status~=MissionDemand.Status.SUCCESS then fail("RESUPPLY demand not SUCCESS"); return end
    if state.firePhysicalShotsTotal<1 then fail("Wright L118 lacks physical EVENTS.Shot evidence"); return end
    state.passed=true
    if state.finishScheduler and type(state.finishScheduler.Stop)=="function" then state.finishScheduler:Stop() end
    msg("PASS",string.format("Reconciled full response complete: production alarm/Guard/QRF + generic C2 ARTY/CAS demands + deterministic Wright/Jalalabad providers + M1083 rearm + CH-47 OPSTRANSPORT; Wright 30/30; fireMissions=%d",state.fireTargetCount),40)
    log("PASS guardReturned="..tostring(state.guardReturned).." qrfEngaged="..tostring(state.qrfEngaged).." qrfReturned="..tostring(state.qrfReturned).." casFired="..tostring(state.casFired).." casNoContact="..tostring(state.casNoContactReported))
    return
  end
  if elapsed>TEST_TIMEOUT_SEC then fail("TIMEOUT_INCOMPLETE_RECONCILED_FULL_RESPONSE") end
end

local function start()
  if OMW_GROUND_READY~=1 then fail("Ground Base not ready"); return end
  need(GROUP:FindByName(GUARD_TEMPLATE),GUARD_TEMPLATE); need(GROUP:FindByName(QRF_TEMPLATE),QRF_TEMPLATE); need(GROUP:FindByName(RED_FIXTURE),RED_FIXTURE)
  if not context() then return end
  if not resolveConfiguredFlightPath() then return end
  if not prepareAirwing() then fail("Jalalabad AIRWING/AH64D/CH47 foundation unavailable"); return end
  installAirObserver()
  if not preconditionWright() then return end
  if not setupFireSupport() then return end
  if not setupProductionRuntime() then return end
  startC2Observation()
  state.startedAt=timer.getTime()
  msg("READY","Stage 3 Acceptance 2 armed: production FSSR alarm/Guard/QRF; C2 support demands use deterministic Wright/Jalalabad test providers",18)
end

SCHEDULER:New(nil,start,{},5)
state.finishScheduler=SCHEDULER:New(nil,observe,{},10,5)
