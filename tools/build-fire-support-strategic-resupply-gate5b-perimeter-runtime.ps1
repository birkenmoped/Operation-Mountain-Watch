[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5b-six-site-perimeter-runtime\src\01-six-site-perimeter-runtime-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5b-six-site-perimeter-runtime\dist\OMW_FireSupStratResupply_Gate5B_Perimeter_Runtime.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5B-PERIMETER-RUNTIME-1'

foreach($file in @($prodBuilder,$src)){
  if(-not(Test-Path -LiteralPath $file -PathType Leaf)){throw "Required file not found: $file"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$production=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$acceptance=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$combined=$production+"`n"+$acceptance

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-17',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME-2',
  'OMW-FOB-THREAT-OPSZONE-ADAPTER-5',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8',
  'ZONE_RADIUS:New','OPSZONE:New','PROXIMITY_INTRUSION','StartPerimeters',
  'INSTALLATION_ATTACK_INITIAL_QRF','cancelWhenIncidentClosed=false',
  'OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT','2438.4','1524.0','2743.2','1219.2',
  'BadGuys_A3_FENTY','BadGuys_A3_FORTRESS','BadGuys_A3_JOYCE','BadGuys_A3_WRIGHT','BadGuys_A3_HONAKER','BadGuys_A3_BOSTICK',
  'GetIntermediateCoordinate','RouteGroundTo','GetRadius','QRF_DEMAND_COUNT_'
)){
  if(-not $combined.Contains($marker)){throw "Gate 5B acceptance marker missing: $marker"}
}

foreach($forbidden in @(
  'ReportInstallationEvidence(',
  'CloseInstallationIncident(',
  'ExpireDemand(',
  'ZON_TEST_',
  'PATROL_TEST',
  'AUFTRAG:NewGROUNDATTACK',
  'EnableHuntingPatrol',
  'SetEngageDetected'
)){
  if($acceptance.Contains($forbidden)){throw "Gate 5B acceptance must not contain forbidden marker: $forbidden"}
}

if($acceptance -match 'accessZoneName'){throw 'Gate 5B perimeter acceptance must not depend on Convoy ACCESS zones.'}
if($acceptance -match 'securityZone\s*=\s*ZONE:FindByName'){throw 'Gate 5B must create runtime ZONE_RADIUS perimeters rather than reuse the Jalalabad source-zone radius.'}
if($acceptance -match 'updateSeconds\s*='){throw 'Gate 5B Acceptance 1 intentionally exercises the current production/default OPSZONE update cadence.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$header="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $version`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Gate 5B: approved six-site runtime ZONE_RADIUS/OPSZONE perimeter -> physical intrusion -> PROXIMITY_INTRUSION -> authoritative incident -> exactly one initial QRF demand. No QRF execution acceptance in this bundle.`n`n"

New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
[System.IO.File]::WriteAllText($out,$header+$production+"`n`n"+$acceptance,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'Sites: 6'
Write-Host 'JalalabadAlarmAnchor: OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT center (owner-approved airfield exception)'
Write-Host 'OtherAlarmAnchors: site MOOSE Warehouse coordinates'
Write-Host 'AlarmRadiiM: 2438.4, 1524.0, 2743.2, 1219.2, 2743.2, 1524.0'
Write-Host 'AlarmBoundary: runtime MOOSE ZONE_RADIUS + OPSZONE; no Mission Editor alarm zones'
Write-Host 'AlarmEvidence: physical MOOSE OPSZONE intrusion -> PROXIMITY_INTRUSION'
Write-Host 'IncidentAuthority: OMW_GroundInstallationAttackIncident'
Write-Host 'ExpectedInitialResponse: exactly one QRF demand per installation incident'
Write-Host 'QrfExecutionAcceptance: false (Gate 4 A4-8 remains the accepted QRF execution baseline)'
Write-Host 'AcceptanceOwnedEvidenceInjection: false'
Write-Host 'AcceptanceOwnedIncidentClose: false'
Write-Host 'AcceptanceOwnedQrfRelease: false'
Write-Host 'PerimeterAccessZoneDependency: none'
Write-Host 'MissionEditorAdditionalAlarmZonesRequired: false'
Write-Host 'MizMutation: false'
