[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$materializerFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundSupportMaterializer.lua'
$fixedSupportFile = Join-Path $repoRoot 'scripts\ground\OMW_FixedFireSupportAmmoSupport.lua'
$rearmAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
$fixedRearmFile = Join-Path $repoRoot 'scripts\ground\OMW_FixedFireSupportAmmoRearmService.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\ground-ammo-rearm-integration\src\02-fixed-fire-support-combined-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-ammo-rearm-integration\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Fire_Support_Acceptance_2.lua'

$builderVersion = 'GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7'
$testId = 'GROUND-FIRE-SUPPORT-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @($materializerFile,$fixedSupportFile,$rearmAdapterFile,$fixedRearmFile,$harnessFile)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required Ground fire-support acceptance source not found: $file" }
}

$materializer = Get-Content -LiteralPath $materializerFile -Raw -Encoding UTF8
$fixedSupport = Get-Content -LiteralPath $fixedSupportFile -Raw -Encoding UTF8
$rearmAdapter = Get-Content -LiteralPath $rearmAdapterFile -Raw -Encoding UTF8
$fixedRearm = Get-Content -LiteralPath $fixedRearmFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8
$combined = $materializer + $fixedSupport + $rearmAdapter + $fixedRearm + $harness

$requiredMarkers = @(
  'GROUND-FIRE-SUPPORT-ACCEPTANCE-2',
  'WH_BLUE_GND_BOSTICK','WH_BLUE_GND_WRIGHT','WH_BLUE_GND_FORTRESS','WH_BLUE_GND_HONAKER',
  'ZON_BLUE_GND_BOSTICK_RESUPPLY','ZON_BLUE_GND_WRIGHT_RESUPPLY','ZON_BLUE_GND_FORTRESS_RESUPPLY','ZON_BLUE_GND_HONAKER_RESUPPLY',
  'ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET','ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET','ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET','ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET',
  'TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2','TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2','TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1','TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2',
  'TPL_BLUE_GND_SUP_M1083','TPL_BLUE_GND_SUP_M939','GROUND_NODE_BOSTICK','GROUND_NODE_WRIGHT','GROUND_NODE_FORTRESS','GROUND_NODE_HONAKER','GROUND_AMMO_PACKAGE',
  'ARTY:New(','AssignTargetCoord(','GetAmmo(','SetRearmingGroup','SetSpawnZone(','ReturnToStock','AddAsset(',
  'OnAfterCeaseFire','OnAfterRearmed','startArty = false','onRoad = false','WAREHOUSE.Descriptor.GROUPNAME','PLATOON:New(','BRIGADE:New(',
  'OMW_GROUND_READY','OMW.Ground.Base.GetContext()','SITE_REARMED site=','SITE_SUPPORT_RETURNED site=','SITE_PASS site=','FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true',
  'HONAKER_AMMO_DEPLETED','HONAKER_REARM_REQUEST_AFTER_EMPTY','HONAKER_AMMO_NOT_DEPLETED'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) { throw "Ground fire-support acceptance sources are missing required marker: $marker" }
}

$forbiddenPatterns = @('MissionScripting\.lua','world\.addEventHandler','timer\.scheduleFunction','mist\.','MIST','(?<![A-Za-z0-9_])io\.','lfs\.','os\.execute',':Teleport\s*\(','LoadBackAssetInPosition','SpawnFromCoordinate','AMMOTRUCK:','_DATABASE:Spawn\s*\(','_SpawnAssetGroundNaval')
foreach ($pattern in $forbiddenPatterns) {
  if ($combined -match $pattern) { throw "Ground fire-support acceptance sources contain forbidden pattern: $pattern" }
}

if ($fixedSupport -notmatch 'brigade:SetSpawnZone\(spawnZone, spawnZoneMaxDistanceM\)') { throw 'Fixed fire-support support module must use public WAREHOUSE SetSpawnZone.' }
if ($fixedSupport -match 'brigade\s*:\s*SetValidateAndRepositionGroundUnits\s*\(') { throw 'Fixed fire-support support module must not call the broken pinned-MOOSE SetValidateAndRepositionGroundUnits path.' }
if ($materializer -notmatch 'self\.brigade:AddAsset\(target\)') { throw 'Ground support materializer must return the known group through WAREHOUSE AddAsset.' }
if ($rearmAdapter -notmatch 'if startArty then\s+arty:Start\(\)') { throw 'Ground ammo rearm adapter is missing the guarded ARTY Start path.' }
if ($fixedRearm -notmatch 'SCHEDULER:New') { throw 'Fixed fire-support rearm service must use the MOOSE SCHEDULER return watcher.' }
if ($harness -notmatch 'startArty\s*=\s*false') { throw 'Combined acceptance harness must preserve prestarted ARTY full-ammo baselines.' }
if ($harness -notmatch 'onRoad\s*=\s*false') { throw 'Combined acceptance harness must keep local support movement independent of roads.' }
if ($harness -notmatch 'for _, spec in ipairs\(SITE_SPECS\) do\s+startSite') { throw 'Combined acceptance harness must launch all configured site legs in the same run.' }
if ($harness -notmatch 'id\s*=\s*"BOSTICK"[\s\S]*?supportTemplate\s*=\s*"TPL_BLUE_GND_SUP_M1083"[\s\S]*?fireShells\s*=\s*DEFAULT_FIRE_SHELLS') { throw 'Bostick must remain on the four-round M1083 regression path.' }
if ($harness -notmatch 'id\s*=\s*"WRIGHT"[\s\S]*?supportTemplate\s*=\s*"TPL_BLUE_GND_SUP_M1083"[\s\S]*?fireShells\s*=\s*DEFAULT_FIRE_SHELLS') { throw 'Wright must remain on the four-round M1083 regression path.' }
if ($harness -notmatch 'id\s*=\s*"FORTRESS"[\s\S]*?supportTemplate\s*=\s*"TPL_BLUE_GND_SUP_M1083"[\s\S]*?fireShells\s*=\s*DEFAULT_FIRE_SHELLS') { throw 'Fortress must remain on the four-round M1083 regression path.' }
if ($harness -notmatch 'id\s*=\s*"HONAKER"[\s\S]*?supportTemplate\s*=\s*"TPL_BLUE_GND_SUP_M939"[\s\S]*?fireShells\s*=\s*40[\s\S]*?requireAmmoDepleted\s*=\s*true') { throw 'Honaker must use M939 and require full 40-round depletion before rearm.' }
if ($harness -notmatch 'templateName\s*=\s*spec\.supportTemplate') { throw 'Combined acceptance harness must pass the site-specific support template into the MOOSE materializer.' }
if ($harness -notmatch 'siteState\.postFireAmmo\s*~=\s*0') { throw 'Honaker empty-rearm diagnostic must block support request unless post-fire ammo is exactly zero.' }
if ($harness -notmatch 'siteState\.spec\.fireShells') { throw 'Combined acceptance harness must use the per-site fire-shell count.' }

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) { Remove-Item -LiteralPath $outputFile -Force }

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD for Ground fire-support acceptance build.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-fire-support-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: concurrent Bostick/Wright/Fortress L118 four-round M1083 regression legs plus Honaker 2B11 full-ammo-depletion M939 diagnostic -> support request only after Honaker reaches zero ammo -> local Warehouse self-request materialization -> CampaignState GROUND_AMMO_PACKAGE consumption -> MOOSE ARTY RearmingGroup rearm -> MOOSE ARTY physical support return -> WAREHOUSE AddAsset return-to-stock -> per-site and aggregate confirmation.
-- Diagnostic variable: Honaker fires all 40 observed 2B11 rounds and must report post-fire ammo exactly zero before TPL_BLUE_GND_SUP_M939 can be requested. The three L118 control legs remain four-round M1083 tests.
-- Strategic authority: existing OMW.Ground.Base authoritative CampaignState store only.
-- Ground spawn: public MOOSE WAREHOUSE SetSpawnZone only; the pinned-MOOSE SetValidateAndRepositionGroundUnits path is excluded because its UTILS.GetCenterPoint dependency is missing at runtime. No private road-spawn override is used.
-- Support cleanup: public MOOSE ARTY return movement plus WAREHOUSE AddAsset after physical return confirmation.
-- MIZ mutation: false. Safe target geometry and local support spawn geometry must be supplied by the named Mission Editor zones.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

function Embed-Module([string]$Name, [string]$Source) { return "local $Name = (function()`n$Source`nend)()`n`n" }

$bundle = $header
$bundle += Embed-Module 'GroundSupportMaterializer' $materializer
$bundle += Embed-Module 'FixedFireSupportAmmoSupport' $fixedSupport
$bundle += Embed-Module 'GroundAmmoRearmAdapter' $rearmAdapter
$bundle += Embed-Module 'FixedFireSupportAmmoRearmService' $fixedRearm
$bundle += $harness

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Sites: BOSTICK,WRIGHT,FORTRESS,HONAKER"
Write-Host "BostickBattery: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2"
Write-Host "WrightBattery: TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2"
Write-Host "FortressBattery: TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1"
Write-Host "HonakerBattery: TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2"
Write-Host "BostickSupportTemplate: TPL_BLUE_GND_SUP_M1083"
Write-Host "WrightSupportTemplate: TPL_BLUE_GND_SUP_M1083"
Write-Host "FortressSupportTemplate: TPL_BLUE_GND_SUP_M1083"
Write-Host "HonakerSupportTemplate: TPL_BLUE_GND_SUP_M939"
Write-Host "StrategicResource: GROUND_AMMO_PACKAGE"
Write-Host "StrategicQuantityPerSite: 1"
Write-Host "StandardFireShells: 4"
Write-Host "HonakerFireShells: 40"
Write-Host "HonakerRequireAmmoDepleted: true"
Write-Host "ConcurrentSiteLegs: true"
Write-Host "PrestartedARTYPreserved: true"
Write-Host "LocalWarehouseSpawnZones: true"
Write-Host "ValidateAndRepositionGroundUnits: false"
Write-Host "PinnedMooseRepositionDefectGuard: true"
Write-Host "ApprovedRoadSpawnException: false"
Write-Host "SupportReturnToStock: true"
Write-Host "HonakerM939Diagnostic: true"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
