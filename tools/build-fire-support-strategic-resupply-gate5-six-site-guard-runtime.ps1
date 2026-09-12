[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$siteRegistry = Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_SiteRegistry.lua'
$sourceFile = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5-six-site-guard-runtime\src\02-six-site-guard-compact-aligned-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5-six-site-guard-runtime\dist'
$outputFile = Join-Path $distDir 'OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua'

$builderVersion = 'FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-2'
$testId = 'FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'

foreach ($required in @($siteRegistry, $sourceFile)) {
  if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
    throw "Required Gate-5 source not found: $required"
  }
}

$registrySource = Get-Content -LiteralPath $siteRegistry -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

foreach ($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-4',
  'OMW_RTE_BLUE_GUARD_FENTY_01',
  'OMW_RTE_BLUE_GUARD_FORTRESS_01',
  'OMW_RTE_BLUE_GUARD_JOYCE_01',
  'OMW_RTE_BLUE_GUARD_WRIGHT_01',
  'OMW_RTE_BLUE_GUARD_HONAKER_01',
  'OMW_RTE_BLUE_GUARD_BOSTICK_01',
  'TPL_BLUE_GND_INF_RIFLE_SQUAD_9'
)) {
  if (-not $registrySource.Contains($marker)) {
    throw "Gate-5 SiteRegistry missing required marker: $marker"
  }
}

foreach ($marker in @(
  $testId,
  'BRIGADE:New(',
  'PLATOON:New(',
  'AUFTRAG:NewONGUARD(',
  'PATHLINE:FindByName(',
  'OptionFormationInterval(INTERVAL)',
  'COMPACT_SPAWN_PREPARED',
  'COMPACT_ALIGNED_WAREHOUSE_SPAWN',
  '_SpawnAssetGroundNaval',
  '_SpawnAssetPrepareTemplate',
  '_DATABASE:Spawn(t)',
  'TaskFunction("CONTROLLABLE.Route"',
  'SetTaskWaypoint(',
  's.group:Route(r,2)',
  '6/6 Guards compact/aligned'
)) {
  if (-not $acceptanceSource.Contains($marker)) {
    throw "Gate-5 acceptance source missing required marker: $marker"
  }
}

foreach ($pattern in @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  ':Teleport\s*\('
)) {
  if ($acceptanceSource -match $pattern) {
    throw "Gate-5 acceptance source contains forbidden pattern: $pattern"
  }
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD.'
}

$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: six persistent Guards; compact PATHLINE-aligned materialization; Off Road route; 2 m formation interval; five-minute movement acceptance.
-- Extension: test-scoped reuse of the owner-approved ARMY Ground Acceptance 3-2 WAREHOUSE spawn-adapter pattern.
-- Exclusions: no QRF, no ARTY, no CAS, no resupply, no alarm/attack stimulus, no MIZ mutation.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- Encoding: UTF-8 without BOM.
-- MizMutation: false.

"@

$bundle = $header
$bundle += "local OMW_GATE5_SITE_REGISTRY = (function()`n$registrySource`nend)()`n`n"
$bundle += $acceptanceSource

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outputFile, $bundle, $utf8NoBom)

$bytes = [System.IO.File]::ReadAllBytes($outputFile)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
  throw 'Gate-5 output unexpectedly contains a UTF-8 BOM.'
}
if ($bytes.Length -eq 0) {
  throw 'Gate-5 output is empty.'
}

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash

Write-Host "BuilderVersion: $builderVersion"
Write-Host "GitCommit: $commit"
Write-Host "TestId: $testId"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "Moose.lua SHA-256: $mooseSha256"
Write-Host "Formation: Off Road"
Write-Host "FormationIntervalM: 2"
Write-Host "SpawnAlignment: PATHLINE_FIRST_SEGMENT"
Write-Host "Output: $outputFile"
Write-Host "Encoding: UTF-8 without BOM"
Write-Host "Bundle SHA-256: $hash"
Write-Host "MIZ mutation: false"
