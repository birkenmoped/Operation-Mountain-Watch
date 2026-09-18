-- Operation Mountain Watch - Production Base Acceptance 6.
-- Compact Base command-chain / C2 provider-selection acceptance.
--
-- Scope:
--   physical RED attack at FOB Joyce
--   -> production MOOSE perimeter / incident
--   -> production QRF direct-target response
--   -> explicit C2 CAS escalation through Base:RequestIncidentSupport()
--   -> generic ExternalSupportRuntime / CommanderBridge
--   -> one local MOOSE COMMANDER containing all currently running OMW AIRWINGs
--   -> MOOSE selects/recruits the CAS provider and operational asset
--
-- The harness does NOT select an AIRWING, SQUADRON, aircraft type, CAS provider,
-- route, corridor, or lifecycle completion policy. It does not rewrite the RED
-- Mission Editor route. PASS ends after command-chain and physical assignment
-- evidence; weapon employment, RTB and resupply are deliberately out of scope.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A6]"
local SITE_ID="FOB_JOYCE"
local FIXTURE_NAME="BadGuys_A3_JOYCE"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local STARTUP_NO_GUARD_SEC=20
local TEST_TIMEOUT_SEC=600
local TELEMETRY_SEC=5
local CAS_ZONE_RADIUS_NM=3

local state={
  failed=false,passed=false,startedAt=nil,fixtureActivated=false,
  runtime=nil,brigade=nil,perimeter=nil,perimeterState=nil,
  qrfArmy=nil,qrfGroup=nil,qrfEngageObserved=false,
  incident=nil,casDemand=nil,casRequested=false,
  commander=nil,candidateAirwings={},casCapableAirwings={},
  casMission=nil,casAssigned=false,casAssignedLegions={},
  casOpsOnMission=false,casOpsGroup=nil,casAssetSquadron=nil,
}

local function log(message) env.info(TAG.." "..tostring(message),false) end
local function announce(kind,message,time)
  local text="[PRODUCTION BASE A6]["..kind.."] "..message
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

local function addCandidateAirwing(airwing)
  if type(airwing)~="table" then return end
  local alias=tostring(airwing.alias or airwing.name or airwing)
  if state.candidateAirwings[alias] then return end
  state.candidateAirwings[alias]=airwing
end

local function discoverRunningAirwings()
  if type(OMW)~="table" or type(OMW.AirOps)~="table" then
    return nil,false,"OMW_AIROPS_UNAVAILABLE"
  end
  for nodeName,node in pairs(OMW.AirOps) do
    if type(node)=="table" and node.Status=="RUNNING" then
      addCandidateAirwing(node.Airwing)
      if type(node.Airwings)=="table" then
        for _,airwing in pairs(node.Airwings) do addCandidateAirwing(airwing) end
      end
      log("C2_AIROPS_NODE_DISCOVERED node="..tostring(nodeName))
    end
  end

  local count=0
  local casCount=0
  for alias,airwing in pairs(state.candidateAirwings) do
    count=count+1
    local capable=false
    for _,cohort in pairs(airwing.cohorts or {}) do
      if AUFTRAG.CheckMissionCapability(AUFTRAG.Type.CAS,cohort.missiontypes) then
        capable=true
        break
      end
    end
    if capable then
      state.casCapableAirwings[alias]=airwing
      casCount=casCount+1
    end
    log("C2_CANDIDATE_AIRWING alias="..alias.." casCapable="..tostring(capable))
  end

  if count<2 then return nil,false,"FEWER_THAN_TWO_RUNNING_AIRWINGS" end
  if casCount<2 then return nil,false,"FEWER_THAN_TWO_CAS_CAPABLE_AIRWINGS" end
  return {running=count,casCapable=casCount},true,nil
end

local function buildCommander()
  local summary,ok,reason=discoverRunningAirwings()
  if not ok then return nil,false,reason end

  local commander=COMMANDER:New(coalition.side.BLUE,"OMW_FSSR_BASE_A6_C2")
  if not commander then return nil,false,"COMMANDER_CREATE_FAILED" end
  commander:SetVerbosity(2)

  for alias,airwing in pairs(state.candidateAirwings) do
    commander:AddAirwing(airwing)
    log("C2_LEGION_REGISTERED alias="..alias)
  end

  local previousAssign=commander.OnAfterMissionAssign
  function commander:OnAfterMissionAssign(From,Event,To,Mission,Legions)
    if previousAssign then previousAssign(self,From,Event,To,Mission,Legions) end
    if not Mission or Mission:GetType()~=AUFTRAG.Type.CAS then return end
    state.casMission=Mission
    state.casAssigned=true
    state.casAssignedLegions={}
    for alias,legion in pairs(Legions or {}) do
      local name=tostring((type(legion)=="table" and (legion.alias or legion.name)) or alias)
      state.casAssignedLegions[#state.casAssignedLegions+1]=name
      log("C2_CAS_PROVIDER_SELECTED legion="..name)
    end
    if #state.casAssignedLegions<1 then fail("CAS_MISSION_ASSIGNED_WITHOUT_PROVIDER") end
  end

  local previousOps=commander.OnAfterOpsOnMission
  function commander:OnAfterOpsOnMission(From,Event,To,OpsGroup,Mission)
    if previousOps then previousOps(self,From,Event,To,OpsGroup,Mission) end
    if not Mission or Mission:GetType()~=AUFTRAG.Type.CAS then return end
    state.casOpsOnMission=true
    state.casOpsGroup=OpsGroup
    local group=OpsGroup and type(OpsGroup.GetGroup)=="function" and OpsGroup:GetGroup() or nil
    local groupName=group and group:GetName() or (OpsGroup and OpsGroup.groupname) or "unknown"
    local unitType=group and group:GetTypeName() or "unknown"
    local asset=Mission.assets and Mission.assets[1] or nil
    state.casAssetSquadron=asset and asset.squadname or nil
    log("C2_CAS_OPS_ON_MISSION group="..tostring(groupName)
      .." type="..tostring(unitType)
      .." squadron="..tostring(state.casAssetSquadron))
  end

  commander:Start()
  state.commander=commander
  log("C2_READY runningAirwings="..tostring(summary.running).." casCapableAirwings="..tostring(summary.casCapable))
  return commander,true,nil
end

local function buildBrigade(p)
  local s=p.SiteRegistry.Sites[SITE_ID]
  local brigade=BRIGADE:New(s.warehouseName,"BDE_FSSR_A6_"..SITE_ID)
  local guard=PLATOON:New(s.guardTemplateName,1,"PLT_FSSR_A6_GUARD_"..SITE_ID)
  local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A6_QRF_"..SITE_ID)
  guard:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  brigade:AddPlatoon(guard)
  brigade:AddPlatoon(qrf)

  local previousArmy=brigade.OnAfterArmyOnMission
  function brigade:OnAfterArmyOnMission(From,Event,To,ArmyGroup,Mission)
    if previousArmy then previousArmy(self,From,Event,To,ArmyGroup,Mission) end
    local group=ArmyGroup and ArmyGroup:GetGroup() or nil
    if not group then return end
    if group:GetAttribute()==GROUP.Attribute.GROUND_APC then
      if state.qrfArmy and state.qrfArmy~=ArmyGroup then fail("DUPLICATE_QRF_ARMYGROUP"); return end
      state.qrfArmy=ArmyGroup
      state.qrfGroup=group
      local previousEngage=ArmyGroup.OnAfterEngageTarget
      function ArmyGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
        if previousEngage then previousEngage(self,F,E,T,Target,Speed,Formation) end
        state.qrfEngageObserved=true
        local targetName=Target and type(Target.GetName)=="function" and Target:GetName() or tostring(Target)
        log("QRF_DIRECT_TARGET_ENGAGE target="..tostring(targetName)
          .." speed="..tostring(Speed).." formation="..tostring(Formation))
      end
      log("QRF_MATERIALIZED group="..tostring(group:GetName())
        .." missionType="..tostring(Mission and Mission:GetType()))
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
    [SITE_ID]={
      anchorCoordinate=anchor,
      zoneName="OMW_SECURITY_"..s.installationId,
      radiusM=alarm.radiusM,
      priority=0,
    },
  }
  return state.perimeter,nil
end

local function activeBaseIncident()
  local p=package()
  local s=site()
  local incidentRuntime=state.runtime and state.runtime.installationIncidentRuntime
  if not p or not s or not incidentRuntime then return nil end
  local coordinator=incidentRuntime:GetCoordinator(s.installationId)
  local active=coordinator and coordinator:GetActive() or nil
  if not active then return nil end
  local incidentId=p.IdContract.Incident(SITE_ID,active.incidentId)
  return state.runtime:GetBase():GetIncident(incidentId),active
end

local function resolveCasGeometry(demand,context)
  local targetGroup=context and context.incident and context.incident.context
    and context.incident.context.physicalTargetGroup or nil
  if not targetGroup or targetGroup:IsAlive()~=true then return nil,"CAS_PHYSICAL_TARGET_UNAVAILABLE" end
  local coordinate=targetGroup:GetCoordinate()
  if not coordinate then return nil,"CAS_TARGET_COORDINATE_UNAVAILABLE" end
  local zone=ZONE_RADIUS:New("OMW_FSSR_BASE_A6_CAS_"..tostring(demand.demandId),coordinate:GetVec2(),UTILS.NMToMeters(CAS_ZONE_RADIUS_NM))
  return {
    missionMode="CAS",
    zone=zone,
    targetTypes={"Ground Units"},
    configureMission=function(mission)
      mission:SetName("OMW_FSSR_BASE_A6_C2_CAS")
    end,
  },nil
end

local function requestCasIfReady()
  if state.casRequested or not state.runtime then return end
  local incident=activeBaseIncident()
  if not incident then return end
  state.incident=incident
  local demand,created,reason=state.runtime:GetBase():RequestIncidentSupport(
    incident.incidentId,
    "CAS",
    {
      requestKey="C2_PROVIDER_SELECTION",
      priority=20,
      cancelWhenIncidentClosed=false,
    })
  if not demand then fail("CAS_REQUEST_FAILED reason="..tostring(reason)); return end
  state.casDemand=demand
  state.casRequested=true
  log("CAS_ESCALATION_REQUESTED demandId="..tostring(demand.demandId)
    .." status="..tostring(demand.status)
    .." created="..tostring(created)
    .." reason="..tostring(reason))
end

local function evaluate()
  if state.failed or state.passed then return end
  requestCasIfReady()
  if state.incident and state.qrfEngageObserved and state.casRequested and state.casAssigned and state.casOpsOnMission then
    if #state.casAssignedLegions<1 then fail("CAS_PROVIDER_EVIDENCE_MISSING"); return end
    state.passed=true
    announce("PASS","production attack -> incident -> QRF concrete-target engagement plus Base CAS escalation -> generic COMMANDER -> runtime-selected CAS provider -> physical OPSGROUP on mission. No provider, squadron or aircraft type was selected by the Acceptance.",40)
    return
  end
  if state.startedAt and timer.getTime()-state.startedAt>TEST_TIMEOUT_SEC then
    fail("TIMEOUT incident="..tostring(state.incident~=nil)
      .." qrfEngage="..tostring(state.qrfEngageObserved)
      .." casRequested="..tostring(state.casRequested)
      .." casAssigned="..tostring(state.casAssigned)
      .." casOpsOnMission="..tostring(state.casOpsOnMission))
  end
end

local function activateFixture()
  if state.fixtureActivated or state.failed then return end
  local fixture=GROUP:FindByName(FIXTURE_NAME)
  if not fixture then fail("FIXTURE_GROUP_MISSING "..FIXTURE_NAME); return end
  if fixture:IsAlive()~=true then fixture:Activate() end
  state.fixtureActivated=true
  state.startedAt=timer.getTime()
  announce("ATTACK","Joyce RED fixture activated on its existing Mission Editor route; no route rewrite. Base/C2 observation started.",15)
end

local function start()
  local p=package()
  if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then fail("BLUE_TEMPLATE_MISSING"); return end
  if not GROUP:FindByName(FIXTURE_NAME) then fail("FIXTURE_GROUP_MISSING "..FIXTURE_NAME); return end
  if type(COMMANDER)~="table" or type(COMMANDER.New)~="function" then fail("MOOSE_COMMANDER_UNAVAILABLE"); return end

  local commander,commanderOk,commanderReason=buildCommander()
  if not commanderOk then fail("C2_PREFLIGHT_FAILED "..tostring(commanderReason)); return end

  buildBrigade(p)
  local perimeters,perimeterReason=buildPerimeter(p)
  if not perimeters then fail("PERIMETER_CONFIG_FAILED "..tostring(perimeterReason)); return end

  -- Production Runtime validates Guard/QRF composition for every site in the
  -- injected registry. Acceptance 6 intentionally exercises one physical site,
  -- so pass an explicit one-site registry view instead of pretending that
  -- brigades exist for the other five production sites.
  local singleSiteRegistry={
    SchemaVersion=p.SiteRegistry.SchemaVersion,
    Sites={[SITE_ID]=p.SiteRegistry.Sites[SITE_ID]},
  }

  local ok,runtimeOrError=pcall(function()
    local runtime=p.New({
      siteRegistry=singleSiteRegistry,
      brigades={[SITE_ID]=state.brigade},
      resolveGuardPathline=function(name) return PATHLINE:FindByName(name) end,
      resolveGuardTemplateGroup=function(name) return GROUP:FindByName(name) end,
      guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
      resolveQrfCoordinate=function(_,context)
        local physical=context and context.incident and context.incident.context
          and context.incident.context.physicalTargetGroup or nil
        if not physical then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
        return physical,nil
      end,
      qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
      blueCoalition=coalition.side.BLUE,
      redCoalition=coalition.side.RED,
      perimeters=perimeters,
      externalSupport={
        commander=commander,
        resolveArtyTarget=function() return nil,"ARTY_NOT_IN_ACCEPTANCE_6_SCOPE" end,
        resolveCasGeometry=resolveCasGeometry,
        casRequiredAssetsMin=1,
        casRequiredAssetsMax=1,
      },
      logger=log,
    })
    return runtime:Prepare()
  end)
  if not ok or not runtimeOrError then fail("RUNTIME_PREPARE_FAILED "..tostring(runtimeOrError)); return end
  state.runtime=runtimeOrError

  local perimeterStates,started,reason=state.runtime:StartPerimeters()
  if started~=true then fail("PERIMETER_START_FAILED "..tostring(reason)); return end
  state.perimeterState=perimeterStates and perimeterStates[SITE_ID] or nil

  state.brigade:Start()
  local _,siteStarted,siteReason=state.runtime:StartSite(SITE_ID,{})
  if siteStarted==false then fail("SITE_START_FAILED "..tostring(siteReason)); return end

  announce("READY","Joyce Base runtime active. C2 contains every currently running OMW AIRWING; at least two CAS-capable AIRWINGs are required. No CAS provider is preselected.",15)

  SCHEDULER:New(nil,function()
    if state.failed or state.passed then return end
    activateFixture()
  end,{},STARTUP_NO_GUARD_SEC)

  SCHEDULER:New(nil,evaluate,{},TELEMETRY_SEC,TELEMETRY_SEC)
end

SCHEDULER:New(nil,start,{},10)
