[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$foundationFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist\OMW_AirOps_Shindand.lua'
$sourceFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\src\07-shindand-g7-ah64-cold-vertical-departure.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand_G7_AH64_ColdVerticalDeparture.lua'
$builderVersion = 'SHND-G7-AH64-COLD-VERTICAL-DEPARTURE-2'

if (-not (Test-Path -LiteralPath $foundationFile -PathType Leaf)) {
    throw "Built Shindand foundation not found: $foundationFile"
}
if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Shindand G7 source not found: $sourceFile"
}

$foundation = Get-Content -LiteralPath $foundationFile -Raw -Encoding UTF8
$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredFoundationMarkers = @(
    'BuilderVersion: SHND-AIR-OPS-FOUNDATION-3',
    'Pattern = "JALALABAD"',
    'airwing:SetTakeoffCold()',
    'airwing:SetOptionPreferVerticalLanding()',
    'airwing:Start()'
)
foreach ($marker in $requiredFoundationMarkers) {
    if (-not $foundation.Contains($marker)) {
        throw "Built foundation is missing required G7 prerequisite marker: $marker"
    }
}

$requiredSourceMarkers = @(
    '[OMW][AirOps.SHND.G7.AH64Departure]',
    'AUFTRAG:NewCAS',
    'airwing:AddMission(mission)',
    'FLIGHT_ON_MISSION',
    'IsTakeoffCold',
    'OptionPreferVertical',
    'OnAfterElementEngineOn',
    'OnAfterTaxiing',
    'OnAfterTakeoff',
    'OnAfterAirborne',
    'PASS_COLD_VERTICAL_DEPARTURE',
    'parkingAcceptance=false',
    'parkingMutation=false'
)
foreach ($marker in $requiredSourceMarkers) {
    if (-not $source.Contains($marker)) {
        throw "G7 source is missing required marker: $marker"
    }
}

# Strip Lua comments before executable-pattern checks. This avoids false positives
# from explanatory scope comments such as "native coalition.addGroup".
$executableSource = (($source -split "`r?`n") | ForEach-Object {
    $line = $_
    $commentIndex = $line.IndexOf('--')
    if ($commentIndex -ge 0) {
        $line = $line.Substring(0, $commentIndex)
    }
    $line
}) -join "`n"

$forbiddenPatterns = @(
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
foreach ($pattern in $forbiddenPatterns) {
    if ($executableSource -match $pattern) {
        throw "G7 scope regression: forbidden executable pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-shindand-g7-ah64-cold-vertical-departure.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: one native Shindand AH-64 CAS departure gate; parking ownership excluded from acceptance.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $source
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: SHINDAND_G7_AH64_COLD_VERTICAL_DEPARTURE"
Write-Host "RequestPath: AIRWING_ADD_MISSION"
Write-Host "RequiredAssetGroups: 1"
Write-Host "ExpectedAircraftPerAssetGroup: 2"
Write-Host "ColdTakeoffConfigured: REQUIRED"
Write-Host "VerticalPreferencePropagation: REQUIRED"
Write-Host "EngineStartTelemetry: ENABLED"
Write-Host "TaxiTelemetry: ENABLED"
Write-Host "TakeoffTelemetry: ENABLED"
Write-Host "AirborneTelemetry: ENABLED"
Write-Host "ParkingMutation: ABSENT"
Write-Host "ParkingAcceptance: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "RequiredGuardPatternsChecked: $($requiredSourceMarkers.Count)"
Write-Host "ForbiddenExecutablePatternsChecked: $($forbiddenPatterns.Count)"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
