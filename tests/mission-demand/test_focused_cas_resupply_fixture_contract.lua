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

local fixturePath = "mission/tests/stage3-cas-resupply-focused/src/02-stage3-cas-resupply-opstransport-acceptance.lua"
local fixtureHandle = assert(io.open(fixturePath, "rb"))
local source = fixtureHandle:read("*a")
fixtureHandle:close()

local adapterPath = "scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua"
local adapterHandle = assert(io.open(adapterPath, "rb"))
local adapterSource = adapterHandle:read("*a")
adapterHandle:close()

-- CAS and RESUPPLY remain independent observation paths. A failure in one focused
-- subsystem must not suppress execution of the other real MOOSE lifecycle.
assertContains(source, "casFailed=false", "independent CAS state")
assertContains(source, "cargoFailed=false", "independent RESUPPLY state")
assertContains(source, "local function casFail", "CAS failure function")
assertContains(source, "local function cargoFail", "RESUPPLY failure function")
assertNotContains(source, "state.failed", "cross-subsystem failure gate")

-- The primary FlightPath route identity is stable while its _Rnnn/_Lnnn suffix is
-- mission-editor configuration. The acceptance must discover the configured name
-- and must never hard-code one offset such as R500 as route identity.
assertContains(source, "local FLIGHTPATH_BASE = \"OMW_FlightPath\"", "logical FlightPath identity")
assertContains(source, "FlightPathNameContract.SelectFromRegistry", "configured FlightPath selection")
assertContains(source, "_DATABASE.PATHLINES", "validation-only MOOSE PATHLINE registry read")
assertContains(source, "state.flightPathName", "resolved configured FlightPath name")
assertContains(source, "Corridor.OffsetMode.PATHLINE_SUFFIX", "suffix-driven corridor offset")
assertNotContains(source, "local R500 = \"OMW_FlightPath_R500\"", "fixed R500 route identity")

-- Preserve the previously used MOOSE CAS engagement contract. This test does not
-- change the independent AH-64 route/engagement path while RESUPPLY is reconciled.
assertContains(source, "AUFTRAG:NewCAS", "MOOSE CAS constructor")
assertContains(source, "SetMissionIngressCoord", "explicit CAS ingress")
assertContains(source, "SetMissionEgressCoord", "explicit CAS egress")
assertContains(source, "SetMissionWaypointRandomization(0)", "CAS waypoint randomization")
assertContains(source, "SetEngageDetected", "MOOSE CAS EngageDetected")
assertContains(source, "SetROE(ENUMS.ROE.OpenFire)", "MOOSE CAS ROE")
assertContains(source, "SetROT(ENUMS.ROT.PassiveDefense)", "MOOSE CAS ROT")

-- The focused Air-AMMO path uses MOOSE OPSTRANSPORT STORAGE transport end to end.
assertContains(source, "OPSTRANSPORT:New(nil,state.pickup,state.drop)", "MOOSE OPSTRANSPORT storage constructor")
assertContains(source, "AddCargoStorage", "MOOSE storage cargo")
assertContains(source, "GetStaticStorage", "MOOSE STORAGE fixture")
assertContains(source, "LEGION.RecruitCohortAssets", "MOOSE carrier recruitment")
assertContains(source, "for _,legion in pairs(legions) do", "alias-keyed legion map iteration")
assertContains(source, "legionCount==1", "single carrier legion validation")
assertContains(source, "recruitedLegion==state.airwing", "Jalalabad AIRWING validation")
assertContains(source, "state.airwing:TransportAssign", "MOOSE transport assignment")
assertContains(source, "OnAfterAssetSpawned", "AIRWING spawned carrier observation")
assertContains(source, "OnAfterDelivered", "MOOSE delivery observation")
assertNotContains(source, "#legions", "invalid Lua length use on legion alias map")
assertNotContains(source, "AUFTRAG:NewCARGOTRANSPORT", "superseded CARGOTRANSPORT path")
assertNotContains(source, "PauseMission(", "superseded mission pause handoff")
assertNotContains(source, "CargoTransportation", "superseded native cargo task")
assertNotContains(source, "OnBeforeUnpauseMission", "falsified auto-unpause guard")

-- Carrier startup/recruitment is a bounded readiness window.
assertContains(source, "local CARRIER_RECRUIT_RETRY_SEC = 5", "carrier retry interval")
assertContains(source, "local CARRIER_RECRUIT_MAX_ATTEMPTS = 6", "carrier retry bound")
assertContains(source, "GetMissionCapability(AUFTRAG.Type.OPSTRANSPORT)", "carrier mission capability diagnostic")
assertContains(source, "CountAssets(true,{AUFTRAG.Type.OPSTRANSPORT})", "carrier stock diagnostic")
assertContains(source, "CountPayloadsInStock({AUFTRAG.Type.OPSTRANSPORT},state.carrierUnitType)", "carrier payload diagnostic")
assertContains(source, "[STAGE3 FOCUSED][RESUPPLY RECRUIT]", "carrier recruitment preflight diagnostic")
assertContains(source, "[STAGE3 FOCUSED][RESUPPLY RECRUIT RESULT]", "carrier recruitment result diagnostic")
assertContains(source, "LEGION.UnRecruitAssets(assets)", "malformed successful recruitment cleanup")
assertContains(source, "scheduleCargoRecruitment()", "bounded carrier retry scheduling")
assertContains(source, "state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS", "carrier retry stop condition")

-- Wright is a field LZ zone. Adapter schema 2 preserves the public MOOSE-only
-- waypoint boundary and adds optional speed/lead-turn geometry without changing the
-- OPSTRANSPORT lifecycle. Focused legacy callers may omit those optional settings.
assertContains(adapterSource, "OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2", "OPSTRANSPORT corridor adapter schema")
assertContains(adapterSource, "OnAfterTransport", "transport lifecycle route hook")
assertContains(adapterSource, "OnAfterDelivered", "delivery lifecycle return hook")
assertContains(adapterSource, "GetWaypointCurrentUID", "public current waypoint API")
assertContains(adapterSource, "AddWaypoint", "public FLIGHTGROUP waypoint API")
assertContains(adapterSource, "UpdateRoute", "public FLIGHTGROUP route update API")
assertContains(adapterSource, "transport:IsCarrier(self)", "public carrier identity API")
assertContains(adapterSource, "GetIntermediateCoordinate", "public MOOSE lead-turn geometry API")
assertContains(adapterSource, "HeadingTo", "public MOOSE turn-angle geometry API")
assertContains(adapterSource, "speedKts", "optional explicit waypoint speed")
assertContains(adapterSource, "leadTurnDistanceM", "optional lead-turn distance")
assertNotContains(adapterSource, "Controller:setTask", "native controller route replacement")
assertNotContains(adapterSource, "PauseMission", "mission lifecycle interception")
assertNotContains(adapterSource, "CargoTransportation", "native cargo task")

print("PASS test_focused_cas_resupply_fixture_contract")
