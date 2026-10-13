[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$acceptanceParts=@(
  'mission\tests\stage3-honaker-wright-full-response\src\a2\01-core.lua',
  'mission\tests\stage3-honaker-wright-full-response\src\a2\02-cas.lua',
  'mission\tests\stage3-honaker-wright-full-response\src\a2\03-logistics.lua',
  'mission\tests\stage3-honaker-wright-full-response\src\a2\04-fire-support.lua',
  'mission\tests\stage3-honaker-wright-full-response\src\a2\05-runtime.lua'
)
$distDir=Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist'
$outputFile=Join-Path $distDir 'OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_2.lua'
$builderVersion='STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2-1'
$testId='STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2'
$mooseCommit='73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256='E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'

$sources=[ordered]@{
  OMW_STAGE3_MISSION_DEMAND='scripts\campaign\OMW_MissionDemand.lua'
  OMW_STAGE3_RESOURCE_DEMAND_POLICY='scripts\campaign\OMW_ResourceDemandPolicy.lua'
  OMW_STAGE3_RESOURCE_DEMAND_COORDINATOR='scripts\campaign\OMW_ResourceDemandCoordinator.lua'
  OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY='scripts\campaign\OMW_FobAttackDemandPolicy.lua'
  OMW_STAGE3_FIRE_SUPPORT_DEMAND_POLICY='scripts\campaign\OMW_FobAttackFireSupportDemandPolicy.lua'
  OMW_STAGE3_FUNCTIONAL_ARTY_DISPATCH_ADAPTER='scripts\ground\OMW_FobAttackFunctionalArtyDispatchAdapter.lua'
  OMW_STAGE3_GROUND_AMMO_REARM_ADAPTER='scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
  OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_SUPPORT='scripts\ground\OMW_FixedFireSupportAmmoSupport.lua'
  OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_REARM_SERVICE='scripts\ground\OMW_FixedFireSupportAmmoRearmService.lua'
  OMW_STAGE3_GROUND_SUPPORT_MATERIALIZER='scripts\ground\OMW_GroundSupportMaterializer.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER='scripts\air-operations\OMW_FobAttackCasDispatchAdapter.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_PATROL_CLOSURE='scripts\air-operations\OMW_FobAttackCasPatrolClosure.lua'
  OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR='scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
  OMW_STAGE3_HELICOPTER_CAS_TACTICAL_CORRIDOR='scripts\air-operations\OMW_HelicopterCasTacticalCorridor.lua'
  OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT='scripts\air-operations\OMW_FlightPathNameContract.lua'
  OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER='scripts\air-operations\OMW_OpsTransportCorridorAdapter.lua'
}

foreach($f in @($prodBuilder)+($acceptanceParts|ForEach-Object{Join-Path $repoRoot $_})){
  if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}
}
& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}

function Embed-Module([string]$Name,[string]$Source){"local $Name = (function()`n$Source`nend)()`n`n"}
$prod=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$acceptance=''
foreach($relative in $acceptanceParts){$acceptance+=(Get-Content -LiteralPath (Join-Path $repoRoot $relative) -Raw -Encoding UTF8)+"`n"}
$stage3=''
foreach($name in $sources.Keys){
  $path=Join-Path $repoRoot $sources[$name]
  if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required Stage 3 source not found: $path"}
  $stage3+=Embed-Module $name (Get-Content -LiteralPath $path -Raw -Encoding UTF8)
}

foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-19',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13',
  'INSTALLATION_ATTACK_LOCAL_GUARD','INSTALLATION_ATTACK_INITIAL_QRF',
  'QRF_ENGAGE_FORMATION = "On Road"','MOOSE_OPSZONE_RED_PRESENCE','2743.2')){
  if(-not $prod.Contains($marker)){throw "Production Base marker missing: $marker"}
}
foreach($marker in @(
  'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2','SITE_ID="COP_HONAKER"','BadGuys_A3_HONAKER',
  'state.package.New','StartPerimeters()','StartSite(SITE_ID','RequestIncidentSupport(state.baseIncidentId,"ARTY"','RequestIncidentSupport(state.baseIncidentId,"CAS"',
  'STAGE3_C2_ARTY','STAGE3_C2_CAS','ACCEPTANCE_DETERMINISTIC_WRIGHT','ACCEPTANCE_DETERMINISTIC_JALALABAD_AH64D',
  'ARTY:New','M1083','OPSTRANSPORT:New','AddCargoStorage','LEGION.RecruitCohortAssets',
  'PATROLZONE_ENGAGE','GetDetectedGroups','SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT',
  'HONAKER_NO_KNOWN_ATTACKERS','CANCEL_REQUESTED','qrfReturned','guardReturned','routeSource=MISSION_EDITOR routeOverride=false')){
  if(-not $acceptance.Contains($marker)){throw "Acceptance 2 marker missing: $marker"}
}
foreach($forbidden in @(
  'SECURITY_RADIUS_M','local GUARD_PATROL_SPEED_KMH','buildGuardPatrolRoute','state.guardGroup:Route','TaskFunction("CONTROLLABLE.Route"',
  'AUFTRAG:NewONGUARD','ThreatAdapter.New','IncidentCoordinator.New','requestQrfRecovery','entry.mission:Cancel()','QRF_ENGAGE_RANGE_NM')){
  if($acceptance.Contains($forbidden)){throw "Acceptance 2 contains superseded Ground implementation marker: $forbidden"}
}
foreach($pattern in @('MissionScripting\.lua','(?i)\bMIST\b|mist\.','coalition\.addGroup','timer\.scheduleFunction',':Teleport\s*\(','KnowTarget\s*\(','ARMYGROUP:EngageTarget\s*\(')){
  if($acceptance -match $pattern){throw "Acceptance 2 contains forbidden runtime pattern: $pattern"}
}
if($acceptance -match 'radiusM\s*=\s*1000'){throw 'Acceptance 2 must not restore the historical 1000-m Honaker alarm.'}

$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc=(Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header=@"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-stage3-honaker-wright-full-response-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- GroundAuthority: accepted FSSR Production Base A4/A5 only; no acceptance-owned Guard/QRF missions or target cycle.
-- C2Boundary: generic FSSR ARTY/CAS support demands; Wright/Jalalabad bindings are deterministic Acceptance fixtures only.
-- StrategicAuthority: existing OMW CampaignState only.
-- MizMutation: false.

"@
$bundle=$header+$prod+"`n`n"+$stage3+"`n"+$acceptance
New-Item -ItemType Directory -Path $distDir -Force|Out-Null
[System.IO.File]::WriteAllText($outputFile,$bundle,[System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host 'GroundAuthority: FSSR Production Base A4/A5'
Write-Host 'HonakerAlarmRadiusM: 2743.2'
Write-Host 'Guard: no physical Guard before alarm; incident-local ONGUARD; production incident close -> ReturnToLegion'
Write-Host 'QRF: production direct concrete incident UNIT cycle; On Road; target exhaustion -> ReturnToLegion'
Write-Host 'ExternalSupportBoundary: generic FSSR RequestIncidentSupport ARTY/CAS; deterministic Wright/Jalalabad providers are Acceptance fixtures only'
Write-Host 'FireSupport: Wright Functional MOOSE ARTY -> M1083 local rearm -> CampaignState reorder'
Write-Host 'CAS: Jalalabad AH-64D PATROLZONE + SetEngageDetected with own detected-group picture and supported-element release'
Write-Host 'StrategicResupply: Jalalabad CH-47 MOOSE OPSTRANSPORT STORAGE -> Wright -> reverse recovery'
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
foreach($relative in $acceptanceParts){Write-Host "AcceptancePartSHA256 $relative $((Get-FileHash -LiteralPath (Join-Path $repoRoot $relative) -Algorithm SHA256).Hash.ToUpperInvariant())"}
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'MizMutation: false'
