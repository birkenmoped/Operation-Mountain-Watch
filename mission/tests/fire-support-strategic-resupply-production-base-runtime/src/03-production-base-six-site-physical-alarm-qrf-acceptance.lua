-- Operation Mountain Watch - Production Base Acceptance 3.
-- Six-site physical MOOSE OPSZONE proximity -> incident -> local QRF response.
-- BadGuys_A3_* are test fixtures only; no production RED-C2 dependency.
--
-- IMPORTANT: this harness observes the accepted QRF contract. It does not invent
-- a QRF mission-end condition. In particular, movement distance, perimeter clear
-- and incident close must never release/cancel a dispatched QRF.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A3]"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local MIN_M=25
local TELEMETRY_SEC=20
local TEST_TIMEOUT_SEC=900
local FIXTURE_ROUTE_SPEED_KMH=20
local INTRUSION_DEPTH_FRACTION=0.65
local ALARM_PRIORITY=0 -- Acceptance-neutral metadata; not a production response-priority decision.
local sites={
  {id="JALALABAD_FENTY",fixture="BadGuys_A3_FENTY"},
  {id="COP_FORTRESS",fixture="BadGuys_A3_FORTRESS"},
  {id="FOB_JOYCE",fixture="BadGuys_A3_JOYCE"},
  {id="FOB_WRIGHT",fixture="BadGuys_A3_WRIGHT"},
  {id="COP_HONAKER",fixture="BadGuys_A3_HONAKER"},
  {id="FOB_BOSTICK",fixture="BadGuys_A3_BOSTICK"},
}
local state={failed=false,passed=false,released=false,runtime=nil,brigades={},site={},perimeters={},startedAt=nil}
local function log(m) env.info(TAG.." "..tostring(m),false) end
local function announce(k,m,t) local x="[PRODUCTION BASE A3]["..k.."] "..m; log(x); MESSAGE:New(x,t or 10):ToAll() end
local function fail(m) if not state.failed and not state.passed then state.failed=true; announce("FAIL",m,30) end end

local function baseIncident(siteId)
  local p=OMW.FireSupStratResupply
  local site=p.SiteRegistry.Sites[siteId]
  local sourceId=string.format("INSTALLATION-ATTACK|%s|1",site.installationId)
  return state.runtime:GetBase():GetIncident(p.IdContract.Incident(siteId,sourceId))
end

local function proximityEvidenceObserved(siteId)
  local p=OMW.FireSupStratResupply
  local site=p.SiteRegistry.Sites[siteId]
  local incidentRuntime=state.runtime and state.runtime.installationIncidentRuntime
  if not incidentRuntime then return false end
  local coordinator=incidentRuntime:GetCoordinator(site.installationId)
  local active=coordinator and coordinator:GetActive() or nil
  if not active then return false end
  for _,evidence in ipairs(active.evidence or {}) do
    if evidence.evidenceType=="PROXIMITY_INTRUSION" then return true end
  end
  return false
end

local function updateSiteState(d)
  local s=state.site[d.id]
  if s.guard and s.guard:IsAlive() and s.guardStart then
    local c=s.guard:GetCoordinate(); if c then s.guardMove=s.guardStart:Get2DDistance(c) end
  end
  local fixture=GROUP:FindByName(d.fixture)
  if s.qrf and s.qrf:IsAlive() and fixture and fixture:IsAlive() then
    local qrfCoordinate=s.qrf:GetCoordinate()
    local targetCoordinate=fixture:GetCoordinate()
    if qrfCoordinate and targetCoordinate then
      s.qrfCurrent=qrfCoordinate:Get2DDistance(targetCoordinate)
      if not s.qrfInitial then s.qrfInitial=s.qrfCurrent end
      s.qrfProgress=s.qrfInitial-s.qrfCurrent
    end
  end
  s.proximity=proximityEvidenceObserved(d.id)
  local incident=baseIncident(d.id); if incident then s.incident=true; s.demandCount=#incident.demandIds end
end

local function allGuardsPassed()
  for _,d in ipairs(sites) do
    local s=state.site[d.id]; updateSiteState(d)
    if not s.guardObserved or not s.guard or not s.guard:IsAlive() or (s.guardMove or 0)<MIN_M then return false end
  end
  return true
end

local function routeFixtureIntoPerimeter(d,fixture)
  local s=state.site[d.id]
  local perimeter=state.perimeters[d.id]
  local from=fixture:GetCoordinate()
  local anchor=perimeter and perimeter.anchorCoordinate
  if not from or not anchor then return false,"COORDINATE_UNAVAILABLE" end
  local targetDistance=perimeter.radiusM*INTRUSION_DEPTH_FRACTION
  local target=anchor:GetIntermediateCoordinate(from,targetDistance)
  if not target then return false,"INTRUSION_TARGET_UNAVAILABLE" end
  s.fixtureStart=from
  s.intrusionTarget=target
  fixture:RouteGroundTo(target,FIXTURE_ROUTE_SPEED_KMH,"Off Road",1)
  log(string.format("FIXTURE_ROUTE siteId=%s group=%s startDistanceM=%.1f targetDistanceM=%.1f radiusM=%.1f speedKmh=%d",
    d.id,d.fixture,anchor:Get2DDistance(from),targetDistance,perimeter.radiusM,FIXTURE_ROUTE_SPEED_KMH))
  return true,nil
end

local function releaseFixtures()
  if state.released or state.failed then return end
  for _,d in ipairs(sites) do
    local f=GROUP:FindByName(d.fixture); if not f then fail("FIXTURE_GROUP_MISSING "..d.fixture); return end
    if f:IsAlive()~=true then f:Activate() end
    local ok,reason=routeFixtureIntoPerimeter(d,f)
    if not ok then fail("FIXTURE_ROUTE_FAILED "..d.id.." "..tostring(reason)); return end
  end
  state.released=true
  announce("ARMED","6/6 Guards passed >=25 m; six RED fixtures physically routed toward owner-defined MOOSE alarm perimeters",20)
end

local function telemetry()
  if state.failed or state.passed or not state.runtime then return end
  if not state.released and allGuardsPassed() then releaseFixtures() end
  for _,d in ipairs(sites) do
    local s=state.site[d.id]
    local f=GROUP:FindByName(d.fixture)
    if state.released and f and f:IsAlive() and s.target then s.fixtureDistance=s.target:Get2DDistance(f:GetCoordinate()) end
    updateSiteState(d)
    log(string.format("SITE_TELEMETRY siteId=%s perimeterStarted=%s proximity=%s guardObserved=%s guardMoveM=%.1f incident=%s demandCount=%s qrfObserved=%s qrfAccess=%s qrfMissionType=%s qrfProgressM=%.1f fixtureDistanceToAnchorM=%s",
      d.id,tostring(s.perimeterStarted),tostring(s.proximity),tostring(s.guardObserved),s.guardMove or 0,tostring(s.incident),tostring(s.demandCount),tostring(s.qrfObserved),tostring(s.qrfAccess),tostring(s.qrfMissionType),s.qrfProgress or 0,tostring(s.fixtureDistance and string.format("%.1f",s.fixtureDistance) or "n/a")))
  end
end

local function evaluate()
  if state.failed or state.passed then return end
  telemetry()
  local bad={}; local pending=false
  for _,d in ipairs(sites) do
    local s=state.site[d.id]
    if not s.guardPassed then pending=true end
    if not s.perimeterStarted then bad[#bad+1]=d.id..":PERIMETER_NOT_STARTED" end
    if not s.proximity then pending=true end
    if not s.incident then pending=true elseif s.demandCount~=1 then bad[#bad+1]=d.id..":DEMAND_COUNT_"..tostring(s.demandCount) end
    if not s.qrfObserved then pending=true
    elseif s.qrfAccess~=true then bad[#bad+1]=d.id..":QRF_NOT_MATERIALIZED_IN_ACCESS"
    elseif s.qrfAttribute~=GROUP.Attribute.GROUND_APC then bad[#bad+1]=d.id..":QRF_ATTRIBUTE"
    elseif s.qrfMissionType~=AUFTRAG.Type.ONGUARD then bad[#bad+1]=d.id..":QRF_NOT_ONGUARD"
    elseif not s.qrf or not s.qrf:IsAlive() then bad[#bad+1]=d.id..":QRF_NOT_ALIVE_DURING_RESPONSE"
    elseif (s.qrfProgress or 0)<MIN_M then pending=true
    end
  end
  if #bad>0 then fail(table.concat(bad,",")); return end
  if not pending and state.released then
    state.passed=true
    announce("PASS","6/6 Guards >=25 m; 6/6 owner-defined MOOSE perimeters; 6/6 PROXIMITY_INTRUSION incidents; exactly one initial QRF demand each; 6/6 Ground_APC QRFs materialized in ACCESS under ONGUARD and showed >=25 m physical closing response. Harness issued no QRF release/cancel.",40)
    return
  end
  if state.startedAt and timer.getTime()-state.startedAt>TEST_TIMEOUT_SEC then fail("TIMEOUT_INCOMPLETE_SIX_SITE_PHYSICAL_RESPONSE_CHAIN") end
end

local function buildBrigades(package)
  for _,d in ipairs(sites) do
    local site=package.SiteRegistry.Sites[d.id]
    state.site[d.id]={guardMove=0,qrfProgress=0,guardPassed=false,perimeterStarted=false,proximity=false,qrfAccess=false}
    local b=BRIGADE:New(site.warehouseName,"BDE_FSSR_A3_"..d.id)
    local g=PLATOON:New(site.guardTemplateName,1,"PLT_FSSR_A3_GUARD_"..d.id)
    local q=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A3_QRF_"..d.id)
    g:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
    q:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
    b:AddPlatoon(g)
    b:AddPlatoon(q)
    local s=state.site[d.id]
    local previous=b.OnAfterArmyOnMission
    b.OnAfterArmyOnMission=function(self,From,Event,To,armyGroup,mission)
      if previous then previous(self,From,Event,To,armyGroup,mission) end
      local grp=armyGroup and armyGroup:GetGroup() or nil; if not grp then return end
      local a=grp:GetAttribute(); log("ARMY_ON_MISSION siteId="..d.id.." group="..tostring(grp:GetName()).." attribute="..tostring(a))
      if a==GROUP.Attribute.GROUND_INFANTRY then
        s.guard=grp; s.guardStart=grp:GetCoordinate(); s.guardObserved=true
      elseif a==GROUP.Attribute.GROUND_APC then
        if s.qrfArmy and s.qrfArmy~=armyGroup then fail(d.id..":DUPLICATE_QRF_ARMYGROUP"); return end
        s.qrfArmy=armyGroup; s.qrf=grp; s.qrfObserved=true; s.qrfAttribute=a; s.qrfGroupName=grp:GetName()
        local access=ZONE:FindByName(site.accessZoneName)
        local qrfCoordinate=grp:GetCoordinate()
        s.qrfAccess=access~=nil and qrfCoordinate~=nil and access:IsCoordinateInZone(qrfCoordinate)==true
        s.qrfMissionType=mission and mission:GetType() or nil
        log("QRF_MATERIALIZATION siteId="..d.id.." group="..tostring(s.qrfGroupName).." accessZone="..tostring(site.accessZoneName).." inside="..tostring(s.qrfAccess).." missionType="..tostring(s.qrfMissionType))
      end
    end
    state.brigades[d.id]=b
  end
end

local function buildPerimeters(package)
  if type(ZONE)~="table" or type(ZONE.FindByName)~="function" then return nil,"MOOSE_ZONE_FIND_UNAVAILABLE" end
  for _,d in ipairs(sites) do
    local site=package.SiteRegistry.Sites[d.id]
    local alarm=site and site.alarm
    if type(alarm)~="table" or type(alarm.radiusM)~="number" or alarm.radiusM<=0 then return nil,"ALARM_CONFIG_INVALID:"..d.id end
    local anchor=nil
    local anchorSource="WAREHOUSE_COORDINATE"
    if alarm.anchorKind=="WAREHOUSE" then
      local brigade=state.brigades[d.id]
      if not brigade or type(brigade.GetCoordinate)~="function" then return nil,"WAREHOUSE_COORDINATE_UNAVAILABLE:"..d.id end
      anchor=brigade:GetCoordinate()
    elseif alarm.anchorKind=="MOOSE_ZONE" then
      local sourceZone=ZONE:FindByName(alarm.anchorName)
      if not sourceZone or type(sourceZone.GetCoordinate)~="function" then return nil,"MOOSE_ZONE_UNAVAILABLE:"..tostring(alarm.anchorName) end
      anchor=sourceZone:GetCoordinate()
      anchorSource="EXISTING_MOOSE_ZONE_CENTER"
    else
      return nil,"ALARM_ANCHOR_KIND_UNSUPPORTED:"..d.id..":"..tostring(alarm.anchorKind)
    end
    if not anchor or type(anchor.GetVec2)~="function" then return nil,"ALARM_ANCHOR_COORDINATE_INVALID:"..d.id end
    state.site[d.id].target=anchor
    state.perimeters[d.id]={
      anchorCoordinate=anchor,
      securityZone=nil,
      zoneName="OMW_SECURITY_"..site.installationId,
      radiusM=alarm.radiusM,
      priority=ALARM_PRIORITY,
    }
    log(string.format("PERIMETER_CONFIG siteId=%s anchorKind=%s anchorName=%s radiusM=%.1f anchorSource=%s zoneSource=RUNTIME_ZONE_RADIUS",
      d.id,tostring(alarm.anchorKind),tostring(alarm.anchorName or site.warehouseName),alarm.radiusM,anchorSource))
  end
  return state.perimeters,nil
end

local function start()
  local p=OMW and OMW.FireSupStratResupply; if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then fail("BLUE_TEMPLATE_MISSING"); return end
  for _,d in ipairs(sites) do if not GROUP:FindByName(d.fixture) then fail("FIXTURE_GROUP_MISSING "..d.fixture); return end end
  buildBrigades(p)
  local perimeters,perimeterReason=buildPerimeters(p); if not perimeters then fail("PERIMETER_CONFIG_FAILED "..tostring(perimeterReason)); return end
  local ok,r=pcall(function() return p.New({
    brigades=state.brigades,
    resolveGuardPathline=function(n) return PATHLINE:FindByName(n) end,
    resolveGuardTemplateGroup=function(n) return GROUP:FindByName(n) end,
    guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
    resolveQrfCoordinate=function(demand,context)
      local i=context and context.incident
      local c=i and i.context
      local target=c and c.physicalTargetGroup
      if not target then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
      return target,nil
    end,
    qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
    blueCoalition=coalition.side.BLUE,redCoalition=coalition.side.RED,
    perimeters=perimeters,logger=log,
  }):Prepare() end)
  if not ok or not r then fail("RUNTIME_PREPARE_FAILED "..tostring(r)); return end
  state.runtime=r
  local perimeterStates,started,reason=r:StartPerimeters(); if started~=true then fail("PERIMETER_START_FAILED "..tostring(reason)); return end
  for _,d in ipairs(sites) do state.site[d.id].perimeterStarted=perimeterStates[d.id]~=nil end
  for _,b in pairs(state.brigades) do b:Start() end
  for _,d in ipairs(sites) do local _,created,siteReason=r:StartSite(d.id,{}); if created==false then fail(d.id.." GUARD_START_FAILED "..tostring(siteReason)); return end end
  state.startedAt=timer.getTime()
  announce("READY","six owner-defined MOOSE perimeters and Guard/QRF organisations active; RED fixtures remain late-activated until all Guards pass >=25 m; Acceptance observes QRF response only and never releases/cancels QRF missions",20)
  SCHEDULER:New(nil,function()
    for _,d in ipairs(sites) do local s=state.site[d.id]; updateSiteState(d); if s.guardObserved and s.guard and s.guard:IsAlive() and (s.guardMove or 0)>=MIN_M then s.guardPassed=true end end
    evaluate()
  end,{},TELEMETRY_SEC,TELEMETRY_SEC)
end

SCHEDULER:New(nil,start,{},10)