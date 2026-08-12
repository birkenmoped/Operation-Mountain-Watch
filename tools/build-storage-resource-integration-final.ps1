[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$manifestFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsResourceManifest.lua'
$observerFile = Join-Path $repoRoot 'scripts\logistics\OMW_StorageResourceObserver.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-resource-integration-final\src\01-storage-resource-integration-final.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-resource-integration-final\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Resource_Integration_Final.lua'
$builderVersion = 'STORAGE-RESOURCE-INTEGRATION-FINAL-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-client-fuel-exchange'
$baseCommit = '6a9332aae2334efbcace4226147eb6d0a83dd5a6'

foreach ($file in @($campaignStateFile, $manifestFile, $observerFile, $harnessFile)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required source file not found: $file"
    }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$manifest = Get-Content -LiteralPath $manifestFile -Raw -Encoding UTF8
$observer = Get-Content -LiteralPath $observerFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

foreach ($marker in @('FUEL_JP8','FUEL_AVGAS','function CampaignState.New','function Store:GetResource','return CampaignState')) {
    if (-not $campaignState.Contains($marker)) { throw "CampaignState source is missing required marker: $marker" }
}
foreach ($marker in @(
    'AMMUNITION_HELLFIRE',
    'AMMUNITION_ROCKETS_70MM',
    'AMMUNITION_30MM_M230',
    'AMMUNITION_30MM_GAU8',
    'AMMUNITION_50CAL_M3P',
    'weapons.missiles.AGM_114K',
    'weapons.nurs.HYDRA_70_M151',
    'weapons.droptanks.{IAFS_ComboPak_100}',
    'weapons.droptanks.fuel_tank_370gal',
    'function AirOpsResourceManifest.GetReconciliationEntries',
    'return AirOpsResourceManifest'
)) {
    if (-not $manifest.Contains($marker)) { throw "Resource manifest is missing required marker: $marker" }
}
foreach ($marker in @(
    'STORAGE:FindByName',
    'GetLiquidAmount',
    'GetItemAmount',
    'function StorageResourceObserver.New',
    'function Observer:ReadNode',
    'function Observer:CompareNode',
    'function Observer:MeasureDelta',
    'return StorageResourceObserver'
)) {
    if (-not $observer.Contains($marker)) { throw "Storage observer is missing required marker: $marker" }
}
foreach ($marker in @(
    'STORAGE-RESOURCE-INTEGRATION-FINAL-1',
    'BASELINE_RECONCILIATION_PASS',
    'DRIFT_GUARD_PASS',
    'DELTA_MEASUREMENT_PASS',
    'MAPPING_SCOPE_PASS',
    'RESULT status=PASS',
    'Bagram',
    'Shindand Heliport'
)) {
    if (-not $harness.Contains($marker)) { throw "Harness is missing required marker: $marker" }
}

$forbiddenPatterns = @(
    'SetLiquid\s*\(',
    'AddLiquid\s*\(',
    'RemoveLiquid\s*\(',
    'SetItem\s*\(',
    'AddItem\s*\(',
    'RemoveItem\s*\(',
    'coalition\.addGroup',
    'trigger\.action\.explosion',
    'unit:destroy',
    'OPSGROUP\s*:\s*Destroy',
    'ReturnToLegion\s*\(',
    '_DATABASE',
    'world\.searchObjects',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($manifest -match $pattern -or $observer -match $pattern -or $harness -match $pattern) {
        throw "Final integration source contains forbidden pattern: $pattern"
    }
}

if ($observer -match 'campaignStateStore\s*[:\.]\s*(Set|Add|Remove|Consume|Reserve|Mark)') {
    throw 'Observer must not mutate CampaignState'
}
if ($harness -match 'nodesById' -or $harness -match '_DATABASE') {
    throw 'Harness must not access CampaignState or MOOSE internals directly'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-resource-integration-final.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only MOOSE STORAGE resource mapping, CampaignState comparison, drift guard and bounded reconciliation acceptance.

"@

$content = $header
$content += "local OMWCampaignState = (function()`n$campaignState`nend)()`n`n"
$content += "local OMWAirOpsResourceManifest = (function()`n$manifest`nend)()`n`n"
$content += "local OMWStorageResourceObserver = (function()`n$observer`nend)()`n`n"
$content += $harness

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_RESOURCE_INTEGRATION_FINAL"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "Nodes: Bagram;Shindand Heliport"
Write-Host "CompleteReconciliationResources: FUEL_JP8,FUEL_AVGAS"
Write-Host "VariantTelemetry: AGM_114K,HYDRA_70_M151,IAFS_ComboPak_100,F16_370GAL_TANK"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutationByObserver: ABSENT"
Write-Host "NativeDcsFallback: ABSENT"
Write-Host "Scheduler: BOUNDED_ONE_SHOT_10S"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
