local Continuation = dofile("scripts/campaign/OMW_FireSupStratResupply_FireContinuation.lua")

local function eq(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)), 2)
  end
end

local queue = {}
local function scheduleOnce(callback)
  queue[#queue + 1] = callback
end
local function runDeferred()
  local pending = queue
  queue = {}
  for _, callback in ipairs(pending) do callback() end
end

local function group(name)
  return {
    GetName = function() return name end,
    GetCoordinate = function() return { name = name .. "-COORD" } end,
  }
end

local incident = { incidentId = "INC-C2", siteId = "COP_HONAKER", closed = false }
local targets = {group("RED-A"), group("RED-B")}
local cas = false
local ammo = 10
local fireCalls = {}
local rearmCalls = 0
local logged = {}
local busy = false
local runtime = Continuation.New({
  getIncident = function(id)
    eq(id, incident.incidentId, "lookup incident")
    return incident
  end,
  getCandidates = function(context)
    eq(context.incident.incidentId, incident.incidentId, "original context retained")
    return targets
  end,
  resolveCasPresence = function(coordinate)
    eq(type(coordinate), "table", "target coordinate")
    return cas, cas == nil and "POSITION_UNKNOWN" or nil
  end,
  getPhysicalAmmo = function(entry)
    eq(entry.owner.realAssetId, "HONAKER", "ammo asset identity")
    return ammo
  end,
  requestFire = function(incidentArg, contextArg, target, requestKey, demandArg)
    eq(incidentArg, incident, "base incident identity")
    eq(contextArg.incident, incident, "selection context identity")
    eq(demandArg.incidentId, incident.incidentId, "source demand incident")
    fireCalls[#fireCalls + 1] = {target=target:GetName(),key=requestKey}
    return {demandId="CYCLE-"..#fireCalls,status=busy and "NOT_DISPATCHED" or "DISPATCHED"},true,nil
  end,
  requestRearm = function(entry, demandArg)
    eq(entry.owner.realAssetId, "HONAKER", "rearm asset identity")
    eq(demandArg.incidentId, incident.incidentId, "rearm context")
    rearmCalls = rearmCalls + 1
    return true,nil
  end,
  schedule = scheduleOnce,
  log = function(message) logged[#logged + 1]=message end,
})

local context = {incident=incident}
local entry = {
  released=true, physicalShots=4,
  owner={realAssetId="HONAKER",acceptedShots=4},
  target={shots=4},
}
local demand = {incidentId=incident.incidentId,demandId="ORIGINAL",supportType="ARTY"}
runtime:OnFinished(demand,context,entry,"CEASE_FIRE")
runtime:OnFinished(demand,context,entry,"CEASE_FIRE")
eq(#queue,1,"one shot completion scheduling, no direct reentrant dispatch")
eq(#fireCalls,0,"no synchronous reentrant fire")
runDeferred()
eq(#fireCalls,1,"fire mission continued after callback unwind")
eq(fireCalls[1].key,"INSTALLATION_ATTACK_C2_ARTY_CYCLE_1","unique cycle key")
eq(runtime:GetWaiting(incident.incidentId),nil,"successful dispatch clears pending")

local demand2={incidentId=incident.incidentId,demandId="CYCLE-1",supportType="ARTY"}
cas=true
runtime:OnFinished(demand2,context,entry,"CEASE_FIRE")
runDeferred()
eq(#fireCalls,1,"CAS physically on station blocks new ARTY")
eq(runtime:GetWaiting(incident.incidentId)~=nil,true,"CAS blocked demand remains pending")
cas=nil
runtime:OnCasEvidence()
runDeferred()
eq(#fireCalls,1,"unknown CAS position is not fire clearance")
cas=false
runtime:OnCasEvidence()
runDeferred()
eq(#fireCalls,2,"CAS egress permits next cycle")
eq(fireCalls[2].key,"INSTALLATION_ATTACK_C2_ARTY_CYCLE_2","cycle increments")
eq(fireCalls[2].target,"RED-B","C2 target alternates among live participants")
eq(fireCalls[3] and fireCalls[3].target,nil,"no third cycle before rearm")

-- With physical ammo insufficient, the existing M1083 service is requested
-- only once and is resumed by its OnAfterRearmed callback.
local demand3={incidentId=incident.incidentId,demandId="CYCLE-2",supportType="ARTY"}
ammo=2
runtime:OnFinished(demand3,context,entry,"CEASE_FIRE")
runDeferred()
eq(rearmCalls,1,"rearm service requested once")
eq(#fireCalls,2,"no fire with insufficient ammo")
runtime:OnCasEvidence()
runDeferred()
eq(rearmCalls,1,"no repeated rearm request while active")
ammo=10
runtime:OnRearmed("HONAKER")
runDeferred()
eq(#fireCalls,3,"fire resumes after confirmed rearm")
eq(fireCalls[3].key,"INSTALLATION_ATTACK_C2_ARTY_CYCLE_3","rearm continuation key")
eq(fireCalls[3].target,"RED-A","next C2 source target after rearm")

local demand4={incidentId=incident.incidentId,demandId="NO_SHOT",supportType="ARTY"}
runtime:OnFinished(demand4,context,{released=true,physicalShots=0,owner=entry.owner},"NO_PHYSICAL_SHOT_EVIDENCE")
eq(#queue,0,"no-shot cease fire does not schedule blind retry")
runtime:OnFinished({incidentId=incident.incidentId,demandId="DEAD",supportType="ARTY"},context,entry,"FUNCTIONAL_ARTY_DEAD")
eq(#queue,0,"dead battery does not reschedule")

-- Failed recruitment is not retried in a polling loop. An unrelated CAS
-- lifecycle event may cause reevaluation with a different request key.
busy=true
local demand5={incidentId=incident.incidentId,demandId="CYCLE-3",supportType="ARTY"}
runtime:OnFinished(demand5,context,entry,"CEASE_FIRE")
runDeferred()
eq(#fireCalls,4,"one attempt during unavailable provider")
eq(runtime:GetWaiting(incident.incidentId)~=nil,true,"failed dispatch retained")
busy=false
runtime:OnCasEvidence()
runDeferred()
eq(#fireCalls,5,"retry only after external event")
eq(fireCalls[5].key,"INSTALLATION_ATTACK_C2_ARTY_CYCLE_5","failed request key not recycled")

-- Perimeter closure alone does not invalidate living C2 participants;
-- the Base adapter independently checks the strictly scoped ARTY exception.
local demand6={incidentId=incident.incidentId,demandId="CYCLE-5",supportType="ARTY"}
incident.closed=true
runtime:OnFinished(demand6,context,entry,"CEASE_FIRE")
runDeferred()
eq(runtime:GetWaiting(incident.incidentId),nil,"closed incident with living target continues")
eq(#fireCalls,6,"closed incident still has C2-qualified live target")
targets={}
runtime:OnFinished({incidentId=incident.incidentId,demandId="NO_TARGET",supportType="ARTY"},context,entry,"CEASE_FIRE")
runDeferred()
eq(#fireCalls,6,"no C2 participants means no fire")

print("PASS test_fire_support_strategic_resupply_fire_continuation")
