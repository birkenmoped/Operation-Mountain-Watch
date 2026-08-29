[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$resourceDemandCoordinatorFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandCoordinator.lua'
$demandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
$personnelLedgerFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundPersonnelDeploymentLedger.lua'
$threatAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'
$casDispatchAdapterFile = Join-Path $repoRoot 'scripts\air-operations\OMW_FobAttackCasDispatchAdapter.lua'
$helicopterCorridorFile = Join-Path $repoRoot 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\src\02-fob-attack-cas-dispatch-acceptance-2.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\dist'
$outputFile = Join-Path $distDir 'OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua'

$builderVersion = 'FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-2'
$testId = 'FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $missionDemandFile, $resourceDemandPolicyFile, $resourceDemandCoordinatorFile,
  $demandPolicyFile, $personnelLedgerFile, $threatAdapterFile,
  $casDispatchAdapterFile, $helicopterCorridorFile, $acceptanceSourceFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Stage 2B acceptance source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$resourceDemandPolicy = Get-Content -LiteralPath $resourceDemandPolicyFile -Raw -Encoding UTF8
$resourceDemandCoordinator = Get-Content -LiteralPath $resourceDemandCoordinatorFile -Raw -Encoding UTF8
$demandPolicy = Get-Content -LiteralPath $demandPolicyFile -Raw -Encoding UTF8
$personnelLedger = Get-Content -LiteralPath $personnelLedgerFile -Raw -Encoding UTF8
$threatAdapter = Get-Content -LiteralPath $threatAdapterFile -Raw -Encoding UTF8
$casDispatchAdapter = Get-Content -LiteralPath $casDispatchAdapterFile -Raw -Encoding UTF8
$helicopterCorridor = Get-Content -LiteralPath $helicopterCorridorFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $resourceDemandPolicy + $resourceDemandCoordinator + $demandPolicy + $personnelLedger + $threatAdapter + $casDispatchAdapter + $helicopterCorridor + $acceptanceSource

$requiredMarkers = @(
  'CAS_IMMEDIATE', 'OPSZONE:New', 'OnAfterAttacked', 'OnAfterDefeated',
  'OMW-FOB-ATTACK-CAS-DISPATCH-ADAPTER-2', 'AUFTRAG:NewCAS', 'RequestMissionClosure',
  'AUFTRAG:NewGROUNDATTACK', 'RTZ', 'OnAfterReturned', 'GetNelements',
  'OMW-GROUND-PERSONNEL-DEPLOYMENT-LEDGER-1', 'OMW-RESOURCE-DEMAND-COORDINATOR-1',
  'OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-1', 'PATHLINE:FindByName', 'OMW_FlightPath',
  'OnAfterFlightOnMission', 'OnAfterRTB', 'OnAfterLanded', 'OnAfterArrived',
  'FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2', 'AW_US_JBAD_TF_SHOOTER_6_6_CAV',
  'SQ_US_JBAD_AH64D_B_1_10_AVN', 'PERSONNEL_RESERVE_FLOOR = 80'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Stage 2B acceptance sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'CampaignState\.New', 'CampaignState\.Restore', 'MissionScripting\.lua',
  'mist\.', '\bMIST\b', 'world\.addEventHandler', 'timer\.scheduleFunction',
  'os\.execute', ':Teleport\s*\(', 'SPAWN:'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern -or $casDispatchAdapter -match $pattern -or $threatAdapter -match $pattern -or $helicopterCorridor -match $pattern) {
    throw "Stage 2B acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) { Remove-Item -LiteralPath $outputFile -Force }

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD for Stage 2B acceptance build.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fob-attack-cas-dispatch-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Fortress OPSZONE threat -> CAS_IMMEDIATE -> existing Jalalabad AH64D CAS via OMW_FlightPath -> OPSZONE Defeated threat-clear -> AUFTRAG Cancel -> FLIGHTGROUP RTB/Landed/Arrived; parallel CampaignState-reserved infantry QRF via GROUNDATTACK -> RTZ ACCESS recovery -> Returned/Warehouse -> exact casualty settlement -> PERSONNEL reorder evaluation.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- RequiredBefore: existing OMW AirOps Warehouse Base, Ground Base attach, OMW_AirOps_Jalalabad_Bootstrap.lua RUNNING, owner-authored PATHLINE OMW_FlightPath.
-- StrategicAuthority: pre-existing OMW Ground CampaignState; deployed personnel are reserved, not consumed; only confirmed casualties permanently decrement strategic quantity.
-- DefenceReserveFloor: 80 PERSONNEL for Fortress acceptance (50 percent of target 160).
-- RecoveryHandoff: ZON_BLUE_GND_FORTRESS_ACCESS; operational return/materialization boundary, not security geometry.
-- ExplicitExclusions: direct SPAWN, native world event handler, MIST, MissionScripting.lua mutation, new CampaignState, custom presence/ammo polling.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE2B_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_STAGE2B_RESOURCE_DEMAND_POLICY' $resourceDemandPolicy
$bundle += Embed-Module 'OMW_STAGE2B_RESOURCE_DEMAND_COORDINATOR' $resourceDemandCoordinator
$bundle += Embed-Module 'OMW_STAGE2B_FOB_ATTACK_DEMAND_POLICY' $demandPolicy
$bundle += Embed-Module 'OMW_STAGE2B_GROUND_PERSONNEL_DEPLOYMENT_LEDGER' $personnelLedger
$bundle += Embed-Module 'OMW_STAGE2B_FOB_THREAT_OPSZONE_ADAPTER' $threatAdapter
$bundle += Embed-Module 'OMW_STAGE2B_FOB_ATTACK_CAS_DISPATCH_ADAPTER' $casDispatchAdapter
$bundle += Embed-Module 'OMW_STAGE2B_HELICOPTER_FLIGHTPATH_CORRIDOR' $helicopterCorridor
$bundle += $acceptanceSource

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'RequiresGroundBaseAttached: true'
Write-Host 'RequiresJalalabadAirOpsRunning: true'
Write-Host 'RequiresPathline: OMW_FlightPath'
Write-Host 'CASAirwing: AW_US_JBAD_TF_SHOOTER_6_6_CAV'
Write-Host 'CASSquadron: SQ_US_JBAD_AH64D_B_1_10_AVN'
Write-Host 'CASMissionType: AUFTRAG.Type.CAS'
Write-Host 'CASClosure: OPSZONE Defeated(RED) -> AUFTRAG Cancel -> FLIGHTGROUP RTB/Landed/Arrived'
Write-Host 'CASHelicopterCorridor: OMW_FlightPath / 500m directional right offset / 500ft AGL'
Write-Host 'LocalCounterattack: AUFTRAG.Type.GROUNDATTACK'
Write-Host 'GroundRecovery: ARMYGROUP RTZ -> ZON_BLUE_GND_FORTRESS_ACCESS -> Returned -> Warehouse AddAsset'
Write-Host 'PersonnelAccounting: reserve while deployed; consume confirmed casualties only'
Write-Host 'FortressDefenceReserveFloor: 80'
Write-Host 'PostCombatReorderEvaluation: strict existing GroundInitialStock policy'
Write-Host 'DirectSpawn: false'
Write-Host 'CommanderCreated: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
