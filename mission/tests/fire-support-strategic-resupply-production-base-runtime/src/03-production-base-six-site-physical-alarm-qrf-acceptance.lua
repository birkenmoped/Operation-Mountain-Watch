-- Operation Mountain Watch - Production Base Acceptance 3.
-- Acceptance-only six-site physical alarm evidence -> incident -> local QRF.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A3]"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local MIN_M=25
local sites={
  {id="JALALABAD_FENTY",fixture="BadGuys_A3_FENTY",zone="ZON_TEST_A3_FENTY_ALARM"},
  {id="COP_FORTRESS",fixture="BadGuys_A3_FORTRESS",zone="ZON_TEST_A3_FORTRESS_ALARM"},
  {id="FOB_JOYCE",fixture="BadGuys_A3_JOYCE",zone="ZON_TEST_A3_JOYCE_ALARM"},
  {id="FOB_WRIGHT",fixture="BadGuys_A3_WRIGHT",zone="ZON_TEST_A3_WRIGHT_ALARM"},
  {id="COP_HONAKER",fixture="BadGuys_A3_HONAKER",zone="ZON_TEST_A3_HONAKER_ALARM"},
  {id="FOB_BOSTICK",fixture="BadGuys_A3_BOSTICK",zone="ZON_TEST_A3_BOSTICK_ALARM"},
}
local state={failed=false,passed=false,runtime=nil,brigades={},site={}}
local function log(m) env.info(TAG.." "..tostring(m),false) end
local function announce(k,m,t) local x="[PRODUCTION BASE A3]["..k.."] "..m; log(x); MESSAGE:New(x,t or 10):ToAll() end
local function fail(m) if not state.failed and not state.passed then state.failed=true; announce("FAIL",m,30) end end

local function baseIncident(siteId)
  local p=OMW.FireSupStratResupply
  local site=p.SiteRegistry.Sites[siteId]
  local sourceId=string.format("INSTALLATION-ATTACK|%s|1",site.installationId)
  local id=p.IdContract.Incident(siteId,sourceId)
  return state.runtime:GetBase():GetIncident(id)
end

local function telemetry()
  if state.failed or state.passed or not state.runtime then return end
  for _,d in ipairs(sites) do
    local s=state.site[d.id]
    if s.guard and s.guard:IsAlive() and s.guardStart then local c=s.guard:GetCoordinate(); if c then s.guardMove=s.guardStart:Get2DDistance(c) end end
    if s.qrf and s.qrf:IsAlive() and s.target then local c=s.qrf:GetCoordinate(); if c then s.qrfCurrent=c:Get2DDistance(s.target); s.qrfProgress=(s.qrfInitial or s.qrfCurrent)-s.qrfCurrent end end
    local incident=baseIncident(d.id); if incident then s.incident=true; s.demandCount=#incident.demandIds end
    log(string.format("SITE_TELEMETRY siteId=%s guardMoveM=%.1f incident=%s demandCount=%s qrfObserved=%s qrfProgressM=%.1f",d.id,s.guardMove or 0,tostring(s.incident),tostring(s.demandCount),tostring(s.qrfObserved),s.qrfProgress or 0))
  end
end

local function finish()
  if state.failed or state.passed then return end
  telemetry(); local bad={}
  for _,d in ipairs(sites) do
    local s=state.site[d.id]
    if not s.guardObserved or not s.guard or not s.guard:IsAlive() or (s.guardMove or 0)<MIN_M then bad[#bad+1]=d.id..":GUARD" end
    if not s.incident or s.demandCount~=1 then bad[#bad+1]=d.id..":INCIDENT" end
    if not s.qrfObserved or not s.qrf or not s.qrf:IsAlive() or s.qrfAttribute~=GROUP.Attribute.GROUND_APC or (s.qrfProgress or 0)<MIN_M then bad[#bad+1]=d.id..":QRF" end
  end
  if #bad>0 then fail(table.concat(bad,",")); return end
  state.passed=true
  announce("PASS","6/6 Guards >=25 m; 6/6 physical alarm incidents; exactly one initial QRF demand each; 6/6 Ground_APC QRFs progressed >=25 m",35)
end

local function buildBrigades(package)
  for _,d in ipairs(sites) do
    local site=package.SiteRegistry.Sites[d.id]
    local b=BRIGADE:New(site.warehouseName,"BDE_FSSR_A3_"..d.id)
    local g=PLATOON:New(site.guardTemplateName,1,"PLT_FSSR_A3_GUARD_"..d.id)
    local q=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A3_QRF_"..d.id)
    g:AddMissionCapability(AUFTRAG.Type.ONGUARD,100); q:AddMissionCapability(AUFTRAG.Type.ONGUARD,100); b:AddPlatoon(g); b:AddPlatoon(q)
    state.site[d.id]={guardMove=0,qrfProgress=0}
    local s=state.site[d.id]; local previous=b.OnAfterArmyOnMission
    b.OnAfterArmyOnMission=function(self,From,Event,To,armyGroup,mission)
      if previous then previous(self,From,Event,To,armyGroup,mission) end
      local grp=armyGroup and armyGroup:GetGroup() or nil; if not grp then return end
      local a=grp:GetAttribute(); log("ARMY_ON_MISSION siteId="..d.id.." group="..tostring(grp:GetName()).." attribute="..tostring(a))
      if a==GROUP.Attribute.GROUND_INFANTRY then s.guard=grp; s.guardStart=grp:GetCoordinate(); s.guardObserved=true
      elseif a==GROUP.Attribute.GROUND_APC then s.qrf=grp; s.qrfAttribute=a; s.qrfObserved=true; local c=grp:GetCoordinate(); if c and s.target then s.qrfInitial=c:Get2DDistance(s.target); s.qrfCurrent=s.qrfInitial end end
    end
    state.brigades[d.id]=b
  end
end

local function start()
  local p=OMW and OMW.FireSupStratResupply
  if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then fail("BLUE_TEMPLATE_MISSING"); return end
  buildBrigades(p)
  local alarmSites={}
  for _,d in ipairs(sites) do local z=ZONE:FindByName(d.zone); if not z then fail("TEST_ZONE_MISSING "..d.zone); return end; alarmSites[d.id]={alarmZone=z} end
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
  for _,d in ipairs(sites) do local f=GROUP:FindByName(d.fixture); if not f then fail("FIXTURE_GROUP_MISSING "..d.fixture); return end; if f:IsAlive()~=true then f:Activate() end; SCHEDULER:New(nil,function() if f:IsAlive() then state.site[d.id].target=f:GetCoordinate() end end,{},2) end
  announce("READY","six-site physical alarm evidence handlers active; six late-activated RED acceptance fixtures released",20)
  SCHEDULER:New(nil,telemetry,{},30,30)
  SCHEDULER:New(nil,finish,{},600)
end

SCHEDULER:New(nil,start,{},10)
