[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\09-production-cas-lifecycle-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_9.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-9-1'

foreach($f in @($prodBuilder,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$all=$p+[Environment]::NewLine+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-23',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-RELEASE-POLICY-1',
  'OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8',
  'OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1',
  'CAS_PROVIDER_PROFILE_BOUND',
  'CAS_OWNER_CORRIDOR_INSTALLED',
  'CAS_EXECUTING',
  'CAS_NO_CONTACT_REPORTED',
  'CAS_SUPPORTED_ELEMENT_CLEAR',
  'CAS_CONTROLLED_RELEASE',
  'CAS_HOME_LANDED',
  'CAS_LEGION_ASSET_RETURNED',
  'CAS_LIFECYCLE_COMPLETE',
  'SUPPORTED_ELEMENT_STABLE_NO_CONTACT',
  'stableNoContactSec=30',
  'FOB_JOYCE',
  'BadGuys_A3_JOYCE',
  'QRF_DIRECT_TARGET_ENGAGE')){
  if(-not $all.Contains($marker)){throw "Acceptance 9 marker missing: $marker"}
}

# Acceptance may configure and observe, but must not own the CAS lifecycle.
foreach($forbidden in @(
  'GetDetectedGroups(',
  'CasTacticalCorridor.Bind(',
  'HelicopterCorridor.ResolveSequence(',
  'OnAfterFuelLow',
  'OnAfterLanded',
  'OnAfterLegionAssetReturned',
  'mission:Cancel(',
  'Mission:Cancel(',
  'UpdateRoute(',
  'AddWaypoint(',
  'CAS_NO_CONTACT_STABLE_SEC',
  'noContactSince',
  'noContactReported=false')){
  if($t.Contains($forbidden)){throw "Acceptance 9 illegally owns CAS lifecycle marker: $forbidden"}
}

if($t -match 'RouteGroundTo\s*\(|RouteTo\s*\(|SetTask\s*\(|PushTask\s*\('){
  throw 'Acceptance 9 must not own native/custom routing.'
}
if($t -match 'ReportInstallationEvidence\s*\('){
  throw 'Acceptance 9 must not inject installation evidence.'
}
if(-not $t.Contains('onEvidence=onCasEvidence')){
  throw 'Acceptance 9 must observe the production CAS lifecycle through onEvidence.'
}
if(-not $t.Contains('state.runtime.externalSupportRuntime.casLifecycle:GetState')){
  throw 'Acceptance 9 must assert the production CAS lifecycle state rather than duplicate it.'
}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$nl=[Environment]::NewLine
$header='-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.'+$nl
$header+='-- BuilderVersion: '+$version+$nl
$header+='-- GitCommit: '+$commit+$nl
$header+='-- MOOSE release: 2.9.18'+$nl
$header+='-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'+$nl
$header+='-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'+$nl
$header+='-- HarnessRole: stimulus + observation + assertion only; production CasLifecycleRuntime owns CAS route/release/recovery.'+$nl
$header+='-- MizMutation: false'+$nl+$nl

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
[System.IO.File]::WriteAllText($out,$header+$p+$nl+$nl+$t,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "CasLifecycleSourceSHA256: $((Get-FileHash -LiteralPath (Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_CasLifecycleRuntime.lua') -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'LifecycleInheritance: Stage2B accepted owner route + binding CAS release/recovery law -> shared production CasLifecycleRuntime'
Write-Host 'HarnessRole: stimulus + observation + assertion only'
Write-Host 'CASSelection: MOOSE COMMANDER/LEGION'
Write-Host 'CASLifecycleOwner: production OMW_FireSupStratResupply_CasLifecycleRuntime.lua'
Write-Host 'Watchdog: diagnostic only; cannot stop production lifecycle'
Write-Host 'MizMutation: false'
