-- Operation Mountain Watch - Production Base Acceptance 9.
-- Harness role is intentionally limited to stimulus, observation and assertion.
-- CAS routing, release, RTB/recovery and asset return are owned by the production
-- OMW_FireSupStratResupply_CasLifecycleRuntime included in the Base bundle.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A9]"
local SITE_ID="FOB_JOYCE"
local FIXTURE_NAME="BadGuys_A3_JOYCE"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"

local STARTUP_SEC=20
local OBSERVE_SEC=5
local WATCHDOG_SEC=3600
local CAS_RADIUS_NM=5
local CAS_RANGE_NM=5
local CAS_SPEED_KTS=125
local CAS_ALTITUDE_FT_AGL=2500

local state={
  failed=false,passed=false,startedAt=nil,watchdogWarned=false,
  runtime=nil,base=nil,brigade=nil,commander=nil,
  fixtureActivated=false,qrfEngage=false,casRequested=false,casDemand=nil,
  evidence={},casLifecycleState=nil,
}

local function log(message) env.info(TAG.." "..tostring(message),false) end
local function msg(kind,message,time)
  local text="[PRODUCTION BASE A9]["..kind.."] "..tostring(message)
  log(text)
  MESSAGE:New(text,time or 12):ToAll()
end
local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  msg("FAIL",message,30)
end

local function package() return OMW and OMW.FireSupStratResupply or nil end
local function site()
  local p=package()
  return p and p.SiteRegistry and p.SiteRegistry.Sites[SITE_ID] or nil
end

local function discoverAirwings(commander)
  if type(OMW)~="table" or type(OMW.AirOps)~="table" then return 0 end
  local count=0
  local seen={}
  local function add(airwing)
    if type(airwing)~="table" then return end
    local alias=tostring(airwing.alias or airwing.name or airwing)
    if seen[alias] then return end
    seen[alias]=true
    commander:AddAirwing(airwing)
    count=count+1
    log("C2_LEGION_REGISTERED alias="..alias)
  end
  for _,node in pairs(OMW.AirOps) do
    if type(node)=="table" and node.Status=="RUNNING" then
      add(node.Airwing)
      for _,airwing in pairs(node.Airwings or {}) do add(airwing) end
    end
  end
  return count
end

local function buildCommander()
  local commander=COMMANDER:New(coalition.side.BLUE,"OMW_FSSR_BASE_A9_C2")
  commander:SetVerbosity(2)
  local count=discoverAirwings(commander)
  if count<1 then return nil,false,"NO_RUNNING_AIRWINGS" end
  commander:Start()
  log("C2_READY runningAirwings="..tostring(count))
  return commander,true,nil
end

local function buildBrigade(p)
  local s=p.SiteRegistry.Sites[SITE_ID]
  local brigade=BRIGADE:New(s.warehouseName,"BDE_FSSR_A9_"..SITE_ID)
  local guard=PLATOON:New(s.guardTemplateName,1,"PLT_FSSR_A9_GUARD_"..SITE_ID)
  local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A9_QRF_"..SITE_ID)
  guard:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  brigade:AddPlatoon(guard)
  brigade:AddPlatoon(qrf)

  local previous=brigade.OnAfterArmyOnMission
  function brigade:OnAfterArmyOnMission(From,Event,To,ArmyGroup,Mission)
    if previous then previous(self,From,Event,To,ArmyGroup,Mission) end
    local group=ArmyGroup and ArmyGroup:GetGroup() or nil
    if not group or group:GetAttribute()~=GROUP.Attribute.GROUND_APC then return end
    local oldEngage=ArmyGroup.OnAfterEngageTarget
    function ArmyGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
      if oldEngage then oldEngage(self,F,E,T,Target,Speed,Formation) end
      state.qrfEngage=true
      log("QRF_DIRECT_TARGET_ENGAGE target="
        ..tostring(Target and Target.GetName and Target:GetName() or "unknown")
        .." formation="..tostring(Formation))
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
  return {
    [SITE_ID]={
      anchorCoordinate=anchor,
      zoneName="OMW_SECURITY_"..s.installationId,
      radiusM=alarm.radiusM,
      priority=0,
    },
  },nil
end

local function activeBaseIncident()
  local p=package()
  local s=site()
  local ir=state.runtime and state.runtime.installationIncidentRuntime or nil
  local coordinator=ir and s and ir:GetCoordinator(s.installationId) or nil
  local active=coordinator and coordinator:GetActive() or nil
  if not active then return nil end
  return state.base:GetIncident(p.IdContract.Incident(SITE_ID,active.incidentId))
end

local function resolveCasGeometry(demand,context)
  local target=context and context.incident and context.incident.context
    and context.incident.context.physicalTargetGroup or nil
  if not target or target:IsAlive()~=true then return nil,"CAS_PHYSICAL_TARGET_UNAVAILABLE" end
  local coordinate=target:GetCoordinate()
  if not coordinate then return nil,"CAS_TARGET_COORDINATE_UNAVAILABLE" end

  local zone=ZONE_RADIUS:New(
    "OMW_FSSR_BASE_A9_CAS_"..tostring(demand.demandId),
    coordinate:GetVec2(),
    UTILS.NMToMeters(CAS_RADIUS_NM))

  local altitudeFt=UTILS.MetersToFeet(zone:GetCoordinate():GetLandHeight())+CAS_ALTITUDE_FT_AGL
  return {
    missionMode="PATROLZONE_ENGAGE",
    zone=zone,
    altitudeFt=altitudeFt,
    speedKts=CAS_SPEED_KTS,
    engageDetectedRangeNm=CAS_RANGE_NM,
    engageDetectedTargetTypes={"Ground Units"},
    targetTypes={"Ground Units"},
    requiredAttributes=GROUP.Attribute.AIR_ATTACKHELO,
    configureMission=function(mission) mission:SetName("OMW_FSSR_BASE_A9_CAS") end,
  },nil
end

local function onCasEvidence(fields,entry)
  state.evidence[fields.event]=fields
  log("PRODUCTION_CAS_EVIDENCE event="..tostring(fields.event)
    .." demandId="..tostring(fields.demandId)
    .." provider="..tostring(fields.provider)
    .." reason="..tostring(fields.reason))
end

local function requestCas()
  if state.casRequested then return end
  local incident=activeBaseIncident()
  if not incident then return end
  local demand,created,reason=state.base:RequestIncidentSupport(
    incident.incidentId,
    "CAS",
    {requestKey="A9_PRODUCTION_CAS_LIFECYCLE",priority=20,cancelWhenIncidentClosed=false})
  if not demand then fail("CAS_REQUEST_FAILED "..tostring(reason)); return end
  state.casDemand=demand
  state.casRequested=true
  log("CAS_ESCALATION_REQUESTED demandId="..tostring(demand.demandId)
    .." created="..tostring(created).." reason="..tostring(reason))
end

local function observe()
  if state.passed then return end
  requestCas()

  if state.casDemand and state.runtime and state.runtime.externalSupportRuntime
      and state.runtime.externalSupportRuntime.casLifecycle then
    state.casLifecycleState=state.runtime.externalSupportRuntime.casLifecycle:GetState(state.casDemand.demandId)
  end

  local lifecycle=state.casLifecycleState
  if lifecycle and lifecycle.failed and not state.failed then
    fail("PRODUCTION_CAS_LIFECYCLE_FAILED "..tostring(lifecycle.failureReason))
  end
  if lifecycle and lifecycle.fuelLowBeforeRelease and not state.failed then
    fail("FUEL_LOW_PRECEDED_CONTROLLED_RELEASE")
  end

  if not state.failed and state.qrfEngage and lifecycle and lifecycle.completed then
    local required={
      "CAS_PROVIDER_PROFILE_BOUND",
      "CAS_MISSION_ASSIGNED",
      "CAS_OWNER_CORRIDOR_INSTALLED",
      "CAS_EXECUTING",
      "CAS_NO_CONTACT_REPORTED",
      "CAS_SUPPORTED_ELEMENT_CLEAR",
      "CAS_CONTROLLED_RELEASE",
      "CAS_HOME_LANDED",
      "CAS_LEGION_ASSET_RETURNED",
      "CAS_LIFECYCLE_COMPLETE",
    }
    for _,eventName in ipairs(required) do
      if not state.evidence[eventName] then return end
    end
    state.passed=true
    msg("PASS","Production Base CAS lifecycle complete: MOOSE selection -> owner route -> supported-element/no-contact release -> reverse recovery -> home landing -> Legion asset return.",45)
    return
  end

  if state.startedAt and not state.watchdogWarned and timer.getTime()-state.startedAt>WATCHDOG_SEC then
    state.watchdogWarned=true
    msg("WARN","Observation watchdog elapsed; production lifecycle continues. No lifecycle state is changed by the Acceptance.",20)
  end
end

local function activateFixture()
  if state.fixtureActivated then return end
  local fixture=GROUP:FindByName(FIXTURE_NAME)
  if not fixture then fail("FIXTURE_GROUP_MISSING "..FIXTURE_NAME); return end
  if fixture:IsAlive()~=true then fixture:Activate() end
  state.fixtureActivated=true
  state.startedAt=timer.getTime()
  msg("ATTACK","Joyce RED fixture activated on existing Mission Editor route.",15)
end

local function start()
  local p=package()
  if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then
    fail("BLUE_TEMPLATE_MISSING"); return
  end
  if not GROUP:FindByName(FIXTURE_NAME) then fail("FIXTURE_GROUP_MISSING "..FIXTURE_NAME); return end
  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then
    fail("PATHLINE_REGISTRY_UNAVAILABLE"); return
  end

  local commander,ok,reason=buildCommander()
  if not ok then fail("C2_PREFLIGHT_FAILED "..tostring(reason)); return end
  state.commander=commander

  buildBrigade(p)
  local perimeters,perimeterReason=buildPerimeter(p)
  if not perimeters then fail(perimeterReason); return end

  local focused={
    SchemaVersion=p.SiteRegistry.SchemaVersion,
    GuardTemplateName=p.SiteRegistry.GuardTemplateName,
    Sites={[SITE_ID]=p.SiteRegistry.Sites[SITE_ID]},
  }

  local okRuntime,runtimeOrError=pcall(function()
    local runtime=p.New({
      siteRegistry=focused,
      brigades={[SITE_ID]=state.brigade},
      resolveGuardPathline=function(name) return PATHLINE:FindByName(name) end,
      resolveGuardTemplateGroup=function(name) return GROUP:FindByName(name) end,
      guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
      resolveQrfCoordinate=function(_,ctx)
        local incident=ctx and ctx.incident
        local physical=incident and incident.context and incident.context.physicalTargetGroup
        if not physical then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
        return physical,nil
      end,
      qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
      blueCoalition=coalition.side.BLUE,
      redCoalition=coalition.side.RED,
      perimeters=perimeters,
      externalSupport={
        commander=commander,
        resolveArtyTarget=function() return nil,"ARTY_NOT_IN_ACCEPTANCE_9_SCOPE" end,
        resolveCasGeometry=resolveCasGeometry,
        casRequiredAssetsMin=1,
        casRequiredAssetsMax=1,
        casLifecycle={
          executionProfiles={
            AW_US_JBAD_TF_SHOOTER_6_6_CAV={
              pathlineBase="OMW_FlightPath",
              pathlineNames={"OMW_FlightPath","OMW_FlightPath_WEST"},
              segmentProfiles={
                {altitudeFtAgl=500},
                {altitudeFtAgl=2500,formation=ENUMS.Formation.RotaryWing.Column.D70},
              },
              maxJunctionDistanceM=1000,
              routeGateDistanceNm=3.5,
              transitAltitudeFtAgl=2500,
              missionAltitudeFtAgl=2500,
              speedKts=CAS_SPEED_KTS,
            },
          },
          pathlineRegistry=_DATABASE.PATHLINES,
          noContactStableSec=30,
          updateSeconds=5,
          redCoalition=coalition.side.RED,
          onEvidence=onCasEvidence,
        },
      },
      logger=log,
    })
    return runtime:Prepare()
  end)

  if not okRuntime or not runtimeOrError then
    fail("RUNTIME_PREPARE_FAILED "..tostring(runtimeOrError)); return
  end

  state.runtime=runtimeOrError
  state.base=state.runtime:GetBase()
  local _,perimetersStarted,perimeterStartReason=state.runtime:StartPerimeters()
  if perimetersStarted~=true then fail("PERIMETER_START_FAILED "..tostring(perimeterStartReason)); return end

  state.brigade:Start()
  local _,siteStarted,siteReason=state.runtime:StartSite(SITE_ID,{})
  if siteStarted==false then fail("SITE_START_FAILED "..tostring(siteReason)); return end

  msg("READY","A9 armed. Acceptance is observer-only for CAS lifecycle; production CasLifecycleRuntime owns route/release/recovery.",18)
  SCHEDULER:New(nil,activateFixture,{},STARTUP_SEC)
  SCHEDULER:New(nil,observe,{},OBSERVE_SEC,OBSERVE_SEC)
end

SCHEDULER:New(nil,start,{},10)
