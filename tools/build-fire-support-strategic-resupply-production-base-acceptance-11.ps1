[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$groundInitialStock=Join-Path $repoRoot 'scripts\logistics\OMW_GroundInitialStock.lua'
$resourceDemandPolicy=Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\11-production-multisite-full-response-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_11.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-11-2'

foreach($f in @($prodBuilder,$groundInitialStock,$resourceDemandPolicy,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$g=Get-Content -LiteralPath $groundInitialStock -Raw -Encoding UTF8
$r=Get-Content -LiteralPath $resourceDemandPolicy -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$all=$p+$g+$r+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-33',
  'accessContainment=ANCHOR_ONLY',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-12',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-TRANSPORT-RUNTIME-5',
  'OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-REAL-ASSET-REGISTRY-1',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-RUNTIME-1',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1',
  'OMW-RESOURCE-DEMAND-POLICY-1',
  'OMW-GROUND-INITIAL-STOCK-3',
  'BadGuys_A3_JOYCE',
  'BadGuys_A3_WRIGHT',
  'BadGuys_A3_HONAKER',
  'TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2',
  'TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2',
  'AUTHORITATIVE_SHORTAGE_PRECONDITION',
  'AIR_RESUPPLY',
  'resolvedCorridor=state.resolvedTransportCorridor',
  'RESUPPLY_OUTBOUND_CORRIDOR_INSTALLED',
  'RESUPPLY_RETURN_CORRIDOR_INSTALLED',
  'RESUPPLY_LEGION_ASSET_RETURNED',
  'ARTY_ASSET_DOUBLE_BOOKED',
  'CAS_ASSET_DOUBLE_BOOKED',
  'A11 combined multi-site response complete'
)){
  if(-not $all.Contains($marker)){throw "Acceptance 11 marker missing: $marker"}
}

foreach($forbidden in @(
  'AssignSquadrons(',
  'AIRWING:AddMission(',
  'LEGION.RecruitCohortAssets(',
  'RecruitAssetsForTransport(',
  'TransportAssign(',
  'transport:AddAsset(',
  'commander:AddMission(',
  'COMMANDER:AddMission(',
  'AssignTargetCoord(',
  'RemoveTarget(',
  'SetMissionIngressCoord(',
  'SetMissionEgressCoord(',
  'TransportCorridor.Bind(',
  'flight:AddWaypoint(',
  ':Teleport(',
  'world.addEventHandler',
  'timer.scheduleFunction',
  'mist.',
  'MIST'
)){
  if($t.Contains($forbidden)){throw "Acceptance 11 forbidden lifecycle/provider shortcut: $forbidden"}
}

if(-not $t.Contains('state.modules.artyRealAssetRegistry.New(')){throw 'Acceptance 11 must use production ArtyRealAssetRegistry.'}
if(-not $t.Contains('state.package.New({')){throw 'Acceptance 11 must use the shared Production Base runtime.'}
if(-not $t.Contains('state.runtime:EvaluateResupply()')){throw 'Acceptance 11 must create Strategic Resupply through the production ResupplyMonitor.'}
if(-not $t.Contains('context.campaignState.TransactionKind.CONSUMPTION')){throw 'Acceptance 11 shortage precondition must use authoritative CampaignState, not a parallel ledger.'}
if(-not $t.Contains('performance=50')){throw 'Acceptance 11 fixed-fire-support providers must retain equal performance for autonomous MOOSE selection.'}
if(-not $t.Contains('selectSupportType=function(candidate)')){throw 'Acceptance 11 must express transport mode as demand policy without choosing a carrier.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
if([string]::IsNullOrWhiteSpace($commit)){throw 'Unable to resolve Git HEAD.'}
$nl=[Environment]::NewLine
$header='-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.'+$nl
$header+='-- BuilderVersion: '+$version+$nl
$header+='-- GitCommit: '+$commit+$nl
$header+='-- MOOSE release: 2.9.18'+$nl
$header+='-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'+$nl
$header+='-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'+$nl
$header+='-- Scope: multi-site Guard/QRF + autonomous real ARTY/Mortar + concurrent CAS + threshold-driven mandatory-corridor Strategic Resupply.'+$nl
$header+='-- HarnessRole: fixture stimulus + observation + assertion; production modules own selection, fire, routing, recovery and settlement.'+$nl
$header+='-- MizMutation: false'+$nl+$nl

function Embed([string]$Name,[string]$Source){"local $Name = (function()"+$nl+$Source+$nl+"end)()"+$nl+$nl}

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
$bundle=$header+$p+$nl
$bundle+=Embed 'GroundInitialStock' $g
$bundle+=Embed 'ResourceDemandPolicy' $r
$bundle+=$t
[System.IO.File]::WriteAllText($out,$bundle,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "GroundInitialStockSHA256: $((Get-FileHash -LiteralPath $groundInitialStock -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ResourceDemandPolicySHA256: $((Get-FileHash -LiteralPath $resourceDemandPolicy -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'AttackFixtures: BadGuys_A3_JOYCE + BadGuys_A3_WRIGHT + BadGuys_A3_HONAKER'
Write-Host 'QrfAccessContainment: ACCESS validates the materialization road anchor; road-aligned formation members may extend outside ACCESS'
Write-Host 'ExternalSupport: ARTY x2 + CAS x2 requested only after all three QRFs have physically engaged'
Write-Host 'FixedFireSupport: Bostick/Wright/Fortress L118 + Honaker 2B11 real MOOSE assets, equal performance=50'
Write-Host 'StrategicResupply: authoritative Wright AMMO shortage -> ResourceDemandPolicy -> AIR_RESUPPLY -> MOOSE carrier selection'
Write-Host 'HelicopterCorridor: mandatory Production Base corridor; outbound + reverse route observed, no direct-line fallback'
Write-Host 'ProviderSelection: MOOSE COMMANDER/LEGION owned; no AIRWING/SQUADRON/battery/mortar/carrier preselection'
Write-Host 'MizMutation: false'
