[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G6A_ParkingAnalysis.lua'

$sourceFiles = @(
    '02-tarinkot-g6a-parking-candidate-analysis.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

$forbiddenPatterns = [ordered]@{
    'AIRWING constructor' = 'AIRWING\s*:\s*New\s*\('
    'SQUADRON constructor' = 'SQUADRON\s*:\s*New\s*\('
    'COMMANDER constructor' = 'COMMANDER\s*:\s*New\s*\('
    'AUFTRAG constructor' = 'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\('
    'OPSTRANSPORT constructor' = 'OPSTRANSPORT\s*:\s*New\s*\('
    'SPAWN constructor' = 'SPAWN\s*:\s*New[A-Za-z0-9_]*\s*\('
    'Payload registration' = ':\s*NewPayload\s*\('
    'Squadron or warehouse parking assignment' = ':\s*SetParkingIDs\s*\('
    'Airbase parking whitelist mutation' = ':\s*SetParkingWhitelist\s*\('
    'Airbase parking blacklist mutation' = ':\s*SetParkingBlacklist\s*\('
    'Safe parking mutation' = ':\s*SetSafeParking(On|Off)\s*\('
    'Client parking enablement' = ':\s*SetAllowSpawnOnClientParking\s*\('
    'Commander mission queue mutation' = ':\s*AddMission\s*\('
    'Commander transport queue mutation' = ':\s*AddOpsTransport\s*\('
    'Group or object activation' = ':\s*Activate\s*\('
    'Spawn call' = ':\s*Spawn[A-Za-z0-9_]*\s*\('
    'F10 parking marks' = ':\s*MarkParkingSpots\s*\('
    'F10 map mark mutation' = ':\s*MarkTo(All|Coalition|Group)\s*\('
}

$sourceContent = New-Object System.Collections.Generic.List[string]
foreach ($fileName in $sourceFiles) {
    $path = Join-Path $sourceDir $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required source file not found: $path"
    }

    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
        if ($text -match $entry.Value) {
            throw "G6A read-only guard rejected '$fileName': $($entry.Key) matched pattern $($entry.Value)"
        }
    }
    $sourceContent.Add($text)
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G6A-PARKING-ANALYSIS-1'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-tarinkot-air-operations-g6a-parking-analysis.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestGate: G6A_PARKING_CANDIDATE_ANALYSIS
-- ExpectedMissionSHA256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
-- ExpectedMooseSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
-- ExpectedMooseCommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

local OMW_TKOT_G6A_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g6a-parking-analysis.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

"@

$chunks = New-Object System.Collections.Generic.List[string]
$chunks.Add($header)

for ($index = 0; $index -lt $sourceFiles.Count; $index++) {
    $fileName = $sourceFiles[$index]
    $chunks.Add("-- BEGIN SOURCE: $fileName`r`n")
    $chunks.Add($sourceContent[$index])
    $chunks.Add("`r`n-- END SOURCE: $fileName`r`n")
}

$content = [string]::Concat($chunks)
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "ReadOnlyGuardPatternsChecked: $($forbiddenPatterns.Count)"
