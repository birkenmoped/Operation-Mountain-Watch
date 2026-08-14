[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\aar-kc135-runtime\src\01-aar-kc135-runtime-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\aar-kc135-runtime\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_KC135_Runtime_Acceptance.lua'

$builderVersion = 'AAR-KC135-RUNTIME-ACCEPTANCE-1'
$testId = 'AAR-KC135-RUNTIME-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required AAR acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'AAR-KC135-RUNTIME-ACCEPTANCE-1',
  'OMW_AAR_KC135_CLANCY',
  'OMW_AAR_KC135_HOMER',
  'OMW_AAR_KC135_NELSON',
  'SPAWN:New(spec.template)',
  'SpawnFromCoordinate(gateCoord)',
  'FLIGHTGROUP:New(group)',
  'AUFTRAG:NewTANKER(',
  'Unit.RefuelingSystem.BOOM_AND_RECEPTACLE',
  'mission:SetRadio(spec.frequencyMHz, 0)',
  'mission:SetTACAN(',
  'mission:SetMissionEgressCoord(',
  'flightGroup:SetFuelLowThreshold(',
  'flightGroup:SetFuelLowRTB(false)',
  'function flightGroup:OnAfterFuelLow',
  'mission:Cancel()',
  'STAGE_TRANSITION from=CLANCY to=HOMER',
  'SUPPORT_CONCURRENCY',
  'supportMissionLimit=2',
  'FUEL_LOW_PASS',
  'TANKER_EXECUTING_PASS',
  'HARNESS_READY'
)
foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "AAR acceptance source is missing required marker: $marker"
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
foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "AAR acceptance source contains forbidden pattern: $pattern"
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
-- Builder: tools/build-aar-kc135-runtime-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: staged KC-135 Boom tanker acceptance with max two concurrent support missions; template fuel preservation; AUFTRAG:TANKER; radio; TACAN; accelerated FuelLow; mission egress.
-- Initial concurrent templates: OMW_AAR_KC135_CLANCY, OMW_AAR_KC135_NELSON.
-- Staged template after CLANCY FuelLow: OMW_AAR_KC135_HOMER.
-- Prepared but inactive templates: OMW_AAR_KC135_KRUSTY, OMW_AAR_KC135_PATTY.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "InitialConcurrentTankers: CLANCY,NELSON"
Write-Host "StagedTanker: HOMER_AFTER_CLANCY_FUEL_LOW"
Write-Host "PreparedInactiveTankers: KRUSTY,PATTY"
Write-Host "MaxConcurrentSupportMissions: 2"
Write-Host "MaxConcurrentSupportAircraft: 4"
Write-Host "InitialFuelExpectedPct: CLANCY=90,HOMER=90,NELSON=96"
Write-Host "AcceleratedFuelLowPct: CLANCY=89,HOMER=89,NELSON=95"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
