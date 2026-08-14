[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$controllerFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
$testFile = Join-Path $repoRoot 'mission\tests\aar-production-integration\src\01-aar-production-integration.lua'
$distDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Production_Integration.lua'

$builderVersion = 'AAR-PRODUCTION-INTEGRATION-1'
$testId = 'AAR-PRODUCTION-INTEGRATION-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($file in @($controllerFile, $testFile)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required AAR production integration source not found: $file"
  }
}

$controller = Get-Content -LiteralPath $controllerFile -Raw -Encoding UTF8
$test = Get-Content -LiteralPath $testFile -Raw -Encoding UTF8

$requiredControllerMarkers = @(
  'OMW_AAR_KC135_PATTY',
  'OMW_AAR_KC135_KRUSTY',
  'SOURCE_SPAWN_INTERVAL_SEC = 60',
  'AUFTRAG:NewTANKER(',
  'mission:SetMissionIngressCoord(',
  'mission:SetMissionEgressCoord(',
  'flightGroup:SetFuelLowRTB(false)',
  'flightGroup:SetFuelLowThreshold(areaSpec.fuelLowPct)',
  'function flightGroup:OnAfterFuelLow',
  'mission:Cancel()',
  'runtime.flightGroup:Despawn(1, true)',
  'SCHEDULER:New(',
  'function Controller.SelectArea',
  'function Controller.SubmitDemand',
  'function Controller.SetStrategicAdapter'
)
foreach ($marker in $requiredControllerMarkers) {
  if (-not $controller.Contains($marker)) {
    throw "AAR controller is missing required marker: $marker"
  }
}

$requiredTestMarkers = @(
  'AAR-PRODUCTION-INTEGRATION-1',
  'AAR-TEST-NELSON',
  'AAR-TEST-KRUSTY',
  'AAR-TEST-PATTY',
  'AAR-TEST-MILHOUSE',
  'AAR-TEST-MOE',
  'AAR-TEST-LISA',
  'POLICY_PASS',
  'EXECUTING_PASS',
  'INTEGRATION_PASS',
  'artificialFuelLow=false'
)
foreach ($marker in $requiredTestMarkers) {
  if (-not $test.Contains($marker)) {
    throw "AAR integration test is missing required marker: $marker"
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
  'ACCELERATED_FUEL_LOW',
  '99'
)
foreach ($pattern in $forbiddenPatterns) {
  if (($controller -match $pattern) -or ($test -match $pattern)) {
    throw "AAR production integration source contains forbidden pattern: $pattern"
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
-- Builder: tools/build-aar-production-integration.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: MissionDemand -> six operational AAR areas -> MOOSE tanker materialization and mission execution.
-- Existing accepted seed templates only: OMW_AAR_KC135_PATTY (MANAS 96%), OMW_AAR_KC135_KRUSTY (AL UDEID 90%).
-- Source-domain materialization spacing: minimum 60 seconds; MANAS and AL UDEID may materialize concurrently.
-- Production FuelLow thresholds are retained; no artificial/accelerated FuelLow trigger is used.
-- No Mission Editor template addition and no automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header + "local __omwAarControllerLoader = function()`n" + $controller + "`nend`n__omwAarControllerLoader()`n" + $test
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
$controllerHash = (Get-FileHash -LiteralPath $controllerFile -Algorithm SHA256).Hash.ToLowerInvariant()
$testHash = (Get-FileHash -LiteralPath $testFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "ProductionController: scripts/air-operations/OMW_AAR_Controller.lua"
Write-Host "ControllerSHA256: $controllerHash"
Write-Host "TestSourceSHA256: $testHash"
Write-Host "BundleSHA256: $hash"
Write-Host "SourceSpawnIntervalSec: 60"
Write-Host "ArtificialFuelLow: false"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
