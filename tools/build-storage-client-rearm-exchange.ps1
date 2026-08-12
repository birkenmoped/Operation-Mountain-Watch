[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-client-rearm-exchange\src\01-storage-client-rearm-exchange.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-client-rearm-exchange\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Client_Rearm_Exchange_Test.lua'
$builderVersion = 'STORAGE-CLIENT-REARM-EXCHANGE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-physical-loss-recovery'
$baseCommit = '8ee3d28de07e418c77b3ab6c343f90f1498909de'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-CLIENT-REARM-EXCHANGE-1',
    'AIRBASE:FindByName',
    'airbase:GetStorage()',
    'STORAGE:FindByName',
    'STORAGE:GetInventory()',
    'SET_CLIENT:New()',
    'FilterTypes(CLIENT_TYPE)',
    'EVENTHANDLER:New()',
    'EVENTS.WeaponRearm',
    'client:GetAmmo()',
    'SCHEDULER:New',
    'STORAGE_WEAPON',
    'AIRCRAFT_AMMO',
    'storageMutation=false',
    'campaignStateMutation=false',
    'POLL_INTERVAL_S = 5',
    'MAX_RUNTIME_S = 3600'
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
        throw "Client-rearm harness contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-client-rearm-exchange.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only Bagram F-16 client rearm/loadout exchange correlation.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_CLIENT_REARM_EXCHANGE"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "AircraftType: F-16C_50"
Write-Host "Node: Bagram"
Write-Host "PollIntervalSeconds: 5"
Write-Host "MaxRuntimeSeconds: 3600"
Write-Host "WeaponRearmEvent: OBSERVED_IF_DELIVERED_BY_DCS"
Write-Host "FallbackObservation: STORAGE_AND_AMMO_POLLING"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
