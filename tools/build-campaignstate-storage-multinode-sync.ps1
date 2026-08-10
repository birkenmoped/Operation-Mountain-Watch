[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$adapterFile = Join-Path $repoRoot 'scripts\logistics\OMW_StorageFuelAdapter.lua'
$syncFile = Join-Path $repoRoot 'scripts\logistics\OMW_CampaignStateStorageSync.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\campaignstate-storage-multinode-sync\src\01-campaignstate-storage-multinode-sync.lua'
$distDir = Join-Path $repoRoot 'mission\tests\campaignstate-storage-multinode-sync\dist'
$outputFile = Join-Path $distDir 'OMW_CampaignState_Storage_MultiNode_Test.lua'
$builderVersion = 'CAMPAIGNSTATE-STORAGE-MULTINODE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/campaignstate-storage-special-cases'
$baseCommit = 'a6b791c4e835a8a39990c13c58b189e024414239'

foreach ($file in @($campaignStateFile, $adapterFile, $syncFile, $harnessFile)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required source file not found: $file"
    }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$adapter = Get-Content -LiteralPath $adapterFile -Raw -Encoding UTF8
$sync = Get-Content -LiteralPath $syncFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

foreach ($marker in @('FUEL_JP8','FUEL_AVGAS','function CampaignState.New','function Store:GetFuelSnapshot','return CampaignState')) {
    if (-not $campaignState.Contains($marker)) { throw "CampaignState source is missing required marker: $marker" }
}
foreach ($marker in @('function CampaignStateStorageSync.New','function Sync:PlanNode','function Sync:ApplyNode','return CampaignStateStorageSync')) {
    if (-not $sync.Contains($marker)) { throw "Sync source is missing required marker: $marker" }
}
foreach ($marker in @('STORAGE.Liquid.JETFUEL','STORAGE.Liquid.GASOLINE','function StorageFuelAdapter.ApplySnapshot','function StorageFuelAdapter.ReadNode')) {
    if (-not $adapter.Contains($marker)) { throw "Storage adapter source is missing required marker: $marker" }
}

$requiredHarnessMarkers = @(
    'CAMPAIGNSTATE-STORAGE-MULTINODE-1',
    'TEST_NODE_BAGRAM',
    'TEST_NODE_JALALABAD',
    'TEST_NODE_KANDAHAR',
    'TEST_NODE_KANDAHAR_HELIPORT',
    'TEST_NODE_SALERNO',
    'TEST_NODE_TARINKOT',
    'TEST_NODE_SHINDAND_HELIPORT',
    'Bagram',
    'Jalalabad',
    'Kandahar Heliport',
    'FOB Salerno',
    'Tarinkot',
    'Shindand Heliport',
    'SYNC_PLAN_PASS',
    'SYNC_WRITE_READBACK_PASS',
    'SYNC_IDEMPOTENCY_PASS',
    'NO_REVERSE_MUTATION_PASS',
    'RESTORE_PASS',
    'NODE_PASS',
    'nodesExpected=%d'
)
foreach ($marker in $requiredHarnessMarkers) {
    if (-not $harness.Contains($marker)) { throw "Harness is missing required marker: $marker" }
}

$forbiddenPatterns = @(
    'SCHEDULER\s*:',
    'timer\.scheduleFunction',
    'SaveToFile',
    'LoadFromFile',
    'StartAutoSave',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    'SetResourceKg',
    'ApplyResourceTransaction',
    '_DATABASE',
    'world\.searchObjects'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($campaignState -match $pattern -or $sync -match $pattern -or $harness -match $pattern) {
        throw "Multi-node foundation source contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-campaignstate-storage-multinode-sync.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: seven-node one-way CampaignState fuel snapshot to MOOSE STORAGE mirror with exact readback, idempotency, no reverse mutation and restore.

"@

$content = $header
$content += "local OMWCampaignState = (function()`n$campaignState`nend)()`n`n"
$content += "local OMWStorageFuelAdapter = (function()`n$adapter`nend)()`n`n"
$content += "local OMWCampaignStateStorageSync = (function()`n$sync`nend)()`n`n"
$content += $harness

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: CAMPAIGNSTATE_STORAGE_MULTINODE_SYNC"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "NodesExpected: 7"
Write-Host "Airbases: Bagram;Jalalabad;Kandahar;Kandahar Heliport;FOB Salerno;Tarinkot;Shindand Heliport"
Write-Host "FuelResources: FUEL_JP8,FUEL_AVGAS"
Write-Host "CanonicalUnit: kg"
Write-Host "Direction: CampaignState-to-STORAGE"
Write-Host "CampaignStateRuntimeMutation: ABSENT"
Write-Host "ReverseOverwrite: ABSENT"
Write-Host "Persistence: ABSENT"
Write-Host "Transport: ABSENT"
Write-Host "AutomaticAircraftDebit: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
