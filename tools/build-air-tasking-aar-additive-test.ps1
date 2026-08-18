[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$bridgeFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirTasking_AARBridge.lua'
$bootstrapFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirTasking_AARBootstrap.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\src\01-air-tasking-aar-vertical-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\dist'
$outputFile = Join-Path $distDir 'OMW_AirTasking_AAR_Vertical_Test.lua'

$builderVersion = 'OMW-AIR-TASKING-AAR-ADDITIVE-TEST-2'
$testId = 'AIR-TASKING-AAR-VERTICAL-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($required in @($bridgeFile, $bootstrapFile, $harnessFile)) {
  if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
    throw "Required Air Tasking additive source not found: $required"
  }
}

$bridge = Get-Content -LiteralPath $bridgeFile -Raw -Encoding UTF8
$bootstrap = Get-Content -LiteralPath $bootstrapFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
  @{ Text = $bootstrap; Marker = 'OMW-AIR-TASKING-AAR-BOOTSTRAP-3' },
  @{ Text = $bootstrap; Marker = 'spec.aarFacade must already be RUNNING' },
  @{ Text = $bootstrap; Marker = 'GetStation' },
  @{ Text = $bootstrap; Marker = 'MOOSE SCHEDULER is unavailable' },
  @{ Text = $bootstrap; Marker = 'adapterRecreated=false adapterMutated=false' },
  @{ Text = $bridge; Marker = 'function Bridge:SubmitApprovedAAR' },
  @{ Text = $bridge; Marker = 'function Bridge:EndAAR' },
  @{ Text = $harness; Marker = 'AIR-TASKING-AAR-VERTICAL-2' },
  @{ Text = $harness; Marker = 'WAITING_FOR_EXISTING_AAR_BASE' },
  @{ Text = $harness; Marker = 'EXISTING_AAR_ATTACH_PASS' },
  @{ Text = $harness; Marker = 'STANDARD_BASELINE_PASS' },
  @{ Text = $harness; Marker = 'NATURAL_LISA_ON_STATION_PASS' },
  @{ Text = $harness; Marker = 'SETTLEMENT_PASS' },
  @{ Text = $harness; Marker = 'RESULT PASS' }
)

foreach ($requirement in $requiredMarkers) {
  if (-not $requirement.Text.Contains($requirement.Marker)) {
    throw "Missing additive Air Tasking marker: $($requirement.Marker)"
  }
}

$combinedSource = $bridge + "`n" + $bootstrap + "`n" + $harness
$forbiddenPatterns = @(
  'OMW-AIROPS-AAR-BASE-1',
  'OMW_AAR_TEST_Controller',
  'OMW_AAR_TEST_Adapter',
  'OMW_AAR_TEST_RuntimeIntegration',
  'OMW_AAR_TEST_CampaignState',
  'build-air-tasking-aar-vertical-base.ps1',
  'build-air-tasking-aar-vertical-acceptance.ps1',
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  'UNIT:Explode',
  'TestForceEgress',
  'runtime\.trackCoord\s*=',
  'adapter\.OnMaterialized\s*=',
  'adapter\.OnHandoff\s*=',
  'adapter\.OnLost\s*=',
  'SetStrategicAdapter\s*\('
)

foreach ($pattern in $forbiddenPatterns) {
  if ($combinedSource -match $pattern) {
    throw "Forbidden pattern in additive Air Tasking test bundle: $pattern"
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
-- Builder: tools/build-air-tasking-aar-additive-test.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceCommitUtc: $sourceCommitUtc
-- TestId: $testId
-- Scope: additive Air Tasking attachment to an already running accepted AAR base.
-- Existing AAR base/controller/adapter are not embedded, recreated, replaced or mutated.
-- The test waits for OMW.AirOps.AAR.Status == RUNNING before attaching.
-- Air Tasking observes controller-exposed runtime state with MOOSE SCHEDULER at bounded cadence.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AIR_TASKING_TEST_Bridge = (function()`n" + $bridge + "`nend)()`n"
$bundle += "local OMW_AIR_TASKING_TEST_Bootstrap = (function()`n" + $bootstrap + "`nend)()`n"
$bundle += $harness + "`n"

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

$bridgeHash = (Get-FileHash -LiteralPath $bridgeFile -Algorithm SHA256).Hash.ToLowerInvariant()
$bootstrapHash = (Get-FileHash -LiteralPath $bootstrapFile -Algorithm SHA256).Hash.ToLowerInvariant()
$harnessHash = (Get-FileHash -LiteralPath $harnessFile -Algorithm SHA256).Hash.ToLowerInvariant()
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'Scope: AIR_TASKING_AAR_ADDITIVE_TEST'
Write-Host 'MizMutation: false'
Write-Host 'ExistingAARBaseEmbedded: false'
Write-Host 'ExistingAARBaseRecreated: false'
Write-Host 'ExistingAARAdapterRecreated: false'
Write-Host 'ExistingAARAdapterMutated: false'
Write-Host 'RuntimeObservation: CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER'
Write-Host 'ObserverIntervalSec: 5'
Write-Host 'WaitsForExistingAARFacade: true'
Write-Host 'MissionEditorAdditionalScriptRequired: true'
Write-Host 'InsertFileName: OMW_AirTasking_AAR_Vertical_Test.lua'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "AirTaskingBridgeSHA256: $bridgeHash"
Write-Host "AirTaskingBootstrapSHA256: $bootstrapHash"
Write-Host "HarnessSHA256: $harnessHash"
Write-Host "BundleSHA256: $bundleHash"
