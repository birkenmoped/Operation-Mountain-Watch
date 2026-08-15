[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-fuel-telemetry\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-fuel-telemetry\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Fuel_Telemetry.lua'

$builderVersion = 'AAR-FUEL-TELEMETRY-1'
$testId = 'AAR-FUEL-TELEMETRY-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  Initializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Harness = Join-Path $sourceDir '01-aar-fuel-telemetry.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AAR fuel-telemetry source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requirements = @(
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'function Controller.GetActive' },
  @{ File = 'Controller'; Marker = 'spawnToFirNm = spawnToFirNm' },
  @{ File = 'Controller'; Marker = 'firToTrackNm = firToTrackNm' },
  @{ File = 'Harness'; Marker = 'AAR-FUEL-TELEMETRY-1' },
  @{ File = 'Harness'; Marker = 'point=SPAWN' },
  @{ File = 'Harness'; Marker = 'fuelLowExcluded=true' },
  @{ File = 'Harness'; Marker = 'RESULT PASS allTracks=6' },
  @{ File = 'Harness'; Marker = 'unit:GetFuel()' },
  @{ File = 'Harness'; Marker = 'unit:GetCurrentFuelKgs()' },
  @{ File = 'Harness'; Marker = 'Get2DDistance' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AAR fuel-telemetry marker in $($requirement.File): $($requirement.Marker)"
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
  'runtime\.trackCoord\s*=',
  ':SetFuelLowThreshold\(',
  'fuelLowPct\s*='
)

foreach ($entry in $content.GetEnumerator()) {
  if ($entry.Key -eq 'Controller') { continue }
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in AAR fuel telemetry $($entry.Key): $pattern"
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
-- Builder: tools/build-aar-fuel-telemetry.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: read-only fuel telemetry for the first natural sortie to all six AAR tracks.
-- Samples: fuel at first observed spawn, FIR ingress radius, and track-entry radius.
-- FuelLow is intentionally excluded because the current threshold is itself subject to recalibration.
-- Four STANDARD tracks start through the production RuntimeIntegration; LISA and MOE are opened by explicit reserve demands.
-- The harness does not change production initial fuel values, FuelLow values, routes, track coordinates, relief timing or resource ownership.
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
$bundle += $content.Harness + "`n"

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host 'FuelPoints: SPAWN,INGRESS,TRACK'
Write-Host 'FuelLowIncluded: false'
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'PollSeconds: 1'
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
