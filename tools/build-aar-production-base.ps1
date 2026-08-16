[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot 'mission\runtime\air-operations'
$outputFile = Join-Path $distDir 'OMW_AAR_Base.lua'

$builderVersion = 'OMW-AIROPS-AAR-BASE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  InitialStock = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
  AARStrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  CampaignStateInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Bootstrap = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_AAR_Bootstrap.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AAR production-base source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requiredMarkers = @(
  @{ File = 'AARStrategicStock'; Marker = 'OFFMAP_MANAS' },
  @{ File = 'AARStrategicStock'; Marker = 'OFFMAP_AL_UDEID' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'STATION_CYCLE_SEC = 3 * 60 * 60' },
  @{ File = 'Controller'; Marker = 'RELIEF_HANDOVER_ETA_SEC = 5 * 60' },
  @{ File = 'Controller'; Marker = 'SOURCE_SPAWN_INTERVAL_SEC = 60' },
  @{ File = 'Controller'; Marker = 'SPAWN_INITIAL_SPEED_KT = 480' },
  @{ File = 'Controller'; Marker = 'LATE_APPROACH_NM = 60' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterFuelLow' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Controller'; Marker = 'function Controller.SubmitDemand' },
  @{ File = 'Controller'; Marker = 'function Controller.EndDemand' },
  @{ File = 'Bootstrap'; Marker = 'PRODUCTION_AAR_BASE' },
  @{ File = 'Bootstrap'; Marker = 'facade.SubmitDemand' },
  @{ File = 'Bootstrap'; Marker = 'facade.EndDemand' },
  @{ File = 'Bootstrap'; Marker = 'testHarness=false' }
)

foreach ($requirement in $requiredMarkers) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AAR production-base marker in $($requirement.File): $($requirement.Marker)"
  }
}

$forbiddenPatterns = @(
  'TestForceEgress',
  'UNIT:Explode',
  'AAR-PRODUCTION-FINAL-ACCEPTANCE',
  'AAR-FUEL-TELEMETRY',
  'HOLD_BACKGROUND_SCHEDULED_RELIEF',
  'TEST_ISOLATION',
  'RESULT PASS',
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute'
)

foreach ($entry in $content.GetEnumerator()) {
  if ($entry.Key -eq 'Controller') {
    foreach ($pattern in $forbiddenPatterns) {
      if ($entry.Value -match $pattern) {
        throw "Forbidden test/native marker in production controller: $pattern"
      }
    }
  }
  if ($entry.Key -eq 'Bootstrap') {
    foreach ($pattern in $forbiddenPatterns) {
      if ($entry.Value -match $pattern) {
        throw "Forbidden test/native marker in production bootstrap: $pattern"
      }
    }
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
-- Builder: tools/build-aar-production-base.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceCommitUtc: $sourceCommitUtc
-- Scope: permanent OMW AirOps AAR production base.
-- STANDARD: NELSON, PATTY, MILHOUSE, KRUSTY continuous coverage.
-- RESERVE: LISA, MOE demand-driven only.
-- Real lifecycle only: scheduled relief, FuelLow relief, aircraft loss/replacement, FIR ingress/egress, external handoff, CampaignState accounting.
-- Test-only mechanisms: absent.
-- CampaignState: reuse OMW.AirOps.CampaignContext when present; otherwise create the single initial context from approved AirOps stock plus AAR off-map stock.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AAR_BASE_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_InitialStock = (function()`n" + $content.InitialStock + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_AARStrategicStock = (function()`n" + $content.AARStrategicStock + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_CampaignStateInitializer = (function()`n" + $content.CampaignStateInitializer + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_Controller = (function()`n" + $content.Controller + "`nend)()`n"
$bundle += "local OMW_AAR_BASE_Bootstrap = (function()`n" + $content.Bootstrap + "`nend)()`n"
$bundle += @"
OMW_AAR_BASE_Bootstrap.Start({
  campaignState = OMW_AAR_BASE_CampaignState,
  initialStock = OMW_AAR_BASE_InitialStock,
  aarStrategicStock = OMW_AAR_BASE_AARStrategicStock,
  campaignStateInitializer = OMW_AAR_BASE_CampaignStateInitializer,
  adapterModule = OMW_AAR_BASE_Adapter,
  runtimeIntegration = OMW_AAR_BASE_RuntimeIntegration,
  controller = OMW_AAR_BASE_Controller,
})
"@

foreach ($pattern in $forbiddenPatterns) {
  if ($bundle -match $pattern) {
    throw "Generated AAR production base contains forbidden marker: $pattern"
  }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'DeterministicBundleForCommit: true'
Write-Host 'Scope: PRODUCTION_AAR_BASE'
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'ContinuousCoverage: NELSON,PATTY,MILHOUSE,KRUSTY'
Write-Host 'ReserveDemandOnly: LISA,MOE'
Write-Host 'StationCycleSec: 10800'
Write-Host 'ReliefHandoverArmSec: 300'
Write-Host 'SameSourceMaterializationSpacingSec: 60'
Write-Host 'RealFuelLowLifecycle: true'
Write-Host 'RealLossReplacementLifecycle: true'
Write-Host 'ArtificialFuelLow: false'
Write-Host 'ArtificialLoss: false'
Write-Host 'AcceleratedRelief: false'
Write-Host 'AcceptanceHarness: false'
Write-Host 'MissionDemandFacade: OMW.AirOps.AAR.SubmitDemand/EndDemand'
Write-Host 'CampaignStateAuthority: OMW.AirOps.CampaignContext'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}

$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"