[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$groundStockFile = Join-Path $repoRoot 'scripts\logistics\OMW_GroundInitialStock.lua'
$adapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundCampaignStateAdapter.lua'
$integrationFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRuntimeIntegration.lua'
$baseFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundBase.lua'
$distDir = Join-Path $repoRoot 'mission\ground-operations\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Base.lua'

$builderVersion = 'OMW-GROUND-PRODUCTION-BASE-2'

$files = @(
  $groundStockFile,
  $adapterFile,
  $integrationFile,
  $baseFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Ground production source not found: $file"
  }
}

$groundStock = Get-Content -LiteralPath $groundStockFile -Raw -Encoding UTF8
$adapter = Get-Content -LiteralPath $adapterFile -Raw -Encoding UTF8
$integration = Get-Content -LiteralPath $integrationFile -Raw -Encoding UTF8
$groundBase = Get-Content -LiteralPath $baseFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'OMW-GROUND-INITIAL-STOCK-2',
  'GROUND_SUPPLY_PACKAGE',
  'GROUND_AMMO_PACKAGE',
  'GROUND_FUEL_PACKAGE',
  'OMW-GROUND-RUNTIME-INTEGRATION-1',
  'OMW-GROUND-PRODUCTION-BASE-1',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_FORTRESS',
  'GROUND_NODE_JOYCE',
  'GROUND_NODE_WRIGHT',
  'GROUND_NODE_HONAKER',
  'GROUND_NODE_BOSTICK',
  '1 physical vehicle = 1 VEHICLE + 3 PERSONNEL',
  'ReconcileRestore',
  'CreditResourceOnce',
  'GroundRuntimeIntegration.Attach',
  'GroundBase.Attach'
)
$combined = $groundStock + $adapter + $integration + $groundBase
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Ground production sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'mist\.',
  'MIST',
  '(?<![A-Za-z0-9_])io\.',
  'lfs\.',
  'os\.execute',
  ':Teleport\s*\(',
  '_DATABASE',
  'SPAWN:',
  'BRIGADE:',
  'WAREHOUSE:'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($combined -match $pattern) {
    throw "Ground production base contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Ground production build.'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-production-base.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- Scope: production packaging of the accepted six-node ARMY Ground strategic foundation.
-- Strategic authority: caller-provided single CampaignState store only.
-- MOOSE/DCS lifecycle: none created by this package.
-- Fixed ARTY/mortar and reusable DCS templates remain Mission Editor assets and are not spawned here.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'GroundInitialStock' $groundStock
$bundle += Embed-Module 'GroundCampaignStateAdapter' $adapter
$bundle += Embed-Module 'GroundRuntimeIntegration' $integration
$bundle += Embed-Module 'GroundBase' $groundBase
$bundle += @"
GroundBase.Configure({
  groundInitialStock = GroundInitialStock,
  groundCampaignStateAdapter = GroundCampaignStateAdapter,
  groundRuntimeIntegration = GroundRuntimeIntegration,
})

OMW = OMW or {}
OMW.Ground = OMW.Ground or {}
OMW.Ground.Base = GroundBase
OMW_GROUND_BASE_LOADED = 1
OMW_GROUND_READY = 0

local GroundBaseAttach = GroundBase.Attach
GroundBase.Attach = function(spec)
  local context = GroundBaseAttach(spec)
  OMW_GROUND_READY = 1
  return context
end

"@

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "GroundBaseSchema: OMW-GROUND-PRODUCTION-BASE-1"
Write-Host "GroundInitialStockSchema: OMW-GROUND-INITIAL-STOCK-2"
Write-Host "GroundTransferableResources: GROUND_SUPPLY_PACKAGE,GROUND_AMMO_PACKAGE,GROUND_FUEL_PACKAGE"
Write-Host "GroundNodes: GROUND_NODE_JALALABAD,GROUND_NODE_FORTRESS,GROUND_NODE_JOYCE,GROUND_NODE_WRIGHT,GROUND_NODE_HONAKER,GROUND_NODE_BOSTICK"
Write-Host "MotorizedPatrolContract: 1 M-ATV = 1 VEHICLE + 3 PERSONNEL"
Write-Host "StrategicAuthority: caller-provided single CampaignState store"
Write-Host "GroundBaseLoadedFlag: OMW_GROUND_BASE_LOADED=1"
Write-Host "GroundReadyFlag: OMW_GROUND_READY becomes 1 only after successful OMW.Ground.Base.Attach(...)"
Write-Host "GroundLifecycleMutation: false"
Write-Host "MOOSEOverride: false"
Write-Host "MizMutation: false"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
