[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\07-tarinkot-g7-airwing-squadron-payload-foundation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G7_Foundation.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source file not found: $sourceFile"
}

$sourceText = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredPatterns = @(
    'AIRWING\s*:\s*New\s*\(',
    ':\s*SetAirbase\s*\(',
    ':\s*SetTakeoffCold\s*\(',
    ':\s*SetSafeParkingOn\s*\(',
    ':\s*SetOptionPreferVerticalLanding\s*\(',
    'SQUADRON\s*:\s*New\s*\(',
    ':\s*SetGrouping\s*\(',
    ':\s*SetParkingIDs\s*\(',
    ':\s*AddMissionCapability\s*\(',
    ':\s*AddSquadron\s*\(',
    ':\s*NewPayload\s*\(',
    ':\s*GetSquadron\s*\(',
    ':\s*GetOpsGroups\s*\(',
    'airwing\s*:\s*Start\s*\(',
    'G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION',
    'verticalPolicySetBeforeStart=true',
    'commanderCreated=0',
    'auftragCreated=0',
    'opsTransportCreated=0',
    'deliberateSpawns=0'
)

foreach ($pattern in $requiredPatterns) {
    if ($sourceText -notmatch $pattern) {
        throw "Required source pattern missing: $pattern"
    }
}

$forbiddenPatterns = @(
    'COMMANDER\s*:\s*New\s*\(',
    'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    'SPAWN\s*:',
    'FLIGHTGROUP\s*:\s*New\s*\(',
    ':\s*SetAIOn\s*\(',
    ':\s*StartUncontrolled\s*\(',
    ':\s*Despawn\s*\(',
    ':\s*Destroy\s*\(',
    'coalition\s*\.\s*addGroup\s*\(',
    'ZONE_RADIUS\s*:\s*New\s*\(',
    'CampaignState\s*[\.:]',
    ':\s*AddMission\s*\('
)

foreach ($pattern in $forbiddenPatterns) {
    if ($sourceText -match $pattern) {
        throw "Forbidden source pattern matched: $pattern"
    }
}

$verticalCall = 'airwing:SetOptionPreferVerticalLanding()'
$startCall = 'airwing:Start()'
$verticalIndex = $sourceText.IndexOf($verticalCall, [System.StringComparison]::Ordinal)
$startIndex = $sourceText.IndexOf($startCall, [System.StringComparison]::Ordinal)

if ($verticalIndex -lt 0) {
    throw "Vertical-policy call not found: $verticalCall"
}
if ($startIndex -lt 0) {
    throw "AIRWING start call not found: $startCall"
}
if ($verticalIndex -ge $startIndex) {
    throw 'AIRWING:SetOptionPreferVerticalLanding() must occur before AIRWING:Start().'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G7-AIRWING-FOUNDATION-1'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}
$generatedUtc = [DateTime]::UtcNow.ToString('o')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-tarinkot-air-operations-g7-foundation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
-- Scope: one AIRWING, three SQUADRONs, G6-accepted parking pools,
-- capabilities, role payloads and stable idle AIRWING start.
-- Excluded: COMMANDER, AUFTRAG instances, OPSTRANSPORT, SPAWN, functional
-- zones, tactical dispatch, return/recovery and lifecycle cleanup.
-- Vertical policy order: AIRWING:SetOptionPreferVerticalLanding() before
-- AIRWING:Start(); actual vertical departure remains a later G8 dispatch test.

local OMW_TKOT_G7_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g7-foundation.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

-- BEGIN SOURCE
"@

$footer = @"

-- END SOURCE
"@

$content = $header + $sourceText + $footer
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION"
Write-Host "Airwing: AW_US_TKOT_TF_ATTACK_3_101_AVN"
Write-Host "Squadrons: 3"
Write-Host "RegisteredGroups: 5"
Write-Host "RegisteredAircraft: 7"
Write-Host "RolePayloads: 3"
Write-Host "ExpectedTotalPayloadsIncludingRelocation: 6"
Write-Host "ParkingPools: AH64=21,4 UH60=30,27,23 CH47=32,29,10"
Write-Host "VerticalPolicy: AIRWING:SetOptionPreferVerticalLanding before AIRWING:Start"
Write-Host "OperationalMissions: 0"
Write-Host "DeliberateSpawns: 0"
Write-Host "RequiredGuardPatternsChecked: $($requiredPatterns.Count)"
Write-Host "ForbiddenGuardPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host "BundlesBuilt: 1"
