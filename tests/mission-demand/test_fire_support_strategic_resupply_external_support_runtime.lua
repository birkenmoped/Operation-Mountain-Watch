local Runtime=dofile("scripts/campaign/OMW_FireSupStratResupply_ExternalSupportRuntime.lua")
local CommanderBridge=dofile("scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua")
local ArtyFactory=dofile("scripts/campaign/OMW_FireSupStratResupply_ArtyMissionFactory.lua")
local CasFactory=dofile("scripts/campaign/OMW_FireSupStratResupply_CasMissionFactory.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local previousAuftrag=AUFTRAG
AUFTRAG={}
local function mission(kind,target)
  local m={kind=kind,target=target,cancelCount=0}
  function m:SetTeleport(v) self.teleport=v return self end
  function m:SetRequiredAssets(a,b) self.min=a;self.max=b;return self end
  function m:SetPriority(p,u) self.priority=p;self.urgent=u;return self end
  function m:Cancel() self.cancelCount=self.cancelCount+1 end
  return m
end
function AUFTRAG:NewARTY(coord,shots,radius,altitude) local m=mission("ARTY",coord);m.shots=shots;m.radius=radius;m.altitude=altitude;return m end
function AUFTRAG:NewCAS(zone,altitude,speed,coordinate,heading,leg,targetTypes) local m=mission("CAS",zone);m.altitude=altitude;m.speed=speed;m.coordinate=coordinate;m.heading=heading;m.leg=leg;m.targetTypes=targetTypes;return m end

local commander={missions={}}
function commander:AddMission(m) self.missions[#self.missions+1]=m return self end
local artyCoord={marker="ARTY_TARGET"}
local casZone={marker="CAS_TACTICAL_ZONE"}
local runtime=Runtime.New({
  commander=commander,
  commanderBridge=CommanderBridge,
  artyMissionFactory=ArtyFactory,
  casMissionFactory=CasFactory,
  resolveArtyTarget=function(demand,context)
    if context.noTarget then return nil,"C2_ARTY_TARGET_NOT_CONFIRMED" end
    return {coordinate=artyCoord,shots=6,radiusM=100}
  end,
  resolveCasGeometry=function(demand,context)
    if context.noTarget then return nil,"C2_CAS_GEOMETRY_NOT_CONFIRMED" end
    return {zone=casZone,altitudeFt=10000,speedKts=250}
  end,
})
local adapters=runtime:GetAdapters()
yes(adapters.ARTY~=nil,"ARTY adapter")
yes(adapters.CAS~=nil,"CAS adapter")
eq(runtime:GetAdapter("ARTY"),adapters.ARTY,"ARTY lookup")
eq(runtime:GetAdapter("CAS"),adapters.CAS,"CAS lookup")
eq(runtime:GetAdapter("QRF"),nil,"non-external lookup")

local arty,artyCreated,artyReason=adapters.ARTY:Dispatch({demandId="D|ARTY",siteId="COP_HONAKER",supportType="ARTY",priority=7},{})
yes(artyCreated,"ARTY queued")
eq(artyReason,nil,"ARTY reason")
eq(#commander.missions,1,"one ARTY commander mission")
eq(commander.missions[1].kind,"ARTY","ARTY mission type")
eq(commander.missions[1].target,artyCoord,"ARTY target")
eq(commander.missions[1].teleport,false,"ARTY teleport disabled")

local cas,casCreated,casReason=adapters.CAS:Dispatch({demandId="D|CAS",siteId="COP_HONAKER",supportType="CAS",priority=8},{})
yes(casCreated,"CAS queued")
eq(casReason,nil,"CAS reason")
eq(#commander.missions,2,"CAS also queued")
eq(commander.missions[2].kind,"CAS","CAS mission type")
eq(commander.missions[2].target,casZone,"CAS tactical zone")
eq(commander.missions[2].teleport,false,"CAS teleport disabled")

local refused,refusedCreated,refusedReason=adapters.ARTY:Dispatch({demandId="D|ARTY|NO",siteId="COP_HONAKER",supportType="ARTY"},{noTarget=true})
eq(refused,nil,"unconfirmed ARTY no handle")
no(refusedCreated,"unconfirmed ARTY not queued")
eq(refusedReason,"C2_ARTY_TARGET_NOT_CONFIRMED","ARTY refusal propagated")
eq(#commander.missions,2,"no guessed ARTY mission")

AUFTRAG=previousAuftrag
print("PASS test_fire_support_strategic_resupply_external_support_runtime")
