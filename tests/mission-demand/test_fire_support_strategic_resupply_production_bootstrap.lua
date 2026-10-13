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
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-1',
  'OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED',
  'OMW_WAREHOUSE_READY',
  'OMW_GROUND_READY',
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
