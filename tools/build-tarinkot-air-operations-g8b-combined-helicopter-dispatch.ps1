[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$g7Builder = Join-Path $repoRoot 'tools\build-tarinkot-air-operations-g7-foundation.ps1'
$g7Bundle = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist\OMW_AirOps_Tarinkot_G7_Foundation.lua'
$sourceFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\09-tarinkot-g8b-combined-helicopter-dispatch.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G8B_CombinedHelicopterDispatch.lua'

foreach ($requiredFile in @($g7Builder, $sourceFile)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required file not found: $requiredFile"
    }
}

& $g7Builder
if ($LASTEXITCODE -ne 0) {
    throw "G7 foundation builder failed with exit code $LASTEXITCODE"
}
if (-not (Test-Path -LiteralPath $g7Bundle -PathType Leaf)) {
    throw "G7 foundation bundle was not produced: $g7Bundle"
}

$g7Text = Get-Content -LiteralPath $g7Bundle -Raw -Encoding UTF8
$sourceText = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredPatterns = @(
    'TKOT-G7-AIRWING-FOUNDATION-5',
    'G8B_COMBINED_HELICOPTER_DISPATCH',
    'AH64_1',
    'AH64_2',
    'UH60_1',
    'UH60_2',
    'CH47_1',
    'AUFTRAG\s*:\s*NewCAS\s*\(',
    'AUFTRAG\s*:\s*NewLANDATCOORDINATE\s*\(',
    'airwing\s*:\s*AddMission\s*\(',
    'OnAfterFlightOnMission',
    'OnAfterTakeoff',
    'ASSIGNMENT_TIMEOUT_SECONDS\s*=\s*720',
    'TAKEOFF_TIMEOUT_SECONDS\s*=\s*360',
    'expectedRuntimeUnits=7',
    'expectedTakeoffGroups=5',
    'expectedLandingMissions=3',
    'ownerVisualRequired=true'
)
foreach ($pattern in $requiredPatterns) {
    $text = if ($pattern -eq 'TKOT-G7-AIRWING-FOUNDATION-5') { $g7Text } else { $sourceText }
    if ($text -notmatch $pattern) {
        throw "Required combined-dispatch pattern missing: $pattern"
    }
}

$forbiddenPatterns = @(
    'COMMANDER\s*:\s*New\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    'SPAWN\s*:',
    'FLIGHTGROUP\s*:\s*New\s*\(',
    ':\s*SetOptionPreferVertical\s*\(',
    'ZONE_RADIUS\s*:\s*New\s*\(',
    ':\s*SetAIOn\s*\(',
    ':\s*StartUncontrolled\s*\(',
    ':\s*Despawn\s*\(',
    ':\s*Destroy\s*\(',
    'coalition\s*\.\s*addGroup\s*\(',
    'CampaignState\s*[\.:]'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($sourceText -match $pattern) {
        throw "Forbidden combined-dispatch pattern matched: $pattern"
    }
}

if ([regex]::Matches($sourceText, 'airwing\s*:\s*AddMission\s*\(').Count -ne 1) {
    throw 'Combined dispatch must contain one looped AIRWING:AddMission code path.'
}
if ([regex]::Matches($sourceText, 'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(').Count -ne 2) {
    throw 'Combined dispatch must contain exactly the CAS and LANDATCOORDINATE constructors.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G8B-COMBINED-HELICOPTER-DISPATCH-1'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}
$generatedUtc = [DateTime]::UtcNow.ToString('o')

$header = @"

-- BEGIN TARINKOT G8B COMBINED HELICOPTER DISPATCH
-- Builder: tools/build-tarinkot-air-operations-g8b-combined-helicopter-dispatch.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Runtime scope: five registered groups, seven aircraft, five AUFTRAG instances.
-- Excluded: COMMANDER, OPSTRANSPORT, raw SPAWN, standalone FLIGHTGROUP,
-- synthetic zones, campaign-state mutation and lifecycle cleanup.

local OMW_TKOT_G8B_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g8b-combined-helicopter-dispatch.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

"@

$content = $g7Text + $header + $sourceText + "`n-- END TARINKOT G8B COMBINED HELICOPTER DISPATCH`n"
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-5'
Write-Host 'LifecycleGuard: PASS via G7 builder'
Write-Host 'Gate: G8B_COMBINED_HELICOPTER_DISPATCH'
Write-Host 'RegisteredGroups: AH64=2 UH60=2 CH47=1 Total=5'
Write-Host 'RuntimeAircraft: AH64=4 UH60=2 CH47=1 Total=7'
Write-Host 'OperationalMissions: CAS=2 LANDATCOORDINATE=3 Total=5'
Write-Host 'AssignmentTimeoutS: 720'
Write-Host 'TakeoffTimeoutAfterFlightOnMissionS: 360'
Write-Host 'AggregateTimeoutS: 1200'
Write-Host 'GroundDisplacementThresholdM: 75'
Write-Host 'Commander: 0'
Write-Host 'OpsTransport: 0'
Write-Host 'RawSpawn: 0'
Write-Host 'StandaloneFlightGroup: 0'
Write-Host 'SyntheticZones: 0'
Write-Host 'OwnerVisualConfirmation: required'
Write-Host "RequiredPatternsChecked: $($requiredPatterns.Count)"
Write-Host "ForbiddenPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host 'BundlesBuilt: 1'
