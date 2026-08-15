[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Production_Final_Acceptance.lua'

$builderVersion = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-1'
$testId = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  Initializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Harness = Join-Path $sourceDir '02-aar-production-final-acceptance.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AAR final-acceptance source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requirements = @(
  @{ File = 'StrategicStock'; Marker = 'initial = 16' },
  @{ File = 'StrategicStock'; Marker = 'initial = 40' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnMaterialized' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnHandoff' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnLost' },
  @{ File = 'Adapter'; Marker = 'function Adapter:ReconcileRestore' },
  @{ File = 'RuntimeIntegration'; Marker = 'function Integration.Attach' },
  @{ File = 'Controller'; Marker = 'MAX_CONCURRENT_SUPPORT_MISSIONS = 2' },
  @{ File = 'Controller'; Marker = 'MAX_AIRCRAFT_PER_SUPPORT_MISSION = 2' },
  @{ File = 'Controller'; Marker = 'MAX_CONCURRENT_SUPPORT_AIRCRAFT = 4' },
  @{ File = 'Controller'; Marker = 'spawner:InitSTN(transitCallsign.stn)' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Harness'; Marker = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-1' },
  @{ File = 'Harness'; Marker = 'RESTORE_RECONCILIATION_PASS' },
  @{ File = 'Harness'; Marker = 'POOL_BASELINE_PASS' },
  @{ File = 'Harness'; Marker = 'SOURCE_INDEPENDENCE_PASS' },
  @{ File = 'Harness'; Marker = 'CONCURRENCY_2_2_4_PASS' },
  @{ File = 'Harness'; Marker = 'STATION_IDENTITY_PASS' },
  @{ File = 'Harness'; Marker = 'FUEL_LOW_RELIEF_PASS' },
  @{ File = 'Harness'; Marker = 'SCHEDULED_RELIEF_PASS' },
  @{ File = 'Harness'; Marker = 'unit:Explode(LOSS_EXPLOSION_POWER)' },
  @{ File = 'Harness'; Marker = 'AIRCRAFT_LOSS_PASS' },
  @{ File = 'Harness'; Marker = 'DEMAND_END_PASS' },
  @{ File = 'Harness'; Marker = 'FINAL_SETTLEMENT_PASS' },
  @{ File = 'Harness'; Marker = 'RESULT PASS' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AAR final-acceptance marker in $($requirement.File): $($requirement.Marker)"
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
  'os\.execute'
)

foreach ($entry in $content.GetEnumerator()) {
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in AAR final acceptance $($entry.Key): $pattern"
    }
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-aar-production-final-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: combined AAR production acceptance for CampaignState pools/accounting, 2/2/4 concurrency, transit/station identity, scheduled/FuelLow relief, demand end, handoff, loss and restore reconciliation.
-- Test acceleration: track-entry coordinates and scheduled-relief timestamps are controlled by the harness; no physical aircraft is teleported.
-- Loss injection: public MOOSE UNIT:Explode() is used only on the designated test tanker to exercise the real FLIGHTGROUP Dead/OnAfterDead path.
-- Restore: CampaignState snapshot/Restore is exercised in-process; this is not a physical DCS server restart.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AAR_TEST_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_StrategicStock = (function()`n" + $content.StrategicStock + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Initializer = (function()`n" + $content.Initializer + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Controller = (function()`n" + $content.Controller + "`nend)()`n"
$bundle += $content.Harness

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "ControlledTrackEntry: true"
Write-Host "ControlledReliefTiming: true"
Write-Host "PhysicalTeleport: false"
Write-Host "NaturalGateTransitRequired: false"
Write-Host "LossInjection: MOOSE UNIT:Explode"
Write-Host "RestoreMode: in-process CampaignState Snapshot/Restore"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"
