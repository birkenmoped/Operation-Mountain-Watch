[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\04-qrf-response-clearance-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_4.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-6'

foreach($f in @($prodBuilder,$src)){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}

& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$c=$p+"`n"+$t

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-16',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-12',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-4',
  'AUFTRAG:NewONGUARD','SetReturnToLegion(true)','armyGroup:EngageTarget','OnAfterDisengage',
  'DEFAULT_ENGAGE_FORMATION = "On Road"',
  'sourceIncidentCoordinator','GetParticipants(true)','QRF_NO_LIVING_INCIDENT_TARGETS_IN_TACTICAL_ZONE',
  'FOB_JOYCE','BadGuys_A3_JOYCE','ZON_BLUE_GND_JOYCE_ACCESS',
  'AUFTRAG.Type.ONGUARD','QRF_CONCRETE_TARGET','targetCount>=2','fixtureClearedObserved','returnObserved',
  'fixtureActivated','fixtureMove>=MIN_FIXTURE_MOVE_M','routeSource=MISSION_EDITOR','routeOverride=false',
  'focusedSiteRegistry','siteRegistry=focusedSiteRegistry','IsReturning',
  'ROAD_ALIGNED_WAREHOUSE_SPAWN','forwardCoordinate = targetCoordinate')){
  if(-not $c.Contains($marker)){throw "Acceptance 4 marker missing: $marker"}
}

if($p -match 'AUFTRAG:NewGROUNDATTACK|AUFTRAG:NewPATROLZONE|EnableHuntingPatrol'){throw 'Production QRF must use direct MOOSE EngageTarget, not GROUNDATTACK/PATROLZONE/HuntingPatrol.'}
if($p.Contains('local DEFAULT_ENGAGE_FORMATION = "Vee"')){throw 'Production QRF motorized march must not default to Vee.'}
if($t -match 'AUFTRAG\.Type\.GROUNDATTACK|AUFTRAG:NewGROUNDATTACK|AUFTRAG\.Type\.PATROLZONE|EnableHuntingPatrol|hp_target|hp_timer'){throw 'Acceptance 4 must not use the rejected patrol/hunting design.'}
if($t -match 'ExpireDemand\s*\(|ACCEPTANCE_SUPPORTED_ELEMENT_RELEASE'){throw 'Acceptance 4 must not manufacture QRF release; target exhaustion is the product completion condition.'}
if($t -match 'PATROL_TEST'){throw 'Acceptance 4 must not depend on historical PATROL_TEST zones.'}
if($t -match 'ZON_TEST_A4_'){throw 'Acceptance 4 must not introduce new Mission Editor zones.'}
if($t -match 'ReportInstallationEvidence\s*\('){throw 'Acceptance 4 must not inject installation evidence directly.'}
if($t -match 'Teleport\s*\('){throw 'Acceptance 4 must not teleport QRF or fixture groups.'}
if($t -match 'RouteGroundTo\s*\(|RouteTo\s*\(|:Route\s*\(|SetTask\s*\(|PushTask\s*\('){throw 'Acceptance 4 must not replace or rewrite the existing Joyce Mission Editor attack route.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$header="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $version`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Joyce focused QRF: existing Mission Editor RED attack route remains untouched; road-aligned ACCESS materialization -> MOOSE On Road EngageTarget transit -> concrete moving incident UNIT pursuit -> target death/reacquire -> target exhaustion -> ReturnToLegion.`n`n"

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
Write-Host 'RedFixtureRoute: existing Mission Editor route; Acceptance activates only and must not replace/rewrite it'
Write-Host 'QrfRecruitmentAnchor: AUFTRAG ONGUARD; no stale-coordinate clearance phase'
Write-Host 'QrfMovementContract: motorized QRF uses MOOSE On Road transit; MOOSE owns final off-road target approach when required'
Write-Host 'QrfTargetCycle: same ARMYGROUP directly EngageTarget nearest living concrete incident UNIT; Disengage triggers reacquisition'
Write-Host 'QrfTargetEvidence: at least two unique concrete moving RED UNIT acquisitions plus physical Joyce hostile fixture clearance'
Write-Host 'QrfCompletionStimulus: none from Acceptance; zero living authorized incident targets is production completion condition'
Write-Host 'QrfReturnEvidence: MOOSE ARMYGROUP Returning/Returned state observed after target exhaustion'
Write-Host 'MissionEditorAdditionalZonesRequired: false'
Write-Host 'MizMutation: false'
