[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot 'mission\runtime\air-operations'
$outputFile = Join-Path $distDir 'OMW_AirTasking_AAR_Vertical_Base.lua'

$builderVersion = 'OMW-AIR-TASKING-AAR-VERTICAL-BASE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  InitialStock = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
  AARStrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  CampaignStateInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  BaseAdapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  AARBootstrap = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_AAR_Bootstrap.lua'
  AirTaskingBridge = Join-Path $repoRoot 'scripts\air-operations\OMW_AirTasking_AARBridge.lua'
  AirTaskingBootstrap = Join-Path $repoRoot 'scripts\air-operations\OMW_AirTasking_AARBootstrap.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required Air Tasking AAR vertical-base source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requiredMarkers = @(
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'function Controller.SelectArea' },
  @{ File = 'Controller'; Marker = 'function Controller.SubmitDemand' },
  @{ File = 'Controller'; Marker = 'function Controller.EndDemand' },
  @{ File = 'AARBootstrap'; Marker = 'PRODUCTION_AAR_BASE' },
  @{ File = 'AirTaskingBridge'; Marker = 'function Bridge:SubmitApprovedAAR' },
  @{ File = 'AirTaskingBridge'; Marker = 'function Bridge:EndAAR' },
  @{ File = 'AirTaskingBridge'; Marker = 'function Bridge:GetAdapterModule' },
  @{ File = 'AirTaskingBootstrap'; Marker = 'AIR_TASKING_AAR_VERTICAL' },
  @{ File = 'AirTaskingBootstrap'; Marker = 'baseAdapterModule = baseAdapterModule' },
  @{ File = 'AirTaskingBootstrap'; Marker = 'adapterModule = wrappedAdapterModule' }
)

foreach ($requirement in $requiredMarkers) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing Air Tasking AAR vertical-base marker in $($requirement.File): $($requirement.Marker)"
  }
}

$forbiddenPatterns = @(
  'UNIT:Explode',
  'TestForceEgress',
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  'os\.execute'
)

foreach ($entry in @('Controller', 'AARBootstrap', 'AirTaskingBridge', 'AirTaskingBootstrap')) {
  foreach ($pattern in $forbiddenPatterns) {
    if ($content[$entry] -match $pattern) {
      throw "Forbidden marker in ${entry}: $pattern"
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
-- Builder: tools/build-air-tasking-aar-vertical-base.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceCommitUtc: $sourceCommitUtc
-- Scope: Air Tasking -> accepted AAR vertical integration base.
-- This bundle does not mutate a .miz and does not auto-submit a MissionDemand.
-- CampaignState remains strategic resource authority.
-- Existing AAR controller remains area/profile/lifecycle authority.
-- Air Tasking adds stable ASR/ATM/EXE correlation only.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AT_AAR_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AT_AAR_InitialStock = (function()`n" + $content.InitialStock + "`nend)()`n"
$bundle += "local OMW_AT_AAR_AARStrategicStock = (function()`n" + $content.AARStrategicStock + "`nend)()`n"
$bundle += "local OMW_AT_AAR_CampaignStateInitializer = (function()`n" + $content.CampaignStateInitializer + "`nend)()`n"
$bundle += "local OMW_AT_AAR_BaseAdapter = (function()`n" + $content.BaseAdapter + "`nend)()`n"
$bundle += "local OMW_AT_AAR_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AT_AAR_Controller = (function()`n" + $content.Controller + "`nend)()`n"
$bundle += "local OMW_AT_AAR_AARBootstrap = (function()`n" + $content.AARBootstrap + "`nend)()`n"
$bundle += "local OMW_AT_AAR_Bridge = (function()`n" + $content.AirTaskingBridge + "`nend)()`n"
$bundle += "local OMW_AT_AAR_Bootstrap = (function()`n" + $content.AirTaskingBootstrap + "`nend)()`n"
$bundle += @"
OMW = OMW or {}
OMW.AirTasking = OMW.AirTasking or {}
OMW.AirTasking.AARVerticalBase = {
  SchemaVersion = "$builderVersion",
  MOOSECommit = "$mooseCommit",
  MooseLuaSHA256 = "$mooseSha256",
}

function OMW.AirTasking.AARVerticalBase.Start(spec)
  spec = spec or {}
  if type(spec.nextExecutionId) ~= "function" then
    error("[OMW][AirTasking.AARVerticalBase] nextExecutionId function is required", 2)
  end

  return OMW_AT_AAR_Bootstrap.Start({
    campaignState = OMW_AT_AAR_CampaignState,
    initialStock = OMW_AT_AAR_InitialStock,
    aarStrategicStock = OMW_AT_AAR_AARStrategicStock,
    campaignStateInitializer = OMW_AT_AAR_CampaignStateInitializer,
    campaignContext = spec.campaignContext,
    baseAdapterModule = OMW_AT_AAR_BaseAdapter,
    runtimeIntegration = OMW_AT_AAR_RuntimeIntegration,
    controller = OMW_AT_AAR_Controller,
    aarBootstrap = OMW_AT_AAR_AARBootstrap,
    bridgeModule = OMW_AT_AAR_Bridge,
    nextExecutionId = spec.nextExecutionId,
    logger = spec.logger,
  })
end
"@

foreach ($pattern in $forbiddenPatterns) {
  if ($bundle -match $pattern) {
    throw "Generated Air Tasking AAR vertical base contains forbidden marker: $pattern"
  }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'DeterministicBundleForCommit: true'
Write-Host 'Scope: AIR_TASKING_AAR_VERTICAL_BASE'
Write-Host 'MizMutation: false'
Write-Host 'AutoSubmitMissionDemand: false'
Write-Host 'CampaignStateAuthority: true'
Write-Host 'ExistingAARControllerAuthority: true'
Write-Host 'AirTaskingCorrelationOnly: true'
Write-Host 'StableExecutionIdProviderRequired: true'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}

$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"
