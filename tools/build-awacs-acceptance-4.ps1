[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\src\04-awacs-full-fuel-aar-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\dist'
$output = Join-Path $distDir 'OMW_AWACS_Acceptance_4.lua'
$builderVersion = 'OMW-AWACS-ACCEPTANCE-4-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
  throw "Acceptance 4 source not found: $source"
}

$content = Get-Content -LiteralPath $source -Raw -Encoding UTF8
$required = @(
  'AWACS.Acceptance4',
  'GetFuelMin()',
  'AAR_PHASE',
  'TELEMETRY',
  'observerOnly=true'
)
foreach ($marker in $required) {
  if (-not $content.Contains($marker)) {
    throw "Missing Acceptance 4 marker: $marker"
  }
}

$forbidden = @(
  'SPAWN:New',
  'AUFTRAG:New',
  ':Refuel(',
  ':AddWaypoint(',
  'MissionScripting\.lua',
  'mist\.',
  'io\.',
  'os\.execute'
)
foreach ($pattern in $forbidden) {
  if ($content -match $pattern) {
    throw "Acceptance 4 must remain observer-only; forbidden marker: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $output -PathType Leaf) {
  Remove-Item -LiteralPath $output -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-awacs-acceptance-4.ps1
-- BuilderVersion: $builderVersion
-- TestId: AWACS-FULL-FUEL-AAR-ACCEPTANCE-4
-- Scope: full fuel-driven WIZARD lifecycle observer.
-- Expected visible spawn: FL350 / 440 KT / approximately 77 percent template fuel.
-- LISA pre-dispatch threshold: 65 percent WIZARD fuel.
-- AAR trigger: 40 percent WIZARD fuel.
-- Critical off-map contingency: 25 percent WIZARD fuel if no established refuel path exists.
-- MOOSE FuelLow RTB: disabled; nearest compatible tanker fallback is required.
-- Acceptance observer does not spawn, route or refuel aircraft.
-- GitCommit: $commit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- SourceSHA256: $sourceHash

"@

[System.IO.File]::WriteAllText($output, $header + $content, [System.Text.UTF8Encoding]::new($false))
$bundleHash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $output"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'TestId: AWACS-FULL-FUEL-AAR-ACCEPTANCE-4'
Write-Host 'Scope: AWACS_FULL_FUEL_DRIVEN_AAR_ACCEPTANCE'
Write-Host 'SampleIntervalSec: 30'
Write-Host 'ExpectedSpawnAltitudeFt: 35000'
Write-Host 'ExpectedSpawnSpeedKt: 440'
Write-Host 'ExpectedSpawnFuelPct: 77'
Write-Host 'LisaPredispatchFuelPct: 65'
Write-Host 'AARTriggerFuelPct: 40'
Write-Host 'AARCriticalFuelPct: 25'
Write-Host 'FuelLowRTB: false'
Write-Host 'AutomaticNearestTankerFallback: true'
Write-Host 'ObserverOnly: true'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "BundleSHA256: $bundleHash"
