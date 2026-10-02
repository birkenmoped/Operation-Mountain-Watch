local Bridge = dofile("scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local commander={missions={},transports={}}
function commander:AddMission(m) self.missions[#self.missions+1]=m return self end
function commander:AddOpsTransport(t) self.transports[#self.transports+1]=t return self end

local created={}
local bridge=Bridge.New({
  commander=commander,
  kind=Bridge.Kind.MISSION,
  factory=function(demand,context)
    if demand.requestKey=="REFUSE" then return nil,false,"TARGET_GEOMETRY_UNAVAILABLE" end
    local runtime={cancelCount=0,context=context}
    function runtime:Cancel() self.cancelCount=self.cancelCount+1 end
    created[#created+1]=runtime
    return runtime,true,nil
  end,
})

local demand={demandId="INC|ARTY|1",incidentId="INC|1",siteId="FOB_JOYCE",supportType="ARTY",requestKey="1"}
local handle,dispatched,reason=bridge:Dispatch(demand,{marker="CTX"})
yes(dispatched,"mission dispatched")
eq(reason,nil,"dispatch reason")
eq(#commander.missions,1,"one commander mission")
eq(commander.missions[1],handle.runtime,"queued runtime")
yes(handle:Cancel(),"first cancel")
no(handle:Cancel(),"second cancel idempotent")
eq(handle.runtime.cancelCount,1,"runtime cancel once")

local duplicate,duplicateCreated,duplicateReason=bridge:Dispatch(demand,{})
eq(duplicate,handle,"duplicate existing handle")
no(duplicateCreated,"duplicate not created")
eq(duplicateReason,"ALREADY_DISPATCHED","duplicate reason")
eq(#commander.missions,1,"duplicate not queued")

local refused,refusedCreated,refusedReason=bridge:Dispatch({demandId="INC|ARTY|2",siteId="FOB_JOYCE",supportType="ARTY",requestKey="REFUSE"},{})
eq(refused,nil,"factory refusal no handle")
no(refusedCreated,"factory refusal not dispatched")
eq(refusedReason,"TARGET_GEOMETRY_UNAVAILABLE","factory reason propagated")
eq(#commander.missions,1,"factory refusal not queued")

local transportRuntime={cancelCount=0}
function transportRuntime:Cancel() self.cancelCount=self.cancelCount+1 end
local transportBridge=Bridge.New({
  commander=commander,
  kind=Bridge.Kind.TRANSPORT,
  factory=function() return transportRuntime,true,nil end,
})
local th,tcreated=transportBridge:Dispatch({demandId="R|1",siteId="FOB_JOYCE",supportType="AIR_RESUPPLY"},{})
yes(tcreated,"transport dispatched")
eq(#commander.transports,1,"one commander transport")
eq(commander.transports[1],transportRuntime,"queued transport runtime")
yes(th:Cancel(),"transport cancel")
eq(transportRuntime.cancelCount,1,"transport cancel forwarded")

print("PASS test_fire_support_strategic_resupply_commander_bridge")
