[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-client-fuel-exchange\src\01-storage-client-fuel-exchange.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-client-fuel-exchange\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Client_Fuel_Exchange_Test.lua'
$builderVersion = 'STORAGE-CLIENT-FUEL-EXCHANGE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-client-rearm-exchange'
$baseCommit = 'ffe1943d46e04b9e4aca341ef2497dbde61576fd'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-CLIENT-FUEL-EXCHANGE-1',
    'AIRBASE:FindByName',
    'airbase:GetStorage()',
    'STORAGE:FindByName',
    'GetLiquidAmount(STORAGE.Liquid.JETFUEL)',
    'client:GetCurrentFuelKgs()',
    'SET_CLIENT:New()',
    'FilterTypes(CLIENT_TYPE)',
    'SCHEDULER:New',
    'storageJetFuelKg',
    'aircraftFuelKg',
    'combinedDeltaKg',
    'storageMutation=false',
    'campaignStateMutation=false',
    'POLL_INTERVAL_S = 2',
    'MAX_RUNTIME_S = 1800'
)
foreach ($marker in $requiredMarkers) {
    if (-not $harness.Contains($marker)) {
        throw "Harness is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'STORAGE\s*:\s*SetItem',
    'STORAGE\s*:\s*AddItem',
    'STORAGE\s*:\s*RemoveItem',
    'STORAGE\s*:\s*SetLiquid',
    'STORAGE\s*:\s*AddLiquid',
    'STORAGE\s*:\s*RemoveLiquid',
    'SetItem\s*\(',
    'AddItem\s*\(',
    'RemoveItem\s*\(',
    'SetLiquid\s*\(',
    'AddLiquid\s*\(',
    'RemoveLiquid\s*\(',
    'CampaignState\s*[\.:]',
    'coalition\.addGroup',
    'trigger\.action\.explosion',
    'unit\s*:\s*destroy\s*\(',
    'OPSGROUP\s*:\s*Destroy',
    'ReturnToLegion\s*\(',
    '_DATABASE',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($harness -match $pattern) {
        throw "Client-fuel harness contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-client-fuel-exchange.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only Bagram F-16 client ground-crew fuel exchange correlation.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_CLIENT_FUEL_EXCHANGE"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "AircraftType: F-16C_50"
Write-Host "Node: Bagram"
Write-Host "PollIntervalSeconds: 2"
Write-Host "MaxRuntimeSeconds: 1800"
Write-Host "Liquid: JETFUEL"
Write-Host "AircraftFuelTelemetry: UNIT:GetCurrentFuelKgs"
Write-Host "StorageFuelTelemetry: STORAGE:GetLiquidAmount(JETFUEL)"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
