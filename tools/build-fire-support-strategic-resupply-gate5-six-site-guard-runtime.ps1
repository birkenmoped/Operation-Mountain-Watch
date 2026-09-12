[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$siteRegistry = Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_SiteRegistry.lua'
$materializer = Join-Path $repoRoot 'scripts\ground\OMW_GuardPathlineMaterializationAdapter.lua'
$patrolAdapter = Join-Path $repoRoot 'scripts\ground\OMW_GuardPathlinePatrolAdapter.lua'
$sourceFile = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5-six-site-guard-runtime\src\03-six-site-guard-production-materializer-acceptance.lua'
$outputFile = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5-six-site-guard-runtime\dist\OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua'
$builderVersion = 'FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-6'
$testId = 'FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'

foreach ($required in @($siteRegistry, $materializer, $patrolAdapter, $sourceFile)) {
  if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Required Gate-5 source not found: $required" }
}

$registrySource = Get-Content -LiteralPath $siteRegistry -Raw -Encoding UTF8
$materializerSource = Get-Content -LiteralPath $materializer -Raw -Encoding UTF8
$patrolSource = Get-Content -LiteralPath $patrolAdapter -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

foreach ($marker in @(
  'OMW-GUARD-PATHLINE-PATROL-ADAPTER-1',
  'CONTROLLABLE.WayPointExecute',
  'PATHLINE_FIRST_POINT',
  'closed PATHLINE patrol'
)) {
  if (-not ($patrolSource.Contains($marker) -or $acceptanceSource.Contains($marker))) {
    throw "Gate-5 continuous Guard patrol source missing required marker: $marker"
  }
}

foreach ($forbiddenMarker in @(
  'ZONE:FindByName(site.accessZoneName)',
  'SetSpawnZone(access)',
  'ACCESS_CENTER',
  'IsVec2InZone('
)) {
  if ($materializerSource.Contains($forbiddenMarker) -or $patrolSource.Contains($forbiddenMarker) -or $acceptanceSource.Contains($forbiddenMarker)) {
    throw "Gate-5 Guard runtime must not depend on convoy ACCESS zones: $forbiddenMarker"
  }
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }

$bundle = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n"
$bundle += "-- BuilderVersion: $builderVersion`n"
$bundle += "-- GitCommit: $commit`n"
$bundle += "-- TestId: $testId`n"
$bundle += "-- MOOSECommit: $mooseCommit`n"
$bundle += "-- MooseLuaSHA256: $mooseSha256`n"
$bundle += "-- GuardPatrol: explicit closed PATHLINE + public MOOSE WayPointExecute loop`n"
$bundle += "-- MizMutation: false`n`n"
$bundle += "local OMW_GATE5_SITE_REGISTRY = (function()`n$registrySource`nend)()`n`n"
$bundle += "local OMW_GUARD_PATHLINE_MATERIALIZATION_ADAPTER = (function()`n$materializerSource`nend)()`n`n"
$bundle += "local OMW_GUARD_PATHLINE_PATROL_ADAPTER = (function()`n$patrolSource`nend)()`n`n"
$bundle += $acceptanceSource

New-Item -ItemType Directory -Path (Split-Path -Parent $outputFile) -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile, $bundle, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "BuilderVersion: $builderVersion"
Write-Host "GitCommit: $commit"
Write-Host "TestId: $testId"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "Moose.lua SHA-256: $mooseSha256"
Write-Host "GuardPatrol: CLOSED_PATHLINE_MOOSE_WAYPOINT_EXECUTE"
Write-Host "GuardAccessZoneDependency: none"
Write-Host "Output: $outputFile"
Write-Host "Bundle SHA-256: $((Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash)"
Write-Host "Materializer SHA-256: $((Get-FileHash -LiteralPath $materializer -Algorithm SHA256).Hash)"
Write-Host "Patrol adapter SHA-256: $((Get-FileHash -LiteralPath $patrolAdapter -Algorithm SHA256).Hash)"
Write-Host "Acceptance source SHA-256: $((Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash)"
Write-Host "MIZ mutation: false"
