[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\bagram-parking-correlation\src\OMW_Bagram_Parking_Correlation.lua'
$candidateCsv = Join-Path $repoRoot 'docs\data\bagram-me-parking-to-moose-terminalid-candidate.csv'
$distDir = Join-Path $repoRoot 'mission\tests\bagram-parking-correlation\dist'
$outputFile = Join-Path $distDir 'OMW_Bagram_Parking_Correlation.lua'
$builderVersion = 'BAGRAM-PARKING-CORRELATION-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Bagram parking correlation source not found: $sourceFile"
}
if (-not (Test-Path -LiteralPath $candidateCsv -PathType Leaf)) {
    throw "Bagram parking candidate CSV not found: $candidateCsv"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
$rows = @(Import-Csv -LiteralPath $candidateCsv)

if ($rows.Count -ne 187) {
    throw "Expected 187 Bagram parking candidates, found $($rows.Count)."
}

$seenLabels = @{}
$seenTerminalIDs = @{}
$luaRows = New-Object System.Collections.Generic.List[string]

foreach ($row in $rows) {
    $groupLabel = [string]$row.group_label
    $meParkingID = [string]$row.mission_editor_parking_id
    $terminalText = [string]$row.moose_terminal_id_candidate

    if ([string]::IsNullOrWhiteSpace($groupLabel)) {
        throw 'Candidate row has empty group_label.'
    }
    if ([string]::IsNullOrWhiteSpace($meParkingID)) {
        throw "Candidate row '$groupLabel' has empty mission_editor_parking_id."
    }

    $terminalID = 0
    if (-not [int]::TryParse($terminalText, [ref]$terminalID)) {
        throw "Candidate row '$groupLabel' has invalid TerminalID '$terminalText'."
    }

    if ($seenLabels.ContainsKey($groupLabel)) {
        throw "Duplicate group_label in candidate CSV: $groupLabel"
    }
    if ($seenTerminalIDs.ContainsKey($terminalID)) {
        throw "Duplicate candidate TerminalID in candidate CSV: $terminalID"
    }
    $seenLabels[$groupLabel] = $true
    $seenTerminalIDs[$terminalID] = $true

    $escapedGroup = $groupLabel.Replace('\', '\\').Replace('"', '\"')
    $escapedParking = $meParkingID.Replace('\', '\\').Replace('"', '\"')
    $luaRows.Add("  { groupLabel = `"$escapedGroup`", meParkingID = `"$escapedParking`", terminalID = $terminalID },")
}

if (-not $seenLabels.ContainsKey('D09')) {
    throw 'Required Bagram marker group D09 is missing.'
}
if (-not $seenLabels.ContainsKey('D09-1')) {
    throw 'Required Bagram marker group D09-1 is missing.'
}
if (-not $seenTerminalIDs.ContainsKey(0)) {
    throw 'Required valid TerminalID 0 candidate is missing.'
}

$luaTable = "{`n" + (($luaRows -join "`n")) + "`n}"
if (-not $source.Contains('__BAGRAM_PARKING_CANDIDATES__')) {
    throw 'Diagnostic source is missing candidate-table placeholder.'
}

$content = $source.Replace('__BAGRAM_PARKING_CANDIDATES__', $luaTable)

$requiredMarkers = @(
    'AIRBASE:FindByName',
    'GetParkingSpotsTable',
    'GROUP:FindByName',
    'Get2DDistance',
    'RESULT status=%s',
    'matchDistanceMeters'
)
foreach ($marker in $requiredMarkers) {
    if (-not $content.Contains($marker)) {
        throw "Generated diagnostic is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'SetParkingIDs\s*\(',
    'SetParkingSpotWhitelist\s*\(',
    'SetParkingSpotBlacklist\s*\(',
    'SpawnAtParkingSpot\s*\(',
    'SpawnAtAirbase\s*\(',
    'AUFTRAG\s*:\s*New',
    'COMMANDER\s*:\s*New',
    'OPSTRANSPORT\s*:\s*New',
    'missionCommands',
    '_FindParkingForAssets'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($content -match $pattern) {
        throw "Read-only parking correlation regression: forbidden pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-bagram-parking-correlation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: read-only Bagram parking marker to runtime MOOSE TerminalID correlation.`n`n"
$content = $header + $content

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: READ_ONLY_BAGRAM_PARKING_CORRELATION"
Write-Host "Candidates: $($rows.Count)"
Write-Host "ExpectedMarkerGroups: 187"
Write-Host "ParkingMutation: ABSENT"
Write-Host "SpawnMutation: ABSENT"
Write-Host "TaskingMutation: ABSENT"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
