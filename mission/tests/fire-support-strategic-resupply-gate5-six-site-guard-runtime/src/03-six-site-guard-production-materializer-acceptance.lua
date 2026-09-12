-- Gate 5 Acceptance 3: validate the production Guard PATHLINE materialization adapter.
local ID="FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3"
local TAG="[OMW]["..ID.."]"
local R=OMW_GATE5_SITE_REGISTRY
local M=OMW_GUARD_PATHLINE_MATERIALIZATION_ADAPTER
local SPEED,OBS,STEP,MINMOVE=5,300,30,25
local FORM,INTERVAL="Off Road",2
local KEYS={"JALALABAD_FENTY","COP_FORTRESS","FOB_JOYCE","FOB_WRIGHT","COP_HONAKER","FOB_BOSTICK"}
local S={failed=false,passed=false,sites={}}
local function log(x) env.info(TAG.." "..tostring(x),false) end
local function msg(t,x,n) local z="[GATE 5]["..t.."] "..x;log(z);MESSAGE:New(z,n or 10):ToAll() end
local function fail(x) if S.failed or S.passed then return end;S.failed=true;msg("FAIL",x,20) end

local function route(g,s)
  local c=s.path:GetCoordinates();if type(c)~="table" or #c<2 then return nil end
  local r={s.materializer:GetLeadCoordinate():WaypointGround(SPEED,FORM)}
  for i=2,#c do r[#r+1]=c[i]:WaypointGround(SPEED,FORM) end
  g:SetTaskWaypoint(r[#r],g:TaskFunction("CONTROLLABLE.Route",r,2));return r
end

local function setup(k,tpl)
  local site=R.Sites[k];if not site then fail(k.." REGISTRY_MISSING");return false end
  local path=PATHLINE:FindByName(site.guardRoute.pathlineName);if not path then fail(site.guardRoute.pathlineName.." missing");return false end
  local s={site=site,path=path,movement=0,routeStarted=false};S.sites[k]=s
  local ok,materializer=pcall(function()
    return M.New({
      siteId=site.siteId,
      guardTemplateName=site.guardTemplateName,
      pathline=path,
      templateGroup=tpl,
      targetSpacingM=2,
      minimumSpacingM=0.75,
      logger=log,
    }):Prepare()
  end)
  if not ok then fail(k.." MATERIALIZER_PREPARE_FAILED "..tostring(materializer));return false end
  s.materializer=materializer
  s.bde=BRIGADE:New(site.warehouseName,"BDE_G5_GUARD_A3_"..k)
  ok,materializer=pcall(function() return s.materializer:Install(s.bde) end)
  if not ok then fail(k.." MATERIALIZER_INSTALL_FAILED "..tostring(materializer));return false end
  s.plt=PLATOON:New(site.guardTemplateName,1,"PLT_G5_GUARD_A3_"..k);s.plt:AddMissionCapability(AUFTRAG.Type.ONGUARD,100);s.bde:AddPlatoon(s.plt)
  s.bde.OnAfterArmyOnMission=function(self,From,Event,To,ag,m)
    if m~=s.mission then return end;s.group=ag:GetGroup();if not s.group then fail(k.." GROUP_WRAPPER_MISSING");return end
    s.start=s.group:GetCoordinate();if not s.start then fail(k.." START_COORD_MISSING");return end
    s.group:OptionFormationInterval(INTERVAL);local r=route(s.group,s);if not r then fail(k.." ROUTE_BUILD_FAILED");return end
    s.group:Route(r,2);s.routeStarted=true;msg("GUARD",k.." production materializer active on "..site.guardRoute.pathlineName,8)
  end
  s.bde.OnAfterStart=function() SCHEDULER:New(nil,function()
    if S.failed then return end;s.mission=AUFTRAG:NewONGUARD(s.materializer:GetLeadCoordinate());s.mission:SetRequiredAssets(1,1);s.mission:SetName("OMW_G5_GUARD_A3_"..k);s.mission:AssignCohort(s.plt);s.bde:AddMission(s.mission);log("GUARD_MISSION_ADDED siteId="..site.siteId.." pathline="..site.guardRoute.pathlineName)
  end,{},3) end
  s.bde:Start();return true
end

local function telemetry()
  for _,k in ipairs(KEYS) do
    local s=S.sites[k]
    if s and s.group and s.start and s.group:IsAlive() then local c=s.group:GetCoordinate();if c then s.movement=s.start:Get2DDistance(c) end end
    if s then local _,spacing=s.materializer:GetSpawnGeometry();log(string.format("TELEMETRY siteId=%s routeStarted=%s alive=%s movementM=%.1f spawnSpacingM=%.2f",s.site.siteId,tostring(s.routeStarted),tostring(s.group~=nil and s.group:IsAlive()),s.movement or 0,spacing or 0)) end
  end
end

local function finish()
  if S.failed or S.passed then return end;telemetry();local f={}
  for _,k in ipairs(KEYS) do local s=S.sites[k];if not s then f[#f+1]=k..":NO_STATE" else if not s.routeStarted then f[#f+1]=k..":ROUTE_NOT_STARTED" end;if not s.group or not s.group:IsAlive() then f[#f+1]=k..":GUARD_NOT_ALIVE" end;if(s.movement or 0)<MINMOVE then f[#f+1]=string.format("%s:MOVEMENT_%.1f_LT_%d",k,s.movement or 0,MINMOVE) end end end
  if #f>0 then fail("production materializer runtime incomplete: "..table.concat(f,", "));return end
  S.passed=true;msg("PASS","6/6 Guards production materializer >=25 m movement observed",25)
end

local function start()
  if type(R)~="table" or type(R.Sites)~="table" then fail("registry unavailable");return end
  if type(M)~="table" or M.SchemaVersion~="OMW-GUARD-PATHLINE-MATERIALIZATION-ADAPTER-1" then fail("production materializer unavailable");return end
  if OMW_GROUND_READY~=1 then fail("Ground Base not ready");return end
  local tpl=GROUP:FindByName(R.GuardTemplateName);if not tpl then fail("Guard template unavailable");return end
  for _,k in ipairs(KEYS) do if not setup(k,tpl) then return end end
  SCHEDULER:New(nil,telemetry,{},STEP,STEP);SCHEDULER:New(nil,finish,{},OBS);msg("READY","production Guard materializer acceptance started; PATHLINE materialization; 2 m interval; 300 s observation",15)
end
SCHEDULER:New(nil,start,{},10)
