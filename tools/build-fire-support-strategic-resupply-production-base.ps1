[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist'
$outputFile = Join-Path $distDir 'OMW_FireSupStratResupply_Base.lua'
$builderVersion = 'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-3'

$moduleSpecs = @(
  @{ Name='SiteRegistry'; Path='scripts\campaign\OMW_FireSupStratResupply_SiteRegistry.lua' },
  @{ Name='SupportProfiles'; Path='scripts\campaign\OMW_FireSupStratResupply_SupportProfiles.lua' },
  @{ Name='IdContract'; Path='scripts\campaign\OMW_FireSupStratResupply_IdContract.lua' },
  @{ Name='Base'; Path='scripts\campaign\OMW_FireSupStratResupply_Base.lua' },
  @{ Name='LifecycleAdapter'; Path='scripts\campaign\OMW_FireSupStratResupply_LifecycleAdapter.lua' },
  @{ Name='LegionBridge'; Path='scripts\campaign\OMW_FireSupStratResupply_LegionBridge.lua' },
  @{ Name='GuardMissionFactory'; Path='scripts\campaign\OMW_FireSupStratResupply_GuardMissionFactory.lua' },
  @{ Name='GuardRuntime'; Path='scripts\campaign\OMW_FireSupStratResupply_GuardRuntime.lua' },
  @{ Name='QrfMissionFactory'; Path='scripts\campaign\OMW_FireSupStratResupply_QrfMissionFactory.lua' },
  @{ Name='QrfRuntime'; Path='scripts\campaign\OMW_FireSupStratResupply_QrfRuntime.lua' },
  @{ Name='CommanderBridge'; Path='scripts\campaign\OMW_FireSupStratResupply_CommanderBridge.lua' },
  @{ Name='ArtyMissionFactory'; Path='scripts\campaign\OMW_FireSupStratResupply_ArtyMissionFactory.lua' },
  @{ Name='CasMissionFactory'; Path='scripts\campaign\OMW_FireSupStratResupply_CasMissionFactory.lua' },
  @{ Name='ExternalSupportRuntime'; Path='scripts\campaign\OMW_FireSupStratResupply_ExternalSupportRuntime.lua' },
  @{ Name='InstallationIncidentBridge'; Path='scripts\campaign\OMW_FireSupStratResupply_InstallationIncidentBridge.lua' },
  @{ Name='InstallationIncidentRuntime'; Path='scripts\campaign\OMW_FireSupStratResupply_InstallationIncidentRuntime.lua' },
  @{ Name='PerimeterBridge'; Path='scripts\campaign\OMW_FireSupStratResupply_PerimeterBridge.lua' },
  @{ Name='PerimeterRuntime'; Path='scripts\campaign\OMW_FireSupStratResupply_PerimeterRuntime.lua' },
  @{ Name='ResupplyMonitor'; Path='scripts\campaign\OMW_FireSupStratResupply_ResupplyMonitor.lua' },
  @{ Name='StorageTransportFactory'; Path='scripts\campaign\OMW_FireSupStratResupply_StorageTransportFactory.lua' },
  @{ Name='TransportSettlement'; Path='scripts\campaign\OMW_FireSupStratResupply_TransportSettlement.lua' },
  @{ Name='ResupplyTransportRuntime'; Path='scripts\campaign\OMW_FireSupStratResupply_ResupplyTransportRuntime.lua' },
  @{ Name='InstallationAttackIncident'; Path='scripts\ground\OMW_GroundInstallationAttackIncident.lua' },
  @{ Name='ThreatAdapter'; Path='scripts\ground\OMW_FobThreatOpsZoneAdapter.lua' },
  @{ Name='GuardMaterializationAdapter'; Path='scripts\ground\OMW_GuardPathlineMaterializationAdapter.lua' },
  @{ Name='GuardRouteAdapter'; Path='scripts\ground\OMW_GuardPathlineRouteAdapter.lua' },
  @{ Name='Runtime'; Path='scripts\campaign\OMW_FireSupStratResupply_Runtime.lua' }
)

$sources = @{}
foreach ($spec in $moduleSpecs) {
  $file = Join-Path $repoRoot $spec.Path
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required Fire Support / Strategic Resupply source not found: $file" }
  $source = Get-Content -LiteralPath $file -Raw -Encoding UTF8
  if ($source -notmatch 'SchemaVersion\s*=') { throw "Source $($spec.Path) does not expose a SchemaVersion contract." }
  $sources[$spec.Name] = $source
}

$combined = ($moduleSpecs | ForEach-Object { $sources[$_.Name] }) -join "`n"
$requiredSourceMarkers = @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-7',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-MISSION-FACTORY-2',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-RUNTIME-2',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-2',
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-2',
  'SetRequiredAttribute',
  'OMW-GUARD-PATHLINE-MATERIALIZATION-ADAPTER-1',
  'PATHLINE_FIRST_SEGMENT',
  'INSTALLATION_ATTACK_INITIAL_QRF',
  'GROUND_RESUPPLY',
  'AIR_RESUPPLY'
)
foreach ($marker in $requiredSourceMarkers) {
  if (-not $combined.Contains($marker)) { throw "Fire Support / Strategic Resupply sources are missing required contract marker: $marker" }
}

$forbiddenPatterns = @('MissionScripting\.lua','mist\.','MIST','os\.execute')
foreach ($pattern in $forbiddenPatterns) {
  if ($combined -match $pattern) { throw "Fire Support / Strategic Resupply production sources contain forbidden pattern: $pattern" }
}

$guardAndPerimeterSource = @(
  $sources.GuardMissionFactory,$sources.GuardRuntime,$sources.GuardMaterializationAdapter,
  $sources.GuardRouteAdapter,$sources.PerimeterBridge,$sources.PerimeterRuntime,$sources.ThreatAdapter
) -join "`n"
if ($guardAndPerimeterSource -match 'ZON_BLUE_GND_[A-Z_]+_ACCESS') {
  throw 'Guard/perimeter production sources must not depend on convoy ACCESS zones.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) { Remove-Item -LiteralPath $outputFile -Force }

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD for Fire Support / Strategic Resupply production build.' }

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fire-support-strategic-resupply-production-base.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- Scope: generic six-site Fire Support / Strategic Resupply production composition package.
-- MOOSE release: 2.9.18
-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
-- Operational asset selection/recruitment authority: MOOSE organisation and mission/transport lifecycle.
-- Strategic persistence/resource authority: caller-provided CampaignState/store only.
-- Tactical geometry: caller-provided resolvers/configuration; no alarm radii, QRF coordinates, CAS geometry or resupply routes are invented by this package.
-- Guard/QRF capability constraints: caller-provided requirements are forwarded to public MOOSE AUFTRAG recruitment filters; OMW does not select assets.
-- Guard materialization: owner-approved narrow exact-geometry exception only; all other Guard lifecycle remains MOOSE BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG.
-- ACCESS zones: convoy/access contract only; forbidden from Guard and perimeter composition.
-- Perimeter clear/OPSZONE Defeated: evidence state only; does not close an installation incident.

"@

function Embed-Module([string]$Name, [string]$Source) { return "local $Name = (function()`n$Source`nend)()`n`n" }

$bundle = $header
foreach ($spec in $moduleSpecs) { $bundle += Embed-Module $spec.Name $sources[$spec.Name] }

$bundle += @"
local Modules = {
  base = Base,
  lifecycleAdapter = LifecycleAdapter,
  guardRuntime = GuardRuntime,
  qrfRuntime = QrfRuntime,
  legionBridge = LegionBridge,
  guardMissionFactory = GuardMissionFactory,
  qrfMissionFactory = QrfMissionFactory,
  guardMaterializationAdapter = GuardMaterializationAdapter,
  guardRouteAdapter = GuardRouteAdapter,
  commanderBridge = CommanderBridge,
  artyMissionFactory = ArtyMissionFactory,
  casMissionFactory = CasMissionFactory,
  externalSupportRuntime = ExternalSupportRuntime,
  installationIncidentBridge = InstallationIncidentBridge,
  installationIncidentRuntime = InstallationIncidentRuntime,
  installationAttackIncident = InstallationAttackIncident,
  perimeterBridge = PerimeterBridge,
  perimeterRuntime = PerimeterRuntime,
  threatAdapter = ThreatAdapter,
  resupplyMonitor = ResupplyMonitor,
  storageTransportFactory = StorageTransportFactory,
  transportSettlement = TransportSettlement,
  resupplyTransportRuntime = ResupplyTransportRuntime,
}

local Package = {
  SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1",
  SiteRegistry = SiteRegistry,
  SupportProfiles = SupportProfiles,
  IdContract = IdContract,
  Modules = Modules,
  Runtime = Runtime,
}

function Package.New(spec)
  if type(spec) ~= "table" then error("[OMW][FireSupStratResupply.Package] spec must be a table", 2) end
  local runtimeSpec = {}
  for key, value in pairs(spec) do runtimeSpec[key] = value end
  runtimeSpec.modules = Modules
  runtimeSpec.siteRegistry = runtimeSpec.siteRegistry or SiteRegistry
  runtimeSpec.supportProfiles = runtimeSpec.supportProfiles or SupportProfiles
  runtimeSpec.idContract = runtimeSpec.idContract or IdContract
  return Runtime.New(runtimeSpec)
end

OMW = OMW or {}
OMW.FireSupStratResupply = Package
OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED = 1
"@

$bundleMarkers = @(
  'SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1"',
  'runtimeSpec.modules = Modules',
  'runtimeSpec.siteRegistry = runtimeSpec.siteRegistry or SiteRegistry',
  'installationAttackIncident = InstallationAttackIncident',
  'guardMaterializationAdapter = GuardMaterializationAdapter',
  'guardRequiredAttributes = spec.guardRequiredAttributes',
  'qrfRequiredAttributes = spec.qrfRequiredAttributes',
  'threatAdapter = ThreatAdapter',
  'resupplyTransportRuntime = ResupplyTransportRuntime',
  'OMW.FireSupStratResupply = Package',
  'OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED = 1'
)
foreach ($marker in $bundleMarkers) {
  if (-not $bundle.Contains($marker)) { throw "Fire Support / Strategic Resupply production bundle is missing contract marker: $marker" }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()
$builderHash = (Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1"
Write-Host "RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-7"
Write-Host "Sites: 6"
Write-Host "MOOSERelease: 2.9.18"
Write-Host "MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
Write-Host "MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
Write-Host "OperationalAssetSelectionAuthority: MOOSE"
Write-Host "GuardQRFRecruitmentConstraintAuthority: MOOSE AUFTRAG/LEGION"
Write-Host "StrategicResourceAuthority: caller-provided CampaignState/store"
Write-Host "GuardAccessZoneDependency: none"
Write-Host "PerimeterAccessZoneDependency: none"
Write-Host "PerimeterClearClosesIncident: false"
Write-Host "MissionSpecificGeometryInjected: true"
Write-Host "MOOSEOverride: Guard materialization exact-geometry exception only"
Write-Host "MizMutation: false"
Write-Host "Encoding: UTF-8 without BOM"
Write-Host "BuilderSHA256: $builderHash"
Write-Host "BundleSHA256: $bundleHash"
Write-Host "GitCommit: $commit"
