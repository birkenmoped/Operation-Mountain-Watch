[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\src\02-shindand-g2-ah64-dispatch.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand_G2_AH64_Dispatch.lua'
$builderVersion = 'SHND-G2-AH64-DISPATCH-3'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Shindand G2 source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    '[OMW][AirOps.SHND.G2.AH64]',
    'SQ_US_SHND_AH64D_ATTACK',
    'EXPECTED_PARKING_IDS = { 21, 3, 34, 15 }',
    'AUFTRAG:NewCAS',
    'mission:SetRequiredAssets(1, 1)',
    'airwing:AddMission(mission)',
    'airwing.OnAfterFlightOnMission',
    'GetClosestParkingSpot',
    'flightGroup:IsTaxiing()',
    'flightGroup:IsAirborne()',
    'PASS_DISPATCH_AIRBORNE',
    'exactlyOneMission=true',
    'verticalPolicyConfigured=true'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "G2 source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'COMMANDER\s*:\s*New',
    'OPSTRANSPORT\s*:\s*New',
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    'SPAWN\s*:',
    'coalition\s*\.\s*addGroup',
    'mist\s*\.',
    '(?<![A-Za-z0-9_])CampaignState\s*(?:[\.:=\[]|\()',
    'SetParkingIDs\s*\(',
    'SetParkingSpotBlacklist\s*\(',
    'SetParkingIDsForType\s*\(',
    'trigger\.action\.setUserFlag',
    'trigger\.action\.markTo'
)

# Guard executable source, not descriptive comment-only lines. Match
# CampaignState only when used as an actual symbol/expression, not when the
# telemetry string reports campaignStateMutation=false.
$scanSource = [regex]::Replace($source, '(?m)^\s*--.*(?:\r?\n|$)', '')
foreach ($pattern in $forbiddenPatterns) {
    if ($scanSource -match $pattern) {
        throw "G2 regression: forbidden pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-shindand-g2-ah64-dispatch.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: isolated Shindand AH-64 native AIRWING/AUFTRAG dispatch test.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $source
$scanContent = [regex]::Replace($content, '(?m)^\s*--.*(?:\r?\n|$)', '')
foreach ($pattern in $forbiddenPatterns) {
    if ($scanContent -match $pattern) {
        throw "Generated G2 bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: SHINDAND_G2_AH64_NATIVE_DISPATCH_ONLY"
Write-Host "MissionType: CAS"
Write-Host "RequiredAssetGroups: 1"
Write-Host "ExpectedAircraftPerAssetGroup: 2"
Write-Host "AH64ParkingTerminalIDs: 21,3,34,15"
Write-Host "Commander: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "RequiredGuardPatternsChecked: $($requiredMarkers.Count)"
Write-Host "ForbiddenGuardPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
