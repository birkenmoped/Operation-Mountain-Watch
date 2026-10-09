local Factory=dofile("scripts/campaign/OMW_FireSupStratResupply_CasMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
local calls={cas={},patrol={}}
AUFTRAG={}
function AUFTRAG:NewCAS(zone,altitude,speed,coordinate,heading,leg,targetTypes)
  calls.cas[#calls.cas+1]={zone=zone,altitude=altitude,speed=speed,coordinate=coordinate,heading=heading,leg=leg,targetTypes=targetTypes}
  local m={cancelCount=0}
  function m:SetTeleport(v) self.teleport=v return self end
  function m:SetRequiredAssets(a,b) self.min=a;self.max=b;return self end
  function m:SetRequiredAttribute(v) self.requiredAttributes=v;return self end
  function m:SetRequiredProperty(v) self.requiredProperties=v;return self end
  function m:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function m:Cancel() self.cancelCount=self.cancelCount+1 end
  return m
end
function AUFTRAG:NewPATROLZONE(zone,speed,altitude)
  calls.patrol[#calls.patrol+1]={zone=zone,speed=speed,altitude=altitude}
  local m={cancelCount=0}
  function m:SetEngageDetected(range,targetTypes,engageZone,noEngageZoneSet)
    self.engage={range=range,targetTypes=targetTypes,engageZone=engageZone,noEngageZoneSet=noEngageZoneSet}
    return self
  end
  function m:SetTeleport(v) self.teleport=v return self end
  function m:SetRequiredAssets(a,b) self.min=a;self.max=b;return self end
  function m:SetRequiredAttribute(v) self.requiredAttributes=v;return self end
  function m:SetRequiredProperty(v) self.requiredProperties=v;return self end
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
eq(#calls.cas,1,"NewCAS once")
eq(#calls.patrol,0,"PATROLZONE not used for default CAS")
eq(calls.cas[1].zone,zone,"CAS tactical zone")
eq(calls.cas[1].altitude,9000,"CAS altitude")
eq(calls.cas[1].speed,220,"CAS speed")
eq(calls.cas[1].coordinate,orbit,"CAS orbit")
eq(calls.cas[1].heading,45,"CAS heading")
eq(calls.cas[1].leg,6,"CAS leg")
eq(calls.cas[1].targetTypes,targetTypes,"CAS target types")
eq(mission.teleport,false,"CAS teleport disabled")
eq(mission.min,1,"CAS required min")
eq(mission.max,1,"CAS required max")
eq(mission.priority,9,"CAS priority")
eq(mission.urgent,false,"CAS not made urgent by factory")

local configured=false
local patrolFactory=Factory.New({
  requiredAssetsMin=2,
  requiredAssetsMax=2,
  resolveGeometry=function()
    return {
      missionMode=Factory.MissionMode.PATROLZONE_ENGAGE,
      zone=zone,
      altitudeFt=7200,
      speedKts=125,
      engageDetectedRangeNm=5,
      engageDetectedTargetTypes={"Ground Units"},
      requiredAttributes="Air_AttackHelo",
      requiredProperties={"OMW_CAS_ROUTE_PROFILE"},
      configureMission=function(m,g,d,c)
        configured=true
        eq(g.zone,zone,"configurator geometry")
        eq(d.demandId,"D|CAS|PATROL","configurator demand")
        eq(c.marker,"STAGE3","configurator context")
        m.configured=true
      end,
    }
  end,
})
local patrolDemand={demandId="D|CAS|PATROL",siteId="COP_HONAKER",supportType="CAS",priority=7}
local patrolMission,patrolCreated,patrolReason=patrolFactory:Create(patrolDemand,{marker="STAGE3"})
yes(patrolCreated,"PATROLZONE CAS created")
eq(patrolReason,nil,"PATROLZONE CAS reason")
eq(#calls.patrol,1,"NewPATROLZONE once")
eq(calls.patrol[1].zone,zone,"PATROLZONE tactical zone")
eq(calls.patrol[1].speed,125,"PATROLZONE speed")
eq(calls.patrol[1].altitude,7200,"PATROLZONE altitude")
eq(patrolMission.engage.range,5,"PATROLZONE engage range")
eq(patrolMission.engage.targetTypes[1],"Ground Units","PATROLZONE target type")
eq(patrolMission.engage.engageZone,zone,"PATROLZONE engage zone")
eq(patrolMission.engage.noEngageZoneSet,nil,"PATROLZONE no-engage set")
eq(patrolMission.teleport,false,"PATROLZONE teleport disabled")
eq(patrolMission.min,2,"PATROLZONE required min")
eq(patrolMission.max,2,"PATROLZONE required max")
eq(patrolMission.priority,7,"PATROLZONE priority")
eq(patrolMission.requiredAttributes,"Air_AttackHelo","PATROLZONE required attribute")
eq(patrolMission.requiredProperties[1],"OMW_CAS_ROUTE_PROFILE","PATROLZONE required property")
yes(configured,"PATROLZONE mission configurator called")
yes(patrolMission.configured,"PATROLZONE configurator changed mission")

local unavailableFactory=Factory.New({resolveGeometry=function() return nil,"C2_CAS_GEOMETRY_NOT_CONFIRMED" end})
local noMission,noCreated,noReason=unavailableFactory:Create({demandId="D|CAS|2",siteId="COP_HONAKER",supportType="CAS"},{})
eq(noMission,nil,"unavailable geometry no mission")
no(noCreated,"unavailable not created")
eq(noReason,"C2_CAS_GEOMETRY_NOT_CONFIRMED","unavailable reason")
eq(#calls.cas,1,"unavailable geometry does not call NewCAS")
eq(#calls.patrol,1,"unavailable geometry does not call NewPATROLZONE")

local badModeFactory=Factory.New({resolveGeometry=function() return {zone=zone,missionMode="UNKNOWN"} end})
local okBadMode=pcall(function() badModeFactory:Create({demandId="D|CAS|BADMODE",siteId="COP_HONAKER",supportType="CAS"},{}) end)
no(okBadMode,"unknown mission mode rejected")
local missingRangeFactory=Factory.New({resolveGeometry=function() return {zone=zone,missionMode=Factory.MissionMode.PATROLZONE_ENGAGE} end})
local okMissingRange=pcall(function() missingRangeFactory:Create({demandId="D|CAS|NORANGE",siteId="COP_HONAKER",supportType="CAS"},{}) end)
no(okMissingRange,"PATROLZONE engage range required")

AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_cas_mission_factory")
