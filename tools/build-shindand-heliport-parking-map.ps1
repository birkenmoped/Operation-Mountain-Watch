[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\shindand-air-operations\src\01-shindand-heliport-me-parking-map.lua'
$distDir = Join-Path $repoRoot 'mission\tests\shindand-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Shindand_Heliport_MEParkingMap.lua'

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
    'SPAWN constructor' = 'SPAWN\s*:\s*New[A-Za-z0-9_]*\s*\('
    'Parking assignment' = ':\s*SetParkingIDs\s*\('
    'Parking whitelist mutation' = ':\s*SetParking(Spot)?Whitelist\s*\('
    'Parking blacklist mutation' = ':\s*SetParking(Spot)?Blacklist\s*\('
    'Activation' = ':\s*Activate\s*\('
    'Spawn call' = ':\s*Spawn[A-Za-z0-9_]*\s*\('
    'Direct DCS spawn' = 'coalition\s*\.\s*addGroup\s*\('
    'MIST dynamic spawn' = 'mist\s*\.\s*dynAdd\s*\('
    'User flag mutation' = 'trigger\s*\.\s*action\s*\.\s*setUserFlag\s*\('
    'F10 mark mutation' = ':\s*MarkTo(All|Coalition|Group)\s*\('
}

foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
    if ($sourceText -match $entry.Value) {
        throw "Shindand parking-map guard rejected source: $($entry.Key) matched pattern $($entry.Value)"
    }
}

$requiredPatterns = [ordered]@{
    'Mapping prefix' = 'DIAG_SHND_HP_ME_'
    'Mission source traversal' = 'env\s*\.\s*mission'
    'Shindand Heliport enum' = 'AIRBASE\s*\.\s*Afghanistan\s*\.\s*Shindand_Heliport'
    'MOOSE airbase lookup' = ':\s*FindByName\s*\('
    'MOOSE parking data' = ':\s*GetParkingSpotsTable\s*\('
    'MOOSE closest parking' = ':\s*GetClosestParkingSpot\s*\('
    'MOOSE scheduler' = 'SCHEDULER\s*:\s*New\s*\('
    'Parking map marker' = 'PARKING_MAP'
    'Result marker' = 'SHND_HP_ME_PARKING_MAP'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
    if ($sourceText -notmatch $entry.Value) {
        throw "Shindand parking-map guard requires: $($entry.Key) pattern $($entry.Value)"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'SHND-HP-ME-PARKING-MAP-1'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-shindand-heliport-parking-map.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestGate: SHND_HP_ME_PARKING_MAP
-- Scope: read-only Shindand Heliport Mission Editor parking label to MOOSE TerminalID mapping
-- Excludes: AIRWING, SQUADRON, AUFTRAG, COMMANDER, spawn, activation, parking mutation, CampaignState mutation
-- ExpectedMooseCommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- ExpectedMooseSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

local OMW_SHND_HP_PARKMAP_BUILD = {
  Builder = "tools/build-shindand-heliport-parking-map.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

-- BEGIN SOURCE: 01-shindand-heliport-me-parking-map.lua
"@

$footer = @"

-- END SOURCE: 01-shindand-heliport-me-parking-map.lua
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
Write-Host "MappingPrefix: DIAG_SHND_HP_ME_"
Write-Host "ExpectedAnchorCount: 45"
Write-Host "BundlesBuilt: 1"
