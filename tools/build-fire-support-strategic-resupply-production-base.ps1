[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$distDir=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist'
$outputFile=Join-Path $distDir 'OMW_FireSupStratResupply_Base.lua'
$builderVersion='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-14'

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
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-11',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-6',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-3',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME-2',
  'AUFTRAG:NewONGUARD','SetEngageDetected','SetReturnToLegion(true)','cancelWhenIncidentClosed=false',
  'AUFTRAG:NewPATROLZONE','SetPatrolAdInfinitum(true)','EnableHuntingPatrol','DisableHuntingPatrol',
  'brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)','physicalTargetGroup',
  'ROAD_ALIGNED_WAREHOUSE_SPAWN','vehicleSpacingM','forwardCoordinate = targetCoordinate',
  'QRF_TACTICAL_RADIUS_NM = 5','QRF_ENGAGE_RANGE_NM = 5','QRF_CLEARANCE_SCAN_INTERVAL_SECONDS = 5','accessZoneName','2438.4',
  'INSTALLATION_ATTACK_INITIAL_QRF','OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT')){
  if(-not $combined.Contains($marker)){throw "Required contract marker missing: $marker"}
}
if($sources.QrfMissionFactory.Contains('AUFTRAG:NewGROUNDATTACK')){throw 'QRF MissionFactory must not substitute GROUNDATTACK for the accepted Honaker ONGUARD contract.'}
foreach($forbidden in @('PATROL_TEST','roadForwardCoordinates','QRF_VALIDATED_ROAD_FORWARD_COORDINATE_UNAVAILABLE','ROAD_DIRECTION_SAMPLE_DISTANCES_M','resolveOutboundRoadCoordinate')){
  if($sources.QrfRuntime.Contains($forbidden)){throw "QRF runtime forbidden materialization dependency: $forbidden"}
}
if($combined -match '(?i)\bMIST\b|mist\.'){throw 'MIST use is forbidden in this production bundle.'}

New-Item -ItemType Directory -Path $distDir -Force|Out-Null
$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
if([string]::IsNullOrWhiteSpace($commit)){throw 'Unable to resolve Git HEAD.'}
function Embed([string]$Name,[string]$Source){"local $Name = (function()`n$Source`nend)()`n`n"}
$bundle="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Mobile Ground QRF: ONGUARD + SetEngageDetected response, then same-group PATROLZONE + HuntingPatrol clearance; exact site ACCESS remains materialization/home boundary; explicit Supported-Element/C2 release remains sole return authority.`n`n"
foreach($spec in $moduleSpecs){$bundle+=Embed $spec.Name $sources[$spec.Name]}
$bundle+=Embed 'RoadSpawnAdapter' $roadSource
$bundle+=@"
local Modules={
 base=Base,lifecycleAdapter=LifecycleAdapter,guardRuntime=GuardRuntime,qrfRuntime=QrfRuntime,
 legionBridge=LegionBridge,guardMissionFactory=GuardMissionFactory,qrfMissionFactory=QrfMissionFactory,
 roadSpawnAdapter=RoadSpawnAdapter,guardMaterializationAdapter=GuardMaterializationAdapter,
 guardRouteAdapter=GuardRouteAdapter,commanderBridge=CommanderBridge,artyMissionFactory=ArtyMissionFactory,
 casMissionFactory=CasMissionFactory,externalSupportRuntime=ExternalSupportRuntime,
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
foreach($marker in @('roadSpawnAdapter=RoadSpawnAdapter','OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-11','OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-6','AUFTRAG:NewONGUARD','SetEngageDetected','SetReturnToLegion(true)','AUFTRAG:NewPATROLZONE','SetPatrolAdInfinitum(true)','EnableHuntingPatrol','DisableHuntingPatrol','cancelWhenIncidentClosed=false','brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)','physicalTargetGroup','ROAD_ALIGNED_WAREHOUSE_SPAWN','vehicleSpacingM','forwardCoordinate = targetCoordinate','OMW.FireSupStratResupply=Package')){if(-not $bundle.Contains($marker)){throw "Bundle marker missing: $marker"}}
[System.IO.File]::WriteAllText($outputFile,$bundle,[System.Text.UTF8Encoding]::new($false))
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1'
Write-Host 'RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8'
Write-Host 'SiteRegistrySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-6'
Write-Host 'QrfRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-11'
Write-Host 'QrfMissionFactorySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-6'
Write-Host 'InstallationIncidentBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-3'
Write-Host 'PerimeterBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-3'
Write-Host 'QrfResponsePhase: MOOSE AUFTRAG ONGUARD + SetEngageDetected in site-local 5 NM tactical zone'
Write-Host 'QrfClearancePhase: same physical ARMYGROUP -> MOOSE PATROLZONE + EnableHuntingPatrol in the same tactical zone'
Write-Host 'QrfVehicleMaterialization: approved GroundRoadSpawnAdapter; exact site ACCESS is sole materialization/home boundary; fixed 18 m spacing'
Write-Host 'QrfRoadDirection: physical incident target coordinate is direction input only; actual spawn positions remain constrained to ACCESS'
Write-Host 'QrfReturnLifecycle: explicit Supported-Element/C2 release -> clearance cancel -> MOOSE SetReturnToLegion/RTZ -> Returned -> LEGION/Warehouse AddAsset'
Write-Host 'QrfReleaseAuthority: explicit supported-element/C2 release only; movement/perimeter/incident state has no mission-end authority'
Write-Host 'QrfIncidentClosePolicy: local incident/perimeter clear does not auto-cancel dispatched QRF'
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