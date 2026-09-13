[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\04-qrf-response-clearance-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_4.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-3'

foreach($f in @($prodBuilder,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$c=$p+"`n"+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-14',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-11',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-6',
  'AUFTRAG:NewONGUARD','SetEngageDetected','SetReturnToLegion(true)',
  'AUFTRAG:NewPATROLZONE','SetPatrolAdInfinitum(true)','EnableHuntingPatrol','DisableHuntingPatrol',
  'FOB_JOYCE','BadGuys_A3_JOYCE','ZON_BLUE_GND_JOYCE_ACCESS',
  'AUFTRAG.Type.ONGUARD','AUFTRAG.Type.PATROLZONE','hp_timer','hp_target','fixtureClearedObserved',
  'focusedSiteRegistry','siteRegistry=focusedSiteRegistry',
  'ACCEPTANCE_SUPPORTED_ELEMENT_RELEASE','ExpireDemand','IsReturning',
  'ROAD_ALIGNED_WAREHOUSE_SPAWN','forwardCoordinate = targetCoordinate')){
  if(-not $c.Contains($marker)){throw "Acceptance 4 marker missing: $marker"}
}

if($t -match 'AUFTRAG\.Type\.GROUNDATTACK|AUFTRAG:NewGROUNDATTACK'){throw 'Acceptance 4 must not use GROUNDATTACK.'}
if($t -match 'PATROL_TEST'){throw 'Acceptance 4 must not depend on historical PATROL_TEST zones.'}
if($t -match 'ZON_TEST_A4_'){throw 'Acceptance 4 must not introduce new Mission Editor zones.'}
if($t -match 'ReportInstallationEvidence\s*\('){throw 'Acceptance 4 must not inject installation evidence directly.'}
if($t -match 'Teleport\s*\('){throw 'Acceptance 4 must not teleport QRF or fixture groups.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$header="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $version`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Joyce focused QRF response -> same-group PATROLZONE + HuntingPatrol target acquisition and hostile fixture clearance -> explicit Supported-Element/C2 release acceptance.`n`n"

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
Write-Host 'AcceptanceSiteRegistryScope: FOB_JOYCE only; production SiteRegistry remains unchanged'
Write-Host 'AlarmEvidence: physical MOOSE OPSZONE PROXIMITY_INTRUSION only'
Write-Host 'QrfResponsePhase: AUFTRAG ONGUARD + SetEngageDetected'
Write-Host 'QrfClearancePhase: same ARMYGROUP AUFTRAG PATROLZONE + EnableHuntingPatrol'
Write-Host 'QrfClearanceEvidence: PATROLZONE current mission + hp_timer + hp_target acquisition + physical Joyce hostile fixture clearance'
Write-Host 'QrfReleaseStimulus: explicit acceptance Supported-Element/C2 release only after physical hostile fixture clearance'
Write-Host 'QrfReturnEvidence: MOOSE ARMYGROUP Returning/Returned state observed after explicit release'
Write-Host 'MissionEditorAdditionalZonesRequired: false'
Write-Host 'MizMutation: false'