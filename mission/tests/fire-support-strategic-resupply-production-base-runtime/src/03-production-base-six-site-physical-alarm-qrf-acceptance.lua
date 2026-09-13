-- Operation Mountain Watch - Production Base Acceptance 3.
-- Acceptance-only six-site physical alarm evidence -> incident -> local QRF.
-- BadGuys_A3_* are test fixtures only; no production RED-C2 dependency.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A3]"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local MIN_M=25
local TELEMETRY_SEC=20
local TEST_TIMEOUT_SEC=720
local sites={
  {id="JALALABAD_FENTY",fixture="BadGuys_A3_FENTY"},
  {id="COP_FORTRESS",fixture="BadGuys_A3_FORTRESS"},
  {id="FOB_JOYCE",fixture="BadGuys_A3_JOYCE"},
  {id="FOB_WRIGHT",fixture="BadGuys_A3_WRIGHT"},
  {id="COP_HONAKER",fixture="BadGuys_A3_HONAKER"},
  {id="FOB_BOSTICK",fixture="BadGuys_A3_BOSTICK"},
}
local state={failed=false,passed=false,released=false,runtime=nil,brigades={},site={},startedAt=nil}
local function log(m) env.info(TAG.." "..tostring(m),false) end
local function announce(k,m,t) local x="[PRODUCTION BASE A3]["..k.."] "..m; log(x); MESSAGE:New(x,t or 10):ToAll() end
local function fail(m) if not state.failed and not state.passed then state.failed=true; announce("FAIL",m,30) end end

local function baseIncident(siteId)
  local p=OMW.FireSupStratResupply
  local site=p.SiteRegistry.Sites[siteId]
  local sourceId=string.format("INSTALLATION-ATTACK|%s|1",site.installationId)
  return state.runtime:GetBase():GetIncident(p.IdContract.Incident(siteId,sourceId))
end

local function targetBelongsToGuard(siteId,target)
  local s=state.site[siteId]
  if not s or not s.guard or type(target)~="table" then return false end
  if type(target.GetGroup)=="function" then
    local group=target:GetGroup()
    if group and type(group.GetName)=="function" then return group:GetName()==s.guard:GetName() end
  end
  return type(target.GetName)=="function" and target:GetName()==s.guard:GetName()
end

local function updateSiteState(d)
  local s=state.site[d.id]
  if s.guard and s.guard:IsAlive() and s.guardStart then
    local c=s.guard:GetCoordinate(); if c then s.guardMove=s.guardStart:Get2DDistance(c) end
  end
  if s.qrf and s.qrf:IsAlive() and s.target then
    local c=s.qrf:GetCoordinate()
    if c then
      s.qrfCurrent=c:Get2DDistance(s.target)
      if not s.qrfInitial then s.qrfInitial=s.qrfCurrent end
      s.qrfProgress=s.qrfInitial-s.qrfCurrent
    end
  end
  local incident=baseIncident(d.id); if incident then s.incident=true; s.demandCount=#incident.demandIds end
end

local function allGuardsPassed()
  for _,d in ipairs(sites) do
    local s=state.site[d.id]; updateSiteState(d)
    if not s.guardObserved or not s.guard or not s.guard:IsAlive() or (s.guardMove or 0)<MIN_M then return false end
  end
  return true
end

local function releaseFixtures()
  if state.released or state.failed then return end
  for _,d in ipairs(sites) do
    local f=GROUP:FindByName(d.fixture); if not f then fail("FIXTURE_GROUP_MISSING "..d.fixture); return end
    if f:IsAlive()~=true then f:Activate() end
  end
  state.released=true
  announce("ARMED","6/6 Guards passed >=25 m; six late-activated RED acceptance fixtures released for physical MOOSE evidence",20)
end

local function telemetry()
  if state.failed or state.passed or not state.runtime then return end
  if not state.released and allGuardsPassed() then releaseFixtures() end
  for _,d in ipairs(sites) do
    local s=state.site[d.id]
    local f=GROUP:FindByName(d.fixture)
    if state.released and f and f:IsAlive() and not s.target then s.target=f:GetCoordinate() end
    updateSiteState(d)
    log(string.format("SITE_TELEMETRY siteId=%s guardObserved=%s guardMoveM=%.1f incident=%s demandCount=%s qrfObserved=%s qrfAttribute=%s qrfProgressM=%.1f",
      d.id,tostring(s.guardObserved),s.guardMove or 0,tostring(s.incident),tostring(s.demandCount),tostring(s.qrfObserved),tostring(s.qrfAttribute),s.qrfProgress or 0))
  end
end

local function evaluate()
  if state.failed or state.passed then return end
  telemetry()
  local bad={}; local pending=false
  for _,d in ipairs(sites) do
    local s=state.site[d.id]
    if not s.guardPassed then pending=true end
    if not s.incident then pending=true elseif s.demandCount~=1 then bad[#bad+1]=d.id..":DEMAND_COUNT_"..tostring(s.demandCount) end
    if not s.qrfObserved then pending=true
    elseif s.qrfAttribute~=GROUP.Attribute.GROUND_APC then bad[#bad+1]=d.id..":QRF_ATTRIBUTE"
    elseif not s.qrf or not s.qrf:IsAlive() then bad[#bad+1]=d.id..":QRF_NOT_ALIVE"
    elseif (s.qrfProgress or 0)<MIN_M then pending=true end
  end
  if #bad>0 then fail(table.concat(bad,",")); return end
  if not pending and state.released then
    state.passed=true; announce("PASS","6/6 Guards >=25 m before hostile release; 6/6 physical MOOSE alarm incidents; one initial QRF demand each; 6/6 Ground_APC QRFs progressed >=25 m",35); return
  end
  if state.startedAt and timer.getTime()-state.startedAt>TEST_TIMEOUT_SEC then fail("TIMEOUT_INCOMPLETE_SIX_SITE_PHYSICAL_CHAIN") end
end

local function buildBrigades(package)
  for _,d in ipairs(sites) do
    local site=package.SiteRegistry.Sites[d.id]; state.site[d.id]={guardMove=0,qrfProgress=0,guardPassed=false}
    local b=BRIGADE:New(site.warehouseName,"BDE_FSSR_A3_"..d.id)
    local g=PLATOON:New(site.guardTemplateName,1,"PLT_FSSR_A3_GUARD_"..d.id)
    local q=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A3_QRF_"..d.id)
    g:AddMissionCapability(AUFTRAG.Type.ONGUARD,100); q:AddMissionCapability(AUFTRAG.Type.ONGUARD,100); b:AddPlatoon(g); b:AddPlatoon(q)
    local s=state.site[d.id]; local previous=b.OnAfterArmyOnMission
    b.OnAfterArmyOnMission=function(self,From,Event,To,armyGroup,mission)
      if previous then previous(self,From,Event,To,armyGroup,mission) end
      local grp=armyGroup and armyGroup:GetGroup() or nil; if not grp then return end
      local a=grp:GetAttribute(); log("ARMY_ON_MISSION siteId="..d.id.." group="..tostring(grp:GetName()).." attribute="..tostring(a))
      if a==GROUP.Attribute.GROUND_INFANTRY then s.guard=grp; s.guardStart=grp:GetCoordinate(); s.guardObserved=true
      elseif a==GROUP.Attribute.GROUND_APC then s.qrf=grp; s.qrfObserved=true; s.qrfAttribute=a end
    end
    state.brigades[d.id]=b
  end
end

local function start()
  local p=OMW and OMW.FireSupStratResupply; if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then fail("BLUE_TEMPLATE_MISSING"); return end
  for _,d in ipairs(sites) do if not GROUP:FindByName(d.fixture) then fail("FIXTURE_GROUP_MISSING "..d.fixture); return end end
  buildBrigades(p)
  local alarmSites={}
  for _,d in ipairs(sites) do
    local zone={}; function zone:IsCoordinateInZone(_) return false end
    alarmSites[d.id]={alarmZone=zone,targetInAlarmZone=function(target) return targetBelongsToGuard(d.id,target) end}
  end
  local ok,r=pcall(function() return p.New({
    brigades=state.brigades,
    resolveGuardPathline=function(n) return PATHLINE:FindByName(n) end,
    resolveGuardTemplateGroup=function(n) return GROUP:FindByName(n) end,
    guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
    resolveQrfCoordinate=function(demand,context) local i=context and context.incident; local c=i and i.context; return c and c.position or nil,"INCIDENT_POSITION_UNAVAILABLE" end,
    qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
    blueCoalition=coalition.side.BLUE,redCoalition=coalition.side.RED,
    alarmEvidence={sites=alarmSites},logger=log,
  }):Prepare() end)
  if not ok or not r then fail("RUNTIME_PREPARE_FAILED "..tostring(r)); return end
  state.runtime=r
  local _,started,reason=r:StartAlarmEvidence(); if started~=true then fail("ALARM_EVIDENCE_START_FAILED "..tostring(reason)); return end
  for _,b in pairs(state.brigades) do b:Start() end
  for _,d in ipairs(sites) do local _,created,reason=r:StartSite(d.id,{}); if created==false then fail(d.id.." GUARD_START_FAILED "..tostring(reason)); return end end
  state.startedAt=timer.getTime()
  announce("READY","six Guard/QRF organisations and physical MOOSE evidence handlers active; RED fixtures remain late-activated until all Guards pass >=25 m",20)
  SCHEDULER:New(nil,function()
    for _,d in ipairs(sites) do local s=state.site[d.id]; updateSiteState(d); if s.guardObserved and s.guard and s.guard:IsAlive() and (s.guardMove or 0)>=MIN_M then s.guardPassed=true end end
    evaluate()
  end,{},TELEMETRY_SEC,TELEMETRY_SEC)
end

SCHEDULER:New(nil,start,{},10)
