local Factory=dofile("scripts/campaign/OMW_FireSupStratResupply_CasMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
local calls={}
AUFTRAG={}
function AUFTRAG:NewCAS(zone,altitude,speed,coordinate,heading,leg,targetTypes)
  calls[#calls+1]={zone=zone,altitude=altitude,speed=speed,coordinate=coordinate,heading=heading,leg=leg,targetTypes=targetTypes}
  local m={cancelCount=0}
  function m:SetTeleport(v) self.teleport=v return self end
  function m:SetRequiredAssets(a,b) self.min=a;self.max=b;return self end
  function m:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function m:Cancel() self.cancelCount=self.cancelCount+1 end
  return m
end

local zone={marker="TACTICAL_CAS_ZONE"}
local orbit={marker="ORBIT"}
local targetTypes={"Ground Units"}
local factory=Factory.New({
  resolveGeometry=function(demand,context)
    eq(context.marker,"C2_CAS_TARGET","resolver context")
    return {zone=zone,altitudeFt=9000,speedKts=220,orbitCoordinate=orbit,headingDeg=45,legNm=6,targetTypes=targetTypes}
  end,
})
local demand={demandId="D|CAS|1",siteId="COP_HONAKER",supportType="CAS",priority=9}
local mission,created,reason=factory:Create(demand,{marker="C2_CAS_TARGET"})
yes(created,"CAS created")
eq(reason,nil,"CAS reason")
eq(#calls,1,"NewCAS once")
eq(calls[1].zone,zone,"CAS tactical zone")
eq(calls[1].altitude,9000,"CAS altitude")
eq(calls[1].speed,220,"CAS speed")
eq(calls[1].coordinate,orbit,"CAS orbit")
eq(calls[1].heading,45,"CAS heading")
eq(calls[1].leg,6,"CAS leg")
eq(calls[1].targetTypes,targetTypes,"CAS target types")
eq(mission.teleport,false,"CAS teleport disabled")
eq(mission.min,1,"CAS required min")
eq(mission.max,1,"CAS required max")
eq(mission.priority,9,"CAS priority")
eq(mission.urgent,false,"CAS not made urgent by factory")

local unavailableFactory=Factory.New({resolveGeometry=function() return nil,"C2_CAS_GEOMETRY_NOT_CONFIRMED" end})
local noMission,noCreated,noReason=unavailableFactory:Create({demandId="D|CAS|2",siteId="COP_HONAKER",supportType="CAS"},{})
eq(noMission,nil,"unavailable geometry no mission")
no(noCreated,"unavailable not created")
eq(noReason,"C2_CAS_GEOMETRY_NOT_CONFIRMED","unavailable reason")
eq(#calls,1,"unavailable geometry does not call MOOSE")

AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_cas_mission_factory")
