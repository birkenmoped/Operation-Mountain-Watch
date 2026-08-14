[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\01-kandahar-main-a10-parking-dispatch.lua'
$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_Test_Kandahar_Main_A10_Parking.lua'
$builderVersion = 'KAF-MAIN-A10-PARKING-DISPATCH-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Kandahar A-10 parking test source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    '[OMW][AirOps.KAF.Parking.A10]',
    'EXPECTED_AIRBASE = "Kandahar"',
    'EXPECTED_AIRBASE_ID = 7',
    'SQ_US_KAF_A10C_74_EFS',
    'AUFTRAG:NewCAS',
    'mission:SetRequiredAssets(1, 1)',
    'mission:AssignSquadrons({ squadron })',
    'airwing:AddMission(mission)',
    'group:GetUnits()',
    'GetClosestParkingSpot',
    'SPAWN_PARKING',
    'PASS_PHYSICAL_PARKING_AND_DISPATCH',
    'exactlyOneMission=true',
    'commander=false',
    'opstransport=false',
    'directSpawn=false',
    'campaignStateMutation=false'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Parking test source is missing required marker: $marker"
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
    'CampaignState\s*[\.:]',
    '_FindParkingForAssets\s*=',
    'WAREHOUSE\._FindParkingForAssets\s*=',
    'SetAllowSpawnOnClientParking'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Parking test scope regression: forbidden pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToLowerInvariant()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-kandahar-main-a10-parking-dispatch-test.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: one native Kandahar Main AIRWING/AUFTRAG A-10 parking compliance dispatch.`n`n"
$content = $header + $source

foreach ($pattern in $forbiddenPatterns) {
    if ($content -match $pattern) {
        throw "Generated parking test bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: KANDAHAR_MAIN_A10_PHYSICAL_PARKING_DISPATCH"
Write-Host "Airbase: Kandahar / ID 7"
Write-Host "Squadron: SQ_US_KAF_A10C_74_EFS"
Write-Host "MissionType: CAS"
Write-Host "RequiredAssets: 1"
Write-Host "ExpectedGrouping: 2"
Write-Host "ParkingPoolSize: 24"
Write-Host "DirectSpawn: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "SHA256: $bundleHash"
Write-Host "GitCommit: $commit"
