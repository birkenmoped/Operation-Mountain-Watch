local Policy=dofile("scripts/campaign/OMW_FireSupStratResupply_CasReleasePolicy.lua")

local function eq(a,b,label)
  if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end
end

local policy=Policy.New({
  mode=Policy.Mode.SUPPORTED_ELEMENT_STABLE_NO_CONTACT,
  stableNoContactSec=30,
})

local state,changed,reason=policy:Observe("D1",{
  now=0,sensorReady=false,supportedElementClear=false,eligibleCount=0,
})
eq(changed,false,"sensor not ready changed")
eq(reason,"SENSOR_NOT_READY","sensor not ready reason")
eq(state.release,false,"sensor not ready release")

state,changed,reason=policy:Observe("D1",{
  now=10,sensorReady=true,supportedElementClear=false,eligibleCount=1,
})
eq(state.noContactSince,nil,"contact no timer")
eq(state.release,false,"contact release")
eq(reason,"HOLD","contact reason")

state=policy:Observe("D1",{
  now=20,sensorReady=true,supportedElementClear=false,eligibleCount=0,
})
eq(state.noContactSince,20,"zero contact starts timer")
eq(state.noContactReported,false,"zero contact not stable")

state=policy:Observe("D1",{
  now=49,sensorReady=true,supportedElementClear=true,eligibleCount=0,
})
eq(state.noContactReported,false,"29 sec not stable")
eq(state.release,false,"29 sec no release")

state=policy:Observe("D1",{
  now=50,sensorReady=true,supportedElementClear=false,eligibleCount=0,
})
eq(state.noContactReported,true,"30 sec stable")
eq(state.release,false,"supported element still active")

state,changed,reason=policy:Observe("D1",{
  now=51,sensorReady=true,supportedElementClear=true,eligibleCount=0,
})
eq(state.release,true,"supported clear plus stable no contact")
eq(state.releaseReason,"SUPPORTED_ELEMENT_RELEASE_NO_CONTACT","release reason")
eq(reason,"RELEASE","release result")

local p2=Policy.New({stableNoContactSec=30})
p2:Observe("D2",{now=0,sensorReady=true,supportedElementClear=true,eligibleCount=0})
p2:Observe("D2",{now=20,sensorReady=true,supportedElementClear=true,eligibleCount=1})
local s2=p2:Observe("D2",{now=40,sensorReady=true,supportedElementClear=true,eligibleCount=0})
eq(s2.noContactSince,40,"contact resets stable timer")
eq(s2.release,false,"reset prevents release")

print("PASS fire support CAS release policy")
