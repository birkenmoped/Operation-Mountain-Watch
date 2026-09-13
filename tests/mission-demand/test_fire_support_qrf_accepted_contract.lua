local function read(path)
  local file, err = io.open(path, "rb")
  if not file then error("cannot read " .. path .. ": " .. tostring(err)) end
  local content = file:read("*a")
  file:close()
  return content
end

local function contains(content, token, label)
  if not content:find(token, 1, true) then error(label .. " missing token: " .. token) end
end

local function excludes(content, token, label)
  if content:find(token, 1, true) then error(label .. " forbidden token: " .. token) end
end

local factory = read("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")
local runtime = read("scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua")
local acceptance = read("mission/tests/fire-support-strategic-resupply-production-base-runtime/src/03-production-base-six-site-physical-alarm-qrf-acceptance.lua")

-- Accepted response phase remains intact.
contains(factory, "AUFTRAG:NewONGUARD", "QRF factory response")
contains(factory, "SetEngageDetected", "QRF factory response")
contains(factory, "SetReturnToLegion(true)", "QRF factory response")
contains(factory, "SetTeleport(false)", "QRF factory response")
excludes(factory, "AUFTRAG:NewGROUNDATTACK", "QRF factory")

-- Owner-approved 2026-09-13 clearance extension must use native MOOSE only.
contains(factory, "AUFTRAG:NewPATROLZONE", "QRF factory clearance")
contains(factory, "SetPatrolAdInfinitum(true)", "QRF factory clearance")
contains(factory, "EnableHuntingPatrol", "QRF factory clearance")
contains(factory, "__MissionDone(0.1, self)", "QRF response to clearance handoff")
contains(factory, "_OMWQrfClearanceByGroup", "QRF phase tracking")
contains(factory, "clearanceMission:SetReturnToLegion(true)", "QRF clearance return contract")
contains(factory, "clearanceMission:SetTeleport(false)", "QRF clearance physical lifecycle")
excludes(factory, "SCHEDULER", "QRF factory custom search scheduler")
excludes(factory, "timer.scheduleFunction", "QRF factory native timer search")

-- ACCESS materialization and response road contract are unchanged.
contains(runtime, "roadSpawnAdapter.Install", "QRF runtime")
contains(runtime, "brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)", "QRF runtime")
contains(runtime, "accessZone = accessZone", "QRF runtime ACCESS boundary")
contains(runtime, "forwardCoordinate = targetCoordinate", "QRF runtime direction input")
contains(runtime, "QRF_TACTICAL_RADIUS_NM = 5", "QRF runtime")
contains(runtime, "QRF_ENGAGE_RANGE_NM = 5", "QRF runtime")
excludes(runtime, "roadForwardCoordinates", "QRF runtime")
excludes(runtime, "QRF_VALIDATED_ROAD_FORWARD_COORDINATE_UNAVAILABLE", "QRF runtime")
excludes(runtime, "PATROL_TEST", "QRF runtime")

-- Explicit C2 release must stop HuntingPatrol and cancel the active clearance phase.
contains(runtime, "DisableHuntingPatrol", "QRF clearance release")
contains(runtime, "SetPatrolAdInfinitum(false)", "QRF clearance release")
contains(runtime, "clearanceMission:Cancel()", "QRF clearance release")
excludes(runtime, "perimeter clear", "QRF runtime automatic release")
excludes(runtime, "incident close", "QRF runtime automatic release")

-- Frozen Acceptance 3 remains historical response evidence and is not rewritten.
contains(acceptance, "AUFTRAG.Type.ONGUARD", "Acceptance 3")
contains(acceptance, "qrfProgress", "Acceptance 3 response observation")
excludes(acceptance, "PATROL_TEST", "Acceptance 3")
excludes(acceptance, "ExpireDemand(", "Acceptance 3")
excludes(acceptance, "ACCEPTANCE_SUPPORTED_ELEMENT_RELEASE", "Acceptance 3")
excludes(acceptance, "QRF_RELEASE_REQUESTED", "Acceptance 3")
excludes(acceptance, "AUFTRAG.Type.GROUNDATTACK", "Acceptance 3")

print("PASS test_fire_support_qrf_accepted_contract")
