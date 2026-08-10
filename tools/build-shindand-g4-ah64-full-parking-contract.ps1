[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\src\04-shindand-g4-ah64-full-kandahar-parking-contract.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand_G4_AH64_FullParkingContract.lua'
$builderVersion = 'SHND-G4-AH64-FULL-PARKING-CONTRACT-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Shindand G4 source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    '[OMW][AirOps.SHND.G4.AH64Parking]',
    'EXPECTED_PARKING_IDS',
    'ALLOWED_IDS = { 21, 3, 34, 15 }',
    'GetParkingSpotsTable',
    'SetParkingSpotBlacklist',
    'SetParkingIDs',
    'SetSafeParkingOn',
    'airwing:AddRequest',
    'SELF_REQUEST_FULFILLED',
    'GROUP_SPAWNED',
    'UNIT_PARKED',
    'PASS_FULL_PARKING_CONTRACT',
    'FAIL_FULL_PARKING_CONTRACT',
    'nativeWarehouseSelfRequest=true'
)

foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "G4 source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
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
    '_FindParkingForAssets\s*=',
    'WAREHOUSE\s*\.\s*_SpawnAssetAircraft\s*=',
    'WAREHOUSE\s*\.\s*_FindParkingForAssets\s*='
)

$scanSource = [regex]::Replace($source, '(?m)^\s*--.*(?:\r?\n|$)', '')
foreach ($pattern in $forbiddenPatterns) {
    if ($scanSource -match $pattern) {
        throw "G4 regression: forbidden pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-shindand-g4-ah64-full-parking-contract.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: isolated Shindand AH-64 full Kandahar-style parking contract test.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $source
$scanContent = [regex]::Replace($content, '(?m)^\s*--.*(?:\r?\n|$)', '')
foreach ($pattern in $forbiddenPatterns) {
    if ($scanContent -match $pattern) {
        throw "Generated G4 bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: SHINDAND_G4_AH64_FULL_KANDAHAR_STYLE_PARKING_CONTRACT"
Write-Host "RequestPath: AIRWING_WAREHOUSE_SELF_REQUEST"
Write-Host "RequiredAssetGroups: 1"
Write-Host "ExpectedAircraftPerAssetGroup: 2"
Write-Host "AH64ParkingTerminalIDs: 21,3,34,15"
Write-Host "AirbaseBlacklist: REQUIRED"
Write-Host "AirwingParkingRestriction: REQUIRED"
Write-Host "SafeParkingConfigured: REQUIRED"
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
