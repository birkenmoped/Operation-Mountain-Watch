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
  OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF = 'scripts\air-operations\OMW_SlingloadCorridorHandoff.lua'
  OMW_STAGE3_HELICOPTER_MISSION_OWNED_CORRIDOR = 'scripts\air-operations\OMW_HelicopterMissionOwnedCorridor.lua'
}
$acceptanceRelative = 'mission\tests\stage3-honaker-wright-full-response\src\01-honaker-wright-full-response-acceptance.lua'
$acceptanceFile = Join-Path $repoRoot $acceptanceRelative
$jalalabadFoundationFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Jalalabad_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist'
$outputFile = Join-Path $distDir 'OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua'
$builderVersion = 'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-15'
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
  'missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED, AUFTRAG.Type.PATROLZONE }'
)) {
  if (-not $jalalabadFoundationSource.Contains($marker)) { throw "Jalalabad AirOps foundation missing Stage 3 CAS prerequisite: $marker" }
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
-- Scope: Honaker attack -> Guard PATHLINE patrol + 5-NM tactical-clear gated mixed QRF recovery + PATROLZONE/EngageDetected CAS corridor lifecycle + Wright ARTY/rearm -> CampaignState AMMO reorder -> Jalalabad CH47 pickup-first Air-AMMO -> Wright -> route return.
-- Guard: TPL_BLUE_GND_INF_RIFLE_SQUAD_9 materialized through Honaker BRIGADE/PLATOON and routed repeatedly over OMW_RTE_BLUE_GUARD_HONAKER_01 using public MOOSE PATHLINE/GetCoordinates/WaypointGround/TaskFunction/SetTaskWaypoint/Route APIs.
-- QRF: one TPL_BLUE_GND_QRF_MIXED_6 GROUP, five infantry plus one CHAP_MATV, no embark/disembark, 5 GROUND_PERSONNEL reserved while deployed; after zero active RED ground groups remain in the 5-NM tactical area, mission Cancel + SetReturnToLegion(true) returns survivors and settles reservation.
-- CAS: native AUFTRAG ingress is the common-route entry; mission-owned R500/WEST outbound reaches CAS; non-mission-owned WEST/R500 recovery waypoints survive AUFTRAG cancellation and lead back to Jalalabad.
-- AirAmmo: MOOSE CARGOTRANSPORT performs physical pickup; after confirmed pickup the owner-approved narrow CargoTransportation handoff constrains outbound R500 routing, re-issues the same DCS cargo task at the Wright route exit, and preserves R500 return routing.
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
$bundle += $acceptanceSource
$combinedForValidation += $acceptanceSource

$requiredMarkers = @(
  'FIRE_SUPPORT_IMMEDIATE','OPSZONE','OnAfterEvaluated','GetScannedGroupSet','PROXIMITY_INTRUSION','TACTICAL_AREA_CLEAR',
  'ARTY:New','AssignTargetCoord','QueueTarget','LIVE_FIRE_RETARGET','SetWaitForShotTime','verifyFireComplete','PHYSICAL_AMMO_UNCHANGED',
  'TPL_BLUE_GND_INF_RIFLE_SQUAD_9','TPL_BLUE_GND_QRF_MIXED_6','OMW_RTE_BLUE_GUARD_HONAKER_01',
  'PATHLINE:FindByName','GetCoordinates','WaypointGround','TaskFunction("CONTROLLABLE.Route"','SetTaskWaypoint','state.guardGroup:Route',
  'AUFTRAG:NewONGUARD','SetEngageDetected','AssignCohort','SetReturnToLegion(true)','OnAfterReturned','SettleReturned','qrfReturned',
  'SET_GROUP:New','FilterCoalitions("red")','FilterCategoryGround','FilterActive(true)','FilterZones({state.casTacticalZone})','CountAlive',
  'AUFTRAG:NewPATROLZONE','PATROLZONE_ENGAGE','CAS_TACTICAL_RADIUS_NM','CAS_COMBAT_HEIGHT_FT_AGL','GetLandHeight','NMToMeters',
  'SetMissionIngressCoord','SetMissionEgressCoord','missionUID','GetGroupEgressWaypointUID','OnAfterUpdateRoute','ConfirmExecutionEvidence','EVENTS.Shot',
  'OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-4','MOOSE_NATIVE_CORRIDOR_ENTRY_PLUS_PERSISTENT_RECOVERY_ROUTE','MISSION_OVER_RECOVERY_ROUTE_PRESERVED',
  'OMW-FOB-ATTACK-CAS-PATROL-CLOSURE-1','AssignSquadrons','squadrons={state.ah64d}',
  'PATHLINE_SUFFIX','ParsePathlineOffset','OMW_FlightPath_R500','OMW_FlightPath_WEST','WEST_ALTITUDE_FT_AGL','ResolveSequence',
  'OMW-SLINGLOAD-CORRIDOR-HANDOFF-1','APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF','GetWaypointCurrentUID','AddTaskWaypoint','CargoTransportation','AUFTRAG:Success()',
  'GROUND_AMMO_PACKAGE','GROUND_NODE_WRIGHT','GROUND_NODE_JALALABAD','TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2','TPL_BLUE_GND_SUP_M1083',
  'AUFTRAG:NewCARGOTRANSPORT','SQ_US_JBAD_CH47_HEAVYLIFT','MarkInTransit','MarkDelivered','active_duplicate','duplicate.id','duplicate.dedupeKey',
  'state.threat:Stop()','state.airCorridorRequested=true','state.finishScheduler:Stop()','MESSAGE:New','onThreatCleared','perimeterClear'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combinedForValidation.Contains($marker)) { throw "Stage 3 full-response sources missing marker: $marker" }
}

foreach ($marker in @(
  'local GUARD_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"',
  'local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"',
  'local QRF_PERSONNEL = 5',
  'local GUARD_PATHLINE = "OMW_RTE_BLUE_GUARD_HONAKER_01"',
  'state.guardPathline = need(PATHLINE:FindByName(GUARD_PATHLINE), GUARD_PATHLINE)',
  'state.qrfPlatoon = PLATOON:New(QRF_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_QRF_MIXED_6")',
  'mission:SetReturnToLegion(true)',
  'entry.mission:Cancel()',
  'local tacticalRed=countRedGroundGroupsInTacticalZone()',
  'if tacticalRed==nil or tacticalRed>0 then return false end',
  'state.threat:Stop()',
  'if state.cargo:IsInZone(ZONE:FindByName(PICKUP_ZONE)) then return end',
  'installCargoCorridor(FlightGroup, Mission, ZONE:FindByName(DROP_ZONE):GetCoordinate(), AIR_AMMO_PATHLINES)',
  'state.finishScheduler=SCHEDULER:New(nil,finish,{},10,10)'
)) {
  if (-not $acceptanceSource.Contains($marker)) { throw "Stage 3 acceptance missing lifecycle marker: $marker" }
}

foreach ($obsolete in @(
  'QRF_VEHICLE_TEMPLATE',
  'TPL_BLUE_GND_QRF_MIXED_4',
  'qrfVehiclePlatoon',
  'qrfInfDeployed',
  'qrfVehicleDeployed',
  'GROUP:FindByName(GUARD_ROUTE_GROUP)',
  'state.guardGroup:PatrolRoute()',
  'state.finishScheduler=SCHEDULER:New(nil,finish,{},10,2)',
  'CH-47 assigned; Air-AMMO manifest loading at Jalalabad", 10)\n    installCargoCorridor'
)) {
  if ($acceptanceSource.Contains($obsolete)) { throw "Stage 3 acceptance still contains obsolete marker: $obsolete" }
}
if ($acceptanceSource.Contains('CasAdapter.MissionMode.CASENHANCED')) { throw 'Stage 3 acceptance must not use CASENHANCED after PATROLZONE reconciliation.' }
if ($acceptanceSource -match 'SetAltitude\s*\(') { throw 'Stage 3 acceptance must not issue a FLIGHTGROUP/OPSGROUP SetAltitude override for CAS.' }
if ($acceptanceSource.Contains('duplicate ~= demand')) { throw 'Stage 3 acceptance must not compare RESUPPLY duplicate Lua table identity.' }

$slingloadSource = Get-Content -LiteralPath $resolved['OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF'] -Raw -Encoding UTF8
foreach ($marker in @('Controller:setTask','coalition.addGroup','coalition.addStaticObject',':Teleport(','world.addEventHandler','timer.scheduleFunction')) {
  if ($slingloadSource.Contains($marker)) { throw "Approved slingload handoff exceeds documented exception boundary: $marker" }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua','mist\.','\bMIST\b','(?<![A-Za-z0-9_])io\.','lfs\.','os\.execute',':Teleport\s*\(',
  'world\.addEventHandler','timer\.scheduleFunction','coalition\.addGroup','coalition\.addStaticObject','AddCargoStorage','NewFREIGHTTRANSPORT',
  'casTacticalZone:SetDrawZone','casTacticalZone:SetMarkZone','AUFTRAG:NewGROUNDATTACK\s*\(targets\[i\]'
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
Write-Host 'GuardTemplate: TPL_BLUE_GND_INF_RIFLE_SQUAD_9'
Write-Host 'GuardPathline: OMW_RTE_BLUE_GUARD_HONAKER_01'
Write-Host 'GuardRouting: MOOSE PATHLINE GetCoordinates -> COORDINATE WaypointGround -> GROUP TaskFunction/SetTaskWaypoint/Route repeated circuit'
Write-Host 'QRFTemplate: TPL_BLUE_GND_QRF_MIXED_6'
Write-Host 'ResponseCompletionGate: zero active RED ground groups in 5-NM tactical zone via MOOSE SET_GROUP FilterOnce/CountAlive'
Write-Host 'QRFReturn: MOOSE AUFTRAG Cancel + SetReturnToLegion(true) -> ARMYGROUP RTZ/Returned -> PersonnelLedger settlement'
Write-Host 'CASMission: MOOSE AUFTRAG NewPATROLZONE + SetEngageDetected'
Write-Host 'CASRouteOrder: spawn -> native ingress at common-route entry -> R500 -> WEST -> CAS -> persistent WEST reverse -> R500 reverse -> Jalalabad'
Write-Host 'CASRecoveryOwnership: return waypoints are non-mission FLIGHTGROUP waypoints and survive AUFTRAG Cancel'
Write-Host 'CASRouteOutboundAltitude: R500 500ft AGL -> WEST 2500ft AGL'
Write-Host 'CASRouteReturnAltitude: WEST 2500ft AGL -> R500 500ft AGL'
Write-Host 'ThreatCleanup: MOOSE OPSZONE Stop only after 5-NM tactical-clear response completion'
Write-Host 'FireSupport: Wright TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2 via MOOSE Functional ARTY AssignTargetCoord / DCS Fire At Point'
Write-Host 'StrategicResupply: exactly one RESUPPLY, Jalalabad -> Wright, quantity 15'
Write-Host 'AirPhysicalMission: MOOSE AUFTRAG CARGOTRANSPORT'
Write-Host 'AirAmmoRouteOrder: spawn -> MOOSE slingload pickup confirmed -> R500 outbound -> re-issued CargoTransportation at Wright exit -> physical delivery -> R500 reverse -> Jalalabad'
Write-Host 'AirAmmoException: owner-approved narrow DCS CargoTransportation waypoint-task handoff; no raw Controller/setTask, spawn or teleport path'
Write-Host 'AcceptanceScheduler: 10-second completion check; stops on PASS/FAIL'
Write-Host "SHA256: $hash"
Write-Host 'MizMutation: false'
