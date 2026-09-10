[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sources = [ordered]@{
  OMW_STAGE3_CAMPAIGN_STATE = 'scripts\campaign\OMW_CampaignState.lua'
  OMW_STAGE3_MISSION_DEMAND = 'scripts\campaign\OMW_MissionDemand.lua'
  OMW_STAGE3_RESOURCE_DEMAND_POLICY = 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
  OMW_STAGE3_RESOURCE_DEMAND_COORDINATOR = 'scripts\campaign\OMW_ResourceDemandCoordinator.lua'
  OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY = 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
  OMW_STAGE3_FIRE_SUPPORT_DEMAND_POLICY = 'scripts\campaign\OMW_FobAttackFireSupportDemandPolicy.lua'
  OMW_STAGE3_FOB_THREAT_OPSZONE_ADAPTER = 'scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'
  OMW_STAGE3_GROUND_INSTALLATION_ATTACK_INCIDENT = 'scripts\ground\OMW_GroundInstallationAttackIncident.lua'
  OMW_STAGE3_FUNCTIONAL_ARTY_DISPATCH_ADAPTER = 'scripts\ground\OMW_FobAttackFunctionalArtyDispatchAdapter.lua'
  OMW_STAGE3_PERSONNEL_LEDGER = 'scripts\ground\OMW_GroundPersonnelDeploymentLedger.lua'
  OMW_STAGE3_GROUND_AMMO_REARM_ADAPTER = 'scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
  OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_SUPPORT = 'scripts\ground\OMW_FixedFireSupportAmmoSupport.lua'
  OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_REARM_SERVICE = 'scripts\ground\OMW_FixedFireSupportAmmoRearmService.lua'
  OMW_STAGE3_GROUND_SUPPORT_MATERIALIZER = 'scripts\ground\OMW_GroundSupportMaterializer.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER = 'scripts\air-operations\OMW_FobAttackCasDispatchAdapter.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_PATROL_CLOSURE = 'scripts\air-operations\OMW_FobAttackCasPatrolClosure.lua'
  OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR = 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
  OMW_STAGE3_HELICOPTER_CAS_TACTICAL_CORRIDOR = 'scripts\air-operations\OMW_HelicopterCasTacticalCorridor.lua'
  OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT = 'scripts\air-operations\OMW_FlightPathNameContract.lua'
  OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER = 'scripts\air-operations\OMW_OpsTransportCorridorAdapter.lua'
}
$acceptanceRelative = 'mission\tests\stage3-honaker-wright-full-response\src\01-honaker-wright-full-response-acceptance.lua'
$acceptanceFile = Join-Path $repoRoot $acceptanceRelative
$jalalabadFoundationFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Jalalabad_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist'
$outputFile = Join-Path $distDir 'OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua'
$builderVersion = 'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-23'
$testId = 'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$resolved = [ordered]@{}
foreach ($name in $sources.Keys) {
  $path = Join-Path $repoRoot $sources[$name]
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required Stage 3 source not found: $path" }
  $resolved[$name] = $path
}
if (-not (Test-Path -LiteralPath $acceptanceFile -PathType Leaf)) { throw "Acceptance source not found: $acceptanceFile" }
if (-not (Test-Path -LiteralPath $jalalabadFoundationFile -PathType Leaf)) { throw "Jalalabad AirOps foundation source not found: $jalalabadFoundationFile" }

$jalalabadFoundationSource = Get-Content -LiteralPath $jalalabadFoundationFile -Raw -Encoding UTF8
foreach ($marker in @(
  'SQ_US_JBAD_AH64D_B_1_10_AVN',
  'TPL_AIR_US_JBAD_AH64D_CAS_2SHIP',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED, AUFTRAG.Type.PATROLZONE }',
  'AUFTRAG.Type.OPSTRANSPORT'
)) {
  if (-not $jalalabadFoundationSource.Contains($marker)) { throw "Jalalabad AirOps foundation missing Stage 3 prerequisite: $marker" }
}

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- Scope: Honaker attack -> Guard/QRF + supported-element CAS -> Wright ARTY/rearm -> CampaignState AMMO reorder -> Jalalabad CH47 MOOSE OPSTRANSPORT internal STORAGE -> configured FlightPath outbound/return -> Jalalabad.
-- CASAuthority: OPSZONE, attackIncident and raw tactical RED counts do not directly terminate CAS.
-- CASStatus: Honaker local no-known-attackers status is reconciled with the AH-64 FLIGHTGROUP own GetDetectedGroups picture; explicit supported-element release requires on-station CAS no-contact.
-- AirAmmo: MOOSE OPSTRANSPORT owns load/transport/unload/Delivered. OMW_OpsTransportCorridorAdapter uses public FLIGHTGROUP waypoints at 125 kt and public COORDINATE geometry for a bounded 250-m lead-turn approximation.
-- ExternalSlingload: suspended by owner decision; no NewCARGOTRANSPORT/PauseMission/CargoTransportation handoff is part of this build.
-- StrategicAuthority: existing OMW CampaignState only.
-- MizMutation: false.

"@

$bundle = $header
$combinedForValidation = ''
foreach ($name in $resolved.Keys) {
  $source = Get-Content -LiteralPath $resolved[$name] -Raw -Encoding UTF8
  $bundle += Embed-Module $name $source
  $combinedForValidation += $source
}
$acceptanceSource = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
$opsTransportCorridorSource = Get-Content -LiteralPath $resolved['OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER'] -Raw -Encoding UTF8
$bundle += $acceptanceSource
$combinedForValidation += $acceptanceSource

$requiredMarkers = @(
  'FIRE_SUPPORT_IMMEDIATE','OPSZONE','OnAfterEvaluated','GetScannedGroupSet','PROXIMITY_INTRUSION','HONAKER_NO_KNOWN_ATTACKERS',
  'ARTY:New','AssignTargetCoord','QueueTarget','LIVE_FIRE_RETARGET','SetWaitForShotTime','verifyFireComplete','WRIGHT_ARTY_EVENTS_SHOT','NO_MOOSE_ARTY_EVENTS_SHOT',
  'TPL_BLUE_GND_INF_RIFLE_SQUAD_9','TPL_BLUE_GND_QRF_MIXED_6','OMW_RTE_BLUE_GUARD_HONAKER_01','ZON_BLUE_GND_HONAKER_ACCESS',
  'PATHLINE:FindByName','GetCoordinates','WaypointGround','TaskFunction("CONTROLLABLE.Route"','SetTaskWaypoint','state.guardGroup:Route','SetSpawnZone(accessZone)',
  'AUFTRAG:NewONGUARD','SetEngageDetected','AssignCohort','SetReturnToLegion(true)','OnAfterReturned','SettleReturned','qrfReturned',
  'AUFTRAG:NewPATROLZONE','PATROLZONE_ENGAGE','CAS_TACTICAL_RADIUS_NM','CAS_COMBAT_HEIGHT_FT_AGL','GetLandHeight','NMToMeters',
  'GetDetectedGroups','IsCoordinateInZone','Get3DDistance','CAS_SENSOR_REPORT','CAS_ENGAGE_EVENT','SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT',
  'casSupportRequirementActive','casOnStation','casNoContactReported','CAS_NO_CONTACT_STABLE_SEC','casHomeLanded','casAssetReturned','ConfirmExecutionEvidence','EVENTS.Shot',
  'C2_FIRE_OBSERVATION','C2_FIRE_OBSERVATION_RADIUS_NM','authority=QRF_ARTY_ONLY','CAS_ON_STATION_ARTY_DECONFLICTION',
  'OnAfterUpdateRoute','MISSION_ROUTE_UIDS_NOT_READY','__omwFlightPathCorridorInstalled','CAS_CORRIDOR_PENDING_MOOSE_ROUTE_CALLBACK','CAS_ROUTE_GATES_DERIVED','PlanRouteGated','CasTacticalCorridor.Bind',
  'OMW-FOB-ATTACK-CAS-PATROL-CLOSURE-2','requireExecutionEvidence=false','executionEvidenceConfirmed=state.casFired','AssignSquadrons','squadrons={state.ah64d}',
  'PATHLINE_SUFFIX','ParsePathlineOffset','OMW_FlightPath','OMW_FlightPath_WEST','WEST_ALTITUDE_FT_AGL','ResolveSequence',
  'OMW-FLIGHTPATH-NAME-CONTRACT-1','OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2','GetWaypointCurrentUID','AddWaypoint','UpdateRoute','GetIntermediateCoordinate','HeadingTo',
  'OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1','PlanRouteGated','CAS_ROUTE_GATES_DERIVED','SetMissionIngressCoord','SetMissionWaypointCoord','SetMissionEgressCoord','CAS_GEOMETRY_CONFIGURED',
  'OPSTRANSPORT:New','AddCargoStorage','GetStaticStorage','LEGION.RecruitCohortAssets','TransportAssign','OnAfterAssetSpawned','OnAfterDelivered',
  'ZON_BLUE_LOG_SLG_JALALABAD_01','InitValidateAndRepositionStatic(false)',
  'GROUND_AMMO_PACKAGE','GROUND_NODE_WRIGHT','GROUND_NODE_JALALABAD','TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2','TPL_BLUE_GND_SUP_M1083',
  'SQ_US_JBAD_CH47_HEAVYLIFT','MarkInTransit','MarkDelivered','active_duplicate','duplicate.id','duplicate.dedupeKey',
  'state.threat:Stop()','state.finishScheduler:Stop()','MESSAGE:New','onThreatCleared','perimeterClear'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combinedForValidation.Contains($marker)) { throw "Stage 3 full-response sources missing marker: $marker" }
}

foreach ($marker in @(
  'local GUARD_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"',
  'local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"',
  'local QRF_PERSONNEL = 5',
  'local GUARD_PATHLINE = "OMW_RTE_BLUE_GUARD_HONAKER_01"',
  'local HONAKER_ACCESS_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"',
  'local FLIGHTPATH_BASE = "OMW_FlightPath"',
  'local CAS_SPEED_KTS = 125',
  'local CAS_NO_CONTACT_STABLE_SEC = 30',
  'local CH47_TRANSIT_SPEED_KTS = 125',
  'local CH47_LEAD_TURN_DISTANCE_M = 250',
  'FlightPathNameContract.SelectFromRegistry',
  '_DATABASE.PATHLINES',
  'state.guardPathline = need(PATHLINE:FindByName(GUARD_PATHLINE), GUARD_PATHLINE)',
  'state.brigade:SetSpawnZone(accessZone)',
  'state.qrfPlatoon = PLATOON:New(QRF_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_QRF_MIXED_6")',
  'mission:SetReturnToLegion(true)',
  'entry.mission:Cancel()',
  'requireExecutionEvidence=false',
  'executionEvidenceConfirmed=state.casFired',
  'local detected=state.casFlight:GetDetectedGroups()',
  'if not state.honakerNoKnownAttackers then return false end',
  'if not state.casOnStation or not state.casNoContactReported then return false end',
  'timer.getAbsTime() - state.casNoContactSince < CAS_NO_CONTACT_STABLE_SEC',
  'state.attackIncident:Close("HONAKER_NO_KNOWN_ATTACKERS")',
  'releaseSource=INSTALLATION_ID',
  'state.threat:Stop()',
  'OPSTRANSPORT:New(nil,state.pickup,state.drop)',
  'AddCargoStorage(state.sourceStorage,state.destStorage',
  'LEGION.RecruitCohortAssets(',
  'state.airwing:TransportAssign(state.cargoTransport,legions)',
  'TransportCorridor.Bind(flight,state.cargoTransport,state.cargoResolved',
  'speedKts=CAS_SPEED_KTS',
  'speedKts=CH47_TRANSIT_SPEED_KTS',
  'leadTurnDistanceM=CH47_LEAD_TURN_DISTANCE_M',
  'physicalMission="OPSTRANSPORT:STORAGE"',
  'state.cargoReturnInstalled',
  'state.finishScheduler=SCHEDULER:New(nil,finish,{},10,10)'
)) {
  if (-not $acceptanceSource.Contains($marker)) { throw "Stage 3 acceptance missing lifecycle marker: $marker" }
}

foreach ($marker in @(
  'OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2',
  'GetIntermediateCoordinate(previous, trimM)',
  'GetIntermediateCoordinate(following, trimM)',
  'flightGroup:AddWaypoint(routeCoordinates[i], speedKts',
  'FLIGHTPATH_OUTBOUND',
  'FLIGHTPATH_RETURN'
)) {
  if (-not $opsTransportCorridorSource.Contains($marker)) { throw "OPSTRANSPORT corridor adapter missing Stage 3 route-profile marker: $marker" }
}

foreach ($obsolete in @(
  'QRF_VEHICLE_TEMPLATE','TPL_BLUE_GND_QRF_MIXED_4','qrfVehiclePlatoon','qrfInfDeployed','qrfVehicleDeployed',
  'GROUP:FindByName(GUARD_ROUTE_GROUP)','state.guardGroup:PatrolRoute()','state.finishScheduler=SCHEDULER:New(nil,finish,{},10,2)',
  'local PICKUP_ZONE = "OMW_LOG_NODE_JALALABAD"','InitValidateAndRepositionStatic(true,120)','state.brigade:SetSpawnZone(accessZone,100)',
  'requireExecutionEvidence=true','OMW-FOB-ATTACK-CAS-PATROL-CLOSURE-1','OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-4','OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-5',
  'OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF','AUFTRAG:NewCARGOTRANSPORT','PauseMission(','TaskDone(','CargoTransportation','OnBeforeUnpauseMission',
  'APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF','local PRIMARY_PATHLINE = "OMW_FlightPath_R500"','SLG-zone pickup-first R500 Air-AMMO',
  'local function closeCasIfReady','TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC','countRedGroundGroupsInTacticalZone','immediate PATROLZONE CAS recovery'
)) {
  if ($acceptanceSource.Contains($obsolete)) { throw "Stage 3 acceptance still contains obsolete lifecycle marker: $obsolete" }
}
if ($acceptanceSource.Contains('CasAdapter.MissionMode.CASENHANCED')) { throw 'Stage 3 acceptance must not use CASENHANCED after PATROLZONE reconciliation.' }
if ($acceptanceSource -match 'SetAltitude\s*\(') { throw 'Stage 3 acceptance must not issue a FLIGHTGROUP/OPSGROUP SetAltitude override for CAS.' }
if ($acceptanceSource.Contains('duplicate ~= demand')) { throw 'Stage 3 acceptance must not compare RESUPPLY duplicate Lua table identity.' }
if ($acceptanceSource.Contains('#legions')) { throw 'Stage 3 OPSTRANSPORT acceptance must not use Lua length on alias-keyed legion map.' }

foreach ($marker in @('Controller:setTask','coalition.addGroup','coalition.addStaticObject',':Teleport(','world.addEventHandler','timer.scheduleFunction','PauseMission','CargoTransportation')) {
  if ($opsTransportCorridorSource.Contains($marker)) { throw "OPSTRANSPORT corridor adapter exceeds documented MOOSE-first boundary: $marker" }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua','mist\.','\bMIST\b','(?<![A-Za-z0-9_])io\.','lfs\.','os\.execute',':Teleport\s*\(',
  'world\.addEventHandler','timer\.scheduleFunction','coalition\.addGroup','coalition\.addStaticObject','NewFREIGHTTRANSPORT',
  'AUFTRAG:NewCARGOTRANSPORT','PauseMission\s*\(','TaskDone\s*\(','CargoTransportation','OnBeforeUnpauseMission',
  'casTacticalZone:SetDrawZone','casTacticalZone:SetMarkZone','AUFTRAG:NewGROUNDATTACK\s*\(targets\[i\]','KnowTarget\s*\('
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) { throw "Stage 3 full-response acceptance contains forbidden runtime pattern: $pattern" }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'AttackSite: BLUE_GROUND_COP_HONAKER'
Write-Host 'Guard/QRF: QRF remains in MOOSE ONGUARD until explicit supported-element CAS release; local incident closure alone does not recover QRF'
Write-Host 'CASMission: MOOSE AUFTRAG NewPATROLZONE + SetEngageDetected'
Write-Host 'CASContactSource: AH-64 FLIGHTGROUP:GetDetectedGroups only; no-contact requires a 30-second stable own sensor picture'
Write-Host 'CASRelease: Honaker no-known-attackers + CAS on-station stable own no-contact -> explicit supported-element release -> controlled reverse corridor'
Write-Host 'CASGroundTriggerAuthority: OPSZONE/attackIncident/raw RED counts have no direct CAS termination authority'
Write-Host 'CASAcceptanceEvidence: real EVENTS.Shot OR stable on-station no-contact, plus Jalalabad landing and AIRWING/LEGION recovery, is required before CAS terminal acceptance'
Write-Host 'CASRouteOrder: configured OMW_FlightPath variant -> WEST route-gated dynamic CAS_INGRESS (3.5 NM) -> PATROLZONE dynamic AO anchor -> route-gated dynamic CAS_EGRESS -> WEST reverse -> configured OMW_FlightPath reverse -> Jalalabad'
Write-Host 'FireSupport: 5-NM MOOSE C2 observation -> unique fresh ARTY/QRF target picture; ARTY physical fire uses MOOSE EVENTS.Shot; CAS on station holds new fires -> local M1083 rearm -> strategic reorder'
Write-Host 'StrategicResupply: exactly one RESUPPLY, Jalalabad -> Wright, quantity 15; CampaignState authoritative'
Write-Host 'AirPhysicalMission: MOOSE OPSTRANSPORT with internal STORAGE fixture'
Write-Host 'CH47TransitSpeedKts: 125'
Write-Host 'CH47LeadTurnDistanceM: 250'
Write-Host 'CH47LeadTurnImplementation: public MOOSE COORDINATE:GetIntermediateCoordinate + FLIGHTGROUP:AddWaypoint TurningPoint route geometry'
Write-Host 'AirAmmoRouteOrder: Jalalabad -> configured OMW_FlightPath variant -> Wright -> same configured route reverse -> Jalalabad'
Write-Host 'ExternalSlingload: suspended; no NewCARGOTRANSPORT/PauseMission/CargoTransportation handoff'
Write-Host 'AcceptanceScheduler: 10-second completion check; failed assertions remain visible while independent physical recovery observation continues'
Write-Host "SHA256: $hash"
Write-Host 'MizMutation: false'
