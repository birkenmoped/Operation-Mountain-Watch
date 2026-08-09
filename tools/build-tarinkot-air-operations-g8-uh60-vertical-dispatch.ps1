[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$g7Builder = Join-Path $repoRoot 'tools\build-tarinkot-air-operations-g7-foundation.ps1'
$g7Bundle = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist\OMW_AirOps_Tarinkot_G7_Foundation.lua'
$g8Source = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\08-tarinkot-g8-uh60-native-vertical-dispatch.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G8_UH60_VerticalDispatch.lua'

foreach ($requiredFile in @($g7Builder, $g8Source)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required file not found: $requiredFile"
    }
}

# Build the accepted G7 foundation first. Its builder applies the binding
# project-wide lifecycle guard and emits the corrected foundation source.
& $g7Builder
if ($LASTEXITCODE -ne 0) {
    throw "G7 foundation builder failed with exit code $LASTEXITCODE"
}
if (-not (Test-Path -LiteralPath $g7Bundle -PathType Leaf)) {
    throw "G7 foundation bundle was not produced: $g7Bundle"
}

$g7Text = Get-Content -LiteralPath $g7Bundle -Raw -Encoding UTF8
$g8Text = Get-Content -LiteralPath $g8Source -Raw -Encoding UTF8

$requiredG7Patterns = @(
    'TKOT-G7-AIRWING-FOUNDATION-5',
    'G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION',
    'observerClientsDetected=',
    'SQUADRON_STOCK_PRESTART',
    'SetOptionPreferVerticalLanding'
)
foreach ($pattern in $requiredG7Patterns) {
    if ($g7Text -notmatch $pattern) {
        throw "Required G7 foundation pattern missing: $pattern"
    }
}

$requiredG8Patterns = @(
    'AUFTRAG\s*:\s*NewLANDATCOORDINATE\s*\(',
    ':\s*SetRequiredAssets\s*\(',
    ':\s*AssignSquadrons\s*\(',
    ':\s*AddRequiredPayload\s*\(',
    'airwing\s*:\s*AddMission\s*\(',
    'OnAfterFlightOnMission',
    'OptionPreferVertical',
    'Unit\.getByName\s*\(',
    ':inAir\s*\(',
    'ZONE_AIR_US_TKOT_ROTARY_STAGING',
    'G8_UH60_NATIVE_VERTICAL_DEPARTURE',
    'PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL',
    'maxGroundDisplacementM=',
    'ownerVisualRequired=true'
)
foreach ($pattern in $requiredG8Patterns) {
    if ($g8Text -notmatch $pattern) {
        throw "Required G8 source pattern missing: $pattern"
    }
}

$forbiddenG8Patterns = @(
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
foreach ($pattern in $forbiddenG8Patterns) {
    if ($g8Text -match $pattern) {
        throw "Forbidden G8 source pattern matched: $pattern"
    }
}

$missionAdds = [regex]::Matches($g8Text, 'airwing\s*:\s*AddMission\s*\(').Count
if ($missionAdds -ne 1) {
    throw "G8 must contain exactly one native AIRWING:AddMission path; actual=$missionAdds"
}

$auftragConstructors = [regex]::Matches($g8Text, 'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(').Count
if ($auftragConstructors -ne 1) {
    throw "G8 must contain exactly one AUFTRAG constructor; actual=$auftragConstructors"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G8-UH60-VERTICAL-DISPATCH-2'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}
$generatedUtc = [DateTime]::UtcNow.ToString('o')

$g8Header = @"

-- BEGIN TARINKOT G8 NATIVE UH-60 VERTICAL-DEPARTURE DISPATCH
-- Builder: tools/build-tarinkot-air-operations-g8-uh60-vertical-dispatch.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Required Mission Editor zone: ZONE_AIR_US_TKOT_ROTARY_STAGING
-- Runtime scope: one UH-60, one LANDATCOORDINATE AUFTRAG, one AIRWING:AddMission.
-- Excluded: COMMANDER, OPSTRANSPORT, SPAWN, standalone FLIGHTGROUP,
-- synthetic zones, lifecycle cleanup and campaign-state mutation.
-- Acceptance: runtime telemetry plus mandatory owner visual confirmation.

local OMW_TKOT_G8_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g8-uh60-vertical-dispatch.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

"@

$footer = @"

-- END TARINKOT G8 NATIVE UH-60 VERTICAL-DEPARTURE DISPATCH
"@

$content = $g7Text + $g8Header + $g8Text + $footer
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

if ($content -match 'activePlayerClientCount\s*=\s*function') {
    throw 'Generated G8 bundle contains observer-count masking.'
}
if ([regex]::Matches($content, 'airwing\s*:\s*AddMission\s*\(').Count -ne 1) {
    throw 'Generated G8 bundle does not contain exactly one operational mission path.'
}
if ($content -notmatch 'TKOT-G7-AIRWING-FOUNDATION-5') {
    throw 'Generated G8 bundle does not embed the corrected G7 foundation.'
}

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-5'
Write-Host 'LifecycleGuard: PASS via G7 builder'
Write-Host 'Gate: G8_UH60_NATIVE_VERTICAL_DEPARTURE'
Write-Host 'MissionType: AUFTRAG.Type.LANDATCOORDINATE'
Write-Host 'Squadron: SQ_US_TKOT_UH60_TF_ATTACK'
Write-Host 'RequiredAssets: 1'
Write-Host 'DestinationZone: ZONE_AIR_US_TKOT_ROTARY_STAGING'
Write-Host 'GroundDisplacementThresholdM: 75'
Write-Host 'OperationalMissions: 1'
Write-Host 'Commander: 0'
Write-Host 'OpsTransport: 0'
Write-Host 'RawSpawn: 0'
Write-Host 'StandaloneFlightGroup: 0'
Write-Host 'SyntheticZones: 0'
Write-Host 'OwnerVisualConfirmation: required'
Write-Host "RequiredG8PatternsChecked: $($requiredG8Patterns.Count)"
Write-Host "ForbiddenG8PatternsChecked: $($forbiddenG8Patterns.Count)"
Write-Host 'BundlesBuilt: 1'
