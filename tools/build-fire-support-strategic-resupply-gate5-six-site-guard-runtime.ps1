[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repoRoot = Split-Path -Parent $PSScriptRoot
$siteRegistry = Join-Path $repoRoot 'scripts\campaign\OMW_FireSupStratResupply_SiteRegistry.lua'
$materializer = Join-Path $repoRoot 'scripts\ground\OMW_GuardPathlineMaterializationAdapter.lua'
$sourceFile = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5-six-site-guard-runtime\src\03-six-site-guard-production-materializer-acceptance.lua'
$outputFile = Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-gate5-six-site-guard-runtime\dist\OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua'
$registrySource = Get-Content -LiteralPath $siteRegistry -Raw -Encoding UTF8
$materializerSource = Get-Content -LiteralPath $materializer -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$bundle = "-- BuilderVersion: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-5`n-- GitCommit: $commit`n-- TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3`n-- MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- MizMutation: false`n`n"
$bundle += "local OMW_GATE5_SITE_REGISTRY = (function()`n$registrySource`nend)()`n`n"
$bundle += "local OMW_GUARD_PATHLINE_MATERIALIZATION_ADAPTER = (function()`n$materializerSource`nend)()`n`n"
$bundle += $acceptanceSource
New-Item -ItemType Directory -Path (Split-Path -Parent $outputFile) -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile, $bundle, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "BuilderVersion: FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-5"
Write-Host "GitCommit: $commit"
Write-Host "Output: $outputFile"
Write-Host "Bundle SHA-256: $((Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash)"
Write-Host "Materializer SHA-256: $((Get-FileHash -LiteralPath $materializer -Algorithm SHA256).Hash)"
Write-Host "Acceptance source SHA-256: $((Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash)"
Write-Host "MIZ mutation: false"
