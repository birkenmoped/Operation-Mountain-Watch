[CmdletBinding()]
param()

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$productionBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$productionBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$acceptanceSource=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\02-production-base-honaker-incident-qrf-acceptance.lua'
$outputFile=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_2.lua'
$builderVersion='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2-2'

foreach($file in @($productionBuilder,$acceptanceSource)) {
  if(-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required file not found: $file" }
}

& $productionBuilder
if($LASTEXITCODE -ne 0) { throw "Production Base builder failed with exit code $LASTEXITCODE" }
if(-not (Test-Path -LiteralPath $productionBundle -PathType Leaf)) { throw "Production Base bundle not produced: $productionBundle" }

$productionSource=Get-Content -LiteralPath $productionBundle -Raw -Encoding UTF8
$testSource=Get-Content -LiteralPath $acceptanceSource -Raw -Encoding UTF8
foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-7',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-2',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-2',
  'guardRequiredAttributes',
  'qrfRequiredAttributes',
  'SetRequiredAttribute',
  'GROUP.Attribute.GROUND_INFANTRY',
  'GROUP.Attribute.GROUND_APC',
  'BLUE_GROUND_COP_HONAKER_MIRACLE',
  'TPL_BLUE_GND_QRF_MIXED_6',
  'BadGuys1',
  'INCIDENT_REFRESH_CREATED_DUPLICATE_DEMAND'
)) {
  if(-not (($productionSource + "`n" + $testSource).Contains($marker))) { throw "Acceptance 2 contract marker missing: $marker" }
}
if($testSource -match 'ZON_BLUE_GND_[A-Z_]+_ACCESS') { throw 'Acceptance 2 must not use convoy ACCESS zones for Guard, QRF, or alarm behavior.' }

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
if([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$header=@"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fire-support-strategic-resupply-production-base-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2
-- GitCommit: $commit
-- MOOSE release: 2.9.18
-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
-- Scope: six-site Guard regression + production installation incident + MOOSE-selected local QRF + incident refresh dedupe.
-- Guard recruitment need: Ground_Infantry via MOOSE AUFTRAG filter.
-- QRF recruitment need: Ground_APC via MOOSE AUFTRAG filter.
-- Physical detection: not validated; evidence is injected by this acceptance at the live BadGuys1 coordinate.
-- MIZ mutation: false

"@
$bundle=$header + $productionSource + "`n`n" + $testSource
New-Item -ItemType Directory -Path (Split-Path -Parent $outputFile) -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile,$bundle,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $productionBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $productionBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $acceptanceSource -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "MOOSERelease: 2.9.18"
Write-Host "MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
Write-Host "MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
Write-Host "IncidentEvidenceSource: acceptance fixture at live BadGuys1 coordinate"
Write-Host "GuardRecruitmentConstraint: MOOSE SetRequiredAttribute Ground_Infantry"
Write-Host "QRFRecruitmentConstraint: MOOSE SetRequiredAttribute Ground_APC"
Write-Host "AccessZoneDependency: none"
Write-Host "MizMutation: false"
