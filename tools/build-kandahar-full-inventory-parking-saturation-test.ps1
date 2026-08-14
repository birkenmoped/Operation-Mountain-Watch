[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\01-kandahar-full-inventory-parking-saturation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_Test_Kandahar_Full_Inventory_Parking.lua'
$builderVersion = 'KAF-FULL-INVENTORY-PARKING-SATURATION-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Kandahar full-inventory parking test source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    '[OMW][AirOps.KAF.Parking.FullInventory]',
    'EXPECTED_GROUPS = 76',
    'EXPECTED_AIRFRAMES = 112',
    'EXPECTED_REQUESTS = 9',
    'SQ_US_KAF_A10C_74_EFS',
    'SQ_US_KAF_HH60G_26_ERQS',
    'SQ_US_KAF_C130_772_EAS',
    'SQ_US_KAF_MQ1_361_ERS',
    'SQ_US_KAF_MQ9_361_ERS',
    'SQ_US_KAF_AH64_4_227_AVN',
    'SQ_US_KAF_OH58D_7_17_CAV',
    'SQ_US_KAF_CH47_7_101_GSAB',
    'SQ_US_KAF_UH60_7_101_GSAB',
    'WAREHOUSE.Descriptor.GROUPNAME',
    'WAREHOUSE.TransportType.SELFPROPELLED',
    'airwing:AddRequest(',
    'OnAfterSelfRequest',
    'GetClosestParkingSpot',
    'SPAWN_PARKING',
    'REQUEST_RESULT',
    'PASS_FULL_INVENTORY_PHYSICAL_PARKING',
    'FAIL_FULL_INVENTORY_PHYSICAL_PARKING',
    'FAIL_TIMEOUT'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Full-inventory parking test source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    'SPAWN\s*:\s*New',
    'coalition\.addGroup',
    'OPSTRANSPORT\s*:\s*New',
    'COMMANDER\s*:\s*New',
    'AUFTRAG\s*:\s*New',
    'CampaignState\s*[\.:]',
    '_FindParkingForAssets\s*=',
    'WAREHOUSE\._FindParkingForAssets\s*=',
    'SetAllowSpawnOnClientParking'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Full-inventory parking test scope regression: forbidden pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToLowerInvariant()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-kandahar-full-inventory-parking-saturation-test.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: all 76 Kandahar AI asset groups / 112 airframes via native MOOSE WAREHOUSE self-request parking saturation.`n`n"
$content = $header + $source

foreach ($pattern in $forbiddenPatterns) {
    if ($content -match $pattern) {
        throw "Generated full-inventory parking test bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: KANDAHAR_FULL_INVENTORY_PHYSICAL_PARKING_SATURATION"
Write-Host "Airbases: Kandahar Main + Kandahar Heliport"
Write-Host "Squadrons: 9"
Write-Host "AssetGroupsRequested: 76"
Write-Host "RegisteredAirframesRequested: 112"
Write-Host "MainGroups: 32"
Write-Host "MainAirframes: 40"
Write-Host "HeliportGroups: 44"
Write-Host "HeliportAirframes: 72"
Write-Host "RequestPath: MOOSE WAREHOUSE self-request"
Write-Host "TacticalAUFTRAG: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "SHA256: $bundleHash"
Write-Host "GitCommit: $commit"
