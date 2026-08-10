[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$adapterFile = Join-Path $repoRoot 'scripts\logistics\OMW_StorageFuelAdapter.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-fuel-adapter\src\01-storage-fuel-adapter-foundation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-fuel-adapter\dist'
$outputFile = Join-Path $distDir 'OMW_StorageFuelAdapter_Foundation_Test.lua'
$builderVersion = 'STORAGE-FUEL-ADAPTER-FOUNDATION-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($file in @($adapterFile, $harnessFile)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required source file not found: $file"
    }
}

$adapter = Get-Content -LiteralPath $adapterFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredAdapterMarkers = @(
    'FUEL_JP8',
    'FUEL_AVGAS',
    'STORAGE.Liquid.JETFUEL',
    'STORAGE.Liquid.GASOLINE',
    'STORAGE:FindByName',
    'GetLiquidAmount',
    'SetLiquid',
    'function StorageFuelAdapter.PlanSnapshot',
    'function StorageFuelAdapter.ApplySnapshot',
    'return StorageFuelAdapter'
)
foreach ($marker in $requiredAdapterMarkers) {
    if (-not $adapter.Contains($marker)) {
        throw "Storage fuel adapter source is missing required marker: $marker"
    }
}

$requiredHarnessMarkers = @(
    'STORAGE-FUEL-ADAPTER-FOUNDATION-1',
    'HUB_KANDAHAR',
    'WRITE_READBACK_PASS',
    'IDEMPOTENCY_PASS',
    'RESTORE_PASS',
    'automaticAircraftDebit=false',
    'campaignStateMutation=false'
)
foreach ($marker in $requiredHarnessMarkers) {
    if (-not $harness.Contains($marker)) {
        throw "Storage fuel adapter harness is missing required marker: $marker"
    }
}

$forbiddenAdapterPatterns = @(
    'CampaignState\s*[:\.]',
    'SCHEDULER\s*:',
    'timer\.scheduleFunction',
    'StartAutoSave',
    'SaveToFile',
    'LoadFromFile',
    'AddLiquid\s*\(',
    'RemoveLiquid\s*\(',
    'IsUnlimitedLiquids\s*\(',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:'
)
foreach ($pattern in $forbiddenAdapterPatterns) {
    if ($adapter -match $pattern) {
        throw "Storage fuel adapter contains forbidden foundation pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-fuel-adapter-foundation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: controlled MOOSE STORAGE liquid mirror test; no CampaignState mutation, persistence, transport, or aircraft fuel debit.

"@

$wrappedAdapter = "local OMWStorageFuelAdapter = (function()`n$adapter`nend)()`n`n"
$content = $header + $wrappedAdapter + $harness

foreach ($marker in @('FUEL_JP8', 'FUEL_AVGAS', 'WRITE_READBACK_PASS', 'IDEMPOTENCY_PASS', 'RESTORE_PASS')) {
    if (-not $content.Contains($marker)) {
        throw "Generated bundle is missing required marker: $marker"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_FUEL_ADAPTER_FOUNDATION"
Write-Host "Node: HUB_KANDAHAR"
Write-Host "FuelResources: FUEL_JP8,FUEL_AVGAS"
Write-Host "CanonicalUnit: kg"
Write-Host "AutomaticAircraftDebit: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "Persistence: ABSENT"
Write-Host "Transport: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
