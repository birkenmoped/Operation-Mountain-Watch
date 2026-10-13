local Adapter = dofile("scripts/ground/OMW_GuardPathlineRouteAdapter.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local function coord(name)
  local c={name=name}
  function c:WaypointGround(speed,formation) return {name=self.name,speed=speed,formation=formation} end
  return c
end
local lead=coord("lead")
local p1,p2,p3=coord("p1"),coord("p2"),coord("p3")
local path={}
function path:GetCoordinates() return {p1,p2,p3} end
local materializer={}
function materializer:GetLeadCoordinate() return lead end

local group={interval=nil,taskWaypoint=nil,task=nil,route=nil,delay=nil}
function group:OptionFormationInterval(v) self.interval=v end
function group:TaskFunction(name,route,delay) return {name=name,route=route,delay=delay} end
function group:SetTaskWaypoint(wp,task) self.taskWaypoint=wp;self.task=task end
function group:Route(route,delay) self.route=route;self.delay=delay end
local army={}
function army:GetGroup() return group end

local previousCount=0
local brigade={}
function brigade:OnAfterArmyOnMission() previousCount=previousCount+1 end
local adapter=Adapter.New({siteId="FOB_JOYCE",pathline=path,materializer=materializer})
local _,installed=adapter:Install(brigade);yes(installed,"first install")
local _,installedAgain=adapter:Install(brigade);no(installedAgain,"second install idempotent")

local tracked={id="guard"};local unrelated={id="qrf"}
adapter:TrackMission(tracked)
brigade:OnAfterArmyOnMission("Running","ArmyOnMission","Running",army,unrelated)
eq(previousCount,1,"previous callback chained for unrelated mission")
eq(group.route,nil,"unrelated mission route untouched")
brigade:OnAfterArmyOnMission("Running","ArmyOnMission","Running",army,tracked)
eq(previousCount,2,"previous callback chained for tracked mission")
eq(group.interval,2,"formation interval")
eq(#group.route,3,"route point count")
eq(group.route[1].name,"lead","route starts at materialized lead")
eq(group.route[2].name,"p2","route continues at PATHLINE point two")
eq(group.route[3].name,"p3","route ends at PATHLINE final point")
eq(group.route[1].speed,5,"route speed")
eq(group.route[1].formation,"Off Road","route formation")
eq(group.taskWaypoint,group.route[3],"loop task attached to last waypoint")
eq(group.task.name,"CONTROLLABLE.Route","accepted route restart task")
eq(group.task.route,group.route,"restart uses same route")
eq(group.task.delay,2,"restart task delay")
eq(group.delay,2,"initial route delay")

local _,applied,reason=adapter:Apply(army,unrelated)
no(applied,"untracked mission apply rejected")
eq(reason,"MISSION_NOT_TRACKED","untracked reason")

print("PASS test_guard_pathline_route_adapter")
