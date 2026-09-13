[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\03-production-base-six-site-physical-alarm-qrf-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-4'
foreach($f in @($prodBuilder,$src)){if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}}
& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}
$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$c=$p+"`n"+$t
foreach($m in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME-2',
  'OMW-FOB-THREAT-OPSZONE-ADAPTER-5',
  'StartPerimeters',
  'PROXIMITY_INTRUSION',
  'OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT',
  'EXISTING_MOOSE_ZONE_CENTER',
  'RUNTIME_ZONE_RADIUS',
  'QRF_MATERIALIZATION',
  'QRF_NOT_MATERIALIZED_IN_ACCESS',
  'vehicleSpacingM',
  'BadGuys_A3_FENTY','BadGuys_A3_FORTRESS','BadGuys_A3_JOYCE','BadGuys_A3_WRIGHT','BadGuys_A3_HONAKER','BadGuys_A3_BOSTICK',
  'RouteGroundTo','GROUP.Attribute.GROUND_INFANTRY','GROUP.Attribute.GROUND_APC')){
  if(-not $c.Contains($m)){throw "Acceptance 3 marker missing: $m"}
}
foreach($radius in @('2438.4','1524.0','2743.2','1219.2')){if(-not $c.Contains($radius)){throw "Acceptance 3 owner-defined radius marker missing: $radius"}}
foreach($access in @('ZON_BLUE_GND_FENTY_ACCESS','ZON_BLUE_GND_FORTRESS_ACCESS','ZON_BLUE_GND_JOYCE_ACCESS','ZON_BLUE_GND_WRIGHT_ACCESS','ZON_BLUE_GND_HONAKER_ACCESS','ZON_BLUE_GND_BOSTICK_ACCESS')){if(-not $c.Contains($access)){throw "Acceptance 3 QRF ACCESS contract marker missing: $access"}}
if($t -match 'securityZone\s*=\s*ZONE:FindByName\(alarm\.anchorName\)'){throw 'Acceptance 3 must not reuse the 6000 ft Jalalabad ME zone geometry as the security perimeter.'}
if($t -match 'ZON_TEST_A3_'){throw 'Acceptance 3 no longer requires Mission Editor test zones.'}
if($t -match 'ReportInstallationEvidence\s*\('){throw 'Acceptance 3 must not inject evidence directly.'}
if($t -match 'targetBelongsToGuard|targetInAlarmZone'){throw 'Acceptance 3 must not use the rejected Guard-only alarm correlation.'}
$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$header="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $version`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Acceptance-only six-site owner-defined alarm geometry, physical MOOSE OPSZONE qualification, and ACCESS-bound QRF materialization.`n`n"
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
Write-Host 'PrimaryAlarmEvidenceSource: MOOSE OPSZONE proximity qualification'
Write-Host 'JalalabadAlarmZoneSource: existing MOOSE ZONE center OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT + runtime ZONE_RADIUS 8000 ft / 2438.4 m'
Write-Host 'OtherAlarmZoneSource: MOOSE WAREHOUSE coordinate + runtime ZONE_RADIUS'
Write-Host 'QrfVehicleMaterialization: site ACCESS zone + accepted road-aligned adapter + fixed 18 m vehicle spacing'
Write-Host 'MissionEditorAdditionalAlarmZonesRequired: false'
Write-Host 'MizMutation: false'
