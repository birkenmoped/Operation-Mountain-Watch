[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\06-tarinkot-g6a2-me-parking-map.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G6A2_MEParkingMap.lua'

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
        throw "G6A2 parking-map guard rejected source: $($entry.Key) matched pattern $($entry.Value)"
    }
}

$requiredPatterns = [ordered]@{
    'Mapping prefix' = 'TKOT_PARKMAP_ME_'
    'Mission source traversal' = 'env\s*\.\s*mission'
    'MOOSE parking data' = ':\s*GetParkingSpotsTable\s*\('
    'Parking map marker' = 'PARKING_MAP'
    'Result marker' = 'G6A2_ME_PARKING_MAP'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
    if ($sourceText -notmatch $entry.Value) {
        throw "G6A2 parking-map guard requires: $($entry.Key) pattern $($entry.Value)"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G6A2-ME-PARKING-MAP-1'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-tarinkot-air-operations-g6a2-parking-map.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestGate: G6A2_ME_PARKING_MAP
-- ExpectedMooseSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

local OMW_TKOT_G6A2_PARKMAP_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g6a2-parking-map.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

-- BEGIN SOURCE: 06-tarinkot-g6a2-me-parking-map.lua
"@

$footer = @"

-- END SOURCE: 06-tarinkot-g6a2-me-parking-map.lua
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
Write-Host "MappingPrefix: TKOT_PARKMAP_ME_"
Write-Host "BundlesBuilt: 1"
