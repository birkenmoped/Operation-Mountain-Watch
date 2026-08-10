[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$foundationSourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Shindand_Bootstrap.lua'
$testSourceFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\src\08-shindand-final-foundation-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand_FinalFoundationAcceptance.lua'
$lifecycleGuard = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$builderVersion = 'SHND-FINAL-FOUNDATION-ACCEPTANCE-1'

foreach ($requiredFile in @($foundationSourceFile, $testSourceFile, $lifecycleGuard)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required file not found: $requiredFile"
    }
}

$foundation = Get-Content -LiteralPath $foundationSourceFile -Raw -Encoding UTF8
$testSource = Get-Content -LiteralPath $testSourceFile -Raw -Encoding UTF8

$requiredFoundationMarkers = @(
    'AIRBASE.Afghanistan.Shindand_Heliport',
    'WH_AIR_US_SHINDAND_HELIPORT',
    'AW_US_SHINDAND',
    'SQ_US_SHND_AH64D_ATTACK',
    'SQ_US_SHND_UH60_UTILITY_MEDEVAC',
    'SQ_US_SHND_CH47_HEAVYLIFT',
    'logicalAirframes = 20',
    'representedAirframes = 20',
    'airwing:SetTakeoffCold()',
    'airwing:SetOptionPreferVerticalLanding()',
    'airwing:Start()',
    'postStartAssetParkingSync=true',
    'parkingPattern=JALALABAD'
)
foreach ($marker in $requiredFoundationMarkers) {
    if (-not $foundation.Contains($marker)) {
        throw "Foundation source is missing final-acceptance prerequisite marker: $marker"
    }
}

$requiredTestMarkers = @(
    '[OMW][AirOps.SHND.FinalFoundation]',
    'AUFTRAG:NewCAS',
    'AUFTRAG:NewLANDATCOORDINATE',
    'AssignSquadrons',
    'SQ_US_SHND_AH64D_ATTACK',
    'SQ_US_SHND_UH60_UTILITY_MEDEVAC',
    'SQ_US_SHND_CH47_HEAVYLIFT',
    'OnAfterElementEngineOn',
    'OnAfterTaxiing',
    'OnAfterTakeoff',
    'OnAfterAirborne',
    'OnAfterLandedAt',
    'OnAfterSuccess',
    'PASS_FINAL_FOUNDATION_ACCEPTANCE',
    'parkingAcceptance=false',
    'taxiRequired=false'
)
foreach ($marker in $requiredTestMarkers) {
    if (-not $testSource.Contains($marker)) {
        throw "Final acceptance source is missing required marker: $marker"
    }
}

# Scan executable Lua only. Full-line comments may document excluded APIs.
$testExecutable = (($testSource -split "`r?`n") | Where-Object { $_ -notmatch '^\s*--' }) -join "`n"

$forbiddenTestPatterns = @(
    'COMMANDER\s*:\s*New',
    'OPSTRANSPORT\s*:\s*New',
    'SPAWN\s*:',
    'coalition\s*\.\s*addGroup',
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    'CampaignState\s*[\.:\[]',
    'SetParkingSpotBlacklist\s*\(',
    'SetParkingIDs\s*\(',
    'SetSafeParkingOn\s*\(',
    '_SpawnAsset',
    '_FindParkingForAssets',
    'MissionScripting',
    'mist\s*\.'
)
foreach ($pattern in $forbiddenTestPatterns) {
    if ($testExecutable -match $pattern) {
        throw "Final acceptance scope regression: forbidden executable pattern found in test source: $pattern"
    }
}

$foundationBlacklistIndex = $foundation.IndexOf('airbase:SetParkingSpotBlacklist(parkingBlacklist)')
$foundationAirwingNewIndex = $foundation.IndexOf('local airwing = AIRWING:New')
$foundationSafeParkingIndex = $foundation.IndexOf('airwing:SetSafeParkingOn()')
$foundationAirwingStartIndex = $foundation.IndexOf('airwing:Start()')
if ($foundationBlacklistIndex -lt 0 -or $foundationAirwingNewIndex -lt 0 -or $foundationBlacklistIndex -gt $foundationAirwingNewIndex) {
    throw 'Foundation parking blacklist must remain before AIRWING creation.'
}
if ($foundationSafeParkingIndex -lt 0 -or $foundationAirwingStartIndex -lt 0 -or $foundationSafeParkingIndex -gt $foundationAirwingStartIndex) {
    throw 'Foundation safe parking must remain before AIRWING start.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-shindand-final-foundation-acceptance.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: final combined Shindand AIRWING/SQUADRON foundation acceptance in one DCS run.`n-- Load only after Moose.lua; foundation is embedded in this bundle.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $foundation + "`n`n-- FINAL COMBINED ACCEPTANCE TEST`n" + $testSource
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

& $lifecycleGuard `
    -SourceFile $foundationSourceFile `
    -GeneratedFile $outputFile `
    -PreStartFunctionName 'constructFoundation' `
    -PostStartFunctionName 'inspectIdleFoundation' `
    -RequirePostStartAssetValidation `
    -RequireVerticalPolicyBeforeStart

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: SHINDAND_FINAL_COMBINED_FOUNDATION_ACCEPTANCE"
Write-Host "LoadOrder: Moose.lua -> OMW_AirOps_Shindand_FinalFoundationAcceptance.lua"
Write-Host "FoundationEmbedded: YES"
Write-Host "Airbase: Shindand Heliport"
Write-Host "Airwings: 1"
Write-Host "Squadrons: 3"
Write-Host "RegisteredGroups: 16"
Write-Host "RepresentedAirframes: 20"
Write-Host "LogicalAirframes: 20"
Write-Host "AH64Mission: CAS"
Write-Host "UH60Mission: LANDATCOORDINATE"
Write-Host "CH47Mission: LANDATCOORDINATE"
Write-Host "SquadronPinning: AUFTRAG.AssignSquadrons"
Write-Host "ColdTakeoff: REQUIRED_ALL_THREE"
Write-Host "VerticalPreferencePropagation: REQUIRED_ALL_THREE"
Write-Host "EngineStart: REQUIRED_ALL_THREE"
Write-Host "Taxi: TELEMETRY_ONLY"
Write-Host "Takeoff: REQUIRED_ALL_THREE"
Write-Host "Airborne: REQUIRED_ALL_THREE"
Write-Host "CoordinateLanding: REQUIRED_UH60_CH47"
Write-Host "MissionSuccess: REQUIRED_ALL_THREE"
Write-Host "ParkingAcceptance: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "LifecycleGuard: PASS"
Write-Host "RequiredFoundationMarkersChecked: $($requiredFoundationMarkers.Count)"
Write-Host "RequiredTestMarkersChecked: $($requiredTestMarkers.Count)"
Write-Host "ForbiddenTestExecutablePatternsChecked: $($forbiddenTestPatterns.Count)"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
