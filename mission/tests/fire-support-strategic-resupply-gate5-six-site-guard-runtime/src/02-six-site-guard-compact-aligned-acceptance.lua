-- Gate 5 Acceptance 2: compact, PATHLINE-aligned Guard materialization.
local ID="FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2"
local TAG="[OMW]["..ID.."]"
local R=OMW_GATE5_SITE_REGISTRY
local SPEED,OBS,STEP,MINMOVE=5,300,30,25
local FORM,INTERVAL,SPACING="Off Road",2,2
local KEYS={"JALALABAD_FENTY","COP_FORTRESS","FOB_JOYCE","FOB_WRIGHT","COP_HONAKER","FOB_BOSTICK"}
local S={failed=false,passed=false,sites={}}
local function log(x) env.info(TAG.." "..tostring(x),false) end
local function msg(t,x,n) local z="[GATE 5]["..t.."] "..x;log(z);MESSAGE:New(z,n or 10):ToAll() end
local function fail(x) if S.failed or S.passed then return end;S.failed=true;msg("FAIL",x,20) end
local function dist(a,b) local x,y=b.x-a.x,b.y-a.y;return math.sqrt(x*x+y*y) end
local function heading(a,b) local h=math.deg(math.atan2(b.y-a.y,b.x-a.x));if h<0 then h=h+360 end;return h end
local function point(a,b,d) local l=dist(a,b);if l<=0 then return nil end;local f=d/l;return{x=a.x+(b.x-a.x)*f,y=a.y+(b.y-a.y)*f} end

local function prepareSpawn(k,s,tpl)
  local c=s.path:GetCoordinates();if type(c)~="table" or #c<2 then return false,"PATHLINE_TOO_SHORT" end
  local n=tpl:GetInitialSize();if type(n)~="number" or n<1 then return false,"TEMPLATE_SIZE_INVALID" end
  local a,b=c[1]:GetVec2(),c[2]:GetVec2();local l=dist(a,b)
  local spacing=math.min(SPACING,(l-1)/math.max(1,n-1));if spacing<0.75 then return false,"FIRST_LEG_TOO_SHORT" end
  local h=heading(a,b);local lead=(n-1)*spacing;s.positions={};s.spacing=spacing;s.heading=h
  for i=1,n do local p=point(a,b,lead-(i-1)*spacing);if not p or s.access:IsVec2InZone(p)~=true then return false,"SPAWN_OUTSIDE_ACCESS_"..i end;s.positions[i]={x=p.x,y=p.y,heading=h} end
  s.lead=COORDINATE:NewFromVec2(s.positions[1])
  log(string.format("COMPACT_SPAWN_PREPARED siteId=%s units=%d spacingM=%.2f headingDeg=%.1f",s.site.siteId,n,spacing,h));return true
end

local function installSpawn(k,s)
  local original=s.bde._SpawnAssetGroundNaval;if type(original)~="function" then return false,"WAREHOUSE_PRIVATE_SPAWN_UNAVAILABLE" end
  if s.bde.ValidateAndRepositionGroundUnits==true then return false,"WAREHOUSE_REPOSITIONING_CONFLICT" end
  s.bde._SpawnAssetGroundNaval=function(self,alias,asset,request,spawnzone,late)
    if not asset or asset.category~=Group.Category.GROUND then return original(self,alias,asset,request,spawnzone,late) end
    local t=self:_SpawnAssetPrepareTemplate(asset,alias);if not t or type(t.units)~="table" or #t.units~=#s.positions then fail(k.." WAREHOUSE_SPAWN_TEMPLATE_INVALID");return nil end
    t.route=t.route or{points={}};t.route.points=t.route.points or{};t.route.points[1]=t.route.points[1] or{}
    for i,p in ipairs(s.positions) do local u=t.units[i];u.x=p.x;u.y=p.y;u.heading=math.rad(p.heading);if asset.livery then u.livery_id=asset.livery end;if asset.skill then u.skill=asset.skill end end
    local p=s.positions[1];t.route.points[1].x=p.x;t.route.points[1].y=p.y;t.x=p.x;t.y=p.y;t.lateActivation=late
    log(string.format("COMPACT_ALIGNED_WAREHOUSE_SPAWN siteId=%s units=%d spacingM=%.2f headingDeg=%.1f",s.site.siteId,#s.positions,s.spacing,s.heading))
    return _DATABASE:Spawn(t)
  end
  return true
end

local function route(g,s)
  local c=s.path:GetCoordinates();if type(c)~="table" or #c<2 then return nil end
  local r={s.lead:WaypointGround(SPEED,FORM)};for i=2,#c do r[#r+1]=c[i]:WaypointGround(SPEED,FORM) end
  g:SetTaskWaypoint(r[#r],g:TaskFunction("CONTROLLABLE.Route",r,2));return r
end

local function setup(k,tpl)
  local site=R.Sites[k];if not site then fail(k.." REGISTRY_MISSING");return false end
  local access=ZONE:FindByName(site.accessZoneName);local path=PATHLINE:FindByName(site.guardRoute.pathlineName)
  if not access then fail(site.accessZoneName.." missing");return false end;if not path then fail(site.guardRoute.pathlineName.." missing");return false end
  local s={site=site,access=access,path=path,movement=0,routeStarted=false};S.sites[k]=s
  local ok,why=prepareSpawn(k,s,tpl);if not ok then fail(k.." "..why);return false end
  s.bde=BRIGADE:New(site.warehouseName,"BDE_G5_GUARD_A2_"..k);s.bde:SetSpawnZone(access)
  ok,why=installSpawn(k,s);if not ok then fail(k.." "..why);return false end
  s.plt=PLATOON:New(site.guardTemplateName,1,"PLT_G5_GUARD_A2_"..k);s.plt:AddMissionCapability(AUFTRAG.Type.ONGUARD,100);s.bde:AddPlatoon(s.plt)
  s.bde.OnAfterArmyOnMission=function(self,From,Event,To,ag,m)
    if m~=s.mission then return end;s.group=ag:GetGroup();if not s.group then fail(k.." GROUP_WRAPPER_MISSING");return end
    s.start=s.group:GetCoordinate();if not s.start then fail(k.." START_COORD_MISSING");return end
    s.group:OptionFormationInterval(INTERVAL);local r=route(s.group,s);if not r then fail(k.." ROUTE_BUILD_FAILED");return end
    s.group:Route(r,2);s.routeStarted=true;msg("GUARD",k.." compact/aligned on "..site.guardRoute.pathlineName,8)
  end
  s.bde.OnAfterStart=function() SCHEDULER:New(nil,function()
    if S.failed then return end;s.mission=AUFTRAG:NewONGUARD(s.lead);s.mission:SetRequiredAssets(1,1);s.mission:SetName("OMW_G5_GUARD_A2_"..k);s.mission:AssignCohort(s.plt);s.bde:AddMission(s.mission);log("GUARD_MISSION_ADDED siteId="..site.siteId.." pathline="..site.guardRoute.pathlineName)
  end,{},3) end
  s.bde:Start();return true
end

local function telemetry()
  for _,k in ipairs(KEYS) do local s=S.sites[k];if s and s.group and s.start and s.group:IsAlive() then local c=s.group:GetCoordinate();if c then s.movement=s.start:Get2DDistance(c) end end;if s then log(string.format("TELEMETRY siteId=%s routeStarted=%s alive=%s movementM=%.1f spawnSpacingM=%.2f",s.site.siteId,tostring(s.routeStarted),tostring(s.group~=nil and s.group:IsAlive()),s.movement or 0,s.spacing or 0)) end end
end
local function finish()
  if S.failed or S.passed then return end;telemetry();local f={}
  for _,k in ipairs(KEYS) do local s=S.sites[k];if not s then f[#f+1]=k..":NO_STATE" else if not s.routeStarted then f[#f+1]=k..":ROUTE_NOT_STARTED" end;if not s.group or not s.group:IsAlive() then f[#f+1]=k..":GUARD_NOT_ALIVE" end;if(s.movement or 0)<MINMOVE then f[#f+1]=string.format("%s:MOVEMENT_%.1f_LT_%d",k,s.movement or 0,MINMOVE) end end end
  if #f>0 then fail("compact/aligned runtime incomplete: "..table.concat(f,", "));return end;S.passed=true;msg("PASS","6/6 Guards compact/aligned and >=25 m movement observed",25)
end
local function start()
  if type(R)~="table" or type(R.Sites)~="table" then fail("registry unavailable");return end;if OMW_GROUND_READY~=1 then fail("Ground Base not ready");return end
  local tpl=GROUP:FindByName(R.GuardTemplateName);if not tpl then fail("Guard template unavailable");return end
  for _,k in ipairs(KEYS) do if not setup(k,tpl) then return end end
  SCHEDULER:New(nil,telemetry,{},STEP,STEP);SCHEDULER:New(nil,finish,{},OBS);msg("READY","compact/aligned six-site Guard acceptance started; 2 m interval; 300 s observation",15)
end
SCHEDULER:New(nil,start,{},10)
