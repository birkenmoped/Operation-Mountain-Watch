[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$stage3Builder = Join-Path $repoRoot 'tools\build-stage3-honaker-wright-full-response-acceptance-1.ps1'
$stage3Bundle = Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua'
$preflight = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate4-stage3-regression\src\01-gate4-stage3-regression-preflight.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate4-stage3-regression\dist'
$outputFile = Join-Path $distDir 'OMW_FireSupStratResupply_Gate4_Stage3_Regression.lua'

$modules = [ordered]@{
  OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_BASE = 'scripts\campaign\OMW_FireSupStratResupply_Base.lua'
  OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_LIFECYCLE = 'scripts\campaign\OMW_FireSupStratResupply_LifecycleAdapter.lua'
  OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_SITES = 'scripts\campaign\OMW_FireSupStratResupply_SiteRegistry.lua'
  OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_PROFILES = 'scripts\campaign\OMW_FireSupStratResupply_SupportProfiles.lua'
  OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_IDS = 'scripts\campaign\OMW_FireSupStratResupply_IdContract.lua'
}

$builderVersion = 'FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE4-STAGE3-REGRESSION-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'
$referenceMizSha256 = '25387ABB697E9D500F243EF5D2220459EC6AA711712DB57F126DDF7C7D47E0FA'
$referenceStage3BundleSha256 = '33CEB7AA6BC7FA833CCF456C41B689245B0CB70BD587AF533D0071A92B346661'

if (-not (Test-Path -LiteralPath $stage3Builder -PathType Leaf)) { throw "Stage-3 builder not found: $stage3Builder" }
if (-not (Test-Path -LiteralPath $preflight -PathType Leaf)) { throw "Gate-4 preflight not found: $preflight" }

& $stage3Builder
if ($LASTEXITCODE -ne 0) { throw "Stage-3 builder failed with exit code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $stage3Bundle -PathType Leaf)) { throw "Stage-3 bundle not found: $stage3Bundle" }

$stage3Source = Get-Content -LiteralPath $stage3Bundle -Raw -Encoding UTF8
foreach ($marker in @(
  'BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-26',
  'MooseLuaSHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915',
  'local GUARD_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"',
  'local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"',
  'local WRIGHT_BATTERY = "TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2"',
  'local CAS_NO_CONTACT_STABLE_SEC = 30',
  'OPSTRANSPORT:New(nil,state.pickup,state.drop)'
)) {
  if (-not $stage3Source.Contains($marker)) { throw "Stage-3 reference bundle missing regression marker: $marker" }
}

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fire-support-strategic-resupply-gate4-stage3-regression.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- ReferenceMizSHA256: $referenceMizSha256
-- ReferenceStage3BundleSHA256: $referenceStage3BundleSha256
-- Scope: site-persistent Guard + incident-scoped QRF/C2 support + threshold-driven Resupply contract preflight followed by the unchanged Stage-3 Honaker/Wright runtime fixture.
-- MizMutation: false.

"@

$bundle = $header
foreach ($name in $modules.Keys) {
  $path = Join-Path $repoRoot $modules[$name]
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required Gate-4 source not found: $path" }
  $source = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $bundle += Embed-Module $name $source
}

$preflightSource = Get-Content -LiteralPath $preflight -Raw -Encoding UTF8
$bundle += $preflightSource + "`n`n"
$bundle += $stage3Source

foreach ($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-3',
  'function Instance:StartSite',
  'function Instance:RequestIncidentSupport',
  'function Instance:RequestResupply',
  'SUPPORT_NOT_INCIDENT_SCOPED',
  'PREFLIGHT_PASS',
  'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-26'
)) {
  if (-not $bundle.Contains($marker)) { throw "Gate-4 bundle missing marker: $marker" }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
Set-Content -LiteralPath $outputFile -Value $bundle -Encoding UTF8
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash

Write-Host "BuilderVersion: $builderVersion"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "Moose.lua SHA-256: $mooseSha256"
Write-Host "Reference MIZ SHA-256: $referenceMizSha256"
Write-Host "Reference Stage-3 bundle SHA-256: $referenceStage3BundleSha256"
Write-Host "Output: $outputFile"
Write-Host "Bundle SHA-256: $hash"
Write-Host 'MIZ mutation: false'
