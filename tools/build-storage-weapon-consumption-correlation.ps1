[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-weapon-consumption-correlation\src\01-storage-weapon-consumption-correlation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-weapon-consumption-correlation\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Weapon_Consumption_Correlation_Test.lua'
$builderVersion = 'STORAGE-WEAPON-CONSUMPTION-CORRELATION-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/ammunition-exact-item-mapping'
$baseCommit = 'e93b0ad022a6ba6c32d2899ac24bdabb80615008'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-WEAPON-CONSUMPTION-CORRELATION-1',
    'Bagram',
    'Jalalabad',
    'Kandahar',
    'Kandahar Heliport',
    'FOB Salerno',
    'Tarinkot',
    'Shindand Heliport',
    'AIRBASE:FindByName',
    'STORAGE:FindByName',
    'GetInventory',
    'SCHEDULER:New',
    'BASELINE_CAPTURED',
    'ACTION_WINDOW_OPEN',
    'WEAPON_DELTA',
    'ACTION_WINDOW_CLOSE',
    'FINAL_SNAPSHOT',
    'deltasObserved=%d'
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
    '_DATABASE',
    'getWarehouse\s*\(',
    'world\.searchObjects',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    'CampaignState',
    'SaveToFile',
    'LoadFromFile',
    'StartAutoSave',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($harness -match $pattern) {
        throw "Read-only consumption-correlation harness contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-weapon-consumption-correlation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only seven-node MOOSE STORAGE weapon inventory delta correlation.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_WEAPON_CONSUMPTION_CORRELATION_READ_ONLY"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "NodesExpected: 7"
Write-Host "PollIntervalSeconds: 2"
Write-Host "ActionWindowSeconds: 20-100"
Write-Host "Mutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CTLD: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
