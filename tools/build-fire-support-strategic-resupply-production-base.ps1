[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$distDir=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist'
$outputFile=Join-Path $distDir 'OMW_FireSupStratResupply_Base.lua'
$builderVersion='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-21'

$moduleSpecs=@(
  @{Name='SiteRegistry';Path='scripts\campaign\OMW_FireSupStratResupply_SiteRegistry.lua'},
  @{Name='SupportProfiles';Path='scripts\campaign\OMW_FireSupStratResupply_SupportProfiles.lua'},
  @{Name='IdContract';Path='scripts\campaign\OMW_FireSupStratResupply_IdContract.lua'},
  @{Name='Base';Path='scripts\campaign\OMW_FireSupStratResupply_Base.lua'},
  @{Name='LifecycleAdapter';Path='scripts\campaign\OMW_FireSupStratResupply_LifecycleAdapter.lua'},
  @{Name='LegionBridge';Path='scripts\campaign\OMW_FireSupStratResupply_LegionBridge.lua'},
  @{Name='GuardMissionFactory';Path='scripts\campaign\OMW_FireSupStratResupply_GuardMissionFactory.lua'},
  @{Name='GuardRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_GuardRuntime.lua'},
  @{Name='QrfMissionFactory';Path='scripts\campaign\OMW_FireSupStratResupply_QrfMissionFactory.lua'},
  @{Name='QrfRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_QrfRuntime.lua'},
  @{Name='CommanderBridge';Path='scripts\campaign\OMW_FireSupStratResupply_CommanderBridge.lua'},
  @{Name='ArtyMissionFactory';Path='scripts\campaign\OMW_FireSupStratResupply_ArtyMissionFactory.lua'},
  @{Name='CasMissionFactory';Path='scripts\campaign\OMW_FireSupStratResupply_CasMissionFactory.lua'},
  @{Name='CasLifecycleRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_CasLifecycleRuntime.lua'},
  @{Name='FlightPathNameContract';Path='scripts\air-operations\OMW_FlightPathNameContract.lua'},
  @{Name='HelicopterCorridor';Path='scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'},
  @{Name='CasTacticalCorridor';Path='scripts\air-operations\OMW_HelicopterCasTacticalCorridor.lua'},
  @{Name='ExternalSupportRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_ExternalSupportRuntime.lua'},
  @{Name='InstallationIncidentBridge';Path='scripts\campaign\OMW_FireSupStratResupply_InstallationIncidentBridge.lua'},
  @{Name='InstallationIncidentRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_InstallationIncidentRuntime.lua'},
  @{Name='PerimeterBridge';Path='scripts\campaign\OMW_FireSupStratResupply_PerimeterBridge.lua'},
  @{Name='PerimeterRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_PerimeterRuntime.lua'},
  @{Name='ResupplyMonitor';Path='scripts\campaign\OMW_FireSupStratResupply_ResupplyMonitor.lua'},
  @{Name='StorageTransportFactory';Path='scripts\campaign\OMW_FireSupStratResupply_StorageTransportFactory.lua'},
  @{Name='TransportSettlement';Path='scripts\campaign\OMW_FireSupStratResupply_TransportSettlement.lua'},
  @{Name='ResupplyTransportRuntime';Path='scripts\campaign\OMW_FireSupStratResupply_ResupplyTransportRuntime.lua'},
  @{Name='InstallationAttackIncident';Path='scripts\ground\OMW_GroundInstallationAttackIncident.lua'},
  @{Name='AlarmEvidenceAdapter';Path='scripts\ground\OMW_GroundInstallationAlarmEvidenceAdapter.lua'},
  @{Name='ThreatAdapter';Path='scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'},
  @{Name='GuardMaterializationAdapter';Path='scripts\ground\OMW_GuardPathlineMaterializationAdapter.lua'},
  @{Name='GuardRouteAdapter';Path='scripts\ground\OMW_GuardPathlineRouteAdapter.lua'},
  @{Name='Runtime';Path='scripts\campaign\OMW_FireSupStratResupply_Runtime.lua'}
)

$sources=@{}
foreach($spec in $moduleSpecs){
  $file=Join-Path $repoRoot $spec.Path
  if(-not(Test-Path -LiteralPath $file -PathType Leaf)){throw "Required source not found: $file"}
  $source=Get-Content -LiteralPath $file -Raw -Encoding UTF8
  if($source -notmatch 'SchemaVersion\s*='){throw "Source lacks SchemaVersion: $($spec.Path)"}
  $sources[$spec.Name]=$source
}
$roadPath=Join-Path $repoRoot 'scripts\ground\OMW_GroundRoadSpawnAdapter.lua'
if(-not(Test-Path -LiteralPath $roadPath -PathType Leaf)){throw "Required GroundRoadSpawnAdapter not found: $roadPath"}
$roadSource=Get-Content -LiteralPath $roadPath -Raw -Encoding UTF8

$combined=(($moduleSpecs|ForEach-Object{$sources[$_.Name]}) -join "`n")+"`n"+$roadSource
foreach($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-6',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SUPPORT-PROFILES-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1',
  'OMW-FLIGHTPATH-NAME-CONTRACT-1','OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8','OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1',
  'CAS_CONTROLLED_RELEASE','CAS_HOME_LANDED','CAS_LEGION_ASSET_RETURNED',
  'PATROLZONE_ENGAGE','AUFTRAG:NewPATROLZONE','SetEngageDetected',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-5',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-4',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME-2',
  'OMW-FOB-THREAT-OPSZONE-ADAPTER-6',
  'INCIDENT_LOCAL_SECURITY','INSTALLATION_ATTACK_LOCAL_GUARD',
  'MOOSE_OPSZONE_RED_PRESENCE','OnAfterEvaluated','GetScannedGroupSet',
  'AUFTRAG:NewONGUARD','SetReturnToLegion(true)','cancelWhenIncidentClosed=false',
  'armyGroup:EngageTarget','OnAfterDisengage','_OMWQrfBindArmyGroup',
  'DEFAULT_ENGAGE_FORMATION = "On Road"','QRF_ENGAGE_FORMATION = "On Road"','engageFormation=QRF_ENGAGE_FORMATION',
  'sourceIncidentCoordinator','GetParticipants(true)','group:GetUnits()',
  'QRF_NO_LIVING_INCIDENT_TARGETS_IN_TACTICAL_ZONE','mission:Cancel()',
  'brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)','physicalTargetGroup',
  'ROAD_ALIGNED_WAREHOUSE_SPAWN','vehicleSpacingM','forwardCoordinate = targetCoordinate',
  'QRF_TACTICAL_RADIUS_NM = 5','accessZoneName','2438.4',
  'INSTALLATION_ATTACK_INITIAL_QRF','OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT')){
  if(-not $combined.Contains($marker)){throw "Required contract marker missing: $marker"}
}
if($sources.GuardMissionFactory.Contains('SetEngageDetected(')){throw 'Incident-local Guard must not use proactive SetEngageDetected.'}
if($sources.GuardRuntime.Contains('routeAdapter:TrackMission') -or $sources.GuardRuntime.Contains('router:Install')){throw 'Incident-local Guard runtime must not install or track a patrol route.'}
if($sources.QrfMissionFactory.Contains('local DEFAULT_ENGAGE_FORMATION = "Vee"')){throw 'QRF MissionFactory motorized march must not default to Vee.'}
if($sources.QrfRuntime.Contains('local QRF_ENGAGE_FORMATION = "Vee"')){throw 'QRF runtime must not override motorized march with Vee.'}
if(-not $sources.QrfRuntime.Contains('local QRF_ENGAGE_FORMATION = "On Road"')){throw 'QRF runtime must explicitly enforce MOOSE On Road march.'}
foreach($forbidden in @('AUFTRAG:NewGROUNDATTACK','AUFTRAG:NewPATROLZONE','EnableHuntingPatrol','SetPatrolAdInfinitum','SCHEDULER','timer.scheduleFunction')){
  if($sources.QrfMissionFactory.Contains($forbidden) -or $sources.QrfRuntime.Contains($forbidden)){throw "QRF direct-target contract forbids marker: $forbidden"}
}
foreach($forbidden in @('PATROL_TEST','roadForwardCoordinates','QRF_VALIDATED_ROAD_FORWARD_COORDINATE_UNAVAILABLE','ROAD_DIRECTION_SAMPLE_DISTANCES_M','resolveOutboundRoadCoordinate')){
  if($sources.QrfRuntime.Contains($forbidden)){throw "QRF runtime forbidden materialization dependency: $forbidden"}
}
if($combined -match '(?i)\bMIST\b|mist\.'){throw 'MIST use is forbidden in this production bundle.'}

New-Item -ItemType Directory -Path $distDir -Force|Out-Null
$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
if([string]::IsNullOrWhiteSpace($commit)){throw 'Unable to resolve Git HEAD.'}
function Embed([string]$Name,[string]$Source){"local $Name = (function()`n$Source`nend)()`n`n"}
$bundle="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Guard: no physical Guard before alarm; MOOSE OPSZONE scanned RED presence opens incident -> local ONGUARD Guard + mobile QRF; no permanent Guard patrol router.`n-- Mobile Ground QRF: road-aligned ACCESS materialization -> runtime-enforced MOOSE On Road transit in EngageTarget -> MOOSE final off-road target approach when required -> direct concrete UNIT pursuit -> Disengage/reacquire -> target exhaustion -> ReturnToLegion.`n-- External CAS: COMMANDER provider selection supports both standard MOOSE CAS and source-verified PATROLZONE + SetEngageDetected geometry selected by the caller.`n`n"
foreach($spec in $moduleSpecs){$bundle+=Embed $spec.Name $sources[$spec.Name]}
$bundle+=Embed 'RoadSpawnAdapter' $roadSource
$bundle+=@"
local Modules={
 base=Base,lifecycleAdapter=LifecycleAdapter,guardRuntime=GuardRuntime,qrfRuntime=QrfRuntime,
 legionBridge=LegionBridge,guardMissionFactory=GuardMissionFactory,qrfMissionFactory=QrfMissionFactory,
 roadSpawnAdapter=RoadSpawnAdapter,guardMaterializationAdapter=GuardMaterializationAdapter,
 guardRouteAdapter=GuardRouteAdapter,commanderBridge=CommanderBridge,artyMissionFactory=ArtyMissionFactory,
 casMissionFactory=CasMissionFactory,casLifecycleRuntime=CasLifecycleRuntime,
 flightPathNameContract=FlightPathNameContract,helicopterCorridor=HelicopterCorridor,casTacticalCorridor=CasTacticalCorridor,
 externalSupportRuntime=ExternalSupportRuntime,
 installationIncidentBridge=InstallationIncidentBridge,installationIncidentRuntime=InstallationIncidentRuntime,
 installationAttackIncident=InstallationAttackIncident,alarmEvidenceAdapter=AlarmEvidenceAdapter,
 perimeterBridge=PerimeterBridge,perimeterRuntime=PerimeterRuntime,threatAdapter=ThreatAdapter,
 resupplyMonitor=ResupplyMonitor,storageTransportFactory=StorageTransportFactory,
 transportSettlement=TransportSettlement,resupplyTransportRuntime=ResupplyTransportRuntime,
}
local Package={SchemaVersion="OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1",SiteRegistry=SiteRegistry,SupportProfiles=SupportProfiles,IdContract=IdContract,Modules=Modules,Runtime=Runtime}
function Package.New(spec)
 if type(spec)~="table" then error("[OMW][FireSupStratResupply.Package] spec must be a table",2) end
 local runtimeSpec={}; for key,value in pairs(spec) do runtimeSpec[key]=value end
 runtimeSpec.modules=Modules
 runtimeSpec.siteRegistry=runtimeSpec.siteRegistry or SiteRegistry
 runtimeSpec.supportProfiles=runtimeSpec.supportProfiles or SupportProfiles
 runtimeSpec.idContract=runtimeSpec.idContract or IdContract
 return Runtime.New(runtimeSpec)
end
OMW=OMW or {}; OMW.FireSupStratResupply=Package; OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED=1
"@
foreach($marker in @(
  'roadSpawnAdapter=RoadSpawnAdapter',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1',
  'OMW-FLIGHTPATH-NAME-CONTRACT-1','OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8','OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1',
  'CAS_CONTROLLED_RELEASE','CAS_HOME_LANDED','CAS_LEGION_ASSET_RETURNED',
  'PATROLZONE_ENGAGE','AUFTRAG:NewPATROLZONE','SetEngageDetected',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-5',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-4',
  'OMW-FOB-THREAT-OPSZONE-ADAPTER-6',
  'INCIDENT_LOCAL_SECURITY','INSTALLATION_ATTACK_LOCAL_GUARD','MOOSE_OPSZONE_RED_PRESENCE',
  'AUFTRAG:NewONGUARD','SetReturnToLegion(true)','armyGroup:EngageTarget',
  'DEFAULT_ENGAGE_FORMATION = "On Road"','QRF_ENGAGE_FORMATION = "On Road"',
  'sourceIncidentCoordinator','GetParticipants(true)','cancelWhenIncidentClosed=false',
  'brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)','physicalTargetGroup',
  'ROAD_ALIGNED_WAREHOUSE_SPAWN','vehicleSpacingM','forwardCoordinate = targetCoordinate',
  'OMW.FireSupStratResupply=Package')){
  if(-not $bundle.Contains($marker)){throw "Bundle marker missing: $marker"}
}
[System.IO.File]::WriteAllText($outputFile,$bundle,[System.Text.UTF8Encoding]::new($false))
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1'
Write-Host 'RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-9'
Write-Host 'SiteRegistrySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-6'
Write-Host 'SupportProfilesSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SUPPORT-PROFILES-4'
Write-Host 'BaseSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-4'
Write-Host 'GuardRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-3'
Write-Host 'GuardMissionFactorySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-3'
Write-Host 'QrfRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13'
Write-Host 'QrfMissionFactorySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8'
Write-Host 'CasMissionFactorySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-MISSION-FACTORY-3'
Write-Host 'CasLifecycleRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1'
Write-Host 'ExternalCasModes: CAS | PATROLZONE_ENGAGE; provider selection remains MOOSE COMMANDER-owned'
Write-Host 'CasLifecycle: shared production route/release/recovery owner; Acceptance harness must observe only'
Write-Host 'InstallationIncidentBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-5'
Write-Host 'PerimeterBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-4'
Write-Host 'ThreatAdapterSchema: OMW-FOB-THREAT-OPSZONE-ADAPTER-6'
Write-Host 'GuardActivation: no physical Guard before alarm; incident-local Guard demand on qualified RED perimeter presence'
Write-Host 'GuardMission: MOOSE ONGUARD at validated local materialization anchor; no permanent PATHLINE patrol; no proactive SetEngageDetected'
Write-Host 'GuardReturnLifecycle: authoritative incident close -> Guard Cancel -> MOOSE SetReturnToLegion/Legion lifecycle'
Write-Host 'AlarmQualification: MOOSE OPSZONE scan/GetScannedGroupSet via Evaluated callback; no custom scheduler/world scan'
Write-Host 'QrfResponsePhase: MOOSE AUFTRAG ONGUARD is recruitment/materialization anchor only'
Write-Host 'QrfTargetCycle: same physical ARMYGROUP -> nearest living known incident UNIT -> MOOSE EngageTarget dynamic pursuit -> Disengage/reacquire'
Write-Host 'QrfMovementContract: motorized QRF runtime explicitly passes MOOSE On Road to EngageTarget; Vee is forbidden for march/transit'
Write-Host 'QrfTargetAuthority: GroundInstallationAttackIncident GetParticipants(true), flattened to living UNITs and filtered to site-local 5 NM tactical zone'
Write-Host 'QrfVehicleMaterialization: approved GroundRoadSpawnAdapter; exact site ACCESS is sole materialization/home boundary; fixed 18 m spacing'
Write-Host 'QrfRoadDirection: initial physical incident target coordinate is direction input only; actual spawn positions remain constrained to ACCESS'
Write-Host 'QrfReturnLifecycle: no living authorized incident target -> mission Cancel -> MOOSE ReturnToLegion/RTZ -> Returned -> LEGION/Warehouse AddAsset'
Write-Host 'QrfReleaseAuthority: tactical completion is zero living incident targets in the tactical zone; perimeter/incident-close alone is not return authority'
Write-Host 'QrfIncidentClosePolicy: local incident/perimeter clear alone does not auto-cancel dispatched QRF'
Write-Host 'JalalabadAlarmRadius: 8000 ft / 2438.4 m'
Write-Host 'Sites: 6'
Write-Host 'MOOSERelease: 2.9.18'
Write-Host 'MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
Write-Host 'MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'
Write-Host 'OperationalAssetSelectionAuthority: MOOSE'
Write-Host 'StrategicResourceAuthority: caller-provided CampaignState/store'
Write-Host 'GuardAccessZoneDependency: none'
Write-Host 'QrfVehicleAccessZoneDependency: required and reused as MOOSE QRF homezone'
Write-Host 'PerimeterAccessZoneDependency: none'
Write-Host 'MizMutation: false'
Write-Host 'Encoding: UTF-8 without BOM'
Write-Host "BuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "BundleSHA256: $((Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "GitCommit: $commit"
