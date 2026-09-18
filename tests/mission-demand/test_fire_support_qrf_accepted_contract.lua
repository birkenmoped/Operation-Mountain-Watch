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
local incidentBridge = read("scripts/campaign/OMW_FireSupStratResupply_InstallationIncidentBridge.lua")
local acceptance = read("mission/tests/fire-support-strategic-resupply-production-base-runtime/src/03-production-base-six-site-physical-alarm-qrf-acceptance.lua")

-- Honaker-reconciled QRF recruitment/materialization anchor remains MOOSE ONGUARD.
contains(factory, "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8", "QRF factory schema")
contains(factory, "AUFTRAG:NewONGUARD", "QRF factory recruitment anchor")
contains(factory, "SetReturnToLegion(true)", "QRF factory return contract")
contains(factory, "SetTeleport(false)", "QRF factory physical lifecycle")
excludes(factory, "AUFTRAG:NewGROUNDATTACK", "QRF factory")
excludes(factory, "AUFTRAG:NewPATROLZONE", "QRF factory rejected patrol design")
excludes(factory, "EnableHuntingPatrol", "QRF factory rejected hunting design")

-- The same physical ARMYGROUP directly engages concrete live incident UNIT targets.
contains(factory, "resolveTargets", "QRF concrete target resolver")
contains(factory, "armyGroup:EngageTarget", "QRF native MOOSE direct engagement")
contains(factory, "OnAfterDisengage", "QRF event-driven target reacquisition")
contains(factory, "MOOSE_DISENGAGE_REACQUIRE", "QRF target reacquisition")
contains(factory, "QRF_NO_LIVING_INCIDENT_TARGETS_IN_TACTICAL_ZONE", "QRF tactical completion")
contains(factory, "tacticalZone:IsCoordinateInZone", "QRF target zone authority")
contains(factory, "mission:Cancel()", "QRF completion return trigger")
excludes(factory, "SCHEDULER", "QRF factory custom target scheduler")
excludes(factory, "timer.scheduleFunction", "QRF factory custom target scheduler")

-- Motorized QRF march is road-preferred. Both layers are locked because a runtime
-- override wins over the MissionFactory default.
contains(factory, 'local DEFAULT_ENGAGE_FORMATION = "On Road"', "QRF factory road-preferred transit")
excludes(factory, 'local DEFAULT_ENGAGE_FORMATION = "Vee"', "QRF factory march formation")
contains(runtime, "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13", "QRF runtime schema")
contains(runtime, 'local QRF_ENGAGE_FORMATION = "On Road"', "QRF runtime road-preferred transit")
contains(runtime, "engageFormation=QRF_ENGAGE_FORMATION", "QRF runtime formation forwarding")
excludes(runtime, 'local QRF_ENGAGE_FORMATION = "Vee"', "QRF runtime Vee override")

-- Existing installation incident participant registry remains QRF target authority.
-- Bridge v5 additionally requests the local Guard, but the QRF contract itself is
-- unchanged and explicitly remains independent of incident-close cancellation.
contains(incidentBridge, "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-5", "incident bridge schema")
contains(incidentBridge, "sourceIncidentCoordinator=sourceCoordinator", "incident coordinator handoff")
contains(incidentBridge, 'requestKey="INSTALLATION_ATTACK_INITIAL_QRF"', "stable QRF request key")
contains(incidentBridge, "cancelWhenIncidentClosed=false", "incident close independence")
contains(runtime, "sourceIncidentCoordinator", "QRF runtime participant authority")
contains(runtime, "GetParticipants(true)", "QRF runtime living participant query")
contains(runtime, "group:GetUnits()", "QRF runtime concrete UNIT targets")
contains(runtime, "_OMWQrfBindArmyGroup", "QRF ArmyOnMission direct-target binding")
contains(runtime, "OnAfterArmyOnMission", "QRF public BRIGADE lifecycle binding")
excludes(runtime, "EnableHuntingPatrol", "QRF runtime rejected hunting design")
excludes(runtime, "SCHEDULER", "QRF runtime custom target scheduler")
excludes(runtime, "timer.scheduleFunction", "QRF runtime custom target scheduler")

-- ACCESS materialization and road-direction contract remain unchanged.
contains(runtime, "roadSpawnAdapter.Install", "QRF runtime")
contains(runtime, "brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)", "QRF runtime")
contains(runtime, "accessZone = accessZone", "QRF runtime ACCESS boundary")
contains(runtime, "forwardCoordinate = targetCoordinate", "QRF runtime direction input")
contains(runtime, "QRF_TACTICAL_RADIUS_NM = 5", "QRF runtime tactical area")
excludes(runtime, "roadForwardCoordinates", "QRF runtime")
excludes(runtime, "QRF_VALIDATED_ROAD_FORWARD_COORDINATE_UNAVAILABLE", "QRF runtime")
excludes(runtime, "PATROL_TEST", "QRF runtime")

-- Frozen Acceptance 3 remains historical response evidence and is not rewritten.
contains(acceptance, "AUFTRAG.Type.ONGUARD", "Acceptance 3")
contains(acceptance, "qrfProgress", "Acceptance 3 response observation")
excludes(acceptance, "PATROL_TEST", "Acceptance 3")
excludes(acceptance, "ExpireDemand(", "Acceptance 3")
excludes(acceptance, "QRF_RELEASE_REQUESTED", "Acceptance 3")
excludes(acceptance, "AUFTRAG.Type.GROUNDATTACK", "Acceptance 3")

print("PASS test_fire_support_qrf_accepted_contract")
