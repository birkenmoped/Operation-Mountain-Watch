[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Shindand_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand.lua'
$lifecycleGuard = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$builderVersion = 'SHND-AIR-OPS-FOUNDATION-2'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Shindand foundation source not found: $sourceFile"
}
if (-not (Test-Path -LiteralPath $lifecycleGuard -PathType Leaf)) {
    throw "AirOps lifecycle guard not found: $lifecycleGuard"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AIRBASE.Afghanistan.Shindand_Heliport',
    'WH_AIR_US_SHINDAND_HELIPORT',
    'AW_US_SHINDAND',
    'SQ_US_SHND_AH64D_ATTACK',
    'SQ_US_SHND_UH60_UTILITY_MEDEVAC',
    'SQ_US_SHND_CH47_HEAVYLIFT',
    'TPL_AIR_US_SHND_AH64D_CAS_2SHIP',
    'TPL_AIR_US_SHND_UH60_UTILITY_1SHIP',
    'TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP',
    'parkingIDs = { 21, 3, 34, 15 }',
    'parkingIDs = { 41, 18, 13, 20, 19 }',
    'parkingIDs = { 30, 10, 23 }',
    'sharedFreeParkingIDs = { 0, 16, 24, 33, 14, 25, 42, 27, 22, 39, 38, 5, 29, 11, 26, 40, 9 }',
    'buildGlobalParkingBlacklist',
    'airbase:SetParkingSpotBlacklist(parkingBlacklist)',
    'airwing:SetSafeParkingOn()',
    'pattern=JALALABAD',
    'AirbaseBlacklistAppliedBeforeAirwingCreation = true',
    'SafeParkingConfiguredBeforeStart = true',
    'AirwingParkingRestriction = false',
    'logicalAirframes = 20',
    'representedAirframes = 20',
    'SQUADRON_STOCK_PRESTART',
    'airwing:SetOptionPreferVerticalLanding()',
    'airwing:Start()',
    'postStartAssetParkingSync=true',
    'parkingPattern=JALALABAD',
    'airbaseBlacklistPreStart=true',
    'safeParkingPreStart=true',
    'airwingParkingRestriction=false',
    'sharedFreeParkingConfigured=true',
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
    ':\s*AddMission\s*\(',
    'SPAWN\s*:',
    'coalition\s*\.\s*addGroup',
    'mist\s*\.',
    'CampaignState\s*[\.:\[]',
    'TPL_AIR_US_SHND_UH60_MEDEVAC_LEAD_1SHIP',
    'TPL_AIR_US_SHND_UH60_MEDEVAC_COVER_1SHIP',
    'airwing\s*:\s*SetParkingIDs\s*\('
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Foundation-only regression: forbidden pattern found: $pattern"
    }
}

$blacklistIndex = $source.IndexOf('airbase:SetParkingSpotBlacklist(parkingBlacklist)')
$airwingNewIndex = $source.IndexOf('local airwing = AIRWING:New')
$safeParkingIndex = $source.IndexOf('airwing:SetSafeParkingOn()')
$airwingStartIndex = $source.IndexOf('airwing:Start()')
if ($blacklistIndex -lt 0 -or $airwingNewIndex -lt 0 -or $blacklistIndex -gt $airwingNewIndex) {
    throw 'Shindand parking blacklist must be applied before AIRWING creation.'
}
if ($safeParkingIndex -lt 0 -or $airwingStartIndex -lt 0 -or $safeParkingIndex -gt $airwingStartIndex) {
    throw 'Shindand safe parking must be configured before AIRWING start.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-shindand-air-operations-foundation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: Shindand Heliport AIRWING/SQUADRON foundation with Jalalabad-style parking preflight; no task dispatch.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $source

foreach ($pattern in $forbiddenPatterns) {
    if ($content -match $pattern) {
        throw "Generated foundation-only bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

& $lifecycleGuard `
    -SourceFile $sourceFile `
    -GeneratedFile $outputFile `
    -PreStartFunctionName 'constructFoundation' `
    -PostStartFunctionName 'inspectIdleFoundation' `
    -RequirePostStartAssetValidation `
    -RequireVerticalPolicyBeforeStart `
    -FoundationScope

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRWING_SQUADRON_FOUNDATION_ONLY"
Write-Host "ParkingPattern: JALALABAD"
Write-Host "AirbaseBlacklistBeforeAirwingCreation: REQUIRED"
Write-Host "SafeParkingBeforeStart: REQUIRED"
Write-Host "AirwingParkingRestriction: ABSENT"
Write-Host "Airbase: Shindand Heliport"
Write-Host "Airwings: 1"
Write-Host "Squadrons: 3"
Write-Host "RegisteredGroups: 16"
Write-Host "RepresentedAirframes: 20"
Write-Host "LogicalAirframes: 20"
Write-Host "LogicalReserve: 0"
Write-Host "RolePayloadsExpected: 3"
Write-Host "AH64ParkingTerminalIDs: 21,3,34,15"
Write-Host "UH60ParkingTerminalIDs: 41,18,13,20,19"
Write-Host "CH47ParkingTerminalIDs: 30,10,23"
Write-Host "SharedFreeParkingTerminalIDs: 0,16,24,33,14,25,42,27,22,39,38,5,29,11,26,40,9"
Write-Host "LifecycleGuard: PASS"
Write-Host "TestDispatch: ABSENT"
Write-Host "AUFTRAGInstances: ABSENT"
Write-Host "OPSTRANSPORTInstances: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
