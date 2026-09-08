[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sources = [ordered]@{
  OMW_STAGE3_MISSION_DEMAND = 'scripts\campaign\OMW_MissionDemand.lua'
  OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY = 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
  OMW_STAGE3_FOB_THREAT_OPSZONE_ADAPTER = 'scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'
  OMW_STAGE3_GROUND_INSTALLATION_ATTACK_INCIDENT = 'scripts\ground\OMW_GroundInstallationAttackIncident.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER = 'scripts\air-operations\OMW_FobAttackCasDispatchAdapter.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_PATROL_CLOSURE = 'scripts\air-operations\OMW_FobAttackCasPatrolClosure.lua'
  OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR = 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
  OMW_STAGE3_HELICOPTER_MISSION_OWNED_CORRIDOR = 'scripts\air-operations\OMW_HelicopterMissionOwnedCorridor.lua'
  OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT = 'scripts\air-operations\OMW_FlightPathNameContract.lua'
}

$acceptanceRelative = 'mission\tests\stage3-honaker-cas-support\src\01-honaker-cas-support-acceptance.lua'
$acceptanceFile = Join-Path $repoRoot $acceptanceRelative
$jalalabadFoundationFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Jalalabad_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\stage3-honaker-cas-support\dist'
$outputFile = Join-Path $distDir 'OMW_Stage3_Honaker_CAS_Support_Acceptance_1.lua'
$builderVersion = 'STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1-1'
$testId = 'STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$resolved = [ordered]@{}
foreach ($name in $sources.Keys) {
  $path = Join-Path $repoRoot $sources[$name]
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required Stage 3 CAS source not found: $path" }
  $resolved[$name] = $path
}
if (-not (Test-Path -LiteralPath $acceptanceFile -PathType Leaf)) { throw "Acceptance source not found: $acceptanceFile" }
if (-not (Test-Path -LiteralPath $jalalabadFoundationFile -PathType Leaf)) { throw "Jalalabad AirOps foundation source not found: $jalalabadFoundationFile" }

$jalalabadFoundationSource = Get-Content -LiteralPath $jalalabadFoundationFile -Raw -Encoding UTF8
foreach ($marker in @(
  'SQ_US_JBAD_AH64D_B_1_10_AVN',
  'TPL_AIR_US_JBAD_AH64D_CAS_2SHIP',
  'missionTypes = { AUFTRAG.Type.CAS, AUFTRAG.Type.CASENHANCED, AUFTRAG.Type.PATROLZONE }',
  'SetOptionPreferVerticalLanding'
)) {
  if (-not $jalalabadFoundationSource.Contains($marker)) { throw "Jalalabad AirOps foundation missing focused CAS prerequisite: $marker" }
}

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-stage3-honaker-cas-support-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- Scope: focused Honaker CAS support lifecycle and MOOSE detected-target engagement only.
-- GroundIsolation: this bundle does not dispatch Guard, QRF, ARTY or logistics.
-- CASAuthority: OPSZONE/attackIncident/tactical RED counts do not directly terminate CAS.
-- CASStatus: supported-element local status and AH-64 FLIGHTGROUP own detectedgroups are reconciled before explicit release.
-- TargetKnowledge: no blanket KnowTarget/F10-map RED injection; MOOSE/DCS detection remains authoritative for CAS contact reporting.
-- MizMutation: false.

"@

$bundle = $header
$combined = ''
foreach ($name in $resolved.Keys) {
  $source = Get-Content -LiteralPath $resolved[$name] -Raw -Encoding UTF8
  $bundle += Embed-Module $name $source
  $combined += $source
}
$acceptanceSource = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
$bundle += $acceptanceSource
$combined += $acceptanceSource

$required = @(
  'AUFTRAG:NewPATROLZONE',
  'SetEngageDetected',
  'SetDetection(true)',
  'GetDetectedGroups',
  'IsCoordinateInZone',
  'Get3DDistance',
  'CAS_SENSOR_REPORT',
  'CAS_ENGAGE_EVENT',
  'HONAKER_NO_KNOWN_ATTACKERS',
  'SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT',
  'casSupportRequirementActive',
  'casOnStation',
  'casNoContactReported',
  'CasPatrolClosure.Complete',
  'releaseSource=INSTALLATION_ID',
  'MissionOwnedCorridor.ConfigureMission',
  'MissionOwnedCorridor.Bind',
  'FlightPathNameContract.SelectFromRegistry',
  'OMW_FlightPath_WEST',
  'EVENTS.Shot',
  'weapon use does not itself terminate CAS',
  '1000-m alarm perimeter clear. This diagnostic/local alarm transition has NO CAS release authority.'
)
foreach ($marker in $required) {
  if (-not $combined.Contains($marker)) { throw "Focused Stage 3 CAS sources missing marker: $marker" }
}

foreach ($requiredAcceptance in @(
  'local validExecution=state.casFired or state.casNoContactReported',
  'if not state.honakerNoKnownAttackers then return false end',
  'if not state.casOnStation or not state.casNoContactReported then return false end',
  'local detected=state.casFlight:GetDetectedGroups()',
  'state.casTacticalZone:IsCoordinateInZone(coordinate)',
  'flightCoord:Get3DDistance(coordinate)<=UTILS.NMToMeters(CAS_ENGAGE_RANGE_NM)',
  'state.casSupportRequirementActive=true',
  'state.honakerNoKnownAttackers=true'
)) {
  if (-not $acceptanceSource.Contains($requiredAcceptance)) { throw "Focused Stage 3 CAS acceptance missing lifecycle guard: $requiredAcceptance" }
}

foreach ($obsolete in @(
  'closeCasIfReady',
  'not state.attackIncidentClosed or not state.casDemand',
  'TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC',
  'countRedGroundGroupsInTacticalZone',
  'AUFTRAG:NewCARGOTRANSPORT',
  'CASENHANCED',
  'PauseMission(',
  'TaskDone(',
  'CargoTransportation',
  'KnowTarget('
)) {
  if ($acceptanceSource.Contains($obsolete)) { throw "Focused Stage 3 CAS acceptance contains forbidden lifecycle/knowledge marker: $obsolete" }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'mist\.',
  '\bMIST\b',
  '(?<![A-Za-z0-9_])io\.',
  'lfs\.',
  'os\.execute',
  'coalition\.addGroup',
  'coalition\.addStaticObject',
  ':Teleport\('
)
foreach ($pattern in $forbiddenPatterns) {
  if ($combined -match $pattern) { throw "Focused Stage 3 CAS bundle violates project boundary: $pattern" }
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $outputFile).Hash

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host "CASMission: MOOSE AUFTRAG NewPATROLZONE + SetEngageDetected"
Write-Host "CASContactSource: AH-64 FLIGHTGROUP:GetDetectedGroups only"
Write-Host "CASRelease: Honaker no-known-attackers status + CAS on-station no-contact report -> explicit supported-element release"
Write-Host "GroundTriggerAuthority: OPSZONE/attackIncident retained for local alarm/status only; no direct CAS termination"
Write-Host "CASRoute: configured logical OMW_FlightPath -> WEST -> PATROLZONE -> WEST reverse -> configured logical OMW_FlightPath reverse -> Jalalabad"
Write-Host "GroundIsolation: Guard/QRF/ARTY/logistics not dispatched by focused CAS acceptance"
Write-Host "MizMutation: false"
Write-Host "SHA256: $hash"
