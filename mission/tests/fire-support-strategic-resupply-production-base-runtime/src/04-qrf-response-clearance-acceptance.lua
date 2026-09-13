-- Operation Mountain Watch - Production Base Acceptance 4.
-- Joyce regression for the Honaker-reconciled direct-target QRF lifecycle.
--
-- Production contract under test:
--   physical PROXIMITY_INTRUSION
--   -> exactly one QRF demand
--   -> ACCESS-only materialization with ONGUARD recruitment anchor
--   -> same physical ARMYGROUP directly EngageTarget()s a live incident UNIT
--   -> target death / MOOSE Disengage -> next live incident UNIT
--   -> no live authorized incident target -> mission completion / ReturnToLegion
--   -> MOOSE RTZ / Returned lifecycle.
--
-- The harness observes this product behavior only. It does not select QRF targets,
-- implement target search, create Mission Editor zones, replace the RED fixture route
-- or issue a tactical release.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A4]"
local SITE_ID="FOB_JOYCE"
local FIXTURE_NAME="BadGuys_A3_JOYCE"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local MIN_GUARD_MOVE_M=25
local MIN_FIXTURE_MOVE_M=25
local TEST_TIMEOUT_SEC=900
local TELEMETRY_SEC=5

local state={
  failed=false,passed=false,fixtureActivated=false,runtime=nil,brigade=nil,perimeter=nil,
  guard=nil,guardStart=nil,guardMove=0,fixtureStart=nil,fixtureMove=0,
  qrf=nil,qrfArmy=nil,qrfGroupName=nil,qrfAccess=false,responseObserved=false,
  targetNames={},targetCount=0,fixtureClearedObserved=false,returnObserved=false,
  demandId=nil,startedAt=nil,
}

local function log(message) env.info(TAG.." "..tostring(message),false) end
local function announce(kind,message,time)
  local text="[PRODUCTION BASE A4]["..kind.."] "..message
  log(text)
  MESSAGE:New(text,time or 10):ToAll()
end
local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  announce("FAIL",message,30)
end

local function incident()
  if not state.runtime then return nil end
  local package=OMW.FireSupStratResupply
  local site=package.SiteRegistry.Sites[SITE_ID]
  local sourceId=string.format("INSTALLATION-ATTACK|%s|1",site.installationId)
  return state.runtime:GetBase():GetIncident(package.IdContract.Incident(SITE_ID,sourceId))
end

local function proximityObserved()
  local package=OMW.FireSupStratResupply
  local site=package.SiteRegistry.Sites[SITE_ID]
  local runtime=state.runtime and state.runtime.installationIncidentRuntime
  local coordinator=runtime and runtime:GetCoordinator(site.installationId) or nil
  local active=coordinator and coordinator:GetActive() or nil
  for _,evidence in ipairs((active and active.evidence) or {}) do
    if evidence.evidenceType=="PROXIMITY_INTRUSION" then return true end
  end
  return false
end

local function observeTarget(target)
  local name=target and type(target.GetName)=="function" and target:GetName() or nil
  if not name or state.targetNames[name] then return end
  state.targetNames[name]=true
  state.targetCount=state.targetCount+1
  log("QRF_CONCRETE_TARGET acquisition="..tostring(state.targetCount).." target="..tostring(name))
end

local function buildBrigade(package)
  local site=package.SiteRegistry.Sites[SITE_ID]
  local brigade=BRIGADE:New(site.warehouseName,"BDE_FSSR_A4_"..SITE_ID)
  local guard=PLATOON:New(site.guardTemplateName,1,"PLT_FSSR_A4_GUARD_"..SITE_ID)
  local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A4_QRF_"..SITE_ID)
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
      state.guard=group
      state.guardStart=group:GetCoordinate()
    elseif attribute==GROUP.Attribute.GROUND_APC then
      if state.qrfArmy and state.qrfArmy~=armyGroup then fail("DUPLICATE_QRF_ARMYGROUP"); return end
      state.qrfArmy=armyGroup
      state.qrf=group
      state.qrfGroupName=group:GetName()
      local access=ZONE:FindByName(site.accessZoneName)
      local coordinate=group:GetCoordinate()
      state.qrfAccess=access~=nil and coordinate~=nil and access:IsCoordinateInZone(coordinate)==true
      if mission and mission:GetType()==AUFTRAG.Type.ONGUARD then state.responseObserved=true end
      local previousEngage=armyGroup.OnAfterEngageTarget
      function armyGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
        if previousEngage then previousEngage(self,F,E,T,Target,Speed,Formation) end
        observeTarget(Target)
      end
      log("QRF_MATERIALIZATION group="..tostring(state.qrfGroupName).." access="..tostring(site.accessZoneName).." inside="..tostring(state.qrfAccess).." responseObserved="..tostring(state.responseObserved))
    end
  end
  state.brigade=brigade
end

local function buildPerimeter(package)
  local site=package.SiteRegistry.Sites[SITE_ID]
  local alarm=site.alarm
  if type(alarm)~="table" or alarm.anchorKind~="WAREHOUSE" or type(alarm.radiusM)~="number" then return nil,"JOYCE_ALARM_CONFIG_INVALID" end
  local anchor=state.brigade:GetCoordinate()
  if not anchor then return nil,"JOYCE_WAREHOUSE_COORDINATE_UNAVAILABLE" end
  state.perimeter={anchorCoordinate=anchor,securityZone=nil,zoneName="OMW_SECURITY_"..site.installationId,radiusM=alarm.radiusM,priority=0}
  return {[SITE_ID]=state.perimeter},nil
end

local function activateFixture()
  if state.fixtureActivated then return true end
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
  announce("ARMED","Joyce RED fixture activated; existing Mission Editor attack route remains untouched",15)
  return true,nil
end

local function observe()
  if state.failed or state.passed or not state.runtime then return end
  if state.guard and state.guard:IsAlive() and state.guardStart then
    local c=state.guard:GetCoordinate()
    if c then state.guardMove=state.guardStart:Get2DDistance(c) end
  end
  if not state.fixtureActivated and state.guardMove>=MIN_GUARD_MOVE_M then
    local ok,reason=activateFixture(); if not ok then fail(reason); return end
  end

  local fixture=GROUP:FindByName(FIXTURE_NAME)
  local fixtureAlive=fixture~=nil and fixture:IsAlive()==true
  if state.fixtureActivated and fixtureAlive and state.fixtureStart then
    local current=fixture:GetCoordinate()
    if current then state.fixtureMove=math.max(state.fixtureMove,state.fixtureStart:Get2DDistance(current)) end
  end

  local inc=incident()
  local demandCount=inc and #inc.demandIds or 0
  if inc and demandCount==1 then state.demandId=inc.demandIds[1] end
  if state.targetCount>0 and state.fixtureActivated and not fixtureAlive then state.fixtureClearedObserved=true end

  if state.qrfArmy then
    local returning=type(state.qrfArmy.IsReturning)=="function" and state.qrfArmy:IsReturning() or false
    local returned=type(state.qrfArmy.GetState)=="function" and state.qrfArmy:GetState()=="Returned" or false
    if returning or returned then state.returnObserved=true end
    log(string.format("TELEMETRY guardMoveM=%.1f fixtureActivated=%s fixtureMoveM=%.1f proximity=%s demandCount=%d qrfAccess=%s response=%s targetCount=%d fixtureAlive=%s fixtureCleared=%s returning=%s returned=%s",
      state.guardMove,tostring(state.fixtureActivated),state.fixtureMove,tostring(proximityObserved()),demandCount,tostring(state.qrfAccess),tostring(state.responseObserved),state.targetCount,tostring(fixtureAlive),tostring(state.fixtureClearedObserved),tostring(returning),tostring(returned)))
  else
    log(string.format("TELEMETRY guardMoveM=%.1f fixtureActivated=%s fixtureMoveM=%.1f proximity=%s demandCount=%d qrfArmy=nil fixtureAlive=%s",
      state.guardMove,tostring(state.fixtureActivated),state.fixtureMove,tostring(proximityObserved()),demandCount,tostring(fixtureAlive)))
  end

  if inc and demandCount>1 then fail("DEMAND_COUNT_"..tostring(demandCount)); return end
  if state.qrfArmy and state.qrfAccess~=true then fail("QRF_NOT_MATERIALIZED_IN_ACCESS"); return end
  if state.qrfArmy and not state.responseObserved then fail("INITIAL_QRF_MISSION_NOT_ONGUARD"); return end

  if state.guardMove>=MIN_GUARD_MOVE_M and state.fixtureMove>=MIN_FIXTURE_MOVE_M and proximityObserved() and demandCount==1
      and state.qrfArmy and state.responseObserved and state.qrfAccess and state.targetCount>=2
      and state.fixtureClearedObserved and state.returnObserved then
    state.passed=true
    announce("PASS","Joyce Mission Editor RED route remained untouched -> physical alarm -> one ACCESS QRF -> same ARMYGROUP directly engaged multiple moving concrete incident UNIT targets -> hostile fixture cleared -> no target remained -> MOOSE return observed",40)
    return
  end

  if state.startedAt and timer.getTime()-state.startedAt>TEST_TIMEOUT_SEC then fail("TIMEOUT_INCOMPLETE_QRF_DIRECT_TARGET_CHAIN") end
end

local function start()
  local package=OMW and OMW.FireSupStratResupply
  if type(package)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then fail("BLUE_TEMPLATE_MISSING"); return end
  if not GROUP:FindByName(FIXTURE_NAME) then fail("FIXTURE_GROUP_MISSING"); return end

  local fullSiteRegistry=package.SiteRegistry
  local focusedSiteRegistry={SchemaVersion=fullSiteRegistry.SchemaVersion,GuardTemplateName=fullSiteRegistry.GuardTemplateName,Sites={[SITE_ID]=fullSiteRegistry.Sites[SITE_ID]}}
  if type(focusedSiteRegistry.Sites[SITE_ID])~="table" then fail("FOCUSED_SITE_REGISTRY_MISSING"); return end

  buildBrigade(package)
  local perimeters,reason=buildPerimeter(package); if not perimeters then fail(reason); return end
  local ok,runtime=pcall(function()
    return package.New({
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

  local _,started,perimeterReason=runtime:StartPerimeters(); if started~=true then fail("PERIMETER_START_FAILED "..tostring(perimeterReason)); return end
  state.brigade:Start()
  local _,created,siteReason=runtime:StartSite(SITE_ID,{}); if created==false then fail("GUARD_START_FAILED "..tostring(siteReason)); return end

  state.startedAt=timer.getTime()
  announce("READY","Joyce direct-target QRF acceptance armed; RED fixture remains late-activated until Guard moves >=25 m and then follows its existing Mission Editor route without override",20)
  SCHEDULER:New(nil,observe,{},5,TELEMETRY_SEC)
end

SCHEDULER:New(nil,start,{},5)