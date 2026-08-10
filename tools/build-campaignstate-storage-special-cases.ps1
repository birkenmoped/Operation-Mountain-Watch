[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\campaignstate-storage-special-cases\src\01-storage-special-cases.lua'
$distDir = Join-Path $repoRoot 'mission\tests\campaignstate-storage-special-cases\dist'
$outputFile = Join-Path $distDir 'OMW_CampaignState_Storage_Special_Cases_Test.lua'
$builderVersion = 'CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/campaignstate-storage-sync-foundation'
$baseCommit = '6087e389824a82d01ba735ba8e8f63951840cb08'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required source file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1',
    'KANDAHAR_MAIN_VS_HELIPORT',
    'SHINDAND_MAIN_VS_HELIPORT',
    'SALERNO_VS_KHOST',
    'FOB Salerno',
    'Khost',
    'AIRBASE:FindByName',
    'STORAGE:FindByName',
    'GetStorage',
    'GetWarehouse',
    'GetLiquidAmount',
    'SetLiquid',
    'RESTORE_PASS',
    'PAIR_RESULT'
)
foreach ($marker in $requiredMarkers) {
    if (-not $harness.Contains($marker)) {
        throw "Harness is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'OMWCampaignState\.',
    'SCHEDULER\s*:',
    'timer\.scheduleFunction',
    'SaveToFile',
    'LoadFromFile',
    'StartAutoSave',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    '_DATABASE',
    'world\.searchObjects'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($harness -match $pattern) {
        throw "Special-case harness contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-campaignstate-storage-special-cases.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: combined MOOSE STORAGE topology/aliasing diagnostics for Kandahar, Shindand and FOB Salerno special cases.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: CAMPAIGNSTATE_STORAGE_SPECIAL_CASES"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "Pairs: Kandahar|Kandahar Heliport;Shindand|Shindand Heliport;FOB Salerno|Khost"
Write-Host "ProbeLiquid: JETFUEL"
Write-Host "ProbeDeltaKg: 37"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "ReverseOverwrite: ABSENT"
Write-Host "Persistence: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
