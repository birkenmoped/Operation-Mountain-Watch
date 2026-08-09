[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$g7Builder = Join-Path $repoRoot 'tools\build-tarinkot-air-operations-g7-foundation.ps1'
$g7Bundle = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist\OMW_AirOps_Tarinkot_G7_Foundation.lua'
$g8dSource = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\11-tarinkot-g8d-ah64-jalalabad-profile-ab.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G8D_AH64_JalalabadProfileAB.lua'

foreach ($path in @($g7Builder, $g8dSource)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required file not found: $path" }
}

& $g7Builder
if ($LASTEXITCODE -ne 0) { throw "G7 foundation builder failed with exit code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $g7Bundle -PathType Leaf)) { throw "G7 foundation bundle was not produced: $g7Bundle" }

$g7Text = Get-Content -LiteralPath $g7Bundle -Raw -Encoding UTF8
$g8dText = Get-Content -LiteralPath $g8dSource -Raw -Encoding UTF8

foreach ($pattern in @(
    'TKOT-G7-AIRWING-FOUNDATION-5',
    'SetOptionPreferVerticalLanding',
    '\[21\] = "CLIENT_US_TKOT_AH64D_01"',
    'ParkingIDs = \{ 20, 19 \}',
    'ParkingIDs = \{ 23, 27, 30 \}',
    'ParkingIDs = \{ 32, 29, 10 \}'
)) {
    if ($g7Text -notmatch $pattern) { throw "Required G7 foundation pattern missing: $pattern" }
}
foreach ($forbidden in @(
    'ParkingIDs = \{ 21, 4 \}',
    '\[20\] = "CLIENT_US_TKOT_AH64D_01"'
)) {
    if ($g7Text -match $forbidden) { throw "Forbidden historical G7 parking pattern present: $forbidden" }
}

foreach ($pattern in @(
    'AUFTRAG\s*:\s*NewCAS\s*\(',
    'AUFTRAG\.Type\.CAS',
    'SetMissionAltitude\s*\(\s*ROTOR_ALTITUDE_FEET\s*\)',
    'SetMissionSpeed\s*\(\s*ROTOR_SPEED_KNOTS\s*\)',
    'SetMissionIngressCoord\s*\(',
    'SetMissionEgressCoord\s*\(',
    'SetFormation\s*\(\s*ROTOR_FORMATION\s*\)',
    'ENUMS\.Formation\.RotaryWing\.EchelonRight\.D300',
    'CAS_DISTANCE_METERS = 8000',
    'ROTOR_ALTITUDE_FEET = 3500',
    'ROTOR_SPEED_KNOTS = 110',
    'SetRequiredAssets\s*\(\s*1\s*,\s*1\s*\)',
    'expectedUnits=2',
    'PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL',
    'taxiInference=disabled'
)) {
    if ($g8dText -notmatch $pattern) { throw "Required G8D source pattern missing: $pattern" }
}

foreach ($pattern in @(
    'AUFTRAG\s*:\s*NewHOVER\s*\(',
    'AUFTRAG\.Type\.HOVER',
    'AH64_2',
    'UH60_1',
    'UH60_2',
    'CH47_1',
    'COMMANDER\s*:\s*New\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    'SPAWN\s*:',
    'FLIGHTGROUP\s*:\s*New\s*\(',
    ':\s*SetOptionPreferVertical\s*\(',
    'coalition\s*\.\s*addGroup\s*\('
)) {
    if ($g8dText -match $pattern) { throw "Forbidden G8D source pattern matched: $pattern" }
}

if ([regex]::Matches($g8dText, 'AUFTRAG\s*:\s*NewCAS\s*\(').Count -ne 1) { throw 'G8D must contain exactly one AUFTRAG:NewCAS constructor.' }
if ([regex]::Matches($g8dText, 'airwing\s*:\s*AddMission\s*\(').Count -ne 1) { throw 'G8D must contain exactly one AIRWING:AddMission path.' }
if ([regex]::Matches($g8dText, 'SetRequiredAssets\s*\(\s*1\s*,\s*1\s*\)').Count -ne 1) { throw 'G8D must request exactly one MOOSE AH-64 asset group.' }

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
$builderVersion = 'TKOT-G8D-AH64-JBAD-PROFILE-AB-1'
$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"

-- BEGIN TARINKOT G8D AH64 JALALABAD-PROFILE A/B TEST
-- Builder: tools/build-tarinkot-air-operations-g8d-ah64-jalalabad-profile-ab.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Runtime scope: exactly one AH-64D two-ship, one CAS mission, Jalalabad-like rotor routing profile.
-- Parking scope: binding Tarinkot AH-64 AI parking IDs 20 and 19; client IDs remain excluded.
-- Acceptance: runtime telemetry plus mandatory owner visual confirmation of direct ramp departure.

local OMW_TKOT_G8D_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g8d-ah64-jalalabad-profile-ab.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

"@

$content = $g7Text + $header + $g8dText + "`n-- END TARINKOT G8D AH64 JALALABAD-PROFILE A/B TEST`n"
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

if ([regex]::Matches($content, 'airwing\s*:\s*AddMission\s*\(').Count -ne 1) { throw 'Generated G8D bundle does not contain exactly one operational mission path.' }
if ([regex]::Matches($content, 'AUFTRAG\s*:\s*NewCAS\s*\(').Count -ne 1) { throw 'Generated G8D bundle does not contain exactly one CAS constructor.' }
if ($content -match 'AUFTRAG\s*:\s*NewHOVER\s*\(') { throw 'Generated G8D bundle unexpectedly contains HOVER mission construction.' }

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-5'
Write-Host 'ClientTerminalIDs: 21,8,3'
Write-Host 'ParkingPools: AH64=20,19 UH60=23,27,30 CH47=32,29,10'
Write-Host 'Gate: G8D_AH64_JALALABAD_PROFILE_AB'
Write-Host 'DispatchGroups: 1'
Write-Host 'RuntimeAircraft: 2'
Write-Host 'MissionType: AUFTRAG.Type.CAS'
Write-Host 'TargetDistanceM: 8000'
Write-Host 'RotorAltitudeFt: 3500'
Write-Host 'RotorSpeedKt: 110'
Write-Host 'Formation: ENUMS.Formation.RotaryWing.EchelonRight.D300'
Write-Host 'TaxiInference: disabled'
Write-Host 'OwnerVisualConfirmation: required'
