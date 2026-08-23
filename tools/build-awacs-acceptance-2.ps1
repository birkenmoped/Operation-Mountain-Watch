[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\src\02-awacs-flight-profile-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\dist'
$outputFile = Join-Path $distDir 'OMW_AWACS_Acceptance_2.lua'

$builderVersion = 'OMW-AWACS-ACCEPTANCE-2-3'
$testId = 'AWACS-ACCEPTANCE-2-FULL-DURATION-AAR'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  '[OMW][AWACS.Acceptance2]',
  'AWACS_FULL_DURATION_AAR_ACCEPTANCE',
  'SCHEDULER:New',
  'SPAWN:New',
  'FLIGHTGROUP:New',
  'AUFTRAG:NewTANKER',
  'GetAltitude()',
  'GetVelocity()',
  'GetHeading()',
  'GetFuelMin()',
  'GetCurrentFuelKgs()',
  'GetFuelMassMax()',
  'GetLLDDM()',
  'UTILS.MpsToKnots',
  'UTILS.SecondsOfToday',
  'TANKER_DISPATCHED',
  'TANKER_READY',
  'AWACS_AAR_REQUESTED',
  'AWACS_AAR_COMPLETED',
  'TANKER_EXTERNAL_HANDOFF',
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
  'os\.execute',
  'GetLat\(',
  'GetLon\('
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
-- Scope: full 1530L-2330L AWACS service, flight profile, fuel telemetry and visible designated reserve-tanker AAR acceptance.
-- Test-only tanker coordinator: LISA KC-135 uses the already-running AAR subsystem StrategicAdapter and CampaignState authority.
-- Production AAR controller mutation: false.
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
Write-Host 'Scope: AWACS_FULL_DURATION_VISIBLE_AAR_ACCEPTANCE'
Write-Host 'SampleIntervalSec: 60'
Write-Host 'ServiceStartLocal: 15:30'
Write-Host 'ReserveTankerDispatchLocal: 18:10'
Write-Host 'PlannedAARLocal: 19:30'
Write-Host 'ServiceEndLocal: 23:30'
Write-Host 'ServiceWindowSec: 28800'
Write-Host 'ReserveTanker: LISA / OMW_AAR_KC135_LISA / Texaco3-1'
Write-Host 'ReserveTankerSource: AL_UDEID via DAVER'
Write-Host 'AARRendezvous: 60 NM bearing 340T from APOC'
Write-Host 'AARRendezvousAltitudeFt: 25000'
Write-Host 'AARRendezvousSpeedKt: 300'
Write-Host 'AWACSTransferAltitudeFt: 34000'
Write-Host 'AWACSTransferSpeedKt: 300'
Write-Host 'ManualRadioCheckRequired: true'
Write-Host 'ProductionAARControllerMutation: false'
Write-Host 'SharedAARStrategicAdapter: true'
Write-Host 'MizMutation: false'
Write-Host 'NativeDcsScheduler: false'
Write-Host 'MooseScheduler: true'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "BundleSHA256: $bundleHash"
