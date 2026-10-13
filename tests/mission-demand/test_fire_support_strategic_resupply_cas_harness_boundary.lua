local function read(path)
  local f=assert(io.open(path,"rb"))
  local text=f:read("*a")
  f:close()
  return text
end

local function contains(text,marker)
  return text:find(marker,1,true)~=nil
end

local source=read("mission/tests/fire-support-strategic-resupply-production-base-runtime/src/09-production-cas-lifecycle-acceptance.lua")
local production=read("scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua")

local forbidden={
  "GetDetectedGroups(",
  "CasTacticalCorridor.Bind(",
  "HelicopterCorridor.ResolveSequence(",
  "OnAfterFuelLow",
  "OnAfterLanded",
  "OnAfterLegionAssetReturned",
  "mission:Cancel(",
  "Mission:Cancel(",
  "UpdateRoute(",
  "AddWaypoint(",
  "CAS_NO_CONTACT_STABLE_SEC",
}
for _,marker in ipairs(forbidden) do
  if contains(source,marker) then
    error("A9 harness owns forbidden CAS lifecycle marker: "..marker)
  end
end

local requiredHarness={
  "onEvidence=onCasEvidence",
  "state.runtime.externalSupportRuntime.casLifecycle:GetState",
  "BadGuys_A3_JOYCE",
  "RequestIncidentSupport",
  "QRF_DIRECT_TARGET_ENGAGE",
}
for _,marker in ipairs(requiredHarness) do
  if not contains(source,marker) then
    error("A9 harness missing observer/stimulus marker: "..marker)
  end
end

local requiredProduction={
  "GetDetectedGroups()",
  "CAS_CONTROLLED_RELEASE",
  "OnAfterFuelLow",
  "OnAfterLanded",
  "OnAfterLegionAssetReturned",
  "CAS_LEGION_ASSET_RETURNED",
  "CAS_LIFECYCLE_COMPLETE",
  "self.casTacticalCorridor.Bind",
  "self.helicopterCorridor.ResolveSequence",
}
for _,marker in ipairs(requiredProduction) do
  if not contains(production,marker) then
    error("production CAS lifecycle missing inherited marker: "..marker)
  end
end

print("PASS fire support CAS harness boundary")
