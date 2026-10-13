local function read(path)
  local f=assert(io.open(path,"rb"))
  local text=f:read("*a")
  f:close()
  return text
end
local function contains(text,marker) return text:find(marker,1,true)~=nil end

local source=read("mission/tests/fire-support-strategic-resupply-production-base-runtime/src/10-production-real-arty-selection-rearm-acceptance.lua")

local forbidden={
  "commander:AddMission(",
  "COMMANDER:AddMission(",
  "RouteGroundTo(",
  "RouteTo(",
  "SetTask(",
  "PushTask(",
  ":Teleport(",
  "SetRearmOnOutOfAmmo(",
  "world.addEventHandler",
  "timer.scheduleFunction",
}
for _,marker in ipairs(forbidden) do
  if contains(source,marker) then error("A10 harness owns forbidden provider/lifecycle marker: "..marker) end
end

local required={
  "m.artyRealAssetRegistry.New(",
  "m.artySelectionRuntime.New(",
  "FixedFireSupportAmmoRearmService.New(",
  "MULTIPLE_ELIGIBLE_PROVIDERS",
  "MOOSE_REAL_ARTY_SELECTED",
  "EXACT_POSITION_PASS",
  "FIXED_BATTERY_STATIONARY",
  "startArty=false",
  "performance=50",
}
for _,marker in ipairs(required) do
  if not contains(source,marker) then error("A10 harness missing required inherited/observer marker: "..marker) end
end

print("PASS fire support ARTY A10 harness boundary")
