[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseBuilder = Join-Path $repoRoot 'tools\build-air-tasking-aar-vertical-base.ps1'
$baseBundle = Join-Path $repoRoot 'mission\runtime\air-operations\OMW_AirTasking_AAR_Vertical_Base.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\src\01-air-tasking-aar-vertical-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\dist'
$outputFile = Join-Path $distDir 'OMW_AirTasking_AAR_Vertical_Acceptance.lua'

$builderVersion = 'OMW-AIR-TASKING-AAR-VERTICAL-ACCEPTANCE-1'
$testId = 'AIR-TASKING-AAR-VERTICAL-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($required in @($baseBuilder, $harnessFile)) {
  if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
    throw "Required Air Tasking AAR acceptance source not found: $required"
  }
}

& $baseBuilder

if (-not (Test-Path -LiteralPath $baseBundle -PathType Leaf)) {
  throw "Vertical base bundle was not generated: $baseBundle"
}

$base = Get-Content -LiteralPath $baseBundle -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'Scope: Air Tasking -> accepted AAR vertical integration base.',
  'function OMW.AirTasking.AARVerticalBase.Start(spec)',
  'StableExecutionIdProviderRequired: true',
  'local TEST_ID = "AIR-TASKING-AAR-VERTICAL-1"',
  'STANDARD_BASELINE_PASS',
  'EXECUTION_STARTED_PASS',
  'NATURAL_LISA_ON_STATION_PASS',
  'MISSION_END_REQUESTED_PASS',
  'CORRELATION_PASS',
  'SETTLEMENT_PASS',
  'RESULT PASS'
)

$combinedSource = $base + "`n" + $harness
foreach ($marker in $requiredMarkers) {
  if (-not $combinedSource.Contains($marker)) {
    throw "Missing Air Tasking AAR acceptance marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  '_DATABASE',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  'UNIT:Explode',
  'TestForceEgress',
  'runtime\.trackCoord\s*=',
  'mission:SetMissionIngressCoord\(lateApproachCoord'
)

foreach ($pattern in $forbiddenPatterns) {
  if ($combinedSource -match $pattern) {
    throw "Forbidden pattern in Air Tasking AAR acceptance bundle: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$sourceCommitUtc = (& git -C $repoRoot show -s --format=%cI HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($sourceCommitUtc)) {
  throw 'Unable to determine source commit timestamp.'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-tasking-aar-vertical-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceCommitUtc: $sourceCommitUtc
-- TestId: $testId
-- Scope: first real DCS vertical acceptance for Air Tasking -> accepted AAR runtime.
-- Test case: one WEST/FAST approved MissionDemand -> LISA reserve track.
-- Completion gate: natural LISA on-station arrival before EndAAR(COMPLETE).
-- Settlement gate: external handoff must restore AL_UDEID availability to the captured pre-demand baseline.
-- Stable domain IDs: MD-000001 / ASR-000001 / ATM-000001 / EXE-*.
-- Existing STANDARD AAR tracks remain active and unchanged.
-- No artificial FuelLow, loss, teleport, route rewrite or strategic resource mutation.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header + $combinedSource
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'DeterministicBundleForCommit: true'
Write-Host 'Scope: AIR_TASKING_AAR_VERTICAL_ACCEPTANCE'
Write-Host 'MizMutation: false'
Write-Host 'TestArea: LISA'
Write-Host 'MissionDemandId: MD-000001'
Write-Host 'RequestId: ASR-000001'
Write-Host 'MissionId: ATM-000001'
Write-Host 'NaturalTrackArrivalRequired: true'
Write-Host 'ExternalHandoffRequired: true'
Write-Host 'ExactOnceSettlementRequired: true'
Write-Host 'ArtificialFuelLow: false'
Write-Host 'ArtificialLoss: false'
Write-Host 'RouteRewrite: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

$baseHash = (Get-FileHash -LiteralPath $baseBundle -Algorithm SHA256).Hash.ToLowerInvariant()
$harnessHash = (Get-FileHash -LiteralPath $harnessFile -Algorithm SHA256).Hash.ToLowerInvariant()
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "VerticalBaseSHA256: $baseHash"
Write-Host "HarnessSHA256: $harnessHash"
Write-Host "BundleSHA256: $bundleHash"
