[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\src\03-awacs-persistent-orbit-emission-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\dist'
$outputFile = Join-Path $distDir 'OMW_AWACS_Acceptance_3.lua'

$builderVersion = 'OMW-AWACS-ACCEPTANCE-3-1'
$testId = 'AWACS-PERSISTENT-ORBIT-EMISSION-ACCEPTANCE-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  '[OMW][AWACS.Acceptance3]',
  'AWACS-PERSISTENT-ORBIT-EMISSION-ACCEPTANCE-3',
  'PERSISTENT_RACETRACK',
  'SILENT',
  'EMITTING',
  'GetAltitude()',
  'GetVelocity()',
  'GetHeading()',
  'GetFuelMin()',
  'GetCurrentFuelKgs()',
  'GetFuelMassMax()',
  'GetLLDDM()',
  'UTILS.SecondsOfToday',
  'RequestEgress',
  'CONTROLLED_EGRESS_REQUESTED',
  'AUTOMATED_CAPTURE_COMPLETE'
)

foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "Missing Acceptance-3 marker: $marker"
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
  'os\.execute',
  'AUFTRAG:NewAWACS',
  'EnRouteTaskAWACS'
)

foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "Forbidden Acceptance-3 implementation marker: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-awacs-acceptance-3.ps1
-- BuilderVersion: $builderVersion
-- TestId: $testId
-- GitCommit: $commit
-- Scope: persistent APOC racetrack, service sensor/emission toggle, no AWACS mission-task replacement, controlled direct egress.
-- Native DCS scheduler: false; MOOSE SCHEDULER only.
-- MIZ mutation: false.
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
Write-Host 'Scope: AWACS_PERSISTENT_ORBIT_EMISSION_ACCEPTANCE'
Write-Host 'MissionStartLocal: 15:05'
Write-Host 'ServiceStartLocal: 15:30'
Write-Host 'ControlledEgressLocal: 15:40'
Write-Host 'SampleIntervalSec: 30'
Write-Host 'PhysicalOrbit: AUFTRAG:NewORBIT_RACETRACK'
Write-Host 'ServiceToggle: OPSGROUP:SwitchEmission + CONTROLLABLE radar option'
Write-Host 'AWACSMissionTaskUsed: false'
Write-Host 'ManualRWRCheckRequired: true'
Write-Host 'ManualNoDetourCheckRequired: true'
Write-Host 'MizMutation: false'
Write-Host 'NativeDcsScheduler: false'
Write-Host 'MooseScheduler: true'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "BundleSHA256: $bundleHash"
