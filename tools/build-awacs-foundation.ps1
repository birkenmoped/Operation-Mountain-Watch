[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot 'mission\runtime\air-operations'
$outputFile = Join-Path $distDir 'OMW_AWACS_Foundation.lua'

$builderVersion = 'OMW-AIROPS-AWACS-FOUNDATION-11'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  InitialStock = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
  OffMapStrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  CampaignStateInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_CampaignStateAdapter.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_Controller_FullLifecycle_V3.lua'
  MoeRelief = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_MOE_Relief.lua'
  Bootstrap = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_AWACS_Bootstrap.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AWACS foundation source not found: $($entry.Value)"
  }
}

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requiredMarkers = @(
  @{ File = 'OffMapStrategicStock'; Marker = 'OFFMAP_AL_DHAFRA' },
  @{ File = 'OffMapStrategicStock'; Marker = 'AIRCRAFT_E3A_AWACS' },
  @{ File = 'Adapter'; Marker = 'AWACS-E3A-COMMIT:' },
  @{ File = 'Controller'; Marker = 'OMW_C2_E3A_WIZARD' },
  @{ File = 'Controller'; Marker = 'FIR_FIX_NAME = "ROSIE"' },
  @{ File = 'Controller'; Marker = 'AREA_NAME = "APOC"' },
  @{ File = 'Controller'; Marker = 'FREQUENCY_MHZ = 357.300' },
  @{ File = 'Controller'; Marker = 'TRANSIT_ALTITUDE_FT = 35000' },
  @{ File = 'Controller'; Marker = 'TRANSIT_IAS_KT = 270' },
  @{ File = 'Controller'; Marker = 'TRACK_ALTITUDE_FT = 32000' },
  @{ File = 'Controller'; Marker = 'TRACK_SPEED_KIAS = 250' },
  @{ File = 'Controller'; Marker = 'LISA_RENDEZVOUS = { lat = 33.6233926368, lon = 68.6395554105 }' },
  @{ File = 'Controller'; Marker = 'LISA_TRACK_ALTITUDE_FT = 25000' },
  @{ File = 'Controller'; Marker = 'LISA_TRACK_SPEED_KIAS = 270' },
  @{ File = 'Controller'; Marker = 'LISA_READY_ON_RENDEZVOUS' },
  @{ File = 'Controller'; Marker = 'LISA_EGRESS_DEFERRED' },
  @{ File = 'Controller'; Marker = 'runtime.flightGroup:Refuel(coordinate)' },
  @{ File = 'MoeRelief'; Marker = 'OMW_AAR_KC135_MOE' },
  @{ File = 'MoeRelief'; Marker = '33.6233926368' },
  @{ File = 'MoeRelief'; Marker = '68.6395554105' },
  @{ File = 'MoeRelief'; Marker = 'SECOND_CYCLE_ARMED' },
  @{ File = 'MoeRelief'; Marker = 'MOE_READY' },
  @{ File = 'MoeRelief'; Marker = 'controller.RequestRefuel' },
  @{ File = 'MoeRelief'; Marker = 'AUFTRAG:NewTANKER' },
  @{ File = 'Bootstrap'; Marker = 'AWACS_FULL_FUEL_DRIVEN_AAR_FOUNDATION' }
)

foreach ($requirement in $requiredMarkers) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AWACS foundation marker in $($requirement.File): $($requirement.Marker)"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  'UNIT:Explode',
  'AUFTRAG:NewAWACS\(',
  'EnRouteTaskAWACS\(',
  'SetFuelLowRefuel\(true\)',
  'ClearWaypoints\('
)

foreach ($entry in $content.GetEnumerator()) {
  if ($entry.Key -in @('Controller','MoeRelief','Bootstrap')) {
    foreach ($pattern in $forbiddenPatterns) {
      if ($entry.Value -match $pattern) {
        throw "Forbidden native/live-retask marker in AWACS foundation $($entry.Key): $pattern"
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
-- Builder: tools/build-awacs-foundation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceCommitUtc: $sourceCommitUtc
-- Scope: OMW external E-3 AWACS full fuel-driven lifecycle foundation.
-- Proven runtime base: OMW_AWACS_Controller_FullLifecycle_V3.lua from the last working AWACS/LISA flow.
-- Strategic source: OFFMAP_AL_DHAFRA.
-- WIZARD route: external materialization FL350 -> ROSIE -> APOC FL320 / 250 KIAS.
-- First planned AAR: unchanged V3 LISA flow on AWACS_APOC 33.6233926368N 68.6395554105E / FL250 / 270 KIAS / 340T / 20 NM.
-- Second planned AAR: MOE relief only, using the exact same AWACS_APOC tanker geometry; no live route retask.
-- MOE source identity: MANAS / PINAX / OMW_AAR_KC135_MOE / Texaco 4.
-- WIZARD receiver task remains Controller.RequestRefuel() -> MOOSE FLIGHTGROUP:Refuel().
-- No production-AAR track override and no ClearWaypoints surgery.
-- Fuel policy remains 65 percent planned pre-dispatch, 40 percent fallback, 25 percent contingency.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AWACS_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AWACS_InitialStock = (function()`n" + $content.InitialStock + "`nend)()`n"
$bundle += "local OMW_AWACS_OffMapStrategicStock = (function()`n" + $content.OffMapStrategicStock + "`nend)()`n"
$bundle += "local OMW_AWACS_CampaignStateInitializer = (function()`n" + $content.CampaignStateInitializer + "`nend)()`n"
$bundle += "local OMW_AWACS_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AWACS_Controller = (function()`n" + $content.Controller + "`nend)()`n"
$bundle += "local OMW_AWACS_MoeRelief = (function()`n" + $content.MoeRelief + "`nend)()`n"
$bundle += "local OMW_AWACS_Bootstrap = (function()`n" + $content.Bootstrap + "`nend)()`n"
$bundle += @"
OMW_AWACS_Bootstrap.Start({
  campaignState = OMW_AWACS_CampaignState,
  initialStock = OMW_AWACS_InitialStock,
  offMapStrategicStock = OMW_AWACS_OffMapStrategicStock,
  campaignStateInitializer = OMW_AWACS_CampaignStateInitializer,
  adapterModule = OMW_AWACS_Adapter,
  controller = OMW_AWACS_Controller,
})
OMW_AWACS_MoeRelief.Start(OMW_AWACS_Controller)
"@

foreach ($pattern in $forbiddenPatterns) {
  if ($bundle -match $pattern) {
    throw "Generated AWACS foundation contains forbidden marker: $pattern"
  }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

$bytes = [System.IO.File]::ReadAllBytes($outputFile)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
  throw 'Generated AWACS foundation unexpectedly contains a UTF-8 BOM.'
}

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'Scope: AWACS_FULL_FUEL_DRIVEN_AAR_FOUNDATION'
Write-Host 'ControllerRevision: V3_PROVEN_BASE_PLUS_MINIMAL_MOE_RELIEF'
Write-Host 'Template: OMW_C2_E3A_WIZARD'
Write-Host 'TransitTargetIASKt: 270'
Write-Host 'TrackAltitudeFt: 32000'
Write-Host 'TrackSpeedKIAS: 250'
Write-Host 'PlannedAAR1: LISA'
Write-Host 'PlannedAAR2: MOE'
Write-Host 'DedicatedAARTrackLat: 33.6233926368'
Write-Host 'DedicatedAARTrackLon: 68.6395554105'
Write-Host 'DedicatedAARTrackAltitudeFt: 25000'
Write-Host 'DedicatedAARTrackSpeedKIAS: 270'
Write-Host 'DedicatedAARTrackHeadingTrueDeg: 340'
Write-Host 'DedicatedAARTrackLegNm: 20'
Write-Host 'MoeSource: MANAS'
Write-Host 'MoeFIRFix: PINAX'
Write-Host 'MoeFuelLowPct: 31'
Write-Host 'LiveTrackRetask: false'
Write-Host 'ClearWaypointsUsed: false'
Write-Host 'AARTriggerFuelPct: 40'
Write-Host 'AARCriticalFuelPct: 25'
Write-Host 'FuelLowRTB: false'
Write-Host 'FuelLowRefuelBuiltIn: false'
Write-Host 'DCSValidatedFullLifecycle: false'
Write-Host 'Utf8Bom: false'
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
