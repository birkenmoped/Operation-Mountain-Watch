[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundStartup.lua'
$distDir = Join-Path $repoRoot 'mission\ground-operations\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Startup.lua'
$builderVersion = 'OMW-GROUND-STARTUP-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required Ground startup source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
$requiredMarkers = @(
  'OMW-GROUND-STARTUP-1',
  'OMW_WAREHOUSE_READY',
  'OMW_GROUND_READY',
  'OMW.AirOps.CampaignContext',
  'OMW.Ground.Base',
  'groundBase.Attach',
  'groundBase.GetContext'
)
foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "Ground startup source is missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'CampaignState\.New',
  'CampaignState\.Restore',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'mist\.',
  '\bMIST\b',
  'MissionScripting\.lua',
  'SPAWN:',
  ':Teleport\s*\('
)
foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "Ground startup source contains forbidden pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Ground startup build.'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-startup.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- Scope: attach OMW_Ground_Base.lua to the single OMW.AirOps.CampaignContext created by OMW_AirOps_Warehouse_Base.lua.
-- CampaignStateCreation: false
-- PhysicalLifecycleMutation: false
-- MizMutation: false

"@

$bundle = $header
$bundle += "local OMW_GROUND_STARTUP = (function()`n" + $source + "`nend)()`n`n"
$bundle += @"
OMW = OMW or {}
OMW.Ground = OMW.Ground or {}
OMW.Ground.Startup = OMW_GROUND_STARTUP
OMW_GROUND_STARTUP.Start()
"@

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()
$sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "GitCommit: $commit"
Write-Host 'RequiresBefore: OMW_AirOps_Warehouse_Base.lua,OMW_Ground_Base.lua'
Write-Host 'CampaignStateAuthority: OMW.AirOps.CampaignContext'
Write-Host 'CampaignStateCreation: false'
Write-Host 'GroundAttach: true'
Write-Host 'ExpectedReadyFlags: OMW_WAREHOUSE_READY=1,OMW_GROUND_READY=1'
Write-Host 'MizMutation: false'
Write-Host "SourceSHA256: $sourceHash"
Write-Host "SHA256: $hash"
