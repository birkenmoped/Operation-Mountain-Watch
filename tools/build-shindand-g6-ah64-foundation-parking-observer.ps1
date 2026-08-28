[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\src\06-shindand-g6-ah64-foundation-parking-observer.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand_G6_AH64_FoundationParkingObserver.lua'
$builderVersion = 'SHND-G6-AH64-FOUNDATION-PARKING-OBSERVER-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Shindand G6 source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    '[OMW][AirOps.SHND.G6.AH64Parking]',
    'AH64_RESERVED_IDS = { 21, 3, 34, 15 }',
    'SHARED_FREE_IDS = { 0, 16, 24, 33, 14, 25, 42, 27, 22, 39, 38, 5, 29, 11, 26, 40, 9 }',
    'UH60_RESERVED_IDS = { 41, 18, 13, 20, 19 }',
    'CH47_RESERVED_IDS = { 30, 10, 23 }',
    'state.Parking.Pattern ~= "JALALABAD"',
    'AirbaseBlacklistAppliedBeforeAirwingCreation',
    'SafeParkingConfiguredBeforeStart',
    'AirwingParkingRestriction',
    'FOUNDATION_CONTRACT_VERIFIED',
    'airwing:AddRequest',
    'PASS_FOUNDATION_PARKING',
    'FAIL_FOUNDATION_PARKING',
    'parkingMutation=false'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "G6 source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'SetParkingSpotBlacklist\s*\(',
    'SetParkingIDs\s*\(',
    'SetSafeParkingOn\s*\(',
    'SetSafeParkingOff\s*\(',
    'COMMANDER\s*:\s*New',
    'AUFTRAG\s*:\s*New',
    'OPSTRANSPORT\s*:\s*New',
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    'SPAWN\s*:',
    'coalition\s*\.\s*addGroup',
    'mist\s*\.',
    '(?<![A-Za-z0-9_])CampaignState\s*(?:[\.:=\[]|\()',
    '_SpawnAssetAircraft\s*=',
    '_FindParkingForAssets\s*='
)

$scanSource = [regex]::Replace($source, '(?m)^\s*--.*(?:\r?\n|$)', '')
foreach ($pattern in $forbiddenPatterns) {
    if ($scanSource -match $pattern) {
        throw "G6 regression: forbidden mutation/dispatch pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-shindand-g6-ah64-foundation-parking-observer.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: observe one native AH-64 self-request against the preconfigured Shindand foundation; no parking mutation.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $source
$scanContent = [regex]::Replace($content, '(?m)^\s*--.*(?:\r?\n|$)', '')
foreach ($pattern in $forbiddenPatterns) {
    if ($scanContent -match $pattern) {
        throw "Generated G6 bundle contains forbidden mutation/dispatch pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: SHINDAND_G6_AH64_FOUNDATION_PARKING_OBSERVER"
Write-Host "RequestPath: AIRWING_WAREHOUSE_SELF_REQUEST"
Write-Host "ParkingMutation: ABSENT"
Write-Host "FoundationPatternRequired: JALALABAD"
Write-Host "RequiredAssetGroups: 1"
Write-Host "ExpectedAircraftPerAssetGroup: 2"
Write-Host "AH64ReservedTerminalIDs: 21,3,34,15"
Write-Host "SharedFreeTerminalIDs: 0,16,24,33,14,25,42,27,22,39,38,5,29,11,26,40,9"
Write-Host "UH60ReservedTerminalIDs: 41,18,13,20,19"
Write-Host "CH47ReservedTerminalIDs: 30,10,23"
Write-Host "Commander: ABSENT"
Write-Host "AUFTRAG: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "MOOSEOverride: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "RequiredGuardPatternsChecked: $($requiredMarkers.Count)"
Write-Host "ForbiddenGuardPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
