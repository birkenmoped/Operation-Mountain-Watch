[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_ProductionBootstrap.lua'
$resourceDemandPolicy = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$outputDir = Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist'
$output = Join-Path $outputDir 'OMW_FireSupStratResupply_Production.lua'
$builderVersion = 'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-2'

foreach ($file in @($source, $resourceDemandPolicy)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required source not found: $file"
  }
}

$bootstrap = Get-Content -LiteralPath $source -Raw -Encoding UTF8
$policy = Get-Content -LiteralPath $resourceDemandPolicy -Raw -Encoding UTF8

foreach ($marker in @(
  'OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-2',
  'OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED',
  'requireUserFlag("OMW_WAREHOUSE_READY", 1)',
  'requireUserFlag("OMW_GROUND_READY", 1)',
  'OMW.Ground.Base.GetContext',
  'OMW.Ground.Base.GetInitialStock',
  'COMMANDER:New',
  'commander:AddAirwing',
  'artyRealAssetRegistry.New',
  'runtime:StartPerimeters',
  'runtime:StartSite',
  'OMW_FSSR_READY',
  'OMW_FSSR_RESUPPLY_READY',
  'PRODUCTION_PHYSICAL_TRANSPORT_DESCRIPTOR_REQUIRED'
)) {
  if (-not $bootstrap.Contains($marker)) {
    throw "Production bootstrap marker missing: $marker"
  }
}

foreach ($forbidden in @(
  'BadGuys_A3_',
  'AUTHORITATIVE_SHORTAGE_PRECONDITION',
  'SPAWNSTATIC:NewFromType',
  'RouteGroundTo(',
  'MESSAGE:New(',
  'SCHEDULER:New(',
  '[PASS]',
  '[FAIL]',
  'mist.',
  'MIST',
  'AssignSquadrons(',
  'AIRWING:AddMission('
)) {
  if ($bootstrap.Contains($forbidden)) {
    throw "Production bootstrap forbidden Acceptance/parallel-authority marker: $forbidden"
  }
}

if (-not $policy.Contains('OMW-RESOURCE-DEMAND-POLICY-1')) {
  throw 'ResourceDemandPolicy schema marker missing.'
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD.'
}

$nl = [Environment]::NewLine
$header = '-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.' + $nl
$header += '-- BuilderVersion: ' + $builderVersion + $nl
$header += '-- GitCommit: ' + $commit + $nl
$header += '-- MOOSE release: 2.9.18' + $nl
$header += '-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54' + $nl
$header += '-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915' + $nl
$header += '-- Role: mission-specific production bootstrap for the separately loaded OMW_FireSupStratResupply_Base.lua package.' + $nl
$header += '-- Strategic Resupply physical transport mapping remains fail-closed unless injected through OMW.FireSupStratResupplyProductionConfig.resupply.' + $nl
$header += '-- MizMutation: false' + $nl + $nl

function Embed([string]$Name, [string]$SourceText) {
  return "local $Name = (function()" + $nl + $SourceText + $nl + "end)()" + $nl + $nl
}

$bundle = $header
$bundle += Embed 'ResourceDemandPolicy' $policy
$bundle += Embed 'ProductionBootstrap' $bootstrap
$bundle += @"
OMW = OMW or {}
OMW.FireSupStratResupplyProduction = ProductionBootstrap
OMW_FSSR_PRODUCTION_BOOTSTRAP_LOADED = 1

local config = OMW.FireSupStratResupplyProductionConfig or {}
local _, started, reason = ProductionBootstrap.Start(config)
if started ~= true and reason ~= "ALREADY_STARTED" then
  error("[OMW][FireSupStratResupply.Production] bootstrap start failed: " .. tostring(reason), 0)
end
"@

foreach ($marker in @(
  'OMW.FireSupStratResupplyProduction = ProductionBootstrap',
  'OMW_FSSR_PRODUCTION_BOOTSTRAP_LOADED = 1',
  'ProductionBootstrap.Start(config)',
  'OMW_FSSR_READY',
  'OMW_FSSR_RESUPPLY_READY',
  'OMW-RESOURCE-DEMAND-POLICY-1'
)) {
  if (-not $bundle.Contains($marker)) {
    throw "Production bundle marker missing: $marker"
  }
}

[System.IO.File]::WriteAllText($output, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $output"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "GitCommit: $commit"
Write-Host "BootstrapSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-2"
Write-Host "BaseDependency: OMW_FireSupStratResupply_Base.lua loaded first"
Write-Host "ReadyFlag: OMW_FSSR_READY"
Write-Host "ResupplyReadyFlag: OMW_FSSR_RESUPPLY_READY"
Write-Host "StrategicResupplyDefault: disabled/fail-closed until production physical transport descriptor is injected"
Write-Host "BuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "BootstrapSourceSHA256: $((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ResourceDemandPolicySHA256: $((Get-FileHash -LiteralPath $resourceDemandPolicy -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "BundleSHA256: $((Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'MizMutation: false'
