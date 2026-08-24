Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourcePath = Join-Path $repoRoot "mission/tests/awacs-external-lifecycle/src/05-awacs-e3-performance-matrix.lua"
$distDir = Join-Path $repoRoot "mission/tests/awacs-external-lifecycle/dist"
$outputPath = Join-Path $distDir "OMW_AWACS_Acceptance_5.lua"
$moosePath = Join-Path $repoRoot "Moose.lua"

if (-not (Test-Path $sourcePath)) { throw "Missing source: $sourcePath" }
if (-not (Test-Path $moosePath)) { throw "Missing Moose.lua: $moosePath" }
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$gitCommit = (git -C $repoRoot rev-parse HEAD).Trim()
$sourceSha = (Get-FileHash $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
$mooseSha = (Get-FileHash $moosePath -Algorithm SHA256).Hash.ToLowerInvariant()
$expectedMooseSha = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"
if ($mooseSha -ne $expectedMooseSha) {
    throw "Unexpected Moose.lua SHA256. Expected $expectedMooseSha but got $mooseSha"
}

$source = Get-Content $sourcePath -Raw -Encoding UTF8
$requiredMarkers = @(
    'OMW_TEST_E3_FL',
    'STABILIZATION_NM = 20',
    'MEASUREMENT_NM = 200',
    'ALTITUDES_FT = { 25000, 32000, 35000 }',
    'TARGET_IAS_KT = { 230, 250, 270, 290, 310 }',
    'SPAWN:NewWithAlias',
    'FLIGHTGROUP:New',
    'UTILS.IasToTas',
    'GetAirspeedIndicated',
    'GetAirspeedTrue',
    'GetFuelMin',
    'SUMMARY testId='
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) { throw "Required marker missing: $marker" }
}

$forbiddenMarkers = @(
    'trigger.action.',
    'missionCommands.',
    'GetCurrentFuelKgs',
    'GetFuelMassMax'
)
foreach ($marker in $forbiddenMarkers) {
    if ($source.Contains($marker)) { throw "Forbidden marker present: $marker" }
}

$header = @"
-- GENERATED FILE - DO NOT EDIT DIRECTLY.
-- BuilderVersion: OMW-AWACS-ACCEPTANCE-5-1
-- TestId: AWACS-E3-PERFORMANCE-MATRIX-ACCEPTANCE-5
-- Scope: E3_ALTITUDE_IAS_FUEL_PERFORMANCE_MATRIX
-- Template: OMW_C2_E3A_WIZARD
-- Profiles: 15
-- AltitudesFt: 25000,32000,35000
-- TargetIASKt: 230,250,270,290,310
-- StabilizationNm: 20
-- MeasurementNm: 200
-- RuntimeGeometry: true
-- MissionEditorMarkersRequired: false
-- MissionEditorRoutesRequired: false
-- MissionEditorPerProfileTriggersRequired: false
-- MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- MooseLuaSHA256: $mooseSha
-- GitCommit: $gitCommit
-- SourceSHA256: $sourceSha

"@

Set-Content -Path $outputPath -Value ($header + $source) -Encoding UTF8
$bundleSha = (Get-FileHash $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputPath"
Write-Host "BuilderVersion: OMW-AWACS-ACCEPTANCE-5-1"
Write-Host "TestId: AWACS-E3-PERFORMANCE-MATRIX-ACCEPTANCE-5"
Write-Host "Scope: E3_ALTITUDE_IAS_FUEL_PERFORMANCE_MATRIX"
Write-Host "Template: OMW_C2_E3A_WIZARD"
Write-Host "Profiles: 15"
Write-Host "AltitudesFt: 25000,32000,35000"
Write-Host "TargetIASKt: 230,250,270,290,310"
Write-Host "StabilizationNm: 20"
Write-Host "MeasurementNm: 200"
Write-Host "RuntimeGeometry: true"
Write-Host "MissionEditorMarkersRequired: false"
Write-Host "MissionEditorRoutesRequired: false"
Write-Host "MissionEditorPerProfileTriggersRequired: false"
Write-Host "MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
Write-Host "MooseLuaSHA256: $mooseSha"
Write-Host "GitCommit: $gitCommit"
Write-Host "SourceSHA256: $sourceSha"
Write-Host "BundleSHA256: $bundleSha"
