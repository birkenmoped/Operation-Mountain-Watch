-- Operation Mountain Watch - Production Base Acceptance 5.
-- Joyce-focused acceptance for the incident-local Guard redesign.
--
-- New contract under test:
--   no physical Guard before alarm
--   -> physical RED intrusion is qualified by the MOOSE OPSZONE scan
--   -> PROXIMITY_INTRUSION / installation incident
--   -> one incident-local GUARD demand plus the existing initial QRF demand
--   -> Guard materializes locally on MOOSE ONGUARD and does not receive a patrol route
--   -> once the authoritative incident has zero living participants, the acceptance
--      invokes the production CloseInstallationIncident() API as an explicit closure
--      stimulus for this test only
--   -> incident close cancels Guard, not QRF
--   -> Guard returns through the MOOSE RTZ / Returned lifecycle.
--
-- The harness does not inject evidence, rewrite the RED fixture route, select QRF
-- targets, cancel any demand directly, or implement a Guard patrol/engagement loop.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A5]"
local SITE_ID="FOB_JOYCE"
local FIXTURE_NAME="BadGuys_A3_JOYCE"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local STARTUP_NO_GUARD_WINDOW_SEC=20
local MIN_FIXTURE_MOVE_M=25
local TEST_TIMEOUT_SEC=900
local TELEMETRY_SEC=5

local state={
  failed=false,passed=false,runtime=nil,brigade=nil,perimeter=nil,perimeterState=nil,
  startedAt=nil,fixtureActivated=false,fixtureStart=nil,fixtureMove=0,
  preAlarmNoGuard=false,alarmObserved=false,proximityObserved=false,
  guard=nil,guardArmy=nil,guardMissionType=nil,guardInsidePerimeter=false,
  guardRtzObserved=false,guardReturnedObserved=false,
  qrf=nil,qrfArmy=nil,
  baseIncidentId=nil,guardDemand=nil,qrfDemand=nil,
  fixtureCleared=false,closeRequested=false,closeReason=nil,
}

local function log(message) env.info(TAG.." "..tostring(message),false) end
local function announce(kind,message,time)
  local text="[PRODUCTION BASE A5]["..kind.."] "..message
  log(text)
  MESSAGE:New(text,time or 10):ToAll()
end
local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  announce("FAIL",message,30)
end

local function package()
  return OMW and OMW.FireSupStratResupply or nil
end

local function site()
  local p=package()
  return p and p.SiteRegistry and p.SiteRegistry.Sites[SITE_ID] or nil
end

local function coordinator()
  local s=site()
  local runtime=state.runtime and state.runtime.installationIncidentRuntime or nil
  return s and runtime and runtime:GetCoordinator(s.installationId) or nil
end

local function activeIncident()
  local c=coordinator()
  return c and c:GetActive() or nil
end

local function hasProximityEvidence(active)
  for _,evidence in ipairs((active and active.evidence) or {}) do
    if evidence.evidenceType=="PROXIMITY_INTRUSION" then return true end
  end
  return false
end

local function buildBrigade(p)
  local s=p.SiteRegistry.Sites[SITE_ID]
  local brigade=BRIGADE:New(s.warehouseName,"BDE_FSSR_A5_"..SITE_ID)
  local guard=PLATOON:New(s.guardTemplateName,1,"PLT_FSSR_A5_GUARD_"..SITE_ID)
  local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A5_QRF_"..SITE_ID)
  guard:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  brigade:AddPlatoon(guard)
  brigade:AddPlatoon(qrf)

  brigade.OnAfterArmyOnMission=function(self,From,Event,To,armyGroup,mission)
    local group=armyGroup and armyGroup:GetGroup() or nil
    if not group then return end
    local attribute=group:GetAttribute()
    log("ARMY_ON_MISSION group="..tostring(group:GetName()).." attribute="..tostring(attribute).." missionType="..tostring(mission and mission:GetType()))

    if attribute==GROUP.Attribute.GROUND_INFANTRY then
      if not state.alarmObserved then fail("GUARD_MATERIALIZED_BEFORE_ALARM"); return end
      if state.guardArmy and state.guardArmy~=armyGroup then fail("DUPLICATE_GUARD_ARMYGROUP"); return end
      state.guardArmy=armyGroup
      state.guard=group
      state.guardMissionType=mission and mission:GetType() or nil
      local zone=state.perimeterState and state.perimeterState.securityZone or nil
      local coordinate=group:GetCoordinate()
      state.guardInsidePerimeter=zone~=nil and coordinate~=nil and zone:IsCoordinateInZone(coordinate)==true

      local previousRTZ=armyGroup.OnAfterRTZ
      function armyGroup:OnAfterRTZ(F,E,T,Zone,Formation)
        if previousRTZ then previousRTZ(self,F,E,T,Zone,Formation) end
        state.guardRtzObserved=true
        log("GUARD_RTZ group="..tostring(group:GetName()).." formation="..tostring(Formation))
      end

      local previousReturned=armyGroup.OnAfterReturned
      function armyGroup:OnAfterReturned(F,E,T)
        if previousReturned then previousReturned(self,F,E,T) end
        state.guardReturnedObserved=true
        log("GUARD_RETURNED group="..tostring(group:GetName()).." from="..tostring(F).." to="..tostring(T))
      end

      log("GUARD_MATERIALIZED group="..tostring(group:GetName()).." insidePerimeter="..tostring(state.guardInsidePerimeter).." missionType="..tostring(state.guardMissionType))
    elseif attribute==GROUP.Attribute.GROUND_APC then
      if state.qrfArmy and state.qrfArmy~=armyGroup then fail("DUPLICATE_QRF_ARMYGROUP"); return end
      state.qrfArmy=armyGroup
      state.qrf=group
      log("QRF_MATERIALIZED group="..tostring(group:GetName()).." missionType="..tostring(mission and mission:GetType()))
    end
  end

  state.brigade=brigade
end

local function buildPerimeter(p)
  local s=p.SiteRegistry.Sites[SITE_ID]
  local alarm=s.alarm
  if type(alarm)~="table" or alarm.anchorKind~="WAREHOUSE" or type(alarm.radiusM)~="number" then
    return nil,"JOYCE_ALARM_CONFIG_INVALID"
  end
  local anchor=state.brigade:GetCoordinate()
  if not anchor then return nil,"JOYCE_WAREHOUSE_COORDINATE_UNAVAILABLE" end
  state.perimeter={
    anchorCoordinate=anchor,
    securityZone=nil,
    zoneName="OMW_SECURITY_"..s.installationId,
    radiusM=alarm.radiusM,
    priority=0,
  }
  return {[SITE_ID]=state.perimeter},nil
end

local function activateFixture()
  if state.fixtureActivated then return true,nil end
  local fixture=GROUP:FindByName(FIXTURE_NAME)
  if not fixture then return false,"FIXTURE_GROUP_MISSING" end
  if fixture:IsAlive()~=true then fixture:Activate() end
  local startCoordinate=fixture:GetCoordinate()
  if not startCoordinate then return false,"FIXTURE_COORDINATE_UNAVAILABLE" end
  state.fixtureStart=startCoordinate
  state.fixtureActivated=true
  local anchor=state.perimeter and state.perimeter.anchorCoordinate
  local startDistance=anchor and anchor:Get2DDistance(startCoordinate) or -1
  log(string.format("FIXTURE_ACTIVATE group=%s startDistanceM=%.1f routeSource=MISSION_EDITOR routeOverride=false",FIXTURE_NAME,startDistance))
  announce("ARMED","Joyce RED fixture activated after the no-Guard startup gate; existing Mission Editor route remains untouched",15)
  return true,nil
end

local function resolveDemands(active)
  if not active or not state.runtime then return 0 end
  local p=package()
  local base=state.runtime:GetBase()
  state.baseIncidentId=p.IdContract.Incident(SITE_ID,active.incidentId)
  local inc=base:GetIncident(state.baseIncidentId)
  if not inc then return 0 end

  local guardCount,qrfCount=0,0
  for _,demandId in ipairs(inc.demandIds or {}) do
    local demand=base:GetDemand(demandId)
    if demand and demand.supportType=="GUARD" and demand.requestKey=="INSTALLATION_ATTACK_LOCAL_GUARD" then
      guardCount=guardCount+1
      state.guardDemand=demand
    elseif demand and demand.supportType=="QRF" and demand.requestKey=="INSTALLATION_ATTACK_INITIAL_QRF" then
      qrfCount=qrfCount+1
      state.qrfDemand=demand
    end
  end

  if guardCount>1 then fail("DUPLICATE_GUARD_DEMAND") end
  if qrfCount>1 then fail("DUPLICATE_QRF_DEMAND") end
  if state.guardDemand and (not state.guardDemand.validity or state.guardDemand.validity.cancelWhenIncidentClosed~=true) then
    fail("GUARD_CANCEL_POLICY_INVALID")
  end
  if state.qrfDemand and (not state.qrfDemand.validity or state.qrfDemand.validity.cancelWhenIncidentClosed~=false) then
    fail("QRF_CANCEL_POLICY_INVALID")
  end
  return #(inc.demandIds or {})
end

local function requestAuthoritativeCloseIfReady(active,fixtureAlive)
  if state.closeRequested or not active or fixtureAlive then return end
  local c=coordinator()
  if not c or c:HasAliveParticipants()==true then return end
  if not state.guardDemand or not state.qrfDemand or not state.guardArmy then return end

  local s=site()
  local closed,changed,reason=state.runtime:CloseInstallationIncident(s.installationId,"ACCEPTANCE_CONFIRMED_NO_LIVING_PARTICIPANTS")
  if changed~=true or not closed then
    fail("AUTHORITATIVE_CLOSE_FAILED:"..tostring(reason))
    return
  end
  state.closeRequested=true
  state.closeReason=closed.closeReason
  log("AUTHORITATIVE_CLOSE_REQUESTED reason="..tostring(state.closeReason).." participantAuthority=GroundInstallationAttackIncident zeroLivingParticipants=true")
end

local function observe()
  if state.failed or state.passed or not state.runtime then return end
  local now=timer.getTime()
  local elapsed=state.startedAt and now-state.startedAt or 0

  if not state.fixtureActivated and elapsed>=STARTUP_NO_GUARD_WINDOW_SEC then
    local siteState=state.runtime:GetBase():GetSite(SITE_ID)
    if state.guardArmy or state.guard then fail("GUARD_PRESENT_DURING_NORMAL_STATE"); return end
    if not siteState or siteState.guardDemandId~=nil then fail("NORMAL_STATE_GUARD_DEMAND_PRESENT"); return end
    state.preAlarmNoGuard=true
    local ok,reason=activateFixture(); if not ok then fail(reason); return end
  end

  local fixture=GROUP:FindByName(FIXTURE_NAME)
  local fixtureAlive=fixture~=nil and fixture:IsAlive()==true
  if state.fixtureActivated and fixtureAlive and state.fixtureStart then
    local current=fixture:GetCoordinate()
    if current then state.fixtureMove=math.max(state.fixtureMove,state.fixtureStart:Get2DDistance(current)) end
  end

  local active=activeIncident()
  local demandCount=0
  if active then
    state.alarmObserved=true
    state.proximityObserved=hasProximityEvidence(active)
    demandCount=resolveDemands(active)
  end

  if state.alarmObserved and state.fixtureActivated and not fixtureAlive then state.fixtureCleared=true end
  requestAuthoritativeCloseIfReady(active,fixtureAlive)

  local guardStatus=state.guardDemand and state.guardDemand.status or nil
  local qrfStatus=state.qrfDemand and state.qrfDemand.status or nil
  log(string.format(
    "TELEMETRY elapsed=%.1f preAlarmNoGuard=%s fixtureActivated=%s fixtureMoveM=%.1f fixtureAlive=%s alarm=%s proximity=%s demandCount=%d guardDemand=%s qrfDemand=%s guardMaterialized=%s guardInside=%s guardMissionType=%s closeRequested=%s guardStatus=%s qrfStatus=%s guardRTZ=%s guardReturned=%s",
    elapsed,tostring(state.preAlarmNoGuard),tostring(state.fixtureActivated),state.fixtureMove,tostring(fixtureAlive),
    tostring(state.alarmObserved),tostring(state.proximityObserved),demandCount,tostring(state.guardDemand~=nil),tostring(state.qrfDemand~=nil),
    tostring(state.guardArmy~=nil),tostring(state.guardInsidePerimeter),tostring(state.guardMissionType),tostring(state.closeRequested),
    tostring(guardStatus),tostring(qrfStatus),tostring(state.guardRtzObserved),tostring(state.guardReturnedObserved)))

  if state.guardArmy and state.guardMissionType~=AUFTRAG.Type.ONGUARD then fail("GUARD_MISSION_NOT_ONGUARD"); return end
  if state.guardArmy and state.guardInsidePerimeter~=true then fail("GUARD_NOT_LOCAL_TO_INSTALLATION_PERIMETER"); return end
  if active and demandCount>2 then fail("INCIDENT_DEMAND_COUNT_"..tostring(demandCount)); return end

  if state.closeRequested then
    if not state.guardDemand or state.guardDemand.status~="CANCEL_REQUESTED" then return end
    if state.qrfDemand and state.qrfDemand.status=="CANCEL_REQUESTED" then fail("INCIDENT_CLOSE_CANCELLED_QRF"); return end
  end

  if state.preAlarmNoGuard and state.fixtureMove>=MIN_FIXTURE_MOVE_M and state.proximityObserved
      and state.guardDemand and state.qrfDemand and state.guardArmy and state.guardInsidePerimeter
      and state.guardMissionType==AUFTRAG.Type.ONGUARD and state.fixtureCleared and state.closeRequested
      and state.guardDemand.status=="CANCEL_REQUESTED" and state.qrfDemand.status~="CANCEL_REQUESTED"
      and state.guardReturnedObserved then
    state.passed=true
    announce("PASS","Joyce normal state had no physical Guard -> physical RED route produced MOOSE OPSZONE PROXIMITY_INTRUSION -> exactly one local Guard and one initial QRF demand -> Guard materialized locally on ONGUARD -> zero living authoritative participants -> production incident close cancelled Guard only -> MOOSE Guard Returned observed",40)
    return
  end

  if state.startedAt and elapsed>TEST_TIMEOUT_SEC then fail("TIMEOUT_INCOMPLETE_INCIDENT_LOCAL_GUARD_CHAIN") end
end

local function start()
  local p=package()
  if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then fail("BLUE_TEMPLATE_MISSING"); return end
  if not GROUP:FindByName(FIXTURE_NAME) then fail("FIXTURE_GROUP_MISSING"); return end

  local fullSiteRegistry=p.SiteRegistry
  local focusedSiteRegistry={
    SchemaVersion=fullSiteRegistry.SchemaVersion,
    GuardTemplateName=fullSiteRegistry.GuardTemplateName,
    Sites={[SITE_ID]=fullSiteRegistry.Sites[SITE_ID]},
  }
  if type(focusedSiteRegistry.Sites[SITE_ID])~="table" then fail("FOCUSED_SITE_REGISTRY_MISSING"); return end

  buildBrigade(p)
  local perimeters,reason=buildPerimeter(p); if not perimeters then fail(reason); return end

  local ok,runtime=pcall(function()
    return p.New({
      siteRegistry=focusedSiteRegistry,
      brigades={[SITE_ID]=state.brigade},
      resolveGuardPathline=function(name) return PATHLINE:FindByName(name) end,
      resolveGuardTemplateGroup=function(name) return GROUP:FindByName(name) end,
      guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
      resolveQrfCoordinate=function(_,context)
        local inc=context and context.incident
        local physical=inc and inc.context and inc.context.physicalTargetGroup
        if not physical then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
        return physical,nil
      end,
      qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
      blueCoalition=coalition.side.BLUE,
      redCoalition=coalition.side.RED,
      perimeters=perimeters,
      logger=log,
    }):Prepare()
  end)
  if not ok or not runtime then fail("RUNTIME_PREPARE_FAILED "..tostring(runtime)); return end
  state.runtime=runtime

  local perimeterStates,started,perimeterReason=runtime:StartPerimeters()
  if started~=true or not perimeterStates then fail("PERIMETER_START_FAILED "..tostring(perimeterReason)); return end
  state.perimeterState=perimeterStates[SITE_ID]
  if not state.perimeterState or not state.perimeterState.securityZone then fail("PERIMETER_STATE_MISSING"); return end

  state.brigade:Start()
  local siteState,created,siteReason=runtime:StartSite(SITE_ID,{})
  if created~=true or not siteState then fail("SITE_START_FAILED "..tostring(siteReason)); return end
  if siteState.guardDemandId~=nil then fail("SITE_START_CREATED_GUARD_DEMAND"); return end

  state.startedAt=timer.getTime()
  announce("READY","Joyce incident-local Guard acceptance armed; 20 s normal-state gate must remain Guard-free before the existing RED Mission Editor route is activated",20)
  SCHEDULER:New(nil,observe,{},5,TELEMETRY_SEC)
end

SCHEDULER:New(nil,start,{},5)
