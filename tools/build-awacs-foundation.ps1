[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot 'mission\runtime\air-operations'
$outputFile = Join-Path $distDir 'OMW_AWACS_Foundation.lua'

$builderVersion = 'OMW-AIROPS-AWACS-FOUNDATION-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  InitialStock = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
  OffMapStrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  CampaignStateInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_CampaignStateAdapter.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_Controller.lua'
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
  @{ File = 'Controller'; Marker = 'AUFTRAG:NewAWACS' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionAltitude(TRACK_ALTITUDE_FT)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionEgressCoord' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterPassingWaypoint' },
  @{ File = 'Controller'; Marker = 'AWACS_AAR_DCS_ACCEPTANCE_REQUIRED' },
  @{ File = 'Bootstrap'; Marker = 'AWACS_EXTERNAL_LIFECYCLE_FOUNDATION' }
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
  'SetFuelLowRefuel\(true\)'
)

foreach ($entry in $content.GetEnumerator()) {
  if ($entry.Key -in @('Controller','Bootstrap')) {
    foreach ($pattern in $forbiddenPatterns) {
      if ($entry.Value -match $pattern) {
        throw "Forbidden native/test marker in AWACS foundation $($entry.Key): $pattern"
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
-- Scope: OMW external E-3 AWACS lifecycle foundation.
-- Strategic source: OFFMAP_AL_DHAFRA.
-- Route: external materialization -> ROSIE -> 30 NM late approach -> APOC.
-- Station: WIZARD, 357.300 MHz AM, APOC, FL320, 300 KT, 017T, 30 NM leg.
-- Egress: APOC -> ROSIE -> external handoff/despawn.
-- Scheduled relief: one ACTIVE plus at most one RELIEF; handover only on physical track arrival.
-- AAR dispatch: source-reviewed but intentionally acceptance-gated; no automatic nearest-tanker dispatch.
-- DCS validation: NOT YET PERFORMED for this AWACS foundation.
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
"@

foreach ($pattern in $forbiddenPatterns) {
  if ($bundle -match $pattern) {
    throw "Generated AWACS foundation contains forbidden marker: $pattern"
  }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'Scope: AWACS_EXTERNAL_LIFECYCLE_FOUNDATION'
Write-Host 'Template: OMW_C2_E3A_WIZARD'
Write-Host 'StrategicSource: OFFMAP_AL_DHAFRA'
Write-Host 'FIRFix: ROSIE'
Write-Host 'PrimaryArea: APOC'
Write-Host 'Callsign: WIZARD'
Write-Host 'FrequencyMHzAM: 357.300'
Write-Host 'TrackAltitudeFt: 32000'
Write-Host 'TrackSpeedKt: 300'
Write-Host 'TrackHeadingTrueDeg: 17'
Write-Host 'TrackLegNm: 30'
Write-Host 'LateApproachNm: 30'
Write-Host 'StationCycleSec: 21600'
Write-Host 'MaxPhysicalAircraft: 2'
Write-Host 'AutomaticRefuelDispatch: false'
Write-Host 'DCSValidated: false'
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
