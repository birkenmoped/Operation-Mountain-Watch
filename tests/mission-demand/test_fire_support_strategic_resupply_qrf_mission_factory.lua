local Factory = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")

local function eq(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function yes(value, label) if value ~= true then error(label .. " expected=true") end end
local function no(value, label) if value ~= false then error(label .. " expected=false") end end

local previousAuftrag = AUFTRAG
local created = {}
local groundAttackCalls = 0
AUFTRAG = {}
function AUFTRAG:NewGROUNDATTACK()
  groundAttackCalls = groundAttackCalls + 1
  error("GROUNDATTACK is forbidden for accepted local QRF contract")
end
function AUFTRAG:NewONGUARD(coordinate)
  local mission = { coordinate=coordinate, cancelCount=0, over=false }
  function mission:SetTeleport(value) self.teleport=value return self end
  function mission:SetReturnToLegion(value) self.returnToLegion=value return self end
  function mission:SetRequiredAssets(minimum, maximum) self.requiredMin=minimum; self.requiredMax=maximum; return self end
  function mission:SetRequiredAttribute(value) self.requiredAttributes=value; return self end
  function mission:SetRequiredProperty(value) self.requiredProperties=value; return self end
  function mission:SetPriority(priority, urgent) self.priority=priority; self.urgent=urgent; return self end
  function mission:IsOver() return self.over end
  function mission:Cancel() self.cancelCount=self.cancelCount+1; self.over=true end
  created[#created + 1] = mission
  return mission
end

local function coordinate(distance)
  return { distance=distance, Get2DDistance=function(_, other) return other.distance end }
end
local targetCoordinate = { marker="TARGET_COORDINATE" }
local target = { marker="QRF_PHYSICAL_TARGET", alive=true, name="BadGuys_A3_JOYCE" }
function target:IsInstanceOf(className) return className=="GROUP" end
function target:IsAlive() return self.alive end
function target:GetName() return self.name end
function target:GetCoordinate() return targetCoordinate end

local unit1={name="RED-1",alive=true,coord=coordinate(100)}
local unit2={name="RED-2",alive=true,coord=coordinate(200)}
for _,unit in ipairs({unit1,unit2}) do
  function unit:IsAlive() return self.alive end
  function unit:GetName() return self.name end
  function unit:GetCoordinate() return self.coord end
end
local engageZone = { marker="QRF_TACTICAL_ZONE" }
function engageZone:IsCoordinateInZone() return true end

local resolvedDemand, resolvedContext, resolvedLegion
local factory = Factory.New({
  resolveTarget = function(demand, context, legion)
    resolvedDemand=demand; resolvedContext=context; resolvedLegion=legion
    return target
  end,
  resolveTargets = function() return {unit2,unit1} end,
  resolveEngageZone = function() return engageZone end,
  requiredAssetsMin = 1,
  requiredAssetsMax = 1,
})

local demand = { demandId="DEMAND|FOB_JOYCE|QRF|1", siteId="FOB_JOYCE", supportType="QRF", priority=17 }
local context = { marker="INCIDENT" }
local legion = { alias="BDE_BLUE_GND_JOYCE" }
local mission, made, reason = factory:Create(demand, context, legion)
yes(made, "QRF mission created")
eq(reason, nil, "QRF create reason")
eq(resolvedDemand, demand, "resolver demand")
eq(resolvedContext, context, "resolver context")
eq(resolvedLegion, legion, "resolver legion")
eq(mission.coordinate, targetCoordinate, "ONGUARD initial target coordinate")
eq(mission.teleport, false, "visible teleport disabled")
eq(mission.returnToLegion, true, "MOOSE return lifecycle enabled")
eq(mission.requiredMin, 1, "required assets min")
eq(mission.requiredMax, 1, "required assets max")
eq(mission.priority, 17, "demand priority forwarded")
eq(mission.urgent, false, "QRF does not preempt by default")
eq(groundAttackCalls, 0, "GROUNDATTACK substitution forbidden")
eq(mission._OMWQrfPhase,"DIRECT_TARGET_RESPONSE","direct target phase")

local army={coord=coordinate(0),engaged={}}
function army:GetCoordinate() return self.coord end
function army:EngageTarget(targetUnit,speed,formation)
  self.engaged[#self.engaged+1]={target=targetUnit,speed=speed,formation=formation}
end
mission:_OMWQrfBindArmyGroup(army)
eq(#army.engaged,1,"first concrete target acquired")
eq(army.engaged[1].target,unit1,"nearest live target selected")
eq(army.engaged[1].speed,20,"engagement speed")
eq(army.engaged[1].formation,"On Road","road-preferred engagement transit formation")

unit1.alive=false
army:OnAfterDisengage("Engaging","Disengage","Cruising")
eq(#army.engaged,2,"next target acquired after Disengage")
eq(army.engaged[2].target,unit2,"second live target selected")
eq(army.engaged[2].formation,"On Road","road-preferred formation retained after reacquisition")

unit2.alive=false
army:OnAfterDisengage("Engaging","Disengage","Cruising")
eq(mission.cancelCount,1,"target exhaustion completes QRF mission")
yes(mission._OMWQrfCompleting,"target exhaustion completion flagged")

local attributes={"Ground_APC"}
local properties={"APC"}
local constrainedFactory=Factory.New({
  resolveTarget=function() return target end,
  resolveTargets=function() return {unit1} end,
  resolveEngageZone=function() return engageZone end,
  requiredAttributes=attributes,
  requiredProperties=properties,
})
local constrained, constrainedCreated = constrainedFactory:Create({demandId="DEMAND|COP_HONAKER|QRF|1",siteId="COP_HONAKER",supportType="QRF"},{},legion)
yes(constrainedCreated,"constrained QRF created")
eq(constrained.requiredAttributes,attributes,"MOOSE attribute constraint forwarded")
eq(constrained.requiredProperties,properties,"MOOSE property constraint forwarded")
eq(constrained.returnToLegion,true,"constrained QRF returns to Legion")

local unavailableFactory = Factory.New({
  resolveTarget = function() return nil, "QRF_PHYSICAL_TARGET_UNAVAILABLE" end,
  resolveTargets = function() return {} end,
  resolveEngageZone = function() return engageZone end,
})
local unavailable, unavailableCreated, unavailableReason = unavailableFactory:Create({demandId="DEMAND|FOB_BOSTICK|QRF|1",siteId="FOB_BOSTICK",supportType="QRF"},{},{})
eq(unavailable,nil,"missing physical target returns no mission")
no(unavailableCreated,"missing physical target not created")
eq(unavailableReason,"QRF_PHYSICAL_TARGET_UNAVAILABLE","missing target reason")

local deadTarget={name="BadGuys_A3_BOSTICK"}
function deadTarget:IsInstanceOf(className) return className=="GROUP" end
function deadTarget:IsAlive() return false end
function deadTarget:GetName() return self.name end
function deadTarget:GetCoordinate() return targetCoordinate end
local deadFactory=Factory.New({resolveTarget=function() return deadTarget end,resolveTargets=function() return {} end,resolveEngageZone=function() return engageZone end})
local dead,deadCreated,deadReason=deadFactory:Create({demandId="DEMAND|FOB_BOSTICK|QRF|2",siteId="FOB_BOSTICK",supportType="QRF"},{},{})
eq(dead,nil,"dead physical target returns no mission")
no(deadCreated,"dead physical target not created")
eq(deadReason,"QRF_PHYSICAL_TARGET_NOT_ALIVE","dead target reason")

local ok, err = pcall(function()
  factory:Create({ demandId="DEMAND|FOB_JOYCE|CAS|1", siteId="FOB_JOYCE", supportType="CAS" }, context, legion)
end)
no(ok, "non-QRF demand rejected")
yes(type(err)=="string" and string.find(err, "supportType QRF is required", 1, true) ~= nil, "non-QRF error text")

AUFTRAG = previousAuftrag
print("PASS test_fire_support_strategic_resupply_qrf_mission_factory")
