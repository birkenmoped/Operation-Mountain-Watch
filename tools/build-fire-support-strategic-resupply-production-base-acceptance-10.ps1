[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$materializer=Join-Path $repoRoot 'scripts\ground\OMW_GroundSupportMaterializer.lua'
$support=Join-Path $repoRoot 'scripts\ground\OMW_FixedFireSupportAmmoSupport.lua'
$rearmAdapter=Join-Path $repoRoot 'scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
$rearmService=Join-Path $repoRoot 'scripts\ground\OMW_FixedFireSupportAmmoRearmService.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\10-production-real-arty-selection-rearm-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_10.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-10-1'

foreach($f in @($prodBuilder,$materializer,$support,$rearmAdapter,$rearmService,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$m=Get-Content -LiteralPath $materializer -Raw -Encoding UTF8
$s=Get-Content -LiteralPath $support -Raw -Encoding UTF8
$r=Get-Content -LiteralPath $rearmAdapter -Raw -Encoding UTF8
$rr=Get-Content -LiteralPath $rearmService -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$all=$p+$m+$s+$r+$rr+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-28',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-REAL-ASSET-REGISTRY-1',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-RUNTIME-1',
  'OMW-FIXED-FIRE-SUPPORT-AMMO-REARM-SERVICE-2',
  'OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-4',
  'OMW-GROUND-AMMO-REARM-ADAPTER-2',
  'TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2',
  'TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2',
  'TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1',
  'TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2',
  'TPL_BLUE_GND_SUP_M1083',
  'MULTIPLE_ELIGIBLE_PROVIDERS',
  'MOOSE_REAL_ARTY_SELECTED',
  'EXACT_POSITION_PASS',
  'FIXED_BATTERY_STATIONARY',
  'startArty=false',
  'M1083_RETURNED_TO_STOCK'
)){
  if(-not $all.Contains($marker)){throw "Acceptance 10 marker missing: $marker"}
}

foreach($forbidden in @(
  'commander:AddMission(',
  'COMMANDER:AddMission(',
  'RouteGroundTo(',
  'RouteTo(',
  'SetTask(',
  'PushTask(',
  ':Teleport(',
  'OPSGROUP:SetRearmOnOutOfAmmo',
  'SetRearmOnOutOfAmmo(',
  'world.addEventHandler',
  'timer.scheduleFunction',
  'mist.',
  'MIST'
)){
  if($t.Contains($forbidden)){throw "Acceptance 10 forbidden lifecycle/provider shortcut: $forbidden"}
}

if(-not $t.Contains('m.artyRealAssetRegistry.New(')){throw 'Acceptance 10 must use production ArtyRealAssetRegistry.'}
if(-not $t.Contains('m.artySelectionRuntime.New(')){throw 'Acceptance 10 must use production ArtySelectionRuntime.'}
if(-not $t.Contains('FixedFireSupportAmmoRearmService.New(')){throw 'Acceptance 10 must reuse accepted FixedFireSupportAmmoRearmService.'}
if(-not $t.Contains('performance=50')){throw 'Acceptance 10 must not preference-bind Wright versus Honaker in the multi-provider selection fixture.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$nl=[Environment]::NewLine
$header='-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.'+$nl
$header+='-- BuilderVersion: '+$version+$nl
$header+='-- GitCommit: '+$commit+$nl
$header+='-- MOOSE release: 2.9.18'+$nl
$header+='-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'+$nl
$header+='-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'+$nl
$header+='-- Scope: real site-bound MOOSE ARTY/Mortar materialization -> COMMANDER selection-only recruitment -> Functional ARTY -> accepted M1083 rearm.'+$nl
$header+='-- HarnessRole: composition + stimulus + observation + assertion; no provider selector, no battery movement, no second fire/rearm FSM.'+$nl
$header+='-- MizMutation: false'+$nl+$nl

function Embed([string]$Name,[string]$Source){"local $Name = (function()`n$Source`nend)()`n`n"}

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
$bundle=$header+$p+$nl
$bundle+=Embed 'GroundSupportMaterializer' $m
$bundle+=Embed 'FixedFireSupportAmmoSupport' $s
$bundle+=Embed 'GroundAmmoRearmAdapter' $r
$bundle+=Embed 'FixedFireSupportAmmoRearmService' $rr
$bundle+=$t
[System.IO.File]::WriteAllText($out,$bundle,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "RealAssetRegistrySourceSHA256: $((Get-FileHash -LiteralPath (Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_ArtyRealAssetRegistry.lua') -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ArtySelectionRuntimeSourceSHA256: $((Get-FileHash -LiteralPath (Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_ArtySelectionRuntime.lua') -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "FixedFireSupportAmmoRearmServiceSHA256: $((Get-FileHash -LiteralPath $rearmService -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'ARTYProviders: BOSTICK, WRIGHT, FORTRESS, HONAKER real spawned PLATOON assets'
Write-Host 'MultiEligibleFixture: WRIGHT + HONAKER; equal performance=50; provider selection remains MOOSE COMMANDER-owned'
Write-Host 'BatteryMovement: forbidden; exact materialization + post-fire + post-rearm position assertions'
Write-Host 'RearmLifecycle: accepted FixedFireSupportAmmoRearmService + same Functional ARTY instance + startArty=false'
Write-Host 'MizMutation: false'
