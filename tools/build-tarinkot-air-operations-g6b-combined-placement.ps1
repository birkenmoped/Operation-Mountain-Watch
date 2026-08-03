[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$sourceFile = Join-Path $sourceDir '05-tarinkot-g6b-helicopter-apron-retest.lua'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G6B_HelicopterApronRetest.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source file not found: $sourceFile"
}

$sourceText = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$forbiddenPatterns = [ordered]@{
    'AIRWING constructor' = 'AIRWING\s*:\s*New\s*\('
    'SQUADRON constructor' = 'SQUADRON\s*:\s*New\s*\('
    'COMMANDER constructor' = 'COMMANDER\s*:\s*New\s*\('
    'AUFTRAG constructor' = 'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\('
    'OPSTRANSPORT constructor' = 'OPSTRANSPORT\s*:\s*New\s*\('
    'Payload registration' = ':\s*NewPayload\s*\('
    'Squadron or warehouse parking assignment' = ':\s*SetParkingIDs\s*\('
    'Airbase parking whitelist mutation' = ':\s*SetParking(Spot)?Whitelist\s*\('
    'Airbase parking blacklist mutation' = ':\s*SetParking(Spot)?Blacklist\s*\('
    'Safe parking mutation' = ':\s*SetSafeParking(On|Off)\s*\('
    'Client parking enablement' = ':\s*SetAllowSpawnOnClientParking\s*\('
    'Commander mission queue mutation' = ':\s*AddMission\s*\('
    'Commander transport queue mutation' = ':\s*AddOpsTransport\s*\('
    'Group or object activation' = ':\s*Activate\s*\('
    'Generic Spawn call' = ':\s*Spawn\s*\('
    'Direct SpawnAtAirbase call' = ':\s*SpawnAtAirbase\s*\('
    'Randomized spawn configuration' = ':\s*InitRandomize[A-Za-z0-9_]*\s*\('
    'Position override configuration' = ':\s*InitPosition[A-Za-z0-9_]*\s*\('
    'Direct DCS coalition spawn' = 'coalition\s*\.\s*addGroup\s*\('
    'MIST dynamic spawn' = 'mist\s*\.\s*dynAdd\s*\('
    'F10 parking marks' = ':\s*MarkParkingSpots\s*\('
    'F10 map mark mutation' = ':\s*MarkTo(All|Coalition|Group)\s*\('
    'User flag mutation' = 'trigger\s*\.\s*action\s*\.\s*setUserFlag\s*\('
}

foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
    if ($sourceText -match $entry.Value) {
        throw "G6B helicopter-apron guard rejected source: $($entry.Key) matched pattern $($entry.Value)"
    }
}

$requiredPatterns = [ordered]@{
    'MOOSE SPAWN constructor' = 'SPAWN\s*:\s*NewWithAlias\s*\('
    'AI disabled after placement' = ':\s*InitAIOff\s*\('
    'Exact parking spawn path' = ':\s*SpawnAtParkingSpot\s*\('
    'Cold takeoff mode' = 'SPAWN\s*\.\s*Takeoff\s*\.\s*Cold'
    'HelicopterOnly contract' = 'AIRBASE\s*\.\s*TerminalType\s*\.\s*HelicopterOnly'
    'Helicopter apron result marker' = 'G6B_HELICOPTER_APRON_COMBINED'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
    if ($sourceText -notmatch $entry.Value) {
        throw "G6B helicopter-apron guard requires: $($entry.Key) pattern $($entry.Value)"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G6B-HELICOPTER-APRON-RETEST-1'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-tarinkot-air-operations-g6b-combined-placement.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestGate: G6B_HELICOPTER_APRON_COMBINED_RETEST
-- ExpectedMissionSHA256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
-- ExpectedMooseSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
-- ExpectedMooseCommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

local OMW_TKOT_G6B_HELOAPRON_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g6b-combined-placement.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

local OMW_TKOT_G6B_HELOAPRON_CONFIG = {
  Families = {
    {
      Key = "AH64",
      TemplateGroup = "TPL_AIR_US_TKOT_AH64D_CAS_2SHIP",
      ExpectedType = "AH-64D_BLK_II",
      ModelRadiusM = 9.967,
      ExpectedTotalUnits = 2,
      SpawnRequests = {
        { Alias = "TKOT_G6B_AH64_HELOAPRON", ExpectedUnits = 2, Spots = { 4, 23 } }
      }
    },
    {
      Key = "UH60",
      TemplateGroup = "TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP",
      ExpectedType = "UH-60A",
      ModelRadiusM = 10.020,
      ExpectedTotalUnits = 2,
      SpawnRequests = {
        { Alias = "TKOT_G6B_UH60_LEAD_HELOAPRON", ExpectedUnits = 1, Spots = { 21 } },
        { Alias = "TKOT_G6B_UH60_SUPPORT_HELOAPRON", ExpectedUnits = 1, Spots = { 30 } }
      }
    },
    {
      Key = "CH47",
      TemplateGroup = "TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP",
      ExpectedType = "CH-47Fbl1",
      ModelRadiusM = 7.910,
      ExpectedTotalUnits = 1,
      SpawnRequests = {
        { Alias = "TKOT_G6B_CH47_HELOAPRON", ExpectedUnits = 1, Spots = { 29 } }
      }
    }
  }
}

-- BEGIN SOURCE: 05-tarinkot-g6b-helicopter-apron-retest.lua
"@

$footer = @"

-- END SOURCE: 05-tarinkot-g6b-helicopter-apron-retest.lua
"@

$content = $header + $sourceText + $footer
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "ForbiddenGuardPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host "RequiredGuardPatternsChecked: $($requiredPatterns.Count)"
Write-Host "ExpectedTerminalType: 40 (HelicopterOnly)"
Write-Host "FamiliesCombined: 3"
Write-Host "GroupsRequested: 4"
Write-Host "AircraftRequested: 5"
Write-Host "BundlesBuilt: 1"
