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
  local mission = { coordinate=coordinate, cancelCount=0 }
  function mission:SetTeleport(value) self.teleport=value return self end
  function mission:SetReturnToLegion(value) self.returnToLegion=value return self end
  function mission:SetRequiredAssets(minimum, maximum) self.requiredMin=minimum; self.requiredMax=maximum; return self end
  function mission:SetRequiredAttribute(value) self.requiredAttributes=value; return self end
  function mission:SetRequiredProperty(value) self.requiredProperties=value; return self end
  function mission:SetPriority(priority, urgent) self.priority=priority; self.urgent=urgent; return self end
  function mission:SetEngageDetected(range, targetTypes, zone)
    self.engageRange=range; self.targetTypes=targetTypes; self.engageZone=zone; return self
  end
  function mission:Cancel() self.cancelCount=self.cancelCount+1 end
  created[#created + 1] = mission
  return mission
end

local resolvedDemand, resolvedContext, resolvedLegion
local targetCoordinate = { marker="TARGET_COORDINATE" }
local target = { marker="QRF_PHYSICAL_TARGET", alive=true, name="BadGuys_A3_JOYCE" }
function target:IsInstanceOf(className) return className=="GROUP" end
function target:IsAlive() return self.alive end
function target:GetName() return self.name end
function target:GetCoordinate() return targetCoordinate end
local engageZone = { marker="QRF_TACTICAL_ZONE" }

local factory = Factory.New({
  resolveTarget = function(demand, context, legion)
    resolvedDemand=demand; resolvedContext=context; resolvedLegion=legion
    return target
  end,
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
eq(mission.engageRange, 5, "accepted Honaker engage range")
eq(mission.targetTypes[1], "Ground Units", "accepted Honaker target type")
eq(mission.engageZone, engageZone, "accepted tactical engage zone")
eq(mission.teleport, false, "visible teleport disabled")
eq(mission.returnToLegion, true, "accepted MOOSE return lifecycle enabled")
eq(mission.requiredMin, 1, "required assets min")
eq(mission.requiredMax, 1, "required assets max")
eq(mission.requiredAttributes, nil, "no implicit attribute filter")
eq(mission.requiredProperties, nil, "no implicit property filter")
eq(mission.priority, 17, "demand priority forwarded")
eq(mission.urgent, false, "QRF does not preempt by default")
eq(groundAttackCalls, 0, "GROUNDATTACK substitution forbidden")

local attributes={"Ground_APC"}
local properties={"APC"}
local constrainedFactory=Factory.New({
  resolveTarget=function() return target end,
  resolveEngageZone=function() return engageZone end,
  requiredAttributes=attributes,
  requiredProperties=properties,
})
local constrained, constrainedCreated = constrainedFactory:Create({
  demandId="DEMAND|COP_HONAKER|QRF|1", siteId="COP_HONAKER", supportType="QRF"
}, {}, legion)
yes(constrainedCreated,"constrained QRF created")
eq(constrained.requiredAttributes,attributes,"MOOSE attribute constraint forwarded")
eq(constrained.requiredProperties,properties,"MOOSE property constraint forwarded")
eq(constrained.returnToLegion,true,"constrained QRF returns to Legion")
eq(constrained.engageZone,engageZone,"constrained QRF tactical zone")

local unavailableFactory = Factory.New({
  resolveTarget = function() return nil, "QRF_PHYSICAL_TARGET_UNAVAILABLE" end,
  resolveEngageZone = function() return engageZone end,
})
local unavailable, unavailableCreated, unavailableReason = unavailableFactory:Create({
  demandId="DEMAND|FOB_BOSTICK|QRF|1", siteId="FOB_BOSTICK", supportType="QRF"
}, {}, {})
eq(unavailable, nil, "missing physical target returns no mission")
no(unavailableCreated, "missing physical target not created")
eq(unavailableReason, "QRF_PHYSICAL_TARGET_UNAVAILABLE", "missing target reason")
eq(#created, 2, "no MOOSE mission built when target missing")

local deadTarget={name="BadGuys_A3_BOSTICK"}
function deadTarget:IsInstanceOf(className) return className=="GROUP" end
function deadTarget:IsAlive() return false end
function deadTarget:GetName() return self.name end
function deadTarget:GetCoordinate() return targetCoordinate end
local deadFactory=Factory.New({resolveTarget=function() return deadTarget end,resolveEngageZone=function() return engageZone end})
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