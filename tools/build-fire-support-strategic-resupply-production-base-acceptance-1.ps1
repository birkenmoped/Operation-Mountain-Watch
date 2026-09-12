[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$productionBuilder = Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$productionBundle = Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$acceptanceSource = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\01-production-base-six-site-guard-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist'
$outputFile = Join-Path $distDir 'OMW_FireSupStratResupply_Production_Base_Acceptance_1.lua'
$builderVersion = 'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1-1'

foreach ($file in @($productionBuilder, $acceptanceSource)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Acceptance 1 input not found: $file"
  }
}

& $productionBuilder

if (-not (Test-Path -LiteralPath $productionBundle -PathType Leaf)) {
  throw "Production Base builder did not create expected bundle: $productionBundle"
}

$productionSource = Get-Content -LiteralPath $productionBundle -Raw -Encoding UTF8
$acceptance = Get-Content -LiteralPath $acceptanceSource -Raw -Encoding UTF8

$requiredProductionMarkers = @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-5',
  'OMW.FireSupStratResupply = Package',
  'OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED = 1'
)
foreach ($marker in $requiredProductionMarkers) {
  if (-not $productionSource.Contains($marker)) {
    throw "Production Base bundle is missing required marker: $marker"
  }
}

$requiredAcceptanceMarkers = @(
  'FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1',
  'package.New({',
  'resolveGuardPathline',
  'resolveGuardTemplateGroup',
  'resolveQrfCoordinate',
  '6/6 production-package Guards recruited, routed and >=25 m movement observed'
)
foreach ($marker in $requiredAcceptanceMarkers) {
  if (-not $acceptance.Contains($marker)) {
    throw "Acceptance source is missing required marker: $marker"
  }
}

$forbiddenAcceptancePatterns = @(
  'ZON_BLUE_GND_[A-Z_]+_ACCESS',
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  'os\.execute'
)
foreach ($pattern in $forbiddenAcceptancePatterns) {
  if ($acceptance -match $pattern) {
    throw "Acceptance source contains forbidden pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Production Base Acceptance 1 build.'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fire-support-strategic-resupply-production-base-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1
-- Scope: generated production Base package plus six-site Guard runtime regression only.
-- QRF/ARTY/CAS/resupply: not exercised; no tactical geometry invented.
-- MOOSE release: 2.9.18
-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
-- MIZ mutation: false

"@

$bundle = $header + $productionSource + "`n`n" + $acceptance
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

$builderHash = (Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant()
$productionBuilderHash = (Get-FileHash -LiteralPath $productionBuilder -Algorithm SHA256).Hash.ToUpperInvariant()
$productionBundleHash = (Get-FileHash -LiteralPath $productionBundle -Algorithm SHA256).Hash.ToUpperInvariant()
$acceptanceSourceHash = (Get-FileHash -LiteralPath $acceptanceSource -Algorithm SHA256).Hash.ToUpperInvariant()
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $productionBuilderHash"
Write-Host "ProductionBundleSHA256: $productionBundleHash"
Write-Host "AcceptanceSourceSHA256: $acceptanceSourceHash"
Write-Host "AcceptanceBuilderSHA256: $builderHash"
Write-Host "AcceptanceBundleSHA256: $bundleHash"
Write-Host "MOOSERelease: 2.9.18"
Write-Host "MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
Write-Host "MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
Write-Host "AcceptanceScope: production package composition plus six-site Guard runtime regression"
Write-Host "ExternalSupportExercised: false"
Write-Host "ResupplyExercised: false"
Write-Host "PerimeterExercised: false"
Write-Host "NewGuardException: false"
Write-Host "MizMutation: false"
