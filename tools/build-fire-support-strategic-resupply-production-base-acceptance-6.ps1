[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\06-c2-provider-selection-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_6.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-6-1'

foreach($f in @($prodBuilder,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$c=$p+[Environment]::NewLine+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-COMMANDER-BRIDGE-2',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-EXTERNAL-SUPPORT-RUNTIME-1',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-2',
  'FOB_JOYCE','BadGuys_A3_JOYCE',
  'COMMANDER:New','commander:AddAirwing',
  'RequestIncidentSupport',
  'C2_CAS_PROVIDER_SELECTED','C2_CAS_OPS_ON_MISSION',
  'QRF_DIRECT_TARGET_ENGAGE',
  'FEWER_THAN_TWO_CAS_CAPABLE_AIRWINGS',
  'AUFTRAG.CheckMissionCapability','siteRegistry=singleSiteRegistry')){
  if(-not $c.Contains($marker)){throw "Acceptance 6 marker missing: $marker"}
}

foreach($forbidden in @(
  'OMW.AirOps.Jalalabad','OMW.AirOps.Bagram','OMW.AirOps.Kandahar',
  'OMW.AirOps.Salerno','OMW.AirOps.Tarinkot','OMW.AirOps.Shindand',
  'AH64','A10','F15','F16',
  'specialLegions','specialCohorts',
  'Airwing:AddMission','AIRWING:AddMission',
  'squadrons={','SetMissionIngressCoord','SetMissionEgressCoord',
  'HelicopterCasTacticalCorridor')){
  if($t.Contains($forbidden)){throw "Acceptance 6 forbidden provider/route shortcut found: $forbidden"}
}

if($t -match 'RouteGroundTo\s*\(|RouteTo\s*\(|SetTask\s*\(|PushTask\s*\('){throw 'Acceptance 6 must not rewrite the RED fixture route.'}
if($t -match 'ReportInstallationEvidence\s*\('){throw 'Acceptance 6 must not inject installation evidence directly.'}
if($t -match 'ExpireDemand\s*\('){throw 'Acceptance 6 must not expire/cancel demands directly.'}
if($t -match 'ARTY:New|AUFTRAG:NewARTY'){throw 'Acceptance 6 does not include an ARTY execution/provider fixture.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$nl=[Environment]::NewLine
$header='-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.'+$nl
$header+='-- BuilderVersion: '+$version+$nl
$header+='-- GitCommit: '+$commit+$nl
$header+='-- MOOSE release: 2.9.18'+$nl
$header+='-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'+$nl
$header+='-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'+$nl
$header+='-- Scope: physical Joyce attack -> production incident/QRF plus Base CAS escalation -> generic COMMANDER -> runtime-selected provider/asset. No Acceptance provider selection.'+$nl+$nl

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
[System.IO.File]::WriteAllText($out,$header+$p+$nl+$nl+$t,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'AcceptanceSite: FOB_JOYCE'
Write-Host 'RedFixture: BadGuys_A3_JOYCE existing Mission Editor route; no route rewrite'
Write-Host 'QRF: production incident direct-target chain; ARMYGROUP OnAfterEngageTarget required'
Write-Host 'CAS Escalation: Base RequestIncidentSupport -> ExternalSupportRuntime -> CommanderBridge -> COMMANDER'
Write-Host 'C2 CandidatePool: all RUNNING OMW.AirOps AIRWINGs discovered at runtime; >=2 CAS-capable AIRWINGs required'
Write-Host 'ProviderSelection: MOOSE COMMANDER only; no Acceptance AIRWING/SQUADRON/aircraft/provider binding'
Write-Host 'CAS RuntimeEvidence: COMMANDER MissionAssign + OpsOnMission required'
Write-Host 'ARTY/Resupply/CAS route/RTB/weapon employment: out of scope'
Write-Host 'TimeoutAfterAttackSec: 600'
Write-Host 'MizMutation: false'
