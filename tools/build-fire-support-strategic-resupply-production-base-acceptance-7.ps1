[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\07-c2-routed-cas-lifecycle-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_7.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-7-1'

$sources=[ordered]@{
  OMW_A7_FLIGHTPATH_NAME_CONTRACT='scripts\air-operations\OMW_FlightPathNameContract.lua'
  OMW_A7_HELICOPTER_FLIGHTPATH_CORRIDOR='scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
  OMW_A7_HELICOPTER_CAS_TACTICAL_CORRIDOR='scripts\air-operations\OMW_HelicopterCasTacticalCorridor.lua'
}

foreach($f in @($prodBuilder,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}
foreach($name in $sources.Keys){
  $path=Join-Path $repoRoot $sources[$name]
  if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required A7 source not found: $path"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

function Embed-Module([string]$Name,[string]$Source){
  return 'local '+$Name+' = (function()'+[Environment]::NewLine+$Source+[Environment]::NewLine+'end)()'+[Environment]::NewLine+[Environment]::NewLine
}

$prod=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$test=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$embedded=''
foreach($name in $sources.Keys){
  $embedded+=Embed-Module $name (Get-Content -LiteralPath (Join-Path $repoRoot $sources[$name]) -Raw -Encoding UTF8)
}
$all=$prod+[Environment]::NewLine+$embedded+[Environment]::NewLine+$test

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-19',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-3',
  'requiredAttributes',
  'SetRequiredAttribute',
  'OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8',
  'OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1',
  'FOB_JOYCE',
  'BadGuys_A3_JOYCE',
  'GROUP.Attribute.AIR_ATTACKHELO',
  'OnBeforeMissionAssign',
  'C2_PROVIDER_SELECTED_AND_PROFILED',
  'CAS_OWNER_CORRIDOR_INSTALLED',
  'CAS_NO_CONTACT_REPORTED',
  'CAS_CONTROLLED_RELEASE',
  'CAS_HOME_LANDED',
  'CAS_LEGION_ASSET_RETURNED',
  'QRF_DIRECT_TARGET_ENGAGE')){
  if(-not $all.Contains($marker)){throw "Acceptance 7 marker missing: $marker"}
}

foreach($forbidden in @(
  'OMW.AirOps.Jalalabad',
  'OMW.AirOps.Bagram',
  'OMW.AirOps.Kandahar',
  'OMW.AirOps.Salerno',
  'OMW.AirOps.Tarinkot',
  'OMW.AirOps.Shindand',
  'specialLegions',
  'specialCohorts',
  'Airwing:AddMission',
  'AIRWING:AddMission',
  'KnowTarget(',
  'MissionScripting.lua',
  'coalition.addGroup',
  'timer.scheduleFunction')){
  if($test.Contains($forbidden)){throw "Acceptance 7 forbidden selection/runtime shortcut found: $forbidden"}
}

if($test -match 'RouteGroundTo\s*\(|RouteTo\s*\(|SetTask\s*\(|PushTask\s*\('){
  throw 'Acceptance 7 must not rewrite the RED fixture or CAS route with native/custom controller tasks.'
}
if($test -match 'ReportInstallationEvidence\s*\('){
  throw 'Acceptance 7 must not inject installation evidence directly.'
}
if($test -match 'Mission:Cancel\s*\('){
  throw 'Acceptance 7 must close CAS through the Base/CommanderBridge handle, not by direct mission mutation.'
}
if(-not $test.Contains('SELECTED_PROVIDER_HAS_NO_OWNER_ROUTE_PROFILE')){
  throw 'Acceptance 7 requires fail-closed provider/profile validation before physical dispatch.'
}
if(-not $test.Contains('CAS_FUEL_LOW_BEFORE_PHYSICAL_RETURN')){
  throw 'Acceptance 7 requires explicit FuelLow regression detection.'
}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$nl=[Environment]::NewLine
$header='-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.'+$nl
$header+='-- BuilderVersion: '+$version+$nl
$header+='-- GitCommit: '+$commit+$nl
$header+='-- MOOSE release: 2.9.18'+$nl
$header+='-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'+$nl
$header+='-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'+$nl
$header+='-- Scope: Joyce production incident/QRF plus MOOSE-selected PATROLZONE attack-helicopter CAS with fail-closed owner-route profile, supported-element/no-contact release, reverse recovery, landing and LEGION return.'+$nl
$header+='-- AssetSelectionAuthority: MOOSE COMMANDER/LEGION per ADR 0008.'+$nl
$header+='-- MizMutation: false'+$nl+$nl

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
[System.IO.File]::WriteAllText($out,$header+$prod+$nl+$nl+$embedded+$nl+$test,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
foreach($name in $sources.Keys){
  $path=Join-Path $repoRoot $sources[$name]
  Write-Host "EmbeddedSourceSHA256 $name $((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToUpperInvariant())"
}
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'AcceptanceSite: FOB_JOYCE'
Write-Host 'GroundChain: production perimeter -> installation incident -> production QRF concrete target'
Write-Host 'CASSelection: MOOSE COMMANDER/LEGION; AUFTRAG requires GROUP.Attribute.AIR_ATTACKHELO and PATROLZONE capability'
Write-Host 'CASRoute: selected provider must have owner-authored route profile before MissionAssign; otherwise fail closed with no physical dispatch'
Write-Host 'CASExecution: PATROLZONE + SetEngageDetected'
Write-Host 'CASRelease: supported element clear + FLIGHTGROUP own stable no-contact >= 30 sec'
Write-Host 'CASRecovery: reverse owner route -> physical landing -> LEGION/AIRWING asset return'
Write-Host 'FuelLow: regression FAIL before physical return'
Write-Host 'TimeoutAfterAttackSec: 900'
Write-Host 'MizMutation: false'
