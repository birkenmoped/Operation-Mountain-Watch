[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$demandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
$hitAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_FobAttackHitAdapter.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\src\01-fob-attack-hit-acceptance-1.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\dist'
$outputFile = Join-Path $distDir 'OMW_FOB_Attack_Hit_Acceptance_1.lua'

$builderVersion = 'FOB-ATTACK-HIT-ACCEPTANCE-1-1'
$testId = 'FOB-ATTACK-HIT-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $missionDemandFile,
  $demandPolicyFile,
  $hitAdapterFile,
  $acceptanceSourceFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Stage 2 FOB attack acceptance source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$demandPolicy = Get-Content -LiteralPath $demandPolicyFile -Raw -Encoding UTF8
$hitAdapter = Get-Content -LiteralPath $hitAdapterFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $demandPolicy + $hitAdapter + $acceptanceSource

$requiredMarkers = @(
  'OMW-MISSION-DEMAND-1',
  'CAS_IMMEDIATE',
  'OMW-FOB-ATTACK-DEMAND-POLICY-1',
  'FOB_ATTACK_QUALIFIED',
  'OMW-FOB-ATTACK-HIT-ADAPTER-1',
  'BASE:New()',
  'HandleEvent',
  'EVENTS.Hit',
  'FOB-ATTACK-HIT-ACCEPTANCE-1',
  'TST_BLUE_GND_FORTRESS_HIT_TARGET',
  'BLUE_GROUND_COP_FORTRESS',
  'active_duplicate',
  'SCHEDULER:New'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Stage 2 FOB attack acceptance sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'os\.execute',
  ':Teleport\s*\(',
  'SPAWN:',
  'AUFTRAG:NewCAS',
  'COMMANDER:AddMission',
  'AIRWING',
  'SQUADRON'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern -or $hitAdapter -match $pattern) {
    throw "Stage 2 FOB attack acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Stage 2 FOB attack acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fob-attack-hit-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Stage 2 MOOSE EVENTS.Hit -> qualified Fortress attack -> CAS_IMMEDIATE MissionDemand -> repeated-hit active dedupe.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing MissionDemand/Campaign domain only; no resource mutation.
-- ExplicitExclusions: CAS dispatch, AUFTRAG, COMMANDER mission execution, AIRWING/SQUADRON dispatch, native world event handler, MIST, MissionScripting.lua mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE2_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_STAGE2_FOB_ATTACK_DEMAND_POLICY' $demandPolicy
$bundle += Embed-Module 'OMW_STAGE2_FOB_ATTACK_HIT_ADAPTER' $hitAdapter
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
Write-Host 'TargetGroup: TST_BLUE_GND_FORTRESS_HIT_TARGET'
Write-Host 'InstallationId: BLUE_GROUND_COP_FORTRESS'
Write-Host 'RequiredPhysicalHits: at least 2 real RED-on-BLUE EVENTS.Hit events'
Write-Host 'ExpectedDemandType: CAS_IMMEDIATE'
Write-Host 'ExpectedFirstCreate: true'
Write-Host 'ExpectedSecondCreate: false / active_duplicate'
Write-Host 'ExpectedActiveDemandCount: 1'
Write-Host 'CASDispatch: false'
Write-Host 'NativeWorldEventHandler: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
