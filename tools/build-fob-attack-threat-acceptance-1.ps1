[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$demandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
$threatAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\src\01-fob-attack-threat-acceptance-1.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fob-attack-support-demand\dist'
$outputFile = Join-Path $distDir 'OMW_FOB_Attack_Threat_Acceptance_1.lua'

$builderVersion = 'FOB-ATTACK-THREAT-ACCEPTANCE-1-2'
$testId = 'FOB-ATTACK-THREAT-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @($missionDemandFile, $demandPolicyFile, $threatAdapterFile, $acceptanceSourceFile)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Stage 2 FOB attack threat acceptance source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$demandPolicy = Get-Content -LiteralPath $demandPolicyFile -Raw -Encoding UTF8
$threatAdapter = Get-Content -LiteralPath $threatAdapterFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $demandPolicy + $threatAdapter + $acceptanceSource

$requiredMarkers = @(
  'OMW-MISSION-DEMAND-1', 'CAS_IMMEDIATE', 'OMW-FOB-ATTACK-DEMAND-POLICY-1',
  'FOB_ATTACK_QUALIFIED', 'OMW-FOB-THREAT-OPSZONE-ADAPTER-1',
  'ZONE_RADIUS:New', 'OPSZONE:New', 'OnAfterAttacked', 'SetCaptureThreatlevel',
  'SetCaptureNunits', 'SetObjectCategories', 'SetUnitCategories',
  'FOB-ATTACK-THREAT-ACCEPTANCE-1', 'TPL_BLUE_GND_INF_RIFLE_SQUAD_9',
  'GROUND_NODE_FORTRESS', 'GROUND_PERSONNEL', 'BRIGADE:New', 'PLATOON:New',
  'AUFTRAG:NewONGUARD', 'GetCoordinate()', 'WH_BLUE_GND_FORTRESS',
  'BLUE_GROUND_COP_FORTRESS', 'OMW_SECURITY_BLUE_GROUND_COP_FORTRESS',
  'SECURITY_RADIUS_M = 1000', 'OPSZONE_ATTACKED', 'SCHEDULER:New'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Stage 2 FOB attack threat acceptance sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'CampaignState\.New', 'CampaignState\.Restore', 'MissionScripting\.lua',
  'mist\.', '\bMIST\b', 'world\.addEventHandler', 'timer\.scheduleFunction',
  'os\.execute', ':Teleport\s*\(', 'SPAWN:', 'AUFTRAG:NewCAS',
  'COMMANDER:AddMission', 'AIRWING', 'SQUADRON', 'TST_BLUE_GND_FORTRESS_HIT_TARGET',
  'ZON_BLUE_GND_FORTRESS_PATROL_TEST_01', 'EVENTS\.Hit', 'OMW_FobAttackHitAdapter'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern -or $threatAdapter -match $pattern) {
    throw "Stage 2 FOB attack threat acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Stage 2 FOB attack threat acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fob-attack-threat-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: existing OMW mission stack -> Fortress GROUND_PERSONNEL -> MOOSE BRIGADE/PLATOON rifle squad -> warehouse-derived 1000m runtime ZONE_RADIUS -> BLUE OPSZONE -> RED ground presence -> OPSZONE Attacked -> CAS_IMMEDIATE MissionDemand.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: pre-existing OMW.AirOps.CampaignContext already attached to OMW.Ground.Base by the mission's existing GroundBase.Attach trigger.
-- RequiredBefore: existing mission OMW_AirOps_Warehouse_Base.lua -> OMW_Ground_Base.lua -> existing GroundBase.Attach trigger -> this bundle.
-- CampaignStateCreation: false
-- PhysicalRepresentation: existing TPL_BLUE_GND_INF_RIFLE_SQUAD_9 through public BRIGADE/PLATOON/Warehouse lifecycle.
-- SecurityPerimeter: runtime ZONE_RADIUS centered on the Fortress BRIGADE/WAREHOUSE coordinate; radius 1000m; no Mission Editor security trigger required.
-- ThreatDetection: MOOSE OPSZONE owner BLUE, ground UNIT scan, defended-zone Attacked condition Nred>0 and RED threatlevel>=0, OnAfterAttacked callback.
-- CaptureSemantics: SetCaptureNunits(1) retained explicitly for the separate no-BLUE-presence capture branch; it is not the defended-zone Attacked unit threshold.
-- ExplicitExclusions: EVENTS.Hit dependency, dedicated BLUE hit target, dedicated security trigger zone, CAS dispatch, COMMANDER mission execution, AIRWING/SQUADRON dispatch, native world event handler, MIST, MissionScripting.lua mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE2_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_STAGE2_FOB_ATTACK_DEMAND_POLICY' $demandPolicy
$bundle += Embed-Module 'OMW_STAGE2_FOB_THREAT_OPSZONE_ADAPTER' $threatAdapter
$bundle += $acceptanceSource

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'RequiredBefore: existing OMW_AirOps_Warehouse_Base.lua,existing OMW_Ground_Base.lua,existing GroundBase.Attach trigger'
Write-Host 'CampaignStateAuthority: OMW.AirOps.CampaignContext'
Write-Host 'CampaignStateCreation: false'
Write-Host 'RequiresGroundBaseAttached: true'
Write-Host 'TargetModel: existing Fortress rifle squad from Ground personnel pool'
Write-Host 'Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9'
Write-Host 'PersonnelNode: GROUND_NODE_FORTRESS'
Write-Host 'PersonnelResource: GROUND_PERSONNEL'
Write-Host 'PersonnelCommitted: 9'
Write-Host 'PhysicalLifecycle: MOOSE BRIGADE/PLATOON/Warehouse'
Write-Host 'GuardMission: AUFTRAG NewONGUARD at runtime Fortress warehouse coordinate'
Write-Host 'SecurityZone: OMW_SECURITY_BLUE_GROUND_COP_FORTRESS'
Write-Host 'SecurityRadiusM: 1000'
Write-Host 'SecurityZoneSource: runtime ZONE_RADIUS from Fortress warehouse coordinate'
Write-Host 'MissionEditorSecurityZoneRequired: false'
Write-Host 'ThreatDetection: MOOSE OPSZONE OnAfterAttacked'
Write-Host 'ThreatObjectCategory: UNIT'
Write-Host 'ThreatUnitCategory: GROUND_UNIT'
Write-Host 'AttackedCondition: Nred>0 and RED aggregate threat>=0 while BLUE presence remains'
Write-Host 'CaptureNunits: 1 (separate capture branch)'
Write-Host 'ThreatCaptureThreatlevel: 0'
Write-Host 'ThreatScanSeconds: 5'
Write-Host 'InstallationId: BLUE_GROUND_COP_FORTRESS'
Write-Host 'RequiredPhysicalHits: 0'
Write-Host 'ExpectedDemandType: CAS_IMMEDIATE'
Write-Host 'ExpectedFirstCreate: true'
Write-Host 'ExpectedActiveDemandCount: 1'
Write-Host 'ActiveDuplicateContract: covered by mission-demand CI; no second DCS hit required'
Write-Host 'CASDispatch: false'
Write-Host 'NativeWorldEventHandler: false'
Write-Host 'DedicatedBlueHitTargetRequired: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
