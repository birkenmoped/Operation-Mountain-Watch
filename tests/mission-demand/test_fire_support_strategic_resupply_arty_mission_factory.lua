local Factory=dofile("scripts/campaign/OMW_FireSupStratResupply_ArtyMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
local calls={}
AUFTRAG={}
function AUFTRAG:NewARTY(coordinate,shots,radius,altitude)
  calls[#calls+1]={coordinate=coordinate,shots=shots,radius=radius,altitude=altitude}
  local m={cancelCount=0}
  function m:SetTeleport(v) self.teleport=v return self end
  function m:SetRequiredAssets(a,b) self.min=a;self.max=b;return self end
  function m:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function m:Cancel() self.cancelCount=self.cancelCount+1 end
  return m
end

local targetCoordinate={marker="TARGET"}
local factory=Factory.New({
  resolveTarget=function(demand,context)
    eq(context.marker,"C2_TARGET","resolver context")
    return {coordinate=targetCoordinate,shots=4,radiusM=75,altitudeM=1200}
  end,
})
local demand={demandId="D|ARTY|1",siteId="COP_HONAKER",supportType="ARTY",priority=8}
local mission,created,reason=factory:Create(demand,{marker="C2_TARGET"})
yes(created,"ARTY created")
eq(reason,nil,"ARTY reason")
eq(#calls,1,"NewARTY once")
eq(calls[1].coordinate,targetCoordinate,"target coordinate")
eq(calls[1].shots,4,"shots")
eq(calls[1].radius,75,"radius")
eq(calls[1].altitude,1200,"altitude")
eq(mission.teleport,false,"teleport disabled")
eq(mission.min,1,"required min")
eq(mission.max,1,"required max")
eq(mission.priority,8,"priority")
eq(mission.urgent,false,"not urgent by factory")

local unavailableFactory=Factory.New({resolveTarget=function() return nil,"C2_ARTY_TARGET_NOT_CONFIRMED" end})
local noMission,noCreated,noReason=unavailableFactory:Create({demandId="D|ARTY|2",siteId="COP_HONAKER",supportType="ARTY"},{})
eq(noMission,nil,"unavailable target no mission")
no(noCreated,"unavailable not created")
eq(noReason,"C2_ARTY_TARGET_NOT_CONFIRMED","unavailable reason")
eq(#calls,1,"unavailable target does not call MOOSE")

AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_arty_mission_factory")
