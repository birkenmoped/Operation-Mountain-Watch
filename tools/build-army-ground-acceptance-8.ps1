[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$initializerFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
$airOpsStockFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
$aarStockFile = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
$groundStockFile = Join-Path $repoRoot 'scripts\logistics\OMW_GroundInitialStock.lua'
$adapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundCampaignStateAdapter.lua'
$integrationFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRuntimeIntegration.lua'
$testFile = Join-Path $repoRoot 'mission\tests\army-ground-foundation\src\08-army-ground-production-integration.lua'
$distDir = Join-Path $repoRoot 'mission\tests\army-ground-foundation\dist'
$outputFile = Join-Path $distDir 'OMW_Army_Ground_Acceptance_8.lua'

$builderVersion = 'ARMY-GROUND-ACCEPTANCE-8-1'
$testId = 'ARMY-GROUND-ACCEPTANCE-8-1'

$files = @(
  $campaignStateFile,
  $initializerFile,
  $airOpsStockFile,
  $aarStockFile,
  $groundStockFile,
  $adapterFile,
  $integrationFile,
  $testFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Acceptance 8 source not found: $file"
  }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$initializer = Get-Content -LiteralPath $initializerFile -Raw -Encoding UTF8
$airOpsStock = Get-Content -LiteralPath $airOpsStockFile -Raw -Encoding UTF8
$aarStock = Get-Content -LiteralPath $aarStockFile -Raw -Encoding UTF8
$groundStock = Get-Content -LiteralPath $groundStockFile -Raw -Encoding UTF8
$adapter = Get-Content -LiteralPath $adapterFile -Raw -Encoding UTF8
$integration = Get-Content -LiteralPath $integrationFile -Raw -Encoding UTF8
$test = Get-Content -LiteralPath $testFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-4',
  'OMW-GROUND-INITIAL-STOCK-1',
  'OMW-GROUND-RUNTIME-INTEGRATION-1',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_JOYCE',
  'GROUND_NODE_WRIGHT',
  'GROUND_NODE_BOSTICK',
  'GROUND:GROUND_NODE_JOYCE:VEHICLE_LOST',
  'GROUND:GROUND_NODE_JOYCE:PERSONNEL_LOST',
  'GroundRuntimeIntegration.Attach',
  'GroundCampaignStateAdapter',
  'AirOpsCampaignStateInitializer.CreateStore',
  'AARStrategicStock',
  'GroundInitialStock',
  'RESTART_OK',
  'RUNTIME_PASS'
)
$combined = $initializer + $groundStock + $adapter + $integration + $test
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Acceptance 8 sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'mist\.',
  'MIST',
  '(?<![A-Za-z0-9_])io\.',
  'lfs\.',
  'os\.execute',
  ':Teleport\s*\(',
  '_DATABASE:Spawn',
  '_SpawnAssetGroundNaval'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($test -match $pattern -or $integration -match $pattern -or $groundStock -match $pattern) {
    throw "Acceptance 8 production integration contains forbidden pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-army-ground-acceptance-8.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: production-shaped single-CampaignState composition for AirOps, AAR and ARMY Ground stock; Ground settlement adapter attachment; loss/return exactly-once; restart strategic recredit exactly-once.
-- MOOSE/DCS lifecycle: none introduced by this gate. Acceptance 7 remains the validated MOOSE Ground lifecycle evidence.
-- ProductionBaselineMutation: false
-- MizMutation: false

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'CampaignState' $campaignState
$bundle += Embed-Module 'AirOpsCampaignStateInitializer' $initializer
$bundle += Embed-Module 'AirOpsInitialStock' $airOpsStock
$bundle += Embed-Module 'AARStrategicStock' $aarStock
$bundle += Embed-Module 'GroundInitialStock' $groundStock
$bundle += Embed-Module 'GroundCampaignStateAdapter' $adapter
$bundle += Embed-Module 'GroundRuntimeIntegration' $integration
$bundle += $test

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "CampaignStateComposition: AirOps + AAR + Ground in one store"
Write-Host "GroundNodes: GROUND_NODE_JALALABAD,GROUND_NODE_JOYCE,GROUND_NODE_WRIGHT,GROUND_NODE_BOSTICK"
Write-Host "MotorizedPatrolContract: 1 M-ATV = 1 VEHICLE + 3 PERSONNEL"
Write-Host "GroundLifecycleMutation: false"
Write-Host "MOOSEOverride: false"
Write-Host "ProductionBaselineMutation: false"
Write-Host "MizMutation: false"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
