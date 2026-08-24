[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\src\04-awacs-full-fuel-aar-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\dist'
$output = Join-Path $distDir 'OMW_AWACS_Acceptance_4.lua'
$builderVersion = 'OMW-AWACS-ACCEPTANCE-4-4'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
  throw "Acceptance 4 source not found: $source"
}

$content = Get-Content -LiteralPath $source -Raw -Encoding UTF8
$required = @(
  'AWACS.Acceptance4',
  'GetFuelMin()',
  'GetAirspeedIndicated()',
  'LISA_READY_OBSERVED',
  'AAR_PHASE',
  'TELEMETRY',
  'CONFIG transitAltFt=',
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
  ':Refuel\(',
  ':AddWaypoint\(',
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
-- Scope: final reconciled full fuel-driven WIZARD lifecycle observer.
-- Expected visible WIZARD normal transit: FL350 / 270 KIAS target.
-- Expected APOC racetrack: FL320 / 250 KIAS.
-- LISA pre-dispatch threshold: 65 percent WIZARD fuel.
-- LISA ready contract: dedicated tanker established at FL250 / 270 KIAS initiates WIZARD AAR without waiting for 40 percent.
-- Dedicated-LISA WIZARD rendezvous target: FL250 / 290 KIAS before the MOOSE Refuel task.
-- Final join/contact speed is controlled by the DCS refuelling task and observed, not overridden by the acceptance.
-- Fallback AAR trigger: 40 percent WIZARD fuel if LISA has not established the planned AAR path.
-- Critical visible off-map contingency: 25 percent WIZARD fuel if no established refuel path exists.
-- LISA FuelLow egress must be deferred while WIZARD is actively refuelling from LISA.
-- MOOSE FuelLow RTB: disabled; nearest compatible tanker fallback is required.
-- Acceptance observer does not spawn, route or refuel aircraft.
-- GitCommit: $commit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- SourceSHA256: $sourceHash

"@

[System.IO.File]::WriteAllText($output, $header + $content, [System.Text.UTF8Encoding]::new($false))
$bytes = [System.IO.File]::ReadAllBytes($output)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
  throw 'Generated Acceptance 4 bundle unexpectedly contains a UTF-8 BOM.'
}
$bundleHash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $output"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'TestId: AWACS-FULL-FUEL-AAR-ACCEPTANCE-4'
Write-Host 'Scope: AWACS_FULL_FUEL_DRIVEN_AAR_ACCEPTANCE'
Write-Host 'SampleIntervalSec: 30'
Write-Host 'ExpectedTransitAltitudeFt: 35000'
Write-Host 'ExpectedTransitTargetIASKt: 270'
Write-Host 'ExpectedTrackAltitudeFt: 32000'
Write-Host 'ExpectedTrackTargetIASKt: 250'
Write-Host 'ExpectedSpawnFuelPct: 77'
Write-Host 'LisaPredispatchFuelPct: 65'
Write-Host 'LisaTrackAltitudeFt: 25000'
Write-Host 'LisaTrackTargetIASKt: 270'
Write-Host 'WizardAARRendezvousAltitudeFt: 25000'
Write-Host 'WizardAARRendezvousTargetIASKt: 290'
Write-Host 'FinalContactSpeedDCSControlled: true'
Write-Host 'LisaReadyImmediateAAR: true'
Write-Host 'LisaFuelLowEgressDeferredDuringActiveAAR: true'
Write-Host 'AARTriggerFuelPct: 40'
Write-Host 'AARTriggerRole: FALLBACK'
Write-Host 'AARCriticalFuelPct: 25'
Write-Host 'FuelLowRTB: false'
Write-Host 'AutomaticNearestTankerFallback: true'
Write-Host 'ObserverOnly: true'
Write-Host 'TelemetryAltitudeUnit: FEET'
Write-Host 'TelemetryIncludesIAS: true'
Write-Host 'Utf8Bom: false'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "BundleSHA256: $bundleHash"
