local function read(path)
  local f=assert(io.open(path,"rb"))
  local text=f:read("*a")
  f:close()
  return text
end

local function contains(text,marker)
  return text:find(marker,1,true)~=nil
end

local source=read("scripts/campaign/OMW_FireSupStratResupply_ProductionBootstrap.lua")

local required={
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-6',
  'OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED',
  'requireUserFlag("OMW_WAREHOUSE_READY", 1)',
  'requireUserFlag("OMW_GROUND_READY", 1)',
  'OMW.Ground.Base.GetContext',
  'OMW.Ground.Base.GetInitialStock',
  'COMMANDER:New',
  'commander:AddAirwing',
  'artyRealAssetRegistry.New',
  'runtime:StartPerimeters',
  'runtime:StartSite',
  'OMW_FSSR_READY',
  'OMW_FSSR_RESUPPLY_READY',
  'PRODUCTION_PHYSICAL_TRANSPORT_DESCRIPTOR_REQUIRED',
  'C2_EXTERNAL_SUPPORT_REQUEST',
  'INSTALLATION_ATTACK_C2_CAS',
  'INSTALLATION_ATTACK_C2_ARTY_INITIAL',
  'onExternalSupportRequired = function(incident, escalationContext)',
  'WAITING_FOR_FIXED_FIRE_ASSETS',
  'FIXED_FIRE_READINESS_EVENT',
  'fixedFireMaterialized=true',
  'FireContinuation.New',
  'sourceTargetGroup',
  'LOCAL_REARM_RESOURCE_QUANTITY_NOT_CONFIGURED',
}
for _,marker in ipairs(required) do
  if not contains(source,marker) then
    error("production bootstrap missing required integration marker: "..marker)
  end
end

local forbidden={
  'BadGuys_A3_',
  'AUTHORITATIVE_SHORTAGE_PRECONDITION',
  'SPAWNSTATIC:NewFromType',
  'RouteGroundTo(',
  'MESSAGE:New(',
  'SCHEDULER:New(',
  '[PASS]',
  '[FAIL]',
  'AssignSquadrons(',
  'AIRWING:AddMission(',
  'mist.',
  'MIST',
}
for _,marker in ipairs(forbidden) do
  if contains(source,marker) then
    error("production bootstrap contains forbidden Acceptance/parallel-authority marker: "..marker)
  end
end

if contains(source,'context.store:Consume(') or contains(source,'CompleteConsumption(') then
  error("production bootstrap must not manufacture strategic shortages")
end

if not contains(source,'config.resupply == nil or config.resupply == false') then
  error("production bootstrap must keep Strategic Resupply fail-closed when no physical production mapping is injected")
end

print("PASS fire support production bootstrap boundary")


if contains(source,'if OMW_WAREHOUSE_READY ~= 1') or contains(source,'if OMW_GROUND_READY ~= 1') then
  error("Lua globals must not be used as readiness authority; Mission Editor readiness is a DCS user flag")
end

if not contains(source,'USERFLAG:New(name)') or not contains(source,'flag:Get()') then
  error("production bootstrap must read readiness through pinned MOOSE USERFLAG")
end


if not contains(source,'request("CAS", "INSTALLATION_ATTACK_C2_CAS")')
    or not contains(source,'request("ARTY", "INSTALLATION_ATTACK_C2_ARTY_INITIAL")') then
  error("production bootstrap must create independent CAS and ARTY requirements for a qualified installation attack")
end

if contains(source,'QRF_FAILURE') or contains(source,'QRF_FAILED') then
  error("CAS/ARTY escalation must not be implemented as a fallback after QRF failure")
end


local startPerimetersPos=source:find("runtime:StartPerimeters()",1,true)
local readinessPos=source:find("allFixedFireAssetsMaterialized()",1,true)
if not startPerimetersPos or not readinessPos or readinessPos > startPerimetersPos then
  error("perimeters must not start before fixed-fire materialization readiness is evaluated")
end
