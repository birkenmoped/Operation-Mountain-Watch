[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\src\02-awacs-flight-profile-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\dist'
$outputFile = Join-Path $distDir 'OMW_AWACS_Acceptance_2.lua'

$builderVersion = 'OMW-AWACS-ACCEPTANCE-2-1'
$testId = 'AWACS-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  '[OMW][AWACS.Acceptance2]',
  'SCHEDULER:New',
  'GetAltitude()',
  'GetVelocity()',
  'GetHeading()',
  'GetFuelMin()',
  'GetCurrentFuelKgs()',
  'GetFuelMassMax()',
  'UTILS.MpsToKnots',
  'UTILS.SecondsOfToday',
  'ACCEPTANCE_2_PROFILE_FUEL_EGRESS',
  'STATION_30MIN_COMPLETE',
  'AUTOMATED_CAPTURE_COMPLETE'
)

foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "Missing Acceptance-2 marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  '\bmist\.',
  '\bMIST\b',
  '_DATABASE',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'io\.',
  'lfs\.',
  'os\.execute'
)

foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "Forbidden Acceptance-2 implementation marker: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-awacs-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- TestId: $testId
-- GitCommit: $commit
-- Scope: AWACS flight-profile / fuel telemetry acceptance observer.
-- MIZ mutation: false.
-- Production controller mutation: false.
-- MOOSE-first: public SCHEDULER / FLIGHTGROUP / GROUP / UNIT / COORDINATE / UTILS methods only.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header + $source
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

$sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToLowerInvariant()
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host 'Scope: AWACS_PROFILE_FUEL_TELEMETRY'
Write-Host 'SampleIntervalSec: 15'
Write-Host 'StationDwellSec: 1800'
Write-Host 'ControlledEgressAfterStationDwell: true'
Write-Host 'ManualRadioCheckRequired: true'
Write-Host 'ProductionControllerMutation: false'
Write-Host 'MizMutation: false'
Write-Host 'NativeDcsScheduler: false'
Write-Host 'MooseScheduler: true'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "BundleSHA256: $bundleHash"
