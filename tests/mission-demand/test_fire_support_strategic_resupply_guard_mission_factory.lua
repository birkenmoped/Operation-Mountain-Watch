local Factory = dofile("scripts/campaign/OMW_FireSupStratResupply_GuardMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
local created={}
AUFTRAG={}
function AUFTRAG:NewONGUARD(coordinate)
  local mission={coordinate=coordinate,cancelCount=0}
  function mission:SetTeleport(v) self.teleport=v return self end
  function mission:SetRequiredAssets(a,b) self.requiredMin=a;self.requiredMax=b;return self end
  function mission:SetRequiredAttribute(v) self.requiredAttributes=v;return self end
  function mission:SetRequiredProperty(v) self.requiredProperties=v;return self end
  function mission:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function mission:Cancel() self.cancelCount=self.cancelCount+1 end
  created[#created+1]=mission
  return mission
end

local lead={marker="LEAD"}
local materializer={}
function materializer:GetLeadCoordinate() return lead end
local tracked=nil
local routeAdapter={}
function routeAdapter:TrackMission(mission) tracked=mission return self end

local factory=Factory.New({materializers={FOB_JOYCE=materializer},routeAdapters={FOB_JOYCE=routeAdapter}})
local demand={demandId="SITE|FOB_JOYCE|GUARD|PERSISTENT",siteId="FOB_JOYCE",supportType="GUARD",priority=33}
local mission,made,reason=factory:Create(demand,{}, {})
yes(made,"Guard mission created")
eq(reason,nil,"Guard create reason")
eq(mission.coordinate,lead,"ONGUARD lead coordinate")
eq(mission.teleport,false,"visible teleport disabled")
eq(mission.requiredMin,1,"required min")
eq(mission.requiredMax,1,"required max")
eq(mission.requiredAttributes,nil,"no implicit Guard attribute filter")
eq(mission.requiredProperties,nil,"no implicit Guard property filter")
eq(mission.priority,33,"priority forwarded")
eq(mission.urgent,false,"persistent Guard not urgent")
eq(tracked,mission,"route adapter tracks created mission")

local requiredAttributes={"Ground_Infantry"}
local requiredProperties={"Infantry"}
local constrained=Factory.New({
  materializers={FOB_JOYCE=materializer},
  routeAdapters={FOB_JOYCE=routeAdapter},
  requiredAttributes=requiredAttributes,
  requiredProperties=requiredProperties,
})
local constrainedMission,constrainedCreated=constrained:Create(demand,{}, {})
yes(constrainedCreated,"constrained Guard mission created")
eq(constrainedMission.requiredAttributes,requiredAttributes,"MOOSE Guard attribute constraint forwarded")
eq(constrainedMission.requiredProperties,requiredProperties,"MOOSE Guard property constraint forwarded")

local missing,missingCreated,missingReason=factory:Create({demandId="SITE|FOB_BOSTICK|GUARD|PERSISTENT",siteId="FOB_BOSTICK",supportType="GUARD"},{},{})
eq(missing,nil,"missing materializer no mission")
no(missingCreated,"missing materializer not created")
eq(missingReason,"GUARD_MATERIALIZER_NOT_CONFIGURED","missing materializer reason")
eq(#created,2,"no extra mission created")

local ok,err=pcall(function() factory:Create({demandId="QRF",siteId="FOB_JOYCE",supportType="QRF"},{},{}) end)
no(ok,"non-Guard demand rejected")
yes(type(err)=="string" and string.find(err,"supportType GUARD is required",1,true)~=nil,"non-Guard error text")

AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_guard_mission_factory")
