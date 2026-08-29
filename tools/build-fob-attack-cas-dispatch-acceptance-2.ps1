[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$demandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
$threatAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'
$casDispatchAdapterFile = Join-Path $repoRoot 'scripts\air-operations\OMW_FobAttackCasDispatchAdapter.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\src\02-fob-attack-cas-dispatch-acceptance-2.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\dist'
$outputFile = Join-Path $distDir 'OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua'

$builderVersion = 'FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-1'
$testId = 'FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @($missionDemandFile, $demandPolicyFile, $threatAdapterFile, $casDispatchAdapterFile, $acceptanceSourceFile)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Stage 2B acceptance source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$demandPolicy = Get-Content -LiteralPath $demandPolicyFile -Raw -Encoding UTF8
$threatAdapter = Get-Content -LiteralPath $threatAdapterFile -Raw -Encoding UTF8
$casDispatchAdapter = Get-Content -LiteralPath $casDispatchAdapterFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $demandPolicy + $threatAdapter + $casDispatchAdapter + $acceptanceSource

$requiredMarkers = @(
  'CAS_IMMEDIATE', 'OPSZONE:New', 'OnAfterAttacked',
  'OMW-FOB-ATTACK-CAS-DISPATCH-ADAPTER-1', 'AUFTRAG:NewCAS', 'AddMission',
  'AssignAI', 'OnAfterExecuting', 'Activate', 'OnAfterFlightOnMission',
  'FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2', 'AW_US_JBAD_TF_SHOOTER_6_6_CAV',
  'SQ_US_JBAD_AH64D_B_1_10_AVN', 'CAS_ALTITUDE_FT = 10000', 'CAS_SPEED_KTS = 120'
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
  if ($acceptanceSource -match $pattern -or $casDispatchAdapter -match $pattern -or $threatAdapter -match $pattern) {
    throw "Stage 2B acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Stage 2B acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fob-attack-cas-dispatch-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Stage-2A Fortress OPSZONE threat -> CAS_IMMEDIATE MissionDemand -> existing running Jalalabad AIRWING/AH64D CAS capability -> AUFTRAG NewCAS -> AIRWING AddMission -> real FLIGHTGROUP -> AUFTRAG Executing.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- RequiredBefore: existing OMW AirOps Warehouse Base, Ground Base attach, and OMW_AirOps_Jalalabad_Bootstrap.lua RUNNING.
-- StrategicAuthority: pre-existing OMW.AirOps.CampaignContext; this Stage 2B adapter owns no strategic resources.
-- CASAcceptanceProfile: AH64D, 10000 ft, 120 kts; acceptance-only execution profile, not a production routing/altitude/speed policy.
-- ExplicitExclusions: direct SPAWN, native world event handler, MIST, MissionScripting.lua mutation, new CampaignState, COMMANDER routing policy.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE2B_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_STAGE2B_FOB_ATTACK_DEMAND_POLICY' $demandPolicy
$bundle += Embed-Module 'OMW_STAGE2B_FOB_THREAT_OPSZONE_ADAPTER' $threatAdapter
$bundle += Embed-Module 'OMW_STAGE2B_FOB_ATTACK_CAS_DISPATCH_ADAPTER' $casDispatchAdapter
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
Write-Host 'CASAirwing: AW_US_JBAD_TF_SHOOTER_6_6_CAV'
Write-Host 'CASSquadron: SQ_US_JBAD_AH64D_B_1_10_AVN'
Write-Host 'CASMissionType: AUFTRAG.Type.CAS'
Write-Host 'CASAltitudeFt: 10000 (acceptance-only)'
Write-Host 'CASSpeedKts: 120 (acceptance-only)'
Write-Host 'ExpectedDemandAssignment: AI_ASSIGNED -> ACTIVE on AUFTRAG Executing'
Write-Host 'ExpectedMaterializationEvidence: AIRWING OnAfterFlightOnMission'
Write-Host 'ExpectedExecutionEvidence: AUFTRAG OnAfterExecuting'
Write-Host 'DirectSpawn: false'
Write-Host 'CommanderCreated: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
