[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Jalalabad_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\jalalabad-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Jalalabad.lua'
$builderVersion = 'JBAD-AIR-OPS-FOUNDATION-ONLY-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Jalalabad foundation source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AW_US_JALALABAD',
    'SQ_US_JBAD_OH58D_6_6_CAV',
    'SQ_US_JBAD_AH64D_B_1_10_AVN',
    'SQ_US_JBAD_UH60_UTILITY_MEDEVAC',
    'SQ_US_JBAD_CH47_HEAVYLIFT',
    'SQUADRON:New',
    'SetGrouping',
    'SetParkingIDs',
    'SetTakeoffCold',
    'AddMissionCapability',
    'NewPayload',
    'SetSafeParkingOn',
    'SetOptionPreferVerticalLanding',
    'airwing:Start()',
    'missionsCreated=0',
    'transportsCreated=0',
    'commanderCreated=false',
    'f10Controls=false'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Foundation source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    'AUFTRAG\s*:\s*New',
    'OPSTRANSPORT\s*:\s*New',
    'COMMANDER\s*:\s*New',
    'AddMission\s*\(',
    'ZONE_TEST_US_JBAD_',
    'Phase1',
    'PH1\.',
    'createMenus\s*\('
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Foundation-only regression: forbidden test/dispatch pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-jalalabad-air-operations-foundation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- Scope: AIRWING/SQUADRON foundation only; no F10 test missions or dispatch harness.
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

"@

$content = $header + $source

foreach ($pattern in $forbiddenPatterns) {
    if ($content -match $pattern) {
        throw "Generated foundation-only bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRWING_SQUADRON_FOUNDATION_ONLY"
Write-Host "F10TestMissions: ABSENT"
Write-Host "AUFTRAGInstances: ABSENT"
Write-Host "OPSTRANSPORTInstances: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
