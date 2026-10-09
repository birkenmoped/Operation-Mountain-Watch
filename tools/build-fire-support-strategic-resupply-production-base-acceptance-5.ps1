[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$guardRuntimeSrc=Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_GuardRuntime.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\05-incident-local-guard-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_5.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-5-2'

foreach($f in @($prodBuilder,$guardRuntimeSrc,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$g=Get-Content -LiteralPath $guardRuntimeSrc -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$c=$p+"`n"+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-18',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-5',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-4',
  'OMW-FOB-THREAT-OPSZONE-ADAPTER-6',
  'INSTALLATION_ATTACK_LOCAL_GUARD','INSTALLATION_ATTACK_INITIAL_QRF',
  'INCIDENT_LOCAL_SECURITY','INCIDENT_LOCAL_DEFENSE','MOOSE_OPSZONE_RED_PRESENCE',
  'AUFTRAG:NewONGUARD','SetReturnToLegion(true)','cancelWhenIncidentClosed=true','cancelWhenIncidentClosed=false',
  'FOB_JOYCE','BadGuys_A3_JOYCE','STARTUP_NO_GUARD_WINDOW_SEC',
  'GUARD_MATERIALIZED','GUARD_RETURNED','AUTHORITATIVE_CLOSE_REQUESTED',
  'ACCEPTANCE_CONFIRMED_NO_LIVING_PARTICIPANTS','HasAliveParticipants()',
  'routeSource=MISSION_EDITOR routeOverride=false')){
  if(-not $c.Contains($marker)){throw "Acceptance 5 marker missing: $marker"}
}

if($p -match 'AUFTRAG:NewGROUNDATTACK|AUFTRAG:NewPATROLZONE|EnableHuntingPatrol'){throw 'Production local Guard/QRF contract must not use rejected GROUNDATTACK/PATROLZONE/HuntingPatrol paths.'}
if($p -match 'SetEngageDetected\s*\('){throw 'Production incident-local Guard must not use proactive SetEngageDetected.'}
# The production bundle may still package the historical GuardRouteAdapter as a compatibility module.
# The current contract forbids the incident-local GuardRuntime from consuming/installing it.
if($g -match 'spec\.routeAdapter|routeAdapter\s*=|routeAdapter:Install|routeAdapter\.Install'){
  throw 'Production incident-local GuardRuntime must not consume or install the historical Guard route adapter.'
}
if($t -match 'ReportInstallationEvidence\s*\('){throw 'Acceptance 5 must not inject installation evidence directly.'}
if($t -match 'ExpireDemand\s*\('){throw 'Acceptance 5 must not expire/cancel demands directly.'}
if($t -match 'RouteGroundTo\s*\(|RouteTo\s*\(|:Route\s*\(|SetTask\s*\(|PushTask\s*\('){throw 'Acceptance 5 must not replace or rewrite the existing Joyce Mission Editor attack route.'}
if($t -match 'SetEngageDetected\s*\(|EngageTarget\s*\('){throw 'Acceptance 5 must not implement Guard/QRF engagement logic.'}
if($t -match 'Teleport\s*\('){throw 'Acceptance 5 must not teleport Guard, QRF, or fixture groups.'}
if($t -match ':Cancel\s*\('){throw 'Acceptance 5 must not directly cancel missions or demands.'}
if(-not $t.Contains('CloseInstallationIncident')){throw 'Acceptance 5 must exercise the production incident-close API.'}
if(-not $t.Contains('c:HasAliveParticipants()==true')){throw 'Acceptance 5 close stimulus must be gated by the authoritative participant registry.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$header="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $version`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Joyce incident-local Guard: no pre-alarm physical Guard -> MOOSE OPSZONE RED presence -> PROXIMITY_INTRUSION -> local Guard + existing QRF demand -> Guard ONGUARD -> zero living incident participants -> production incident close -> Guard ReturnToLegion while QRF is not incident-close-cancelled.`n`n"

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
[System.IO.File]::WriteAllText($out,$header+$p+"`n`n"+$t,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'AcceptanceSite: FOB_JOYCE'
Write-Host 'NormalState: no physical Guard and no Guard demand before alarm'
Write-Host 'AlarmEvidence: physical MOOSE OPSZONE scan/GetScannedGroupSet -> PROXIMITY_INTRUSION; no direct evidence injection'
Write-Host 'RedFixtureRoute: existing Mission Editor route; Acceptance activates only and must not replace/rewrite it'
Write-Host 'GuardDemand: INSTALLATION_ATTACK_LOCAL_GUARD; cancelWhenIncidentClosed=true'
Write-Host 'QrfDemand: INSTALLATION_ATTACK_INITIAL_QRF; cancelWhenIncidentClosed=false'
Write-Host 'GuardMission: MOOSE ONGUARD at accepted local materialization anchor; no PATHLINE patrol; no proactive EngageTarget/SetEngageDetected'
Write-Host 'GuardRouteAdapterAssertion: checked against GuardRuntime consumption/installation, not mere compatibility packaging in the production bundle'
Write-Host 'IncidentCloseStimulus: Acceptance invokes production CloseInstallationIncident only after GroundInstallationAttackIncident reports zero living participants; validates downstream cancellation split, not production close policy'
Write-Host 'GuardReturnEvidence: public MOOSE ARMYGROUP OnAfterRTZ and OnAfterReturned callbacks; Returned required for PASS'
Write-Host 'QrfExecutionAcceptance: inherited from accepted A4-8; not re-scored by Acceptance 5'
Write-Host 'MissionEditorAdditionalZonesRequired: false'
Write-Host 'MizMutation: false'
