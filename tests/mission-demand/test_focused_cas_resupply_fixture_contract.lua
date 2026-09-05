local function assertContains(source, marker, label)
  if not string.find(source, marker, 1, true) then
    error(label .. " missing marker: " .. marker)
  end
end

local function assertNotContains(source, marker, label)
  if string.find(source, marker, 1, true) then
    error(label .. " contains forbidden marker: " .. marker)
  end
end

local path = "mission/tests/stage3-cas-resupply-focused/src/01-stage3-cas-resupply-focused-acceptance.lua"
local handle = assert(io.open(path, "rb"))
local source = handle:read("*a")
handle:close()

-- Rejected 2026-09-05 fixture used one global state.failed and a false numeric
-- cargo-ID gate. Either regression can suppress otherwise valid MOOSE execution.
assertContains(source, "casFailed=false", "independent CAS state")
assertContains(source, "cargoFailed=false", "independent RESUPPLY state")
assertContains(source, "local function casFail", "CAS failure function")
assertContains(source, "local function cargoFail", "RESUPPLY failure function")
assertNotContains(source, "state.failed", "cross-subsystem failure gate")
assertNotContains(source, "cargo numeric ID unavailable", "rejected numeric cargo-ID gate")
assertNotContains(source, "type(state.cargo:GetID())~=\"number\"", "numeric cargo-ID requirement")

-- Preserve the previously proven MOOSE engagement configuration while NewCAS owns
-- the CAS task and OMW owns the explicit route geometry.
assertContains(source, "SetMissionIngressCoord", "explicit CAS ingress")
assertContains(source, "SetMissionEgressCoord", "explicit CAS egress")
assertContains(source, "SetMissionWaypointRandomization(0)", "CAS waypoint randomization")
assertContains(source, "SetEngageDetected", "MOOSE CAS EngageDetected")
assertContains(source, "SetROE(ENUMS.ROE.OpenFire)", "MOOSE CAS ROE")
assertContains(source, "SetROT(ENUMS.ROT.PassiveDefense)", "MOOSE CAS ROT")

print("PASS test_focused_cas_resupply_fixture_contract")
